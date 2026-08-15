//! Path A live port of JOE highlighted-block commands (`joe/ublock.c`).
//!
//! JOE `ublock.h` ABI lives here (marks, rect/block-ops, indent, filter,
//! case fold, blksum). `joe/ublock.c` is a tombstone.

const std = @import("std");
const gap_types = @import("gapbuffer/types.zig");

const GapP = gap_types.P;
const GapB = gap_types.B;
const GapOptions = gap_types.OPTIONS;

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;

export var nowmarking: c_int = 0;
export var square: c_int = 0;
export var lightoff: c_int = 0;
export var markb: ?*GapP = null;
export var markk: ?*GapP = null;
export var nstack: c_int = 0;
export var autoswap: c_int = 0;

extern var marking: c_int;

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

comptime {
    if (@sizeOf(WinRec) != 200) @compileError("WinRec size mismatch");
    if (@sizeOf(BwRec) != 488) @compileError("BwRec size mismatch");
    if (@sizeOf(GapP) != 112) @compileError("GapP size mismatch");
}

const MarkLink = extern struct {
    next: ?*MarkSav,
    prev: ?*MarkSav,
};

const MarkSav = extern struct {
    link: MarkLink,
    markb: ?*GapP,
    markk: ?*GapP,
};

var markstack: MarkSav = undefined;
var markfree: MarkSav = undefined;
var mark_sentinels_ready: bool = false;

const NO_MORE_DATA: c_int = -256;

extern fn pdup(p: ?*GapP, tr: [*:0]const u8) ?*GapP;
extern fn pdupown(p: ?*GapP, owner: *?*GapP, tr: [*:0]const u8) ?*GapP;
extern fn prm(p: ?*GapP) void;
extern fn pset(n: ?*GapP, p: ?*GapP) ?*GapP;
extern fn p_goto_bol(p: ?*GapP) ?*GapP;
extern fn p_goto_eol(p: ?*GapP) ?*GapP;
extern fn p_goto_eof(p: ?*GapP) ?*GapP;
extern fn pnextl(p: ?*GapP) ?*GapP;
extern fn pcol(p: ?*GapP, goalcol: i64) ?*GapP;
extern fn pcolwse(p: ?*GapP, goalcol: i64) ?*GapP;
extern fn pcoli(p: ?*GapP, goalcol: i64) ?*GapP;
extern fn piscol(p: ?*GapP) i64;
extern fn pfill(p: ?*GapP, to: i64, usetabs: c_int) void;
extern fn pbackws(p: ?*GapP) void;
extern fn pfwrd(p: ?*GapP, n: i64) ?*GapP;
extern fn pline(p: ?*GapP, line: i64) ?*GapP;
extern fn pgetc(p: ?*GapP) c_int;
extern fn piseol(p: ?*GapP) c_int;
extern fn bdel(from: ?*GapP, to: ?*GapP) void;
extern fn bmk(prop: ?*GapB) ?*GapB;
extern fn brm(b: ?*GapB) void;
extern fn bcpy(from: ?*GapP, to: ?*GapP) ?*GapB;
extern fn binsb(p: ?*GapP, b: ?*GapB) ?*GapP;
extern fn binsc(p: ?*GapP, c: c_int) ?*GapP;
extern fn modify_logic(bw: ?*anyopaque, b: ?*GapB) c_int;
extern fn udelln(w: ?*anyopaque, k: c_int) c_int;
extern fn updall() void;
extern fn scrn_invalidate(t: ?*anyopaque) void;
extern var maint: [*c]extern struct { t: ?*anyopaque };
extern fn msgnw(w: ?*anyopaque, s: [*c]const u8) void;
extern fn my_gettext(s: [*c]const u8) [*c]const u8;
extern fn alitem(list: ?*anyopaque, itemsize: isize) ?*anyopaque;

extern fn pisblank(p: ?*GapP) c_int;
extern fn pisindent(p: ?*GapP) i64;
extern fn pprevl(p: ?*GapP) ?*GapP;
extern fn brc(p: ?*GapP) c_int;
extern fn p_goto_indent(p: ?*GapP, c: c_int) ?*GapP;

fn asWin(w: ?*anyopaque) *WinRec {
    return @ptrCast(@alignCast(w.?));
}

fn windBw(w_in: ?*anyopaque) ?*BwRec {
    if (w_in == null) return null;
    const win = asWin(w_in);
    const wa = win.watom orelse return null;
    if ((wa.what & (TYPETW | TYPEPW)) == 0) return null;
    return @ptrCast(@alignCast(win.object orelse return null));
}

fn ptrEq(a: anytype, b: anytype) bool {
    return @intFromPtr(a) == @intFromPtr(b);
}

fn izqueMark(item: *MarkSav) void {
    item.link.next = item;
    item.link.prev = item;
}

fn ensureMarkSentinels() void {
    if (mark_sentinels_ready) return;
    markstack = std.mem.zeroes(MarkSav);
    markfree = std.mem.zeroes(MarkSav);
    izqueMark(&markstack);
    izqueMark(&markfree);
    mark_sentinels_ready = true;
}

fn enquebMark(queue: *MarkSav, item: *MarkSav) void {
    const p = queue.link.prev.?;
    item.link.next = queue;
    item.link.prev = queue.link.prev;
    p.link.next = item;
    queue.link.prev = item;
}

fn dequeMark(item: *MarkSav) void {
    const n = item.link.next.?;
    const p = item.link.prev.?;
    p.link.next = item.link.next;
    n.link.prev = item.link.prev;
}

fn demoteMark(queue: *MarkSav, item: *MarkSav) void {
    dequeMark(item);
    enquebMark(queue, item);
}

pub export fn upsh(w: ?*anyopaque, k: c_int) c_int {
    _ = w;
    _ = k;
    ensureMarkSentinels();
    const m: *MarkSav = @ptrCast(@alignCast(alitem(@ptrCast(&markfree), @sizeOf(MarkSav)) orelse return -1));
    m.markb = null;
    m.markk = null;
    if (markk != null) _ = pdupown(markk, &m.markk, "upsh");
    if (markb != null) _ = pdupown(markb, &m.markb, "upsh");
    enquebMark(&markstack, m);
    nstack += 1;
    return 0;
}

pub export fn upop(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    ensureMarkSentinels();
    const m = markstack.link.prev.?;
    if (!ptrEq(m, &markstack)) {
        nstack -= 1;
        prm(markk);
        prm(markb);
        markk = m.markk;
        if (markk) |mk| mk.owner = &markk;
        markb = m.markb;
        if (markb) |mb| mb.owner = &markb;
        demoteMark(&markfree, m);
        if (lightoff != 0) _ = unmark(w, 0);
        updall();
        return 0;
    }
    return -1;
}

/// Return true if markb/markk are valid. If `r` is set, swap when needed.
pub export fn markv(r: c_int) c_int {
    if (markb) |mb| {
        if (markk) |mk| {
            if (mb.b == mk.b and
                (if (r == 2) mk.byte >= mb.byte else mk.byte > mb.byte) and
                (square == 0 or (if (r == 2) mk.xcol >= mb.xcol else mk.xcol > mb.xcol)))
            {
                return 1;
            } else if (autoswap != 0 and r != 0 and mb.b == mk.b and mb.byte > mk.byte and
                (square == 0 or mk.xcol < mb.xcol))
            {
                const p = pdup(mb, "markv");
                prm(markb);
                markb = null;
                _ = pdupown(mk, &markb, "markv");
                prm(markk);
                markk = null;
                _ = pdupown(p, &markk, "markv");
                prm(p);
                return 1;
            }
        }
    }
    return 0;
}

pub export fn umarkb(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    _ = pdupown(cur, &markb, "umarkb");
    if (markb) |mb| mb.xcol = cur.xcol;
    updall();
    return 0;
}

pub export fn udrop(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    prm(markk);
    if (marking != 0 and markb != null) {
        prm(markb);
    } else {
        _ = umarkb(w, 0);
    }
    return 0;
}

pub export fn ubegin_marking(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (nowmarking != 0) {
        return 0;
    } else if (markv(0) != 0 and markb != null and cur.b == markb.?.b) {
        if (cur.byte == markb.?.byte) {
            _ = pset(markb, markk);
            prm(markk);
            markk = null;
            nowmarking = 1;
            return 0;
        } else if (cur.byte == markk.?.byte) {
            prm(markk);
            markk = null;
            nowmarking = 1;
            return 0;
        }
    }
    prm(markb);
    markb = null;
    prm(markk);
    markk = null;
    updall();
    nowmarking = 1;
    return umarkb(@ptrCast(bw.parent), 0);
}

pub export fn utoggle_marking(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (markv(0) != 0 and markb != null and cur.b == markb.?.b and
        cur.byte >= markb.?.byte and cur.byte <= markk.?.byte)
    {
        prm(markb);
        markb = null;
        prm(markk);
        markk = null;
        updall();
        nowmarking = 0;
        msgnw(@ptrCast(bw.parent), my_gettext("Selection cleared."));
        return 0;
    } else if (markk != null) {
        prm(markb);
        markb = null;
        prm(markk);
        markk = null;
        updall();
        nowmarking = 1;
        msgnw(@ptrCast(bw.parent), my_gettext("Selection started."));
        return umarkb(@ptrCast(bw.parent), 0);
    } else if (markb != null and markb.?.b == cur.b) {
        nowmarking = 0;
        if (cur.byte < markb.?.byte) {
            _ = pdupown(markb, &markk, "utoggle_marking");
            prm(markb);
            markb = null;
            _ = pdupown(cur, &markb, "utoggle_marking");
            if (markb) |mb| mb.xcol = cur.xcol;
        } else {
            _ = pdupown(cur, &markk, "utoggle_marking");
            if (markk) |mk| mk.xcol = cur.xcol;
        }
        updall();
        return 0;
    } else {
        nowmarking = 1;
        msgnw(@ptrCast(bw.parent), my_gettext("Selection started."));
        return umarkb(@ptrCast(bw.parent), 0);
    }
}

pub export fn uselect(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    if (markb == null) _ = umarkb(w, 0);
    return 0;
}

pub export fn umarkk(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    _ = pdupown(cur, &markk, "umarkk");
    if (markk) |mk| mk.xcol = cur.xcol;
    updall();
    return 0;
}

pub export fn unmark(w: ?*anyopaque, k: c_int) c_int {
    _ = w;
    _ = k;
    prm(markb);
    prm(markk);
    nowmarking = 0;
    updall();
    return 0;
}

pub export fn umarkl(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    _ = p_goto_bol(cur);
    _ = umarkb(w, 0);
    _ = pnextl(cur);
    _ = umarkk(w, 0);
    _ = utomarkb(w, 0);
    _ = pcol(cur, cur.xcol);
    return 0;
}

pub export fn utomarkb(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (markb) |mb| {
        if (mb.b == bw.b) {
            _ = pset(cur, mb);
            return 0;
        }
    }
    return -1;
}

pub export fn utomarkk(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (markk) |mk| {
        if (mk.b == bw.b) {
            _ = pset(cur, mk);
            return 0;
        }
    }
    return -1;
}

pub export fn uswap(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (markb) |mb| {
        if (mb.b == bw.b) {
            const q = pdup(mb, "uswap");
            _ = umarkb(w, 0);
            _ = pset(cur, q);
            prm(q);
            return 0;
        }
    }
    return -1;
}

pub export fn utomarkbk(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (markb) |mb| {
        if (mb.b == bw.b and cur.byte != mb.byte) {
            _ = pset(cur, mb);
            return 0;
        }
    }
    if (markk) |mk| {
        if (mk.b == bw.b and cur.byte != mk.byte) {
            _ = pset(cur, mk);
            return 0;
        }
    }
    return -1;
}

/// Copy a rectangle into a new buffer.
pub export fn pextrect(org: ?*GapP, height_in: i64, right: i64) ?*GapB {
    const orgp = org orelse return null;
    var height = height_in;
    const p = pdup(orgp, "pextrect") orelse return null;
    const q = pdup(p, "pextrect") orelse {
        prm(p);
        return null;
    };
    const tmp = bmk(null) orelse {
        prm(p);
        prm(q);
        return null;
    };
    const z = pdup(tmp.eof, "pextrect") orelse {
        prm(p);
        prm(q);
        brm(tmp);
        return null;
    };
    while (height > 0) : (height -= 1) {
        _ = pcol(p, orgp.xcol);
        _ = pset(q, p);
        _ = pcolwse(q, right);
        _ = p_goto_eof(z);
        _ = binsb(z, bcpy(p, q));
        _ = p_goto_eof(z);
        _ = binsc(z, '\n');
        _ = pnextl(p);
    }
    prm(p);
    prm(q);
    prm(z);
    return tmp;
}

pub export fn pdelrect(org: ?*GapP, height_in: i64, right: i64) void {
    const orgp = org orelse return;
    var height = height_in;
    const p = pdup(orgp, "pdelrect") orelse return;
    const q = pdup(p, "pdelrect") orelse {
        prm(p);
        return;
    };
    while (height > 0) : (height -= 1) {
        _ = pcol(p, orgp.xcol);
        _ = pset(q, p);
        _ = pcol(q, right);
        bdel(p, q);
        _ = pnextl(p);
    }
    prm(p);
    prm(q);
}

pub export fn pclrrect(org: ?*GapP, height_in: i64, right: i64, usetabs: c_int) void {
    const orgp = org orelse return;
    var height = height_in;
    const p = pdup(orgp, "pclrrect") orelse return;
    const q = pdup(p, "pclrrect") orelse {
        prm(p);
        return;
    };
    while (height > 0) : (height -= 1) {
        _ = pcol(p, orgp.xcol);
        _ = pset(q, p);
        _ = pcoli(q, right);
        const pos = q.col;
        bdel(p, q);
        pfill(p, pos, usetabs);
        _ = pnextl(p);
    }
    prm(p);
    prm(q);
}

pub export fn ptabrect(org: ?*GapP, height_in: i64, right: i64) c_int {
    const orgp = org orelse return ' ';
    var height = height_in;
    const p = pdup(orgp, "ptabrect") orelse return ' ';
    while (height > 0) : (height -= 1) {
        _ = pcol(p, orgp.xcol);
        var c: c_int = 0;
        while (true) {
            c = pgetc(p);
            if (c == NO_MORE_DATA or c == '\n') break;
            if (c == '\t') {
                prm(p);
                return '\t';
            } else if (piscol(p) > right) {
                break;
            }
        }
        if (c != '\n') _ = pnextl(p);
    }
    prm(p);
    return ' ';
}

pub export fn pinsrect(cur: ?*GapP, tmp: ?*GapB, width: i64, usetabs: c_int) void {
    const curp = cur orelse return;
    const tmpb = tmp orelse return;
    const p = pdup(curp, "pinsrect") orelse return;
    const q = pdup(tmpb.bof, "pinsrect") orelse {
        prm(p);
        return;
    };
    const r = pdup(q, "pinsrect") orelse {
        prm(p);
        prm(q);
        return;
    };
    while (true) {
        _ = pset(r, q);
        _ = p_goto_eol(q);
        const eof = tmpb.eof orelse break;
        if (!(q.line != eof.line or piscol(q) != 0)) break;
        _ = pcol(p, curp.xcol);
        if (piscol(p) < curp.xcol) pfill(p, curp.xcol, usetabs);
        _ = binsb(p, bcpy(r, q));
        _ = pfwrd(p, q.byte - r.byte);
        if (piscol(p) < curp.xcol + width) pfill(p, curp.xcol + width, usetabs);
        if (piseol(p) != 0) pbackws(p);
        if (pnextl(p) == null) {
            _ = binsc(p, '\n');
            _ = pgetc(p);
        }
        if (pgetc(q) == NO_MORE_DATA) break;
    }
    prm(p);
    prm(q);
    prm(r);
}

pub export fn ublkdel(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    if (markv(1) != 0) {
        const mb = markb orelse return -1;
        const mk = markk orelse return -1;
        if (mb.b != bw.b and modify_logic(@ptrCast(bw), mb.b) == 0) return -1;
        if (square != 0) {
            if (bw.o.overtype != 0) {
                const ocol = mk.xcol;
                pclrrect(mb, mk.line - mb.line + 1, mk.xcol, ptabrect(mb, mk.line - mb.line + 1, mk.xcol));
                _ = pcol(mk, ocol);
                mk.xcol = ocol;
            } else {
                pdelrect(mb, mk.line - mb.line + 1, mk.xcol);
            }
        } else {
            bdel(mb, mk);
        }
        if (lightoff != 0) _ = unmark(@ptrCast(bw.parent), 0);
    } else {
        msgnw(@ptrCast(bw.parent), my_gettext("No block"));
        return -1;
    }
    return 0;
}

pub export fn upicokill(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    _ = upsh(w, 0);
    _ = umarkk(w, 0);
    if (markv(1) != 0) {
        const mb = markb orelse return -1;
        const mk = markk orelse return -1;
        if (square != 0) {
            if (bw.o.overtype != 0) {
                const ocol = mk.xcol;
                pclrrect(mb, mk.line - mb.line + 1, mk.xcol, ptabrect(mb, mk.line - mb.line + 1, mk.xcol));
                _ = pcol(mk, ocol);
                mk.xcol = ocol;
            } else {
                pdelrect(mb, mk.line - mb.line + 1, mk.xcol);
            }
        } else {
            bdel(mb, mk);
        }
        if (lightoff != 0) _ = unmark(w, 0);
    } else {
        _ = udelln(w, 0);
    }
    return 0;
}

pub export fn ublkmove(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (markv(1) != 0) {
        const mb = markb orelse return -1;
        const mk = markk orelse return -1;
        if (mb.b != bw.b and modify_logic(@ptrCast(bw), mb.b) == 0) return -1;
        if (square != 0) {
            const height = mk.line - mb.line + 1;
            const width = mk.xcol - mb.xcol;
            const usetabs = ptabrect(mb, height, mk.xcol);
            const ocol = piscol(cur);
            const tmp = pextrect(mb, height, mk.xcol);
            const update_xcol = cur.xcol >= mk.xcol and cur.line >= mb.line and cur.line <= mk.line;
            _ = ublkdel(w, 0);
            if (bw.o.overtype != 0) {
                _ = pcol(cur, ocol);
                pfill(cur, ocol, ' ');
                pdelrect(cur, height, piscol(cur) + width);
            } else if (update_xcol) {
                cur.xcol -= width;
            }
            pinsrect(cur, tmp, width, usetabs);
            brm(tmp);
            if (lightoff != 0) {
                _ = unmark(@ptrCast(bw.parent), 0);
            } else {
                _ = umarkb(@ptrCast(bw.parent), 0);
                _ = umarkk(@ptrCast(bw.parent), 0);
                if (markk) |nmk| {
                    if (markb) |nmb| {
                        _ = pline(nmk, nmk.line + height - 1);
                        _ = pcol(nmk, nmb.xcol + width);
                        nmk.xcol = nmb.xcol + width;
                    }
                }
            }
            return 0;
        } else if (cur.b != mk.b or cur.byte > mk.byte or cur.byte < mb.byte) {
            const size = mk.byte - mb.byte;
            _ = binsb(cur, bcpy(mb, mk));
            bdel(mb, mk);
            if (lightoff != 0) {
                _ = unmark(@ptrCast(bw.parent), 0);
            } else {
                _ = umarkb(@ptrCast(bw.parent), 0);
                _ = umarkk(@ptrCast(bw.parent), 0);
                if (markk) |nmk| _ = pfwrd(nmk, size);
            }
            updall();
            return 0;
        }
    }
    msgnw(@ptrCast(bw.parent), my_gettext("No block"));
    return -1;
}

fn screenOf(bw: *BwRec) ?*anyopaque {
    if (maint != null) {
        if (maint.*.t) |t| return t;
    }
    // BW.t / W.t is `Screen*`; first field is `SCRN *t`.
    const screen = bw.t orelse (if (bw.parent) |w| w.t else null) orelse return null;
    const head: *extern struct { t: ?*anyopaque } = @ptrCast(@alignCast(screen));
    return head.t;
}

/// After a mouse paste: clear highlight and force every cell to be rewritten.
fn finishMousePaste(bw: *BwRec, w: ?*anyopaque) void {
    _ = unmark(w, 0);
    if (screenOf(bw)) |scrn| {
        // Poison cells + drop pending IL/DL. Do not nredraw here: that emits
        // DECSTBM/cl and leaves relative CUP starting from a stale physical
        // cursor (Ghostty then shifts the whole window).
        scrn_invalidate(scrn);
    } else {
        updall();
    }
}

pub export fn ublkcpy(w: ?*anyopaque, k: c_int) c_int {
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (markv(1) != 0) {
        const mb = markb orelse return -1;
        const mk = markk orelse return -1;
        if (square != 0) {
            const height = mk.line - mb.line + 1;
            const width = mk.xcol - mb.xcol;
            const usetabs = ptabrect(mb, height, mk.xcol);
            const tmp = pextrect(mb, height, mk.xcol);
            if (bw.o.overtype != 0) pdelrect(cur, height, piscol(cur) + width);
            const dest_line = cur.line + height - 1;
            const dest_col = cur.xcol + width;
            pinsrect(cur, tmp, width, usetabs);
            brm(tmp);
            if (k == -2) {
                _ = pline(cur, dest_line);
                _ = pcol(cur, dest_col);
                cur.xcol = dest_col;
                finishMousePaste(bw, w);
            } else if (lightoff != 0) {
                _ = unmark(@ptrCast(bw.parent), 0);
            } else {
                _ = umarkb(@ptrCast(bw.parent), 0);
                _ = umarkk(@ptrCast(bw.parent), 0);
                if (markk) |nmk| {
                    if (markb) |nmb| {
                        _ = pline(nmk, nmk.line + height - 1);
                        _ = pcol(nmk, nmb.xcol + width);
                        nmk.xcol = nmb.xcol + width;
                    }
                }
            }
            return 0;
        } else {
            const size = mk.byte - mb.byte;
            const tmp = bcpy(mb, mk);
            if (bw.o.hex != 0 and bw.o.overtype != 0) {
                const q = pdup(cur, "ublkcpy") orelse return -1;
                const eof = q.b.?.eof orelse {
                    prm(q);
                    return -1;
                };
                if (q.byte + size >= eof.byte) {
                    _ = pset(q, eof);
                } else {
                    _ = pfwrd(q, size);
                }
                bdel(cur, q);
                prm(q);
            }
            if (k == -2) {
                // End-pointer rides the insert: fixupins advances it by amnt/nlines,
                // so the caret lands after the paste with a consistent line count
                // (pfwrd over freshly stolen headers can desync `line` vs `byte`).
                const end_ptr = pdup(cur, "ublkcpy") orelse return -1;
                end_ptr.end = 1;
                _ = binsb(cur, tmp);
                _ = pset(cur, end_ptr);
                cur.end = 0;
                cur.xcol = piscol(cur);
                prm(end_ptr);
                finishMousePaste(bw, w);
            } else {
                _ = binsb(cur, tmp);
                if (lightoff != 0) {
                    _ = unmark(@ptrCast(bw.parent), 0);
                } else {
                    _ = umarkb(@ptrCast(bw.parent), 0);
                    _ = umarkk(@ptrCast(bw.parent), 0);
                    if (markk) |nmk| _ = pfwrd(nmk, size);
                }
                updall();
            }
            return 0;
        }
    } else {
        msgnw(@ptrCast(bw.parent), my_gettext("No block"));
        return -1;
    }
}

/// Set highlighted block on a program indent block.
pub export fn setindent(bw_in: ?*anyopaque) void {
    const bw = @as(*BwRec, @ptrCast(@alignCast(bw_in orelse return)));
    const cur = bw.cursor orelse return;
    if (pisblank(cur) != 0) return;

    const p = pdup(cur, "setindent") orelse return;
    const q = pdup(p, "setindent") orelse {
        prm(p);
        return;
    };
    const indent = pisindent(p);

    var at_bof = false;
    while (true) {
        if (pprevl(p) == null) {
            at_bof = true;
            break;
        }
        _ = p_goto_bol(p);
        if (!(pisindent(p) >= indent or pisblank(p) != 0)) break;
    }
    if (!at_bof) _ = pnextl(p);

    _ = p_goto_bol(p);
    p.xcol = piscol(p);
    prm(markb);
    markb = p;
    p.owner = &markb;

    while (true) {
        if (pnextl(q) == null) break;
        if (!(pisindent(q) >= indent or pisblank(q) != 0)) break;
    }
    prm(markk);
    q.xcol = piscol(q);
    markk = q;
    q.owner = &markk;

    updall();
}

fn getCommonIndentWidth() i64 {
    const mb = markb orelse return 0;
    const mk = markk orelse return 0;
    const p = pdup(mb, "get_common_indent_width") orelse return 0;
    defer prm(p);
    var maxwidth: i64 = 0x7FFFFFFF;
    _ = p_goto_bol(p);
    while (p.byte < mk.byte) {
        var width: i64 = 0;
        while (true) {
            const c = pgetc(p);
            if (!(c == ' ' or c == '\t')) break;
            width = p.col;
        }
        if (width < maxwidth) maxwidth = width;
        _ = pnextl(p);
    }
    const b = mb.b orelse return maxwidth;
    if (b.o.indentc == '\t') {
        const step = b.o.tab * b.o.istep;
        if (step == 0) return maxwidth;
        return maxwidth - @mod(maxwidth, step);
    } else {
        if (b.o.istep == 0) return maxwidth;
        return maxwidth - @mod(maxwidth, b.o.istep);
    }
}

fn isPure(p: *GapP, c: c_int, n: i64) bool {
    const col = piscol(p) + n;
    while (piscol(p) < col) {
        if (pgetc(p) != c) return false;
    }
    return true;
}

fn eatPretabSpaces(p: *GapP, limit: i64) void {
    var col = piscol(p);
    const q = pdup(p, "eat_pretab_spaces") orelse return;
    defer prm(q);
    const b = p.b orelse return;
    const tab = b.o.tab;
    if (tab == 0) return;
    col -= @mod(col, tab);
    _ = pcol(q, col);

    var c = brc(q);
    while (c == ' ' and q.col < limit) {
        c = pgetc(q);
    }
    if (piscol(q) >= limit) {
        _ = pcol(q, limit);
        c = '\t';
    }
    var del = piscol(q) - col;
    if (del != 0) {
        if (c != '\t') {
            del -= @mod(del, tab);
            _ = pcol(q, col + del);
        }
        if (del != 0) {
            bdel(p, q);
            pfill(q, col + del - @mod(del, tab), '\t');
        }
    }
}

fn lindentCheck(c: c_int, n: i64) bool {
    const mb = markb orelse return false;
    const mk = markk orelse return false;
    const p = pdup(mb, "lindent_check") orelse return false;
    const q = pdup(mb, "lindent_check") orelse {
        prm(p);
        return false;
    };
    defer {
        prm(q);
        prm(p);
    }
    const indwid: i64 = if (c == '\t') blk: {
        const b = p.b orelse return false;
        break :blk n * b.o.tab;
    } else n;

    if (c == ' ' or c == '\t') {
        while (p.byte < mk.byte) {
            _ = p_goto_bol(p);
            if (piseol(p) == 0 and pisindent(p) < indwid) return false;
            _ = pnextl(p);
        }
    } else {
        while (p.byte < mk.byte) {
            _ = p_goto_bol(p);
            if (piseol(p) == 0) {
                _ = pset(q, p);
                var x: i64 = 0;
                while (x < indwid and pgetc(q) == c) : (x += 1) {}
                if (x < indwid) return false;
            }
            _ = pnextl(p);
        }
    }
    return true;
}

pub export fn urindent(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (square != 0) {
        if (markb) |mb| {
            if (markk) |mk| {
                if (mb.b == mk.b and mb.byte <= mk.byte and mb.xcol <= mk.xcol) {
                    const p = pdup(mb, "urindent") orelse return -1;
                    defer prm(p);
                    while (true) {
                        _ = pcol(p, mb.xcol);
                        pfill(p, mb.xcol + bw.o.istep, bw.o.indentc);
                        if (pnextl(p) == null or p.line > mk.line) break;
                    }
                }
            }
        }
    } else {
        if (markb == null or markk == null or markb.?.b != markk.?.b or
            cur.byte < markb.?.byte or cur.byte > markk.?.byte or markb.?.byte == markk.?.byte)
        {
            setindent(bw);
        } else {
            const mb = markb.?;
            const mk = markk.?;
            const p = pdup(mb, "urindent") orelse return -1;
            const q = pdup(mb, "urindent") orelse {
                prm(p);
                return -1;
            };
            defer {
                prm(p);
                prm(q);
            }
            const common_width = getCommonIndentWidth();
            const indwid: i64 = if (bw.o.indentc == '\t') bw.o.tab * bw.o.istep else bw.o.istep;

            while (p.byte < mk.byte) {
                _ = p_goto_bol(p);
                if (piseol(p) == 0) {
                    _ = pset(q, p);
                    if (bw.o.indentc == ' ' and brc(p) == '\t') {
                        _ = p_goto_indent(q, bw.o.indentc);
                        const col = piscol(q);
                        bdel(p, q);
                        pfill(p, col + indwid, bw.o.indentc);
                    } else {
                        if (bw.o.indentc == '\t') {
                            var col: i64 = 0;
                            while (col < common_width) : (col += bw.o.tab) {
                                _ = pcol(q, col);
                                eatPretabSpaces(q, common_width);
                            }
                        }
                        while (piscol(p) < bw.o.istep) {
                            _ = binsc(p, bw.o.indentc);
                            _ = pgetc(p);
                        }
                    }
                }
                _ = pnextl(p);
            }
        }
    }
    return 0;
}

pub export fn ulindent(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (square != 0) {
        if (markb) |mb| {
            if (markk) |mk| {
                if (mb.b == mk.b and mb.byte <= mk.byte and mb.xcol <= mk.xcol) {
                    const p = pdup(mb, "ulindent") orelse return -1;
                    const q = pdup(p, "ulindent") orelse {
                        prm(p);
                        return -1;
                    };
                    defer {
                        prm(p);
                        prm(q);
                    }
                    while (true) {
                        _ = pcol(p, mb.xcol);
                        while (piscol(p) < mb.xcol + bw.o.istep) {
                            const c = pgetc(p);
                            if (c != ' ' and c != '\t' and c != bw.o.indentc) return -1;
                        }
                        if (pnextl(p) == null or p.line > mk.line) break;
                    }
                    _ = pset(p, mb);
                    while (true) {
                        _ = pcol(p, mb.xcol);
                        _ = pset(q, p);
                        _ = pcol(q, mb.xcol + bw.o.istep);
                        bdel(p, q);
                        if (pnextl(p) == null or p.line > mk.line) break;
                    }
                }
            }
        }
    } else {
        if (markb == null or markk == null or markb.?.b != markk.?.b or
            cur.byte < markb.?.byte or cur.byte > markk.?.byte or markb.?.byte == markk.?.byte)
        {
            setindent(bw);
        } else if (lindentCheck(bw.o.indentc, bw.o.istep)) {
            const mb = markb.?;
            const mk = markk.?;
            const p = pdup(mb, "ulindent") orelse return -1;
            const q = pdup(mb, "ulindent") orelse {
                prm(p);
                return -1;
            };
            defer {
                prm(p);
                prm(q);
            }
            const common_width = getCommonIndentWidth();
            const indwid: i64 = if (bw.o.indentc == '\t') bw.o.tab * bw.o.istep else bw.o.istep;

            while (p.byte < mk.byte) {
                _ = p_goto_bol(p);
                if (piseol(p) == 0) {
                    _ = pset(q, p);
                    if (isPure(q, bw.o.indentc, common_width)) {
                        _ = pset(q, p);
                        while (piscol(q) < bw.o.istep) _ = pgetc(q);
                        bdel(p, q);
                    } else if (bw.o.indentc == '\t') {
                        _ = pcol(q, common_width);
                        bdel(p, q);
                        if (common_width > bw.o.tab) {
                            pfill(p, common_width - bw.o.tab, '\t');
                        }
                    } else {
                        _ = pset(q, p);
                        _ = p_goto_indent(q, bw.o.indentc);
                        const col = piscol(q);
                        bdel(p, q);
                        pfill(p, col - indwid, bw.o.indentc);
                    }
                }
                _ = pnextl(p);
            }
        } else {
            msgnw(@ptrCast(bw.parent), my_gettext("Selected lines not properly indented"));
            return 1;
        }
    }
    return 0;
}

// --- Path A: filter, case fold, blksum/blklr/blkget ---

const intern = @import("gapbuffer/intern.zig");

const ScreenRec = extern struct {
    t: ?*anyopaque,
    wind: isize,
    topwin: ?*WinRec,
    curwin: ?*WinRec,
    w: isize,
    h: isize,
};

const PWFLAG_COMMAND: c_int = 8;
const MAXOFF: i64 = @divTrunc(std.math.maxInt(u64), 2) - 1;

export var filthist: ?*GapB = null;
var filtflg: c_int = 0;

extern fn bload(s: [*c]const u8) ?*GapB;
extern fn bread(fi: c_int, max: i64, binary: c_int) ?*GapB;
extern fn bsavefd(p: ?*GapP, fd: c_int, size: i64) c_int;
extern fn off_max(a: i64, b: i64) i64;
extern fn vsrm(s: [*c]u8) void;
extern fn vsncpy(vary: [*c]u8, pos: isize, array: [*c]const u8, len: isize) [*c]u8;
extern fn slen(s: [*c]const u8) isize;
extern fn nescape(t: ?*anyopaque) void;
extern fn nreturn(t: ?*anyopaque) void;
extern fn ttclsn() void;
extern fn ttopnn() void;
extern fn signrm() void;
extern fn prgetc(p: ?*GapP) c_int;
extern fn joe_strtod(ptr: [*c]const u8, at_eptr: ?*?[*:0]const u8) f64;
extern fn to_uni(map: ?*anyopaque, c: c_int) c_int;
extern fn utf8_encode(buf: [*]u8, c: c_int) isize;
extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn joe_realloc(ptr: ?*anyopaque, size: isize) ?*anyopaque;
extern fn cmplt_command(bw: ?*anyopaque, k: c_int) c_int;
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
extern var locale_map: ?*anyopaque;
extern fn pipe(fds: *[2]c_int) c_int;
extern fn fork() c_int;
extern fn close(fd: c_int) c_int;
extern fn dup(fd: c_int) c_int;
extern fn execl(path: [*:0]const u8, arg0: [*:0]const u8, ...) c_int;
extern fn _exit(status: c_int) noreturn;
extern fn wait(status: ?*c_int) c_int;
extern fn putenv(string: [*:0]u8) c_int;

fn scrnOf(bw: *BwRec) ?*anyopaque {
    const parent = bw.parent orelse return null;
    const scr: *ScreenRec = @ptrCast(@alignCast(parent.t orelse return null));
    return scr.t;
}

fn vsLen(s: [*c]u8) isize {
    if (s == null) return 0;
    return (@as([*]align(1) const isize, @ptrCast(s)) - 1)[0];
}

fn joeTolower(map: ?*anyopaque, c: c_int) c_int {
    return intern.joe_tolower_v(map, c);
}

fn joeToupper(map: ?*anyopaque, c: c_int) c_int {
    return intern.joe_toupper_v(map, c);
}

fn msgBerror(bw: *BwRec) void {
    const err = intern.berror;
    if (err < 0 and -err < intern.msgs.len) {
        msgnw(@ptrCast(bw.parent), @ptrCast(intern.msgs[@intCast(-err)]));
    }
}

pub export fn doinsf(w: ?*anyopaque, s_in: [*c]u8, object: ?*anyopaque, notify: ?*c_int) c_int {
    _ = object;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (notify) |n| n.* = 1;
    if (square != 0) {
        if (markv(2) != 0) {
            const mb = markb orelse return -1;
            const mk = markk orelse return -1;
            const width = mk.xcol - mb.xcol;
            const usetabs = ptabrect(mb, mk.line - mb.line + 1, mk.xcol);
            const tmp = bload(s_in);
            if (intern.berror != 0) {
                msgBerror(bw);
                brm(tmp);
                return -1;
            }
            const eof = tmp.?.eof orelse {
                brm(tmp);
                return -1;
            };
            const height: i64 = if (piscol(eof) != 0) eof.line + 1 else eof.line;
            if (bw.o.overtype != 0) {
                pclrrect(mb, off_max(mk.line - mb.line + 1, height), mk.xcol, usetabs);
                pdelrect(mb, height, width + mb.xcol);
            }
            pinsrect(mb, tmp, width, usetabs);
            _ = pdupown(mb, &markk, "doinsf");
            if (markk) |nmk| {
                nmk.xcol = mb.xcol;
                if (height != 0) {
                    _ = pline(nmk, nmk.line + height - 1);
                    _ = pcol(nmk, mb.xcol + width);
                    nmk.xcol = mb.xcol + width;
                }
            }
            brm(tmp);
            updall();
            return 0;
        } else {
            msgnw(@ptrCast(bw.parent), my_gettext("No block"));
            return -1;
        }
    } else {
        var ret: c_int = 0;
        const tmp = bload(s_in);
        if (intern.berror != 0) {
            msgBerror(bw);
            brm(tmp);
            ret = -1;
        } else {
            _ = binsb(cur, tmp);
        }
        vsrm(s_in);
        cur.xcol = piscol(cur);
        return ret;
    }
}

fn markall(bw: *BwRec) void {
    const cur = bw.cursor orelse return;
    const b = cur.b orelse return;
    _ = pdupown(b.bof, &markb, "markall");
    if (markb) |mb| mb.xcol = 0;
    _ = pdupown(b.eof, &markk, "markall");
    if (markk) |mk| mk.xcol = piscol(mk);
    updall();
}

fn checkmark(bw: *BwRec) c_int {
    if (markv(1) == 0) {
        if (square != 0) return 2;
        markall(bw);
        filtflg = 1;
        return 1;
    } else {
        filtflg = 0;
        return 0;
    }
}

fn dofilt(w: ?*anyopaque, s_in: [*c]u8, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    var fr: [2]c_int = undefined;
    var fw: [2]c_int = undefined;
    var flg: c_int = 0;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;

    if (notify) |n| n.* = 1;
    if (markb != null and markk != null and square == 0 and markb.?.b == bw.b and markk.?.b == bw.b and markb.?.byte == markk.?.byte) {
        flg = 1;
    } else if (markv(1) == 0) {
        msgnw(@ptrCast(bw.parent), my_gettext("No block"));
        return -1;
    }

    const mb = markb orelse return -1;
    const mk = markk orelse return -1;
    if (mb.b != bw.b and modify_logic(@ptrCast(bw), mb.b) == 0) return -1;

    if (pipe(&fr) == -1) {
        msgnw(@ptrCast(bw.parent), my_gettext("Couldn't create pipe"));
        return -1;
    }
    if (pipe(&fw) == -1) {
        msgnw(@ptrCast(bw.parent), my_gettext("Couldn't create pipe"));
        return -1;
    }
    nescape(scrnOf(bw));
    ttclsn();

    const child1 = fork();
    if (child1 == 0) {
        signrm();
        _ = close(0);
        _ = close(1);
        _ = close(2);
        if (dup(fw[0]) == -1) _exit(1);
        if (dup(fr[1]) == -1) _exit(1);
        if (dup(fr[1]) == -1) _exit(1);
        _ = close(fw[0]);
        _ = close(fr[1]);
        _ = close(fw[1]);
        _ = close(fr[0]);
        const prefix = "JOE_FILENAME=";
        var fname = vsncpy(null, 0, prefix, prefix.len);
        const nam: [*c]const u8 = if (bw.b) |bb| blk: {
            if (bb.name) |n| break :blk @ptrCast(@alignCast(n));
            break :blk "Unnamed";
        } else "Unnamed";
        var nlen = slen(nam);
        if (nlen >= 512) nlen = 512;
        fname = vsncpy(fname, vsLen(fname), nam, nlen);
        _ = putenv(@ptrCast(fname));
        vsrm(fname);
        _ = execl("/bin/sh", "/bin/sh", "-c", s_in, @as(?[*:0]const u8, null));
        _exit(0);
    }

    _ = close(fr[1]);
    _ = close(fw[0]);
    const child2 = fork();
    if (child2 != 0) {
        _ = close(fw[1]);
        if (square != 0) {
            const width = mk.xcol - mb.xcol;
            const usetabs = ptabrect(mb, mk.line - mb.line + 1, mk.xcol);
            const tmp = bread(fr[0], MAXOFF, 0);
            const eof = tmp.?.eof orelse {
                brm(tmp);
                return -1;
            };
            const height: i64 = if (piscol(eof) != 0) eof.line + 1 else eof.line;
            if (bw.o.overtype != 0) {
                pclrrect(mb, mk.line - mb.line + 1, mk.xcol, usetabs);
                pdelrect(mb, off_max(height, mk.line - mb.line + 1), width + mb.xcol);
            } else {
                pdelrect(mb, mk.line - mb.line + 1, mk.xcol);
            }
            pinsrect(mb, tmp, width, usetabs);
            _ = pdupown(mb, &markk, "dofilt");
            if (markk) |nmk| {
                nmk.xcol = mb.xcol;
                if (height != 0) {
                    _ = pline(nmk, nmk.line + height - 1);
                    _ = pcol(nmk, mb.xcol + width);
                    nmk.xcol = mb.xcol + width;
                }
            }
            if (lightoff != 0) _ = unmark(@ptrCast(bw.parent), 0);
            brm(tmp);
            updall();
        } else {
            const p = pdup(mk, "dofilt") orelse return -1;
            if (flg == 0) _ = prgetc(p);
            bdel(mb, p);
            _ = binsb(p, bread(fr[0], MAXOFF, 0));
            if (flg == 0) {
                _ = pset(p, markk);
                _ = prgetc(p);
                bdel(p, markk);
            }
            prm(p);
            if (lightoff != 0) _ = unmark(@ptrCast(bw.parent), 0);
        }
        _ = close(fr[0]);
        _ = wait(null);
        _ = wait(null);
    } else {
        if (square != 0) {
            const tmp = pextrect(mb, mk.line - mb.line + 1, mk.xcol);
            _ = bsavefd(tmp.?.bof, fw[1], tmp.?.eof.?.byte);
            brm(tmp);
        } else {
            _ = bsavefd(mb, fw[1], mk.byte - mb.byte);
        }
        _ = close(fw[1]);
        _exit(0);
    }
    vsrm(s_in);
    ttopnn();
    nreturn(scrnOf(bw));
    if (filtflg != 0) _ = unmark(@ptrCast(bw.parent), 0);
    cur.xcol = piscol(cur);
    return 0;
}

pub export fn ufilt(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    switch (checkmark(bw)) {
        0 => {
            const prompt = my_gettext("Command to filter block through (%{abort} to abort): ");
            if (wmkpw(@ptrCast(bw.parent), prompt, &filthist, &dofilt, null, null, &cmplt_command, null, null, locale_map, PWFLAG_COMMAND) != null) return 0;
            return -1;
        },
        1 => {
            const prompt = my_gettext("Command to filter file through (%{abort} to abort): ");
            if (wmkpw(@ptrCast(bw.parent), prompt, &filthist, &dofilt, null, null, &cmplt_command, null, null, locale_map, PWFLAG_COMMAND) != null) return 0;
            return -1;
        },
        else => {
            msgnw(@ptrCast(bw.parent), my_gettext("No block"));
            return -1;
        },
    }
}

pub export fn ulower(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (markv(1) != 0) {
        const mb = markb orelse return -1;
        const mk = markk orelse return -1;
        const b = bcpy(mb, mk) orelse return -1;
        const q = pdup(mk, "ulower") orelse {
            brm(b);
            return -1;
        };
        _ = prgetc(q);
        bdel(mb, q);
        if (mb.b) |srcb| b.o.charmap = srcb.o.charmap;
        const p = pdup(b.bof, "ulower") orelse {
            prm(q);
            brm(b);
            return -1;
        };
        while (true) {
            var c = pgetc(p);
            if (c == NO_MORE_DATA) break;
            c = joeTolower(@ptrCast(b.o.charmap), c);
            _ = binsc(q, c);
            _ = pgetc(q);
        }
        prm(p);
        bdel(q, mk);
        prm(q);
        brm(b);
        cur.xcol = piscol(cur);
        return 0;
    }
    return -1;
}

pub export fn uupper(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (markv(1) != 0) {
        const mb = markb orelse return -1;
        const mk = markk orelse return -1;
        const b = bcpy(mb, mk) orelse return -1;
        const q = pdup(mk, "uupper") orelse {
            brm(b);
            return -1;
        };
        _ = prgetc(q);
        bdel(mb, q);
        if (mb.b) |srcb| b.o.charmap = srcb.o.charmap;
        const p = pdup(b.bof, "uupper") orelse {
            prm(q);
            brm(b);
            return -1;
        };
        while (true) {
            var c = pgetc(p);
            if (c == NO_MORE_DATA) break;
            c = joeToupper(@ptrCast(b.o.charmap), c);
            _ = binsc(q, c);
            _ = pgetc(q);
        }
        prm(p);
        bdel(q, mk);
        prm(q);
        brm(b);
        cur.xcol = piscol(cur);
        return 0;
    }
    return -1;
}

fn isNumStart(c: c_int) bool {
    return (c >= '0' and c <= '9') or c == '.' or c == '-';
}

fn isNumCont(c: c_int) bool {
    return (c >= '0' and c <= '9') or c == 'e' or c == 'E' or
        c == 'p' or c == 'P' or c == 'x' or c == 'X' or
        c == '.' or c == '-' or c == '+' or c == 'o' or c == 'O' or
        (c >= 'a' and c <= 'f') or (c >= 'A' and c <= 'F') or c == '_';
}

pub export fn blksum(bw_in: ?*anyopaque, sum: ?*f64, sumsq: ?*f64) c_int {
    const bw = @as(*BwRec, @ptrCast(@alignCast(bw_in orelse return -1)));
    if (checkmark(bw) == 2) return -1;
    const mb = markb orelse return -1;
    const mk = markk orelse return -1;
    const q = pdup(mb, "blksum") orelse return -1;
    defer prm(q);
    var buf: [80]u8 = undefined;
    var accu: f64 = 0.0;
    var accusq: f64 = 0.0;
    var count: c_int = 0;
    const left = mb.xcol;
    const right = mk.xcol;
    while (q.byte < mk.byte) {
        while (q.byte < mk.byte and square != 0 and (piscol(q) < left or piscol(q) >= right)) _ = pgetc(q);
        while (q.byte < mk.byte and (square == 0 or (piscol(q) >= left and piscol(q) < right))) {
            var c = pgetc(q);
            if (isNumStart(c)) {
                buf[0] = @truncate(@as(u32, @bitCast(c)));
                var x: usize = 1;
                while (q.byte < mk.byte and (square == 0 or (piscol(q) >= left and piscol(q) < right))) {
                    c = pgetc(q);
                    if (isNumCont(c)) {
                        if (x != 79) {
                            buf[x] = @truncate(@as(u32, @bitCast(c)));
                            x += 1;
                        }
                    } else break;
                }
                buf[x] = 0;
                const v = joe_strtod(&buf, null);
                count += 1;
                accu += v;
                accusq += v * v;
                break;
            }
        }
    }
    if (sum) |s| s.* = accu;
    if (sumsq) |s| s.* = accusq;
    if (filtflg != 0) _ = unmark(@ptrCast(bw.parent), 0);
    return count;
}

pub export fn blklr(
    bw_in: ?*anyopaque,
    xsum: ?*f64,
    xsumsq: ?*f64,
    ysum: ?*f64,
    ysumsq: ?*f64,
    xy: ?*f64,
    logx: c_int,
    logy: c_int,
) c_int {
    const bw = @as(*BwRec, @ptrCast(@alignCast(bw_in orelse return -1)));
    if (checkmark(bw) == 2) return -1;
    const mb = markb orelse return -1;
    const mk = markk orelse return -1;
    const q = pdup(mb, "blklr") orelse return -1;
    defer prm(q);
    var buf: [80]u8 = undefined;
    var accux: f64 = 0.0;
    var accuxsq: f64 = 0.0;
    var accuy: f64 = 0.0;
    var accuysq: f64 = 0.0;
    var accuxy: f64 = 0.0;
    var prevx: f64 = 0.0;
    var state: c_int = 0;
    var count: c_int = 0;
    const left = mb.xcol;
    const right = mk.xcol;
    while (q.byte < mk.byte) {
        while (q.byte < mk.byte and square != 0 and (piscol(q) < left or piscol(q) >= right)) _ = pgetc(q);
        while (q.byte < mk.byte and (square == 0 or (piscol(q) >= left and piscol(q) < right))) {
            var c = pgetc(q);
            if (isNumStart(c)) {
                buf[0] = @truncate(@as(u32, @bitCast(c)));
                var x: usize = 1;
                while (q.byte < mk.byte and (square == 0 or (piscol(q) >= left and piscol(q) < right))) {
                    c = pgetc(q);
                    if (isNumCont(c)) {
                        if (x != 79) {
                            buf[x] = @truncate(@as(u32, @bitCast(c)));
                            x += 1;
                        }
                    } else break;
                }
                buf[x] = 0;
                var v = joe_strtod(&buf, null);
                if (state == 0) {
                    if (logx != 0) v = @log(v);
                    prevx = v;
                    accux += v;
                    accuxsq += v * v;
                    state = 1;
                } else {
                    if (logy != 0) v = @log(v);
                    accuy += v;
                    accuysq += v * v;
                    accuxy += prevx * v;
                    state = 0;
                    count += 1;
                }
                break;
            }
        }
    }
    if (xsum) |s| s.* = accux;
    if (xsumsq) |s| s.* = accuxsq;
    if (ysum) |s| s.* = accuy;
    if (ysumsq) |s| s.* = accuysq;
    if (xy) |s| s.* = accuxy;
    if (filtflg != 0) _ = unmark(@ptrCast(bw.parent), 0);
    if (state != 0) return -1;
    return count;
}

pub export fn blkget(bw_in: ?*anyopaque) [*c]u8 {
    const bw = @as(*BwRec, @ptrCast(@alignCast(bw_in orelse return null)));
    if (checkmark(bw) == 2) return null;
    const mb = markb orelse return null;
    const mk = markk orelse return null;
    var buf_size: isize = mk.byte - mb.byte + 1;
    var buf_x: isize = 0;
    var buf: [*c]u8 = @ptrCast(@alignCast(joe_malloc(buf_size) orelse return null));
    const left = mb.xcol;
    const right = mk.xcol;
    const q = pdup(mb, "blkget") orelse {
        // leak matches failed alloc path rarity; still free
        return null;
    };
    while (q.byte < mk.byte) {
        while (q.byte < mk.byte and square != 0 and (piscol(q) < left or piscol(q) >= right)) _ = pgetc(q);
        while (q.byte < mk.byte and (square == 0 or (piscol(q) >= left and piscol(q) < right))) {
            var ch = pgetc(q);
            var bf: [8]u8 = undefined;
            const map = if (q.b) |b| b.o.charmap else null;
            if (map == null or map.?.@"type" == 0) {
                ch = to_uni(@ptrCast(map), ch);
            }
            const len = utf8_encode(&bf, ch);
            var xi: isize = 0;
            while (xi != len) : (xi += 1) {
                if (buf_x == buf_size - 1) {
                    buf_size *= 2;
                    buf = @ptrCast(@alignCast(joe_realloc(buf, buf_size) orelse {
                        prm(q);
                        return null;
                    }));
                }
                buf[@intCast(buf_x)] = bf[@intCast(xi)];
                buf_x += 1;
            }
        }
        if (square != 0 and q.byte < mk.byte and piscol(q) >= right) {
            if (buf_x == buf_size - 1) {
                buf_size *= 2;
                buf = @ptrCast(@alignCast(joe_realloc(buf, buf_size) orelse {
                    prm(q);
                    return null;
                }));
            }
            buf[@intCast(buf_x)] = '\n';
            buf_x += 1;
        }
    }
    prm(q);
    buf[@intCast(buf_x)] = 0;
    if (filtflg != 0) _ = unmark(@ptrCast(bw.parent), 0);
    return buf;
}
