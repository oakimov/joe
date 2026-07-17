//! Bridge tests-only window paint shapes onto Zig-native `terminal.Screen` cells.
//!
//! Parallel to JOE `genfmt` / `menudisp` / `dispqw` / `disppw` / `mdisp` /
//! `edupd` writing into SCRN. Not wired into live `joe` — unit-tested only.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const terminal = @import("terminal");
const screen = @import("screen.zig");
const tw = @import("tw.zig");
const pw = @import("pw.zig");
const qw = @import("qw.zig");
const menu = @import("menu.zig");

pub const TermScreen = terminal.Screen;
pub const Attribute = terminal.Attribute;
pub const Cell = terminal.screen.Cell;

pub const CursorPos = struct {
    x: u16 = 0,
    y: u16 = 0,
};

/// Read one cell (tests / callers). Out-of-range returns a blank cell.
pub fn cellAt(term: *const TermScreen, x: u16, y: u16) Cell {
    if (x >= term.width or y >= term.height) return .{};
    const idx = @as(usize, y) * @as(usize, term.width) + @as(usize, x);
    return term.cells[idx];
}

fn screenY(term: *const TermScreen, y: i16) ?u16 {
    if (y < 0 or y >= @as(i16, @intCast(term.height))) return null;
    return @intCast(y);
}

fn toggleStyle(attr: Attribute, which: enum { underline, inverse, bold, italic, dim, blink, crossed_out, double_underline }) Attribute {
    var out = attr;
    switch (which) {
        .underline => out.underline = !out.underline,
        .inverse => out.inverse = !out.inverse,
        .bold => out.bold = !out.bold,
        .italic => out.italic = !out.italic,
        .dim => out.dim = !out.dim,
        .blink => out.blink = !out.blink,
        .crossed_out => out.crossed_out = !out.crossed_out,
        .double_underline => out.double_underline = !out.double_underline,
    }
    return out;
}

/// JOE `genfmt` shape: write format string `s` into cells at `(x, y)`, skipping
/// the first `ofst` display columns. Attribute escapes (`\i`, `\u`, …) toggle
/// styles. Byte-column width (matches window `fmtLen` scaffold). Returns the
/// column after the last written glyph (clamped to `term.width`).
pub fn writeFmt(term: *TermScreen, x: u16, y: i16, ofst: usize, s: []const u8, base_attr: Attribute) u16 {
    const sy = screenY(term, y) orelse return x;
    var col: usize = 0;
    var cx: u16 = x;
    var attr = base_attr;
    var i: usize = 0;
    while (i < s.len) {
        if (s[i] == '\\' and i + 1 < s.len) {
            const esc = s[i + 1];
            i += 2;
            switch (esc) {
                'u', 'U' => attr = toggleStyle(attr, .underline),
                'i', 'I' => attr = toggleStyle(attr, .inverse),
                'b', 'B' => attr = toggleStyle(attr, .bold),
                'l', 'L' => attr = toggleStyle(attr, .italic),
                'd', 'D' => attr = toggleStyle(attr, .dim),
                'f', 'F' => attr = toggleStyle(attr, .blink),
                's', 'S' => attr = toggleStyle(attr, .crossed_out),
                'z', 'Z' => attr = toggleStyle(attr, .double_underline),
                '@' => {
                    if (col >= ofst and cx < term.width) {
                        term.writeChar(cx, sy, 0, attr);
                        cx += 1;
                    }
                    col += 1;
                },
                else => {
                    if (col >= ofst and cx < term.width) {
                        term.writeChar(cx, sy, esc, attr);
                        cx += 1;
                    }
                    col += 1;
                },
            }
            continue;
        }
        const ch: u21 = s[i];
        i += 1;
        if (col >= ofst and cx < term.width) {
            term.writeChar(cx, sy, ch, attr);
            cx += 1;
        }
        col += 1;
    }
    return cx;
}

/// Clear cells from `x` through end of window width `win_w` on row `y` (eraeol shape).
pub fn clearWinEol(term: *TermScreen, x: u16, y: i16, win_w: u16, attr: Attribute) void {
    const sy = screenY(term, y) orelse return;
    const end = @min(term.width, x +% win_w);
    var cx = x;
    while (cx < end) : (cx += 1) {
        term.writeChar(cx, sy, ' ', attr);
    }
}

/// Blit a menu `Paint` buffer into `term` at window origin `(ox, oy)`.
pub fn blitMenu(term: *TermScreen, ox: u16, oy: i16, painted: *const menu.Paint, attr: Attribute) CursorPos {
    var y: usize = 0;
    while (y < painted.h) : (y += 1) {
        const row_y: i16 = oy + @as(i16, @intCast(y));
        const sy = screenY(term, row_y) orelse continue;
        var x: usize = 0;
        while (x < painted.w and ox + @as(u16, @intCast(x)) < term.width) : (x += 1) {
            var a = attr;
            if (painted.isInverse(x, y)) a.inverse = true;
            term.writeChar(ox + @as(u16, @intCast(x)), sy, painted.charAt(x, y), a);
        }
    }
    const cur_x = ox +% @as(u16, @intCast(@min(painted.cur.x, std.math.maxInt(u16))));
    const cur_y_i: i16 = oy + @as(i16, @intCast(@min(painted.cur.y, std.math.maxInt(i16))));
    const cur_y: u16 = if (screenY(term, cur_y_i)) |yy| yy else 0;
    return .{ .x = @min(cur_x, term.width -| 1), .y = cur_y };
}

/// Paint a menu window into `term` (JOE `menudisp` → cells).
pub fn paintMenu(term: *TermScreen, allocator: Allocator, m: *const menu.MenuWindow, focused: bool, attr: Attribute) !CursorPos {
    var painted = try m.paint(allocator, focused);
    defer painted.deinit();
    return blitMenu(term, m.x, m.y, &painted, attr);
}

/// Blit query `Paint` rows into `term` at `(ox, oy)`.
pub fn blitQuery(term: *TermScreen, ox: u16, oy: i16, painted: *const qw.Paint, attr: Attribute) CursorPos {
    for (painted.rows, 0..) |row, y| {
        const row_y: i16 = oy + @as(i16, @intCast(y));
        _ = writeFmt(term, ox, row_y, 0, row, attr);
    }
    const cur_x = ox +% @as(u16, @intCast(@min(painted.cur.x, std.math.maxInt(u16))));
    const cur_y_i: i16 = oy + @as(i16, @intCast(@min(painted.cur.y, std.math.maxInt(i16))));
    const cur_y: u16 = if (screenY(term, cur_y_i)) |yy| yy else 0;
    return .{ .x = @min(cur_x, term.width -| 1), .y = cur_y };
}

/// Paint a query window into `term` (JOE `dispqw` → cells).
pub fn paintQuery(term: *TermScreen, allocator: Allocator, q: *const qw.QueryWindow, attr: Attribute) !CursorPos {
    var painted = try q.paint(allocator);
    defer painted.deinit();
    return blitQuery(term, q.x, q.y, &painted, attr);
}

/// Paint prompt label + edit line into `term` (JOE `disppw` label half → cells).
/// Edit bytes use plain `writeText` at the layout edit origin; no BW/render yet.
pub fn paintPrompt(term: *TermScreen, p: *pw.PromptWindow, cursor_col: usize, attr: Attribute) CursorPos {
    const lay = p.computeLayout(cursor_col);
    _ = writeFmt(term, p.x, p.y, lay.prompt_ofst, p.prompt, attr);
    const edit_x = p.x +% @as(u16, @intCast(@min(lay.prompt_visible, std.math.maxInt(u16))));
    const edit = p.line.items;
    const start = @min(lay.edit_offset, edit.len);
    const vis = edit[start..];
    if (screenY(term, p.y)) |sy| {
        // Limit to remaining window width.
        const budget = p.w -| @as(u16, @intCast(@min(lay.prompt_visible, p.w)));
        const n = @min(vis.len, @as(usize, budget));
        if (n > 0) term.writeText(edit_x, sy, vis[0..n], attr);
        // Pad remainder of the prompt window row.
        const used = @as(u16, @intCast(@min(lay.prompt_visible + n, p.w)));
        clearWinEol(term, p.x +% used, p.y, p.w -| used, attr);
    }
    return .{
        .x = p.x +% @as(u16, @intCast(@min(lay.curx, std.math.maxInt(u16)))),
        .y = if (screenY(term, p.y)) |sy| sy else 0,
    };
}

/// Write a composed status / format line into `term` (JOE `genfmt` status path).
pub fn paintStatus(term: *TermScreen, x: u16, y: i16, win_w: u16, line: []const u8, attr: Attribute) void {
    const end = writeFmt(term, x, y, 0, line, attr);
    const used = end -% x;
    if (used < win_w) clearWinEol(term, end, y, win_w -| used, attr);
}

/// Paint temporary top/bottom messages for `w` (JOE `msgout` / `mdisp`).
pub fn paintMsgs(term: *TermScreen, w: *const screen.Window, status_enabled: bool, attr: Attribute) void {
    if (w.msg_bot) |msg| {
        if (w.msgBotRow()) |row| {
            const len = tw.fmtLen(msg);
            const ofst: usize = if (len <= term.width) 0 else len -| term.width;
            _ = writeFmt(term, 0, row, ofst, msg, attr);
        }
    }
    if (w.msg_top) |msg| {
        if (w.msgTopRow(status_enabled)) |row| {
            const len = tw.fmtLen(msg);
            const ofst: usize = if (len <= term.width) 0 else len -| term.width;
            _ = writeFmt(term, 0, row, ofst, msg, attr);
        }
    }
}

/// JOE `gennum` scaffold: right-align 1-based line number into `lincols` cols
/// (trailing space when `lincols >= 2`). Past-EOF / blank → spaces.
pub fn paintLinum(term: *TermScreen, x: u16, y: i16, lincols: u16, line_1based: ?u64, attr: Attribute) void {
    if (lincols == 0) return;
    const sy = screenY(term, y) orelse return;
    var buf: [24]u8 = .{' '} ** 24;
    if (line_1based) |n| {
        var tmp: [24]u8 = undefined;
        // Match JOE `" %21lld "` then take the trailing `lincols` chars.
        const formatted = std.fmt.bufPrint(&tmp, " {d: >21} ", .{n}) catch {
            clearWinEol(term, x, y, lincols, attr);
            return;
        };
        const take = @min(@as(usize, lincols), formatted.len);
        const src = formatted[formatted.len - take ..];
        @memcpy(buf[0..take], src);
    }
    const n = @min(@as(usize, lincols), @as(usize, term.width -| x));
    var i: usize = 0;
    while (i < n) : (i += 1) {
        term.writeChar(x + @as(u16, @intCast(i)), sy, buf[i], attr);
    }
}

/// Shallow text-body paint (bwgen/lgen scaffold): stub lines + optional linums.
/// No gapbuffer/syntax — Phase 6/`render` replaces this with real `lgen`.
/// Clears each content row (and gutter when `linums`); applies `offset` as a
/// byte-column skip (ASCII scaffold).
pub fn paintBody(term: *TermScreen, t: *const tw.TextWindow, attr: Attribute) void {
    if (t.h == 0) return;
    if (t.w == 0 and t.lincols == 0) return;
    var row: u16 = 0;
    while (row < t.h) : (row += 1) {
        const row_y: i16 = t.y + @as(i16, @intCast(row));
        const line_idx = t.lineAtRow(row);
        // null body_lines → no stub buffer (treat as past EOF / blank).
        const past_eof = if (t.body_lines) |lines| line_idx >= lines.len else true;

        if (t.linums and t.lincols > 0) {
            const num: ?u64 = if (past_eof) null else line_idx + 1;
            paintLinum(term, t.parent.x, row_y, t.lincols, num, attr);
        } else if (t.lincols > 0) {
            // Gutter reserved but linums off — clear so ghost digits don't linger.
            clearWinEol(term, t.parent.x, row_y, t.lincols, attr);
        }

        if (t.w == 0) continue;
        const text = if (!past_eof) t.bodyLine(line_idx) else null;
        if (text) |s| {
            const start = @min(@as(usize, t.offset), s.len);
            const vis = s[start..];
            if (screenY(term, row_y)) |sy| {
                const n = @min(vis.len, @as(usize, t.w));
                if (n > 0) term.writeText(t.x, sy, vis[0..n], attr);
                const used: u16 = @intCast(n);
                if (used < t.w) clearWinEol(term, t.x +% used, row_y, t.w -| used, attr);
            }
        } else {
            clearWinEol(term, t.x, row_y, t.w, attr);
        }
    }
}

/// Minimum display width of a help line (JOE help_display first pass).
/// Attribute escapes consume no columns; `\|` is a spring (not width);
/// other `\X` escapes contribute one column for `X`.
fn helpMinWidth(line: []const u8) struct { width: usize, nspans: usize } {
    var width: usize = 0;
    var nspans: usize = 0;
    var i: usize = 0;
    while (i < line.len) {
        if (line[i] == '\\' and i + 1 < line.len) {
            const esc = line[i + 1];
            i += 2;
            switch (esc) {
                'u', 'U', 'i', 'I', 'b', 'B', 'l', 'L', 'd', 'D', 'f', 'F', 's', 'S', 'z', 'Z' => {},
                '|' => nspans += 1,
                else => width += 1,
            }
            continue;
        }
        i += 1;
        width += 1;
    }
    return .{ .width = width, .nspans = nspans };
}

/// Paint one help row across the full terminal width (JOE `help_display` row).
/// Supports genfmt-style toggles plus `\|` springs that absorb leftover width.
pub fn paintHelpLine(term: *TermScreen, y: i16, line: []const u8, base_attr: Attribute) void {
    const sy = screenY(term, y) orelse return;
    const twid: usize = term.width;
    const meta = helpMinWidth(line);
    var spanwidth: usize = 0;
    var spanextra: usize = meta.nspans;
    if (meta.width < twid and meta.nspans > 0) {
        spanwidth = (twid - meta.width) / meta.nspans;
        const rem = twid - meta.width - meta.nspans * spanwidth;
        spanextra = meta.nspans - rem;
    }

    var attr = base_attr;
    var x: usize = 0;
    var i: usize = 0;
    var spancount: usize = 0;
    while (i < line.len and x < twid) {
        if (line[i] == '\\' and i + 1 < line.len) {
            const esc = line[i + 1];
            i += 2;
            switch (esc) {
                'u', 'U' => attr = toggleStyle(attr, .underline),
                'i', 'I' => attr = toggleStyle(attr, .inverse),
                'b', 'B' => attr = toggleStyle(attr, .bold),
                'l', 'L' => attr = toggleStyle(attr, .italic),
                'd', 'D' => attr = toggleStyle(attr, .dim),
                'f', 'F' => attr = toggleStyle(attr, .blink),
                's', 'S' => attr = toggleStyle(attr, .crossed_out),
                'z', 'Z' => attr = toggleStyle(attr, .double_underline),
                '|' => {
                    var z: usize = 0;
                    while (z < spanwidth and x < twid) : (z += 1) {
                        term.writeChar(@intCast(x), sy, ' ', attr);
                        x += 1;
                    }
                    if (spancount >= spanextra and x < twid) {
                        term.writeChar(@intCast(x), sy, ' ', attr);
                        x += 1;
                    }
                    spancount += 1;
                },
                else => {
                    term.writeChar(@intCast(x), sy, esc, attr);
                    x += 1;
                },
            }
            continue;
        }
        const ch: u21 = line[i];
        i += 1;
        term.writeChar(@intCast(x), sy, ch, attr);
        x += 1;
    }
    if (x < twid) clearWinEol(term, @intCast(x), y, @intCast(twid - x), base_attr);
}

/// Paint help chrome into rows `[0, wind)` (JOE `help_display` before window disp).
/// `text` is borrowed multiline help (`\n`-separated). Extra wind rows are cleared.
pub fn paintHelp(term: *TermScreen, wind: u16, text: ?[]const u8, attr: Attribute) void {
    if (wind == 0) return;
    var rest: []const u8 = text orelse &[_]u8{};
    var y: u16 = 0;
    while (y < wind) : (y += 1) {
        var line: []const u8 = &[_]u8{};
        if (rest.len > 0) {
            if (std.mem.indexOfScalar(u8, rest, '\n')) |nl| {
                line = rest[0..nl];
                rest = rest[nl + 1 ..];
            } else {
                line = rest;
                rest = &[_]u8{};
            }
        }
        paintHelpLine(term, @intCast(y), line, attr);
    }
}

pub const PaintError = error{NoTerminal} || Allocator.Error;

/// Paint text-window chrome (status) + shallow body stub (bwgen-shaped).
/// Returns content-area cursor (JOE `disptw` curx/cury abs scaffold).
pub fn paintText(term: *TermScreen, t: *const tw.TextWindow, status_line: ?[]const u8, attr: Attribute) CursorPos {
    if (t.statusRow()) |row| {
        const line = status_line orelse t.status_line;
        if (line) |s| {
            paintStatus(term, t.parent.x, row, t.parent.w, s, attr);
        } else {
            clearWinEol(term, t.parent.x, row, t.parent.w, attr);
        }
    }
    paintBody(term, t, attr);
    const cur = t.contentCursor();
    const cy: u16 = if (screenY(term, cur.y)) |yy| yy else 0;
    return .{ .x = @min(cur.x, term.width -| 1), .y = cy };
}

/// Dispatch one window's paint shape into `term` (JOE `watom->disp`).
pub fn paintWindow(term: *TermScreen, allocator: Allocator, w: *screen.Window, focused: bool, attr: Attribute) PaintError!CursorPos {
    const fallback_y: u16 = if (w.y >= 0 and w.y < @as(i16, @intCast(term.height))) @intCast(w.y) else 0;
    const fallback: CursorPos = .{ .x = @min(w.x, term.width -| 1), .y = fallback_y };
    return switch (w.vtable.kind) {
        .text => blk: {
            const t = w.asText() orelse break :blk fallback;
            break :blk paintText(term, t, null, attr);
        },
        .prompt => blk: {
            const p = w.asPrompt() orelse break :blk fallback;
            // No live BW cursor yet — paint with caret at end of edit line.
            break :blk paintPrompt(term, p, p.line.items.len, attr);
        },
        .query => blk: {
            const q = w.asQuery() orelse break :blk fallback;
            break :blk try paintQuery(term, allocator, q, attr);
        },
        .menu => blk: {
            const m = w.asMenu() orelse break :blk fallback;
            break :blk try paintMenu(term, allocator, m, focused, attr);
        },
        .base => fallback,
    };
}

/// Edupd-shaped pass: paint every on-screen window into `scr.term`, then msgs.
/// Updates `scr.cursor_x` / `scr.cursor_y` from the current window's paint cursor.
pub fn paintAll(scr: *screen.Screen, allocator: Allocator, attr: Attribute) PaintError!CursorPos {
    const term = scr.term orelse return error.NoTerminal;
    var cursor: CursorPos = .{
        .x = scr.cursor_x,
        .y = scr.cursor_y,
    };
    // JOE edupd: help_display(maint) before the window disp loop.
    if (scr.wind > 0) {
        paintHelp(term, scr.wind, scr.help_text, attr);
    }
    const cur_id = scr.cur_id;
    for (scr.order.items) |w| {
        if (w.y < 0 or w.h == 0) continue;
        const focused = w.id == cur_id;
        const c = try paintWindow(term, allocator, w, focused, attr);
        if (focused) cursor = c;
        paintMsgs(term, w, tw.status_enabled, attr);
    }
    scr.cursor_x = cursor.x;
    scr.cursor_y = cursor.y;
    return cursor;
}

test "writeFmt toggles inverse and skips ofst" {
    var term = try TermScreen.init(testing.allocator, 20, 4);
    defer term.deinit();
    const end = writeFmt(&term, 2, 1, 1, "a\\iBC\\ide", .none);
    // ofst=1 skips 'a'; writes B,C inverse, then d,e normal. Start x=2.
    try testing.expectEqual(@as(u16, 6), end);
    try testing.expectEqual(@as(u21, 'B'), cellAt(&term, 2, 1).cp);
    try testing.expect(cellAt(&term, 2, 1).attr.inverse);
    try testing.expectEqual(@as(u21, 'C'), cellAt(&term, 3, 1).cp);
    try testing.expect(cellAt(&term, 3, 1).attr.inverse);
    try testing.expectEqual(@as(u21, 'd'), cellAt(&term, 4, 1).cp);
    try testing.expect(!cellAt(&term, 4, 1).attr.inverse);
    try testing.expectEqual(@as(u21, 'e'), cellAt(&term, 5, 1).cp);
}

test "writeFmt ignores off-screen rows" {
    var term = try TermScreen.init(testing.allocator, 8, 2);
    defer term.deinit();
    _ = writeFmt(&term, 0, 0, 0, "ok", .none);
    _ = writeFmt(&term, 0, -1, 0, "nope", .none);
    _ = writeFmt(&term, 0, 2, 0, "nope", .none);
    try testing.expectEqual(@as(u21, 'o'), cellAt(&term, 0, 0).cp);
    // Row 1 untouched (blank default cell).
    try testing.expect(cellAt(&term, 0, 1).isBlankNone());
}

test "paintMenu writes grid and inverse selection into cells" {
    var scr = try screen.Screen.init(testing.allocator, 20, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    win.w = 11;
    win.h = 2;
    win.x = 3;
    win.y = 4;

    const items = [_][]const u8{ "a", "b", "c", "d", "e", "f" };
    var menu_win = menu.MenuWindow.init(win, &items, 0);
    menu_win.x = win.x;
    menu_win.y = win.y;

    var term = try TermScreen.init(testing.allocator, 20, 24);
    defer term.deinit();
    const cur = try paintMenu(&term, testing.allocator, &menu_win, true, .none);
    try testing.expectEqual(@as(u21, 'a'), cellAt(&term, 3, 4).cp);
    try testing.expect(cellAt(&term, 3, 4).attr.inverse);
    try testing.expectEqual(@as(u21, 'b'), cellAt(&term, 5, 4).cp);
    try testing.expect(!cellAt(&term, 5, 4).attr.inverse);
    try testing.expectEqual(@as(u21, 'f'), cellAt(&term, 3, 5).cp);
    try testing.expectEqual(@as(u16, 3 + 1), cur.x);
    try testing.expectEqual(@as(u16, 4), cur.y);
}

test "paintQuery writes wrapped prompt rows into cells" {
    var scr = try screen.Screen.init(testing.allocator, 20, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    win.x = 1;
    win.y = 2;

    // Word-wrap (JOE break_height): width 10 → "Replace" then "with ...".
    const prompt = "Replace with (S to skip)";
    var qw_win = try qw.QueryWindow.init(testing.allocator, win, prompt, .capture);
    defer qw_win.deinit(testing.allocator);
    qw_win.x = 1;
    qw_win.y = 2;
    qw_win.w = 10;
    qw_win.h = 3;
    qw_win.org_w = 10;

    var term = try TermScreen.init(testing.allocator, 20, 24);
    defer term.deinit();
    const cur = try paintQuery(&term, testing.allocator, &qw_win, .none);
    try testing.expectEqual(@as(u21, 'R'), cellAt(&term, 1, 2).cp);
    try testing.expectEqual(@as(u21, 'w'), cellAt(&term, 1, 3).cp);
    try testing.expectEqual(@as(u16, 4), cur.y); // last painted row (y=2 + h-1)
}

test "paintPrompt writes prompt and edit line into cells" {
    var scr = try screen.Screen.init(testing.allocator, 40, 10);
    defer scr.deinit();
    const win = try scr.createText(null, null, 10);
    win.w = 20;
    win.h = 1;
    win.x = 2;
    win.y = 3;

    var pw_win = try pw.PromptWindow.init(testing.allocator, win, "File: ");
    defer pw_win.deinit(testing.allocator);
    pw_win.x = win.x;
    pw_win.y = win.y;
    try pw_win.setLine(testing.allocator, "hello.txt");

    var term = try TermScreen.init(testing.allocator, 40, 10);
    defer term.deinit();
    const cur = paintPrompt(&term, &pw_win, 0, .none);
    try testing.expectEqual(@as(u21, 'F'), cellAt(&term, 2, 3).cp);
    try testing.expectEqual(@as(u21, 'h'), cellAt(&term, 2 + 6, 3).cp);
    try testing.expectEqual(@as(u16, 2 + 6), cur.x);
    try testing.expectEqual(@as(u16, 3), cur.y);
}

test "paintStatus and paintMsgs write into terminal cells" {
    var scr = try screen.Screen.init(testing.allocator, 20, 8);
    defer scr.deinit();
    const win = try scr.createText(null, null, 8);
    try testing.expect(win.h >= 2);
    win.y = 0;
    win.setMsgBot("bottom-msg");
    win.setMsgTop("top-msg");

    var term = try TermScreen.init(testing.allocator, 20, 8);
    defer term.deinit();

    paintStatus(&term, win.x, win.y, win.w, "\\iSTATUS\\i ok", .{ .bold = true });
    try testing.expectEqual(@as(u21, 'S'), cellAt(&term, win.x, 0).cp);
    try testing.expect(cellAt(&term, win.x, 0).attr.inverse);
    try testing.expect(cellAt(&term, win.x, 0).attr.bold);
    // After closing \\i, space+'o' are bold only.
    const o_x = win.x + 7; // "STATUS" = 6, then ' '
    try testing.expectEqual(@as(u21, 'o'), cellAt(&term, o_x, 0).cp);
    try testing.expect(!cellAt(&term, o_x, 0).attr.inverse);
    try testing.expect(cellAt(&term, o_x, 0).attr.bold);

    paintMsgs(&term, win, true, .none);
    const bot = win.msgBotRow().?;
    const top = win.msgTopRow(true).?;
    try testing.expectEqual(@as(u21, 'b'), cellAt(&term, 0, @intCast(bot)).cp);
    try testing.expectEqual(@as(u21, 't'), cellAt(&term, 0, @intCast(top)).cp);
}

test "paintStatus composes stagen left/right into a status row" {
    var term = try TermScreen.init(testing.allocator, 40, 3);
    defer term.deinit();
    const ctx: tw.StatusContext = .{
        .name = "demo.txt",
        .line = 9,
        .col = 2,
        .changed = true,
    };
    const left = try tw.stagen(testing.allocator, "\\i%n %m\\i", &ctx, ' ');
    defer testing.allocator.free(left);
    const right = try tw.stagen(testing.allocator, "%r,%c", &ctx, ' ');
    defer testing.allocator.free(right);
    const line = try tw.composeStatus(testing.allocator, left, right, 40, ' ');
    defer testing.allocator.free(line);

    paintStatus(&term, 0, 0, 40, line, .none);
    try testing.expectEqual(@as(u21, 'd'), cellAt(&term, 0, 0).cp);
    try testing.expect(cellAt(&term, 0, 0).attr.inverse);
    // Right side ends with "10,  3" (1-based row/col).
    try testing.expectEqual(@as(u21, '3'), cellAt(&term, 39, 0).cp);
}

test "attachTerm + paintAll paints text status, prompt, menu, msgs" {
    const prev = tw.status_enabled;
    defer tw.status_enabled = prev;
    tw.status_enabled = true;

    var scr = try screen.Screen.init(testing.allocator, 40, 12);
    defer scr.deinit();
    var term = try TermScreen.init(testing.allocator, 40, 12);
    defer term.deinit();
    try scr.attachTerm(&term);

    const main_w = try scr.createText(null, null, 12);
    scr.layout();
    try testing.expect(main_w.h >= 2);
    const tw_obj = main_w.asText().?;
    try testing.expect(tw_obj.status_on);
    tw_obj.status_line = "\\iMAIN\\i";

    const prompt = try scr.createPrompt(main_w.id, main_w.id, main_w.id, 1, "File: ");
    const pw_obj = prompt.asPrompt().?;
    try pw_obj.setLine(testing.allocator, "x.txt");

    const items = [_][]const u8{ "aa", "bb", "cc" };
    const menu_w = try scr.createMenu(prompt.id, main_w.id, main_w.id, &items, 1);
    scr.cur_id = menu_w.id;
    scr.layout();

    main_w.setMsgBot("saved");

    const cur = try paintAll(&scr, testing.allocator, .none);
    // Menu focused → cursor recorded on Screen and inside the menu rect.
    try testing.expectEqual(menu_w.id, scr.cur_id);
    try testing.expectEqual(cur.x, scr.cursor_x);
    try testing.expectEqual(cur.y, scr.cursor_y);
    try testing.expect(menu_w.y >= 0);
    try testing.expect(cur.y >= @as(u16, @intCast(menu_w.y)));
    try testing.expect(cur.y < @as(u16, @intCast(menu_w.y + @as(i16, @intCast(menu_w.h)))));
    try testing.expect(cur.x >= menu_w.x);
    try testing.expect(cur.x < menu_w.x + menu_w.w);
    // First item starts at origin; selected "bb" is inverse elsewhere on the row.
    try testing.expectEqual(@as(u21, 'a'), cellAt(&term, menu_w.x, @intCast(menu_w.y)).cp);
    try testing.expect(!cellAt(&term, menu_w.x, @intCast(menu_w.y)).attr.inverse);
    var found_sel = false;
    var mx: u16 = menu_w.x;
    while (mx < menu_w.x + menu_w.w) : (mx += 1) {
        const c = cellAt(&term, mx, @intCast(menu_w.y));
        if (c.cp == 'b' and c.attr.inverse) {
            found_sel = true;
            break;
        }
    }
    try testing.expect(found_sel);

    // Text status on row 0.
    try testing.expectEqual(@as(u21, 'M'), cellAt(&term, 0, 0).cp);
    try testing.expect(cellAt(&term, 0, 0).attr.inverse);

    // Prompt label somewhere in the family stack.
    try testing.expect(prompt.y >= 0);
    try testing.expectEqual(@as(u21, 'F'), cellAt(&term, prompt.x, @intCast(prompt.y)).cp);

    // Bottom message on main text window.
    const bot = main_w.msgBotRow().?;
    try testing.expectEqual(@as(u21, 's'), cellAt(&term, 0, @intCast(bot)).cp);

    // Screen.update wrapper matches paintAll.
    term.clear();
    try scr.update();
    try testing.expectEqual(@as(u21, 'M'), cellAt(&term, 0, 0).cp);
}

test "paintAll requires attached terminal" {
    var scr = try screen.Screen.init(testing.allocator, 20, 8);
    defer scr.deinit();
    _ = try scr.createText(null, null, 8);
    scr.layout();
    try testing.expectError(error.NoTerminal, paintAll(&scr, testing.allocator, .none));
}

test "paintText writes status_line and reports content cursor" {
    var scr = try screen.Screen.init(testing.allocator, 20, 6);
    defer scr.deinit();
    const win = try scr.createText(null, null, 6);
    scr.layout();
    const t = win.asText().?;
    try testing.expect(t.status_on);

    var term = try TermScreen.init(testing.allocator, 20, 6);
    defer term.deinit();
    const cur = paintText(&term, t, "STAT", .none);
    try testing.expectEqual(@as(u21, 'S'), cellAt(&term, 0, 0).cp);
    try testing.expectEqual(@as(u16, t.x), cur.x);
    try testing.expectEqual(@as(u16, @intCast(t.y)), cur.y);
}

test "paintBody writes stub lines, linums, offset, and content cursor" {
    const prev = tw.status_enabled;
    defer tw.status_enabled = prev;
    tw.status_enabled = true;

    var scr = try screen.Screen.init(testing.allocator, 20, 8);
    defer scr.deinit();
    const win = try scr.createText(null, null, 8);
    scr.layout();
    const t = win.asText().?;
    try testing.expect(t.status_on);

    const lines = [_][]const u8{ "alpha", "bravo", "charlie", "delta" };
    t.body_lines = &lines;
    t.top_line = 1; // show bravo..
    t.offset = 1; // skip first column
    t.cursor_line = 2; // charlie
    t.cursor_col = 3;
    t.setLincols(4);
    t.linums = true;

    var term = try TermScreen.init(testing.allocator, 20, 8);
    defer term.deinit();
    const cur = paintText(&term, t, "STAT", .none);

    // Status still on row 0.
    try testing.expectEqual(@as(u21, 'S'), cellAt(&term, 0, 0).cp);

    // Content row 0 (screen y=1): linum for buffer line 2 ("  2 "), then "ravo" (offset 1 into "bravo").
    try testing.expectEqual(@as(u21, '2'), cellAt(&term, 2, 1).cp); // right-aligned in 4-col gutter
    try testing.expectEqual(@as(u21, ' '), cellAt(&term, 3, 1).cp);
    try testing.expectEqual(@as(u21, 'r'), cellAt(&term, 4, 1).cp);
    try testing.expectEqual(@as(u21, 'a'), cellAt(&term, 5, 1).cp);

    // Content row 1: "charlie" with offset → "harlie"
    try testing.expectEqual(@as(u21, '3'), cellAt(&term, 2, 2).cp);
    try testing.expectEqual(@as(u21, 'h'), cellAt(&term, 4, 2).cp);

    // Cursor: x = content_x + (cursor_col - offset) = 4 + (3 - 1) = 6
    //         y = content_y + (cursor_line - top_line) = 1 + (2 - 1) = 2
    try testing.expectEqual(@as(u16, 6), cur.x);
    try testing.expectEqual(@as(u16, 2), cur.y);

    // Past-EOF row (top=1, 4 lines → rows covering lines 1,2,3 then past): line 4 is past.
    // h content = 7 (status on). Row for line_idx 4 is row 3 → y=4.
    try testing.expect(cellAt(&term, 4, 4).cp == ' ' or cellAt(&term, 4, 4).cp == 0);
    try testing.expect(cellAt(&term, 0, 4).cp == ' ' or cellAt(&term, 0, 4).cp == 0);
}

test "paintBody clears content when no stub lines" {
    var scr = try screen.Screen.init(testing.allocator, 12, 4);
    defer scr.deinit();
    const win = try scr.createText(null, null, 4);
    scr.layout();
    const t = win.asText().?;

    var term = try TermScreen.init(testing.allocator, 12, 4);
    defer term.deinit();
    // Dirty a content cell, then paintBody should blank it.
    term.writeChar(t.x, @intCast(t.y), 'Z', .none);
    paintBody(&term, t, .none);
    try testing.expect(cellAt(&term, t.x, @intCast(t.y)).isBlankNone());
}

test "paintHelpLine expands springs and toggles underline" {
    var term = try TermScreen.init(testing.allocator, 20, 3);
    defer term.deinit();
    // min width of "A" + "B" = 2, nspans=3 → leftover 18 / 3 = 6 each.
    paintHelpLine(&term, 0, "\\|\\uA\\u\\|B\\|", .none);
    try testing.expectEqual(@as(u21, 'A'), cellAt(&term, 6, 0).cp);
    try testing.expect(cellAt(&term, 6, 0).attr.underline);
    try testing.expectEqual(@as(u21, 'B'), cellAt(&term, 13, 0).cp);
    try testing.expect(!cellAt(&term, 13, 0).attr.underline);
    // Spring spaces around A.
    try testing.expectEqual(@as(u21, ' '), cellAt(&term, 0, 0).cp);
    try testing.expectEqual(@as(u21, ' '), cellAt(&term, 5, 0).cp);
    try testing.expectEqual(@as(u21, ' '), cellAt(&term, 7, 0).cp);
}

test "paintAll paints help chrome above windows" {
    var scr = try screen.Screen.init(testing.allocator, 20, 8);
    defer scr.deinit();
    var term = try TermScreen.init(testing.allocator, 20, 8);
    defer term.deinit();
    try scr.attachTerm(&term);

    const help =
        \\\uHELP\u title
        \\\brow2\b
    ;
    const main_w = try scr.createText(null, null, 8);
    scr.helpOn(help);
    try testing.expectEqual(@as(u16, 2), scr.wind);
    try testing.expectEqual(@as(i16, 2), main_w.y);

    const tw_obj = main_w.asText().?;
    tw_obj.status_line = "STAT";

    _ = try paintAll(&scr, testing.allocator, .none);
    try testing.expectEqual(@as(u21, 'H'), cellAt(&term, 0, 0).cp);
    try testing.expect(cellAt(&term, 0, 0).attr.underline);
    try testing.expectEqual(@as(u21, 'r'), cellAt(&term, 0, 1).cp);
    try testing.expect(cellAt(&term, 0, 1).attr.bold);
    // Text status begins at wind row.
    try testing.expectEqual(@as(u21, 'S'), cellAt(&term, 0, 2).cp);

    scr.helpOff();
    term.clear();
    _ = try paintAll(&scr, testing.allocator, .none);
    try testing.expectEqual(@as(u16, 0), scr.wind);
    try testing.expectEqual(@as(i16, 0), main_w.y);
    try testing.expectEqual(@as(u21, 'S'), cellAt(&term, 0, 0).cp);
}

test "resize syncs attached terminal dimensions" {
    var scr = try screen.Screen.init(testing.allocator, 20, 8);
    defer scr.deinit();
    var term = try TermScreen.init(testing.allocator, 20, 8);
    defer term.deinit();
    try scr.attachTerm(&term);
    scr.resize(30, 10);
    try testing.expectEqual(@as(u16, 30), term.width);
    try testing.expectEqual(@as(u16, 10), term.height);
}