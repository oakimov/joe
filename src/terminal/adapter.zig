//! Thin hybrid ↔ Zig-native adapter spike (Phase 3 redesign).
//!
//! Bridges JOE's packed `int` attribute bits (`joe/scrn.h`, non-MSDOS layout)
//! and the redesign `Attribute`/`Color` types, plus an obuf-style output sink
//! that can drain `Screen.out` (unit tests / Path B only — not wired into live paint).

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;
const screen = @import("screen.zig");

pub const Attribute = screen.Attribute;
pub const Color = screen.Color;
pub const Rgb = screen.Rgb;
pub const Screen = screen.Screen;

/// JOE packed attribute bits (non-`__MSDOS__` layout from `joe/scrn.h`).
pub const Hybrid = struct {
    pub const CONTEXT_COMMENT: i32 = 1;
    pub const CONTEXT_STRING: i32 = 2;
    pub const CONTEXT_MASK: i32 = CONTEXT_COMMENT + CONTEXT_STRING;

    pub const DOUBLE_UNDERLINE: i32 = 8;
    pub const CROSSED_OUT: i32 = 16;
    pub const ITALIC: i32 = 32;
    pub const INVERSE: i32 = 64;
    pub const UNDERLINE: i32 = 128;
    pub const BOLD: i32 = 256;
    pub const BLINK: i32 = 512;
    pub const DIM: i32 = 1024;
    pub const AT_MASK: i32 = INVERSE + UNDERLINE + BOLD + BLINK + DIM + ITALIC + DOUBLE_UNDERLINE + CROSSED_OUT;

    pub const BG_SHIFT: u5 = 11;
    pub const BG_VALUE: i32 = 255 << BG_SHIFT;
    pub const BG_NOT_DEFAULT: i32 = 256 << BG_SHIFT;
    pub const BG_TRUECOLOR: i32 = 512 << BG_SHIFT;
    pub const BG_MASK: i32 = 1023 << BG_SHIFT;

    pub const FG_SHIFT: u5 = 21;
    pub const FG_VALUE: i32 = 255 << FG_SHIFT;
    pub const FG_NOT_DEFAULT: i32 = 256 << FG_SHIFT;
    pub const FG_TRUECOLOR: i32 = 512 << FG_SHIFT;
    pub const FG_MASK: i32 = 1023 << FG_SHIFT;
};

/// Growing truecolor palette used when encoding RGB → hybrid atr.
/// Indices start at 1 (JOE `build_palette` convention); slot 0 unused.
pub const TruecolorPalette = struct {
    /// Packed 0xRRGGBB; `null` = empty slot.
    slots: [256]?u24 = .{null} ** 256,
    /// Next free index (1..255).
    next: u8 = 1,

    pub fn intern(self: *TruecolorPalette, rgb: Rgb) error{PaletteFull}!u8 {
        const packed_rgb: u24 = (@as(u24, rgb.r) << 16) | (@as(u24, rgb.g) << 8) | rgb.b;
        var i: u8 = 1;
        while (i < self.next) : (i += 1) {
            if (self.slots[i] == packed_rgb) return i;
        }
        if (self.next == 0) return error.PaletteFull; // wrapped past 255
        const idx = self.next;
        self.slots[idx] = packed_rgb;
        self.next +%= 1;
        return idx;
    }

    /// JOE-style `int` palette view (`-1` = unused) for `attributeFromHybrid`.
    pub fn asJoeSlice(self: *const TruecolorPalette, buf: *[256]i32) []const i32 {
        for (buf, 0..) |*slot, i| {
            if (self.slots[i]) |rgb| {
                slot.* = @intCast(rgb);
            } else {
                slot.* = -1;
            }
        }
        return buf[0..@max(@as(usize, self.next), 1)];
    }
};

fn decodeColor(atr: i32, not_default: i32, truecolor: i32, value_mask: i32, shift: u5, palette: ?[]const i32) Color {
    if ((atr & not_default) == 0) return .default;
    const idx: u8 = @truncate(@as(u32, @bitCast((atr & value_mask) >> shift)));
    if ((atr & truecolor) != 0) {
        if (palette) |pal| {
            if (idx < pal.len and pal[idx] >= 0) {
                const rgb: u32 = @intCast(pal[idx]);
                return .{ .rgb = .{
                    .r = @truncate(rgb >> 16),
                    .g = @truncate(rgb >> 8),
                    .b = @truncate(rgb),
                } };
            }
        }
        // No resolvable palette entry — keep the raw index rather than dropping color.
        return .{ .indexed = idx };
    }
    return .{ .indexed = idx };
}

fn encodeColor(color: Color, not_default: i32, truecolor: i32, shift: u5, palette: ?*TruecolorPalette) error{PaletteFull}!struct { bits: i32, rgb: ?u24 } {
    return switch (color) {
        .default => .{ .bits = 0, .rgb = null },
        .indexed => |idx| .{
            .bits = not_default | (@as(i32, idx) << shift),
            .rgb = null,
        },
        .rgb => |rgb| {
            const pal = palette orelse {
                // Without a palette, fall back to dropping RGB (caller should pass one).
                return .{ .bits = 0, .rgb = null };
            };
            const idx = try pal.intern(rgb);
            const packed_rgb: u24 = (@as(u24, rgb.r) << 16) | (@as(u24, rgb.g) << 8) | rgb.b;
            return .{
                .bits = not_default | truecolor | (@as(i32, idx) << shift),
                .rgb = packed_rgb,
            };
        },
    };
}

/// Decode JOE packed atr → Zig-native `Attribute`.
/// `palette` is optional JOE truecolor palette (`palette[i]` = 0xRRGGBB, or `-1`).
/// Context bits (`CONTEXT_*`) are ignored (not part of display Attribute).
pub fn attributeFromHybrid(atr: i32, palette: ?[]const i32) Attribute {
    return .{
        .bold = (atr & Hybrid.BOLD) != 0,
        .dim = (atr & Hybrid.DIM) != 0,
        .italic = (atr & Hybrid.ITALIC) != 0,
        .underline = (atr & Hybrid.UNDERLINE) != 0,
        .double_underline = (atr & Hybrid.DOUBLE_UNDERLINE) != 0,
        .blink = (atr & Hybrid.BLINK) != 0,
        .inverse = (atr & Hybrid.INVERSE) != 0,
        .crossed_out = (atr & Hybrid.CROSSED_OUT) != 0,
        .fg = decodeColor(atr, Hybrid.FG_NOT_DEFAULT, Hybrid.FG_TRUECOLOR, Hybrid.FG_VALUE, Hybrid.FG_SHIFT, palette),
        .bg = decodeColor(atr, Hybrid.BG_NOT_DEFAULT, Hybrid.BG_TRUECOLOR, Hybrid.BG_VALUE, Hybrid.BG_SHIFT, palette),
    };
}

/// True when `-cursor` is the default inverse-only style (no fg/bg, no other
/// style bits). Matches builtin default and schemes that omit `-cursor`.
pub fn cursorStyleIsInverseOnly(bg_cursor: i32) bool {
    if ((bg_cursor & (Hybrid.FG_MASK | Hybrid.BG_MASK)) != 0) return false;
    const style = bg_cursor & Hybrid.AT_MASK;
    return style == 0 or style == Hybrid.INVERSE;
}

/// Soft-cursor attribute for the caret cell.
///
/// Hardware cursor stays visible (and may blink when idle). `-selection` and
/// `-cursor` both default to `INVERSE`, so the caret vanishes inside a mark.
/// For inverse-only `-cursor`, clear inverse + underline (readable hole / bare
/// underline on blanks). Colored `-cursor` schemes replace attrs.
pub fn applySoftCursorAttr(cell: Attribute, bg_cursor: i32, palette: ?[]const i32) Attribute {
    if (cursorStyleIsInverseOnly(bg_cursor)) {
        if (!cell.inverse) return cell;
        var a = cell;
        a.inverse = false;
        a.underline = true;
        return a;
    }
    return attributeFromHybrid(bg_cursor, palette);
}

/// True for cells with no visible glyph (spaces, tabs, empty/unknown).
pub fn isSoftCursorBlankCp(cp: u21) bool {
    return cp == 0 or cp == ' ' or cp == '\t';
}

/// Soft-cursor cell. Inverse-only `-cursor`: no-op outside selection.
/// - Text: clear inverse + underline (letter stays readable in the mark).
/// - Blank: clear inverse + underline on a space — caret is only the underline
///   (no block glyph) against the surrounding selection inverse.
/// Colored `-cursor`: replace attrs only.
pub fn applySoftCursorCell(cell: screen.Cell, bg_cursor: i32, palette: ?[]const i32) screen.Cell {
    if (cursorStyleIsInverseOnly(bg_cursor) and !cell.attr.inverse) {
        return cell;
    }
    if (!cursorStyleIsInverseOnly(bg_cursor)) {
        var out = cell;
        out.attr = attributeFromHybrid(bg_cursor, palette);
        return out;
    }
    var out = cell;
    if (isSoftCursorBlankCp(cell.cp)) {
        // Normalize tabs/empty to space; punch a hole so only underline shows.
        out.cp = ' ';
        out.combine = .{0} ** screen.COMPOSE_MARKS;
    }
    out.attr = applySoftCursorAttr(cell.attr, bg_cursor, palette);
    return out;
}

/// True when soft-cursor changed the cell (i.e. caret is inside a selection or
/// using a colored `-cursor` scheme). Callers hide the hardware cursor then so
/// it cannot cancel the soft paint on text.
pub fn softCursorApplied(before: screen.Cell, after: screen.Cell) bool {
    return !screen.Cell.eql(before, after);
}

/// Encode Zig-native `Attribute` → JOE packed atr.
/// RGB colors are interned into `palette` when provided; without a palette, RGB
/// channels become `.default` (styles + indexed still encode).
pub fn attributeToHybrid(attr: Attribute, palette: ?*TruecolorPalette) error{PaletteFull}!i32 {
    var atr: i32 = 0;
    if (attr.bold) atr |= Hybrid.BOLD;
    if (attr.dim) atr |= Hybrid.DIM;
    if (attr.italic) atr |= Hybrid.ITALIC;
    if (attr.underline) atr |= Hybrid.UNDERLINE;
    if (attr.double_underline) atr |= Hybrid.DOUBLE_UNDERLINE;
    if (attr.blink) atr |= Hybrid.BLINK;
    if (attr.inverse) atr |= Hybrid.INVERSE;
    if (attr.crossed_out) atr |= Hybrid.CROSSED_OUT;

    const fg = try encodeColor(attr.fg, Hybrid.FG_NOT_DEFAULT, Hybrid.FG_TRUECOLOR, Hybrid.FG_SHIFT, palette);
    const bg = try encodeColor(attr.bg, Hybrid.BG_NOT_DEFAULT, Hybrid.BG_TRUECOLOR, Hybrid.BG_SHIFT, palette);
    atr |= fg.bits;
    atr |= bg.bits;
    return atr;
}

/// Obuf-style output sink: buffers bytes and flushes via a callback when full
/// or when `flush` is called — mirrors hybrid `ttputc`/`ttputs`/`ttflsh`
/// without importing hybrid `src/tty.zig`.
pub const OutSink = struct {
    buf: []u8,
    pos: usize = 0,
    /// Bytes accepted by the last flush callback (for tests / metrics).
    flushed_total: usize = 0,
    write_all: *const fn (ctx: *anyopaque, bytes: []const u8) anyerror!void,
    ctx: *anyopaque,

    pub fn init(buf: []u8, ctx: *anyopaque, write_all: *const fn (*anyopaque, []const u8) anyerror!void) OutSink {
        return .{ .buf = buf, .ctx = ctx, .write_all = write_all };
    }

    pub fn putc(self: *OutSink, c: u8) !void {
        self.buf[self.pos] = c;
        self.pos += 1;
        if (self.pos == self.buf.len) try self.flush();
    }

    pub fn puts(self: *OutSink, s: []const u8) !void {
        var i: usize = 0;
        while (i < s.len) {
            const space = self.buf.len - self.pos;
            const n = @min(space, s.len - i);
            @memcpy(self.buf[self.pos..][0..n], s[i..][0..n]);
            self.pos += n;
            i += n;
            if (self.pos == self.buf.len) try self.flush();
        }
    }

    pub fn flush(self: *OutSink) !void {
        if (self.pos == 0) return;
        try self.write_all(self.ctx, self.buf[0..self.pos]);
        self.flushed_total += self.pos;
        self.pos = 0;
    }
};

/// Drain `Screen.out` into an `OutSink`, then clear the screen out buffer.
pub fn drainScreenOut(scr: *Screen, sink: *OutSink) !void {
    const bytes = scr.takeOut();
    if (bytes.len != 0) try sink.puts(bytes);
    scr.clearOut();
    try sink.flush();
}

/// Gated variant for Path B / unit tests.
/// When `enabled` is false, leaves `Screen.out` untouched and returns `false`.
/// When true, drains via `drainScreenOut` and returns `true`.
pub fn drainScreenOutGated(scr: *Screen, sink: *OutSink, enabled: bool) !bool {
    if (!enabled) return false;
    try drainScreenOut(scr, sink);
    return true;
}

/// Pure helper mirroring hybrid `ttputc` → `obuf` growth/flush behaviour.
/// Used by unit tests and documents the contract hybrid `ttputs`/`obuf` must match.
pub fn writeIntoObuf(
    obuf: []u8,
    obufp: *usize,
    bytes: []const u8,
    flush: *const fn (*anyopaque) void,
    flush_ctx: *anyopaque,
) void {
    for (bytes) |c| {
        obuf[obufp.*] = c;
        obufp.* += 1;
        if (obufp.* == obuf.len) {
            flush(flush_ctx);
            obufp.* = 0;
        }
    }
}


/// Sync hybrid `SCRN.scrn`/`attr` shadow grid into a redesign `Screen`.
///
/// `cells` is row-major `COMPOSE=4` int cells (base + up to 3 combining marks).
/// Negative sentinels (JOE "unknown") become continuation/`cp=0`; the JOE
/// erase-eol `'\n'` marker becomes a blank space. `width`/`height` are the
/// hybrid grid dimensions (may exceed `scr` — excess is clipped).
pub fn syncHybridGridToScreen(
    scr: *Screen,
    cells: [*]const [4]i32,
    attrs: [*]const i32,
    width: usize,
    height: usize,
    palette: ?[]const i32,
) void {
    const w = @min(width, @as(usize, scr.width));
    const h = @min(height, @as(usize, scr.height));
    var y: usize = 0;
    while (y < h) : (y += 1) {
        var x: usize = 0;
        while (x < w) : (x += 1) {
            const idx = y * width + x;
            const raw = cells[idx][0];
            const atr = attrs[idx];
            const cp: u21 = if (raw < 0)
                0
            else if (raw == '\n')
                ' '
            else
                @intCast(raw);
            const attr = attributeFromHybrid(atr, palette);
            var combine: [screen.COMPOSE_MARKS]u21 = .{0} ** screen.COMPOSE_MARKS;
            var ci: usize = 0;
            while (ci < screen.COMPOSE_MARKS) : (ci += 1) {
                const mark = cells[idx][ci + 1];
                if (mark > 0) combine[ci] = @intCast(mark);
            }
            scr.writeCell(@intCast(x), @intCast(y), .{ .cp = cp, .combine = combine, .attr = attr });
        }
    }
}

// --- tests ---

test "soft cursor clears inverse and underlines selected cell" {
    const selected = Attribute{ .inverse = true, .bold = true };
    const out = applySoftCursorAttr(selected, Hybrid.INVERSE, null);
    try testing.expect(!out.inverse);
    try testing.expect(out.underline);
    try testing.expect(out.bold);
}

test "soft cursor leaves normal cell alone for hardware cursor" {
    const normal = Attribute{ .underline = true };
    const out = applySoftCursorAttr(normal, Hybrid.INVERSE, null);
    try testing.expect(!out.inverse);
    try testing.expect(out.underline);
    try testing.expect(Attribute.eql(out, normal));
}

test "soft cursor blank cell uses underline-only hole inside selection" {
    const selected_space = screen.Cell{ .cp = ' ', .attr = .{ .inverse = true } };
    const out = applySoftCursorCell(selected_space, Hybrid.INVERSE, null);
    try testing.expect(!out.attr.inverse);
    try testing.expect(out.attr.underline);
    try testing.expectEqual(@as(u21, ' '), out.cp);
    try testing.expect(softCursorApplied(selected_space, out));

    const selected_tab = screen.Cell{ .cp = '\t', .attr = .{ .inverse = true } };
    const out_tab = applySoftCursorCell(selected_tab, Hybrid.INVERSE, null);
    try testing.expect(!out_tab.attr.inverse);
    try testing.expect(out_tab.attr.underline);
    try testing.expectEqual(@as(u21, ' '), out_tab.cp);

    const selected_letter = screen.Cell{ .cp = 'a', .attr = .{ .inverse = true } };
    const out_letter = applySoftCursorCell(selected_letter, Hybrid.INVERSE, null);
    try testing.expect(!out_letter.attr.inverse);
    try testing.expect(out_letter.attr.underline);
    try testing.expectEqual(@as(u21, 'a'), out_letter.cp);
    try testing.expect(softCursorApplied(selected_letter, out_letter));

    const normal_space = screen.Cell{ .cp = ' ', .attr = .{} };
    const out_normal = applySoftCursorCell(normal_space, Hybrid.INVERSE, null);
    try testing.expectEqual(@as(u21, ' '), out_normal.cp);
    try testing.expect(!out_normal.attr.inverse);
    try testing.expect(!softCursorApplied(normal_space, out_normal));
}

test "soft cursor keeps glyph on non-blank selected cell" {
    const letter = screen.Cell{ .cp = 'a', .attr = .{ .inverse = true } };
    const out = applySoftCursorCell(letter, Hybrid.INVERSE, null);
    try testing.expect(!out.attr.inverse);
    try testing.expectEqual(@as(u21, 'a'), out.cp);
}

test "soft cursor uses colored -cursor scheme" {
    const selected = Attribute{ .inverse = true };
    const cursor_atr = Hybrid.INVERSE | Hybrid.BOLD |
        Hybrid.FG_NOT_DEFAULT | (@as(i32, 16) << Hybrid.FG_SHIFT) |
        Hybrid.BG_NOT_DEFAULT | (@as(i32, 231) << Hybrid.BG_SHIFT);
    try testing.expect(!cursorStyleIsInverseOnly(cursor_atr));
    const out = applySoftCursorAttr(selected, cursor_atr, null);
    try testing.expect(out.inverse);
    try testing.expect(out.bold);
    try testing.expect(out.fg == .indexed);
    try testing.expectEqual(@as(u8, 16), out.fg.indexed);
    try testing.expect(out.bg == .indexed);
    try testing.expectEqual(@as(u8, 231), out.bg.indexed);

    // Colored schemes keep the blank glyph (bg color is enough contrast).
    const space = screen.Cell{ .cp = ' ', .attr = selected };
    const cell_out = applySoftCursorCell(space, cursor_atr, null);
    try testing.expectEqual(@as(u21, ' '), cell_out.cp);
}

test "hybrid style bits roundtrip" {
    const attr = Attribute{
        .bold = true,
        .dim = true,
        .italic = true,
        .underline = true,
        .double_underline = true,
        .blink = true,
        .inverse = true,
        .crossed_out = true,
    };
    const atr = try attributeToHybrid(attr, null);
    try testing.expect((atr & Hybrid.BOLD) != 0);
    try testing.expect((atr & Hybrid.DIM) != 0);
    try testing.expect((atr & Hybrid.ITALIC) != 0);
    try testing.expect((atr & Hybrid.UNDERLINE) != 0);
    try testing.expect((atr & Hybrid.DOUBLE_UNDERLINE) != 0);
    try testing.expect((atr & Hybrid.BLINK) != 0);
    try testing.expect((atr & Hybrid.INVERSE) != 0);
    try testing.expect((atr & Hybrid.CROSSED_OUT) != 0);
    try testing.expect(Attribute.eql(attributeFromHybrid(atr, null), attr));
}

test "hybrid indexed colors roundtrip" {
    const attr = Attribute{
        .fg = .{ .indexed = 196 },
        .bg = .{ .indexed = 17 },
        .bold = true,
    };
    const atr = try attributeToHybrid(attr, null);
    try testing.expect((atr & Hybrid.FG_NOT_DEFAULT) != 0);
    try testing.expect((atr & Hybrid.FG_TRUECOLOR) == 0);
    try testing.expect((atr & Hybrid.BG_NOT_DEFAULT) != 0);
    try testing.expectEqual(@as(u8, 196), @as(u8, @truncate(@as(u32, @bitCast((atr & Hybrid.FG_VALUE) >> Hybrid.FG_SHIFT)))));
    try testing.expectEqual(@as(u8, 17), @as(u8, @truncate(@as(u32, @bitCast((atr & Hybrid.BG_VALUE) >> Hybrid.BG_SHIFT)))));
    try testing.expect(Attribute.eql(attributeFromHybrid(atr, null), attr));
}

test "hybrid truecolor roundtrip via palette" {
    var pal: TruecolorPalette = .{};
    const attr = Attribute{
        .fg = .{ .rgb = .{ .r = 10, .g = 20, .b = 30 } },
        .bg = .{ .rgb = .{ .r = 40, .g = 50, .b = 60 } },
        .underline = true,
    };
    const atr = try attributeToHybrid(attr, &pal);
    try testing.expect((atr & Hybrid.FG_TRUECOLOR) != 0);
    try testing.expect((atr & Hybrid.BG_TRUECOLOR) != 0);
    try testing.expect(pal.next == 3);

    var joe_pal: [256]i32 = undefined;
    const slice = pal.asJoeSlice(&joe_pal);
    const decoded = attributeFromHybrid(atr, slice);
    try testing.expect(Attribute.eql(decoded, attr));
}

test "hybrid truecolor decode without palette falls back to indexed" {
    const atr = Hybrid.FG_NOT_DEFAULT | Hybrid.FG_TRUECOLOR | (@as(i32, 7) << Hybrid.FG_SHIFT);
    const attr = attributeFromHybrid(atr, null);
    try testing.expect(attr.fg == .indexed);
    try testing.expectEqual(@as(u8, 7), attr.fg.indexed);
}

test "OutSink flushes when full like obuf" {
    const Ctx = struct {
        chunks: std.ArrayList([]u8),
        allocator: Allocator,

        fn write(ctx: *anyopaque, bytes: []const u8) anyerror!void {
            const self: *@This() = @ptrCast(@alignCast(ctx));
            const copy = try self.allocator.dupe(u8, bytes);
            try self.chunks.append(self.allocator, copy);
        }
    };
    var ctx: Ctx = .{ .chunks = .empty, .allocator = testing.allocator };
    defer {
        for (ctx.chunks.items) |c| testing.allocator.free(c);
        ctx.chunks.deinit(testing.allocator);
    }

    var storage: [4]u8 = undefined;
    var sink = OutSink.init(&storage, &ctx, Ctx.write);
    try sink.puts("abcdefgh"); // 8 bytes → two full flushes
    try testing.expectEqual(@as(usize, 2), ctx.chunks.items.len);
    try testing.expectEqualStrings("abcd", ctx.chunks.items[0]);
    try testing.expectEqualStrings("efgh", ctx.chunks.items[1]);
    try testing.expectEqual(@as(usize, 0), sink.pos);
    try testing.expectEqual(@as(usize, 8), sink.flushed_total);
}

test "drainScreenOut pushes Screen.out through OutSink" {
    const Ctx = struct {
        out: std.ArrayList(u8),
        allocator: Allocator,
        fn write(ctx: *anyopaque, bytes: []const u8) anyerror!void {
            const self: *@This() = @ptrCast(@alignCast(ctx));
            try self.out.appendSlice(self.allocator, bytes);
        }
    };
    var ctx: Ctx = .{ .out = .empty, .allocator = testing.allocator };
    defer ctx.out.deinit(testing.allocator);

    var scr = try Screen.init(testing.allocator, 4, 1);
    defer scr.deinit();
    scr.writeText(0, 0, "Hi", Attribute{ .bold = true });
    try scr.flush();

    var storage: [64]u8 = undefined;
    var sink = OutSink.init(&storage, &ctx, Ctx.write);
    try drainScreenOut(&scr, &sink);

    try testing.expect(scr.takeOut().len == 0);
    try testing.expect(std.mem.indexOf(u8, ctx.out.items, "Hi") != null);
    try testing.expect(std.mem.indexOf(u8, ctx.out.items, "\x1b[0;1") != null);
    try testing.expect(sink.flushed_total == ctx.out.items.len);
}

test "drainScreenOutGated is a no-op when disabled" {
    const Ctx = struct {
        out: std.ArrayList(u8),
        allocator: Allocator,
        fn write(ctx: *anyopaque, bytes: []const u8) anyerror!void {
            const self: *@This() = @ptrCast(@alignCast(ctx));
            try self.out.appendSlice(self.allocator, bytes);
        }
    };
    var ctx: Ctx = .{ .out = .empty, .allocator = testing.allocator };
    defer ctx.out.deinit(testing.allocator);

    var scr = try Screen.init(testing.allocator, 4, 1);
    defer scr.deinit();
    scr.writeText(0, 0, "Hi", .{});
    try scr.flush();
    const pending = scr.takeOut().len;
    try testing.expect(pending > 0);

    var storage: [64]u8 = undefined;
    var sink = OutSink.init(&storage, &ctx, Ctx.write);
    try testing.expect(!(try drainScreenOutGated(&scr, &sink, false)));
    try testing.expectEqual(pending, scr.takeOut().len);
    try testing.expectEqual(@as(usize, 0), ctx.out.items.len);
}

test "drainScreenOutGated drains when enabled into hybrid-style obuf" {
    const Obuf = struct {
        buf: [8]u8 = undefined,
        pos: usize = 0,
        captured: std.ArrayList(u8),
        allocator: Allocator,

        fn flush(ctx: *anyopaque) void {
            const self: *@This() = @ptrCast(@alignCast(ctx));
            if (self.pos == 0) return;
            self.captured.appendSlice(self.allocator, self.buf[0..self.pos]) catch {};
            self.pos = 0;
        }

        fn write(ctx: *anyopaque, bytes: []const u8) anyerror!void {
            const self: *@This() = @ptrCast(@alignCast(ctx));
            writeIntoObuf(&self.buf, &self.pos, bytes, flush, ctx);
        }
    };
    var obuf: Obuf = .{ .captured = .empty, .allocator = testing.allocator };
    defer obuf.captured.deinit(testing.allocator);

    var scr = try Screen.init(testing.allocator, 8, 1);
    defer scr.deinit();
    // Bypass cell SGR — inject raw bytes as if Screen.out already held escapes.
    try scr.out.appendSlice(testing.allocator, "ABCDEFGHIJKLMNOP"); // 16 bytes → two obuf flushes + remainder

    var storage: [4]u8 = undefined;
    var sink = OutSink.init(&storage, &obuf, Obuf.write);
    try testing.expect(try drainScreenOutGated(&scr, &sink, true));
    try testing.expectEqual(@as(usize, 0), scr.takeOut().len);

    // Final partial obuf contents still pending until explicit flush (like ttflsh).
    Obuf.flush(&obuf);
    try testing.expectEqualStrings("ABCDEFGHIJKLMNOP", obuf.captured.items);
    try testing.expectEqual(@as(usize, 0), obuf.pos);
}

test "syncHybridGridToScreen copies base cells and attrs" {
    var scr = try Screen.init(testing.allocator, 4, 2);
    defer scr.deinit();

    var cells: [8][4]i32 = .{.{0} ** 4} ** 8;
    var attrs: [8]i32 = .{0} ** 8;
    cells[0][0] = 'A';
    attrs[0] = Hybrid.BOLD | Hybrid.FG_NOT_DEFAULT | (@as(i32, 2) << Hybrid.FG_SHIFT);
    cells[1][0] = 'B';
    cells[4][0] = -1; // unknown → cp 0
    cells[5][0] = '\n'; // eraeol marker → space

    syncHybridGridToScreen(&scr, &cells, &attrs, 4, 2, null);

    try testing.expectEqual(@as(u21, 'A'), scr.cells[0].cp);
    try testing.expect(scr.cells[0].attr.bold);
    try testing.expect(scr.cells[0].attr.fg == .indexed);
    try testing.expectEqual(@as(u8, 2), scr.cells[0].attr.fg.indexed);
    try testing.expectEqual(@as(u21, 'B'), scr.cells[1].cp);
    try testing.expectEqual(@as(u21, 0), scr.cells[4].cp);
    try testing.expectEqual(@as(u21, ' '), scr.cells[5].cp);
    try testing.expect(scr.dirty_rows.isSet(0));
    try testing.expect(scr.dirty_rows.isSet(1));
}

test "syncHybridGridToScreen copies combining marks" {
    var scr = try Screen.init(testing.allocator, 2, 1);
    defer scr.deinit();

    var cells: [2][4]i32 = .{.{0} ** 4} ** 2;
    var attrs: [2]i32 = .{0} ** 2;
    cells[0][0] = 'e';
    cells[0][1] = 0x0301; // combining acute
    cells[0][2] = 0x0302; // combining circumflex
    cells[1][0] = 'Z';

    syncHybridGridToScreen(&scr, &cells, &attrs, 2, 1, null);

    try testing.expectEqual(@as(u21, 'e'), scr.cells[0].cp);
    try testing.expectEqual(@as(u21, 0x0301), scr.cells[0].combine[0]);
    try testing.expectEqual(@as(u21, 0x0302), scr.cells[0].combine[1]);
    try testing.expectEqual(@as(u21, 0), scr.cells[0].combine[2]);
    try testing.expectEqual(@as(u21, 'Z'), scr.cells[1].cp);
    try testing.expect(!scr.cells[1].hasCombining());
}

