//! Zig-native screen buffer + escape-sequence emitter.
//!
//! Stateful cell grid with dirty-row tracking. Common operations emit
//! ANSI directly (no terminfo required for SGR/cursor/clear). Full
//! cell-diff flush is Phase 6; this module still records intended cells
//! and can emit a simple redraw of dirty rows.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;
const terminfo = @import("terminfo.zig");

/// 24-bit RGB color (direct color / truecolor terminals).
pub const Rgb = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,

    pub fn eql(a: Rgb, b: Rgb) bool {
        return a.r == b.r and a.g == b.g and a.b == b.b;
    }
};

/// Foreground/background color — default, 0–255 indexed, or 24-bit RGB.
pub const Color = union(enum) {
    default,
    indexed: u8,
    rgb: Rgb,

    pub fn eql(a: Color, b: Color) bool {
        return switch (a) {
            .default => b == .default,
            .indexed => |i| b == .indexed and b.indexed == i,
            .rgb => |rgb| b == .rgb and Rgb.eql(rgb, b.rgb),
        };
    }
};

/// Display attributes — Zig-native (not the C atr bitmask).
pub const Attribute = struct {
    bold: bool = false,
    dim: bool = false,
    italic: bool = false,
    underline: bool = false,
    double_underline: bool = false,
    blink: bool = false,
    inverse: bool = false,
    crossed_out: bool = false,
    fg: Color = .default,
    bg: Color = .default,

    pub const none: Attribute = .{};

    pub fn eql(a: Attribute, b: Attribute) bool {
        return a.bold == b.bold and a.dim == b.dim and a.italic == b.italic and a.underline == b.underline and a.double_underline == b.double_underline and a.blink == b.blink and a.inverse == b.inverse and a.crossed_out == b.crossed_out and Color.eql(a.fg, b.fg) and Color.eql(a.bg, b.bg);
    }

    pub fn fgIndexed(index: u8) Attribute {
        return .{ .fg = .{ .indexed = index } };
    }

    pub fn bgIndexed(index: u8) Attribute {
        return .{ .bg = .{ .indexed = index } };
    }

    pub fn fgRgb(r: u8, g: u8, b: u8) Attribute {
        return .{ .fg = .{ .rgb = .{ .r = r, .g = g, .b = b } } };
    }

    pub fn bgRgb(r: u8, g: u8, b: u8) Attribute {
        return .{ .bg = .{ .rgb = .{ .r = r, .g = g, .b = b } } };
    }
};

pub const Cell = struct {
    /// Unicode scalar; 0 means blank / unused / wide-continuation.
    cp: u21 = ' ',
    attr: Attribute = .none,
};

/// Terminal display columns for a Unicode scalar (East Asian Width lite).
/// 0 = combining/control, 1 = narrow, 2 = wide/fullwidth.
/// Self-contained (does not pull hybrid `unicode.zig` / unicat tables).
pub fn displayWidth(cp: u21) u8 {
    if (cp == 0) return 0;
    // C0 / DEL / C1
    if (cp < 0x20 or cp == 0x7F or (cp >= 0x80 and cp < 0xA0)) return 0;
    // Common combining marks (Mn/Me) — not exhaustive, covers BMP + a few extras.
    if (isCombining(cp)) return 0;
    if (isWide(cp)) return 2;
    return 1;
}

fn isCombining(cp: u21) bool {
    return (cp >= 0x0300 and cp <= 0x036F) // Combining Diacritical Marks
        or (cp >= 0x0483 and cp <= 0x0489)
        or (cp >= 0x0591 and cp <= 0x05BD)
        or (cp == 0x05BF)
        or (cp >= 0x05C1 and cp <= 0x05C2)
        or (cp >= 0x05C4 and cp <= 0x05C5)
        or (cp == 0x05C7)
        or (cp >= 0x0610 and cp <= 0x061A)
        or (cp >= 0x064B and cp <= 0x065F)
        or (cp == 0x0670)
        or (cp >= 0x06D6 and cp <= 0x06DC)
        or (cp >= 0x06DF and cp <= 0x06E4)
        or (cp >= 0x06E7 and cp <= 0x06E8)
        or (cp >= 0x06EA and cp <= 0x06ED)
        or (cp >= 0x0711 and cp <= 0x073F) // Syriac (loose)
        or (cp >= 0x07A6 and cp <= 0x07B0)
        or (cp >= 0x07EB and cp <= 0x07F3)
        or (cp >= 0x0816 and cp <= 0x0819)
        or (cp >= 0x081B and cp <= 0x0823)
        or (cp >= 0x0825 and cp <= 0x0827)
        or (cp >= 0x0829 and cp <= 0x082D)
        or (cp >= 0x0859 and cp <= 0x085B)
        or (cp >= 0x08D3 and cp <= 0x08E1)
        or (cp >= 0x08E3 and cp <= 0x0903)
        or (cp >= 0x093A and cp <= 0x094F)
        or (cp >= 0x0951 and cp <= 0x0957)
        or (cp >= 0x0962 and cp <= 0x0963)
        or (cp >= 0x09C1 and cp <= 0x09C4)
        or (cp >= 0x0E31 and cp <= 0x0E31)
        or (cp >= 0x0E34 and cp <= 0x0E3A)
        or (cp >= 0x0E47 and cp <= 0x0E4E)
        or (cp >= 0x0EB1 and cp <= 0x0EB1)
        or (cp >= 0x0EB4 and cp <= 0x0EBC)
        or (cp >= 0x0EC8 and cp <= 0x0ECD)
        or (cp >= 0x0F18 and cp <= 0x0F19)
        or (cp >= 0x0F35 and cp <= 0x0F35)
        or (cp >= 0x0F37 and cp <= 0x0F37)
        or (cp >= 0x0F39 and cp <= 0x0F39)
        or (cp >= 0x0F71 and cp <= 0x0F7E)
        or (cp >= 0x0F80 and cp <= 0x0F84)
        or (cp >= 0x0F86 and cp <= 0x0F87)
        or (cp >= 0x0F8D and cp <= 0x0F97)
        or (cp >= 0x0F99 and cp <= 0x0FBC)
        or (cp >= 0x1AB0 and cp <= 0x1AFF)
        or (cp >= 0x1DC0 and cp <= 0x1DFF)
        or (cp >= 0x20D0 and cp <= 0x20FF)
        or (cp >= 0xFE20 and cp <= 0xFE2F)
        or (cp >= 0xFE00 and cp <= 0xFE0F) // Variation selectors
        or (cp >= 0x16FE4 and cp <= 0x16FE4)
        or (cp >= 0x1CF00 and cp <= 0x1CF2D)
        or (cp >= 0xE0100 and cp <= 0xE01EF);
}

fn isWide(cp: u21) bool {
    // Compact East Asian Wide / Fullwidth / emoji presentation ranges.
    return (cp >= 0x1100 and cp <= 0x115F) // Hangul Jamo
        or (cp >= 0x231A and cp <= 0x231B)
        or (cp >= 0x2329 and cp <= 0x232A)
        or (cp >= 0x23E9 and cp <= 0x23EC)
        or (cp == 0x23F0)
        or (cp == 0x23F3)
        or (cp >= 0x25FD and cp <= 0x25FE)
        or (cp >= 0x2614 and cp <= 0x2615)
        or (cp >= 0x2648 and cp <= 0x2653)
        or (cp == 0x267F)
        or (cp == 0x2693)
        or (cp == 0x26A1)
        or (cp >= 0x26AA and cp <= 0x26AB)
        or (cp >= 0x26BD and cp <= 0x26BE)
        or (cp >= 0x26C4 and cp <= 0x26C5)
        or (cp == 0x26CE)
        or (cp == 0x26D4)
        or (cp == 0x26EA)
        or (cp >= 0x26F2 and cp <= 0x26F3)
        or (cp == 0x26F5)
        or (cp == 0x26FA)
        or (cp == 0x26FD)
        or (cp == 0x2705)
        or (cp >= 0x270A and cp <= 0x270B)
        or (cp == 0x2728)
        or (cp == 0x274C)
        or (cp == 0x274E)
        or (cp >= 0x2753 and cp <= 0x2755)
        or (cp == 0x2757)
        or (cp >= 0x2795 and cp <= 0x2797)
        or (cp == 0x27B0)
        or (cp == 0x27BF)
        or (cp >= 0x2B1B and cp <= 0x2B1C)
        or (cp == 0x2B50)
        or (cp == 0x2B55)
        or (cp >= 0x2E80 and cp <= 0x2FFF) // CJK radicals / Kangxi / Ideographic
        or (cp >= 0x3000 and cp <= 0x303E)
        or (cp >= 0x3040 and cp <= 0xA4CF) // Hiragana..Yi
        or (cp >= 0xA960 and cp <= 0xA97F)
        or (cp >= 0xAC00 and cp <= 0xD7A3) // Hangul Syllables
        or (cp >= 0xF900 and cp <= 0xFAFF) // CJK Compatibility Ideographs
        or (cp >= 0xFE10 and cp <= 0xFE19)
        or (cp >= 0xFE30 and cp <= 0xFE6F)
        or (cp >= 0xFF01 and cp <= 0xFF60)
        or (cp >= 0xFFE0 and cp <= 0xFFE6)
        or (cp >= 0x1F300 and cp <= 0x1F64F) // Misc symbols & pictographs / emoticons
        or (cp >= 0x1F680 and cp <= 0x1F6FF)
        or (cp >= 0x1F900 and cp <= 0x1F9FF)
        or (cp >= 0x1FA00 and cp <= 0x1FAFF)
        or (cp >= 0x20000 and cp <= 0x3FFFD); // CJK Ext B+
}

pub const Screen = struct {
    allocator: Allocator,
    width: u16,
    height: u16,
    cursor_x: u16 = 0,
    cursor_y: u16 = 0,
    /// Last position stored by `saveCursor` (logical tracking for `restoreCursor`).
    saved_cursor_x: ?u16 = null,
    saved_cursor_y: ?u16 = null,
    current_attr: Attribute = .none,
    /// Flat row-major grid: index = y * width + x
    cells: []Cell,
    /// Last flushed cells (for future cell-diff). Same shape as `cells`.
    display: []Cell,
    dirty_rows: std.DynamicBitSet,
    terminfo: ?terminfo.TermInfo = null,
    /// Inclusive scroll-region bounds (JOE `top`/`bot-1` style → last inclusive).
    scroll_top: u16 = 0,
    scroll_last: u16 = 0,
    /// Output scratch buffer (obuf-style for Phase 0–5 compatibility).
    out: std.ArrayList(u8),

    pub fn init(allocator: Allocator, width: u16, height: u16) !Screen {
        const n = @as(usize, width) * @as(usize, height);
        const cells = try allocator.alloc(Cell, n);
        errdefer allocator.free(cells);
        const display = try allocator.alloc(Cell, n);
        errdefer allocator.free(display);
        @memset(cells, .{});
        @memset(display, .{});
        var dirty = try std.DynamicBitSet.initFull(allocator, height);
        errdefer dirty.deinit();
        return .{
            .allocator = allocator,
            .width = width,
            .height = height,
            .cells = cells,
            .display = display,
            .dirty_rows = dirty,
            .scroll_last = height -| 1,
            .out = .empty,
        };
    }

    pub fn deinit(self: *Screen) void {
        self.out.deinit(self.allocator);
        self.dirty_rows.deinit();
        self.allocator.free(self.display);
        self.allocator.free(self.cells);
        self.* = undefined;
    }

    pub fn resize(self: *Screen, width: u16, height: u16) !void {
        const n = @as(usize, width) * @as(usize, height);
        const cells = try self.allocator.alloc(Cell, n);
        errdefer self.allocator.free(cells);
        const display = try self.allocator.alloc(Cell, n);
        errdefer self.allocator.free(display);
        @memset(cells, .{});
        @memset(display, .{});
        var dirty = try std.DynamicBitSet.initFull(self.allocator, height);
        errdefer dirty.deinit();

        self.allocator.free(self.cells);
        self.allocator.free(self.display);
        self.dirty_rows.deinit();

        self.width = width;
        self.height = height;
        self.cells = cells;
        self.display = display;
        self.dirty_rows = dirty;
        self.scroll_top = 0;
        self.scroll_last = height -| 1;
        self.cursor_x = @min(self.cursor_x, width -| 1);
        self.cursor_y = @min(self.cursor_y, height -| 1);
    }

    pub fn clear(self: *Screen) void {
        @memset(self.cells, .{});
        self.dirty_rows.setRangeValue(.{ .start = 0, .end = self.height }, true);
        self.out.clearRetainingCapacity();
        // Emit clear-screen + home as a fast path.
        self.out.appendSlice(self.allocator, "\x1b[2J\x1b[H") catch {};
    }

    pub fn setAttr(self: *Screen, attr: Attribute) void {
        self.current_attr = attr;
    }

    pub fn setCursor(self: *Screen, x: u16, y: u16) void {
        self.cursor_x = @min(x, self.width -| 1);
        self.cursor_y = @min(y, self.height -| 1);
    }

    fn appendRelative(
        self: *Screen,
        count: u16,
        format: *const fn (terminfo.TermInfo, u16) ?[]const u8,
        ansi_letter: u8,
    ) !void {
        if (count == 0) return;
        if (self.terminfo) |ti| {
            if (format(ti, count)) |seq| {
                if (seq.len != 0) {
                    try self.out.appendSlice(self.allocator, seq);
                    return;
                }
            }
        }
        if (count == 1) {
            try self.out.print(self.allocator, "\x1b[{c}", .{ansi_letter});
        } else {
            try self.out.print(self.allocator, "\x1b[{d}{c}", .{ count, ansi_letter });
        }
    }

    /// Move cursor up by `count` rows (clamped). Emits CUU (terminfo `cuu`/`cuu1`
    /// or ANSI `CSI n A`).
    pub fn cursorUp(self: *Screen, count: u16) !void {
        if (count == 0 or self.cursor_y == 0) return;
        const actual = @min(count, self.cursor_y);
        self.cursor_y -= actual;
        try self.appendRelative(actual, terminfo.TermInfo.formatCuu, 'A');
    }

    /// Move cursor down by `count` rows (clamped). Emits CUD (terminfo `cud`/`cud1`
    /// or ANSI `CSI n B`).
    pub fn cursorDown(self: *Screen, count: u16) !void {
        if (count == 0) return;
        const max_y = self.height -| 1;
        if (self.cursor_y >= max_y) return;
        const actual = @min(count, max_y - self.cursor_y);
        self.cursor_y += actual;
        try self.appendRelative(actual, terminfo.TermInfo.formatCud, 'B');
    }

    /// Move cursor forward/right by `count` columns (clamped). Emits CUF
    /// (terminfo `cuf`/`cuf1` or ANSI `CSI n C`).
    pub fn cursorForward(self: *Screen, count: u16) !void {
        if (count == 0) return;
        const max_x = self.width -| 1;
        if (self.cursor_x >= max_x) return;
        const actual = @min(count, max_x - self.cursor_x);
        self.cursor_x += actual;
        try self.appendRelative(actual, terminfo.TermInfo.formatCuf, 'C');
    }

    /// Move cursor back/left by `count` columns (clamped). Emits CUB
    /// (terminfo `cub`/`cub1` or ANSI `CSI n D`).
    pub fn cursorBack(self: *Screen, count: u16) !void {
        if (count == 0 or self.cursor_x == 0) return;
        const actual = @min(count, self.cursor_x);
        self.cursor_x -= actual;
        try self.appendRelative(actual, terminfo.TermInfo.formatCub, 'D');
    }

    /// Relative move by signed deltas. Emits CUU/CUD/CUF/CUB for the clamped
    /// distance actually traveled (no-op axes are skipped).
    pub fn moveBy(self: *Screen, dx: i32, dy: i32) !void {
        if (dy < 0) {
            try self.cursorUp(@intCast(-dy));
        } else if (dy > 0) {
            try self.cursorDown(@intCast(dy));
        }
        if (dx < 0) {
            try self.cursorBack(@intCast(-dx));
        } else if (dx > 0) {
            try self.cursorForward(@intCast(dx));
        }
    }

    /// Save cursor position (logical + emit terminfo `sc` or ANSI DECSC `ESC 7`).
    pub fn saveCursor(self: *Screen) !void {
        self.saved_cursor_x = self.cursor_x;
        self.saved_cursor_y = self.cursor_y;
        const seq: ?[]const u8 = if (self.terminfo) |ti| ti.caps.sc else null;
        try self.appendSeqOrAnsi(seq, "\x1b7");
    }

    /// Restore cursor position (logical from last `saveCursor` when known +
    /// emit terminfo `rc` or ANSI DECRC `ESC 8`).
    pub fn restoreCursor(self: *Screen) !void {
        if (self.saved_cursor_x) |x| {
            if (self.saved_cursor_y) |y| {
                self.cursor_x = @min(x, self.width -| 1);
                self.cursor_y = @min(y, self.height -| 1);
            }
        }
        const seq: ?[]const u8 = if (self.terminfo) |ti| ti.caps.rc else null;
        try self.appendSeqOrAnsi(seq, "\x1b8");
    }

    pub fn writeChar(self: *Screen, x: u16, y: u16, cp: u21, attr: Attribute) void {
        if (x >= self.width or y >= self.height) return;
        const idx = @as(usize, y) * @as(usize, self.width) + @as(usize, x);
        const cell = Cell{ .cp = cp, .attr = attr };
        if (self.cells[idx].cp == cell.cp and Attribute.eql(self.cells[idx].attr, cell.attr)) return;
        self.cells[idx] = cell;
        self.dirty_rows.set(y);
    }

    pub fn writeText(self: *Screen, x: u16, y: u16, text: []const u8, attr: Attribute) void {
        var col: u16 = x;
        var i: usize = 0;
        while (i < text.len and col < self.width) {
            const len = std.unicode.utf8ByteSequenceLength(text[i]) catch {
                self.writeChar(col, y, 0xFFFD, attr);
                col += 1;
                i += 1;
                continue;
            };
            if (i + len > text.len) {
                self.writeChar(col, y, 0xFFFD, attr);
                break;
            }
            const cp = std.unicode.utf8Decode(text[i..][0..len]) catch 0xFFFD;
            const w = displayWidth(cp);
            if (w == 0) {
                // Combining/control: do not advance the cursor column.
                // Cell model has no combining slot yet — skip emission.
                i += len;
                continue;
            }
            self.writeChar(col, y, cp, attr);
            if (w >= 2 and col + 1 < self.width) {
                // Reserve the next cell so subsequent text does not overlap.
                self.writeChar(col + 1, y, 0, attr);
            }
            col +|= w;
            i += len;
        }
    }

    fn appendColor(self: *Screen, color: Color, is_fg: bool) !void {
        switch (color) {
            .default => {},
            .indexed => |idx| {
                if (idx < 8) {
                    const base: u8 = if (is_fg) 30 else 40;
                    try self.out.print(self.allocator, ";{d}", .{base + idx});
                } else if (idx < 16) {
                    const base: u8 = if (is_fg) 90 else 100;
                    try self.out.print(self.allocator, ";{d}", .{base + (idx - 8)});
                } else {
                    const prefix: []const u8 = if (is_fg) ";38;5;" else ";48;5;";
                    try self.out.print(self.allocator, "{s}{d}", .{ prefix, idx });
                }
            },
            .rgb => |rgb| {
                const prefix: []const u8 = if (is_fg) ";38;2;" else ";48;2;";
                try self.out.print(self.allocator, "{s}{d};{d};{d}", .{ prefix, rgb.r, rgb.g, rgb.b });
            },
        }
    }

    fn appendAttr(self: *Screen, attr: Attribute) !void {
        // Reset then re-apply — simple and correct; optimize later.
        try self.out.appendSlice(self.allocator, "\x1b[0");
        if (attr.bold) try self.out.appendSlice(self.allocator, ";1");
        if (attr.dim) try self.out.appendSlice(self.allocator, ";2");
        if (attr.italic) try self.out.appendSlice(self.allocator, ";3");
        if (attr.underline) try self.out.appendSlice(self.allocator, ";4");
        if (attr.blink) try self.out.appendSlice(self.allocator, ";5");
        if (attr.inverse) try self.out.appendSlice(self.allocator, ";7");
        if (attr.crossed_out) try self.out.appendSlice(self.allocator, ";9");
        if (attr.double_underline) try self.out.appendSlice(self.allocator, ";21");
        try self.appendColor(attr.fg, true);
        try self.appendColor(attr.bg, false);
        try self.out.appendSlice(self.allocator, "m");
    }

    fn appendCup(self: *Screen, x: u16, y: u16) !void {
        if (self.terminfo) |ti| {
            if (ti.formatCup(x, y)) |seq| {
                try self.out.appendSlice(self.allocator, seq);
                return;
            }
        }
        // ANSI CUP is 1-based.
        try self.out.print(self.allocator, "\x1b[{d};{d}H", .{ y + 1, x + 1 });
    }

    fn appendSeqOrAnsi(self: *Screen, maybe_seq: ?[]const u8, ansi: []const u8) !void {
        if (maybe_seq) |seq| {
            try self.out.appendSlice(self.allocator, seq);
        } else {
            try self.out.appendSlice(self.allocator, ansi);
        }
    }

    /// Enter alternate screen / ca-mode. Prefers terminfo `smcup`, else ANSI `?1049h`.
    pub fn enterAltScreen(self: *Screen) !void {
        const seq: ?[]const u8 = if (self.terminfo) |ti| ti.caps.smcup else null;
        try self.appendSeqOrAnsi(seq, "\x1b[?1049h");
    }

    /// Leave alternate screen / ca-mode. Prefers terminfo `rmcup`, else ANSI `?1049l`.
    pub fn leaveAltScreen(self: *Screen) !void {
        const seq: ?[]const u8 = if (self.terminfo) |ti| ti.caps.rmcup else null;
        try self.appendSeqOrAnsi(seq, "\x1b[?1049l");
    }

    /// Enable application keypad / cursor keys (`smkx` or ANSI/xterm fallback).
    pub fn enterKeypad(self: *Screen) !void {
        const seq: ?[]const u8 = if (self.terminfo) |ti| ti.caps.smkx else null;
        try self.appendSeqOrAnsi(seq, "\x1b[?1h\x1b=");
    }

    /// Restore normal keypad / cursor keys (`rmkx` or ANSI/xterm fallback).
    pub fn leaveKeypad(self: *Screen) !void {
        const seq: ?[]const u8 = if (self.terminfo) |ti| ti.caps.rmkx else null;
        try self.appendSeqOrAnsi(seq, "\x1b[?1l\x1b>");
    }

    /// Set inclusive scroll region `[top, last]`. Emits terminfo `csr` or ANSI `CSI t;l r`.
    pub fn setScrollRegion(self: *Screen, top: u16, last: u16) !void {
        const t = @min(top, self.height -| 1);
        const l = @min(@max(last, t), self.height -| 1);
        self.scroll_top = t;
        self.scroll_last = l;
        if (self.terminfo) |ti| {
            if (ti.formatCsr(t, l)) |seq| {
                try self.out.appendSlice(self.allocator, seq);
                return;
            }
        }
        try self.out.print(self.allocator, "\x1b[{d};{d}r", .{ t + 1, l + 1 });
    }

    /// Reset scroll region to the full screen.
    pub fn resetScrollRegion(self: *Screen) !void {
        try self.setScrollRegion(0, self.height -| 1);
    }

    fn rowSlice(self: *Screen, y: u16) []Cell {
        const start = @as(usize, y) * @as(usize, self.width);
        return self.cells[start .. start + self.width];
    }

    fn markDirtyRange(self: *Screen, from: u16, to_inclusive: u16) void {
        var y: u16 = from;
        while (y <= to_inclusive) : (y += 1) {
            self.dirty_rows.set(y);
        }
    }

    /// Insert `count` blank lines at `y` within the current scroll region.
    /// Shifts cells down and emits IL (terminfo or ANSI CSI L).
    pub fn insertLines(self: *Screen, y: u16, count: u16) !void {
        if (count == 0 or y < self.scroll_top or y > self.scroll_last) return;
        const region_last = self.scroll_last;
        const n = @min(count, region_last - y + 1);

        // Shift rows down within [y, region_last].
        var src: u16 = region_last - n + 1;
        while (src > y) {
            src -= 1;
            const dst = src + n;
            if (dst <= region_last) {
                @memcpy(self.rowSlice(dst), self.rowSlice(src));
            }
        }
        var clear_y: u16 = y;
        while (clear_y < y + n) : (clear_y += 1) {
            @memset(self.rowSlice(clear_y), .{});
        }
        self.markDirtyRange(y, region_last);

        try self.appendCup(0, y);
        if (self.terminfo) |ti| {
            if (ti.formatIl(n)) |seq| {
                if (seq.len != 0) {
                    try self.out.appendSlice(self.allocator, seq);
                    return;
                }
            }
        }
        if (n == 1) {
            try self.out.appendSlice(self.allocator, "\x1b[L");
        } else {
            try self.out.print(self.allocator, "\x1b[{d}L", .{n});
        }
    }

    /// Delete `count` lines at `y` within the current scroll region.
    /// Shifts cells up and emits DL (terminfo or ANSI CSI M).
    pub fn deleteLines(self: *Screen, y: u16, count: u16) !void {
        if (count == 0 or y < self.scroll_top or y > self.scroll_last) return;
        const region_last = self.scroll_last;
        const n = @min(count, region_last - y + 1);

        var dst: u16 = y;
        while (dst + n <= region_last) : (dst += 1) {
            @memcpy(self.rowSlice(dst), self.rowSlice(dst + n));
        }
        var clear_y: u16 = region_last - n + 1;
        while (clear_y <= region_last) : (clear_y += 1) {
            @memset(self.rowSlice(clear_y), .{});
        }
        self.markDirtyRange(y, region_last);

        try self.appendCup(0, y);
        if (self.terminfo) |ti| {
            if (ti.formatDl(n)) |seq| {
                if (seq.len != 0) {
                    try self.out.appendSlice(self.allocator, seq);
                    return;
                }
            }
        }
        if (n == 1) {
            try self.out.appendSlice(self.allocator, "\x1b[M");
        } else {
            try self.out.print(self.allocator, "\x1b[{d}M", .{n});
        }
    }

    /// Clear cells from column `x` through end of row `y`, then emit EL
    /// (terminfo `el` or ANSI `CSI K`). Moves the logical cursor to `(x, y)`.
    pub fn clearToEol(self: *Screen, x: u16, y: u16) !void {
        if (y >= self.height) return;
        const start_x = @min(x, self.width);
        if (start_x < self.width) {
            const row = self.rowSlice(y);
            @memset(row[start_x..], .{});
            self.dirty_rows.set(y);
        }
        self.cursor_x = start_x;
        self.cursor_y = y;
        try self.appendCup(start_x, y);
        const seq: ?[]const u8 = if (self.terminfo) |ti| ti.caps.el else null;
        try self.appendSeqOrAnsi(seq, "\x1b[K");
    }

    /// Clear from `(x, y)` through end of screen: rest of row `y`, then all
    /// rows below. Emits ED (terminfo `ed` or ANSI `CSI J`).
    pub fn clearToEos(self: *Screen, x: u16, y: u16) !void {
        if (y >= self.height) return;
        const start_x = @min(x, self.width);
        if (start_x < self.width) {
            @memset(self.rowSlice(y)[start_x..], .{});
        }
        var clear_y: u16 = y + 1;
        while (clear_y < self.height) : (clear_y += 1) {
            @memset(self.rowSlice(clear_y), .{});
        }
        self.markDirtyRange(y, self.height -| 1);
        const cup_x = @min(start_x, self.width -| 1);
        self.cursor_x = cup_x;
        self.cursor_y = y;
        try self.appendCup(cup_x, y);
        const seq: ?[]const u8 = if (self.terminfo) |ti| ti.caps.ed else null;
        try self.appendSeqOrAnsi(seq, "\x1b[J");
    }

    /// Insert `count` blank cells at `(x, y)`, shifting the rest of the row
    /// right (cells past the right edge are dropped). Emits ICH (terminfo
    /// `ich`/`ich1` or ANSI `CSI n @`).
    pub fn insertChars(self: *Screen, x: u16, y: u16, count: u16) !void {
        if (count == 0 or y >= self.height or x >= self.width) return;
        const n = @min(count, self.width - x);
        const row = self.rowSlice(y);

        // Shift right within [x, width): copy from the end so we don't overwrite.
        var src: u16 = self.width - n;
        while (src > x) {
            src -= 1;
            row[src + n] = row[src];
        }
        @memset(row[x .. x + n], .{});
        self.dirty_rows.set(y);

        self.cursor_x = x;
        self.cursor_y = y;
        try self.appendCup(x, y);
        if (self.terminfo) |ti| {
            if (ti.formatIch(n)) |seq| {
                if (seq.len != 0) {
                    try self.out.appendSlice(self.allocator, seq);
                    return;
                }
            }
        }
        if (n == 1) {
            try self.out.appendSlice(self.allocator, "\x1b[@");
        } else {
            try self.out.print(self.allocator, "\x1b[{d}@", .{n});
        }
    }

    /// Delete `count` cells at `(x, y)`, shifting the rest of the row left and
    /// blanking the trailing columns. Emits DCH (terminfo `dch`/`dch1` or
    /// ANSI `CSI n P`).
    pub fn deleteChars(self: *Screen, x: u16, y: u16, count: u16) !void {
        if (count == 0 or y >= self.height or x >= self.width) return;
        const n = @min(count, self.width - x);
        const row = self.rowSlice(y);

        var dst: u16 = x;
        while (dst + n < self.width) : (dst += 1) {
            row[dst] = row[dst + n];
        }
        @memset(row[self.width - n ..], .{});
        self.dirty_rows.set(y);

        self.cursor_x = x;
        self.cursor_y = y;
        try self.appendCup(x, y);
        if (self.terminfo) |ti| {
            if (ti.formatDch(n)) |seq| {
                if (seq.len != 0) {
                    try self.out.appendSlice(self.allocator, seq);
                    return;
                }
            }
        }
        if (n == 1) {
            try self.out.appendSlice(self.allocator, "\x1b[P");
        } else {
            try self.out.print(self.allocator, "\x1b[{d}P", .{n});
        }
    }

    /// Emit dirty rows to `out`, then copy cells → display and clear dirty bits.
    /// Does not write to a TTY — caller drains `out` / `takeOut()`.
    pub fn flush(self: *Screen) !void {
        var y: usize = 0;
        while (y < self.height) : (y += 1) {
            if (!self.dirty_rows.isSet(y)) continue;
            try self.appendCup(0, @intCast(y));
            var prev: ?Attribute = null;
            var x: u16 = 0;
            while (x < self.width) {
                const idx = y * @as(usize, self.width) + @as(usize, x);
                const cell = self.cells[idx];
                // Skip wide-continuation cells (cp==0 after a width-2 glyph).
                if (cell.cp == 0 and x > 0) {
                    const prev_idx = idx - 1;
                    if (self.cells[prev_idx].cp != 0 and displayWidth(self.cells[prev_idx].cp) >= 2) {
                        self.display[idx] = cell;
                        x += 1;
                        continue;
                    }
                }
                if (prev == null or !Attribute.eql(prev.?, cell.attr)) {
                    try self.appendAttr(cell.attr);
                    prev = cell.attr;
                }
                var utf8_buf: [4]u8 = undefined;
                const cp: u21 = if (cell.cp == 0) ' ' else cell.cp;
                const len = std.unicode.utf8Encode(cp, &utf8_buf) catch blk: {
                    utf8_buf[0] = '?';
                    break :blk @as(usize, 1);
                };
                try self.out.appendSlice(self.allocator, utf8_buf[0..len]);
                self.display[idx] = cell;
                x += 1;
            }
            self.dirty_rows.unset(y);
        }
        try self.appendCup(self.cursor_x, self.cursor_y);
        try self.appendAttr(self.current_attr);
    }

    pub fn takeOut(self: *Screen) []u8 {
        return self.out.items;
    }

    pub fn clearOut(self: *Screen) void {
        self.out.clearRetainingCapacity();
    }
};

test "Attribute color helpers roundtrip" {
    const a = Attribute{
        .bold = true,
        .underline = true,
        .fg = .{ .indexed = 2 },
    };
    try testing.expect(a.bold);
    try testing.expect(a.underline);
    try testing.expect(!a.italic);
    try testing.expect(Attribute.eql(a, a));
    try testing.expect(!Attribute.eql(a, Attribute.none));
    try testing.expect(Color.eql(Attribute.fgIndexed(2).fg, .{ .indexed = 2 }));
    try testing.expect(Color.eql(Attribute.fgRgb(1, 2, 3).fg, .{ .rgb = .{ .r = 1, .g = 2, .b = 3 } }));
}

test "Screen write + flush emits CUP and text" {
    var screen = try Screen.init(testing.allocator, 10, 3);
    defer screen.deinit();

    screen.writeText(0, 1, "Hi", .{ .bold = true });
    screen.setCursor(2, 1);
    try screen.flush();

    const out = screen.takeOut();
    try testing.expect(std.mem.indexOf(u8, out, "Hi") != null);
    // Row 2 (1-based) CUP somewhere in the stream.
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[2;") != null);
    // Bold SGR.
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[0;1") != null);

    // Second flush with no changes should emit only cursor/attr restore.
    screen.clearOut();
    try screen.flush();
    try testing.expect(std.mem.indexOf(u8, out, "Hi") == null or screen.takeOut().len < 32);
}

test "Screen.clear marks all dirty and queues ED" {
    var screen = try Screen.init(testing.allocator, 4, 2);
    defer screen.deinit();
    screen.clear();
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[2J") != null);
    try testing.expect(screen.dirty_rows.isSet(0));
    try testing.expect(screen.dirty_rows.isSet(1));
}

test "Screen.writeText decodes UTF-8 codepoints" {
    var screen = try Screen.init(testing.allocator, 8, 1);
    defer screen.deinit();

    // "A" + U+00E9 (é, width 1) + U+1F4A9 (💩, width 2) — emoji reserves next cell.
    screen.writeText(0, 0, "A\u{e9}\u{1f4a9}", .none);
    try testing.expectEqual(@as(u21, 'A'), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, 0xE9), screen.cells[1].cp);
    try testing.expectEqual(@as(u21, 0x1F4A9), screen.cells[2].cp);
    try testing.expectEqual(@as(u21, 0), screen.cells[3].cp); // wide continuation

    try screen.flush();
    const out = screen.takeOut();
    try testing.expect(std.mem.indexOf(u8, out, "A") != null);
    try testing.expect(std.mem.indexOf(u8, out, "\u{e9}") != null);
    try testing.expect(std.mem.indexOf(u8, out, "\u{1f4a9}") != null);
}

test "Screen.writeText replaces invalid UTF-8 with U+FFFD" {
    var screen = try Screen.init(testing.allocator, 4, 1);
    defer screen.deinit();
    screen.writeText(0, 0, &[_]u8{ 0x80, 'x' }, .none);
    try testing.expectEqual(@as(u21, 0xFFFD), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, 'x'), screen.cells[1].cp);
}

test "displayWidth narrow wide combining" {
    try testing.expectEqual(@as(u8, 1), displayWidth('A'));
    try testing.expectEqual(@as(u8, 1), displayWidth(0xE9)); // é
    try testing.expectEqual(@as(u8, 2), displayWidth(0x4E00)); // 一
    try testing.expectEqual(@as(u8, 2), displayWidth(0x1F4A9)); // 💩
    try testing.expectEqual(@as(u8, 0), displayWidth(0x0301)); // combining acute
    try testing.expectEqual(@as(u8, 0), displayWidth(0x07)); // BEL
}

test "Screen.writeText advances by display width" {
    var screen = try Screen.init(testing.allocator, 6, 1);
    defer screen.deinit();
    // "A" + CJK "字" (wide) + "B"
    screen.writeText(0, 0, "A\u{5b57}B", .none);
    try testing.expectEqual(@as(u21, 'A'), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, 0x5B57), screen.cells[1].cp);
    try testing.expectEqual(@as(u21, 0), screen.cells[2].cp);
    try testing.expectEqual(@as(u21, 'B'), screen.cells[3].cp);
}

test "Screen.appendCup uses ANSI without terminfo" {
    var screen = try Screen.init(testing.allocator, 4, 2);
    defer screen.deinit();
    try testing.expect(screen.terminfo == null);
    screen.writeText(0, 0, "x", .none);
    try screen.flush();
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[1;1H") != null);
}

test "Screen flush emits truecolor SGR" {
    var screen = try Screen.init(testing.allocator, 4, 1);
    defer screen.deinit();
    const attr = Attribute{
        .fg = .{ .rgb = .{ .r = 10, .g = 20, .b = 30 } },
        .bg = .{ .rgb = .{ .r = 40, .g = 50, .b = 60 } },
    };
    screen.writeText(0, 0, "x", attr);
    try screen.flush();
    const out = screen.takeOut();
    try testing.expect(std.mem.indexOf(u8, out, ";38;2;10;20;30") != null);
    try testing.expect(std.mem.indexOf(u8, out, ";48;2;40;50;60") != null);
}

test "Screen flush emits indexed 256-color SGR" {
    var screen = try Screen.init(testing.allocator, 4, 1);
    defer screen.deinit();
    screen.writeText(0, 0, "x", Attribute.fgIndexed(196));
    try screen.flush();
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), ";38;5;196") != null);
}

test "Screen alt-screen and keypad ANSI fallbacks" {
    var screen = try Screen.init(testing.allocator, 4, 2);
    defer screen.deinit();
    try testing.expect(screen.terminfo == null);

    try screen.enterAltScreen();
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "?1049h") != null);
    screen.clearOut();
    try screen.leaveAltScreen();
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "?1049l") != null);
    screen.clearOut();
    try screen.enterKeypad();
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "?1h") != null);
    screen.clearOut();
    try screen.leaveKeypad();
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "?1l") != null);
}

test "Screen.setScrollRegion emits ANSI DECSTBM" {
    var screen = try Screen.init(testing.allocator, 4, 10);
    defer screen.deinit();
    try screen.setScrollRegion(2, 7);
    try testing.expectEqual(@as(u16, 2), screen.scroll_top);
    try testing.expectEqual(@as(u16, 7), screen.scroll_last);
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[3;8r") != null);
    screen.clearOut();
    try screen.resetScrollRegion();
    try testing.expectEqual(@as(u16, 0), screen.scroll_top);
    try testing.expectEqual(@as(u16, 9), screen.scroll_last);
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[1;10r") != null);
}

test "Screen.insertLines shifts cells and emits IL" {
    var screen = try Screen.init(testing.allocator, 3, 4);
    defer screen.deinit();
    screen.writeText(0, 0, "A", .none);
    screen.writeText(0, 1, "B", .none);
    screen.writeText(0, 2, "C", .none);
    screen.writeText(0, 3, "D", .none);
    screen.clearOut();

    try screen.insertLines(1, 1);
    try testing.expectEqual(@as(u21, 'A'), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[3].cp); // blank inserted row
    try testing.expectEqual(@as(u21, 'B'), screen.cells[6].cp);
    try testing.expectEqual(@as(u21, 'C'), screen.cells[9].cp);
    // D pushed off
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[L") != null);
}

test "Screen.deleteLines shifts cells and emits DL" {
    var screen = try Screen.init(testing.allocator, 3, 4);
    defer screen.deinit();
    screen.writeText(0, 0, "A", .none);
    screen.writeText(0, 1, "B", .none);
    screen.writeText(0, 2, "C", .none);
    screen.writeText(0, 3, "D", .none);
    screen.clearOut();

    try screen.deleteLines(1, 1);
    try testing.expectEqual(@as(u21, 'A'), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, 'C'), screen.cells[3].cp);
    try testing.expectEqual(@as(u21, 'D'), screen.cells[6].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[9].cp); // blank at bottom
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[M") != null);
}

test "Screen.clearToEol clears tail and emits EL" {
    var screen = try Screen.init(testing.allocator, 5, 2);
    defer screen.deinit();
    screen.writeText(0, 0, "ABCDE", .none);
    screen.writeText(0, 1, "fghij", .none);
    screen.clearOut();

    try screen.clearToEol(2, 0);
    try testing.expectEqual(@as(u21, 'A'), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, 'B'), screen.cells[1].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[2].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[4].cp);
    try testing.expectEqual(@as(u21, 'f'), screen.cells[5].cp); // other row untouched
    try testing.expectEqual(@as(u16, 2), screen.cursor_x);
    try testing.expectEqual(@as(u16, 0), screen.cursor_y);
    const out = screen.takeOut();
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[1;3H") != null);
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[K") != null);
}

test "Screen.clearToEos clears below and emits ED" {
    var screen = try Screen.init(testing.allocator, 3, 3);
    defer screen.deinit();
    screen.writeText(0, 0, "ABC", .none);
    screen.writeText(0, 1, "DEF", .none);
    screen.writeText(0, 2, "GHI", .none);
    screen.clearOut();

    try screen.clearToEos(1, 1);
    try testing.expectEqual(@as(u21, 'A'), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, 'D'), screen.cells[3].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[4].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[5].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[6].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[8].cp);
    try testing.expectEqual(@as(u16, 1), screen.cursor_x);
    try testing.expectEqual(@as(u16, 1), screen.cursor_y);
    const out = screen.takeOut();
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[2;2H") != null);
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[J") != null);
}


test "Screen.insertChars shifts cells and emits ICH" {
    var screen = try Screen.init(testing.allocator, 5, 2);
    defer screen.deinit();
    screen.writeText(0, 0, "ABCDE", .none);
    screen.writeText(0, 1, "vwxyz", .none);
    screen.clearOut();

    try screen.insertChars(1, 0, 2);
    try testing.expectEqual(@as(u21, 'A'), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[1].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[2].cp);
    try testing.expectEqual(@as(u21, 'B'), screen.cells[3].cp);
    try testing.expectEqual(@as(u21, 'C'), screen.cells[4].cp); // D,E dropped
    try testing.expectEqual(@as(u21, 'v'), screen.cells[5].cp); // other row untouched
    try testing.expectEqual(@as(u16, 1), screen.cursor_x);
    try testing.expectEqual(@as(u16, 0), screen.cursor_y);
    const out = screen.takeOut();
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[1;2H") != null);
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[2@") != null);
}

test "Screen.deleteChars shifts cells and emits DCH" {
    var screen = try Screen.init(testing.allocator, 5, 2);
    defer screen.deinit();
    screen.writeText(0, 0, "ABCDE", .none);
    screen.writeText(0, 1, "vwxyz", .none);
    screen.clearOut();

    try screen.deleteChars(1, 0, 2);
    try testing.expectEqual(@as(u21, 'A'), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, 'D'), screen.cells[1].cp);
    try testing.expectEqual(@as(u21, 'E'), screen.cells[2].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[3].cp);
    try testing.expectEqual(@as(u21, ' '), screen.cells[4].cp);
    try testing.expectEqual(@as(u21, 'v'), screen.cells[5].cp); // other row untouched
    try testing.expectEqual(@as(u16, 1), screen.cursor_x);
    try testing.expectEqual(@as(u16, 0), screen.cursor_y);
    const out = screen.takeOut();
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[1;2H") != null);
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[2P") != null);
}

test "Screen.insertChars count one emits bare CSI @" {
    var screen = try Screen.init(testing.allocator, 3, 1);
    defer screen.deinit();
    screen.writeText(0, 0, "ABC", .none);
    screen.clearOut();
    try screen.insertChars(0, 0, 1);
    try testing.expectEqual(@as(u21, ' '), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, 'A'), screen.cells[1].cp);
    try testing.expectEqual(@as(u21, 'B'), screen.cells[2].cp);
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[@") != null);
}

test "Screen relative cursor CUU/CUD/CUF/CUB ANSI fallbacks" {
    var screen = try Screen.init(testing.allocator, 10, 8);
    defer screen.deinit();
    try testing.expect(screen.terminfo == null);

    screen.setCursor(5, 4);
    try screen.cursorUp(2);
    try testing.expectEqual(@as(u16, 5), screen.cursor_x);
    try testing.expectEqual(@as(u16, 2), screen.cursor_y);
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[2A") != null);
    screen.clearOut();

    try screen.cursorDown(3);
    try testing.expectEqual(@as(u16, 5), screen.cursor_y);
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[3B") != null);
    screen.clearOut();

    try screen.cursorForward(2);
    try testing.expectEqual(@as(u16, 7), screen.cursor_x);
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[2C") != null);
    screen.clearOut();

    try screen.cursorBack(4);
    try testing.expectEqual(@as(u16, 3), screen.cursor_x);
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[4D") != null);
    screen.clearOut();

    // count==1 uses bare CSI letter
    try screen.cursorUp(1);
    try testing.expectEqual(@as(u16, 4), screen.cursor_y);
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[A") != null);
}

test "Screen relative cursor clamps and skips zero moves" {
    var screen = try Screen.init(testing.allocator, 5, 4);
    defer screen.deinit();

    screen.setCursor(0, 0);
    try screen.cursorUp(3);
    try testing.expectEqual(@as(u16, 0), screen.cursor_y);
    try testing.expectEqual(@as(usize, 0), screen.takeOut().len);

    screen.setCursor(4, 3);
    try screen.cursorDown(9);
    try testing.expectEqual(@as(u16, 3), screen.cursor_y);
    try testing.expectEqual(@as(usize, 0), screen.takeOut().len);

    try screen.cursorForward(9);
    try testing.expectEqual(@as(u16, 4), screen.cursor_x);
    try testing.expectEqual(@as(usize, 0), screen.takeOut().len);

    screen.setCursor(1, 1);
    try screen.cursorBack(5); // only 1 column available
    try testing.expectEqual(@as(u16, 0), screen.cursor_x);
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b[D") != null);
}

test "Screen.moveBy combines axes" {
    var screen = try Screen.init(testing.allocator, 10, 10);
    defer screen.deinit();
    screen.setCursor(4, 4);
    try screen.moveBy(-2, 3);
    try testing.expectEqual(@as(u16, 2), screen.cursor_x);
    try testing.expectEqual(@as(u16, 7), screen.cursor_y);
    const out = screen.takeOut();
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[3B") != null);
    try testing.expect(std.mem.indexOf(u8, out, "\x1b[2D") != null);
}

test "Screen.saveCursor and restoreCursor ANSI DECSC/DECRC" {
    var screen = try Screen.init(testing.allocator, 10, 6);
    defer screen.deinit();
    try testing.expect(screen.terminfo == null);

    screen.setCursor(3, 2);
    try screen.saveCursor();
    try testing.expectEqual(@as(?u16, 3), screen.saved_cursor_x);
    try testing.expectEqual(@as(?u16, 2), screen.saved_cursor_y);
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b7") != null);
    screen.clearOut();

    screen.setCursor(8, 5);
    try screen.restoreCursor();
    try testing.expectEqual(@as(u16, 3), screen.cursor_x);
    try testing.expectEqual(@as(u16, 2), screen.cursor_y);
    try testing.expect(std.mem.indexOf(u8, screen.takeOut(), "\x1b8") != null);
}