//! Mouse support — replaces `joe/mouse.c`.
//!
//! Faithful C-ABI Path A port of JOE mouse (mouseopen/mouseclose/mousedn/mouseup/mousedrag/uxtmouse/uextmouse/utomouse/udefm*/mnow/reset_trig_time + floatmouse/rtbutton/joexterm/auto_scroll/auto_trig_time/auto_rate).
//! GPM console mouse: see `gpm.zig` (`gpmopen`/`gpmclose`); wired when `-Dgpm=true` on Linux.
//! Default-on xterm/SGR mouse (`-mouse`); optional `-mouseclip` OSC 52 copy-on-select;
//! `-mousewheel N` lines per notch (default 1; same motion as up/down arrow).

const std = @import("std");
const build_options = @import("build_options");
const gpm = @import("gpm.zig");
const ptrdiff_t = c_long;

const MOUSE_MULTI_THRESH: c_int = 300;
const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;
const TYPEMENU: c_int = 0x0800;
const KEY_MDOWN: c_int = 0x100000;
const KEY_MUP: c_int = 0x100001;
const KEY_MDRAG: c_int = 0x100002;
const KEY_M2DOWN: c_int = 0x100003;
const KEY_M2UP: c_int = 0x100004;
const KEY_M2DRAG: c_int = 0x100005;
const KEY_M3DOWN: c_int = 0x100006;
const KEY_M3UP: c_int = 0x100007;
const KEY_M3DRAG: c_int = 0x100008;
const KEY_MWUP: c_int = 0x100009;
const KEY_MWDOWN: c_int = 0x10000A;
const KEY_MIDDLEUP: c_int = 0x10000B;
const KEY_MIDDLEDOWN: c_int = 0x10000C;
const Cb_BUTTON_MASK: c_int = 0xC3;
const Cb_DRAG: c_int = 0x20;
const Cb_RELEASE: c_int = 0x8000;
const Cb_BUTTON_LEFT: c_int = 0;
const Cb_BUTTON_MIDDLE: c_int = 1;
const Cb_BUTTON_RIGHT: c_int = 2;
const Cb_WHEEL_UP: c_int = 0x40;
const Cb_WHEEL_DOWN: c_int = 0x41;
const Cb_WHEEL_LEFT: c_int = 0x42;
const Cb_WHEEL_RIGHT: c_int = 0x43;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn malloc(n: c_ulong) ?*anyopaque;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub const off_t = i64;
pub const time_t = i64;
pub const suseconds_t = i32;
pub const struct_timeval = extern struct {
    tv_sec: time_t = 0,
    tv_usec: suseconds_t = 0,
    _pad: i32 = 0,
};
pub extern fn gettimeofday(tv: [*c]struct_timeval, tz: ?*anyopaque) c_int;
pub const B = struct_b;
const struct_unnamed_1 = extern struct {
    next: [*c]B = null,
    prev: [*c]B = null,
};
const struct_unnamed_2 = extern struct {
    next: [*c]P = null,
    prev: [*c]P = null,
};
pub const struct_p = extern struct {
    link: struct_unnamed_2 = std.mem.zeroes(struct_unnamed_2),
    b: [*c]B = null,
    _pad0: [24]u8 = std.mem.zeroes([24]u8),
    byte: off_t = 0,
    line: off_t = 0,
    col: off_t = 0,
    xcol: off_t = 0,
    valcol: c_int = 0,
    end: c_int = 0,
    attr: c_int = 0,
    valattr: c_int = 0,
    owner: [*c][*c]P = null,
    tracker: [*c]const u8 = null,
};
pub const P = struct_p;
pub const struct_high_syntax = opaque {};
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
    to_lower: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    to_upper: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    _pad: [2684]u8 = std.mem.zeroes([2684]u8),
};
pub const struct_macro = extern struct {
    _pad: [64]u8 = std.mem.zeroes([64]u8),
};
pub const MACRO = struct_macro;
pub const struct_options = extern struct {
    next: [*c]struct_options = null,
    ftype: [*c]const u8 = null,
    match: ?*anyopaque = null,
    overtype: c_int = 0,
    lmargin: off_t = 0,
    rmargin: off_t = 0,
    autoindent: c_int = 0,
    wordwrap: c_int = 0,
    nobackup: c_int = 0,
    _pad_tab: [4]u8 = std.mem.zeroes([4]u8),
    tab: off_t = 0,
    indentc: c_int = 0,
    _pad_istep: [4]u8 = std.mem.zeroes([4]u8),
    istep: off_t = 0,
    context: [*c]const u8 = null,
    lmsg: [*c]const u8 = null,
    rmsg: [*c]const u8 = null,
    smsg: [*c]const u8 = null,
    zmsg: [*c]const u8 = null,
    linums: c_int = 0,
    hiline: c_int = 0,
    readonly: c_int = 0,
    french: c_int = 0,
    flowed: c_int = 0,
    spaces: c_int = 0,
    crlf: c_int = 0,
    highlight: c_int = 0,
    visiblews: c_int = 0,
    syntax_debug: c_int = 0,
    syntax_name: [*c]const u8 = null,
    syntax: ?*struct_high_syntax = null,
    map_name: [*c]const u8 = null,
    charmap: [*c]struct_charmap = null,
    language: [*c]const u8 = null,
    smarthome: c_int = 0,
    indentfirst: c_int = 0,
    smartbacks: c_int = 0,
    purify: c_int = 0,
    picture: c_int = 0,
    highlighter_context: c_int = 0,
    single_quoted: c_int = 0,
    no_double_quoted: c_int = 0,
    c_comment: c_int = 0,
    cpp_comment: c_int = 0,
    hash_comment: c_int = 0,
    vhdl_comment: c_int = 0,
    semi_comment: c_int = 0,
    tex_comment: c_int = 0,
    hex: c_int = 0,
    viewmode: c_int = 0,
    ansi: c_int = 0,
    title: c_int = 0,
    text_delimiters: [*c]const u8 = null,
    cpara: [*c]const u8 = null,
    cnotpara: [*c]const u8 = null,
    mnew: [*c]MACRO = null,
    mold: [*c]MACRO = null,
    msnew: [*c]MACRO = null,
    msold: [*c]MACRO = null,
    mfirst: [*c]MACRO = null,
};
pub const OPTIONS = struct_options;
pub const pid_t = c_int;
pub const struct_b = extern struct {
    link: struct_unnamed_1 = std.mem.zeroes(struct_unnamed_1),
    bof: [*c]P = null,
    eof: [*c]P = null,
    name: [*c]u8 = null,
    _pad1: [36]u8 = std.mem.zeroes([36]u8),
    orphan: c_int = 0,
    count: c_int = 0,
    changed: c_int = 0,
    backup: c_int = 0,
    _pad_backup: [4]u8 = std.mem.zeroes([4]u8),
    undo: ?*anyopaque = null,
    _pad_marks: [88]u8 = std.mem.zeroes([88]u8),
    o: OPTIONS = std.mem.zeroes(OPTIONS),
    oldcur: [*c]P = null,
    oldtop: [*c]P = null,
    err: [*c]P = null,
    current_dir: [*c]u8 = null,
    shell_flag: c_int = 0,
    rdonly: c_int = 0,
    internal: c_int = 0,
    scratch: c_int = 0,
    er: c_int = 0,
    pid: pid_t = 0,
    out: c_int = 0,
    vt: ?*anyopaque = null,
    raw: c_int = 0,
    _pad_raw: [4]u8 = std.mem.zeroes([4]u8),
    db: ?*anyopaque = null,
    parseone: ?*const fn (map: [*c]struct_charmap, s: [*c]const u8, rtn_name: [*c][*c]u8, rtn_line: [*c]off_t) callconv(.c) void = null,
};
pub const struct_kmap = opaque {};
pub const KMAP = struct_kmap;
pub const struct_kbd = extern struct {
    curmap: ?*KMAP = null,
    topmap: ?*KMAP = null,
    seq: [16]c_int = std.mem.zeroes([16]c_int),
    x: ptrdiff_t = 0,
};
pub const KBD = struct_kbd;
pub const struct_bstack = opaque {};
pub const W = struct_window;
const struct_unnamed_3 = extern struct {
    next: [*c]W = null,
    prev: [*c]W = null,
};
pub const struct_screen = extern struct {
    t: ?*anyopaque = null,
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
    link: struct_unnamed_3 = std.mem.zeroes(struct_unnamed_3),
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
pub const struct_lattr_db = opaque {};
const struct_unnamed_4 = extern struct {
    ww: c_int = 0,
    ai: c_int = 0,
    sp: c_int = 0,
};
pub const struct_bw = extern struct {
    parent: [*c]W = null,
    b: [*c]B = null,
    top: [*c]P = null,
    cursor: [*c]P = null,
    offset: off_t = 0,
    t: [*c]Screen = null,
    h: ptrdiff_t = 0,
    w: ptrdiff_t = 0,
    x: ptrdiff_t = 0,
    y: ptrdiff_t = 0,
    o: OPTIONS = std.mem.zeroes(OPTIONS),
    object: ?*anyopaque = null,
    lincols: c_int = 0,
    curlin: off_t = 0,
    top_changed: c_int = 0,
    db: ?*struct_lattr_db = null,
    shell_flag: c_int = 0,
    pasting: c_int = 0,
    last_viewmode: c_int = 0,
    saved: struct_unnamed_4 = std.mem.zeroes(struct_unnamed_4),
};
pub const BW = struct_bw;
pub const struct_tw = extern struct {
    stalin: [*c]u8 = null,
    staright: [*c]u8 = null,
    staon: c_int = 0,
    _pad_staon: [4]u8 = std.mem.zeroes([4]u8),
    prevline: off_t = 0,
    changed: c_int = 0,
    _pad_changed: [4]u8 = std.mem.zeroes([4]u8),
    prev_b: [*c]B = null,
};
pub const TW = struct_tw;
pub const struct_pw = extern struct {
    pfunc: ?*const fn (w: [*c]W, s: [*c]u8, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int = null,
    abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int = null,
    tab: ?*const fn (bw: [*c]BW, k: c_int) callconv(.c) c_int = null,
    prompt: [*c]u8 = null,
    promptlen: ptrdiff_t = 0,
    promptofst: ptrdiff_t = 0,
    hist: [*c]B = null,
    object: ?*anyopaque = null,
    file_prompt: c_int = 0,
    _pad_file_prompt: [4]u8 = std.mem.zeroes([4]u8),
};
pub const PW = struct_pw;
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
pub extern fn dokey(kbd: [*c]KBD, n: c_int) [*c]MACRO;
pub extern fn exemac(m: [*c]MACRO, k: c_int) c_int;
pub extern fn ttgetc() c_int;
pub extern fn ttgetch() c_int;
pub extern fn ttputs(s: [*c]const u8) void;
pub extern fn ttflsh() c_int;
pub extern var obuf: [*c]u8;
pub extern var obufp: ptrdiff_t;
pub extern var obufsiz: ptrdiff_t;
pub const FILE = anyopaque;
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn joe_write(fd: c_int, buf: ?*const anyopaque, siz: ptrdiff_t) ptrdiff_t;
pub extern fn fileno(stream: ?*FILE) c_int;
pub extern var termout: ?*FILE;

/// JOE `ttputc` macro (`tty.h`) as a Zig fn — write one byte into `obuf`.
fn ttputc(c: u8) callconv(.c) void {
    obuf[@intCast(obufp)] = c;
    obufp += 1;
    if (obufp == obufsiz) {
        _ = ttflsh();
    }
}
pub extern fn utf8_encode(buf: [*c]u8, c: c_int) ptrdiff_t;
pub extern fn from_uni(map: [*c]struct_charmap, c: c_int) c_int;
pub extern fn to_uni(map: [*c]struct_charmap, c: c_int) c_int;
pub extern fn watpos(t: [*c]Screen, x: ptrdiff_t, y: ptrdiff_t) [*c]W;
pub extern fn uvscroll(w: [*c]W, n: ptrdiff_t) c_int;
pub extern fn uhscroll(w: [*c]W, n: ptrdiff_t) c_int;
pub extern fn menujump(m: [*c]MENU, x: ptrdiff_t, y: ptrdiff_t) void;
pub extern fn wgrowup(w: [*c]W) c_int;
pub extern fn wgrowdown(w: [*c]W) c_int;
pub extern fn pdup(p: [*c]P, where: [*c]const u8) [*c]P;
pub extern fn prm(p: [*c]P) void;
pub extern fn pset(d: [*c]P, s: [*c]P) void;
pub extern fn pgoto(p: [*c]P, loc: off_t) [*c]P;
pub extern fn pline(p: [*c]P, line: off_t) [*c]P;
pub extern fn pcol(p: [*c]P, goalcol: off_t) [*c]P;
pub extern fn piscol(p: [*c]P) off_t;
pub extern fn pgetc(p: [*c]P) c_int;
pub extern fn p_goto_bol(p: [*c]P) void;
pub extern fn pnextl(p: [*c]P) [*c]P;
pub extern fn pisbol(p: [*c]P) c_int;
pub extern fn piseol(p: [*c]P) c_int;
pub extern fn markv(r: c_int) c_int;
pub extern fn umarkb(w: [*c]W, k: c_int) c_int;
pub extern fn umarkk(w: [*c]W, k: c_int) c_int;
pub extern fn ublkcpy(w: [*c]W, k: c_int) c_int;
pub extern fn u_goto_prev(w: [*c]W, k: c_int) c_int;
pub extern fn u_goto_next(w: [*c]W, k: c_int) c_int;
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern var maint: [*c]Screen;
pub extern var usexmouse: c_int;
pub extern var square: c_int;
pub extern var markb: [*c]P;
pub extern var markk: [*c]P;
pub extern var locale_map: [*c]struct_charmap;
pub export fn mousedn(arg_x: ptrdiff_t, arg_y: ptrdiff_t, arg_middle: c_int) void {
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    var middle = arg_middle;
    _ = &middle;
    Cx = x;
    Cy = y;
    if (middle != 0) {
        clicks = 4;
        fake_key(KEY_MIDDLEDOWN);
    } else {
        if ((last_msec == @as(c_long, 0)) or ((mnow() - last_msec) > @as(c_long, MOUSE_MULTI_THRESH))) {
            clicks = 1;
            fake_key(KEY_MDOWN);
        } else if (clicks == @as(c_int, 1)) {
            clicks = 2;
            fake_key(KEY_M2DOWN);
        } else if (clicks == @as(c_int, 2)) {
            clicks = 3;
            fake_key(KEY_M3DOWN);
        } else {
            clicks = 1;
            fake_key(KEY_MDOWN);
        }
    }
}
pub export fn mouseup(arg_x: ptrdiff_t, arg_y: ptrdiff_t) void {
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    Cx = x;
    Cy = y;
    while (true) {
        switch (clicks) {
            @as(c_int, 1) => {
                fake_key(KEY_MUP);
                break;
            },
            @as(c_int, 2) => {
                fake_key(KEY_M2UP);
                break;
            },
            @as(c_int, 3) => {
                fake_key(KEY_M3UP);
                break;
            },
            @as(c_int, 4) => {
                fake_key(KEY_MIDDLEUP);
                break;
            },
            else => {},
        }
        break;
    }
    last_msec = mnow();
}
pub export fn mousedrag(arg_x: ptrdiff_t, arg_y: ptrdiff_t) void {
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    Cx = x;
    Cy = y;
    while (true) {
        switch (clicks) {
            @as(c_int, 1) => {
                fake_key(KEY_MDRAG);
                break;
            },
            @as(c_int, 2) => {
                fake_key(KEY_M2DRAG);
                break;
            },
            @as(c_int, 3) => {
                fake_key(KEY_M3DRAG);
                break;
            },
            else => {},
        }
        break;
    }
}
pub export fn utomouse(arg_xx: [*c]W, arg_k: c_int) c_int {
    var xx = arg_xx;
    _ = &xx;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var x: ptrdiff_t = Cx - @as(ptrdiff_t, 1);
    _ = &x;
    var y: ptrdiff_t = Cy - @as(ptrdiff_t, 1);
    _ = &y;
    var w: [*c]W = watpos(maint, x, y);
    _ = &w;
    if (!(w != null)) return -@as(c_int, 1);
    maint.*.curwin = w;
    drag_size = 0;
    if (w.*.watom.*.what == TYPETW) {
        while (true) {
            if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
            bw_1 = @ptrCast(@alignCast(w.*.object));
            if (!false) break;
        }
        if (bw_1.*.o.hex != 0) {
            var goal_col: off_t = (@as(off_t, x - w.*.x) + bw_1.*.offset) - @as(off_t, 60);
            _ = &goal_col;
            var goal_line: off_t = undefined;
            _ = &goal_line;
            var goal_byte: off_t = undefined;
            _ = &goal_byte;
            if (goal_col < @as(off_t, 0)) {
                goal_col = 0;
            }
            if (goal_col > @as(off_t, 15)) {
                goal_col = 15;
            }
            if (@as([*c]TW, @ptrCast(@alignCast(bw_1.*.object))).*.staon != 0) if (y == w.*.y) {
                if (y != maint.*.wind) {
                    drag_size = y;
                }
                return -@as(c_int, 1);
            } else {
                goal_line = (@as(off_t, y - w.*.y) + @divTrunc(bw_1.*.top.*.byte, @as(off_t, 16))) - @as(off_t, 1);
            } else {
                goal_line = @as(off_t, y - w.*.y) + @divTrunc(bw_1.*.top.*.byte, @as(off_t, 16));
            }
            goal_byte = (goal_line * @as(off_t, 16)) + goal_col;
            if (goal_byte > bw_1.*.b.*.eof.*.byte) {
                goal_byte = bw_1.*.b.*.eof.*.byte;
            }
            _ = pgoto(bw_1.*.cursor, goal_byte);
            return 0;
        } else {
            var goal_col: off_t = (@as(off_t, x - w.*.x) + bw_1.*.offset) - @as(off_t, bw_1.*.lincols);
            _ = &goal_col;
            var goal_line: off_t = undefined;
            _ = &goal_line;
            if (goal_col < @as(off_t, 0)) {
                goal_col = 0;
            }
            if (@as([*c]TW, @ptrCast(@alignCast(bw_1.*.object))).*.staon != 0) if (y == w.*.y) {
                if (y != maint.*.wind) {
                    drag_size = y;
                }
                return -@as(c_int, 1);
            } else {
                goal_line = (@as(off_t, y - w.*.y) + bw_1.*.top.*.line) - @as(off_t, 1);
            } else {
                goal_line = @as(off_t, y - w.*.y) + bw_1.*.top.*.line;
            }
            _ = pline(bw_1.*.cursor, goal_line);
            _ = pcol(bw_1.*.cursor, goal_col);
            if (floatmouse != 0) {
                bw_1.*.cursor.*.xcol = goal_col;
            } else {
                bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
            }
            return 0;
        }
    } else if (w.*.watom.*.what == TYPEPW) {
        var pw_1: [*c]PW = undefined;
        _ = &pw_1;
        while (true) {
            if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
            bw_1 = @ptrCast(@alignCast(w.*.object));
            if (!false) break;
        }
        pw_1 = @ptrCast(@alignCast(bw_1.*.object));
        _ = pcol(bw_1.*.cursor, ((@as(off_t, x - w.*.x) + bw_1.*.offset) - @as(off_t, pw_1.*.promptlen)) + @as(off_t, pw_1.*.promptofst));
        bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
        return 0;
    } else if (w.*.watom.*.what == TYPEMENU) {
        menujump(@ptrCast(@alignCast(w.*.object)), x - w.*.x, y - w.*.y);
        return 0;
    } else return -@as(c_int, 1);
    unreachable;
}
pub export fn mnow() c_long {
    var tv: struct_timeval = undefined;
    _ = &tv;
    _ = gettimeofday(&tv, null);
    return @truncate((tv.tv_sec * @as(time_t, 1000)) + @as(time_t, @divTrunc(tv.tv_usec, @as(c_int, 1000))));
}
pub export fn reset_trig_time() void {
    if (!(auto_rate != 0)) {
        auto_rate = 1;
    }
    auto_trig_time = mnow() + @divTrunc(@as(ptrdiff_t, 300), @as(ptrdiff_t, 1) + auto_rate);
}
pub fn tomousestay() callconv(.c) c_int {
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var x: ptrdiff_t = Cx - @as(ptrdiff_t, 1);
    _ = &x;
    var y: ptrdiff_t = Cy - @as(ptrdiff_t, 1);
    _ = &y;
    var w: [*c]W = undefined;
    _ = &w;
    w = maint.*.curwin;
    bw_1 = @ptrCast(@alignCast(w.*.object));
    if (w.*.watom.*.what == TYPETW) {
        if (bw_1.*.o.hex != 0) {
            var goal_col: off_t = (@as(off_t, x - w.*.x) + bw_1.*.offset) - @as(off_t, 60);
            _ = &goal_col;
            var goal_line: off_t = undefined;
            _ = &goal_line;
            var goal_byte: off_t = undefined;
            _ = &goal_byte;
            if (goal_col < @as(off_t, 0)) {
                goal_col = 0;
            }
            if (goal_col > @as(off_t, 15)) {
                goal_col = 15;
            }
            if (@as([*c]TW, @ptrCast(@alignCast(bw_1.*.object))).*.staon != 0) if (y <= w.*.y) {
                goal_col = 0;
                goal_line = @divTrunc(bw_1.*.top.*.byte, @as(off_t, 16));
            } else if (y >= (w.*.y + w.*.h)) {
                goal_line = (@divTrunc(bw_1.*.top.*.byte, @as(off_t, 16)) + @as(off_t, w.*.h)) - @as(off_t, 2);
                goal_col = 15;
            } else {
                goal_line = (@as(off_t, y - w.*.y) + @divTrunc(bw_1.*.top.*.byte, @as(off_t, 16))) - @as(off_t, 1);
            } else if (y < w.*.y) {
                goal_col = 0;
                goal_line = @divTrunc(bw_1.*.top.*.byte, @as(off_t, 16));
            } else if (y >= (w.*.y + w.*.h)) {
                goal_line = (@divTrunc(bw_1.*.top.*.byte, @as(off_t, 16)) + @as(off_t, w.*.h)) - @as(off_t, 1);
                goal_col = 15;
            } else {
                goal_line = @as(off_t, y - w.*.y) + @divTrunc(bw_1.*.top.*.byte, @as(off_t, 16));
            }
            goal_byte = (goal_line * @as(off_t, 16)) + goal_col;
            if (goal_byte > bw_1.*.b.*.eof.*.byte) {
                goal_byte = bw_1.*.b.*.eof.*.byte;
            }
            _ = pgoto(bw_1.*.cursor, goal_byte);
            tmspos = blk: {
                const tmp = piscol(bw_1.*.cursor);
                bw_1.*.cursor.*.xcol = tmp;
                break :blk tmp;
            };
            return 0;
        } else {
            var goal_col: off_t = (@as(off_t, x - w.*.x) + bw_1.*.offset) - @as(off_t, bw_1.*.lincols);
            _ = &goal_col;
            var goal_line: off_t = undefined;
            _ = &goal_line;
            if (goal_col < @as(off_t, 0)) {
                goal_col = 0;
            }
            if (@as([*c]TW, @ptrCast(@alignCast(bw_1.*.object))).*.staon != 0) if (y <= w.*.y) {
                goal_col = 0;
                goal_line = bw_1.*.top.*.line;
            } else if (y >= (w.*.y + w.*.h)) {
                goal_col = 1000;
                goal_line = (@as(off_t, w.*.h) + bw_1.*.top.*.line) - @as(off_t, 2);
            } else {
                goal_line = (@as(off_t, y - w.*.y) + bw_1.*.top.*.line) - @as(off_t, 1);
            } else if (y < w.*.y) {
                goal_col = 0;
                goal_line = bw_1.*.top.*.line;
            } else if (y >= (w.*.y + w.*.h)) {
                goal_col = 1000;
                goal_line = (@as(off_t, w.*.h) + bw_1.*.top.*.line) - @as(off_t, 1);
            } else {
                goal_line = @as(off_t, y - w.*.y) + bw_1.*.top.*.line;
            }
            _ = pline(bw_1.*.cursor, goal_line);
            _ = pcol(bw_1.*.cursor, goal_col);
            tmspos = blk: {
                const tmp = goal_col;
                bw_1.*.cursor.*.xcol = tmp;
                break :blk tmp;
            };
            if (!(floatmouse != 0)) {
                tmspos = piscol(bw_1.*.cursor);
            }
            return 0;
        }
    } else if (w.*.watom.*.what == TYPEPW) {
        var pw_1: [*c]PW = @ptrCast(@alignCast(bw_1.*.object));
        _ = &pw_1;
        _ = pcol(bw_1.*.cursor, ((@as(off_t, x - w.*.x) + bw_1.*.offset) - @as(off_t, pw_1.*.promptlen)) + @as(off_t, pw_1.*.promptofst));
        tmspos = blk: {
            const tmp = piscol(bw_1.*.cursor);
            bw_1.*.cursor.*.xcol = tmp;
            break :blk tmp;
        };
        return 0;
    } else return -@as(c_int, 1);
}
pub fn select_done(arg_map: [*c]struct_charmap) callconv(.c) void {
    var map = arg_map;
    _ = &map;
    if ((((mouseclip != 0) or (joexterm != 0)) and (markv(1) != 0))) {
        const left: off_t = markb.*.xcol;
        const right: off_t = markk.*.xcol;
        const q: [*c]P = pdup(markb, "select_done");
        defer prm(q);

        // Collect selection bytes first, then emit one atomic OSC 52 write.
        // Chunked ttputs/ttflsh mid-sequence desyncs strict terminals (Ghostty):
        // the display parser eats CSI from a later edupd as if it were payload.
        var plain_cap: usize = 256;
        var plain_len: usize = 0;
        var plain: [*c]u8 = @ptrCast(@alignCast(joe_malloc(@intCast(plain_cap)) orelse return));
        defer joe_free(plain);

        while (q.*.byte < markk.*.byte) {
            while (((q.*.byte < markk.*.byte) and (square != 0)) and ((piscol(q) < left) or (piscol(q) >= right))) {
                _ = pgetc(q);
            }
            while ((q.*.byte < markk.*.byte) and (!(square != 0) or ((piscol(q) >= left) and (piscol(q) < right)))) {
                var buf: [16]u8 = undefined;
                var len: ptrdiff_t = 0;
                var c = pgetc(q);
                if (map.*.type != 0) {
                    if (locale_map.*.type != 0) {
                        len = utf8_encode(@ptrCast(@alignCast(&buf)), c);
                    } else {
                        c = from_uni(locale_map, c);
                        if (c == -@as(c_int, 1)) c = '?';
                        buf[0] = @truncate(@as(u8, @intCast(c)));
                        len = 1;
                    }
                } else if (locale_map.*.type != 0) {
                    c = to_uni(map, c);
                    if (c == -@as(c_int, 1)) c = '?';
                    len = utf8_encode(@ptrCast(@alignCast(&buf)), c);
                } else {
                    buf[0] = @truncate(@as(u8, @intCast(c)));
                    len = 1;
                }
                const need = plain_len + @as(usize, @intCast(len));
                if (need > plain_cap) {
                    var ncap = plain_cap;
                    while (ncap < need) ncap *= 2;
                    const nbuf: [*c]u8 = @ptrCast(@alignCast(joe_malloc(@intCast(ncap)) orelse return));
                    @memcpy(nbuf[0..plain_len], plain[0..plain_len]);
                    joe_free(plain);
                    plain = nbuf;
                    plain_cap = ncap;
                }
                @memcpy(plain[plain_len .. plain_len + @as(usize, @intCast(len))], buf[0..@intCast(len)]);
                plain_len = need;
            }
            if (((square != 0) and (q.*.byte < markk.*.byte)) and (piscol(q) >= right)) {
                if (plain_len + 1 > plain_cap) {
                    const ncap = plain_cap * 2;
                    const nbuf: [*c]u8 = @ptrCast(@alignCast(joe_malloc(@intCast(ncap)) orelse return));
                    @memcpy(nbuf[0..plain_len], plain[0..plain_len]);
                    joe_free(plain);
                    plain = nbuf;
                    plain_cap = ncap;
                }
                plain[plain_len] = 10;
                plain_len += 1;
            }
        }

        // base64 expands 4/3; plus OSC prefix "\x1b]52;;" (7) and ST "\x1b\\" (2).
        const b64_len = ((plain_len + 2) / 3) * 4;
        const msg_len = 7 + b64_len + 2;
        const msg: [*c]u8 = @ptrCast(@alignCast(joe_malloc(@intCast(msg_len)) orelse return));
        defer joe_free(msg);
        msg[0] = 0x1b;
        msg[1] = ']';
        msg[2] = '5';
        msg[3] = '2';
        msg[4] = ';';
        msg[5] = ';';
        const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        var o: usize = 6;
        var i: usize = 0;
        while (i + 3 <= plain_len) : (i += 3) {
            const n: u32 = (@as(u32, plain[i]) << 16) | (@as(u32, plain[i + 1]) << 8) | @as(u32, plain[i + 2]);
            msg[o] = alphabet[(n >> 18) & 63];
            msg[o + 1] = alphabet[(n >> 12) & 63];
            msg[o + 2] = alphabet[(n >> 6) & 63];
            msg[o + 3] = alphabet[n & 63];
            o += 4;
        }
        if (plain_len - i == 1) {
            const n: u32 = @as(u32, plain[i]) << 16;
            msg[o] = alphabet[(n >> 18) & 63];
            msg[o + 1] = alphabet[(n >> 12) & 63];
            msg[o + 2] = '=';
            msg[o + 3] = '=';
            o += 4;
        } else if (plain_len - i == 2) {
            const n: u32 = (@as(u32, plain[i]) << 16) | (@as(u32, plain[i + 1]) << 8);
            msg[o] = alphabet[(n >> 18) & 63];
            msg[o + 1] = alphabet[(n >> 12) & 63];
            msg[o + 2] = alphabet[(n >> 6) & 63];
            msg[o + 3] = '=';
            o += 4;
        }
        msg[o] = 0x1b;
        msg[o + 1] = '\\';
        o += 2;

        // Flush pending paint, then write OSC 52 as one syscall (no mid-sequence ttcheck).
        _ = ttflsh();
        if (termout) |to| {
            _ = joe_write(fileno(to), msg, @intCast(o));
        }
    }
}
pub fn fake_key(arg_c: c_int) callconv(.c) void {
    var c = arg_c;
    _ = &c;
    var m: [*c]MACRO = dokey(maint.*.curwin.*.kbd, c);
    _ = &m;
    var x: ptrdiff_t = maint.*.curwin.*.kbd.*.x;
    _ = &x;
    maint.*.curwin.*.main.*.kbd.*.x = x;
    if (x != 0) {
        maint.*.curwin.*.main.*.kbd.*.seq[@bitCast(@as(isize, @intCast(x - @as(ptrdiff_t, 1))))] = maint.*.curwin.*.kbd.*.seq[@bitCast(@as(isize, @intCast(x - @as(ptrdiff_t, 1))))];
    }
    if (m != null) {
        _ = exemac(m, c);
    }
}
pub fn ttputs64(arg_pp: [*c]u8, arg_length: ptrdiff_t) callconv(.c) void {
    var pp = arg_pp;
    _ = &pp;
    var length = arg_length;
    _ = &length;
    var p_1: [*c]u8 = @ptrCast(@alignCast(pp));
    _ = &p_1;
    var buf: [65]u8 = undefined;
    _ = &buf;
    var x: ptrdiff_t = 0;
    _ = &x;
    while ((blk: {
        const ref = &length;
        const tmp = ref.*;
        ref.* -= 1;
        break :blk tmp;
    }) != 0) {
        while (true) {
            switch (base64_count) {
                @as(c_int, 0) => {
                    buf[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &x;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = base64_code[@bitCast(@as(isize, @intCast(@as(c_int, p_1.*) >> @intCast(@as(c_int, 2)))))];
                    base64_accu = @as(c_int, p_1.*) & @as(c_int, 3);
                    base64_count = 2;
                    p_1 += 1;
                    break;
                },
                @as(c_int, 2) => {
                    buf[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &x;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = base64_code[@bitCast(@as(isize, @intCast((base64_accu << @intCast(@as(c_int, 4))) + (@as(c_int, p_1.*) >> @intCast(@as(c_int, 4))))))];
                    base64_accu = @as(c_int, p_1.*) & @as(c_int, 15);
                    base64_count = 4;
                    p_1 += 1;
                    break;
                },
                @as(c_int, 4) => {
                    buf[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &x;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = base64_code[@bitCast(@as(isize, @intCast((base64_accu << @intCast(@as(c_int, 2))) + (@as(c_int, p_1.*) >> @intCast(@as(c_int, 6))))))];
                    buf[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &x;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = base64_code[@bitCast(@as(isize, @intCast(@as(c_int, p_1.*) & @as(c_int, 63))))];
                    base64_accu = 0;
                    base64_count = 0;
                    p_1 += 1;
                    break;
                },
                else => {},
            }
            break;
        }
        if (x >= @as(ptrdiff_t, 63)) {
            base64_pad += x;
            buf[@bitCast(@as(isize, @intCast(x)))] = 0;
            ttputs(@ptrCast(@alignCast(&buf)));
            x = 0;
        }
    }
    if (x != @as(ptrdiff_t, 0)) {
        base64_pad += x;
        buf[@bitCast(@as(isize, @intCast(x)))] = 0;
        ttputs(@ptrCast(@alignCast(&buf)));
    }
}
pub fn ttputs64_flush() callconv(.c) void {
    // Emit the final incomplete sextet (if any), then pad so total length % 4 == 0.
    // The leftover char must count toward base64_pad — otherwise we emit excess '='
    // (Ghostty rejects that as invalid OSC 52 base64 and leaves the clipboard unchanged).
    switch (base64_count) {
        2 => {
            ttputc(base64_code[@bitCast(@as(isize, @intCast(base64_accu << @intCast(@as(c_int, 4)))))]);
            base64_pad += 1;
        },
        4 => {
            ttputc(base64_code[@bitCast(@as(isize, @intCast(base64_accu << @intCast(@as(c_int, 2)))))]);
            base64_pad += 1;
        },
        else => {},
    }
    if ((base64_pad & @as(ptrdiff_t, 3)) != 0) {
        var z: ptrdiff_t = @as(ptrdiff_t, 4) - (base64_pad & @as(ptrdiff_t, 3));
        while (z > 0) : (z -= 1) {
            ttputc('=');
        }
    }
    base64_count = 0;
    base64_accu = 0;
    base64_pad = 0;
}
pub export var auto_scroll: c_int = 0;
pub export var auto_rate: ptrdiff_t = 0;
pub export var auto_trig_time: c_long = 0;
pub export var rtbutton: c_int = 0;
pub export var floatmouse: c_int = 0;
pub export var joexterm: c_int = 0;
/// When set (or with `-joexterm`), mouse selection end pushes OSC 52 clipboard.
pub export var mouseclip: c_int = 1; // default on: copy selection to clipboard (OSC 52)
/// Lines to move the caret per wheel notch (same as N × up/down arrow).
pub export var mousewheel: c_int = 1;
pub var selecting: c_int = 0;
pub var Cb: c_int = 0;
pub var Cx: ptrdiff_t = 0;
pub var Cy: ptrdiff_t = 0;
pub var last_msec: c_long = 0;
pub var clicks: c_int = 0;
pub fn mcoord(arg_x: ptrdiff_t) callconv(.c) ptrdiff_t {
    var x = arg_x;
    _ = &x;
    if ((x >= @as(ptrdiff_t, 33)) and (x <= @as(ptrdiff_t, 240))) return (x - @as(ptrdiff_t, 33)) + @as(ptrdiff_t, 1) else if (x == @as(ptrdiff_t, 32)) return -@as(c_int, 1) + @as(c_int, 1) else if (x > @as(ptrdiff_t, 240)) return (x - @as(ptrdiff_t, 257)) + @as(ptrdiff_t, 1) else return 0;
}
var wheel_v_last_ms: c_long = 0;
var wheel_h_last_ms: c_long = 0;

/// Window under the pointer, or `fallback`. Prompt windows scroll their text.
fn wheel_target(fallback: [*c]W) [*c]W {
    var w = fallback;
    if (Cx > 0 and Cy > 0) {
        const at = watpos(maint, Cx - 1, Cy - 1);
        if (at != null) w = at;
    }
    if (w != null and w.*.watom != null and w.*.watom.*.what == TYPEPW) {
        if (w.*.main != null) w = w.*.main;
    }
    return w;
}

/// One caret step per accepted tick (`mousewheel`, default 1). Ghostty often
/// emits a second tick ~4ms later; drop ticks closer than 16ms so a notch is
/// one step and a flick is a stream of single-cell moves, not jumps.
fn wheel_lines(last: *c_long) c_int {
    var n = mousewheel;
    if (n < 1) n = 1;
    if (n > 32) n = 32;
    const now = mnow();
    if (last.* != 0 and (now - last.*) < 16) return 0;
    last.* = now;
    return n;
}

fn wheel_apply(w: [*c]W, down: bool) void {
    const n = wheel_lines(&wheel_v_last_ms);
    if (n <= 0) return;
    const target = wheel_target(w);
    const what: c_int = if (target != null and target.*.watom != null) target.*.watom.*.what else 0;
    if ((what & TYPEMENU) != 0) {
        const old = maint.*.curwin;
        maint.*.curwin = target;
        var i = n;
        const key: c_int = if (down) KEY_MWDOWN else KEY_MWUP;
        while (i > 0) : (i -= 1) fake_key(key);
        maint.*.curwin = old;
        return;
    }
    if ((what & (TYPETW | TYPEPW)) != 0) {
        const delta: ptrdiff_t = if (down) n else -n;
        _ = uvscroll(target, delta);
        return;
    }
    var i = n;
    const key: c_int = if (down) KEY_MWDOWN else KEY_MWUP;
    while (i > 0) : (i -= 1) fake_key(key);
}

fn wheel_apply_h(w: [*c]W, right: bool) void {
    const n = wheel_lines(&wheel_h_last_ms);
    if (n <= 0) return;
    const target = wheel_target(w);
    const what: c_int = if (target != null and target.*.watom != null) target.*.watom.*.what else 0;
    if ((what & (TYPETW | TYPEPW)) != 0) {
        const delta: ptrdiff_t = if (right) n else -n;
        _ = uhscroll(target, delta);
        return;
    }
}

pub fn mouse_event(arg_w: [*c]W) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    if ((Cb & Cb_BUTTON_MASK) == Cb_WHEEL_UP) {
        wheel_apply(w, false);
        return 0;
    }
    if ((Cb & Cb_BUTTON_MASK) == Cb_WHEEL_DOWN) {
        wheel_apply(w, true);
        return 0;
    }
    if ((Cb & Cb_BUTTON_MASK) == Cb_WHEEL_LEFT) {
        wheel_apply_h(w, false);
        return 0;
    }
    if ((Cb & Cb_BUTTON_MASK) == Cb_WHEEL_RIGHT) {
        wheel_apply_h(w, true);
        return 0;
    }
    // Select button: left (or right if -rtbutton). Paste button: middle, and the
    // other side button (right by default) so right-click pastes the clipboard /
    // JOE selection.
    const select_btn: c_int = if (rtbutton != 0) Cb_BUTTON_RIGHT else Cb_BUTTON_LEFT;
    const paste_btn: c_int = if (rtbutton != 0) Cb_BUTTON_LEFT else Cb_BUTTON_RIGHT;
    if ((Cb & Cb_RELEASE) == Cb_RELEASE) {
        mouseup(Cx, Cy);
    } else if ((Cb & Cb_BUTTON_MASK) == select_btn) {
        if (!((Cb & Cb_DRAG) == Cb_DRAG)) {
            mousedn(Cx, Cy, 0);
        } else {
            mousedrag(Cx, Cy);
        }
    } else if ((((Cb & Cb_BUTTON_MASK) == Cb_BUTTON_MIDDLE) or ((Cb & Cb_BUTTON_MASK) == paste_btn)) and !((Cb & Cb_DRAG) == Cb_DRAG)) {
        mousedn(Cx, Cy, 1);
    }
    return 0;
}
pub export fn uxtmouse(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    Cb = @as(c_int, @as(u8, @bitCast(@as(i8, @truncate(ttgetc()))))) - @as(c_int, 32);
    if (Cb < @as(c_int, 0)) return -@as(c_int, 1);
    if (Cb == @as(c_int, 3)) {
        Cb = Cb_RELEASE;
    }
    Cx = @as(u8, @bitCast(@as(i8, @truncate(ttgetc()))));
    if (Cx < @as(ptrdiff_t, 32)) return -@as(c_int, 1);
    Cy = @as(u8, @bitCast(@as(i8, @truncate(ttgetc()))));
    if (Cy < @as(ptrdiff_t, 32)) return -@as(c_int, 1);
    Cx = mcoord(Cx);
    Cy = mcoord(Cy);
    return mouse_event(w);
}
pub export fn uextmouse(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var c: c_int = undefined;
    _ = &c;
    Cb = 0;
    Cx = blk: {
        const tmp = @as(ptrdiff_t, 0);
        Cy = tmp;
        break :blk tmp;
    };
    while ((blk: {
        const tmp = ttgetch();
        c = tmp;
        break :blk tmp;
    }) != @as(c_int, ';')) {
        if ((c < @as(c_int, '0')) or (c > @as(c_int, '9'))) return -@as(c_int, 1);
        Cb = ((@as(c_int, 10) * Cb) + c) - @as(c_int, '0');
    }
    while ((blk: {
        const tmp = ttgetch();
        c = tmp;
        break :blk tmp;
    }) != @as(c_int, ';')) {
        if ((c < @as(c_int, '0')) or (c > @as(c_int, '9'))) return -@as(c_int, 1);
        Cx = ((@as(ptrdiff_t, 10) * Cx) + @as(ptrdiff_t, c)) - @as(ptrdiff_t, '0');
    }
    while (((blk: {
        const tmp = ttgetch();
        c = tmp;
        break :blk tmp;
    }) != @as(c_int, 'M')) and (c != @as(c_int, 'm'))) {
        if ((c < @as(c_int, '0')) or (c > @as(c_int, '9'))) return -@as(c_int, 1);
        Cy = ((@as(ptrdiff_t, 10) * Cy) + @as(ptrdiff_t, c)) - @as(ptrdiff_t, '0');
    }
    if (c == @as(c_int, 'm')) {
        Cb |= Cb_RELEASE;
    }
    return mouse_event(w);
}
pub export fn udefmiddledown(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (utomouse(w, 0) != 0) return -@as(c_int, 1);
    w = maint.*.curwin;
    if (!((w.*.watom.*.what == TYPETW) or (w.*.watom.*.what == TYPEPW))) return -@as(c_int, 1);
    // Paste JOE highlighted block first (k=-2 keeps marks / selection highlight).
    if (markv(1) != 0) {
        return ublkcpy(w, -@as(c_int, 2));
    }
    // No JOE block: request terminal clipboard (OSC 52) when copy-on-select or joexterm.
    if ((mouseclip != 0) or (joexterm != 0)) {
        ttputs("\x1b]52;;?\x1b\\");
        return 0;
    }
    return ublkcpy(w, -@as(c_int, 2));
}
pub export fn udefmiddleup(arg_xx: [*c]W, arg_k: c_int) c_int {
    var xx = arg_xx;
    _ = &xx;
    var k = arg_k;
    _ = &k;
    return 0;
}
pub const base64_code: [64:0]u8 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".*;
pub export var base64_accu: c_int = 0;
pub export var base64_count: c_int = 0;
pub export var base64_pad: ptrdiff_t = 0;
pub export var drag_size: ptrdiff_t = 0;
pub var tmspos: off_t = 0;
pub var anchor: off_t = 0;
pub var anchorn: off_t = 0;
pub var marked: c_int = 0;
pub var reversed: c_int = 0;
pub export fn udefmdown(arg_xx: [*c]W, arg_k: c_int) c_int {
    var xx = arg_xx;
    _ = &xx;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    if (utomouse(xx, 0) != 0) return -@as(c_int, 1);
    if ((maint.*.curwin.*.watom.*.what & (TYPEPW | TYPETW)) == @as(c_int, 0)) return 0;
    bw_1 = @ptrCast(@alignCast(maint.*.curwin.*.object));
    anchor = bw_1.*.cursor.*.byte;
    marked = blk: {
        const tmp = @as(c_int, 0);
        reversed = tmp;
        break :blk tmp;
    };
    return 0;
}
pub export fn udefmdrag(arg_xx: [*c]W, arg_k: c_int) c_int {
    var xx = arg_xx;
    _ = &xx;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = @ptrCast(@alignCast(maint.*.curwin.*.object));
    _ = &bw_1;
    var ay: ptrdiff_t = Cy - @as(ptrdiff_t, 1);
    _ = &ay;
    var new_scroll: c_int = undefined;
    _ = &new_scroll;
    var new_rate: ptrdiff_t = undefined;
    _ = &new_rate;
    if (drag_size != 0) {
        while (ay > bw_1.*.parent.*.y) {
            var y: ptrdiff_t = bw_1.*.parent.*.y;
            _ = &y;
            _ = wgrowdown(bw_1.*.parent);
            if (y == bw_1.*.parent.*.y) return -@as(c_int, 1);
        }
        while (ay < bw_1.*.parent.*.y) {
            var y: ptrdiff_t = bw_1.*.parent.*.y;
            _ = &y;
            _ = wgrowup(bw_1.*.parent);
            if (y == bw_1.*.parent.*.y) return -@as(c_int, 1);
        }
        return 0;
    }
    if (ay < bw_1.*.y) {
        new_scroll = -@as(c_int, 1);
        new_rate = bw_1.*.y - ay;
    } else if (ay >= (bw_1.*.y + bw_1.*.h)) {
        new_scroll = 1;
        new_rate = (ay - (bw_1.*.y + bw_1.*.h)) + @as(ptrdiff_t, 1);
    } else {
        new_scroll = 0;
        new_rate = 1;
    }
    if (new_rate > @as(ptrdiff_t, 10)) {
        new_rate = 10;
    }
    if (!(new_scroll != 0)) {
        auto_scroll = 0;
    } else if (new_scroll != auto_scroll) {
        auto_scroll = new_scroll;
        auto_rate = new_rate;
        reset_trig_time();
    } else if (new_rate != auto_rate) {
        auto_rate = new_rate;
    }
    if (!(marked != 0)) {
        marked += 1;
        _ = umarkb(bw_1.*.parent, 0);
    }
    if (tomousestay() != 0) return -@as(c_int, 1);
    selecting = 1;
    if (reversed != 0) {
        _ = umarkb(bw_1.*.parent, 0);
    } else {
        _ = umarkk(bw_1.*.parent, 0);
    }
    if ((!(reversed != 0) and (bw_1.*.cursor.*.byte < anchor)) or ((reversed != 0) and (bw_1.*.cursor.*.byte > anchor))) {
        var q: [*c]P = pdup(markb, "udefmdrag");
        _ = &q;
        var tmp: off_t = markb.*.xcol;
        _ = &tmp;
        pset(markb, markk);
        pset(markk, q);
        markb.*.xcol = markk.*.xcol;
        markk.*.xcol = tmp;
        prm(q);
        reversed = @intFromBool(!(reversed != 0));
    }
    bw_1.*.cursor.*.xcol = tmspos;
    return 0;
}
pub export fn udefmup(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    auto_scroll = 0;
    if (selecting != 0) {
        select_done(@as([*c]BW, @ptrCast(@alignCast(maint.*.curwin.*.object))).*.b.*.o.charmap);
        selecting = 0;
    }
    return 0;
}
pub export fn udefm2down(arg_xx: [*c]W, arg_k: c_int) c_int {
    var xx = arg_xx;
    _ = &xx;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    if (utomouse(xx, k) != 0) return -@as(c_int, 1);
    if ((maint.*.curwin.*.watom.*.what & TYPEMENU) != 0) {
        return maint.*.curwin.*.watom.*.rtn.?(maint.*.curwin);
    }
    if ((maint.*.curwin.*.watom.*.what & (TYPEPW | TYPETW)) == @as(c_int, 0)) return 0;
    bw_1 = @ptrCast(@alignCast(maint.*.curwin.*.object));
    _ = u_goto_prev(bw_1.*.parent, 0);
    anchor = bw_1.*.cursor.*.byte;
    _ = umarkb(bw_1.*.parent, 0);
    markb.*.xcol = piscol(markb);
    _ = u_goto_next(bw_1.*.parent, 0);
    anchorn = bw_1.*.cursor.*.byte;
    _ = umarkk(bw_1.*.parent, 0);
    markk.*.xcol = piscol(markk);
    reversed = 0;
    bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
    selecting = 1;
    return 0;
}
pub export fn udefm2drag(arg_xx: [*c]W, arg_k: c_int) c_int {
    var xx = arg_xx;
    _ = &xx;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = @ptrCast(@alignCast(maint.*.curwin.*.object));
    _ = &bw_1;
    if (tomousestay() != 0) return -@as(c_int, 1);
    if (!(reversed != 0) and (bw_1.*.cursor.*.byte < anchor)) {
        _ = pgoto(markk, anchorn);
        markk.*.xcol = piscol(markk);
        reversed = 1;
    } else if ((reversed != 0) and (bw_1.*.cursor.*.byte > anchorn)) {
        _ = pgoto(markb, anchor);
        markb.*.xcol = piscol(markb);
        reversed = 0;
    }
    bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
    if (reversed != 0) {
        if (!(pisbol(bw_1.*.cursor) != 0)) {
            _ = u_goto_prev(bw_1.*.parent, 0);
            bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
        }
        _ = umarkb(bw_1.*.parent, 0);
    } else {
        if (!(piseol(bw_1.*.cursor) != 0)) {
            _ = u_goto_next(bw_1.*.parent, 0);
            bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
        }
        _ = umarkk(bw_1.*.parent, 0);
    }
    return 0;
}
pub export fn udefm2up(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    auto_scroll = 0;
    if (selecting != 0) {
        select_done(@as([*c]BW, @ptrCast(@alignCast(maint.*.curwin.*.object))).*.b.*.o.charmap);
        selecting = 0;
    }
    return 0;
}
pub export fn udefm3down(arg_xx: [*c]W, arg_k: c_int) c_int {
    var xx = arg_xx;
    _ = &xx;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    if (utomouse(xx, k) != 0) return -@as(c_int, 1);
    if ((maint.*.curwin.*.watom.*.what & (TYPEPW | TYPETW)) == @as(c_int, 0)) return 0;
    bw_1 = @ptrCast(@alignCast(maint.*.curwin.*.object));
    p_goto_bol(bw_1.*.cursor);
    bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
    anchor = bw_1.*.cursor.*.byte;
    _ = umarkb(bw_1.*.parent, 0);
    _ = umarkk(bw_1.*.parent, 0);
    _ = pnextl(markk);
    anchorn = markk.*.byte;
    reversed = 0;
    bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
    selecting = 1;
    return 0;
}
pub export fn udefm3drag(arg_xx: [*c]W, arg_k: c_int) c_int {
    var xx = arg_xx;
    _ = &xx;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = @ptrCast(@alignCast(maint.*.curwin.*.object));
    _ = &bw_1;
    if (tomousestay() != 0) return -@as(c_int, 1);
    if (!(reversed != 0) and (bw_1.*.cursor.*.byte < anchor)) {
        _ = pgoto(markk, anchorn);
        markk.*.xcol = piscol(markk);
        reversed = 1;
    } else if ((reversed != 0) and (bw_1.*.cursor.*.byte > anchorn)) {
        _ = pgoto(markb, anchor);
        markb.*.xcol = piscol(markb);
        reversed = 0;
    }
    p_goto_bol(bw_1.*.cursor);
    bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
    if (reversed != 0) {
        _ = umarkb(bw_1.*.parent, 0);
        markb.*.xcol = piscol(markb);
    } else {
        _ = umarkk(bw_1.*.parent, 0);
        _ = pnextl(markk);
        markk.*.xcol = piscol(markk);
    }
    return 0;
}
pub export fn udefm3up(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    auto_scroll = 0;
    if (selecting != 0) {
        select_done(@as([*c]BW, @ptrCast(@alignCast(maint.*.curwin.*.object))).*.b.*.o.charmap);
        selecting = 0;
    }
    return 0;
}
pub export fn mouseopen() void {
    if (comptime build_options.gpm) {
        _ = gpm.gpmopen();
    }
    if (usexmouse != 0) {
        // Button-event + SGR only (1002 includes press/release; do not also
        // enable 1000 — duplicate reports confuse multi-click detection).
        ttputs("\x1b[?1002h");
        ttputs("\x1b[?1006h");
        if (joexterm != 0) {
            ttputs("\x1b[?2007h");
        }
        _ = ttflsh();
    }
}
pub export fn mouseclose() void {
    if (usexmouse != 0) {
        if (joexterm != 0) {
            ttputs("\x1b[?2007l");
        }
        ttputs("\x1b[?1006l");
        ttputs("\x1b[?1002l");
        _ = ttflsh();
    }
    if (comptime build_options.gpm) {
        gpm.gpmclose();
    }
}
