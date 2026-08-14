//! Path A live port of JOE basic edit/motion commands (`joe/uedit.c`).
//!
//! Landed: `pgamnt`, cursor motions, word/edge, scroll/page, goto
//! line/col/byte prompts, and delete commands. Remaining `uedit.c`
//! (tomatch, type, quote, marks, paste, …) stays linked until later slices.

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
extern fn pdup(p: ?*GapP, tr: [*:0]const u8) ?*GapP;
extern fn prm(p: ?*GapP) void;
extern fn pprevl(p: ?*GapP) ?*GapP;
extern fn pnextl(p: ?*GapP) ?*GapP;
extern fn pcol(p: ?*GapP, goalcol: i64) ?*GapP;
extern fn piscol(p: ?*GapP) i64;
extern fn pline(p: ?*GapP, line: i64) ?*GapP;
extern fn binsc(p: ?*GapP, c: c_int) ?*GapP;
extern fn pgetc(p: ?*GapP) c_int;
extern fn prgetc(p: ?*GapP) c_int;
extern fn pgetb(p: ?*GapP) c_int;
extern fn prgetb(p: ?*GapP) c_int;
extern fn brc(p: ?*GapP) c_int;
extern fn brch(p: ?*GapP) c_int;
extern fn pisbol(p: ?*GapP) c_int;
extern fn piseol(p: ?*GapP) c_int;
extern fn pisindent(p: ?*GapP) i64;
extern fn joe_isblank(map: ?*anyopaque, c: c_int) c_int;
extern fn nscrldn(t: ?*anyopaque, top: isize, bot: isize, amnt: isize) void;
extern fn nscrlup(t: ?*anyopaque, top: isize, bot: isize, amnt: isize) void;
extern fn umpgup(w: ?*anyopaque, k: c_int) c_int;
extern fn umpgdn(w: ?*anyopaque, k: c_int) c_int;
extern fn bdel(from: ?*GapP, to: ?*GapP) void;
extern fn pgoto(p: ?*GapP, loc: i64) ?*GapP;
extern fn pfill(p: ?*GapP, to: i64, usetabs: c_int) void;
extern fn pisbof(p: ?*GapP) c_int;
extern fn piseof(p: ?*GapP) c_int;
extern fn calc(bw: ?*anyopaque, s: [*c]u8, secure: c_int) f64;
extern fn vsrm(s: [*c]u8) void;
extern fn dofollows() void;
extern fn msgnw(w: ?*anyopaque, s: [*c]const u8) void;
extern fn my_gettext(s: [*c]const u8) [*c]const u8;
extern fn math_cmplt(bw: ?*anyopaque, k: c_int) c_int;
extern fn wmkpw(
    w: ?*anyopaque,
    prompt: [*c]const u8,
    history: ?*?*GapB,
    func: ?*const fn (?*anyopaque, [*c]u8, ?*anyopaque, ?*c_int) callconv(.c) c_int,
    huh: ?[*:0]const u8,
    abrt: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) c_int,
    tab: ?*const fn (?*anyopaque, c_int) callconv(.c) c_int,
    object: ?*anyopaque,
    notify: ?*c_int,
    map: ?*anyopaque,
    file_prompt: c_int,
) ?*anyopaque;
extern var menu_above: c_int;
extern var watommenu: Watom;
extern var merr: ?[*:0]const u8;
extern var utf8_map: ?*anyopaque;
extern var opt_mid: c_int;
extern fn binsm(p: ?*GapP, blk: ?*const anyopaque, amnt: isize) ?*GapP;
extern fn pisblank(p: ?*GapP) c_int;
extern fn from_uni(map: ?*anyopaque, c: c_int) c_int;
extern fn utf8_encode(buf: [*]u8, c: c_int) isize;
extern fn joe_write(fd: c_int, buf: ?*const anyopaque, size: isize) isize;
extern fn wrapword(bw: ?*anyopaque, p: ?*GapP, indent: i64, french: c_int, no_over: c_int, indents: ?[*:0]u8) void;
extern var locale_map: ?*FullCharmap;

extern fn mkqwna(
    w: ?*anyopaque,
    prompt: [*c]const u8,
    len: isize,
    func: ?*const fn (?*anyopaque, c_int, ?*anyopaque, ?*c_int) callconv(.c) c_int,
    abrt: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) c_int,
    object: ?*anyopaque,
    notify: ?*c_int,
) ?*anyopaque;
extern fn mkqw(
    w: ?*anyopaque,
    prompt: [*c]const u8,
    len: isize,
    func: ?*const fn (?*anyopaque, c_int, ?*anyopaque, ?*c_int) callconv(.c) c_int,
    abrt: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) c_int,
    object: ?*anyopaque,
    notify: ?*c_int,
) ?*anyopaque;
extern fn nungetc(c: c_int) void;
extern fn pdupown(p: ?*GapP, owner: *?*GapP, tr: [*:0]const u8) ?*GapP;
extern fn poffline(p: ?*GapP) void;
extern fn zhtoi(s: [*c]const u8) c_int;
extern fn zlcpy(a: [*c]u8, len: isize, b: [*c]const u8) [*c]u8;
extern fn slen(s: [*c]const u8) isize;
extern fn vsmk(len: isize) [*c]u8;
extern fn stagen(stalin: [*c]u8, bw: ?*anyopaque, s: [*c]const u8, fill: u8) [*c]u8;
extern fn utf8_decode_fwrd(pos: *[*c]const u8, len: ?*isize) c_int;
extern fn ttgetch() c_int;
extern var msgbuf: [300]u8;



const NO_MORE_DATA: c_int = -256;

const PredFn = *const fn (?*FullCharmap, c_int) callconv(.c) c_int;
/// Prefix of JOE `struct charmap` with predicate slots (see `joe/charmap.h`).
const FullCharmap = extern struct {
    next: ?*FullCharmap,
    name: ?[*:0]const u8,
    @"type": c_int,
    is_punct: ?PredFn,
    is_print: ?PredFn,
    is_space: ?PredFn,
    is_alpha_: ?PredFn,
    is_alnum_: ?PredFn,
};

fn mapOf(p: *GapP) ?*FullCharmap {
    const b = p.b orelse return null;
    return @ptrCast(@alignCast(b.o.charmap));
}

fn joeIsAlnum(map: ?*FullCharmap, c: c_int) bool {
    const m = map orelse return false;
    const f = m.is_alnum_ orelse return false;
    return f(m, c) != 0;
}

fn joeIsSpace(map: ?*FullCharmap, c: c_int) bool {
    const m = map orelse return false;
    const f = m.is_space orelse return false;
    return f(m, c) != 0;
}

fn joeIsPunct(map: ?*FullCharmap, c: c_int) bool {
    const m = map orelse return false;
    const f = m.is_punct orelse return false;
    return f(m, c) != 0;
}

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

/// Smart home: first non-blank, or bol if already there / `indentfirst`.
pub export fn uhome(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    if (bw.o.hex != 0) return u_goto_bol(w, 0);
    const cur = cursorOrNull(bw) orelse return -1;
    const p = pdup(cur, "uhome") orelse return -1;
    defer prm(p);

    if (bw.o.indentfirst != 0) {
        if (bw.o.smarthome != 0 and piscol(p) > pisindent(p)) {
            _ = p_goto_bol(p);
            while (joe_isblank(@ptrCast(mapOf(p)), brc(p)) != 0) _ = pgetc(p);
        } else {
            _ = p_goto_bol(p);
        }
    } else {
        if (bw.o.smarthome != 0 and piscol(p) == 0 and pisindent(p) != 0) {
            while (joe_isblank(@ptrCast(mapOf(p)), brc(p)) != 0) _ = pgetc(p);
        } else {
            _ = p_goto_bol(p);
        }
    }

    _ = pset(cur, p);
    cur.xcol = piscol(cur);
    if (bw.o.viewmode != 0) cur.valcol = 0;
    return 0;
}

/// Move cursor left (hex / picture / viewmode aware).
pub export fn u_goto_left(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    if (bw.o.hex != 0) {
        return if (prgetb(cur) != NO_MORE_DATA) 0 else -1;
    }
    if (bw.o.picture != 0) {
        if (cur.xcol != 0) {
            cur.xcol -= 1;
            _ = pcol(cur, cur.xcol);
            return 0;
        }
        return -1;
    }
    if (bw.o.viewmode != 0) {
        if (prgetc(cur) != NO_MORE_DATA) {
            cur.valcol = 0;
            return 0;
        }
        return -1;
    }
    if (cur.xcol != piscol(cur)) {
        cur.xcol = piscol(cur);
        return 0;
    } else if (prgetc(cur) != NO_MORE_DATA) {
        cur.xcol = piscol(cur);
        return 0;
    }
    return -1;
}

/// Move cursor right (hex / picture aware).
pub export fn u_goto_right(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    if (bw.o.hex != 0) {
        return if (pgetb(cur) != NO_MORE_DATA) 0 else -1;
    }
    if (bw.o.picture != 0) {
        cur.xcol += 1;
        _ = pcol(cur, cur.xcol);
        return 0;
    }
    var rtn: c_int = -1;
    if (pgetc(cur) != NO_MORE_DATA) {
        cur.xcol = piscol(cur);
        rtn = 0;
    }
    if (cur.xcol != piscol(cur)) cur.xcol = piscol(cur);
    return rtn;
}

fn pGotoPrev(ptr: *GapP) c_int {
    const p = pdup(ptr, "p_goto_prev") orelse return -1;
    defer prm(p);
    const map = mapOf(ptr);
    var c = prgetc(p);
    if (joeIsAlnum(map, c)) {
        while (joeIsAlnum(map, blk: {
            c = prgetc(p);
            break :blk c;
        })) {}
        if (c != NO_MORE_DATA) _ = pgetc(p);
    } else if (joeIsSpace(map, c) or joeIsPunct(map, c)) {
        while (blk: {
            c = prgetc(p);
            break :blk joeIsSpace(map, c) or joeIsPunct(map, c);
        }) {}
        if (c != NO_MORE_DATA) _ = pgetc(p);
        while (joeIsAlnum(map, blk: {
            c = prgetc(p);
            break :blk c;
        })) {}
        if (c != NO_MORE_DATA) _ = pgetc(p);
    }
    _ = pset(ptr, p);
    return 0;
}

/// Internal word-back helper (former static in `uedit.c`; still called from C tomatch).
pub export fn p_goto_prev(ptr: ?*GapP) c_int {
    const p = ptr orelse return -1;
    return pGotoPrev(p);
}

/// Move to previous word (or BOF).
pub export fn u_goto_prev(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    return pGotoPrev(cur);
}

fn pGotoNext(ptr: *GapP) c_int {
    const p = pdup(ptr, "p_goto_next") orelse return -1;
    defer prm(p);
    const map = mapOf(ptr);
    var c = brch(p);
    var rtn: c_int = -1;
    if (joeIsAlnum(map, c)) {
        rtn = 0;
        while (joeIsAlnum(map, blk: {
            c = brch(p);
            break :blk c;
        })) _ = pgetc(p);
    } else if (joeIsSpace(map, c) or joeIsPunct(map, c)) {
        while (joeIsSpace(map, blk: {
            c = brch(p);
            break :blk c;
        }) or joeIsPunct(map, c)) _ = pgetc(p);
        while (joeIsAlnum(map, blk: {
            c = brch(p);
            break :blk c;
        })) {
            rtn = 0;
            _ = pgetc(p);
        }
    } else {
        _ = pgetc(p);
    }
    _ = pset(ptr, p);
    return rtn;
}

/// Internal word-forward helper (former static in `uedit.c`; still called from C tomatch).
pub export fn p_goto_next(ptr: ?*GapP) c_int {
    const p = ptr orelse return -1;
    return pGotoNext(p);
}

/// Move to end of next word (or EOF).
pub export fn u_goto_next(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    return pGotoNext(cur);
}

fn pboi(p: *GapP) *GapP {
    _ = p_goto_bol(p);
    while (joe_isblank(@ptrCast(mapOf(p)), brc(p)) != 0) _ = pgetc(p);
    return p;
}

fn pisedge(p: *GapP) c_int {
    if (pisbol(p) != 0) return -1;
    if (piseol(p) != 0) return 1;
    const q = pdup(p, "pisedge") orelse return 0;
    defer prm(q);
    _ = pboi(q);
    if (q.byte == p.byte) return -1;
    const c = brc(p);
    if (joe_isblank(@ptrCast(mapOf(p)), c) != 0) {
        _ = pset(q, p);
        if (joe_isblank(@ptrCast(mapOf(p)), prgetc(q)) != 0) return 0;
        if (c == '\t') return 1;
        _ = pset(q, p);
        _ = pgetc(q);
        if (pgetc(q) == ' ') return 1;
        return 0;
    } else {
        _ = pset(q, p);
        const prev = prgetc(q);
        if (prev == '\t') return -1;
        if (prev != ' ') return 0;
        if (prgetc(q) == ' ') return -1;
        return 0;
    }
}

/// Move left to a whitespace/indent edge.
pub export fn upedge(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    if (prgetc(cur) == NO_MORE_DATA) return -1;
    while (pisedge(cur) != -1) _ = prgetc(cur);
    return 0;
}

/// Move right to a whitespace/indent edge.
pub export fn unedge(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    if (pgetc(cur) == NO_MORE_DATA) return -1;
    while (pisedge(cur) != 1) _ = pgetc(cur);
    return 0;
}

const ScreenRec = extern struct {
    t: ?*anyopaque,
    wind: isize,
    topwin: ?*WinRec,
    curwin: ?*WinRec,
    w: isize,
    h: isize,
};

fn scrnOf(bw: *BwRec) ?*anyopaque {
    const parent = bw.parent orelse return null;
    const scr: *ScreenRec = @ptrCast(@alignCast(parent.t orelse return null));
    return scr.t;
}

/// Scroll buffer window up `n` lines.
pub export fn scrup(bw_in: ?*anyopaque, n: isize, flg: c_int) void {
    const bw = asBw(bw_in);
    const top = bw.top orelse return;
    const cur = bw.cursor orelse return;
    var scrollamnt: isize = 0;
    var cursoramnt: isize = 0;

    if (bw.o.hex != 0) {
        if (@divTrunc(top.byte, 16) >= n) {
            scrollamnt = n;
            cursoramnt = n;
        } else if (@divTrunc(top.byte, 16) != 0) {
            scrollamnt = @intCast(@divTrunc(top.byte, 16));
            cursoramnt = scrollamnt;
        } else if (flg != 0) {
            cursoramnt = @intCast(@divTrunc(cur.byte, 16));
        } else if (@divTrunc(cur.byte, 16) >= n) {
            cursoramnt = n;
        }
    } else {
        if (top.line >= n) {
            scrollamnt = n;
            cursoramnt = n;
        } else if (top.line != 0) {
            scrollamnt = @intCast(top.line);
            cursoramnt = scrollamnt;
        } else if (flg != 0) {
            cursoramnt = @intCast(cur.line);
        } else if (cur.line >= n) {
            cursoramnt = n;
        }
    }

    if (bw.o.hex != 0) {
        _ = pbkwd(top, scrollamnt * 16);
        _ = pbkwd(cur, cursoramnt * 16);
        const parent = bw.parent orelse return;
        if (parent.y != -1) {
            if (scrnOf(bw)) |t| nscrldn(t, bw.y, bw.y + bw.h, scrollamnt);
        }
    } else {
        var x: isize = 0;
        while (x != scrollamnt) : (x += 1) _ = pprevl(top);
        _ = p_goto_bol(top);
        x = 0;
        while (x != cursoramnt) : (x += 1) _ = pprevl(cur);
        _ = p_goto_bol(cur);
        _ = pcol(cur, cur.xcol);
        const parent = bw.parent orelse return;
        if (parent.y != -1) {
            if (scrnOf(bw)) |t| nscrldn(t, bw.y, bw.y + bw.h, scrollamnt);
        }
    }
}

/// Scroll buffer window down `n` lines.
pub export fn scrdn(bw_in: ?*anyopaque, n: isize, flg: c_int) void {
    const bw = asBw(bw_in);
    const top = bw.top orelse return;
    const cur = bw.cursor orelse return;
    const b = top.b orelse return;
    const eof = b.eof orelse return;
    var scrollamnt: isize = 0;
    var cursoramnt: isize = 0;

    if (bw.o.hex != 0) {
        if (@divTrunc(eof.byte, 16) < @divTrunc(top.byte, 16) + bw.h) {
            cursoramnt = @intCast(@divTrunc(eof.byte, 16) - @divTrunc(cur.byte, 16));
            if (flg == 0 and cursoramnt > n) cursoramnt = n;
        } else if (@divTrunc(eof.byte, 16) - (@divTrunc(top.byte, 16) + bw.h) >= n) {
            cursoramnt = n;
            scrollamnt = n;
        } else {
            cursoramnt = @intCast(@divTrunc(eof.byte, 16) - (@divTrunc(top.byte, 16) + bw.h) + 1);
            scrollamnt = cursoramnt;
        }
    } else {
        if (eof.line < top.line + bw.h) {
            cursoramnt = @intCast(eof.line - cur.line);
            if (flg == 0 and cursoramnt > n) cursoramnt = n;
        } else if (eof.line - (top.line + bw.h) >= n) {
            cursoramnt = n;
            scrollamnt = n;
        } else {
            cursoramnt = @intCast(eof.line - (top.line + bw.h) + 1);
            scrollamnt = cursoramnt;
        }
    }

    if (bw.o.hex != 0) {
        _ = pfwrd(top, 16 * scrollamnt);
        _ = pfwrd(cur, 16 * cursoramnt);
        const parent = bw.parent orelse return;
        if (parent.y != -1) {
            if (scrnOf(bw)) |t| nscrlup(t, bw.y, bw.y + bw.h, scrollamnt);
        }
    } else {
        var x: isize = 0;
        while (x != scrollamnt) : (x += 1) _ = pnextl(top);
        x = 0;
        while (x != cursoramnt) : (x += 1) _ = pnextl(cur);
        _ = pcol(cur, cur.xcol);
        const parent = bw.parent orelse return;
        if (parent.y != -1) {
            if (scrnOf(bw)) |t| nscrlup(t, bw.y, bw.y + bw.h, scrollamnt);
        }
    }
}

fn menuPageTarget(w_in: ?*anyopaque) ?*anyopaque {
    const win = asWin(w_in);
    if (menu_above != 0) {
        const prev = win.link.prev orelse return null;
        if (prev.watom == &watommenu and prev.win == win) return prev;
    } else {
        const next = win.link.next orelse return null;
        if (next.watom == &watommenu and next.win == win) return next;
    }
    return null;
}

fn mainBw(bw: *BwRec) ?*BwRec {
    const parent = bw.parent orelse return null;
    const main_win = parent.main orelse return null;
    return @ptrCast(@alignCast(main_win.object orelse return null));
}

/// Page up (or menu page-up when a menu is attached).
pub export fn upgup(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    var bw = windBw(w) orelse return -1;
    if (menuPageTarget(w)) |mw| return umpgup(mw, 0);
    bw = mainBw(bw) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (if (bw.o.hex != 0) cur.byte < 16 else cur.line == 0) return -1;
    if (pgamnt < 0) {
        scrup(bw, @divTrunc(bw.h, 2) + @mod(bw.h, 2), 1);
    } else if (pgamnt < bw.h) {
        scrup(bw, bw.h - pgamnt, 1);
    } else {
        scrup(bw, 1, 1);
    }
    return 0;
}

/// Page down (or menu page-down when a menu is attached).
pub export fn upgdn(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    var bw = windBw(w) orelse return -1;
    if (menuPageTarget(w)) |mw| return umpgdn(mw, 0);
    bw = mainBw(bw) orelse return -1;
    const cur = bw.cursor orelse return -1;
    const b = bw.b orelse return -1;
    const eof = b.eof orelse return -1;
    if (if (bw.o.hex != 0) @divTrunc(cur.byte, 16) == @divTrunc(eof.byte, 16) else cur.line == eof.line) return -1;
    if (pgamnt < 0) {
        scrdn(bw, @divTrunc(bw.h, 2) + @mod(bw.h, 2), 1);
    } else if (pgamnt < bw.h) {
        scrdn(bw, bw.h - pgamnt, 1);
    } else {
        scrdn(bw, 1, 1);
    }
    return 0;
}

/// Scroll up one line; cursor moves with the scroll.
pub export fn uupslide(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const top = bw.top orelse return -1;
    const cur = bw.cursor orelse return -1;
    const can = if (bw.o.hex != 0) @divTrunc(top.byte, 16) != 0 else top.line != 0;
    if (can) {
        const at_bot = if (bw.o.hex != 0)
            @divTrunc(top.byte, 16) + bw.h - 1 != @divTrunc(cur.byte, 16)
        else
            top.line + bw.h - 1 != cur.line;
        if (at_bot) _ = udnarw(w, 0);
        scrup(bw, 1, 0);
        return 0;
    }
    return uuparw(w, 0);
}

/// Scroll down one line; cursor moves with the scroll.
pub export fn udnslide(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const top = bw.top orelse return -1;
    const cur = bw.cursor orelse return -1;
    const b = top.b orelse return -1;
    const eof = b.eof orelse return -1;
    // Preserve C quirk: hex branch uses `top->line/16`, not `top->byte/16`.
    const can = if (bw.o.hex != 0)
        @divTrunc(top.line, 16) + bw.h <= @divTrunc(eof.byte, 16)
    else
        top.line + bw.h <= eof.line;
    if (can) {
        const at_top = if (bw.o.hex != 0)
            @divTrunc(top.byte, 16) != @divTrunc(cur.byte, 16)
        else
            top.line != cur.line;
        if (at_top) _ = uuparw(w, 0);
        scrdn(bw, 1, 0);
        return 0;
    }
    return udnarw(w, 0);
}

// ── Goto line / column / byte prompts ──────────────────────────────

var linehist: ?*GapB = null;
var colhist: ?*GapB = null;
var bytehist: ?*GapB = null;

fn doline(w: ?*anyopaque, s: [*c]u8, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    const bw = windBw(w) orelse {
        vsrm(s);
        return -1;
    };
    const num: i64 = @intFromFloat(calc(bw, s, 1));
    if (notify) |n| n.* = 1;
    vsrm(s);
    if (num >= 1 and merr == null) {
        const cur = cursorOrNull(bw) orelse return -1;
        const b = bw.b orelse return -1;
        const eof = b.eof orelse return -1;
        var line_no = num;
        if (line_no > eof.line) line_no = eof.line + 1;
        const tmp = opt_mid;
        _ = pline(cur, line_no - 1);
        cur.xcol = piscol(cur);
        opt_mid = 1;
        dofollows();
        opt_mid = tmp;
        return 0;
    }
    if (merr) |err| {
        msgnw(@ptrCast(bw.parent), err);
    } else {
        msgnw(@ptrCast(bw.parent), my_gettext("Invalid line number"));
    }
    return -1;
}

/// Prompt and go to a line number.
pub export fn uline(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    if (wmkpw(
        @ptrCast(bw.parent),
        my_gettext("Go to line (%{abort} to abort): "),
        &linehist,
        &doline,
        null,
        null,
        &math_cmplt,
        null,
        null,
        utf8_map,
        0,
    ) != null) return 0;
    return -1;
}

fn docol(w: ?*anyopaque, s: [*c]u8, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    const bw = windBw(w) orelse {
        vsrm(s);
        return -1;
    };
    const num: i64 = @intFromFloat(calc(bw, s, 1));
    if (notify) |n| n.* = 1;
    vsrm(s);
    if (num >= 1 and merr == null) {
        const cur = cursorOrNull(bw) orelse return -1;
        const tmp = opt_mid;
        _ = pcol(cur, num - 1);
        cur.xcol = piscol(cur);
        opt_mid = 1;
        dofollows();
        opt_mid = tmp;
        return 0;
    }
    if (merr) |err| {
        msgnw(@ptrCast(bw.parent), err);
    } else {
        msgnw(@ptrCast(bw.parent), my_gettext("Invalid column number"));
    }
    return -1;
}

/// Prompt and go to a column number.
pub export fn ucol(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    if (wmkpw(
        @ptrCast(bw.parent),
        my_gettext("Go to column (%{abort} to abort): "),
        &colhist,
        &docol,
        null,
        null,
        &math_cmplt,
        null,
        null,
        utf8_map,
        0,
    ) != null) return 0;
    return -1;
}

fn dobyte(w: ?*anyopaque, s: [*c]u8, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    const bw = windBw(w) orelse {
        vsrm(s);
        return -1;
    };
    const num: i64 = @intFromFloat(calc(bw, s, 1));
    if (notify) |n| n.* = 1;
    vsrm(s);
    if (num >= 0 and merr == null) {
        const cur = cursorOrNull(bw) orelse return -1;
        const tmp = opt_mid;
        _ = pgoto(cur, num);
        cur.xcol = piscol(cur);
        opt_mid = 1;
        dofollows();
        opt_mid = tmp;
        return 0;
    }
    if (merr) |err| {
        msgnw(@ptrCast(bw.parent), err);
    } else {
        msgnw(@ptrCast(bw.parent), my_gettext("Invalid byte number"));
    }
    return -1;
}

/// Prompt and go to a byte offset.
pub export fn ubyte(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    if (wmkpw(
        @ptrCast(bw.parent),
        my_gettext("Go to byte (%{abort} to abort): "),
        &bytehist,
        &dobyte,
        null,
        null,
        &math_cmplt,
        null,
        null,
        utf8_map,
        0,
    ) != null) return 0;
    return -1;
}

// ── Delete commands ────────────────────────────────────────────────

/// Delete character under cursor.
pub export fn udelch(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    if (piseof(cur) != 0) return -1;
    const p = pdup(cur, "udelch") orelse return -1;
    defer prm(p);
    _ = pgetc(p);
    bdel(cur, p);
    return 0;
}

/// Backspace (smart-indent aware).
pub export fn ubacks(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    const parent = bw.parent orelse return -1;
    const wa = parent.watom orelse return -1;
    if (wa.what != TYPETW and pisbol(cur) != 0) return -1;

    if (bw.o.overtype != 0) return u_goto_left(@ptrCast(parent), 0);
    if (pisbof(cur) != 0) return -1;

    const indent = pisindent(cur);
    const col = piscol(cur);
    const wid: i64 = if (bw.o.indentc == '\t') bw.o.tab else 1;
    const indwid = bw.o.istep * wid;

    if (col == indent and @mod(col, indwid) == 0 and col != 0 and bw.o.smartbacks != 0 and bw.o.autoindent != 0) {
        const p = pdup(cur, "ubacks") orelse return -1;
        defer prm(p);
        _ = p_goto_bol(p);
        bdel(p, cur);
        pfill(cur, col - indwid, bw.o.indentc);
        return 0;
    }

    if (col < indent and bw.o.smartbacks != 0 and pisbol(cur) == 0) {
        const p = pdup(cur, "ubacks") orelse return -1;
        defer prm(p);
        var cw: i64 = 0;
        while (true) {
            const c = prgetc(cur);
            if (c == '\t') cw += bw.o.tab else cw += 1;
            bdel(cur, p);
            if (!(pisbol(cur) == 0 and cw < indwid)) break;
        }
        return 0;
    }

    const p = pdup(cur, "ubacks") orelse return -1;
    defer prm(p);
    const c = prgetc(cur);
    if (c != NO_MORE_DATA) {
        if (bw.o.overtype == 0 or c == '\t' or pisbol(p) != 0 or piseol(p) != 0) {
            bdel(cur, p);
        }
    }
    return 0;
}

/// Delete alphanumeric or whitespace run under cursor.
pub export fn u_word_delete(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    const p = pdup(cur, "u_word_delete") orelse return -1;
    defer prm(p);
    const map = mapOf(p);
    var c = brch(p);
    if (joeIsAlnum(map, c)) {
        while (joeIsAlnum(map, blk: {
            c = brch(p);
            break :blk c;
        })) _ = pgetc(p);
    } else if (joeIsSpace(map, c)) {
        while (joeIsSpace(map, blk: {
            c = brch(p);
            break :blk c;
        })) _ = pgetc(p);
    } else {
        _ = pgetc(p);
    }
    if (p.byte == cur.byte) return -1;
    bdel(cur, p);
    return 0;
}

/// Delete backward over word / whitespace / single char.
pub export fn ubackw(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    const p = pdup(cur, "ubackw") orelse return -1;
    defer prm(p);
    var c = prgetc(cur);
    const map = mapOf(cur);
    if (joeIsAlnum(map, c)) {
        while (joeIsAlnum(map, blk: {
            c = prgetc(cur);
            break :blk c;
        })) {}
        if (c != NO_MORE_DATA) _ = pgetc(cur);
    } else if (joeIsSpace(map, c)) {
        while (joeIsSpace(map, blk: {
            c = prgetc(cur);
            break :blk c;
        })) {}
        if (c != NO_MORE_DATA) _ = pgetc(cur);
    }
    if (cur.byte == p.byte) return -1;
    bdel(cur, p);
    return 0;
}

/// Delete to end of line (or the linebreak if empty).
pub export fn udelel(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    const p = pdup(cur, "udelel") orelse return -1;
    defer prm(p);
    _ = p_goto_eol(p);
    if (cur.byte == p.byte) return udelch(w, 0);
    bdel(cur, p);
    return 0;
}

/// Delete to beginning of line (or backspace linebreak if empty).
pub export fn udelbl(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    const p = pdup(cur, "udelbl") orelse return -1;
    defer prm(p);
    _ = p_goto_bol(p);
    if (p.byte == cur.byte) return ubacks(w, 8);
    bdel(p, cur);
    return 0;
}

/// Delete entire line.
pub export fn udelln(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    const p = pdup(cur, "udelln") orelse return -1;
    defer prm(p);
    _ = p_goto_bol(cur);
    _ = pnextl(p);
    if (cur.byte == p.byte) return -1;
    bdel(cur, p);
    return 0;
}

/// Insert a single space.
pub export fn uinsc(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    _ = binsc(cur, ' ');
    return 0;
}


// ── Typing / return / open-line ────────────────────────────────────

fn findIndent(p_in: *GapP) i64 {
    var x: c_int = 0;
    while (x != 10) : (x += 1) {
        if (pprevl(p_in) == null) return -1;
        _ = p_goto_bol(p_in);
        if (pisblank(p_in) == 0) break;
    }
    if (x == 10) return -1;
    return pisindent(p_in);
}

/// Core type-into-buffer / shell-forward path. Exported for remaining C quote.
pub export fn utypebw_raw(bw_in: ?*anyopaque, k_in: c_int, no_decode: c_int) c_int {
    const bw = asBw(bw_in);
    const cur = bw.cursor orelse return -1;
    const b = bw.b orelse return -1;
    var k = k_in;
    const map = @as(?*FullCharmap, @ptrCast(@alignCast(b.o.charmap)));

    // Send data to shell window
    const vt_at_cur = blk: {
        if (b.vt == null) break :blk false;
        const vt: *VtRec = @ptrCast(@alignCast(b.vt.?));
        break :blk cur.byte == (vt.vtcur orelse break :blk false).byte;
    };
    if ((b.pid != 0 and b.vt == null and piseof(cur) != 0) or (b.pid != 0 and vt_at_cur)) {
        const loc = locale_map;
        if (loc != null and loc.?.@"type" != 0) {
            var buf: [8]u8 = undefined;
            const len = utf8_encode(&buf, k);
            _ = joe_write(b.out, &buf, len);
        } else {
            if (no_decode == 0) k = from_uni(@ptrCast(loc), k);
            if (k != -1) {
                var c: u8 = @truncate(@as(u32, @bitCast(k)));
                _ = joe_write(b.out, &c, 1);
            }
        }
        return 0;
    }

    // Hex mode overtype needs to preserve file size
    if (bw.o.hex != 0 and bw.o.overtype != 0) {
        var buf: [8]u8 = undefined;
        var len: isize = undefined;
        if (map != null and map.?.@"type" != 0) {
            len = utf8_encode(&buf, k);
        } else {
            if (no_decode == 0) k = from_uni(@ptrCast(map), k);
            if (k == -1) return 1;
            buf[0] = @truncate(@as(u32, @bitCast(k)));
            len = 1;
        }
        _ = binsm(cur, &buf, len);
        var x: isize = 0;
        while (x != len) : (x += 1) _ = pgetb(cur);
        var rem = len;
        while (rem > 0) : (rem -= 1) {
            if (piseof(cur) != 0) return 0;
            const p = pdup(cur, "utypebw_raw") orelse return -1;
            defer prm(p);
            _ = pgetb(p);
            bdel(cur, p);
        }
        return 0;
    }

    if (k == '\t' and bw.o.overtype != 0 and piseol(cur) == 0 and no_decode == 0) {
        var col = cur.xcol;
        col = col + bw.o.tab - @mod(col, bw.o.tab);
        _ = pcol(cur, col);
        if (bw.o.picture == 0 and piseol(cur) != 0 and piscol(cur) < col) {
            if (bw.o.spaces != 0) pfill(cur, col, ' ') else pfill(cur, col, '\t');
        }
        cur.xcol = col;
    } else if (k == '\t' and bw.o.smartbacks != 0 and bw.o.autoindent != 0 and pisindent(cur) >= piscol(cur) and no_decode == 0) {
        const p = pdup(cur, "utypebw_raw") orelse return -1;
        defer prm(p);
        const n = findIndent(p);
        if (n != -1 and pisindent(cur) == piscol(cur) and n > pisindent(cur)) {
            if (pisbol(cur) == 0) _ = udelbl(@ptrCast(bw.parent), 0);
            while (true) {
                k = pgetc(p);
                if (!(joeIsSpace(map, k) and k != '\n')) break;
                _ = binsc(cur, k);
                _ = pgetc(cur);
            }
        } else {
            var x: i64 = 0;
            while (x < bw.o.istep) : (x += 1) {
                _ = binsc(cur, bw.o.indentc);
                _ = pgetc(cur);
            }
        }
        cur.xcol = piscol(cur);
    } else if (k == '\t' and bw.o.spaces != 0 and no_decode == 0) {
        var n: i64 = if (bw.o.picture != 0) cur.xcol else piscol(cur);
        n = bw.o.tab - @mod(n, bw.o.tab);
        while (n > 0) : (n -= 1) _ = utypebw(bw, ' ');
    } else {
        if (bw.o.picture != 0 and cur.xcol != piscol(cur)) pfill(cur, cur.xcol, ' ');

        if (pisblank(cur) != 0) {
            while (piscol(cur) < bw.o.lmargin) {
                _ = binsc(cur, ' ');
                _ = pgetc(cur);
            }
        }

        if (no_decode == 0) {
            if (map == null or map.?.@"type" == 0) {
                k = from_uni(@ptrCast(map), k);
            }
        }

        _ = binsc(cur, k);
        _ = pgetc(cur);

        if (bw.o.overtype != 0 and piseol(cur) == 0 and k != '\t') _ = udelch(@ptrCast(bw.parent), 0);

        if (bw.o.wordwrap != 0 and piscol(cur) > bw.o.rmargin and joe_isblank(@ptrCast(map), k) == 0) {
            wrapword(bw, cur, bw.o.lmargin, bw.o.french, 0, null);
        }

        cur.xcol = piscol(cur);
        // Path A: omit the SCRN micro-update optimization from C (`outatr` hot path);
        // normal follow/update paints the typed character.
    }
    return 0;
}

pub export fn utypebw(bw_in: ?*anyopaque, k: c_int) c_int {
    return utypebw_raw(bw_in, k, 0);
}

pub export fn utypew(w: ?*anyopaque, k: c_int) c_int {
    const bw = windBw(w) orelse return -1;
    return utypebw(bw, k);
}

/// Return / newline with optional autoindent.
pub export fn rtntw(w: ?*anyopaque) c_int {
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    if (bw.o.overtype != 0) {
        _ = p_goto_eol(cur);
        if (piseof(cur) != 0) _ = binsc(cur, '\n');
        _ = pgetc(cur);
        cur.xcol = piscol(cur);
    } else {
        const p = pdup(cur, "rtntw") orelse return -1;
        defer prm(p);
        _ = binsc(cur, '\n');
        _ = pgetc(cur);
        if (bw.o.autoindent != 0) {
            const map = mapOf(cur);
            _ = p_goto_bol(p);
            while (true) {
                const c = pgetc(p);
                if (!(joeIsSpace(map, c) and c != '\n')) break;
                _ = binsc(cur, c);
                _ = pgetc(cur);
            }
        }
        cur.xcol = piscol(cur);
    }
    return 0;
}

/// Open (split) a line with optional autoindent on the new line.
pub export fn uopen(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = cursorOrNull(bw) orelse return -1;
    _ = binsc(cur, '\n');
    if (bw.o.autoindent != 0 and brch(cur) != ' ' and brch(cur) != '\t') {
        const p = pdup(cur, "uopen") orelse return -1;
        defer prm(p);
        const q = pdup(p, "uopen") orelse return -1;
        defer prm(q);
        _ = pgetc(q);
        _ = p_goto_bol(p);
        const map = mapOf(cur);
        while (true) {
            const c = pgetc(p);
            if (!(joeIsSpace(map, c) and c != '\n')) break;
            _ = binsc(q, c);
            _ = pgetc(q);
        }
    }
    return 0;
}


// ── Marks / char-search / message / insert-text / paste ─────────────

fn vsLen(a: [*c]u8) isize {
    if (a == null) return 0;
    const p: [*]const isize = @ptrCast(@alignCast(a));
    return (p - 1)[0];
}

extern fn snprintf(buf: [*]u8, n: usize, fmt: [*c]const u8, ...) c_int;

fn dosetmark(w: ?*anyopaque, c: c_int, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    const bw = windBw(w) orelse return -1;
    if (notify) |n| n.* = 1;
    if (c >= '0' and c <= ':') {
        const cur = cursorOrNull(bw) orelse return -1;
        const b = bw.b orelse return -1;
        const idx: usize = @intCast(c - '0');
        _ = pdupown(cur, &b.marks[idx], "dosetmark");
        poffline(b.marks[idx]);
        if (c != ':') {
            const fmt = my_gettext("Mark %d set");
            _ = snprintf(&msgbuf, msgbuf.len, fmt, c - '0');
            msgnw(@ptrCast(bw.parent), &msgbuf);
        }
        return 0;
    }
    nungetc(c);
    return -1;
}

pub export fn usetmark(w: ?*anyopaque, c: c_int) c_int {
    if (c >= '0' and c <= ':') return dosetmark(w, c, null, null);
    const prompt = my_gettext("Set mark (0-9):");
    if (mkqwna(w, prompt, slen(prompt), &dosetmark, null, null, null) != null) return 0;
    return -1;
}

fn dogomark(w: ?*anyopaque, c: c_int, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    const bw = windBw(w) orelse return -1;
    if (notify) |n| n.* = 1;
    if (c >= '0' and c <= ':') {
        const b = bw.b orelse return -1;
        const idx: usize = @intCast(c - '0');
        if (b.marks[idx]) |mark| {
            const cur = cursorOrNull(bw) orelse return -1;
            _ = pset(cur, mark);
            cur.xcol = piscol(cur);
            return 0;
        }
        const fmt = my_gettext("Mark %d not set");
        _ = snprintf(&msgbuf, msgbuf.len, fmt, c - '0');
        msgnw(@ptrCast(bw.parent), &msgbuf);
        return -1;
    }
    nungetc(c);
    return -1;
}

pub export fn ugomark(w: ?*anyopaque, c: c_int) c_int {
    if (c >= '0' and c <= '9') return dogomark(w, c, null, null);
    const prompt = my_gettext("Goto bookmark (0-9):");
    if (mkqwna(w, prompt, slen(prompt), &dogomark, null, null, null) != null) return 0;
    return -1;
}

var dobkwdc: c_int = 0;

fn dofwrdc(w: ?*anyopaque, k: c_int, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    const bw = windBw(w) orelse return -1;
    if (notify) |n| n.* = 1;
    if (k < 0 or k >= 256) {
        nungetc(k);
        return -1;
    }
    const cur = cursorOrNull(bw) orelse return -1;
    const q = pdup(cur, "dofwrdc") orelse return -1;
    defer prm(q);
    var c: c_int = undefined;
    if (dobkwdc != 0) {
        while (true) {
            c = prgetc(q);
            if (c == NO_MORE_DATA or c == k) break;
        }
    } else {
        while (true) {
            c = pgetc(q);
            if (c == NO_MORE_DATA or c == k) break;
        }
    }
    if (c == NO_MORE_DATA) {
        msgnw(@ptrCast(bw.parent), my_gettext("Not found"));
        return -1;
    }
    _ = pset(cur, q);
    cur.xcol = piscol(cur);
    return 0;
}

pub export fn ufwrdc(w: ?*anyopaque, k: c_int) c_int {
    dobkwdc = 0;
    if (k >= 0 and k < 256) return dofwrdc(w, k, null, null);
    const prompt = my_gettext("Forward to char: ");
    if (mkqw(w, prompt, slen(prompt), &dofwrdc, null, null, null) != null) return 0;
    return -1;
}

pub export fn ubkwdc(w: ?*anyopaque, k: c_int) c_int {
    dobkwdc = 1;
    if (k >= 0 and k < 256) return dofwrdc(w, k, null, null);
    const prompt = my_gettext("Backward to char: ");
    if (mkqw(w, prompt, slen(prompt), &dofwrdc, null, null, null) != null) return 0;
    return -1;
}

fn domsg(w: ?*anyopaque, s: [*c]u8, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    if (notify) |n| n.* = 1;
    _ = zlcpy(&msgbuf, msgbuf.len, s);
    vsrm(s);
    msgnw(w, &msgbuf);
    return 0;
}

pub export fn umsg(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    if (wmkpw(
        w,
        my_gettext("Message (%{abort} to abort): "),
        null,
        &domsg,
        null,
        null,
        null,
        null,
        null,
        @ptrCast(locale_map),
        0,
    ) != null) return 0;
    return -1;
}

fn dotxt(w: ?*anyopaque, s_in: [*c]u8, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    const bw = windBw(w) orelse {
        vsrm(s_in);
        return -1;
    };
    if (notify) |n| n.* = 1;
    var s = s_in;
    if (s != null and s[0] == '`') {
        var str = vsmk(1024);
        str = stagen(str, bw, s + 1, ' ');
        vsrm(s);
        s = str;
    }
    if (s != null) {
        var t: [*c]const u8 = s;
        var len = vsLen(s);
        const map = @as(?*FullCharmap, @ptrCast(@alignCast((bw.b orelse return -1).o.charmap)));
        while (len != 0) {
            var c: c_int = undefined;
            if (map != null and map.?.@"type" != 0) {
                c = utf8_decode_fwrd(&t, &len);
            } else {
                c = t[0];
                t += 1;
                len -= 1;
            }
            if (c >= 0) _ = utypebw_raw(bw, c, 1);
        }
        vsrm(s);
    }
    return 0;
}

pub export fn utxt(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const b = bw.b orelse return -1;
    if (wmkpw(
        w,
        my_gettext("Insert (%{abort} to abort): "),
        null,
        &dotxt,
        null,
        null,
        @ptrCast(&utypebw),
        null,
        null,
        @ptrCast(b.o.charmap),
        0,
    ) != null) return 0;
    return -1;
}

pub export fn uname_joe(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const win = asWin(w);
    const main_win = win.main orelse return -1;
    const bw: *BwRec = @ptrCast(@alignCast(main_win.object orelse return -1));
    const b = bw.b orelse return -1;
    const name_ptr: ?[*:0]const u8 = @ptrCast(@alignCast(b.name orelse return -1));
    const name = name_ptr orelse return -1;
    if (name[0] == 0) return -1;
    var s: [*:0]const u8 = name;
    while (s[0] != 0) : (s += 1) {
        if (utypew(w, s[0]) != 0) return -1;
    }
    return 0;
}

pub export fn upaste(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const tmp_ww = bw.o.wordwrap;
    const tmp_ai = bw.o.autoindent;
    bw.o.wordwrap = 0;
    bw.o.autoindent = 0;
    defer {
        bw.o.wordwrap = tmp_ww;
        bw.o.autoindent = tmp_ai;
    }

    var count: c_int = 0;
    var accu: c_int = 0;

    while (true) {
        const c = ttgetch();
        if (c == -1) return 0;
        if (c == ';') break;
    }

    while (true) {
        var c = ttgetch();
        if (c == -1) break;
        if (c >= 'A' and c <= 'Z') c = c - 'A'
        else if (c >= 'a' and c <= 'z') c = c - 'a' + 26
        else if (c >= '0' and c <= '9') c = c - '0' + 52
        else if (c == '+') c = 62
        else if (c == '/') c = 63
        else if (c == '=') continue
        else {
            if (c == 0o33) _ = ttgetch();
            break;
        }

        switch (count) {
            0 => {
                accu = c;
                count = 6;
            },
            2 => {
                accu = (accu << 6) + c;
                if (accu == 13) _ = rtntw(@ptrCast(bw.parent)) else _ = utypebw(bw, accu);
                count = 0;
            },
            4 => {
                accu = (accu << 4) + (c >> 2);
                if (accu == 13) _ = rtntw(@ptrCast(bw.parent)) else _ = utypebw(bw, accu);
                accu = c & 0x3;
                count = 2;
            },
            6 => {
                accu = (accu << 2) + (c >> 4);
                if (accu == 13) _ = rtntw(@ptrCast(bw.parent)) else _ = utypebw(bw, accu);
                accu = c & 0xF;
                count = 4;
            },
            else => {},
        }
    }
    return 0;
}

pub export fn ubrpaste(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    if (bw.pasting != 0) return 0;
    bw.saved.ww = bw.o.wordwrap;
    bw.saved.ai = bw.o.autoindent;
    bw.saved.sp = bw.o.spaces;
    bw.o.wordwrap = 0;
    bw.o.autoindent = 0;
    bw.o.spaces = 0;
    bw.pasting = 1;
    return 0;
}

pub export fn ubrpaste_done(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    if (bw.pasting == 0) return 0;
    bw.o.wordwrap = bw.saved.ww;
    bw.o.autoindent = bw.saved.ai;
    bw.o.spaces = bw.saved.sp;
    bw.pasting = 0;
    return 0;
}
