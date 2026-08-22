//! Always-on live bridge + JOE `bw.h` C ABI exports.
//! Gated live bridge: JOE `lgen_core` / Feature 2.2 table rows / `gennum` → Zig paint.
//!
//! Path A is always on: plain buffer lines
//! (including linear/square mark inverse + viewmode hide/substitute/link tables +
//! `-visiblews` glyphs + `-ansi` ESC hiding) paint through the Phase 6 renderer
//! and emit via hybrid `outatr` (works with screen-swap shadow + classic tty
//! path). Feature 2.2 padded table rows use `zig_bw_table_row` → `render.table.paintRow`
//! with widths/aligns from Path A detect or C. Line-number gutters use
//! `zig_bw_gennum` (JOE `" %21lld "` trailing `lincols`; past-EOF blanks).
//! Window paint loops use `zig_bw_bwgen` (Zig `bwGetto` + C `lgen`/`gennum`
//! bridges for body/gutter).
//! Thin `bwgen` entry uses `zig_bw_bwgen_entry` (lattr/viewmode/mark setup + loops +
//! Feature 1.10 cursor; Zig-owned mark setup via thin C field accessors).
//! Hex dump paint uses `zig_bw_bwgenh` (loop calls C `genfield`).
//! Thin `bwgenh` entry uses `zig_bw_bwgenh_entry` (Zig-owned mark setup + hex paint).
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
//! paint cleanup; Zig owns viewmode static storage via
//! `zig_bw_vm_*` prepare/getters/after/cleanup/display_col; C Feature fallback
//! body + C Feature/col_map bridges removed; Path A
//! `-1`; `defatr` computed in Zig; dead prepare/hide/subst/urls/table/after
//! bridges removed).
//! Lifecycle uses `zig_bw_bwmove` / `zig_bw_bwresz` / `zig_bw_bwmk` / `zig_bw_bwrm` /
//! `zig_bw_orphit` / `zig_bw_calclincols` (Zig-owned `bwMkInit`/`bwOrphit`/`bwrm`; thin wrappers abort on `-1`).
//! Non-paint helpers use `zig_bw_get_file_pos` / `zig_bw_set_file_pos` /
//! `zig_bw_save_file_pos` / `zig_bw_load_file_pos` / `zig_bw_set_file_pos_all` /
//! `zig_bw_vtmaster` / `zig_bw_ustat` / `zig_bw_ucrawlr` / `zig_bw_ucrawll` /
//! `zig_bw_init_visiblews` (Zig-owned file_pos LRU + TW walk/`vtmaster`/`ustat`/`windBw` + typed BW/W/P/SCRN accessors + resize + P-nav/lattr helpers; orphans via `set_file_pos_orphaned`).
//! Feature 2.1 residual simple pipe substitute uses `zig_bw_table_simple`.
//! Non-UTF-8 (byte) charmaps paint via `lgenLine` byte-mode.
//! Thin C wrappers abort when a Zig export returns `-1` (OOM / oversize / hard fail).
//!
//! Hybrid `syntax.parse` fills `attr_buf` **per character** (`pgetc`); native
//! `lgenLine` expects **per-byte** attrs — this bridge expands before paint.
//! `ansi_parse` temporarily clears `o.ansi`, so ESC bytes stay as normal chars
//! in `attr_buf`; Path A strips JOE `ansi_decode` spans (ESC…letter) after
//! attr/mark apply so colors stay aligned. When `viewmode!=0`, Zig `bwLgenView`/`lgen_view`
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
/// Same heading-color choice as `table.zig`'s `header_fg` and the Cursor
/// Dark scheme's `nord_blue` role — indexed cyan, in this codebase's
/// basic viewmode-only attribute-overlay convention (independent of the
/// `.jcf`/DFA class system).
const FG_CYAN: c_int = FG_NOT_DEFAULT | (6 << FG_SHIFT);

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
    type: c_int = 0,
};
const HighSyntax = opaque {};

const HighlightState = extern struct {
    stack: ?*anyopaque = null,
    delim_stack: ?*anyopaque = null,
    saved_s: ?*const c_int = null,
    state: isize = 0,
};

extern var attr_buf: [*c]c_int;
extern var attr_size: c_int;
export var vwsatr: c_int = DIM;
export var vspace: c_int = 0;
export var vtab: c_int = 0;
export var vrtn: c_int = 0;
export var selectatr: c_int = INVERSE;
export var selectmask: c_int = ~INVERSE;
export var vwsmask: c_int = ~(DIM | FG_MASK);
export var dspasis: c_int = 0;

extern fn parse(syntax: ?*HighSyntax, line: ?*P, h_state: HighlightState, charmap: ?*Charmap) HighlightState;
extern fn load_syntax(name: [*c]const u8) ?*HighSyntax;
extern fn find_state(syntax: ?*HighSyntax, name: [*c]u8) ?*anyopaque;
extern fn pdup(p: ?*P, tr: [*:0]const u8) ?*P;
extern fn pdupown(p: ?*P, owner: ?*?*P, tr: [*:0]const u8) ?*P;
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
/// Read buffer line into `buf` (no newline). Returns len, -2 if too long, -1 on error/EOF-past.
/// Matches C `zig_c_bw_read_line` / `VIEWMODE_TABLE_SCAN_MAX_BYTES` (16KiB) hard cap.
fn bwReadLine(anchor: ?*P, line: i64, buf: ?[*]u8, buf_cap: c_int) c_int {
    const scan_max: c_int = 16 * 1024;
    if (anchor == null or buf == null or buf_cap <= 0 or line < 0) return -1;
    const eof = zig_c_bw_eof_line(anchor);
    if (eof < 0 or line > eof) return -1;
    const tmp = pdup(anchor, "zig_c_bw_read_line") orelse return -1;
    defer prm(tmp);
    zig_c_bw_pline(tmp, line);
    zig_c_bw_p_goto_bol(tmp);
    var ll: c_int = 0;
    while (true) {
        const ch = pgetb(tmp);
        if (ch == NO_MORE_DATA or ch == '\n') break;
        if (ll >= scan_max or ll >= buf_cap) return -2;
        buf.?[@intCast(ll)] = @intCast(ch);
        ll += 1;
    }
    return ll;
}

/// Read one line from `p`'s *current* position (must already be at a
/// line's bol) without reseeking, then leave `p` positioned at the next
/// line's bol (`pgetb`'s own `\n` handling already does that — see
/// `pgetb_` in `gapbuffer/pointer.zig`). Used by sequential multi-line
/// scans (`zig_bw_fence_detect`) so a whole window can be walked with one
/// `pdup`/`pline` seek instead of `bwReadLine`'s reseek-per-line, which
/// made those scans cost O(window²) instead of O(window). Unlike
/// `bwReadLine`, a too-long line is still drained to its `\n` (bytes past
/// `buf_cap` are discarded, not just abandoned) before returning `-2`, so
/// the shared `p` stays correctly aligned with line boundaries for the
/// next call — `bwReadLine` can skip that because its `p` is a throwaway
/// duplicate discarded after one read.
fn readLineFromCurrent(p: ?*P, buf: ?[*]u8, buf_cap: c_int) c_int {
    const scan_max: c_int = 16 * 1024;
    var ll: c_int = 0;
    var truncated = false;
    while (true) {
        const ch = pgetb(p);
        if (ch == NO_MORE_DATA or ch == '\n') break;
        if (ll >= scan_max or ll >= buf_cap) {
            truncated = true;
            continue;
        }
        buf.?[@intCast(ll)] = @intCast(ch);
        ll += 1;
    }
    return if (truncated) -2 else ll;
}
export var opt_mid: c_int = 0;
export var opt_left: c_int = 8;
export var opt_right: c_int = 8;

/// Seek a `P` to bol of `line`.
///
/// Paint walks top→bottom, so the cheap path is `pdup(top)` then `pnextl`.
/// `pline` from `bof` is only the fallback (wrong `top.line`, or a backward
/// gap). Do not `pprevl` from cursor after an insert: that can match `p.line`
/// at the wrong byte and paint the same text on many rows.
fn bwGetto(p_in: ?*P, cur: ?*P, top: ?*P, line: i64) ?*P {
    _ = cur;
    if (p_in == null) {
        const top_p = top orelse return null;
        const p = pdup(top_p, "getto") orelse return null;
        if (zig_c_bw_pline_no(p) == line) {
            zig_c_bw_p_goto_bol(p);
            return p;
        }
        if (line > zig_c_bw_pline_no(p)) {
            while (line > zig_c_bw_pline_no(p)) {
                if (pnextl(p) == null) break;
            }
            if (zig_c_bw_pline_no(p) == line) return p;
        }
        prm(p);
        const origin = zig_c_bw_bof(top) orelse top_p;
        const fresh = pdup(origin, "getto") orelse return null;
        zig_c_bw_pline(fresh, line);
        return fresh;
    }
    const pp = p_in orelse return null;
    while (line > zig_c_bw_pline_no(pp)) {
        if (pnextl(pp) == null) break;
    }
    if (zig_c_bw_pline_no(pp) != line) {
        prm(pp);
        const origin = zig_c_bw_bof(top) orelse (top orelse return null);
        const fresh = pdup(origin, "getto") orelse return null;
        zig_c_bw_pline(fresh, line);
        return fresh;
    }
    return pp;
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

    // Single pdup + one pline seek to back_lim, then sequential pgetb reads
    // only (readLineFromCurrent) — not a fresh pdup+pline reseek per probed
    // line like the old bwReadLine-per-li loop, which made this O(window²)
    // (same class of bug fixed in zig_bw_fence_detect above; this window is
    // even larger — up to 250 lines — so it's the more expensive of the two
    // in practice).
    const scan_p = pdup(anchor, "zig_bw_table_detect_scan") orelse return -1;
    defer prm(scan_p);
    zig_c_bw_pline(scan_p, back_lim);
    zig_c_bw_p_goto_bol(scan_p);

    var li: i64 = back_lim;
    while (li <= fwd_lim) : (li += 1) {
        var tmp: [16 * 1024]u8 = undefined;
        const rc = readLineFromCurrent(scan_p, &tmp, @intCast(tmp.len));
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

const FenceOpen = struct { start: usize, len: usize, ch: u8 };

/// Match a fence delimiter line: leading spaces/tabs, then a run of `>=3`
/// identical backtick/tilde characters (same leading-ws rule as
/// `render.analyzeLineStart` Feature 1.5 — no CommonMark 0-3-space cap).
fn matchFenceOpen(line: []const u8) ?FenceOpen {
    var i: usize = 0;
    while (i < line.len and (line[i] == ' ' or line[i] == '\t')) : (i += 1) {}
    if (i >= line.len) return null;
    const ch = line[i];
    if (ch != '`' and ch != '~') return null;
    var j = i;
    while (j < line.len and line[j] == ch) : (j += 1) {}
    const run = j - i;
    if (run < 3) return null;
    return .{ .start = i, .len = run, .ch = ch };
}

/// True when `line` closes a fence opened with `open_ch`/`open_len`: same
/// character, run length `>=` opening length, nothing but trailing
/// whitespace after the run (CommonMark closing-fence rule). A fence
/// delimiter of the *other* character never closes it — the mismatched
/// marker is body text, not a close.
fn matchFenceClose(line: []const u8, open_ch: u8, open_len: usize) bool {
    const m = matchFenceOpen(line) orelse return false;
    if (m.ch != open_ch or m.len < open_len) return false;
    var k = m.start + m.len;
    while (k < line.len) : (k += 1) {
        if (line[k] != ' ' and line[k] != '\t') return false;
    }
    return true;
}

/// One open/close state transition for a single line — the same shape as
/// `zig_bw_fence_detect`'s scan loop body, factored out so
/// `zig_bw_lgen_view`'s forward-adjacency fast path can step fence state
/// one line at a time (O(1) per step) instead of paying a full
/// `zig_bw_fence_detect` window rescan on every row of a top-to-bottom
/// repaint. `open_ch == 0` means "not currently inside a fence".
fn fenceStepLine(line: []const u8, open_ch: *u8, open_len: *usize, region_start: *i64, this_line: i64) void {
    if (open_ch.* == 0) {
        if (matchFenceOpen(line)) |m| {
            open_ch.* = m.ch;
            open_len.* = m.len;
            region_start.* = this_line;
        }
    } else if (matchFenceClose(line, open_ch.*, open_len.*)) {
        open_ch.* = 0;
        open_len.* = 0;
        region_start.* = -1;
    }
}

/// Bounded backward-then-forward scan window for fence-body detection, in
/// the same order of magnitude as the table detector's 50-back /
/// 199-forward window. Walked with a single `pdup`'d cursor + one `pline`
/// seek to `back_lim`, then sequential `pgetb` reads only (`readLineFromCurrent`)
/// — not a fresh reseek per probed line — so the scan is O(window), not
/// O(window²). (An earlier single-pass attempt, `readLineBytesAdvance`, was
/// reverted for corrupting an unrelated `P`'s state; that was an aliasing
/// bug in that implementation — it mutated a shared `P` — not a problem
/// with sequential scanning itself. `zig_bw_fence_detect` avoids it the
/// same way `bwReadLine` avoids clobbering callers: its own private,
/// `prm`'d-when-done `pdup`, just one for the whole scan instead of one per
/// probe.) Fences beyond this window in either direction are a documented
/// limitation (plan §4.2.1), not a correctness bug: body lines outside the
/// window fall back to being parsed as ordinary markdown, same as before
/// this feature existed.
const fence_scan_window_lines: i64 = 300;

/// `fence_region_end` sentinel meaning "still open as of `vm_fence_scan_line`,
/// real close not yet observed" — written only by `zig_bw_lgen_view`'s
/// forward-adjacency fast path (never by `zig_bw_fence_detect`, which always
/// resolves a real, bounded end). The plain membership check
/// (`buf_line >= region_start and buf_line < region_end`) must NOT trust
/// this sentinel for any `buf_line` beyond `vm_fence_scan_line` — unlike a
/// real resolved end, it says nothing about lines not yet stepped through,
/// so such a `buf_line` still needs its own fast-path step (or fallback).
const fence_region_end_open_sentinel: i64 = std.math.maxInt(i64);

/// Feature 4.2.1 fence-body region detect (plan R1). Simulates fence
/// open/close state **forward** from a bounded window before `buf_line`
/// (fences don't nest, but a body line that merely *looks* like a
/// different-type fence marker — e.g. a `~~~` line inside a ` ``` ` fence —
/// must not toggle state, so backward nearest-marker matching is not
/// sufficient; forward simulation from a known "not in fence" starting
/// assumption is).
///
/// `out_start`/`out_end` are `-1` when `buf_line` is not inside a fence body
/// (ordinary text, or is itself the opening/closing delimiter line — the
/// caller's existing single-line check handles delimiter lines directly).
/// `out_open_ch`/`out_open_len`, when non-null, are also filled with the
/// open fence's marker (`0`/`0` when not open) — lets a caller seed the
/// incremental forward-adjacency tracker (`vm_fence_scan_*` in
/// `zig_bw_lgen_view`) from a full-scan result without re-reading and
/// re-matching `fence_region_start`'s line itself.
/// Returns `0` always; Path A owns fence detection (no C fallback).
pub export fn zig_bw_fence_detect(
    anchor: ?*P,
    buf_line: i64,
    out_start: ?*i64,
    out_end: ?*i64,
    out_open_ch: ?*u8,
    out_open_len: ?*usize,
) c_int {
    if (anchor == null or out_start == null or out_end == null) return -1;
    if (buf_line < 0) return -1;

    const eof_line = zig_c_bw_eof_line(anchor);
    if (eof_line < 0 or buf_line > eof_line) {
        out_start.?.* = -1;
        out_end.?.* = -1;
        if (out_open_ch) |c| c.* = 0;
        if (out_open_len) |l| l.* = 0;
        return 0;
    }

    const back_lim: i64 = @max(@as(i64, 0), buf_line - fence_scan_window_lines);

    const scan_p = pdup(anchor, "zig_bw_fence_detect_scan") orelse return -1;
    defer prm(scan_p);
    zig_c_bw_pline(scan_p, back_lim);
    zig_c_bw_p_goto_bol(scan_p);

    var tmp: [16 * 1024]u8 = undefined;
    var open: ?FenceOpen = null;
    var region_start: i64 = -1;

    var li: i64 = back_lim;
    while (li < buf_line) : (li += 1) {
        const rc = readLineFromCurrent(scan_p, &tmp, @intCast(tmp.len));
        if (rc >= 0) {
            const slice = tmp[0..@intCast(rc)];
            if (open) |o| {
                if (matchFenceClose(slice, o.ch, o.len)) {
                    open = null;
                    region_start = -1;
                }
            } else if (matchFenceOpen(slice)) |m| {
                open = m;
                region_start = li;
            }
        }
        // rc < 0 (too long): not a fence delimiter, but readLineFromCurrent
        // still drained it to the next line's bol, so scan_p stays aligned.
    }

    if (open == null) {
        out_start.?.* = -1;
        out_end.?.* = -1;
        if (out_open_ch) |c| c.* = 0;
        if (out_open_len) |l| l.* = 0;
        return 0;
    }

    const o = open.?;
    if (out_open_ch) |c| c.* = o.ch;
    if (out_open_len) |l| l.* = o.len;
    const fwd_lim: i64 = @min(eof_line, buf_line + fence_scan_window_lines);
    // scan_p is already sitting at buf_line's bol here — the backward loop
    // above (0 or more iterations) always ends there — so the forward scan
    // continues on the same walking cursor with no extra seek.
    var lj: i64 = buf_line;
    while (lj <= fwd_lim) : (lj += 1) {
        const rc = readLineFromCurrent(scan_p, &tmp, @intCast(tmp.len));
        if (rc >= 0) {
            const slice = tmp[0..@intCast(rc)];
            if (matchFenceClose(slice, o.ch, o.len)) {
                out_start.?.* = region_start;
                out_end.?.* = lj + 1;
                return 0;
            }
        }
    }
    // Unterminated within the scan window: treat the remainder as body
    // through the window bound. Matches the table detector's precedent of
    // a bounded, not unbounded, scan.
    out_start.?.* = region_start;
    out_end.?.* = fwd_lim + 1;
    return 0;
}

/// Feature 2.5: markdown fence info-string language tag → JOE syntax name
/// (`syntax/<name>.jsf`). Only remaps tags that don't already match a
/// filename 1:1 (`python`, `c`, `rust`, `go`, ... fall through the `return
/// tag` default and load directly); unrecognized tags fall through to
/// `load_syntax` trying the raw tag, which safely returns null for
/// anything without a matching `.jsf` file (Feature 2.5.4's "unknown
/// language" fallback — no alias table entry needed for that case).
fn fenceSyntaxAlias(tag: []const u8) []const u8 {
    if (eqlIC(tag, "js") or eqlIC(tag, "javascript")) return "js";
    if (eqlIC(tag, "ts") or eqlIC(tag, "typescript")) return "typescript";
    if (eqlIC(tag, "py") or eqlIC(tag, "python")) return "python";
    if (eqlIC(tag, "rb") or eqlIC(tag, "ruby")) return "ruby";
    if (eqlIC(tag, "rs") or eqlIC(tag, "rust")) return "rust";
    if (eqlIC(tag, "sh") or eqlIC(tag, "bash") or eqlIC(tag, "shell") or eqlIC(tag, "zsh")) return "sh";
    if (eqlIC(tag, "cs") or eqlIC(tag, "csharp")) return "csharp";
    return tag;
}

fn eqlIC(a: []const u8, b: []const u8) bool {
    return std.ascii.eqlIgnoreCase(a, b);
}

/// Feature 2.5: extract the language tag from a fence's opening delimiter
/// line's info string — the first whitespace-delimited word after the
/// fence run (CommonMark; e.g. "python" from "```python", "```python
/// linenos", or "~~~ python").
fn fenceInfoLang(open_line: []const u8) ?[]const u8 {
    const m = matchFenceOpen(open_line) orelse return null;
    var i = m.start + m.len;
    while (i < open_line.len and (open_line[i] == ' ' or open_line[i] == '\t')) : (i += 1) {}
    const start = i;
    while (i < open_line.len and open_line[i] != ' ' and open_line[i] != '\t') : (i += 1) {}
    if (i == start) return null;
    return open_line[start..i];
}

/// Feature 2.5: re-parse `buf_line` (a fence body line) with the fence's
/// language syntax instead of `md`, overwriting the plain code-block tint
/// the caller's earlier `md.jsf` pass already left in the shared, aliased
/// `attr_buf` (see `zig_bw_lgen_view_entry`'s own `parse` call and its
/// comment on `attr_buf` — `parse` always starts writing at `attr_buf[0]`,
/// so a second call for the same line cleanly overwrites the first
/// call's results in place, no extra bookkeeping needed).
///
/// Single-line state only: each body line restarts from a fresh initial
/// state (`state = 0`, matching `lattr.zig`'s `clearState`) rather than
/// carrying state from the previous body line, so a construct spanning
/// multiple lines (a block comment, a triple-quoted string) may
/// mis-highlight mid-construct — a deliberate scope tradeoff, not an
/// oversight; see `plans/future-roadmap.md` Feature 2.5. No-op (existing
/// plain tint kept) when the language is unknown, has no matching
/// `syntax/<name>.jsf`, or the fence's opening line can't be read.
fn applyFenceSyntaxHighlight(
    anchor: ?*P,
    fence_open_line: i64,
    buf_line: i64,
    charmap: ?*Charmap,
) void {
    if (fence_open_line < 0) return;
    var tmp: [1024]u8 = undefined;
    const ll = bwReadLine(anchor, fence_open_line, &tmp, @intCast(tmp.len));
    if (ll < 0) return;
    const tag = fenceInfoLang(tmp[0..@intCast(ll)]) orelse return;
    if (tag.len == 0 or tag.len > 24) return;

    var lower: [24]u8 = undefined;
    for (tag, 0..) |c, i| lower[i] = std.ascii.toLower(c);
    const mapped = fenceSyntaxAlias(lower[0..tag.len]);

    var namebuf: [24:0]u8 = undefined;
    @memcpy(namebuf[0..mapped.len], mapped);
    namebuf[mapped.len] = 0;
    const foreign = load_syntax(&namebuf) orelse return;

    const scratch = pdup(anchor, "zig_bw_fence_syntax_hl") orelse return;
    defer prm(scratch);
    zig_c_bw_pline(scratch, buf_line);
    zig_c_bw_p_goto_bol(scratch);
    _ = parse(foreign, scratch, .{ .stack = null, .delim_stack = null, .saved_s = null, .state = 0 }, charmap);
}

test "matchFenceOpen recognizes backtick and tilde runs" {
    try std.testing.expect(matchFenceOpen("```") != null);
    try std.testing.expect(matchFenceOpen("```python") != null);
    try std.testing.expect(matchFenceOpen("~~~~") != null);
    try std.testing.expect(matchFenceOpen("  ```") != null);
    try std.testing.expect(matchFenceOpen("``") == null);
    try std.testing.expect(matchFenceOpen("plain text") == null);
}

test "matchFenceClose requires matching char and sufficient run length" {
    try std.testing.expect(matchFenceClose("```", '`', 3));
    try std.testing.expect(matchFenceClose("````", '`', 3)); // longer close OK
    try std.testing.expect(!matchFenceClose("``", '`', 3)); // shorter close: no
    try std.testing.expect(!matchFenceClose("~~~", '`', 3)); // wrong char: no
    try std.testing.expect(!matchFenceClose("``` trailing text", '`', 3)); // not bare
    try std.testing.expect(matchFenceClose("```   ", '`', 3)); // trailing ws OK
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
        const target: i64 = if (opt_mid != 0)
            if (cur_line >= @divTrunc(win_h, 2)) cur_line - @divTrunc(win_h, 2) else 0
        else
            cur_line;
        const origin = zig_c_bw_bof(top) orelse return -1;
        const newtop = pdup(origin, "zig_bw_bwfllwt") orelse return -1;
        zig_c_bw_pline(newtop, target);
        const delta = top_line - zig_c_bw_pline_no(newtop);
        if (delta > 0 and delta < win_h) {
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
        const origin = zig_c_bw_bof(top) orelse return -1;
        const newtop = pdup(origin, "zig_bw_bwfllwt") orelse return -1;
        zig_c_bw_pline(newtop, target);
        const delta = zig_c_bw_pline_no(newtop) - top_line;
        if (delta > 0 and delta < win_h) {
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

    // Do not call nscrldn/IL here. Scheduling hardware scroll before the next
    // paint leaves the physical screen showing pre-insert lines; follow/nscroll
    // then shifts that stale image (Ghostty: whole window out of place after
    // multi-line mouse paste). Just rewrite from the insert row downward.
    _ = sary;
    _ = li;
    _ = flg;
    _ = eof_line;
    if (l + n >= top_line and l < top_line + win_h) {
        const start_line = if (l < top_line) top_line else l;
        const start: isize = @intCast(start_line - top_line);
        zig_c_bw_msetI(updtab.? + @as(usize, @intCast(win_y + start)), 1, win_h - start);
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

/// Feature 6.2: does `line` match a setext heading underline,
/// `^(=+|-+)[ \t]*$`? Returns `1` for `=` (H1), `2` for `-` (H2), `0`
/// otherwise. A `-` run also matches Feature 1.8's thematic-break shape —
/// resolving that ambiguity (is this an HR, or a setext H2 underline?)
/// needs the *previous* line's content, which this pure, single-line
/// function deliberately doesn't have; see `isSetextUnderline` below.
fn setextUnderlineLevel(line: []const u8) u8 {
    if (line.len == 0) return 0;
    const ch = line[0];
    if (ch != '=' and ch != '-') return 0;
    var i: usize = 0;
    while (i < line.len and line[i] == ch) : (i += 1) {}
    while (i < line.len and (line[i] == ' ' or line[i] == '\t')) : (i += 1) {}
    if (i != line.len) return 0;
    return if (ch == '=') 1 else 2;
}

/// Feature 6.2: is `line` a plausible paragraph line for a setext
/// underline to apply to — non-blank, not itself 4+ columns indented
/// (indented code block), and not the start of a different block
/// construct (heading/blockquote/fence/list marker/table row/another
/// setext underline). Deliberately approximate, not a full CommonMark
/// block-start check — see plan TODO.md 6.2 for the reasoning on scope.
fn looksLikeSetextParagraph(line: []const u8) bool {
    var i: usize = 0;
    while (i < line.len and i < 4 and (line[i] == ' ' or line[i] == '\t')) : (i += 1) {}
    if (i >= line.len) return false; // blank
    if (i >= 4) return false; // indented code block
    const c = line[i];
    if (c == '#' or c == '>' or c == '`' or c == '~' or c == '|') return false;
    if ((c == '-' or c == '*' or c == '+') and i + 1 < line.len and
        (line[i + 1] == ' ' or line[i + 1] == '\t')) return false; // list marker
    if (setextUnderlineLevel(line) != 0) return false; // another underline
    return true;
}

/// Feature 6.2: is `bol_cursor` (positioned at the start of `buf_line`,
/// whose content is `line`) itself a setext underline for the line above?
/// Single bounded `bwReadLine` call for `buf_line - 1` — no scan window
/// needed (only ever looks at exactly one adjacent line, unlike fence
/// detection's bounded forward simulation).
fn isSetextUnderline(bol_cursor: ?*P, buf_line: i64, line: []const u8) bool {
    if (buf_line <= 0) return false;
    if (setextUnderlineLevel(line) == 0) return false;
    var tmp: [1024]u8 = undefined;
    const ll = bwReadLine(bol_cursor, buf_line - 1, &tmp, @intCast(tmp.len));
    if (ll < 0) return false;
    return looksLikeSetextParagraph(tmp[0..@intCast(ll)]);
}

/// Feature 6.2: is `buf_line` (content `line`) a setext heading *text*
/// line — is it a plausible paragraph, and is the line below it an
/// underline? Returns the level (1/2) or 0. Single bounded `bwReadLine`
/// call for `buf_line + 1`.
fn setextHeadingLevel(bol_cursor: ?*P, buf_line: i64, line: []const u8) u8 {
    if (!looksLikeSetextParagraph(line)) return 0;
    var tmp: [1024]u8 = undefined;
    const ll = bwReadLine(bol_cursor, buf_line + 1, &tmp, @intCast(tmp.len));
    if (ll < 0) return 0;
    return setextUnderlineLevel(tmp[0..@intCast(ll)]);
}

/// Feature 4.2.1(d) fix: is `buf_line` (content `line`) a *valid* indented
/// code block line — i.e., does walking backward from it reach a blank
/// line (or buffer start) while every line in between still looks like
/// indented code (`render.looksLikeIndentedCode`)? `render.analyzeLineStart`
/// is pure/single-line and can't answer this itself (see its doc comment);
/// this resolves the CommonMark rule it's missing: an indented code block
/// only *starts* right after a blank line, so an ordinarily-indented
/// list-item continuation line (aligned under its marker, not preceded by
/// a blank line) must NOT be treated as one — that misclassification was
/// dropping markdown processing (emphasis, etc.) for such lines entirely.
/// Bounded backward walk (`fence_scan_window_lines`, matching the fence
/// detector's precedent); a block whose start lies beyond that window
/// falls back to the old, permissive behavior (allowed) rather than being
/// misclassified as ordinary text — false positives here are rarer than
/// the continuation-line case this function exists to fix, and this is
/// the direction that was already correct before this fix, so the bounded
/// fallback doesn't introduce a *new* wrong case, only fails to fix an
/// already-rare, already-pre-existing edge case.
fn isIndentedCodeAllowed(anchor: ?*P, buf_line: i64, line: []const u8, tab: u16) bool {
    if (!render.looksLikeIndentedCode(line, tab)) return true; // shape check fails anyway; irrelevant
    if (buf_line <= 0) return true;

    var tmp: [1024]u8 = undefined;
    const back_lim: i64 = @max(0, buf_line - fence_scan_window_lines);
    var li: i64 = buf_line - 1;
    while (li >= back_lim) : (li -= 1) {
        const ll = bwReadLine(anchor, li, &tmp, @intCast(tmp.len));
        if (ll < 0) return true; // unreadable: don't newly misclassify, keep old behavior
        const prev = tmp[0..@intCast(ll)];
        if (prev.len == 0) return true; // blank line: valid region start
        if (!render.looksLikeIndentedCode(prev, tab)) return false; // non-blank, non-code: continuation of that line's block
        // prev also looks like indented code: keep walking back through the run
    }
    return true; // exceeded scan window: fall back to old, permissive behavior
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
    is_setext_underline: c_int,
    allow_indented_code: c_int,
) c_int {
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

    // Feature 6.2: a setext heading underline (`===`/`---` right after a
    // paragraph line) must not reach the normal dispatch below — in
    // particular Feature 1.8's thematic-break check, which a `---` line
    // would otherwise match (`===` doesn't collide with anything, but is
    // handled the same way for consistency). Leave it fully unconcealed
    // (hide/subst already zeroed above) and let the caller's inline pass
    // build col_map — nothing on a pure `=`/`-`/space line matches
    // emphasis/link/entity patterns, so that pass is a correctness no-op
    // here, just the thing that already owns building col_map for a
    // "not done" line.
    if (is_setext_underline != 0) return 0;

    var tables = ViewTables.init(alloc);
    tables.bindScratch(hide_slice, subst_scratch, url_scratch, col_scratch, n);

    const tab_u: u16 = if (tab <= 0) 8 else @intCast(tab);
    const done = render.analyzeLineStart(&tables, line, tab_u, allow_indented_code != 0);

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
    setext_heading_level: c_int,
) c_int {
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

    // Feature 6.2: setext heading text line — the whole line gets heading
    // styling (matching ATX: H1 bold+underline, H2 bold only), overriding
    // whatever the link-styling pass above set, same as ATX headings take
    // priority over inline styling within them. Applied here rather than
    // via the DFA/`md.jsf` class system (which has already run by the time
    // this executes, in a separate earlier pass) — same viewmode-only
    // attribute-overlay approach as link/table-header styling above.
    if (setext_heading_level != 0 and atr != null and atr_len > 0 and n > 0) {
        const alen: usize = @intCast(atr_len);
        var ai: usize = 0;
        while (ai < n and ai < alen) : (ai += 1) {
            atr.?[ai] |= BOLD;
            if (setext_heading_level == 1) atr.?[ai] |= UNDERLINE;
            atr.?[ai] = (atr.?[ai] & ~FG_MASK) | FG_CYAN;
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

/// Plan R5: given `off` is a hidden byte in `hide`, return the corrected
/// offset — forward-skip to the next visible byte if one exists before end
/// of line; otherwise backward-clamp to the last visible byte, or `0` if
/// the whole prefix through `off` is also hidden (a fully concealed line).
/// Returns `off` unchanged if it isn't hidden. Shared by the paint-time
/// fixup (`zig_bw_view_finish`) and the interactive one
/// (`zig_bw_viewmode_fixup_cursor`) so the two agree by construction.
fn clampHiddenOffset(hide: []const u8, off: usize) usize {
    if (off >= hide.len or hide[off] == 0) return off;
    var next: usize = off + 1;
    while (next < hide.len and hide[next] != 0) : (next += 1) {}
    if (next < hide.len) return next;
    var prev: i64 = @as(i64, @intCast(off)) - 1;
    while (prev >= 0 and hide[@intCast(prev)] != 0) : (prev -= 1) {}
    return if (prev >= 0) @intCast(prev) else 0;
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

    // Plan R5: cursor never rests on a concealed byte. This call site has
    // no movement-direction context (it runs at paint time, not from the
    // arrow-key handlers), so it cannot fully implement "left lands before
    // the run, right lands after" — that needs direction threaded through
    // the cursor-movement call chain. `zig_bw_viewmode_fixup_cursor` (below)
    // covers that case for the arrow-key handlers; this paint-time fixup
    // still runs on every repaint as a backstop. `clampHiddenOffset` covers
    // the deterministic part both need: prefer the forward skip; when the
    // hidden run reaches end of line with nothing visible after it, clamp
    // to the last visible byte before the run (or offset 0 if the whole
    // line is concealed) instead of leaving the cursor on a hidden byte
    // with a stale (pre-collapse) xcol.
    if (skip_hidden != 0 and cursor_offset >= 0 and cursor_offset < hide_len) {
        const off: usize = @intCast(cursor_offset);
        if (off < clear_n and hide.?[off] != 0) {
            const hide_slice = hide.?[0..clear_n];
            const corrected = clampHiddenOffset(hide_slice, off);
            if (corrected != off) {
                const move = pdup(cursor, "zig_bw_view_finish_skip") orelse return -1;
                zig_c_bw_p_goto_bol(move);
                const target = zig_c_bw_pbyte(move) + @as(i64, @intCast(corrected));
                zig_c_bw_pgoto(cursor, target);
                cursor_offset = @intCast(corrected);
                prm(move);
            }
        }
    }

    if (cursor_offset >= 0 and cursor_offset < col_map_len) {
        const new_xcol = col_map.?[@intCast(cursor_offset)];
        zig_c_bw_set_xcol(cursor, new_xcol);
    }
    return 0;
}

/// Shared prefix for the two interactive (non-paint) viewmode column
/// lookups below: locate the cursor's line and its byte offset into it,
/// bailing whenever the collapsed-column model doesn't apply. `buf` is
/// caller-owned scratch for the line text (paint code sizes similarly).
const CursorLineCtx = struct {
    cursor: *P,
    bol_byte: i64,
    off: usize,
    line: []const u8,
};

fn cursorLineCtx(bw: ?*BW, buf: []u8) ?CursorLineCtx {
    if (bw == null) return null;
    if (zig_c_bw_get_viewmode(bw) == 0) return null;
    const syn = zig_c_bw_get_syntax(bw);
    if (!syntaxNameIsMd(syn)) return null;
    const cursor = zig_c_bw_get_cursor(bw) orelse return null;

    const bol = pdup(cursor, "cursorLineCtx") orelse return null;
    defer prm(bol);
    zig_c_bw_p_goto_bol(bol);
    const bol_byte = zig_c_bw_pbyte(bol);
    const cursor_byte_offset = zig_c_bw_pbyte(cursor) - bol_byte;
    if (cursor_byte_offset < 0) return null;

    const buf_line = zig_c_bw_pline_no(cursor);
    const ll = bwReadLine(bol, buf_line, buf.ptr, @intCast(buf.len));
    if (ll < 0) return null;
    return CursorLineCtx{ .cursor = cursor, .bol_byte = bol_byte, .off = @intCast(cursor_byte_offset), .line = buf[0..@intCast(ll)] };
}

/// Interactive counterpart to `zig_bw_view_finish`'s paint-time cursor
/// fixup (plan R5 follow-up). Arrow-key movement (`u_goto_right` etc. in
/// `uedit.zig`) can leave the cursor sitting on a byte that's concealed in
/// viewmode (e.g. inside `**`) — this moves it to the nearest visible byte
/// via `clampHiddenOffset`, and sets `cursor.xcol` (the sticky goal column
/// used by up/down movement, see `tw.zig`'s `disptw`) to the collapsed
/// column. Does NOT affect on-screen cursor rendering — `disptw` recomputes
/// that fresh via `zig_bw_viewmode_cursor_col` below on every paint,
/// ignoring `cursor.xcol` entirely (by original-C design: `xcol` is a goal,
/// not necessarily a real glyph position).
///
/// No-op (returns `-1`, callers ignore the result) unless viewmode is on
/// and the cursor's line is markdown syntax, or the cursor sits at/past
/// EOL — `col_map` has no entry past the last byte, and EOL's collapsed
/// column depends on tail-concealed width that isn't available here; left
/// to the existing raw `piscol` computation.
pub export fn zig_bw_viewmode_fixup_cursor(bw: ?*BW) c_int {
    var tmp: [16 * 1024]u8 = undefined;
    const ctx = cursorLineCtx(bw, &tmp) orelse return -1;
    if (ctx.off >= ctx.line.len) return -1;

    const alloc = std.heap.c_allocator;
    var tables = ViewTables.init(alloc);
    defer tables.deinit();
    render.analyzeLine(&tables, ctx.line, null) catch return -1;

    const corrected = clampHiddenOffset(tables.hide, ctx.off);
    if (corrected != ctx.off) {
        zig_c_bw_pgoto(ctx.cursor, ctx.bol_byte + @as(i64, @intCast(corrected)));
    }
    if (corrected < tables.col_map.len) {
        zig_c_bw_set_xcol(ctx.cursor, @intCast(tables.col_map[corrected]));
    }
    return 0;
}

/// Viewmode-aware display column for the cursor's CURRENT byte position,
/// for `tw.zig`'s `disptw` to draw the terminal cursor at. Read-only:
/// unlike `zig_bw_viewmode_fixup_cursor`, never moves the cursor — a hidden
/// byte still has a well-defined collapsed column (concealed bytes
/// contribute zero width, so `col_map` at that offset already equals the
/// column of whatever visible content follows). `disptw`'s own raw
/// `piscol` handles EOL and the non-markdown/non-viewmode cases when this
/// returns `-1`.
pub export fn zig_bw_viewmode_cursor_col(bw: ?*BW) i64 {
    var tmp: [16 * 1024]u8 = undefined;
    const ctx = cursorLineCtx(bw, &tmp) orelse return -1;
    if (ctx.off >= ctx.line.len) return -1;

    const alloc = std.heap.c_allocator;
    var tables = ViewTables.init(alloc);
    defer tables.deinit();
    render.analyzeLine(&tables, ctx.line, null) catch return -1;
    if (ctx.off >= tables.col_map.len) return -1;
    return @intCast(tables.col_map[ctx.off]);
}

extern fn fork() c_int;
extern fn _exit(status: c_int) noreturn;
extern fn execlp(file: [*c]const u8, arg0: [*c]const u8, arg1: [*c]const u8, arg2: ?*const anyopaque) c_int;
extern fn waitpid(pid: c_int, status: ?*c_int, options: c_int) c_int;
extern fn signrm() void;

/// Double-fork: the intermediate child exits immediately after spawning
/// the grandchild, so the grandchild (the actual `open`/`xdg-open`
/// process) gets reparented to init and never becomes joe's zombie to
/// clean up. The single `waitpid` below only waits for the near-instant
/// intermediate child, not the URL-opener itself — matches plan §5's
/// "fork + `_exit` on failure, never block the editor."
fn spawnOpenUrl(url_z: [*:0]const u8) void {
    const pid = fork();
    if (pid == 0) {
        signrm();
        const gpid = fork();
        if (gpid == 0) {
            // `execlp` never returns on success. Uses argv directly — never
            // `/bin/sh -c` with the URL interpolated, so a URL like
            // `http://a;rm -rf ~` is just one inert argv element, not a
            // shell command (plan §5's explicit security requirement).
            if (execlp("open", "open", url_z, null) == -1) {
                _ = execlp("xdg-open", "xdg-open", url_z, null);
            }
            _exit(1);
        }
        _exit(0);
    }
    if (pid > 0) {
        _ = waitpid(pid, null, 0);
    }
}

/// Feature 5: open the link/image URL under the cursor in the system
/// browser/handler (plan §5, hooked from `udefmup` in `mouse.zig` — a
/// mouseup with no preceding drag). Read-only same as
/// `zig_bw_viewmode_cursor_col`: viewmode+md only (via `cursorLineCtx`),
/// no-ops silently (returns `0`) when there's no link at the cursor or its
/// scheme isn't in the allowed set, rather than doing anything with an
/// unsafe or absent URL. Returns `1` when a spawn was attempted.
pub export fn zig_bw_try_open_link_at_cursor(bw: ?*BW) c_int {
    var tmp: [16 * 1024]u8 = undefined;
    const ctx = cursorLineCtx(bw, &tmp) orelse return 0;
    if (ctx.off >= ctx.line.len) return 0;

    const alloc = std.heap.c_allocator;
    var tables = ViewTables.init(alloc);
    defer tables.deinit();
    render.analyzeLine(&tables, ctx.line, null) catch return 0;
    if (ctx.off >= tables.link_url.len) return 0;
    const raw_url = tables.link_url[ctx.off] orelse return 0;

    // Reference-style links ([a][r]) store the reference *label* here, not
    // a URL (Phase 2 never resolves references — plan R2's "no cache"
    // decision: conceal doesn't need it, so don't scan the whole buffer on
    // every paint). Resolve lazily, only now, at click time.
    var ref_buf: [16 * 1024]u8 = undefined;
    const url = if (render.md_event.isSafeUrlScheme(raw_url))
        raw_url
    else
        resolveReferenceUrl(bw, ctx.cursor, raw_url, &ref_buf) orelse return 0;
    if (!render.md_event.isSafeUrlScheme(url)) return 0;

    var buf: [1024]u8 = undefined;
    if (url.len >= buf.len) return 0;
    @memcpy(buf[0..url.len], url);
    buf[url.len] = 0;
    spawnOpenUrl(buf[0..url.len :0]);
    return 1;
}

/// Plan §5.2b: one-time buffer scan at click time for a reference
/// definition line matching `^[ \t]{0,3}\[label\]:[ \t]*dest` (label
/// match case-insensitive, matching CommonMark's reference-label rules).
/// `scratch` is caller-owned so the returned slice (borrowed from it)
/// outlives this call; returns `null` if no definition line matches.
fn resolveReferenceUrl(bw: ?*BW, cursor: ?*P, label: []const u8, scratch: []u8) ?[]const u8 {
    const eof_line = zig_c_bw_b_eof_line(bw);
    const origin = zig_c_bw_bof(cursor) orelse return null;
    const scan = pdup(origin, "resolveReferenceUrl") orelse return null;
    defer prm(scan);

    var n: i64 = 0;
    while (n <= eof_line) : (n += 1) {
        const ll = bwReadLine(scan, n, scratch.ptr, @intCast(scratch.len));
        if (ll < 0) continue;
        if (render.md_event.parseReferenceDef(scratch[0..@intCast(ll)], label)) |dest| return dest;
    }
    return null;
}

/// Feature 5: reverse of `zig_bw_viewmode_cursor_col` — given `bol_cursor`
/// already positioned at the start of the target line (as `utomouse` does
/// via `pline` before calling this) and a raw *display* column, find the
/// buffer byte offset whose collapsed column best matches, so a mouse
/// click on a concealed markdown line lands on the right byte instead of
/// where raw `pcol` (uncollapsed) would put it — plan §5's "hit-test
/// display cell → buffer byte → URL, using the collapsed col_map".
/// Returns `-1` when not applicable (not viewmode/md); callers fall back
/// to raw `pcol`.
pub export fn zig_bw_viewmode_click_byte_offset(bw: ?*BW, bol_cursor: ?*P, goal_col: i64) i64 {
    if (bw == null or bol_cursor == null) return -1;
    if (zig_c_bw_get_viewmode(bw) == 0) return -1;
    const syn = zig_c_bw_get_syntax(bw);
    if (!syntaxNameIsMd(syn)) return -1;

    const buf_line = zig_c_bw_pline_no(bol_cursor);
    var tmp: [16 * 1024]u8 = undefined;
    const ll = bwReadLine(bol_cursor, buf_line, &tmp, @intCast(tmp.len));
    if (ll < 0) return -1;
    const line: []const u8 = tmp[0..@intCast(ll)];
    if (line.len == 0) return 0;

    const alloc = std.heap.c_allocator;
    var tables = ViewTables.init(alloc);
    defer tables.deinit();
    render.analyzeLine(&tables, line, null) catch return -1;

    // col_map is non-decreasing; the click lands on the last byte whose
    // collapsed column doesn't exceed goal_col (a click past the visible
    // end of a concealed line clamps to the last byte, matching pcol's
    // own end-of-line clamp behavior).
    var best: usize = 0;
    var i: usize = 0;
    while (i < tables.col_map.len) : (i += 1) {
        if (@as(i64, @intCast(tables.col_map[i])) <= goal_col) {
            best = i;
        } else break;
    }
    return @intCast(best);
}

/// Thin `lgen_view` chrome dispatcher (Path A).
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
    fence_region_start: ?*i64,
    fence_region_end: ?*i64,
    fence_cached_for_line: ?*i64,
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
    syntax: ?*HighSyntax,
) c_int {
    if (line_ptr == null or hide == null or subst == null or col_map == null or col_map_line == null) return -1;
    if (cursor == null or p == null) return -1;
    if (fence_region_start == null or fence_region_end == null) return -1;
    if (fence_cached_for_line == null) return -1;
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

    // `cur_line_slice` is needed by the fence fast path below (it's this
    // row's already-read text — the last line of a forward hop needs no
    // extra buffer I/O) as well as by Feature 6.2/4.2.1(d) further down.
    const cur_line_slice: []const u8 = if (line_len > 0) line_ptr.?[0..@intCast(line_len)] else &.{};

    // 0) Fence-body region cache + gate (plan §4.2.1 / R1). Body lines skip
    // every markdown analyzer below — including the line-start dispatch —
    // so a code comment that starts with `#` or contains `**`/`~~~` is
    // never reinterpreted as a heading, emphasis, or a mismatched fence
    // marker. Delimiter lines (the opening/closing fence itself) are NOT
    // gated here: they fall through to the existing single-line check in
    // `zig_bw_view_line_start`, which already recognizes them correctly
    // without needing region context.
    if (fence_cached_for_line.?.* != buf_line) {
        if (buf_line >= fence_region_start.?.* and buf_line < fence_region_end.?.* and
            (fence_region_end.?.* != fence_region_end_open_sentinel or buf_line <= vm_fence_scan_line))
        {
            // Already-known region covers buf_line: O(1), and note the
            // marker (open_ch/open_len) is constant across a single
            // region's whole span, so `vm_fence_scan_*` — wherever it was
            // last set for *this* region — stays valid without touching it
            // here; only `vm_fence_scan_line` (the fast-path high-water
            // mark) can lag behind while scrolling through a long body,
            // which just means the next miss may fall back to a bounded
            // rescan instead of an O(1) step — still correct, not the
            // O(window²) this whole change removes.
            fence_cached_for_line.?.* = buf_line;
        } else if (vm_fence_scan_line != -1 and buf_line > vm_fence_scan_line and
            buf_line - vm_fence_scan_line <= fence_scan_window_lines)
        {
            // Forward-adjacency fast path. `bwGetto`'s doc comment already
            // establishes paint walks top→bottom, so within one repaint
            // this covers every row after the first, and it also covers a
            // repaint's first row whenever the previous repaint left off
            // no more than a window away (e.g. scrolling down) — steps the
            // same open/close transition `zig_bw_fence_detect` uses, one
            // line at a time, instead of a full window rescan per row.
            var open_ch = vm_fence_scan_open_ch;
            var open_len = vm_fence_scan_open_len;
            var region_start = vm_fence_scan_region_start;
            var step_p: ?*P = null;
            defer if (step_p) |sp| prm(sp);
            var scan_line = vm_fence_scan_line;
            while (scan_line < buf_line) {
                scan_line += 1;
                var tmp: [16 * 1024]u8 = undefined;
                const slice: []const u8 = blk: {
                    if (scan_line == buf_line) break :blk cur_line_slice;
                    if (step_p == null) {
                        const sp = pdup(p, "zig_bw_lgen_view_fence_step") orelse break :blk @as([]const u8, &.{});
                        zig_c_bw_pline(sp, scan_line);
                        zig_c_bw_p_goto_bol(sp);
                        step_p = sp;
                    }
                    const rc = readLineFromCurrent(step_p.?, &tmp, @intCast(tmp.len));
                    break :blk if (rc >= 0) tmp[0..@intCast(rc)] else @as([]const u8, &.{});
                };
                fenceStepLine(slice, &open_ch, &open_len, &region_start, scan_line);
            }
            vm_fence_scan_line = buf_line;
            vm_fence_scan_open_ch = open_ch;
            vm_fence_scan_open_len = open_len;
            vm_fence_scan_region_start = region_start;
            if (open_ch == 0) {
                fence_region_start.?.* = -1;
                fence_region_end.?.* = -1;
            } else {
                fence_region_start.?.* = region_start;
                // Real end unknown without a forward scan; the sentinel
                // means "still open as of buf_line" — safe for classifying
                // *this* buf_line (the `in_fence_body` check below only
                // tests `buf_line < fence_region_end - 1`, which any real
                // buf_line satisfies), but the membership check above
                // special-cases this sentinel so it's never trusted as a
                // shortcut for any *later* buf_line without a fresh step.
                fence_region_end.?.* = fence_region_end_open_sentinel;
            }
            fence_cached_for_line.?.* = buf_line;
        } else {
            // No negative-cache shortcut here (unlike the table detector's
            // `±10` window): a delimiter line correctly reporting "not in a
            // body" says nothing about whether the NEXT line is body — that
            // would require caching a state transition point, not a single
            // query result. Fall back to a full bounded scan (O(window),
            // not the O(window²) the old per-probe reseek cost) and seed
            // the forward-adjacency tracker above from its result, so the
            // overwhelmingly likely next call — a small forward hop — can
            // resume the fast path instead of hitting this branch again.
            fence_region_start.?.* = -1;
            fence_region_end.?.* = -1;
            var open_ch: u8 = 0;
            var open_len: usize = 0;
            const zfd = zig_bw_fence_detect(p, buf_line, fence_region_start, fence_region_end, &open_ch, &open_len);
            if (zfd < 0) return -1;
            fence_cached_for_line.?.* = buf_line;
            // zig_bw_fence_detect answers "is buf_line inside a fence
            // opened *strictly before* buf_line" (delimiter lines are
            // classified separately by the caller, so its own scan window
            // deliberately excludes buf_line's own content). The tracker
            // instead needs the state *including* buf_line — so the next
            // line (buf_line+1) starts from the right place even when
            // buf_line itself is an opening or closing delimiter — so
            // apply buf_line's own transition once more before seeding it.
            var region_start_for_scan: i64 = if (open_ch != 0) fence_region_start.?.* else -1;
            fenceStepLine(cur_line_slice, &open_ch, &open_len, &region_start_for_scan, buf_line);
            vm_fence_scan_line = buf_line;
            vm_fence_scan_open_ch = open_ch;
            vm_fence_scan_open_len = open_len;
            vm_fence_scan_region_start = region_start_for_scan;
        }
    }

    const in_fence_body: bool = fence_region_start.?.* != -1 and
        buf_line > fence_region_start.?.* and buf_line < fence_region_end.?.* - 1;

    if (in_fence_body) {
        // Feature 2.5: nested syntax highlighting — re-parse this body
        // line with the fence's language syntax (from its opening
        // delimiter's info string) if one is recognized, overwriting the
        // plain code-block tint `md.jsf` already assigned. No-op (tint
        // kept) for an unknown language.
        applyFenceSyntaxHighlight(p, fence_region_start.?.*, buf_line, charmap);

        // Force a fresh col_map build below: hide/subst are all-zero here
        // (no analyzer has touched them), but `col_map_line` may still hold
        // some earlier, unrelated line's index. Setting it to `buf_line`
        // directly — without building — would make `zig_bw_view_finish`'s
        // own `col_map_line != buf_line` guard skip the rebuild and leave
        // `col_map` holding stale data from whatever line was last mapped.
        col_map_line.?.* = -1;
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

    // 1) Line-start Feature 1.3/1.5/1.7/1.8 (+ task).
    // Feature 6.2: resolve setext-underline ambiguity (a `-` run also
    // matches Feature 1.8's thematic break) with a single bounded look at
    // the previous line, before the normal dispatch runs.
    const is_setext_underline: c_int = if (isSetextUnderline(p, buf_line, cur_line_slice)) 1 else 0;
    // Feature 4.2.1(d) fix: resolve the blank-line-starts-a-region rule
    // `analyzeLineStart` can't check itself (single-line, no lookback).
    const tab_u_scan: u16 = if (tab <= 0) 8 else @intCast(tab);
    const looks_like_indented_shape = render.looksLikeIndentedCode(cur_line_slice, tab_u_scan);
    const allow_indented_code_bool = isIndentedCodeAllowed(p, buf_line, cur_line_slice, tab_u_scan);
    const allow_indented_code: c_int = if (allow_indented_code_bool) 1 else 0;
    // A line whose shape matches "indented code" but whose region isn't a
    // valid start (an ordinary list-item continuation line, not preceded
    // by a blank line) was *also* misparsed by the buffer's own earlier
    // `md.jsf` DFA pass — that pass has the same "4+ leading whitespace"
    // shape check, with the same missing list-context awareness, and it
    // already ran (writing into `atr`/`attr_buf`) before this function was
    // called, via `:line_start`'s dispatch into the indented-code counting
    // chain. Re-parse the line from `:idle` instead of blindly resetting
    // to `defatr`: `:idle` has no special leading-whitespace handling, so
    // the line gets parsed as ordinary paragraph content — plain text
    // comes out plain, but inline constructs within it (code spans,
    // emphasis, links) still get their own correct classification, which
    // a flat reset would have erased too (a code span colored the same as
    // its surrounding text is just as wrong as the whole line being
    // code-tinted). Falls back to the flat reset if `:idle` can't be
    // found (defensive only — `md.jsf` always defines it).
    if (looks_like_indented_shape and !allow_indented_code_bool) {
        var reset_done = false;
        if (mdIdleStateNo(syntax)) |idle_no| {
            if (pdup(p, "zig_bw_lgen_view_idle_reparse")) |idle_scratch| {
                defer prm(idle_scratch);
                zig_c_bw_pline(idle_scratch, buf_line);
                zig_c_bw_p_goto_bol(idle_scratch);
                _ = parse(syntax, idle_scratch, .{ .stack = null, .delim_stack = null, .saved_s = null, .state = idle_no }, charmap);
                reset_done = true;
            }
        }
        if (!reset_done and atr != null and n > 0) {
            const alen: usize = @intCast(atr_len);
            var ri: usize = 0;
            while (ri < n and ri < alen) : (ri += 1) atr.?[ri] = defatr;
        }
    }
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
        is_setext_underline,
        allow_indented_code,
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
    // Feature 6.2: a plausible-paragraph line immediately followed by a
    // setext underline gets heading styling (bold[+underline for H1])
    // applied below, on top of whatever this pass's own link styling set.
    const setext_level: c_int = @intCast(setextHeadingLevel(p, buf_line, cur_line_slice));
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
        setext_level,
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
const vm_max_table_cols: usize = 64;

extern fn joe_malloc(n: isize) ?*anyopaque;
extern fn joe_realloc(p: ?*anyopaque, n: isize) ?*anyopaque;
extern fn joe_free(p: ?*anyopaque) void;
extern var square: c_int;

// Zig-owned viewmode statics for Path A. C keeps parallel Feature
// statics directly (no Zig bridges) for Path A `-1`; only
// `zig_c_bw_view_{defatr,col_map*}` remain as cursor/attr helpers.
var vm_hide: ?[*]u8 = null;
var vm_hide_size: c_int = 0;
var vm_subst: ?[*]c_int = null;
var vm_subst_size: c_int = 0;
var vm_urls: ?[*]?[*:0]u8 = null;
var vm_urls_size: c_int = 0;
var vm_col_map: ?[*]i64 = null;
var vm_col_map_size: c_int = 0;
var vm_col_map_line: i64 = -1;
var vm_table_region_start: i64 = -1;
var vm_table_region_end: i64 = -1;
var vm_table_separator_line: i64 = -1;
var vm_table_cached_for_line: i64 = -1;
var vm_table_no_region_line: i64 = -1;
var vm_table_col_count: c_int = 0;
var vm_table_col_width: [vm_max_table_cols]c_int = [_]c_int{0} ** vm_max_table_cols;
var vm_table_col_align: [vm_max_table_cols]c_int = [_]c_int{0} ** vm_max_table_cols;
// Feature 4.2.1 fence-body region cache (plan §4.2.1 / R1) — mirrors the
// table-region cache above so fenced code content is never re-parsed as
// markdown. `vm_fence_region_end` is exclusive (one past the closing
// delimiter line); a line equal to start or end-1 is a delimiter line and
// falls through to the existing single-line fence-marker conceal. No
// negative-cache field (unlike the table's `no_region_line`) — see the
// comment at its one use site in `zig_bw_lgen_view` for why that shortcut
// is unsound here.
var vm_fence_region_start: i64 = -1;
var vm_fence_region_end: i64 = -1;
var vm_fence_cached_for_line: i64 = -1;
// Content generation observed by the current region caches. Any edit bumps
// `gapbuffer.buffer.vm_content_generation`; on mismatch every cached region
// below is dropped before paint (line numbers may have shifted under them).
var vm_cache_generation: u64 = 0;
// Forward-adjacency incremental tracker: paint walks top→bottom
// (`bwGetto`'s doc comment), so within one repaint `buf_line` increases
// row over row, and consecutive repaints while scrolling down start only a
// few lines apart. `vm_fence_scan_line` is the last buf_line whose fence
// state was resolved (by any path); `vm_fence_scan_open_ch`/`_open_len`/
// `_region_start` are that state (`open_ch == 0` means not inside a
// fence). A small forward hop from `vm_fence_scan_line` can step this
// state one line at a time instead of paying a full `zig_bw_fence_detect`
// window rescan — see the fast path in `zig_bw_lgen_view`.
var vm_fence_scan_line: i64 = -1;
var vm_fence_scan_open_ch: u8 = 0;
var vm_fence_scan_open_len: usize = 0;
var vm_fence_scan_region_start: i64 = -1;
var vm_ready: c_int = 0;
var vm_last_bw: ?*BW = null;

fn vmFreeLinkUrls() void {
    const urls = vm_urls orelse return;
    if (vm_urls_size <= 0) return;
    const n: usize = @intCast(vm_urls_size);
    var m: usize = 0;
    while (m < n) : (m += 1) {
        const p = urls[m] orelse continue;
        joe_free(p);
        var i = m + 1;
        while (i < n) : (i += 1) {
            if (urls[i] == p) urls[i] = null;
        }
        urls[m] = null;
    }
}

/// Ensure Zig viewmode side tables can hold `need` bytes; reset per-line state.
/// Sets `vm_ready` so paint prefers these tables for Path A.
pub export fn zig_bw_vm_prepare(bw: ?*BW, need: c_int) c_int {
    if (bw == null or need <= 0 or need > viewmode_max_line_bytes) return -1;
    const need_usz: usize = @intCast(need);

    if (vm_last_bw != bw) {
        vm_table_region_start = -1;
        vm_table_region_end = -1;
        vm_table_separator_line = -1;
        vm_table_cached_for_line = -1;
        vm_table_no_region_line = -1;
        vm_table_col_count = 0;
        vm_fence_region_start = -1;
        vm_fence_region_end = -1;
        vm_fence_cached_for_line = -1;
        vm_fence_scan_line = -1;
        vm_fence_scan_open_ch = 0;
        vm_fence_scan_open_len = 0;
        vm_fence_scan_region_start = -1;
        vm_col_map_line = -1;
        vm_last_bw = bw;
        vm_cache_generation = gapbuffer_mod.vm_content_generation;
    } else if (vm_cache_generation != gapbuffer_mod.vm_content_generation) {
        // Buffer content changed since the caches were built (edit/undo/
        // replace): line numbers in cached regions may have shifted. Drop
        // every cross-paint cache; per-line state is rebuilt on demand.
        vm_table_region_start = -1;
        vm_table_region_end = -1;
        vm_table_separator_line = -1;
        vm_table_cached_for_line = -1;
        vm_table_no_region_line = -1;
        vm_table_col_count = 0;
        vm_fence_region_start = -1;
        vm_fence_region_end = -1;
        vm_fence_cached_for_line = -1;
        vm_fence_scan_line = -1;
        vm_fence_scan_open_ch = 0;
        vm_fence_scan_open_len = 0;
        vm_fence_scan_region_start = -1;
        vm_col_map_line = -1;
        vm_cache_generation = gapbuffer_mod.vm_content_generation;
    }

    if (vm_hide == null or vm_hide_size < need) {
        if (vm_hide) |h| joe_free(h);
        vm_hide = @ptrCast(@alignCast(joe_malloc(need) orelse {
            vm_hide_size = 0;
            return -1;
        }));
        vm_hide_size = need;
    }
    @memset(vm_hide.?[0..need_usz], 0);

    if (vm_subst == null or vm_subst_size < need) {
        if (vm_subst) |s| joe_free(s);
        const bytes: isize = @intCast(need_usz * @sizeOf(c_int));
        vm_subst = @ptrCast(@alignCast(joe_malloc(bytes) orelse {
            vm_subst_size = 0;
            return -1;
        }));
        vm_subst_size = need;
    }
    @memset(vm_subst.?[0..need_usz], 0);

    if (vm_col_map == null or vm_col_map_size < need) {
        const bytes: isize = @intCast(need_usz * @sizeOf(i64));
        const nm = joe_realloc(@ptrCast(vm_col_map), bytes) orelse {
            if (vm_col_map) |cm| joe_free(cm);
            vm_col_map = null;
            vm_col_map_size = 0;
            vm_col_map_line = -1;
            return -1;
        };
        vm_col_map = @ptrCast(@alignCast(nm));
        vm_col_map_size = need;
    }

    if (vm_urls == null or vm_urls_size < need) {
        vmFreeLinkUrls();
        const bytes: isize = @intCast(need_usz * @sizeOf(?[*:0]u8));
        const nl = joe_realloc(@ptrCast(vm_urls), bytes) orelse return -1;
        const urls: [*]?[*:0]u8 = @ptrCast(@alignCast(nl));
        const old: usize = if (vm_urls_size > 0) @intCast(vm_urls_size) else 0;
        if (old < need_usz) @memset(urls[old..need_usz], null);
        vm_urls = urls;
        vm_urls_size = need;
    } else {
        vmFreeLinkUrls();
        @memset(vm_urls.?[0..need_usz], null);
    }

    vm_ready = 1;
    return 0;
}

pub export fn zig_bw_vm_hide() ?[*]u8 {
    return vm_hide;
}
pub export fn zig_bw_vm_hide_size() c_int {
    return vm_hide_size;
}
pub export fn zig_bw_vm_subst() ?[*]c_int {
    return vm_subst;
}
pub export fn zig_bw_vm_subst_size() c_int {
    return vm_subst_size;
}
pub export fn zig_bw_vm_urls() ?[*]?[*:0]u8 {
    return vm_urls;
}
pub export fn zig_bw_vm_urls_size() c_int {
    return vm_urls_size;
}
pub export fn zig_bw_vm_col_map() ?[*]i64 {
    return vm_col_map;
}
pub export fn zig_bw_vm_col_map_size() c_int {
    return vm_col_map_size;
}
pub export fn zig_bw_vm_col_map_line_ptr() ?*i64 {
    return &vm_col_map_line;
}
pub export fn zig_bw_vm_trs_ptr() ?*i64 {
    return &vm_table_region_start;
}
pub export fn zig_bw_vm_tre_ptr() ?*i64 {
    return &vm_table_region_end;
}
pub export fn zig_bw_vm_tsl_ptr() ?*i64 {
    return &vm_table_separator_line;
}
pub export fn zig_bw_vm_tcfl_ptr() ?*i64 {
    return &vm_table_cached_for_line;
}
pub export fn zig_bw_vm_tnrl_ptr() ?*i64 {
    return &vm_table_no_region_line;
}
pub export fn zig_bw_vm_frs_ptr() ?*i64 {
    return &vm_fence_region_start;
}
pub export fn zig_bw_vm_fre_ptr() ?*i64 {
    return &vm_fence_region_end;
}
pub export fn zig_bw_vm_fcfl_ptr() ?*i64 {
    return &vm_fence_cached_for_line;
}
pub export fn zig_bw_vm_tcc_ptr() ?*c_int {
    return &vm_table_col_count;
}
pub export fn zig_bw_vm_tcw() ?[*]c_int {
    return &vm_table_col_width;
}
pub export fn zig_bw_vm_tca() ?[*]c_int {
    return &vm_table_col_align;
}
pub export fn zig_bw_vm_tcap() c_int {
    return @intCast(vm_max_table_cols);
}
pub export fn zig_bw_vm_ready() c_int {
    return vm_ready;
}

/// Clear per-line Zig viewmode tables after paint (keep allocations).
pub export fn zig_bw_vm_after(line_len: c_int) void {
    const n: usize = @intCast(if (line_len > 0) line_len else 1);
    if (vm_hide) |h| {
        const cap: usize = if (vm_hide_size > 0) @intCast(vm_hide_size) else 0;
        const clear_n = @min(n, cap);
        if (clear_n > 0) @memset(h[0..clear_n], 0);
    }
    if (vm_subst) |s| {
        const cap: usize = if (vm_subst_size > 0) @intCast(vm_subst_size) else 0;
        const clear_n = @min(n, cap);
        if (clear_n > 0) @memset(s[0..clear_n], 0);
    }
    vmFreeLinkUrls();
    vm_ready = 0;
}

/// Feature 1.10: display column for buffer offset from Zig-owned col_map.
/// Returns `-1` when map is missing / stale / out of range.
pub export fn zig_bw_vm_display_col(buf_line: i64, buf_offset: i64) i64 {
    const col_map = vm_col_map orelse return -1;
    if (vm_col_map_line != buf_line) return -1;
    if (buf_offset < 0 or buf_offset >= vm_col_map_size) return -1;
    return col_map[@intCast(buf_offset)];
}

/// Free all Zig-owned viewmode statics (atexit / process cleanup).
pub export fn zig_bw_vm_cleanup() void {
    if (vm_hide) |h| {
        joe_free(h);
        vm_hide = null;
    }
    vm_hide_size = 0;
    if (vm_subst) |s| {
        joe_free(s);
        vm_subst = null;
    }
    vm_subst_size = 0;
    if (vm_col_map) |cm| {
        joe_free(cm);
        vm_col_map = null;
    }
    vm_col_map_size = 0;
    vm_col_map_line = -1;
    if (vm_urls != null) {
        vmFreeLinkUrls();
        joe_free(@ptrCast(vm_urls));
        vm_urls = null;
        vm_urls_size = 0;
    }
    vm_table_region_start = -1;
    vm_table_region_end = -1;
    vm_table_separator_line = -1;
    vm_table_cached_for_line = -1;
    vm_table_no_region_line = -1;
    vm_table_col_count = 0;
    @memset(&vm_table_col_width, 0);
    @memset(&vm_table_col_align, 0);
    vm_fence_region_start = -1;
    vm_fence_region_end = -1;
    vm_fence_cached_for_line = -1;
    vm_fence_scan_line = -1;
    vm_fence_scan_open_ch = 0;
    vm_fence_scan_open_len = 0;
    vm_fence_scan_region_start = -1;
    vm_ready = 0;
    vm_last_bw = null;
}

// Match C bg_* / curlinmask (BG_COLOR is identity in scrn.h).
extern var bg_text: c_int;
export var bg_curlin: c_int = 0;
export var bg_linum: c_int = 0;
export var bg_curlinum: c_int = 0;
extern var bg_cursor: c_int;
export var curlinmask: c_int = -1;

/// Default line attribute: hiline current-line blend, else `bg_text`.
fn viewDefatr(bw: ?*BW, buf_line: i64) c_int {
    if (bw == null) return bg_text;
    if (zig_c_bw_get_hiline(bw) != 0) {
        if (zig_c_bw_get_cursor(bw)) |cursor| {
            if (zig_c_bw_pline_no(cursor) == buf_line) {
                return (bg_text & curlinmask) | bg_curlin;
            }
        }
    }
    return bg_text;
}

/// Paint a line via `zig_bw_lgen` (raw or preparsed viewmode tables).
fn paintBodyWithLgen(
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
    preparsed: bool,
) c_int {
    const syntax = zig_c_bw_get_syntax(bw) orelse return -1;
    const charmap = zig_c_bw_get_charmap(bw) orelse return -1;
    const tab = zig_c_bw_get_tab(bw);
    const top_line = zig_c_bw_get_top_line(bw);
    const win_y = zig_c_bw_get_y(bw);
    const buf_line = top_line + y - win_y;
    const defatr = viewDefatr(bw, buf_line);
    var pal_len: c_int = 0;
    const palette = zig_c_bw_get_palette(t, &pal_len);
    const line_byte = zig_c_bw_pbyte(p);
    if (preparsed) {
        return zig_bw_lgen(
            t,
            y,
            screen,
            attr_row,
            x,
            w,
            p,
            scr,
            syntax,
            st,
            charmap,
            tab,
            defatr,
            palette,
            pal_len,
            from,
            to,
            line_byte,
            1, // preparsed / viewmode_skip_parse
            zig_bw_vm_hide(),
            zig_bw_vm_hide_size(),
            zig_bw_vm_subst(),
            zig_bw_vm_subst_size(),
            zig_bw_vm_urls(),
            zig_bw_vm_urls_size(),
            zig_c_bw_get_visiblews(bw),
            square,
            zig_c_bw_get_ansi(bw),
        );
    }
    return zig_bw_lgen(
        t,
        y,
        screen,
        attr_row,
        x,
        w,
        p,
        scr,
        syntax,
        st,
        charmap,
        tab,
        defatr,
        palette,
        pal_len,
        from,
        to,
        line_byte,
        0,
        null,
        0,
        null,
        0,
        null,
        0,
        zig_c_bw_get_visiblews(bw),
        square,
        zig_c_bw_get_ansi(bw),
    );
}

/// Paint preparsed viewmode line via Zig tables + `zig_bw_lgen`.
fn paintViewBodyWithVm(
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
    return paintBodyWithLgen(t, y, screen, attr_row, x, w, p, scr, from, to, st, bw, true);
}

/// Thin `lgen_view` entry (Path A): prelude + dispatcher + paint cleanup.
///
/// Zig owns viewmode static storage (`zig_bw_vm_*`) for Path A. C keeps the
/// C Feature fallback removed; hard-fails in C if this returns `-1`.
/// Markdown syntax gating stays in C.
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
    if (t == null or screen == null or attr_row == null or p == null or bw == null) return -1;

    const syntax = zig_c_bw_get_syntax(bw) orelse return -1;
    const charmap = zig_c_bw_get_charmap(bw) orelse return -1;
    const cursor = zig_c_bw_get_cursor(bw) orelse return -1;
    const top_line = zig_c_bw_get_top_line(bw);
    const win_y = zig_c_bw_get_y(bw);
    const tab = zig_c_bw_get_tab(bw);

    // Pathological line length: skip viewmode transforms; paint raw via Zig.
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
                return paintBodyWithLgen(t, y, screen, attr_row, x, w, p, scr, from, to, st, bw, false);
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
    if (zig_bw_vm_prepare(bw, need) < 0) return -1;

    if (line_truncated) {
        const result = paintViewBodyWithVm(t, y, screen, attr_row, x, w, p, scr, from, to, st, bw);
        zig_bw_vm_after(line_len);
        return result;
    }

    if (attr_buf == null or attr_size <= 0) return -1;

    const hide = zig_bw_vm_hide() orelse return -1;
    const hide_size = zig_bw_vm_hide_size();
    const subst = zig_bw_vm_subst() orelse return -1;
    const subst_size = zig_bw_vm_subst_size();
    const urls = zig_bw_vm_urls() orelse return -1;
    const urls_size = zig_bw_vm_urls_size();
    const col_map = zig_bw_vm_col_map() orelse return -1;
    const col_map_size = zig_bw_vm_col_map_size();
    const col_map_line = zig_bw_vm_col_map_line_ptr() orelse return -1;
    const frs = zig_bw_vm_frs_ptr() orelse return -1;
    const fre = zig_bw_vm_fre_ptr() orelse return -1;
    const fcfl = zig_bw_vm_fcfl_ptr() orelse return -1;
    const trs = zig_bw_vm_trs_ptr() orelse return -1;
    const tre = zig_bw_vm_tre_ptr() orelse return -1;
    const tsl = zig_bw_vm_tsl_ptr() orelse return -1;
    const tcfl = zig_bw_vm_tcfl_ptr() orelse return -1;
    const tnrl = zig_bw_vm_tnrl_ptr() orelse return -1;
    const tcc = zig_bw_vm_tcc_ptr() orelse return -1;
    const tcw = zig_bw_vm_tcw() orelse return -1;
    const tca = zig_bw_vm_tca() orelse return -1;
    const tcap = zig_bw_vm_tcap();

    var pal_len: c_int = 0;
    const palette = zig_c_bw_get_palette(t, &pal_len);

    const buf_line = top_line + y - win_y;
    const defatr = viewDefatr(bw, buf_line);
    const utf8: c_int = if (charmap.type != 0) 1 else 0;

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
        frs,
        fre,
        fcfl,
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
        syntax,
    );
    if (z < 0) {
        zig_bw_vm_after(line_len);
        return -1;
    }

    if (z == 1) {
        _ = pnextl(p);
        zig_bw_vm_after(line_len);
        return 0;
    }
    const result = paintViewBodyWithVm(t, y, screen, attr_row, x, w, p, scr, from, to, st, bw);
    zig_bw_vm_after(line_len);
    return result;
}

/// Feature 2.1 residual: fill `vm_subst` via `table.applySimpleBorders`.
/// Live C only mutates separator rows when `table_col_count==0`; header/body/last
/// are no-ops — this matches that. Returns `0` on success, `-1` to fall back.
pub export fn zig_bw_table_simple(
    line: ?[*]const u8,
    line_len: c_int,
    row_type: c_int,
    out_subst: ?[*]c_int,
    out_subst_len: c_int,
) c_int {
    if (line == null or line_len < 0) return -1;
    if (out_subst == null or out_subst_len < line_len) return -1;

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
        if (subst[i] != 0) out_subst.?[i] = @intCast(subst[i]);
    }
    return 0;
}

/// C `struct high_syntax` prefix — only `name` is needed for viewmode dispatch.
const HighSyntaxRec = extern struct {
    next: ?*HighSyntaxRec,
    name: ?[*:0]u8,
};

fn syntaxNameIsMd(syn: ?*HighSyntax) bool {
    if (syn == null) return false;
    const rec: *const HighSyntaxRec = @ptrCast(@alignCast(syn.?));
    const name = rec.name orelse return false;
    return std.mem.eql(u8, std.mem.span(name), "md");
}

/// C `struct high_state` prefix — only `no` (the state's own index into
/// `syntax.states[]`, what a `HighlightState.state` value actually is)
/// needed here.
const HighStateRec = extern struct {
    no: isize,
};

/// Feature B.3/B.6 fix, corrected: `md.jsf`'s `:idle` state index, looked
/// up by name rather than hardcoded — state indices are assigned by
/// declaration order in the `.jsf` file, so hardcoding one would silently
/// break if `md.jsf` is ever reordered. `:idle` (not `:line_start`, state
/// 0) is the point: `:line_start`'s own dispatch is *why* a 4+-space line
/// gets wrongly routed into the indented-code counting chain
/// (`maybe_code`→...→`indented_code`) in the first place — `:idle` has no
/// such special-casing for leading whitespace, so re-parsing from there
/// for a line that's *shape*-like indented code but isn't a *valid*
/// indented-code start (see `isIndentedCodeAllowed`) processes it as
/// ordinary paragraph content instead: plain text stays plain, and inline
/// constructs within it (code spans, emphasis, links) get their normal,
/// correct classification — unlike a blind reset to `defatr`, which would
/// erase those too, not just the wrong code-block tint.
fn mdIdleStateNo(syn: ?*HighSyntax) ?isize {
    var idle_name: [5]u8 = "idle\x00".*;
    const st = find_state(syn, @ptrCast(&idle_name)) orelse return null;
    const rec: *const HighStateRec = @ptrCast(@alignCast(st));
    return rec.no;
}

fn pathAAbort(comptime msg: []const u8) noreturn {
    std.debug.print("{s}", .{msg});
    std.process.abort();
}

/// JOE static `lgen_core`: Zig-native body paint via `zig_bw_lgen`.
fn bwLgenCore(
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
    if (p == null or bw == null) pathAAbort("Path A: zig_bw_lgen -1\n");
    const pp = asP(p);
    const b = pp.b orelse pathAAbort("Path A: zig_bw_lgen -1\n");
    const charmap: ?*Charmap = @ptrCast(b.o.charmap);
    if (charmap == null) pathAAbort("Path A: zig_bw_lgen -1\n");

    const top_line = if (asBw(bw).top) |top| top.line else 0;
    const buf_line = y - asBw(bw).y + top_line;
    const defatr = viewDefatr(bw, buf_line);
    const tab: c_int = @intCast(b.o.tab);
    const syntax = zig_c_bw_get_syntax(bw);
    const palette = zig_c_bw_get_palette(t, null);
    const pal_len: c_int = if (palette != null) 256 else 0;

    const z = zig_bw_lgen(
        t,
        y,
        screen,
        attr_row,
        x,
        w,
        p,
        scr,
        syntax,
        st,
        charmap,
        tab,
        defatr, // BG_COLOR identity
        palette,
        pal_len,
        from,
        to,
        pp.byte,
        0,
        null,
        0,
        null,
        0,
        null,
        0,
        asBw(bw).o.visiblews,
        square,
        asBw(bw).o.ansi,
    );
    if (z >= 0) return z;
    pathAAbort("Path A: zig_bw_lgen -1\n");
}

/// JOE static `lgen_view`: Markdown viewmode entry or fall back to core.
fn bwLgenView(
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
    const syn = zig_c_bw_get_syntax(bw);
    if (st.state == -1 or syn == null or !syntaxNameIsMd(syn)) {
        return bwLgenCore(t, y, screen, attr_row, x, w, p, scr, from, to, st, bw);
    }
    const z = zig_bw_lgen_view_entry(t, y, screen, attr_row, x, w, p, scr, from, to, st, bw);
    if (z >= 0) return z;
    pathAAbort("Path A: zig_bw_lgen_view_entry returned -1\n");
}

/// JOE static `lgen` dispatcher (viewmode+md → view, else core).
fn zig_c_bw_lgen(
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
    if (bw != null and asBw(bw).o.viewmode != 0 and syntaxNameIsMd(zig_c_bw_get_syntax(bw))) {
        return bwLgenView(t, y, screen, attr_row, x, w, p, scr, from, to, st, bw);
    }
    return bwLgenCore(t, y, screen, attr_row, x, w, p, scr, from, to, st, bw);
}

/// JOE static `gennum` → Zig `zig_bw_gennum`.
fn zig_c_bw_gennum(
    w: ?*BW,
    screen: ?[*][COMPOSE]c_int,
    attr_row: ?[*]c_int,
    t: ?*SCRN,
    y: isize,
    compose: ?[*]c_int,
) void {
    if (w == null) pathAAbort("Path A: zig_bw_gennum -1\n");
    const bw = asBw(w);
    const top = bw.top orelse pathAAbort("Path A: zig_bw_gennum -1\n");
    const cur = bw.cursor orelse pathAAbort("Path A: zig_bw_gennum -1\n");
    const lin = top.line + y - bw.y;
    const atr: c_int = if (bw.o.hiline != 0 and lin == cur.line) bg_curlinum else bg_linum;
    // C `gennum` is a no-op when the gutter is still 0 (`disptw` skips
    // `calclincols` while typeahead is pending). Do not abort.
    if (bw.lincols <= 0) return;
    const b = bw.b orelse pathAAbort("Path A: zig_bw_gennum -1\n");
    const eof_line = if (b.eof) |e| e.line else @as(i64, -1);
    const have_number: c_int = if (lin <= eof_line) 1 else 0;
    const line_1based: i64 = if (have_number != 0) lin + 1 else 0;
    const charmap: ?*Charmap = @ptrCast(b.o.charmap);
    const z = zig_bw_gennum(
        t,
        y,
        screen,
        attr_row,
        compose,
        bw.lincols,
        have_number,
        line_1based,
        atr,
        charmap,
    );
    if (z >= 0) return;
    pathAAbort("Path A: zig_bw_gennum -1\n");
}
/// JOE `bwgen` paint loops → Zig `bwGetto` / `lgen` / `gennum`.
///
/// Prefer `zig_bw_bwgen_entry` for full setup+loops+cursor. Paints top→bottom
/// from `top` (no cursor-first/`pprevl` pass) and `prm`s the walk pointer.
/// Returns `0` on success, `-1` to fall back to C loops.
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

    // Top → bottom, one buffer line per screen row. Do not abort on `have`:
    // a post-paste invalidate poisons every shadow cell, and a mid-window
    // typeahead abort would leave the physical screen showing a mix of new
    // rows and stale ones (repeated blocks / leftover status).
    _ = mid_y;
    var y = win_y;
    while (y != bot) : (y += 1) {
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
    const buf_line = ctx.top_line + y - ctx.win_y;
    // Always seek, even when the row is clean. Skipping getto leaves `p` on
    // an old line so the next dirty row paints the wrong buffer text.
    const p = bwGetto(p_in, ctx.cursor, ctx.top, buf_line);
    if (ctx.linchg == 0 and ctx.updtab[@intCast(y)] == 0) return p;

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

extern fn markv(r: c_int) c_int;
extern var markb: ?*P;
extern var markk: ?*P;
export var marking: c_int = 0;

const BwgenMarkRange = struct {
    from: i64 = 0,
    to: i64 = 0,
    fromline: i64 = 0,
    toline: i64 = 0,
    dosquare: c_int = 0,
};

fn dirtyMarkingUpdtab(w: ?*BW) void {
    if (marking == 0 or zig_c_bw_is_maint_cur(w) == 0) return;
    const t = zig_c_bw_get_scrn(w) orelse return;
    const updtab = zig_c_bw_scrn_updtab(t) orelse return;
    const y = zig_c_bw_get_y(w);
    const h = zig_c_bw_get_h(w);
    if (h <= 0) return;
    zig_c_bw_msetI(updtab + @as(usize, @intCast(y)), 1, h);
}

/// Linear/square mark range only (no errbuf). Shared by `bwgen`/`bwgenh` setup.
fn resolveMarkRange(w: ?*BW) BwgenMarkRange {
    var r = BwgenMarkRange{};

    if (markv(0) != 0 and zig_c_bw_same_buf(w, markk) != 0) {
        const mb = markb orelse return r;
        const mk = markk orelse return r;
        if (square != 0) {
            r.from = zig_c_bw_pxcol(mb);
            r.to = zig_c_bw_pxcol(mk);
            r.dosquare = 1;
            r.fromline = zig_c_bw_pline_no(mb);
            r.toline = zig_c_bw_pline_no(mk);
        } else {
            r.from = zig_c_bw_pbyte(mb);
            r.to = zig_c_bw_pbyte(mk);
        }
        return r;
    }

    if (marking != 0 and zig_c_bw_is_maint_cur(w) != 0) {
        const mb = markb orelse return r;
        const cursor = zig_c_bw_get_cursor(w) orelse return r;
        if (zig_c_bw_same_buf(w, mb) == 0) return r;
        const cur_byte = zig_c_bw_pbyte(cursor);
        const mb_byte = zig_c_bw_pbyte(mb);
        if (cur_byte == mb_byte or r.from != 0) return r;
        if (square != 0) {
            const cur_xcol = zig_c_bw_pxcol(cursor);
            const mb_xcol = zig_c_bw_pxcol(mb);
            const cur_line = zig_c_bw_pline_no(cursor);
            const mb_line = zig_c_bw_pline_no(mb);
            r.from = @min(cur_xcol, mb_xcol);
            r.to = @max(cur_xcol, mb_xcol);
            r.fromline = @min(cur_line, mb_line);
            r.toline = @max(cur_line, mb_line);
            r.dosquare = 1;
        } else {
            r.from = @min(cur_byte, mb_byte);
            r.to = @max(cur_byte, mb_byte);
        }
    }
    return r;
}

fn resolveBwgenMarks(w: ?*BW) BwgenMarkRange {
    if (zig_c_bw_get_err(w)) |err| {
        var r = BwgenMarkRange{};
        const tmp = pdup(err, "bwgen") orelse return r;
        defer prm(tmp);
        zig_c_bw_p_goto_bol(tmp);
        r.from = zig_c_bw_pbyte(tmp);
        _ = pnextl(tmp);
        r.to = zig_c_bw_pbyte(tmp);
        return r;
    }
    return resolveMarkRange(w);
}

fn bwgenSetup(
    w: ?*BW,
    from: *i64,
    to: *i64,
    fromline: *i64,
    toline: *i64,
    dosquare: *c_int,
) c_int {
    if (w == null) return -1;
    if (zig_c_bw_get_scrn(w) == null) return -1;

    zig_c_bw_ensure_lattr_db(w);
    zig_c_bw_sync_viewmode(w);

    const marks = resolveBwgenMarks(w);
    from.* = marks.from;
    to.* = marks.to;
    fromline.* = marks.fromline;
    toline.* = marks.toline;
    dosquare.* = marks.dosquare;
    dirtyMarkingUpdtab(w);
    return 0;
}

fn bwgenhSetup(w: ?*BW, from: *i64, to: *i64) c_int {
    if (w == null) return -1;
    if (zig_c_bw_get_scrn(w) == null) return -1;

    const marks = resolveMarkRange(w);
    // Hex dump ignores square marks (former C zeroed the range).
    if (marks.dosquare != 0) {
        from.* = 0;
        to.* = 0;
    } else {
        from.* = marks.from;
        to.* = marks.to;
    }
    dirtyMarkingUpdtab(w);
    return 0;
}

fn applyBwgenViewCursor(w: ?*BW) void {
    if (zig_c_bw_get_viewmode(w) == 0) return;
    const cursor = zig_c_bw_get_cursor(w) orelse return;
    const buf_line = zig_c_bw_pline_no(cursor);

    const tmp = pdup(cursor, "zig_bw_bwgen_entry_cursor") orelse return;
    defer prm(tmp);
    zig_c_bw_p_goto_bol(tmp);
    const cursor_offset = zig_c_bw_pbyte(cursor) - zig_c_bw_pbyte(tmp);

    const xcol = zig_bw_vm_display_col(buf_line, cursor_offset);
    if (xcol < 0) return;
    zig_c_bw_set_cursor_xcol(w, xcol);
}

/// Thin `bwgen` entry (Path A): lattr/viewmode/mark setup + paint loops +
/// Feature 1.10 cursor. Mark setup is Zig-owned (thin C field accessors).
///
/// Returns `0` on success, `-1` to fall back to C `bwgen`.
pub export fn zig_bw_bwgen_entry(w: ?*BW, linums: c_int, linchg: c_int) c_int {
    if (w == null) return -1;

    var from: i64 = 0;
    var to: i64 = 0;
    var fromline: i64 = 0;
    var toline: i64 = 0;
    var dosquare: c_int = 0;
    if (bwgenSetup(w, &from, &to, &fromline, &toline, &dosquare) < 0)
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

/// Thin `bwgenh` entry (Path A): Zig-owned mark setup + hex paint.
/// Returns `0` or `-1` fallback.
pub export fn zig_bw_bwgenh_entry(w: ?*BW) c_int {
    if (w == null) return -1;

    var from: i64 = 0;
    var to: i64 = 0;
    if (bwgenhSetup(w, &from, &to) < 0) return -1;

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
        bg_text,
        bg_linum,
        bg_curlinum,
        bg_cursor,
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
    if (t == null or screen == null or attr_row == null) return -1;
    if (line == null or line_len < 0) return -1;
    if (x1 <= x0) return -1;
    if (charmap == null or charmap.?.type == 0) return -1;
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
/// - `-1` — hard failure (C aborts)
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
    in_hide: ?[*]u8,
    in_hide_len: c_int,
    in_subst: ?[*]c_int,
    in_subst_len: c_int,
    in_urls: ?[*]?[*:0]u8,
    in_urls_len: c_int,
    visiblews: c_int,
    do_square: c_int,
    ansi: c_int,
) c_int {
    if (t == null or screen == null or attr_row == null or p == null) return -1;
    if (x1 <= x0) return -1;
    if (charmap == null) return -1;
    const byte_mode = charmap.?.type == 0;

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

        // Edit-mode counterpart of the Feature 4.2.1(d) fix in
        // `zig_bw_lgen_view` (`isIndentedCodeAllowed`): `md.jsf`'s own DFA
        // has the identical "4+ leading whitespace" shape check with no
        // cross-line context (its `line_start` dispatch is memoryless —
        // every line re-decides independently, see the state chain
        // `maybe_code`→`maybe_code2`→`maybe_code3`→`maybe_code4`), so it
        // *also* wrongly tints an ordinary list-item continuation line as
        // an indented code block. Unlike viewmode, nothing runs after this
        // `parse` call to correct it here, so the fix has to happen at
        // this shared, generic call site — gated strictly to markdown
        // syntax so no other language's highlighting is touched. Re-parses
        // from `:idle` (see `mdIdleStateNo`'s doc comment) rather than a
        // flat `defatr` reset, so inline constructs within the line (code
        // spans, emphasis, links) still get their own correct
        // classification instead of being flattened to plain text too.
        if (syntaxNameIsMd(syntax)) {
            const buf_line = zig_c_bw_pline_no(p);
            var edit_tmp: [1024]u8 = undefined;
            const rl = bwReadLine(p, buf_line, &edit_tmp, @intCast(edit_tmp.len));
            if (rl >= 0) {
                const cur_line: []const u8 = edit_tmp[0..@intCast(rl)];
                const tab_u_edit: u16 = if (tab <= 0) 8 else @intCast(tab);
                if (render.looksLikeIndentedCode(cur_line, tab_u_edit) and
                    !isIndentedCodeAllowed(p, buf_line, cur_line, tab_u_edit))
                {
                    var reset_done = false;
                    if (mdIdleStateNo(syntax)) |idle_no| {
                        if (pdup(p, "zig_bw_lgen_idle_reparse")) |idle_scratch| {
                            defer prm(idle_scratch);
                            zig_c_bw_pline(idle_scratch, buf_line);
                            zig_c_bw_p_goto_bol(idle_scratch);
                            _ = parse(syntax, idle_scratch, .{ .stack = null, .delim_stack = null, .saved_s = null, .state = idle_no }, charmap);
                            reset_done = true;
                        }
                    }
                    if (!reset_done and attr_buf != null and attr_size > 0) {
                        const reset_n: usize = @min(@as(usize, @intCast(rl)), @as(usize, @intCast(attr_size)));
                        var ri: usize = 0;
                        while (ri < reset_n) : (ri += 1) attr_buf[ri] = defatr;
                    }
                }
            }
        }
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
    // `bwgen` already scopes square marks to mark lines (passes from=to=0 off-line).
    if (from != to and content.len > 0 and do_square == 0) {
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
            if (in_hide != null and in_hide_len > 0) {
                const hn = @min(n, @as(usize, @intCast(in_hide_len)));
                if (hn == n) break :blk in_hide.?[0..hn];
                const padded = alloc.alloc(u8, n) catch return -1;
                @memset(padded, 0);
                @memcpy(padded[0..hn], in_hide.?[0..hn]);
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
        if (in_subst != null and in_subst_len > 0) {
            const sn = @min(n, @as(usize, @intCast(in_subst_len)));
            var i: usize = 0;
            while (i < sn) : (i += 1) {
                const v = in_subst.?[i];
                if (v > 0) subst[i] = @intCast(v);
            }
        }
        subst_owned = subst;

        const links = alloc.alloc(?[]const u8, n) catch return -1;
        @memset(links, null);
        if (in_urls != null and in_urls_len > 0) {
            const un = @min(n, @as(usize, @intCast(in_urls_len)));
            var i: usize = 0;
            while (i < un) : (i += 1) {
                if (in_urls.?[i]) |up| links[i] = std.mem.span(up);
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
    if (from != to and paint_content.len > 0 and do_square != 0) {
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
        applySquareMarkInverse(mutable, paint_content, tab_u16, from, to, byte_mode, view_ptr);
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

        if (preparsed) current_url = emitOsc8Link(t, current_url, cell.url);

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
    if (preparsed) _ = emitOsc8Link(t, current_url, null);
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
///
/// `outatr` (UTF-8 path) doesn't write a character immediately — it stages
/// it in `outatr_build` and only flushes on the *next* `outatr` call (or an
/// explicit `outatr_complete`), so a character painted right before a link
/// transition is still pending when this function's `ttputs` calls run.
/// Without flushing first, the OSC 8 escape bytes land in the output stream
/// ahead of that still-buffered character instead of wrapping it — the link
/// opens, a stale/off-by-one character flushes, then the link closes before
/// the character it was meant to wrap is even written. `outatr_complete(t)`
/// forces that flush first so the escape always brackets the right glyph.
fn emitOsc8Link(t: ?*SCRN, old: ?[]const u8, new_url: ?[]const u8) ?[]const u8 {
    const same = blk: {
        if (old == null and new_url == null) break :blk true;
        if (old == null or new_url == null) break :blk false;
        break :blk std.mem.eql(u8, old.?, new_url.?);
    };
    if (same) return old;

    outatr_complete(t);

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
///
/// `view`, when set, must agree with the same collapsed column model
/// `lgenUnits` (plan §4) paints with: a hidden byte with no substitute
/// contributes zero columns and is never marked inverse (nothing paints
/// there to invert). Without this, square-mark columns would be computed
/// against the pre-collapse byte-per-column model while the paint loop
/// uses the post-collapse one, and a selection inside a concealed line
/// would land on the wrong glyphs.
fn applySquareMarkInverse(attrs: []Attribute, line: []const u8, tab: u16, from: i64, to: i64, byte_mode: bool, view: ?*const ViewTables) void {
    if (from == to) return;
    const t: i64 = if (tab == 0) 1 else tab;
    var col: i64 = 0;
    var i: usize = 0;
    while (i < line.len and i < attrs.len) {
        const b = line[i];
        if (b == '\n' or b == '\r') break;
        if (view) |vt| {
            if (vt.subAt(i) == 0 and vt.isHidden(i)) {
                i += 1;
                continue;
            }
        }
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
    applySquareMarkInverse(&attrs, "ab\tc", 4, 1, 4, false, null);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(attrs[1].inverse);
    try std.testing.expect(attrs[2].inverse);
    try std.testing.expect(!attrs[3].inverse);
}

test "applySquareMarkInverse tab excluded when end past to" {
    var attrs = [_]Attribute{.{}} ** 3;
    // "\tX" tab=8, from=2 to=5: tcol=8 not in (2,5] → unselected
    applySquareMarkInverse(&attrs, "\tX", 8, 2, 5, false, null);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(!attrs[1].inverse);
}

test "applySquareMarkInverse covers UTF-8 start column" {
    const line = "a\u{00e9}b";
    var attrs = [_]Attribute{.{}} ** 4;
    applySquareMarkInverse(&attrs, line, 8, 1, 2, false, null);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(attrs[1].inverse);
    try std.testing.expect(attrs[2].inverse);
    try std.testing.expect(!attrs[3].inverse);
}

test "applySquareMarkInverse uses collapsed columns when view is set (plan §4 / R1.3)" {
    // "# Hi": '#' and ' ' hidden at zero width, so 'H' is at collapsed
    // column 0 and 'i' at column 1 — not their raw byte indices (2, 3).
    const line = "# Hi";
    var tables = ViewTables.init(std.testing.allocator);
    defer tables.deinit();
    try render.analyzeLine(&tables, line, null);

    var attrs = [_]Attribute{.{}} ** 4;
    // Select display columns [0, 1): should mark only 'H' (byte 2).
    applySquareMarkInverse(&attrs, line, 8, 0, 1, false, &tables);
    try std.testing.expect(!attrs[0].inverse); // '#' — hidden, never marked
    try std.testing.expect(!attrs[1].inverse); // ' ' — hidden, never marked
    try std.testing.expect(attrs[2].inverse); // 'H' — collapsed col 0, in range
    try std.testing.expect(!attrs[3].inverse); // 'i' — collapsed col 1, out of range

    // Selecting [1, 2) should mark only 'i', not 'H'.
    var attrs2 = [_]Attribute{.{}} ** 4;
    applySquareMarkInverse(&attrs2, line, 8, 1, 2, false, &tables);
    try std.testing.expect(!attrs2[0].inverse);
    try std.testing.expect(!attrs2[1].inverse);
    try std.testing.expect(!attrs2[2].inverse); // 'H' now out of range
    try std.testing.expect(attrs2[3].inverse); // 'i' now in range
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
    try std.testing.expectEqual(@as(?[]const u8, u), emitOsc8Link(null, u, u));
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

const gap_types = @import("gapbuffer/types.zig");
/// Direct import (same module graph, no cycle: buffer.zig doesn't import
/// bw_lgen.zig) so paint can watch `vm_content_generation` for cache drops.
const gapbuffer_mod = @import("gapbuffer/buffer.zig");
const GapB = gap_types.B;
const GapP = gap_types.P;
const GapOptions = gap_types.OPTIONS;

const Kbd = opaque {};
const Kmap = opaque {};

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;

/// C `struct watom` (see `joe/w.h`); only `what` is read here.
const Watom = extern struct {
    context: ?*anyopaque,
    disp: ?*anyopaque,
    follow: ?*anyopaque,
    abort: ?*anyopaque,
    rtn: ?*anyopaque,
    type: ?*anyopaque,
    resize: ?*anyopaque,
    move: ?*anyopaque,
    ins: ?*anyopaque,
    del: ?*anyopaque,
    what: c_int,
};

const WinLink = extern struct {
    next: ?*WinRec,
    prev: ?*WinRec,
};

/// C `struct window` layout (see `joe/w.h`); size-checked against live ABI.
const WinRec = extern struct {
    link: WinLink,
    t: ?*Screen,
    x: isize,
    y: isize,
    w: isize,
    h: isize,
    ny: isize,
    nh: isize,
    reqh: isize,
    fixed: isize,
    hh: isize,
    win: ?*WinRec,
    main: ?*WinRec,
    orgwin: ?*WinRec,
    curx: isize,
    cury: isize,
    kbd: ?*Kbd,
    watom: ?*const Watom,
    object: ?*anyopaque,
    msgt: ?[*:0]const u8,
    msgb: ?[*:0]const u8,
    huh: ?[*:0]const u8,
    notify: ?*c_int,
    bstack: ?*anyopaque,
};

const BwSaved = extern struct {
    ww: c_int,
    ai: c_int,
    sp: c_int,
};

/// C `struct bw` layout (see `joe/bw.h`); size-checked against live ABI.
const BwRec = extern struct {
    parent: ?*WinRec,
    b: ?*GapB,
    top: ?*GapP,
    cursor: ?*GapP,
    offset: i64,
    t: ?*Screen,
    h: isize,
    w: isize,
    x: isize,
    y: isize,
    o: GapOptions,
    object: ?*anyopaque,
    lincols: c_int,
    curlin: i64,
    top_changed: c_int,
    db: ?*anyopaque,
    shell_flag: c_int,
    pasting: c_int,
    last_viewmode: c_int,
    saved: BwSaved,
};

/// C `struct screen` layout (see `joe/w.h`); size-checked against live ABI.
const ScreenRec = extern struct {
    t: ?*SCRN,
    wind: isize,
    topwin: ?*WinRec,
    curwin: ?*WinRec,
    w: isize,
    h: isize,
};

/// C `struct utf8_sm` (see `joe/utf8.h`).
const Utf8SmRec = extern struct {
    buf: [8]u8,
    ptr: isize,
    state: c_int,
    accu: c_int,
};

/// C `struct vt_context` (see `joe/vt.h`); size-checked against live ABI.
const VtRec = extern struct {
    state: c_int,
    buf: [1024]u8,
    bufx: isize,
    argv: [3]isize,
    argc: isize,
    top: ?*anyopaque,
    height: isize,
    width: isize,
    regn_top: isize,
    regn_bot: isize,
    vtcur: ?*GapP,
    b: ?*GapB,
    kbd: ?*Kbd,
    attr: c_int,
    utf8_sm: Utf8SmRec,
};

comptime {
    if (@sizeOf(WinRec) != 200) @compileError("WinRec size mismatch");
    if (@sizeOf(BwRec) != 488) @compileError("BwRec size mismatch");
    if (@sizeOf(GapB) != 632) @compileError("GapB size mismatch");
    if (@sizeOf(GapP) != 112) @compileError("GapP size mismatch");
    if (@sizeOf(GapOptions) != 344) @compileError("GapOptions size mismatch");
    if (@sizeOf(ScreenRec) != 48) @compileError("ScreenRec size mismatch");
    if (@sizeOf(Utf8SmRec) != 24) @compileError("Utf8SmRec size mismatch");
    if (@sizeOf(VtRec) != 1168) @compileError("VtRec size mismatch");
    if (@sizeOf(Watom) != 88) @compileError("Watom size mismatch");
}

extern var staen: c_int;
extern var errbuf: ?*B;
extern fn rmkbd(k: ?*Kbd) void;
extern fn mkkbd(kmap: ?*Kmap) ?*Kbd;
extern fn kmap_getcontext(name: ?[*:0]const u8) ?*Kmap;
extern fn brm(b: ?*B) void;

fn asBw(w: ?*BW) *BwRec {
    return @ptrCast(@alignCast(w.?));
}

fn asWin(w: ?*W) *WinRec {
    return @ptrCast(@alignCast(w.?));
}

fn asB(b: ?*B) *GapB {
    return @ptrCast(@alignCast(b.?));
}

fn asScreen(t: ?*Screen) *ScreenRec {
    return @ptrCast(@alignCast(t.?));
}

fn asP(p: ?*P) *GapP {
    return @ptrCast(@alignCast(p.?));
}

extern var maint: ?*Screen;
extern fn vt_resize(vt: ?*anyopaque, top: ?*P, height: isize, width: isize) void;
extern fn ttstsz(fd: c_int, w: isize, h: isize) void;

fn zig_c_bw_pbyte(p: ?*P) i64 {
    return if (p) |pp| asP(pp).byte else 0;
}
fn zig_c_bw_pline_no(p: ?*P) i64 {
    return if (p) |pp| asP(pp).line else -1;
}
fn zig_c_bw_pxcol(p: ?*P) i64 {
    return if (p) |pp| asP(pp).xcol else 0;
}
fn zig_c_bw_set_xcol(p: ?*P, xcol: i64) void {
    if (p == null) return;
    const pp = asP(p);
    pp.xcol = xcol;
    pp.valcol = 1;
}
fn zig_c_bw_bof(p: ?*P) ?*P {
    if (p == null) return null;
    const b = asP(p).b orelse return null;
    return @ptrCast(b.bof);
}
fn zig_c_bw_eof_line(p: ?*P) i64 {
    if (p == null) return -1;
    const b = asP(p).b orelse return -1;
    const eof = b.eof orelse return -1;
    return eof.line;
}

fn zig_c_bw_get_top(bw: ?*BW) ?*P {
    return if (bw) |w| @ptrCast(asBw(w).top) else null;
}
fn zig_c_bw_get_cursor(bw: ?*BW) ?*P {
    return if (bw) |w| @ptrCast(asBw(w).cursor) else null;
}
fn zig_c_bw_get_y(bw: ?*BW) isize {
    return if (bw) |w| asBw(w).y else 0;
}
fn zig_c_bw_get_x(bw: ?*BW) isize {
    return if (bw) |w| asBw(w).x else 0;
}
fn zig_c_bw_get_h(bw: ?*BW) isize {
    return if (bw) |w| asBw(w).h else 0;
}
fn zig_c_bw_get_w(bw: ?*BW) isize {
    return if (bw) |w| asBw(w).w else 0;
}
fn zig_c_bw_get_offset(bw: ?*BW) i64 {
    return if (bw) |w| asBw(w).offset else 0;
}
fn zig_c_bw_set_offset(bw: ?*BW, off: i64) void {
    if (bw) |w| asBw(w).offset = off;
}
fn zig_c_bw_get_top_line(bw: ?*BW) i64 {
    if (bw == null) return 0;
    return if (asBw(bw).top) |top| top.line else 0;
}
fn zig_c_bw_get_tab(bw: ?*BW) c_int {
    if (bw == null) return 8;
    const tab = asBw(bw).o.tab;
    return if (tab <= 0) 8 else @intCast(tab);
}
fn zig_c_bw_get_syntax(bw: ?*BW) ?*HighSyntax {
    return if (bw) |w| @ptrCast(asBw(w).o.syntax) else null;
}
fn zig_c_bw_get_charmap(bw: ?*BW) ?*Charmap {
    if (bw == null) return null;
    const b = asBw(bw).b orelse return null;
    return @ptrCast(b.o.charmap);
}
fn zig_c_bw_get_hiline(bw: ?*BW) c_int {
    return if (bw != null and asBw(bw).o.hiline != 0) 1 else 0;
}
fn zig_c_bw_get_linums(bw: ?*BW) c_int {
    return if (bw != null and asBw(bw).o.linums != 0) 1 else 0;
}
fn zig_c_bw_get_viewmode(bw: ?*BW) c_int {
    return if (bw != null and asBw(bw).o.viewmode != 0) 1 else 0;
}
fn zig_c_bw_get_visiblews(bw: ?*BW) c_int {
    return if (bw != null and asBw(bw).o.visiblews != 0) 1 else 0;
}
fn zig_c_bw_get_ansi(bw: ?*BW) c_int {
    return if (bw != null and asBw(bw).o.ansi != 0) 1 else 0;
}
fn zig_c_bw_b_eof_line(bw: ?*BW) i64 {
    if (bw == null) return 0;
    const b = asBw(bw).b orelse return 0;
    const eof = b.eof orelse return 0;
    return eof.line;
}
fn zig_c_bw_get_scrn(bw: ?*BW) ?*SCRN {
    if (bw == null) return null;
    const t = asBw(bw).t orelse return null;
    return asScreen(@ptrCast(t)).t;
}
fn zig_c_bw_scr_w(bw: ?*BW) isize {
    // Pitch of `SCRN.scrn` / `attr` is terminal columns (`co`), not Screen.w.
    const t = zig_c_bw_get_scrn(bw) orelse return 0;
    return asScrn(t).co;
}
fn zig_c_bw_get_err(bw: ?*BW) ?*P {
    if (bw == null or errbuf == null) return null;
    const b = asBw(bw).b orelse return null;
    if (@intFromPtr(b) != @intFromPtr(errbuf)) return null;
    return @ptrCast(b.err);
}
fn zig_c_bw_same_buf(bw: ?*BW, p: ?*P) c_int {
    if (bw == null or p == null) return 0;
    const pb = asP(p).b;
    return if (pb != null and @intFromPtr(pb) == @intFromPtr(asBw(bw).b)) 1 else 0;
}
fn zig_c_bw_is_maint_cur(bw: ?*BW) c_int {
    if (bw == null or maint == null) return 0;
    const curwin = asScreen(maint).curwin orelse return 0;
    const obj = curwin.object orelse return 0;
    return if (@intFromPtr(obj) == @intFromPtr(bw)) 1 else 0;
}
fn zig_c_bw_get_cursor_xcol(bw: ?*BW) i64 {
    if (bw == null) return 0;
    return if (asBw(bw).cursor) |cur| cur.xcol else 0;
}
fn zig_c_bw_set_cursor_xcol(bw: ?*BW, xcol: i64) void {
    if (bw == null) return;
    if (asBw(bw).cursor) |cur| {
        cur.xcol = xcol;
        cur.valcol = 1;
    }
}
fn zig_c_bw_set_pos(bw: ?*BW, x: isize, y: isize) void {
    if (bw == null) return;
    const w = asBw(bw);
    w.x = x;
    w.y = y;
}
fn zig_c_bw_set_size(bw: ?*BW, wi: isize, he: isize) void {
    if (bw == null) return;
    const w = asBw(bw);
    w.w = wi;
    w.h = he;
}
fn zig_c_bw_dirty_grown_rows(bw: ?*BW, old_h: isize, new_h: isize) void {
    if (bw == null) return;
    const w = asBw(bw);
    if (w.y == -1) return;
    const scrn = zig_c_bw_get_scrn(bw) orelse return;
    const updtab = zig_c_bw_scrn_updtab(scrn) orelse return;
    if (new_h > old_h) {
        const dest = updtab + @as(usize, @intCast(w.y + old_h));
        zig_c_bw_msetI(dest, 1, new_h - old_h);
    }
}
fn zig_c_bw_resz_vt_if_master(bw: ?*BW, wi: isize, he: isize) void {
    if (bw == null) return;
    const w = asBw(bw);
    const b = w.b orelse return;
    const parent = w.parent orelse return;
    if (b.vt == null or b.pid == 0) return;
    var master: ?*BW = null;
    if (zig_bw_vtmaster(@ptrCast(parent.t), @ptrCast(b), &master) < 0) return;
    if (master == null or @intFromPtr(master) != @intFromPtr(bw)) return;
    vt_resize(b.vt, @ptrCast(w.top), he, wi);
    ttstsz(b.out, wi, he);
}

const ScrnRec = @import("scrn.zig").SCRN;
fn asScrn(t: ?*SCRN) *ScrnRec {
    return @ptrCast(@alignCast(t.?));
}

const LattrDb = extern struct {
    next: ?*LattrDb,
    syn: ?*anyopaque,
};

extern fn pisbol(p: ?*P) c_int;
extern fn p_goto_bol(p: ?*P) ?*P;
extern fn pset(d: ?*P, s: ?*P) ?*P;
extern fn pline(p: ?*P, line: i64) ?*P;
extern fn pgoto(p: ?*P, loc: i64) ?*P;
extern fn pbkwd(p: ?*P, n: i64) ?*P;
extern fn pcol(p: ?*P, goalcol: i64) ?*P;
extern fn nscrldn(t: ?*SCRN, top: isize, bot: isize, amnt: isize) void;
extern fn nscrlup(t: ?*SCRN, top: isize, bot: isize, amnt: isize) void;
extern fn msetI(dest: ?*anyopaque, c: c_int, sz: isize) ?*anyopaque;
extern fn updall() void;
extern fn scrn_invalidate(t: ?*SCRN) void;
extern fn find_lattr_db(b: ?*B, y: ?*anyopaque) ?*LattrDb;
extern fn lattr_get(db: ?*anyopaque, syn: ?*anyopaque, p: ?*P, line: isize) HighlightState;
extern var locale_map: ?*Charmap;
extern fn from_uni(cset: ?*Charmap, c: c_int) c_int;

fn zig_c_bw_pisbol(p: ?*P) c_int {
    return if (p != null) pisbol(p) else 1;
}
fn zig_c_bw_p_goto_bol(p: ?*P) void {
    if (p != null) _ = p_goto_bol(p);
}
fn zig_c_bw_pset(d: ?*P, s: ?*P) void {
    if (d != null and s != null) _ = pset(d, s);
}
fn zig_c_bw_pline(p: ?*P, line: i64) void {
    if (p != null) _ = pline(p, line);
}
fn zig_c_bw_pgoto(p: ?*P, loc: i64) void {
    if (p != null) _ = pgoto(p, loc);
}
fn zig_c_bw_pbkwd(p: ?*P, n: i64) void {
    if (p != null) _ = pbkwd(p, n);
}
fn zig_c_bw_pcol(w: ?*BW, xcol: i64) void {
    if (w == null) return;
    if (asBw(w).cursor) |cur| _ = pcol(@ptrCast(cur), xcol);
}
fn zig_c_bw_nscrldn(t: ?*SCRN, top: isize, bot: isize, amnt: isize) void {
    nscrldn(t, top, bot, amnt);
}
fn zig_c_bw_nscrlup(t: ?*SCRN, top: isize, bot: isize, amnt: isize) void {
    nscrlup(t, top, bot, amnt);
}
fn zig_c_bw_msetI(dest: ?[*]c_int, c: c_int, sz: isize) void {
    _ = msetI(@ptrCast(dest), c, sz);
}
fn zig_c_bw_updall() void {
    updall();
}
fn zig_c_bw_scrn_cells(t: ?*SCRN) ?[*][COMPOSE]c_int {
    return if (t) |tt| @ptrCast(asScrn(tt).scrn) else null;
}
fn zig_c_bw_scrn_attr(t: ?*SCRN) ?[*]c_int {
    return if (t) |tt| asScrn(tt).attr else null;
}
fn zig_c_bw_scrn_updtab(t: ?*SCRN) ?[*]c_int {
    return if (t) |tt| asScrn(tt).updtab else null;
}
fn zig_c_bw_scrn_compose(t: ?*SCRN) ?[*]c_int {
    return if (t) |tt| asScrn(tt).compose else null;
}
fn zig_c_bw_get_palette(t: ?*SCRN, out_len: ?*c_int) ?[*]c_int {
    if (out_len) |ol| ol.* = 0;
    if (t == null) return null;
    const pal = asScrn(t).palette;
    if (pal == null) return null;
    if (out_len) |ol| ol.* = 256;
    return pal;
}
fn zig_c_bw_ensure_lattr_db(w: ?*BW) void {
    if (w == null) return;
    const bw = asBw(w);
    if (bw.o.highlight == 0 or bw.o.syntax == null) return;
    const need = if (bw.db) |db_ptr| blk: {
        const db: *LattrDb = @ptrCast(@alignCast(db_ptr));
        break :blk db.syn != bw.o.syntax;
    } else true;
    if (need) bw.db = @ptrCast(find_lattr_db(@ptrCast(bw.b), bw.o.syntax));
}
fn zig_c_bw_sync_viewmode(w: ?*BW) void {
    if (w == null) return;
    const bw = asBw(w);
    const scrn = zig_c_bw_get_scrn(w) orelse return;
    if (bw.o.viewmode != bw.last_viewmode) {
        scrn_invalidate(scrn);
        bw.last_viewmode = bw.o.viewmode;
    }
}
fn zig_c_bw_get_highlight_state(w: ?*BW, p: ?*P, line: i64) HighlightState {
    const invalid = HighlightState{ .stack = null, .delim_stack = null, .saved_s = null, .state = -1 };
    if (w == null) return invalid;
    const bw = asBw(w);
    if (bw.o.highlight == 0 or bw.o.syntax == null) return invalid;
    return lattr_get(bw.db, bw.o.syntax, p, @intCast(line));
}
fn zig_c_bw_locale_utf8() c_int {
    const lm = locale_map orelse return 0;
    return if (lm.type != 0) 1 else 0;
}
fn zig_c_bw_from_uni(cp: c_int) c_int {
    return if (locale_map) |lm| from_uni(lm, cp) else -1;
}

extern var watomtw: Watom;
extern fn set_file_pos_orphaned() void;

/// JOE `bwmk` body: bind window/buffer, reclaim orphan cursors or pdup bof, kbd.
fn bwMkInit(w_in: ?*BW, window_in: ?*W, b_in: ?*B, prompt: c_int) c_int {
    if (w_in == null or window_in == null or b_in == null) return -1;
    const w = asBw(w_in);
    const window = asWin(window_in);
    const b = asB(b_in);

    w.parent = window;
    w.b = b;
    if (prompt != 0 or (window.y == 0 and staen != 0) or window.h < 2) {
        w.y = window.y;
        w.h = window.h;
    } else {
        w.y = window.y + 1;
        w.h = window.h - 1;
    }
    if (b.oldcur != null) {
        w.top = b.oldtop;
        b.oldtop = null;
        if (w.top) |top| top.owner = null;
        w.cursor = b.oldcur;
        b.oldcur = null;
        if (w.cursor) |cur| cur.owner = null;
    } else {
        const top = pdup(@ptrCast(b.bof), "bwmk");
        const cur = pdup(@ptrCast(b.bof), "bwmk");
        if (top == null or cur == null) return -1;
        w.top = @ptrCast(@alignCast(top));
        w.cursor = @ptrCast(@alignCast(cur));
    }
    w.t = window.t;
    w.object = null;
    w.offset = 0;
    w.o = b.o;
    w.lincols = 0;
    w.curlin = 0;
    w.x = window.x;
    w.w = window.w;
    if (window == window.main) {
        rmkbd(window.kbd);
        const ctx: ?[*:0]const u8 = if (w.o.context) |c| @ptrCast(c) else null;
        window.kbd = mkkbd(kmap_getcontext(ctx));
    }
    if (w.top) |top| top.xcol = 0;
    if (w.cursor) |cur| cur.xcol = 0;
    w.top_changed = 1;
    w.db = null;
    w.shell_flag = 0;
    w.pasting = 0;
    w.last_viewmode = 0;
    w.saved = .{ .ww = 0, .ai = 0, .sp = 0 };
    return 0;
}

fn bwOrphit(bw_in: ?*BW) void {
    if (bw_in == null) return;
    const w = asBw(bw_in);
    const b = w.b orelse return;
    b.count += 1;
    b.orphan = 1;
    _ = pdupown(@ptrCast(w.cursor), @ptrCast(&b.oldcur), "orphit");
    _ = pdupown(@ptrCast(w.top), @ptrCast(&b.oldtop), "orphit");
}

fn bwIsSoleErrbuf(w_in: ?*BW) bool {
    if (w_in == null or errbuf == null) return false;
    const w = asBw(w_in);
    return w.b != null and @intFromPtr(w.b) == @intFromPtr(errbuf) and w.b.?.count == 1;
}

fn bwRmSavePos(w_in: ?*BW) void {
    if (w_in == null) return;
    const w = asBw(w_in);
    const b = w.b orelse return;
    const cur = w.cursor orelse return;
    const name: ?[*:0]const u8 = if (b.name) |n| @ptrCast(n) else null;
    set_file_pos(name, cur.line);
}

fn bwRmRelease(w_in: ?*BW) void {
    if (w_in == null) return;
    const w = asBw(w_in);
    if (w.top) |top| prm(@ptrCast(top));
    if (w.cursor) |cur| prm(@ptrCast(cur));
    if (w.b) |b| brm(@ptrCast(b));
    joe_free(@ptrCast(w));
}

/// Path A lifecycle: set BW origin. Returns `0` on success, `-1` to fall back.
pub export fn zig_bw_bwmove(w: ?*BW, x: isize, y: isize) c_int {
    if (w == null) return -1;
    zig_c_bw_set_pos(w, x, y);
    return 0;
}

/// Path A lifecycle: resize BW (+ dirty new rows + VT master resize).
pub export fn zig_bw_bwresz(w: ?*BW, wi: isize, he: isize) c_int {
    if (w == null) return -1;
    const old_h = zig_c_bw_get_h(w);
    zig_c_bw_dirty_grown_rows(w, old_h, he);
    zig_c_bw_set_size(w, wi, he);
    zig_c_bw_resz_vt_if_master(w, wi, he);
    return 0;
}

/// Path A lifecycle: allocate + init BW. On success writes `*out_bw` and returns `0`.
pub export fn zig_bw_bwmk(window: ?*W, b: ?*B, prompt: c_int, out_bw: ?*?*BW) c_int {
    if (window == null or b == null or out_bw == null) return -1;
    const mem = joe_malloc(@sizeOf(BwRec)) orelse return -1;
    const w: ?*BW = @ptrCast(mem);
    if (bwMkInit(w, window, b, prompt) < 0) {
        joe_free(mem);
        return -1;
    }
    out_bw.?.* = w;
    return 0;
}

/// Path A lifecycle: orphan buffer before `bwrm` when needed.
pub export fn zig_bw_orphit(bw: ?*BW) c_int {
    if (bw == null) return -1;
    bwOrphit(bw);
    return 0;
}

/// Path A lifecycle: destroy BW (errbuf orphan, save pos, release).
pub export fn zig_bw_bwrm(w: ?*BW) c_int {
    if (w == null) return -1;
    if (bwIsSoleErrbuf(w)) {
        // Use impl directly to avoid re-entering public `orphit`.
        bwOrphit(w);
    }
    bwRmSavePos(w);
    bwRmRelease(w);
    return 0;
}

/// Path A lifecycle: line-number gutter width (`linums` digit width + 2).
/// Returns width (`>= 0`), or `-1` to fall back to C.
pub export fn zig_bw_calclincols(bw: ?*BW) c_int {
    if (bw == null) return -1;
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

export var ustat_line: [*c]u8 = null;
extern fn brch(p: ?*P) c_int;
extern fn stagen(stalin: [*c]u8, bw: ?*BW, s: [*:0]const u8, fill: u8) [*c]u8;
extern fn msgnw(w: ?*W, s: [*c]const u8) void;
extern fn zdup(s: [*:0]const u8) ?[*:0]u8;
extern fn emit_string(f: ?*anyopaque, s: [*:0]const u8, len: isize) void;
extern fn parse_ws(pp: *[*c]const u8, cmt: c_int) c_int;
extern fn parse_off_t(pp: *[*c]const u8, buf: *i64) c_int;
extern fn parse_string(pp: *[*c]const u8, buf: [*]u8, len: isize) isize;
extern fn fprintf(f: ?*anyopaque, fmt: [*:0]const u8, ...) c_int;
extern fn fgets(buf: [*]u8, len: c_int, f: ?*anyopaque) ?*anyopaque;
export var restore_file_pos: c_int = 0;

const max_file_pos: usize = 20;

const FilePosEntry = struct {
    name: [*:0]u8,
    line: i64,
};

var file_pos_buf: [max_file_pos]FilePosEntry = undefined;
var file_pos_len: usize = 0;

fn filePosFreeEntry(e: FilePosEntry) void {
    joe_free(@ptrCast(e.name));
}

fn filePosNameEq(a: [*:0]const u8, b: [*:0]const u8) bool {
    return std.mem.orderZ(u8, a, b) == .eq;
}

/// Find or create an LRU entry. Index 0 = newest. Matches C: after insert, if
/// length reaches `MAX_FILE_POS` (20), evict oldest (leaving 19).
fn filePosFindOrCreate(name: [*:0]const u8) error{OutOfMemory}!usize {
    var i: usize = 0;
    while (i < file_pos_len) : (i += 1) {
        if (filePosNameEq(file_pos_buf[i].name, name)) {
            if (i != 0) {
                const e = file_pos_buf[i];
                var j = i;
                while (j > 0) : (j -= 1) {
                    file_pos_buf[j] = file_pos_buf[j - 1];
                }
                file_pos_buf[0] = e;
            }
            return 0;
        }
    }
    const dup = zdup(name) orelse return error.OutOfMemory;
    // Shift right; len is at most 19 before insert (eviction keeps it there).
    var j = file_pos_len;
    while (j > 0) : (j -= 1) {
        file_pos_buf[j] = file_pos_buf[j - 1];
    }
    file_pos_buf[0] = .{ .name = @ptrCast(dup), .line = 0 };
    file_pos_len += 1;
    if (file_pos_len == max_file_pos) {
        file_pos_len -= 1;
        filePosFreeEntry(file_pos_buf[file_pos_len]);
    }
    return 0;
}

/// Path A non-paint: get restored file position. Writes `*out` and returns `0`, or `-1` fallback.
pub export fn zig_bw_get_file_pos(name: ?[*:0]const u8, out: ?*i64) c_int {
    if (out == null) return -1;
    out.?.* = 0;
    const n = name orelse return 0;
    if (restore_file_pos == 0) return 0;
    const idx = filePosFindOrCreate(n) catch return -1;
    out.?.* = file_pos_buf[idx].line;
    return 0;
}

/// Path A non-paint: set restored file position (Zig-owned LRU DB).
pub export fn zig_bw_set_file_pos(name: ?[*:0]const u8, pos: i64) c_int {
    const n = name orelse return 0;
    const idx = filePosFindOrCreate(n) catch return -1;
    file_pos_buf[idx].line = pos;
    return 0;
}

/// Path A non-paint: save file-pos database (oldest → newest, then `done`).
pub export fn zig_bw_save_file_pos(f: ?*FILE) c_int {
    const fp = f orelse return -1;
    var i = file_pos_len;
    while (i > 0) {
        i -= 1;
        const e = file_pos_buf[i];
        _ = fprintf(@ptrCast(fp), "\t%lld ", @as(c_longlong, @intCast(e.line)));
        emit_string(@ptrCast(fp), e.name, @intCast(std.mem.len(e.name)));
        _ = fprintf(@ptrCast(fp), "\n");
    }
    _ = fprintf(@ptrCast(fp), "done\n");
    return 0;
}

/// Path A non-paint: load file-pos database until `done`.
pub export fn zig_bw_load_file_pos(f: ?*FILE) c_int {
    const fp = f orelse return -1;
    var buf: [1024]u8 = undefined;
    while (fgets(@ptrCast(&buf), @intCast(buf.len - 1), @ptrCast(fp)) != null) {
        const line = std.mem.sliceTo(@as([*:0]u8, @ptrCast(&buf)), 0);
        if (std.mem.eql(u8, line, "done\n")) break;
        var p: [*c]const u8 = @ptrCast(&buf);
        _ = parse_ws(&p, '#');
        var pos: i64 = 0;
        if (parse_off_t(&p, &pos) == 0) {
            _ = parse_ws(&p, '#');
            var name_buf: [1024]u8 = undefined;
            if (parse_string(&p, &name_buf, name_buf.len) > 0) {
                _ = zig_bw_set_file_pos(@ptrCast(&name_buf), pos);
            }
        }
    }
    return 0;
}

/// Path A non-paint: snapshot positions for all TW windows + orphans.
pub export fn zig_bw_set_file_pos_all(t: ?*Screen) c_int {
    if (t == null) return -1;
    const screen = asScreen(t);
    var w = screen.topwin orelse return 0;
    const start = w;
    while (true) {
        if (w.watom == &watomtw) {
            if (w.object) |obj| {
                const bw: *BwRec = @ptrCast(@alignCast(obj));
                if (bw.b) |b| {
                    if (bw.cursor) |cur| {
                        const name: ?[*:0]const u8 = if (b.name) |n| @ptrCast(n) else null;
                        _ = zig_bw_set_file_pos(name, cur.line);
                    }
                }
            }
        }
        w = w.link.next orelse break;
        if (w == start) break;
    }
    set_file_pos_orphaned();
    return 0;
}

/// Path A non-paint: VT/TW master BW for buffer `b`. Writes `*out` (may be null).
pub export fn zig_bw_vtmaster(t: ?*Screen, b_in: ?*B, out: ?*?*BW) c_int {
    if (t == null or b_in == null or out == null) return -1;
    const screen = asScreen(t);
    const b = asB(b_in);
    var master: ?*BW = null;
    var w = screen.topwin orelse {
        out.?.* = null;
        return 0;
    };
    const start = w;
    while (true) {
        if (w.watom == &watomtw and w.y != -1) {
            if (w.object) |obj| {
                const bw: *BwRec = @ptrCast(@alignCast(obj));
                if (bw.b == b) {
                    // C: (!b->vt || b->vt->vtcur->byte == bw->cursor->byte)
                    const match = if (b.vt) |vt_ptr| blk: {
                        const vt: *VtRec = @ptrCast(@alignCast(vt_ptr));
                        break :blk vt.vtcur.?.byte == bw.cursor.?.byte;
                    } else true;
                    if (match) master = @ptrCast(bw);
                }
            }
        }
        w = w.link.next orelse break;
        if (w == start) break;
    }
    out.?.* = master;
    return 0;
}

/// JOE `WIND_BW`: require TW/PW window and return its BW object.
fn windBw(w_in: ?*W) ?*BW {
    if (w_in == null) return null;
    const win = asWin(w_in);
    const wa = win.watom orelse return null;
    if ((wa.what & (TYPETW | TYPEPW)) == 0) return null;
    return @ptrCast(win.object);
}

/// JOE `ustat` body: format status message for current BW and show via `msgnw`.
fn bwUstat(w_in: ?*W) c_int {
    const bw_ptr = windBw(w_in) orelse return -1;
    const bw = asBw(bw_ptr);
    const c = brch(@ptrCast(bw.cursor));
    const msg: [*:0]const u8 = if (c == NO_MORE_DATA) blk: {
        if (bw.o.zmsg) |m| break :blk @ptrCast(m);
        break :blk "** Line %r Col %c Offset %o(0x%O) **";
    } else blk: {
        if (bw.o.smsg) |m| break :blk @ptrCast(m);
        break :blk "** Line %r Col %c Offset %o(0x%O) %e %a(0x%A) Width %w **";
    };
    const msg_len = std.mem.len(msg);
    const fill: u8 = if (msg_len != 0) msg[msg_len - 1] else ' ';
    ustat_line = stagen(ustat_line, bw_ptr, msg, fill);
    msgnw(@ptrCast(bw.parent), ustat_line);
    return 0;
}

/// Path A non-paint: status-line command. Writes command rc to `*out_rc`.
pub export fn zig_bw_ustat(w: ?*W, k: c_int, out_rc: ?*c_int) c_int {
    _ = k;
    if (w == null or out_rc == null) return -1;
    out_rc.?.* = bwUstat(w);
    return 0;
}

/// Path A non-paint: crawl right (horizontal scroll/cursor).
pub export fn zig_bw_ucrawlr(w: ?*W, k: c_int, out_rc: ?*c_int) c_int {
    _ = k;
    if (w == null or out_rc == null) return -1;
    const bw = windBw(w);
    if (bw == null) {
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
    if (w == null or out_rc == null) return -1;
    const bw = windBw(w);
    if (bw == null) {
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

// ---------------------------------------------------------------------------
// Public JOE C ABI for `joe/bw.h` (formerly abort-wrappers in `joe/bw.c`).
// ---------------------------------------------------------------------------

pub export fn bwfllwh(thew: ?*W) void {
    if (thew == null) pathAAbort("Path A: zig_bw_bwfllwh -1\n");
    const win = asWin(thew);
    const w: ?*BW = @ptrCast(win.object);
    const bw = asBw(w);
    const top = bw.top orelse pathAAbort("Path A: zig_bw_bwfllwh -1\n");
    const cursor = bw.cursor orelse pathAAbort("Path A: zig_bw_bwfllwh -1\n");
    const scrn = zig_c_bw_get_scrn(w) orelse pathAAbort("Path A: zig_bw_bwfllwh -1\n");
    const updtab = zig_c_bw_scrn_updtab(scrn) orelse pathAAbort("Path A: zig_bw_bwfllwh -1\n");
    if (zig_bw_bwfllwh(@ptrCast(top), @ptrCast(cursor), scrn, updtab, bw.y, bw.h, bw.w, &bw.offset) >= 0)
        return;
    pathAAbort("Path A: zig_bw_bwfllwh -1\n");
}

pub export fn bwfllwt(thew: ?*W) void {
    if (thew == null) pathAAbort("Path A: zig_bw_bwfllwt -1\n");
    const win = asWin(thew);
    const w: ?*BW = @ptrCast(win.object);
    const bw = asBw(w);
    const top = bw.top orelse pathAAbort("Path A: zig_bw_bwfllwt -1\n");
    const cursor = bw.cursor orelse pathAAbort("Path A: zig_bw_bwfllwt -1\n");
    const scrn = zig_c_bw_get_scrn(w) orelse pathAAbort("Path A: zig_bw_bwfllwt -1\n");
    const updtab = zig_c_bw_scrn_updtab(scrn) orelse pathAAbort("Path A: zig_bw_bwfllwt -1\n");
    if (zig_bw_bwfllwt(@ptrCast(top), @ptrCast(cursor), scrn, updtab, bw.y, bw.h, bw.w, &bw.offset, &bw.curlin, bw.o.hiline) >= 0)
        return;
    pathAAbort("Path A: zig_bw_bwfllwt -1\n");
}

pub export fn bwfllw(w: ?*W) void {
    if (w == null) pathAAbort("Path A: bwfllw -1\n");
    const bw = asBw(@ptrCast(asWin(w).object));
    if (bw.o.hex != 0) bwfllwh(w) else bwfllwt(w);
}

pub export fn bwins(w: ?*BW, l: i64, n: i64, flg: c_int) void {
    if (w == null) pathAAbort("Path A: zig_bw_bwins -1\n");
    const bw = asBw(w);
    const scrn = zig_c_bw_get_scrn(w) orelse pathAAbort("Path A: zig_bw_bwins -1\n");
    const updtab = zig_c_bw_scrn_updtab(scrn) orelse pathAAbort("Path A: zig_bw_bwins -1\n");
    const srec = asScrn(scrn);
    const top = bw.top orelse pathAAbort("Path A: zig_bw_bwins -1\n");
    const b = bw.b orelse pathAAbort("Path A: zig_bw_bwins -1\n");
    const eof = b.eof orelse pathAAbort("Path A: zig_bw_bwins -1\n");
    const do_hl: c_int = if (bw.o.highlight != 0 and bw.o.syntax != null) 1 else 0;
    if (zig_bw_bwins(scrn, updtab, srec.sary, srec.li, bw.y, bw.h, top.line, eof.line, l, n, flg, do_hl) >= 0)
        return;
    pathAAbort("Path A: zig_bw_bwins -1\n");
}

pub export fn bwdel(w: ?*BW, l: i64, n: i64, flg: c_int) void {
    if (w == null) pathAAbort("Path A: zig_bw_bwdel -1\n");
    const bw = asBw(w);
    const scrn = zig_c_bw_get_scrn(w) orelse pathAAbort("Path A: zig_bw_bwdel -1\n");
    const updtab = zig_c_bw_scrn_updtab(scrn) orelse pathAAbort("Path A: zig_bw_bwdel -1\n");
    const top = bw.top orelse pathAAbort("Path A: zig_bw_bwdel -1\n");
    const b = bw.b orelse pathAAbort("Path A: zig_bw_bwdel -1\n");
    const eof = b.eof orelse pathAAbort("Path A: zig_bw_bwdel -1\n");
    const do_hl: c_int = if (bw.o.highlight != 0 and bw.o.syntax != null) 1 else 0;
    if (zig_bw_bwdel(scrn, updtab, bw.y, bw.h, top.line, eof.line, l, n, flg, do_hl) >= 0)
        return;
    pathAAbort("Path A: zig_bw_bwdel -1\n");
}

pub export fn viewmode_display_col(buf_line: i64, buf_offset: i64) i64 {
    return zig_bw_vm_display_col(buf_line, buf_offset);
}

pub export fn viewmode_cleanup() void {
    zig_bw_vm_cleanup();
}

pub export fn bwgenh(w: ?*BW) void {
    if (zig_bw_bwgenh_entry(w) >= 0) return;
    pathAAbort("Path A: zig_bw_bwgenh_entry returned -1\n");
}

pub export fn bwgen(w: ?*BW, linums: c_int, linchg: c_int) void {
    if (zig_bw_bwgen_entry(w, linums, linchg) >= 0) return;
    pathAAbort("Path A: zig_bw_bwgen_entry returned -1\n");
}

pub export fn bwmove(w: ?*BW, x: isize, y: isize) void {
    if (zig_bw_bwmove(w, x, y) >= 0) return;
    pathAAbort("Path A: zig_bw_bwmove -1\n");
}

pub export fn bwresz(w: ?*BW, wi: isize, he: isize) void {
    if (zig_bw_bwresz(w, wi, he) >= 0) return;
    pathAAbort("Path A: zig_bw_bwresz -1\n");
}

pub export fn bwmk(window: ?*W, b: ?*B, prompt: c_int) ?*BW {
    var zw: ?*BW = null;
    if (zig_bw_bwmk(window, b, prompt, &zw) >= 0) return zw;
    pathAAbort("Path A: zig_bw_bwmk -1\n");
}

pub export fn get_file_pos(name: ?[*:0]const u8) i64 {
    var zpos: i64 = 0;
    if (zig_bw_get_file_pos(name, &zpos) >= 0) return zpos;
    pathAAbort("Path A: zig_bw_get_file_pos -1\n");
}

pub export fn set_file_pos(name: ?[*:0]const u8, pos: i64) void {
    if (zig_bw_set_file_pos(name, pos) >= 0) return;
    pathAAbort("Path A: zig_bw_set_file_pos -1\n");
}

pub export fn save_file_pos(f: ?*FILE) void {
    if (zig_bw_save_file_pos(f) >= 0) return;
    pathAAbort("Path A: zig_bw_save_file_pos -1\n");
}

pub export fn load_file_pos(f: ?*FILE) void {
    if (zig_bw_load_file_pos(f) >= 0) return;
    pathAAbort("Path A: zig_bw_load_file_pos -1\n");
}

pub export fn set_file_pos_all(t: ?*Screen) void {
    if (zig_bw_set_file_pos_all(t) >= 0) return;
    pathAAbort("Path A: zig_bw_set_file_pos_all -1\n");
}

pub export fn vtmaster(t: ?*Screen, b: ?*B) ?*BW {
    var zm: ?*BW = null;
    if (zig_bw_vtmaster(t, b, &zm) >= 0) return zm;
    pathAAbort("Path A: zig_bw_vtmaster -1\n");
}

pub export fn bwrm(w: ?*BW) void {
    if (zig_bw_bwrm(w) >= 0) return;
    pathAAbort("Path A: zig_bw_bwrm -1\n");
}

pub export fn ustat(w: ?*W, k: c_int) c_int {
    var zrc: c_int = 0;
    if (zig_bw_ustat(w, k, &zrc) >= 0) return zrc;
    pathAAbort("Path A: zig_bw_ustat -1\n");
}

pub export fn ucrawlr(w: ?*W, k: c_int) c_int {
    var zrc: c_int = 0;
    if (zig_bw_ucrawlr(w, k, &zrc) >= 0) return zrc;
    pathAAbort("Path A: zig_bw_ucrawlr -1\n");
}

pub export fn ucrawll(w: ?*W, k: c_int) c_int {
    var zrc: c_int = 0;
    if (zig_bw_ucrawll(w, k, &zrc) >= 0) return zrc;
    pathAAbort("Path A: zig_bw_ucrawll -1\n");
}

pub export fn orphit(bw: ?*BW) void {
    if (zig_bw_orphit(bw) >= 0) return;
    pathAAbort("Path A: zig_bw_orphit -1\n");
}

pub export fn calclincols(bw: ?*BW) c_int {
    const z = zig_bw_calclincols(bw);
    if (z >= 0) return z;
    pathAAbort("Path A: zig_bw_calclincols -1\n");
}

pub export fn init_visiblews() void {
    if (zig_bw_init_visiblews() >= 0) return;
    pathAAbort("Path A: zig_bw_init_visiblews -1\n");
}
