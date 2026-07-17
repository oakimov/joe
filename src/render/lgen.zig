//! Minimal JOE `lgen_core`-shaped line renderer (Phase 6 start).
//!
//! Renders one UTF-8 buffer line into a `terminal.Screen` row window. Handles
//! tab expansion, display-column scroll (`bw->offset`), C0/DEL control glyphs,
//! and wide-char clipping (`>` filler). No syntax/highlight/viewmode/mark yet.
//! Not wired into live `joe` — unit-tested only.

const std = @import("std");
const testing = std.testing;

const terminal = @import("terminal");

pub const TermScreen = terminal.Screen;
pub const Attribute = terminal.Attribute;
pub const displayWidth = terminal.displayWidth;

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
    if (w == 0 or y >= term.height or x >= term.width) return 0;
    const end_x: u16 = @min(term.width, x +% w);
    const offset = opts.offset;
    const tab = if (opts.tab == 0) @as(u16, 1) else opts.tab;

    var logical: u64 = 0;
    var sx: u16 = x;
    var i: usize = 0;

    while (i < text.len and sx < end_x) {
        const b = text[i];
        if (b == '\n' or b == '\r') break;

        if (b == '\t') {
            const twid = tabWidth(tab, logical);
            var t: u16 = 0;
            while (t < twid) : (t += 1) {
                if (logical < offset) {
                    logical += 1;
                    continue;
                }
                if (sx >= end_x) break;
                emitSpace(term, &sx, end_x, y, base_attr);
                logical += 1;
            }
            i += 1;
            continue;
        }

        const seq_len = std.unicode.utf8ByteSequenceLength(b) catch {
            // Invalid lead byte — show as underlined 'X' (JOE UTF8_BAD scaffold).
            if (logical >= offset) {
                var a = base_attr;
                a.underline = true;
                emitGlyph(term, &sx, end_x, y, 'X', 1, a);
            }
            logical += 1;
            i += 1;
            continue;
        };
        if (i + seq_len > text.len) {
            if (logical >= offset) {
                var a = base_attr;
                a.underline = true;
                emitGlyph(term, &sx, end_x, y, 'X', 1, a);
            }
            logical += 1;
            break;
        }
        const cp = std.unicode.utf8Decode(text[i..][0..seq_len]) catch {
            if (logical >= offset) {
                var a = base_attr;
                a.underline = true;
                emitGlyph(term, &sx, end_x, y, 'X', 1, a);
            }
            logical += 1;
            i += seq_len;
            continue;
        };
        i += seq_len;

        const shown = controlDisplay(cp);
        var attr = base_attr;
        if (shown.underline) attr.underline = true;
        const wid = shown.width;

        if (wid == 0) {
            // Combining / zero-width: only attach once past the scroll offset
            // and once a base glyph has been emitted into the window.
            if (logical >= offset and sx > x) {
                emitGlyph(term, &sx, end_x, y, shown.cp, 0, attr);
            }
            continue;
        }

        // Scroll/skip whole glyph when it ends at or before `offset`.
        if (logical + wid <= offset) {
            logical += wid;
            continue;
        }

        // Glyph straddles `offset`: JOE shows a leading '<' then the remnant.
        if (logical < offset) {
            const skip = offset - logical;
            // Emit '<' once at window start for partial wide/control glyph.
            emitGlyph(term, &sx, end_x, y, '<', 1, attr);
            logical = offset;
            // Remaining columns of the clipped glyph become spaces (simplified;
            // full JOE keeps going with tach='<' only for the first cell).
            var rem = wid - @as(u8, @intCast(@min(skip, wid)));
            while (rem > 0 and sx < end_x) : (rem -= 1) {
                emitSpace(term, &sx, end_x, y, attr);
                logical += 1;
            }
            continue;
        }

        emitGlyph(term, &sx, end_x, y, shown.cp, wid, attr);
        logical += wid;
    }

    const written = sx -% x;
    if (sx < end_x) clearRange(term, sx, y, end_x, base_attr);
    return written;
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
