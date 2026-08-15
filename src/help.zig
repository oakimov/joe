//! Help system — replaces `joe/help.c`.
//!
//! Faithful C-ABI Path A port of JOE help (`help_init`/`help_display`/`help_on`/`u_help`/`u_help_next`/`u_help_prev` + `bg_help`/`help_is_utf8`).

const std = @import("std");
const ptrdiff_t = c_long;

const FITMIN: c_int = 2;
const DOUBLE_UNDERLINE: c_int = 8;
const CROSSED_OUT: c_int = 16;
const ITALIC: c_int = 32;
const INVERSE: c_int = 64;
const UNDERLINE: c_int = 128;
const BOLD: c_int = 256;
const BLINK: c_int = 512;
const DIM: c_int = 1024;
const BG_SHIFT: c_int = 11;
const FG_SHIFT: c_int = 21;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn malloc(n: c_ulong) ?*anyopaque;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub extern fn strchr(s: [*c]const u8, c: c_int) [*c]u8;
pub const off_t = i64;
pub const struct_hentry = extern struct {
    a: c_int = 0,
    b: c_int = 0,
    c: c_int = 0,
    d: c_int = 0,
};
pub const struct_cap = opaque {};
pub const CAP = struct_cap;
pub const struct_scrn = extern struct {
    cap: ?*CAP = null,
    li: ptrdiff_t = 0,
    co: ptrdiff_t = 0,
    ti: [*c]const u8 = null,
    cl: [*c]const u8 = null,
    cd: [*c]const u8 = null,
    te: [*c]const u8 = null,
    brp: [*c]const u8 = null,
    bre: [*c]const u8 = null,
    haz: c_int = 0,
    os: c_int = 0,
    eo: c_int = 0,
    ul: c_int = 0,
    am: c_int = 0,
    xn: c_int = 0,
    so: [*c]const u8 = null,
    se: [*c]const u8 = null,
    us: [*c]const u8 = null,
    ue: [*c]const u8 = null,
    uc: [*c]const u8 = null,
    ms: c_int = 0,
    _pad_ms: c_int = 0,
    mb: [*c]const u8 = null,
    md: [*c]const u8 = null,
    mh: [*c]const u8 = null,
    mr: [*c]const u8 = null,
    stricken: [*c]const u8 = null,
    dunderline: [*c]const u8 = null,
    me: [*c]const u8 = null,
    ZH: [*c]const u8 = null,
    ZR: [*c]const u8 = null,
    Sb: [*c]const u8 = null,
    Sf: [*c]const u8 = null,
    Co: c_int = 0,
    Tc: c_int = 0,
    ut: c_int = 0,
    da: c_int = 0,
    db: c_int = 0,
    _pad_db: c_int = 0,
    al: [*c]const u8 = null,
    dl: [*c]const u8 = null,
    AL: [*c]const u8 = null,
    DL: [*c]const u8 = null,
    cs: [*c]const u8 = null,
    rr: c_int = 0,
    _pad_rr: c_int = 0,
    sf: [*c]const u8 = null,
    SF: [*c]const u8 = null,
    sr: [*c]const u8 = null,
    SR: [*c]const u8 = null,
    dm: [*c]const u8 = null,
    dc: [*c]const u8 = null,
    DC: [*c]const u8 = null,
    ed: [*c]const u8 = null,
    im: [*c]const u8 = null,
    ic: [*c]const u8 = null,
    IC: [*c]const u8 = null,
    ip: [*c]const u8 = null,
    ei: [*c]const u8 = null,
    mi: c_int = 0,
    _pad_mi: c_int = 0,
    bs: [*c]const u8 = null,
    cbs: ptrdiff_t = 0,
    lf: [*c]const u8 = null,
    clf: ptrdiff_t = 0,
    up: [*c]const u8 = null,
    cup: ptrdiff_t = 0,
    nd: [*c]const u8 = null,
    ta: [*c]const u8 = null,
    cta: ptrdiff_t = 0,
    bt: [*c]const u8 = null,
    cbt: ptrdiff_t = 0,
    tw: ptrdiff_t = 0,
    ho: [*c]const u8 = null,
    cho: ptrdiff_t = 0,
    ll: [*c]const u8 = null,
    cll: ptrdiff_t = 0,
    cr: [*c]const u8 = null,
    ccr: ptrdiff_t = 0,
    RI: [*c]const u8 = null,
    cRI: ptrdiff_t = 0,
    LE: [*c]const u8 = null,
    cLE: ptrdiff_t = 0,
    UP: [*c]const u8 = null,
    cUP: ptrdiff_t = 0,
    DO: [*c]const u8 = null,
    cDO: ptrdiff_t = 0,
    ch: [*c]const u8 = null,
    cch: ptrdiff_t = 0,
    cv: [*c]const u8 = null,
    ccv: ptrdiff_t = 0,
    cV: [*c]const u8 = null,
    ccV: ptrdiff_t = 0,
    cm: [*c]const u8 = null,
    ccm: ptrdiff_t = 0,
    ce: [*c]const u8 = null,
    cce: ptrdiff_t = 0,
    assume_256: c_int = 0,
    truecolor: c_int = 0,
    palette: [*c]c_int = null,
    scroll: c_int = 0,
    insdel: c_int = 0,
    scrn: [*c][4]c_int = null,
    attr: [*c]c_int = null,
    x: ptrdiff_t = 0,
    y: ptrdiff_t = 0,
    top: ptrdiff_t = 0,
    bot: ptrdiff_t = 0,
    attrib: c_int = 0,
    ins: c_int = 0,
    updtab: [*c]c_int = null,
    avattr: c_int = 0,
    _pad_avattr: c_int = 0,
    sary: [*c]ptrdiff_t = null,
    compose: [*c]c_int = null,
    ofst: [*c]ptrdiff_t = null,
    htab: [*c]struct_hentry = null,
    ary: [*c]struct_hentry = null,
};
pub const SCRN = struct_scrn;
pub const W = struct_window;
const struct_unnamed_1 = extern struct {
    next: [*c]W = null,
    prev: [*c]W = null,
};
pub const struct_screen = extern struct {
    t: [*c]SCRN = null,
    wind: ptrdiff_t = 0,
    topwin: [*c]W = null,
    curwin: [*c]W = null,
    w: ptrdiff_t = 0,
    h: ptrdiff_t = 0,
};
pub const Screen = struct_screen;
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
    kbd: ?*anyopaque = null,
    watom: ?*anyopaque = null,
    object: ?*anyopaque = null,
    msgt: [*c]const u8 = null,
    msgb: [*c]const u8 = null,
    huh: [*c]const u8 = null,
    notify: [*c]c_int = null,
    bstack: ?*anyopaque = null,
};
pub const struct_charmap = extern struct {
    next: [*c]struct_charmap = null,
    name: [*c]const u8 = null,
    type: c_int = 0,
    _pad: [2720]u8 = std.mem.zeroes([2720]u8),
};
pub const JFILE = anyopaque;
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_realloc(ptr: ?*anyopaque, size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn mcpy(d: ?*anyopaque, s: ?*const anyopaque, n: ptrdiff_t) ?*anyopaque;
pub extern fn msetI(d: ?*anyopaque, c: c_int, n: ptrdiff_t) ?*anyopaque;
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn vsncpy(d: [*c]u8, dlen: ptrdiff_t, s: [*c]const u8, sl: ptrdiff_t) [*c]u8;
pub extern fn jfgets(buf: [*c]u8, len: c_int, f: ?*JFILE) [*c]u8;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn utf8_decode_fwrd(p: [*c][*c]const u8, len: [*c]ptrdiff_t) c_int;
pub extern fn joe_wcwidth(wide: c_int, c: c_int) c_int;
pub extern fn outatr(map: [*c]struct_charmap, t: [*c]SCRN, scrn: [*c]c_int, attrf: [*c]c_int, xx: ptrdiff_t, yy: ptrdiff_t, c: c_int, a: c_int) void;
pub extern fn outatr_complete(t: [*c]SCRN) void;
pub extern fn eraeol(t: [*c]SCRN, x: ptrdiff_t, y: ptrdiff_t, atr: c_int) c_int;
pub extern fn wfit(t: [*c]Screen) void;
pub extern var skiptop: c_int;
pub extern var bg_stalin: c_int;
pub extern var bg_menu: c_int;
pub extern var locale_map: [*c]struct_charmap;
pub extern var utf8_map: [*c]struct_charmap;
pub const struct_help = extern struct {
    text: [*c]u8 = null,
    lines: c_int = 0,
    prev: [*c]struct_help = null,
    next: [*c]struct_help = null,
    name: [*c]u8 = null,
};
pub export var bg_help: c_int = 0;
pub fn find_context_help(arg_name: [*c]const u8) callconv(.c) [*c]struct_help {
    var name = arg_name;
    _ = &name;
    var tmp: [*c]struct_help = help_actual;
    _ = &tmp;
    while (@as(?*anyopaque, @ptrCast(@alignCast(tmp.*.prev))) != @as(?*anyopaque, null)) {
        tmp = tmp.*.prev;
    }
    while ((@as(?*anyopaque, @ptrCast(@alignCast(tmp))) != @as(?*anyopaque, null)) and (strcmp(tmp.*.name, name) != @as(c_int, 0))) {
        tmp = tmp.*.next;
    }
    return tmp;
}
pub fn help_off(arg_t: [*c]Screen) callconv(.c) void {
    var t = arg_t;
    _ = &t;
    t.*.wind = skiptop;
    wfit(t);
}
pub export var help_actual: [*c]struct_help = null;
pub export var help_ptr: [*c]struct_help = null;
pub export fn help_init(arg_fd: ?*JFILE, arg_bf: [*c]u8, arg_line: c_int) c_int {
    var fd = arg_fd;
    _ = &fd;
    var bf = arg_bf;
    _ = &bf;
    var line = arg_line;
    _ = &line;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    var tmp: [*c]struct_help = undefined;
    _ = &tmp;
    var bfl: ptrdiff_t = undefined;
    _ = &bfl;
    var hlpsiz: ptrdiff_t = undefined;
    _ = &hlpsiz;
    var hlpbsz: ptrdiff_t = undefined;
    _ = &hlpbsz;
    var tempbuf: [*c]u8 = undefined;
    _ = &tempbuf;
    if (@as(c_int, bf[@as(c_int, 0)]) == @as(c_int, '{')) {
        tmp = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_help))))))));
        tmp.*.text = null;
        tmp.*.lines = 0;
        hlpsiz = 0;
        hlpbsz = 0;
        tmp.*.name = vsncpy(null, 0, bf + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), slen(bf + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))) - @as(ptrdiff_t, 1));
        while ((jfgets(@ptrCast(@alignCast(&buf)), @truncate(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf))))))), fd) != null) and (@as(c_int, buf[@as(c_int, 0)]) != @as(c_int, '}'))) {
            line += 1;
            bfl = @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(@ptrCast(@alignCast(&buf)))))));
            if ((hlpsiz + bfl) > hlpbsz) {
                if (tmp.*.text != null) {
                    tempbuf = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(tmp.*.text)), (hlpbsz + bfl) + @as(ptrdiff_t, 1024))));
                    tmp.*.text = tempbuf;
                } else {
                    tmp.*.text = @ptrCast(@alignCast(joe_malloc(bfl + @as(ptrdiff_t, 1024))));
                    tmp.*.text[@as(c_int, 0)] = 0;
                }
                hlpbsz += bfl + @as(ptrdiff_t, 1024);
            }
            _ = mcpy(@ptrCast(@alignCast(tmp.*.text + @as(usize, @bitCast(@as(isize, @intCast(hlpsiz)))))), @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&buf))))), bfl);
            hlpsiz += bfl;
            tmp.*.lines += 1;
        }
        tmp.*.prev = help_ptr;
        tmp.*.next = null;
        if (help_ptr != null) {
            help_ptr.*.next = tmp;
        } else {
            help_actual = tmp;
        }
        help_ptr = tmp;
        if (@as(c_int, buf[@as(c_int, 0)]) == @as(c_int, '}')) {
            line += 1;
        } else {
            _ = printf(my_gettext("\n%d: EOF before end of help text\n"), line);
        }
    }
    return line;
}
pub export var help_is_utf8: c_int = 0;
pub export fn help_display(arg_t: [*c]Screen) void {
    var t = arg_t;
    _ = &t;
    var str: [*c]const u8 = undefined;
    _ = &str;
    var y: c_int = undefined;
    _ = &y;
    var x: c_int = undefined;
    _ = &x;
    var c: c_int = undefined;
    _ = &c;
    var z: c_int = undefined;
    _ = &z;
    var atr: c_int = bg_help;
    _ = &atr;
    if (help_actual != null) {
        str = help_actual.*.text;
    } else {
        str = null;
    }
    {
        y = skiptop;
        while (@as(ptrdiff_t, y) != t.*.wind) : (y += 1) {
            if (t.*.t.*.updtab[@bitCast(@as(isize, @intCast(y)))] != 0) {
                var start: [*c]const u8 = str;
                _ = &start;
                var eol: [*c]const u8 = undefined;
                _ = &eol;
                var width: ptrdiff_t = 0;
                _ = &width;
                var nspans: ptrdiff_t = 0;
                _ = &nspans;
                var spanwidth: ptrdiff_t = undefined;
                _ = &spanwidth;
                var spancount: ptrdiff_t = 0;
                _ = &spancount;
                var spanextra: ptrdiff_t = undefined;
                _ = &spanextra;
                var len: ptrdiff_t = undefined;
                _ = &len;
                eol = strchr(str, @as(c_int, '\n'));
                while ((@as(c_int, str.*) != 0) and (@as(c_int, str.*) != @as(c_int, '\n'))) {
                    if (@as(c_int, str.*) == @as(c_int, '\\')) {
                        str += 1;
                        while (true) {
                            switch (@as(c_int, str.*)) {
                                @as(c_int, 'i'), @as(c_int, 'I'), @as(c_int, 'u'), @as(c_int, 'U'), @as(c_int, 'd'), @as(c_int, 'D'), @as(c_int, 'b'), @as(c_int, 'B'), @as(c_int, 'f'), @as(c_int, 'F'), @as(c_int, 's'), @as(c_int, 'S'), @as(c_int, 'z'), @as(c_int, 'Z') => {
                                    str += 1;
                                    break;
                                },
                                @as(c_int, '|') => {
                                    str += 1;
                                    nspans += 1;
                                    break;
                                },
                                @as(c_int, 0) => {
                                    break;
                                },
                                else => {
                                    str += 1;
                                    width += 1;
                                },
                            }
                            break;
                        }
                    } else {
                        len = @divExact(@as(c_long, @bitCast(@intFromPtr(eol) -% @intFromPtr(str))), @sizeOf(u8));
                        if (help_is_utf8 != 0) {
                            c = utf8_decode_fwrd(&str, &len);
                        } else {
                            c = @as([*c]const u8, @ptrCast(@alignCast(blk: {
                                const ref = &str;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            }))).*;
                            len -= 1;
                        }
                        width += joe_wcwidth(if (help_is_utf8 != 0) @as(c_int, 1) else @intFromBool(!!(locale_map.*.type != 0)), c);
                    }
                }
                str = start;
                if ((width >= t.*.w) or (nspans == @as(ptrdiff_t, 0))) {
                    spanwidth = 0;
                    spanextra = nspans;
                } else {
                    spanwidth = @divTrunc(t.*.w - width, nspans);
                    spanextra = nspans - ((t.*.w - width) - (nspans * spanwidth));
                }
                {
                    x = 0;
                    while (@as(ptrdiff_t, x) != t.*.w) : (x += 1) {
                        if ((@as(c_int, str.*) == @as(c_int, '\n')) or !(@as(c_int, str.*) != 0)) {
                            if (eraeol(t.*.t, x, y, bg_help) != 0) {
                                return;
                            } else {
                                break;
                            }
                        } else {
                            // C is `if (*str == '\\') { switch (*++str) { ... continue; } }`
                            // where `continue` advances the for-x loop. translate-c wrapped
                            // this in `while (true)` so Zig `continue` restarted the while and
                            // ate the next help glyph (REGION → EGION, etc.).
                            if (@as(c_int, str.*) == @as(c_int, '\\')) {
                                str += 1;
                                switch (@as(c_int, str.*)) {
                                    @as(c_int, '|') => {
                                        str += 1;
                                        {
                                            z = 0;
                                            while (@as(ptrdiff_t, z) != spanwidth) : (z += 1) {
                                                outatr(if (help_is_utf8 != 0) utf8_map else locale_map, t.*.t, @ptrCast(@alignCast(((t.*.t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(x))))) + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, y) * t.*.w))))) + @as(usize, @bitCast(@as(isize, @intCast(z)))))), ((t.*.t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(x))))) + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, y) * t.*.w))))) + @as(usize, @bitCast(@as(isize, @intCast(z)))), x + z, y, ' ', atr);
                                            }
                                        }
                                        if ((blk: {
                                            const ref = &spancount;
                                            const tmp = ref.*;
                                            ref.* += 1;
                                            break :blk tmp;
                                        }) >= spanextra) {
                                            outatr(if (help_is_utf8 != 0) utf8_map else locale_map, t.*.t, @ptrCast(@alignCast(((t.*.t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(x))))) + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, y) * t.*.w))))) + @as(usize, @bitCast(@as(isize, @intCast(z)))))), ((t.*.t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(x))))) + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, y) * t.*.w))))) + @as(usize, @bitCast(@as(isize, @intCast(z)))), x + z, y, ' ', atr);
                                            z += 1;
                                        }
                                        x += z - @as(c_int, 1);
                                        continue;
                                    },
                                    @as(c_int, 'i'), @as(c_int, 'I') => {
                                        atr ^= INVERSE;
                                        atr = (atr & ~((@as(c_int, 1023) << @intCast(BG_SHIFT)) | (@as(c_int, 1023) << @intCast(FG_SHIFT)))) | ((if ((atr & INVERSE) != 0) bg_stalin else bg_menu) & ((@as(c_int, 1023) << @intCast(BG_SHIFT)) | (@as(c_int, 1023) << @intCast(FG_SHIFT))));
                                        str += 1;
                                        x -= 1;
                                        continue;
                                    },
                                    @as(c_int, 'u'), @as(c_int, 'U') => {
                                        atr ^= UNDERLINE;
                                        str += 1;
                                        x -= 1;
                                        continue;
                                    },
                                    @as(c_int, 'd'), @as(c_int, 'D') => {
                                        atr ^= DIM;
                                        str += 1;
                                        x -= 1;
                                        continue;
                                    },
                                    @as(c_int, 'b'), @as(c_int, 'B') => {
                                        atr ^= BOLD;
                                        str += 1;
                                        x -= 1;
                                        continue;
                                    },
                                    @as(c_int, 'l'), @as(c_int, 'L') => {
                                        atr ^= ITALIC;
                                        str += 1;
                                        x -= 1;
                                        continue;
                                    },
                                    @as(c_int, 'f'), @as(c_int, 'F') => {
                                        atr ^= BLINK;
                                        str += 1;
                                        x -= 1;
                                        continue;
                                    },
                                    @as(c_int, 'z'), @as(c_int, 'Z') => {
                                        atr ^= DOUBLE_UNDERLINE;
                                        str += 1;
                                        x -= 1;
                                        continue;
                                    },
                                    @as(c_int, 's'), @as(c_int, 'S') => {
                                        atr ^= CROSSED_OUT;
                                        str += 1;
                                        x -= 1;
                                        continue;
                                    },
                                    @as(c_int, 0) => {
                                        x -= 1;
                                        continue;
                                    },
                                    else => {},
                                }
                            }
                            len = @divExact(@as(c_long, @bitCast(@intFromPtr(eol) -% @intFromPtr(str))), @sizeOf(u8));
                            if (help_is_utf8 != 0) {
                                c = utf8_decode_fwrd(&str, &len);
                            } else {
                                c = @as([*c]const u8, @ptrCast(@alignCast(blk: {
                                    const ref = &str;
                                    const tmp = ref.*;
                                    ref.* += 1;
                                    break :blk tmp;
                                }))).*;
                                len -= 1;
                            }
                            outatr(if (help_is_utf8 != 0) utf8_map else locale_map, t.*.t, @ptrCast(@alignCast((t.*.t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(x))))) + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, y) * t.*.w)))))), (t.*.t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(x))))) + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, y) * t.*.w)))), x, y, c, atr);
                            x += joe_wcwidth(if (help_is_utf8 != 0) @as(c_int, 1) else @intFromBool(!!(locale_map.*.type != 0)), c) - @as(c_int, 1);
                        }
                    }
                }
                atr = bg_help;
                t.*.t.*.updtab[@bitCast(@as(isize, @intCast(y)))] = 0;
                outatr_complete(t.*.t);
            }
            while ((@as(c_int, str.*) != 0) and (@as(c_int, str.*) != @as(c_int, '\n'))) {
                str += 1;
            }
            if (@as(c_int, str.*) == @as(c_int, '\n')) {
                str += 1;
            }
        }
    }
}
pub export fn help_on(arg_t: [*c]Screen) c_int {
    var t = arg_t;
    _ = &t;
    if (help_actual != null) {
        t.*.wind = help_actual.*.lines + skiptop;
        if ((t.*.h - t.*.wind) < @as(ptrdiff_t, FITMIN)) {
            t.*.wind = t.*.h - @as(ptrdiff_t, FITMIN);
        }
        if (t.*.wind <= @as(ptrdiff_t, skiptop)) {
            t.*.wind = skiptop;
            return -@as(c_int, 1);
        }
        wfit(t);
        _ = msetI(@ptrCast(@alignCast(t.*.t.*.updtab + @as(usize, @bitCast(@as(isize, @intCast(skiptop)))))), 1, t.*.wind - @as(ptrdiff_t, skiptop));
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
pub export fn u_help(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var new_help: [*c]struct_help = undefined;
    _ = &new_help;
    if ((w.*.huh != null) and (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = find_context_help(w.*.huh);
        new_help = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null))) {
        if (help_actual != new_help) {
            if (w.*.t.*.wind != @as(ptrdiff_t, skiptop)) {
                help_off(w.*.t);
            }
            help_actual = new_help;
        }
    }
    if (w.*.t.*.wind == @as(ptrdiff_t, skiptop)) {
        return help_on(w.*.t);
    } else {
        help_off(w.*.t);
        return 0;
    }
}
pub export fn u_help_next(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if ((help_actual != null) and (help_actual.*.next != null)) {
        if (w.*.t.*.wind != @as(ptrdiff_t, skiptop)) {
            help_off(w.*.t);
        }
        help_actual = help_actual.*.next;
        return help_on(w.*.t);
    } else {
        return -@as(c_int, 1);
    }
}
pub export fn u_help_prev(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if ((help_actual != null) and (help_actual.*.prev != null)) {
        if (w.*.t.*.wind != @as(ptrdiff_t, skiptop)) {
            help_off(w.*.t);
        }
        help_actual = help_actual.*.prev;
        return help_on(w.*.t);
    } else {
        return -@as(c_int, 1);
    }
}
