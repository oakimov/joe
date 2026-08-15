//! Text windows — replaces `joe/tw.c`.
//!
//! Faithful C-ABI port of JOE text-window + status-line logic. Generated from a goto-free rewrite of tw.c via `zig translate-c`, then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;

pub const FITHEIGHT: c_int = 4;
pub const SAVED_SIZE: c_int = 80;
pub const stdsiz: c_int = 8192;
pub const TYPETW: c_int = 0x0100;
pub const TYPEPW: c_int = 0x0200;
pub const TYPEMENU: c_int = 0x0800;
pub const TYPEQW: c_int = 0x1000;
pub const YES_CODE: c_int = -10;
pub const VERSION: [*c]const u8 = "4.8";

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub extern fn strspn(s: [*c]const u8, accept: [*c]const u8) c_ulong;
pub const off_t = i64;
pub const time_t = i64;
pub const FILE = anyopaque;
const struct_unnamed_1 = extern struct {
    next: [*c]P = null,
    prev: [*c]P = null,
};
pub const B = struct_b;
pub const struct_p = extern struct {
    link: struct_unnamed_1 = std.mem.zeroes(struct_unnamed_1),
    b: [*c]B = null,
    _pad0: [24]u8 = std.mem.zeroes([24]u8),
    byte: off_t = 0,
    line: off_t = 0,
    col: off_t = 0,
    xcol: off_t = 0,
    valcol: c_int = 0,
    end: c_int = 0,
    _pad1: [24]u8 = std.mem.zeroes([24]u8),
};
pub const P = struct_p;
pub const struct_high_syntax = extern struct {
    next: ?*anyopaque = null,
    name: [*c]const u8 = null,
    _pad: [120]u8 = std.mem.zeroes([120]u8),
};
pub const struct_charmap = extern struct {
    next: ?*anyopaque = null,
    name: [*c]const u8 = null,
    type: c_int = 0,
    _pad: [2732]u8 = std.mem.zeroes([2732]u8),
};
pub const struct_macro = opaque {};
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
    syntax: [*c]struct_high_syntax = null,
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
    mnew: ?*MACRO = null,
    mold: ?*MACRO = null,
    msnew: ?*MACRO = null,
    msold: ?*MACRO = null,
    mfirst: ?*MACRO = null,
};
pub const OPTIONS = struct_options;
pub const pid_t = c_int;
pub const struct_b = extern struct {
    _pad0: [24]u8 = std.mem.zeroes([24]u8),
    eof: [*c]P = null,
    name: [*c]u8 = null,
    _pad1: [40]u8 = std.mem.zeroes([40]u8),
    count: c_int = 0,
    changed: c_int = 0,
    _pad2: [104]u8 = std.mem.zeroes([104]u8),
    o: OPTIONS = std.mem.zeroes(OPTIONS),
    oldcur: [*c]P = null,
    oldtop: [*c]P = null,
    err: [*c]P = null,
    _pad3: [12]u8 = std.mem.zeroes([12]u8),
    rdonly: c_int = 0,
    internal: c_int = 0,
    scratch: c_int = 0,
    er: c_int = 0,
    pid: pid_t = 0,
    out: c_int = 0,
    _pad5: [4]u8 = std.mem.zeroes([4]u8),
    vt: ?*anyopaque = null,
    _pad6: [24]u8 = std.mem.zeroes([24]u8),
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
pub const struct_bstack = extern struct {
    next: [*c]struct_bstack = null,
    b: [*c]B = null,
    cursor: [*c]P = null,
    top: [*c]P = null,
};
pub const W = struct_window;
const struct_unnamed_2 = extern struct {
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
    link: struct_unnamed_2 = std.mem.zeroes(struct_unnamed_2),
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
pub const struct_lattr_db = opaque {
};
const struct_unnamed_3 = extern struct {
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
    saved: struct_unnamed_3 = std.mem.zeroes(struct_unnamed_3),
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
pub const struct_qw = opaque {};
pub const QW = struct_qw;
pub const struct_highlight_state = extern struct {
    stack: ?*anyopaque = null,
    delim_stack: ?*anyopaque = null,
    saved_s: [*c]const c_int = null,
    state: c_int = 0,
    _pad: [4]u8 = std.mem.zeroes([4]u8),
};
pub const HIGHLIGHT_STATE = struct_highlight_state;
pub const struct_recmac = extern struct {
    next: [*c]struct_recmac = null,
    n: c_int = 0,
    _pad: [12]u8 = std.mem.zeroes([12]u8),
};
pub const struct_tm = extern struct {
    tm_sec: c_int = 0,
    tm_min: c_int = 0,
    tm_hour: c_int = 0,
    tm_mday: c_int = 0,
    tm_mon: c_int = 0,
    tm_year: c_int = 0,
    tm_wday: c_int = 0,
    tm_yday: c_int = 0,
    tm_isdst: c_int = 0,
    _pad: [20]u8 = std.mem.zeroes([20]u8),
};
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn vsmk(len: ptrdiff_t) [*c]u8;
pub extern fn vsadd(s: [*c]u8, c: c_int) [*c]u8;
pub extern fn vstrunc(s: [*c]u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsncpy(s: [*c]u8, len: ptrdiff_t, blk: [*c]const u8, blklen: ptrdiff_t) [*c]u8;
pub extern fn vsfill(s: [*c]u8, len: ptrdiff_t, c: c_int, amnt: ptrdiff_t) [*c]u8;
pub extern fn vsrm(s: [*c]u8) void;
pub extern fn nscrldn(t: [*c]SCRN, top: ptrdiff_t, bot: ptrdiff_t, amnt: ptrdiff_t) void;
pub extern fn nscrlup(t: [*c]SCRN, top: ptrdiff_t, bot: ptrdiff_t, amnt: ptrdiff_t) void;
pub extern fn fmtlen(s: [*c]const u8) ptrdiff_t;
pub extern fn fmtpos(s: [*c]const u8, goal: ptrdiff_t) ptrdiff_t;
pub extern fn genfmt(t: [*c]SCRN, x: ptrdiff_t, y: ptrdiff_t, ofst: ptrdiff_t, s: [*c]const u8, flg: c_int, trunc: c_int, atr: c_int) void;
pub extern fn wcreate(t: [*c]Screen, watom: [*c]const WATOM, where: [*c]W, target: [*c]W, after: [*c]W, lines: ptrdiff_t, huh: [*c]const u8, notify: [*c]c_int) [*c]W;
pub extern fn wabort(w: [*c]W) c_int;
pub extern fn wfit(t: [*c]Screen) void;
pub extern fn wnext(t: [*c]Screen) void;
pub extern fn wredraw(w: [*c]W) void;
pub extern fn updall() void;
pub extern fn getgrouph(w: [*c]W) ptrdiff_t;
pub extern fn findbotw(w: [*c]W) [*c]W;
pub extern fn demotegroup(w: [*c]W) c_int;
pub extern fn countmain(t: [*c]Screen) c_int;
pub extern fn bwmk(window: [*c]W, b: [*c]B, prompt: c_int) [*c]BW;
pub extern fn bwmove(w: [*c]BW, x: ptrdiff_t, y: ptrdiff_t) void;
pub extern fn bwresz(w: [*c]BW, wi: ptrdiff_t, he: ptrdiff_t) void;
pub extern fn bwrm(w: [*c]BW) void;
pub extern fn bwins(w: [*c]BW, l: off_t, n: off_t, flg: c_int) void;
pub extern fn bwdel(w: [*c]BW, l: off_t, n: off_t, flg: c_int) void;
pub extern fn bwgen(w: [*c]BW, linums: c_int, linchg: c_int) void;
pub extern fn bwgenh(w: [*c]BW) void;
pub extern fn bwfllw(w: [*c]W) void;
pub extern fn orphit(bw: [*c]BW) void;
pub extern fn calclincols(bw: [*c]BW) c_int;
pub extern fn get_buffer_in_window(bw: [*c]BW, b: [*c]B) c_int;
pub extern fn pdup(p: [*c]P, where: [*c]const u8) [*c]P;
pub extern fn prm(p: [*c]P) void;
pub extern fn pset(d: [*c]P, s: [*c]P) void;
pub extern fn p_goto_bol(p: [*c]P) void;
pub extern fn pline(p: [*c]P, line: off_t) c_int;
pub extern fn piscol(p: [*c]P) off_t;
pub extern fn piseof(p: [*c]P) c_int;
pub extern fn brch(p: [*c]P) c_int;
pub extern fn borphan() [*c]B;
pub extern fn load_syntax(name: [*c]const u8) [*c]struct_high_syntax;
pub extern fn find_lattr_db(b: [*c]B, y: [*c]struct_high_syntax) ?*struct_lattr_db;
pub extern fn lattr_get(db: ?*struct_lattr_db, y: [*c]struct_high_syntax, p: [*c]P, line: ptrdiff_t) HIGHLIGHT_STATE;
pub extern fn parse(syntax: [*c]struct_high_syntax, line: [*c]P, state: HIGHLIGHT_STATE, charmap: [*c]struct_charmap) HIGHLIGHT_STATE;
pub extern fn my_iconv1(dest: [*c]u8, destsiz: ptrdiff_t, dest_map: [*c]struct_charmap, s: [*c]const u8) void;
pub extern fn simplify_prefix(path: [*c]const u8) [*c]u8;
pub extern fn get_status(bw: [*c]BW, s: [*c]u8) [*c]const u8;
pub extern fn markv(r: c_int) c_int;
pub extern fn genexmsg(bw: [*c]BW, saved: c_int, name: [*c]u8) void;
pub extern fn okrepl(bw: [*c]BW) c_int;
pub extern fn yncheck(string: [*c]const u8, c: c_int) c_int;
pub extern fn joe_wcwidth(wide: c_int, c: c_int) c_int;
pub extern fn ukillpid(w: [*c]W, k: c_int) c_int;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn mkqw(w: [*c]W, prompt: [*c]const u8, len: ptrdiff_t, func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int) ?*QW;
pub extern fn time(t: [*c]time_t) time_t;
pub extern fn localtime(t: [*c]const time_t) [*c]struct_tm;
pub extern fn ctime(t: [*c]const time_t) [*c]u8;
pub extern var skiptop: c_int;
pub extern var dostaupd: c_int;
pub extern var leave: c_int;
pub extern var maint: [*c]Screen;
pub extern var errbuf: [*c]B;
pub extern var stdbuf: [8192]u8;
pub extern var locale_map: [*c]struct_charmap;
pub extern var recmac: [*c]struct_recmac;
pub extern var markb: [*c]P;
pub extern var markk: [*c]P;
pub extern var exmsg: [*c]u8;
pub extern var have: c_int;
pub extern var square: c_int;
pub extern var yes_key: [*c]const u8;
pub extern fn rtntw(w: [*c]W) c_int;
pub extern fn utypew(w: [*c]W, k: c_int) c_int;
pub extern fn msetI(dest: [*c]c_int, c: c_int, sz: ptrdiff_t) [*c]c_int;
pub fn movetw(arg_w: [*c]W, arg_x: ptrdiff_t, arg_y: ptrdiff_t) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    var bw_1: [*c]BW = @ptrCast(@alignCast(w.*.object));
    _ = &bw_1;
    var tw_2: [*c]TW = @ptrCast(@alignCast(bw_1.*.object));
    _ = &tw_2;
    if (((y != 0) or (@as(ptrdiff_t, @intFromBool(!(staen != 0))) != 0)) and (w.*.h > @as(ptrdiff_t, 1))) {
        if (!(tw_2.*.staon != 0)) {
            nscrldn(bw_1.*.parent.*.t.*.t, y, bw_1.*.parent.*.nh + y, 1);
        }
        bwmove(bw_1, x + @as(ptrdiff_t, bw_1.*.lincols), y + @as(ptrdiff_t, 1));
        tw_2.*.staon = 1;
    } else {
        if (tw_2.*.staon != 0) {
            nscrlup(bw_1.*.parent.*.t.*.t, y, bw_1.*.parent.*.nh + y, 1);
        }
        bwmove(bw_1, x + @as(ptrdiff_t, bw_1.*.lincols), y);
        tw_2.*.staon = 0;
    }
}
pub fn resizetw(arg_w: [*c]W, arg_wi: ptrdiff_t, arg_he: ptrdiff_t) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var wi = arg_wi;
    _ = &wi;
    var he = arg_he;
    _ = &he;
    var bw_1: [*c]BW = @ptrCast(@alignCast(w.*.object));
    _ = &bw_1;
    if (((bw_1.*.parent.*.ny != 0) or (@as(ptrdiff_t, @intFromBool(!(staen != 0))) != 0)) and (he > @as(ptrdiff_t, 1))) {
        bwresz(bw_1, wi - @as(ptrdiff_t, bw_1.*.lincols), he - @as(ptrdiff_t, 1));
    } else {
        bwresz(bw_1, wi - @as(ptrdiff_t, bw_1.*.lincols), he);
    }
}
pub fn disptw(arg_w: [*c]W, arg_flg: c_int) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var flg = arg_flg;
    _ = &flg;
    var bw_1: [*c]BW = @ptrCast(@alignCast(w.*.object));
    _ = &bw_1;
    var tw_2: [*c]TW = @ptrCast(@alignCast(bw_1.*.object));
    _ = &tw_2;
    var newcols: c_int = calclincols(bw_1);
    _ = &newcols;
    var linchg: c_int = 0;
    _ = &linchg;
    if ((bw_1.*.lincols != newcols) and !(have != 0)) {
        bw_1.*.lincols = newcols;
        resizetw(w, w.*.w, w.*.h);
        movetw(w, w.*.x, w.*.y);
        bwfllw(w);
        linchg = 1;
    }
    if (bw_1.*.o.hex != 0) {
        w.*.cury = @as(ptrdiff_t, @truncate((@divTrunc(bw_1.*.cursor.*.byte - bw_1.*.top.*.byte, @as(off_t, 16)) + @as(off_t, bw_1.*.y)) - @as(off_t, w.*.y)));
        w.*.curx = @as(ptrdiff_t, @truncate((@rem(bw_1.*.cursor.*.byte - bw_1.*.top.*.byte, @as(off_t, 16)) + @as(off_t, 60)) - bw_1.*.offset));
    } else {
        w.*.cury = @as(ptrdiff_t, @truncate(((bw_1.*.cursor.*.line - bw_1.*.top.*.line) + @as(off_t, bw_1.*.y)) - @as(off_t, w.*.y)));
        // Draw on a real column. `xcol` is the sticky goal for up/down; past
        // EOL it has no glyph, so sit at the end of the line (unless -picture).
        const cur_col: off_t = if (bw_1.*.o.picture != 0) bw_1.*.cursor.*.xcol else piscol(bw_1.*.cursor);
        w.*.curx = @as(ptrdiff_t, @truncate((cur_col - bw_1.*.offset) + @as(off_t, bw_1.*.lincols)));
    }
    if (((((((staupd != 0) or ((keepup != 0) and !(have != 0))) or (bw_1.*.cursor.*.line != tw_2.*.prevline)) or (bw_1.*.b.*.changed != tw_2.*.changed)) or (bw_1.*.b != tw_2.*.prev_b)) and ((w.*.y != 0) or (@as(ptrdiff_t, @intFromBool(!(staen != 0))) != 0))) and (w.*.h > @as(ptrdiff_t, 1))) {
        var fill: u8 = undefined;
        _ = &fill;
        tw_2.*.prevline = bw_1.*.cursor.*.line;
        tw_2.*.changed = bw_1.*.b.*.changed;
        tw_2.*.prev_b = bw_1.*.b;
        if (@as(c_int, bw_1.*.o.rmsg[@as(c_int, 0)]) != 0) {
            fill = bw_1.*.o.rmsg[@as(c_int, 0)];
        } else {
            fill = ' ';
        }
        tw_2.*.stalin = stagen(tw_2.*.stalin, bw_1, bw_1.*.o.lmsg, fill);
        tw_2.*.staright = stagen(tw_2.*.staright, bw_1, bw_1.*.o.rmsg, fill);
        if (fmtlen(tw_2.*.staright) < w.*.w) {
            var x: ptrdiff_t = fmtpos(tw_2.*.stalin, w.*.w - fmtlen(tw_2.*.staright));
            _ = &x;
            if (x > (if (tw_2.*.stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tw_2.*.stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0))) {
                tw_2.*.stalin = vsfill(tw_2.*.stalin, if (tw_2.*.stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tw_2.*.stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), fill, x - (if (tw_2.*.stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tw_2.*.stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)));
            }
            tw_2.*.stalin = vsncpy(tw_2.*.stalin, fmtpos(tw_2.*.stalin, w.*.w - fmtlen(tw_2.*.staright)), tw_2.*.staright, if (tw_2.*.staright != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tw_2.*.staright))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        }
        tw_2.*.stalin = vstrunc(tw_2.*.stalin, fmtpos(tw_2.*.stalin, w.*.w));
        genfmt(w.*.t.*.t, w.*.x, w.*.y, 0, tw_2.*.stalin, bg_stalin, 0, 0);
        w.*.t.*.t.*.updtab[@bitCast(@as(isize, @intCast(w.*.y)))] = 0;
    }
    if (flg != 0) {
        if (bw_1.*.o.hex != 0) {
            bwgenh(bw_1);
        } else {
            bwgen(bw_1, bw_1.*.o.linums, linchg);
        }
    }
}
pub fn iztw(arg_tw_1: [*c]TW, arg_y: ptrdiff_t) callconv(.c) void {
    var tw_1 = arg_tw_1;
    _ = &tw_1;
    var y = arg_y;
    _ = &y;
    tw_1.*.stalin = null;
    tw_1.*.staright = null;
    tw_1.*.changed = -@as(c_int, 1);
    tw_1.*.prevline = -@as(c_int, 1);
    tw_1.*.staon = @intFromBool((@as(ptrdiff_t, @intFromBool(!(staen != 0))) != 0) or (y != 0));
    tw_1.*.prev_b = null;
}
pub fn instw(arg_w: [*c]W, arg_b_1: [*c]B, arg_l: off_t, arg_n: off_t, arg_flg: c_int) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var b_1 = arg_b_1;
    _ = &b_1;
    var l = arg_l;
    _ = &l;
    var n = arg_n;
    _ = &n;
    var flg = arg_flg;
    _ = &flg;
    var bw_2: [*c]BW = @ptrCast(@alignCast(w.*.object));
    _ = &bw_2;
    if (b_1 == bw_2.*.b) {
        bwins(bw_2, l, n, flg);
    }
}
pub fn deltw(arg_w: [*c]W, arg_b_1: [*c]B, arg_l: off_t, arg_n: off_t, arg_flg: c_int) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var b_1 = arg_b_1;
    _ = &b_1;
    var l = arg_l;
    _ = &l;
    var n = arg_n;
    _ = &n;
    var flg = arg_flg;
    _ = &flg;
    var bw_2: [*c]BW = @ptrCast(@alignCast(w.*.object));
    _ = &bw_2;
    if (b_1 == bw_2.*.b) {
        bwdel(bw_2, l, n, flg);
    }
}
pub fn naborttw(arg_w: [*c]W, arg_k: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var bw_1: [*c]BW = @ptrCast(@alignCast(w.*.object));
    _ = &bw_1;
    if (notify != null) {
        notify.* = 1;
    }
    if ((k != -@as(c_int, 10)) and !(yncheck(yes_key, k) != 0)) return -@as(c_int, 1);
    if (bw_1.*.b.*.count == @as(c_int, 1)) {
        genexmsg(bw_1, 0, null);
    }
    return abortit(bw_1.*.parent, 0);
}
pub fn naborttw1(arg_w: [*c]W, arg_k: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var bw_1: [*c]BW = @ptrCast(@alignCast(w.*.object));
    _ = &bw_1;
    if (notify != null) {
        notify.* = 1;
    }
    if ((k != -@as(c_int, 10)) and !(yncheck(yes_key, k) != 0)) return -@as(c_int, 1);
    if (!(exmsg != null)) {
        genexmsg(bw_1, 0, null);
    }
    return abortit(bw_1.*.parent, 0);
}
pub fn wpop(arg_bw_1: [*c]BW) callconv(.c) [*c]B {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var b_2: [*c]B = undefined;
    _ = &b_2;
    var e: [*c]struct_bstack = bw_1.*.parent.*.bstack;
    _ = &e;
    b_2 = e.*.b;
    if (b_2.*.oldcur != null) {
        prm(b_2.*.oldcur);
    }
    if (b_2.*.oldtop != null) {
        prm(b_2.*.oldtop);
    }
    b_2.*.oldcur = e.*.cursor;
    b_2.*.oldtop = e.*.top;
    bw_1.*.parent.*.bstack = e.*.next;
    free(@ptrCast(@alignCast(e)));
    b_2.*.count -= 1;
    return b_2;
}
pub fn get_context(arg_bw_1: [*c]BW) callconv(.c) [*c]const c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    const static_local_buf1 = struct {
        var buf1: [160]c_int = std.mem.zeroes([160]c_int);
    };
    _ = &static_local_buf1;
    var src: [*c]const c_int = undefined;
    _ = &src;
    var p_2: [*c]P = undefined;
    _ = &p_2;
    var db: ?*struct_lattr_db = undefined;
    _ = &db;
    var st: HIGHLIGHT_STATE = undefined;
    _ = &st;
    (&st).*.saved_s = null;
    (&st).*.state = 0;
    (&st).*.stack = null;
    (&st).*.delim_stack = null;
    p_2 = pdup(bw_1.*.cursor, "get_context");
    p_goto_bol(p_2);
    if (!(context_syntax != null)) {
        context_syntax = load_syntax("context");
    }
    if (context_syntax != null) {
        db = find_lattr_db(bw_1.*.b, context_syntax);
        if (db != null) {
            st = lattr_get(db, context_syntax, p_2, @truncate(p_2.*.line + @as(off_t, 1)));
        }
    }
    prm(p_2);
    src = st.saved_s;
    static_local_buf1.buf1[@as(c_int, 0)] = 0;
    if (src != null) {
        var i: ptrdiff_t = undefined;
        _ = &i;
        var j: ptrdiff_t = undefined;
        _ = &j;
        var spc: ptrdiff_t = undefined;
        _ = &spc;
        i = 0;
        j = 0;
        spc = 0;
        while ((src[@bitCast(@as(isize, @intCast(i)))] != 0) and (i < @as(ptrdiff_t, SAVED_SIZE - @as(c_int, 1)))) : (i += 1) {
            if ((src[@bitCast(@as(isize, @intCast(i)))] == @as(c_int, '\t')) or (src[@bitCast(@as(isize, @intCast(i)))] == @as(c_int, ' '))) {
                if (spc != 0) continue;
                spc = 1;
            } else {
                spc = 0;
            }
            if (src[@bitCast(@as(isize, @intCast(i)))] == @as(c_int, '\t')) {
                static_local_buf1.buf1[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &j;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = ' ';
            } else if (src[@bitCast(@as(isize, @intCast(i)))] == @as(c_int, '\\')) {
                static_local_buf1.buf1[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &j;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = '\\';
                static_local_buf1.buf1[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &j;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = '\\';
            } else if (src[@bitCast(@as(isize, @intCast(i)))] != @as(c_int, '\r')) {
                static_local_buf1.buf1[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &j;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = src[@bitCast(@as(isize, @intCast(i)))];
            }
        }
        static_local_buf1.buf1[@bitCast(@as(isize, @intCast(j)))] = '\x00';
    }
    return @ptrCast(@alignCast(&static_local_buf1.buf1));
}
pub export var staen: c_int = 0;
pub export var staupd: c_int = 0;
pub export var keepup: c_int = 0;
pub export var bg_stalin: c_int = 0;
pub var context_syntax: [*c]struct_high_syntax = null;
pub export fn duplicate_backslashes(arg_s: [*c]const u8, arg_len: ptrdiff_t) [*c]u8 {
    var s = arg_s;
    _ = &s;
    var len = arg_len;
    _ = &len;
    var m: [*c]u8 = undefined;
    _ = &m;
    var x: ptrdiff_t = undefined;
    _ = &x;
    var count: ptrdiff_t = undefined;
    _ = &count;
    {
        x = blk: {
            const tmp = @as(ptrdiff_t, 0);
            count = tmp;
            break :blk tmp;
        };
        while (x != len) : (x += 1) if (@as(c_int, s[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, '\\')) {
            count += 1;
        };
    }
    m = vsmk(len + count);
    {
        x = 0;
        while (x != len) : (x += 1) {
            m = vsadd(m, s[@bitCast(@as(isize, @intCast(x)))]);
            if (@as(c_int, s[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, '\\')) {
                m = vsadd(m, '\\');
            }
        }
    }
    return m;
}
pub export fn stagen(arg_stalin: [*c]u8, arg_bw_1: [*c]BW, arg_s: [*c]const u8, arg_fill: u8) [*c]u8 {
    var stalin = arg_stalin;
    _ = &stalin;
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var s = arg_s;
    _ = &s;
    var fill = arg_fill;
    _ = &fill;
    var buf: [80]u8 = undefined;
    _ = &buf;
    var x: c_int = undefined;
    _ = &x;
    var field: c_int = undefined;
    _ = &field;
    var w: [*c]W = bw_1.*.parent;
    _ = &w;
    var n: time_t = time(null);
    _ = &n;
    var cas: [*c]struct_tm = undefined;
    _ = &cas;
    cas = localtime(&n);
    stalin = vstrunc(stalin, 0);
    while (@as(c_int, s.*) != 0) {
        if ((@as(c_int, s.*) == @as(c_int, '%')) and (@as(c_int, s[@as(c_int, 1)]) != 0)) {
            field = 0;
            s += 1;
            while (((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9'))) and (@as(c_int, s[@as(c_int, 1)]) != 0)) {
                field = ((field * @as(c_int, 10)) + @as(c_int, s.*)) - @as(c_int, '0');
                s += 1;
            }
            while (true) {
                switch (@as(c_int, s.*)) {
                    @as(c_int, 'v') => {
                        {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%s", @constCast("4.8"));
                            stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        }
                        break;
                    },
                    @as(c_int, 'x') => {
                        {
                            if (bw_1.*.o.title != 0) {
                                var ts: [*c]const c_int = get_context(bw_1);
                                _ = &ts;
                                if (ts != null) {
                                    my_iconv1(@ptrCast(@alignCast(&stdbuf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(stdbuf)))))), locale_map, @ptrCast(@alignCast(ts)));
                                    stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&stdbuf)), slen(@ptrCast(@alignCast(&stdbuf))));
                                }
                            }
                        }
                        break;
                    },
                    @as(c_int, 'y') => {
                        {
                            if (bw_1.*.o.syntax != null) {
                                _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "(%s)", bw_1.*.o.syntax.*.name);
                                stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                            }
                        }
                        break;
                    },
                    @as(c_int, 't') => {
                        {
                            var curtime: time_t = time(null);
                            _ = &curtime;
                            var l: c_int = undefined;
                            _ = &l;
                            var d: [*c]u8 = ctime(&curtime);
                            _ = &d;
                            l = (((@as(c_int, d[@as(c_int, 11)]) - @as(c_int, '0')) * @as(c_int, 10)) + @as(c_int, d[@as(c_int, 12)])) - @as(c_int, '0');
                            if (l > @as(c_int, 12)) {
                                l -= 12;
                            }
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%2.2d", l);
                            if (@as(c_int, buf[@as(c_int, 0)]) == @as(c_int, '0')) {
                                buf[@as(c_int, 0)] = fill;
                            }
                            stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), 2);
                            stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), d + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 13))))), 3);
                        }
                        break;
                    },
                    @as(c_int, 'd') => {
                        {
                            if (@as(c_int, s[@as(c_int, 1)]) != 0) {
                                while (true) {
                                    switch (@as(c_int, (blk: {
                                        const ref = &s;
                                        ref.* += 1;
                                        break :blk ref.*;
                                    }).*)) {
                                        @as(c_int, 'd') => {
                                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%02d", cas.*.tm_mday);
                                            break;
                                        },
                                        @as(c_int, 'm') => {
                                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%02d", cas.*.tm_mon + @as(c_int, 1));
                                            break;
                                        },
                                        @as(c_int, 'y') => {
                                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%02d", @rem(cas.*.tm_year, @as(c_int, 100)));
                                            break;
                                        },
                                        @as(c_int, 'Y') => {
                                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%04d", cas.*.tm_year + @as(c_int, 1900));
                                            break;
                                        },
                                        @as(c_int, 'w') => {
                                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%d", cas.*.tm_wday);
                                            break;
                                        },
                                        @as(c_int, 'D') => {
                                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%03d", cas.*.tm_yday);
                                            break;
                                        },
                                        else => {
                                            buf[@as(c_int, 0)] = 'd';
                                            buf[@as(c_int, 1)] = s.*;
                                            buf[@as(c_int, 2)] = 0;
                                        },
                                    }
                                    break;
                                }
                            } else {
                                buf[@as(c_int, 0)] = 'd';
                                buf[@as(c_int, 1)] = 0;
                            }
                            stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        }
                        break;
                    },
                    @as(c_int, 'E') => {
                        {
                            var ch: [*c]u8 = undefined;
                            _ = &ch;
                            var l: c_int = undefined;
                            _ = &l;
                            buf[@as(c_int, 0)] = 0;
                            {
                                l = 0;
                                while ((@as(c_int, s[@bitCast(@as(isize, @intCast(l + @as(c_int, 1))))]) != 0) and (@as(c_int, s[@bitCast(@as(isize, @intCast(l + @as(c_int, 1))))]) != @as(c_int, '%'))) : (l += 1) {
                                    buf[@bitCast(@as(isize, @intCast(l)))] = s[@bitCast(@as(isize, @intCast(l + @as(c_int, 1))))];
                                }
                            }
                            if ((@as(c_int, s[@bitCast(@as(isize, @intCast(l + @as(c_int, 1))))]) == @as(c_int, '%')) and (@as(c_int, buf[@as(c_int, 0)]) != 0)) {
                                buf[@bitCast(@as(isize, @intCast(l)))] = 0;
                                s += @as(usize, @bitCast(@as(isize, @intCast(l + @as(c_int, 1)))));
                                ch = getenv(@ptrCast(@alignCast(&buf)));
                                if (ch != null) {
                                    stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), ch, slen(ch));
                                }
                            }
                        }
                        break;
                    },
                    @as(c_int, 'Z') => {
                        {
                            var ch: [*c]const u8 = undefined;
                            _ = &ch;
                            var l: c_int = undefined;
                            _ = &l;
                            buf[@as(c_int, 0)] = 0;
                            {
                                l = 0;
                                while ((@as(c_int, s[@bitCast(@as(isize, @intCast(l + @as(c_int, 1))))]) != 0) and (@as(c_int, s[@bitCast(@as(isize, @intCast(l + @as(c_int, 1))))]) != @as(c_int, '%'))) : (l += 1) {
                                    buf[@bitCast(@as(isize, @intCast(l)))] = s[@bitCast(@as(isize, @intCast(l + @as(c_int, 1))))];
                                }
                            }
                            if ((@as(c_int, s[@bitCast(@as(isize, @intCast(l + @as(c_int, 1))))]) == @as(c_int, '%')) and (@as(c_int, buf[@as(c_int, 0)]) != 0)) {
                                buf[@bitCast(@as(isize, @intCast(l)))] = 0;
                                s += @as(usize, @bitCast(@as(isize, @intCast(l + @as(c_int, 1)))));
                                ch = get_status(bw_1, @ptrCast(@alignCast(&buf)));
                                if (ch != null) {
                                    stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), ch, slen(ch));
                                }
                            }
                        }
                        break;
                    },
                    @as(c_int, 'u') => {
                        {
                            var curtime: time_t = time(null);
                            _ = &curtime;
                            var d: [*c]u8 = ctime(&curtime);
                            _ = &d;
                            stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), d + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 11))))), 5);
                        }
                        break;
                    },
                    @as(c_int, 'T') => {
                        if (bw_1.*.o.overtype != 0) {
                            stalin = vsadd(stalin, 'O');
                        } else {
                            stalin = vsadd(stalin, 'I');
                        }
                        break;
                    },
                    @as(c_int, 'W') => {
                        if (bw_1.*.o.wordwrap != 0) {
                            stalin = vsadd(stalin, 'W');
                        } else {
                            stalin = vsadd(stalin, fill);
                        }
                        break;
                    },
                    @as(c_int, 'I') => {
                        if (bw_1.*.o.autoindent != 0) {
                            stalin = vsadd(stalin, 'A');
                        } else {
                            stalin = vsadd(stalin, fill);
                        }
                        break;
                    },
                    @as(c_int, 'X') => {
                        if (square != 0) {
                            stalin = vsadd(stalin, 'X');
                        } else {
                            stalin = vsadd(stalin, fill);
                        }
                        break;
                    },
                    @as(c_int, 'n') => {
                        {
                            if (bw_1.*.b.*.name != null) {
                                var tmp: [*c]u8 = simplify_prefix(bw_1.*.b.*.name);
                                _ = &tmp;
                                var tmp1: [*c]u8 = duplicate_backslashes(tmp, if (tmp != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tmp))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
                                _ = &tmp1;
                                vsrm(tmp);
                                stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), tmp1, if (tmp1 != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tmp1))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
                                vsrm(tmp1);
                            } else {
                                stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), my_gettext("Unnamed"), slen(my_gettext("Unnamed")));
                            }
                        }
                        break;
                    },
                    @as(c_int, 'm') => {
                        if (bw_1.*.b.*.changed != 0) {
                            stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), my_gettext("(Modified)"), slen(my_gettext("(Modified)")));
                        }
                        break;
                    },
                    @as(c_int, 'R') => {
                        if (bw_1.*.b.*.rdonly != 0) {
                            stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), my_gettext("(Read only)"), slen(my_gettext("(Read only)")));
                        }
                        break;
                    },
                    @as(c_int, '*') => {
                        if (bw_1.*.b.*.changed != 0) {
                            stalin = vsadd(stalin, '*');
                        } else {
                            stalin = vsadd(stalin, fill);
                        }
                        break;
                    },
                    @as(c_int, 'r') => {
                        if (field != 0) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%-4lld", bw_1.*.cursor.*.line + @as(off_t, 1));
                        } else {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%lld", bw_1.*.cursor.*.line + @as(off_t, 1));
                        }
                        {
                            x = 0;
                            while (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) if (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, ' ')) {
                                buf[@bitCast(@as(isize, @intCast(x)))] = fill;
                            };
                        }
                        stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        break;
                    },
                    @as(c_int, 'o') => {
                        if (field != 0) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%-4lld", bw_1.*.cursor.*.byte);
                        } else {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%lld", bw_1.*.cursor.*.byte);
                        }
                        {
                            x = 0;
                            while (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) if (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, ' ')) {
                                buf[@bitCast(@as(isize, @intCast(x)))] = fill;
                            };
                        }
                        stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        break;
                    },
                    @as(c_int, 'O') => {
                        if (field != 0) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%-4llX", @as(c_ulonglong, @bitCast(@as(c_longlong, bw_1.*.cursor.*.byte))));
                        } else {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%llX", @as(c_ulonglong, @bitCast(@as(c_longlong, bw_1.*.cursor.*.byte))));
                        }
                        {
                            x = 0;
                            while (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) if (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, ' ')) {
                                buf[@bitCast(@as(isize, @intCast(x)))] = fill;
                            };
                        }
                        stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        break;
                    },
                    @as(c_int, 'a') => {
                        if (!(piseof(bw_1.*.cursor) != 0)) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%3d", brch(bw_1.*.cursor));
                        } else {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "   ");
                        }
                        {
                            x = 0;
                            while (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) if (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, ' ')) {
                                buf[@bitCast(@as(isize, @intCast(x)))] = fill;
                            };
                        }
                        stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        break;
                    },
                    @as(c_int, 'A') => {
                        if (field != 0) if (!(piseof(bw_1.*.cursor) != 0)) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%2.2X", brch(bw_1.*.cursor));
                        } else {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "  ");
                        } else if (!(piseof(bw_1.*.cursor) != 0)) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%x", brch(bw_1.*.cursor));
                        } else {
                            buf[@as(c_int, 0)] = 0;
                        }
                        {
                            x = 0;
                            while (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) if (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, ' ')) {
                                buf[@bitCast(@as(isize, @intCast(x)))] = fill;
                            };
                        }
                        stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        break;
                    },
                    @as(c_int, 'c') => {
                        if (field != 0) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%-3lld", piscol(bw_1.*.cursor) + @as(off_t, 1));
                        } else {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%lld", piscol(bw_1.*.cursor) + @as(off_t, 1));
                        }
                        {
                            x = 0;
                            while (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) if (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, ' ')) {
                                buf[@bitCast(@as(isize, @intCast(x)))] = fill;
                            };
                        }
                        stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        break;
                    },
                    @as(c_int, 'p') => {
                        if (bw_1.*.b.*.eof.*.byte >= @as(off_t, @as(c_int, 1024) * @as(c_int, 1024))) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%3lld", @divTrunc((bw_1.*.cursor.*.byte >> @intCast(@as(c_longlong, 10))) * @as(c_longlong, 100), bw_1.*.b.*.eof.*.byte >> @intCast(@as(c_longlong, 10))));
                        } else if (bw_1.*.b.*.eof.*.byte != 0) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%3lld", @divTrunc(bw_1.*.cursor.*.byte * @as(c_longlong, 100), bw_1.*.b.*.eof.*.byte));
                        } else {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "100");
                        }
                        {
                            x = 0;
                            while (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) if (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, ' ')) {
                                buf[@bitCast(@as(isize, @intCast(x)))] = fill;
                            };
                        }
                        stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        break;
                    },
                    @as(c_int, 'l') => {
                        if (field != 0) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%-4lld", bw_1.*.b.*.eof.*.line + @as(off_t, 1));
                        } else {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%lld", bw_1.*.b.*.eof.*.line + @as(off_t, 1));
                        }
                        {
                            x = 0;
                            while (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) if (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, ' ')) {
                                buf[@bitCast(@as(isize, @intCast(x)))] = fill;
                            };
                        }
                        stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        break;
                    },
                    @as(c_int, 'k') => {
                        {
                            var i: ptrdiff_t = undefined;
                            _ = &i;
                            var mycpos: [*c]u8 = @ptrCast(@alignCast(&buf));
                            _ = &mycpos;
                            buf[@as(c_int, 0)] = 0;
                            const kseq: [*c]c_int = @ptrCast(&w.*.kbd.*.seq);
                            if ((w.*.kbd.*.x != 0) and (kseq[0] != 0)) {
                                i = 0;
                                while (i != w.*.kbd.*.x) : (i += 1) {
                                    var c: u8 = @bitCast(@as(i8, @truncate(kseq[@intCast(i)] & @as(c_int, 127))));
                                    _ = &c;
                                    if (@as(c_int, c) < @as(c_int, 32)) {
                                        mycpos[@as(c_int, 0)] = '^';
                                        mycpos[@as(c_int, 1)] = @bitCast(@as(i8, @truncate(@as(c_int, c) + @as(c_int, '@'))));
                                        mycpos += @as(usize, @bitCast(@as(isize, @intCast(2))));
                                    } else if (@as(c_int, c) == @as(c_int, 127)) {
                                        mycpos[@as(c_int, 0)] = '^';
                                        mycpos[@as(c_int, 1)] = '?';
                                        mycpos += @as(usize, @bitCast(@as(isize, @intCast(2))));
                                    } else {
                                        mycpos[@as(c_int, 0)] = c;
                                        mycpos += @as(usize, @bitCast(@as(isize, @intCast(1))));
                                    }
                                }
                            }
                            (blk: {
                                const ref = &mycpos;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            }).* = fill;
                            while (@divExact(@as(c_long, @bitCast(@intFromPtr(mycpos) -% @intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&buf)))))), @sizeOf(u8)) < @as(c_long, 4)) {
                                (blk: {
                                    const ref = &mycpos;
                                    const tmp = ref.*;
                                    ref.* += 1;
                                    break :blk tmp;
                                }).* = fill;
                            }
                            stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), @divExact(@as(c_long, @bitCast(@intFromPtr(mycpos) -% @intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&buf)))))), @sizeOf(u8)));
                        }
                        break;
                    },
                    @as(c_int, 'S') => {
                        if (bw_1.*.b.*.pid != 0) {
                            stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), my_gettext("*SHELL*"), slen(my_gettext("*SHELL*")));
                        }
                        break;
                    },
                    @as(c_int, 'M') => {
                        if (recmac != null) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), my_gettext("(Macro %d recording...)"), recmac.*.n);
                            stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        }
                        break;
                    },
                    @as(c_int, 'e') => {
                        stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), bw_1.*.b.*.o.charmap.*.name, slen(bw_1.*.b.*.o.charmap.*.name));
                        break;
                    },
                    @as(c_int, 'b') => {
                        stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), locale_map.*.name, slen(locale_map.*.name));
                        break;
                    },
                    @as(c_int, 'w') => {
                        if (!(piseof(bw_1.*.cursor) != 0)) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%d", joe_wcwidth(bw_1.*.o.charmap.*.type, brch(bw_1.*.cursor)));
                            stalin = vsncpy(stalin, if (stalin != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(stalin))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))));
                        }
                        break;
                    },
                    else => {
                        stalin = vsadd(stalin, s.*);
                    },
                }
                break;
            }
        } else {
            stalin = vsadd(stalin, s.*);
        }
        s += 1;
    }
    return stalin;
}
pub export fn usplitw(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var newh: ptrdiff_t = getgrouph(w);
    _ = &newh;
    var neww: [*c]W = undefined;
    _ = &neww;
    var newtw: [*c]TW = undefined;
    _ = &newtw;
    var newbw: [*c]BW = undefined;
    _ = &newbw;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    dostaupd = 1;
    if (@divTrunc(newh, @as(ptrdiff_t, 2)) < @as(ptrdiff_t, FITHEIGHT)) return -@as(c_int, 1);
    neww = wcreate(w.*.t, w.*.watom, findbotw(w), null, w, @divTrunc(newh, @as(ptrdiff_t, 2)) + (newh & @as(ptrdiff_t, 1)), null, null);
    if (!(neww != null)) return -@as(c_int, 1);
    neww.*.object = @ptrCast(@alignCast(blk: {
        const tmp = bwmk(neww, bw_1.*.b, 0);
        newbw = tmp;
        break :blk tmp;
    }));
    bw_1.*.b.*.count += 1;
    newbw.*.offset = bw_1.*.offset;
    newbw.*.object = @ptrCast(@alignCast(blk: {
        const tmp = @as([*c]TW, @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(TW)))))))));
        newtw = tmp;
        break :blk tmp;
    }));
    iztw(newtw, neww.*.y);
    pset(newbw.*.top, bw_1.*.top);
    pset(newbw.*.cursor, bw_1.*.cursor);
    newbw.*.cursor.*.xcol = bw_1.*.cursor.*.xcol;
    neww.*.t.*.curwin = neww;
    wfit(neww.*.t);
    return 0;
}
pub export fn uduptw(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var newh: ptrdiff_t = getgrouph(w);
    _ = &newh;
    var neww: [*c]W = undefined;
    _ = &neww;
    var newtw: [*c]TW = undefined;
    _ = &newtw;
    var newbw: [*c]BW = undefined;
    _ = &newbw;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    dostaupd = 1;
    neww = wcreate(w.*.t, w.*.watom, findbotw(w), null, null, newh, null, null);
    if (!(neww != null)) return -@as(c_int, 1);
    if (demotegroup(w) != 0) {
        neww.*.t.*.topwin = neww;
    }
    neww.*.object = @ptrCast(@alignCast(blk: {
        const tmp = bwmk(neww, bw_1.*.b, 0);
        newbw = tmp;
        break :blk tmp;
    }));
    bw_1.*.b.*.count += 1;
    newbw.*.offset = bw_1.*.offset;
    newbw.*.object = @ptrCast(@alignCast(blk: {
        const tmp = @as([*c]TW, @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(TW)))))))));
        newtw = tmp;
        break :blk tmp;
    }));
    iztw(newtw, neww.*.y);
    pset(newbw.*.top, bw_1.*.top);
    pset(newbw.*.cursor, bw_1.*.cursor);
    newbw.*.cursor.*.xcol = bw_1.*.cursor.*.xcol;
    neww.*.t.*.curwin = neww;
    wfit(w.*.t);
    return 0;
}
pub export var watomtw: WATOM = WATOM{
    .context = "main",
    .disp = disptw,
    .follow = bwfllw,
    .abort = null,
    .rtn = rtntw,
    .type = utypew,
    .resize = resizetw,
    .move = movetw,
    .ins = instw,
    .del = deltw,
    .what = TYPETW,
};
pub export fn abortit(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var tw_2: [*c]TW = undefined;
    _ = &tw_2;
    var b_3: [*c]B = undefined;
    _ = &b_3;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (bw_1.*.parent.*.watom != (&watomtw)) return wabort(bw_1.*.parent);
    if ((bw_1.*.b.*.pid != 0) and (bw_1.*.b.*.count == @as(c_int, 1))) return ukillpid(bw_1.*.parent, 0);
    w = bw_1.*.parent;
    tw_2 = @ptrCast(@alignCast(bw_1.*.object));
    if (countmain(w.*.t) == @as(c_int, 1)) if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = borphan();
        b_3 = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        var object: ?*anyopaque = bw_1.*.object;
        _ = &object;
        bwrm(bw_1);
        w.*.object = @ptrCast(@alignCast(blk: {
            const tmp = bwmk(w, b_3, 0);
            bw_1 = tmp;
            break :blk tmp;
        }));
        wredraw(bw_1.*.parent);
        bw_1.*.object = object;
        bw_1 = @ptrCast(@alignCast(w.*.object));
        bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
        return 0;
    };
    bwrm(bw_1);
    vsrm(tw_2.*.stalin);
    joe_free(@ptrCast(@alignCast(tw_2)));
    w.*.object = null;
    _ = wabort(w);
    return 0;
}
pub export fn upopabort(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (bw_1.*.parent.*.bstack != null) {
        var rtn: c_int = undefined;
        _ = &rtn;
        var b_1: [*c]B = wpop(bw_1);
        _ = &b_1;
        w = bw_1.*.parent;
        rtn = get_buffer_in_window(bw_1, b_1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
        return rtn;
    } else {
        return 0;
    }
}
pub export fn uabort(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    if (w.*.watom != (&watomtw)) return wabort(w);
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if ((markv(0) != 0) and (markb.*.b == bw_1.*.b)) {
        prm(markk);
        markk = null;
        updall();
        return 0;
    }
    if (bw_1.*.parent.*.bstack != null) {
        var rtn: c_int = undefined;
        _ = &rtn;
        var b_1: [*c]B = wpop(bw_1);
        _ = &b_1;
        w = bw_1.*.parent;
        rtn = get_buffer_in_window(bw_1, b_1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
        return rtn;
    }
    if ((bw_1.*.b.*.pid != 0) and (bw_1.*.b.*.count == @as(c_int, 1))) return ukillpid(bw_1.*.parent, 0);
    if (((bw_1.*.b.*.changed != 0) and (bw_1.*.b.*.count == @as(c_int, 1))) and !(bw_1.*.b.*.scratch != 0)) if (mkqw(w, my_gettext("Lose changes to this file (y,n,%{abort})? "), slen(my_gettext("Lose changes to this file (y,n,%{abort})? ")), naborttw, null, null, null) != null) return 0 else return -@as(c_int, 1) else return naborttw(bw_1.*.parent, -@as(c_int, 10), null, null);
}
pub export fn ucancel(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (w.*.watom != (&watomtw)) {
        _ = wabort(w);
        return 0;
    } else return uabort(w, k);
}
pub export fn uabort1(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    if (w.*.watom != (&watomtw)) return wabort(w);
    bw_1 = @ptrCast(@alignCast(w.*.object));
    if ((bw_1.*.b.*.pid != 0) and (bw_1.*.b.*.count == @as(c_int, 1))) return ukillpid(bw_1.*.parent, 0);
    if (((bw_1.*.b.*.changed != 0) and (bw_1.*.b.*.count == @as(c_int, 1))) and !(bw_1.*.b.*.scratch != 0)) if (mkqw(w, my_gettext("Lose changes to this file (y,n,%{abort})? "), slen(my_gettext("Lose changes to this file (y,n,%{abort})? ")), naborttw1, null, null, null) != null) return 0 else return -@as(c_int, 1) else return naborttw1(w, -@as(c_int, 10), null, null);
}
pub export fn uabortbuf(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var b_2: [*c]B = undefined;
    _ = &b_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if ((bw_1.*.b.*.pid != 0) and (bw_1.*.b.*.count == @as(c_int, 1))) return ukillpid(w, 0);
    if (okrepl(bw_1) != 0) return -@as(c_int, 1);
    if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = borphan();
        b_2 = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        var object: ?*anyopaque = bw_1.*.object;
        _ = &object;
        bwrm(bw_1);
        w.*.object = @ptrCast(@alignCast(blk: {
            const tmp = bwmk(w, b_2, 0);
            bw_1 = tmp;
            break :blk tmp;
        }));
        wredraw(bw_1.*.parent);
        bw_1.*.object = object;
        return 0;
    }
    return naborttw(w, -@as(c_int, 10), null, null);
}
pub export fn utw0(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    w = w.*.main;
    bw_1 = @ptrCast(@alignCast(w.*.object));
    if (w.*.bstack != null) return uabort(w, -@as(c_int, 1));
    if (countmain(w.*.t) == @as(c_int, 1)) return -@as(c_int, 1);
    if (bw_1.*.b.*.count == @as(c_int, 1)) {
        orphit(bw_1);
    }
    return uabort(w, -@as(c_int, 1));
}
pub export fn utw1(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var starting: [*c]W = w;
    _ = &starting;
    var mainw: [*c]W = starting.*.main;
    _ = &mainw;
    var t: [*c]Screen = mainw.*.t;
    _ = &t;
    var myyn: c_int = undefined;
    _ = &myyn;
    while (true) {
        myyn = 0;
        while (true) {
            while (true) {
                wnext(t);
                if (!((t.*.curwin.*.main == mainw) and (t.*.curwin != starting))) break;
            }
            if (t.*.curwin.*.main != mainw) {
                _ = utw0(t.*.curwin.*.main, 0);
                myyn = 1;
                continue;
            }
            break;
        }
        if (!(myyn != 0)) break;
    }
    return 0;
}
pub export fn setline(arg_b_1: [*c]B, arg_line: off_t) void {
    var b_1 = arg_b_1;
    _ = &b_1;
    var line = arg_line;
    _ = &line;
    var w: [*c]W = maint.*.curwin;
    _ = &w;
    while (true) {
        if (w.*.watom.*.what == TYPETW) {
            var bw_1: [*c]BW = @ptrCast(@alignCast(w.*.object));
            _ = &bw_1;
            if (bw_1.*.b == b_1) {
                var oline: off_t = bw_1.*.top.*.line;
                _ = &oline;
                _ = pline(bw_1.*.cursor, line);
                if (!(bw_1.*.b.*.err != null)) {
                    bw_1.*.b.*.err = pdup(bw_1.*.cursor, "setline");
                }
                _ = pline(bw_1.*.b.*.err, line);
                if (((w.*.y >= @as(ptrdiff_t, 0)) and (bw_1.*.top.*.line > oline)) and ((bw_1.*.top.*.line - oline) < @as(off_t, bw_1.*.h))) {
                    nscrlup(w.*.t.*.t, bw_1.*.y, bw_1.*.y + bw_1.*.h, @as(c_int, @truncate(bw_1.*.top.*.line - oline)));
                } else if (((w.*.y >= @as(ptrdiff_t, 0)) and (bw_1.*.top.*.line < oline)) and ((oline - bw_1.*.top.*.line) < @as(off_t, bw_1.*.h))) {
                    nscrldn(w.*.t.*.t, bw_1.*.y, bw_1.*.y + bw_1.*.h, @as(c_int, @truncate(oline - bw_1.*.top.*.line)));
                }
                _ = msetI(bw_1.*.t.*.t.*.updtab + @as(usize, @bitCast(@as(isize, @intCast(bw_1.*.y)))), 1, bw_1.*.h);
            }
        }
        if (!((blk: {
            const tmp = w.*.link.next;
            w = tmp;
            break :blk tmp;
        }) != maint.*.curwin)) break;
    }
    if ((errbuf == b_1) and (b_1.*.oldcur != null)) {
        _ = pline(b_1.*.oldcur, line);
        if (!(b_1.*.err != null)) {
            b_1.*.err = pdup(b_1.*.oldcur, "setline1");
        }
        _ = pline(b_1.*.err, line);
    }
}
pub export fn wmktw(arg_t: [*c]Screen, arg_b_1: [*c]B) [*c]BW {
    var t = arg_t;
    _ = &t;
    var b_1 = arg_b_1;
    _ = &b_1;
    var w: [*c]W = undefined;
    _ = &w;
    var bw_2: [*c]BW = undefined;
    _ = &bw_2;
    var tw_3: [*c]TW = undefined;
    _ = &tw_3;
    w = wcreate(t, &watomtw, null, null, null, t.*.h, null, null);
    wfit(w.*.t);
    w.*.object = @ptrCast(@alignCast(blk: {
        const tmp = bwmk(w, b_1, 0);
        bw_2 = tmp;
        break :blk tmp;
    }));
    bw_2.*.object = @ptrCast(@alignCast(blk: {
        const tmp = @as([*c]TW, @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(TW)))))))));
        tw_3 = tmp;
        break :blk tmp;
    }));
    iztw(tw_3, w.*.y);
    return bw_2;
}

comptime {
    if (@sizeOf(TW) != 48) @compileError("TW size mismatch");
    if (@sizeOf(BW) != 488) @compileError("BW size mismatch");
    if (@sizeOf(OPTIONS) != 344) @compileError("OPTIONS size mismatch");
    if (@sizeOf(W) != 200) @compileError("W size mismatch");
    if (@sizeOf(B) != 632) @compileError("B size mismatch");
    if (@sizeOf(P) != 112) @compileError("P size mismatch");
    if (@sizeOf(KBD) != 88) @compileError("KBD size mismatch");
    if (@offsetOf(BW, "object") != 424) @compileError("BW.object offset mismatch");
    if (@offsetOf(BW, "lincols") != 432) @compileError("BW.lincols offset mismatch");
    if (@offsetOf(B, "pid") != 588) @compileError("B.pid offset mismatch");
    if (@offsetOf(B, "err") != 552) @compileError("B.err offset mismatch");
    if (@offsetOf(OPTIONS, "hex") != 264) @compileError("OPTIONS.hex offset mismatch");
}
