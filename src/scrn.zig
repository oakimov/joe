//! Screen / escape-sequence interface — replaces `joe/scrn.c`.
//!
//! Faithful C-ABI port of JOE's terminal screen buffer and attribute
//! emission. Generated from a goto-free rewrite of scrn.c (non-TERMINFO
//! path) via `zig translate-c`, then cleaned for the hybrid Zig+C build.

const std = @import("std");
const terminal = @import("terminal");
const tty = @import("tty.zig");
const ptrdiff_t = c_long;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn fprintf(stream: ?*anyopaque, fmt: [*c]const u8, ...) c_int;
pub extern fn fputs(s: [*c]const u8, stream: ?*anyopaque) c_int;
pub extern fn fflush(stream: ?*anyopaque) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub const off_t = i64;
pub const FILE = anyopaque;
pub extern var __stdinp: ?*FILE;
pub extern var __stdoutp: ?*FILE;
pub extern var __stderrp: ?*FILE;
pub const struct_hentry = extern struct {
    next: ptrdiff_t = 0,
    loc: ptrdiff_t = 0,
};
pub const struct_sortentry = extern struct {
    name: [*c]u8 = null,
    value: [*c]u8 = null,
};
pub const struct_cap = extern struct {
    tbuf: [*c]u8 = null,
    sort: [*c]struct_sortentry = null,
    sortlen: ptrdiff_t = 0,
    abuf: [*c]u8 = null,
    abufp: [*c]u8 = null,
    div: c_long = 0,
    baud: c_long = 0,
    pad: [*c]const u8 = null,
    out: ?*const fn (?*anyopaque, u8) callconv(.c) void = null,
    outptr: ?*anyopaque = null,
    dopadding: c_int = 0,
};
pub const CAP = struct_cap;
pub const struct_scrn = extern struct {
    cap: [*c]CAP = null,
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
pub const struct_charmap = extern struct {
    next: [*c]struct_charmap = null,
    name: [*c]const u8 = null,
    type: c_int = 0,
    is_punct: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    is_print: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    _pad: [2712]u8 = std.mem.zeroes([2712]u8),
};
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_calloc(nmemb: ptrdiff_t, size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_realloc(ptr: ?*anyopaque, size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn mmove(d: ?*anyopaque, s: ?*const anyopaque, sz: ptrdiff_t) ?*anyopaque;
pub extern fn msetI(d: ?*anyopaque, c: c_int, sz: ptrdiff_t) ?*anyopaque;
pub extern fn msetD(d: ?*anyopaque, c: ptrdiff_t, sz: ptrdiff_t) ?*anyopaque;
pub extern fn setcap(cap: [*c]CAP, baud: c_long, out: ?*const fn (?*anyopaque, u8) callconv(.c) void, outptr: ?*anyopaque) [*c]CAP;
pub extern fn jgetstr(cap: [*c]CAP, name: [*c]const u8) [*c]const u8;
pub extern fn getflag(cap: [*c]CAP, name: [*c]const u8) c_int;
pub extern fn getnum(cap: [*c]CAP, name: [*c]const u8) c_int;
pub extern fn rmcap(cap: [*c]CAP) void;
pub extern fn texec(cap: [*c]CAP, s: [*c]const u8, l: ptrdiff_t, a0: ptrdiff_t, a1: ptrdiff_t, a2: ptrdiff_t, a3: ptrdiff_t) void;
pub extern fn tcost(cap: [*c]CAP, s: [*c]const u8, l: ptrdiff_t, a0: ptrdiff_t, a1: ptrdiff_t, a2: ptrdiff_t, a3: ptrdiff_t) ptrdiff_t;
pub extern fn ttopen() void;
pub extern fn ttclose() void;
pub extern fn ttflsh() void;
pub extern fn ttputs(s: [*c]const u8) void;
pub extern fn ttgtsz(x: [*c]ptrdiff_t, y: [*c]ptrdiff_t) void;
pub extern fn signrm() void;
pub extern fn mouseopen() void;
pub extern fn mouseclose() void;
pub extern var tty_baud: c_long;
pub extern var obufp: ptrdiff_t;
pub extern var obufsiz: ptrdiff_t;
pub extern var obuf: [*c]u8;
pub extern var have: c_int;
pub extern var leave: c_int;
pub extern var locale_map: [*c]struct_charmap;
pub extern var dspasis: c_int;
pub extern var opt_mid: c_int;
pub extern var opt_left: c_int;
pub extern var opt_right: c_int;
pub extern var dostaupd: c_int;
pub extern fn sprintf(buf: [*c]u8, fmt: [*c]const u8, ...) c_int;
pub extern fn zicmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn ztoi(s: [*c]const u8) c_int;
pub extern fn unictrl(c: c_int) c_int;
pub extern fn utf8_putc(c: c_int) void;
pub const struct_utf8_sm = extern struct {
    buf: [8]u8 = std.mem.zeroes([8]u8),
    ptr: ptrdiff_t = 0,
    state: c_int = 0,
    accu: c_int = 0,
};
pub extern fn utf8_init(sm: [*c]struct_utf8_sm) void;
pub extern fn utf8_decode(sm: [*c]struct_utf8_sm, c: u8) c_int;
pub extern fn utf8_encode(buf: [*c]u8, c: c_int) ptrdiff_t;
pub extern fn to_uni(cset: [*c]struct_charmap, c: c_int) c_int;
pub extern fn from_uni(cset: [*c]struct_charmap, c: c_int) c_int;
pub extern fn joe_wcwidth(wide: c_int, c: c_int) c_int;
pub extern fn cclass_lookup(table: ?*const anyopaque, c: c_int) c_int;
// C header: `extern struct Cclass cclass_combining[1];` — object, not pointer var.
const cclass_combining: *anyopaque = @extern(*anyopaque, .{ .name = "cclass_combining" });
pub const COMPOSE = @as(c_int, 4);
pub const CONTEXT_COMMENT = @as(c_int, 1);
pub const CONTEXT_STRING = @as(c_int, 2);
pub const CONTEXT_MASK = CONTEXT_COMMENT + CONTEXT_STRING;
pub const DOUBLE_UNDERLINE = @as(c_int, 8);
pub const CROSSED_OUT = @as(c_int, 16);
pub const ITALIC = @as(c_int, 32);
pub const INVERSE = @as(c_int, 64);
pub const UNDERLINE = @as(c_int, 128);
pub const BOLD = @as(c_int, 256);
pub const BLINK = @as(c_int, 512);
pub const DIM = @as(c_int, 1024);
pub const AT_MASK = ((((((INVERSE + UNDERLINE) + BOLD) + BLINK) + DIM) + ITALIC) + DOUBLE_UNDERLINE) + CROSSED_OUT;
pub const BG_SHIFT = @as(c_int, 11);
pub const BG_VALUE = @as(c_int, 255) << BG_SHIFT;
pub const BG_NOT_DEFAULT = @as(c_int, 256) << BG_SHIFT;
pub const BG_TRUECOLOR = @as(c_int, 512) << BG_SHIFT;
pub const BG_MASK = @as(c_int, 1023) << BG_SHIFT;
pub const BG_DEFAULT = @as(c_int, 0) << BG_SHIFT;
pub const FG_SHIFT = @as(c_int, 21);
pub const FG_VALUE = @as(c_int, 255) << FG_SHIFT;
pub const FG_NOT_DEFAULT = @as(c_int, 256) << FG_SHIFT;
pub const FG_TRUECOLOR = @as(c_int, 512) << FG_SHIFT;
pub const FG_MASK = @as(c_int, 1023) << FG_SHIFT;
pub const FG_DEFAULT = @as(c_int, 0) << FG_SHIFT;
pub const BG_BLACK = BG_NOT_DEFAULT | (@as(c_int, 0) << BG_SHIFT);
pub const BG_RED = BG_NOT_DEFAULT | (@as(c_int, 1) << BG_SHIFT);
pub const BG_GREEN = BG_NOT_DEFAULT | (@as(c_int, 2) << BG_SHIFT);
pub const BG_YELLOW = BG_NOT_DEFAULT | (@as(c_int, 3) << BG_SHIFT);
pub const BG_BLUE = BG_NOT_DEFAULT | (@as(c_int, 4) << BG_SHIFT);
pub const BG_MAGENTA = BG_NOT_DEFAULT | (@as(c_int, 5) << BG_SHIFT);
pub const BG_CYAN = BG_NOT_DEFAULT | (@as(c_int, 6) << BG_SHIFT);
pub const BG_WHITE = BG_NOT_DEFAULT | (@as(c_int, 7) << BG_SHIFT);
pub const BG_BBLACK = BG_NOT_DEFAULT | (@as(c_int, 8) << BG_SHIFT);
pub const BG_BRED = BG_NOT_DEFAULT | (@as(c_int, 9) << BG_SHIFT);
pub const BG_BGREEN = BG_NOT_DEFAULT | (@as(c_int, 10) << BG_SHIFT);
pub const BG_BYELLOW = BG_NOT_DEFAULT | (@as(c_int, 11) << BG_SHIFT);
pub const BG_BBLUE = BG_NOT_DEFAULT | (@as(c_int, 12) << BG_SHIFT);
pub const BG_BMAGENTA = BG_NOT_DEFAULT | (@as(c_int, 13) << BG_SHIFT);
pub const BG_BCYAN = BG_NOT_DEFAULT | (@as(c_int, 14) << BG_SHIFT);
pub const BG_BWHITE = BG_NOT_DEFAULT | (@as(c_int, 15) << BG_SHIFT);
pub const FG_BWHITE = FG_NOT_DEFAULT | (@as(c_int, 15) << FG_SHIFT);
pub const FG_BCYAN = FG_NOT_DEFAULT | (@as(c_int, 14) << FG_SHIFT);
pub const FG_BMAGENTA = FG_NOT_DEFAULT | (@as(c_int, 13) << FG_SHIFT);
pub const FG_BBLUE = FG_NOT_DEFAULT | (@as(c_int, 12) << FG_SHIFT);
pub const FG_BYELLOW = FG_NOT_DEFAULT | (@as(c_int, 11) << FG_SHIFT);
pub const FG_BGREEN = FG_NOT_DEFAULT | (@as(c_int, 10) << FG_SHIFT);
pub const FG_BRED = FG_NOT_DEFAULT | (@as(c_int, 9) << FG_SHIFT);
pub const FG_BBLACK = FG_NOT_DEFAULT | (@as(c_int, 8) << FG_SHIFT);
pub const FG_WHITE = FG_NOT_DEFAULT | (@as(c_int, 7) << FG_SHIFT);
pub const FG_CYAN = FG_NOT_DEFAULT | (@as(c_int, 6) << FG_SHIFT);
pub const FG_MAGENTA = FG_NOT_DEFAULT | (@as(c_int, 5) << FG_SHIFT);
pub const FG_BLUE = FG_NOT_DEFAULT | (@as(c_int, 4) << FG_SHIFT);
pub const FG_YELLOW = FG_NOT_DEFAULT | (@as(c_int, 3) << FG_SHIFT);
pub const FG_GREEN = FG_NOT_DEFAULT | (@as(c_int, 2) << FG_SHIFT);
pub const FG_RED = FG_NOT_DEFAULT | (@as(c_int, 1) << FG_SHIFT);
pub const FG_BLACK = FG_NOT_DEFAULT | (@as(c_int, 0) << FG_SHIFT);

pub export fn clrins(arg_t: [*c]SCRN) c_int {
    var t = arg_t;
    _ = &t;
    if (t.*.ins != @as(c_int, 0)) {
        texec(t.*.cap, t.*.ei, 1, 0, 0, 0, 0);
        t.*.ins = 0;
    }
    return 0;
}
pub export fn cpos(arg_t: [*c]SCRN, arg_x: ptrdiff_t, arg_y: ptrdiff_t) c_int {
    var t = arg_t;
    _ = &t;
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    if (y == t.*.y) {
        if (((x > t.*.x) and ((x - t.*.x) < @as(ptrdiff_t, 4))) and !(t.*.ins != 0)) {
            var cs: [*c][4]c_int = (t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(t.*.x))))) + @as(usize, @bitCast(@as(isize, @intCast(t.*.co * t.*.y))));
            _ = &cs;
            var as: [*c]c_int = (t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(t.*.x))))) + @as(usize, @bitCast(@as(isize, @intCast(t.*.co * t.*.y))));
            _ = &as;
            while (true) {
                if ((cs[0][0] < @as(c_int, 32)) or (cs[0][0] >= @as(c_int, 127))) break;
                if (cs[0][1] != 0) break;
                if (as.* != t.*.attrib) {
                    _ = set_attr(t, as.*);
                }
                while (true) {
                    obuf[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &obufp;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = @as(u8, @bitCast(@as(i8, @truncate(cs[0][0]))));
                    if (obufp == obufsiz) {
                        ttflsh();
                    }
                    if (!false) break;
                }
                cs += 1;
                as += 1;
                t.*.x += 1;
                if (!(x != t.*.x)) break;
            }
        }
        if (x == t.*.x) return 0;
    }
    if (!(t.*.ms != 0) and ((t.*.attrib & ((INVERSE | UNDERLINE) | (@as(c_int, 256) << @intCast(BG_SHIFT)))) != 0)) {
        _ = set_attr(t, t.*.attrib & ~((INVERSE | UNDERLINE) | (@as(c_int, 1023) << @intCast(BG_SHIFT))));
    }
    if ((y < t.*.top) or (y >= t.*.bot)) {
        setregn(t, 0, t.*.li);
    }
    cposs(t, x, y);
    return 0;
}
pub export fn nresize(arg_t: [*c]SCRN, arg_w: ptrdiff_t, arg_h: ptrdiff_t) c_int {
    var t = arg_t;
    _ = &t;
    var w = arg_w;
    _ = &w;
    var h = arg_h;
    _ = &h;
    if (h < @as(ptrdiff_t, skiptop + @as(c_int, 1))) {
        h = skiptop + @as(c_int, 1);
    }
    if (w < @as(ptrdiff_t, 8)) {
        w = 8;
    }
    if (!(t.*.xn != 0)) {
        w -= 1;
    }
    if ((h == t.*.li) and (w == t.*.co)) return 0;
    t.*.li = h;
    t.*.co = w;
    if (t.*.sary != null) {
        joe_free(@ptrCast(@alignCast(t.*.sary)));
    }
    if (t.*.updtab != null) {
        joe_free(@ptrCast(@alignCast(t.*.updtab)));
    }
    if (t.*.scrn != null) {
        joe_free(@ptrCast(@alignCast(t.*.scrn)));
    }
    if (t.*.attr != null) {
        joe_free(@ptrCast(@alignCast(t.*.attr)));
    }
    if (t.*.compose != null) {
        joe_free(@ptrCast(@alignCast(t.*.compose)));
    }
    if (t.*.ofst != null) {
        joe_free(@ptrCast(@alignCast(t.*.ofst)));
    }
    if (t.*.ary != null) {
        joe_free(@ptrCast(@alignCast(t.*.ary)));
    }
    t.*.scrn = @ptrCast(@alignCast(joe_malloc((t.*.li * t.*.co) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([4]c_int))))))));
    t.*.attr = @ptrCast(@alignCast(joe_malloc((t.*.li * t.*.co) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))));
    t.*.sary = @ptrCast(@alignCast(joe_calloc(t.*.li, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(ptrdiff_t))))))));
    t.*.updtab = @ptrCast(@alignCast(joe_malloc(t.*.li * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))));
    t.*.compose = @ptrCast(@alignCast(joe_malloc(t.*.co * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))));
    t.*.ofst = @ptrCast(@alignCast(joe_malloc(t.*.co * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(ptrdiff_t))))))));
    t.*.ary = @ptrCast(@alignCast(joe_malloc(t.*.co * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_hentry))))))));
    nredraw(t);
    zigScrnSwapResize(t);
    return 1;
}
pub export fn nredraw(arg_t: [*c]SCRN) void {
    var t = arg_t;
    _ = &t;
    dostaupd = 1;
    mfill(t.*.scrn, ' ', t.*.co * @as(ptrdiff_t, skiptop));
    _ = msetI(@ptrCast(@alignCast(t.*.attr)), bg_text, t.*.co * @as(ptrdiff_t, skiptop));
    mfill(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, skiptop) * t.*.co)))), -@as(c_int, 1), (t.*.li - @as(ptrdiff_t, skiptop)) * t.*.co);
    _ = msetI(@ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, skiptop) * t.*.co)))))), bg_text, (t.*.li - @as(ptrdiff_t, skiptop)) * t.*.co);
    _ = msetD(@ptrCast(@alignCast(t.*.sary)), 0, t.*.li);
    _ = msetI(@ptrCast(@alignCast(t.*.updtab + @as(usize, @bitCast(@as(isize, @intCast(skiptop)))))), -@as(c_int, 1), t.*.li - @as(ptrdiff_t, skiptop));
    t.*.x = -@as(c_int, 1);
    t.*.y = -@as(c_int, 1);
    t.*.top = t.*.li;
    t.*.bot = 0;
    t.*.attrib = -@as(c_int, 1);
    t.*.ins = -@as(c_int, 1);
    _ = set_attr(t, bg_text);
    _ = clrins(t);
    setregn(t, 0, t.*.li);
    if (!(skiptop != 0)) {}
}
pub export var bg_text: c_int = 0;
pub export var skiptop: c_int = 0;
pub export var env_lines: c_int = 0;
pub export var env_columns: c_int = 0;
pub export var notite: c_int = 0;
pub export var brpaste: c_int = 0;
pub export var nolinefeeds: c_int = 0;
pub export var opt_usetabs: c_int = 0;
pub export var assume_color: c_int = 0;
pub export var assume_256color: c_int = 0;
pub const xlatc: [256]u8 = [256]u8{
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    90,
    91,
    92,
    93,
    94,
    95,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50,
    51,
    52,
    53,
    54,
    55,
    56,
    57,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    90,
    91,
    92,
    93,
    94,
    95,
    96,
    97,
    98,
    99,
    100,
    101,
    102,
    103,
    104,
    105,
    106,
    107,
    108,
    109,
    110,
    111,
    112,
    113,
    114,
    115,
    116,
    117,
    118,
    119,
    120,
    121,
    122,
    123,
    124,
    125,
    126,
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    90,
    91,
    92,
    93,
    94,
    95,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50,
    51,
    52,
    53,
    54,
    55,
    56,
    57,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    90,
    91,
    92,
    93,
    94,
    95,
    96,
    97,
    98,
    99,
    100,
    101,
    102,
    103,
    104,
    105,
    106,
    107,
    108,
    109,
    110,
    111,
    112,
    113,
    114,
    115,
    116,
    117,
    118,
    119,
    120,
    121,
    122,
    123,
    124,
    125,
    126,
    63,
};
pub const xlata: [256]c_int = [256]c_int{
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    UNDERLINE,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE + UNDERLINE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE,
    INVERSE + UNDERLINE,
};
pub fn mfill(arg_dest: [*c][4]c_int, arg_val: c_int, arg_count: ptrdiff_t) callconv(.c) void {
    var dest = arg_dest;
    _ = &dest;
    var val = arg_val;
    _ = &val;
    var count = arg_count;
    _ = &count;
    var x: ptrdiff_t = undefined;
    _ = &x;
    while ((blk: {
        const ref = &count;
        const tmp = ref.*;
        ref.* -= 1;
        break :blk tmp;
    }) != 0) {
        dest[0][0] = val;
        {
            x = 1;
            while (x != @as(ptrdiff_t, COMPOSE)) : (x += 1) {
                dest[0][@bitCast(@as(isize, @intCast(x)))] = 0;
            }
        }
        dest += 1;
    }
}
pub fn fixupcursor(arg_t: [*c]SCRN) callconv(.c) void {
    var t = arg_t;
    _ = &t;
    if (t.*.x == t.*.co) {
        texec(t.*.cap, t.*.cr, 1, 0, 0, 0, 0);
        t.*.x = 0;
    }
}
pub export fn set_attr(arg_t: [*c]SCRN, arg_c: c_int) c_int {
    var t = arg_t;
    _ = &t;
    var c = arg_c;
    _ = &c;
    var e: c_int = undefined;
    _ = &e;
    e = ((((((((((INVERSE + UNDERLINE) + BOLD) + BLINK) + DIM) + ITALIC) + DOUBLE_UNDERLINE) + CROSSED_OUT) | (@as(c_int, 256) << @intCast(FG_SHIFT))) | (@as(c_int, 256) << @intCast(BG_SHIFT))) & t.*.attrib) & ~c;
    if (e != 0) {
        if (t.*.me != null) {
            texec(t.*.cap, t.*.me, 1, 0, 0, 0, 0);
        } else {
            if (t.*.ue != null) {
                texec(t.*.cap, t.*.ue, 1, 0, 0, 0, 0);
            }
            if (t.*.se != null) {
                texec(t.*.cap, t.*.se, 1, 0, 0, 0, 0);
            }
            if (t.*.ZR != null) {
                texec(t.*.cap, t.*.ZR, 1, 0, 0, 0, 0);
            }
        }
        t.*.attrib = 0;
    }
    e = c & ~t.*.attrib;
    if ((e & INVERSE) != 0) {
        if (t.*.mr != null) {
            texec(t.*.cap, t.*.mr, 1, 0, 0, 0, 0);
        } else if (t.*.so != null) {
            texec(t.*.cap, t.*.so, 1, 0, 0, 0, 0);
        }
    }
    if ((e & UNDERLINE) != 0) if (t.*.us != null) {
        texec(t.*.cap, t.*.us, 1, 0, 0, 0, 0);
    };
    if ((e & DOUBLE_UNDERLINE) != 0) if (t.*.dunderline != null) {
        texec(t.*.cap, t.*.dunderline, 1, 0, 0, 0, 0);
    };
    if ((e & CROSSED_OUT) != 0) if (t.*.stricken != null) {
        texec(t.*.cap, t.*.stricken, 1, 0, 0, 0, 0);
    };
    if ((e & BLINK) != 0) if (t.*.mb != null) {
        texec(t.*.cap, t.*.mb, 1, 0, 0, 0, 0);
    };
    if ((e & BOLD) != 0) if (t.*.md != null) {
        texec(t.*.cap, t.*.md, 1, 0, 0, 0, 0);
    };
    if ((e & DIM) != 0) if (t.*.mh != null) {
        texec(t.*.cap, t.*.mh, 1, 0, 0, 0, 0);
    };
    if ((e & ITALIC) != 0) if (t.*.ZH != null) {
        texec(t.*.cap, t.*.ZH, 1, 0, 0, 0, 0);
    };
    if ((t.*.attrib & (@as(c_int, 1023) << @intCast(FG_SHIFT))) != (c & (@as(c_int, 1023) << @intCast(FG_SHIFT)))) {
        if (t.*.Sf != null) {
            var color: c_int = (c & (@as(c_int, 255) << @intCast(FG_SHIFT))) >> @intCast(FG_SHIFT);
            _ = &color;
            if ((c & (@as(c_int, 512) << @intCast(FG_SHIFT))) != 0) {
                if (((t.*.truecolor != 0) and (t.*.palette != null)) and (t.*.palette[@bitCast(@as(isize, @intCast(color)))] >= @as(c_int, 0))) {
                    var bf: [32]u8 = undefined;
                    _ = &bf;
                    var rgb: c_int = t.*.palette[@bitCast(@as(isize, @intCast(color)))];
                    _ = &rgb;
                    _ = snprintf(@ptrCast(@alignCast(&bf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))))), "\x1b[38;2;%d;%d;%dm", (rgb >> @intCast(@as(c_int, 16))) & @as(c_int, 255), (rgb >> @intCast(@as(c_int, 8))) & @as(c_int, 255), rgb & @as(c_int, 255));
                    ttputs(@ptrCast(@alignCast(&bf)));
                }
            } else if ((t.*.assume_256 != 0) and (color >= t.*.Co)) {
                var bf: [32]u8 = undefined;
                _ = &bf;
                _ = snprintf(@ptrCast(@alignCast(&bf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))))), "\x1b[38;5;%dm", color);
                ttputs(@ptrCast(@alignCast(&bf)));
            } else {
                if ((t.*.Co & (t.*.Co - @as(c_int, 1))) != 0) {
                    texec(t.*.cap, t.*.Sf, 1, @rem(color, t.*.Co), 0, 0, 0);
                } else {
                    texec(t.*.cap, t.*.Sf, 1, color & (t.*.Co - @as(c_int, 1)), 0, 0, 0);
                }
            }
        }
    }
    if ((t.*.attrib & (@as(c_int, 1023) << @intCast(BG_SHIFT))) != (c & (@as(c_int, 1023) << @intCast(BG_SHIFT)))) {
        if (t.*.Sb != null) {
            var color: c_int = (c & (@as(c_int, 255) << @intCast(BG_SHIFT))) >> @intCast(BG_SHIFT);
            _ = &color;
            if ((c & (@as(c_int, 512) << @intCast(BG_SHIFT))) != 0) {
                if (((t.*.truecolor != 0) and (t.*.palette != null)) and (t.*.palette[@bitCast(@as(isize, @intCast(color)))] >= @as(c_int, 0))) {
                    var bf: [32]u8 = undefined;
                    _ = &bf;
                    var rgb: c_int = t.*.palette[@bitCast(@as(isize, @intCast(color)))];
                    _ = &rgb;
                    _ = snprintf(@ptrCast(@alignCast(&bf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))))), "\x1b[48;2;%d;%d;%dm", (rgb >> @intCast(@as(c_int, 16))) & @as(c_int, 255), (rgb >> @intCast(@as(c_int, 8))) & @as(c_int, 255), rgb & @as(c_int, 255));
                    ttputs(@ptrCast(@alignCast(&bf)));
                }
            } else if ((t.*.assume_256 != 0) and (color >= t.*.Co)) {
                var bf: [32]u8 = undefined;
                _ = &bf;
                _ = snprintf(@ptrCast(@alignCast(&bf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))))), "\x1b[48;5;%dm", color);
                ttputs(@ptrCast(@alignCast(&bf)));
            } else {
                if ((t.*.Co & (t.*.Co - @as(c_int, 1))) != 0) {
                    texec(t.*.cap, t.*.Sb, 1, @rem(color, t.*.Co), 0, 0, 0);
                } else {
                    texec(t.*.cap, t.*.Sb, 1, color & (t.*.Co - @as(c_int, 1)), 0, 0, 0);
                }
            }
        }
    }
    t.*.attrib = c;
    return 0;
}
pub export var outatr_state: c_int = 0;
pub export var outatr_scrn: [*c][4]c_int = null;
pub export var outatr_attrf: [*c]c_int = null;
pub export var outatr_build: [4]c_int = std.mem.zeroes([4]c_int);
pub export var outatr_xx: ptrdiff_t = 0;
pub export var outatr_yy: ptrdiff_t = 0;
pub export var outatr_ofst: ptrdiff_t = 0;
pub export var outatr_wid: c_int = 0;
pub export var outatr_uni_ctrl: c_int = 0;
pub export var outatr_a: c_int = 0;
pub export fn outatr_complete(arg_t: [*c]SCRN) void {
    var t = arg_t;
    _ = &t;
    if (outatr_state == @as(c_int, 1)) {
        var x: ptrdiff_t = undefined;
        _ = &x;
        {
            x = 0;
            while (x != @as(ptrdiff_t, COMPOSE)) : (x += 1) if (outatr_scrn[@as(c_int, 0)][@bitCast(@as(isize, @intCast(x)))] != outatr_build[@bitCast(@as(isize, @intCast(x)))]) break;
        }
        if ((x != @as(ptrdiff_t, COMPOSE)) or (outatr_attrf.* != outatr_a)) {
            var buf: [16]u8 = undefined;
            _ = &buf;
            {
                x = 0;
                while (x != @as(ptrdiff_t, COMPOSE)) : (x += 1) {
                    outatr_scrn[@as(c_int, 0)][@bitCast(@as(isize, @intCast(x)))] = outatr_build[@bitCast(@as(isize, @intCast(x)))];
                }
            }
            outatr_attrf.* = outatr_a;
            // Hybrid scrn swap: keep shadow buffers, defer emission to Zig flush.
            if (zig_screen_swap_enabled != 0) {
                t.*.x = outatr_xx + @as(ptrdiff_t, outatr_wid);
                t.*.y = outatr_yy;
                while (outatr_wid > @as(c_int, 1)) {
                    (blk: {
                        const ref = &outatr_scrn;
                        ref.* += 1;
                        break :blk ref.*;
                    })[0][0] = -@as(c_int, 1);
                    (blk: {
                        const ref = &outatr_attrf;
                        ref.* += 1;
                        break :blk ref.*;
                    }).* = 0;
                    outatr_wid -= 1;
                }
            } else {
            if (t.*.ins != 0) {
                _ = clrins(t);
            }
            if ((t.*.x != outatr_xx) or (t.*.y != outatr_yy)) {
                _ = cpos(t, outatr_xx, outatr_yy);
            }
            if (t.*.attrib != outatr_a) {
                _ = set_attr(t, outatr_a);
            }
            if (outatr_uni_ctrl != 0) {
                _ = sprintf(@ptrCast(@alignCast(&buf)), "<%X>", outatr_build[@as(c_int, 0)]);
                ttputs(@ptrCast(@alignCast(&buf)));
            } else {
                {
                    x = 0;
                    while ((x != @as(ptrdiff_t, COMPOSE)) and (outatr_build[@bitCast(@as(isize, @intCast(x)))] != 0)) : (x += 1) {
                        _ = utf8_encode(@ptrCast(@alignCast(&buf)), outatr_build[@bitCast(@as(isize, @intCast(x)))]);
                        ttputs(@ptrCast(@alignCast(&buf)));
                    }
                }
            }
            t.*.x += outatr_wid;
            while (outatr_wid > @as(c_int, 1)) {
                (blk: {
                    const ref = &outatr_scrn;
                    ref.* += 1;
                    break :blk ref.*;
                })[0][0] = -@as(c_int, 1);
                (blk: {
                    const ref = &outatr_attrf;
                    ref.* += 1;
                    break :blk ref.*;
                }).* = 0;
                outatr_wid -= 1;
            }
            }
        }
    }
    outatr_state = 0;
}
pub export fn outatr(arg_map: [*c]struct_charmap, arg_t: [*c]SCRN, arg_scrn_1: [*c][4]c_int, arg_attrf: [*c]c_int, arg_xx: ptrdiff_t, arg_yy: ptrdiff_t, arg_c: c_int, arg_a: c_int) void {
    var map = arg_map;
    _ = &map;
    var t = arg_t;
    _ = &t;
    var scrn_1 = arg_scrn_1;
    _ = &scrn_1;
    var attrf = arg_attrf;
    _ = &attrf;
    var xx = arg_xx;
    _ = &xx;
    var yy = arg_yy;
    _ = &yy;
    var c = arg_c;
    _ = &c;
    var a = arg_a;
    _ = &a;
    if (c < @as(c_int, 0)) {
        c += 256;
    }
    if (map.*.type != 0) if (locale_map.*.type != 0) {
        if (cclass_lookup(cclass_combining, c) != 0) {
            if (!(outatr_state != 0)) {
                outatr_state = 2;
            } else if (outatr_state == @as(c_int, 1)) {
                if (outatr_ofst != @as(ptrdiff_t, COMPOSE)) {
                    outatr_build[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &outatr_ofst;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = c;
                } else {
                    var buf: [16]u8 = undefined;
                    _ = &buf;
                    outatr_scrn[@as(c_int, 0)][@as(c_int, 0)] = -@as(c_int, 1);
                    outatr_complete(t);
                    _ = utf8_encode(@ptrCast(@alignCast(&buf)), c);
                    if (zig_screen_swap_enabled == 0) ttputs(@ptrCast(@alignCast(&buf)));
                    outatr_state = 3;
                }
            } else if (outatr_state == @as(c_int, 3)) {
                var buf: [16]u8 = undefined;
                _ = &buf;
                _ = utf8_encode(@ptrCast(@alignCast(&buf)), c);
                if (zig_screen_swap_enabled == 0) ttputs(@ptrCast(@alignCast(&buf)));
            }
        } else {
            var x: ptrdiff_t = undefined;
            _ = &x;
            if (outatr_state != 0) {
                outatr_complete(t);
            }
            outatr_uni_ctrl = 0;
            if (c < @as(c_int, 32)) {
                c = c + @as(c_int, '@');
                a ^= UNDERLINE;
            } else if (c == @as(c_int, 127)) {
                c = '?';
                a ^= UNDERLINE;
            } else if (unictrl(c) != 0) {
                a ^= UNDERLINE;
                outatr_uni_ctrl = 1;
            }
            outatr_wid = joe_wcwidth(1, c);
            outatr_state = 1;
            outatr_scrn = scrn_1;
            outatr_attrf = attrf;
            outatr_xx = xx;
            outatr_yy = yy;
            outatr_ofst = 1;
            outatr_a = a;
            outatr_build[@as(c_int, 0)] = c;
            {
                x = 1;
                while (x != @as(ptrdiff_t, COMPOSE)) : (x += 1) {
                    outatr_build[@bitCast(@as(isize, @intCast(x)))] = 0;
                }
            }
        }
    } else {
        if (((c >= @as(c_int, 32)) and (c <= @as(c_int, 126))) or (c >= @as(c_int, 160))) {
            if (unictrl(c) != 0) {
                a ^= UNDERLINE;
            }
            c = from_uni(locale_map, c);
            if (c == -@as(c_int, 1)) {
                c = '?';
            }
        }
        if (!(locale_map.*.is_print.?(locale_map, c) != 0) and !((dspasis != 0) and (c >= @as(c_int, 128)))) {
            a ^= xlata[@bitCast(@as(isize, @intCast(c)))];
            c = xlatc[@bitCast(@as(isize, @intCast(c)))];
        }
        if ((scrn_1[0][0] == c) and (attrf.* == a)) return;
        scrn_1[0][0] = c;
        attrf.* = a;
        if (t.*.ins != 0) {
            _ = clrins(t);
        }
        if ((t.*.x != xx) or (t.*.y != yy)) {
            _ = cpos(t, xx, yy);
        }
        if (t.*.attrib != a) {
            _ = set_attr(t, a);
        }
        while (true) {
            obuf[
                @bitCast(@as(isize, @intCast(blk: {
                    const ref = &obufp;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                })))
            ] = @as(u8, @bitCast(@as(i8, @truncate(c))));
            if (obufp == obufsiz) {
                ttflsh();
            }
            if (!false) break;
        }
        t.*.x += 1;
    } else if (!(locale_map.*.type != 0)) {
        if (!(locale_map.*.is_print.?(locale_map, c) != 0) and !((dspasis != 0) and (c >= @as(c_int, 128)))) {
            a ^= xlata[@bitCast(@as(isize, @intCast(c)))];
            c = xlatc[@bitCast(@as(isize, @intCast(c)))];
        }
        if ((scrn_1[0][0] == c) and (attrf.* == a)) return;
        scrn_1[0][0] = c;
        attrf.* = a;
        if (zig_screen_swap_enabled != 0) {
            t.*.x = xx + 1;
            t.*.y = yy;
        } else {
        if (t.*.ins != 0) {
            _ = clrins(t);
        }
        if ((t.*.x != xx) or (t.*.y != yy)) {
            _ = cpos(t, xx, yy);
        }
        if (t.*.attrib != a) {
            _ = set_attr(t, a);
        }
        while (true) {
            obuf[
                @bitCast(@as(isize, @intCast(blk: {
                    const ref = &obufp;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                })))
            ] = @as(u8, @bitCast(@as(i8, @truncate(c))));
            if (obufp == obufsiz) {
                ttflsh();
            }
            if (!false) break;
        }
        t.*.x += 1;
        }
    } else {
        var buf: [16]u8 = undefined;
        _ = &buf;
        var wid: c_int = undefined;
        _ = &wid;
        if (!((dspasis != 0) and (c >= @as(c_int, 128))) and !(map.*.is_print.?(map, c) != 0)) {
            a ^= xlata[@bitCast(@as(isize, @intCast(c)))];
            c = xlatc[@bitCast(@as(isize, @intCast(c)))];
        }
        c = to_uni(map, c);
        if (c == -@as(c_int, 1)) {
            c = '?';
        }
        _ = utf8_encode(@ptrCast(@alignCast(&buf)), c);
        if ((scrn_1[0][0] == c) and (attrf.* == a)) return;
        wid = joe_wcwidth(0, c);
        scrn_1[0][0] = c;
        attrf.* = a;
        if (zig_screen_swap_enabled != 0) {
            t.*.x = xx + @as(ptrdiff_t, wid);
            t.*.y = yy;
            while (wid > @as(c_int, 1)) {
                (blk: {
                    const ref = &scrn_1;
                    ref.* += 1;
                    break :blk ref.*;
                })[0][0] = -@as(c_int, 1);
                (blk: {
                    const ref = &attrf;
                    ref.* += 1;
                    break :blk ref.*;
                }).* = 0;
                wid -= 1;
            }
        } else {
        if (t.*.ins != 0) {
            _ = clrins(t);
        }
        if ((t.*.x != xx) or (t.*.y != yy)) {
            _ = cpos(t, xx, yy);
        }
        if (t.*.attrib != a) {
            _ = set_attr(t, a);
        }
        ttputs(@ptrCast(@alignCast(&buf)));
        t.*.x += wid;
        while (wid > @as(c_int, 1)) {
            (blk: {
                const ref = &scrn_1;
                ref.* += 1;
                break :blk ref.*;
            })[0][0] = -@as(c_int, 1);
            (blk: {
                const ref = &attrf;
                ref.* += 1;
                break :blk ref.*;
            }).* = 0;
            wid -= 1;
        }
        }
    }
}
pub fn setregn(arg_t: [*c]SCRN, arg_top: ptrdiff_t, arg_bot: ptrdiff_t) callconv(.c) void {
    var t = arg_t;
    _ = &t;
    var top = arg_top;
    _ = &top;
    var bot = arg_bot;
    _ = &bot;
    if (!(t.*.cs != null)) {
        t.*.top = top;
        t.*.bot = bot;
        return;
    }
    if ((t.*.top != top) or (t.*.bot != bot)) {
        t.*.top = top;
        t.*.bot = bot;
        texec(t.*.cap, t.*.cs, 1, top, bot - @as(ptrdiff_t, 1), 0, 0);
        t.*.x = -@as(c_int, 1);
        t.*.y = -@as(c_int, 1);
    }
}
pub export fn eraeol(arg_t: [*c]SCRN, arg_x: ptrdiff_t, arg_y: ptrdiff_t, arg_atr: c_int) c_int {
    var t = arg_t;
    _ = &t;
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    var atr = arg_atr;
    _ = &atr;
    var s: [*c][4]c_int = undefined;
    _ = &s;
    var ss: [*c][4]c_int = undefined;
    _ = &ss;
    var a: [*c]c_int = undefined;
    _ = &a;
    var aa: [*c]c_int = undefined;
    _ = &aa;
    var w: ptrdiff_t = t.*.co - x;
    _ = &w;
    if (w <= @as(ptrdiff_t, 0)) return 0;
    s = (t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(y * t.*.co))))) + @as(usize, @bitCast(@as(isize, @intCast(x))));
    a = (t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(y * t.*.co))))) + @as(usize, @bitCast(@as(isize, @intCast(x))));
    ss = s + @as(usize, @bitCast(@as(isize, @intCast(w))));
    aa = a + @as(usize, @bitCast(@as(isize, @intCast(w))));
    while (true) {
        ss -= 1;
        if (ss[0][0] != (if (ss == s) @as(c_int, '\n') else @as(c_int, ' '))) {
            ss += 1;
            break;
        } else if ((blk: {
            const ref = &aa;
            ref.* -= 1;
            break :blk ref.*;
        }).* != atr) {
            ss += 1;
            aa += 1;
            break;
        }
        if (!(ss != s)) break;
    }
    if (s != ss) {
        if (zig_screen_swap_enabled != 0) {
            mfill(s, ' ', w);
            _ = msetI(@ptrCast(@alignCast(a)), atr, w);
            s[0][0] = '\n';
            return 0;
        }
        if (t.*.ce != null) {
            _ = cpos(t, x, y);
            if (t.*.attrib != atr) {
                _ = set_attr(t, atr);
            }
            texec(t.*.cap, t.*.ce, 1, 0, 0, 0, 0);
            mfill(s, ' ', w);
            _ = msetI(@ptrCast(@alignCast(a)), atr, w);
            s[0][0] = '\n';
        } else {
            if (t.*.ins != 0) {
                _ = clrins(t);
            }
            if ((t.*.x != x) or (t.*.y != y)) {
                _ = cpos(t, x, y);
            }
            if (t.*.attrib != atr) {
                _ = set_attr(t, atr);
            }
            s[0][0] = '\n';
            a.* = atr;
            while (true) {
                obuf[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &obufp;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = @bitCast(@as(i8, @truncate(@as(c_int, ' '))));
                if (obufp == obufsiz) {
                    ttflsh();
                }
                if (!false) break;
            }
            t.*.x += 1;
            s += 1;
            a += 1;
            while (s != ss) {
                s[0][0] = ' ';
                a.* = atr;
                while (true) {
                    obuf[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &obufp;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = @bitCast(@as(i8, @truncate(@as(c_int, ' '))));
                    if (obufp == obufsiz) {
                        ttflsh();
                    }
                    if (!false) break;
                }
                t.*.x += 1;
                s += 1;
                a += 1;
            }
        }
    }
    return 0;
}
pub fn out(arg_t: ?*anyopaque, arg_c: u8) callconv(.c) void {
    var t = arg_t;
    _ = &t;
    var c = arg_c;
    _ = &c;
    while (true) {
        obuf[
            @bitCast(@as(isize, @intCast(blk: {
                const ref = &obufp;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            })))
        ] = c;
        if (obufp == obufsiz) {
            ttflsh();
        }
        if (!false) break;
    }
}
pub export fn nopen(arg_cap_1: [*c]CAP) [*c]SCRN {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var t: [*c]SCRN = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(SCRN))))))));
    _ = &t;
    var x: ptrdiff_t = undefined;
    _ = &x;
    var y: ptrdiff_t = undefined;
    _ = &y;
    var co: ptrdiff_t = undefined;
    _ = &co;
    var li: ptrdiff_t = undefined;
    _ = &li;
    var ansiish: c_int = undefined;
    _ = &ansiish;
    ttopen();
    t.*.cap = cap_1;
    _ = setcap(cap_1, tty_baud, out, null);
    li = getnum(t.*.cap, "li");
    if (li < @as(ptrdiff_t, 1)) {
        li = 24;
    }
    co = getnum(t.*.cap, "co");
    if (co < @as(ptrdiff_t, 2)) {
        co = 80;
    }
    x = blk: {
        const tmp = @as(ptrdiff_t, 0);
        y = tmp;
        break :blk tmp;
    };
    ttgtsz(&x, &y);
    if ((x > @as(ptrdiff_t, 7)) and (y > @as(ptrdiff_t, 3))) {
        li = y;
        co = x;
    }
    t.*.co = blk: {
        const tmp = @as(ptrdiff_t, -@as(c_int, 1));
        t.*.li = tmp;
        break :blk tmp;
    };
    t.*.haz = getflag(t.*.cap, "hz");
    t.*.os = getflag(t.*.cap, "os");
    t.*.eo = getflag(t.*.cap, "eo");
    if (getflag(t.*.cap, "hc") != 0) {
        t.*.os = 1;
    }
    if ((t.*.os != 0) or (getflag(t.*.cap, "ul") != 0)) {
        t.*.ul = 1;
    } else {
        t.*.ul = 0;
    }
    t.*.xn = getflag(t.*.cap, "xn");
    t.*.am = getflag(t.*.cap, "am");
    if (notite != 0) {
        t.*.ti = null;
    } else {
        t.*.ti = jgetstr(t.*.cap, "ti");
    }
    t.*.cl = jgetstr(t.*.cap, "cl");
    t.*.cd = jgetstr(t.*.cap, "cd");
    if (notite != 0) {
        t.*.te = null;
    } else {
        t.*.te = jgetstr(t.*.cap, "te");
    }
    t.*.ut = getflag(t.*.cap, "ut");
    t.*.Sb = jgetstr(t.*.cap, "AB");
    if (!(t.*.Sb != null)) {
        t.*.Sb = jgetstr(t.*.cap, "Sb");
    }
    t.*.Sf = jgetstr(t.*.cap, "AF");
    if (!(t.*.Sf != null)) {
        t.*.Sf = jgetstr(t.*.cap, "Sf");
    }
    t.*.Co = getnum(t.*.cap, "Co");
    if (t.*.Co == -@as(c_int, 1)) {
        t.*.Co = 8;
    }
    t.*.Tc = getflag(t.*.cap, "Tc");
    t.*.mb = null;
    t.*.md = null;
    t.*.mh = null;
    t.*.mr = null;
    t.*.stricken = null;
    t.*.dunderline = null;
    t.*.avattr = 0;
    t.*.me = jgetstr(t.*.cap, "me");
    if (t.*.me != null) {
        if ((blk: {
            const tmp = jgetstr(t.*.cap, "mb");
            t.*.mb = tmp;
            break :blk tmp;
        }) != null) {
            t.*.avattr |= BLINK;
        }
        if ((blk: {
            const tmp = jgetstr(t.*.cap, "md");
            t.*.md = tmp;
            break :blk tmp;
        }) != null) {
            t.*.avattr |= BOLD;
        }
        if ((blk: {
            const tmp = jgetstr(t.*.cap, "mh");
            t.*.mh = tmp;
            break :blk tmp;
        }) != null) {
            t.*.avattr |= DIM;
        }
        if ((blk: {
            const tmp = jgetstr(t.*.cap, "mr");
            t.*.mr = tmp;
            break :blk tmp;
        }) != null) {
            t.*.avattr |= INVERSE;
        }
    }
    ansiish = @intFromBool((((t.*.md != null) and (@as(c_int, t.*.md[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, t.*.md[@as(c_int, 1)]) == @as(c_int, 'E'))) and (@as(c_int, t.*.md[@as(c_int, 2)]) == @as(c_int, '[')));
    if (ansiish != 0) {
        t.*.stricken = "\x1b[9m";
    }
    if (ansiish != 0) {
        t.*.dunderline = "\x1b[21m";
    }
    if ((ansiish != 0) and (brpaste != 0)) {
        t.*.brp = "\\E[?2004h";
        t.*.bre = "\\E[?2004l";
    } else {
        t.*.brp = blk: {
            const tmp = @as([*c]const u8, null);
            t.*.bre = tmp;
            break :blk tmp;
        };
    }
    if ((assume_color != 0) or (assume_256color != 0)) {
        if ((ansiish != 0) and !(t.*.Sf != null)) {
            t.*.ut = 1;
            t.*.Sf = "\\E[3%dm";
            t.*.Sb = "\\E[4%dm";
            t.*.Co = 8;
        }
    }
    t.*.assume_256 = 0;
    if ((assume_256color != 0) and (t.*.Co < @as(c_int, 256))) {
        if (ansiish != 0) {
            t.*.assume_256 = 1;
        }
    }
    {
        var s: [*c]u8 = getenv("COLORTERM");
        _ = &s;
        t.*.truecolor = @intFromBool((t.*.Tc != 0) or ((s != null) and (!(zicmp(s, "truecolor") != 0) or !(zicmp(s, "24bit") != 0))));
        t.*.palette = null;
    }
    t.*.so = null;
    t.*.se = null;
    if (((getnum(t.*.cap, "sg") <= @as(c_int, 0)) and !(t.*.mr != null)) and (jgetstr(t.*.cap, "se") != null)) {
        if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(blk: {
            const tmp = jgetstr(t.*.cap, "so");
            t.*.so = tmp;
            break :blk tmp;
        })))) != @as(?*anyopaque, null)) {
            t.*.avattr |= INVERSE;
        }
        t.*.se = jgetstr(t.*.cap, "se");
    }
    if ((getflag(t.*.cap, "xs") != 0) or (getflag(t.*.cap, "xt") != 0)) {
        t.*.so = null;
    }
    t.*.us = null;
    t.*.ue = null;
    if ((getnum(t.*.cap, "ug") <= @as(c_int, 0)) and (jgetstr(t.*.cap, "ue") != null)) {
        if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(blk: {
            const tmp = jgetstr(t.*.cap, "us");
            t.*.us = tmp;
            break :blk tmp;
        })))) != @as(?*anyopaque, null)) {
            t.*.avattr |= UNDERLINE;
        }
        t.*.ue = jgetstr(t.*.cap, "ue");
    }
    t.*.ZH = null;
    t.*.ZR = null;
    if (@as(?*anyopaque, @ptrCast(@alignCast(@constCast(blk: {
        const tmp = jgetstr(t.*.cap, "ZH");
        t.*.ZH = tmp;
        break :blk tmp;
    })))) != @as(?*anyopaque, null)) {
        t.*.avattr |= ITALIC;
    }
    t.*.ZR = jgetstr(t.*.cap, "ZR");
    if (!((blk: {
        const tmp = jgetstr(t.*.cap, "uc");
        t.*.uc = tmp;
        break :blk tmp;
    }) != null)) if (t.*.ul != 0) {
        t.*.uc = "_";
    };
    if (t.*.uc != null) {
        t.*.avattr |= UNDERLINE;
    }
    t.*.ms = getflag(t.*.cap, "ms");
    t.*.da = getflag(t.*.cap, "da");
    t.*.db = getflag(t.*.cap, "db");
    t.*.cs = jgetstr(t.*.cap, "cs");
    t.*.rr = getflag(t.*.cap, "rr");
    t.*.sf = jgetstr(t.*.cap, "sf");
    t.*.sr = jgetstr(t.*.cap, "sr");
    t.*.SF = jgetstr(t.*.cap, "SF");
    t.*.SR = jgetstr(t.*.cap, "SR");
    t.*.al = jgetstr(t.*.cap, "al");
    t.*.dl = jgetstr(t.*.cap, "dl");
    t.*.AL = jgetstr(t.*.cap, "AL");
    t.*.DL = jgetstr(t.*.cap, "DL");
    if (!(getflag(t.*.cap, "ns") != 0) and !(t.*.sf != null)) {
        t.*.sf = "\n";
    }
    if (!(getflag(t.*.cap, "in") != 0) and (tty_baud < @as(c_long, 38400))) {
        t.*.dc = jgetstr(t.*.cap, "dc");
        t.*.DC = jgetstr(t.*.cap, "DC");
        t.*.dm = jgetstr(t.*.cap, "dm");
        t.*.ed = jgetstr(t.*.cap, "ed");
        t.*.im = jgetstr(t.*.cap, "im");
        t.*.ei = jgetstr(t.*.cap, "ei");
        t.*.ic = jgetstr(t.*.cap, "ic");
        t.*.IC = jgetstr(t.*.cap, "IC");
        t.*.ip = jgetstr(t.*.cap, "ip");
        t.*.mi = getflag(t.*.cap, "mi");
    } else {
        t.*.dm = null;
        t.*.dc = null;
        t.*.DC = null;
        t.*.ed = null;
        t.*.im = null;
        t.*.ic = null;
        t.*.IC = null;
        t.*.ip = null;
        t.*.ei = null;
        t.*.mi = 1;
    }
    t.*.bs = null;
    if (jgetstr(t.*.cap, "bc") != null) {
        t.*.bs = jgetstr(t.*.cap, "bc");
    } else if (jgetstr(t.*.cap, "le") != null) {
        t.*.bs = jgetstr(t.*.cap, "le");
    }
    if (getflag(t.*.cap, "bs") != 0) {
        t.*.bs = "\x08";
    }
    t.*.cbs = tcost(t.*.cap, t.*.bs, 1, 2, 2, 0, 0);
    t.*.lf = "\n";
    if (jgetstr(t.*.cap, "do") != null) {
        t.*.lf = jgetstr(t.*.cap, "do");
    }
    t.*.clf = tcost(t.*.cap, t.*.lf, 1, 2, 2, 0, 0);
    t.*.up = jgetstr(t.*.cap, "up");
    t.*.cup = tcost(t.*.cap, t.*.up, 1, 2, 2, 0, 0);
    t.*.nd = jgetstr(t.*.cap, "nd");
    t.*.tw = 8;
    if (getnum(t.*.cap, "it") > @as(c_int, 0)) {
        t.*.tw = getnum(t.*.cap, "it");
    } else if (getnum(t.*.cap, "tw") > @as(c_int, 0)) {
        t.*.tw = getnum(t.*.cap, "tw");
    }
    if (!((blk: {
        const tmp = jgetstr(t.*.cap, "ta");
        t.*.ta = tmp;
        break :blk tmp;
    }) != null)) if (getflag(t.*.cap, "pt") != 0) {
        t.*.ta = "\t";
    };
    t.*.bt = jgetstr(t.*.cap, "bt");
    if (getflag(t.*.cap, "xt") != 0) {
        t.*.ta = null;
        t.*.bt = null;
    }
    if (!(opt_usetabs != 0)) {
        t.*.ta = null;
        t.*.bt = null;
    }
    t.*.cta = tcost(t.*.cap, t.*.ta, 1, 2, 2, 0, 0);
    t.*.cbt = tcost(t.*.cap, t.*.bt, 1, 2, 2, 0, 0);
    t.*.ho = jgetstr(t.*.cap, "ho");
    t.*.cho = tcost(t.*.cap, t.*.ho, 1, 2, 2, 0, 0);
    t.*.ll = jgetstr(t.*.cap, "ll");
    t.*.cll = tcost(t.*.cap, t.*.ll, 1, 2, 2, 0, 0);
    t.*.cr = "\r";
    if (jgetstr(t.*.cap, "cr") != null) {
        t.*.cr = jgetstr(t.*.cap, "cr");
    }
    if ((getflag(t.*.cap, "nc") != 0) or (getflag(t.*.cap, "xr") != 0)) {
        t.*.cr = null;
    }
    t.*.ccr = tcost(t.*.cap, t.*.cr, 1, 2, 2, 0, 0);
    t.*.cRI = tcost(t.*.cap, blk: {
        const tmp = jgetstr(t.*.cap, "RI");
        t.*.RI = tmp;
        break :blk tmp;
    }, 1, 2, 2, 0, 0);
    t.*.cLE = tcost(t.*.cap, blk: {
        const tmp = jgetstr(t.*.cap, "LE");
        t.*.LE = tmp;
        break :blk tmp;
    }, 1, 2, 2, 0, 0);
    t.*.cUP = tcost(t.*.cap, blk: {
        const tmp = jgetstr(t.*.cap, "UP");
        t.*.UP = tmp;
        break :blk tmp;
    }, 1, 2, 2, 0, 0);
    t.*.cDO = tcost(t.*.cap, blk: {
        const tmp = jgetstr(t.*.cap, "DO");
        t.*.DO = tmp;
        break :blk tmp;
    }, 1, 2, 2, 0, 0);
    t.*.cch = tcost(t.*.cap, blk: {
        const tmp = jgetstr(t.*.cap, "ch");
        t.*.ch = tmp;
        break :blk tmp;
    }, 1, 2, 2, 0, 0);
    t.*.ccv = tcost(t.*.cap, blk: {
        const tmp = jgetstr(t.*.cap, "cv");
        t.*.cv = tmp;
        break :blk tmp;
    }, 1, 2, 2, 0, 0);
    t.*.ccV = tcost(t.*.cap, blk: {
        const tmp = jgetstr(t.*.cap, "cV");
        t.*.cV = tmp;
        break :blk tmp;
    }, 1, 2, 2, 0, 0);
    t.*.ccm = tcost(t.*.cap, blk: {
        const tmp = jgetstr(t.*.cap, "cm");
        t.*.cm = tmp;
        break :blk tmp;
    }, 1, 2, 2, 0, 0);
    t.*.cce = tcost(t.*.cap, blk: {
        const tmp = jgetstr(t.*.cap, "ce");
        t.*.ce = tmp;
        break :blk tmp;
    }, 1, 2, 2, 0, 0);
    if (!(((((t.*.cm != null) or ((t.*.ch != null) and (t.*.cv != null))) or ((t.*.ho != null) and (((t.*.lf != null) or (t.*.DO != null)) or (t.*.cv != null)))) or ((t.*.ll != null) and (((t.*.up != null) or (t.*.UP != null)) or (t.*.cv != null)))) or ((t.*.cr != null) and (t.*.cv != null)))) {
        leave = 1;
        ttclose();
        signrm();
        _ = fprintf(__stderrp, "cm=%p ch=%p cv=%p ho=%p lf=%p DO=%p ll=%p up=%p UP=%p cr=%p\n", t.*.cm, t.*.ch, t.*.cv, t.*.ho, t.*.lf, t.*.DO, t.*.ll, t.*.up, t.*.UP, t.*.cr);
        _ = fputs("Sorry, your terminal can't do absolute cursor positioning.\nIt's broken\n", __stderrp);
        return null;
    }
    if (((((t.*.sr != null) or (t.*.SR != null)) and ((t.*.sf != null) or (t.*.SF != null))) and (t.*.cs != null)) or (((t.*.al != null) or (t.*.AL != null)) and ((t.*.dl != null) or (t.*.DL != null)))) {
        t.*.scroll = 1;
    } else {
        t.*.scroll = 0;
        if (tty_baud < @as(c_long, 38400)) {
            opt_mid = 1;
        }
    }
    if ((((t.*.im != null) or (t.*.ic != null)) or (t.*.IC != null)) and ((t.*.dc != null) or (t.*.DC != null))) {
        t.*.insdel = 1;
    } else {
        t.*.insdel = 0;
    }
    if (tty_baud >= @as(c_long, 38400)) {
        t.*.insdel = 0;
    }
    if (tty_baud < @as(c_long, 38400)) {
        opt_left = -@as(c_int, 2);
        opt_right = -@as(c_int, 2);
    }
    if ((notite != 0) and !(nolinefeeds != 0)) {
        {
            y = 1;
            while (y < li) : (y += 1) while (true) {
                obuf[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &obufp;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = @bitCast(@as(i8, @truncate(@as(c_int, 10))));
                if (obufp == obufsiz) {
                    ttflsh();
                }
                if (!false) break;
            };
        }
    }
    if (t.*.ti != null) {
        texec(t.*.cap, t.*.ti, 1, 0, 0, 0, 0);
    }
    if (!(skiptop != 0) and (t.*.cl != null)) {
        texec(t.*.cap, t.*.cl, 1, 0, 0, 0, 0);
    }
    if (t.*.brp != null) {
        texec(t.*.cap, t.*.brp, 1, 0, 0, 0, 0);
    }
    t.*.scrn = null;
    t.*.attr = null;
    t.*.sary = null;
    t.*.updtab = null;
    t.*.compose = null;
    t.*.ofst = null;
    t.*.ary = null;
    t.*.htab = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, 256) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_hentry))))))));
    _ = nresize(t, co, li);
    mouseopen();
    return t;
}
pub fn relcost(arg_t: [*c]SCRN, arg_x: ptrdiff_t, arg_y: ptrdiff_t, arg_ox: ptrdiff_t, arg_oy: ptrdiff_t) callconv(.c) ptrdiff_t {
    var t = arg_t;
    _ = &t;
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    var ox = arg_ox;
    _ = &ox;
    var oy = arg_oy;
    _ = &oy;
    var cost: ptrdiff_t = 0;
    _ = &cost;
    if ((oy == @as(ptrdiff_t, -@as(c_int, 1))) or (ox == @as(ptrdiff_t, -@as(c_int, 1)))) return 10000;
    if (y > oy) {
        var dist: ptrdiff_t = y - oy;
        _ = &dist;
        if (t.*.lf != null) {
            var mult: ptrdiff_t = dist * t.*.clf;
            _ = &mult;
            if ((dist < @as(ptrdiff_t, 10)) and (t.*.cDO < mult)) {
                cost += t.*.cDO;
            } else if ((dist >= @as(ptrdiff_t, 10)) and ((t.*.cDO + @as(ptrdiff_t, 1)) < mult)) {
                cost += t.*.cDO + @as(ptrdiff_t, 1);
            } else {
                cost += mult;
            }
        } else if (t.*.DO != null) if (dist < @as(ptrdiff_t, 10)) {
            cost += t.*.cDO;
        } else {
            cost += t.*.cDO + @as(ptrdiff_t, 1);
        } else return 10000;
    } else if (y < oy) {
        var dist: ptrdiff_t = oy - y;
        _ = &dist;
        if (t.*.up != null) {
            var mult: ptrdiff_t = dist * t.*.cup;
            _ = &mult;
            if ((dist < @as(ptrdiff_t, 10)) and (t.*.cUP < mult)) {
                cost += t.*.cUP;
            } else if ((dist >= @as(ptrdiff_t, 10)) and (t.*.cUP < mult)) {
                cost += t.*.cUP + @as(ptrdiff_t, 1);
            } else {
                cost += mult;
            }
        } else if (t.*.UP != null) if (dist < @as(ptrdiff_t, 10)) {
            cost += t.*.cUP;
        } else {
            cost += t.*.cUP + @as(ptrdiff_t, 1);
        } else return 10000;
    }
    if ((x > ox) and (t.*.ta != null)) {
        var dist: ptrdiff_t = x - ox;
        _ = &dist;
        var ntabs: ptrdiff_t = @divTrunc(dist + @rem(ox, t.*.tw), t.*.tw);
        _ = &ntabs;
        var cstunder: ptrdiff_t = @rem(x, t.*.tw) + (t.*.cta * ntabs);
        _ = &cstunder;
        var cstover: ptrdiff_t = undefined;
        _ = &cstover;
        if (((x + t.*.tw) < t.*.co) and (t.*.bs != null)) {
            cstover = (t.*.cbs * (t.*.tw - @rem(x, t.*.tw))) + (t.*.cta * (ntabs + @as(ptrdiff_t, 1)));
        } else {
            cstover = 10000;
        }
        if ((((dist < @as(ptrdiff_t, 10)) and (cstunder < t.*.cRI)) and (cstunder < (x - ox))) and (cstover > cstunder)) return cost + cstunder else if (((cstunder < (t.*.cRI + @as(ptrdiff_t, 1))) and (cstunder < (x - ox))) and (cstover > cstunder)) return cost + cstunder else if (((dist < @as(ptrdiff_t, 10)) and (cstover < t.*.cRI)) and (cstover < (x - ox))) return cost + cstover else if ((cstover < (t.*.cRI + @as(ptrdiff_t, 1))) and (cstover < (x - ox))) return cost + cstover;
    } else if ((x < ox) and (t.*.bt != null)) {
        var dist: ptrdiff_t = ox - x;
        _ = &dist;
        var ntabs: ptrdiff_t = @divTrunc((dist + t.*.tw) - @rem(ox, t.*.tw), t.*.tw);
        _ = &ntabs;
        var cstunder: ptrdiff_t = undefined;
        _ = &cstunder;
        var cstover: ptrdiff_t = undefined;
        _ = &cstover;
        if (t.*.bs != null) {
            cstunder = (t.*.cbt * ntabs) + (t.*.cbs * (t.*.tw - @rem(x, t.*.tw)));
        } else {
            cstunder = 10000;
        }
        if (x >= t.*.tw) {
            cstover = (t.*.cbt * (ntabs + @as(ptrdiff_t, 1))) + @rem(x, t.*.tw);
        } else {
            cstover = 10000;
        }
        if ((((dist < @as(ptrdiff_t, 10)) and (cstunder < t.*.cLE)) and ((if (t.*.bs != null) @intFromBool(cstunder < ((ox - x) * t.*.cbs)) else @as(c_int, 1)) != 0)) and (cstover > cstunder)) return cost + cstunder;
        if (((cstunder < (t.*.cLE + @as(ptrdiff_t, 1))) and ((if (t.*.bs != null) @intFromBool(cstunder < ((ox - x) * t.*.cbs)) else @as(c_int, 1)) != 0)) and (cstover > cstunder)) return cost + cstunder else if (((dist < @as(ptrdiff_t, 10)) and (cstover < t.*.cRI)) and ((if (t.*.bs != null) @intFromBool(cstover < ((ox - x) * t.*.cbs)) else @as(c_int, 1)) != 0)) return cost + cstover else if ((cstover < (t.*.cRI + @as(ptrdiff_t, 1))) and ((if (t.*.bs != null) @intFromBool(cstover < ((ox - x) * t.*.cbs)) else @as(c_int, 1)) != 0)) return cost + cstover;
    }
    if (x < ox) {
        var dist: ptrdiff_t = ox - x;
        _ = &dist;
        if (t.*.bs != null) {
            var mult: ptrdiff_t = dist * t.*.cbs;
            _ = &mult;
            if ((t.*.cLE < mult) and (dist < @as(ptrdiff_t, 10))) {
                cost += t.*.cLE;
            } else if ((t.*.cLE + @as(ptrdiff_t, 1)) < mult) {
                cost += t.*.cLE + @as(ptrdiff_t, 1);
            } else {
                cost += mult;
            }
        } else if (t.*.LE != null) {
            cost += t.*.cLE;
        } else return 10000;
    } else if (x > ox) {
        var dist: ptrdiff_t = x - ox;
        _ = &dist;
        if ((t.*.cRI < dist) and (dist < @as(ptrdiff_t, 10))) {
            cost += t.*.cRI;
        } else if ((t.*.cRI + @as(ptrdiff_t, 1)) < dist) {
            cost += t.*.cRI + @as(ptrdiff_t, 1);
        } else {
            cost += dist;
        }
    }
    return cost;
}
pub fn cposs(arg_t: [*c]SCRN, arg_x: ptrdiff_t, arg_y: ptrdiff_t) callconv(.c) void {
    var t = arg_t;
    _ = &t;
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    var bestcost: ptrdiff_t = undefined;
    _ = &bestcost;
    var cost: ptrdiff_t = undefined;
    _ = &cost;
    var bestway: c_int = undefined;
    _ = &bestway;
    var hy: ptrdiff_t = undefined;
    _ = &hy;
    var hl: ptrdiff_t = undefined;
    _ = &hl;
    fixupcursor(t);
    if (t.*.rr != 0) {
        hy = t.*.top;
        hl = t.*.bot - @as(ptrdiff_t, 1);
    } else {
        hy = 0;
        hl = t.*.li - @as(ptrdiff_t, 1);
    }
    bestcost = relcost(t, x, y, t.*.x, t.*.y);
    bestway = 0;
    if (t.*.ccm < bestcost) {
        cost = tcost(t.*.cap, t.*.cm, 1, y, x, 0, 0);
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 6;
        }
    }
    if (t.*.ccr < bestcost) {
        cost = relcost(t, x, y, 0, t.*.y) + t.*.ccr;
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 1;
        }
    }
    if (t.*.cho < bestcost) {
        cost = relcost(t, x, y, 0, hy) + t.*.cho;
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 2;
        }
    }
    if (t.*.cll < bestcost) {
        cost = relcost(t, x, y, 0, hl) + t.*.cll;
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 3;
        }
    }
    if ((t.*.cch < bestcost) and (x != t.*.x)) {
        cost = relcost(t, x, y, x, t.*.y) + tcost(t.*.cap, t.*.ch, 1, x, 0, 0, 0);
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 4;
        }
    }
    if ((t.*.ccv < bestcost) and (y != t.*.y)) {
        cost = relcost(t, x, y, t.*.x, y) + tcost(t.*.cap, t.*.cv, 1, y, 0, 0, 0);
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 5;
        }
    }
    if (t.*.ccV < bestcost) {
        cost = relcost(t, x, y, 0, y) + tcost(t.*.cap, t.*.cV, 1, y, 0, 0, 0);
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 13;
        }
    }
    if ((((t.*.cch + t.*.ccv) < bestcost) and (x != t.*.x)) and (y != t.*.y)) {
        cost = tcost(t.*.cap, t.*.cv, 1, y - hy, 0, 0, 0) + tcost(t.*.cap, t.*.ch, 1, x, 0, 0, 0);
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 7;
        }
    }
    if (((t.*.ccv + t.*.ccr) < bestcost) and (y != t.*.y)) {
        cost = (tcost(t.*.cap, t.*.cv, 1, y, 0, 0, 0) + tcost(t.*.cap, t.*.cr, 1, 0, 0, 0, 0)) + relcost(t, x, y, 0, y);
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 8;
        }
    }
    if ((t.*.cll + t.*.cch) < bestcost) {
        cost = (tcost(t.*.cap, t.*.ll, 1, 0, 0, 0, 0) + tcost(t.*.cap, t.*.ch, 1, x, 0, 0, 0)) + relcost(t, x, y, x, hl);
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 9;
        }
    }
    if ((t.*.cll + t.*.ccv) < bestcost) {
        cost = (tcost(t.*.cap, t.*.ll, 1, 0, 0, 0, 0) + tcost(t.*.cap, t.*.cv, 1, y, 0, 0, 0)) + relcost(t, x, y, 0, y);
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 10;
        }
    }
    if ((t.*.cho + t.*.cch) < bestcost) {
        cost = (tcost(t.*.cap, t.*.ho, 1, 0, 0, 0, 0) + tcost(t.*.cap, t.*.ch, 1, x, 0, 0, 0)) + relcost(t, x, y, x, hy);
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 11;
        }
    }
    if ((t.*.cho + t.*.ccv) < bestcost) {
        cost = (tcost(t.*.cap, t.*.ho, 1, 0, 0, 0, 0) + tcost(t.*.cap, t.*.cv, 1, y, 0, 0, 0)) + relcost(t, x, y, 0, y);
        if (cost < bestcost) {
            bestcost = cost;
            bestway = 12;
        }
    }
    while (true) {
        switch (bestway) {
            @as(c_int, 1) => {
                texec(t.*.cap, t.*.cr, 1, 0, 0, 0, 0);
                t.*.x = 0;
                break;
            },
            @as(c_int, 2) => {
                texec(t.*.cap, t.*.ho, 1, 0, 0, 0, 0);
                t.*.x = 0;
                t.*.y = hy;
                break;
            },
            @as(c_int, 3) => {
                texec(t.*.cap, t.*.ll, 1, 0, 0, 0, 0);
                t.*.x = 0;
                t.*.y = hl;
                break;
            },
            @as(c_int, 9) => {
                texec(t.*.cap, t.*.ll, 1, 0, 0, 0, 0);
                t.*.x = 0;
                t.*.y = hl;
                texec(t.*.cap, t.*.ch, 1, x, 0, 0, 0);
                t.*.x = x;
                break;
            },
            @as(c_int, 11) => {
                texec(t.*.cap, t.*.ho, 1, 0, 0, 0, 0);
                t.*.x = 0;
                t.*.y = hy;
                texec(t.*.cap, t.*.ch, 1, x, 0, 0, 0);
                t.*.x = x;
                break;
            },
            @as(c_int, 4) => {
                texec(t.*.cap, t.*.ch, 1, x, 0, 0, 0);
                t.*.x = x;
                break;
            },
            @as(c_int, 10) => {
                texec(t.*.cap, t.*.ll, 1, 0, 0, 0, 0);
                t.*.x = 0;
                t.*.y = hl;
                texec(t.*.cap, t.*.cv, 1, y, 0, 0, 0);
                t.*.y = y;
                break;
            },
            @as(c_int, 12) => {
                texec(t.*.cap, t.*.ho, 1, 0, 0, 0, 0);
                t.*.x = 0;
                t.*.y = hy;
                texec(t.*.cap, t.*.cv, 1, y, 0, 0, 0);
                t.*.y = y;
                break;
            },
            @as(c_int, 8) => {
                texec(t.*.cap, t.*.cr, 1, 0, 0, 0, 0);
                t.*.x = 0;
                texec(t.*.cap, t.*.cv, 1, y, 0, 0, 0);
                t.*.y = y;
                break;
            },
            @as(c_int, 5) => {
                texec(t.*.cap, t.*.cv, 1, y, 0, 0, 0);
                t.*.y = y;
                break;
            },
            @as(c_int, 6) => {
                texec(t.*.cap, t.*.cm, 1, y, x, 0, 0);
                t.*.y = y;
                t.*.x = x;
                break;
            },
            @as(c_int, 7) => {
                texec(t.*.cap, t.*.cv, 1, y, 0, 0, 0);
                t.*.y = y;
                texec(t.*.cap, t.*.ch, 1, x, 0, 0, 0);
                t.*.x = x;
                break;
            },
            @as(c_int, 13) => {
                texec(t.*.cap, t.*.cV, 1, y, 0, 0, 0);
                t.*.y = y;
                t.*.x = 0;
                break;
            },
            else => {},
        }
        break;
    }
    if (y > t.*.y) {
        if (!(t.*.lf != null) or (t.*.cDO < ((y - t.*.y) * t.*.clf))) {
            texec(t.*.cap, t.*.DO, 1, y - t.*.y, 0, 0, 0);
            t.*.y = y;
        } else while (y > t.*.y) {
            texec(t.*.cap, t.*.lf, 1, 0, 0, 0, 0);
            t.*.y += 1;
        }
    } else if (y < t.*.y) {
        if (!(t.*.up != null) or (t.*.cUP < ((t.*.y - y) * t.*.cup))) {
            texec(t.*.cap, t.*.UP, 1, t.*.y - y, 0, 0, 0);
            t.*.y = y;
        } else while (y < t.*.y) {
            texec(t.*.cap, t.*.up, 1, 0, 0, 0, 0);
            t.*.y -= 1;
        }
    }
    if ((x > t.*.x) and (t.*.ta != null)) {
        var ntabs: ptrdiff_t = @divTrunc((x - t.*.x) + @rem(t.*.x, t.*.tw), t.*.tw);
        _ = &ntabs;
        var cstunder: ptrdiff_t = @rem(x, t.*.tw) + (t.*.cta * ntabs);
        _ = &cstunder;
        var cstover: ptrdiff_t = undefined;
        _ = &cstover;
        if (((x + t.*.tw) < t.*.co) and (t.*.bs != null)) {
            cstover = (t.*.cbs * (t.*.tw - @rem(x, t.*.tw))) + (t.*.cta * (ntabs + @as(ptrdiff_t, 1)));
        } else {
            cstover = 10000;
        }
        if (((cstunder < t.*.cRI) and (cstunder < (x - t.*.x))) and (cstover > cstunder)) {
            if (ntabs != 0) {
                t.*.x = x - @rem(x, t.*.tw);
                while (true) {
                    texec(t.*.cap, t.*.ta, 1, 0, 0, 0, 0);
                    if (!((blk: {
                        const ref = &ntabs;
                        ref.* -= 1;
                        break :blk ref.*;
                    }) != 0)) break;
                }
            }
        } else if ((cstover < t.*.cRI) and (cstover < (x - t.*.x))) {
            t.*.x = (t.*.tw + x) - @rem(x, t.*.tw);
            ntabs += 1;
            while (true) {
                texec(t.*.cap, t.*.ta, 1, 0, 0, 0, 0);
                if (!((blk: {
                    const ref = &ntabs;
                    ref.* -= 1;
                    break :blk ref.*;
                }) != 0)) break;
            }
        }
    } else if ((x < t.*.x) and (t.*.bt != null)) {
        var ntabs: ptrdiff_t = @divTrunc((((t.*.x + t.*.tw) - @as(ptrdiff_t, 1)) - @rem((t.*.x + t.*.tw) - @as(ptrdiff_t, 1), t.*.tw)) - (((x + t.*.tw) - @as(ptrdiff_t, 1)) - @rem((x + t.*.tw) - @as(ptrdiff_t, 1), t.*.tw)), t.*.tw);
        _ = &ntabs;
        var cstunder: ptrdiff_t = undefined;
        _ = &cstunder;
        var cstover: ptrdiff_t = undefined;
        _ = &cstover;
        if (t.*.bs != null) {
            cstunder = (t.*.cbt * ntabs) + (t.*.cbs * (t.*.tw - @rem(x, t.*.tw)));
        } else {
            cstunder = 10000;
        }
        if (x >= t.*.tw) {
            cstover = (t.*.cbt * (ntabs + @as(ptrdiff_t, 1))) + @rem(x, t.*.tw);
        } else {
            cstover = 10000;
        }
        if (((cstunder < t.*.cLE) and ((if (t.*.bs != null) @intFromBool(cstunder < ((t.*.x - x) * t.*.cbs)) else @as(c_int, 1)) != 0)) and (cstover > cstunder)) {
            if (ntabs != 0) {
                while (true) {
                    texec(t.*.cap, t.*.bt, 1, 0, 0, 0, 0);
                    if (!((blk: {
                        const ref = &ntabs;
                        ref.* -= 1;
                        break :blk ref.*;
                    }) != 0)) break;
                }
                t.*.x = (x + t.*.tw) - @rem(x, t.*.tw);
            }
        } else if ((cstover < t.*.cRI) and ((if (t.*.bs != null) @intFromBool(cstover < ((t.*.x - x) * t.*.cbs)) else @as(c_int, 1)) != 0)) {
            t.*.x = x - @rem(x, t.*.tw);
            ntabs += 1;
            while (true) {
                texec(t.*.cap, t.*.bt, 1, 0, 0, 0, 0);
                if (!((blk: {
                    const ref = &ntabs;
                    ref.* -= 1;
                    break :blk ref.*;
                }) != 0)) break;
            }
        }
    }
    if (x < t.*.x) {
        if (!(t.*.bs != null) or (t.*.cLE < ((t.*.x - x) * t.*.cbs))) {
            texec(t.*.cap, t.*.LE, 1, t.*.x - x, 0, 0, 0);
            t.*.x = x;
        } else while (x < t.*.x) {
            texec(t.*.cap, t.*.bs, 1, 0, 0, 0, 0);
            t.*.x -= 1;
        }
    } else if (x > t.*.x) {
        if (((x - t.*.x) > @as(ptrdiff_t, 1)) and (t.*.RI != null)) {
            texec(t.*.cap, t.*.RI, 1, x - t.*.x, 0, 0, 0);
            t.*.x = x;
        } else {
            while (x > t.*.x) {
                texec(t.*.cap, t.*.nd, 1, 0, 0, 0, 0);
                t.*.x += 1;
            }
        }
    }
}
pub fn doupscrl(arg_t: [*c]SCRN, arg_top: ptrdiff_t, arg_bot: ptrdiff_t, arg_amnt: ptrdiff_t, arg_atr: c_int) callconv(.c) void {
    var t = arg_t;
    _ = &t;
    var top = arg_top;
    _ = &top;
    var bot = arg_bot;
    _ = &bot;
    var amnt = arg_amnt;
    _ = &amnt;
    var atr = arg_atr;
    _ = &atr;
    var a: ptrdiff_t = amnt;
    _ = &a;
    var did: c_int = 0;
    _ = &did;
    if (!(amnt != 0)) return;
    if (zig_screen_swap_enabled != 0) {
        _ = mmove(@ptrCast(@alignCast(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(top * t.*.co)))))), @ptrCast(@alignCast(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast((top + amnt) * t.*.co)))))), (((bot - top) - amnt) * t.*.co) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([4]c_int))))));
        _ = mmove(@ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(top * t.*.co)))))), @ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast((top + amnt) * t.*.co)))))), (((bot - top) - amnt) * t.*.co) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))));
        if ((bot == t.*.li) and (t.*.db != 0)) {
            mfill(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast((t.*.li - amnt) * t.*.co)))), -@as(c_int, 1), amnt * t.*.co);
            _ = msetI(@ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast((t.*.li - amnt) * t.*.co)))))), 0, amnt * t.*.co);
            _ = msetI(@ptrCast(@alignCast((t.*.updtab + @as(usize, @bitCast(@as(isize, @intCast(t.*.li))))) - @as(usize, @bitCast(@as(isize, @intCast(amnt)))))), 1, amnt);
        } else {
            mfill(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast((bot - amnt) * t.*.co)))), ' ', amnt * t.*.co);
            _ = msetI(@ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast((bot - amnt) * t.*.co)))))), 0, amnt * t.*.co);
        }
        return;
    }
    _ = set_attr(t, atr);
    if (((top == @as(ptrdiff_t, 0)) and (bot == t.*.li)) and ((t.*.sf != null) or (t.*.SF != null))) {
        setregn(t, 0, t.*.li);
        _ = cpos(t, 0, t.*.li - @as(ptrdiff_t, 1));
        if (((amnt == @as(ptrdiff_t, 1)) and (t.*.sf != null)) or !(t.*.SF != null)) {
            while ((blk: {
                const ref = &a;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                texec(t.*.cap, t.*.sf, 1, t.*.li - @as(ptrdiff_t, 1), 0, 0, 0);
            }
        } else {
            texec(t.*.cap, t.*.SF, a, a, 0, 0, 0);
        }
        did = 1;
    } else if ((bot == t.*.li) and ((t.*.dl != null) or (t.*.DL != null))) {
        setregn(t, 0, t.*.li);
        _ = cpos(t, 0, top);
        if (((amnt == @as(ptrdiff_t, 1)) and (t.*.dl != null)) or !(t.*.DL != null)) {
            while ((blk: {
                const ref = &a;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                texec(t.*.cap, t.*.dl, 1, top, 0, 0, 0);
            }
        } else {
            texec(t.*.cap, t.*.DL, a, a, 0, 0, 0);
        }
        did = 1;
    } else if ((t.*.cs != null) and ((t.*.sf != null) or (t.*.SF != null))) {
        setregn(t, top, bot);
        _ = cpos(t, 0, bot - @as(ptrdiff_t, 1));
        if (((amnt == @as(ptrdiff_t, 1)) and (t.*.sf != null)) or !(t.*.SF != null)) {
            while ((blk: {
                const ref = &a;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                texec(t.*.cap, t.*.sf, 1, bot - @as(ptrdiff_t, 1), 0, 0, 0);
            }
        } else {
            texec(t.*.cap, t.*.SF, a, a, 0, 0, 0);
        }
        did = 1;
    } else if (((t.*.dl != null) or (t.*.DL != null)) and ((t.*.al != null) or (t.*.AL != null))) {
        _ = cpos(t, 0, top);
        if (((amnt == @as(ptrdiff_t, 1)) and (t.*.dl != null)) or !(t.*.DL != null)) {
            while ((blk: {
                const ref = &a;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                texec(t.*.cap, t.*.dl, 1, top, 0, 0, 0);
            }
        } else {
            texec(t.*.cap, t.*.DL, a, a, 0, 0, 0);
        }
        a = amnt;
        _ = cpos(t, 0, bot - amnt);
        if (((amnt == @as(ptrdiff_t, 1)) and (t.*.al != null)) or !(t.*.AL != null)) {
            while ((blk: {
                const ref = &a;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                texec(t.*.cap, t.*.al, 1, bot - amnt, 0, 0, 0);
            }
        } else {
            texec(t.*.cap, t.*.AL, a, a, 0, 0, 0);
        }
        did = 1;
    }
    if (!(did != 0)) {
        _ = msetI(@ptrCast(@alignCast(t.*.updtab + @as(usize, @bitCast(@as(isize, @intCast(top)))))), 1, bot - top);
        return;
    }
    _ = mmove(@ptrCast(@alignCast(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(top * t.*.co)))))), @ptrCast(@alignCast(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast((top + amnt) * t.*.co)))))), (((bot - top) - amnt) * t.*.co) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([4]c_int))))));
    _ = mmove(@ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(top * t.*.co)))))), @ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast((top + amnt) * t.*.co)))))), (((bot - top) - amnt) * t.*.co) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))));
    if ((bot == t.*.li) and (t.*.db != 0)) {
        mfill(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast((t.*.li - amnt) * t.*.co)))), -@as(c_int, 1), amnt * t.*.co);
        _ = msetI(@ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast((t.*.li - amnt) * t.*.co)))))), 0, amnt * t.*.co);
        _ = msetI(@ptrCast(@alignCast((t.*.updtab + @as(usize, @bitCast(@as(isize, @intCast(t.*.li))))) - @as(usize, @bitCast(@as(isize, @intCast(amnt)))))), 1, amnt);
    } else {
        mfill(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast((bot - amnt) * t.*.co)))), ' ', amnt * t.*.co);
        _ = msetI(@ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast((bot - amnt) * t.*.co)))))), 0, amnt * t.*.co);
    }
}
pub fn dodnscrl(arg_t: [*c]SCRN, arg_top: ptrdiff_t, arg_bot: ptrdiff_t, arg_amnt: ptrdiff_t, arg_atr: c_int) callconv(.c) void {
    var t = arg_t;
    _ = &t;
    var top = arg_top;
    _ = &top;
    var bot = arg_bot;
    _ = &bot;
    var amnt = arg_amnt;
    _ = &amnt;
    var atr = arg_atr;
    _ = &atr;
    var a: ptrdiff_t = amnt;
    _ = &a;
    var did: c_int = 0;
    _ = &did;
    if (!(amnt != 0)) return;
    if (zig_screen_swap_enabled != 0) {
        _ = mmove(@ptrCast(@alignCast(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast((top + amnt) * t.*.co)))))), @ptrCast(@alignCast(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(top * t.*.co)))))), (((bot - top) - amnt) * t.*.co) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([4]c_int))))));
        _ = mmove(@ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast((top + amnt) * t.*.co)))))), @ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(top * t.*.co)))))), (((bot - top) - amnt) * t.*.co) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))));
        if (!(top != 0) and (t.*.da != 0)) {
            mfill(t.*.scrn, -@as(c_int, 1), amnt * t.*.co);
            _ = msetI(@ptrCast(@alignCast(t.*.attr)), 0, amnt * t.*.co);
            _ = msetI(@ptrCast(@alignCast(t.*.updtab)), 1, amnt);
        } else {
            mfill(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(t.*.co * top)))), ' ', amnt * t.*.co);
            _ = msetI(@ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(t.*.co * top)))))), 0, amnt * t.*.co);
        }
        return;
    }
    _ = set_attr(t, atr);
    if (((top == @as(ptrdiff_t, 0)) and (bot == t.*.li)) and ((t.*.sr != null) or (t.*.SR != null))) {
        setregn(t, 0, t.*.li);
        _ = cpos(t, 0, 0);
        if (((amnt == @as(ptrdiff_t, 1)) and (t.*.sr != null)) or !(t.*.SR != null)) {
            while ((blk: {
                const ref = &a;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                texec(t.*.cap, t.*.sr, 1, 0, 0, 0, 0);
            }
        } else {
            texec(t.*.cap, t.*.SR, a, a, 0, 0, 0);
        }
        did = 1;
    } else if ((bot == t.*.li) and ((t.*.al != null) or (t.*.AL != null))) {
        setregn(t, 0, t.*.li);
        _ = cpos(t, 0, top);
        if (((amnt == @as(ptrdiff_t, 1)) and (t.*.al != null)) or !(t.*.AL != null)) {
            while ((blk: {
                const ref = &a;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                texec(t.*.cap, t.*.al, 1, top, 0, 0, 0);
            }
        } else {
            texec(t.*.cap, t.*.AL, a, a, 0, 0, 0);
        }
        did = 1;
    } else if ((t.*.cs != null) and ((t.*.sr != null) or (t.*.SR != null))) {
        setregn(t, top, bot);
        _ = cpos(t, 0, top);
        if (((amnt == @as(ptrdiff_t, 1)) and (t.*.sr != null)) or !(t.*.SR != null)) {
            while ((blk: {
                const ref = &a;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                texec(t.*.cap, t.*.sr, 1, top, 0, 0, 0);
            }
        } else {
            texec(t.*.cap, t.*.SR, a, a, 0, 0, 0);
        }
        did = 1;
    } else if (((t.*.dl != null) or (t.*.DL != null)) and ((t.*.al != null) or (t.*.AL != null))) {
        _ = cpos(t, 0, bot - amnt);
        if (((amnt == @as(ptrdiff_t, 1)) and (t.*.dl != null)) or !(t.*.DL != null)) {
            while ((blk: {
                const ref = &a;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                texec(t.*.cap, t.*.dl, 1, bot - amnt, 0, 0, 0);
            }
        } else {
            texec(t.*.cap, t.*.DL, a, a, 0, 0, 0);
        }
        a = amnt;
        _ = cpos(t, 0, top);
        if (((amnt == @as(ptrdiff_t, 1)) and (t.*.al != null)) or !(t.*.AL != null)) {
            while ((blk: {
                const ref = &a;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                texec(t.*.cap, t.*.al, 1, top, 0, 0, 0);
            }
        } else {
            texec(t.*.cap, t.*.AL, a, a, 0, 0, 0);
        }
        did = 1;
    }
    if (!(did != 0)) {
        _ = msetI(@ptrCast(@alignCast(t.*.updtab + @as(usize, @bitCast(@as(isize, @intCast(top)))))), 1, bot - top);
        return;
    }
    _ = mmove(@ptrCast(@alignCast(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast((top + amnt) * t.*.co)))))), @ptrCast(@alignCast(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(top * t.*.co)))))), (((bot - top) - amnt) * t.*.co) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([4]c_int))))));
    _ = mmove(@ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast((top + amnt) * t.*.co)))))), @ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(top * t.*.co)))))), (((bot - top) - amnt) * t.*.co) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))));
    if (!(top != 0) and (t.*.da != 0)) {
        mfill(t.*.scrn, -@as(c_int, 1), amnt * t.*.co);
        _ = msetI(@ptrCast(@alignCast(t.*.attr)), 0, amnt * t.*.co);
        _ = msetI(@ptrCast(@alignCast(t.*.updtab)), 1, amnt);
    } else {
        mfill(t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(t.*.co * top)))), ' ', amnt * t.*.co);
        _ = msetI(@ptrCast(@alignCast(t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(t.*.co * top)))))), 0, amnt * t.*.co);
    }
}
pub export fn nscroll(arg_t: [*c]SCRN, arg_atr: c_int) void {
    var t = arg_t;
    _ = &t;
    var atr = arg_atr;
    _ = &atr;
    var y: ptrdiff_t = undefined;
    _ = &y;
    var z: ptrdiff_t = undefined;
    _ = &z;
    var q: ptrdiff_t = undefined;
    _ = &q;
    var r: ptrdiff_t = undefined;
    _ = &r;
    var p: ptrdiff_t = undefined;
    _ = &p;
    {
        y = 0;
        while (y != t.*.li) : (y += 1) {
            q = t.*.sary[@bitCast(@as(isize, @intCast(y)))];
            if (have != 0) return;
            if ((q != 0) and (@as(ptrdiff_t, @intFromBool(q != t.*.li)) != 0)) {
                if (q > @as(ptrdiff_t, 0)) {
                    {
                        z = y;
                        while ((z != t.*.li) and (t.*.sary[@bitCast(@as(isize, @intCast(z)))] == q)) : (z += 1) {
                            t.*.sary[@bitCast(@as(isize, @intCast(z)))] = 0;
                        }
                    }
                    doupscrl(t, y, z + q, q, atr);
                    y = z - @as(ptrdiff_t, 1);
                } else {
                    {
                        r = y;
                        while ((r != t.*.li) and ((t.*.sary[@bitCast(@as(isize, @intCast(r)))] < @as(ptrdiff_t, 0)) or (t.*.sary[@bitCast(@as(isize, @intCast(r)))] == t.*.li))) : (r += 1) {}
                    }
                    p = r - @as(ptrdiff_t, 1);
                    while (true) {
                        q = t.*.sary[@bitCast(@as(isize, @intCast(p)))];
                        if ((q != 0) and (@as(ptrdiff_t, @intFromBool(q != t.*.li)) != 0)) {
                            {
                                z = p;
                                while ((blk: {
                                    t.*.sary[@bitCast(@as(isize, @intCast(z)))] = 0;
                                    break :blk @intFromBool((z != 0) and (@as(ptrdiff_t, @intFromBool(t.*.sary[@bitCast(@as(isize, @intCast(z - @as(ptrdiff_t, 1))))] == q)) != 0));
                                }) != 0) : (z -= 1) {}
                            }
                            dodnscrl(t, z + q, p + @as(ptrdiff_t, 1), -q, atr);
                            p = z + @as(ptrdiff_t, 1);
                        }
                        if (!((blk: {
                            const ref = &p;
                            const tmp = ref.*;
                            ref.* -= 1;
                            break :blk tmp;
                        }) != y)) break;
                    }
                    y = r - @as(ptrdiff_t, 1);
                }
            }
        }
    }
    _ = msetD(@ptrCast(@alignCast(t.*.sary)), 0, t.*.li);
}
pub export fn npartial(arg_t: [*c]SCRN) void {
    var t = arg_t;
    _ = &t;
    _ = set_attr(t, bg_text);
    _ = clrins(t);
    setregn(t, 0, t.*.li);
}
pub export fn nescape(arg_t: [*c]SCRN) void {
    var t = arg_t;
    _ = &t;
    mouseclose();
    npartial(t);
    _ = cpos(t, 0, t.*.li - @as(ptrdiff_t, 1));
    _ = eraeol(t, 0, t.*.li - @as(ptrdiff_t, 1), 0);
    if (t.*.bre != null) {
        texec(t.*.cap, t.*.bre, 1, 0, 0, 0, 0);
    }
    if (t.*.te != null) {
        texec(t.*.cap, t.*.te, 1, 0, 0, 0, 0);
    }
}
pub export fn nreturn(arg_t: [*c]SCRN) void {
    var t = arg_t;
    _ = &t;
    mouseopen();
    if (t.*.ti != null) {
        texec(t.*.cap, t.*.ti, 1, 0, 0, 0, 0);
    }
    if (!(skiptop != 0) and (t.*.cl != null)) {
        texec(t.*.cap, t.*.cl, 1, 0, 0, 0, 0);
    }
    if (t.*.brp != null) {
        texec(t.*.cap, t.*.brp, 1, 0, 0, 0, 0);
    }
    nredraw(t);
}
pub export fn nclose(arg_t: [*c]SCRN) void {
    var t = arg_t;
    _ = &t;
    mouseclose();
    leave = 1;
    _ = set_attr(t, 0);
    _ = clrins(t);
    setregn(t, 0, t.*.li);
    _ = cpos(t, 0, t.*.li - @as(ptrdiff_t, 1));
    if (t.*.bre != null) {
        texec(t.*.cap, t.*.bre, 1, 0, 0, 0, 0);
    }
    if (t.*.te != null) {
        texec(t.*.cap, t.*.te, 1, 0, 0, 0, 0);
    }
    ttclose();
    rmcap(t.*.cap);
    zigScrnSwapDestroy();
    joe_free(@ptrCast(@alignCast(t.*.scrn)));
    joe_free(@ptrCast(@alignCast(t.*.attr)));
    joe_free(@ptrCast(@alignCast(t.*.sary)));
    joe_free(@ptrCast(@alignCast(t.*.ofst)));
    joe_free(@ptrCast(@alignCast(t.*.htab)));
    joe_free(@ptrCast(@alignCast(t.*.ary)));
    joe_free(@ptrCast(@alignCast(t)));
}
pub export fn nscrldn(arg_t: [*c]SCRN, arg_top: ptrdiff_t, arg_bot: ptrdiff_t, arg_amnt: ptrdiff_t) void {
    var t = arg_t;
    _ = &t;
    var top = arg_top;
    _ = &top;
    var bot = arg_bot;
    _ = &bot;
    var amnt = arg_amnt;
    _ = &amnt;
    var x: ptrdiff_t = undefined;
    _ = &x;
    if ((!(amnt != 0) or (top >= bot)) or (bot > t.*.li)) return;
    if (((amnt < (bot - top)) and (((bot - top) - amnt) < @divTrunc(amnt, @as(ptrdiff_t, 2)))) or !(t.*.scroll != 0)) {
        amnt = bot - top;
    }
    if (amnt < (bot - top)) {
        {
            x = bot;
            while (x != (top + amnt)) : (x -= 1) {
                t.*.sary[@bitCast(@as(isize, @intCast(x - @as(ptrdiff_t, 1))))] = if (t.*.sary[@bitCast(@as(isize, @intCast((x - amnt) - @as(ptrdiff_t, 1))))] == t.*.li) t.*.li else t.*.sary[@bitCast(@as(isize, @intCast((x - amnt) - @as(ptrdiff_t, 1))))] - amnt;
                t.*.updtab[@bitCast(@as(isize, @intCast(x - @as(ptrdiff_t, 1))))] = t.*.updtab[@bitCast(@as(isize, @intCast((x - amnt) - @as(ptrdiff_t, 1))))];
            }
        }
        {
            x = top;
            while (x != (top + amnt)) : (x += 1) {
                t.*.updtab[@bitCast(@as(isize, @intCast(x)))] = 1;
            }
        }
    }
    if (amnt > (bot - top)) {
        amnt = bot - top;
    }
    _ = msetD(@ptrCast(@alignCast(t.*.sary + @as(usize, @bitCast(@as(isize, @intCast(top)))))), t.*.li, amnt);
    if (amnt == (bot - top)) {
        _ = msetI(@ptrCast(@alignCast(t.*.updtab + @as(usize, @bitCast(@as(isize, @intCast(top)))))), 1, amnt);
    }
}
pub export fn nscrlup(arg_t: [*c]SCRN, arg_top: ptrdiff_t, arg_bot: ptrdiff_t, arg_amnt: ptrdiff_t) void {
    var t = arg_t;
    _ = &t;
    var top = arg_top;
    _ = &top;
    var bot = arg_bot;
    _ = &bot;
    var amnt = arg_amnt;
    _ = &amnt;
    var x: ptrdiff_t = undefined;
    _ = &x;
    if ((!(amnt != 0) or (top >= bot)) or (bot > t.*.li)) return;
    if (((amnt < (bot - top)) and (((bot - top) - amnt) < @divTrunc(amnt, @as(ptrdiff_t, 2)))) or !(t.*.scroll != 0)) {
        amnt = bot - top;
    }
    if (amnt < (bot - top)) {
        {
            x = top + amnt;
            while (x != bot) : (x += 1) {
                t.*.sary[@bitCast(@as(isize, @intCast(x - amnt)))] = if (t.*.sary[@bitCast(@as(isize, @intCast(x)))] == t.*.li) t.*.li else t.*.sary[@bitCast(@as(isize, @intCast(x)))] + amnt;
                t.*.updtab[@bitCast(@as(isize, @intCast(x - amnt)))] = t.*.updtab[@bitCast(@as(isize, @intCast(x)))];
            }
        }
        {
            x = bot - amnt;
            while (x != bot) : (x += 1) {
                t.*.updtab[@bitCast(@as(isize, @intCast(x)))] = 1;
            }
        }
    }
    if (amnt > (bot - top)) {
        amnt = bot - top;
    }
    _ = msetD(@ptrCast(@alignCast((t.*.sary + @as(usize, @bitCast(@as(isize, @intCast(bot))))) - @as(usize, @bitCast(@as(isize, @intCast(amnt)))))), t.*.li, amnt);
    if (amnt == (bot - top)) {
        _ = msetI(@ptrCast(@alignCast((t.*.updtab + @as(usize, @bitCast(@as(isize, @intCast(bot))))) - @as(usize, @bitCast(@as(isize, @intCast(amnt)))))), 1, amnt);
    }
}
pub export fn scrn_invalidate(arg_t: [*c]SCRN) void {
    var t = arg_t;
    _ = &t;
    mfill(t.*.scrn, -@as(c_int, 1), t.*.li * t.*.co);
    _ = msetI(@ptrCast(@alignCast(t.*.attr)), 0, t.*.li * t.*.co);
    _ = msetI(@ptrCast(@alignCast(t.*.updtab)), 1, t.*.li);
}
pub fn meta_color_single(arg_s: [*c]const u8) callconv(.c) c_int {
    var s = arg_s;
    _ = &s;
    if (!(strcmp(s, "inverse") != 0)) return INVERSE else if (!(strcmp(s, "underline") != 0)) return UNDERLINE else if (!(strcmp(s, "bold") != 0)) return BOLD else if (!(strcmp(s, "blink") != 0)) return BLINK else if (!(strcmp(s, "dim") != 0)) return DIM else if (!(strcmp(s, "italic") != 0)) return ITALIC else if (!(strcmp(s, "dunderline") != 0)) return DOUBLE_UNDERLINE else if (!(strcmp(s, "stricken") != 0)) return CROSSED_OUT else if (!(strcmp(s, "white") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 7) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "cyan") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 6) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "magenta") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 5) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "blue") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 4) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "yellow") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 3) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "green") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 2) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "red") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 1) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "black") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 0) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "bg_white") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 7) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_cyan") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 6) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_magenta") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 5) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_blue") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 4) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_yellow") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 3) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_green") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 2) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_red") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 1) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_black") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 0) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "WHITE") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 15) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "CYAN") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 14) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "MAGENTA") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 13) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "BLUE") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 12) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "YELLOW") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 11) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "GREEN") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 10) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "RED") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 9) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "BLACK") != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 8) << @intCast(FG_SHIFT)) else if (!(strcmp(s, "bg_WHITE") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 15) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_CYAN") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 14) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_MAGENTA") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 13) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_BLUE") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 12) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_YELLOW") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 11) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_GREEN") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 10) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_RED") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 9) << @intCast(BG_SHIFT)) else if (!(strcmp(s, "bg_BLACK") != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 8) << @intCast(BG_SHIFT)) else if ((((((((((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 'f')) and (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'g'))) and (@as(c_int, s[@as(c_int, 2)]) == @as(c_int, '_'))) and (@as(c_int, s[@as(c_int, 3)]) >= @as(c_int, '0'))) and (@as(c_int, s[@as(c_int, 3)]) <= @as(c_int, '5'))) and (@as(c_int, s[@as(c_int, 4)]) >= @as(c_int, '0'))) and (@as(c_int, s[@as(c_int, 4)]) <= @as(c_int, '5'))) and (@as(c_int, s[@as(c_int, 5)]) >= @as(c_int, '0'))) and (@as(c_int, s[@as(c_int, 5)]) <= @as(c_int, '5'))) and !(@as(c_int, s[@as(c_int, 6)]) != 0)) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | ((((@as(c_int, 16) + (((@as(c_int, s[@as(c_int, 3)]) - @as(c_int, '0')) * @as(c_int, 6)) * @as(c_int, 6))) + ((@as(c_int, s[@as(c_int, 4)]) - @as(c_int, '0')) * @as(c_int, 6))) + (@as(c_int, s[@as(c_int, 5)]) - @as(c_int, '0'))) << @intCast(FG_SHIFT)) else if ((((((((((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 'b')) and (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'g'))) and (@as(c_int, s[@as(c_int, 2)]) == @as(c_int, '_'))) and (@as(c_int, s[@as(c_int, 3)]) >= @as(c_int, '0'))) and (@as(c_int, s[@as(c_int, 3)]) <= @as(c_int, '5'))) and (@as(c_int, s[@as(c_int, 4)]) >= @as(c_int, '0'))) and (@as(c_int, s[@as(c_int, 4)]) <= @as(c_int, '5'))) and (@as(c_int, s[@as(c_int, 5)]) >= @as(c_int, '0'))) and (@as(c_int, s[@as(c_int, 5)]) <= @as(c_int, '5'))) and !(@as(c_int, s[@as(c_int, 6)]) != 0)) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | ((((@as(c_int, 16) + (((@as(c_int, s[@as(c_int, 3)]) - @as(c_int, '0')) * @as(c_int, 6)) * @as(c_int, 6))) + ((@as(c_int, s[@as(c_int, 4)]) - @as(c_int, '0')) * @as(c_int, 6))) + (@as(c_int, s[@as(c_int, 5)]) - @as(c_int, '0'))) << @intCast(BG_SHIFT)) else if (((((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 'f')) and (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'g'))) and (@as(c_int, s[@as(c_int, 2)]) == @as(c_int, '_'))) and (ztoi(s + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 3)))))) >= @as(c_int, 0))) and (ztoi(s + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 3)))))) <= @as(c_int, 23))) return (@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, 232) + (ztoi(s + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 3)))))) << @intCast(FG_SHIFT))) else if (((((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 'b')) and (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'g'))) and (@as(c_int, s[@as(c_int, 2)]) == @as(c_int, '_'))) and (ztoi(s + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 3)))))) >= @as(c_int, 0))) and (ztoi(s + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 3)))))) <= @as(c_int, 23))) return (@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, 232) + (ztoi(s + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 3)))))) << @intCast(BG_SHIFT))) else return 0;
}
pub export fn meta_color(arg_s: [*c]const u8) c_int {
    var s = arg_s;
    _ = &s;
    var code: c_int = 0;
    _ = &code;
    while (@as(c_int, s.*) != 0) {
        var buf: [32]u8 = undefined;
        _ = &buf;
        var x: c_int = 0;
        _ = &x;
        while (@as(c_int, s.*) != 0) if ((@as(c_int, s.*) != 0) and (@as(c_int, s.*) != @as(c_int, '+'))) {
            if (@as(ptrdiff_t, x) != (@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))) - @as(ptrdiff_t, 1))) {
                buf[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &x;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = s.*;
            }
            s += 1;
        } else break;
        if (@as(c_int, s.*) == @as(c_int, '+')) {
            s += 1;
        }
        buf[@bitCast(@as(isize, @intCast(x)))] = 0;
        code |= meta_color_single(@ptrCast(@alignCast(&buf)));
    }
    return code;
}
pub export fn genfield(arg_t: [*c]SCRN, arg_scrn_1: [*c][4]c_int, arg_attr: [*c]c_int, arg_x: ptrdiff_t, arg_y: ptrdiff_t, arg_ofst: ptrdiff_t, arg_s: [*c]const u8, arg_len: ptrdiff_t, arg_atr: c_int, arg_width: ptrdiff_t, arg_flg: c_int, arg_fmt: [*c]c_int) void {
    var t = arg_t;
    _ = &t;
    var scrn_1 = arg_scrn_1;
    _ = &scrn_1;
    var attr = arg_attr;
    _ = &attr;
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    var ofst = arg_ofst;
    _ = &ofst;
    var s = arg_s;
    _ = &s;
    var len = arg_len;
    _ = &len;
    var atr = arg_atr;
    _ = &atr;
    var width = arg_width;
    _ = &width;
    var flg = arg_flg;
    _ = &flg;
    var fmt = arg_fmt;
    _ = &fmt;
    var col: ptrdiff_t = undefined;
    _ = &col;
    var sm: struct_utf8_sm = undefined;
    _ = &sm;
    var last_col: ptrdiff_t = x + width;
    _ = &last_col;
    utf8_init(&sm);
    {
        col = 0;
        while ((len != @as(ptrdiff_t, 0)) and (x < last_col)) : (len -= 1) {
            var c: c_int = @as([*c]const u8, @ptrCast(@alignCast(blk: {
                const ref = &s;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }))).*;
            _ = &c;
            var wid: ptrdiff_t = -@as(c_int, 1);
            _ = &wid;
            var my_atr: c_int = atr;
            _ = &my_atr;
            if (fmt != null) {
                var fmtatr: c_int = (blk: {
                    const ref = &fmt;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).*;
                _ = &fmtatr;
                if ((fmtatr & (@as(c_int, 1023) << @intCast(FG_SHIFT))) != 0) {
                    my_atr = (my_atr & ~(@as(c_int, 1023) << @intCast(FG_SHIFT))) | (fmtatr & (@as(c_int, 1023) << @intCast(FG_SHIFT)));
                }
                if ((fmtatr & (@as(c_int, 1023) << @intCast(BG_SHIFT))) != 0) {
                    my_atr = (my_atr & ~(@as(c_int, 1023) << @intCast(BG_SHIFT))) | (fmtatr & (@as(c_int, 1023) << @intCast(BG_SHIFT)));
                }
                my_atr |= fmtatr & (((((((INVERSE + UNDERLINE) + BOLD) + BLINK) + DIM) + ITALIC) + DOUBLE_UNDERLINE) + CROSSED_OUT);
            }
            if (locale_map.*.type != 0) {
                c = utf8_decode(&sm, @as(u8, @bitCast(@as(i8, @truncate(c)))));
                if (c >= @as(c_int, 0)) {
                    wid = joe_wcwidth(1, c);
                }
            } else {
                wid = 1;
            }
            if (wid >= @as(ptrdiff_t, 0)) {
                if (col >= ofst) {
                    if ((x + wid) > last_col) {
                        while (x < last_col) {
                            outatr(locale_map, t, scrn_1, attr, x, y, '>', my_atr);
                            scrn_1 += 1;
                            attr += 1;
                            x += 1;
                        }
                    } else if (wid != 0) {
                        outatr(locale_map, t, scrn_1, attr, x, y, c, my_atr);
                        x += wid;
                        scrn_1 += @as(usize, @bitCast(@as(isize, @intCast(wid))));
                        attr += @as(usize, @bitCast(@as(isize, @intCast(wid))));
                    }
                } else if ((col + wid) > ofst) {
                    wid -= ofst - col;
                    col = ofst;
                    while (wid != 0) {
                        outatr(locale_map, t, scrn_1, attr, x, y, '<', my_atr);
                        scrn_1 += 1;
                        attr += 1;
                        x += 1;
                        col += 1;
                        wid -= 1;
                    }
                } else {
                    col += wid;
                }
            }
        }
    }
    while (x < last_col) {
        outatr(locale_map, t, scrn_1, attr, x, y, ' ', atr);
        x += 1;
        scrn_1 += 1;
        attr += 1;
    }
    outatr_complete(t);
    if (flg != 0) {
        _ = eraeol(t, x, y, atr);
    }
}
pub export fn txtwidth(arg_s: [*c]const u8, arg_len: ptrdiff_t) ptrdiff_t {
    var s = arg_s;
    _ = &s;
    var len = arg_len;
    _ = &len;
    if (locale_map.*.type != 0) {
        var col: ptrdiff_t = 0;
        _ = &col;
        var sm: struct_utf8_sm = undefined;
        _ = &sm;
        utf8_init(&sm);
        while ((blk: {
            const ref = &len;
            const tmp = ref.*;
            ref.* -= 1;
            break :blk tmp;
        }) != 0) {
            var d: c_int = utf8_decode(&sm, (blk: {
                const ref = &s;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).*);
            _ = &d;
            if (d >= @as(c_int, 0)) {
                col += joe_wcwidth(1, d);
            }
        }
        return col;
    } else return len;
    return undefined;
}
pub export fn txtwidth1(arg_map: [*c]struct_charmap, arg_tabwidth: off_t, arg_s: [*c]const u8, arg_len: ptrdiff_t) off_t {
    var map = arg_map;
    _ = &map;
    var tabwidth = arg_tabwidth;
    _ = &tabwidth;
    var s = arg_s;
    _ = &s;
    var len = arg_len;
    _ = &len;
    if (map.*.type != 0) {
        var col: off_t = 0;
        _ = &col;
        var sm: struct_utf8_sm = undefined;
        _ = &sm;
        utf8_init(&sm);
        while ((blk: {
            const ref = &len;
            const tmp = ref.*;
            ref.* -= 1;
            break :blk tmp;
        }) != 0) {
            var d: c_int = utf8_decode(&sm, (blk: {
                const ref = &s;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).*);
            _ = &d;
            if (d == @as(c_int, '\t')) {
                col += 1;
                col += tabwidth - @rem(col, tabwidth);
            } else if (d >= @as(c_int, 0)) {
                col += joe_wcwidth(1, d);
            }
        }
        return col;
    } else {
        var col: off_t = 0;
        _ = &col;
        while ((blk: {
            const ref = &len;
            const tmp = ref.*;
            ref.* -= 1;
            break :blk tmp;
        }) != 0) {
            if (@as(c_int, (blk: {
                const ref = &s;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).*) == @as(c_int, '\t')) {
                col += 1;
                col += tabwidth - @rem(col, tabwidth);
            } else {
                col += 1;
            }
        }
        return col;
    }
    return undefined;
}
pub export fn genfmt(arg_t: [*c]SCRN, arg_x: ptrdiff_t, arg_y: ptrdiff_t, arg_ofst: ptrdiff_t, arg_s: [*c]const u8, arg_atr: c_int, arg_iatr: c_int, arg_flg: c_int) void {
    var t = arg_t;
    _ = &t;
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    var ofst = arg_ofst;
    _ = &ofst;
    var s = arg_s;
    _ = &s;
    var atr = arg_atr;
    _ = &atr;
    var iatr = arg_iatr;
    _ = &iatr;
    var flg = arg_flg;
    _ = &flg;
    var scrn_1: [*c][4]c_int = (t.*.scrn + @as(usize, @bitCast(@as(isize, @intCast(y * t.*.co))))) + @as(usize, @bitCast(@as(isize, @intCast(x))));
    _ = &scrn_1;
    var attr: [*c]c_int = (t.*.attr + @as(usize, @bitCast(@as(isize, @intCast(y * t.*.co))))) + @as(usize, @bitCast(@as(isize, @intCast(x))));
    _ = &attr;
    var col: ptrdiff_t = 0;
    _ = &col;
    var c: c_int = undefined;
    _ = &c;
    var sm: struct_utf8_sm = undefined;
    _ = &sm;
    var inverted: c_int = @intFromBool(!!((atr & INVERSE) != 0));
    _ = &inverted;
    var origcolor: c_int = atr & ~((@as(c_int, 1023) << @intCast(FG_SHIFT)) | (@as(c_int, 1023) << @intCast(BG_SHIFT)));
    _ = &origcolor;
    if ((iatr != 0) and (inverted != 0)) {
        atr = iatr | (atr & ~(((@as(c_int, 1023) << @intCast(FG_SHIFT)) | (@as(c_int, 1023) << @intCast(BG_SHIFT))) | INVERSE));
    }
    utf8_init(&sm);
    while ((blk: {
        const tmp = @as(c_int, @as([*c]const u8, @ptrCast(@alignCast(blk_1: {
            const ref = &s;
            const tmp_2 = ref.*;
            ref.* += 1;
            break :blk_1 tmp_2;
        }))).*);
        c = tmp;
        break :blk tmp;
    }) != @as(c_int, '\x00')) if (c == @as(c_int, '\\')) {
        while (true) {
            switch (blk: {
                const tmp = @as(c_int, (blk_1: {
                    const ref = &s;
                    const tmp_2 = ref.*;
                    ref.* += 1;
                    break :blk_1 tmp_2;
                }).*);
                c = tmp;
                break :blk tmp;
            }) {
                @as(c_int, 'u'), @as(c_int, 'U') => {
                    atr ^= UNDERLINE;
                    break;
                },
                @as(c_int, 'i'), @as(c_int, 'I') => {
                    if (iatr != 0) {
                        inverted = @intFromBool(!(inverted != 0));
                        atr = (if (inverted != 0) iatr else origcolor) | (atr & ~((@as(c_int, 1023) << @intCast(FG_SHIFT)) | (@as(c_int, 1023) << @intCast(BG_SHIFT))));
                    } else {
                        atr ^= INVERSE;
                    }
                    break;
                },
                @as(c_int, 'b'), @as(c_int, 'B') => {
                    atr ^= BOLD;
                    break;
                },
                @as(c_int, 'l'), @as(c_int, 'L') => {
                    atr ^= ITALIC;
                    break;
                },
                @as(c_int, 'd'), @as(c_int, 'D') => {
                    atr ^= DIM;
                    break;
                },
                @as(c_int, 'f'), @as(c_int, 'F') => {
                    atr ^= BLINK;
                    break;
                },
                @as(c_int, 's'), @as(c_int, 'S') => {
                    atr ^= CROSSED_OUT;
                    break;
                },
                @as(c_int, 'z'), @as(c_int, 'Z') => {
                    atr ^= DOUBLE_UNDERLINE;
                    break;
                },
                @as(c_int, 0) => {
                    s -= 1;
                    break;
                },
                @as(c_int, '@') => {
                    c = 0;
                    if ((blk: {
                        const ref = &col;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    }) >= ofst) {
                        outatr(locale_map, t, scrn_1, attr, x, y, c & @as(c_int, 127), atr);
                        scrn_1 += 1;
                        attr += 1;
                        x += 1;
                    }
                    break;
                },
                else => {
                    {
                        if ((blk: {
                            const ref = &col;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        }) >= ofst) {
                            outatr(locale_map, t, scrn_1, attr, x, y, c & @as(c_int, 127), atr);
                            scrn_1 += 1;
                            attr += 1;
                            x += 1;
                        }
                        break;
                    }
                },
            }
            break;
        }
    } else {
        var wid: ptrdiff_t = -@as(c_int, 1);
        _ = &wid;
        if (locale_map.*.type != 0) {
            c = utf8_decode(&sm, @as(u8, @bitCast(@as(i8, @truncate(c)))));
            if (c >= @as(c_int, 0)) {
                wid = joe_wcwidth(1, c);
            }
        } else {
            wid = 1;
        }
        if (wid >= @as(ptrdiff_t, 0)) {
            if (col >= ofst) {
                outatr(locale_map, t, scrn_1, attr, x, y, c, atr);
                scrn_1 += @as(usize, @bitCast(@as(isize, @intCast(wid))));
                attr += @as(usize, @bitCast(@as(isize, @intCast(wid))));
                x += wid;
                col += wid;
            } else if ((col + wid) > ofst) {
                while (col < ofst) {
                    col += 1;
                    wid -= 1;
                }
                while (wid != 0) {
                    outatr(locale_map, t, scrn_1, attr, x, y, '<', atr);
                    scrn_1 += 1;
                    attr += 1;
                    x += 1;
                    col += 1;
                    wid -= 1;
                }
            } else {
                col += wid;
            }
        }
    };
    outatr_complete(t);
    if (flg != 0) {
        _ = eraeol(t, x, y, atr);
    }
}
pub export fn fmtlen(arg_s: [*c]const u8) ptrdiff_t {
    var s = arg_s;
    _ = &s;
    var col: ptrdiff_t = 0;
    _ = &col;
    var sm: struct_utf8_sm = undefined;
    _ = &sm;
    var c: c_int = undefined;
    _ = &c;
    utf8_init(&sm);
    while ((blk: {
        const tmp = @as(c_int, @as([*c]const u8, @ptrCast(@alignCast(blk_1: {
            const ref = &s;
            const tmp_2 = ref.*;
            ref.* += 1;
            break :blk_1 tmp_2;
        }))).*);
        c = tmp;
        break :blk tmp;
    }) != 0) {
        if (c == @as(c_int, '\\')) {
            while (true) {
                switch (@as(c_int, (blk: {
                    const ref = &s;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).*)) {
                    @as(c_int, 'u'), @as(c_int, 'i'), @as(c_int, 'd'), @as(c_int, 'f'), @as(c_int, 'b'), @as(c_int, 'U'), @as(c_int, 'I'), @as(c_int, 'D'), @as(c_int, 'F'), @as(c_int, 'B') => {
                        break;
                    },
                    @as(c_int, 0) => {
                        return col;
                    },
                    else => {
                        col += 1;
                        break;
                    },
                }
                break;
            }
        } else {
            var wid: ptrdiff_t = 0;
            _ = &wid;
            if (locale_map.*.type != 0) {
                c = utf8_decode(&sm, @as(u8, @bitCast(@as(i8, @truncate(c)))));
                if (c >= @as(c_int, 0)) {
                    wid = joe_wcwidth(1, c);
                }
            } else {
                wid = 1;
            }
            col += wid;
        }
    }
    return col;
}
pub export fn fmtpos(arg_s: [*c]const u8, arg_goal: ptrdiff_t) ptrdiff_t {
    var s = arg_s;
    _ = &s;
    var goal = arg_goal;
    _ = &goal;
    var org: [*c]const u8 = s;
    _ = &org;
    var col: ptrdiff_t = 0;
    _ = &col;
    var c: c_int = undefined;
    _ = &c;
    var sm: struct_utf8_sm = undefined;
    _ = &sm;
    utf8_init(&sm);
    while (((blk: {
        const tmp = @as(c_int, @as([*c]const u8, @ptrCast(@alignCast(s))).*);
        c = tmp;
        break :blk tmp;
    }) != 0) and (col < goal)) {
        s += 1;
        if (c == @as(c_int, '\\')) {
            while (true) {
                switch (@as(c_int, (blk: {
                    const ref = &s;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).*)) {
                    @as(c_int, 'u'), @as(c_int, 'i'), @as(c_int, 'd'), @as(c_int, 'f'), @as(c_int, 'b'), @as(c_int, 'U'), @as(c_int, 'I'), @as(c_int, 'D'), @as(c_int, 'F'), @as(c_int, 'B') => {
                        break;
                    },
                    @as(c_int, 0) => {
                        s -= 1;
                        break;
                    },
                    else => {
                        col += 1;
                        break;
                    },
                }
                break;
            }
        } else {
            var wid: ptrdiff_t = 0;
            _ = &wid;
            if (locale_map.*.type != 0) {
                c = utf8_decode(&sm, @as(u8, @bitCast(@as(i8, @truncate(c)))));
                if (c >= @as(c_int, 0)) {
                    wid = joe_wcwidth(1, c);
                }
            } else {
                wid = 1;
            }
            col += wid;
        }
    }
    return (@divExact(@as(c_long, @bitCast(@intFromPtr(s) -% @intFromPtr(org))), @sizeOf(u8)) + goal) - col;
}
pub export fn setextpal(arg_t: [*c]SCRN, arg_palette: [*c]c_int) void {
    var t = arg_t;
    _ = &t;
    var palette = arg_palette;
    _ = &palette;
    t.*.palette = palette;
}


// ── Zig-native screen swap (Phase 3 redesign deepen) ─────────────────
// When `JOE_ZIG_SCREEN_SWAP` / `zig_screen_swap_enabled` is on, hybrid paint
// paths update the `scrn`/`attr` shadow only; `zig_scrn_swap_flush` syncs into
// the redesign `Screen`, runs cell-diff (+ ICH/DCH magic) flush, and drains
// into hybrid `obuf`. Default off — live path unchanged.

/// C-visible gate (also set from `JOE_ZIG_SCREEN_SWAP` in `ttopnn`). Default 0.
pub export var zig_screen_swap_enabled: c_int = 0;

var zig_scr_storage: ?terminal.Screen = null;

fn zigScrnSwapEnsure(t: [*c]SCRN) ?*terminal.Screen {
    if (t == null) return null;
    if (t.*.co <= 0 or t.*.li <= 0) return null;
    const w: u16 = @intCast(t.*.co);
    const h: u16 = @intCast(t.*.li);
    if (zig_scr_storage) |*s| {
        if (s.width != w or s.height != h) {
            s.resize(w, h) catch return null;
            s.clear();
        }
        return s;
    }
    zig_scr_storage = terminal.Screen.init(std.heap.c_allocator, w, h) catch return null;
    return &zig_scr_storage.?;
}

fn zigScrnSwapResize(t: [*c]SCRN) void {
    if (zig_screen_swap_enabled == 0) return;
    _ = zigScrnSwapEnsure(t);
}

fn zigScrnSwapDestroy() void {
    if (zig_scr_storage) |*s| {
        s.deinit();
        zig_scr_storage = null;
    }
}

fn zigPaletteSlice(t: [*c]SCRN) ?[]const i32 {
    if (t == null or t.*.palette == null) return null;
    // JOE truecolor palette is 256 ints (index 0 unused).
    return @as([*]const i32, @ptrCast(t.*.palette))[0..256];
}

/// End-of-frame swap emit: sync hybrid shadow → Zig Screen → flush → drain.
/// Places the cursor at `(x, y)`. No-op when the swap gate is off.
pub export fn zig_scrn_swap_flush(arg_t: [*c]SCRN, arg_x: ptrdiff_t, arg_y: ptrdiff_t) void {
    const t = arg_t;
    var x = arg_x;
    var y = arg_y;
    if (zig_screen_swap_enabled == 0 or t == null) return;
    if (t.*.scrn == null or t.*.attr == null) return;

    const scr = zigScrnSwapEnsure(t) orelse return;
    if (x < 0) x = 0;
    if (y < 0) y = 0;
    if (x >= t.*.co) x = t.*.co - 1;
    if (y >= t.*.li) y = t.*.li - 1;

    const cells: [*]const [4]i32 = @ptrCast(@alignCast(t.*.scrn));
    const attrs: [*]const i32 = @ptrCast(@alignCast(t.*.attr));
    terminal.syncHybridGridToScreen(
        scr,
        cells,
        attrs,
        @intCast(t.*.co),
        @intCast(t.*.li),
        zigPaletteSlice(t),
    );

    scr.cursor_x = @intCast(x);
    scr.cursor_y = @intCast(y);
    scr.flush() catch {};

    // Drain requires the drain gate; force on for this call then restore.
    const old_drain = tty.zig_screen_drain_enabled;
    tty.zig_screen_drain_enabled = 1;
    defer tty.zig_screen_drain_enabled = old_drain;
    _ = tty.drainZigScreen(scr) catch {};

    t.*.x = x;
    t.*.y = y;
}
