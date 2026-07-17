//! RC macro menus — replaces `joe/mmenu.c`.
//!
//! Faithful C-ABI port of JOE rc-defined macro menus. Generated from goto-free mmenu.c via `zig translate-c`, then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;

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
pub const aELEMENT = [*c]u8;
pub const struct_options = extern struct {
    _pad0: [136]u8 = std.mem.zeroes([136]u8),
    readonly: c_int = 0,
    _pad1: [204]u8 = std.mem.zeroes([204]u8),
};
pub const OPTIONS = struct_options;
pub const struct_b = extern struct {
    _pad0: [192]u8 = std.mem.zeroes([192]u8),
    o: OPTIONS = std.mem.zeroes(OPTIONS),
    _pad1: [36]u8 = std.mem.zeroes([36]u8),
    rdonly: c_int = 0,
    _pad2: [56]u8 = std.mem.zeroes([56]u8),
};
pub const B = struct_b;
pub const struct_p = opaque {};
pub const P = struct_p;
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
pub const struct_bw = extern struct {
    parent: [*c]W = null,
    b: [*c]B = null,
    _pad0: [64]u8 = std.mem.zeroes([64]u8),
    o: OPTIONS = std.mem.zeroes(OPTIONS),
    _pad1: [64]u8 = std.mem.zeroes([64]u8),
};
pub const BW = struct_bw;
pub const MENU = struct_menu;
pub const struct_menu = extern struct {
    parent: [*c]W = null,
    list: [*c][*c]u8 = null,
    top: ptrdiff_t = 0,
    cursor: ptrdiff_t = 0,
    width: ptrdiff_t = 0,
    fitline: ptrdiff_t = 0,
    perline: ptrdiff_t = 0,
    lines: ptrdiff_t = 0,
    nitems: ptrdiff_t = 0,
    t: [*c]Screen = null,
    h: ptrdiff_t = 0,
    w: ptrdiff_t = 0,
    x: ptrdiff_t = 0,
    y: ptrdiff_t = 0,
    abrt: ?*const fn (w: [*c]W, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int = null,
    func: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque, k: c_int) callconv(.c) c_int = null,
    backs: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int = null,
    object: ?*anyopaque = null,
};
pub const struct_macro = extern struct {
    _pad: [64]u8 = std.mem.zeroes([64]u8),
};
pub const MACRO = struct_macro;
pub const struct_charmap = extern struct {
    next: ?*anyopaque = null,
    name: [*c]const u8 = null,
    type: c_int = 0,
    _pad_type: [4]u8 = std.mem.zeroes([4]u8),
    _pad: [2732]u8 = std.mem.zeroes([2732]u8),
};
pub const struct_rc_menu_entry = extern struct {
    m: [*c]MACRO = null,
    name: [*c]u8 = null,
};
pub const struct_rc_menu = extern struct {
    next: [*c]struct_rc_menu = null,
    name: [*c]u8 = null,
    last_position: ptrdiff_t = 0,
    size: ptrdiff_t = 0,
    entries: [*c][*c]struct_rc_menu_entry = null,
    backs: [*c]MACRO = null,
};
pub const struct_menu_instance = extern struct {
    menu: [*c]struct_rc_menu = null,
    s: [*c][*c]u8 = null,
};
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_realloc(ptr: ?*anyopaque, size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn vsncpy(s: [*c]u8, len: ptrdiff_t, blk: [*c]const u8, blklen: ptrdiff_t) [*c]u8;
pub extern fn vsrm(s: [*c]u8) void;
pub extern fn vaensure(vary: [*c]aELEMENT, len: ptrdiff_t) [*c]aELEMENT;
pub extern fn vaadd(vary: [*c]aELEMENT, element: aELEMENT) [*c]aELEMENT;
pub extern fn vasort(ary: [*c]aELEMENT, len: ptrdiff_t) [*c]aELEMENT;
pub extern fn stagen(stalin: [*c]u8, bw: [*c]BW, s: [*c]const u8, fill: u8) [*c]u8;
pub extern fn exmacro(m: [*c]MACRO, u: c_int, k: c_int) c_int;
pub extern fn msgnw(w: [*c]W, s: [*c]const u8) void;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn wabort(w: [*c]W) c_int;
pub extern fn mkmenu(loc: [*c]W, targ: [*c]W, s: [*c][*c]u8, func: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque, k: c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, backs: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, cursor: ptrdiff_t, object: ?*anyopaque, notify: [*c]c_int) [*c]MENU;
pub extern fn wmkpw(w: [*c]W, prompt: [*c]const u8, history: [*c][*c]B, func: ?*const fn (w: [*c]W, s: [*c]u8, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, huh: [*c]const u8, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, tab: ?*const fn (bw: [*c]BW, k: c_int) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int, map: [*c]struct_charmap, file_prompt: c_int) [*c]BW;
pub extern fn simple_cmplt(bw: [*c]BW, list: [*c][*c]u8) c_int;
pub extern var locale_map: [*c]struct_charmap;
pub fn find_menu(arg_s: [*c]u8) callconv(.c) [*c]struct_rc_menu {
    var s = arg_s;
    _ = &s;
    var m: [*c]struct_rc_menu = undefined;
    _ = &m;
    {
        m = menus;
        while (m != null) : (m = m.*.next) if (!(strcmp(m.*.name, s) != 0)) break;
    }
    return m;
}
pub fn backsmenu(arg_m: [*c]MENU, arg_x: ptrdiff_t, arg_obj: ?*anyopaque) callconv(.c) c_int {
    var m = arg_m;
    _ = &m;
    var x = arg_x;
    _ = &x;
    var obj = arg_obj;
    _ = &obj;
    var mi: [*c]struct_menu_instance = @ptrCast(@alignCast(obj));
    _ = &mi;
    var menu_1: [*c]struct_rc_menu = mi.*.menu;
    _ = &menu_1;
    var notify: [*c]c_int = m.*.parent.*.notify;
    _ = &notify;
    if (notify != null) {
        notify.* = 1;
    }
    _ = wabort(m.*.parent);
    if (menu_1.*.backs != null) return exmacro(menu_1.*.backs, 1, -@as(c_int, 1)) else return 0;
}
pub fn doabrt(arg_w: [*c]W, arg_x: ptrdiff_t, arg_obj: ?*anyopaque) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var x = arg_x;
    _ = &x;
    var obj = arg_obj;
    _ = &obj;
    var mi: [*c]struct_menu_instance = @ptrCast(@alignCast(obj));
    _ = &mi;
    mi.*.menu.*.last_position = x;
    {
        x = 0;
        while (mi.*.s[@bitCast(@as(isize, @intCast(x)))] != null) : (x += 1) {
            vsrm(mi.*.s[@bitCast(@as(isize, @intCast(x)))]);
        }
    }
    joe_free(@ptrCast(@alignCast(mi.*.s)));
    joe_free(@ptrCast(@alignCast(mi)));
    return -@as(c_int, 1);
}
pub fn execmenu(arg_m: [*c]MENU, arg_x: ptrdiff_t, arg_obj: ?*anyopaque, arg_flg: c_int) callconv(.c) c_int {
    var m = arg_m;
    _ = &m;
    var x = arg_x;
    _ = &x;
    var obj = arg_obj;
    _ = &obj;
    var flg = arg_flg;
    _ = &flg;
    var mi: [*c]struct_menu_instance = @ptrCast(@alignCast(obj));
    _ = &mi;
    var menu_1: [*c]struct_rc_menu = mi.*.menu;
    _ = &menu_1;
    var notify: [*c]c_int = m.*.parent.*.notify;
    _ = &notify;
    if (notify != null) {
        notify.* = 1;
    }
    _ = wabort(m.*.parent);
    menu_flg = flg;
    return exmacro(menu_1.*.entries[@bitCast(@as(isize, @intCast(x)))].*.m, 1, -@as(c_int, 1));
}
pub fn display_menu(arg_bw_1: [*c]BW, arg_menu_2: [*c]struct_rc_menu, arg_notify: [*c]c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var menu_2 = arg_menu_2;
    _ = &menu_2;
    var notify = arg_notify;
    _ = &notify;
    var m: [*c]struct_menu_instance = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_menu_instance))))))));
    _ = &m;
    var s: [*c][*c]u8 = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]u8))))) * (menu_2.*.size + @as(ptrdiff_t, 1)))));
    _ = &s;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (@as(ptrdiff_t, x) != menu_2.*.size) : (x += 1) {
            s[@bitCast(@as(isize, @intCast(x)))] = stagen(null, bw_1, menu_2.*.entries[@bitCast(@as(isize, @intCast(x)))].*.name, ' ');
        }
    }
    s[@bitCast(@as(isize, @intCast(x)))] = null;
    m.*.menu = menu_2;
    m.*.s = s;
    if (mkmenu(bw_1.*.parent, bw_1.*.parent, m.*.s, execmenu, doabrt, backsmenu, menu_2.*.last_position, @ptrCast(@alignCast(m)), notify) != null) return 0 else return -@as(c_int, 1);
}
pub fn getmenus() callconv(.c) [*c][*c]u8 {
    var s: [*c][*c]u8 = vaensure(null, 20);
    _ = &s;
    var m: [*c]struct_rc_menu = undefined;
    _ = &m;
    {
        m = menus;
        while (m != null) : (m = m.*.next) {
            s = vaadd(s, vsncpy(null, 0, m.*.name, slen(m.*.name)));
        }
    }
    _ = vasort(s, (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).*);
    return s;
}
pub fn menucmplt(arg_bw_1: [*c]BW, arg_k: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    if (!(smenus != null)) {
        smenus = getmenus();
    }
    return simple_cmplt(bw_1, smenus);
}
pub fn domenu(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var menu_2: [*c]struct_rc_menu = undefined;
    _ = &menu_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    menu_2 = find_menu(s);
    vsrm(s);
    if (!(menu_2 != null)) {
        msgnw(w, my_gettext("No such menu"));
        if (notify != null) {
            notify.* = 1;
        }
        return -@as(c_int, 1);
    } else {
        bw_1.*.b.*.o.readonly = blk: {
            const tmp = bw_1.*.b.*.rdonly;
            bw_1.*.o.readonly = tmp;
            break :blk tmp;
        };
        return display_menu(bw_1, menu_2, notify);
    }
}
pub var menuhist: [*c]B = null;
pub var menus: [*c]struct_rc_menu = null;
pub var smenus: [*c][*c]u8 = null;
pub export fn create_menu(arg_name: [*c]u8, arg_bs: [*c]MACRO) [*c]struct_rc_menu {
    var name = arg_name;
    _ = &name;
    var bs = arg_bs;
    _ = &bs;
    var menu_1: [*c]struct_rc_menu = find_menu(name);
    _ = &menu_1;
    if (menu_1 != null) return menu_1;
    menu_1 = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_rc_menu))))))));
    menu_1.*.name = zdup(name);
    menu_1.*.next = menus;
    menus = menu_1;
    menu_1.*.last_position = 0;
    menu_1.*.size = 0;
    menu_1.*.entries = null;
    menu_1.*.backs = bs;
    return menu_1;
}
pub export fn add_menu_entry(arg_menu_1: [*c]struct_rc_menu, arg_entry_name: [*c]u8, arg_m: [*c]MACRO) void {
    var menu_1 = arg_menu_1;
    _ = &menu_1;
    var entry_name = arg_entry_name;
    _ = &entry_name;
    var m = arg_m;
    _ = &m;
    var e: [*c]struct_rc_menu_entry = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_rc_menu_entry))))))));
    _ = &e;
    e.*.m = m;
    e.*.name = zdup(entry_name);
    menu_1.*.size += 1;
    if (!(menu_1.*.entries != null)) {
        menu_1.*.entries = @ptrCast(@alignCast(joe_malloc(menu_1.*.size * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]struct_rc_menu_entry))))))));
    } else {
        menu_1.*.entries = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(menu_1.*.entries)), menu_1.*.size * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]struct_rc_menu_entry))))))));
    }
    menu_1.*.entries[@bitCast(@as(isize, @intCast(menu_1.*.size - @as(ptrdiff_t, 1))))] = e;
}
pub export var menu_flg: c_int = 0;
pub export fn umenu(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (wmkpw(w, my_gettext("Menu: "), &menuhist, domenu, "menu", null, menucmplt, null, null, locale_map, 0) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
