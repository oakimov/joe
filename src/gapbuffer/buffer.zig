//! Buffer (B) operations — creation, destruction, copy, delete, insert.
//! Replaces the buffer-management portions of `b.c`.

const types = @import("types.zig");
extern fn vsrm(s: ?*anyopaque) void;
const intern = @import("intern.zig");
const pointer = @import("pointer.zig");

const P = types.P;
const H = types.H;
const B = types.B;
const Link = types.Link;
const OPTIONS = types.OPTIONS;
const SEGSIZ = types.SEGSIZ;

extern var pdefault: OPTIONS;

const ptrEq = intern.ptrEq;
const charmapIsUtf8 = intern.charmapIsUtf8;
const Hlink = intern.Hlink;
const Plink = intern.Plink;
const Blink = intern.Blink;
const link2H = intern.link2H;
const link2P = intern.link2P;
const link2B = intern.link2B;
const izque = intern.izque;
const deque_ = intern.deque_;
const enquef_ = intern.enquef_;
const enqueb_ = intern.enqueb_;
const qempty_ = intern.qempty_;
const splicef_ = intern.splicef_;
const spliceb_f_ = intern.spliceb_f_;
const snip_ = intern.snip_;
const demote_ = intern.demote_;

const ggapsz = intern.ggapsz;
const gsize_ = intern.gsize_;
const gstgap = intern.gstgap;
const ginsm = intern.ginsm;
const grmem = intern.grmem;
const count_nl = intern.count_nl;
const halloc = intern.halloc;
const hallocFresh = intern.hallocFresh;
const hfree = intern.hfree;
const hfreechn = intern.hfreechn;
const palloc = intern.palloc;
const pfree = intern.pfree;

const vlock = intern.vlock;
const vunlock_page = intern.vunlock_page;
const vchanged_page = intern.vchanged_page;
const vupcount_page = intern.vupcount_page;
const joe_malloc = intern.joe_malloc;
const joe_free = intern.joe_free;
const mmove = intern.mmove;

const undomk = intern.undomk;
const undorm = intern.undorm;
const undodel = intern.undodel;
const undoins = intern.undoins;
const scrdel = intern.scrdel;
const scrins = intern.scrins;
const abrerr = intern.abrerr;
const inserr = intern.inserr;
const delerr = intern.delerr;
const lattr_ins = intern.lattr_ins;
const lattr_del = intern.lattr_del;
const rm_all_lattr_db = intern.rm_all_lattr_db;
const set_file_pos = intern.set_file_pos;
const time = intern.time;
const strcmp = intern.strcmp;
const utf8_encode = intern.utf8_encode;

const pdup_ = pointer.pdup_;
const pset_ = pointer.pset_;
const prm = pointer.prm;
const pnext_ = pointer.pnext_;
const pprev_ = pointer.pprev_;
const pgetb_ = pointer.pgetb_;
const pgetc_ = pointer.pgetc_;
const prgetc_ = pointer.prgetc_;
const pfwrd_ = pointer.pfwrd_;
const pisbof = pointer.pisbof;
const piseof = pointer.piseof;
const pisbol = pointer.pisbol;
const poffline_ = pointer.poffline_;
const ponline_ = pointer.ponline_;
const brc_ = pointer.brc_;

const ansi_mod = @import("ansi.zig");

// ═══════════════════════════════════════════════════════════════════════
// bmkchn — make a buffer out of a header chain
// ═══════════════════════════════════════════════════════════════════════

pub fn bmkchn(chn: *H, prop: ?*B, amnt: i64, nlines: i64) *B {
    _ = intern.ensureBufs();
    intern.ensureFrebufs();
    const b = @as(*B, @alignCast(@ptrCast(intern.alitem(Blink(&intern.frebufs_sentinel), @sizeOf(B)) orelse unreachable)));
    b.* = .{
        .link = .{ .next = undefined, .prev = undefined },
        .bof = null, .eof = null, .name = null,
        .locked = 0, .ignored_lock = 0, .didfirst = 0, ._pad0 = 0,
        .mod_time = time(null), .check_time = 0,
        .gave_notice = 0, .orphan = 0, .count = 1, .changed = 0, .backup = 1,
        ._pad1 = 0, .undo = null,
        .marks = [_]?*P{null} ** 11,
        .o = undefined,
        .oldcur = null, .oldtop = null, .err = null, .current_dir = null,
        .shell_flag = 0, .rdonly = 0, .internal = 1, .scratch = 0,
        .er = -3, .pid = 0, .out = -1, .vt = null, .raw = 0,
        ._pad2 = 0, .db = null, .parseone = null,
    };
    // Match C bmkchn: copy prop options, otherwise start from pdefault.
    if (prop) |p| b.o = p.o else b.o = pdefault;
    b.check_time = b.mod_time;
    b.undo = undomk(@ptrCast(b));

    b.bof = palloc();
    izque(Plink(b.bof.?));
    b.bof.?.end = 0;
    b.bof.?.b = b;
    b.bof.?.owner = null;
    b.bof.?.hdr = chn;
    b.bof.?.ptr = vlock(intern.vmem, b.bof.?.hdr.?.seg);
    b.bof.?.ofst = 0;
    b.bof.?.byte = 0;
    b.bof.?.line = 0;
    b.bof.?.col = 0;
    b.bof.?.xcol = 0;
    b.bof.?.valcol = 1;
    b.bof.?.attr = 0;
    b.bof.?.valattr = 1;
    b.bof.?.tracker = @ptrCast(@as(*const [7]u8, "bmkchn\x00"));

    b.eof = pdup_(b.bof.?, "bmkchn");
    b.eof.?.end = 1;
    vunlock_page(b.eof.?.ptr);
    {
        const prev = @as(*Link, @alignCast(@ptrCast(chn.link.prev)));
        b.eof.?.hdr = link2H(prev);
    }
    b.eof.?.ptr = vlock(intern.vmem, b.eof.?.hdr.?.seg);
    b.eof.?.ofst = gsize_(b.eof.?.hdr.?);
    b.eof.?.byte = amnt;
    b.eof.?.line = nlines;
    b.eof.?.valcol = 0;
    b.eof.?.valattr = 0;

    enqueb_(Blink(&intern.bufs), Blink(b));
    pcoalesce_(b.bof.?);
    pcoalesce_(b.eof.?);
    return b;
}

pub export fn bmk(prop: ?*B) *B {
    return bmkchn(halloc(), prop, 0, 0);
}

// ═══════════════════════════════════════════════════════════════════════
// brm / brmall
// ═══════════════════════════════════════════════════════════════════════

pub export fn brm(b: ?*B) void {
    const bp = b orelse return;
    if (bp.count == 0) return;
    bp.count -= 1;
    if (bp.count > 0) return;
    if (bp.changed != 0) abrerr(bp.name);
    if (bp.undo) |u| undorm(u);
    if (bp.eof) |eof| {
        hfreechn(eof.hdr.?);
        while (!qempty_(Plink(bp.bof.?))) {
            prm(link2P(@alignCast(@ptrCast(bp.bof.?.link.next))));
        }
        prm(bp.bof.?);
    }
    if (bp.name) |nm| joe_free(nm);
    if (bp.db) |db| rm_all_lattr_db(db);
    if (bp.current_dir) |cd| vsrm(cd);
    demote_(Blink(&intern.frebufs_sentinel), Blink(bp));
}

pub export fn brmall() void {
    _ = intern.ensureBufs();
    while (!qempty_(Blink(&intern.bufs))) {
        brm(link2B(@alignCast(@ptrCast(intern.bufs.link.next))));
    }
}

// ═══════════════════════════════════════════════════════════════════════
// bonline / boffline
// ═══════════════════════════════════════════════════════════════════════

pub export fn boffline(b: ?*B) ?*B {
    const bp = b.?;
    var p = link2P(@alignCast(@ptrCast(bp.bof.?.link.next)));
    while (!ptrEq(p, bp.bof.?)) : (p = link2P(@alignCast(@ptrCast(p.link.next)))) {
        _ = poffline_(p);
    }
    return bp;
}

pub export fn bonline(b: ?*B) ?*B {
    const bp = b.?;
    var p = link2P(@alignCast(@ptrCast(bp.bof.?.link.next)));
    while (!ptrEq(p, bp.bof.?)) : (p = link2P(@alignCast(@ptrCast(p.link.next)))) {
        _ = ponline_(p);
    }
    return bp;
}

// ═══════════════════════════════════════════════════════════════════════
// breplace — replace contents of b with n (n destroyed)
// ═══════════════════════════════════════════════════════════════════════

pub export fn breplace(b: ?*B, n: ?*B) void {
    const bp = b.?;
    const np = n.?;
    abrerr(bp.name);

    if (bp.undo) |u| {
        undorm(u);
        bp.undo = null;
    }

    // Remove all vfile references on b's pointers.
    var p = link2P(@alignCast(@ptrCast(bp.eof.?.link.next)));
    while (!ptrEq(p, bp.eof.?)) : (p = link2P(@alignCast(@ptrCast(p.link.next)))) {
        if (p.ptr) |pt| vunlock_page(pt);
    }
    if (bp.eof.?.ptr) |pt| vunlock_page(pt);

    hfreechn(bp.eof.?.hdr.?);

    if (bp.name) |nm| joe_free(nm);
    reset_all_lattr_db(bp.db.?);

    // Take new name
    bp.name = @ptrCast(zdup(@ptrCast(np.name)));

    // bof pointer: take np->bof's vlock
    bp.bof.?.ofst = np.bof.?.ofst;
    bp.bof.?.ptr = np.bof.?.ptr;
    bp.bof.?.hdr = np.bof.?.hdr;
    bp.bof.?.byte = 0;
    bp.bof.?.line = 0;
    bp.bof.?.col = 0;
    bp.bof.?.xcol = 0;
    bp.bof.?.valcol = 1;
    bp.bof.?.attr = 0;
    bp.bof.?.valattr = 1;
    bp.bof.?.end = 0;

    // eof pointer: take bp->eof's vlock
    bp.eof.?.ofst = np.eof.?.ofst;
    bp.eof.?.ptr = np.eof.?.ptr;
    bp.eof.?.hdr = np.eof.?.hdr;
    bp.eof.?.byte = np.eof.?.byte;
    bp.eof.?.line = np.eof.?.line;
    bp.eof.?.col = np.eof.?.col;
    bp.eof.?.xcol = np.eof.?.xcol;
    bp.eof.?.valcol = np.eof.?.valcol;
    bp.eof.?.attr = np.eof.?.attr;
    bp.eof.?.valattr = np.eof.?.valattr;
    bp.eof.?.end = 1;

    // Reset other pointers in b
    p = link2P(@alignCast(@ptrCast(bp.eof.?.link.next)));
    while (!ptrEq(p, bp.eof.?)) : (p = link2P(@alignCast(@ptrCast(p.link.next)))) {
        if (!ptrEq(p, bp.bof.?)) {
            const goal_line = p.line;
            const goal_col = p.xcol;
            p.ptr = null;
            if (goal_line > bp.eof.?.line) {
                _ = pset_(p, bp.eof.?);
                _ = pointer.p_goto_bol(p);
            } else {
                _ = pset_(p, bp.bof.?);
                _ = pointer.pline(p, goal_line);
                _ = pointer.pcol(p, goal_col);
            }
        }
    }

    // Delete pointers from n (except bof/eof whose locks transferred)
    {
        var pp = link2P(@alignCast(@ptrCast(np.eof.?.link.next)));
        while (!ptrEq(pp, np.eof.?)) {
            const next = link2P(@alignCast(@ptrCast(pp.link.next)));
            if (!ptrEq(pp, np.bof.?)) prm(pp);
            pp = next;
        }
    }
    np.bof.?.ptr = null;
    prm(np.bof.?);
    np.bof = null;
    np.eof.?.ptr = null;
    prm(np.eof.?);
    np.eof = null;

    bp.undo = undomk(@ptrCast(bp));
    bp.changed = 0;
    bp.rdonly = np.rdonly;
    bp.mod_time = np.mod_time;

    brm(np);
}

extern fn zdup(s: ?*anyopaque) ?*anyopaque;
extern fn reset_all_lattr_db(db: ?*anyopaque) void;

// ═══════════════════════════════════════════════════════════════════════
// bcpy — copy [from,to) into a new buffer
// ═══════════════════════════════════════════════════════════════════════

pub export fn bcpy(from: ?*P, to: ?*P) ?*B {
    const f = from.?;
    const t = to.?;
    if (f.byte >= t.byte) return bmk(f.b);
    const q = pdup_(f, "bcpy");
    var anchor: H = undefined;
    izque(Hlink(&anchor));

    if (q.hdr == t.hdr) {
        const l = halloc();
        if (q.ofst != q.hdr.?.hole) gstgap(q.hdr.?, q.ptr, q.ofst);
        const sz = t.ofst - q.ofst;
        l.nlines = @as(i16, @intCast(count_nl(@ptrFromInt(@intFromPtr(q.ptr) + @as(usize, @intCast(q.hdr.?.ehole))), @as(isize, @intCast(sz)))));
        const ptr = vlock(intern.vmem, l.seg);
        _ = mmove(ptr, @ptrFromInt(@intFromPtr(q.ptr) + @as(usize, @intCast(q.hdr.?.ehole))), @as(isize, @intCast(sz)));
        l.hole = sz;
        vchanged_page(ptr);
        vunlock_page(ptr);
        enqueb_(Hlink(&anchor), Hlink(l));
    } else {
        var l = halloc();
        var lptr = vlock(intern.vmem, l.seg);
        if (q.ofst != q.hdr.?.hole) gstgap(q.hdr.?, q.ptr, q.ofst);
        const sz1: i16 = @intCast(SEGSIZ - q.hdr.?.ehole);
        l.nlines = @as(i16, @intCast(count_nl(@ptrFromInt(@intFromPtr(q.ptr) + @as(usize, @intCast(q.hdr.?.ehole))), sz1)));
        _ = mmove(lptr, @ptrFromInt(@intFromPtr(q.ptr) + @as(usize, @intCast(q.hdr.?.ehole))), sz1);
        l.hole = sz1;
        vchanged_page(lptr);
        vunlock_page(lptr);
        enqueb_(Hlink(&anchor), Hlink(l));
        _ = pnext_(q);
        while (!ptrEq(q.hdr, t.hdr)) {
            l = halloc();
            lptr = vlock(intern.vmem, l.seg);
            l.nlines = q.hdr.?.nlines;
            _ = mmove(lptr, q.ptr, @as(isize, @intCast(q.hdr.?.hole)));
            _ = mmove(@ptrFromInt(@intFromPtr(lptr) + @as(usize, @intCast(q.hdr.?.hole))),
                      @ptrFromInt(@intFromPtr(q.ptr) + @as(usize, @intCast(q.hdr.?.ehole))),
                      @as(isize, @intCast(SEGSIZ - q.hdr.?.ehole)));
            l.hole = gsize_(q.hdr.?);
            vchanged_page(lptr);
            vunlock_page(lptr);
            enqueb_(Hlink(&anchor), Hlink(l));
            _ = pnext_(q);
        }
        if (t.ofst != 0) {
            l = halloc();
            lptr = vlock(intern.vmem, l.seg);
            if (t.ofst != t.hdr.?.hole) gstgap(t.hdr.?, t.ptr, t.ofst);
            l.nlines = @as(i16, @intCast(count_nl(t.ptr, @as(isize, @intCast(t.ofst)))));
            _ = mmove(lptr, t.ptr, @as(isize, @intCast(t.ofst)));
            l.hole = t.ofst;
            vchanged_page(lptr);
            vunlock_page(lptr);
            enqueb_(Hlink(&anchor), Hlink(l));
        }
    }

    const result = link2H(@alignCast(@ptrCast(anchor.link.next)));
    deque_(Hlink(&anchor));
    prm(q);
    return bmkchn(result, f.b, t.byte - f.byte, t.line - f.line);
}

// ═══════════════════════════════════════════════════════════════════════
// bcut / bdel
// ═══════════════════════════════════════════════════════════════════════

pub fn bcut_(from: *P, to: *P) ?*B {
    const amnt = to.byte - from.byte;
    if (amnt == 0) return null;
    const nlines = to.line - from.line;

    var h: ?*H = null;
    var i: ?*H = null;
    var a: ?*H = null;
    var toamnt: i16 = 0;
    var bofmove = false;

    if (from.hdr == to.hdr) {
        if (from.ofst != from.hdr.?.hole) gstgap(from.hdr.?, from.ptr, from.ofst);
        h = halloc();
        const ptr = vlock(intern.vmem, h.?.seg);
        _ = mmove(ptr, @ptrFromInt(@intFromPtr(from.ptr) + @as(usize, @intCast(from.hdr.?.ehole))), @as(isize, @intCast(amnt)));
        h.?.hole = @as(i16, @intCast(amnt));
        h.?.nlines = @as(i16, @intCast(nlines));
        vchanged_page(ptr);
        vunlock_page(ptr);
        from.hdr.?.ehole += @as(i16, @intCast(amnt));
        from.hdr.?.nlines -= @as(i16, @intCast(nlines));
        toamnt = @as(i16, @intCast(amnt));
    } else {
        toamnt = to.ofst;
        if (toamnt != 0) {
            if (to.ofst != to.hdr.?.hole) gstgap(to.hdr.?, to.ptr, to.ofst);
            i = halloc();
            const ptr = vlock(intern.vmem, i.?.seg);
            _ = mmove(ptr, to.ptr, @as(isize, @intCast(to.hdr.?.hole)));
            i.?.hole = to.hdr.?.hole;
            i.?.nlines = @as(i16, @intCast(count_nl(ptr, @as(isize, @intCast(to.hdr.?.hole)))));
            vchanged_page(ptr);
            vunlock_page(ptr);
            to.hdr.?.nlines -= i.?.nlines;
            to.hdr.?.hole = 0;
        }

        if (from.ofst == 0) {
            a = intern.H_of(from.hdr.?.link.prev);
            h = null;
            if (ptrEq(a, from.b.?.eof.?.hdr.?)) bofmove = true;
        } else {
            a = from.hdr;
            if (from.ofst != from.hdr.?.hole) gstgap(from.hdr.?, from.ptr, from.ofst);
            h = halloc();
            const ptr = vlock(intern.vmem, h.?.seg);
            const sz = SEGSIZ - from.hdr.?.ehole;
            _ = mmove(ptr, @ptrFromInt(@intFromPtr(from.ptr) + @as(usize, @intCast(from.hdr.?.ehole))), @as(isize, @intCast(sz)));
            h.?.hole = @as(i16, @intCast(sz));
            h.?.nlines = @as(i16, @intCast(count_nl(ptr, @as(isize, @intCast(sz)))));
            vchanged_page(ptr);
            vunlock_page(ptr);
            from.hdr.?.nlines -= h.?.nlines;
            from.hdr.?.ehole = SEGSIZ;
        }

        from.hdr = to.hdr;
        vunlock_page(from.ptr);
        from.ptr = to.ptr;
        vupcount_page(to.ptr.?);
        from.ofst = 0;

        if (!ptrEq(@as(?*anyopaque, @ptrCast(a.?.link.next)), @as(?*anyopaque, @ptrCast(to.hdr)))) {
            const snip_first = @as(*Link, @alignCast(@ptrCast(a.?.link.next)));
            const snip_last = @as(*Link, @alignCast(@ptrCast(to.hdr.?.link.prev)));
            snip_(snip_first, snip_last);
            if (h == null) {
                h = link2H(snip_first);
            } else {
                splicef_(Hlink(h.?), snip_first);
            }
            if (i != null) enqueb_(Hlink(h.?), Hlink(i.?));
        } else if (h == null) {
            h = i;
        } else if (i != null) {
            enqueb_(Hlink(h.?), Hlink(i.?));
        }
    }

    // If to is empty, it was at EOF — delete it
    if (gsize_(to.hdr.?) == 0 and from.byte != 0) {
        const ph = @as(*H, @alignCast(@ptrCast(from.hdr.?.link.prev)));
        hfree(from.hdr.?);
        vunlock_page(from.ptr);
        from.hdr = ph;
        from.ptr = vlock(intern.vmem, from.hdr.?.seg);
        from.ofst = gsize_(from.hdr.?);
        vunlock_page(from.b.?.eof.?.ptr);
        from.b.?.eof.?.ptr = from.ptr;
        vupcount_page(from.ptr.?);
        from.b.?.eof.?.hdr = from.hdr;
        from.b.?.eof.?.ofst = from.ofst;
    }

    if (bofmove) _ = pset_(from.b.?.bof.?, from);
    if (from.b.?.db) |d| lattr_del(d, from.line, nlines);
    if (pisbol(from) != 0) {
        scrdel(@ptrCast(from.b), from.line, nlines, 0);
    } else {
        scrdel(@ptrCast(from.b), from.line, nlines, 1);
    }
    delerr(from.b.?.name, from.line, nlines);

    // Fix pointers
    var pp = link2P(@alignCast(@ptrCast(from.link.next)));
    while (!ptrEq(pp, from)) : (pp = link2P(@alignCast(@ptrCast(pp.link.next)))) {
        if (pp.line == from.line and (pp.byte > from.byte or (pp.end != 0 and pp.byte == from.byte))) {
            pp.valcol = 0;
            pp.valattr = 0;
        }
    }
    pp = link2P(@alignCast(@ptrCast(from.link.next)));
    while (!ptrEq(pp, from)) : (pp = link2P(@alignCast(@ptrCast(pp.link.next)))) {
        if (pp.byte >= from.byte) {
            if (pp.byte <= from.byte + amnt) {
                if (pp.ptr != null) {
                    _ = pset_(pp, from);
                } else {
                    _ = poffline_(pset_(pp, from));
                }
            } else {
                if (pp.hdr == to.hdr) pp.ofst -= toamnt;
                pp.byte -= amnt;
                pp.line -= nlines;
            }
        }
    }

    pcoalesce_(from);
    return bmkchn(h orelse halloc(), from.b, amnt, nlines);
}

pub fn bdel_(from: *P, to: *P) void {
    if (to.byte - from.byte > 0) {
        const b = bcut_(from, to);
        if (b) |bp| {
            const u = from.b.?.undo;
            if (u != null) {
                undodel(u.?, from.byte, @ptrCast(bp));
            } else {
                brm(bp);
            }
        }
        from.b.?.changed = 1;
    }
}

pub export fn bdel(from: ?*P, to: ?*P) void { bdel_(from.?, to.?); }

// ═══════════════════════════════════════════════════════════════════════
// pcoalesce — merge small adjacent segments
// ═══════════════════════════════════════════════════════════════════════

pub fn pcoalesce_(p: *P) void {
    // Coalesce with following segment
    if (!ptrEq(p.hdr, p.b.?.eof.?.hdr) and
        @as(i32, gsize_(p.hdr.?)) + @as(i32, gsize_(intern.H_of(p.hdr.?.link.next))) <= @as(i32, SEGSIZ) - @divTrunc(@as(i32, SEGSIZ), 4))
    {
        const hdr = @as(*H, @alignCast(@ptrCast(p.hdr.?.link.next)));
        const ptr = vlock(intern.vmem, hdr.seg);
        const osize = gsize_(p.hdr.?);
        const size = gsize_(hdr);
        gstgap(hdr, ptr, size);
        ginsm(p.hdr.?, p.ptr, gsize_(p.hdr.?), ptr, size);
        p.hdr.?.nlines += hdr.nlines;
        vunlock_page(ptr);
        hfree(hdr);
        var q = link2P(@alignCast(@ptrCast(p.link.next)));
        while (!ptrEq(q, p)) : (q = link2P(@alignCast(@ptrCast(q.link.next)))) {
            if (q.hdr == hdr) {
                q.hdr = p.hdr;
                if (q.ptr) |qp| {
                    vunlock_page(qp);
                    q.ptr = vlock(intern.vmem, q.hdr.?.seg);
                }
                q.ofst += osize;
            }
        }
    }
    // Coalesce with preceding segment
    if (!ptrEq(p.hdr, p.b.?.bof.?.hdr) and
        @as(i32, gsize_(intern.H_of(p.hdr.?.link.prev))) + @as(i32, gsize_(p.hdr.?)) <= @as(i32, SEGSIZ) - @divTrunc(@as(i32, SEGSIZ), 4))
    {
        const hdr = @as(*H, @alignCast(@ptrCast(p.hdr.?.link.prev)));
        const ptr = vlock(intern.vmem, hdr.seg);
        const size = gsize_(hdr);
        gstgap(hdr, ptr, size);
        ginsm(p.hdr.?, p.ptr, 0, ptr, size);
        p.hdr.?.nlines += hdr.nlines;
        vunlock_page(ptr);
        hfree(hdr);
        p.ofst += size;
        var q = link2P(@alignCast(@ptrCast(p.link.next)));
        while (!ptrEq(q, p)) : (q = link2P(@alignCast(@ptrCast(q.link.next)))) {
            if (q.hdr == hdr) {
                q.hdr = p.hdr;
                if (q.ptr) |qp| {
                    vunlock_page(qp);
                    q.ptr = vlock(intern.vmem, q.hdr.?.seg);
                }
            } else if (q.hdr == p.hdr) {
                q.ofst += size;
            }
        }
    }
}

pub export fn pcoalesce(p: ?*P) void { pcoalesce_(p.?); }

// ═══════════════════════════════════════════════════════════════════════
// bsplit / bldchn / inschn / fixupins — insert machinery
// ═══════════════════════════════════════════════════════════════════════

fn bsplit_(p: *P) void {
    if (p.ofst != 0) {
        const hdr = halloc();
        const ptr = vlock(intern.vmem, hdr.seg);
        if (p.ofst != p.hdr.?.hole) gstgap(p.hdr.?, p.ptr, p.ofst);
        _ = mmove(ptr, @ptrFromInt(@intFromPtr(p.ptr) + @as(usize, @intCast(p.hdr.?.ehole))), @as(isize, @intCast(SEGSIZ - p.hdr.?.ehole)));
        hdr.hole = @as(i16, @intCast(SEGSIZ - p.hdr.?.ehole));
        hdr.nlines = @as(i16, @intCast(count_nl(ptr, hdr.hole)));
        p.hdr.?.nlines -= hdr.nlines;
        p.hdr.?.ehole = SEGSIZ;
        vchanged_page(ptr);
        enquef_(Hlink(p.hdr.?), Hlink(hdr));
        vunlock_page(p.ptr);
        var pp = link2P(@alignCast(@ptrCast(p.link.next)));
        while (!ptrEq(pp, p)) : (pp = link2P(@alignCast(@ptrCast(pp.link.next)))) {
            if (pp.hdr == p.hdr and pp.ofst >= p.ofst) {
                pp.hdr = hdr;
                if (pp.ptr) |qpp| {
                    vunlock_page(qpp);
                    pp.ptr = ptr;
                    vupcount_page(ptr);
                }
                pp.ofst -= p.ofst;
            }
        }
        p.ptr = ptr;
        p.hdr = hdr;
        p.ofst = 0;
    }
}

fn bldchn_(blk: ?*const anyopaque, size: isize) ?*H {
    var anchor: H = undefined;
    izque(Hlink(&anchor));
    var remain = size;
    var bytes = @as([*]const u8, @ptrCast(blk));
    while (remain > 0) {
        const l = halloc();
        const ptr = vlock(intern.vmem, l.seg);
        const amnt = @min(remain, @as(isize, SEGSIZ));
        _ = mmove(ptr, @ptrCast(bytes), amnt);
        l.hole = @as(i16, @intCast(amnt));
        l.ehole = SEGSIZ;
        l.nlines = @as(i16, @intCast(count_nl(ptr, amnt)));
        vchanged_page(ptr);
        vunlock_page(ptr);
        enqueb_(Hlink(&anchor), Hlink(l));
        bytes += @as(usize, @intCast(amnt));
        remain -= amnt;
    }
    const result = link2H(@alignCast(@ptrCast(anchor.link.next)));
    deque_(Hlink(&anchor));
    return result;
}

fn inschn_(p: *P, a: *H) void {
    if (p.b.?.eof.?.byte == 0) {
        // Empty buffer: replace the empty segment with chain a.
        // If p.hdr == a (header freelist double-alloc), do not hfree —
        // that would place the data header on ohdrs for the next halloc
        // to reclaim and zero (hole=0), wiping the just-copied content.
        if (!ptrEq(p.hdr, a)) {
            hfree(p.hdr.?);
            p.hdr = a;
            vunlock_page(p.ptr);
            p.ptr = vlock(intern.vmem, a.seg);
            _ = pset_(p.b.?.bof.?, p);
        }
        p.b.?.eof.?.hdr = @as(*H, @alignCast(@ptrCast(a.link.prev)));
        vunlock_page(p.b.?.eof.?.ptr);
        p.b.?.eof.?.ptr = vlock(intern.vmem, p.b.?.eof.?.hdr.?.seg);
        p.b.?.eof.?.ofst = gsize_(p.b.?.eof.?.hdr.?);
    } else if (piseof(p) != 0) {
        // At EOF: append chain a
        p.b.?.eof.?.hdr = @as(*H, @alignCast(@ptrCast(a.link.prev)));
        _ = spliceb_f_(Hlink(p.b.?.bof.?.hdr.?), Hlink(a));
        vunlock_page(p.b.?.eof.?.ptr);
        p.b.?.eof.?.ptr = vlock(intern.vmem, p.b.?.eof.?.hdr.?.seg);
        p.b.?.eof.?.ofst = gsize_(p.b.?.eof.?.hdr.?);
        p.hdr = a;
        vunlock_page(p.ptr);
        p.ptr = vlock(intern.vmem, a.seg);
        p.ofst = 0;
    } else if (pisbof(p) != 0) {
        // At BOF: insert chain, set bof pointer
        p.hdr = link2H(spliceb_f_(Hlink(p.hdr.?), Hlink(a)));
        vunlock_page(p.ptr);
        p.ptr = vlock(intern.vmem, a.seg);
        _ = pset_(p.b.?.bof.?, p);
    } else {
        // Middle: split and insert
        bsplit_(p);
        p.hdr = link2H(spliceb_f_(Hlink(p.hdr.?), Hlink(a)));
        vunlock_page(p.ptr);
        p.ptr = vlock(intern.vmem, a.seg);
    }
}

fn fixupins_(p: *P, amnt: i64, nlines: i64, hdr: ?*H, hdramnt: i16) void {
    if (pisbol(p) != 0) {
        scrins(@ptrCast(p.b), p.line, nlines, 0);
    } else {
        scrins(@ptrCast(p.b), p.line, nlines, 1);
    }
    if (p.b.?.db) |d| lattr_ins(d, p.line, nlines);
    inserr(p.b.?.name, p.line, nlines, if (pisbol(p) != 0) 1 else 0);

    var pp = link2P(@alignCast(@ptrCast(p.link.next)));
    while (!ptrEq(pp, p)) : (pp = link2P(@alignCast(@ptrCast(pp.link.next)))) {
        if (pp.line == p.line and (pp.byte > p.byte or (pp.end != 0 and pp.byte == p.byte))) {
            pp.valcol = 0;
            pp.valattr = 0;
        }
    }
    pp = link2P(@alignCast(@ptrCast(p.link.next)));
    while (!ptrEq(pp, p)) : (pp = link2P(@alignCast(@ptrCast(pp.link.next)))) {
        if (pp.byte == p.byte and pp.end == 0) {
            if (pp.ptr != null) {
                _ = pset_(pp, p);
            } else {
                _ = poffline_(pset_(pp, p));
            }
        } else if (pp.byte > p.byte or (pp.end != 0 and pp.byte == p.byte)) {
            pp.byte += amnt;
            pp.line += nlines;
            if (hdr != null and pp.hdr == hdr) pp.ofst += hdramnt;
        }
    }
    if (p.b.?.undo) |u| undoins(u, @ptrCast(p), amnt);
    p.b.?.changed = 1;
}

// ═══════════════════════════════════════════════════════════════════════
// binsb / binsm / binsmq / binsc / binsbyte / binss
// ═══════════════════════════════════════════════════════════════════════

pub export fn binsb(p: ?*P, b: ?*B) ?*P {
    const pp = p.?;
    const bp = b.?;
    if (bp.eof.?.byte > 0) {
        const q = pdup_(pp, "binsb");
        const stolen = bp.bof.?.hdr.?;
        inschn_(q, stolen);
        // Always use a brand-new header for the emptied temp buffer. After
        // header-freelist corruption, halloc() can hand back a still-live
        // header from the stolen chain and zero its hole (wiping content).
        bp.eof.?.hdr = hallocFresh();
        fixupins_(q, bp.eof.?.byte, bp.eof.?.line, null, 0);
        pcoalesce_(q);
        prm(q);
    }
    brm(bp);
    return pp;
}


pub export fn binsm(p: ?*P, blk: ?*const anyopaque, amnt: isize) ?*P {
    return @ptrCast(binsm_(p.?, blk, amnt));
}


pub fn binsm_(p: *P, blk: ?*const anyopaque, amnt: isize) ?*P {
    if (amnt == 0) return p;
    const q = pdup_(p, "binsm");
    var h: ?*H = null;
    var hdramnt: i16 = 0;
    var nlines: i64 = 0;
    const gsz = @as(isize, @intCast(ggapsz(q.hdr.?)));
    if (amnt <= gsz) {
        h = q.hdr;
        hdramnt = @as(i16, @intCast(amnt));
        ginsm(q.hdr.?, q.ptr, q.ofst, blk, @as(i16, @intCast(amnt)));
        nlines = count_nl(blk, amnt);
        q.hdr.?.nlines += @as(i16, @intCast(nlines));
    } else if (q.ofst == 0 and !ptrEq(q.hdr, q.b.?.bof.?.hdr) and
        amnt <= @as(isize, @intCast(ggapsz(intern.H_of(q.hdr.?.link.prev)))))
    {
        // Match C: do not set h/hdramnt on this path.
        _ = pprev_(q);
        ginsm(q.hdr.?, q.ptr, q.ofst, blk, @as(i16, @intCast(amnt)));
        nlines = count_nl(blk, amnt);
        q.hdr.?.nlines += @as(i16, @intCast(nlines));
    } else {
        const a = bldchn_(blk, amnt);
        inschn_(q, a.?);
        nlines = count_nl(blk, amnt);
    }
    fixupins_(q, amnt, nlines, h, hdramnt);
    pcoalesce_(q);
    prm(q);
    return p;
}

pub export fn binsmq(p: ?*P, blk: ?*const anyopaque, amnt: isize) ?*P {
    const pp = p.?;
    // C tolerates NULL blk when amnt==0 (e.g. sv(NULL) from empty get_cd).
    // Zig forbids casting null to [*]u8, so bail out first.
    if (amnt == 0 or blk == null) return pp;
    const q = pdup_(pp, "binsmq");
    const bytes = @as([*]const u8, @ptrCast(blk));
    var y: isize = 0;
    while (y < amnt) {
        var x = y;
        while (x < amnt) {
            const xb = bytes[@as(usize, @intCast(x))];
            const esc = (x == 0 and xb == '!') or
                (x == 0 and bytes[0] == '>' and bytes[1] == '>') or
                (x == 1 and bytes[0] == '>' and xb == '>') or
                xb == ' ' or xb == '\t' or xb == '\\' or xb == ',';
            if (esc) break;
            x += 1;
        }
        if (x != y) {
            _ = binsm_(q, @ptrCast(bytes + @as(usize, @intCast(y))), x - y);
            _ = pfwrd_(q, x - y);
        }
        if (x != amnt) {
            const xb = bytes[@as(usize, @intCast(x))];
            const esc_str: ?[*]const u8 = switch (xb) {
                ' ' => "\\ ",
                '\t' => "\\\t",
                ',' => "\\,",
                '!' => "\\!",
                '>' => "\\>",
                '\\' => "\\\\",
                else => null,
            };
            if (esc_str) |es| {
                _ = binsm_(q, @ptrCast(es), 2);
                _ = pfwrd_(q, 2);
                y = x + 1;
            } else {
                break;
            }
        } else {
            break;
        }
    }
    prm(q);
    return pp;
}

pub export fn binsbyte(p: ?*P, c: u8) ?*P {
    const pp = p.?;
    if (pp.b.?.o.crlf != 0 and c == '\n') return binss(pp, "\r\n");
    return binsm(pp, @ptrCast(&c), 1);
}

pub export fn binsc(p: ?*P, c: c_int) ?*P {
    return @ptrCast(binsc_(p.?, c));
}

pub fn binsc_(p: *P, c: c_int) ?*P {
    var cc = c;
    if (cc >= -128 and cc < 0) cc += 256;
    if ((cc & types.ANSI_BIT) != 0 and p.b.?.o.ansi != 0) {
        if (ansi_mod.ansi_string(cc)) |s| {
            const slen = strlen(@ptrCast(s));
            return binsm_(p, s, @as(isize, @intCast(slen)));
        }
    }
    if (cc > 127 and charmapIsUtf8(p.b.?.o.charmap)) {
        var buf: [8]u8 = undefined;
        const len = utf8_encode(&buf, cc);
        return binsm_(p, @ptrCast(&buf), len);
    }
    const ch: u8 = @intCast(cc & 0xFF);
    if (p.b.?.o.crlf != 0 and cc == '\n') return binss_(p, "\r\n");
    return binsm_(p, @ptrCast(&[1]u8{ch}), 1);
}

pub export fn binss(p: ?*P, s: [*c]const u8) ?*P {
    return @ptrCast(binss_(p.?, s));
}

pub fn binss_(p: *P, s: [*c]const u8) ?*P {
    return binsm_(p, @ptrCast(s), @as(isize, @intCast(strlen(s))));
}

extern fn strlen(s: [*c]const u8) usize;

// ═══════════════════════════════════════════════════════════════════════
// Buffer list navigation
// ═══════════════════════════════════════════════════════════════════════

pub export fn bafter(b: ?*B) ?*B {
    _ = intern.ensureBufs();
    const first = b.?;
    var cur = link2B(@alignCast(@ptrCast(first.link.next)));
    while (!ptrEq(cur, first) and (cur.internal != 0 or cur.scratch != 0 or ptrEq(cur, &intern.bufs))) {
        cur = link2B(@alignCast(@ptrCast(cur.link.next)));
    }
    return if (ptrEq(cur, first)) null else cur;
}

pub export fn bnext() ?*B {
    _ = intern.ensureBufs();
    var b = link2B(@alignCast(@ptrCast(intern.bufs.link.prev)));
    while (!ptrEq(b, &intern.bufs) and b.internal != 0) {
        b = link2B(@alignCast(@ptrCast(b.link.prev)));
    }
    return if (ptrEq(b, &intern.bufs)) null else b;
}

pub export fn bprev() ?*B {
    _ = intern.ensureBufs();
    var b = link2B(@alignCast(@ptrCast(intern.bufs.link.next)));
    while (!ptrEq(b, &intern.bufs) and b.internal != 0) {
        b = link2B(@alignCast(@ptrCast(b.link.next)));
    }
    return if (ptrEq(b, &intern.bufs)) null else b;
}

pub export fn borphan() ?*B {
    _ = intern.ensureBufs();
    var b = link2B(@alignCast(@ptrCast(intern.bufs.link.next)));
    while (!ptrEq(b, &intern.bufs)) : (b = link2B(@alignCast(@ptrCast(b.link.next)))) {
        if (b.orphan != 0 and (b.scratch == 0 or b.pid != 0)) {
            b.orphan = 0;
            return b;
        }
    }
    return null;
}

// ═══════════════════════════════════════════════════════════════════════
// bfind family — defined in fileio.zig (need file loading), but the
// pure-lookup bfind_scratch lives here.
// ═══════════════════════════════════════════════════════════════════════

pub export fn set_file_pos_orphaned() void {
    _ = intern.ensureBufs();
    var b = link2B(@alignCast(@ptrCast(intern.bufs.link.next)));
    while (!ptrEq(b, &intern.bufs)) : (b = link2B(@alignCast(@ptrCast(b.link.next)))) {
        if (b.orphan != 0 and b.oldcur != null) {
            set_file_pos(@ptrCast(b.name), b.oldcur.?.line);
        }
    }
}

pub export fn udebug_joe(w: ?*anyopaque, k: c_int) c_int {
    _ = w;
    _ = k;
    return 0;
}
