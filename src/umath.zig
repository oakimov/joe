//! Math expression evaluator — replaces `joe/umath.c`.
//!
//! Faithful C-ABI Path A port of JOE math (`calc`/`umath`/`usmath`/`joe_strtod`).

const std = @import("std");
const ptrdiff_t = c_long;

// stdbuf must match the real definition (gapbuffer/intern.zig); size comes from
// gap_types.stdsiz so the extern view can never silently disagree again.
const gap_types = @import("gapbuffer/types.zig");

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;
const M_PI: f64 = 3.14159265358979323846;
const M_E: f64 = 2.71828182845904523536;
const SIGFPE: c_int = 8;

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
    _pad_type: [4]u8 = std.mem.zeroes([4]u8),
    is_punct: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    is_print: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    is_space: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    is_alpha_: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    is_alnum_: ?*const fn (map: [*c]struct_charmap, c: c_int) callconv(.c) c_int = null,
    _pad: [2692]u8 = std.mem.zeroes([2692]u8),
};
pub const struct_macro = opaque {
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
    _pad0: [16]u8 = std.mem.zeroes([16]u8),
    bof: [*c]P = null,
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
    current_dir: [*c]u8 = null,
    _pad3: [4]u8 = std.mem.zeroes([4]u8),
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
pub extern var stdbuf: [gap_types.stdsiz]u8;
pub extern var locale_map: [*c]struct_charmap;
pub extern var recmac: [*c]struct_recmac;
pub extern var markb: [*c]P;
pub extern var markk: [*c]P;
pub extern var exmsg: [*c]u8;
pub extern var have: c_int;
pub extern var square: c_int;
pub extern var yes_key: [*c]const u8;
pub extern var watomtw: WATOM;
pub extern fn rtntw(w: [*c]W) c_int;
pub extern fn utypew(w: [*c]W, k: c_int) c_int;
pub extern fn msetI(dest: [*c]c_int, c: c_int, sz: ptrdiff_t) [*c]c_int;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn dirprt(path: [*c]const u8) [*c]u8;
pub extern fn canonical(s: [*c]u8, flags: c_int) [*c]u8;
pub extern fn brvs(p: [*c]P, size: off_t) [*c]u8;
pub extern fn brc(p: [*c]P) c_int;
pub extern fn pgetc(p: [*c]P) c_int;
pub extern fn prgetc(p: [*c]P) c_int;
pub extern fn p_goto_eol(p: [*c]P) void;
pub extern fn p_goto_eof(p: [*c]P) void;
pub extern fn pnextl(p: [*c]P) c_int;
pub extern fn bmk(prop: [*c]B) [*c]B;
pub extern fn bcpy(from: [*c]P, to: [*c]P) [*c]B;
pub extern fn bdel(from: [*c]P, to: [*c]P) void;
pub extern fn binsb(p: [*c]P, b: [*c]B) void;
pub extern fn binsc(p: [*c]P, c: c_int) void;
pub extern fn binsm(p: [*c]P, blk: [*c]const u8, size: ptrdiff_t) void;
pub extern fn binsmq(p: [*c]P, blk: [*c]const u8, size: ptrdiff_t) void;
pub extern fn vaadd(vary: [*c][*c]u8, element: [*c]u8) [*c][*c]u8;
pub extern fn varm(vary: [*c][*c]u8) void;
pub extern fn rmatch(pattern: [*c]const u8, s: [*c]const u8) c_int;
pub extern fn isreg(s: [*c]const u8) c_int;
pub extern fn cmplt_file(bw: [*c]BW, k: c_int) c_int;
pub extern fn mkmenu(loc: [*c]W, targ: [*c]W, s: [*c][*c]u8, func: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque, k: c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, backs: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, cursor: ptrdiff_t, object: ?*anyopaque, notify: [*c]c_int) [*c]MENU;
pub extern fn mcomplete(m: [*c]MENU) [*c]u8;
pub extern fn bwfllwt(w: [*c]W) void;
pub extern fn ttflsh() void;
pub extern var obufp: ptrdiff_t;
pub extern var obufsiz: ptrdiff_t;
pub extern var obuf: [*c]u8;
pub extern var smode: c_int;
pub extern var menu_above: c_int;
pub extern var menu_jump: c_int;
pub extern var watommenu: WATOM;
pub extern fn sin(f64) f64;
pub extern fn cos(f64) f64;
pub extern fn tan(f64) f64;
pub extern fn exp(f64) f64;
pub extern fn sqrt(f64) f64;
pub extern fn cbrt(f64) f64;
pub extern fn log(f64) f64;
pub extern fn log10(f64) f64;
pub extern fn asin(f64) f64;
pub extern fn acos(f64) f64;
pub extern fn atan(f64) f64;
pub extern fn sinh(f64) f64;
pub extern fn cosh(f64) f64;
pub extern fn tanh(f64) f64;
pub extern fn asinh(f64) f64;
pub extern fn acosh(f64) f64;
pub extern fn atanh(f64) f64;
pub extern fn floor(f64) f64;
pub extern fn ceil(f64) f64;
pub extern fn fabs(f64) f64;
pub extern fn erf(f64) f64;
pub extern fn erfc(f64) f64;
pub extern fn j0(f64) f64;
pub extern fn j1(f64) f64;
pub extern fn y0(f64) f64;
pub extern fn y1(f64) f64;
pub extern fn pow(f64, f64) f64;
pub extern fn strtod([*c]const u8, [*c][*c]u8) f64;
pub extern var msgbuf: [300]u8;
pub extern fn joe_set_signal(signum: c_int, handler: ?*const fn (c_int) callconv(.c) void) c_int;
pub extern fn parse_wsl(p: [*c][*c]const u8, cmt: c_int) c_int;
pub extern fn parse_wsn(p: [*c][*c]const u8, cmt: c_int) c_int;
pub extern fn parse_ident(p: [*c][*c]const u8, buf: [*c]u8, len: ptrdiff_t) c_int;
pub extern fn blksum(bw: [*c]BW, sum: [*c]f64, sumsq: [*c]f64) c_int;
pub extern fn blklr(bw: [*c]BW, sumx: [*c]f64, sumx2: [*c]f64, sumy: [*c]f64, sumy2: [*c]f64, sumxy: [*c]f64, logx: c_int, logy: c_int) c_int;
pub extern fn blkget(bw: [*c]BW) [*c]u8;
pub extern fn msgnw(w: [*c]W, s: [*c]const u8) void;
pub extern fn mparse(m: ?*MACRO, s: [*c]u8, sta: [*c]ptrdiff_t, sec: c_int) ?*MACRO;
pub extern fn exmacro(m: ?*MACRO, u: c_int, k: c_int) c_int;
pub extern fn rmmacro(m: ?*MACRO) void;
pub extern fn wmkpw(w: [*c]W, prompt: [*c]const u8, history: [*c][*c]B, func: ?*const fn (w: [*c]W, s: [*c]u8, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, huh: [*c]const u8, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, tab: ?*const fn (bw: [*c]BW, k: c_int) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int, map: [*c]struct_charmap, file_prompt: c_int) [*c]BW;
pub extern fn simple_cmplt(bw: [*c]BW, list: [*c][*c]u8) c_int;
pub extern fn utypebw(bw: [*c]BW, k: c_int) c_int;
pub extern fn binss(p: [*c]P, s: [*c]const u8) void;
pub extern fn vamk(len: ptrdiff_t) [*c][*c]u8;
pub extern var utf8_map: [*c]struct_charmap;
pub extern fn zlcpy(a: [*c]u8, len: ptrdiff_t, b: [*c]const u8) [*c]u8;
pub extern fn pfwrd(p: [*c]P, n: off_t) [*c]P;
pub extern fn word_cmplt(bw: [*c]BW, list: [*c][*c]u8) c_int;
pub extern var current_arg: c_int;
pub extern var current_arg_set: c_int;
pub fn doumath(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    return domath(w, s, object, notify, 0);
}
pub fn dosmath(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    return domath(w, s, object, notify, 1);
}
pub fn domath(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int, arg_secure: c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var secure = arg_secure;
    _ = &secure;
    var result: f64 = undefined;
    _ = &result;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    result = calc(bw_1, s, secure);
    if (notify != null) {
        notify.* = 1;
    }
    if (merr != null) {
        msgnw(bw_1.*.parent, merr);
        return -@as(c_int, 1);
    }
    vsrm(s);
    if ((bw_1.*.parent.*.watom.*.what != TYPETW) or (mode_ins != 0)) {
        format_result(@ptrCast(@alignCast(&msgbuf)), result, mode_display, mode_commas);
        binsm(bw_1.*.cursor, @ptrCast(@alignCast(&msgbuf)), slen(@ptrCast(@alignCast(&msgbuf))));
        _ = pfwrd(bw_1.*.cursor, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(@ptrCast(@alignCast(&msgbuf))))))));
        bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
    } else {
        format_result(@ptrCast(@alignCast(&msgbuf)), result, mode_display, 1);
        msgnw(bw_1.*.parent, @ptrCast(@alignCast(&msgbuf)));
    }
    if (mode_ins != 0) {
        mode_ins = 0;
        mode_commas = 0;
        return 0;
    } else {
        return 0;
    }
}
pub const struct_var = extern struct {
    name: [*c]u8 = null,
    func: ?*const fn (n: f64) callconv(.c) f64 = null,
    set: c_int = 0,
    val: f64 = 0,
    next: [*c]struct_var = null,
};
pub fn setup_vars(arg_tbw: [*c]BW) callconv(.c) void {
    var tbw = arg_tbw;
    _ = &tbw;
    var v: [*c]struct_var = undefined;
    _ = &v;
    var c: c_int = brch(tbw.*.cursor);
    _ = &c;
    if (!(vars != null)) {
        v = get("sin");
        v.*.func = m_sin;
        v = get("cos");
        v.*.func = m_cos;
        v = get("tan");
        v.*.func = m_tan;
        v = get("exp");
        v.*.func = m_exp;
        v = get("sqrt");
        v.*.func = m_sqrt;
        v = get("cbrt");
        v.*.func = m_cbrt;
        v = get("ln");
        v.*.func = m_log;
        v = get("log");
        v.*.func = m_log10;
        v = get("asin");
        v.*.func = m_asin;
        v = get("acos");
        v.*.func = m_acos;
        v = get("atan");
        v.*.func = m_atan;
        v = get("pi");
        v.*.val = M_PI;
        v.*.set = 1;
        v = get("e");
        v.*.val = M_E;
        v.*.set = 1;
        v = get("sinh");
        v.*.func = m_sinh;
        v = get("cosh");
        v.*.func = m_cosh;
        v = get("tanh");
        v.*.func = m_tanh;
        v = get("asinh");
        v.*.func = m_asinh;
        v = get("acosh");
        v.*.func = m_acosh;
        v = get("atanh");
        v.*.func = m_atanh;
        v = get("floor");
        v.*.func = m_floor;
        v = get("ceil");
        v.*.func = m_ceil;
        v = get("abs");
        v.*.func = m_fabs;
        v = get("erf");
        v.*.func = m_erf;
        v = get("erfc");
        v.*.func = m_erfc;
        v = get("j0");
        v.*.func = m_j0;
        v = get("j1");
        v.*.func = m_j1;
        v = get("y0");
        v.*.func = m_y0;
        v = get("y1");
        v.*.func = m_y1;
        v = get("int");
        v.*.func = m_int;
        v = get("lr");
        v.*.func = m_lr;
        v = get("rlr");
        v.*.func = m_rlr;
        v = get("Lr");
        v.*.func = m_Lr;
        v = get("rLr");
        v.*.func = m_rLr;
        v = get("lR");
        v.*.func = m_lR;
        v = get("rlR");
        v.*.func = m_rlR;
        v = get("LR");
        v.*.func = m_LR;
        v = get("rLR");
        v.*.func = m_rLR;
    }
    v = get("top");
    v.*.val = @floatFromInt(tbw.*.top.*.line + @as(off_t, 1));
    v.*.set = 1;
    v = get("lines");
    v.*.val = @floatFromInt(tbw.*.b.*.eof.*.line + @as(off_t, 1));
    v.*.set = 1;
    v = get("line");
    v.*.val = @floatFromInt(tbw.*.cursor.*.line + @as(off_t, 1));
    v.*.set = 1;
    v = get("col");
    v.*.val = @floatFromInt(tbw.*.cursor.*.col + @as(off_t, 1));
    v.*.set = 1;
    v = get("byte");
    v.*.val = @floatFromInt(tbw.*.cursor.*.byte + @as(off_t, 1));
    v.*.set = 1;
    v = get("size");
    v.*.val = @floatFromInt(tbw.*.b.*.eof.*.byte);
    v.*.set = 1;
    v = get("height");
    v.*.val = @floatFromInt(tbw.*.h);
    v.*.set = 1;
    v = get("width");
    v.*.val = @floatFromInt(tbw.*.w);
    v.*.set = 1;
    v = get("char");
    v.*.val = if (c == -@as(c_int, 256)) -@as(f64, 1.0) else @as(f64, @floatFromInt(c));
    v.*.set = 1;
    v = get("markv");
    v.*.val = if (markv(1) != 0) @as(f64, 1.0) else @as(f64, 0.0);
    v.*.set = 1;
    v = get("rdonly");
    v.*.val = @floatFromInt(tbw.*.b.*.rdonly);
    v.*.set = 1;
    v = get("arg");
    v.*.val = @floatFromInt(current_arg);
    v.*.set = 1;
    v = get("argset");
    v.*.val = @floatFromInt(current_arg_set);
    v.*.set = 1;
    v = get("no_windows");
    v.*.val = @floatFromInt(countmain(tbw.*.parent.*.t));
    v.*.set = 1;
    merr = null;
    v = get("is_shell");
    v.*.val = @floatFromInt(tbw.*.b.*.pid);
    v.*.set = 1;
}
pub fn format_result(arg_out: [*c]u8, arg_result: f64, arg_base: c_int, arg_commas: c_int) callconv(.c) void {
    var out = arg_out;
    _ = &out;
    var result = arg_result;
    _ = &result;
    var base = arg_base;
    _ = &base;
    var commas = arg_commas;
    _ = &commas;
    var comma_char: u8 = get_lcl_comma();
    _ = &comma_char;
    var buf: [128]u8 = undefined;
    _ = &buf;
    var buf1: [128]u8 = undefined;
    _ = &buf1;
    while (true) {
        switch (base) {
            @as(c_int, 0) => {
                {
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%.16g", result);
                    insert_commas(out, @ptrCast(@alignCast(&buf)), commas);
                    break;
                }
            },
            @as(c_int, 1) => {
                {
                    _ = snprintf(@ptrCast(@alignCast(&buf1)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf1)))))))), "%.16g", result);
                    _ = eng(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf))))), @ptrCast(@alignCast(&buf1)));
                    insert_commas(out, @ptrCast(@alignCast(&buf)), commas);
                    break;
                }
            },
            @as(c_int, 2) => {
                {
                    var n: c_ulonglong = @intFromFloat(result);
                    _ = &n;
                    var ofst: c_int = 0;
                    _ = &ofst;
                    var len: c_int = 0;
                    _ = &len;
                    var cnt: c_int = 0;
                    _ = &cnt;
                    out[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &ofst;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = '0';
                    out[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &ofst;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = 'x';
                    while (n != 0) {
                        buf[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &len;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = "0123456789ABCDEF"[@intCast(n & @as(c_ulonglong, 15))];
                        n >>= @intCast(4);
                    }
                    if (!(len != 0)) {
                        buf[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &len;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = '0';
                    }
                    cnt = len;
                    while (true) {
                        if ((((commas != 0) and (len != 0)) and (cnt != len)) and ((len & @as(c_int, 3)) == @as(c_int, 0))) {
                            out[
                                @bitCast(@as(isize, @intCast(blk: {
                                    const ref = &ofst;
                                    const tmp = ref.*;
                                    ref.* += 1;
                                    break :blk tmp;
                                })))
                            ] = comma_char;
                        }
                        out[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &ofst;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = buf[@bitCast(@as(isize, @intCast(len - @as(c_int, 1))))];
                        if (!((blk: {
                            const ref = &len;
                            ref.* -= 1;
                            break :blk ref.*;
                        }) != 0)) break;
                    }
                    out[@bitCast(@as(isize, @intCast(ofst)))] = 0;
                    break;
                }
            },
            @as(c_int, 3) => {
                {
                    var n: c_ulonglong = @intFromFloat(result);
                    _ = &n;
                    var ofst: c_int = 0;
                    _ = &ofst;
                    var len: c_int = 0;
                    _ = &len;
                    var cnt: c_int = 0;
                    _ = &cnt;
                    out[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &ofst;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = '0';
                    out[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &ofst;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = 'o';
                    while (n != 0) {
                        buf[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &len;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = "01234567"[@intCast(n & @as(c_ulonglong, 7))];
                        n >>= @intCast(3);
                    }
                    if (!(len != 0)) {
                        buf[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &len;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = '0';
                    }
                    cnt = len;
                    while (true) {
                        if ((((commas != 0) and (len != 0)) and (cnt != len)) and ((len & @as(c_int, 3)) == @as(c_int, 0))) {
                            out[
                                @bitCast(@as(isize, @intCast(blk: {
                                    const ref = &ofst;
                                    const tmp = ref.*;
                                    ref.* += 1;
                                    break :blk tmp;
                                })))
                            ] = comma_char;
                        }
                        out[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &ofst;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = buf[@bitCast(@as(isize, @intCast(len - @as(c_int, 1))))];
                        if (!((blk: {
                            const ref = &len;
                            ref.* -= 1;
                            break :blk ref.*;
                        }) != 0)) break;
                    }
                    out[@bitCast(@as(isize, @intCast(ofst)))] = 0;
                    break;
                }
            },
            @as(c_int, 4) => {
                {
                    var n: c_ulonglong = @intFromFloat(result);
                    _ = &n;
                    var ofst: c_int = 0;
                    _ = &ofst;
                    var len: c_int = 0;
                    _ = &len;
                    var cnt: c_int = 0;
                    _ = &cnt;
                    out[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &ofst;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = '0';
                    out[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &ofst;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = 'b';
                    while (n != 0) {
                        buf[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &len;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = @bitCast(@as(i8, @truncate(@as(c_int, '0') + @as(c_int, @as(u8, @truncate(n & @as(c_ulonglong, 1)))))));
                        n >>= @intCast(1);
                    }
                    if (!(len != 0)) {
                        buf[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &len;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = '0';
                    }
                    cnt = len;
                    while (true) {
                        if ((((commas != 0) and (len != 0)) and (cnt != len)) and ((len & @as(c_int, 3)) == @as(c_int, 0))) {
                            out[
                                @bitCast(@as(isize, @intCast(blk: {
                                    const ref = &ofst;
                                    const tmp = ref.*;
                                    ref.* += 1;
                                    break :blk tmp;
                                })))
                            ] = comma_char;
                        }
                        out[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &ofst;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = buf[@bitCast(@as(isize, @intCast(len - @as(c_int, 1))))];
                        if (!((blk: {
                            const ref = &len;
                            ref.* -= 1;
                            break :blk ref.*;
                        }) != 0)) break;
                    }
                    out[@bitCast(@as(isize, @intCast(ofst)))] = 0;
                    break;
                }
            },
            else => {},
        }
        break;
    }
}
pub fn get_math_list() callconv(.c) void {
    var v: [*c]struct_var = undefined;
    _ = &v;
    var s: [*c]u8 = undefined;
    _ = &s;
    varm(math_word_list);
    math_word_list = null;
    {
        v = vars;
        while (v != null) : (v = v.*.next) {
            s = vsncpy(null, 0, v.*.name, slen(v.*.name));
            math_word_list = vaadd(math_word_list, s);
        }
    }
}
pub fn get_lcl_dp() callconv(.c) u8 {
    const static_local_lcl_dp = struct {
        var lcl_dp: u8 = 0;
    };
    _ = &static_local_lcl_dp;
    if (@as(c_int, static_local_lcl_dp.lcl_dp) == @as(c_int, 0)) {
        var buf: [32]u8 = undefined;
        _ = &buf;
        var c: [*c]u8 = @ptrCast(@alignCast(&buf));
        _ = &c;
        _ = snprintf(@ptrCast(@alignCast(&buf)), @sizeOf(@TypeOf(buf)), "%f", @as(f64, 0.5));
        while ((@as(c_int, c.*) >= @as(c_int, '0')) and (@as(c_int, c.*) <= @as(c_int, '9'))) {
            c += 1;
        }
        static_local_lcl_dp.lcl_dp = c.*;
    }
    return static_local_lcl_dp.lcl_dp;
}
pub fn get_lcl_comma() callconv(.c) u8 {
    var lcl_dp: u8 = get_lcl_dp();
    _ = &lcl_dp;
    return @bitCast(@as(i8, @truncate(if (@as(c_int, lcl_dp) == @as(c_int, ',')) @as(c_int, '.') else @as(c_int, ','))));
}
pub export var merr: [*c]const u8 = null;
pub export var mode_display: c_int = 0;
pub export var mode_ins: c_int = 0;
pub export var mode_commas: c_int = 0;
pub var calc_bw: [*c]BW = null;
pub export var vzero: f64 = 0.0;
pub fn fperr(arg_unused: c_int) callconv(.c) void {
    var unused = arg_unused;
    _ = &unused;
    if (!(merr != null)) {
        merr = my_gettext("Float point exception");
    }
    _ = joe_set_signal(SIGFPE, fperr);
}
pub export var vars: [*c]struct_var = null;
pub fn get(arg_str: [*c]const u8) callconv(.c) [*c]struct_var {
    var str = arg_str;
    _ = &str;
    var v: [*c]struct_var = undefined;
    _ = &v;
    {
        v = vars;
        while (v != null) : (v = v.*.next) {
            if (!(strcmp(v.*.name, str) != 0)) {
                return v;
            }
        }
    }
    v = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_var))))))));
    v.*.set = 0;
    v.*.func = null;
    v.*.val = @floatFromInt(@as(c_int, 0));
    v.*.next = vars;
    vars = v;
    v.*.name = zdup(str);
    return v;
}
pub export var ptr: [*c]const u8 = null;
pub export var dumb: [*c]struct_var = null;
pub fn eval(arg_s: [*c]const u8, arg_secure: c_int) callconv(.c) f64 {
    var s = arg_s;
    _ = &s;
    var secure = arg_secure;
    _ = &secure;
    var result: f64 = 0.0;
    _ = &result;
    var v: [*c]struct_var = undefined;
    _ = &v;
    if ((blk: {
        const ref = &recur;
        ref.* += 1;
        break :blk ref.*;
    }) == @as(c_int, 1000)) {
        merr = my_gettext("Recursion depth exceeded");
        recur -= 1;
        return 0.0;
    }
    ptr = s;
    while (!(merr != null) and (parse_wsl(&ptr, '#') != 0)) {
        result = expr(0, 1, &dumb, secure);
        v = get("ans");
        v.*.val = result;
        v.*.set = 1;
        if (!(merr != null)) {
            _ = parse_wsn(&ptr, '#');
            if (((@as(c_int, ptr.*) == @as(c_int, ':')) or (@as(c_int, ptr.*) == @as(c_int, '\r'))) or (@as(c_int, ptr.*) == @as(c_int, '\n'))) {
                if (@as(c_int, ptr.*) == @as(c_int, '\r')) {
                    ptr += 1;
                    if (@as(c_int, ptr.*) == @as(c_int, '\n')) {
                        ptr += 1;
                    }
                } else {
                    ptr += 1;
                }
            } else if (@as(c_int, ptr.*) != 0) {
                merr = my_gettext("Extra junk after end of expr");
            }
        }
    }
    recur -= 1;
    return result;
}
pub export var recur: c_int = 0;
pub export fn joe_strtod(arg_bptr: [*c]const u8, arg_at_eptr: [*c][*c]const u8) f64 {
    var bptr = arg_bptr;
    _ = &bptr;
    var at_eptr = arg_at_eptr;
    _ = &at_eptr;
    var inv: c_int = 0;
    _ = &inv;
    var buf: [128]u8 = undefined;
    _ = &buf;
    var n: c_ulonglong = 0;
    _ = &n;
    var x: f64 = 0.0;
    _ = &x;
    if (@as(c_int, bptr[@as(c_int, 0)]) == @as(c_int, '-')) {
        inv = 1;
        bptr += 1;
    }
    if ((@as(c_int, bptr[@as(c_int, 0)]) == @as(c_int, '0')) and ((@as(c_int, bptr[@as(c_int, 1)]) == @as(c_int, 'b')) or (@as(c_int, bptr[@as(c_int, 1)]) == @as(c_int, 'B')))) {
        bptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
        while (((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '1'))) or (@as(c_int, bptr.*) == @as(c_int, '_'))) {
            if ((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '1'))) {
                n <<= @intCast(1);
                n +%= @as(c_uint, @bitCast(@as(c_int, @as(c_int, bptr.*) - @as(c_int, '0'))));
            }
            bptr += 1;
        }
        x = @floatFromInt(n);
    } else if ((@as(c_int, bptr[@as(c_int, 0)]) == @as(c_int, '0')) and ((@as(c_int, bptr[@as(c_int, 1)]) == @as(c_int, 'o')) or (@as(c_int, bptr[@as(c_int, 1)]) == @as(c_int, 'O')))) {
        bptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
        while (((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '7'))) or (@as(c_int, bptr.*) == @as(c_int, '_'))) {
            if ((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '7'))) {
                n <<= @intCast(3);
                n +%= @as(c_uint, @bitCast(@as(c_int, @as(c_int, bptr.*) - @as(c_int, '0'))));
            }
            bptr += 1;
        }
        x = @floatFromInt(n);
    } else if ((@as(c_int, bptr[@as(c_int, 0)]) == @as(c_int, '0')) and ((@as(c_int, bptr[@as(c_int, 1)]) == @as(c_int, 'x')) or (@as(c_int, bptr[@as(c_int, 1)]) == @as(c_int, 'X')))) {
        bptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
        while (((((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '9'))) or ((@as(c_int, bptr.*) >= @as(c_int, 'a')) and (@as(c_int, bptr.*) <= @as(c_int, 'f')))) or ((@as(c_int, bptr.*) >= @as(c_int, 'A')) and (@as(c_int, bptr.*) <= @as(c_int, 'F')))) or (@as(c_int, bptr.*) == @as(c_int, '_'))) {
            if ((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '9'))) {
                n <<= @intCast(4);
                n +%= @as(c_uint, @bitCast(@as(c_int, @as(c_int, bptr.*) - @as(c_int, '0'))));
            } else if ((@as(c_int, bptr.*) >= @as(c_int, 'A')) and (@as(c_int, bptr.*) <= @as(c_int, 'F'))) {
                n <<= @intCast(4);
                n +%= @as(c_uint, @bitCast(@as(c_int, (@as(c_int, bptr.*) - @as(c_int, 'A')) + @as(c_int, 10))));
            } else if ((@as(c_int, bptr.*) >= @as(c_int, 'a')) and (@as(c_int, bptr.*) <= @as(c_int, 'f'))) {
                n <<= @intCast(4);
                n +%= @as(c_uint, @bitCast(@as(c_int, (@as(c_int, bptr.*) - @as(c_int, 'a')) + @as(c_int, 10))));
            }
            bptr += 1;
        }
        x = @floatFromInt(n);
    } else {
        var j: c_int = 0;
        _ = &j;
        while (((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '9'))) or (@as(c_int, bptr.*) == @as(c_int, '_'))) {
            if ((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '9'))) {
                buf[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &j;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = bptr.*;
            }
            bptr += 1;
        }
        if (@as(c_int, bptr.*) == @as(c_int, '.')) {
            buf[
                @bitCast(@as(isize, @intCast(blk: {
                    const ref = &j;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                })))
            ] = (blk: {
                const ref = &bptr;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).*;
            while (((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '9'))) or (@as(c_int, bptr.*) == @as(c_int, '_'))) {
                if ((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '9'))) {
                    buf[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &j;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = bptr.*;
                }
                bptr += 1;
            }
        }
        if ((@as(c_int, bptr.*) == @as(c_int, 'e')) or (@as(c_int, bptr.*) == @as(c_int, 'E'))) {
            buf[
                @bitCast(@as(isize, @intCast(blk: {
                    const ref = &j;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                })))
            ] = (blk: {
                const ref = &bptr;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).*;
            if ((@as(c_int, bptr.*) == @as(c_int, '-')) or (@as(c_int, bptr.*) == @as(c_int, '+'))) {
                buf[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &j;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = (blk: {
                    const ref = &bptr;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).*;
            }
            while (((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '9'))) or (@as(c_int, bptr.*) == @as(c_int, '_'))) {
                if ((@as(c_int, bptr.*) >= @as(c_int, '0')) and (@as(c_int, bptr.*) <= @as(c_int, '9'))) {
                    buf[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &j;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = bptr.*;
                }
                bptr += 1;
            }
        }
        buf[@bitCast(@as(isize, @intCast(j)))] = 0;
        {
            var lcl_dp: u8 = get_lcl_dp();
            _ = &lcl_dp;
            var i: c_int = undefined;
            _ = &i;
            {
                i = 0;
                while (@as(c_int, buf[@bitCast(@as(isize, @intCast(i)))]) != 0) : (i += 1) {
                    if (@as(c_int, buf[@bitCast(@as(isize, @intCast(i)))]) == @as(c_int, '.')) {
                        buf[@bitCast(@as(isize, @intCast(i)))] = lcl_dp;
                        break;
                    }
                }
            }
            x = strtod(@ptrCast(@alignCast(&buf)), null);
        }
    }
    if (inv != 0) {
        x = -x;
    }
    if (at_eptr != null) {
        at_eptr.* = bptr;
    }
    return x;
}
pub fn expr(arg_prec: c_int, arg_en: c_int, arg_rtv: [*c][*c]struct_var, arg_secure: c_int) callconv(.c) f64 {
    var prec = arg_prec;
    _ = &prec;
    var en = arg_en;
    _ = &en;
    var rtv = arg_rtv;
    _ = &rtv;
    var secure = arg_secure;
    _ = &secure;
    var x: f64 = 0.0;
    _ = &x;
    var y: f64 = undefined;
    _ = &y;
    var z: f64 = undefined;
    _ = &z;
    var v: [*c]struct_var = null;
    _ = &v;
    var ident: [256]u8 = undefined;
    _ = &ident;
    var macr: [256]u8 = undefined;
    _ = &macr;
    _ = parse_wsl(&ptr, '#');
    if (!(parse_ident(&ptr, @ptrCast(@alignCast(&ident)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(ident))))))) != 0)) {
        if (!(secure != 0) and !(strcmp(@ptrCast(@alignCast(&ident)), "joe") != 0)) {
            v = null;
            x = 0.0;
            _ = parse_wsl(&ptr, '#');
            if (@as(c_int, ptr.*) == @as(c_int, '(')) {
                var idx: ptrdiff_t = undefined;
                _ = &idx;
                var m: ?*MACRO = undefined;
                _ = &m;
                var sta: ptrdiff_t = undefined;
                _ = &sta;
                idx = 0;
                ptr += 1;
                while ((@as(c_int, ptr.*) != 0) and (@as(c_int, ptr.*) != @as(c_int, ')'))) {
                    if (idx != (@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(macr)))))) - @as(ptrdiff_t, 1))) {
                        macr[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &idx;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = ptr.*;
                    }
                    ptr += 1;
                }
                macr[@bitCast(@as(isize, @intCast(idx)))] = 0;
                if (@as(c_int, ptr.*) != @as(c_int, ')')) {
                    if (!(merr != null)) {
                        merr = my_gettext("Missing )");
                    }
                } else {
                    ptr += 1;
                }
                if (en != 0) {
                    m = mparse(null, @ptrCast(@alignCast(&macr)), &sta, 0);
                    if (m != null) {
                        x = @floatFromInt(@intFromBool(!(exmacro(m, 1, -@as(c_int, 256)) != 0)));
                        rmmacro(m);
                    } else {
                        if (!(merr != null)) {
                            merr = my_gettext("Syntax error in macro");
                        }
                    }
                }
            } else {
                if (!(merr != null)) {
                    merr = my_gettext("Missing (");
                }
            }
        } else if (!(en != 0)) {
            v = null;
            x = 0.0;
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "hex") != 0)) {
            mode_display = 2;
            v = get("ans");
            x = v.*.val;
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "oct") != 0)) {
            mode_display = 3;
            v = get("ans");
            x = v.*.val;
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "bin") != 0)) {
            mode_display = 4;
            v = get("ans");
            x = v.*.val;
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "dec") != 0)) {
            mode_display = 0;
            v = get("ans");
            x = v.*.val;
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "eng") != 0)) {
            mode_display = 1;
            v = get("ans");
            x = v.*.val;
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "ins") != 0)) {
            mode_ins = 1;
            v = get("ans");
            x = v.*.val;
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "insf") != 0)) {
            mode_ins = 1;
            mode_commas = 1;
            v = get("ans");
            x = v.*.val;
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "sum") != 0)) {
            var xsq: f64 = undefined;
            _ = &xsq;
            var cnt: c_int = blksum(calc_bw, &x, &xsq);
            _ = &cnt;
            if (!(merr != null) and (cnt <= @as(c_int, 0))) {
                merr = my_gettext("No numbers in block");
            }
            v = null;
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "cnt") != 0)) {
            var xsq: f64 = undefined;
            _ = &xsq;
            var cnt: c_int = blksum(calc_bw, &x, &xsq);
            _ = &cnt;
            if (!(merr != null) and (cnt <= @as(c_int, 0))) {
                merr = my_gettext("No numbers in block");
            }
            v = null;
            x = @floatFromInt(cnt);
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "avg") != 0)) {
            var xsq: f64 = undefined;
            _ = &xsq;
            var cnt: c_int = blksum(calc_bw, &x, &xsq);
            _ = &cnt;
            if (!(merr != null) and (cnt <= @as(c_int, 0))) {
                merr = my_gettext("No numbers in block");
            }
            v = null;
            if (cnt != 0) {
                x /= @floatFromInt(cnt);
            }
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "dev") != 0)) {
            var xsq: f64 = undefined;
            _ = &xsq;
            var cnt: c_int = blksum(calc_bw, &x, &xsq);
            _ = &cnt;
            if (!(merr != null) and (cnt <= @as(c_int, 0))) {
                merr = my_gettext("No numbers in block");
            }
            v = null;
            if (cnt != 0) {
                x = sqrt((xsq - ((x * x) / @as(f64, @floatFromInt(cnt)))) / @as(f64, @floatFromInt(cnt)));
            }
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "samp") != 0)) {
            var xsq: f64 = undefined;
            _ = &xsq;
            var cnt: c_int = blksum(calc_bw, &x, &xsq);
            _ = &cnt;
            if (!(merr != null) and (cnt <= @as(c_int, 0))) {
                merr = my_gettext("No numbers in block");
            }
            v = null;
            if (cnt != 0) {
                x = sqrt((xsq - ((x * x) / @as(f64, @floatFromInt(cnt)))) / @as(f64, @floatFromInt(cnt - @as(c_int, 1))));
            }
        } else if (!(strcmp(@ptrCast(@alignCast(&ident)), "eval") != 0)) {
            var save: [*c]const u8 = ptr;
            _ = &save;
            var e: [*c]u8 = blkget(calc_bw);
            _ = &e;
            if (e != null) {
                v = null;
                x = eval(e, secure);
                joe_free(@ptrCast(@alignCast(e)));
                ptr = save;
            } else if (!(merr != null)) {
                merr = my_gettext("No block");
            }
        } else {
            v = get(@ptrCast(@alignCast(&ident)));
            x = v.*.val;
        }
    } else if (((@as(c_int, ptr.*) >= @as(c_int, '0')) and (@as(c_int, ptr.*) <= @as(c_int, '9'))) or (@as(c_int, ptr.*) == @as(c_int, '.'))) {
        var eptr: [*c]const u8 = undefined;
        _ = &eptr;
        x = joe_strtod(ptr, &eptr);
        ptr = eptr;
    } else if (@as(c_int, ptr.*) == @as(c_int, '(')) {
        ptr += 1;
        x = expr(0, en, &v, secure);
        if (@as(c_int, ptr.*) == @as(c_int, ')')) {
            ptr += 1;
        } else {
            if (!(merr != null)) {
                merr = my_gettext("Missing )");
            }
        }
    } else if (@as(c_int, ptr.*) == @as(c_int, '-')) {
        ptr += 1;
        x = -expr(10, en, &dumb, secure);
    } else if (@as(c_int, ptr.*) == @as(c_int, '!')) {
        ptr += 1;
        x = @floatFromInt(@intFromBool(expr(10, en, &dumb, secure) == @as(f64, 0.0)));
    }
    while (true) {
        while ((@as(c_int, ptr.*) == @as(c_int, ' ')) or (@as(c_int, ptr.*) == @as(c_int, '\t'))) {
            ptr += 1;
        }
        if ((@as(c_int, ptr.*) == @as(c_int, '(')) and (@as(c_int, 11) > prec)) {
            ptr += 1;
            y = expr(0, en, &dumb, secure);
            if (@as(c_int, ptr.*) == @as(c_int, ')')) {
                ptr += 1;
            } else {
                if (!(merr != null)) {
                    merr = my_gettext("Missing )");
                }
            }
            if ((v != null) and (v.*.func != null)) {
                x = v.*.func.?(y);
            } else {
                if (!(merr != null)) {
                    merr = my_gettext("Called object is not a function");
                }
            }
            continue;
        } else if (((@as(c_int, ptr.*) == @as(c_int, '!')) and (@as(c_int, ptr[@as(c_int, 1)]) != @as(c_int, '='))) and (@as(c_int, 10) >= prec)) {
            ptr += 1;
            if (((x == @as(f64, @floatFromInt(@as(c_int, @intFromFloat(x))))) and (x >= @as(f64, 1.0))) and (x < @as(f64, 70.0))) {
                y = 1.0;
                while (x > @as(f64, 1.0)) {
                    y *= x;
                    x -= 1.0;
                }
                x = y;
            } else {
                if (!(merr != null)) {
                    merr = my_gettext("Factorial can only take positive integers");
                }
            }
            v = null;
            continue;
        } else if (((@as(c_int, ptr.*) == @as(c_int, '*')) and (@as(c_int, ptr[@as(c_int, 1)]) == @as(c_int, '*'))) and (@as(c_int, 8) > prec)) {
            ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            x = pow(x, expr(8, en, &dumb, secure));
            v = null;
            continue;
        } else if ((@as(c_int, ptr.*) == @as(c_int, '^')) and (@as(c_int, 8) > prec)) {
            ptr += 1;
            x = pow(x, expr(8, en, &dumb, secure));
            v = null;
            continue;
        } else if ((@as(c_int, ptr.*) == @as(c_int, '*')) and (@as(c_int, 7) > prec)) {
            ptr += 1;
            x *= expr(7, en, &dumb, secure);
            v = null;
            continue;
        } else if ((@as(c_int, ptr.*) == @as(c_int, '/')) and (@as(c_int, 7) > prec)) {
            ptr += 1;
            x /= expr(7, en, &dumb, secure);
            v = null;
            continue;
        } else if ((@as(c_int, ptr.*) == @as(c_int, '%')) and (@as(c_int, 7) > prec)) {
            ptr += 1;
            y = expr(7, en, &dumb, secure);
            if (@as(c_int, @intFromFloat(y)) == @as(c_int, 0)) {
                x = @as(f64, 1.0) / vzero;
            } else {
                x = @floatFromInt(@rem(@as(c_int, @intFromFloat(x)), @as(c_int, @intFromFloat(y))));
            }
            v = null;
            continue;
        } else if ((@as(c_int, ptr.*) == @as(c_int, '+')) and (@as(c_int, 6) > prec)) {
            ptr += 1;
            x += expr(6, en, &dumb, secure);
            v = null;
            continue;
        } else if ((@as(c_int, ptr.*) == @as(c_int, '-')) and (@as(c_int, 6) > prec)) {
            ptr += 1;
            x -= expr(6, en, &dumb, secure);
            v = null;
            continue;
        } else if ((@as(c_int, ptr.*) == @as(c_int, '<')) and (@as(c_int, 5) > prec)) {
            ptr += 1;
            if (@as(c_int, ptr.*) == @as(c_int, '=')) {
                ptr += 1;
                x = @floatFromInt(@intFromBool(x <= expr(5, en, &dumb, secure)));
            } else {
                x = @floatFromInt(@intFromBool(x < expr(5, en, &dumb, secure)));
            }
            v = null;
            continue;
        } else if ((@as(c_int, ptr.*) == @as(c_int, '>')) and (@as(c_int, 5) > prec)) {
            ptr += 1;
            if (@as(c_int, ptr.*) == @as(c_int, '=')) {
                ptr += 1;
                x = @floatFromInt(@intFromBool(x >= expr(5, en, &dumb, secure)));
            } else {
                x = @floatFromInt(@intFromBool(x > expr(5, en, &dumb, secure)));
            }
            v = null;
            continue;
        } else if (((@as(c_int, ptr.*) == @as(c_int, '=')) and (@as(c_int, ptr[@as(c_int, 1)]) == @as(c_int, '='))) and (@as(c_int, 5) > prec)) {
            ptr += 1;
            ptr += 1;
            x = @floatFromInt(@intFromBool(x == expr(5, en, &dumb, secure)));
            v = null;
            continue;
        } else if (((@as(c_int, ptr.*) == @as(c_int, '!')) and (@as(c_int, ptr[@as(c_int, 1)]) == @as(c_int, '='))) and (@as(c_int, 5) > prec)) {
            ptr += 1;
            ptr += 1;
            x = @floatFromInt(@intFromBool(x != expr(5, en, &dumb, secure)));
            v = null;
            continue;
        } else if (((@as(c_int, ptr.*) == @as(c_int, '&')) and (@as(c_int, ptr[@as(c_int, 1)]) == @as(c_int, '&'))) and (@as(c_int, 3) > prec)) {
            ptr += 1;
            ptr += 1;
            y = expr(3, @intFromBool((x != @as(f64, 0.0)) and (en != 0)), &dumb, secure);
            x = @floatFromInt(@intFromBool((@as(c_int, @intFromFloat(x)) != 0) and (@as(c_int, @intFromFloat(y)) != 0)));
            v = null;
            continue;
        } else if (((@as(c_int, ptr.*) == @as(c_int, '|')) and (@as(c_int, ptr[@as(c_int, 1)]) == @as(c_int, '|'))) and (@as(c_int, 3) > prec)) {
            ptr += 1;
            ptr += 1;
            y = expr(3, @intFromBool((x == @as(f64, 0.0)) and (en != 0)), &dumb, secure);
            x = @floatFromInt(@intFromBool((@as(c_int, @intFromFloat(x)) != 0) or (@as(c_int, @intFromFloat(y)) != 0)));
            v = null;
            continue;
        } else if ((@as(c_int, ptr.*) == @as(c_int, '?')) and (@as(c_int, 2) >= prec)) {
            ptr += 1;
            y = expr(2, @intFromBool((x != @as(f64, 0.0)) and (en != 0)), &dumb, secure);
            if (@as(c_int, ptr.*) == @as(c_int, ':')) {
                ptr += 1;
                z = expr(2, @intFromBool((x == @as(f64, 0.0)) and (en != 0)), &dumb, secure);
                if (x != @as(f64, 0.0)) {
                    x = y;
                } else {
                    x = z;
                }
                v = null;
            } else if (!(merr != null)) {
                merr = ": missing after ?";
            }
            continue;
        } else if ((@as(c_int, ptr.*) == @as(c_int, '=')) and (@as(c_int, 1) >= prec)) {
            ptr += 1;
            x = expr(1, en, &dumb, secure);
            if (v != null) {
                v.*.val = x;
                v.*.set = 1;
            } else {
                if (!(merr != null)) {
                    merr = my_gettext("Left side of = is not an l-value");
                }
            }
            v = null;
            continue;
        }
        break;
    }
    rtv.* = v;
    return x;
}
pub fn m_sin(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return sin(n);
}
pub fn m_cos(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return cos(n);
}
pub fn m_tan(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return tan(n);
}
pub fn m_exp(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return exp(n);
}
pub fn m_sqrt(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return sqrt(n);
}
pub fn m_cbrt(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return cbrt(n);
}
pub fn m_log(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return log(n);
}
pub fn m_log10(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return log10(n);
}
pub fn m_asin(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return asin(n);
}
pub fn m_acos(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return acos(n);
}
pub fn m_atan(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return atan(n);
}
pub fn m_sinh(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return sinh(n);
}
pub fn m_cosh(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return cosh(n);
}
pub fn m_tanh(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return tanh(n);
}
pub fn m_asinh(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return asinh(n);
}
pub fn m_acosh(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return acosh(n);
}
pub fn m_atanh(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return atanh(n);
}
pub fn m_floor(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return floor(n);
}
pub fn m_ceil(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return ceil(n);
}
pub fn m_fabs(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return fabs(n);
}
pub fn m_erf(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return erf(n);
}
pub fn m_erfc(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return erfc(n);
}
pub fn m_j0(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return j0(n);
}
pub fn m_j1(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return j1(n);
}
pub fn m_y0(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return y0(n);
}
pub fn m_y1(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return y1(n);
}
pub fn m_int(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    return @floatFromInt(@as(c_int, @intFromFloat(n)));
}
pub fn m_lr(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    var v: [*c]struct_var = undefined;
    _ = &v;
    var xsq: f64 = undefined;
    _ = &xsq;
    var xsum: f64 = undefined;
    _ = &xsum;
    var ysq: f64 = undefined;
    _ = &ysq;
    var ysum: f64 = undefined;
    _ = &ysum;
    var xy: f64 = undefined;
    _ = &xy;
    var A: f64 = undefined;
    _ = &A;
    var BB: f64 = undefined;
    _ = &BB;
    var r: f64 = undefined;
    _ = &r;
    var cov: f64 = undefined;
    _ = &cov;
    var xavg: f64 = undefined;
    _ = &xavg;
    var yavg: f64 = undefined;
    _ = &yavg;
    var cnt: c_int = blklr(calc_bw, &xsum, &xsq, &ysum, &ysq, &xy, 0, 0);
    _ = &cnt;
    if (!(merr != null) and (cnt <= @as(c_int, 0))) {
        merr = my_gettext("No numbers in block");
        return 0.0;
    }
    BB = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / ((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum));
    A = (ysum - (BB * xsum)) / @as(f64, @floatFromInt(cnt));
    r = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / sqrt(m_fabs((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum)) * m_fabs((@as(f64, @floatFromInt(cnt)) * ysq) - (ysum * ysum)));
    xavg = xsum / @as(f64, @floatFromInt(cnt));
    yavg = ysum / @as(f64, @floatFromInt(cnt));
    cov = (xy - ((@as(f64, @floatFromInt(cnt)) * xavg) * yavg)) / @as(f64, @floatFromInt(cnt - @as(c_int, 1)));
    v = get("b");
    v.*.val = A;
    v.*.set = 1;
    v = get("m");
    v.*.val = BB;
    v.*.set = 1;
    v = get("r");
    v.*.val = r;
    v.*.set = 1;
    v = get("cov");
    v.*.val = cov;
    v.*.set = 1;
    return A + (BB * n);
}
pub fn m_Lr(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    var v: [*c]struct_var = undefined;
    _ = &v;
    var xsq: f64 = undefined;
    _ = &xsq;
    var xsum: f64 = undefined;
    _ = &xsum;
    var ysq: f64 = undefined;
    _ = &ysq;
    var ysum: f64 = undefined;
    _ = &ysum;
    var xy: f64 = undefined;
    _ = &xy;
    var A: f64 = undefined;
    _ = &A;
    var BB: f64 = undefined;
    _ = &BB;
    var r: f64 = undefined;
    _ = &r;
    var cov: f64 = undefined;
    _ = &cov;
    var xavg: f64 = undefined;
    _ = &xavg;
    var yavg: f64 = undefined;
    _ = &yavg;
    var cnt: c_int = blklr(calc_bw, &xsum, &xsq, &ysum, &ysq, &xy, 1, 0);
    _ = &cnt;
    if (!(merr != null) and (cnt <= @as(c_int, 0))) {
        merr = my_gettext("No numbers in block");
        return 0.0;
    }
    BB = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / ((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum));
    A = (ysum - (BB * xsum)) / @as(f64, @floatFromInt(cnt));
    r = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / sqrt(m_fabs((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum)) * m_fabs((@as(f64, @floatFromInt(cnt)) * ysq) - (ysum * ysum)));
    xavg = xsum / @as(f64, @floatFromInt(cnt));
    yavg = ysum / @as(f64, @floatFromInt(cnt));
    cov = (xy - ((@as(f64, @floatFromInt(cnt)) * xavg) * yavg)) / @as(f64, @floatFromInt(cnt - @as(c_int, 1)));
    v = get("b");
    v.*.val = A;
    v.*.set = 1;
    v = get("m");
    v.*.val = BB;
    v.*.set = 1;
    v = get("r");
    v.*.val = r;
    v.*.set = 1;
    v = get("cov");
    v.*.val = cov;
    v.*.set = 1;
    return A + (BB * log(n));
}
pub fn m_lR(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    var v: [*c]struct_var = undefined;
    _ = &v;
    var xsq: f64 = undefined;
    _ = &xsq;
    var xsum: f64 = undefined;
    _ = &xsum;
    var ysq: f64 = undefined;
    _ = &ysq;
    var ysum: f64 = undefined;
    _ = &ysum;
    var xy: f64 = undefined;
    _ = &xy;
    var A: f64 = undefined;
    _ = &A;
    var BB: f64 = undefined;
    _ = &BB;
    var r: f64 = undefined;
    _ = &r;
    var cov: f64 = undefined;
    _ = &cov;
    var xavg: f64 = undefined;
    _ = &xavg;
    var yavg: f64 = undefined;
    _ = &yavg;
    var cnt: c_int = blklr(calc_bw, &xsum, &xsq, &ysum, &ysq, &xy, 0, 1);
    _ = &cnt;
    if (!(merr != null) and (cnt <= @as(c_int, 0))) {
        merr = my_gettext("No numbers in block");
        return 0.0;
    }
    BB = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / ((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum));
    A = (ysum - (BB * xsum)) / @as(f64, @floatFromInt(cnt));
    r = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / sqrt(m_fabs((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum)) * m_fabs((@as(f64, @floatFromInt(cnt)) * ysq) - (ysum * ysum)));
    xavg = xsum / @as(f64, @floatFromInt(cnt));
    yavg = ysum / @as(f64, @floatFromInt(cnt));
    cov = (xy - ((@as(f64, @floatFromInt(cnt)) * xavg) * yavg)) / @as(f64, @floatFromInt(cnt - @as(c_int, 1)));
    v = get("b");
    v.*.val = exp(A);
    v.*.set = 1;
    v = get("m");
    v.*.val = BB;
    v.*.set = 1;
    v = get("r");
    v.*.val = r;
    v.*.set = 1;
    v = get("cov");
    v.*.val = cov;
    v.*.set = 1;
    return exp(A + (BB * n));
}
pub fn m_LR(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    var v: [*c]struct_var = undefined;
    _ = &v;
    var xsq: f64 = undefined;
    _ = &xsq;
    var xsum: f64 = undefined;
    _ = &xsum;
    var ysq: f64 = undefined;
    _ = &ysq;
    var ysum: f64 = undefined;
    _ = &ysum;
    var xy: f64 = undefined;
    _ = &xy;
    var A: f64 = undefined;
    _ = &A;
    var BB: f64 = undefined;
    _ = &BB;
    var r: f64 = undefined;
    _ = &r;
    var cov: f64 = undefined;
    _ = &cov;
    var xavg: f64 = undefined;
    _ = &xavg;
    var yavg: f64 = undefined;
    _ = &yavg;
    var cnt: c_int = blklr(calc_bw, &xsum, &xsq, &ysum, &ysq, &xy, 1, 1);
    _ = &cnt;
    if (!(merr != null) and (cnt <= @as(c_int, 0))) {
        merr = my_gettext("No numbers in block");
        return 0.0;
    }
    BB = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / ((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum));
    A = (ysum - (BB * xsum)) / @as(f64, @floatFromInt(cnt));
    r = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / sqrt(m_fabs((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum)) * m_fabs((@as(f64, @floatFromInt(cnt)) * ysq) - (ysum * ysum)));
    xavg = xsum / @as(f64, @floatFromInt(cnt));
    yavg = ysum / @as(f64, @floatFromInt(cnt));
    cov = (xy - ((@as(f64, @floatFromInt(cnt)) * xavg) * yavg)) / @as(f64, @floatFromInt(cnt - @as(c_int, 1)));
    v = get("b");
    v.*.val = exp(A);
    v.*.set = 1;
    v = get("m");
    v.*.val = BB;
    v.*.set = 1;
    v = get("r");
    v.*.val = r;
    v.*.set = 1;
    v = get("cov");
    v.*.val = cov;
    v.*.set = 1;
    return exp(A + (BB * log(n)));
}
pub fn m_rlr(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    var v: [*c]struct_var = undefined;
    _ = &v;
    var xsq: f64 = undefined;
    _ = &xsq;
    var xsum: f64 = undefined;
    _ = &xsum;
    var ysq: f64 = undefined;
    _ = &ysq;
    var ysum: f64 = undefined;
    _ = &ysum;
    var xy: f64 = undefined;
    _ = &xy;
    var A: f64 = undefined;
    _ = &A;
    var BB: f64 = undefined;
    _ = &BB;
    var r: f64 = undefined;
    _ = &r;
    var cov: f64 = undefined;
    _ = &cov;
    var xavg: f64 = undefined;
    _ = &xavg;
    var yavg: f64 = undefined;
    _ = &yavg;
    var cnt: c_int = blklr(calc_bw, &xsum, &xsq, &ysum, &ysq, &xy, 0, 0);
    _ = &cnt;
    if (!(merr != null) and (cnt <= @as(c_int, 0))) {
        merr = my_gettext("No numbers in block");
        return 0.0;
    }
    BB = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / ((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum));
    A = (ysum - (BB * xsum)) / @as(f64, @floatFromInt(cnt));
    r = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / sqrt(m_fabs((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum)) * m_fabs((@as(f64, @floatFromInt(cnt)) * ysq) - (ysum * ysum)));
    xavg = xsum / @as(f64, @floatFromInt(cnt));
    yavg = ysum / @as(f64, @floatFromInt(cnt));
    cov = (xy - ((@as(f64, @floatFromInt(cnt)) * xavg) * yavg)) / @as(f64, @floatFromInt(cnt - @as(c_int, 1)));
    v = get("b");
    v.*.val = A;
    v.*.set = 1;
    v = get("m");
    v.*.val = BB;
    v.*.set = 1;
    v = get("r");
    v.*.val = r;
    v.*.set = 1;
    v = get("cov");
    v.*.val = cov;
    v.*.set = 1;
    return (n - A) / BB;
}
pub fn m_rLr(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    var v: [*c]struct_var = undefined;
    _ = &v;
    var xsq: f64 = undefined;
    _ = &xsq;
    var xsum: f64 = undefined;
    _ = &xsum;
    var ysq: f64 = undefined;
    _ = &ysq;
    var ysum: f64 = undefined;
    _ = &ysum;
    var xy: f64 = undefined;
    _ = &xy;
    var A: f64 = undefined;
    _ = &A;
    var BB: f64 = undefined;
    _ = &BB;
    var r: f64 = undefined;
    _ = &r;
    var cov: f64 = undefined;
    _ = &cov;
    var xavg: f64 = undefined;
    _ = &xavg;
    var yavg: f64 = undefined;
    _ = &yavg;
    var cnt: c_int = blklr(calc_bw, &xsum, &xsq, &ysum, &ysq, &xy, 1, 0);
    _ = &cnt;
    if (!(merr != null) and (cnt <= @as(c_int, 0))) {
        merr = my_gettext("No numbers in block");
        return 0.0;
    }
    BB = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / ((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum));
    A = (ysum - (BB * xsum)) / @as(f64, @floatFromInt(cnt));
    r = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / sqrt(m_fabs((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum)) * m_fabs((@as(f64, @floatFromInt(cnt)) * ysq) - (ysum * ysum)));
    xavg = xsum / @as(f64, @floatFromInt(cnt));
    yavg = ysum / @as(f64, @floatFromInt(cnt));
    cov = (xy - ((@as(f64, @floatFromInt(cnt)) * xavg) * yavg)) / @as(f64, @floatFromInt(cnt - @as(c_int, 1)));
    v = get("b");
    v.*.val = A;
    v.*.set = 1;
    v = get("m");
    v.*.val = BB;
    v.*.set = 1;
    v = get("r");
    v.*.val = r;
    v.*.set = 1;
    v = get("cov");
    v.*.val = cov;
    v.*.set = 1;
    return exp((n - A) / BB);
}
pub fn m_rlR(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    var v: [*c]struct_var = undefined;
    _ = &v;
    var xsq: f64 = undefined;
    _ = &xsq;
    var xsum: f64 = undefined;
    _ = &xsum;
    var ysq: f64 = undefined;
    _ = &ysq;
    var ysum: f64 = undefined;
    _ = &ysum;
    var xy: f64 = undefined;
    _ = &xy;
    var A: f64 = undefined;
    _ = &A;
    var BB: f64 = undefined;
    _ = &BB;
    var r: f64 = undefined;
    _ = &r;
    var cov: f64 = undefined;
    _ = &cov;
    var xavg: f64 = undefined;
    _ = &xavg;
    var yavg: f64 = undefined;
    _ = &yavg;
    var cnt: c_int = blklr(calc_bw, &xsum, &xsq, &ysum, &ysq, &xy, 0, 1);
    _ = &cnt;
    if (!(merr != null) and (cnt <= @as(c_int, 0))) {
        merr = my_gettext("No numbers in block");
        return 0.0;
    }
    BB = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / ((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum));
    A = (ysum - (BB * xsum)) / @as(f64, @floatFromInt(cnt));
    r = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / sqrt(m_fabs((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum)) * m_fabs((@as(f64, @floatFromInt(cnt)) * ysq) - (ysum * ysum)));
    xavg = xsum / @as(f64, @floatFromInt(cnt));
    yavg = ysum / @as(f64, @floatFromInt(cnt));
    cov = (xy - ((@as(f64, @floatFromInt(cnt)) * xavg) * yavg)) / @as(f64, @floatFromInt(cnt - @as(c_int, 1)));
    v = get("b");
    v.*.val = exp(A);
    v.*.set = 1;
    v = get("m");
    v.*.val = BB;
    v.*.set = 1;
    v = get("r");
    v.*.val = r;
    v.*.set = 1;
    v = get("cov");
    v.*.val = cov;
    v.*.set = 1;
    return (log(n) - A) / BB;
}
pub fn m_rLR(arg_n: f64) callconv(.c) f64 {
    var n = arg_n;
    _ = &n;
    var v: [*c]struct_var = undefined;
    _ = &v;
    var xsq: f64 = undefined;
    _ = &xsq;
    var xsum: f64 = undefined;
    _ = &xsum;
    var ysq: f64 = undefined;
    _ = &ysq;
    var ysum: f64 = undefined;
    _ = &ysum;
    var xy: f64 = undefined;
    _ = &xy;
    var A: f64 = undefined;
    _ = &A;
    var BB: f64 = undefined;
    _ = &BB;
    var r: f64 = undefined;
    _ = &r;
    var cov: f64 = undefined;
    _ = &cov;
    var xavg: f64 = undefined;
    _ = &xavg;
    var yavg: f64 = undefined;
    _ = &yavg;
    var cnt: c_int = blklr(calc_bw, &xsum, &xsq, &ysum, &ysq, &xy, 1, 1);
    _ = &cnt;
    if (!(merr != null) and (cnt <= @as(c_int, 0))) {
        merr = my_gettext("No numbers in block");
        return 0.0;
    }
    BB = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / ((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum));
    A = (ysum - (BB * xsum)) / @as(f64, @floatFromInt(cnt));
    r = ((@as(f64, @floatFromInt(cnt)) * xy) - (xsum * ysum)) / sqrt(m_fabs((@as(f64, @floatFromInt(cnt)) * xsq) - (xsum * xsum)) * m_fabs((@as(f64, @floatFromInt(cnt)) * ysq) - (ysum * ysum)));
    xavg = xsum / @as(f64, @floatFromInt(cnt));
    yavg = ysum / @as(f64, @floatFromInt(cnt));
    cov = (xy - ((@as(f64, @floatFromInt(cnt)) * xavg) * yavg)) / @as(f64, @floatFromInt(cnt - @as(c_int, 1)));
    v = get("b");
    v.*.val = exp(A);
    v.*.set = 1;
    v = get("m");
    v.*.val = BB;
    v.*.set = 1;
    v = get("r");
    v.*.val = r;
    v.*.set = 1;
    v = get("cov");
    v.*.val = cov;
    v.*.set = 1;
    return exp((log(n) - A) / BB);
}
pub export fn calc(arg_bw_1: [*c]BW, arg_s: [*c]u8, arg_secure: c_int) f64 {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var s = arg_s;
    _ = &s;
    var secure = arg_secure;
    _ = &secure;
    calc_bw = bw_1;
    setup_vars(calc_bw);
    merr = null;
    return eval(s, secure);
}
pub fn insert_commas(arg_dst: [*c]u8, arg_src: [*c]u8, arg_commas: c_int) callconv(.c) void {
    var dst = arg_dst;
    _ = &dst;
    var src = arg_src;
    _ = &src;
    var commas = arg_commas;
    _ = &commas;
    var dp_char: u8 = get_lcl_dp();
    _ = &dp_char;
    var comma_char: u8 = get_lcl_comma();
    _ = &comma_char;
    var leading: c_int = undefined;
    _ = &leading;
    var trailing: c_int = undefined;
    _ = &trailing;
    var n: c_int = undefined;
    _ = &n;
    var s: [*c]u8 = undefined;
    _ = &s;
    if (!(commas != 0)) {
        while (@as(c_int, src.*) != 0) {
            if (@as(c_int, src.*) == @as(c_int, dp_char)) {
                dst.* = '.';
            } else {
                dst.* = src.*;
            }
            dst += 1;
            src += 1;
        }
        dst.* = 0;
        return;
    }
    s = src;
    leading = 0;
    trailing = 0;
    if (@as(c_int, s.*) == @as(c_int, '-')) {
        s += 1;
    } else if (@as(c_int, s.*) == @as(c_int, '+')) {
        s += 1;
    }
    while ((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
        s += 1;
        leading += 1;
    }
    if (@as(c_int, s.*) == @as(c_int, dp_char)) {
        s += 1;
        while ((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
            s += 1;
            trailing += 1;
        }
    }
    s = src;
    n = 0;
    if (@as(c_int, s.*) == @as(c_int, '-')) {
        (blk: {
            const ref = &dst;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).* = (blk: {
            const ref = &s;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).*;
    } else if (@as(c_int, s.*) == @as(c_int, '+')) {
        (blk: {
            const ref = &dst;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).* = (blk: {
            const ref = &s;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).*;
    }
    while ((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
        (blk: {
            const ref = &dst;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).* = (blk: {
            const ref = &s;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).*;
        leading -= 1;
        if ((leading != @as(c_int, 0)) and (@rem(leading, @as(c_int, 3)) == @as(c_int, 0))) {
            (blk: {
                const ref = &dst;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).* = comma_char;
        }
    }
    if (@as(c_int, s.*) == @as(c_int, dp_char)) {
        (blk: {
            const ref = &dst;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).* = (blk: {
            const ref = &s;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).*;
        while ((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
            (blk: {
                const ref = &dst;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).* = (blk: {
                const ref = &s;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).*;
            n += 1;
            if ((n != trailing) and (@rem(n, @as(c_int, 3)) == @as(c_int, 0))) {
                (blk: {
                    const ref = &dst;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).* = comma_char;
            }
        }
    }
    while (@as(c_int, s.*) != 0) {
        (blk: {
            const ref = &dst;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).* = (blk: {
            const ref = &s;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).*;
    }
    dst.* = 0;
}
pub fn eng(arg_d: [*c]u8, arg_d_len: ptrdiff_t, arg_s: [*c]const u8) callconv(.c) [*c]u8 {
    var d = arg_d;
    _ = &d;
    var d_len = arg_d_len;
    _ = &d_len;
    var s = arg_s;
    _ = &s;
    var dp_char: u8 = get_lcl_dp();
    _ = &dp_char;
    var s_org: [*c]const u8 = s;
    _ = &s_org;
    var d_org: [*c]u8 = d;
    _ = &d_org;
    var a: [128]u8 = undefined;
    _ = &a;
    var a_len: c_int = undefined;
    _ = &a_len;
    var sign: c_int = undefined;
    _ = &sign;
    var dp: c_int = undefined;
    _ = &dp;
    var myexp: c_int = undefined;
    _ = &myexp;
    var exp_sign: c_int = undefined;
    _ = &exp_sign;
    var x: c_int = 0;
    _ = &x;
    var flg: c_int = 0;
    _ = &flg;
    d_len -= 1;
    if (@as(c_int, s.*) == @as(c_int, '-')) {
        sign = 1;
        s += 1;
    } else if (@as(c_int, s.*) == @as(c_int, '+')) {
        sign = 0;
        s += 1;
    } else {
        sign = 0;
    }
    while (@as(c_int, s.*) == @as(c_int, '0')) {
        flg = 1;
        s += 1;
    }
    a_len = 0;
    while ((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
        a[
            @bitCast(@as(isize, @intCast(blk: {
                const ref = &a_len;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            })))
        ] = (blk: {
            const ref = &s;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).*;
        flg = 1;
    }
    dp = 0;
    if (@as(c_int, s.*) == @as(c_int, dp_char)) {
        flg = 1;
        s += 1;
        if (!(a_len != 0)) {
            while (@as(c_int, s.*) == @as(c_int, '0')) {
                s += 1;
                dp += 1;
            }
        }
        if ((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
            while ((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
                a[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &a_len;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = (blk: {
                    const ref = &s;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).*;
                dp += 1;
            }
        } else {
            dp = 0;
        }
    }
    while ((a_len != 0) and (@as(c_int, a[@bitCast(@as(isize, @intCast(a_len - @as(c_int, 1))))]) == @as(c_int, '0'))) {
        a_len -= 1;
        dp -= 1;
    }
    if ((@as(c_int, s.*) == @as(c_int, 'e')) or (@as(c_int, s.*) == @as(c_int, 'E'))) {
        s += 1;
        if (@as(c_int, s.*) == @as(c_int, '-')) {
            s += 1;
            exp_sign = 1;
        } else if (@as(c_int, s.*) == @as(c_int, '+')) {
            s += 1;
            exp_sign = 0;
        } else {
            exp_sign = 0;
        }
        myexp = 0;
        while ((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
            myexp = ((myexp * @as(c_int, 10)) + @as(c_int, (blk: {
                const ref = &s;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).*)) - @as(c_int, '0');
        }
    } else {
        myexp = 0;
        exp_sign = 0;
    }
    if (!(flg != 0)) {
        _ = zlcpy(d, d_len, s_org);
        return d;
    }
    if (exp_sign != 0) {
        myexp = -myexp;
    }
    myexp -= dp;
    a[@bitCast(@as(isize, @intCast(a_len)))] = 0;
    if (myexp < @as(c_int, 0)) {
        while (true) {
            switch (@rem(-myexp, @as(c_int, 3))) {
                @as(c_int, 0) => {
                    x = 0;
                    break;
                },
                @as(c_int, 1) => {
                    x = 2;
                    break;
                },
                @as(c_int, 2) => {
                    x = 1;
                    break;
                },
                else => {},
            }
            break;
        }
    } else {
        x = @rem(myexp, @as(c_int, 3));
    }
    myexp -= x;
    while ((blk: {
        const ref = &x;
        const tmp = ref.*;
        ref.* -= 1;
        break :blk tmp;
    }) != 0) {
        a[
            @bitCast(@as(isize, @intCast(blk: {
                const ref = &a_len;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            })))
        ] = '0';
    }
    if (!(a_len != 0)) {
        a[
            @bitCast(@as(isize, @intCast(blk: {
                const ref = &a_len;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            })))
        ] = '0';
    }
    dp = @divTrunc(a_len - @as(c_int, 1), @as(c_int, 3));
    dp *= 3;
    myexp += dp;
    if ((@as(ptrdiff_t, sign) != 0) and (d_len != 0)) {
        (blk: {
            const ref = &d;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).* = '-';
        d_len -= 1;
    }
    {
        x = 0;
        while (x != (a_len - dp)) : (x += 1) {
            if (d_len != 0) {
                (blk: {
                    const ref = &d;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).* = a[@bitCast(@as(isize, @intCast(x)))];
                d_len -= 1;
            }
        }
    }
    if (dp != 0) {
        if (d_len != 0) {
            (blk: {
                const ref = &d;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).* = dp_char;
            d_len -= 1;
        }
        {
            x = a_len - dp;
            while (x != a_len) : (x += 1) {
                if (d_len != 0) {
                    (blk: {
                        const ref = &d;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    }).* = a[@bitCast(@as(isize, @intCast(x)))];
                    d_len -= 1;
                }
            }
        }
        while ((d != d_org) and (@as(c_int, d[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))]) == @as(c_int, '0'))) {
            d -= 1;
            d_len += 1;
        }
    }
    if (myexp != 0) {
        _ = snprintf(d, @as(usize, @bitCast(@as(c_long, d_len + @as(ptrdiff_t, 1)))), "e%+d", myexp);
    } else {
        d.* = 0;
    }
    return d_org;
}
pub export var mathhist: [*c]B = null;
pub var math_word_list: [*c][*c]u8 = null;
pub export fn math_cmplt(arg_bw_1: [*c]BW, arg_k: c_int) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    setup_vars(bw_1);
    get_math_list();
    if (!(math_word_list != null)) {
        while (true) {
            obuf[
                @bitCast(@as(isize, @intCast(blk: {
                    const ref = &obufp;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                })))
            ] = @bitCast(@as(i8, @truncate(@as(c_int, 7))));
            if (obufp == obufsiz) {
                ttflsh();
            }
            if (!false) break;
        }
        return 0;
    }
    return word_cmplt(bw_1, math_word_list);
}
pub export fn umath(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    _ = joe_set_signal(SIGFPE, fperr);
    if (wmkpw(w, "=", &mathhist, doumath, "Math", null, math_cmplt, null, null, utf8_map, 0) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
pub export fn usmath(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    _ = joe_set_signal(SIGFPE, fperr);
    if (wmkpw(w, "=", &mathhist, dosmath, "Math", null, math_cmplt, null, null, utf8_map, 0) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
