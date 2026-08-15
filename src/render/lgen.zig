//! Minimal JOE `lgen_core`-shaped line renderer (Phase 6).
//!
//! Renders one UTF-8 buffer line into a `terminal.Screen` row window. Handles
//! tab expansion, display-column scroll (`bw->offset`), C0/DEL control glyphs,
//! and wide-char clipping (`>` filler). Optional per-byte `attrs` (JOE `attr_buf`),
//! viewmode side tables (`Options.view` — hide→space / substitute), and
//! visible-whitespace glyphs (`Options.visible_ws`).

const std = @import("std");
const testing = std.testing;

const terminal = @import("terminal");
const gap = @import("gap.zig");
const attr_mod = @import("attr.zig");
const view_mod = @import("view.zig");

pub const TermScreen = terminal.Screen;
pub const Attribute = terminal.Attribute;
pub const Color = terminal.Color;
pub const displayWidth = terminal.displayWidth;
pub const GapBuffer = gap.GapBuffer;
pub const Point = gap.Point;
pub const mergeHighlight = attr_mod.mergeHighlight;
pub const attrAt = attr_mod.attrAt;
pub const fromHybridRow = attr_mod.fromHybridRow;
pub const ViewTables = view_mod.ViewTables;
pub const analyzeLine = view_mod.analyzeLine;
pub const resolveCp = view_mod.resolveCp;

/// JOE `-visiblews` glyphs + style (default: dim, clear FG).
/// Live bridge builds this from `vspace`/`vtab`/`vrtn` + `vwsatr`.
pub const VisibleWs = struct {
    space: u21, // JOE `vspace` (middle dot)
    tab: u21, // JOE `vtab` (right arrow) — first cell of a tab run
    rtn: u21, // JOE `vrtn` (return arrow) — painted at EOL before clear
    /// Forced style bits (typically `{ .dim = true }`).
    style: Attribute = .{ .dim = true },
    /// When true, clear FG from the cell atr (JOE `vwsmask` drops `FG_MASK`).
    clear_fg: bool = true,
};

pub const Options = struct {
    /// Tab stop width — JOE `o.tab` (default 8).
    tab: u16 = 8,
    /// First visible display column — JOE `bw->offset` / `scr`.
    offset: u64 = 0,
    /// Per-byte syntax attributes from BOL (JOE `attr_buf`). Lead byte wins
    /// for multi-byte UTF-8. `null` ⇒ paint everything with `base_attr`.
    attrs: ?[]const Attribute = null,
    /// Optional viewmode side tables (JOE `viewmode_hide` / `substitute`).
    /// When set, hide→space and substitute wins (like `lgen_core` + `viewmode_skip_parse`).
    view: ?*const ViewTables = null,
    /// Optional visible-whitespace glyphs (JOE `-visiblews`).
    visible_ws: ?*const VisibleWs = null,
    /// Non-UTF-8 charmap: each byte is one latin1-ish codepoint.
    byte_mode: bool = false,
};

/// Merge cell atr with visible-ws style (JOE `((atr & vwsmask) | (vwsatr & ~vwsmask))`
/// for the default mask that keeps styles/BG, forces DIM, clears FG).
pub fn mergeVisibleWsAttr(base: Attribute, vws: *const VisibleWs) Attribute {
    var out = base;
    out.dim = vws.style.dim;
    if (vws.clear_fg) {
        out.fg = if (!Color.eql(vws.style.fg, .default)) vws.style.fg else .default;
    } else if (!Color.eql(vws.style.fg, .default)) {
        out.fg = vws.style.fg;
    }
    return out;
}

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

fn emitGlyph(term: *TermScreen, sx: *u16, end_x: u16, y: u16, cp: u21, wid: u8, attr: Attribute, url: ?[]const u8) void {
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
    if (url) |u| {
        term.writeCharLink(sx.*, y, cp, attr, u);
    } else {
        term.writeChar(sx.*, y, cp, attr);
    }
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
    url: ?[]const u8,
    vws: ?*const VisibleWs,
) bool {
    // Returns false when the line ends (eol).
    switch (unit) {
        .eol => {
            // JOE paints `vrtn` on `\n` (and `\r\n` when crlf) before eraeol.
            // EOF without newline does not emit rtn (iterator ends without `.eol`).
            if (vws) |v| {
                if (logical.* >= offset and sx.* < end_x) {
                    const a = mergeVisibleWsAttr(base_attr, v);
                    emitGlyph(term, sx, end_x, y, v.rtn, 1, a, null);
                }
            }
            return false;
        },
        .invalid => {
            if (logical.* >= offset) {
                var a = base_attr;
                a.underline = true;
                emitGlyph(term, sx, end_x, y, 'X', 1, a, null);
            }
            logical.* += 1;
            return true;
        },
        .cp => |cp| {
            if (cp == '\t') {
                // JOE: first cell of the tab run → `vtab` + vws atr; rest → spaces.
                const twid = tabWidth(tab, logical.*);
                var t: u16 = 0;
                while (t < twid) : (t += 1) {
                    if (logical.* < offset) {
                        logical.* += 1;
                        continue;
                    }
                    if (sx.* >= end_x) break;
                    if (vws) |v| {
                        if (t == 0) {
                            const a = mergeVisibleWsAttr(base_attr, v);
                            emitGlyph(term, sx, end_x, y, v.tab, 1, a, null);
                        } else {
                            emitSpace(term, sx, end_x, y, base_attr);
                        }
                    } else {
                        emitSpace(term, sx, end_x, y, base_attr);
                    }
                    logical.* += 1;
                }
                return true;
            }

            // JOE `-visiblews`: space → `vspace` glyph with vws atr merge.
            if (cp == ' ') {
                if (vws) |v| {
                    const a = mergeVisibleWsAttr(base_attr, v);
                    if (logical.* < offset) {
                        logical.* += 1;
                        return true;
                    }
                    emitGlyph(term, sx, end_x, y, v.space, 1, a, url);
                    logical.* += 1;
                    return true;
                }
            }

            const shown = controlDisplay(cp);
            var attr = base_attr;
            if (shown.underline) attr.underline = true;
            const wid = shown.width;

            if (wid == 0) {
                if (logical.* >= offset and sx.* > x) {
                    emitGlyph(term, sx, end_x, y, shown.cp, 0, attr, url);
                }
                return true;
            }

            if (logical.* + wid <= offset) {
                logical.* += wid;
                return true;
            }

            if (logical.* < offset) {
                const skip = offset - logical.*;
                emitGlyph(term, sx, end_x, y, '<', 1, attr, null);
                logical.* = offset;
                var rem = wid - @as(u8, @intCast(@min(skip, wid)));
                while (rem > 0 and sx.* < end_x) : (rem -= 1) {
                    emitSpace(term, sx, end_x, y, attr);
                    logical.* += 1;
                }
                return true;
            }

            emitGlyph(term, sx, end_x, y, shown.cp, wid, attr, url);
            logical.* += wid;
            return true;
        },
    }
}

const SliceIter = struct {
    text: []const u8,
    i: usize = 0,
    /// Byte index (from BOL / slice start) of the unit returned by the last `next`.
    last_byte: usize = 0,
    /// Non-UTF-8: each byte is one latin1-ish codepoint.
    byte_mode: bool = false,

    fn next(self: *SliceIter) ?Unit {
        if (self.i >= self.text.len) return null;
        self.last_byte = self.i;
        const b = self.text[self.i];
        if (b == '\n' or b == '\r') return .eol;

        if (b == '\t') {
            self.i += 1;
            return .{ .cp = '\t' };
        }

        if (self.byte_mode) {
            self.i += 1;
            return .{ .cp = b };
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

/// Point walker that reports byte offsets relative to the line start (`p` at BOL).
const PointIter = struct {
    p: *Point,
    line_start: usize,
    last_byte: usize = 0,

    fn init(p: *Point) PointIter {
        return .{ .p = p, .line_start = p.byte };
    }

    fn next(self: *PointIter) ?gap.Unit {
        self.last_byte = self.p.byte - self.line_start;
        return self.p.next();
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
    var it: SliceIter = .{ .text = text, .byte_mode = opts.byte_mode };
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
    var it = PointIter.init(p);
    return lgenUnits(term, x, y, w, &it, opts, base_attr);
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
        const byte_idx: usize = iter.last_byte;
        var u: Unit = switch (@TypeOf(unit)) {
            gap.Unit => switch (unit) {
                .cp => |cp| .{ .cp = cp },
                .invalid => .invalid,
                .eol => .eol,
            },
            Unit => unit,
            else => @compileError("unsupported unit iterator"),
        };
        if (opts.view) |vt| {
            switch (u) {
                .cp => |cp| u = .{ .cp = resolveCp(vt, byte_idx, cp) },
                else => {},
            }
        }
        const cell_attr = attrAt(base_attr, opts.attrs, byte_idx);
        const cell_url: ?[]const u8 = if (opts.view) |vt| vt.linkAt(byte_idx) else null;
        if (!paintUnit(term, &sx, end_x, y, x, &logical, offset, tab, u, cell_attr, cell_url, opts.visible_ws)) break;
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

test "lgenLine applies per-byte attrs (lead byte for UTF-8)" {
    var term = try TermScreen.init(testing.allocator, 10, 1);
    defer term.deinit();
    // "a" + U+00E9 (é = 2 bytes c3 a9) + "b"
    const line = "a\u{00e9}b";
    var row: [4]Attribute = .{
        Attribute.fgIndexed(1), // 'a'
        Attribute{ .bold = true, .fg = .{ .indexed = 2 } }, // lead of é
        Attribute.fgIndexed(9), // continuation — ignored by paint
        Attribute{ .underline = true, .fg = .{ .indexed = 3 } }, // 'b'
    };
    _ = lgenLine(&term, 0, 0, 8, line, .{ .attrs = &row }, .none);
    try testing.expectEqual(@as(u21, 'a'), term.cells[0].cp);
    try testing.expect(Color.eql(term.cells[0].attr.fg, .{ .indexed = 1 }));
    try testing.expectEqual(@as(u21, 0xe9), term.cells[1].cp);
    try testing.expect(term.cells[1].attr.bold);
    try testing.expect(Color.eql(term.cells[1].attr.fg, .{ .indexed = 2 }));
    try testing.expectEqual(@as(u21, 'b'), term.cells[2].cp);
    try testing.expect(term.cells[2].attr.underline);
    try testing.expect(Color.eql(term.cells[2].attr.fg, .{ .indexed = 3 }));
}

test "lgenLine merges missing FG from base_attr" {
    var term = try TermScreen.init(testing.allocator, 6, 1);
    defer term.deinit();
    const base = Attribute.fgIndexed(7);
    var row: [2]Attribute = .{
        .{ .bold = true }, // fg default → inherit 7
        .{ .fg = .{ .indexed = 4 } },
    };
    _ = lgenLine(&term, 0, 0, 4, "ab", .{ .attrs = &row }, base);
    try testing.expect(term.cells[0].attr.bold);
    try testing.expect(Color.eql(term.cells[0].attr.fg, .{ .indexed = 7 }));
    try testing.expect(Color.eql(term.cells[1].attr.fg, .{ .indexed = 4 }));
}

test "lgenPoint applies attrs across the gap" {
    var buf = try GapBuffer.init(testing.allocator);
    defer buf.deinit();
    try buf.append("xy");
    buf.moveGap(1);
    try buf.insert(1, "Z");

    // attrs for "xZy"
    var row: [3]Attribute = .{
        Attribute.fgIndexed(1),
        Attribute{ .inverse = true, .fg = .{ .indexed = 2 } },
        Attribute.fgIndexed(3),
    };
    var term = try TermScreen.init(testing.allocator, 8, 1);
    defer term.deinit();
    var p = Point.bof(&buf);
    _ = lgenPoint(&term, 0, 0, 6, &p, .{ .attrs = &row }, .none);
    try testing.expectEqual(@as(u21, 'x'), term.cells[0].cp);
    try testing.expect(Color.eql(term.cells[0].attr.fg, .{ .indexed = 1 }));
    try testing.expectEqual(@as(u21, 'Z'), term.cells[1].cp);
    try testing.expect(term.cells[1].attr.inverse);
    try testing.expectEqual(@as(u21, 'y'), term.cells[2].cp);
    try testing.expect(Color.eql(term.cells[2].attr.fg, .{ .indexed = 3 }));
}

test "lgenLine hybrid attr_buf row via fromHybridRow" {
    var term = try TermScreen.init(testing.allocator, 6, 1);
    defer term.deinit();
    const Hybrid = terminal.Hybrid;
    const src = [_]i32{
        Hybrid.BOLD | Hybrid.CONTEXT_STRING,
        Hybrid.UNDERLINE | Hybrid.FG_NOT_DEFAULT | (5 << Hybrid.FG_SHIFT),
    };
    var row: [2]Attribute = undefined;
    fromHybridRow(&row, &src, null);
    _ = lgenLine(&term, 0, 0, 4, "ab", .{ .attrs = &row }, .none);
    try testing.expect(term.cells[0].attr.bold);
    try testing.expect(term.cells[1].attr.underline);
    try testing.expect(Color.eql(term.cells[1].attr.fg, .{ .indexed = 5 }));
}

test "lgenLine applies viewmode hide and substitute" {
    var tables = ViewTables.init(testing.allocator);
    defer tables.deinit();
    try analyzeLine(&tables, "# Hi", null);

    var term = try TermScreen.init(testing.allocator, 8, 1);
    defer term.deinit();
    _ = lgenLine(&term, 0, 0, 8, "# Hi", .{ .view = &tables }, .none);
    try testing.expectEqual(@as(u21, ' '), term.cells[0].cp);
    try testing.expectEqual(@as(u21, ' '), term.cells[1].cp);
    try testing.expectEqual(@as(u21, 'H'), term.cells[2].cp);
    try testing.expectEqual(@as(u21, 'i'), term.cells[3].cp);

    try analyzeLine(&tables, "> quote", null);
    var term2 = try TermScreen.init(testing.allocator, 10, 1);
    defer term2.deinit();
    _ = lgenLine(&term2, 0, 0, 10, "> quote", .{ .view = &tables }, .none);
    try testing.expectEqual(@as(u21, 0x2502), term2.cells[0].cp);
    try testing.expectEqual(@as(u21, ' '), term2.cells[1].cp);
    try testing.expectEqual(@as(u21, 'q'), term2.cells[2].cp);
}

// Plan §4 / R5: painted column must equal `col_map[byte]` for every visible
// byte. `buildColMap` already treats hidden bytes as zero-width (this was
// true before Phase 1.2 too — see `view.zig`'s `buildColMap`); the paint
// loop does not yet (`resolveCp` still emits a space per hidden byte, which
// consumes a column). Written first, expected RED until the Phase 1.2
// collapse lands in `lgenLine`'s paint loop — then it passes with no
// further edits. Do not "fix" this test to match today's paint; that would
// defeat its purpose.
test "lgenLine painted column matches col_map for every visible byte (Phase 1.2 gate)" {
    var tables = ViewTables.init(testing.allocator);
    defer tables.deinit();

    // "# Hi!" — heading hash + space hidden (bytes 0-1), H/i/! visible and
    // individually distinguishable so a cell match is unambiguous.
    const line = "# Hi!";
    try analyzeLine(&tables, line, null);

    var term = try TermScreen.init(testing.allocator, 10, 1);
    defer term.deinit();
    _ = lgenLine(&term, 0, 0, 10, line, .{ .view = &tables }, .none);

    // Visible bytes: 2='H', 3='i', 4='!'. Once conceal collapses, they paint
    // at columns 0, 1, 2 respectively (col_map already predicts this).
    const h_col = tables.col_map[2];
    const i_col = tables.col_map[3];
    const bang_col = tables.col_map[4];
    try testing.expectEqual(@as(u21, 'H'), term.cells[@intCast(h_col)].cp);
    try testing.expectEqual(@as(u21, 'i'), term.cells[@intCast(i_col)].cp);
    try testing.expectEqual(@as(u21, '!'), term.cells[@intCast(bang_col)].cp);

    // A hidden run in the MIDDLE of a line, not just the start.
    var tables2 = ViewTables.init(testing.allocator);
    defer tables2.deinit();
    const line2 = "Some **bold** text";
    try analyzeLine(&tables2, line2, null);

    var term2 = try TermScreen.init(testing.allocator, 32, 1);
    defer term2.deinit();
    _ = lgenLine(&term2, 0, 0, 32, line2, .{ .view = &tables2 }, .none);

    // "bold" is bytes 7-10 of "Some **bold** text" (0-indexed: S=0,o=1,m=2,
    // e=3, =4,*=5,*=6,b=7,o=8,l=9,d=10,*=11,*=12, =13,t=14...).
    inline for (.{ 7, 8, 9, 10 }, .{ 'b', 'o', 'l', 'd' }) |byte_idx, ch| {
        const col = tables2.col_map[byte_idx];
        try testing.expectEqual(@as(u21, ch), term2.cells[@intCast(col)].cp);
    }
    // And "text" after the trailing "**" must follow immediately, not two
    // columns further right where the space-padded paint would leave it.
    inline for (.{ 14, 15, 16, 17 }, .{ 't', 'e', 'x', 't' }) |byte_idx, ch| {
        const col = tables2.col_map[byte_idx];
        try testing.expectEqual(@as(u21, ch), term2.cells[@intCast(col)].cp);
    }
}

test "lgenLine applies viewmode link urls onto cells" {
    var tables = ViewTables.init(testing.allocator);
    defer tables.deinit();
    const line = "See [here](http://example.com)";
    var attrs: [64]Attribute = .{Attribute.none} ** 64;
    try analyzeLine(&tables, line, attrs[0..line.len]);

    var term = try TermScreen.init(testing.allocator, 40, 1);
    defer term.deinit();
    _ = lgenLine(&term, 0, 0, 40, line, .{ .view = &tables, .attrs = attrs[0..line.len] }, .none);

    // 'h' of here — hidden '[' is a space before it
    // "See  here  http://example.com "
    // Find cell with 'h' that has URL
    var found = false;
    for (term.cells) |c| {
        if (c.cp == 'h' and c.url != null) {
            try testing.expectEqualStrings("http://example.com", c.url.?);
            try testing.expect(c.attr.underline);
            found = true;
            break;
        }
    }
    try testing.expect(found);

    try term.flush();
    const out = term.takeOut();
    try testing.expect(std.mem.indexOf(u8, out, "\x1b]8;;http://example.com\x1b\\") != null);
}

test "mergeVisibleWsAttr forces dim and clears FG" {
    const vws: VisibleWs = .{ .space = 0xb7, .tab = 0x2192, .rtn = 0x21b5 };
    const base = Attribute{ .bold = true, .fg = .{ .indexed = 3 }, .bg = .{ .indexed = 4 } };
    const m = mergeVisibleWsAttr(base, &vws);
    try testing.expect(m.bold);
    try testing.expect(m.dim);
    try testing.expect(Color.eql(m.fg, .default));
    try testing.expect(Color.eql(m.bg, .{ .indexed = 4 }));
}

test "lgenLine visiblews paints space tab rtn glyphs" {
    const vws: VisibleWs = .{ .space = 0xb7, .tab = 0x2192, .rtn = 0x21b5 };
    var term = try TermScreen.init(testing.allocator, 10, 1);
    defer term.deinit();
    // col0 space, col1-3 tab (width 3 at tab=4), 'a', then rtn on \n
    _ = lgenLine(&term, 0, 0, 10, " \ta\n", .{ .tab = 4, .visible_ws = &vws }, .none);
    try testing.expectEqual(@as(u21, 0xb7), term.cells[0].cp);
    try testing.expect(term.cells[0].attr.dim);
    try testing.expectEqual(@as(u21, 0x2192), term.cells[1].cp);
    try testing.expect(term.cells[1].attr.dim);
    try testing.expectEqual(@as(u21, ' '), term.cells[2].cp);
    try testing.expect(!term.cells[2].attr.dim);
    try testing.expectEqual(@as(u21, ' '), term.cells[3].cp);
    try testing.expectEqual(@as(u21, 'a'), term.cells[4].cp);
    try testing.expectEqual(@as(u21, 0x21b5), term.cells[5].cp);
    try testing.expect(term.cells[5].attr.dim);
}

test "lgenLine visiblews omits rtn when line has no newline" {
    const vws: VisibleWs = .{ .space = 0xb7, .tab = 0x2192, .rtn = 0x21b5 };
    var term = try TermScreen.init(testing.allocator, 6, 1);
    defer term.deinit();
    _ = lgenLine(&term, 0, 0, 6, "a ", .{ .visible_ws = &vws }, .none);
    try testing.expectEqual(@as(u21, 'a'), term.cells[0].cp);
    try testing.expectEqual(@as(u21, 0xb7), term.cells[1].cp);
    // Remaining pad is plain spaces (eraeol), not rtn.
    try testing.expectEqual(@as(u21, ' '), term.cells[2].cp);
    try testing.expect(!term.cells[2].attr.dim);
}

test "lgenLine visiblews skips vtab when offset cuts mid-tab" {
    const vws: VisibleWs = .{ .space = 0xb7, .tab = 0x2192, .rtn = 0x21b5 };
    var term = try TermScreen.init(testing.allocator, 8, 1);
    defer term.deinit();
    // tab width 4 at col 0; offset 2 → trailing two tab cells are plain spaces.
    _ = lgenLine(&term, 0, 0, 8, "\tX", .{ .tab = 4, .offset = 2, .visible_ws = &vws }, .none);
    try testing.expectEqual(@as(u21, ' '), term.cells[0].cp);
    try testing.expect(!term.cells[0].attr.dim);
    try testing.expectEqual(@as(u21, ' '), term.cells[1].cp);
    try testing.expectEqual(@as(u21, 'X'), term.cells[2].cp);
}


test "lgenLine byte_mode paints high bytes as codepoints" {
    const gpa = testing.allocator;
    var term = try TermScreen.init(gpa, 4, 1);
    defer term.deinit();
    const opts: Options = .{ .byte_mode = true };
    _ = lgenLine(&term, 0, 0, 4, &[_]u8{ 'A', 0xE9, 'B' }, opts, .none);
    try testing.expectEqual(@as(u21, 'A'), term.cells[0].cp);
    try testing.expectEqual(@as(u21, 0xE9), term.cells[1].cp);
    try testing.expectEqual(@as(u21, 'B'), term.cells[2].cp);
}
