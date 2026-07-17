//! Query windows — replaces `joe/qw.c`.
//!
//! Faithful C-ABI port of JOE single-key query windows. Generated from goto-free qw.c via `zig translate-c`, then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;

pub const TYPETW: c_int = 0x0100;
pub const TYPEPW: c_int = 0x0200;
pub const TYPEMENU: c_int = 0x0800;
pub const TYPEQW: c_int = 0x1000;
pub const COMPOSE: c_int = 4;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub const off_t = i64;
pub const struct_b = extern struct {
    _pad: [632]u8 = std.mem.zeroes([632]u8),
};
pub const B = struct_b;
pub const struct_kbd = extern struct {
    _pad: [88]u8 = std.mem.zeroes([88]u8),
};
pub const KBD = struct_kbd;
pub const struct_kmap = opaque {};
pub const KMAP = struct_kmap;
pub const struct_bstack = extern struct {
    next: [*c]struct_bstack = null,
    b: [*c]B = null,
    cursor: ?*anyopaque = null,
    top: ?*anyopaque = null,
};
pub const W = struct_window;
const struct_unnamed_1 = extern struct {
    next: [*c]W = null,
    prev: [*c]W = null,
};
pub const struct_scrn = extern struct {
    _pad0: [8]u8 = std.mem.zeroes([8]u8),
    li: ptrdiff_t = 0,
    co: ptrdiff_t = 0,
    _pad1: [704]u8 = std.mem.zeroes([704]u8),
    scrn: [*c][4]c_int = null,
    attr: [*c]c_int = null,
    _pad2: [40]u8 = std.mem.zeroes([40]u8),
    updtab: [*c]c_int = null,
    _pad3: [48]u8 = std.mem.zeroes([48]u8),
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
    ins: ?*const fn (w: [*c]W, b: [*c]B, l: off_t, n: off_t, flg: c_int) callconv(.c) void = null,
    del: ?*const fn (w: [*c]W, b: [*c]B, l: off_t, n: off_t, flg: c_int) callconv(.c) void = null,
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
    bstack: [*c]struct_bstack = null,
};
pub const struct_qw = extern struct {
    parent: [*c]W = null,
    func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int = null,
    abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int = null,
    object: ?*anyopaque = null,
    prompt: [*c]u8 = null,
    promptlen: ptrdiff_t = 0,
    org_w: ptrdiff_t = 0,
    org_h: ptrdiff_t = 0,
};
pub const QW = struct_qw;
pub const struct_charmap = extern struct {
    next: ?*anyopaque = null,
    name: [*c]const u8 = null,
    type: c_int = 0,
    _pad_type: [4]u8 = std.mem.zeroes([4]u8),
    is_punct: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    is_print: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    is_space: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    is_alpha_: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    is_alnum_: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    _pad: [2692]u8 = std.mem.zeroes([2692]u8),
};
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn vsncpy(s: [*c]u8, len: ptrdiff_t, blk: [*c]const u8, blklen: ptrdiff_t) [*c]u8;
pub extern fn vsrm(s: [*c]u8) void;
pub extern fn joe_wcswidth(map: [*c]struct_charmap, s: [*c]const u8, len: ptrdiff_t) ptrdiff_t;
pub extern fn genfield(t: [*c]SCRN, scrn: [*c][4]c_int, attr: [*c]c_int, x: ptrdiff_t, y: ptrdiff_t, ofst: ptrdiff_t, s: [*c]const u8, len: ptrdiff_t, atr: c_int, width: ptrdiff_t, flg: c_int, fmt: [*c]c_int) void;
pub extern fn wcreate(t: [*c]Screen, watom: [*c]const WATOM, where: [*c]W, target: [*c]W, after: [*c]W, lines: ptrdiff_t, huh: [*c]const u8, notify: [*c]c_int) [*c]W;
pub extern fn wabort(w: [*c]W) c_int;
pub extern fn wfit(t: [*c]Screen) void;
pub extern var locale_map: [*c]struct_charmap;
pub extern var bg_prompt: c_int;
pub fn break_height(arg_map: [*c]struct_charmap, arg_src: [*c][*c]const u8, arg_src_len: [*c]ptrdiff_t, arg_wid: ptrdiff_t, arg_n: ptrdiff_t) callconv(.c) ptrdiff_t {
    var map = arg_map;
    _ = &map;
    var src = arg_src;
    _ = &src;
    var src_len = arg_src_len;
    _ = &src_len;
    var wid = arg_wid;
    _ = &wid;
    var n = arg_n;
    _ = &n;
    var s: [*c]const u8 = src.*;
    _ = &s;
    var len: ptrdiff_t = src_len.*;
    _ = &len;
    var h: ptrdiff_t = 1;
    _ = &h;
    var col: ptrdiff_t = 0;
    _ = &col;
    var x: ptrdiff_t = 0;
    _ = &x;
    var start_of_line: ptrdiff_t = 0;
    _ = &start_of_line;
    while (x != len) {
        var space: ptrdiff_t = 0;
        _ = &space;
        var word: ptrdiff_t = 0;
        _ = &word;
        var start: ptrdiff_t = x;
        _ = &start;
        var start_word: ptrdiff_t = undefined;
        _ = &start_word;
        while ((x != len) and (@as(c_int, s[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, ' '))) {
            space += 1;
            x += 1;
        }
        start_word = x;
        while ((x != len) and (@as(c_int, s[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, ' '))) {
            x += 1;
        }
        word = joe_wcswidth(map, s + @as(usize, @bitCast(@as(isize, @intCast(start_word)))), x - start_word);
        if ((((col + space) + word) < wid) or !(col != 0)) {
            col += space + word;
        } else {
            if (!((blk: {
                const ref = &n;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0)) {
                x = start;
                break;
            }
            h += 1;
            col = word;
            start_of_line = start_word;
        }
    }
    src.* = s + @as(usize, @bitCast(@as(isize, @intCast(start_of_line))));
    src_len.* = x - start_of_line;
    return h;
}
pub fn dispqw(arg_w: [*c]W, arg_flg: c_int) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var flg = arg_flg;
    _ = &flg;
    var qw_1: [*c]QW = @ptrCast(@alignCast(w.*.object));
    _ = &qw_1;
    var y: ptrdiff_t = undefined;
    _ = &y;
    {
        y = 0;
        while (y != w.*.h) : (y += 1) {
            var s: [*c]const u8 = qw_1.*.prompt;
            _ = &s;
            var l: ptrdiff_t = qw_1.*.promptlen;
            _ = &l;
            _ = break_height(locale_map, &s, &l, qw_1.*.org_w, y);
            w.*.t.*.t.*.updtab[@bitCast(@as(isize, @intCast(w.*.y + y)))] = 1;
            genfield(w.*.t.*.t, (w.*.t.*.t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast((w.*.y + y) * w.*.t.*.t.*.co))))) + @as(usize, @bitCast(@as(isize, @intCast(w.*.x)))), (w.*.t.*.t.*.attr + @as(usize, @bitCast(@as(isize, @intCast((w.*.y + y) * w.*.t.*.t.*.co))))) + @as(usize, @bitCast(@as(isize, @intCast(w.*.x)))), w.*.x, w.*.y + y, 0, s, l, bg_prompt, w.*.w - w.*.x, 1, null);
            w.*.cury = y;
            w.*.curx = w.*.x + joe_wcswidth(locale_map, s, l);
        }
    }
}
pub fn dispqwn(arg_w: [*c]W, arg_flg: c_int) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var flg = arg_flg;
    _ = &flg;
    var qw_1: [*c]QW = @ptrCast(@alignCast(w.*.object));
    _ = &qw_1;
    var y: ptrdiff_t = undefined;
    _ = &y;
    if (w.*.win.*.h != 0) {
        if ((w.*.win.*.watom.*.follow != null) and (w.*.win.*.object != null)) {
            w.*.win.*.watom.*.follow.?(w.*.win);
        }
        if ((w.*.win.*.watom.*.disp != null) and (w.*.win.*.object != null)) {
            w.*.win.*.watom.*.disp.?(w.*.win, 1);
        }
        w.*.curx = w.*.win.*.curx;
        w.*.cury = (w.*.win.*.cury + w.*.win.*.y) - w.*.y;
    }
    {
        y = 0;
        while (y != w.*.h) : (y += 1) {
            var s: [*c]const u8 = qw_1.*.prompt;
            _ = &s;
            var l: ptrdiff_t = qw_1.*.promptlen;
            _ = &l;
            _ = break_height(locale_map, &s, &l, qw_1.*.org_w, y);
            w.*.t.*.t.*.updtab[@bitCast(@as(isize, @intCast(w.*.y + y)))] = 1;
            genfield(w.*.t.*.t, (w.*.t.*.t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast((w.*.y + y) * w.*.t.*.t.*.co))))) + @as(usize, @bitCast(@as(isize, @intCast(w.*.x)))), (w.*.t.*.t.*.attr + @as(usize, @bitCast(@as(isize, @intCast((w.*.y + y) * w.*.t.*.t.*.co))))) + @as(usize, @bitCast(@as(isize, @intCast(w.*.x)))), w.*.x, w.*.y + y, 0, s, l, bg_prompt, w.*.w - w.*.x, 1, null);
            if (!(w.*.win.*.h != 0)) {
                w.*.cury = y;
                w.*.curx = w.*.x + joe_wcswidth(locale_map, s, l);
            }
        }
    }
}
pub fn utypeqw(arg_w: [*c]W, arg_c: c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var qw_1: [*c]QW = @ptrCast(@alignCast(w.*.object));
    _ = &qw_1;
    var win: [*c]W = undefined;
    _ = &win;
    var notify: [*c]c_int = w.*.notify;
    _ = &notify;
    var func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int = undefined;
    _ = &func;
    var object: ?*anyopaque = qw_1.*.object;
    _ = &object;
    win = qw_1.*.parent.*.win;
    func = qw_1.*.func;
    vsrm(qw_1.*.prompt);
    joe_free(@ptrCast(@alignCast(qw_1)));
    w.*.object = null;
    w.*.notify = null;
    _ = wabort(w);
    if (func != null) return func.?(win, c, object, notify);
    return -@as(c_int, 1);
}
pub fn abortqw(arg_w: [*c]W) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var qw_1: [*c]QW = @ptrCast(@alignCast(w.*.object));
    _ = &qw_1;
    var win: [*c]W = w.*.win;
    _ = &win;
    var object: ?*anyopaque = qw_1.*.object;
    _ = &object;
    var abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int = qw_1.*.abrt;
    _ = &abrt;
    vsrm(qw_1.*.prompt);
    joe_free(@ptrCast(@alignCast(qw_1)));
    if (abrt != null) return abrt.?(win, object) else return -@as(c_int, 1);
}
pub const watomqw: WATOM = WATOM{
    .context = "query",
    .disp = dispqw,
    .follow = null,
    .abort = abortqw,
    .rtn = null,
    .type = utypeqw,
    .resize = null,
    .move = null,
    .ins = null,
    .del = null,
    .what = TYPEQW,
};
pub const watqwn: WATOM = WATOM{
    .context = "querya",
    .disp = dispqwn,
    .follow = null,
    .abort = abortqw,
    .rtn = null,
    .type = utypeqw,
    .resize = null,
    .move = null,
    .ins = null,
    .del = null,
    .what = TYPEQW,
};
pub const watqwsr: WATOM = WATOM{
    .context = "querysr",
    .disp = dispqwn,
    .follow = null,
    .abort = abortqw,
    .rtn = null,
    .type = utypeqw,
    .resize = null,
    .move = null,
    .ins = null,
    .del = null,
    .what = TYPEQW,
};
pub export fn mkqw(arg_w: [*c]W, arg_prompt: [*c]const u8, arg_len: ptrdiff_t, arg_func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, arg_abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) [*c]QW {
    var w = arg_w;
    _ = &w;
    var prompt = arg_prompt;
    _ = &prompt;
    var len = arg_len;
    _ = &len;
    var func = arg_func;
    _ = &func;
    var abrt = arg_abrt;
    _ = &abrt;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var neww: [*c]W = undefined;
    _ = &neww;
    var qw_1: [*c]QW = undefined;
    _ = &qw_1;
    var s: [*c]const u8 = prompt;
    _ = &s;
    var l: ptrdiff_t = len;
    _ = &l;
    var h: ptrdiff_t = break_height(locale_map, &s, &l, w.*.w, -@as(c_int, 1));
    _ = &h;
    neww = wcreate(w.*.t, &watomqw, w, w, w.*.main, h, null, notify);
    if (!(neww != null)) {
        if (notify != null) {
            notify.* = 1;
        }
        return null;
    }
    w.*.t.*.curwin = neww;
    wfit(neww.*.t);
    neww.*.object = @ptrCast(@alignCast(blk: {
        const tmp = @as([*c]QW, @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(QW)))))))));
        qw_1 = tmp;
        break :blk tmp;
    }));
    qw_1.*.parent = neww;
    qw_1.*.prompt = vsncpy(null, 0, prompt, len);
    qw_1.*.promptlen = len;
    qw_1.*.org_w = w.*.w;
    qw_1.*.org_h = h;
    qw_1.*.func = func;
    qw_1.*.abrt = abrt;
    qw_1.*.object = object;
    return qw_1;
}
pub export fn mkqwna(arg_w: [*c]W, arg_prompt: [*c]const u8, arg_len: ptrdiff_t, arg_func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, arg_abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) [*c]QW {
    var w = arg_w;
    _ = &w;
    var prompt = arg_prompt;
    _ = &prompt;
    var len = arg_len;
    _ = &len;
    var func = arg_func;
    _ = &func;
    var abrt = arg_abrt;
    _ = &abrt;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var neww: [*c]W = undefined;
    _ = &neww;
    var qw_1: [*c]QW = undefined;
    _ = &qw_1;
    var s: [*c]const u8 = prompt;
    _ = &s;
    var l: ptrdiff_t = len;
    _ = &l;
    var h: ptrdiff_t = break_height(locale_map, &s, &l, w.*.w, -@as(c_int, 1));
    _ = &h;
    neww = wcreate(w.*.t, &watqwn, w, w, w.*.main, h, null, notify);
    if (!(neww != null)) {
        if (notify != null) {
            notify.* = 1;
        }
        return null;
    }
    w.*.t.*.curwin = neww;
    wfit(neww.*.t);
    neww.*.object = @ptrCast(@alignCast(blk: {
        const tmp = @as([*c]QW, @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(QW)))))))));
        qw_1 = tmp;
        break :blk tmp;
    }));
    qw_1.*.parent = neww;
    qw_1.*.prompt = vsncpy(null, 0, prompt, len);
    qw_1.*.promptlen = len;
    qw_1.*.org_w = w.*.w;
    qw_1.*.org_h = h;
    qw_1.*.func = func;
    qw_1.*.abrt = abrt;
    qw_1.*.object = object;
    return qw_1;
}
pub export fn mkqwnsr(arg_w: [*c]W, arg_prompt: [*c]const u8, arg_len: ptrdiff_t, arg_func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, arg_abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) [*c]QW {
    var w = arg_w;
    _ = &w;
    var prompt = arg_prompt;
    _ = &prompt;
    var len = arg_len;
    _ = &len;
    var func = arg_func;
    _ = &func;
    var abrt = arg_abrt;
    _ = &abrt;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var neww: [*c]W = undefined;
    _ = &neww;
    var qw_1: [*c]QW = undefined;
    _ = &qw_1;
    var s: [*c]const u8 = prompt;
    _ = &s;
    var l: ptrdiff_t = len;
    _ = &l;
    var h: ptrdiff_t = break_height(locale_map, &s, &l, w.*.w, -@as(c_int, 1));
    _ = &h;
    neww = wcreate(w.*.t, &watqwsr, w, w, w.*.main, h, null, notify);
    if (!(neww != null)) {
        if (notify != null) {
            notify.* = 1;
        }
        return null;
    }
    w.*.t.*.curwin = neww;
    wfit(neww.*.t);
    neww.*.object = @ptrCast(@alignCast(blk: {
        const tmp = @as([*c]QW, @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(QW)))))))));
        qw_1 = tmp;
        break :blk tmp;
    }));
    qw_1.*.parent = neww;
    qw_1.*.prompt = vsncpy(null, 0, prompt, len);
    qw_1.*.promptlen = len;
    qw_1.*.org_w = w.*.w;
    qw_1.*.org_h = h;
    qw_1.*.func = func;
    qw_1.*.abrt = abrt;
    qw_1.*.object = object;
    return qw_1;
}
