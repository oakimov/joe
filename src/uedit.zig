//! Path A live port of JOE basic edit/motion commands (`joe/uedit.c`).
//!
//! First slice: `pgamnt` + simple cursor motions (`u_goto_{bol,eol,bof,eof}`,
//! `uuparw`/`udnarw`, `utos`/`ubos`). Remaining `uedit.c` stays linked until
//! later Path A slices retire it the same way `bw.c` was removed.

const std = @import("std");
const gap_types = @import("gapbuffer/types.zig");

const GapP = gap_types.P;
const GapB = gap_types.B;
const GapOptions = gap_types.OPTIONS;

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;

/// PgUp/PgDn lines to keep (`-pg`); owned here, still read by remaining C.
export var pgamnt: c_int = -1;

const Watom = extern struct {
    context: ?[*:0]const u8,
    disp: ?*const fn (?*anyopaque, c_int) callconv(.c) void,
    follow: ?*const fn (?*anyopaque) callconv(.c) void,
    abort: ?*const fn (?*anyopaque) callconv(.c) c_int,
    rtn: ?*const fn (?*anyopaque) callconv(.c) c_int,
    @"type": ?*const fn (?*anyopaque, c_int) callconv(.c) c_int,
    resize: ?*const fn (?*anyopaque, isize, isize) callconv(.c) void,
    move: ?*const fn (?*anyopaque, isize, isize) callconv(.c) void,
    ins: ?*const fn (?*anyopaque, ?*anyopaque, i64, i64, c_int) callconv(.c) void,
    del: ?*const fn (?*anyopaque, ?*anyopaque, i64, i64, c_int) callconv(.c) void,
    what: c_int,
};

const WinLink = extern struct {
    next: ?*WinRec,
    prev: ?*WinRec,
};

const WinRec = extern struct {
    link: WinLink,
    t: ?*anyopaque,
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
    kbd: ?*anyopaque,
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

const BwRec = extern struct {
    parent: ?*WinRec,
    b: ?*GapB,
    top: ?*GapP,
    cursor: ?*GapP,
    offset: i64,
    t: ?*anyopaque,
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

const Utf8SmRec = extern struct {
    buf: [8]u8,
    ptr: isize,
    state: c_int,
    accu: c_int,
};

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
    kbd: ?*anyopaque,
    attr: c_int,
    utf8_sm: Utf8SmRec,
};

comptime {
    if (@sizeOf(WinRec) != 200) @compileError("WinRec size mismatch");
    if (@sizeOf(BwRec) != 488) @compileError("BwRec size mismatch");
    if (@sizeOf(GapB) != 632) @compileError("GapB size mismatch");
    if (@sizeOf(GapP) != 112) @compileError("GapP size mismatch");
    if (@sizeOf(GapOptions) != 344) @compileError("GapOptions size mismatch");
    if (@sizeOf(VtRec) != 1168) @compileError("VtRec size mismatch");
    if (@sizeOf(Watom) != 88) @compileError("Watom size mismatch");
}

extern fn p_goto_bol(p: ?*GapP) ?*GapP;
extern fn p_goto_eol(p: ?*GapP) ?*GapP;
extern fn p_goto_bof(p: ?*GapP) ?*GapP;
extern fn p_goto_eof(p: ?*GapP) ?*GapP;
extern fn pbkwd(p: ?*GapP, n: i64) ?*GapP;
extern fn pfwrd(p: ?*GapP, n: i64) ?*GapP;
extern fn pset(n: ?*GapP, p: ?*GapP) ?*GapP;
extern fn pprevl(p: ?*GapP) ?*GapP;
extern fn pnextl(p: ?*GapP) ?*GapP;
extern fn pcol(p: ?*GapP, goalcol: i64) ?*GapP;
extern fn piscol(p: ?*GapP) i64;
extern fn pline(p: ?*GapP, line: i64) ?*GapP;
extern fn binsc(p: ?*GapP, c: c_int) ?*GapP;
extern fn pgetc(p: ?*GapP) c_int;

fn asWin(w: ?*anyopaque) *WinRec {
    return @ptrCast(@alignCast(w.?));
}

fn asBw(bw: ?*anyopaque) *BwRec {
    return @ptrCast(@alignCast(bw.?));
}

/// JOE `WIND_BW`: require TW/PW window and return its BW object.
fn windBw(w_in: ?*anyopaque) ?*BwRec {
    if (w_in == null) return null;
    const win = asWin(w_in);
    const wa = win.watom orelse return null;
    if ((wa.what & (TYPETW | TYPEPW)) == 0) return null;
    return @ptrCast(@alignCast(win.object orelse return null));
}

fn cursorOrNull(bw: *BwRec) ?*GapP {
    return bw.cursor;
}

/// Move cursor to beginning of line.
pub export fn u_goto_bol(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    if (bw.o.hex != 0) {
        _ = pbkwd(cur, @mod(cur.byte, 16));
    } else {
        _ = p_goto_bol(cur);
        cur.xcol = piscol(cur);
    }
    return 0;
}

/// Move cursor to end of line.
pub export fn u_goto_eol(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    const b = bw.b orelse return -1;
    if (bw.o.hex != 0) {
        const eof = b.eof orelse return -1;
        if (cur.byte + 15 - @mod(cur.byte, 16) > eof.byte) {
            _ = pset(cur, eof);
        } else {
            _ = pfwrd(cur, 15 - @mod(cur.byte, 16));
        }
    } else {
        _ = p_goto_eol(cur);
        cur.xcol = piscol(cur);
    }
    if (bw.o.viewmode != 0) cur.valcol = 0;
    return 0;
}

/// Move cursor to beginning of file.
pub export fn u_goto_bof(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    _ = p_goto_bof(cur);
    return 0;
}

/// Move cursor to end of file (or VT cursor when shell-owned).
pub export fn u_goto_eof(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    const b = bw.b orelse return -1;
    if (b.vt != null and b.pid != 0) {
        const vt: *VtRec = @ptrCast(@alignCast(b.vt.?));
        _ = pset(cur, vt.vtcur);
    } else {
        _ = p_goto_eof(cur);
    }
    return 0;
}

/// Move cursor up one line (or 16 bytes in hex).
pub export fn uuparw(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    if (bw.o.hex != 0) {
        if (cur.byte < 16) return -1;
        _ = pbkwd(cur, 16);
        return 0;
    }
    if (cur.line != 0) {
        _ = pprevl(cur);
        _ = pcol(cur, cur.xcol);
        return 0;
    }
    return -1;
}

/// Move cursor down one line (or 16 bytes in hex; picture mode extends EOF).
pub export fn udnarw(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    const b = bw.b orelse return -1;
    const eof = b.eof orelse return -1;
    if (bw.o.hex != 0) {
        if (cur.byte + 16 <= eof.byte) {
            _ = pfwrd(cur, 16);
            return 0;
        } else if (cur.byte != eof.byte) {
            _ = pset(cur, eof);
            return 0;
        } else {
            return -1;
        }
    }
    if (cur.line != eof.line) {
        _ = pnextl(cur);
        _ = pcol(cur, cur.xcol);
        return 0;
    } else if (bw.o.picture != 0) {
        _ = p_goto_eol(cur);
        _ = binsc(cur, '\n');
        _ = pgetc(cur);
        _ = pcol(cur, cur.xcol);
        return 0;
    }
    return -1;
}

/// Move cursor to top of window.
pub export fn utos(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    const top = bw.top orelse return -1;
    const col = cur.xcol;
    _ = pset(cur, top);
    _ = pcol(cur, col);
    cur.xcol = col;
    return 0;
}

/// Move cursor to bottom of window.
pub export fn ubos(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    const top = bw.top orelse return -1;
    const col = cur.xcol;
    _ = pline(cur, top.line + bw.h - 1);
    _ = pcol(cur, col);
    cur.xcol = col;
    return 0;
}
