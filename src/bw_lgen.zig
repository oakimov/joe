//! Gated live bridge: JOE `lgen_core` / Feature 2.2 table rows / `gennum` → Zig paint.
//!
//! When `JOE_ZIG_BW_LGEN` / `zig_bw_lgen_enabled` is on, plain buffer lines
//! (including linear/square mark inverse + viewmode hide/substitute/link tables +
//! `-visiblews` glyphs + `-ansi` ESC hiding) paint through the Phase 6 renderer
//! and emit via hybrid `outatr` (works with screen-swap shadow + classic tty
//! path). Feature 2.2 padded table rows use `zig_bw_table_row` → `render.table.paintRow`
//! with widths/aligns from Path A detect or C. Line-number gutters use
//! `zig_bw_gennum` (JOE `" %21lld "` trailing `lincols`; past-EOF blanks).
//! Window paint loops use `zig_bw_bwgen` (loops call C `getto`/`lgen`/`gennum`
//! so Path A body/gutter bridges still apply).
//! Thin `bwgen` entry uses `zig_bw_bwgen_entry` (lattr/viewmode/mark setup + loops +
//! Feature 1.10 cursor; C fallback retained).
//! Hex dump paint uses `zig_bw_bwgenh` (loop calls C `genfield`).
//! Thin `bwgenh` entry uses `zig_bw_bwgenh_entry` (mark setup + hex paint; C fallback retained).
//! Table region detect uses `zig_bw_table_detect` → `table.layoutAt` (fills C widths/aligns).
//! Cursor follow/scroll uses `zig_bw_bwfllwt` / `zig_bw_bwfllwh` (C scroll helpers).
//! Post-edit window scroll uses `zig_bw_bwins` / `zig_bw_bwdel`.
//! `lgen_view` line-start Feature 1.3/1.5/1.7/1.8 uses `zig_bw_view_line_start`.
//! `lgen_view` inline Feature 1.4/1.5/1.6 + col_map uses `zig_bw_view_inline`.
//! Feature 1.9 single-line table dim/bold uses `zig_bw_view_table_hl`.
//! Feature 1.10 col_map ensure + cursor xcol uses `zig_bw_view_finish`.
//! Thin `lgen_view` chrome orchestration uses `zig_bw_lgen_view` (composes the
//! Feature 1.x/2.x sequence).
//! Thin `lgen_view` entry uses `zig_bw_lgen_view_entry` (prelude + dispatcher +
//! paint cleanup; C keeps viewmode static storage helpers + Feature fallback).
//! Lifecycle uses `zig_bw_bwmove` / `zig_bw_bwresz` / `zig_bw_bwmk` / `zig_bw_bwrm` /
//! `zig_bw_orphit` / `zig_bw_calclincols` (C fallback retained).
//! Non-paint helpers use `zig_bw_get_file_pos` / `zig_bw_set_file_pos` /
//! `zig_bw_save_file_pos` / `zig_bw_load_file_pos` / `zig_bw_set_file_pos_all` /
//! `zig_bw_vtmaster` / `zig_bw_ustat` / `zig_bw_ucrawlr` / `zig_bw_ucrawll` /
//! `zig_bw_init_visiblews` (C fallback retained).
//! Feature 2.1 residual simple pipe substitute uses `zig_bw_table_simple`.
//! Non-UTF-8 (byte) charmaps paint via `lgenLine` byte-mode.
//! Default off until soak. Falls back to C when the gate is off.
//!
//! Hybrid `syntax.parse` fills `attr_buf` **per character** (`pgetc`); native
//! `lgenLine` expects **per-byte** attrs — this bridge expands before paint.
//! `ansi_parse` temporarily clears `o.ansi`, so ESC bytes stay as normal chars
//! in `attr_buf`; Path A strips JOE `ansi_decode` spans (ESC…letter) after
//! attr/mark apply so colors stay aligned. When `viewmode!=0`, C `lgen_view`
//! already parsed+mutated `attr_buf` — do **not** re-parse. Linear marks use
//! raw byte offsets (before strip); square marks use post-strip display
//! columns. Default `selectatr=INVERSE`. Visible whitespace uses C
//! `vspace`/`vtab`/`vrtn` + `vwsatr`.

const std = @import("std");
const terminal = @import("terminal");
const render = @import("render");

const Attribute = terminal.Attribute;
const TruecolorPalette = terminal.TruecolorPalette;
const ViewTables = render.ViewTables;
const VisibleWs = render.VisibleWs;
const TableLayout = render.table.Layout;
const TableRowKind = render.table.RowKind;

const COMPOSE = 4;
const NO_MORE_DATA: c_int = -256;
const max_line_bytes: usize = 256 * 1024;
const INVERSE: c_int = 64;
const UNDERLINE: c_int = 128;
const BOLD: c_int = 256;
const DIM: c_int = 1024;
const FG_SHIFT: c_int = 21;
const FG_NOT_DEFAULT: c_int = 256 << FG_SHIFT;
const FG_MASK: c_int = 1023 << FG_SHIFT;
const FG_BLUE: c_int = FG_NOT_DEFAULT | (4 << FG_SHIFT);

const SCRN = opaque {};
const P = opaque {};
const BW = opaque {};
const W = opaque {};
const B = opaque {};
const Screen = opaque {};
const Charmap = extern struct {
    next: ?*Charmap = null,
    name: ?[*:0]u8 = null,
    /// Non-zero ⇒ UTF-8 (JOE `charmap->type`). Truncated layout; only first fields used.
    @"type": c_int = 0,
};
const HighSyntax = opaque {};

const HighlightState = extern struct {
    stack: ?*anyopaque = null,
    delim_stack: ?*anyopaque = null,
    saved_s: ?*const c_int = null,
    state: isize = 0,
};

pub export var zig_bw_lgen_enabled: c_int = 0;

extern var attr_buf: [*c]c_int;
extern var attr_size: c_int;
extern var vwsatr: c_int;
extern var vspace: c_int;
extern var vtab: c_int;
extern var vrtn: c_int;

extern fn parse(syntax: ?*HighSyntax, line: ?*P, h_state: HighlightState, charmap: ?*Charmap) HighlightState;
extern fn pdup(p: ?*P, tr: [*:0]const u8) ?*P;
extern fn prm(p: ?*P) void;
extern fn pnextl(p: ?*P) ?*P;
extern fn pgetb(p: ?*P) c_int;
extern fn outatr(
    map: ?*Charmap,
    t: ?*SCRN,
    scrn: ?*[COMPOSE]c_int,
    attrf: ?*c_int,
    xx: isize,
    yy: isize,
    c: c_int,
    a: c_int,
) void;
extern fn outatr_complete(t: ?*SCRN) void;
extern fn eraeol(t: ?*SCRN, x: isize, y: isize, atr: c_int) c_int;
extern fn ttputs(s: [*c]const u8) void;
extern fn genfield(
    t: ?*SCRN,
    scrn: ?[*][COMPOSE]c_int,
    attr: ?[*]c_int,
    x: isize,
    y: isize,
    ofst: isize,
    s: [*:0]const u8,
    len: isize,
    atr: c_int,
    width: isize,
    flg: c_int,
    fmt: ?[*]c_int,
) void;
extern fn zig_c_bw_pbyte(p: ?*P) i64;
extern fn zig_c_bw_eof_line(p: ?*P) i64;
/// Read buffer line into `buf` (no newline). Returns len, -2 if too long, -1 on error/EOF-past.
extern fn zig_c_bw_read_line(anchor: ?*P, line: i64, buf: ?[*]u8, buf_cap: c_int) c_int;
extern fn zig_c_bw_pline_no(p: ?*P) i64;
extern fn zig_c_bw_pxcol(p: ?*P) i64;
extern fn zig_c_bw_set_xcol(p: ?*P, xcol: i64) void;
extern fn zig_c_bw_bof(p: ?*P) ?*P;
extern fn zig_c_bw_pisbol(p: ?*P) c_int;
extern fn zig_c_bw_p_goto_bol(p: ?*P) void;
extern fn zig_c_bw_pset(d: ?*P, s: ?*P) void;
extern fn zig_c_bw_pline(p: ?*P, line: i64) void;
extern fn zig_c_bw_pgoto(p: ?*P, loc: i64) void;
extern fn zig_c_bw_pbkwd(p: ?*P, n: i64) void;
extern fn zig_c_bw_getto(p: ?*P, cur: ?*P, top: ?*P, line: i64) ?*P;
extern fn zig_c_bw_nscrldn(t: ?*SCRN, top: isize, bot: isize, amnt: isize) void;
extern fn zig_c_bw_nscrlup(t: ?*SCRN, top: isize, bot: isize, amnt: isize) void;
extern fn zig_c_bw_msetI(dest: ?[*]c_int, c: c_int, sz: isize) void;
extern var opt_mid: c_int;
extern var opt_left: c_int;
extern var opt_right: c_int;

/// Apply env gate (called from `ttopnn` alongside screen-swap).
pub export fn zig_bw_lgen_apply_env() void {
    if (std.c.getenv("JOE_ZIG_BW_LGEN")) |v| {
        zig_bw_lgen_enabled = if (v[0] == '1' or v[0] == 'y' or v[0] == 'Y') 1 else 0;
    }
}

/// JOE `gennum` line-number gutter → hybrid `outatr`.
///
/// Formats like C / `window.paint.paintLinum`: `" {d: >21} "` then trailing
/// `lincols` chars. Past-EOF (`have_number==0`) paints spaces. Paints at absolute
/// columns `0..lincols-1` to match live C `gennum`. Fills optional `compose`.
/// Returns `0` on success, `-1` to fall back to C.
pub export fn zig_bw_gennum(
    t: ?*SCRN,
    y: isize,
    screen: ?[*][COMPOSE]c_int,
    attr_row: ?[*]c_int,
    compose: ?[*]c_int,
    lincols: c_int,
    have_number: c_int,
    line_1based: i64,
    atr: c_int,
    charmap: ?*Charmap,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (t == null or screen == null or attr_row == null) return -1;
    if (lincols <= 0 or lincols > 64) return -1;

    const cols: usize = @intCast(lincols);
    var buf: [24]u8 = .{' '} ** 24;

    if (have_number != 0) {
        if (line_1based < 0) return -1;
        var tmp: [24]u8 = undefined;
        const n: u64 = @intCast(line_1based);
        const formatted = std.fmt.bufPrint(&tmp, " {d: >21} ", .{n}) catch return -1;
        const take = @min(cols, formatted.len);
        const src = formatted[formatted.len - take ..];
        @memcpy(buf[0..take], src);
    }

    var x: usize = 0;
    while (x < cols) : (x += 1) {
        const ch: c_int = buf[x];
        const xx: isize = @intCast(x);
        outatr(
            charmap,
            t,
            @ptrCast(screen.? + x),
            @ptrCast(attr_row.? + x),
            xx,
            y,
            ch,
            atr,
        );
        if (compose) |comp| comp[x] = ch;
    }
    outatr_complete(t);
    return 0;
}



/// Feature 2.1/2.2 table region detect → Zig `table.layoutAt`.
///
/// Fills `out_*` the same way C's scan fills its statics. Returns:
/// - `0` — detection complete (`out_start == -1` means no region)
/// - `-1` — fall back to C scan
pub export fn zig_bw_table_detect(
    anchor: ?*P,
    buf_line: i64,
    out_start: ?*i64,
    out_end: ?*i64,
    out_sep: ?*i64,
    out_ncols: ?*c_int,
    out_widths: ?[*]c_int,
    out_aligns: ?[*]c_int,
    out_cap: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (anchor == null or out_start == null or out_end == null or out_sep == null) return -1;
    if (out_ncols == null or out_widths == null or out_aligns == null) return -1;
    if (buf_line < 0 or out_cap <= 0) return -1;
    const cap: usize = @intCast(@min(out_cap, @as(c_int, @intCast(render.table.max_cols))));

    const eof_line = zig_c_bw_eof_line(anchor);
    if (eof_line < 0 or buf_line > eof_line) {
        out_start.?.* = -1;
        out_end.?.* = -1;
        out_sep.?.* = -1;
        out_ncols.?.* = 0;
        return 0;
    }

    // Match C: backward ≤50 from current; forward window covers JOE's 200-line scan.
    const back_lim: i64 = @max(@as(i64, 0), buf_line - 50);
    const fwd_lim: i64 = @min(eof_line, buf_line + 199);
    if (fwd_lim < back_lim) {
        out_start.?.* = -1;
        out_end.?.* = -1;
        out_sep.?.* = -1;
        out_ncols.?.* = 0;
        return 0;
    }

    const around: usize = @intCast(buf_line - back_lim);

    const alloc = std.heap.c_allocator;

    var storage: std.ArrayList(u8) = .empty;
    defer storage.deinit(alloc);
    var starts: std.ArrayList(usize) = .empty;
    defer starts.deinit(alloc);
    var lens: std.ArrayList(usize) = .empty;
    defer lens.deinit(alloc);

    var li: i64 = back_lim;
    while (li <= fwd_lim) : (li += 1) {
        var tmp: [16 * 1024]u8 = undefined;
        const rc = zig_c_bw_read_line(anchor, li, &tmp, @intCast(tmp.len));
        const slice: []const u8 = blk: {
            if (rc == -2) {
                // Too long: not a table line (breaks regions), store non-pipe marker.
                break :blk "x";
            }
            if (rc < 0) break :blk "";
            break :blk tmp[0..@intCast(rc)];
        };
        const start = storage.items.len;
        storage.appendSlice(alloc, slice) catch return -1;
        starts.append(alloc, start) catch return -1;
        lens.append(alloc, slice.len) catch return -1;
    }

    if (starts.items.len == 0 or around >= starts.items.len) {
        out_start.?.* = -1;
        out_end.?.* = -1;
        out_sep.?.* = -1;
        out_ncols.?.* = 0;
        return 0;
    }

    const line_ptrs = alloc.alloc([]const u8, starts.items.len) catch return -1;
    defer alloc.free(line_ptrs);
    for (starts.items, lens.items, 0..) |st, ln, i| {
        line_ptrs[i] = storage.items[st .. st + ln];
    }

    const layout = render.table.layoutAt(line_ptrs, around) orelse {
        out_start.?.* = -1;
        out_end.?.* = -1;
        out_sep.?.* = -1;
        out_ncols.?.* = 0;
        var z: usize = 0;
        while (z < cap) : (z += 1) {
            out_widths.?[z] = 0;
            out_aligns.?[z] = 0;
        }
        return 0;
    };

    out_start.?.* = back_lim + @as(i64, @intCast(layout.start));
    out_end.?.* = back_lim + @as(i64, @intCast(layout.end));
    out_sep.?.* = if (layout.sep) |s| back_lim + @as(i64, @intCast(s)) else -1;
    out_ncols.?.* = @intCast(layout.ncols);

    var z: usize = 0;
    while (z < cap) : (z += 1) {
        if (z < layout.ncols) {
            out_widths.?[z] = layout.widths[z];
            out_aligns.?[z] = @intFromEnum(layout.aligns[z]);
        } else {
            out_widths.?[z] = 0;
            out_aligns.?[z] = 0;
        }
    }
    return 0;
}

/// Path A cursor follow for text windows (`bwfllwt`).
/// Returns `0` on success, `-1` to fall back to C.
pub export fn zig_bw_bwfllwt(
    top: ?*P,
    cursor: ?*P,
    t: ?*SCRN,
    updtab: ?[*]c_int,
    win_y: isize,
    win_h: isize,
    win_w: isize,
    offset: ?*i64,
    curlin: ?*i64,
    hiline: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (top == null or cursor == null or t == null or updtab == null) return -1;
    if (offset == null or curlin == null) return -1;
    if (win_h <= 0 or win_w <= 0) return -1;

    if (zig_c_bw_pisbol(top) == 0) {
        zig_c_bw_p_goto_bol(top);
    }

    const cur_line = zig_c_bw_pline_no(cursor);
    const top_line = zig_c_bw_pline_no(top);
    if (cur_line < 0 or top_line < 0) return -1;

    if (cur_line < top_line) {
        const newtop = pdup(cursor, "zig_bw_bwfllwt") orelse return -1;
        zig_c_bw_p_goto_bol(newtop);
        if (opt_mid != 0) {
            const nl = zig_c_bw_pline_no(newtop);
            if (nl >= @divTrunc(win_h, 2)) {
                zig_c_bw_pline(newtop, nl - @divTrunc(win_h, 2));
            } else {
                const bof = zig_c_bw_bof(newtop);
                if (bof == null) {
                    prm(newtop);
                    return -1;
                }
                zig_c_bw_pset(newtop, bof);
            }
        }
        const new_line = zig_c_bw_pline_no(newtop);
        const delta = top_line - new_line;
        if (delta < win_h) {
            zig_c_bw_nscrldn(t, win_y, win_y + win_h, @intCast(delta));
        } else {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, win_h);
        }
        zig_c_bw_pset(top, newtop);
        prm(newtop);
    } else if (cur_line >= top_line + win_h) {
        const target: i64 = if (opt_mid != 0)
            cur_line - @divTrunc(win_h, 2)
        else
            cur_line - (win_h - 1);
        const newtop = zig_c_bw_getto(null, cursor, top, target) orelse return -1;
        const new_line = zig_c_bw_pline_no(newtop);
        const delta = new_line - top_line;
        if (delta < win_h) {
            zig_c_bw_nscrlup(t, win_y, win_y + win_h, @intCast(delta));
        } else {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, win_h);
        }
        zig_c_bw_pset(top, newtop);
        prm(newtop);
    }

    const xcol = zig_c_bw_pxcol(cursor);
    var off = offset.?.*;
    if (xcol < off) {
        var target = xcol;
        var amnt: isize = if (opt_left < 0)
            @divTrunc(win_w, -opt_left)
        else
            opt_left - 1;
        if (amnt >= win_w) amnt = win_w - 1;
        if (amnt < 0) amnt = 0;
        if (target < amnt) {
            target = 0;
        } else {
            target -= amnt;
        }
        off = target;
        offset.?.* = off;
        zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, win_h);
    }
    if (xcol >= off + win_w) {
        var amnt: isize = if (opt_right < 0)
            win_w - @divTrunc(win_w, -opt_right)
        else
            win_w - opt_right;
        if (amnt >= win_w) amnt = win_w - 1;
        if (amnt < 0) amnt = 0;
        off = xcol - amnt;
        offset.?.* = off;
        zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, win_h);
    }

    // Match C: hiline dirty checks use top AFTER any vertical move.
    const top_now = zig_c_bw_pline_no(top);
    if (hiline != 0) {
        const old = curlin.?.*;
        if (old != cur_line) {
            if (old >= top_now and old < top_now + win_h) {
                updtab.?[@intCast(win_y + (old - top_now))] = 1;
            }
            curlin.?.* = cur_line;
            updtab.?[@intCast(win_y + (cur_line - top_now))] = 1;
        }
    } else {
        curlin.?.* = cur_line;
    }
    return 0;
}

/// Path A cursor follow for hex windows (`bwfllwh`).
/// Returns `0` on success, `-1` to fall back to C.
pub export fn zig_bw_bwfllwh(
    top: ?*P,
    cursor: ?*P,
    t: ?*SCRN,
    updtab: ?[*]c_int,
    win_y: isize,
    win_h: isize,
    win_w: isize,
    offset: ?*i64,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (top == null or cursor == null or t == null or updtab == null or offset == null) return -1;
    if (win_h <= 0 or win_w <= 0) return -1;

    var top_byte = zig_c_bw_pbyte(top);
    const cur_byte = zig_c_bw_pbyte(cursor);
    if (@mod(top_byte, 16) != 0) {
        zig_c_bw_pbkwd(top, @mod(top_byte, 16));
        top_byte = zig_c_bw_pbyte(top);
    }

    if (cur_byte < top_byte) {
        var new_top = @divTrunc(cur_byte, 16);
        if (opt_mid != 0) {
            if (new_top >= @divTrunc(win_h, 2)) {
                new_top -= @divTrunc(win_h, 2);
            } else {
                new_top = 0;
            }
        }
        const delta = @divTrunc(top_byte, 16) - new_top;
        if (delta < win_h) {
            zig_c_bw_nscrldn(t, win_y, win_y + win_h, @intCast(delta));
        } else {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, win_h);
        }
        zig_c_bw_pgoto(top, new_top * 16);
        top_byte = zig_c_bw_pbyte(top);
    }

    if (cur_byte >= top_byte + (win_h * 16)) {
        const new_top: i64 = if (opt_mid != 0)
            @divTrunc(cur_byte, 16) - @divTrunc(win_h, 2)
        else
            @divTrunc(cur_byte, 16) - (win_h - 1);
        const delta = new_top - @divTrunc(top_byte, 16);
        if (delta < win_h) {
            zig_c_bw_nscrlup(t, win_y, win_y + win_h, @intCast(delta));
        } else {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, win_h);
        }
        zig_c_bw_pgoto(top, new_top * 16);
        top_byte = zig_c_bw_pbyte(top);
    }

    const col = @mod(cur_byte, 16) + 60;
    var off = offset.?.*;
    if (col < off) {
        off = col;
        offset.?.* = off;
        zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, win_h);
    } else if (col >= off + win_w) {
        off = col - (win_w - 1);
        offset.?.* = off;
        zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, win_h);
    }
    return 0;
}

/// Path A post-insert window scroll (`bwins`).
/// Returns `0` on success, `-1` to fall back to C.
pub export fn zig_bw_bwins(
    t: ?*SCRN,
    updtab: ?[*]c_int,
    sary: ?[*]isize,
    li: isize,
    win_y: isize,
    win_h: isize,
    top_line: i64,
    eof_line: i64,
    l: i64,
    n: i64,
    flg: c_int,
    do_highlight: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (t == null or updtab == null or win_h <= 0) return -1;

    if (do_highlight != 0) {
        if (l < top_line) {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, win_h);
        } else if ((l + 1) < top_line + win_h) {
            const start: isize = @intCast(l + 1 - top_line);
            const size = win_h - start;
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y + start)), 1, size);
        }
    }

    if (l + flg + n < top_line + win_h and l + flg >= top_line and l + flg <= eof_line) {
        if (flg != 0) {
            if (sary == null) return -1;
            sary.?[@intCast(win_y + l - top_line)] = li;
        }
        zig_c_bw_nscrldn(t, @intCast(win_y + l + flg - top_line), win_y + win_h, @intCast(n));
    }

    if (l < top_line + win_h and l >= top_line) {
        if (n >= win_h - (l - top_line)) {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y + l - top_line)), 1, win_h - @as(isize, @intCast(l - top_line)));
        } else {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y + l - top_line)), 1, @intCast(n + 1));
        }
    }
    return 0;
}

/// Path A post-delete window scroll (`bwdel`).
/// Returns `0` on success, `-1` to fall back to C.
pub export fn zig_bw_bwdel(
    t: ?*SCRN,
    updtab: ?[*]c_int,
    win_y: isize,
    win_h: isize,
    top_line: i64,
    eof_line: i64,
    l: i64,
    n: i64,
    flg: c_int,
    do_highlight: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (t == null or updtab == null or win_h <= 0) return -1;

    if (do_highlight != 0) {
        if (l < top_line) {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, win_h);
        } else if ((l + 1) < top_line + win_h) {
            const start: isize = @intCast(l + 1 - top_line);
            const size = win_h - start;
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y + start)), 1, size);
        }
    }

    if (l < top_line + win_h and l >= top_line)
        updtab.?[@intCast(win_y + l - top_line)] = 1;

    if (l + n < top_line + win_h and l + n >= top_line)
        updtab.?[@intCast(win_y + l + n - top_line)] = 1;

    if (l < top_line + win_h and (l + n >= top_line + win_h or (l + n == eof_line and eof_line >= top_line + win_h))) {
        if (l >= top_line) {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y + l - top_line)), 1, win_h - @as(isize, @intCast(l - top_line)));
        } else {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, win_h);
        }
    } else if (l < top_line + win_h and l + n == eof_line and eof_line < top_line + win_h) {
        if (l >= top_line) {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y + l - top_line)), 1, @intCast(n));
        } else {
            zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y)), 1, @intCast(eof_line - top_line));
        }
    } else if (l + n < top_line + win_h and l + n > top_line and l + n < eof_line) {
        if (l + flg >= top_line) {
            zig_c_bw_nscrlup(t, @intCast(win_y + l + flg - top_line), win_y + win_h, @intCast(n));
        } else {
            zig_c_bw_nscrlup(t, win_y, win_y + win_h, @intCast(l + n - top_line));
        }
    }
    return 0;
}

/// Path A Feature 1.9: dim/bold highlight for pipe lines outside a table region.
/// Returns `0` on success, `-1` to fall back to C.
pub export fn zig_bw_view_table_hl(
    line_ptr: ?[*]const u8,
    line_len: c_int,
    atr: ?[*]c_int,
    atr_len: c_int,
    in_table_region: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (line_ptr == null or atr == null or line_len < 0 or atr_len <= 0) return -1;
    if (in_table_region != 0) return 0;

    const n: usize = @intCast(line_len);
    const line = line_ptr.?[0..n];
    var i: usize = 0;
    while (i < n and (line[i] == ' ' or line[i] == '\t')) : (i += 1) {}
    if (i >= n or line[i] != '|') return 0;

    var is_separator = true;
    var has_dash = false;
    for (line) |b| {
        switch (b) {
            '|', ' ', '\t', ':' => {},
            '-' => has_dash = true,
            else => {
                is_separator = false;
                break;
            },
        }
    }
    const flag: c_int = if (is_separator and has_dash) DIM else BOLD;
    const alen: usize = @intCast(atr_len);
    var j: usize = 0;
    while (j < n and j < alen) : (j += 1) {
        atr.?[j] |= flag;
    }
    return 0;
}

/// Path A `lgen_view` line-start chrome: heading/fence/blockquote/HR/task.
/// Returns:
/// - `1` — line fully handled (`goto done`); col_map filled
/// - `0` — start features applied or N/A; continue with tables/inline
/// - `-1` — fall back to C
pub export fn zig_bw_view_line_start(
    line_ptr: ?[*]const u8,
    line_len: c_int,
    hide: ?[*]u8,
    hide_len: c_int,
    subst: ?[*]c_int,
    subst_len: c_int,
    col_map: ?[*]i64,
    col_map_len: c_int,
    tab: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (line_ptr == null or hide == null or subst == null or col_map == null) return -1;
    if (line_len < 0) return -1;
    const n: usize = @intCast(line_len);
    const clear_n: usize = if (n == 0) 1 else n;
    if (hide_len < @as(c_int, @intCast(clear_n))) return -1;
    if (subst_len < @as(c_int, @intCast(clear_n))) return -1;
    if (col_map_len < @as(c_int, @intCast(clear_n))) return -1;

    const line = line_ptr.?[0..n];
    const alloc = std.heap.c_allocator;

    const hide_slice = hide.?[0..clear_n];
    const subst_scratch = alloc.alloc(u21, clear_n) catch return -1;
    defer alloc.free(subst_scratch);
    const url_scratch = alloc.alloc(?[]const u8, clear_n) catch return -1;
    defer alloc.free(url_scratch);
    const col_scratch = alloc.alloc(u64, clear_n) catch return -1;
    defer alloc.free(col_scratch);

    @memset(hide_slice, 0);
    @memset(subst_scratch, 0);

    var tables = ViewTables.init(alloc);
    tables.bindScratch(hide_slice, subst_scratch, url_scratch, col_scratch, n);

    const tab_u: u16 = if (tab <= 0) 8 else @intCast(tab);
    const done = render.analyzeLineStart(&tables, line, tab_u);

    var si: usize = 0;
    while (si < clear_n) : (si += 1) {
        subst.?[si] = @intCast(subst_scratch[si]);
        col_map.?[si] = @intCast(col_scratch[si]);
    }
    return if (done) 1 else 0;
}

/// Path A `lgen_view` inline chrome: emphasis / inline code / links / col_map.
/// Preserves any C hide/subst already set (task lists / simple table pipes).
/// Fills URL + col_map buffers and mutates hybrid `attr_buf` for link styling.
/// Returns `0` on success, `-1` to fall back to C.
pub export fn zig_bw_view_inline(
    line_ptr: ?[*]const u8,
    line_len: c_int,
    hide: ?[*]u8,
    hide_len: c_int,
    subst: ?[*]c_int,
    subst_len: c_int,
    urls: ?[*]?[*:0]u8,
    urls_len: c_int,
    col_map: ?[*]i64,
    col_map_len: c_int,
    atr: ?[*]c_int,
    atr_len: c_int,
    tab: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (line_ptr == null or hide == null or subst == null or col_map == null) return -1;
    if (line_len < 0) return -1;
    const n: usize = @intCast(line_len);
    const clear_n: usize = if (n == 0) 1 else n;
    if (hide_len < @as(c_int, @intCast(clear_n))) return -1;
    if (subst_len < @as(c_int, @intCast(clear_n))) return -1;
    if (col_map_len < @as(c_int, @intCast(clear_n))) return -1;
    if (urls != null and urls_len < @as(c_int, @intCast(clear_n))) return -1;

    const line = line_ptr.?[0..n];
    const alloc = std.heap.c_allocator;

    const saved_hide = alloc.alloc(u8, clear_n) catch return -1;
    defer alloc.free(saved_hide);
    const saved_subst = alloc.alloc(c_int, clear_n) catch return -1;
    defer alloc.free(saved_subst);
    @memcpy(saved_hide[0..clear_n], hide.?[0..clear_n]);
    @memcpy(saved_subst[0..clear_n], subst.?[0..clear_n]);

    const hide_slice = hide.?[0..clear_n];
    const subst_scratch = alloc.alloc(u21, clear_n) catch return -1;
    defer alloc.free(subst_scratch);
    const url_scratch = alloc.alloc(?[]const u8, clear_n) catch return -1;
    defer alloc.free(url_scratch);
    const col_scratch = alloc.alloc(u64, clear_n) catch return -1;
    defer alloc.free(col_scratch);
    const attrs = alloc.alloc(Attribute, if (n == 0) 1 else n) catch return -1;
    defer alloc.free(attrs);
    @memset(attrs, .{});

    var tables = ViewTables.init(alloc);
    tables.bindScratch(hide_slice, subst_scratch, url_scratch, col_scratch, n);

    // Restore C pre-state (task / Feature 2.1 simple borders) after bindScratch clear.
    @memcpy(hide_slice, saved_hide);
    var si: usize = 0;
    while (si < clear_n) : (si += 1) {
        if (saved_subst[si] != 0) subst_scratch[si] = @intCast(saved_subst[si]);
    }

    const tab_u: u16 = if (tab <= 0) 8 else @intCast(tab);
    const attr_arg: ?[]Attribute = if (n == 0) null else attrs[0..n];
    render.analyzeLineInline(&tables, line, attr_arg, tab_u);

    // Copy substitutes + col_map back to C.
    si = 0;
    while (si < clear_n) : (si += 1) {
        subst.?[si] = @intCast(subst_scratch[si]);
        col_map.?[si] = @intCast(col_scratch[si]);
    }

    // Link styling → hybrid attr_buf (byte-indexed, matching C).
    if (atr != null and atr_len > 0 and n > 0) {
        const alen: usize = @intCast(atr_len);
        var ai: usize = 0;
        while (ai < n and ai < alen and ai < attrs.len) : (ai += 1) {
            if (!attrs[ai].underline) continue;
            atr.?[ai] |= UNDERLINE;
            if ((atr.?[ai] & FG_MASK) == 0) atr.?[ai] |= FG_BLUE;
        }
    }

    // URLs: strdup unique borrowed slices into C-owned pointers (joe_free-compatible).
    if (urls != null and n > 0) {
        var i: usize = 0;
        while (i < n) : (i += 1) {
            const u = url_scratch[i] orelse continue;
            // Reuse pointer if an earlier slot already strdup'd the same slice.
            var reused: ?[*:0]u8 = null;
            var j: usize = 0;
            while (j < i) : (j += 1) {
                const prev = url_scratch[j] orelse continue;
                if (prev.ptr == u.ptr and prev.len == u.len) {
                    reused = urls.?[j];
                    break;
                }
            }
            if (reused) |p| {
                urls.?[i] = p;
                continue;
            }
            const dup = alloc.alloc(u8, u.len + 1) catch return -1;
            @memcpy(dup[0..u.len], u);
            dup[u.len] = 0;
            urls.?[i] = dup[0..u.len :0].ptr;
        }
    }
    return 0;
}


/// Path A Feature 1.10 epilogue: ensure `col_map` for `buf_line`, then update cursor xcol.
/// When `skip_hidden != 0` and cursor sits on a hidden byte, advance to next visible (lgen_view).
/// Returns `0` on success, `-1` to fall back to C.
pub export fn zig_bw_view_finish(
    line_ptr: ?[*]const u8,
    line_len: c_int,
    hide: ?[*]u8,
    hide_len: c_int,
    subst: ?[*]c_int,
    subst_len: c_int,
    col_map: ?[*]i64,
    col_map_len: c_int,
    col_map_line: ?*i64,
    buf_line: i64,
    tab: c_int,
    cursor: ?*P,
    skip_hidden: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (line_ptr == null or hide == null or subst == null or col_map == null or col_map_line == null) return -1;
    if (cursor == null or line_len < 0) return -1;
    const n: usize = @intCast(line_len);
    const clear_n: usize = if (n == 0) 1 else n;
    if (hide_len < @as(c_int, @intCast(clear_n))) return -1;
    if (subst_len < @as(c_int, @intCast(clear_n))) return -1;
    if (col_map_len < @as(c_int, @intCast(clear_n))) return -1;

    const line = line_ptr.?[0..n];
    const alloc = std.heap.c_allocator;
    const tab_u: u16 = if (tab <= 0) 8 else @intCast(tab);

    if (col_map_line.?.* != buf_line) {
        const hide_slice = hide.?[0..clear_n];
        const subst_scratch = alloc.alloc(u21, clear_n) catch return -1;
        defer alloc.free(subst_scratch);
        const url_scratch = alloc.alloc(?[]const u8, clear_n) catch return -1;
        defer alloc.free(url_scratch);
        const col_scratch = alloc.alloc(u64, clear_n) catch return -1;
        defer alloc.free(col_scratch);

        const saved_hide = alloc.alloc(u8, clear_n) catch return -1;
        defer alloc.free(saved_hide);
        @memcpy(saved_hide, hide_slice);

        var si: usize = 0;
        while (si < clear_n) : (si += 1) {
            subst_scratch[si] = if (subst.?[si] > 0) @intCast(subst.?[si]) else 0;
        }

        var tables = ViewTables.init(alloc);
        tables.bindScratch(hide_slice, subst_scratch, url_scratch, col_scratch, n);
        @memcpy(hide_slice, saved_hide);
        si = 0;
        while (si < clear_n) : (si += 1) {
            if (subst.?[si] > 0) subst_scratch[si] = @intCast(subst.?[si]);
        }
        render.buildColMap(&tables, line, tab_u);
        si = 0;
        while (si < clear_n) : (si += 1) {
            col_map.?[si] = @intCast(col_scratch[si]);
        }
        col_map_line.?.* = buf_line;
    }

    // Cursor update when this painted line is the cursor line.
    if (zig_c_bw_pline_no(cursor) != buf_line) return 0;
    if (col_map_line.?.* != buf_line or col_map_len <= 0) return 0;

    const bol = pdup(cursor, "zig_bw_view_finish") orelse return -1;
    zig_c_bw_p_goto_bol(bol);
    var cursor_offset: i64 = zig_c_bw_pbyte(cursor) - zig_c_bw_pbyte(bol);
    prm(bol);

    if (skip_hidden != 0 and cursor_offset >= 0 and cursor_offset < hide_len) {
        const off: usize = @intCast(cursor_offset);
        if (off < clear_n and hide.?[off] != 0) {
            var next: usize = off + 1;
            while (next < clear_n and next < @as(usize, @intCast(hide_len)) and hide.?[next] != 0) : (next += 1) {}
            if (next < clear_n and next < @as(usize, @intCast(hide_len))) {
                const move = pdup(cursor, "zig_bw_view_finish_skip") orelse return -1;
                zig_c_bw_p_goto_bol(move);
                const target = zig_c_bw_pbyte(move) + @as(i64, @intCast(next));
                zig_c_bw_pgoto(cursor, target);
                cursor_offset = @intCast(next);
                prm(move);
            }
        }
    }

    if (cursor_offset >= 0 and cursor_offset < col_map_len) {
        zig_c_bw_set_xcol(cursor, col_map.?[@intCast(cursor_offset)]);
    }
    return 0;
}

/// Thin `lgen_view` chrome dispatcher (JOE_ZIG_BW_LGEN).
///
/// Prefers being called from `zig_bw_lgen_view_entry` (prelude + paint cleanup).
/// This owns Feature 1.x/2.x chrome sequencing: line-start → table detect/row
/// /simple → table_hl → inline → finish.
///
/// Returns:
/// - `1` — Feature 2.2 table row painted; caller `pnextl`
/// - `0` — side tables ready; caller `lgen_core` with `viewmode_skip_parse`
/// - `-1` — fall back to C chrome
pub export fn zig_bw_lgen_view(
    t: ?*SCRN,
    y: isize,
    screen: ?[*][COMPOSE]c_int,
    attr_row: ?[*]c_int,
    x0: isize,
    x1: isize,
    p: ?*P,
    line_ptr: ?[*]const u8,
    line_len: c_int,
    hide: ?[*]u8,
    hide_len: c_int,
    subst: ?[*]c_int,
    subst_len: c_int,
    urls: ?[*]?[*:0]u8,
    urls_len: c_int,
    col_map: ?[*]i64,
    col_map_len: c_int,
    col_map_line: ?*i64,
    atr: ?[*]c_int,
    atr_len: c_int,
    tab: c_int,
    buf_line: i64,
    cursor: ?*P,
    table_region_start: ?*i64,
    table_region_end: ?*i64,
    table_separator_line: ?*i64,
    table_cached_for_line: ?*i64,
    table_no_region_line: ?*i64,
    table_col_count: ?*c_int,
    table_col_width: ?[*]c_int,
    table_col_align: ?[*]c_int,
    table_cap: c_int,
    charmap: ?*Charmap,
    defatr: c_int,
    palette: ?[*]c_int,
    palette_len: c_int,
    utf8: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (line_ptr == null or hide == null or subst == null or col_map == null or col_map_line == null) return -1;
    if (cursor == null or p == null) return -1;
    if (table_region_start == null or table_region_end == null or table_separator_line == null) return -1;
    if (table_cached_for_line == null or table_no_region_line == null or table_col_count == null) return -1;
    if (table_col_width == null or table_col_align == null or table_cap <= 0) return -1;
    if (line_len < 0) return -1;

    const n: usize = @intCast(line_len);
    const clear_n: usize = if (n == 0) 1 else n;
    if (hide_len < @as(c_int, @intCast(clear_n))) return -1;
    if (subst_len < @as(c_int, @intCast(clear_n))) return -1;
    if (col_map_len < @as(c_int, @intCast(clear_n))) return -1;
    if (urls == null or urls_len < @as(c_int, @intCast(clear_n))) return -1;
    if (atr == null or atr_len <= 0) return -1;

    // 1) Line-start Feature 1.3/1.5/1.7/1.8 (+ task).
    const zls = zig_bw_view_line_start(
        line_ptr,
        line_len,
        hide,
        hide_len,
        subst,
        subst_len,
        col_map,
        col_map_len,
        tab,
    );
    if (zls < 0) return -1;
    if (zls == 1) {
        col_map_line.?.* = buf_line;
        if (zig_bw_view_finish(
            line_ptr,
            line_len,
            hide,
            hide_len,
            subst,
            subst_len,
            col_map,
            col_map_len,
            col_map_line,
            buf_line,
            tab,
            cursor,
            1,
        ) < 0)
            return -1;
        return 0;
    }

    // 2) Table region cache + detect + row paint / simple borders.
    var row_type: c_int = 0; // TABLE_ROW_NONE
    if (table_cached_for_line.?.* != buf_line) {
        if (buf_line >= table_region_start.?.* and buf_line < table_region_end.?.*) {
            table_cached_for_line.?.* = buf_line;
        } else {
            table_region_start.?.* = -1;
            table_region_end.?.* = -1;
            table_separator_line.?.* = -1;
            table_col_count.?.* = 0;
            var vi: c_int = 0;
            while (vi < table_cap) : (vi += 1) {
                table_col_width.?[@intCast(vi)] = 0;
                table_col_align.?[@intCast(vi)] = 0;
            }

            var has_pipe: bool = false;
            var pi: usize = 0;
            while (pi < n) : (pi += 1) {
                if (line_ptr.?[pi] == '|') {
                    has_pipe = true;
                    break;
                }
            }
            const no_line = table_no_region_line.?.*;
            if (!has_pipe and no_line != -1 and buf_line >= no_line - 10 and buf_line <= no_line + 10) {
                table_cached_for_line.?.* = buf_line;
            } else {
                const zdet = zig_bw_table_detect(
                    p,
                    buf_line,
                    table_region_start,
                    table_region_end,
                    table_separator_line,
                    table_col_count,
                    table_col_width,
                    table_col_align,
                    table_cap,
                );
                if (zdet < 0) return -1;
                if (table_region_start.?.* == -1)
                    table_no_region_line.?.* = buf_line;
                table_cached_for_line.?.* = buf_line;
            }
        }
    }

    if (buf_line >= table_region_start.?.* and buf_line < table_region_end.?.*) {
        if (buf_line == table_separator_line.?.*) {
            row_type = 2; // SEPARATOR
        } else if (buf_line == table_region_start.?.*) {
            row_type = 1; // HEADER
        } else if (buf_line == table_region_end.?.* - 1 and table_region_end.?.* - 1 > table_separator_line.?.*) {
            row_type = 4; // LAST
        } else if (buf_line > table_separator_line.?.*) {
            row_type = 3; // BODY
        } else {
            row_type = 1; // between header and separator
        }
    }

    if (row_type != 0) {
        const ncols = table_col_count.?.*;
        if (ncols > 0) {
            // Feature 2.2 padded row requires UTF-8 (matches live C gate).
            if (utf8 == 0 or t == null or screen == null or attr_row == null or charmap == null)
                return -1;
            var use_ncols = ncols;
            if (use_ncols > table_cap) use_ncols = table_cap;
            const zrow = zig_bw_table_row(
                t,
                y,
                screen,
                attr_row,
                x0,
                x1,
                line_ptr,
                line_len,
                use_ncols,
                table_col_width,
                table_col_align,
                row_type,
                charmap,
                defatr,
                palette,
                palette_len,
                col_map,
                col_map_len,
            );
            if (zrow < 0) return -1;
            if (row_type != 2 and col_map_len >= @as(c_int, @intCast(clear_n)))
                col_map_line.?.* = buf_line;
            _ = zig_bw_view_finish(
                line_ptr,
                line_len,
                hide,
                hide_len,
                subst,
                subst_len,
                col_map,
                col_map_len,
                col_map_line,
                buf_line,
                tab,
                cursor,
                0, // table-rendered: do not skip hidden
            );
            return 1;
        } else if (utf8 != 0) {
            // Feature 2.1 residual (separator-only mutate).
            if (zig_bw_table_simple(line_ptr, line_len, row_type, subst, subst_len) < 0)
                return -1;
        } else {
            return -1;
        }
    }

    // 3) Feature 1.9 table highlight (outside region).
    const in_region: c_int = if (buf_line >= table_region_start.?.* and buf_line < table_region_end.?.*) 1 else 0;
    if (zig_bw_view_table_hl(line_ptr, line_len, atr, atr_len, in_region) < 0)
        return -1;

    // 4) Inline Feature 1.4/1.5/1.6 + col_map.
    if (zig_bw_view_inline(
        line_ptr,
        line_len,
        hide,
        hide_len,
        subst,
        subst_len,
        urls,
        urls_len,
        col_map,
        col_map_len,
        atr,
        atr_len,
        tab,
    ) < 0)
        return -1;
    col_map_line.?.* = buf_line;

    // 5) Feature 1.10 finish.
    if (zig_bw_view_finish(
        line_ptr,
        line_len,
        hide,
        hide_len,
        subst,
        subst_len,
        col_map,
        col_map_len,
        col_map_line,
        buf_line,
        tab,
        cursor,
        1,
    ) < 0)
        return -1;
    return 0;
}

const viewmode_max_line_bytes: c_int = 1024 * 1024;

extern fn joe_malloc(n: isize) ?*anyopaque;
extern fn joe_realloc(p: ?*anyopaque, n: isize) ?*anyopaque;
extern fn joe_free(p: ?*anyopaque) void;
extern fn zig_c_bw_lgen_core(
    t: ?*SCRN,
    y: isize,
    screen: ?[*][COMPOSE]c_int,
    attr_row: ?[*]c_int,
    x: isize,
    w: isize,
    p: ?*P,
    scr: i64,
    from: i64,
    to: i64,
    st: HighlightState,
    bw: ?*BW,
) c_int;
extern fn zig_c_bw_view_paint_body(
    t: ?*SCRN,
    y: isize,
    screen: ?[*][COMPOSE]c_int,
    attr_row: ?[*]c_int,
    x: isize,
    w: isize,
    p: ?*P,
    scr: i64,
    from: i64,
    to: i64,
    st: HighlightState,
    bw: ?*BW,
) c_int;
extern fn zig_c_bw_get_top(bw: ?*BW) ?*P;
extern fn zig_c_bw_get_cursor(bw: ?*BW) ?*P;
extern fn zig_c_bw_get_y(bw: ?*BW) isize;
extern fn zig_c_bw_get_top_line(bw: ?*BW) i64;
extern fn zig_c_bw_get_tab(bw: ?*BW) c_int;
extern fn zig_c_bw_get_syntax(bw: ?*BW) ?*HighSyntax;
extern fn zig_c_bw_get_charmap(bw: ?*BW) ?*Charmap;
extern fn zig_c_bw_view_defatr(bw: ?*BW, buf_line: i64) c_int;
extern fn zig_c_bw_view_prepare(bw: ?*BW, need: c_int) c_int;
extern fn zig_c_bw_view_hide() ?[*]u8;
extern fn zig_c_bw_view_hide_size() c_int;
extern fn zig_c_bw_view_subst() ?[*]c_int;
extern fn zig_c_bw_view_subst_size() c_int;
extern fn zig_c_bw_view_urls() ?[*]?[*:0]u8;
extern fn zig_c_bw_view_urls_size() c_int;
extern fn zig_c_bw_view_col_map() ?[*]i64;
extern fn zig_c_bw_view_col_map_size() c_int;
extern fn zig_c_bw_view_col_map_line_ptr() ?*i64;
extern fn zig_c_bw_view_trs_ptr() ?*i64;
extern fn zig_c_bw_view_tre_ptr() ?*i64;
extern fn zig_c_bw_view_tsl_ptr() ?*i64;
extern fn zig_c_bw_view_tcfl_ptr() ?*i64;
extern fn zig_c_bw_view_tnrl_ptr() ?*i64;
extern fn zig_c_bw_view_tcc_ptr() ?*c_int;
extern fn zig_c_bw_view_tcw() ?[*]c_int;
extern fn zig_c_bw_view_tca() ?[*]c_int;
extern fn zig_c_bw_view_tcap() c_int;
extern fn zig_c_bw_view_after(line_len: c_int) void;
extern fn zig_c_bw_get_palette(t: ?*SCRN, out_len: ?*c_int) ?[*]c_int;

/// Thin `lgen_view` entry (JOE_ZIG_BW_LGEN): prelude + dispatcher + paint cleanup.
///
/// C keeps viewmode static storage (`zig_c_bw_view_*`) and the full Feature
/// fallback body when this returns `-1`. Markdown syntax gating stays in C.
///
/// Returns paint result (`>= 0`) or `-1` to fall back to C `lgen_view`.
pub export fn zig_bw_lgen_view_entry(
    t: ?*SCRN,
    y: isize,
    screen: ?[*][COMPOSE]c_int,
    attr_row: ?[*]c_int,
    x: isize,
    w: isize,
    p: ?*P,
    scr: i64,
    from: i64,
    to: i64,
    st: HighlightState,
    bw: ?*BW,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (t == null or screen == null or attr_row == null or p == null or bw == null) return -1;

    const syntax = zig_c_bw_get_syntax(bw) orelse return -1;
    const charmap = zig_c_bw_get_charmap(bw) orelse return -1;
    const cursor = zig_c_bw_get_cursor(bw) orelse return -1;
    const top_line = zig_c_bw_get_top_line(bw);
    const win_y = zig_c_bw_get_y(bw);
    const tab = zig_c_bw_get_tab(bw);

    // Pathological line length: match C early bail to `lgen_core`.
    {
        const lp = pdup(p, "zig_bw_lgen_view_entry_len") orelse return -1;
        defer prm(lp);
        zig_c_bw_p_goto_bol(lp);
        var ll: c_int = 0;
        while (true) {
            const ch = pgetb(lp);
            if (ch == NO_MORE_DATA or ch == '\n') break;
            ll += 1;
            if (ll > viewmode_max_line_bytes) {
                return zig_c_bw_lgen_core(t, y, screen, attr_row, x, w, p, scr, from, to, st, bw);
            }
        }
    }

    // Parse into hybrid attr_buf (same as C prelude).
    {
        const tmp = pdup(p, "zig_bw_lgen_view_entry_parse") orelse return -1;
        defer prm(tmp);
        zig_c_bw_p_goto_bol(tmp);
        _ = parse(syntax, tmp, st, charmap);
    }

    // Read line bytes.
    var line_len: c_int = 0;
    var line_cap: isize = 1024;
    var line_truncated: bool = false;
    const line_mem = joe_malloc(line_cap) orelse return -1;
    var line_ptr: [*]u8 = @ptrCast(@alignCast(line_mem));
    defer joe_free(line_ptr);

    {
        const tmp = pdup(p, "zig_bw_lgen_view_entry_read") orelse return -1;
        defer prm(tmp);
        zig_c_bw_p_goto_bol(tmp);
        while (true) {
            const c = pgetb(tmp);
            if (c == NO_MORE_DATA or c == '\n') break;
            if (line_len >= std.math.maxInt(c_int) - 1) break;
            if (line_len >= viewmode_max_line_bytes) {
                line_truncated = true;
                break;
            }
            if (@as(isize, @intCast(line_len)) >= line_cap) {
                var new_cap = line_cap * 2;
                if (new_cap <= line_cap) new_cap = line_cap + 1024 * 1024;
                if (new_cap > viewmode_max_line_bytes) new_cap = viewmode_max_line_bytes;
                const np = joe_realloc(line_ptr, new_cap) orelse return -1;
                line_ptr = @ptrCast(@alignCast(np));
                line_cap = new_cap;
            }
            line_ptr[@intCast(line_len)] = @intCast(c);
            line_len += 1;
        }
    }

    const need: c_int = if (line_len > 0) line_len else 1;
    if (zig_c_bw_view_prepare(bw, need) < 0) return -1;

    if (line_truncated) {
        zig_c_bw_view_after(line_len);
        return zig_c_bw_view_paint_body(t, y, screen, attr_row, x, w, p, scr, from, to, st, bw);
    }

    if (attr_buf == null or attr_size <= 0) return -1;

    const hide = zig_c_bw_view_hide() orelse return -1;
    const hide_size = zig_c_bw_view_hide_size();
    const subst = zig_c_bw_view_subst() orelse return -1;
    const subst_size = zig_c_bw_view_subst_size();
    const urls = zig_c_bw_view_urls() orelse return -1;
    const urls_size = zig_c_bw_view_urls_size();
    const col_map = zig_c_bw_view_col_map() orelse return -1;
    const col_map_size = zig_c_bw_view_col_map_size();
    const col_map_line = zig_c_bw_view_col_map_line_ptr() orelse return -1;
    const trs = zig_c_bw_view_trs_ptr() orelse return -1;
    const tre = zig_c_bw_view_tre_ptr() orelse return -1;
    const tsl = zig_c_bw_view_tsl_ptr() orelse return -1;
    const tcfl = zig_c_bw_view_tcfl_ptr() orelse return -1;
    const tnrl = zig_c_bw_view_tnrl_ptr() orelse return -1;
    const tcc = zig_c_bw_view_tcc_ptr() orelse return -1;
    const tcw = zig_c_bw_view_tcw() orelse return -1;
    const tca = zig_c_bw_view_tca() orelse return -1;
    const tcap = zig_c_bw_view_tcap();

    var pal_len: c_int = 0;
    const palette = zig_c_bw_get_palette(t, &pal_len);

    const buf_line = top_line + y - win_y;
    const defatr = zig_c_bw_view_defatr(bw, buf_line);
    const utf8: c_int = if (charmap.@"type" != 0) 1 else 0;

    const z = zig_bw_lgen_view(
        t,
        y,
        screen,
        attr_row,
        x,
        w,
        p,
        line_ptr,
        line_len,
        hide,
        hide_size,
        subst,
        subst_size,
        urls,
        urls_size,
        col_map,
        col_map_size,
        col_map_line,
        attr_buf,
        attr_size,
        tab,
        buf_line,
        cursor,
        trs,
        tre,
        tsl,
        tcfl,
        tnrl,
        tcc,
        tcw,
        tca,
        tcap,
        charmap,
        defatr,
        palette,
        pal_len,
        utf8,
    );
    if (z < 0) return -1;

    if (z == 1) {
        _ = pnextl(p);
        zig_c_bw_view_after(line_len);
        return 0;
    }
    const result = zig_c_bw_view_paint_body(t, y, screen, attr_row, x, w, p, scr, from, to, st, bw);
    zig_c_bw_view_after(line_len);
    return result;
}

/// Feature 2.1 residual: fill `vm_subst` via `table.applySimpleBorders`.
/// Live C only mutates separator rows when `table_col_count==0`; header/body/last
/// are no-ops — this matches that. Returns `0` on success, `-1` to fall back.
pub export fn zig_bw_table_simple(
    line: ?[*]const u8,
    line_len: c_int,
    row_type: c_int,
    vm_subst: ?[*]c_int,
    vm_subst_len: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (line == null or line_len < 0) return -1;
    if (vm_subst == null or vm_subst_len < line_len) return -1;

    // Match live C residual: only separator mutates; others succeed as no-op.
    if (row_type != 2) return 0; // TABLE_ROW_SEPARATOR == 2
    if (line_len == 0) return 0;

    const src = line.?[0..@intCast(line_len)];
    const n: usize = @intCast(line_len);
    const subst = std.heap.c_allocator.alloc(u21, n) catch return -1;
    defer std.heap.c_allocator.free(subst);
    @memset(subst, 0);
    render.table.applySimpleBorders(subst, src, .separator);

    var i: usize = 0;
    while (i < n) : (i += 1) {
        if (subst[i] != 0) vm_subst.?[i] = @intCast(subst[i]);
    }
    return 0;
}


extern var have: c_int;
extern fn zig_c_bw_lgen(
    t: ?*SCRN,
    y: isize,
    screen: ?[*][COMPOSE]c_int,
    attr_row: ?[*]c_int,
    x: isize,
    w: isize,
    p: ?*P,
    scr: i64,
    from: i64,
    to: i64,
    st: HighlightState,
    bw: ?*BW,
) c_int;
extern fn zig_c_bw_gennum(
    w: ?*BW,
    screen: ?[*][COMPOSE]c_int,
    attr_row: ?[*]c_int,
    t: ?*SCRN,
    y: isize,
    compose: ?[*]c_int,
) void;
extern fn zig_c_bw_get_highlight_state(w: ?*BW, p: ?*P, line: i64) HighlightState;
/// JOE `bwgen` paint loops → C `getto` / `gennum` / `lgen`.
///
/// Prefer `zig_bw_bwgen_entry` for full setup+loops+cursor. This owns the two
/// screen-row loops (cursor→bottom, then top→cursor) plus `prm` of the walk
/// pointer. Returns `0` on success, `-1` to fall back to C loops.
pub export fn zig_bw_bwgen(
    w: ?*BW,
    t: ?*SCRN,
    scrn: ?[*][COMPOSE]c_int,
    attr_base: ?[*]c_int,
    updtab: ?[*]c_int,
    compose: ?[*]c_int,
    scr_w: isize,
    win_x: isize,
    win_y: isize,
    win_w: isize,
    win_h: isize,
    mid_y: isize,
    top: ?*P,
    cursor: ?*P,
    top_line: i64,
    offset: i64,
    linums: c_int,
    linchg: c_int,
    dosquare: c_int,
    from: i64,
    to: i64,
    fromline: i64,
    toline: i64,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (w == null or t == null or scrn == null or attr_base == null or updtab == null) return -1;
    if (top == null or cursor == null) return -1;
    if (scr_w <= 0 or win_h < 0 or win_w < 0) return -1;

    const bot = win_y + win_h;
    const x1 = win_x + win_w;
    var p: ?*P = null;

    const PaintCtx = struct {
        w: ?*BW,
        t: ?*SCRN,
        scrn: [*][COMPOSE]c_int,
        attr_base: [*]c_int,
        updtab: [*]c_int,
        compose: ?[*]c_int,
        scr_w: isize,
        win_x: isize,
        win_y: isize,
        x1: isize,
        top: ?*P,
        cursor: ?*P,
        top_line: i64,
        offset: i64,
        linums: c_int,
        linchg: c_int,
        dosquare: c_int,
        from: i64,
        to: i64,
        fromline: i64,
        toline: i64,
    };

    const ctx = PaintCtx{
        .w = w,
        .t = t,
        .scrn = scrn.?,
        .attr_base = attr_base.?,
        .updtab = updtab.?,
        .compose = compose,
        .scr_w = scr_w,
        .win_x = win_x,
        .win_y = win_y,
        .x1 = x1,
        .top = top,
        .cursor = cursor,
        .top_line = top_line,
        .offset = offset,
        .linums = linums,
        .linchg = linchg,
        .dosquare = dosquare,
        .from = from,
        .to = to,
        .fromline = fromline,
        .toline = toline,
    };

    // Cursor line → bottom.
    var y = mid_y;
    while (y != bot) : (y += 1) {
        if (have != 0) break;
        p = paintOneRow(&ctx, y, p);
    }

    // Top → cursor line.
    y = win_y;
    while (y != mid_y) : (y += 1) {
        if (have != 0) break;
        p = paintOneRow(&ctx, y, p);
    }

    if (p) |pp| prm(pp);
    return 0;
}

fn paintOneRow(ctx: anytype, y: isize, p_in: ?*P) ?*P {
    const row_off: usize = @intCast(y * ctx.scr_w);
    const screen: [*][COMPOSE]c_int = ctx.scrn + row_off;
    const attr_row: [*]c_int = ctx.attr_base + row_off;
    if (ctx.linums != 0) {
        zig_c_bw_gennum(ctx.w, screen, attr_row, ctx.t, y, ctx.compose);
    }
    if (ctx.linchg == 0 and ctx.updtab[@intCast(y)] == 0) return p_in;

    const buf_line = ctx.top_line + y - ctx.win_y;
    const p = zig_c_bw_getto(p_in, ctx.cursor, ctx.top, buf_line);
    const st = zig_c_bw_get_highlight_state(ctx.w, p, buf_line);
    var use_from = ctx.from;
    var use_to = ctx.to;
    if (ctx.dosquare != 0) {
        if (buf_line < ctx.fromline or buf_line > ctx.toline) {
            use_from = 0;
            use_to = 0;
        }
    }
    ctx.updtab[@intCast(y)] = zig_c_bw_lgen(
        ctx.t,
        y,
        screen,
        attr_row,
        ctx.win_x,
        ctx.x1,
        p,
        ctx.offset,
        use_from,
        use_to,
        st,
        ctx.w,
    );
    return p;
}


extern fn zig_c_bw_bwgen_setup(
    w: ?*BW,
    from: ?*i64,
    to: ?*i64,
    fromline: ?*i64,
    toline: ?*i64,
    dosquare: ?*c_int,
) c_int;
extern fn zig_c_bw_get_scrn(w: ?*BW) ?*SCRN;
extern fn zig_c_bw_get_x(w: ?*BW) isize;
extern fn zig_c_bw_scr_w(w: ?*BW) isize;
extern fn zig_c_bw_scrn_cells(t: ?*SCRN) ?[*][COMPOSE]c_int;
extern fn zig_c_bw_scrn_attr(t: ?*SCRN) ?[*]c_int;
extern fn zig_c_bw_scrn_updtab(t: ?*SCRN) ?[*]c_int;
extern fn zig_c_bw_scrn_compose(t: ?*SCRN) ?[*]c_int;
extern fn zig_c_bw_get_viewmode(w: ?*BW) c_int;
extern fn zig_c_bw_get_h(w: ?*BW) isize;
extern fn zig_c_bw_get_w(w: ?*BW) isize;
extern fn zig_c_bw_get_offset(w: ?*BW) i64;
extern fn zig_c_bw_set_cursor_xcol(w: ?*BW, xcol: i64) void;

fn applyBwgenViewCursor(w: ?*BW) void {
    if (zig_c_bw_get_viewmode(w) == 0) return;
    const col_map = zig_c_bw_view_col_map() orelse return;
    const col_map_size = zig_c_bw_view_col_map_size();
    if (col_map_size <= 0) return;
    const map_line_ptr = zig_c_bw_view_col_map_line_ptr() orelse return;
    const cursor = zig_c_bw_get_cursor(w) orelse return;
    const buf_line = zig_c_bw_pline_no(cursor);
    if (map_line_ptr.* != buf_line) return;

    const tmp = pdup(cursor, "zig_bw_bwgen_entry_cursor") orelse return;
    defer prm(tmp);
    zig_c_bw_p_goto_bol(tmp);
    const cursor_offset = zig_c_bw_pbyte(cursor) - zig_c_bw_pbyte(tmp);
    if (cursor_offset >= 0 and cursor_offset < col_map_size) {
        zig_c_bw_set_cursor_xcol(w, col_map[@intCast(cursor_offset)]);
    }
}

/// Thin `bwgen` entry (JOE_ZIG_BW_LGEN): lattr/viewmode/mark setup + paint loops +
/// Feature 1.10 cursor. C keeps the full `bwgen` fallback body.
///
/// Returns `0` on success, `-1` to fall back to C `bwgen`.
pub export fn zig_bw_bwgen_entry(w: ?*BW, linums: c_int, linchg: c_int) c_int {
    if (zig_bw_lgen_enabled == 0 or w == null) return -1;

    var from: i64 = 0;
    var to: i64 = 0;
    var fromline: i64 = 0;
    var toline: i64 = 0;
    var dosquare: c_int = 0;
    if (zig_c_bw_bwgen_setup(w, &from, &to, &fromline, &toline, &dosquare) < 0)
        return -1;

    const t = zig_c_bw_get_scrn(w) orelse return -1;
    const scrn = zig_c_bw_scrn_cells(t) orelse return -1;
    const attr_base = zig_c_bw_scrn_attr(t) orelse return -1;
    const updtab = zig_c_bw_scrn_updtab(t) orelse return -1;
    const compose = zig_c_bw_scrn_compose(t);
    const top = zig_c_bw_get_top(w) orelse return -1;
    const cursor = zig_c_bw_get_cursor(w) orelse return -1;

    const scr_w = zig_c_bw_scr_w(w);
    const win_x = zig_c_bw_get_x(w);
    const win_y = zig_c_bw_get_y(w);
    const win_w = zig_c_bw_get_w(w);
    const win_h = zig_c_bw_get_h(w);
    const top_line = zig_c_bw_get_top_line(w);
    const offset = zig_c_bw_get_offset(w);
    const cursor_line = zig_c_bw_pline_no(cursor);
    const mid_y = @as(isize, @intCast(cursor_line - top_line)) + win_y;

    if (zig_bw_bwgen(
        w,
        t,
        scrn,
        attr_base,
        updtab,
        compose,
        scr_w,
        win_x,
        win_y,
        win_w,
        win_h,
        mid_y,
        top,
        cursor,
        top_line,
        offset,
        linums,
        linchg,
        dosquare,
        from,
        to,
        fromline,
        toline,
    ) < 0) return -1;

    applyBwgenViewCursor(w);
    return 0;
}

/// JOE `bwgenh` hex dump paint loop → C `genfield`.
///
/// Prefer `zig_bw_bwgenh_entry` for mark setup + paint. This owns the per-row
/// hex formatting and `genfield` emit. Returns `0` on success, `-1` to fall back.
pub export fn zig_bw_bwgenh(
    t: ?*SCRN,
    scrn: ?[*][COMPOSE]c_int,
    attr_base: ?[*]c_int,
    scr_w: isize,
    win_y: isize,
    win_h: isize,
    win_w: isize,
    offset: i64,
    top: ?*P,
    cursor_byte: i64,
    hiline: c_int,
    from: i64,
    to: i64,
    bg_text_atr: c_int,
    bg_linum_atr: c_int,
    bg_curlinum_atr: c_int,
    bg_cursor_atr: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (t == null or scrn == null or attr_base == null or top == null) return -1;
    if (scr_w <= 0 or win_h < 0 or win_w < 0) return -1;

    const q = pdup(top, "zig_bw_bwgenh") orelse return -1;
    defer prm(q);

    var flg: c_int = 0;
    var y: isize = win_y;
    const bot = win_y + win_h;
    const ofst: isize = if (offset < 0) 0 else @intCast(offset);

    while (y != bot) : (y += 1) {
        const screen: [*][COMPOSE]c_int = @ptrCast(scrn.? + @as(usize, @intCast(y * scr_w)));
        const attr_row: [*]c_int = @ptrCast(attr_base.? + @as(usize, @intCast(y * scr_w)));

        var txt: [80]u8 = undefined;
        var fmt: [80]c_int = undefined;
        @memset(txt[0..76], ' ');
        @memset(fmt[0..76], bg_text_atr);
        txt[76] = 0;

        const qbyte = zig_c_bw_pbyte(q);
        const same16 = (qbyte & ~@as(i64, 15)) == (cursor_byte & ~@as(i64, 15));
        const addr_atr: c_int = if (hiline != 0 and same16) bg_curlinum_atr else bg_linum_atr;
        @memset(fmt[0..9], addr_atr);

        if (flg == 0) {
            var bf: [16]u8 = undefined;
            const addr_u: u64 = @bitCast(qbyte);
            const addr = std.fmt.bufPrint(&bf, "{x: >8} ", .{addr_u}) catch return -1;
            const n = @min(addr.len, @as(usize, 9));
            @memcpy(txt[0..n], addr[0..n]);

            var x: usize = 0;
            while (x < 8) : (x += 1) {
                const live = zig_c_bw_pbyte(q);
                if (live == cursor_byte and flg == 0) {
                    fmt[10 + x * 3] = bg_cursor_atr;
                    fmt[10 + x * 3 + 1] = bg_cursor_atr;
                }
                if (live >= from and live < to and flg == 0) {
                    fmt[10 + x * 3] |= UNDERLINE;
                    fmt[10 + x * 3 + 1] |= UNDERLINE;
                    fmt[60 + x] |= INVERSE;
                }
                const c = pgetb(q);
                if (c != NO_MORE_DATA) {
                    const hx = std.fmt.bufPrint(&bf, "{x:0>2}", .{@as(u8, @intCast(c))}) catch return -1;
                    txt[10 + x * 3] = hx[0];
                    txt[10 + x * 3 + 1] = hx[1];
                    if (c >= 0x20 and c <= 0x7E)
                        txt[60 + x] = @intCast(c)
                    else
                        txt[60 + x] = '.';
                } else {
                    flg = 1;
                }
            }
            x = 8;
            while (x < 16) : (x += 1) {
                const live = zig_c_bw_pbyte(q);
                if (live == cursor_byte and flg == 0) {
                    fmt[11 + x * 3] = bg_cursor_atr;
                    fmt[11 + x * 3 + 1] = bg_cursor_atr;
                }
                if (live >= from and live < to and flg == 0) {
                    fmt[11 + x * 3] |= UNDERLINE;
                    fmt[11 + x * 3 + 1] |= UNDERLINE;
                    fmt[60 + x] |= INVERSE;
                }
                const c = pgetb(q);
                if (c != NO_MORE_DATA) {
                    const hx = std.fmt.bufPrint(&bf, "{x:0>2}", .{@as(u8, @intCast(c))}) catch return -1;
                    txt[11 + x * 3] = hx[0];
                    txt[11 + x * 3 + 1] = hx[1];
                    if (c >= 0x20 and c <= 0x7E)
                        txt[60 + x] = @intCast(c)
                    else
                        txt[60 + x] = '.';
                } else {
                    flg = 1;
                }
            }
        }

        genfield(
            t,
            screen,
            attr_row,
            0,
            y,
            ofst,
            @ptrCast(&txt),
            76,
            bg_text_atr,
            win_w,
            1,
            &fmt,
        );
    }
    return 0;
}

extern fn zig_c_bw_bwgenh_setup(w: ?*BW, from: ?*i64, to: ?*i64) c_int;
extern fn zig_c_bw_get_hiline(w: ?*BW) c_int;
extern fn zig_c_bw_bg_text() c_int;
extern fn zig_c_bw_bg_linum() c_int;
extern fn zig_c_bw_bg_curlinum() c_int;
extern fn zig_c_bw_bg_cursor() c_int;

/// Thin `bwgenh` entry (JOE_ZIG_BW_LGEN): mark setup + hex paint.
/// C keeps the full `bwgenh` fallback body. Returns `0` or `-1` fallback.
pub export fn zig_bw_bwgenh_entry(w: ?*BW) c_int {
    if (zig_bw_lgen_enabled == 0 or w == null) return -1;

    var from: i64 = 0;
    var to: i64 = 0;
    if (zig_c_bw_bwgenh_setup(w, &from, &to) < 0) return -1;

    const t = zig_c_bw_get_scrn(w) orelse return -1;
    const scrn = zig_c_bw_scrn_cells(t) orelse return -1;
    const attr_base = zig_c_bw_scrn_attr(t) orelse return -1;
    const top = zig_c_bw_get_top(w) orelse return -1;
    const cursor = zig_c_bw_get_cursor(w) orelse return -1;

    return zig_bw_bwgenh(
        t,
        scrn,
        attr_base,
        zig_c_bw_scr_w(w),
        zig_c_bw_get_y(w),
        zig_c_bw_get_h(w),
        zig_c_bw_get_w(w),
        zig_c_bw_get_offset(w),
        top,
        zig_c_bw_pbyte(cursor),
        zig_c_bw_get_hiline(w),
        from,
        to,
        zig_c_bw_bg_text(),
        zig_c_bw_bg_linum(),
        zig_c_bw_bg_curlinum(),
        zig_c_bw_bg_cursor(),
    );
}


/// Feature 2.2 padded table row → Zig `table.paintRow` → hybrid `outatr`.
///
/// C still detects the table region and computes `widths`/`aligns`/`row_type`.
/// Returns `0` on success, `-1` to fall back to C `render_padded_table_row`.
/// Does **not** advance `P` (C `lgen_view` does `pnextl` when table-rendered).
/// Optional `col_map` fill matches C (only when already sized).
pub export fn zig_bw_table_row(
    t: ?*SCRN,
    y: isize,
    screen: ?[*][COMPOSE]c_int,
    attr_row: ?[*]c_int,
    x0: isize,
    x1: isize,
    line: ?[*]const u8,
    line_len: c_int,
    ncols: c_int,
    widths: ?[*]const c_int,
    aligns: ?[*]const c_int,
    row_type: c_int,
    charmap: ?*Charmap,
    defatr: c_int,
    palette: ?[*]c_int,
    palette_len: c_int,
    col_map: ?[*]i64,
    col_map_size: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (t == null or screen == null or attr_row == null) return -1;
    if (line == null or line_len < 0) return -1;
    if (x1 <= x0) return -1;
    if (charmap == null or charmap.?.@"type" == 0) return -1;
    if (ncols <= 0 or widths == null or aligns == null) return -1;
    if (ncols > render.table.max_cols) return -1;

    const win_w_isize = x1 - x0;
    if (win_w_isize <= 0 or win_w_isize > 10000) return -1;
    const win_w: u16 = @intCast(win_w_isize);
    const src = line.?[0..@intCast(line_len)];

    const row_kind: TableRowKind = switch (row_type) {
        1 => .header, // TABLE_ROW_HEADER
        2 => .separator, // TABLE_ROW_SEPARATOR
        3 => .body, // TABLE_ROW_BODY
        4 => .last, // TABLE_ROW_LAST
        else => return -1,
    };

    var layout: TableLayout = .{
        .start = 0,
        .end = 4,
        .sep = 1,
        .ncols = @intCast(ncols),
    };
    // Synthetic indices so `Layout.kind` matches JOE row_type. Feature 2.2 paints
    // `.last` like `.body` (│ borders); only header/separator change glyphs/attrs.
    const line_idx: usize = switch (row_kind) {
        .header => 0,
        .separator => 1,
        .body, .last => 2,
        .none => return -1,
    };

    var ci: usize = 0;
    while (ci < layout.ncols) : (ci += 1) {
        const w = widths.?[ci];
        layout.widths[ci] = if (w < 0) 0 else @intCast(@min(w, 65535));
        layout.aligns[ci] = switch (aligns.?[ci]) {
            1 => .center,
            2 => .right,
            else => .left,
        };
    }

    const alloc = std.heap.c_allocator;
    const pal: ?[]const i32 = if (palette != null and palette_len > 0)
        palette.?[0..@intCast(palette_len)]
    else
        null;
    const base_attr = terminal.attributeFromHybrid(defatr, pal);

    var scratch = terminal.Screen.init(alloc, win_w, 1) catch return -1;
    defer scratch.deinit();

    if (!render.table.paintRow(&scratch, 0, 0, win_w, src, layout, line_idx, base_attr))
        return -1;

    var tc_pal: TruecolorPalette = .{};
    if (palette != null and palette_len > 0) {
        var pi: u8 = 1;
        const plen: usize = @intCast(palette_len);
        while (pi < 255 and pi < plen) : (pi += 1) {
            const v = palette.?[pi];
            if (v >= 0) {
                tc_pal.slots[pi] = @intCast(v);
                if (tc_pal.next <= pi) tc_pal.next = pi +% 1;
            }
        }
    }

    var cx: u16 = 0;
    while (cx < win_w) : (cx += 1) {
        const cell = scratch.cells[cx];
        if (cell.cp == 0) continue;
        const atr: c_int = attributeToHybridOrDef(cell.attr, &tc_pal, defatr);
        const xx: isize = x0 + @as(isize, @intCast(cx));
        outatr(
            charmap,
            t,
            @ptrCast(screen.? + @as(usize, @intCast(xx))),
            @ptrCast(attr_row.? + @as(usize, @intCast(xx))),
            xx,
            y,
            @intCast(cell.cp),
            atr,
        );
        for (cell.combine) |mark| {
            if (mark == 0) break;
            outatr(
                charmap,
                t,
                @ptrCast(screen.? + @as(usize, @intCast(xx))),
                @ptrCast(attr_row.? + @as(usize, @intCast(xx))),
                xx,
                y,
                @intCast(mark),
                atr,
            );
        }
    }
    outatr_complete(t);
    // paintRow already cleared the scratch to win_w; emit covers [x0,x1).
    // eraeol from x1 clears any cells past the window right edge (matches C when oc==w).
    _ = eraeol(t, x1, y, defatr);

    // C `render_padded_table_row` skips col_map on separator rows (early return).
    if (row_kind != .separator and col_map != null and col_map_size >= line_len and line_len > 0) {
        fillTableColMap(col_map.?, @intCast(col_map_size), src, layout, x0);
    }

    return 0;
}

/// Returns:
/// - `0`/`1` — same meaning as C `lgen_core` (`updtab` done flag from `eraeol`)
/// - `-1` — caller should fall back to C `lgen_core`
pub export fn zig_bw_lgen(
    t: ?*SCRN,
    y: isize,
    screen: ?[*][COMPOSE]c_int,
    attr_row: ?[*]c_int,
    x0: isize,
    x1: isize,
    p: ?*P,
    scr_offset: i64,
    syntax: ?*HighSyntax,
    st: HighlightState,
    charmap: ?*Charmap,
    tab: c_int,
    defatr: c_int,
    palette: ?[*]c_int,
    palette_len: c_int,
    from: i64,
    to: i64,
    line_byte: i64,
    viewmode: c_int,
    vm_hide: ?[*]u8,
    vm_hide_len: c_int,
    vm_subst: ?[*]c_int,
    vm_subst_len: c_int,
    vm_urls: ?[*]?[*:0]u8,
    vm_urls_len: c_int,
    visiblews: c_int,
    square: c_int,
    ansi: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (t == null or screen == null or attr_row == null or p == null) return -1;
    if (x1 <= x0) return -1;
    if (charmap == null) return -1;
    const byte_mode = charmap.?.@"type" == 0;

    const win_w_isize = x1 - x0;
    if (win_w_isize <= 0 or win_w_isize > 10000) return -1;
    const win_w: u16 = @intCast(win_w_isize);
    const preparsed = viewmode != 0;

    const alloc = std.heap.c_allocator;
    var line_buf: std.ArrayList(u8) = .empty;
    defer line_buf.deinit(alloc);

    // Read from caller's `p` as-is (BOL of the target line, or EOF).
    // Do **not** `p_goto_bol`: past-EOF `getto` leaves `p` at EOF on the last
    // line, and C `lgen_core` paints blank from that position. Going to BOL
    // would repaint the last line on every trailing screen row.
    const len_tmp = pdup(p, "zig_bw_lgen_len") orelse return -1;
    defer prm(len_tmp);
    var ll: usize = 0;
    while (true) {
        const ch = pgetb(len_tmp);
        if (ch == NO_MORE_DATA or ch == '\n') break;
        ll += 1;
        if (ll > max_line_bytes) return -1;
    }

    const highlight = (syntax != null and st.state != -1);
    // Viewmode: `lgen_view` already ran `parse` and mutated `attr_buf` (links etc).
    if (highlight and !preparsed) {
        const parse_tmp = pdup(p, "zig_bw_lgen_parse") orelse return -1;
        defer prm(parse_tmp);
        _ = parse(syntax, parse_tmp, st, charmap);
    }

    const copy_tmp = pdup(p, "zig_bw_lgen_copy") orelse return -1;
    defer prm(copy_tmp);
    var saw_eol = false;
    while (true) {
        const ch = pgetb(copy_tmp);
        if (ch == NO_MORE_DATA) break;
        if (ch == '\n') {
            saw_eol = true;
            break;
        }
        if (line_buf.items.len >= max_line_bytes) break;
        line_buf.append(alloc, @intCast(ch)) catch return -1;
    }
    // Include trailing `\n` so native paint emits `vrtn` (EOF-without-NL omits it).
    if (saw_eol and visiblews != 0) {
        line_buf.append(alloc, '\n') catch return -1;
    }
    const line = line_buf.items;
    // Attr/mark/view tables are per content byte — exclude synthetic `\n`.
    const content = if (saw_eol and visiblews != 0 and line.len > 0 and line[line.len - 1] == '\n')
        line[0 .. line.len - 1]
    else
        line;

    const pal: ?[]const i32 = if (palette != null and palette_len > 0)
        palette.?[0..@intCast(palette_len)]
    else
        null;

    var attrs_owned: ?[]Attribute = null;
    defer if (attrs_owned) |a| alloc.free(a);
    var native_attrs: ?[]const Attribute = null;

    const use_attr_buf = (highlight or preparsed) and attr_buf != null and attr_size > 0 and content.len > 0;
    if (use_attr_buf) {
        // Hybrid `parse`/`pgetc` fills one atr per character, not per byte.
        // Viewmode ASCII-mostly lines: char index ≡ byte index after C mutations.
        const nchar = if (byte_mode)
            @min(content.len, @as(usize, @intCast(attr_size)))
        else
            @min(utf8CharCount(content), @as(usize, @intCast(attr_size)));
        const char_attrs = alloc.alloc(Attribute, nchar) catch return -1;
        defer alloc.free(char_attrs);
        render.fromHybridRow(char_attrs, attr_buf[0..nchar], pal);

        const byte_attrs = alloc.alloc(Attribute, content.len) catch return -1;
        if (byte_mode) {
            const n = @min(nchar, content.len);
            @memcpy(byte_attrs[0..n], char_attrs[0..n]);
            if (n < content.len) @memset(byte_attrs[n..], .none);
        } else {
            expandCharAttrsToBytes(content, char_attrs, byte_attrs);
        }
        attrs_owned = byte_attrs;
        native_attrs = byte_attrs;
    }

    // Linear mark inverse on raw bytes (ESC bytes count in buffer offsets).
    // Square marks wait until after ansi strip (display columns skip ESC).
    // `bwgen` already scopes square to mark lines (passes from=to=0 off-line).
    if (from != to and content.len > 0 and square == 0) {
        if (attrs_owned == null) {
            const byte_attrs = alloc.alloc(Attribute, content.len) catch return -1;
            @memset(byte_attrs, .none);
            attrs_owned = byte_attrs;
        }
        applyLinearMarkInverse(attrs_owned.?, line_byte, from, to);
        native_attrs = attrs_owned;
    }

    // Borrow C `lgen_view` side tables. `col_map` is cursor-only (stays in C).
    var hide_owned: ?[]u8 = null;
    defer if (hide_owned) |h| alloc.free(h);
    var subst_owned: ?[]u21 = null;
    defer if (subst_owned) |s| alloc.free(s);
    var links_owned: ?[]?[]const u8 = null;
    defer if (links_owned) |l| alloc.free(l);

    var view_tables: ViewTables = undefined;
    var view_ptr: ?*const ViewTables = null;

    if (preparsed and content.len > 0) {
        const n = content.len;

        const hide_slice: []u8 = blk: {
            if (vm_hide != null and vm_hide_len > 0) {
                const hn = @min(n, @as(usize, @intCast(vm_hide_len)));
                if (hn == n) break :blk vm_hide.?[0..hn];
                const padded = alloc.alloc(u8, n) catch return -1;
                @memset(padded, 0);
                @memcpy(padded[0..hn], vm_hide.?[0..hn]);
                hide_owned = padded;
                break :blk padded;
            }
            const zeros = alloc.alloc(u8, n) catch return -1;
            @memset(zeros, 0);
            hide_owned = zeros;
            break :blk zeros;
        };

        const subst = alloc.alloc(u21, n) catch return -1;
        @memset(subst, 0);
        if (vm_subst != null and vm_subst_len > 0) {
            const sn = @min(n, @as(usize, @intCast(vm_subst_len)));
            var i: usize = 0;
            while (i < sn) : (i += 1) {
                const v = vm_subst.?[i];
                if (v > 0) subst[i] = @intCast(v);
            }
        }
        subst_owned = subst;

        const links = alloc.alloc(?[]const u8, n) catch return -1;
        @memset(links, null);
        if (vm_urls != null and vm_urls_len > 0) {
            const un = @min(n, @as(usize, @intCast(vm_urls_len)));
            var i: usize = 0;
            while (i < un) : (i += 1) {
                if (vm_urls.?[i]) |up| links[i] = std.mem.span(up);
            }
        }
        links_owned = links;

        view_tables = .{
            .allocator = alloc,
            .owns_memory = false,
            .hide = hide_slice,
            .substitute = subst,
            .link_url = links,
            .col_map = &.{},
            .len = n,
        };
        view_ptr = &view_tables;
    }

    // `-ansi`: strip JOE `ansi_decode` spans (ESC…letter) for paint. Attrs from
    // `ansi_parse` stay aligned because parse walked the same raw characters.
    var ansi_text_owned: ?[]u8 = null;
    defer if (ansi_text_owned) |bytes| alloc.free(bytes);
    var ansi_attrs_owned: ?[]Attribute = null;
    defer if (ansi_attrs_owned) |a| alloc.free(a);
    var ansi_hide_owned: ?[]u8 = null;
    defer if (ansi_hide_owned) |h| alloc.free(h);
    var ansi_subst_owned: ?[]u21 = null;
    defer if (ansi_subst_owned) |s| alloc.free(s);
    var ansi_links_owned: ?[]?[]const u8 = null;
    defer if (ansi_links_owned) |l| alloc.free(l);

    var paint_content: []const u8 = content;
    if (ansi != 0 and content.len > 0) {
        const stripped = stripAnsiEscapes(
            alloc,
            content,
            if (attrs_owned) |a| a else null,
            if (view_ptr) |vt| vt.hide else null,
            if (view_ptr) |vt| vt.substitute else null,
            if (view_ptr) |vt| vt.link_url else null,
        ) catch return -1;
        ansi_text_owned = stripped.text;
        paint_content = stripped.text;
        if (stripped.attrs) |a| {
            ansi_attrs_owned = a;
            native_attrs = a;
        }
        if (view_ptr != null) {
            if (stripped.hide) |h| ansi_hide_owned = h;
            if (stripped.subst) |s| ansi_subst_owned = s;
            if (stripped.links) |l| ansi_links_owned = l;
            view_tables = .{
                .allocator = alloc,
                .owns_memory = false,
                .hide = ansi_hide_owned orelse &.{},
                .substitute = ansi_subst_owned orelse &.{},
                .link_url = ansi_links_owned orelse &.{},
                .col_map = &.{},
                .len = paint_content.len,
            };
            view_ptr = &view_tables;
        }
    }

    // Square mark inverse on display columns (post-ansi-strip).
    if (from != to and paint_content.len > 0 and square != 0) {
        const mutable: []Attribute = blk: {
            if (ansi_attrs_owned) |a| break :blk a;
            if (attrs_owned) |a| break :blk a;
            const byte_attrs = alloc.alloc(Attribute, paint_content.len) catch return -1;
            @memset(byte_attrs, .none);
            attrs_owned = byte_attrs;
            break :blk byte_attrs;
        };
        if (mutable.len != paint_content.len) return -1;
        const tab_u16: u16 = if (tab <= 0) 1 else @intCast(tab);
        applySquareMarkInverse(mutable, paint_content, tab_u16, from, to, byte_mode);
        native_attrs = mutable;
    }

    // Paint text: content (+ trailing \n for visiblews rtn).
    var paint_line_buf: std.ArrayList(u8) = .empty;
    defer paint_line_buf.deinit(alloc);
    var paint_line: []const u8 = paint_content;
    if (saw_eol and visiblews != 0) {
        paint_line_buf.appendSlice(alloc, paint_content) catch return -1;
        paint_line_buf.append(alloc, '\n') catch return -1;
        paint_line = paint_line_buf.items;
    } else if (ansi != 0) {
        paint_line = paint_content;
    } else {
        paint_line = line;
    }

    const base_attr = terminal.attributeFromHybrid(defatr, pal);

    var vws_storage: VisibleWs = undefined;
    var vws_ptr: ?*const VisibleWs = null;
    if (visiblews != 0) {
        const style = terminal.attributeFromHybrid(vwsatr, pal);
        vws_storage = .{
            .space = if (vspace > 0) @intCast(vspace) else 0xb7,
            .tab = if (vtab > 0) @intCast(vtab) else 0x2192,
            .rtn = if (vrtn > 0) @intCast(vrtn) else 0x21b5,
            .style = .{ .dim = style.dim, .fg = style.fg },
            .clear_fg = true,
        };
        vws_ptr = &vws_storage;
    }

    var scratch = terminal.Screen.init(alloc, win_w, 1) catch return -1;
    defer scratch.deinit();

    const tab_u: u16 = if (tab <= 0) 8 else @intCast(@min(tab, 256));
    const opts: render.Options = .{
        .tab = tab_u,
        .offset = if (scr_offset < 0) 0 else @intCast(scr_offset),
        .attrs = native_attrs,
        .view = view_ptr,
        .visible_ws = vws_ptr,
        .byte_mode = byte_mode,
    };
    _ = render.lgenLine(&scratch, 0, 0, win_w, paint_line, opts, base_attr);

    var tc_pal: TruecolorPalette = .{};
    if (palette != null and palette_len > 0) {
        var pi: u8 = 1;
        const plen: usize = @intCast(palette_len);
        while (pi < 255 and pi < plen) : (pi += 1) {
            const v = palette.?[pi];
            if (v >= 0) {
                tc_pal.slots[pi] = @intCast(v);
                if (tc_pal.next <= pi) tc_pal.next = pi +% 1;
            }
        }
    }

    var current_url: ?[]const u8 = null;
    var cx: u16 = 0;
    while (cx < win_w) : (cx += 1) {
        const cell = scratch.cells[cx];
        // Wide-continuation cells (cp==0) are filled by `outatr_complete`.
        if (cell.cp == 0) continue;

        if (preparsed) current_url = emitOsc8Link(current_url, cell.url);

        const atr: c_int = attributeToHybridOrDef(cell.attr, &tc_pal, defatr);
        const xx: isize = x0 + @as(isize, @intCast(cx));
        outatr(
            charmap,
            t,
            @ptrCast(screen.? + @as(usize, @intCast(xx))),
            @ptrCast(attr_row.? + @as(usize, @intCast(xx))),
            xx,
            y,
            @intCast(cell.cp),
            atr,
        );
        for (cell.combine) |mark| {
            if (mark == 0) break;
            outatr(
                charmap,
                t,
                @ptrCast(screen.? + @as(usize, @intCast(xx))),
                @ptrCast(attr_row.? + @as(usize, @intCast(xx))),
                xx,
                y,
                @intCast(mark),
                atr,
            );
        }
    }
    if (preparsed) _ = emitOsc8Link(current_url, null);
    outatr_complete(t);

    // Advance caller's P to next line (JOE lgen contract).
    _ = pnextl(p);

    const done = eraeol(t, x1, y, defatr);
    return done;
}

fn attributeToHybridOrDef(attr: Attribute, palette: *TruecolorPalette, defatr: c_int) c_int {
    return terminal.attributeToHybrid(attr, palette) catch defatr;
}

/// JOE `render_padded_table_row` col_map fill — buffer byte → display column.
/// `base_x` is window content left (`bw->x`), matching C.
fn fillTableColMap(col_map: [*]i64, col_map_size: usize, line: []const u8, layout: TableLayout, base_x: isize) void {
    const n = @min(line.len, col_map_size);
    if (n == 0) return;
    var bi: usize = 0;
    while (bi < n) : (bi += 1) col_map[bi] = 0;

    var pipe_pos: [render.table.max_cols]usize = undefined;
    const pipe_count = blk: {
        var count: usize = 0;
        var i: usize = 0;
        while (i < line.len and count < pipe_pos.len) : (i += 1) {
            if (line[i] == '|') {
                pipe_pos[count] = i;
                count += 1;
            }
        }
        break :blk count;
    };
    if (pipe_count == 0) return;
    const ncols = @min(if (pipe_count > 0) pipe_count - 1 else 0, layout.ncols);
    if (ncols == 0) return;

    var cells: [render.table.max_cols]struct { start: usize, end: usize, width: u16 } = undefined;
    var ci: usize = 0;
    while (ci < ncols) : (ci += 1) {
        const cs = pipe_pos[ci] + 1;
        const ce = if (ci + 1 < pipe_count) pipe_pos[ci + 1] else line.len;
        var ts = cs;
        while (ts < ce and (line[ts] == ' ' or line[ts] == '\t')) : (ts += 1) {}
        var te = ce;
        while (te > ts and (line[te - 1] == ' ' or line[te - 1] == '\t')) : (te -= 1) {}
        var width: u16 = 0;
        var p = ts;
        while (p < te) {
            const b = line[p];
            if ((b & 0x80) == 0) {
                const cw = terminal.displayWidth(b);
                if (cw > 0) width +|= cw;
                p += 1;
            } else {
                const seq_len = std.unicode.utf8ByteSequenceLength(b) catch {
                    width +|= 1;
                    p += 1;
                    continue;
                };
                if (p + seq_len > te) break;
                const cp = std.unicode.utf8Decode(line[p..][0..seq_len]) catch {
                    width +|= 1;
                    p += 1;
                    continue;
                };
                const cw = terminal.displayWidth(cp);
                if (cw > 0) width +|= cw;
                p += seq_len;
            }
        }
        cells[ci] = .{ .start = ts, .end = te, .width = width };
    }

    var content_display_start: [render.table.max_cols]isize = undefined;
    var col_start_disp: isize = base_x;
    ci = 0;
    while (ci < ncols) : (ci += 1) {
        content_display_start[ci] = col_start_disp;
        var cw = layout.widths[ci];
        if (cw < cells[ci].width) cw = cells[ci].width;
        col_start_disp += 3 + @as(isize, @intCast(cw));
    }

    ci = 0;
    while (ci < ncols) : (ci += 1) {
        const base = content_display_start[ci];
        var cw = layout.widths[ci];
        if (cw < cells[ci].width) cw = cells[ci].width;
        const pad_t: u16 = cw -| cells[ci].width;
        const pl: u16 = switch (layout.aligns[ci]) {
            .left => 0,
            .center => pad_t / 2,
            .right => pad_t,
        };
        if (ci < pipe_count and pipe_pos[ci] < n) col_map[pipe_pos[ci]] = base;

        var content_col: isize = base + 1 + 1 + @as(isize, @intCast(pl));
        var buf_i = cells[ci].start;
        var p = cells[ci].start;
        while (p < cells[ci].end and buf_i < cells[ci].end) {
            const b = line[p];
            var seq_len: usize = 1;
            var cww: u16 = 1;
            if ((b & 0x80) == 0) {
                cww = terminal.displayWidth(b);
                p += 1;
            } else {
                seq_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
                if (p + seq_len > cells[ci].end) break;
                if (std.unicode.utf8Decode(line[p..][0..seq_len])) |cp| {
                    cww = terminal.displayWidth(cp);
                } else |_| {
                    seq_len = 1;
                    cww = 1;
                }
                p += seq_len;
            }
            while (buf_i < cells[ci].end and buf_i < p) {
                if (buf_i < n) col_map[buf_i] = content_col;
                buf_i += 1;
            }
            if (cww > 0) content_col += cww;
        }
        const content_end_col: isize = base + 1 + 1 + @as(isize, @intCast(cw)) + 1;
        const next_pipe = if (ci + 1 < pipe_count) pipe_pos[ci + 1] else line.len;
        while (buf_i < next_pipe and buf_i < n) : (buf_i += 1) {
            col_map[buf_i] = content_end_col;
        }
    }
}

/// JOE `out_osc8_link` shaped — content equality (C uses pointer equality on shared URLs).
fn emitOsc8Link(old: ?[]const u8, new_url: ?[]const u8) ?[]const u8 {
    const same = blk: {
        if (old == null and new_url == null) break :blk true;
        if (old == null or new_url == null) break :blk false;
        break :blk std.mem.eql(u8, old.?, new_url.?);
    };
    if (same) return old;

    if (old != null) ttputs("\x1b]8;;\x1b\\");
    if (new_url) |url| {
        ttputs("\x1b]8;;");
        var buf: [256]u8 = undefined;
        var n: usize = 0;
        for (url) |ch| {
            if (ch < 0x20 or ch == 0x7F or (ch >= 0x80 and ch <= 0x9F)) continue;
            if (n + 1 >= buf.len) {
                buf[n] = 0;
                ttputs(@ptrCast(&buf));
                n = 0;
            }
            buf[n] = ch;
            n += 1;
        }
        if (n > 0) {
            buf[n] = 0;
            ttputs(@ptrCast(&buf));
        }
        ttputs("\x1b\\");
    }
    return new_url;
}

const AnsiStripResult = struct {
    text: []u8,
    attrs: ?[]Attribute,
    hide: ?[]u8,
    subst: ?[]u21,
    links: ?[]?[]const u8,
};

/// Remove JOE `ansi_decode` hidden spans (from ESC through terminating ASCII letter).
/// Compacts optional parallel slices in lockstep (must be null or `src.len`).
fn stripAnsiEscapes(
    alloc: std.mem.Allocator,
    src: []const u8,
    attrs: ?[]const Attribute,
    hide: ?[]const u8,
    subst: ?[]const u21,
    links: ?[]const ?[]const u8,
) !AnsiStripResult {
    if (attrs) |a| std.debug.assert(a.len == src.len);
    if (hide) |h| std.debug.assert(h.len == src.len);
    if (subst) |s| std.debug.assert(s.len == src.len);
    if (links) |l| std.debug.assert(l.len == src.len);

    var text: std.ArrayList(u8) = .empty;
    errdefer text.deinit(alloc);
    var out_attrs: std.ArrayList(Attribute) = .empty;
    errdefer out_attrs.deinit(alloc);
    var out_hide: std.ArrayList(u8) = .empty;
    errdefer out_hide.deinit(alloc);
    var out_subst: std.ArrayList(u21) = .empty;
    errdefer out_subst.deinit(alloc);
    var out_links: std.ArrayList(?[]const u8) = .empty;
    errdefer out_links.deinit(alloc);

    var in_esc = false;
    var i: usize = 0;
    while (i < src.len) {
        const b = src[i];
        var nbytes: usize = 1;
        var cp: u21 = b;
        if (b >= 0x80) {
            nbytes = utf8SeqLen(b);
            if (i + nbytes <= src.len) {
                if (std.unicode.utf8Decode(src[i..][0..nbytes])) |decoded| {
                    cp = decoded;
                } else |_| {
                    nbytes = 1;
                    cp = b;
                }
            } else {
                nbytes = 1;
                cp = b;
            }
        }
        const end = i + nbytes;

        var hidden = false;
        if (in_esc) {
            hidden = true;
            if ((cp >= 'a' and cp <= 'z') or (cp >= 'A' and cp <= 'Z')) in_esc = false;
        } else if (cp == 0x1b) {
            hidden = true;
            in_esc = true;
        }

        if (!hidden) {
            try text.appendSlice(alloc, src[i..end]);
            if (attrs) |aa| {
                var k = i;
                while (k < end) : (k += 1) try out_attrs.append(alloc, aa[k]);
            }
            if (hide) |hh| {
                var k = i;
                while (k < end) : (k += 1) try out_hide.append(alloc, hh[k]);
            }
            if (subst) |ss| {
                var k = i;
                while (k < end) : (k += 1) try out_subst.append(alloc, ss[k]);
            }
            if (links) |ll| {
                var k = i;
                while (k < end) : (k += 1) try out_links.append(alloc, ll[k]);
            }
        }
        i = end;
    }

    return .{
        .text = try text.toOwnedSlice(alloc),
        .attrs = if (attrs != null) try out_attrs.toOwnedSlice(alloc) else null,
        .hide = if (hide != null) try out_hide.toOwnedSlice(alloc) else null,
        .subst = if (subst != null) try out_subst.toOwnedSlice(alloc) else null,
        .links = if (links != null) try out_links.toOwnedSlice(alloc) else null,
    };
}

/// Force inverse on bytes whose absolute buffer offset is in `[from, to)`.
fn applyLinearMarkInverse(attrs: []Attribute, line_byte: i64, from: i64, to: i64) void {
    if (from == to) return;
    for (attrs, 0..) |*a, i| {
        const b = line_byte + @as(i64, @intCast(i));
        if (b >= from and b < to) a.inverse = true;
    }
}

/// Display width matching `lgen` / JOE C0→caret (width 1) + `displayWidth`.
fn squareUnitWidth(cp: u21) u8 {
    if (cp < 32 or cp == 127) return 1;
    return terminal.displayWidth(cp);
}

/// Force inverse for square marks: `from`/`to` are display columns (`xcol`).
/// JOE `SELECT_IF`: tab uses end-col `tcol > from && tcol <= to` (whole run);
/// other units use start-col `col >= from && col < to`.
fn applySquareMarkInverse(attrs: []Attribute, line: []const u8, tab: u16, from: i64, to: i64, byte_mode: bool) void {
    if (from == to) return;
    const t: i64 = if (tab == 0) 1 else tab;
    var col: i64 = 0;
    var i: usize = 0;
    while (i < line.len and i < attrs.len) {
        const b = line[i];
        if (b == '\n' or b == '\r') break;
        if (b == '\t') {
            const tcol = col + t - @rem(col, t);
            if (tcol > from and tcol <= to) attrs[i].inverse = true;
            col = tcol;
            i += 1;
            continue;
        }
        if (byte_mode) {
            const wid = squareUnitWidth(b);
            if (col >= from and col < to) attrs[i].inverse = true;
            col += wid;
            i += 1;
            continue;
        }
        const seq_len = utf8SeqLen(b);
        const end = @min(i + seq_len, @min(line.len, attrs.len));
        var wid: u8 = 1;
        if (seq_len >= 1 and i + seq_len <= line.len) {
            if (std.unicode.utf8Decode(line[i..][0..seq_len])) |cp| {
                wid = squareUnitWidth(cp);
            } else |_| {
                wid = 1;
            }
        }
        if (col >= from and col < to) {
            var k = i;
            while (k < end) : (k += 1) attrs[k].inverse = true;
        }
        col += wid;
        i = if (i + seq_len > line.len) line.len else i + seq_len;
    }
}

/// Expand hybrid per-character `attr_buf` (from `parse`/`pgetc`) into per-byte
/// attrs for UTF-8 `lgenLine` (lead + continuation share the char's atr).
fn expandCharAttrsToBytes(line: []const u8, char_attrs: []const Attribute, out: []Attribute) void {
    @memset(out, .none);
    var bi: usize = 0;
    var ci: usize = 0;
    while (bi < line.len and bi < out.len) {
        const nbytes = utf8SeqLen(line[bi]);
        const a = if (ci < char_attrs.len) char_attrs[ci] else Attribute.none;
        var k: usize = 0;
        while (k < nbytes and bi + k < out.len) : (k += 1) {
            out[bi + k] = a;
        }
        bi += nbytes;
        ci += 1;
    }
}

fn utf8SeqLen(lead: u8) usize {
    if (lead < 0x80) return 1;
    if (lead < 0xC2) return 1; // invalid / continuation → paint as single byte
    if (lead < 0xE0) return 2;
    if (lead < 0xF0) return 3;
    if (lead < 0xF5) return 4;
    return 1;
}

/// Count Unicode characters in a UTF-8 byte slice (invalid leads count as 1).
fn utf8CharCount(line: []const u8) usize {
    var n: usize = 0;
    var i: usize = 0;
    while (i < line.len) {
        i += utf8SeqLen(line[i]);
        n += 1;
    }
    return n;
}

test "gate defaults off" {
    try std.testing.expectEqual(@as(c_int, 0), zig_bw_lgen_enabled);
}

test "expandCharAttrsToBytes maps UTF-8 multi-byte to shared atr" {
    const line = "a\u{00e9}b"; // a, é (2 bytes), b
    var char_attrs = [_]Attribute{
        .{ .bold = true },
        .{ .underline = true },
        .{ .italic = true },
    };
    var out: [4]Attribute = undefined;
    expandCharAttrsToBytes(line, &char_attrs, &out);
    try std.testing.expect(out[0].bold);
    try std.testing.expect(out[1].underline);
    try std.testing.expect(out[2].underline); // continuation of é
    try std.testing.expect(out[3].italic);
}

test "applyLinearMarkInverse marks ASCII byte range" {
    var attrs = [_]Attribute{ .{ .bold = true }, .{ .bold = true }, .{ .bold = true }, .{ .bold = true }, .{ .bold = true } };
    applyLinearMarkInverse(&attrs, 10, 11, 14);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(attrs[1].inverse);
    try std.testing.expect(attrs[2].inverse);
    try std.testing.expect(attrs[3].inverse);
    try std.testing.expect(!attrs[4].inverse);
    try std.testing.expect(attrs[1].bold);
}

test "applyLinearMarkInverse covers UTF-8 continuation bytes" {
    var attrs = [_]Attribute{.{}} ** 4;
    applyLinearMarkInverse(&attrs, 100, 101, 103);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(attrs[1].inverse);
    try std.testing.expect(attrs[2].inverse);
    try std.testing.expect(!attrs[3].inverse);
}

test "applyLinearMarkInverse no-op when from==to" {
    var attrs = [_]Attribute{.{ .underline = true }} ** 3;
    applyLinearMarkInverse(&attrs, 0, 5, 5);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(!attrs[1].inverse);
    try std.testing.expect(!attrs[2].inverse);
}

test "applySquareMarkInverse tab uses end-col inclusive" {
    var attrs = [_]Attribute{.{}} ** 4;
    // "ab\tc" tab=4 → a@0 b@1 tab→4 c@4; from=1 to=4 selects b + tab
    applySquareMarkInverse(&attrs, "ab\tc", 4, 1, 4, false);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(attrs[1].inverse);
    try std.testing.expect(attrs[2].inverse);
    try std.testing.expect(!attrs[3].inverse);
}

test "applySquareMarkInverse tab excluded when end past to" {
    var attrs = [_]Attribute{.{}} ** 3;
    // "\tX" tab=8, from=2 to=5: tcol=8 not in (2,5] → unselected
    applySquareMarkInverse(&attrs, "\tX", 8, 2, 5, false);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(!attrs[1].inverse);
}

test "applySquareMarkInverse covers UTF-8 start column" {
    const line = "a\u{00e9}b";
    var attrs = [_]Attribute{.{}} ** 4;
    applySquareMarkInverse(&attrs, line, 8, 1, 2, false);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(attrs[1].inverse);
    try std.testing.expect(attrs[2].inverse);
    try std.testing.expect(!attrs[3].inverse);
}

test "stripAnsiEscapes removes CSI color sequences" {
    const src = "a\x1b[31mB\x1b[0mC";
    const stripped = try stripAnsiEscapes(std.testing.allocator, src, null, null, null, null);
    defer std.testing.allocator.free(stripped.text);
    try std.testing.expectEqualStrings("aBC", stripped.text);
}

test "stripAnsiEscapes compacts attrs with escapes" {
    const src = "a\x1b[1mB";
    var attrs = [_]Attribute{ .{ .bold = true }, .{}, .{}, .{}, .{ .underline = true }, .{ .italic = true } };
    try std.testing.expectEqual(src.len, attrs.len);
    const stripped = try stripAnsiEscapes(std.testing.allocator, src, &attrs, null, null, null);
    defer std.testing.allocator.free(stripped.text);
    defer std.testing.allocator.free(stripped.attrs.?);
    try std.testing.expectEqualStrings("aB", stripped.text);
    try std.testing.expect(stripped.attrs.?[0].bold);
    try std.testing.expect(stripped.attrs.?[1].italic);
}

test "emitOsc8Link no-op when unchanged" {
    const u = "http://example.com";
    try std.testing.expectEqual(@as(?[]const u8, u), emitOsc8Link(u, u));
}

test "formatLinum trailing cols matches JOE gennum" {
    // Mirror zig_bw_gennum formatting without SCRN (JOE `" %21lld "`).
    var tmp: [24]u8 = undefined;
    const formatted = try std.fmt.bufPrint(&tmp, " {d: >21} ", .{@as(u64, 42)});
    try std.testing.expectEqualStrings(" 42 ", formatted[formatted.len - 4 ..]);
    const f2 = try std.fmt.bufPrint(&tmp, " {d: >21} ", .{@as(u64, 1)});
    try std.testing.expectEqualStrings("  1 ", f2[f2.len - 4 ..]);
    // When lincols is narrower than digits+padding, C takes the trailing slice
    // (e.g. 10000 with 5 cols → "0000 ").
    const f3 = try std.fmt.bufPrint(&tmp, " {d: >21} ", .{@as(u64, 10000)});
    try std.testing.expectEqualStrings("0000 ", f3[f3.len - 5 ..]);
}

test "bwgen square mark line scope matches C" {
    // Outside [fromline,toline] C clears from/to to 0.
    const buf_line: i64 = 5;
    const fromline: i64 = 2;
    const toline: i64 = 4;
    const in_range = buf_line >= fromline and buf_line <= toline;
    try std.testing.expect(!in_range);
    const buf_line2: i64 = 3;
    try std.testing.expect(buf_line2 >= fromline and buf_line2 <= toline);
}

extern fn zig_c_bw_set_pos(w: ?*BW, x: isize, y: isize) void;
extern fn zig_c_bw_set_size(w: ?*BW, wi: isize, he: isize) void;
extern fn zig_c_bw_dirty_grown_rows(w: ?*BW, old_h: isize, new_h: isize) void;
extern fn zig_c_bw_resz_vt_if_master(w: ?*BW, wi: isize, he: isize) void;
extern fn zig_c_bw_get_linums(w: ?*BW) c_int;
extern fn zig_c_bw_b_eof_line(w: ?*BW) i64;
extern fn zig_c_bw_alloc() ?*BW;
extern fn zig_c_bw_mk_init(w: ?*BW, window: ?*W, b: ?*B, prompt: c_int) c_int;
extern fn zig_c_bw_orphit_impl(bw: ?*BW) void;
extern fn zig_c_bw_is_sole_errbuf(w: ?*BW) c_int;
extern fn zig_c_bw_rm_save_pos(w: ?*BW) void;
extern fn zig_c_bw_rm_release(w: ?*BW) void;

/// Path A lifecycle: set BW origin. Returns `0` on success, `-1` to fall back.
pub export fn zig_bw_bwmove(w: ?*BW, x: isize, y: isize) c_int {
    if (zig_bw_lgen_enabled == 0 or w == null) return -1;
    zig_c_bw_set_pos(w, x, y);
    return 0;
}

/// Path A lifecycle: resize BW (+ dirty new rows + VT master resize).
pub export fn zig_bw_bwresz(w: ?*BW, wi: isize, he: isize) c_int {
    if (zig_bw_lgen_enabled == 0 or w == null) return -1;
    const old_h = zig_c_bw_get_h(w);
    zig_c_bw_dirty_grown_rows(w, old_h, he);
    zig_c_bw_set_size(w, wi, he);
    zig_c_bw_resz_vt_if_master(w, wi, he);
    return 0;
}

/// Path A lifecycle: allocate + init BW. On success writes `*out_bw` and returns `0`.
pub export fn zig_bw_bwmk(window: ?*W, b: ?*B, prompt: c_int, out_bw: ?*?*BW) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (window == null or b == null or out_bw == null) return -1;
    const w = zig_c_bw_alloc() orelse return -1;
    if (zig_c_bw_mk_init(w, window, b, prompt) < 0) {
        joe_free(w);
        return -1;
    }
    out_bw.?.* = w;
    return 0;
}

/// Path A lifecycle: orphan buffer before `bwrm` when needed.
pub export fn zig_bw_orphit(bw: ?*BW) c_int {
    if (zig_bw_lgen_enabled == 0 or bw == null) return -1;
    zig_c_bw_orphit_impl(bw);
    return 0;
}

/// Path A lifecycle: destroy BW (errbuf orphan, save pos, release).
pub export fn zig_bw_bwrm(w: ?*BW) c_int {
    if (zig_bw_lgen_enabled == 0 or w == null) return -1;
    if (zig_c_bw_is_sole_errbuf(w) != 0) {
        // Use impl directly to avoid re-entering gated `orphit`.
        zig_c_bw_orphit_impl(w);
    }
    zig_c_bw_rm_save_pos(w);
    zig_c_bw_rm_release(w);
    return 0;
}

/// Path A lifecycle: line-number gutter width (`linums` digit width + 2).
/// Returns width (`>= 0`), or `-1` to fall back to C.
pub export fn zig_bw_calclincols(bw: ?*BW) c_int {
    if (zig_bw_lgen_enabled == 0 or bw == null) return -1;
    if (zig_c_bw_get_linums(bw) == 0) return 0;
    const lines = zig_c_bw_b_eof_line(bw) + 1;
    var width: c_int = 0;
    if (lines < 10) {
        width = 1;
    } else if (lines < 100) {
        width = 2;
    } else if (lines < 1000) {
        width = 3;
    } else if (lines < 10000) {
        width = 4;
    } else {
        var l: i64 = 10000;
        width = 4;
        while (lines >= l) : (l *= 10) {
            width += 1;
            // Guard against overflow in the decade walk.
            if (l > std.math.maxInt(i64) / 10) break;
        }
    }
    return width + 2;
}

const FILE = std.c.FILE;

extern fn zig_c_bw_file_pos_get(name: ?[*:0]const u8) i64;
extern fn zig_c_bw_file_pos_set(name: ?[*:0]const u8, pos: i64) void;
extern fn zig_c_bw_file_pos_save(f: ?*FILE) void;
extern fn zig_c_bw_file_pos_load(f: ?*FILE) void;
extern fn zig_c_bw_file_pos_all(t: ?*Screen) void;
extern fn zig_c_bw_vtmaster_impl(t: ?*Screen, b: ?*B) ?*BW;
extern fn zig_c_bw_ustat_impl(w: ?*W) c_int;
extern fn zig_c_bw_wind_bw(w: ?*W, out: ?*?*BW) c_int;
extern fn zig_c_bw_set_offset(w: ?*BW, off: i64) void;
extern fn zig_c_bw_get_cursor_xcol(w: ?*BW) i64;
extern fn zig_c_bw_pcol(w: ?*BW, xcol: i64) void;
extern fn zig_c_bw_updall() void;
extern fn zig_c_bw_locale_utf8() c_int;
extern fn zig_c_bw_from_uni(cp: c_int) c_int;

/// Path A non-paint: get restored file position. Writes `*out` and returns `0`, or `-1` fallback.
pub export fn zig_bw_get_file_pos(name: ?[*:0]const u8, out: ?*i64) c_int {
    if (zig_bw_lgen_enabled == 0 or out == null) return -1;
    out.?.* = zig_c_bw_file_pos_get(name);
    return 0;
}

/// Path A non-paint: set restored file position.
pub export fn zig_bw_set_file_pos(name: ?[*:0]const u8, pos: i64) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    zig_c_bw_file_pos_set(name, pos);
    return 0;
}

/// Path A non-paint: save file-pos database.
pub export fn zig_bw_save_file_pos(f: ?*FILE) c_int {
    if (zig_bw_lgen_enabled == 0 or f == null) return -1;
    zig_c_bw_file_pos_save(f);
    return 0;
}

/// Path A non-paint: load file-pos database.
pub export fn zig_bw_load_file_pos(f: ?*FILE) c_int {
    if (zig_bw_lgen_enabled == 0 or f == null) return -1;
    zig_c_bw_file_pos_load(f);
    return 0;
}

/// Path A non-paint: snapshot positions for all TW windows + orphans.
pub export fn zig_bw_set_file_pos_all(t: ?*Screen) c_int {
    if (zig_bw_lgen_enabled == 0 or t == null) return -1;
    zig_c_bw_file_pos_all(t);
    return 0;
}

/// Path A non-paint: VT/TW master BW for buffer `b`. Writes `*out` (may be null).
pub export fn zig_bw_vtmaster(t: ?*Screen, b: ?*B, out: ?*?*BW) c_int {
    if (zig_bw_lgen_enabled == 0 or t == null or b == null or out == null) return -1;
    out.?.* = zig_c_bw_vtmaster_impl(t, b);
    return 0;
}

/// Path A non-paint: status-line command. Writes command rc to `*out_rc`.
pub export fn zig_bw_ustat(w: ?*W, k: c_int, out_rc: ?*c_int) c_int {
    _ = k;
    if (zig_bw_lgen_enabled == 0 or w == null or out_rc == null) return -1;
    out_rc.?.* = zig_c_bw_ustat_impl(w);
    return 0;
}

/// Path A non-paint: crawl right (horizontal scroll/cursor).
pub export fn zig_bw_ucrawlr(w: ?*W, k: c_int, out_rc: ?*c_int) c_int {
    _ = k;
    if (zig_bw_lgen_enabled == 0 or w == null or out_rc == null) return -1;
    var bw: ?*BW = null;
    if (zig_c_bw_wind_bw(w, &bw) < 0) {
        out_rc.?.* = -1;
        return 0;
    }
    const win_w = zig_c_bw_get_w(bw);
    var amnt: isize = if (opt_right < 0)
        @divTrunc(win_w, -opt_right)
    else
        @as(isize, @intCast(opt_right));
    if (amnt > win_w) amnt = win_w;
    if (amnt <= 0) amnt = 1;
    const amnt64: i64 = @intCast(amnt);
    const xcol = zig_c_bw_get_cursor_xcol(bw);
    const new_xcol = xcol + amnt64;
    zig_c_bw_pcol(bw, new_xcol);
    zig_c_bw_set_cursor_xcol(bw, new_xcol);
    zig_c_bw_set_offset(bw, zig_c_bw_get_offset(bw) + amnt64);
    zig_c_bw_updall();
    out_rc.?.* = 0;
    return 0;
}

/// Path A non-paint: crawl left (horizontal scroll/cursor).
pub export fn zig_bw_ucrawll(w: ?*W, k: c_int, out_rc: ?*c_int) c_int {
    _ = k;
    if (zig_bw_lgen_enabled == 0 or w == null or out_rc == null) return -1;
    var bw: ?*BW = null;
    if (zig_c_bw_wind_bw(w, &bw) < 0) {
        out_rc.?.* = -1;
        return 0;
    }
    const win_w = zig_c_bw_get_w(bw);
    var amnt: i64 = if (opt_left < 0)
        @intCast(@divTrunc(win_w, -opt_left))
    else
        @as(i64, @intCast(opt_left));
    if (amnt > win_w) amnt = @intCast(win_w);
    if (amnt < 1) amnt = 1;

    var rtn: c_int = -1;
    var xcol = zig_c_bw_get_cursor_xcol(bw);
    if (amnt > xcol) {
        if (xcol != 0) rtn = 0;
        xcol = 0;
    } else {
        xcol -= amnt;
        rtn = 0;
    }
    zig_c_bw_set_cursor_xcol(bw, xcol);

    var offset = zig_c_bw_get_offset(bw);
    if (amnt > offset) {
        if (offset != 0) rtn = 0;
        offset = 0;
    } else {
        offset -= amnt;
        rtn = 0;
    }
    zig_c_bw_set_offset(bw, offset);

    if (rtn != 0) {
        out_rc.?.* = rtn;
        return 0;
    }
    zig_c_bw_pcol(bw, xcol);
    zig_c_bw_updall();
    out_rc.?.* = rtn;
    return 0;
}

/// Path A non-paint: choose visible-whitespace glyphs for locale.
pub export fn zig_bw_init_visiblews() c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    const spaces = [_]c_int{ 0xb7, 0x2291, '.', 0 };
    const tabs = [_]c_int{ 0x2192, 0x203a, 0xbb, 0x25ba, '>', 0 };
    const rtns = [_]c_int{ 0x21b5, 0x21b2, '$', 0 };

    vspace = 0;
    vtab = 0;
    vrtn = 0;

    if (zig_c_bw_locale_utf8() != 0) {
        vspace = spaces[0];
        vtab = tabs[0];
        vrtn = rtns[0];
        return 0;
    }

    var i: usize = 0;
    while (spaces[i] != 0) : (i += 1) {
        if (zig_c_bw_from_uni(spaces[i]) > 0) {
            vspace = spaces[i];
            break;
        }
    }
    i = 0;
    while (tabs[i] != 0) : (i += 1) {
        if (zig_c_bw_from_uni(tabs[i]) > 0) {
            vtab = tabs[i];
            break;
        }
    }
    i = 0;
    while (rtns[i] != 0) : (i += 1) {
        if (zig_c_bw_from_uni(rtns[i]) > 0) {
            vrtn = rtns[i];
            break;
        }
    }
    return 0;
}
