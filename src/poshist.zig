//! Path A live port of JOE position history (`joe/poshist.c`).
//!
//! JOE `poshist.h` ABI lives here (`afterpos`, `aftermove`, `windie`,
//! `uprevpos`, `unextpos`). `joe/poshist.c` is a tombstone.

const std = @import("std");
const gap_types = @import("gapbuffer/types.zig");

const GapP = gap_types.P;
const GapB = gap_types.B;

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;

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

const Screen = extern struct {
    t: ?*anyopaque,
    wind: isize,
    topwin: ?*WinRec,
    curwin: ?*WinRec,
    w: isize,
    h: isize,
};

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
    kbd: ?*anyopaque,
    watom: ?*const Watom,
    object: ?*anyopaque,
    msgt: ?[*:0]const u8,
    msgb: ?[*:0]const u8,
    huh: ?[*:0]const u8,
    notify: ?*c_int,
    bstack: ?*anyopaque,
};

const BwRec = extern struct {
    parent: ?*WinRec,
    b: ?*GapB,
    top: ?*GapP,
    cursor: ?*GapP,
    offset: i64,
    // remainder unused by poshist
};

comptime {
    if (@sizeOf(WinRec) != 200) @compileError("WinRec size mismatch");
    if (@offsetOf(BwRec, "cursor") != 24) @compileError("BwRec.cursor offset");
    if (@offsetOf(Screen, "curwin") != 24) @compileError("Screen.curwin offset");
}

const PosLink = extern struct {
    next: ?*Pos,
    prev: ?*Pos,
};

const Pos = extern struct {
    link: PosLink,
    p: ?*GapP,
    w: ?*WinRec,
};

var pos: Pos = undefined;
var frpos: Pos = undefined;
var curpos: *Pos = undefined;
var npos: c_int = 0;
var pos_ready: bool = false;

extern fn alitem(list: ?*anyopaque, itemsize: isize) ?*anyopaque;
extern fn pdupown(p: ?*GapP, owner: ?*?*GapP, tr: [*c]const u8) ?*GapP;
extern fn poffline(p: ?*GapP) ?*GapP;
extern fn prm(p: ?*GapP) void;
extern fn pset(n: ?*GapP, p: ?*GapP) ?*GapP;
extern fn oabs(a: i64) i64;
extern fn wfit(t: ?*Screen) void;

fn ensurePos() void {
    if (pos_ready) return;
    pos = Pos{
        .link = .{ .next = &pos, .prev = &pos },
        .p = null,
        .w = null,
    };
    frpos = Pos{
        .link = .{ .next = &frpos, .prev = &frpos },
        .p = null,
        .w = null,
    };
    curpos = &pos;
    npos = 0;
    pos_ready = true;
}

fn dequeF(item: *Pos) *Pos {
    const n = item.link.next.?;
    const p = item.link.prev.?;
    p.link.next = item.link.next;
    n.link.prev = item.link.prev;
    return item;
}

fn enqueb(queue: *Pos, item: *Pos) void {
    item.link.next = queue;
    item.link.prev = queue.link.prev;
    queue.link.prev.?.link.next = item;
    queue.link.prev = item;
}

fn demote(queue: *Pos, item: *Pos) void {
    enqueb(queue, dequeF(item));
}

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

fn markpos(w: ?*WinRec, p: ?*GapP) void {
    ensurePos();
    const newpos: *Pos = @ptrCast(@alignCast(alitem(@ptrCast(&frpos), @sizeOf(Pos)) orelse return));
    newpos.p = null;
    _ = pdupown(p, @ptrCast(&newpos.p), "markpos");
    _ = poffline(newpos.p);
    newpos.w = w;
    enqueb(&pos, newpos);
    if (npos == 20) {
        const oldest = pos.link.next.?;
        prm(oldest.p);
        demote(&frpos, oldest);
    } else {
        npos += 1;
    }
}

export fn afterpos() void {
    ensurePos();
    if (curpos != &pos) {
        demote(&pos, curpos);
        curpos = &pos;
    }
}

export fn aftermove(w_in: ?*anyopaque, p: ?*GapP) void {
    ensurePos();
    const w = if (w_in != null) asWin(w_in) else null;
    if (pos.link.prev != &pos and pos.link.prev.?.w == w and pos.link.prev.?.p != null and
        oabs(pos.link.prev.?.p.?.line - p.?.line) < 3)
    {
        _ = poffline(pset(pos.link.prev.?.p, p));
    } else {
        markpos(w, p);
    }
}

export fn windie(w_in: ?*anyopaque) void {
    ensurePos();
    const w = if (w_in != null) asWin(w_in) else null;
    var n = pos.link.prev;
    while (n != null and n != &pos) : (n = n.?.link.prev) {
        if (n.?.w == w) {
            n.?.w = null;
        }
    }
}

fn jumpToCurpos(w_in: ?*WinRec) c_int {
    var w = w_in orelse return -1;
    const scr = w.t orelse return -1;

    if (scr.curwin != curpos.w) {
        scr.curwin = curpos.w;
        if (scr.curwin.?.y == -1) {
            wfit(scr);
        }
    }
    w = scr.curwin.?;
    const bw = @as(*BwRec, @ptrCast(@alignCast(w.object.?)));
    if (bw.cursor.?.byte != curpos.p.?.byte) {
        _ = pset(bw.cursor, curpos.p);
    }
    return 0;
}

fn posOk() bool {
    if (curpos.p == null or curpos.w == null) return false;
    const wa = curpos.w.?.watom orelse return false;
    if ((wa.what & (TYPETW | TYPEPW)) == 0) return false;
    const bw: *BwRec = @ptrCast(@alignCast(curpos.w.?.object orelse return false));
    if (bw.b != curpos.p.?.b) return false;
    return true;
}

fn sameSpot(w: *WinRec) bool {
    const scr = w.t orelse return false;
    if (scr.curwin != curpos.w) return false;
    const bw: *BwRec = @ptrCast(@alignCast(scr.curwin.?.object orelse return false));
    return bw.cursor.?.byte == curpos.p.?.byte;
}

export fn unextpos(w_in: ?*anyopaque, k: c_int) c_int {
    _ = k;
    ensurePos();
    if (windBw(w_in) == null) return -1;
    const w0 = asWin(w_in);

    while (true) {
        if (!(curpos.link.next != &pos and curpos != &pos)) return -1;
        curpos = curpos.link.next.?;
        if (!posOk()) continue;
        if (sameSpot(w0)) continue;
        return jumpToCurpos(w0);
    }
}

export fn uprevpos(w_in: ?*anyopaque, k: c_int) c_int {
    _ = k;
    ensurePos();
    if (windBw(w_in) == null) return -1;
    const w0 = asWin(w_in);

    while (true) {
        if (curpos.link.prev == &pos) return -1;
        curpos = curpos.link.prev.?;
        if (!posOk()) continue;
        if (sameSpot(w0)) continue;
        return jumpToCurpos(w0);
    }
}
