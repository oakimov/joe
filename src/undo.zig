//! Undo / redo / yank system — replaces `joe/undo.c`.
//!
//! Faithful C ABI port: same record merging, yank ring, unit grouping,
//! and redo-invalidation semantics as the original.

const std = @import("std");
const types = @import("gapbuffer/types.zig");

const B = types.B;
const P = types.P;

// ═══════════════════════════════════════════════════════════════════════
// Constants
// ═══════════════════════════════════════════════════════════════════════

const SMALL: i64 = 1024;
const MAX_YANK: c_int = 100;
const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;

// ═══════════════════════════════════════════════════════════════════════
// External C / Zig symbols
// ═══════════════════════════════════════════════════════════════════════

extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn joe_realloc(ptr: ?*anyopaque, size: isize) ?*anyopaque;
extern fn joe_free(ptr: ?*anyopaque) void;
extern fn alitem(list: ?*anyopaque, itemsize: isize) ?*anyopaque;
extern fn frchn(list: ?*anyopaque, ch: ?*anyopaque) void;
extern fn mmove(d: ?*anyopaque, s: ?*const anyopaque, sz: isize) ?*anyopaque;
extern fn mcpy(a: ?*anyopaque, b: ?*const anyopaque, len: isize) ?*anyopaque;

extern fn bmk(prop: ?*B) *B;
extern fn brm(b: ?*B) void;
extern fn bonline(b: ?*B) ?*B;
extern fn boffline(b: ?*B) ?*B;
extern fn bcpy(from: ?*P, to: ?*P) ?*B;
extern fn bdel(from: ?*P, to: ?*P) void;
extern fn binsb(p: ?*P, b: ?*B) ?*P;
extern fn binsm(p: ?*P, blk: ?*const anyopaque, amnt: isize) ?*P;
extern fn brmem(p: ?*P, blk: ?*anyopaque, size: isize) ?*anyopaque;
extern fn pdup(p: ?*P, tr: [*c]const u8) ?*P;
extern fn prm(p: ?*P) void;
extern fn pgoto(p: ?*P, loc: i64) ?*P;
extern fn pfwrd(p: ?*P, n: i64) ?*P;
extern fn pbkwd(p: ?*P, n: i64) ?*P;

extern fn unlock_it(path: [*c]const u8) void;
extern fn plain_file(b: ?*B) c_int;
extern fn exemac_pasting(state: c_int) void;
extern fn ubrpaste_done(w: ?*W, k: c_int) c_int;
extern fn markv(r: c_int) c_int;
extern fn unmark(w: ?*W, k: c_int) c_int;
extern fn msgnw(w: ?*W, s: [*c]const u8) void;
extern fn my_gettext(s: [*c]const u8) [*c]const u8;
extern fn parse_ws(pp: [*c][*c]const u8, cmt: c_int) c_int;
extern fn parse_string(pp: [*c][*c]const u8, buf: [*c]u8, len: isize) isize;
extern fn emit_string(f: ?*anyopaque, s: [*c]const u8, len: isize) void;
extern fn fprintf(f: ?*anyopaque, fmt: [*c]const u8, ...) c_int;
extern fn fgets(buf: [*c]u8, len: c_int, f: ?*anyopaque) ?*anyopaque;
extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;

extern var dostaupd: c_int;
extern var square: c_int;
extern var lightoff: c_int;
extern var markb: ?*P;
extern var markk: ?*P;

// ═══════════════════════════════════════════════════════════════════════
// Struct layouts (must match joe/undo.h + callers)
// ═══════════════════════════════════════════════════════════════════════

const Link = extern struct {
    next: ?*anyopaque,
    prev: ?*anyopaque,
};

const UNDOREC = extern struct {
    link: Link, // 0
    unit: ?*UNDOREC, // 16
    min: c_int, // 24
    changed: c_int, // 28
    where: i64, // 32
    len: i64, // 40
    del: c_int, // 48
    _pad0: c_int, // 52
    big: ?*B, // 56
    small: ?[*]u8, // 64
};

comptime {
    if (@sizeOf(UNDOREC) != 72) @compileError("UNDOREC size mismatch");
}

const UNDO = extern struct {
    link: Link, // 0
    b: ?*B, // 16
    nrecs: isize, // 24
    recs: UNDOREC, // 32 (72 bytes) → ends at 104
    ptr: ?*UNDOREC, // 104
    first: ?*UNDOREC, // 112
    last: ?*UNDOREC, // 120
};

comptime {
    if (@sizeOf(UNDO) != 128) @compileError("UNDO size mismatch");
}

const WATOM = extern struct {
    _pad: [80]u8,
    what: c_int,
};

const W = extern struct {
    _pad0: [144]u8,
    watom: ?*const WATOM,
    object: ?*anyopaque,
};

const BW = extern struct {
    parent: ?*W, // 0
    b: ?*B, // 8
    top: ?*P, // 16
    cursor: ?*P, // 24
    _pad: [468 - 32]u8,
    pasting: c_int, // 468
};

comptime {
    if (@offsetOf(BW, "pasting") != 468) @compileError("BW.pasting offset mismatch");
}

// ═══════════════════════════════════════════════════════════════════════
// Globals
// ═══════════════════════════════════════════════════════════════════════

export var undo_keep: c_int = 1000;
export var inundo: c_int = 0;
export var justkilled: c_int = 0;

var inredo: c_int = 0;
var inyank: c_int = 0;
var nyanked: c_int = 0;
var yankbuf: ?*B = null;
var yankwhere: i64 = -1;

var undos_sentinel: UNDO = undefined;
var frdos_sentinel: UNDO = undefined;
var yanked_sentinel: UNDOREC = undefined;
var frrecs_sentinel: UNDOREC = undefined;
var sentinels_ready: bool = false;

fn ensureSentinels() void {
    if (sentinels_ready) return;
    undos_sentinel = std.mem.zeroes(UNDO);
    frdos_sentinel = std.mem.zeroes(UNDO);
    yanked_sentinel = std.mem.zeroes(UNDOREC);
    frrecs_sentinel = std.mem.zeroes(UNDOREC);
    izqueUndo(&undos_sentinel);
    izqueUndo(&frdos_sentinel);
    izqueRec(&yanked_sentinel);
    izqueRec(&frrecs_sentinel);
    sentinels_ready = true;
}

// ═══════════════════════════════════════════════════════════════════════
// Queue helpers (LINK macros for UNDO / UNDOREC)
// ═══════════════════════════════════════════════════════════════════════

fn ptrEq(a: anytype, b: anytype) bool {
    return @intFromPtr(a) == @intFromPtr(b);
}

fn asUndo(p: ?*anyopaque) *UNDO {
    return @alignCast(@ptrCast(p.?));
}

fn asRec(p: ?*anyopaque) *UNDOREC {
    return @alignCast(@ptrCast(p.?));
}

fn izqueUndo(item: *UNDO) void {
    item.link.next = @ptrCast(item);
    item.link.prev = @ptrCast(item);
}

fn izqueRec(item: *UNDOREC) void {
    item.link.next = @ptrCast(item);
    item.link.prev = @ptrCast(item);
}

fn enquefUndo(queue: *UNDO, item: *UNDO) void {
    const n = asUndo(queue.link.next);
    item.link.next = queue.link.next;
    item.link.prev = @ptrCast(queue);
    n.link.prev = @ptrCast(item);
    queue.link.next = @ptrCast(item);
}

fn enquebUndo(queue: *UNDO, item: *UNDO) void {
    const p = asUndo(queue.link.prev);
    item.link.next = @ptrCast(queue);
    item.link.prev = queue.link.prev;
    p.link.next = @ptrCast(item);
    queue.link.prev = @ptrCast(item);
}

fn dequeUndo(item: *UNDO) void {
    const n = asUndo(item.link.next);
    const p = asUndo(item.link.prev);
    p.link.next = item.link.next;
    n.link.prev = item.link.prev;
}

fn demoteUndo(queue: *UNDO, item: *UNDO) void {
    dequeUndo(item);
    enquebUndo(queue, item);
}

fn enquefRec(queue: *UNDOREC, item: *UNDOREC) void {
    const n = asRec(queue.link.next);
    item.link.next = queue.link.next;
    item.link.prev = @ptrCast(queue);
    n.link.prev = @ptrCast(item);
    queue.link.next = @ptrCast(item);
}

fn enquebRec(queue: *UNDOREC, item: *UNDOREC) void {
    const p = asRec(queue.link.prev);
    item.link.next = @ptrCast(queue);
    item.link.prev = queue.link.prev;
    p.link.next = @ptrCast(item);
    queue.link.prev = @ptrCast(item);
}

fn dequeRec(item: *UNDOREC) void {
    const n = asRec(item.link.next);
    const p = asRec(item.link.prev);
    p.link.next = item.link.next;
    n.link.prev = item.link.prev;
}

fn dequeRecF(item: *UNDOREC) *UNDOREC {
    dequeRec(item);
    return item;
}

// ═══════════════════════════════════════════════════════════════════════
// Record freelist
// ═══════════════════════════════════════════════════════════════════════

fn alrec() *UNDOREC {
    ensureSentinels();
    return @alignCast(@ptrCast(alitem(@ptrCast(&frrecs_sentinel), @sizeOf(UNDOREC)).?));
}

fn frrec(rec: *UNDOREC) void {
    ensureSentinels();
    if (rec.del != 0) {
        if (rec.len < SMALL) {
            joe_free(@ptrCast(rec.small));
        } else {
            const b = rec.big;
            _ = bonline(b);
            brm(b);
        }
    }
    enquefRec(&frrecs_sentinel, rec);
}

// ═══════════════════════════════════════════════════════════════════════
// Create / destroy undo structures
// ═══════════════════════════════════════════════════════════════════════

export fn undomk(b: ?*B) ?*UNDO {
    ensureSentinels();
    const undo = @as(*UNDO, @alignCast(@ptrCast(alitem(@ptrCast(&frdos_sentinel), @sizeOf(UNDO)).?)));
    undo.nrecs = 0;
    undo.ptr = null;
    undo.last = null;
    undo.first = null;
    undo.b = b;
    izqueRec(&undo.recs);
    enquefUndo(&undos_sentinel, undo);
    return undo;
}

export fn undorm(undo: ?*UNDO) void {
    ensureSentinels();
    const u = undo.?;
    frchn(@ptrCast(&frrecs_sentinel), @ptrCast(&u.recs));
    demoteUndo(&frdos_sentinel, u);
}

// ═══════════════════════════════════════════════════════════════════════
// Window helpers
// ═══════════════════════════════════════════════════════════════════════

fn windBw(w: ?*W) ?*BW {
    const ww = w orelse return null;
    const atom = ww.watom orelse return null;
    if ((atom.what & (TYPETW | TYPEPW)) == 0) return null;
    return @alignCast(@ptrCast(ww.object));
}

export fn bw_unlock(bw: ?*BW) void {
    const bww = bw.?;
    const b = bww.b.?;
    if (b.locked != 0 and b.ignored_lock == 0 and plain_file(b) != 0) {
        unlock_it(@ptrCast(b.name));
        b.locked = 0;
    }
}

fn doundo(bw: *BW, ptr: *UNDOREC) void {
    dostaupd = 1;
    if (ptr.del != 0) {
        if (ptr.len < SMALL) {
            _ = binsm(bw.cursor, @ptrCast(ptr.small), @intCast(ptr.len));
        } else {
            const b = ptr.big;
            _ = bonline(b);
            _ = binsb(bw.cursor, bcpy(b.?.bof, b.?.eof));
            _ = boffline(b);
        }
    } else {
        const q = pdup(bw.cursor, "doundo");
        _ = pfwrd(q, ptr.len);
        bdel(bw.cursor, q);
        prm(q);
    }
    if (bw.b.?.changed != 0 and ptr.changed == 0) {
        bw_unlock(bw);
    }
    bw.b.?.changed = ptr.changed;
}

// ═══════════════════════════════════════════════════════════════════════
// Undo / redo commands
// ═══════════════════════════════════════════════════════════════════════

export fn uundo(w: ?*W, k: c_int) c_int {
    const bw = windBw(w) orelse return -1;
    if (bw.pasting != 0) {
        exemac_pasting(0);
        _ = ubrpaste_done(w, k);
        return 0;
    }
    const undo = @as(?*UNDO, @ptrCast(@alignCast(bw.b.?.undo))) orelse return -1;
    if (undo.nrecs == 0) return -1;
    if (undo.ptr == null) {
        _ = pgoto(bw.cursor, asRec(undo.recs.link.prev).where);
        undo.ptr = &undo.recs;
    }
    if (ptrEq(asRec(undo.ptr.?.link.prev), &undo.recs)) return -1;
    const upto = asRec(undo.ptr.?.link.prev).unit;
    while (true) {
        undo.ptr = asRec(undo.ptr.?.link.prev);
        _ = pgoto(bw.cursor, undo.ptr.?.where);
        inundo = 1;
        doundo(bw, undo.ptr.?);
        inundo = 0;
        if (upto == null or ptrEq(upto, undo.ptr)) break;
    }
    return 0;
}

export fn uredo(w: ?*W, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const undo = @as(?*UNDO, @ptrCast(@alignCast(bw.b.?.undo))) orelse return -1;
    if (undo.ptr == null) return -1;
    if (ptrEq(undo.ptr, &undo.recs)) return -1;
    const upto = asRec(undo.recs.link.prev).unit;
    while (true) {
        const ptr = asRec(undo.recs.link.prev);
        _ = pgoto(bw.cursor, ptr.where);
        inredo = 1;
        doundo(bw, ptr);
        inredo = 0;
        frrec(dequeRecF(ptr));
        undo.ptr = asRec(undo.ptr.?.link.next);
        if (upto == null or ptrEq(upto, ptr)) break;
    }
    undo.nrecs -= 1;
    return 0;
}

export fn umclear() void {
    ensureSentinels();
    var undo = asUndo(undos_sentinel.link.next);
    while (!ptrEq(undo, &undos_sentinel)) : (undo = asUndo(undo.link.next)) {
        var rec = asRec(undo.recs.link.next);
        while (!ptrEq(rec, &undo.recs)) : (rec = asRec(rec.link.next)) {
            rec.min = 0;
        }
    }
}

fn undogc(undo: *UNDO) void {
    const unit = asRec(undo.recs.link.next).unit;
    var flg: c_int = 0;
    if (unit != null) {
        while (!ptrEq(unit, asRec(undo.recs.link.next))) {
            if (ptrEq(asRec(undo.recs.link.next), undo.ptr)) flg = 1;
            frrec(dequeRecF(asRec(undo.recs.link.next)));
        }
    }
    if (ptrEq(asRec(undo.recs.link.next), undo.ptr)) flg = 1;
    frrec(dequeRecF(asRec(undo.recs.link.next)));
    undo.nrecs -= 1;
    if (flg != 0) undo.ptr = asRec(undo.recs.link.next);
}

export fn undomark() void {
    ensureSentinels();
    if ((undo_keep & 1) != 0) undo_keep += 1;
    var undo = asUndo(undos_sentinel.link.next);
    while (!ptrEq(undo, &undos_sentinel)) : (undo = asUndo(undo.link.next)) {
        if (undo.first != null) {
            undo.first.?.unit = undo.last;
            undo.last.?.unit = undo.first;
            undo.first = null;
            undo.last = null;
            undo.nrecs += 1;
            if (undo_keep != 0) {
                while (undo.nrecs > undo_keep) undogc(undo);
            }
        }
    }
}

fn undoover(undo: *UNDO) void {
    undo.ptr = null;
}

export fn undoins(undo: ?*UNDO, p: ?*P, size: i64) void {
    if (inredo != 0) return;
    const u = undo.?;
    if (inundo == 0) {
        if (u.ptr != null and !ptrEq(u.ptr, &u.recs)) undoover(u);
    }
    var rec = asRec(u.recs.link.prev);
    if (!ptrEq(rec, &u.recs) and rec.min != 0 and rec.del == 0 and
        (p.?.byte == rec.where + rec.len or p.?.byte == rec.where))
    {
        rec.len += size;
    } else {
        rec = alrec();
        rec.del = 0;
        if (u.first == null) u.first = rec;
        u.last = rec;
        rec.where = p.?.byte;
        rec.min = 1;
        rec.unit = null;
        rec.len = size;
        rec.changed = u.b.?.changed;
        rec.big = null;
        rec.small = null;
        enquebRec(&u.recs, rec);
    }
}

export fn uyapp(w: ?*W, k: c_int) c_int {
    _ = k;
    ensureSentinels();
    const bw = windBw(w) orelse return -1;
    const rec = asRec(yanked_sentinel.link.prev);
    if (!ptrEq(rec, &yanked_sentinel)) {
        rec.where = bw.cursor.?.byte;
    }
    return 0;
}

fn yankdel(where: i64, b: *B) void {
    ensureSentinels();
    const size = b.eof.?.byte;
    var rec = asRec(yanked_sentinel.link.prev);
    if (inyank != 0) return;

    if (!ptrEq(rec, &yanked_sentinel) and where == rec.where and justkilled != 0) {
        if (rec.len + size >= SMALL) {
            if (rec.len < SMALL) {
                rec.big = bmk(null);
                _ = binsm(rec.big.?.bof, @ptrCast(rec.small), @intCast(rec.len));
                _ = boffline(rec.big);
                joe_free(@ptrCast(rec.small));
                rec.small = null;
            }
            _ = bonline(rec.big);
            _ = binsb(rec.big.?.eof, bcpy(b.bof, b.eof));
            _ = boffline(rec.big);
        } else {
            rec.small = @ptrCast(joe_realloc(@ptrCast(rec.small), @intCast(rec.len + size)));
            _ = brmem(b.bof, @ptrCast(rec.small.? + @as(usize, @intCast(rec.len))), @intCast(size));
        }
        rec.len += size;
    } else if (!ptrEq(rec, &yanked_sentinel) and where + size == rec.where and justkilled != 0) {
        if (rec.len + size >= SMALL) {
            if (rec.len < SMALL) {
                rec.big = bmk(null);
                _ = binsm(rec.big.?.bof, @ptrCast(rec.small), @intCast(rec.len));
                _ = boffline(rec.big);
                joe_free(@ptrCast(rec.small));
                rec.small = null;
            }
            _ = bonline(rec.big);
            _ = binsb(rec.big.?.bof, bcpy(b.bof, b.eof));
            _ = boffline(rec.big);
        } else {
            rec.small = @ptrCast(joe_realloc(@ptrCast(rec.small), @intCast(rec.len + size)));
            _ = mmove(@ptrCast(rec.small.? + @as(usize, @intCast(size))), @ptrCast(rec.small), @intCast(rec.len));
            _ = brmem(b.bof, @ptrCast(rec.small), @intCast(size));
        }
        rec.len += size;
        rec.where = where;
    } else {
        nyanked += 1;
        if (nyanked == MAX_YANK) {
            frrec(dequeRecF(asRec(yanked_sentinel.link.next)));
            nyanked -= 1;
        }
        rec = alrec();
        if (size < SMALL and size > 0) {
            rec.small = @ptrCast(joe_malloc(@intCast(size)));
            _ = brmem(b.bof, @ptrCast(rec.small), @intCast(b.eof.?.byte));
            rec.big = null;
        } else {
            rec.big = bcpy(b.bof, b.eof);
            _ = boffline(rec.big);
            rec.small = null;
        }
        rec.where = where;
        rec.len = size;
        rec.del = 1;
        rec.min = 0;
        rec.unit = null;
        rec.changed = 0;
        enquebRec(&yanked_sentinel, rec);
    }
}

export fn undodel(undo: ?*UNDO, where: i64, b: ?*B) void {
    const bb = b.?;
    const size = bb.eof.?.byte;
    if (inredo != 0) {
        brm(bb);
        return;
    }
    const u = undo.?;
    if (inundo == 0) {
        if (u.ptr != null and !ptrEq(u.ptr, &u.recs)) undoover(u);
    }

    yankdel(where, bb);

    var rec = asRec(u.recs.link.prev);
    if (!ptrEq(rec, &u.recs) and rec.min != 0 and rec.del != 0 and where == rec.where) {
        if (rec.len + size >= SMALL) {
            if (rec.len < SMALL) {
                rec.big = bmk(null);
                _ = binsm(rec.big.?.bof, @ptrCast(rec.small), @intCast(rec.len));
                _ = boffline(rec.big);
                joe_free(@ptrCast(rec.small));
                rec.small = null;
            }
            _ = bonline(rec.big);
            _ = binsb(rec.big.?.eof, bb);
            _ = boffline(rec.big);
        } else {
            rec.small = @ptrCast(joe_realloc(@ptrCast(rec.small), @intCast(rec.len + size)));
            _ = brmem(bb.bof, @ptrCast(rec.small.? + @as(usize, @intCast(rec.len))), @intCast(size));
            brm(bb);
        }
        rec.len += size;
    } else if (!ptrEq(rec, &u.recs) and rec.min != 0 and rec.del != 0 and where + size == rec.where) {
        if (rec.len + size >= SMALL) {
            if (rec.len < SMALL) {
                rec.big = bmk(null);
                _ = binsm(rec.big.?.bof, @ptrCast(rec.small), @intCast(rec.len));
                _ = boffline(rec.big);
                joe_free(@ptrCast(rec.small));
                rec.small = null;
            }
            _ = bonline(rec.big);
            _ = binsb(rec.big.?.bof, bb);
            _ = boffline(rec.big);
        } else {
            rec.small = @ptrCast(joe_realloc(@ptrCast(rec.small), @intCast(rec.len + size)));
            _ = mmove(@ptrCast(rec.small.? + @as(usize, @intCast(size))), @ptrCast(rec.small), @intCast(rec.len));
            _ = brmem(bb.bof, @ptrCast(rec.small), @intCast(size));
            brm(bb);
        }
        rec.len += size;
        rec.where = where;
    } else {
        rec = alrec();
        if (size < SMALL) {
            rec.small = @ptrCast(joe_malloc(@intCast(size)));
            _ = brmem(bb.bof, @ptrCast(rec.small), @intCast(bb.eof.?.byte));
            brm(bb);
            rec.big = null;
        } else {
            rec.big = bb;
            _ = boffline(bb);
            rec.small = null;
        }
        if (u.first == null) u.first = rec;
        u.last = rec;
        rec.where = where;
        rec.min = 1;
        rec.unit = null;
        rec.len = size;
        rec.del = 1;
        rec.changed = u.b.?.changed;
        enquebRec(&u.recs, rec);
    }
}

export fn uyank(w: ?*W, k: c_int) c_int {
    _ = k;
    ensureSentinels();
    const bw = windBw(w) orelse return -1;
    const ptr = asRec(yanked_sentinel.link.prev);
    if (!ptrEq(ptr, &yanked_sentinel)) {
        if (ptr.len < SMALL) {
            _ = binsm(bw.cursor, @ptrCast(ptr.small), @intCast(ptr.len));
        } else {
            const b = ptr.big;
            _ = bonline(b);
            _ = binsb(bw.cursor, bcpy(b.?.bof, b.?.eof));
            _ = boffline(b);
        }
        _ = pfwrd(bw.cursor, ptr.len);
        yankbuf = bw.b;
        yankwhere = bw.cursor.?.byte;
        return 0;
    }
    return -1;
}

export fn uyankpop(w: ?*W, k: c_int) c_int {
    _ = k;
    ensureSentinels();
    const bw = windBw(w) orelse return -1;
    if (ptrEq(bw.b, yankbuf) and bw.cursor.?.byte == yankwhere) {
        const ptr = asRec(yanked_sentinel.link.prev);
        dequeRec(&yanked_sentinel);
        enquebRec(ptr, &yanked_sentinel);
        const q = pdup(bw.cursor, "uyankpop");
        _ = pbkwd(q, ptr.len);
        inyank = 1;
        bdel(q, bw.cursor);
        inyank = 0;
        prm(q);
        return uyank(bw.parent, 0);
    }
    return uyank(bw.parent, 0);
}

export fn unotmod(w: ?*W, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    bw_unlock(bw);
    bw.b.?.changed = 0;
    msgnw(bw.parent, my_gettext("Modified flag cleared"));
    return 0;
}

export fn ucopy(w: ?*W, k: c_int) c_int {
    _ = k;
    if (markv(1) != 0 and square == 0) {
        const b = bcpy(markb, markk);
        yankdel(markb.?.byte, b.?);
        brm(b);
        if (lightoff != 0) _ = unmark(w, 0);
        return 0;
    } else {
        msgnw(w, my_gettext("No block"));
        return -1;
    }
}

export fn save_yank(f: ?*anyopaque) void {
    ensureSentinels();
    var rec = asRec(yanked_sentinel.link.next);
    while (!ptrEq(rec, &yanked_sentinel)) : (rec = asRec(rec.link.next)) {
        if (rec.len < SMALL) {
            _ = fprintf(f, "\t");
            emit_string(f, @ptrCast(rec.small), @intCast(rec.len));
            _ = fprintf(f, "\n");
        }
    }
    _ = fprintf(f, "done\n");
}

export fn load_yank(f: ?*anyopaque) void {
    ensureSentinels();
    var buf: [SMALL * 4 + 80]u8 = undefined;
    var bf: [SMALL + 1]u8 = undefined;
    while (fgets(@ptrCast(&buf), @intCast(buf.len - 1), f) != null and
        strcmp(@ptrCast(&buf), "done\n") != 0)
    {
        var p: [*c]const u8 = @ptrCast(&buf);
        _ = parse_ws(@ptrCast(&p), '#');
        const len = parse_string(@ptrCast(&p), @ptrCast(&bf), @intCast(bf.len));
        if (len > 0 and len <= SMALL) {
            nyanked += 1;
            if (nyanked == MAX_YANK) {
                frrec(dequeRecF(asRec(yanked_sentinel.link.next)));
                nyanked -= 1;
            }
            const rec = alrec();
            rec.small = @ptrCast(joe_malloc(len));
            _ = mcpy(@ptrCast(rec.small), @ptrCast(&bf), len);
            rec.where = -1;
            rec.len = len;
            rec.del = 1;
            rec.big = null;
            rec.min = 0;
            rec.unit = null;
            rec.changed = 0;
            enquebRec(&yanked_sentinel, rec);
        }
    }
}
