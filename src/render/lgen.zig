//! Minimal JOE `lgen_core`-shaped line renderer (Phase 6 start).
//!
//! Renders one UTF-8 buffer line into a `terminal.Screen` row window. Handles
//! tab expansion, display-column scroll (`bw->offset`), C0/DEL control glyphs,
//! and wide-char clipping (`>` filler). No syntax/highlight/viewmode/mark yet.
//! Not wired into live `joe` — unit-tested only.

const std = @import("std");
const testing = std.testing;

const terminal = @import("terminal");
const gap = @import("gap.zig");

pub const TermScreen = terminal.Screen;
pub const Attribute = terminal.Attribute;
pub const displayWidth = terminal.displayWidth;
pub const GapBuffer = gap.GapBuffer;
pub const Point = gap.Point;

pub const Options = struct {
    /// Tab stop width — JOE `o.tab` (default 8).
    tab: u16 = 8,
    /// First visible display column — JOE `bw->offset` / `scr`.
    offset: u64 = 0,
};

fn tabWidth(tab: u16, col: u64) u16 {
    const t: u64 = if (tab == 0) 1 else tab;
    return @intCast(t - (col % t));
}

fn controlDisplay(cp: u21) struct { cp: u21, underline: bool, width: u8 } {
    if (cp < 32) return .{ .cp = cp + '@', .underline = true, .width = 1 };
    if (cp == 127) return .{ .cp = '?', .underline = true, .width = 1 };
    return .{ .cp = cp, .underline = false, .width = displayWidth(cp) };
}

fn clearRange(term: *TermScreen, x: u16, y: u16, end_x: u16, attr: Attribute) void {
    var cx = x;
    const stop = @min(end_x, term.width);
    while (cx < stop) : (cx += 1) {
        term.writeChar(cx, y, ' ', attr);
    }
}

fn emitSpace(term: *TermScreen, sx: *u16, end_x: u16, y: u16, attr: Attribute) void {
    if (sx.* >= end_x or sx.* >= term.width) return;
    term.writeChar(sx.*, y, ' ', attr);
    sx.* += 1;
}

fn emitGlyph(term: *TermScreen, sx: *u16, end_x: u16, y: u16, cp: u21, wid: u8, attr: Attribute) void {
    if (wid == 0) {
        // Combining mark: attach to previous base if possible.
        if (sx.* > 0) term.addCombining(sx.* - 1, y, cp);
        return;
    }
    if (sx.* >= end_x) return;
    if (@as(u32, sx.*) + wid > end_x) {
        while (sx.* < end_x and sx.* < term.width) : (sx.* += 1) {
            term.writeChar(sx.*, y, '>', attr);
        }
        return;
    }
    term.writeChar(sx.*, y, cp, attr);
    if (wid >= 2 and sx.* + 1 < term.width) {
        term.writeChar(sx.* + 1, y, 0, attr);
    }
    sx.* +|= wid;
}

const Unit = union(enum) {
    cp: u21,
    invalid,
    eol,
};

fn paintUnit(
    term: *TermScreen,
    sx: *u16,
    end_x: u16,
    y: u16,
    x: u16,
    logical: *u64,
    offset: u64,
    tab: u16,
    unit: Unit,
    base_attr: Attribute,
) bool {
    // Returns false when the line ends (eol).
    switch (unit) {
        .eol => return false,
        .invalid => {
            if (logical.* >= offset) {
                var a = base_attr;
                a.underline = true;
                emitGlyph(term, sx, end_x, y, 'X', 1, a);
            }
            logical.* += 1;
            return true;
        },
        .cp => |cp| {
            if (cp == '\t') {
                const twid = tabWidth(tab, logical.*);
                var t: u16 = 0;
                while (t < twid) : (t += 1) {
                    if (logical.* < offset) {
                        logical.* += 1;
                        continue;
                    }
                    if (sx.* >= end_x) break;
                    emitSpace(term, sx, end_x, y, base_attr);
                    logical.* += 1;
                }
                return true;
            }

            const shown = controlDisplay(cp);
            var attr = base_attr;
            if (shown.underline) attr.underline = true;
            const wid = shown.width;

            if (wid == 0) {
                if (logical.* >= offset and sx.* > x) {
                    emitGlyph(term, sx, end_x, y, shown.cp, 0, attr);
                }
                return true;
            }

            if (logical.* + wid <= offset) {
                logical.* += wid;
                return true;
            }

            if (logical.* < offset) {
                const skip = offset - logical.*;
                emitGlyph(term, sx, end_x, y, '<', 1, attr);
                logical.* = offset;
                var rem = wid - @as(u8, @intCast(@min(skip, wid)));
                while (rem > 0 and sx.* < end_x) : (rem -= 1) {
                    emitSpace(term, sx, end_x, y, attr);
                    logical.* += 1;
                }
                return true;
            }

            emitGlyph(term, sx, end_x, y, shown.cp, wid, attr);
            logical.* += wid;
            return true;
        },
    }
}

const SliceIter = struct {
    text: []const u8,
    i: usize = 0,

    fn next(self: *SliceIter) ?Unit {
        if (self.i >= self.text.len) return null;
        const b = self.text[self.i];
        if (b == '\n' or b == '\r') return .eol;

        if (b == '\t') {
            self.i += 1;
            return .{ .cp = '\t' };
        }

        const seq_len = std.unicode.utf8ByteSequenceLength(b) catch {
            self.i += 1;
            return .{ .invalid = {} };
        };
        if (self.i + seq_len > self.text.len) {
            self.i += 1;
            return .{ .invalid = {} };
        }
        const cp = std.unicode.utf8Decode(self.text[self.i..][0..seq_len]) catch {
            self.i += seq_len;
            return .{ .invalid = {} };
        };
        self.i += seq_len;
        return .{ .cp = cp };
    }
};

/// Render one line into cells `[x, x+w)` on row `y`.
/// Stops at `\n` / `\r`. Pads remaining window width with spaces.
/// Returns screen columns written from `x` (not counting trailing pad).
pub fn lgenLine(
    term: *TermScreen,
    x: u16,
    y: u16,
    w: u16,
    text: []const u8,
    opts: Options,
    base_attr: Attribute,
) u16 {
    var it: SliceIter = .{ .text = text };
    return lgenUnits(term, x, y, w, &it, opts, base_attr);
}

/// Render one line by walking a live `Point` (gap-buffer backed).
/// Leaves `p` on the EOL byte (`\n`/`\r`) or at EOF — does not consume the newline.
pub fn lgenPoint(
    term: *TermScreen,
    x: u16,
    y: u16,
    w: u16,
    p: *Point,
    opts: Options,
    base_attr: Attribute,
) u16 {
    return lgenUnits(term, x, y, w, p, opts, base_attr);
}

fn lgenUnits(
    term: *TermScreen,
    x: u16,
    y: u16,
    w: u16,
    iter: anytype,
    opts: Options,
    base_attr: Attribute,
) u16 {
    if (w == 0 or y >= term.height or x >= term.width) return 0;
    const end_x: u16 = @min(term.width, x +% w);
    const offset = opts.offset;
    const tab = if (opts.tab == 0) @as(u16, 1) else opts.tab;

    var logical: u64 = 0;
    var sx: u16 = x;

    while (sx < end_x) {
        const unit = iter.next() orelse break;
        // Point.nextUnit / SliceIter.next both yield Unit.
        const u: Unit = switch (@TypeOf(unit)) {
            gap.Unit => switch (unit) {
                .cp => |cp| .{ .cp = cp },
                .invalid => .invalid,
                .eol => .eol,
            },
            Unit => unit,
            else => @compileError("unsupported unit iterator"),
        };
        if (!paintUnit(term, &sx, end_x, y, x, &logical, offset, tab, u, base_attr)) break;
        if (sx >= end_x) break;
    }

    const written = sx -% x;
    if (sx < end_x) clearRange(term, sx, y, end_x, base_attr);
    return written;
}

/// bwgen-shaped: paint `h` rows from `top_line` of a live gap buffer.
/// Returns number of content rows painted (always `h` when h>0 and w path runs).
pub fn lgenBuffer(
    term: *TermScreen,
    x: u16,
    y: u16,
    w: u16,
    h: u16,
    buf: *GapBuffer,
    top_line: u64,
    opts: Options,
    base_attr: Attribute,
) u16 {
    if (h == 0 or w == 0) return 0;
    var row: u16 = 0;
    while (row < h) : (row += 1) {
        const line_idx = top_line +% row;
        const sy = y +% row;
        if (sy >= term.height) break;
        if (line_idx >= buf.lineCount()) {
            clearRange(term, x, sy, @min(term.width, x +% w), base_attr);
            continue;
        }
        var p = Point.bof(buf);
        p.gotoLine(line_idx);
        _ = lgenPoint(term, x, sy, w, &p, opts, base_attr);
    }
    return row;
}

test "lgenLine writes plain ASCII and pads" {
    var term = try TermScreen.init(testing.allocator, 10, 2);
    defer term.deinit();
    const n = lgenLine(&term, 1, 0, 6, "hi", .{}, .none);
    try testing.expectEqual(@as(u16, 2), n);
    try testing.expectEqual(@as(u21, 'h'), term.cells[1].cp);
    try testing.expectEqual(@as(u21, 'i'), term.cells[2].cp);
    try testing.expectEqual(@as(u21, ' '), term.cells[3].cp);
    try testing.expectEqual(@as(u21, ' '), term.cells[6].cp);
}

test "lgenLine expands tabs to tab stops" {
    var term = try TermScreen.init(testing.allocator, 16, 1);
    defer term.deinit();
    _ = lgenLine(&term, 0, 0, 12, "a\tb", .{ .tab = 4 }, .none);
    try testing.expectEqual(@as(u21, 'a'), term.cells[0].cp);
    try testing.expectEqual(@as(u21, ' '), term.cells[1].cp);
    try testing.expectEqual(@as(u21, ' '), term.cells[2].cp);
    try testing.expectEqual(@as(u21, ' '), term.cells[3].cp);
    try testing.expectEqual(@as(u21, 'b'), term.cells[4].cp);
}

test "lgenLine scrolls by display column offset" {
    var term = try TermScreen.init(testing.allocator, 10, 1);
    defer term.deinit();
    _ = lgenLine(&term, 0, 0, 8, "abcdef", .{ .offset = 2 }, .none);
    try testing.expectEqual(@as(u21, 'c'), term.cells[0].cp);
    try testing.expectEqual(@as(u21, 'd'), term.cells[1].cp);
}

test "lgenLine scrolls mid-tab" {
    var term = try TermScreen.init(testing.allocator, 10, 1);
    defer term.deinit();
    // "\tX" with tab=4: cols 0..3 spaces, col 4 = X. offset=2 → two spaces then X.
    _ = lgenLine(&term, 0, 0, 8, "\tX", .{ .tab = 4, .offset = 2 }, .none);
    try testing.expectEqual(@as(u21, ' '), term.cells[0].cp);
    try testing.expectEqual(@as(u21, ' '), term.cells[1].cp);
    try testing.expectEqual(@as(u21, 'X'), term.cells[2].cp);
}

test "lgenLine shows C0 controls as underlined caret glyphs" {
    var term = try TermScreen.init(testing.allocator, 8, 1);
    defer term.deinit();
    _ = lgenLine(&term, 0, 0, 4, "\x01Z", .{}, .none);
    try testing.expectEqual(@as(u21, 'A'), term.cells[0].cp); // SOH → '^A' glyph 'A'
    try testing.expect(term.cells[0].attr.underline);
    try testing.expectEqual(@as(u21, 'Z'), term.cells[1].cp);
    try testing.expect(!term.cells[1].attr.underline);
}

test "lgenLine clips wide char at window edge with >" {
    var term = try TermScreen.init(testing.allocator, 4, 1);
    defer term.deinit();
    // U+3000 IDEOGRAPHIC SPACE is width 2; at x=2 with w=1 → '>'.
    const line = "ab\u{3000}";
    _ = lgenLine(&term, 0, 0, 3, line, .{}, .none);
    try testing.expectEqual(@as(u21, 'a'), term.cells[0].cp);
    try testing.expectEqual(@as(u21, 'b'), term.cells[1].cp);
    try testing.expectEqual(@as(u21, '>'), term.cells[2].cp);
}

test "lgenLine stops at newline" {
    var term = try TermScreen.init(testing.allocator, 8, 1);
    defer term.deinit();
    _ = lgenLine(&term, 0, 0, 8, "ab\ncd", .{}, .none);
    try testing.expectEqual(@as(u21, 'a'), term.cells[0].cp);
    try testing.expectEqual(@as(u21, 'b'), term.cells[1].cp);
    try testing.expectEqual(@as(u21, ' '), term.cells[2].cp);
}

test "lgenPoint matches lgenLine over a gap buffer" {
    var buf = try GapBuffer.init(testing.allocator);
    defer buf.deinit();
    try buf.append("a\tb\nZZ");

    var term = try TermScreen.init(testing.allocator, 12, 1);
    defer term.deinit();
    var p = Point.bof(&buf);
    _ = lgenPoint(&term, 0, 0, 10, &p, .{ .tab = 4 }, .none);
    try testing.expectEqual(@as(u21, 'a'), term.cells[0].cp);
    try testing.expectEqual(@as(u21, ' '), term.cells[1].cp);
    try testing.expectEqual(@as(u21, ' '), term.cells[2].cp);
    try testing.expectEqual(@as(u21, ' '), term.cells[3].cp);
    try testing.expectEqual(@as(u21, 'b'), term.cells[4].cp);
    // Point left at EOL, not past it.
    try testing.expect(p.isEol());
    try testing.expectEqual(@as(u8, '\n'), p.peekb().?);
}

test "lgenBuffer paints multiple lines with offset and past-EOF blanking" {
    var buf = try GapBuffer.init(testing.allocator);
    defer buf.deinit();
    try buf.append("alpha\nbravo\ncharlie");

    var term = try TermScreen.init(testing.allocator, 10, 4);
    defer term.deinit();
    // Dirty past-EOF row.
    term.writeChar(0, 3, 'Z', .none);
    _ = lgenBuffer(&term, 0, 0, 8, 4, &buf, 1, .{ .offset = 1 }, .none);
    // top_line=1 → bravo, charlie, then past EOF blank.
    try testing.expectEqual(@as(u21, 'r'), term.cells[0].cp); // "ravo"
    try testing.expectEqual(@as(u21, 'h'), term.cells[10].cp); // row1 "harlie" — width 10, row stride
    try testing.expectEqual(@as(u21, 'h'), term.cells[1 * 10 + 0].cp);
    try testing.expect(term.cells[3 * 10 + 0].isBlankNone() or term.cells[3 * 10].cp == ' ');
}

test "lgenPoint sees edits across the gap" {
    var buf = try GapBuffer.init(testing.allocator);
    defer buf.deinit();
    try buf.append("hello");
    // Force gap into the middle, then insert.
    buf.moveGap(2);
    try buf.insert(2, "XY");

    var term = try TermScreen.init(testing.allocator, 10, 1);
    defer term.deinit();
    var p = Point.bof(&buf);
    _ = lgenPoint(&term, 0, 0, 8, &p, .{}, .none);
    try testing.expectEqual(@as(u21, 'h'), term.cells[0].cp);
    try testing.expectEqual(@as(u21, 'e'), term.cells[1].cp);
    try testing.expectEqual(@as(u21, 'X'), term.cells[2].cp);
    try testing.expectEqual(@as(u21, 'Y'), term.cells[3].cp);
    try testing.expectEqual(@as(u21, 'l'), term.cells[4].cp);
}
