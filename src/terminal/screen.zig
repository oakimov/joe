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
    /// Unicode scalar; 0 means blank / unused.
    cp: u21 = ' ',
    attr: Attribute = .none,
};

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
            self.writeChar(col, y, cp, attr);
            // Display-column advance: East Asian wide width lands in Phase 6/unicode.
            col +|= 1;
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
            while (x < self.width) : (x += 1) {
                const idx = y * @as(usize, self.width) + @as(usize, x);
                const cell = self.cells[idx];
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

    // "A" + U+00E9 (é) + U+1F4A9 (💩, 4-byte) — each advances one cell for now.
    screen.writeText(0, 0, "A\u{e9}\u{1f4a9}", .none);
    try testing.expectEqual(@as(u21, 'A'), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, 0xE9), screen.cells[1].cp);
    try testing.expectEqual(@as(u21, 0x1F4A9), screen.cells[2].cp);

    try screen.flush();
    const out = screen.takeOut();
    try testing.expect(std.mem.indexOf(u8, out, "A") != null);
    try testing.expect(std.mem.indexOf(u8, out, "\u{e9}") != null);
}

test "Screen.writeText replaces invalid UTF-8 with U+FFFD" {
    var screen = try Screen.init(testing.allocator, 4, 1);
    defer screen.deinit();
    screen.writeText(0, 0, &[_]u8{ 0x80, 'x' }, .none);
    try testing.expectEqual(@as(u21, 0xFFFD), screen.cells[0].cp);
    try testing.expectEqual(@as(u21, 'x'), screen.cells[1].cp);
}