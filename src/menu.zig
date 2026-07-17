//! Menu windows — replaces `joe/menu.c`.
//!
//! Faithful C-ABI port of JOE grid menu windows. Generated from goto-free menu.c via `zig translate-c`, then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;

pub const TYPETW: c_int = 0x0100;
pub const TYPEPW: c_int = 0x0200;
pub const TYPEMENU: c_int = 0x0800;
pub const TYPEQW: c_int = 0x1000;
pub const COMPOSE: c_int = 4;
pub const INVERSE: c_int = 64;

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
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn vsncpy(s: [*c]u8, len: ptrdiff_t, blk: [*c]const u8, blklen: ptrdiff_t) [*c]u8;
pub extern fn vstrunc(s: [*c]u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsrm(s: [*c]u8) void;
pub extern fn genfield(t: [*c]SCRN, scrn: [*c][4]c_int, attr: [*c]c_int, x: ptrdiff_t, y: ptrdiff_t, ofst: ptrdiff_t, s: [*c]const u8, len: ptrdiff_t, atr: c_int, width: ptrdiff_t, flg: c_int, fmt: [*c]c_int) void;
pub extern fn outatr(map: [*c]struct_charmap, t: [*c]SCRN, scrn: [*c][4]c_int, attrf: [*c]c_int, xx: ptrdiff_t, yy: ptrdiff_t, c: c_int, a: c_int) void;
pub extern fn outatr_complete(t: [*c]SCRN) void;
pub extern fn eraeol(t: [*c]SCRN, x: ptrdiff_t, y: ptrdiff_t, atr: c_int) c_int;
pub extern fn txtwidth(s: [*c]const u8, len: ptrdiff_t) ptrdiff_t;
pub extern fn wcreate(t: [*c]Screen, watom: [*c]const WATOM, where: [*c]W, target: [*c]W, after: [*c]W, lines: ptrdiff_t, huh: [*c]const u8, notify: [*c]c_int) [*c]W;
pub extern fn wfit(t: [*c]Screen) void;
pub extern var locale_map: [*c]struct_charmap;
pub extern var dostaupd: c_int;
pub fn menufllw(arg_w: [*c]W) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var m: [*c]MENU = @ptrCast(@alignCast(w.*.object));
    _ = &m;
    if (transpose != 0) {
        if (@rem(m.*.cursor, m.*.lines) < m.*.top) {
            m.*.top = @rem(m.*.cursor, m.*.lines);
        } else if (@rem(m.*.cursor, m.*.lines) >= (@rem(m.*.top, m.*.lines) + m.*.h)) {
            m.*.top = @rem(m.*.cursor, m.*.lines) - (m.*.h - @as(ptrdiff_t, 1));
        }
    } else {
        if (m.*.cursor < m.*.top) {
            m.*.top = m.*.cursor - @rem(m.*.cursor, m.*.perline);
        } else if (m.*.cursor >= (m.*.top + (m.*.perline * m.*.h))) {
            m.*.top = (m.*.cursor - @rem(m.*.cursor, m.*.perline)) - (m.*.perline * (m.*.h - @as(ptrdiff_t, 1)));
        }
    }
}
pub fn menudisp(arg_w: [*c]W, arg_flg: c_int) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var flg = arg_flg;
    _ = &flg;
    var m: [*c]MENU = @ptrCast(@alignCast(w.*.object));
    _ = &m;
    var col: ptrdiff_t = undefined;
    _ = &col;
    var x: c_int = undefined;
    _ = &x;
    var y: c_int = undefined;
    _ = &y;
    var s: [*c][4]c_int = (m.*.t.*.t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(m.*.x))))) + @as(usize, @bitCast(@as(isize, @intCast(m.*.y * m.*.t.*.t.*.co))));
    _ = &s;
    var a: [*c]c_int = (m.*.t.*.t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(m.*.x))))) + @as(usize, @bitCast(@as(isize, @intCast(m.*.y * m.*.t.*.t.*.co))));
    _ = &a;
    var cut: ptrdiff_t = @rem(m.*.nitems, m.*.lines);
    _ = &cut;
    if (!(cut != 0)) {
        cut = m.*.lines;
    }
    {
        y = 0;
        while (@as(ptrdiff_t, y) != m.*.h) : (y += 1) {
            col = 0;
            if (transpose != 0) {
                if (@as(ptrdiff_t, y) < m.*.lines) {
                    x = 0;
                    while (@as(ptrdiff_t, x) < (if ((@as(ptrdiff_t, y) + m.*.top) >= cut) m.*.perline - @as(ptrdiff_t, 1) else m.*.perline)) : (x += 1) {
                        var atr: c_int = undefined;
                        _ = &atr;
                        var ndx: ptrdiff_t = ((@as(ptrdiff_t, x) * m.*.lines) + @as(ptrdiff_t, y)) + m.*.top;
                        _ = &ndx;
                        if ((ndx == m.*.cursor) and (m.*.t.*.curwin == m.*.parent)) {
                            atr = (bg_menu & bg_menumask) | bg_menusel;
                        } else {
                            atr = bg_menu;
                        }
                        if (col == m.*.w) break;
                        genfield(m.*.t.*.t, s + @as(usize, @bitCast(@as(isize, @intCast(col)))), a + @as(usize, @bitCast(@as(isize, @intCast(col)))), m.*.x + col, m.*.y + @as(ptrdiff_t, y), 0, m.*.list[@bitCast(@as(isize, @intCast(ndx)))], @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(m.*.list[@bitCast(@as(isize, @intCast(ndx)))]))))), atr, m.*.width, 0, null);
                        col += m.*.width;
                        if (col != m.*.w) {
                            outatr(locale_map, m.*.t.*.t, s + @as(usize, @bitCast(@as(isize, @intCast(col)))), a + @as(usize, @bitCast(@as(isize, @intCast(col)))), m.*.x + col, m.*.y + @as(ptrdiff_t, y), ' ', bg_menu);
                            col += 1;
                        }
                    }
                }
            } else {
                {
                    x = 0;
                    while ((@as(ptrdiff_t, x) != m.*.perline) and ((((@as(ptrdiff_t, y) * m.*.perline) + @as(ptrdiff_t, x)) + m.*.top) < m.*.nitems)) : (x += 1) {
                        var atr: c_int = undefined;
                        _ = &atr;
                        var ndx: ptrdiff_t = (@as(ptrdiff_t, x) + (@as(ptrdiff_t, y) * m.*.perline)) + m.*.top;
                        _ = &ndx;
                        if ((ndx == m.*.cursor) and (m.*.t.*.curwin == m.*.parent)) {
                            atr = INVERSE | bg_menu;
                        } else {
                            atr = bg_menu;
                        }
                        if (col == m.*.w) break;
                        genfield(m.*.t.*.t, s + @as(usize, @bitCast(@as(isize, @intCast(col)))), a + @as(usize, @bitCast(@as(isize, @intCast(col)))), m.*.x + col, m.*.y + @as(ptrdiff_t, y), 0, m.*.list[@bitCast(@as(isize, @intCast(ndx)))], @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(m.*.list[@bitCast(@as(isize, @intCast(ndx)))]))))), atr, m.*.width, 0, null);
                        col += m.*.width;
                        if (col != m.*.w) {
                            outatr(locale_map, m.*.t.*.t, s + @as(usize, @bitCast(@as(isize, @intCast(col)))), a + @as(usize, @bitCast(@as(isize, @intCast(col)))), m.*.x + col, m.*.y + @as(ptrdiff_t, y), ' ', bg_menu);
                            col += 1;
                        }
                    }
                }
            }
            outatr_complete(m.*.t.*.t);
            if (col != m.*.w) {
                _ = eraeol(m.*.t.*.t, m.*.x + col, m.*.y + @as(ptrdiff_t, y), bg_menu);
            }
            s += @as(usize, @bitCast(@as(isize, @intCast(m.*.t.*.t.*.co))));
            a += @as(usize, @bitCast(@as(isize, @intCast(m.*.t.*.t.*.co))));
        }
    }
    if (transpose != 0) {
        m.*.parent.*.cury = @rem(m.*.cursor, m.*.lines) - m.*.top;
        col = txtwidth(m.*.list[@bitCast(@as(isize, @intCast(m.*.cursor)))], @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(m.*.list[@bitCast(@as(isize, @intCast(m.*.cursor)))]))))));
        if (col < m.*.width) {
            m.*.parent.*.curx = (@divTrunc(m.*.cursor, m.*.lines) * (m.*.width + @as(ptrdiff_t, 1))) + col;
        } else {
            m.*.parent.*.curx = (@divTrunc(m.*.cursor, m.*.lines) * (m.*.width + @as(ptrdiff_t, 1))) + m.*.width;
        }
    } else {
        m.*.parent.*.cury = @divTrunc(m.*.cursor - m.*.top, m.*.perline);
        col = txtwidth(m.*.list[@bitCast(@as(isize, @intCast(m.*.cursor)))], @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(m.*.list[@bitCast(@as(isize, @intCast(m.*.cursor)))]))))));
        if (col < m.*.width) {
            m.*.parent.*.curx = (@rem(m.*.cursor - m.*.top, m.*.perline) * (m.*.width + @as(ptrdiff_t, 1))) + col;
        } else {
            m.*.parent.*.curx = (@rem(m.*.cursor - m.*.top, m.*.perline) * (m.*.width + @as(ptrdiff_t, 1))) + m.*.width;
        }
    }
}
pub fn menumove(arg_w: [*c]W, arg_x: ptrdiff_t, arg_y: ptrdiff_t) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    var m: [*c]MENU = @ptrCast(@alignCast(w.*.object));
    _ = &m;
    m.*.x = x;
    m.*.y = y;
}
pub fn mlines(arg_s: [*c][*c]u8, arg_w: ptrdiff_t) callconv(.c) ptrdiff_t {
    var s = arg_s;
    _ = &s;
    var w = arg_w;
    _ = &w;
    var x: ptrdiff_t = undefined;
    _ = &x;
    var lines: ptrdiff_t = undefined;
    _ = &lines;
    var width: ptrdiff_t = undefined;
    _ = &width;
    var nitems: ptrdiff_t = undefined;
    _ = &nitems;
    var perline: ptrdiff_t = undefined;
    _ = &perline;
    {
        x = 0;
        width = 0;
        while (s[@bitCast(@as(isize, @intCast(x)))] != null) : (x += 1) {
            var d: ptrdiff_t = txtwidth(s[@bitCast(@as(isize, @intCast(x)))], @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(s[@bitCast(@as(isize, @intCast(x)))]))))));
            _ = &d;
            if (d > width) {
                width = d;
            }
        }
    }
    nitems = x;
    if (width > (w - @as(ptrdiff_t, 1))) {
        width = w - @as(ptrdiff_t, 1);
    }
    perline = @divTrunc(w, width + @as(ptrdiff_t, 1));
    lines = @divTrunc((nitems + perline) - @as(ptrdiff_t, 1), perline);
    return lines;
}
pub fn mconfig(arg_m: [*c]MENU) callconv(.c) void {
    var m = arg_m;
    _ = &m;
    if (m.*.list != null) {
        var x: ptrdiff_t = undefined;
        _ = &x;
        m.*.top = 0;
        {
            x = 0;
            m.*.width = 0;
            while (m.*.list[@bitCast(@as(isize, @intCast(x)))] != null) : (x += 1) {
                var d: ptrdiff_t = txtwidth(m.*.list[@bitCast(@as(isize, @intCast(x)))], @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(m.*.list[@bitCast(@as(isize, @intCast(x)))]))))));
                _ = &d;
                if (d > m.*.width) {
                    m.*.width = d;
                }
            }
        }
        m.*.nitems = x;
        if (m.*.width > (m.*.w - @as(ptrdiff_t, 1))) {
            m.*.width = m.*.w - @as(ptrdiff_t, 1);
        }
        m.*.fitline = @divTrunc(m.*.w, m.*.width + @as(ptrdiff_t, 1));
        m.*.lines = @divTrunc((m.*.nitems + m.*.fitline) - @as(ptrdiff_t, 1), m.*.fitline);
        if (transpose != 0) {
            m.*.perline = @divTrunc((m.*.nitems + m.*.lines) - @as(ptrdiff_t, 1), m.*.lines);
        } else {
            m.*.perline = m.*.fitline;
        }
    }
}
pub fn menuresz(arg_w: [*c]W, arg_wi: ptrdiff_t, arg_he: ptrdiff_t) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var wi = arg_wi;
    _ = &wi;
    var he = arg_he;
    _ = &he;
    var m: [*c]MENU = @ptrCast(@alignCast(w.*.object));
    _ = &m;
    m.*.w = wi;
    m.*.h = he;
    mconfig(m);
}
pub fn mscrup(arg_m: [*c]MENU, arg_amnt: ptrdiff_t) callconv(.c) c_int {
    var m = arg_m;
    _ = &m;
    var amnt = arg_amnt;
    _ = &amnt;
    if (transpose != 0) {
        if (m.*.top >= amnt) {
            m.*.top -= amnt;
            m.*.cursor -= amnt;
            return 0;
        } else if (m.*.top != 0) {
            m.*.cursor -= m.*.top;
            m.*.top = 0;
            return 0;
        } else if (@rem(m.*.cursor, m.*.lines) != 0) {
            m.*.cursor -= @rem(m.*.cursor, m.*.lines);
            return 0;
        } else return -@as(c_int, 1);
    } else {
        if (m.*.top >= (amnt * m.*.perline)) {
            m.*.top -= amnt * m.*.perline;
            m.*.cursor -= amnt * m.*.perline;
            return 0;
        } else if (m.*.top != 0) {
            m.*.cursor -= m.*.top;
            m.*.top = 0;
            return 0;
        } else if (m.*.cursor >= m.*.perline) {
            m.*.cursor = @rem(m.*.cursor, m.*.perline);
            return 0;
        } else return -@as(c_int, 1);
    }
}
pub fn mscrdn(arg_m: [*c]MENU, arg_amnt: ptrdiff_t) callconv(.c) c_int {
    var m = arg_m;
    _ = &m;
    var amnt = arg_amnt;
    _ = &amnt;
    if (transpose != 0) {
        var col: ptrdiff_t = @divTrunc(m.*.cursor, m.*.lines);
        _ = &col;
        var y: ptrdiff_t = @rem(m.*.cursor, m.*.lines);
        _ = &y;
        var h: ptrdiff_t = m.*.lines;
        _ = &h;
        var t: ptrdiff_t = m.*.top;
        _ = &t;
        var cut: ptrdiff_t = @rem(m.*.nitems, m.*.lines);
        _ = &cut;
        if (!(cut != 0)) {
            cut = m.*.lines;
        }
        {
            const ref = &m.*.cursor;
            ref.* = @rem(ref.*, m.*.lines);
        }
        if (((t + m.*.h) + amnt) <= h) {
            m.*.top += amnt;
            m.*.cursor += amnt;
            if ((m.*.cursor >= cut) and (col == (m.*.perline - @as(ptrdiff_t, 1)))) {
                col -= 1;
            }
            m.*.cursor += col * m.*.lines;
            return 0;
        } else if ((t + m.*.h) < h) {
            amnt = h - (t + m.*.h);
            m.*.top += amnt;
            m.*.cursor += amnt;
            if ((m.*.cursor >= cut) and (col == (m.*.perline - @as(ptrdiff_t, 1)))) {
                col -= 1;
            }
            m.*.cursor += col * m.*.lines;
            return 0;
        } else if ((y + @as(ptrdiff_t, 1)) != h) {
            m.*.cursor = h - @as(ptrdiff_t, 1);
            if ((m.*.cursor >= cut) and (col == (m.*.perline - @as(ptrdiff_t, 1)))) {
                col -= 1;
            }
            m.*.cursor += col * m.*.lines;
            return 0;
        } else {
            m.*.cursor += col * m.*.lines;
            return -@as(c_int, 1);
        }
    } else {
        var col: ptrdiff_t = @rem(m.*.cursor, m.*.perline);
        _ = &col;
        var y: ptrdiff_t = @divTrunc(m.*.cursor, m.*.perline);
        _ = &y;
        var h: ptrdiff_t = @divTrunc((m.*.nitems + m.*.perline) - @as(ptrdiff_t, 1), m.*.perline);
        _ = &h;
        var t: ptrdiff_t = @divTrunc(m.*.top, m.*.perline);
        _ = &t;
        m.*.cursor -= col;
        if (((t + m.*.h) + amnt) <= h) {
            m.*.top += amnt * m.*.perline;
            m.*.cursor += amnt * m.*.perline;
            if ((m.*.cursor + col) >= m.*.nitems) if (m.*.nitems != 0) {
                m.*.cursor = m.*.nitems - @as(ptrdiff_t, 1);
            } else {
                m.*.cursor = 0;
            } else {
                m.*.cursor += col;
            }
            return 0;
        } else if ((t + m.*.h) < h) {
            amnt = h - (t + m.*.h);
            m.*.top += amnt * m.*.perline;
            m.*.cursor += amnt * m.*.perline;
            if ((m.*.cursor + col) >= m.*.nitems) if (m.*.nitems != 0) {
                m.*.cursor = m.*.nitems - @as(ptrdiff_t, 1);
            } else {
                m.*.cursor = 0;
            } else {
                m.*.cursor += col;
            }
            return 0;
        } else if ((y + @as(ptrdiff_t, 1)) != h) {
            m.*.cursor = (h - @as(ptrdiff_t, 1)) * m.*.perline;
            if ((m.*.cursor + col) >= m.*.nitems) if (m.*.nitems != 0) {
                m.*.cursor = m.*.nitems - @as(ptrdiff_t, 1);
            } else {
                m.*.cursor = 0;
            } else {
                m.*.cursor += col;
            }
            return 0;
        } else {
            m.*.cursor += col;
            return -@as(c_int, 1);
        }
    }
}
pub fn umrtn(arg_w: [*c]W) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var m: [*c]MENU = @ptrCast(@alignCast(w.*.object));
    _ = &m;
    dostaupd = 1;
    if (m.*.func != null) return m.*.func.?(m, m.*.cursor, m.*.object, 0) else return -@as(c_int, 1);
}
pub fn menufold(arg_c: c_int) callconv(.c) c_int {
    var c = arg_c;
    _ = &c;
    if ((c >= @as(c_int, 'a')) and (c <= @as(c_int, 'z'))) return c & @as(c_int, 31) else if ((c >= @as(c_int, 'A')) and (c <= @as(c_int, 'Z'))) return c & @as(c_int, 31) else return c;
}
pub fn umkey(arg_w: [*c]W, arg_c: c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var m: [*c]MENU = @ptrCast(@alignCast(w.*.object));
    _ = &m;
    var x: c_int = undefined;
    _ = &x;
    var n: c_int = 0;
    _ = &n;
    if ((c == @as(c_int, '-')) and (m.*.func != null)) {
        if (m.*.func != null) return m.*.func.?(m, m.*.cursor, m.*.object, -@as(c_int, 1)) else return -@as(c_int, 1);
    }
    if ((c == @as(c_int, '+')) and (m.*.func != null)) {
        if (m.*.func != null) return m.*.func.?(m, m.*.cursor, m.*.object, 1) else return -@as(c_int, 1);
    }
    c = menufold(c);
    {
        x = 0;
        while (@as(ptrdiff_t, x) != m.*.nitems) : (x += 1) if (menufold(m.*.list[@bitCast(@as(isize, @intCast(x)))][@as(c_int, 0)]) == c) {
            n += 1;
        };
    }
    if (!(n != 0)) return -@as(c_int, 1);
    if (n == @as(c_int, 1)) {
        x = 0;
        while (@as(ptrdiff_t, x) != m.*.nitems) : (x += 1) if (menufold(m.*.list[@bitCast(@as(isize, @intCast(x)))][@as(c_int, 0)]) == c) {
            m.*.cursor = x;
            return umrtn(m.*.parent);
        };
    }
    while (true) {
        m.*.cursor += 1;
        if (m.*.cursor == m.*.nitems) {
            m.*.cursor = 0;
        }
        if (!(menufold(m.*.list[@bitCast(@as(isize, @intCast(m.*.cursor)))][@as(c_int, 0)]) != c)) break;
    }
    return -@as(c_int, 1);
}
pub fn menuabort(arg_w: [*c]W) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var m: [*c]MENU = @ptrCast(@alignCast(w.*.object));
    _ = &m;
    var abrt: ?*const fn (w: [*c]W, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int = m.*.abrt;
    _ = &abrt;
    var object: ?*anyopaque = m.*.object;
    _ = &object;
    var x: ptrdiff_t = m.*.cursor;
    _ = &x;
    var win: [*c]W = w.*.win;
    _ = &win;
    joe_free(@ptrCast(@alignCast(m)));
    if (abrt != null) return abrt.?(win, x, object) else return -@as(c_int, 1);
}
pub fn cull(arg_a: [*c]u8, arg_b_1: [*c]u8) callconv(.c) [*c]u8 {
    var a = arg_a;
    _ = &a;
    var b_1 = arg_b_1;
    _ = &b_1;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (((@as(c_int, a[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, b_1[@bitCast(@as(isize, @intCast(x)))]) != 0)) and (@as(c_int, a[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, b_1[@bitCast(@as(isize, @intCast(x)))]))) : (x += 1) {}
    }
    return vstrunc(a, x);
}
pub export var bg_menu: c_int = 0;
pub export var bg_menusel: c_int = INVERSE;
pub export var bg_menumask: c_int = ~INVERSE;
pub export var transpose: c_int = 0;
pub export fn umbol(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (transpose != 0) {
        {
            const ref = &m.*.cursor;
            ref.* = @rem(ref.*, m.*.lines);
        }
    } else {
        m.*.cursor -= @rem(m.*.cursor, m.*.perline);
    }
    return 0;
}
pub export fn umbof(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    m.*.cursor = 0;
    return 0;
}
pub export fn umeof(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (m.*.nitems != 0) {
        if ((transpose != 0) and (@rem(m.*.nitems, m.*.lines) != @as(ptrdiff_t, 0))) {
            m.*.cursor = (m.*.lines - @as(ptrdiff_t, 1)) + (m.*.lines * (m.*.perline - @as(ptrdiff_t, 2)));
        } else {
            m.*.cursor = m.*.nitems - @as(ptrdiff_t, 1);
        }
    }
    return 0;
}
pub export fn umeol(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (transpose != 0) {
        var cut: ptrdiff_t = @rem(m.*.nitems, m.*.lines);
        _ = &cut;
        if (!(cut != 0)) {
            cut = m.*.lines;
        }
        {
            const ref = &m.*.cursor;
            ref.* = @rem(ref.*, m.*.lines);
        }
        if (m.*.cursor >= cut) {
            m.*.cursor += m.*.lines * (m.*.perline - @as(ptrdiff_t, 2));
        } else {
            m.*.cursor += m.*.lines * (m.*.perline - @as(ptrdiff_t, 1));
        }
    } else {
        m.*.cursor -= @rem(m.*.cursor, m.*.perline);
        if (((m.*.cursor + m.*.perline) - @as(ptrdiff_t, 1)) >= m.*.nitems) {
            m.*.cursor = m.*.nitems - @as(ptrdiff_t, 1);
        } else {
            m.*.cursor += m.*.perline - @as(ptrdiff_t, 1);
        }
    }
    return 0;
}
pub export fn umrtarw(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (transpose != 0) {
        var cut: ptrdiff_t = @rem(m.*.nitems, m.*.lines);
        _ = &cut;
        if (!(cut != 0)) {
            cut = m.*.lines;
        }
        if (@rem(m.*.cursor, m.*.lines) >= cut) {
            if (@divTrunc(m.*.cursor, m.*.lines) != (m.*.perline - @as(ptrdiff_t, 2))) {
                m.*.cursor += m.*.lines;
                return 0;
            }
        } else {
            if (@divTrunc(m.*.cursor, m.*.lines) != (m.*.perline - @as(ptrdiff_t, 1))) {
                m.*.cursor += m.*.lines;
                return 0;
            }
        }
        if ((@rem(m.*.cursor, m.*.lines) + @as(ptrdiff_t, 1)) < m.*.lines) {
            m.*.cursor = @rem(m.*.cursor, m.*.lines) + @as(ptrdiff_t, 1);
            return 0;
        }
        return -@as(c_int, 1);
    } else if ((m.*.cursor + @as(ptrdiff_t, 1)) < m.*.nitems) {
        m.*.cursor += 1;
        return 0;
    } else return -@as(c_int, 1);
}
pub export fn umtab(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if ((m.*.cursor + @as(ptrdiff_t, 1)) >= m.*.nitems) {
        m.*.cursor = 0;
    } else {
        m.*.cursor += 1;
    }
    return 0;
}
pub export fn umltarw(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if ((transpose != 0) and (m.*.cursor >= m.*.lines)) {
        m.*.cursor -= m.*.lines;
        return 0;
    } else if ((@as(ptrdiff_t, transpose) != 0) and (m.*.cursor != 0)) {
        var cut: ptrdiff_t = @rem(m.*.nitems, m.*.lines);
        _ = &cut;
        if (!(cut != 0)) {
            cut = m.*.lines;
        }
        m.*.cursor -= 1;
        if (m.*.cursor >= cut) {
            m.*.cursor += (m.*.perline - @as(ptrdiff_t, 2)) * m.*.lines;
        } else {
            m.*.cursor += (m.*.perline - @as(ptrdiff_t, 1)) * m.*.lines;
        }
        return 0;
    } else if ((@as(ptrdiff_t, @intFromBool(!(transpose != 0))) != 0) and (m.*.cursor != 0)) {
        m.*.cursor -= 1;
        return 0;
    } else return -@as(c_int, 1);
}
pub export fn umuparw(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if ((@as(ptrdiff_t, transpose) != 0) and (@rem(m.*.cursor, m.*.lines) != 0)) {
        m.*.cursor -= 1;
        return 0;
    } else if (!(transpose != 0) and (m.*.cursor >= m.*.perline)) {
        m.*.cursor -= m.*.perline;
        return 0;
    } else return -@as(c_int, 1);
}
pub export fn umdnarw(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (transpose != 0) {
        if ((m.*.cursor != (m.*.nitems - @as(ptrdiff_t, 1))) and (@rem(m.*.cursor, m.*.lines) != (m.*.lines - @as(ptrdiff_t, 1)))) {
            m.*.cursor += 1;
            return 0;
        } else {
            return -@as(c_int, 1);
        }
    } else {
        var col: ptrdiff_t = @rem(m.*.cursor, m.*.perline);
        _ = &col;
        m.*.cursor -= col;
        if ((m.*.cursor + m.*.perline) < m.*.nitems) {
            m.*.cursor += m.*.perline;
            if ((m.*.cursor + col) >= m.*.nitems) if (m.*.nitems != 0) {
                m.*.cursor = m.*.nitems - @as(ptrdiff_t, 1);
            } else {
                m.*.cursor = 0;
            } else {
                m.*.cursor += col;
            }
            return 0;
        } else {
            m.*.cursor += col;
            return -@as(c_int, 1);
        }
    }
}
pub export fn menujump(arg_m: [*c]MENU, arg_x: ptrdiff_t, arg_y: ptrdiff_t) void {
    var m = arg_m;
    _ = &m;
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    var pos: ptrdiff_t = m.*.top;
    _ = &pos;
    if (transpose != 0) {
        pos += y;
        pos += @divTrunc(x, m.*.width + @as(ptrdiff_t, 1)) * m.*.lines;
    } else {
        pos += y * m.*.perline;
        pos += @divTrunc(x, m.*.width + @as(ptrdiff_t, 1));
    }
    if (pos >= m.*.nitems) {
        pos = m.*.nitems - @as(ptrdiff_t, 1);
    }
    if (pos < @as(ptrdiff_t, 0)) {
        pos = 0;
    }
    m.*.cursor = pos;
}
pub export fn umscrup(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    return mscrup(m, 1);
}
pub export fn umpgup(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    return mscrup(m, @divTrunc(m.*.h + @as(ptrdiff_t, 1), @as(ptrdiff_t, 2)));
}
pub export fn umscrdn(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    return mscrdn(m, 1);
}
pub export fn umpgdn(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    return mscrdn(m, @divTrunc(m.*.h + @as(ptrdiff_t, 1), @as(ptrdiff_t, 2)));
}
pub export fn umbacks(arg_w: [*c]W, arg_c: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var m: [*c]MENU = undefined;
    _ = &m;
    while (true) {
        if (w.*.watom.*.what != TYPEMENU) return -@as(c_int, 1);
        m = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (m.*.backs != null) return m.*.backs.?(m, m.*.cursor, m.*.object) else return -@as(c_int, 1);
}
pub export var watommenu: WATOM = WATOM{
    .context = "menu",
    .disp = menudisp,
    .follow = menufllw,
    .abort = menuabort,
    .rtn = umrtn,
    .type = umkey,
    .resize = menuresz,
    .move = menumove,
    .ins = null,
    .del = null,
    .what = TYPEMENU,
};
pub export fn ldmenu(arg_m: [*c]MENU, arg_s: [*c][*c]u8, arg_cursor: ptrdiff_t) void {
    var m = arg_m;
    _ = &m;
    var s = arg_s;
    _ = &s;
    var cursor = arg_cursor;
    _ = &cursor;
    m.*.list = s;
    m.*.cursor = cursor;
    mconfig(m);
}
pub export var menu_above: c_int = 0;
pub export fn mkmenu(arg_w: [*c]W, arg_targ: [*c]W, arg_s: [*c][*c]u8, arg_func: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque, k: c_int) callconv(.c) c_int, arg_abrt: ?*const fn (w: [*c]W, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, arg_backs: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, arg_cursor: ptrdiff_t, arg_object: ?*anyopaque, arg_notify: [*c]c_int) [*c]MENU {
    var w = arg_w;
    _ = &w;
    var targ = arg_targ;
    _ = &targ;
    var s = arg_s;
    _ = &s;
    var func = arg_func;
    _ = &func;
    var abrt = arg_abrt;
    _ = &abrt;
    var backs = arg_backs;
    _ = &backs;
    var cursor = arg_cursor;
    _ = &cursor;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var neww: [*c]W = undefined;
    _ = &neww;
    var m: [*c]MENU = undefined;
    _ = &m;
    var lines: ptrdiff_t = undefined;
    _ = &lines;
    var h: ptrdiff_t = @divTrunc(w.*.main.*.h * @as(ptrdiff_t, 60), @as(ptrdiff_t, 100));
    _ = &h;
    if (!(h != 0)) {
        h = 1;
    }
    if (s != null) {
        lines = mlines(s, w.*.t.*.w);
        if (lines < h) {
            h = lines;
        }
    }
    neww = wcreate(w.*.t, &watommenu, w, targ, targ.*.main, h, null, notify);
    if (!(neww != null)) {
        if (notify != null) {
            notify.* = 1;
        }
        return null;
    }
    w.*.t.*.curwin = neww;
    wfit(neww.*.t);
    neww.*.object = @ptrCast(@alignCast(blk: {
        const tmp = @as([*c]MENU, @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(MENU)))))))));
        m = tmp;
        break :blk tmp;
    }));
    m.*.parent = neww;
    m.*.func = func;
    m.*.abrt = abrt;
    m.*.backs = backs;
    m.*.object = object;
    m.*.t = w.*.t;
    m.*.h = neww.*.h;
    m.*.w = neww.*.w;
    m.*.x = neww.*.x;
    m.*.y = neww.*.y;
    m.*.top = 0;
    ldmenu(m, s, cursor);
    return m;
}
pub export fn find_longest(arg_lst: [*c][*c]u8) [*c]u8 {
    var lst = arg_lst;
    _ = &lst;
    var com: [*c]u8 = undefined;
    _ = &com;
    var x: c_int = undefined;
    _ = &x;
    if (!(lst != null) or !((if (lst != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(lst))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) != 0)) return vstrunc(null, 0);
    com = vsncpy(null, 0, lst[@as(c_int, 0)], if (lst[@as(c_int, 0)] != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(lst[@as(c_int, 0)]))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    {
        x = 1;
        while (@as(ptrdiff_t, x) != (if (lst != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(lst))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0))) : (x += 1) {
            com = cull(com, lst[@bitCast(@as(isize, @intCast(x)))]);
        }
    }
    return com;
}
pub export fn mcomplete(arg_m: [*c]MENU) [*c]u8 {
    var m = arg_m;
    _ = &m;
    var com: [*c]u8 = undefined;
    _ = &com;
    var x: c_int = undefined;
    _ = &x;
    if (!(m.*.nitems != 0)) return vstrunc(null, 0);
    if ((m.*.nitems == @as(ptrdiff_t, 1)) and !(strcmp(m.*.list[@as(c_int, 0)], "../") != 0)) return vstrunc(null, 0);
    com = vsncpy(null, 0, m.*.list[@as(c_int, 0)], slen(m.*.list[@as(c_int, 0)]));
    {
        x = 1;
        while (@as(ptrdiff_t, x) != m.*.nitems) : (x += 1) {
            com = cull(com, m.*.list[@bitCast(@as(isize, @intCast(x)))]);
        }
    }
    return com;
}
