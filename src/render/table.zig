//! Zig-native markdown table box-drawing (JOE `lgen_view` Feature 2.1/2.2).
//!
//! Detects contiguous `|`-delimited table regions, computes per-column display
//! widths + alignment from separator markers, and paints padded rows with
//! Unicode box-drawing borders. Live Path A uses `layoutAt` via
//! `zig_bw_table_detect` and `paintRow` via `zig_bw_table_row`.

const std = @import("std");
const testing = std.testing;
const terminal = @import("terminal");

pub const TermScreen = terminal.Screen;
pub const Attribute = terminal.Attribute;
pub const displayWidth = terminal.displayWidth;

pub const max_cols: usize = 64;
/// Max lines scanned for a single table region (JOE scans up to 200).
pub const max_scan_lines: usize = 200;

pub const Align = enum(u8) {
    left = 0,
    center = 1,
    right = 2,
};

pub const RowKind = enum {
    none,
    header,
    separator,
    body,
    last,
};

pub const Layout = struct {
    /// Inclusive start line index within the source line list.
    start: usize = 0,
    /// Exclusive end line index.
    end: usize = 0,
    /// Separator line index, if any.
    sep: ?usize = null,
    ncols: usize = 0,
    widths: [max_cols]u16 = .{0} ** max_cols,
    aligns: [max_cols]Align = .{.left} ** max_cols,

    pub fn kind(self: Layout, line_idx: usize) RowKind {
        if (line_idx < self.start or line_idx >= self.end) return .none;
        if (self.sep) |s| {
            if (line_idx == s) return .separator;
        }
        if (line_idx == self.start) return .header;
        if (line_idx + 1 == self.end) {
            // Last row is only special for Feature 2.1 fallback; Feature 2.2
            // paints last like body. Prefer .last when no separator (2.1 path).
            if (self.sep == null) return .last;
            if (self.sep) |s| {
                if (line_idx > s) return .last;
            }
        }
        if (self.sep) |s| {
            if (line_idx < s) return .header;
            if (line_idx > s) return .body;
        }
        return .body;
    }
};

/// True when, after leading whitespace, the line starts with `|`.
pub fn isPipeLine(line: []const u8) bool {
    var i: usize = 0;
    while (i < line.len and (line[i] == ' ' or line[i] == '\t')) : (i += 1) {}
    return i < line.len and line[i] == '|';
}

/// Separator row: only `|`, `-`, `:`, space/tab, and at least one `-`.
pub fn isSepLine(line: []const u8) bool {
    var has_dash = false;
    for (line) |b| {
        switch (b) {
            '|', ' ', '\t', ':' => {},
            '-' => has_dash = true,
            else => return false,
        }
    }
    return has_dash;
}

fn cellDisplayWidth(bytes: []const u8) u16 {
    var width: u16 = 0;
    var i: usize = 0;
    while (i < bytes.len) {
        const b = bytes[i];
        if ((b & 0x80) == 0) {
            const cw = displayWidth(b);
            if (cw > 0) width +|= cw;
            i += 1;
        } else {
            const seq_len = std.unicode.utf8ByteSequenceLength(b) catch {
                width +|= 1;
                i += 1;
                continue;
            };
            if (i + seq_len > bytes.len) {
                width +|= 1;
                break;
            }
            const cp = std.unicode.utf8Decode(bytes[i..][0..seq_len]) catch {
                width +|= 1;
                i += 1;
                continue;
            };
            const cw = displayWidth(cp);
            if (cw > 0) width +|= cw;
            i += seq_len;
        }
    }
    return width;
}

fn trimCell(line: []const u8, start: usize, end: usize) struct { start: usize, end: usize } {
    var ts = start;
    while (ts < end and (line[ts] == ' ' or line[ts] == '\t')) : (ts += 1) {}
    var te = end;
    while (te > ts and (line[te - 1] == ' ' or line[te - 1] == '\t')) : (te -= 1) {}
    return .{ .start = ts, .end = te };
}

fn collectPipes(line: []const u8, pipe_pos: *[max_cols]usize) usize {
    var n: usize = 0;
    for (line, 0..) |b, i| {
        if (b == '|' and n < max_cols) {
            pipe_pos[n] = i;
            n += 1;
        }
    }
    return n;
}

fn applySepAlign(layout: *Layout, line: []const u8) void {
    var pipe_pos: [max_cols]usize = undefined;
    const np = collectPipes(line, &pipe_pos);
    if (np == 0) return;
    const ncols = np - 1;
    layout.ncols = @min(ncols, max_cols);
    var k: usize = 0;
    while (k < layout.ncols) : (k += 1) {
        const cs = pipe_pos[k] + 1;
        const ce = if (k + 1 < np) pipe_pos[k + 1] else line.len;
        if (cs >= ce) continue;
        const has_left = line[cs] == ':';
        const has_right = line[ce - 1] == ':';
        if (has_left and has_right) {
            layout.aligns[k] = .center;
        } else if (has_right) {
            layout.aligns[k] = .right;
        } else {
            layout.aligns[k] = .left;
        }
    }
}

fn accumulateWidths(layout: *Layout, line: []const u8) void {
    var pipe_pos: [max_cols]usize = undefined;
    const np = collectPipes(line, &pipe_pos);
    if (np == 0) return;
    const ncols = @min(np - 1, max_cols);
    if (ncols > layout.ncols) layout.ncols = ncols;
    var k: usize = 0;
    while (k < ncols) : (k += 1) {
        const cs = pipe_pos[k] + 1;
        const ce = if (k + 1 < np) pipe_pos[k + 1] else line.len;
        const cell = trimCell(line, cs, ce);
        const width = cellDisplayWidth(line[cell.start..cell.end]);
        if (width > layout.widths[k]) layout.widths[k] = width;
    }
}

/// Detect a table region covering `around` within `lines` (≥2 consecutive pipe lines).
pub fn layoutAt(lines: []const []const u8, around: usize) ?Layout {
    if (around >= lines.len or !isPipeLine(lines[around])) return null;

    var start = around;
    while (start > 0 and isPipeLine(lines[start - 1])) : (start -= 1) {}
    var end = around + 1;
    while (end < lines.len and end - start < max_scan_lines and isPipeLine(lines[end])) : (end += 1) {}
    if (end - start < 2) return null;

    var layout: Layout = .{ .start = start, .end = end };
    var i = start;
    while (i < end) : (i += 1) {
        const line = lines[i];
        if (isSepLine(line)) {
            if (layout.sep == null) layout.sep = i;
            applySepAlign(&layout, line);
        } else {
            accumulateWidths(&layout, line);
        }
    }
    // Separator alone does not contribute content widths; still need ncols.
    if (layout.ncols == 0) {
        if (layout.sep) |s| {
            var pipe_pos: [max_cols]usize = undefined;
            const np = collectPipes(lines[s], &pipe_pos);
            if (np > 0) layout.ncols = np - 1;
        }
    }
    if (layout.ncols == 0) return null;
    return layout;
}

fn clearEol(term: *TermScreen, x: u16, y: u16, end_x: u16, attr: Attribute) void {
    var cx = x;
    const stop = @min(end_x, term.width);
    while (cx < stop) : (cx += 1) {
        term.writeChar(cx, y, ' ', attr);
    }
}

fn put(term: *TermScreen, x: *u16, end_x: u16, y: u16, cp: u21, attr: Attribute) void {
    if (x.* >= end_x or x.* >= term.width) return;
    const wid = displayWidth(cp);
    if (wid >= 2 and @as(u32, x.*) + wid > end_x) {
        while (x.* < end_x and x.* < term.width) : (x.* += 1) {
            term.writeChar(x.*, y, '>', attr);
        }
        return;
    }
    term.writeChar(x.*, y, cp, attr);
    if (wid >= 2 and x.* + 1 < term.width) {
        term.writeChar(x.* + 1, y, 0, attr);
    }
    x.* +|= if (wid > 0) wid else 1;
}

/// Paint one Feature 2.2 padded table row. Returns false if `line_idx` is not in layout.
pub fn paintRow(
    term: *TermScreen,
    x: u16,
    y: u16,
    w: u16,
    line: []const u8,
    layout: Layout,
    line_idx: usize,
    base_attr: Attribute,
) bool {
    const row_kind = layout.kind(line_idx);
    if (row_kind == .none) return false;
    if (w == 0) return true;

    var attr = base_attr;
    if (row_kind == .header) attr.bold = true;

    const end_x: u16 = x +| w;
    var pipe_pos: [max_cols]usize = undefined;
    const pipe_count = collectPipes(line, &pipe_pos);
    if (pipe_count == 0) return false;
    const ncols = @min(if (pipe_count > 0) pipe_count - 1 else 0, layout.ncols);
    if (ncols == 0) return false;

    var cells: [max_cols]struct { start: usize, end: usize, width: u16 } = undefined;
    var ci: usize = 0;
    while (ci < ncols) : (ci += 1) {
        const cs = pipe_pos[ci] + 1;
        const ce = if (ci + 1 < pipe_count) pipe_pos[ci + 1] else line.len;
        const cell = trimCell(line, cs, ce);
        cells[ci] = .{
            .start = cell.start,
            .end = cell.end,
            .width = cellDisplayWidth(line[cell.start..cell.end]),
        };
    }

    var total_width: u16 = 1; // closing border
    var col: usize = 0;
    while (col < ncols) : (col += 1) {
        total_width +|= 3 + layout.widths[col];
    }
    const max_col = w;
    if (total_width > max_col) total_width = max_col;
    if (total_width == 0) return true;
    const limit = x +| total_width;

    if (row_kind == .separator) {
        var oc = x;
        col = 0;
        while (col < ncols and oc < limit) : (col += 1) {
            const cw = layout.widths[col];
            const seg_w: u16 = cw +| 2;
            if (@as(u32, oc) + 1 + seg_w > limit) break;
            const joint: u21 = if (col == 0) 0x251C else 0x253C; // ├ ┼
            put(term, &oc, limit, y, joint, attr);
            var di: u16 = 0;
            while (di < seg_w and oc < limit) : (di += 1) {
                put(term, &oc, limit, y, 0x2500, attr); // ─
            }
        }
        if (oc < limit) put(term, &oc, limit, y, 0x2524, attr); // ┤
        if (oc < end_x) clearEol(term, oc, y, end_x, base_attr);
        return true;
    }

    // Header / body / last — Feature 2.2 always uses │ borders.
    var oc = x;
    col = 0;
    while (col < ncols and oc < limit) : (col += 1) {
        var cw = layout.widths[col];
        if (cw < cells[col].width) cw = cells[col].width;
        if (@as(u32, oc) + 1 + 1 + cw + 1 > limit) break;

        put(term, &oc, limit, y, 0x2502, attr); // │
        put(term, &oc, limit, y, ' ', attr);

        const avail = cw;
        var cwidth = cells[col].width;
        if (cwidth > avail) cwidth = avail;
        const pad_total: u16 = avail -| cwidth;
        var pad_left: u16 = 0;
        var pad_right: u16 = pad_total;
        switch (layout.aligns[col]) {
            .left => {},
            .center => {
                pad_left = pad_total / 2;
                pad_right = pad_total -| pad_left;
            },
            .right => {
                pad_left = pad_total;
                pad_right = 0;
            },
        }

        var pi: u16 = 0;
        while (pi < pad_left and oc < limit) : (pi += 1) {
            put(term, &oc, limit, y, ' ', attr);
        }

        // Cell content
        var bi = cells[col].start;
        while (bi < cells[col].end and oc < limit) {
            const b = line[bi];
            if ((b & 0x80) == 0) {
                put(term, &oc, limit, y, b, attr);
                bi += 1;
            } else {
                const seq_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
                if (bi + seq_len > cells[col].end) break;
                const cp = std.unicode.utf8Decode(line[bi..][0..seq_len]) catch {
                    put(term, &oc, limit, y, 'X', attr);
                    bi += 1;
                    continue;
                };
                put(term, &oc, limit, y, cp, attr);
                bi += seq_len;
            }
        }

        pi = 0;
        while (pi < pad_right and oc < limit) : (pi += 1) {
            put(term, &oc, limit, y, ' ', attr);
        }
        if (oc < limit) put(term, &oc, limit, y, ' ', attr); // right pad
    }
    if (oc < limit) put(term, &oc, limit, y, 0x2502, attr); // closing │
    if (oc < end_x) clearEol(term, oc, y, end_x, base_attr);
    return true;
}

/// Feature 2.1 in-place pipe substitution when no column widths are available.
pub fn applySimpleBorders(substitute: []u21, line: []const u8, row_kind: RowKind) void {
    if (row_kind == .none) return;
    var pipe_pos: [max_cols]usize = undefined;
    const pipe_count = collectPipes(line, &pipe_pos);
    if (pipe_count == 0) return;

    const first: u21, const mid: u21, const last: u21 = switch (row_kind) {
        .header => .{ 0x250C, 0x252C, 0x2510 }, // ┌ ┬ ┐
        .separator => .{ 0x251C, 0x253C, 0x2524 }, // ├ ┼ ┤
        .body => .{ 0x2502, 0x2502, 0x2502 }, // │
        .last => .{ 0x2514, 0x2534, 0x2518 }, // └ ┴ ┘
        .none => return,
    };

    if (pipe_count == 1) {
        if (pipe_pos[0] < substitute.len) substitute[pipe_pos[0]] = first;
    } else {
        if (pipe_pos[0] < substitute.len) substitute[pipe_pos[0]] = first;
        var pi: usize = 1;
        while (pi + 1 < pipe_count) : (pi += 1) {
            if (pipe_pos[pi] < substitute.len) substitute[pipe_pos[pi]] = mid;
        }
        if (pipe_pos[pipe_count - 1] < substitute.len)
            substitute[pipe_pos[pipe_count - 1]] = last;
    }

    if (row_kind == .separator) {
        for (line, 0..) |b, i| {
            if (i >= substitute.len) break;
            if (b == '-' or b == ':') substitute[i] = 0x2500;
        }
    }
}

/// Try to paint `line_idx` as a padded table row from `lines`. True if painted.
pub fn tryPaintFromLines(
    term: *TermScreen,
    x: u16,
    y: u16,
    w: u16,
    lines: []const []const u8,
    line_idx: usize,
    base_attr: Attribute,
) bool {
    const layout = layoutAt(lines, line_idx) orelse return false;
    if (line_idx >= lines.len) return false;
    return paintRow(term, x, y, w, lines[line_idx], layout, line_idx, base_attr);
}

// ── Tests ────────────────────────────────────────────────────────────

fn expectRow(term: *const TermScreen, x: u16, y: u16, expected: []const u8) !void {
    var col: u16 = x;
    var i: usize = 0;
    while (i < expected.len) {
        const b = expected[i];
        const idx = @as(usize, y) * @as(usize, term.width) + @as(usize, col);
        try testing.expect(idx < term.cells.len);
        if ((b & 0x80) == 0) {
            try testing.expectEqual(@as(u21, b), term.cells[idx].cp);
            col += 1;
            i += 1;
        } else {
            const seq_len = try std.unicode.utf8ByteSequenceLength(b);
            const cp = try std.unicode.utf8Decode(expected[i..][0..seq_len]);
            try testing.expectEqual(cp, term.cells[idx].cp);
            col +|= displayWidth(cp);
            i += seq_len;
        }
    }
}

test "table layoutAt requires two pipe lines" {
    const lines = [_][]const u8{"| a | b |"};
    try testing.expect(layoutAt(&lines, 0) == null);

    const single = [_][]const u8{"a | b"};
    try testing.expect(layoutAt(&single, 0) == null);
}

test "table layoutAt widths and alignment" {
    const lines = [_][]const u8{
        "| Short | LongerName |",
        "|---|---|",
        "| ab | cd |",
    };
    const layout = layoutAt(&lines, 0).?;
    try testing.expectEqual(@as(usize, 0), layout.start);
    try testing.expectEqual(@as(usize, 3), layout.end);
    try testing.expectEqual(@as(?usize, 1), layout.sep);
    try testing.expectEqual(@as(usize, 2), layout.ncols);
    // "Short" = 5, "LongerName" = 10; body ab=2, cd=2
    try testing.expectEqual(@as(u16, 5), layout.widths[0]);
    try testing.expectEqual(@as(u16, 10), layout.widths[1]);
    try testing.expect(layout.kind(0) == .header);
    try testing.expect(layout.kind(1) == .separator);
    try testing.expect(layout.kind(2) == .last);
}

test "table layoutAt reads : alignment markers" {
    const lines = [_][]const u8{
        "| L | C | R |",
        "|:---|:---:|---:|",
        "| a | b | c |",
    };
    const layout = layoutAt(&lines, 2).?;
    try testing.expect(layout.aligns[0] == .left);
    try testing.expect(layout.aligns[1] == .center);
    try testing.expect(layout.aligns[2] == .right);
}

test "table paint separator and padded body" {
    const lines = [_][]const u8{
        "| Header1 | Header2 |",
        "|---|---|",
        "| cell1 | cell2 |",
        "| cell3 | cell4 |",
    };
    const layout = layoutAt(&lines, 0).?;
    try testing.expectEqual(@as(u16, 7), layout.widths[0]);
    try testing.expectEqual(@as(u16, 7), layout.widths[1]);

    var term = try TermScreen.init(testing.allocator, 40, 4);
    defer term.deinit();

    try testing.expect(paintRow(&term, 0, 0, 40, lines[0], layout, 0, .none));
    try testing.expect(paintRow(&term, 0, 1, 40, lines[1], layout, 1, .none));
    try testing.expect(paintRow(&term, 0, 2, 40, lines[2], layout, 2, .none));
    try testing.expect(paintRow(&term, 0, 3, 40, lines[3], layout, 3, .none));

    // Separator: ├ + 9*─ + ┼ + 9*─ + ┤
    try expectRow(&term, 0, 1, "\u{251c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{253c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2524}");
    // Body: │ cell1   │ cell2   │
    try expectRow(&term, 0, 2, "\u{2502} cell1   \u{2502} cell2   \u{2502}");
    try expectRow(&term, 0, 3, "\u{2502} cell3   \u{2502} cell4   \u{2502}");
    // Header bold
    try testing.expect(term.cells[0].attr.bold);
}

test "table paint varying widths and body wider than header" {
    const lines = [_][]const u8{
        "| Hdr | Label |",
        "|----|------|",
        "| longbody | tiny |",
    };
    var term = try TermScreen.init(testing.allocator, 40, 3);
    defer term.deinit();
    try testing.expect(tryPaintFromLines(&term, 0, 0, 40, &lines, 0, .none));
    try testing.expect(tryPaintFromLines(&term, 0, 1, 40, &lines, 1, .none));
    try testing.expect(tryPaintFromLines(&term, 0, 2, 40, &lines, 2, .none));

    try expectRow(&term, 0, 0, "\u{2502} Hdr      \u{2502} Label \u{2502}");
    try expectRow(&term, 0, 1, "\u{251c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{253c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2524}");
    try expectRow(&term, 0, 2, "\u{2502} longbody \u{2502} tiny  \u{2502}");
}

test "table two regions separated by blank line" {
    const lines = [_][]const u8{
        "| A | B |",
        "|---|---|",
        "| 1 | 2 |",
        "",
        "| X | Y |",
        "|---|---|",
        "| a | b |",
    };
    const a = layoutAt(&lines, 0).?;
    try testing.expectEqual(@as(usize, 0), a.start);
    try testing.expectEqual(@as(usize, 3), a.end);
    const b = layoutAt(&lines, 4).?;
    try testing.expectEqual(@as(usize, 4), b.start);
    try testing.expectEqual(@as(usize, 7), b.end);

    var term = try TermScreen.init(testing.allocator, 20, 1);
    defer term.deinit();
    try testing.expect(tryPaintFromLines(&term, 0, 0, 20, &lines, 2, .none));
    try expectRow(&term, 0, 0, "\u{2502} 1 \u{2502} 2 \u{2502}");
}

test "table applySimpleBorders header and last" {
    var sub: [16]u21 = .{0} ** 16;
    const line = "| a | b |";
    applySimpleBorders(&sub, line, .header);
    try testing.expectEqual(@as(u21, 0x250C), sub[0]);
    try testing.expectEqual(@as(u21, 0x252C), sub[4]);
    try testing.expectEqual(@as(u21, 0x2510), sub[8]);

    @memset(&sub, 0);
    applySimpleBorders(&sub, line, .last);
    try testing.expectEqual(@as(u21, 0x2514), sub[0]);
    try testing.expectEqual(@as(u21, 0x2534), sub[4]);
    try testing.expectEqual(@as(u21, 0x2518), sub[8]);
}
