//! Path A live port of JOE tags lookup (`joe/utag.c`).
//!
//! JOE `utag.h` ABI lives here (`notagsmenu`, `utag`, `utagjump`).
//! `joe/utag.c` is a tombstone.

const std = @import("std");
const gap_types = @import("gapbuffer/types.zig");
const intern = @import("gapbuffer/intern.zig");

const GapP = gap_types.P;
const GapB = gap_types.B;
const GapOptions = gap_types.OPTIONS;
const NO_MORE_DATA = gap_types.NO_MORE_DATA;

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;

export var notagsmenu: c_int = 0;
export var tag_array: [*c][*c]u8 = null;

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

const ScreenRec = extern struct {
    t: ?*anyopaque,
    wind: isize,
    topwin: ?*WinRec,
    curwin: ?*WinRec,
    w: isize,
    h: isize,
};

const MenuRec = extern struct {
    parent: ?*WinRec,
};

const TagLink = extern struct {
    next: ?*Tag,
    prev: ?*Tag,
};

const Tag = extern struct {
    link: TagLink,
    key: [*c]u8,
    file: [*c]u8,
    srch: [*c]u8,
    line: i64,
    cmnt: [*c]u8,
    last: c_int,
};

comptime {
    if (@sizeOf(WinRec) != 200) @compileError("WinRec size mismatch");
    if (@sizeOf(BwRec) != 488) @compileError("BwRec size mismatch");
}

var tags: Tag = undefined;
var tagnodes: Tag = undefined;
var tag_sentinels_ready: bool = false;
var last_cursor: isize = 0;
var tag_word_list: [*c][*c]u8 = null;
var last_update: c_long = 0;

extern var maint: ?*ScreenRec;
extern var locale_map: ?*anyopaque;
extern var smode: c_int;
extern var opt_mid: c_int;
extern var obuf: [*c]u8;
extern var obufp: isize;
extern var obufsiz: isize;

extern fn pdup(p: ?*GapP, tr: [*:0]const u8) ?*GapP;
extern fn prm(p: ?*GapP) void;
extern fn pset(n: ?*GapP, p: ?*GapP) ?*GapP;
extern fn p_goto_bof(p: ?*GapP) ?*GapP;
extern fn pline(p: ?*GapP, line: i64) ?*GapP;
extern fn piscol(p: ?*GapP) i64;
extern fn pgetc(p: ?*GapP) c_int;
extern fn prgetc(p: ?*GapP) c_int;
extern fn brch(p: ?*GapP) c_int;
extern fn bcpy(from: ?*GapP, to: ?*GapP) ?*GapB;
extern fn binsb(p: ?*GapP, b: ?*GapB) ?*GapP;
extern fn alitem(list: ?*anyopaque, itemsize: isize) ?*anyopaque;
extern fn msgnw(w: ?*anyopaque, s: [*c]const u8) void;
extern fn my_gettext(s: [*c]const u8) [*c]const u8;
extern fn dofollows() void;
extern fn vsrm(s: [*c]u8) void;
extern fn vsncpy(vary: [*c]u8, pos: isize, array: [*c]const u8, len: isize) [*c]u8;
extern fn vamk(len: isize) [*c][*c]u8;
extern fn vaadd(vary: [*c][*c]u8, el: [*c]u8) [*c][*c]u8;
extern fn varm(v: [*c][*c]u8) void;
extern fn slen(s: [*c]const u8) isize;
extern fn zmcmp(a: [*c]const u8, b: [*c]const u8) c_int;
extern fn ztoo(s: [*c]const u8) i64;
extern fn zncpy(a: [*c]u8, b: [*c]const u8, len: isize) [*c]u8;
extern fn hack_check(name: [*c]const u8) c_int;
extern fn dirprt(path: [*c]const u8) [*c]u8;
extern fn doswitch(w: ?*anyopaque, s: [*c]u8, obj: ?*anyopaque, notify: ?*c_int) c_int;
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
) ?*anyopaque;
extern fn dopfnext(bw: ?*anyopaque, srch: ?*anyopaque, notify: ?*c_int) c_int;
extern fn wabort(w: ?*anyopaque) c_int;
extern fn mkmenu(
    loc: ?*anyopaque,
    targ: ?*anyopaque,
    s: [*c][*c]u8,
    func: ?*const fn (?*anyopaque, isize, ?*anyopaque, c_int) callconv(.c) c_int,
    abrt: ?*const fn (?*anyopaque, isize, ?*anyopaque) callconv(.c) c_int,
    backs: ?*const fn (?*anyopaque, isize, ?*anyopaque) callconv(.c) c_int,
    cursor: isize,
    object: ?*anyopaque,
    notify: ?*c_int,
) ?*anyopaque;
extern fn simple_cmplt(bw: ?*anyopaque, list: [*c][*c]u8) c_int;
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
) ?*BwRec;
extern fn htmk(n: isize) ?*anyopaque;
extern fn htadd(h: ?*anyopaque, name: [*c]const u8, val: ?*anyopaque) void;
extern fn htfind(h: ?*anyopaque, name: [*c]const u8) ?*anyopaque;
extern fn htrm(h: ?*anyopaque) void;
extern fn ttflsh() c_int;
extern fn getenv(name: [*c]const u8) [*c]u8;
extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
extern fn strstr(hay: [*c]u8, needle: [*c]const u8) [*c]u8;
extern fn snprintf(buf: [*c]u8, n: usize, fmt: [*c]const u8, ...) c_int;
extern fn fopen(path: [*c]const u8, mode: [*c]const u8) ?*anyopaque;
extern fn fclose(stream: ?*anyopaque) c_int;
extern fn fgets(s: [*c]u8, n: c_int, stream: ?*anyopaque) [*c]u8;
extern fn fileno(stream: ?*anyopaque) c_int;

var taghist: ?*GapB = null;

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

fn aLEN(vary: [*c][*c]u8) isize {
    if (vary == null) return 0;
    return (@as([*]align(1) const isize, @ptrCast(vary)) - 1)[0];
}

fn zlen(s: [*c]const u8) isize {
    if (s == null) return 0;
    return @intCast(std.mem.len(@as([*:0]const u8, @ptrCast(s))));
}

fn joeIsAlnum(map: ?*anyopaque, ch: c_int) bool {
    return intern.joe_isalnum_v(map, ch) != 0;
}

fn ttputcBell() void {
    if (obuf == null) return;
    const idx: usize = @intCast(obufp);
    obuf[idx] = 7;
    obufp += 1;
    if (obufp == obufsiz) _ = ttflsh();
}

fn izqueTag(item: *Tag) void {
    item.link.next = item;
    item.link.prev = item;
}

fn ensureTagSentinels() void {
    if (tag_sentinels_ready) return;
    tags = std.mem.zeroes(Tag);
    tagnodes = std.mem.zeroes(Tag);
    izqueTag(&tags);
    izqueTag(&tagnodes);
    tag_sentinels_ready = true;
}

fn qemptyTags() bool {
    ensureTagSentinels();
    return tags.link.next == &tags;
}

fn enquebTag(queue: *Tag, item: *Tag) void {
    const p = queue.link.prev.?;
    item.link.next = queue;
    item.link.prev = queue.link.prev;
    p.link.next = item;
    queue.link.prev = item;
}

fn enquefTag(queue: *Tag, item: *Tag) void {
    const n = queue.link.next.?;
    item.link.prev = queue;
    item.link.next = queue.link.next;
    n.link.prev = item;
    queue.link.next = item;
}

fn dequeTag(item: *Tag) *Tag {
    const n = item.link.next.?;
    const p = item.link.prev.?;
    p.link.next = item.link.next;
    n.link.prev = item.link.prev;
    return item;
}

fn demoteTag(queue: *Tag, item: *Tag) void {
    enquebTag(queue, dequeTag(item));
}

fn freetag(n: *Tag) void {
    vsrm(n.key);
    vsrm(n.file);
    vsrm(n.srch);
    vsrm(n.cmnt);
    enquefTag(&tagnodes, n);
}

fn clrtags() void {
    ensureTagSentinels();
    while (!qemptyTags()) {
        freetag(dequeTag(tags.link.next.?));
    }
}

fn addtag(key: [*c]u8, file: [*c]u8, srch: [*c]u8, line: i64, cmnt: [*c]u8) void {
    ensureTagSentinels();
    const n: *Tag = @ptrCast(@alignCast(alitem(@ptrCast(&tagnodes), @sizeOf(Tag)) orelse return));
    n.key = key;
    n.file = file;
    n.srch = srch;
    n.line = line;
    n.cmnt = cmnt;
    n.last = 0;
    enquebTag(&tags, n);
}

fn openTagsFile() struct { f: ?*anyopaque, prefix: [*c]u8 } {
    var f = fopen("tags", "r");
    var prefix: [*c]u8 = null;
    if (f == null) {
        const env = getenv("TAGS");
        if (env != null) f = fopen(env, "r");
        const parents = [_][*:0]const u8{ "../tags", "../../tags", "../../../tags", "../../../../tags", "../../../../../tags" };
        var tagspath: [*c]const u8 = null;
        for (parents) |p| {
            if (f != null) break;
            tagspath = p;
            f = fopen(tagspath, "r");
        }
        if (f != null and tagspath != null) prefix = dirprt(tagspath);
    }
    return .{ .f = f, .prefix = prefix };
}

fn jumpToTag(bw_in: *BwRec, file: [*c]u8, srch: [*c]u8, line: i64, flag: c_int, show_match_msg: bool, last: c_int) c_int {
    var bw = bw_in;
    if (doswitch(@ptrCast(bw.parent), vsncpy(null, 0, file, vsLen(file)), null, null) != 0) return -1;
    if (maint) |screen| {
        if (screen.curwin) |cw| {
            if (cw.object) |obj| bw = @ptrCast(@alignCast(obj));
        }
    }
    const cur = bw.cursor orelse return -1;
    _ = p_goto_bof(cur);
    if (show_match_msg and notagsmenu != 0) {
        if (last != 0) {
            msgnw(@ptrCast(bw.parent), my_gettext("Last match"));
        } else {
            msgnw(@ptrCast(bw.parent), my_gettext("There are more matches"));
        }
    }
    if (srch == null) {
        const omid = opt_mid;
        opt_mid = 1;
        _ = pline(cur, line - 1);
        cur.xcol = piscol(cur);
        dofollows();
        opt_mid = omid;
        if (flag != 0) smode = 2;
        return 0;
    }
    if (flag != 0) smode = 2;
    return dopfnext(bw, mksrch(vsncpy(null, 0, srch, vsLen(srch)), null, 0, 0, -1, 0, 0, 0, 0), null);
}

fn dotagjump(bw: *BwRec, flag: c_int) c_int {
    ensureTagSentinels();
    if (qemptyTags()) {
        msgnw(@ptrCast(bw.parent), my_gettext("Not found"));
        return -1;
    }
    const n = tags.link.next.?;
    const file = n.file;
    const srch = n.srch;
    const line = n.line;
    const last = n.last;
    demoteTag(&tags, n);
    return jumpToTag(bw, file, srch, line, flag, true, last);
}

pub export fn utagjump(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    return dotagjump(bw, 1);
}

fn dotagmenu(m_in: ?*anyopaque, x_in: isize, obj: ?*anyopaque, k: c_int) callconv(.c) c_int {
    _ = obj;
    _ = k;
    ensureTagSentinels();
    const m: *MenuRec = @ptrCast(@alignCast(m_in orelse return -1));
    var x = x_in;
    last_cursor = x;
    var t = tags.link.next.?;
    if (t == &tags) return -1;
    while (x > 0) : (x -= 1) {
        t = t.link.next.?;
        if (t == &tags) return -1;
    }
    const file = t.file;
    const srch = t.srch;
    const line = t.line;
    const parent = m.parent orelse return -1;
    const win = parent.win orelse return -1;
    const bw: *BwRec = @ptrCast(@alignCast(win.object orelse return -1));
    _ = wabort(@ptrCast(parent));
    return jumpToTag(bw, file, srch, line, 1, false, 0);
}

fn dotag(w: ?*anyopaque, s_in: [*c]u8, obj: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = obj;
    const bw = windBw(w) orelse return -1;
    const s = s_in;
    if (notify) |n| n.* = 1;

    var t: [*c]u8 = null;
    if (bw.b) |b| {
        if (b.name) |name_raw| {
            const name: [*c]const u8 = @ptrCast(name_raw);
            t = vsncpy(t, 0, name, zlen(name));
            t = vsncpy(t, vsLen(t), ":", 1);
            t = vsncpy(t, vsLen(t), s, vsLen(s));
        }
    }

    const opened = openTagsFile();
    const f = opened.f;
    const prefix = opened.prefix;
    if (f == null) {
        msgnw(@ptrCast(bw.parent), my_gettext("Couldn't open tags file"));
        vsrm(s);
        vsrm(t);
        return -1;
    }
    defer {
        _ = fclose(f);
        vsrm(prefix);
    }

    clrtags();
    var buf: [512]u8 = undefined;
    var buf1: [512]u8 = undefined;
    while (fgets(&buf, @intCast(buf.len), f) != null) {
        var x: isize = 0;
        while (buf[@intCast(x)] != 0 and buf[@intCast(x)] != ' ' and buf[@intCast(x)] != '\t') : (x += 1) {}
        const c0 = buf[@intCast(x)];
        buf[@intCast(x)] = 0;
        if (zmcmp(&buf, s) == 0 or (t != null and strcmp(t, &buf) == 0)) {
            const key = vsncpy(null, 0, &buf, zlen(&buf));
            buf[@intCast(x)] = c0;
            while (buf[@intCast(x)] == ' ' or buf[@intCast(x)] == '\t') : (x += 1) {}
            var y = x;
            while (buf[@intCast(y)] != 0 and buf[@intCast(y)] != ' ' and buf[@intCast(y)] != '\t' and buf[@intCast(y)] != '\n') : (y += 1) {}
            if (x != y and hack_check(@ptrCast(&buf[@intCast(x)])) == 0) {
                var file: [*c]u8 = null;
                const c1 = buf[@intCast(y)];
                buf[@intCast(y)] = 0;
                if (prefix != null) file = vsncpy(null, 0, prefix, vsLen(prefix));
                file = vsncpy(file, vsLen(file), @ptrCast(&buf[@intCast(x)]), zlen(@ptrCast(&buf[@intCast(x)])));
                buf[@intCast(y)] = c1;
                while (buf[@intCast(y)] == ' ' or buf[@intCast(y)] == '\t') : (y += 1) {}
                x = y;
                while (buf[@intCast(x)] != 0 and buf[@intCast(x)] != '\n') : (x += 1) {}
                buf[@intCast(x)] = 0;
                if (x != y) {
                    if (buf[@intCast(y)] >= '0' and buf[@intCast(y)] <= '9') {
                        const line = ztoo(@ptrCast(&buf[@intCast(y)]));
                        if (line >= 1) {
                            while (buf[@intCast(y)] >= '0' and buf[@intCast(y)] <= '9') : (y += 1) {}
                            while (buf[@intCast(y)] == ' ' or buf[@intCast(y)] == '\t' or
                                buf[@intCast(y)] == ';' or buf[@intCast(y)] == '"' or
                                (buf[@intCast(y)] != 0 and (buf[@intCast(y + 1)] == ' ' or
                                buf[@intCast(y + 1)] == '\t' or
                                buf[@intCast(y + 1)] == '\r' or
                                buf[@intCast(y + 1)] == '\n' or
                                buf[@intCast(y + 1)] == 0))) : (y += 1)
                            {}
                            var q = y + zlen(@ptrCast(&buf[@intCast(y)]));
                            if (q > y and buf[@intCast(q - 1)] == '\n') {
                                buf[@intCast(q - 1)] = 0;
                                q -= 1;
                                if (q > y and buf[@intCast(q - 1)] == '\r') {
                                    buf[@intCast(q - 1)] = 0;
                                    q -= 1;
                                }
                            }
                            const cmnt: [*c]u8 = if (q > y) vsncpy(null, 0, @ptrCast(&buf[@intCast(y)]), q - y) else null;
                            addtag(key, file, null, line, cmnt);
                        } else {
                            vsrm(key);
                            vsrm(file);
                        }
                    } else {
                        var z: isize = 0;
                        if (buf[@intCast(y)] == '/' or buf[@intCast(y)] == '?') {
                            const ch = buf[@intCast(y)];
                            y += 1;
                            x = y + zlen(@ptrCast(&buf[@intCast(y)]));
                            while (x != y) : (x -= 1) {
                                if (buf[@intCast(x)] == ch) break;
                            }
                            if (buf[@intCast(y)] == '^') {
                                buf1[@intCast(z)] = '\\';
                                z += 1;
                                buf1[@intCast(z)] = '^';
                                z += 1;
                                y += 1;
                            }
                            while (buf[@intCast(y)] != 0 and buf[@intCast(y)] != '\n' and !(buf[@intCast(y)] == ch and y == x)) {
                                if (buf[@intCast(y)] == '$' and buf[@intCast(y + 1)] == ch) {
                                    y += 1;
                                    buf1[@intCast(z)] = '\\';
                                    z += 1;
                                    buf1[@intCast(z)] = '$';
                                    z += 1;
                                } else if (buf[@intCast(y)] == '\\' and buf[@intCast(y + 1)] != 0) {
                                    y += 1;
                                    if (buf[@intCast(y)] == '\\') {
                                        buf1[@intCast(z)] = '\\';
                                        z += 1;
                                    }
                                    buf1[@intCast(z)] = buf[@intCast(y)];
                                    z += 1;
                                    y += 1;
                                } else {
                                    buf1[@intCast(z)] = buf[@intCast(y)];
                                    z += 1;
                                    y += 1;
                                }
                            }
                        }
                        if (z != 0) {
                            const srch = vsncpy(null, 0, &buf1, z);
                            if (buf[@intCast(y)] != 0) y += 1;
                            while (buf[@intCast(y)] == ' ' or buf[@intCast(y)] == '\t' or
                                buf[@intCast(y)] == ';' or buf[@intCast(y)] == '"' or
                                (buf[@intCast(y)] != 0 and (buf[@intCast(y + 1)] == ' ' or
                                buf[@intCast(y + 1)] == '\t' or
                                buf[@intCast(y + 1)] == '\r' or
                                buf[@intCast(y + 1)] == '\n' or
                                buf[@intCast(y + 1)] == 0))) : (y += 1)
                            {}
                            var q = y + zlen(@ptrCast(&buf[@intCast(y)]));
                            if (q > y and buf[@intCast(q - 1)] == '\n') {
                                buf[@intCast(q - 1)] = 0;
                                q -= 1;
                                if (q > y and buf[@intCast(q - 1)] == '\r') {
                                    buf[@intCast(q - 1)] = 0;
                                    q -= 1;
                                }
                            }
                            const cmnt: [*c]u8 = if (q > y) vsncpy(null, 0, @ptrCast(&buf[@intCast(y)]), q - y) else null;
                            addtag(key, file, srch, 1, cmnt);
                        } else {
                            vsrm(key);
                            vsrm(file);
                        }
                    }
                } else {
                    vsrm(key);
                    vsrm(file);
                }
            } else {
                vsrm(key);
            }
        }
    }

    vsrm(s);
    vsrm(t);

    if (!qemptyTags()) tags.link.prev.?.last = 1;

    varm(tag_array);
    tag_array = vamk(10);
    var ta = tags.link.next.?;
    while (ta != &tags) : (ta = ta.link.next.?) {
        var tbuf: [1024]u8 = undefined;
        if (ta.srch != null) {
            _ = snprintf(&tbuf, tbuf.len, "%s%s", ta.file, ta.srch);
            if (strstr(&tbuf, "\\^")) |a| {
                a[0] = ':';
                a[1] = '"';
            }
            if (strstr(&tbuf, "\\$")) |a| {
                a[0] = '"';
                a[1] = ' ';
            }
        } else {
            _ = snprintf(&tbuf, tbuf.len, "%s:%lld", ta.file, @as(c_longlong, @intCast(ta.line)));
        }
        tag_array = vaadd(tag_array, vsncpy(null, 0, &tbuf, zlen(&tbuf)));
    }
    last_cursor = 0;
    if (notagsmenu != 0 or aLEN(tag_array) == 1) return dotagjump(bw, notagsmenu);
    if (mkmenu(@ptrCast(bw.parent), @ptrCast(bw.parent), tag_array, &dotagmenu, null, null, 0, @ptrCast(tag_array), null) != null)
        return 0;
    return -1;
}

const StatRec = extern struct {
    st_mtime: c_long = 0,
    _pad: [128]u8 = std.mem.zeroes([128]u8),
};
extern fn fstat(fd: c_int, buf: *StatRec) c_int;

fn getTagList() void {
    const opened = openTagsFile();
    const f = opened.f orelse return;
    // openTagsFile may allocate a prefix for parent tags; discard for word-list path.
    vsrm(opened.prefix);
    defer _ = fclose(f);

    const fd = fileno(f);
    if (fd >= 0) {
        var mystat: StatRec = .{};
        if (fstat(fd, &mystat) == 0) {
            if (last_update == mystat.st_mtime) return;
            last_update = mystat.st_mtime;
        }
    }

    const ht = htmk(256) orelse return;
    defer htrm(ht);
    varm(tag_word_list);
    tag_word_list = null;

    var buf: [512]u8 = undefined;
    var tag: [512]u8 = undefined;
    while (fgets(&buf, @intCast(buf.len), f) != null) {
        var pos: isize = 0;
        var i: isize = 0;
        while (i < @as(isize, @intCast(buf.len))) : (i += 1) {
            if (buf[@intCast(i)] == ' ' or buf[@intCast(i)] == '\t') {
                pos = i;
                break;
            }
        }
        if (pos > 0) {
            _ = zncpy(&tag, &buf, pos);
            tag[@intCast(pos)] = 0;
            if (htfind(ht, &tag) == null) {
                var s = vsncpy(null, 0, &tag, zlen(&tag));
                htadd(ht, s, s);
                tag_word_list = vaadd(tag_word_list, s);
                i = zlen(&tag);
                while (true) {
                    if (tag[@intCast(i)] == ':' and tag[@intCast(i + 1)] == ':') {
                        if (htfind(ht, @ptrCast(&tag[@intCast(i)])) == null) {
                            s = vsncpy(null, 0, @ptrCast(&tag[@intCast(i)]), zlen(@ptrCast(&tag[@intCast(i)])));
                            htadd(ht, s, s);
                            tag_word_list = vaadd(tag_word_list, s);
                        }
                        if (htfind(ht, @ptrCast(&tag[@intCast(i + 2)])) == null) {
                            s = vsncpy(null, 0, @ptrCast(&tag[@intCast(i + 2)]), zlen(@ptrCast(&tag[@intCast(i + 2)])));
                            htadd(ht, s, s);
                            tag_word_list = vaadd(tag_word_list, s);
                        }
                    }
                    if (i == 0) break;
                    i -= 1;
                }
            }
        }
    }
}

fn tagCmplt(bw: ?*anyopaque, k: c_int) callconv(.c) c_int {
    _ = k;
    getTagList();
    if (tag_word_list == null) {
        ttputcBell();
        return 0;
    }
    return simple_cmplt(bw, tag_word_list);
}

pub export fn utag(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    ensureTagSentinels();

    if (smode != 0 and !qemptyTags()) {
        if (notagsmenu != 0) return utagjump(@ptrCast(bw.parent), 0);
        if (mkmenu(@ptrCast(bw.parent), @ptrCast(bw.parent), tag_array, &dotagmenu, null, null, last_cursor, @ptrCast(tag_array), null) != null)
            return 0;
        return -1;
    }

    const pbw = wmkpw(@ptrCast(bw.parent), my_gettext("Tag search: "), &taghist, &dotag, null, null, &tagCmplt, null, null, locale_map, 0);
    if (pbw) |prompt_bw| {
        const b = bw.b orelse return 0;
        const cur = bw.cursor orelse return 0;
        const map = @as(?*anyopaque, @ptrCast(b.o.charmap));
        if (joeIsAlnum(map, brch(cur))) {
            const p = pdup(cur, "utag") orelse return 0;
            const q = pdup(p, "utag") orelse {
                prm(p);
                return 0;
            };
            var c = prgetc(p);
            while (joeIsAlnum(map, c)) : (c = prgetc(p)) {}
            if (c != NO_MORE_DATA) _ = pgetc(p);
            _ = pset(q, p);
            c = pgetc(q);
            while (joeIsAlnum(map, c)) : (c = pgetc(q)) {}
            if (c != NO_MORE_DATA) _ = prgetc(q);
            _ = binsb(prompt_bw.cursor, bcpy(p, q));
            if (prompt_bw.b) |pb| {
                if (pb.eof) |eof| _ = pset(prompt_bw.cursor, eof);
            }
            if (prompt_bw.cursor) |pc| pc.xcol = piscol(pc);
            prm(p);
            prm(q);
        }
        return 0;
    }
    return -1;
}
