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

/// Display attributes — Zig-native packing (not the C atr bitmask).
pub const Attribute = packed struct(u32) {
    bold: bool = false,
    dim: bool = false,
    italic: bool = false,
    underline: bool = false,
    double_underline: bool = false,
    blink: bool = false,
    inverse: bool = false,
    crossed_out: bool = false,
    _pad0: u4 = 0,
    /// 0 = default; 1..=256 = ANSI/256-color index+1; truecolor uses fg_rgb.
    fg_kind: ColorKind = .default,
    bg_kind: ColorKind = .default,
    fg: u8 = 0,
    bg: u8 = 0,

    pub const ColorKind = enum(u2) {
        default = 0,
        indexed = 1,
        // Reserved for truecolor path later.
        truecolor = 2,
        _unused = 3,
    };

    pub const none: Attribute = .{};

    pub fn eql(a: Attribute, b: Attribute) bool {
        return @as(u32, @bitCast(a)) == @as(u32, @bitCast(b));
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
    current_attr: Attribute = .none,
    /// Flat row-major grid: index = y * width + x
    cells: []Cell,
    /// Last flushed cells (for future cell-diff). Same shape as `cells`.
    display: []Cell,
    dirty_rows: std.DynamicBitSet,
    terminfo: ?terminfo.TermInfo = null,
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
        switch (attr.fg_kind) {
            .default => {},
            .indexed => {
                if (attr.fg < 8) {
                    try self.out.print(self.allocator, ";{d}", .{30 + attr.fg});
                } else if (attr.fg < 16) {
                    try self.out.print(self.allocator, ";{d}", .{90 + (attr.fg - 8)});
                } else {
                    try self.out.print(self.allocator, ";38;5;{d}", .{attr.fg});
                }
            },
            else => {},
        }
        switch (attr.bg_kind) {
            .default => {},
            .indexed => {
                if (attr.bg < 8) {
                    try self.out.print(self.allocator, ";{d}", .{40 + attr.bg});
                } else if (attr.bg < 16) {
                    try self.out.print(self.allocator, ";{d}", .{100 + (attr.bg - 8)});
                } else {
                    try self.out.print(self.allocator, ";48;5;{d}", .{attr.bg});
                }
            },
            else => {},
        }
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

test "Attribute packing roundtrip" {
    const a = Attribute{
        .bold = true,
        .underline = true,
        .fg_kind = .indexed,
        .fg = 2,
    };
    try testing.expect(a.bold);
    try testing.expect(a.underline);
    try testing.expect(!a.italic);
    try testing.expect(Attribute.eql(a, a));
    try testing.expect(!Attribute.eql(a, Attribute.none));
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