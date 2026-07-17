//! Window system — replaces `joe/w.c`.
//!
//! Faithful C-ABI port of JOE's window tree, wfit, create/abort, and
//! message helpers. Generated from a goto-free rewrite of w.c via
//! `zig translate-c`, then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;


pub const FITMIN: c_int = 2;
pub const FITHEIGHT: c_int = 4;
pub const JOE_MSGBUFSIZE: c_int = 300;
pub const TYPETW: c_int = 0x0100;
pub const TYPEPW: c_int = 0x0200;
pub const TYPEMENU: c_int = 0x0800;
pub const TYPEQW: c_int = 0x1000;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub const off_t = i64;
pub const FILE = anyopaque;
pub extern var ITEM: ?*anyopaque;
pub extern var QUEUE: ?*anyopaque;
pub extern var LAST: ?*anyopaque;
pub const struct_b = opaque {
};
pub const B = struct_b;
pub const struct_kbd = extern struct {
    _pad: [88]u8 = std.mem.zeroes([88]u8),
};
pub const KBD = struct_kbd;
pub const struct_kmap = opaque {
};
pub const KMAP = struct_kmap;
pub const struct_bstack = opaque {};
pub const W = struct_window;
const struct_unnamed_1 = extern struct {
    next: [*c]W = null,
    prev: [*c]W = null,
};
pub const struct_scrn = extern struct {
    _pad0: [8]u8 = std.mem.zeroes([8]u8),
    li: ptrdiff_t = 0,
    co: ptrdiff_t = 0,
    _pad1: [760]u8 = std.mem.zeroes([760]u8),
    updtab: [*c]c_int = null,
    _pad2: [48]u8 = std.mem.zeroes([48]u8),
};
pub const SCRN = struct_scrn;
pub const struct_screen = extern struct {
    t: [*c]SCRN = null,
    wind: ptrdiff_t = 0,
    topwin: [*c]W = null,
    curwin: [*c]W = null,
    w: ptrdiff_t = 0,
    h: ptrdiff_t = 0,
};
pub const Screen = struct_screen;
pub const struct_watom = extern struct {
    context: [*c]const u8 = null,
    disp: ?*const fn (w: [*c]W, flg: c_int) callconv(.c) void = null,
    follow: ?*const fn (w: [*c]W) callconv(.c) void = null,
    abort: ?*const fn (w: [*c]W) callconv(.c) c_int = null,
    rtn: ?*const fn (w: [*c]W) callconv(.c) c_int = null,
    type: ?*const fn (w: [*c]W, k: c_int) callconv(.c) c_int = null,
    resize: ?*const fn (w: [*c]W, width: ptrdiff_t, height: ptrdiff_t) callconv(.c) void = null,
    move: ?*const fn (w: [*c]W, x: ptrdiff_t, y: ptrdiff_t) callconv(.c) void = null,
    ins: ?*const fn (w: [*c]W, b: ?*B, l: off_t, n: off_t, flg: c_int) callconv(.c) void = null,
    del: ?*const fn (w: [*c]W, b: ?*B, l: off_t, n: off_t, flg: c_int) callconv(.c) void = null,
    what: c_int = 0,
};
pub const WATOM = struct_watom;
pub const struct_window = extern struct {
    link: struct_unnamed_1 = std.mem.zeroes(struct_unnamed_1),
    t: [*c]Screen = null,
    x: ptrdiff_t = 0,
    y: ptrdiff_t = 0,
    w: ptrdiff_t = 0,
    h: ptrdiff_t = 0,
    ny: ptrdiff_t = 0,
    nh: ptrdiff_t = 0,
    reqh: ptrdiff_t = 0,
    fixed: ptrdiff_t = 0,
    hh: ptrdiff_t = 0,
    win: [*c]W = null,
    main: [*c]W = null,
    orgwin: [*c]W = null,
    curx: ptrdiff_t = 0,
    cury: ptrdiff_t = 0,
    kbd: [*c]KBD = null,
    watom: [*c]const WATOM = null,
    object: ?*anyopaque = null,
    msgt: [*c]const u8 = null,
    msgb: [*c]const u8 = null,
    huh: [*c]const u8 = null,
    notify: [*c]c_int = null,
    bstack: ?*struct_bstack = null,
};
pub const struct_bw = extern struct {
    parent: [*c]W = null,
    b: ?*B = null,
    _pad: [472]u8 = std.mem.zeroes([472]u8),
};
pub const BW = struct_bw;
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn msetI(d: ?*anyopaque, c: c_int, sz: ptrdiff_t) ?*anyopaque;
pub extern fn diff_min(a: ptrdiff_t, b: ptrdiff_t) ptrdiff_t;
pub extern fn nscrldn(t: [*c]SCRN, top: ptrdiff_t, bot: ptrdiff_t, amnt: ptrdiff_t) void;
pub extern fn nscrlup(t: [*c]SCRN, top: ptrdiff_t, bot: ptrdiff_t, amnt: ptrdiff_t) void;
pub extern fn nredraw(t: [*c]SCRN) void;
pub extern fn fmtlen(s: [*c]const u8) ptrdiff_t;
pub extern fn genfmt(t: [*c]SCRN, x: ptrdiff_t, y: ptrdiff_t, ofst: ptrdiff_t, s: [*c]const u8, flg: c_int, trunc: c_int, atr: c_int) void;
pub extern fn mkkbd(kmap: ?*KMAP) [*c]KBD;
pub extern fn rmkbd(k: [*c]KBD) void;
pub extern fn kmap_getcontext(name: [*c]const u8) ?*KMAP;
pub extern fn windie(w: [*c]W) void;
pub extern fn usplitw(w: [*c]W, k: c_int) c_int;
pub extern fn get_buffer_in_window(bw: [*c]BW, b: ?*B) c_int;
pub extern fn bfind(s: [*c]const u8) ?*B;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern var skiptop: c_int;
pub extern var dostaupd: c_int;
pub extern var leave: c_int;
pub extern var maint: [*c]Screen;
pub extern var staen: c_int;
pub extern var watomtw: WATOM;
pub extern var errbuf: ?*B;
pub export fn wfit(arg_t: [*c]Screen) void {
    var t = arg_t;
    _ = &t;
    var y: ptrdiff_t = undefined;
    _ = &y;
    var left: ptrdiff_t = undefined;
    _ = &left;
    var w: [*c]W = undefined;
    _ = &w;
    var pw: [*c]W = undefined;
    _ = &pw;
    var req: ptrdiff_t = undefined;
    _ = &req;
    var adj: ptrdiff_t = undefined;
    _ = &adj;
    var flg: c_int = undefined;
    _ = &flg;
    var ret: c_int = undefined;
    _ = &ret;
    dostaupd = 1;
    while (true) {
        flg = 0;
        y = t.*.wind;
        left = t.*.h - y;
        pw = null;
        w = t.*.topwin;
        while (true) {
            w.*.ny = -@as(c_int, 1);
            w.*.nh = geth(w);
            w = w.*.link.next;
            if (!(w != t.*.topwin)) break;
        }
        w = t.*.topwin;
        while (true) {
            req = getgrouph(w);
            if (req > left) {
                adj = req - left;
            } else {
                adj = 0;
            }
            while (true) {
                w.*.ny = y;
                if (!(w.*.win != null)) {
                    pw = w;
                    w.*.nh -= adj;
                }
                if (!(w.*.win != null) and ((w.*.nh < @as(ptrdiff_t, 0)) or ((w == t.*.curwin) and (w.*.nh < @as(ptrdiff_t, 1))))) while (((w.*.nh < @as(ptrdiff_t, 0)) or ((w == t.*.curwin) and (w.*.nh < @as(ptrdiff_t, 1)))) and (w.*.link.next.*.win != null)) {
                    w.*.nh += doabort(w.*.link.next, &ret);
                };
                if (w == t.*.curwin) {
                    flg = 1;
                }
                y += w.*.nh;
                left -= w.*.nh;
                w = w.*.link.next;
                if (!((w != t.*.topwin) and (w.*.main == w.*.link.prev.*.main))) break;
            }
            if (!((w != t.*.topwin) and (left >= @as(ptrdiff_t, FITHEIGHT)))) break;
        }
        pw.*.nh += left;
        while ((blk: {
            const tmp = pw.*.link.next;
            pw = tmp;
            break :blk tmp;
        }) != w) {
            pw.*.ny += left;
        }
        if (!(flg != 0)) {
            t.*.topwin = findbotw(t.*.topwin).*.link.next;
            continue;
        }
        break;
    }
    w = t.*.topwin;
    while (true) {
        if ((w.*.y >= @as(ptrdiff_t, 0)) and (w.*.ny >= @as(ptrdiff_t, 0))) if (w.*.ny > w.*.y) {
            var l: [*c]W = blk: {
                const tmp = w;
                pw = tmp;
                break :blk tmp;
            };
            _ = &l;
            while ((pw.*.link.next != t.*.topwin) and (((pw.*.link.next.*.y < @as(ptrdiff_t, 0)) or (pw.*.link.next.*.ny < @as(ptrdiff_t, 0))) or (pw.*.link.next.*.ny > pw.*.link.next.*.y))) {
                pw = pw.*.link.next;
                if ((pw.*.ny >= @as(ptrdiff_t, 0)) and (pw.*.y >= @as(ptrdiff_t, 0))) {
                    l = pw;
                }
            }
            while (true) {
                if ((l.*.ny >= @as(ptrdiff_t, 0)) and (l.*.y >= @as(ptrdiff_t, 0))) {
                    nscrldn(t.*.t, l.*.y, l.*.ny + diff_min(l.*.h, l.*.nh), l.*.ny - l.*.y);
                }
                if (w == l) break;
                l = l.*.link.prev;
            }
            w = pw.*.link.next;
        } else if (w.*.ny < w.*.y) {
            var l: [*c]W = blk: {
                const tmp = w;
                pw = tmp;
                break :blk tmp;
            };
            _ = &l;
            while ((pw.*.link.next != t.*.topwin) and (((pw.*.link.next.*.y < @as(ptrdiff_t, 0)) or (pw.*.link.next.*.ny < @as(ptrdiff_t, 0))) or (pw.*.link.next.*.ny < pw.*.link.next.*.y))) {
                pw = pw.*.link.next;
                if ((pw.*.ny >= @as(ptrdiff_t, 0)) and (pw.*.y >= @as(ptrdiff_t, 0))) {
                    l = pw;
                }
            }
            while (true) {
                if ((w.*.ny >= @as(ptrdiff_t, 0)) and (w.*.y >= @as(ptrdiff_t, 0))) {
                    nscrlup(t.*.t, w.*.ny, w.*.y + diff_min(w.*.h, w.*.nh), w.*.y - w.*.ny);
                }
                if (w == l) break;
                w = w.*.link.next;
            }
            w = pw.*.link.next;
        } else {
            w = w.*.link.next;
        } else {
            w = w.*.link.next;
        }
        if (!(w != t.*.topwin)) break;
    }
    w = t.*.topwin;
    while (true) {
        if (w.*.ny >= @as(ptrdiff_t, 0)) {
            if (w.*.y == @as(ptrdiff_t, -@as(c_int, 1))) {
                _ = msetI(@ptrCast(@alignCast(t.*.t.*.updtab + @as(usize, @bitCast(@as(isize, @intCast(w.*.ny)))))), 1, w.*.nh);
            }
            w.*.y = w.*.ny;
        } else {
            w.*.y = -@as(c_int, 1);
        }
        w.*.h = w.*.nh;
        w.*.reqh = 0;
        w = w.*.link.next;
        if (!(w != t.*.topwin)) break;
    }
    w = t.*.topwin;
    while (true) {
        if (w.*.y >= @as(ptrdiff_t, 0)) {
            if (w.*.object != null) {
                if (w.*.watom.*.move != null) {
                    w.*.watom.*.move.?(w, w.*.x, w.*.y);
                }
                if (w.*.watom.*.resize != null) {
                    w.*.watom.*.resize.?(w, w.*.w, w.*.h);
                }
            }
        }
        w = w.*.link.next;
        if (!(w != t.*.topwin)) break;
    }
}
pub export fn updall() void {
    var y: c_int = undefined;
    _ = &y;
    {
        y = 0;
        while (@as(ptrdiff_t, y) != scr.*.h) : (y += 1) {
            scr.*.t.*.updtab[@bitCast(@as(isize, @intCast(y)))] = 1;
        }
    }
}
pub export fn wshrink(arg_w: [*c]W) c_int {
    var w = arg_w;
    _ = &w;
    var nextw: [*c]W = undefined;
    _ = &nextw;
    if (((w.*.link.next == w.*.t.*.topwin) or (w.*.link.next.*.y == @as(ptrdiff_t, -@as(c_int, 1)))) and (w != w.*.t.*.topwin)) return wgrow(w.*.link.prev.*.main);
    if (w.*.h <= @as(ptrdiff_t, FITHEIGHT)) return -@as(c_int, 1);
    {
        nextw = w.*.link.next;
        while ((@as(ptrdiff_t, @intFromBool(nextw != w.*.t.*.topwin)) != 0) and (nextw.*.fixed != 0)) : (nextw = nextw.*.link.next) {}
    }
    if (nextw == w.*.t.*.topwin) return -@as(c_int, 1);
    seth(w, w.*.h - @as(ptrdiff_t, 1));
    seth(nextw, nextw.*.h + @as(ptrdiff_t, 1));
    wfit(w.*.t);
    return 0;
}
pub export fn wgrow(arg_w: [*c]W) c_int {
    var w = arg_w;
    _ = &w;
    var nextw: [*c]W = undefined;
    _ = &nextw;
    if (((w.*.link.next == w.*.t.*.topwin) or (w.*.link.next.*.y == @as(ptrdiff_t, -@as(c_int, 1)))) and (w != w.*.t.*.topwin)) return wshrink(w.*.link.prev.*.main);
    {
        nextw = w.*.link.next;
        while ((nextw.*.fixed != 0) and (@as(ptrdiff_t, @intFromBool(nextw != w.*.t.*.topwin)) != 0)) : (nextw = nextw.*.link.next) {}
    }
    if (((nextw == w.*.t.*.topwin) or (nextw.*.y == @as(ptrdiff_t, -@as(c_int, 1)))) or (nextw.*.h <= @as(ptrdiff_t, FITHEIGHT))) return -@as(c_int, 1);
    seth(w, w.*.h + @as(ptrdiff_t, 1));
    seth(nextw, nextw.*.h - @as(ptrdiff_t, 1));
    wfit(w.*.t);
    return 0;
}
pub fn geth(arg_w: [*c]W) callconv(.c) ptrdiff_t {
    var w = arg_w;
    _ = &w;
    if (w.*.reqh != 0) {
        if ((w.*.win != null) and (w.*.reqh < @as(ptrdiff_t, 1))) return 1;
        if (!(w.*.win != null) and (w.*.reqh < @as(ptrdiff_t, FITMIN))) return FITMIN;
        return w.*.reqh;
    } else if (w.*.fixed != 0) return w.*.fixed else {
        var h: ptrdiff_t = @divTrunc((w.*.t.*.h - w.*.t.*.wind) * w.*.hh, @as(c_long, 1000));
        _ = &h;
        if (h < @as(ptrdiff_t, FITMIN)) {
            h = FITMIN;
        }
        return h;
    }
}
pub fn seth(arg_w: [*c]W, arg_h: ptrdiff_t) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var h = arg_h;
    _ = &h;
    var tmp: c_long = undefined;
    _ = &tmp;
    w.*.reqh = h;
    tmp = @as(c_long, 1000) * h;
    w.*.hh = @divTrunc(tmp, w.*.t.*.h - w.*.t.*.wind) + @as(c_long, if (@rem(tmp, w.*.t.*.h - w.*.t.*.wind) != 0) @as(c_int, 1) else @as(c_int, 0));
}
pub fn getminh(arg_w: [*c]W) callconv(.c) ptrdiff_t {
    var w = arg_w;
    _ = &w;
    var x: [*c]W = undefined;
    _ = &x;
    var h: ptrdiff_t = undefined;
    _ = &h;
    x = findtopw(w);
    {
        w = x;
        h = getminhthis(w);
        while ((w.*.link.next != x) and (w.*.link.next.*.main == x.*.main)) {
            w = w.*.link.next;
            h += getminhthis(w);
        }
    }
    return h;
}
pub fn wspread(arg_t: [*c]Screen) callconv(.c) void {
    var t = arg_t;
    _ = &t;
    var n: ptrdiff_t = 0;
    _ = &n;
    var w: [*c]W = t.*.topwin;
    _ = &w;
    while (true) {
        if ((w.*.y >= @as(ptrdiff_t, 0)) and !(w.*.win != null)) {
            n += 1;
        }
        w = w.*.link.next;
        if (!(w != t.*.topwin)) break;
    }
    if (!(n != 0)) {
        wfit(t);
        return;
    }
    if (@divTrunc(t.*.h - t.*.wind, n) >= @as(ptrdiff_t, FITHEIGHT)) {
        n = @divTrunc(t.*.h - t.*.wind, n);
    } else {
        n = FITHEIGHT;
    }
    w = t.*.topwin;
    while (true) {
        if (!(w.*.win != null)) {
            var h: ptrdiff_t = getminh(w);
            _ = &h;
            if (h >= n) {
                seth(w, FITMIN);
            } else {
                seth(w, n - (h - @as(ptrdiff_t, FITMIN)));
            }
            w.*.orgwin = null;
        }
        w = w.*.link.next;
        if (!(w != t.*.topwin)) break;
    }
    wfit(t);
}
pub export fn countmain(arg_t: [*c]Screen) c_int {
    var t = arg_t;
    _ = &t;
    var nmain: c_int = 1;
    _ = &nmain;
    var m: [*c]W = t.*.curwin.*.main;
    _ = &m;
    var q: [*c]W = undefined;
    _ = &q;
    {
        q = t.*.curwin.*.link.next;
        while (q != t.*.curwin) : (q = q.*.link.next) if (q.*.main != m) {
            nmain += 1;
            m = q.*.main;
        };
    }
    return nmain;
}
pub export fn wredraw(arg_w: [*c]W) void {
    var w = arg_w;
    _ = &w;
    _ = msetI(@ptrCast(@alignCast(w.*.t.*.t.*.updtab + @as(usize, @bitCast(@as(isize, @intCast(w.*.y)))))), 1, w.*.h);
}
pub export fn findtopw(arg_w: [*c]W) [*c]W {
    var w = arg_w;
    _ = &w;
    var x: [*c]W = undefined;
    _ = &x;
    {
        x = w;
        while ((x.*.link.prev.*.main == w.*.main) and (x.*.link.prev != w)) : (x = x.*.link.prev) {}
    }
    return x;
}
pub export fn getgrouph(arg_w: [*c]W) ptrdiff_t {
    var w = arg_w;
    _ = &w;
    var x: [*c]W = undefined;
    _ = &x;
    var h: ptrdiff_t = undefined;
    _ = &h;
    x = findtopw(w);
    {
        w = x;
        h = geth(w);
        while ((w.*.link.next != x) and (w.*.link.next.*.main == x.*.main)) {
            w = w.*.link.next;
            h += geth(w);
        }
    }
    return h;
}
pub fn getminhthis(arg_w: [*c]W) callconv(.c) ptrdiff_t {
    var w = arg_w;
    _ = &w;
    if (w.*.fixed != 0) return w.*.fixed;
    if (w.*.win != null) return 1;
    return FITMIN;
}
pub export fn findbotw(arg_w: [*c]W) [*c]W {
    var w = arg_w;
    _ = &w;
    var x: [*c]W = undefined;
    _ = &x;
    {
        x = w;
        while ((x.*.link.next.*.main == w.*.main) and (x.*.link.next != w)) : (x = x.*.link.next) {}
    }
    return x;
}
pub export fn demotegroup(arg_w: [*c]W) c_int {
    var w = arg_w;
    _ = &w;
    var top: [*c]W = findtopw(w);
    _ = &top;
    var bot: [*c]W = findbotw(w);
    _ = &bot;
    var next: [*c]W = undefined;
    _ = &next;
    var flg: c_int = 0;
    _ = &flg;
    {
        w = top;
        while (w != bot) : (w = next) {
            next = w.*.link.next;
            if (w == w.*.t.*.topwin) {
                flg = 1;
                w.*.t.*.topwin = next;
            } else while (true) {
                ITEM = @ptrCast(@alignCast(blk: {
                    ITEM = @ptrCast(@alignCast(w));
                    @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.prev.*.link.next = @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.next;
                    @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.next.*.link.prev = @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.prev;
                    break :blk ITEM;
                }));
                QUEUE = @ptrCast(@alignCast(w.*.t.*.topwin));
                @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.next = @ptrCast(@alignCast(QUEUE));
                @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.prev = @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.prev;
                @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.prev.*.link.next = @ptrCast(@alignCast(ITEM));
                @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.prev = @ptrCast(@alignCast(ITEM));
                if (!false) break;
            }
            w.*.y = -@as(c_int, 1);
        }
    }
    if (w == w.*.t.*.topwin) {
        flg = 1;
    } else while (true) {
        ITEM = @ptrCast(@alignCast(blk: {
            ITEM = @ptrCast(@alignCast(w));
            @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.prev.*.link.next = @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.next;
            @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.next.*.link.prev = @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.prev;
            break :blk ITEM;
        }));
        QUEUE = @ptrCast(@alignCast(w.*.t.*.topwin));
        @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.next = @ptrCast(@alignCast(QUEUE));
        @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.prev = @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.prev;
        @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.prev.*.link.next = @ptrCast(@alignCast(ITEM));
        @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.prev = @ptrCast(@alignCast(ITEM));
        if (!false) break;
    }
    w.*.y = -@as(c_int, 1);
    return flg;
}
pub export fn lastw(arg_t: [*c]Screen) [*c]W {
    var t = arg_t;
    _ = &t;
    var x: [*c]W = undefined;
    _ = &x;
    {
        x = t.*.topwin;
        while ((x.*.link.next != t.*.topwin) and (x.*.link.next.*.y >= @as(ptrdiff_t, 0))) : (x = x.*.link.next) {}
    }
    return x;
}
pub export var scr: [*c]Screen = null;
pub export fn screate(arg_scrn_1: [*c]SCRN) [*c]Screen {
    var scrn_1 = arg_scrn_1;
    _ = &scrn_1;
    var t: [*c]Screen = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(Screen))))))));
    _ = &t;
    t.*.t = scrn_1;
    t.*.w = scrn_1.*.co;
    t.*.h = scrn_1.*.li;
    t.*.topwin = null;
    t.*.curwin = null;
    t.*.wind = skiptop;
    scr = t;
    return t;
}
pub export fn sresize(arg_t: [*c]Screen) void {
    var t = arg_t;
    _ = &t;
    var scrn_1: [*c]SCRN = t.*.t;
    _ = &scrn_1;
    var w: [*c]W = undefined;
    _ = &w;
    t.*.w = scrn_1.*.co;
    t.*.h = scrn_1.*.li;
    if ((t.*.h - t.*.wind) < @as(ptrdiff_t, FITMIN)) {
        t.*.wind = t.*.h - @as(ptrdiff_t, FITMIN);
    }
    if (t.*.wind < @as(ptrdiff_t, skiptop)) {
        t.*.wind = skiptop;
    }
    w = t.*.topwin;
    while (true) {
        w.*.y = -@as(c_int, 1);
        w.*.w = t.*.w;
        w = w.*.link.next;
        if (!(w != t.*.topwin)) break;
    }
    wfit(t);
    updall();
}
pub export fn scrins(arg_b_1: ?*B, arg_l: off_t, arg_n: off_t, arg_flg: c_int) void {
    var b_1 = arg_b_1;
    _ = &b_1;
    var l = arg_l;
    _ = &l;
    var n = arg_n;
    _ = &n;
    var flg = arg_flg;
    _ = &flg;
    var w: [*c]W = undefined;
    _ = &w;
    if ((scr != null) and (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = scr.*.topwin;
        w = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null))) {
        while (true) {
            if (w.*.y >= @as(ptrdiff_t, 0)) {
                if ((w.*.object != null) and (w.*.watom.*.ins != null)) {
                    w.*.watom.*.ins.?(w, b_1, l, n, flg);
                }
            }
            w = w.*.link.next;
            if (!(w != scr.*.topwin)) break;
        }
    }
}
pub export fn scrdel(arg_b_1: ?*B, arg_l: off_t, arg_n: off_t, arg_flg: c_int) void {
    var b_1 = arg_b_1;
    _ = &b_1;
    var l = arg_l;
    _ = &l;
    var n = arg_n;
    _ = &n;
    var flg = arg_flg;
    _ = &flg;
    var w: [*c]W = undefined;
    _ = &w;
    if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = scr.*.topwin;
        w = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        while (true) {
            if (w.*.y >= @as(ptrdiff_t, 0)) {
                if ((w.*.object != null) and (w.*.watom.*.del != null)) {
                    w.*.watom.*.del.?(w, b_1, l, n, flg);
                }
            }
            w = w.*.link.next;
            if (!(w != scr.*.topwin)) break;
        }
    }
}
pub export fn watpos(arg_t: [*c]Screen, arg_x: ptrdiff_t, arg_y: ptrdiff_t) [*c]W {
    var t = arg_t;
    _ = &t;
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    var w: [*c]W = t.*.topwin;
    _ = &w;
    while (true) {
        if (((((w.*.y >= @as(ptrdiff_t, 0)) and (w.*.y <= y)) and ((w.*.y + w.*.h) > y)) and (w.*.x <= x)) and ((w.*.x + w.*.w) > x)) return w;
        if (!((blk: {
            w = w.*.link.next;
            break :blk @intFromBool(w != t.*.topwin);
        }) != 0)) break;
    }
    return null;
}
pub fn doabort(arg_w: [*c]W, arg_ret: [*c]c_int) callconv(.c) ptrdiff_t {
    var w = arg_w;
    _ = &w;
    var ret = arg_ret;
    _ = &ret;
    var amnt: ptrdiff_t = geth(w);
    _ = &amnt;
    var z: [*c]W = undefined;
    _ = &z;
    var again: c_int = undefined;
    _ = &again;
    w.*.y = -@as(c_int, 2);
    if (w.*.t.*.topwin == w) {
        w.*.t.*.topwin = w.*.link.next;
    }
    while (true) {
        again = 0;
        z = w.*.t.*.topwin;
        while (true) {
            if (z.*.orgwin == w) {
                z.*.orgwin = null;
            }
            if (((z.*.win == w) or (z.*.main == w)) and (z.*.y != @as(ptrdiff_t, -@as(c_int, 2)))) {
                amnt += doabort(z, ret);
                again = 1;
                break;
            }
            if (!((blk: {
                z = z.*.link.next;
                break :blk @intFromBool(z != w.*.t.*.topwin);
            }) != 0)) break;
        }
        if (!(again != 0)) break;
    }
    if (w.*.orgwin != null) {
        seth(w.*.orgwin, geth(w.*.orgwin) + geth(w));
    }
    if (w.*.t.*.curwin == w) {
        if (w.*.t.*.curwin.*.win != null) {
            w.*.t.*.curwin = w.*.t.*.curwin.*.win;
        } else if (w.*.orgwin != null) {
            w.*.t.*.curwin = w.*.orgwin;
        } else {
            w.*.t.*.curwin = w.*.link.next;
        }
    }
    if ((blk: {
        QUEUE = @ptrCast(@alignCast(w));
        break :blk @intFromBool(@as([*c]W, @ptrCast(@alignCast(QUEUE))) == @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.next);
    }) != 0) {
        leave = 1;
        amnt = 0;
    }
    while (true) {
        ITEM = @ptrCast(@alignCast(w));
        @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.prev.*.link.next = @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.next;
        @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.next.*.link.prev = @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.prev;
        if (!false) break;
    }
    if ((w.*.watom.*.abort != null) and (w.*.object != null)) {
        ret.* = w.*.watom.*.abort.?(w);
        if (w.*.notify != null) {
            w.*.notify.* = -@as(c_int, 1);
        }
    } else {
        ret.* = -@as(c_int, 1);
        if (w.*.notify != null) {
            w.*.notify.* = 1;
        }
    }
    rmkbd(w.*.kbd);
    windie(w);
    joe_free(@ptrCast(@alignCast(w)));
    return amnt;
}
pub export fn wnext(arg_t: [*c]Screen) c_int {
    var t = arg_t;
    _ = &t;
    if (t.*.curwin.*.link.next != t.*.curwin) {
        t.*.curwin = t.*.curwin.*.link.next;
        if (t.*.curwin.*.y == @as(ptrdiff_t, -@as(c_int, 1))) {
            wfit(t);
        }
        return 0;
    } else return -@as(c_int, 1);
}
pub export fn wprev(arg_t: [*c]Screen) c_int {
    var t = arg_t;
    _ = &t;
    if (t.*.curwin.*.link.prev != t.*.curwin) {
        t.*.curwin = t.*.curwin.*.link.prev;
        if (t.*.curwin.*.y == @as(ptrdiff_t, -@as(c_int, 1))) {
            t.*.topwin = findtopw(t.*.curwin);
            wfit(t);
        }
        return 0;
    } else return -@as(c_int, 1);
}
pub export fn wgrowup(arg_w: [*c]W) c_int {
    var w = arg_w;
    _ = &w;
    return wshrink(w.*.link.prev.*.main);
}
pub export fn wgrowdown(arg_w: [*c]W) c_int {
    var w = arg_w;
    _ = &w;
    return wgrow(w.*.link.prev.*.main);
}
pub export fn wshowall(arg_t: [*c]Screen) void {
    var t = arg_t;
    _ = &t;
    var n: ptrdiff_t = 0;
    _ = &n;
    var set: ptrdiff_t = undefined;
    _ = &set;
    var w: [*c]W = undefined;
    _ = &w;
    w = t.*.topwin;
    while (true) {
        if (!(w.*.win != null)) {
            n += 1;
        }
        w = w.*.link.next;
        if (!(w != t.*.topwin)) break;
    }
    if ((blk: {
        const tmp = @divTrunc(t.*.h - t.*.wind, n);
        set = tmp;
        break :blk tmp;
    }) < @as(ptrdiff_t, FITHEIGHT)) {
        set = FITHEIGHT;
    }
    w = t.*.topwin;
    while (true) {
        if (!(w.*.win != null)) {
            var h: ptrdiff_t = getminh(w);
            _ = &h;
            if (h >= set) {
                seth(w, FITMIN);
            } else {
                seth(w, set - (h - @as(ptrdiff_t, FITMIN)));
            }
            w.*.orgwin = null;
        }
        w = w.*.link.next;
        if (!(w != t.*.topwin)) break;
    }
    wfit(t);
}
pub export fn wshowone(arg_w: [*c]W) void {
    var w = arg_w;
    _ = &w;
    var q: [*c]W = w.*.t.*.topwin;
    _ = &q;
    while (true) {
        if (!(q.*.win != null)) {
            seth(q, (w.*.t.*.h - w.*.t.*.wind) - (getminh(q) - @as(ptrdiff_t, FITMIN)));
            q.*.orgwin = null;
        }
        q = q.*.link.next;
        if (!(q != w.*.t.*.topwin)) break;
    }
    wfit(w.*.t);
}
pub export fn wcreate(arg_t: [*c]Screen, arg_watom_1: [*c]const WATOM, arg_where: [*c]W, arg_target: [*c]W, arg_original: [*c]W, arg_height: ptrdiff_t, arg_huh: [*c]const u8, arg_notify: [*c]c_int) [*c]W {
    var t = arg_t;
    _ = &t;
    var watom_1 = arg_watom_1;
    _ = &watom_1;
    var where = arg_where;
    _ = &where;
    var target = arg_target;
    _ = &target;
    var original = arg_original;
    _ = &original;
    var height = arg_height;
    _ = &height;
    var huh = arg_huh;
    _ = &huh;
    var notify = arg_notify;
    _ = &notify;
    var neww: [*c]W = undefined;
    _ = &neww;
    if (height < @as(ptrdiff_t, 1)) return null;
    neww = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(W))))))));
    neww.*.notify = notify;
    neww.*.t = t;
    neww.*.w = t.*.w;
    seth(neww, height);
    neww.*.h = neww.*.reqh;
    neww.*.y = -@as(c_int, 1);
    neww.*.ny = 0;
    neww.*.nh = 0;
    neww.*.x = 0;
    neww.*.huh = huh;
    neww.*.orgwin = original;
    neww.*.watom = watom_1;
    neww.*.object = null;
    neww.*.msgb = null;
    neww.*.msgt = null;
    neww.*.bstack = null;
    if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = target;
        neww.*.win = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        neww.*.main = target.*.main;
        neww.*.fixed = height;
    } else {
        neww.*.main = neww;
        neww.*.fixed = 0;
    }
    if (original != null) {
        if ((original.*.h - height) < @as(ptrdiff_t, 0)) {
            joe_free(@ptrCast(@alignCast(neww)));
            return null;
        } else {
            seth(original, original.*.h - height);
        }
    }
    if (watom_1.*.context != null) {
        neww.*.kbd = mkkbd(kmap_getcontext(watom_1.*.context));
    } else {
        neww.*.kbd = null;
    }
    if (where != null) {
        while (true) {
            ITEM = @ptrCast(@alignCast(neww));
            QUEUE = @ptrCast(@alignCast(where));
            @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.next = @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.next;
            @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.prev = @ptrCast(@alignCast(QUEUE));
            @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.next.*.link.prev = @ptrCast(@alignCast(ITEM));
            @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.next = @ptrCast(@alignCast(ITEM));
            if (!false) break;
        }
    } else {
        if (t.*.topwin != null) {
            while (true) {
                ITEM = @ptrCast(@alignCast(neww));
                QUEUE = @ptrCast(@alignCast(t.*.topwin));
                @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.next = @ptrCast(@alignCast(QUEUE));
                @as([*c]W, @ptrCast(@alignCast(ITEM))).*.link.prev = @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.prev;
                @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.prev.*.link.next = @ptrCast(@alignCast(ITEM));
                @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.prev = @ptrCast(@alignCast(ITEM));
                if (!false) break;
            }
        } else {
            while (true) {
                QUEUE = @ptrCast(@alignCast(neww));
                @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.prev = @ptrCast(@alignCast(QUEUE));
                @as([*c]W, @ptrCast(@alignCast(QUEUE))).*.link.next = @ptrCast(@alignCast(QUEUE));
                if (!false) break;
            }
            t.*.curwin = blk: {
                const tmp = neww;
                t.*.topwin = tmp;
                break :blk tmp;
            };
        }
    }
    return neww;
}
pub export fn wabort(arg_w: [*c]W) c_int {
    var w = arg_w;
    _ = &w;
    var t: [*c]Screen = w.*.t;
    _ = &t;
    var ret: c_int = undefined;
    _ = &ret;
    if (w != w.*.main) {
        _ = doabort(w, &ret);
        if (!(leave != 0)) {
            wfit(t);
        }
    } else {
        var msgt: [*c]const u8 = w.*.msgt;
        _ = &msgt;
        var msgb: [*c]const u8 = w.*.msgb;
        _ = &msgb;
        _ = doabort(w, &ret);
        if (!(leave != 0)) {
            if (lastw(t).*.link.next != t.*.topwin) {
                wfit(t);
            } else {
                wspread(t);
            }
            if ((msgt != null) and !(maint.*.curwin.*.msgt != null)) {
                maint.*.curwin.*.msgt = msgt;
            }
            if ((msgb != null) and !(maint.*.curwin.*.msgb != null)) {
                maint.*.curwin.*.msgb = msgb;
            }
        }
    }
    return ret;
}
pub export var bg_msg: c_int = 0;
pub fn mdisp(arg_t: [*c]SCRN, arg_y: ptrdiff_t, arg_s: [*c]const u8) callconv(.c) void {
    var t = arg_t;
    _ = &t;
    var y = arg_y;
    _ = &y;
    var s = arg_s;
    _ = &s;
    var ofst: ptrdiff_t = undefined;
    _ = &ofst;
    var len: ptrdiff_t = undefined;
    _ = &len;
    len = fmtlen(s);
    if (len <= t.*.co) {
        ofst = 0;
    } else {
        ofst = len - t.*.co;
    }
    genfmt(t, 0, y, ofst, s, bg_msg, 0, 1);
    t.*.updtab[@bitCast(@as(isize, @intCast(y)))] = 1;
}
pub export fn msgout(arg_w: [*c]W) void {
    var w = arg_w;
    _ = &w;
    var t: [*c]SCRN = w.*.t.*.t;
    _ = &t;
    if ((w.*.msgb != null) and (w.*.h != 0)) {
        mdisp(t, (w.*.y + w.*.h) - @as(ptrdiff_t, 1), w.*.msgb);
    }
    if ((w.*.msgt != null) and (w.*.h != 0)) {
        mdisp(t, w.*.y + @as(ptrdiff_t, if ((w.*.h > @as(ptrdiff_t, 1)) and ((w.*.y != 0) or (@as(ptrdiff_t, @intFromBool(!(staen != 0))) != 0))) @as(c_int, 1) else @as(c_int, 0)), w.*.msgt);
    }
}
pub export fn msgclr(arg_w: [*c]W) void {
    var w = arg_w;
    _ = &w;
    w.*.msgb = null;
    w.*.msgt = null;
}
pub export var msgbuf: [300]u8 = std.mem.zeroes([300]u8);
pub export fn msgnw(arg_w: [*c]W, arg_s: [*c]const u8) void {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    w.*.msgb = s;
}
pub export fn msgnwt(arg_w: [*c]W, arg_s: [*c]const u8) void {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    w.*.msgt = s;
}
pub export fn urtn(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (w.*.watom.*.rtn != null) return w.*.watom.*.rtn.?(w) else return -@as(c_int, 1);
}
pub export fn utype(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (w.*.watom.*.type != null) return w.*.watom.*.type.?(w, k) else return -@as(c_int, 1);
}
pub export fn uprevw(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    return wprev(w.*.t);
}
pub export fn unextw(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    return wnext(w.*.t);
}
pub export fn ugroww(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    return wgrow(w);
}
pub export fn ushrnk(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    return wshrink(w);
}
pub export fn uexpld(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if ((w.*.t.*.h - w.*.t.*.wind) == getgrouph(w)) {
        wshowall(w.*.t);
    } else {
        wshowone(w);
    }
    return 0;
}
pub export fn uretyp(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    nredraw(w.*.t.*.t);
    return 0;
}
pub fn find_window(arg_t: [*c]Screen, arg_b_1: ?*B) callconv(.c) [*c]W {
    var t = arg_t;
    _ = &t;
    var b_1 = arg_b_1;
    _ = &b_1;
    var w: [*c]W = t.*.topwin;
    _ = &w;
    while (true) {
        if ((w.*.watom == (&watomtw)) and (@as([*c]BW, @ptrCast(@alignCast(w.*.object))).*.b == b_1)) return w;
        w = w.*.link.next;
        if (!(w != t.*.topwin)) break;
    }
    return null;
}
pub export fn umwind(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var msgw: [*c]W = undefined;
    _ = &msgw;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (!(errbuf != null)) {
        msgnw(w, my_gettext("There are no messages"));
        return -@as(c_int, 1);
    }
    msgw = find_window(w.*.t, errbuf);
    if (msgw != null) {
        w.*.t.*.curwin = msgw;
        wshowone(msgw);
        return 0;
    } else {
        msgw = w;
        _ = get_buffer_in_window(bw_1, errbuf);
        wshowone(msgw);
        return 0;
    }
}
pub export fn umfit(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var p: [*c]W = undefined;
    _ = &p;
    var t: [*c]Screen = w.*.t;
    _ = &t;
    wshowone(w);
    p = findtopw(w).*.link.prev.*.main;
    if (p == w) {
        _ = usplitw(w, 0);
        w = t.*.curwin;
        p = findtopw(w).*.link.prev.*.main;
        if (p == w) {
            return -@as(c_int, 1);
        }
        _ = get_buffer_in_window(@ptrCast(@alignCast(p.*.object)), bfind(""));
    }
    if ((p.*.t.*.h >> @intCast(@as(ptrdiff_t, 1))) < @as(ptrdiff_t, 3)) return -@as(c_int, 1);
    seth(p, p.*.t.*.h >> @intCast(@as(ptrdiff_t, 1)));
    t.*.topwin = p;
    t.*.curwin = p;
    wfit(t);
    t.*.curwin = w;
    wfit(t);
    return 0;
}
