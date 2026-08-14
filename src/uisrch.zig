//! Path A live port of JOE incremental search (`joe/uisrch.c`).
//!
//! JOE `uisrch.h` ABI lives here (`uisrch`, `ursrch`).
//! `joe/uisrch.c` is a tombstone.

const std = @import("std");
const gap_types = @import("gapbuffer/types.zig");

const GapP = gap_types.P;
const GapB = gap_types.B;
const GapOptions = gap_types.OPTIONS;
const Charmap = gap_types.Charmap;

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
}

const IrecLink = extern struct {
    next: ?*Irec,
    prev: ?*Irec,
};

const Irec = extern struct {
    link: IrecLink,
    what: isize,
    start: i64,
    disp: i64,
    wrap_flag: c_int,
};

const Isrch = extern struct {
    irecs: Irec,
    pattern: [*c]u8,
    prompt: [*c]u8,
    ofst: isize,
    dir: c_int,
    quote: c_int,
};

const Regmatch = extern struct {
    rm_so: i64,
    rm_eo: i64,
};

const SrchRec = extern struct {
    link: extern struct { next: ?*anyopaque, prev: ?*anyopaque },
    yn: c_int,
    wrap_flag: c_int,
    addr: i64,
    b: ?*anyopaque,
    last_repl: i64,
};

/// C `struct search` / `SRCH` — layout verified against clang offsetof.
const Srch = extern struct {
    pattern: [*c]u8,
    comp: ?*anyopaque,
    replacement: [*c]u8,
    backwards: c_int,
    ignore: c_int,
    regex: c_int,
    repeat: c_int,
    replace: c_int,
    debug: c_int,
    rest: c_int,
    _pad0: c_int,
    pieces: [26]Regmatch,
    entire: Regmatch,
    flg: c_int,
    _pad1: c_int,
    recs: SrchRec,
    markb: ?*GapP,
    markk: ?*GapP,
    wrap_p: ?*GapP,
    wrap_flag: c_int,
    allow_wrap: c_int,
    valid: c_int,
    _pad2: c_int,
    addr: i64,
    last_repl: i64,
    block_restrict: c_int,
    all: c_int,
    first: ?*GapB,
    current: ?*GapB,
};

comptime {
    if (@sizeOf(Srch) != 624) @compileError("Srch size mismatch");
    if (@offsetOf(Srch, "backwards") != 24) @compileError("Srch.backwards offset");
    if (@offsetOf(Srch, "wrap_p") != 560) @compileError("Srch.wrap_p offset");
    if (@offsetOf(Srch, "wrap_flag") != 568) @compileError("Srch.wrap_flag offset");
    if (@offsetOf(Srch, "addr") != 584) @compileError("Srch.addr offset");
}

var lastisrch: ?*Isrch = null;
var lastpat: [*c]u8 = null;

var fri: Irec = undefined;
var fri_ready: bool = false;

extern var globalsrch: ?*Srch;
extern var smode: c_int;
extern var opt_mid: c_int;
extern var opt_icase: c_int;
extern var joe_beep: c_int;
extern var locale_map: ?*Charmap;
extern var obuf: [*c]u8;
extern var obufp: isize;
extern var obufsiz: isize;

extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn joe_free(ptr: ?*anyopaque) void;
extern fn alitem(list: ?*anyopaque, itemsize: isize) ?*anyopaque;
extern fn frchn(list: ?*anyopaque, ch: ?*anyopaque) void;
extern fn vsrm(s: [*c]u8) void;
extern fn vsncpy(vary: [*c]u8, pos: isize, array: [*c]const u8, len: isize) [*c]u8;
extern fn vstrunc(vary: [*c]u8, len: isize) [*c]u8;
extern fn vsadd(vary: [*c]u8, el: u8) [*c]u8;
extern fn slen(s: [*c]const u8) isize;
extern fn pgoto(p: ?*GapP, loc: i64) ?*GapP;
extern fn pdup(p: ?*GapP, tr: [*:0]const u8) ?*GapP;
extern fn prm(p: ?*GapP) void;
extern fn piscol(p: ?*GapP) i64;
extern fn dofollows() void;
extern fn nungetc(c: c_int) void;
extern fn ttflsh() c_int;
extern fn my_gettext(s: [*c]const u8) [*c]const u8;
extern fn utf8_encode(buf: [*]u8, c: c_int) isize;
extern fn utf8_decode_fwrd(pos: *[*c]const u8, len: ?*isize) c_int;
extern fn to_uni(cset: ?*Charmap, c_in: c_int) c_int;
extern fn from_uni(cset: ?*Charmap, c_in: c_int) c_int;
extern fn mksrch(
    pattern: [*c]u8,
    replacement: [*c]u8,
    ignore: c_int,
    backwards: c_int,
    repeat: c_int,
    replace: c_int,
    rest: c_int,
    all: c_int,
    regex: c_int,
) ?*Srch;
extern fn setpat(srch: ?*Srch, pattern: [*c]u8) void;
extern fn rmsrch(srch: ?*Srch) void;
extern fn dopfnext(bw: ?*anyopaque, srch: ?*Srch, notify: ?*c_int) c_int;
extern fn mkqwnsr(
    w: ?*WinRec,
    prompt: [*c]const u8,
    len: isize,
    func: ?*const fn (?*WinRec, c_int, ?*anyopaque, ?*c_int) callconv(.c) c_int,
    abrt: ?*const fn (?*WinRec, ?*anyopaque) callconv(.c) c_int,
    object: ?*anyopaque,
    notify: ?*c_int,
) ?*anyopaque;

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

fn vsLen(s: [*c]u8) isize {
    if (s == null) return 0;
    return (@as([*]align(1) const isize, @ptrCast(s)) - 1)[0];
}

fn ttputcBell() void {
    if (joe_beep == 0) return;
    if (obuf == null) return;
    const idx: usize = @intCast(obufp);
    obuf[idx] = 7;
    obufp += 1;
    if (obufp == obufsiz) _ = ttflsh();
}

fn ensureFri() void {
    if (fri_ready) return;
    fri = std.mem.zeroes(Irec);
    fri.link.next = &fri;
    fri.link.prev = &fri;
    fri_ready = true;
}

fn izqueIrec(item: *Irec) void {
    item.link.next = item;
    item.link.prev = item;
}

fn qemptyIrecs(queue: *Irec) bool {
    return queue.link.next == queue;
}

fn enquebIrec(queue: *Irec, item: *Irec) void {
    const p = queue.link.prev.?;
    item.link.next = queue;
    item.link.prev = queue.link.prev;
    p.link.next = item;
    queue.link.prev = item;
}

fn enquefIrec(queue: *Irec, item: *Irec) void {
    const n = queue.link.next.?;
    item.link.prev = queue;
    item.link.next = queue.link.next;
    n.link.prev = item;
    queue.link.next = item;
}

fn dequeIrec(item: *Irec) *Irec {
    const n = item.link.next.?;
    const p = item.link.prev.?;
    p.link.next = item.link.next;
    n.link.prev = item.link.prev;
    return item;
}

fn alirec() *Irec {
    ensureFri();
    return @ptrCast(@alignCast(alitem(@ptrCast(&fri), @sizeOf(Irec)).?));
}

fn frirec(i: *Irec) void {
    ensureFri();
    enquefIrec(&fri, i);
}

fn rmisrch(isrch: ?*Isrch) void {
    const s = isrch orelse return;
    ensureFri();
    vsrm(s.pattern);
    vsrm(s.prompt);
    frchn(@ptrCast(&fri), @ptrCast(&s.irecs));
    joe_free(s);
}

fn iabrt(w: ?*WinRec, obj: ?*anyopaque) callconv(.c) c_int {
    _ = w;
    rmisrch(@ptrCast(@alignCast(obj)));
    return -1;
}

fn iappend(bw: *BwRec, isrch: *Isrch, s: [*c]u8, len: isize) void {
    const i = alirec();
    i.what = len;
    i.disp = bw.cursor.?.byte;
    isrch.pattern = vsncpy(isrch.pattern, vsLen(isrch.pattern), s, len);

    if (!qemptyIrecs(&isrch.irecs)) {
        const prev = isrch.irecs.link.prev.?;
        _ = pgoto(bw.cursor, prev.start);
        if (globalsrch) |gs| {
            gs.wrap_flag = prev.wrap_flag;
        }
    }
    i.start = bw.cursor.?.byte;

    var srch: *Srch = undefined;
    if (globalsrch == null) {
        srch = mksrch(null, null, opt_icase, isrch.dir, -1, 0, 0, 0, 0).?;
    } else {
        srch = globalsrch.?;
        globalsrch = null;
    }

    srch.addr = bw.cursor.?.byte;

    if (srch.wrap_p == null or srch.wrap_p.?.b != bw.b) {
        prm(srch.wrap_p);
        srch.wrap_p = pdup(bw.cursor, "iappend");
        srch.wrap_p.?.owner = &srch.wrap_p;
        srch.wrap_flag = 0;
    }

    i.wrap_flag = srch.wrap_flag;

    setpat(srch, vsncpy(null, 0, isrch.pattern, vsLen(isrch.pattern)));
    srch.backwards = isrch.dir;

    if (dopfnext(@ptrCast(bw), srch, null) != 0) {
        ttputcBell();
    }
    enquebIrec(&isrch.irecs, i);
}

fn itype(w: ?*WinRec, c: c_int, obj: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    const isrch: *Isrch = @ptrCast(@alignCast(obj.?));
    const bw = windBw(@ptrCast(w)) orelse return -1;

    var handled_char = false;
    if (isrch.quote != 0) {
        handled_char = true;
    } else if (c == 8 or c == 127) {
        if (isrch.irecs.link.prev != &isrch.irecs) {
            const i = isrch.irecs.link.prev.?;
            _ = pgoto(bw.cursor, i.disp);
            if (globalsrch) |gs| {
                gs.wrap_flag = i.wrap_flag;
            }
            const omid = opt_mid;
            opt_mid = 1;
            dofollows();
            opt_mid = omid;
            isrch.pattern = vstrunc(isrch.pattern, vsLen(isrch.pattern) - i.what);
            frirec(dequeIrec(i));
        } else {
            ttputcBell();
        }
    } else if (c == 'Q' - '@') {
        isrch.quote = 1;
    } else if (c == 'S' - '@' or c == '\\' - '@' or c == 'L' - '@' or c == 'R' - '@') {
        if (c == 'R' - '@') {
            isrch.dir = 1;
        } else {
            isrch.dir = 0;
        }
        if (qemptyIrecs(&isrch.irecs)) {
            if (lastpat != null and lastpat[0] != 0) {
                iappend(bw, isrch, lastpat, vsLen(lastpat));
            }
        } else {
            const i = alirec();
            i.disp = bw.cursor.?.byte;
            i.start = bw.cursor.?.byte;
            i.what = 0;

            var srch: *Srch = undefined;
            if (globalsrch == null) {
                srch = mksrch(null, null, opt_icase, isrch.dir, -1, 0, 0, 0, 0).?;
            } else {
                srch = globalsrch.?;
                globalsrch = null;
            }

            srch.addr = bw.cursor.?.byte;

            if (srch.wrap_p == null or srch.wrap_p.?.b != bw.b) {
                prm(srch.wrap_p);
                srch.wrap_p = pdup(bw.cursor, "itype");
                srch.wrap_p.?.owner = &srch.wrap_p;
                srch.wrap_flag = 0;
            }

            i.wrap_flag = srch.wrap_flag;

            setpat(srch, vsncpy(null, 0, isrch.pattern, vsLen(isrch.pattern)));
            srch.backwards = isrch.dir;

            if (dopfnext(@ptrCast(bw), srch, null) != 0) {
                ttputcBell();
                frirec(i);
            } else {
                enquebIrec(&isrch.irecs, i);
            }
        }
    } else if (c >= 0 and c < 32) {
        nungetc(c);
        if (notify) |n| n.* = 1;
        smode = 2;
        if (lastisrch) |prev| {
            lastpat = vstrunc(lastpat, 0);
            lastpat = vsncpy(lastpat, 0, prev.pattern, vsLen(prev.pattern));
            rmisrch(prev);
        }
        lastisrch = isrch;
        return 0;
    } else if (c != -1) {
        handled_char = true;
    }

    if (handled_char) {
        var buf: [16]u8 = undefined;
        var buf_len: isize = undefined;
        const bmap = bw.b.?.o.charmap;
        if (bmap != null and bmap.?.@"type" != 0) {
            buf_len = utf8_encode(&buf, c);
        } else {
            // TO_CHAR_OK(from_uni(...)): C int→char truncate
            const tc = from_uni(bmap, c);
            buf[0] = @as(u8, @bitCast(@as(i8, @truncate(tc))));
            buf_len = 1;
        }

        isrch.quote = 0;
        iappend(bw, isrch, &buf, buf_len);
    }

    const omid = opt_mid;
    opt_mid = 1;
    bw.cursor.?.xcol = piscol(bw.cursor);
    dofollows();
    opt_mid = omid;

    isrch.prompt = vstrunc(isrch.prompt, isrch.ofst);

    const loc = locale_map;
    const bmap = bw.b.?.o.charmap;
    if (loc != null and loc.?.@"type" != 0 and (bmap == null or bmap.?.@"type" == 0)) {
        // Translate bytes to utf-8
        var x: isize = 0;
        const plen = vsLen(isrch.pattern);
        while (x != plen) : (x += 1) {
            var ubuf: [16]u8 = undefined;
            const tc = to_uni(bmap, isrch.pattern[@intCast(x)]);
            _ = utf8_encode(&ubuf, tc);
            isrch.prompt = vsncpy(isrch.prompt, vsLen(isrch.prompt), &ubuf, slen(&ubuf));
        }
    } else if ((loc == null or loc.?.@"type" == 0) and bmap != null and bmap.?.@"type" != 0) {
        // Translate utf-8 to bytes
        var p: [*c]const u8 = isrch.pattern;
        var len = vsLen(isrch.pattern);
        while (len != 0) {
            const tc0 = utf8_decode_fwrd(&p, &len);
            if (tc0 >= 0) {
                const tc = from_uni(loc, tc0);
                isrch.prompt = vsadd(isrch.prompt, @as(u8, @bitCast(@as(i8, @truncate(tc)))));
            }
        }
    } else {
        isrch.prompt = vsncpy(isrch.prompt, vsLen(isrch.prompt), isrch.pattern, vsLen(isrch.pattern));
    }

    if (mkqwnsr(bw.parent, isrch.prompt, vsLen(isrch.prompt), &itype, &iabrt, @ptrCast(isrch), notify) != null) {
        return 0;
    } else {
        rmisrch(isrch);
        return -1;
    }
}

fn doisrch(bw: *BwRec, dir: c_int) c_int {
    const isrch: *Isrch = @ptrCast(@alignCast(joe_malloc(@sizeOf(Isrch)).?));
    izqueIrec(&isrch.irecs);
    isrch.pattern = vsncpy(null, 0, null, 0);
    isrch.dir = dir;
    isrch.quote = 0;
    const prompt_txt = my_gettext("I-find: ");
    isrch.prompt = vsncpy(null, 0, prompt_txt, slen(prompt_txt));
    isrch.ofst = vsLen(isrch.prompt);
    return itype(bw.parent, -1, @ptrCast(isrch), null);
}

export fn uisrch(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    if (smode != 0 and lastisrch != null) {
        const isrch = lastisrch.?;
        lastisrch = null;
        return itype(bw.parent, 'S' - '@', @ptrCast(isrch), null);
    } else {
        if (globalsrch) |gs| {
            rmsrch(gs);
            globalsrch = null;
        }
        if (lastisrch) |prev| {
            lastpat = vstrunc(lastpat, 0);
            lastpat = vsncpy(lastpat, 0, prev.pattern, vsLen(prev.pattern));
            rmisrch(prev);
            lastisrch = null;
        }
        return doisrch(bw, 0);
    }
}

export fn ursrch(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    if (smode != 0 and lastisrch != null) {
        const isrch = lastisrch.?;
        lastisrch = null;
        return itype(bw.parent, 'R' - '@', @ptrCast(isrch), null);
    } else {
        if (globalsrch) |gs| {
            rmsrch(gs);
            globalsrch = null;
        }
        if (lastisrch) |prev| {
            lastpat = vstrunc(lastpat, 0);
            lastpat = vsncpy(lastpat, 0, prev.pattern, vsLen(prev.pattern));
            rmisrch(prev);
            lastisrch = null;
        }
        return doisrch(bw, 1);
    }
}
