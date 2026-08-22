//! Prompt windows — replaces `joe/pw.c`.
//!
//! Faithful C-ABI port of JOE prompt-window + history/completion logic. Generated from goto-free pw.c via `zig translate-c`, then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;

// stdbuf must match the real definition (gapbuffer/intern.zig); size comes from
// gap_types.stdsiz so the extern view can never silently disagree again.
const gap_types = @import("gapbuffer/types.zig");

pub const TYPETW: c_int = 0x0100;
pub const TYPEPW: c_int = 0x0200;
pub const TYPEMENU: c_int = 0x0800;
pub const TYPEQW: c_int = 0x1000;
pub const PWFLAG_FILENAME: c_int = 1;
pub const PWFLAG_UPDATE_CD: c_int = 2;
pub const PWFLAG_SEED_CD: c_int = 4;
pub const PWFLAG_COMMAND: c_int = 8;
pub const CANFLAG_NORESTART: c_int = 1;
pub const NO_MORE_DATA: c_int = -256;

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
pub fn disppw(arg_w: [*c]W, arg_flg: c_int) callconv(.c) void {
    var w = arg_w;
    _ = &w;
    var flg = arg_flg;
    _ = &flg;
    var bw_1: [*c]BW = @ptrCast(@alignCast(w.*.object));
    _ = &bw_1;
    var pw_2: [*c]PW = @ptrCast(@alignCast(bw_1.*.object));
    _ = &pw_2;
    if (!(flg != 0)) {
        return;
    }
    if (pw_2.*.promptlen > (w.*.w - @as(ptrdiff_t, 5))) {
        pw_2.*.promptofst = pw_2.*.promptlen - @divTrunc(w.*.w, @as(ptrdiff_t, 2));
        if (piscol(bw_1.*.cursor) < @as(off_t, w.*.w - (pw_2.*.promptlen - pw_2.*.promptofst))) {
            bw_1.*.offset = 0;
        } else {
            bw_1.*.offset = piscol(bw_1.*.cursor) - @as(off_t, (w.*.w - (pw_2.*.promptlen - pw_2.*.promptofst)) - @as(ptrdiff_t, 1));
        }
    } else {
        if (piscol(bw_1.*.cursor) < @as(off_t, w.*.w - pw_2.*.promptlen)) {
            pw_2.*.promptofst = 0;
            bw_1.*.offset = 0;
        } else if (piscol(bw_1.*.cursor) >= @as(off_t, w.*.w)) {
            pw_2.*.promptofst = pw_2.*.promptlen;
            bw_1.*.offset = piscol(bw_1.*.cursor) - @as(off_t, w.*.w - @as(ptrdiff_t, 1));
        } else {
            pw_2.*.promptofst = pw_2.*.promptlen - @as(ptrdiff_t, @truncate((@as(off_t, w.*.w) - piscol(bw_1.*.cursor)) - @as(off_t, 1)));
            bw_1.*.offset = piscol(bw_1.*.cursor) - @as(off_t, (w.*.w - (pw_2.*.promptlen - pw_2.*.promptofst)) - @as(ptrdiff_t, 1));
        }
    }
    w.*.curx = @as(ptrdiff_t, @truncate(((piscol(bw_1.*.cursor) - bw_1.*.offset) + @as(off_t, pw_2.*.promptlen)) - @as(off_t, pw_2.*.promptofst)));
    w.*.cury = 0;
    w.*.t.*.t.*.updtab[@bitCast(@as(isize, @intCast(w.*.y)))] = 1;
    genfmt(w.*.t.*.t, w.*.x, w.*.y, pw_2.*.promptofst, pw_2.*.prompt, bg_prompt, 0, 0);
    bwmove(bw_1, (w.*.x + pw_2.*.promptlen) - pw_2.*.promptofst, w.*.y);
    bwresz(bw_1, w.*.w - (pw_2.*.promptlen - pw_2.*.promptofst), 1);
    bwgen(bw_1, 0, 0);
}
pub fn rtnpw(arg_w: [*c]W) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var bw_1: [*c]BW = @ptrCast(@alignCast(w.*.object));
    _ = &bw_1;
    var pw_2: [*c]PW = @ptrCast(@alignCast(bw_1.*.object));
    _ = &pw_2;
    var s: [*c]u8 = undefined;
    _ = &s;
    var win: [*c]W = undefined;
    _ = &win;
    var notify: [*c]c_int = undefined;
    _ = &notify;
    var pfunc: ?*const fn (w: [*c]W, s: [*c]u8, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int = undefined;
    _ = &pfunc;
    var object: ?*anyopaque = undefined;
    _ = &object;
    var byte: off_t = undefined;
    _ = &byte;
    p_goto_eol(bw_1.*.cursor);
    byte = bw_1.*.cursor.*.byte;
    p_goto_bol(bw_1.*.cursor);
    s = brvs(bw_1.*.cursor, byte - bw_1.*.cursor.*.byte);
    if ((pw_2.*.file_prompt & PWFLAG_FILENAME) != 0) {
        s = canonical(s, 0);
    } else if ((pw_2.*.file_prompt & PWFLAG_COMMAND) != 0) {
        s = canonical(s, CANFLAG_NORESTART);
    }
    if (pw_2.*.hist != null) {
        if (bw_1.*.b.*.changed != 0) {
            append_history(pw_2.*.hist, s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        } else {
            promote_history(pw_2.*.hist, bw_1.*.cursor.*.line);
        }
    }
    if ((pw_2.*.file_prompt & PWFLAG_UPDATE_CD) != 0) {
        set_current_dir(bw_1, s, 1);
    }
    win = w.*.win;
    pfunc = pw_2.*.pfunc;
    object = pw_2.*.object;
    bwrm(bw_1);
    joe_free(@ptrCast(@alignCast(pw_2.*.prompt)));
    joe_free(@ptrCast(@alignCast(pw_2)));
    w.*.object = null;
    notify = w.*.notify;
    w.*.notify = null;
    _ = wabort(w);
    dostaupd = 1;
    if (pfunc != null) {
        return pfunc.?(win, s, object, notify);
    } else {
        return -@as(c_int, 1);
    }
}
pub fn inspw(arg_w: [*c]W, arg_b_1: [*c]B, arg_l: off_t, arg_n: off_t, arg_flg: c_int) callconv(.c) void {
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
pub fn delpw(arg_w: [*c]W, arg_b_1: [*c]B, arg_l: off_t, arg_n: off_t, arg_flg: c_int) callconv(.c) void {
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
pub fn abortpw(arg_w: [*c]W) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var bw_1: [*c]BW = @ptrCast(@alignCast(w.*.object));
    _ = &bw_1;
    var pw_2: [*c]PW = @ptrCast(@alignCast(bw_1.*.object));
    _ = &pw_2;
    var object: ?*anyopaque = pw_2.*.object;
    _ = &object;
    var abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int = pw_2.*.abrt;
    _ = &abrt;
    var win: [*c]W = bw_1.*.parent.*.win;
    _ = &win;
    bwrm(bw_1);
    joe_free(@ptrCast(@alignCast(pw_2.*.prompt)));
    joe_free(@ptrCast(@alignCast(pw_2)));
    if (abrt != null) {
        return abrt.?(win, object);
    } else {
        return -@as(c_int, 1);
    }
}
pub fn p_goto_bow(arg_ptr: [*c]P) callconv(.c) void {
    var ptr = arg_ptr;
    _ = &ptr;
    var map: [*c]struct_charmap = ptr.*.b.*.o.charmap;
    _ = &map;
    var c: c_int = undefined;
    _ = &c;
    while (map.*.is_alnum_.?(map, blk: {
        const tmp = prgetc(ptr);
        c = tmp;
        break :blk tmp;
    }) != 0) {}
    if (c != -@as(c_int, 256)) {
        _ = pgetc(ptr);
    }
}
pub fn p_goto_eow(arg_ptr: [*c]P) callconv(.c) void {
    var ptr = arg_ptr;
    _ = &ptr;
    var map: [*c]struct_charmap = ptr.*.b.*.o.charmap;
    _ = &map;
    while (map.*.is_alnum_.?(map, brch(ptr)) != 0) {
        _ = pgetc(ptr);
    }
}
pub fn word_ins(arg_bw_1: [*c]BW, arg_line: [*c]u8) callconv(.c) void {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var line = arg_line;
    _ = &line;
    var p_2: [*c]P = pdup(bw_1.*.cursor, "cmplt_ins");
    _ = &p_2;
    p_goto_bow(p_2);
    p_goto_eow(bw_1.*.cursor);
    bdel(p_2, bw_1.*.cursor);
    binsm(bw_1.*.cursor, line, if (line != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(line))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    p_goto_eol(bw_1.*.cursor);
    prm(p_2);
    bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
}
pub fn word_rtn(arg_m: [*c]MENU, arg_x: ptrdiff_t, arg_object: ?*anyopaque, arg_k: c_int) callconv(.c) c_int {
    var m = arg_m;
    _ = &m;
    var x = arg_x;
    _ = &x;
    var object = arg_object;
    _ = &object;
    var k = arg_k;
    _ = &k;
    var line: [*c]u8 = @ptrCast(@alignCast(object));
    _ = &line;
    word_ins(@ptrCast(@alignCast(m.*.parent.*.win.*.object)), m.*.list[@bitCast(@as(isize, @intCast(x)))]);
    vsrm(line);
    m.*.object = null;
    _ = wabort(m.*.parent);
    return 0;
}
pub export var bg_prompt: c_int = 0;
pub export var nocurdir: c_int = 0;
pub export fn get_cd(arg_w: [*c]W) [*c]u8 {
    var w = arg_w;
    _ = &w;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    w = w.*.main;
    bw_1 = @ptrCast(@alignCast(w.*.object));
    return bw_1.*.b.*.current_dir;
}
pub export fn set_current_dir(arg_bw_1: [*c]BW, arg_s: [*c]u8, arg_simp: c_int) void {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var s = arg_s;
    _ = &s;
    var simp = arg_simp;
    _ = &simp;
    var w: [*c]W = bw_1.*.parent.*.main;
    _ = &w;
    var b_2: [*c]B = undefined;
    _ = &b_2;
    bw_1 = @ptrCast(@alignCast(w.*.object));
    b_2 = bw_1.*.b;
    if ((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, '!')) or ((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, '>')) and (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, '>')))) return;
    vsrm(b_2.*.current_dir);
    if (s != null) {
        b_2.*.current_dir = dirprt(s);
        if (simp != 0) {
            var tmp: [*c]u8 = simplify_prefix(b_2.*.current_dir);
            _ = &tmp;
            vsrm(b_2.*.current_dir);
            b_2.*.current_dir = tmp;
        }
    } else {
        b_2.*.current_dir = null;
    }
}
pub export fn setup_history(arg_history: [*c][*c]B) void {
    var history = arg_history;
    _ = &history;
    if (!(history.* != null)) {
        history.* = bmk(null);
    }
}
pub export fn append_history(arg_hist: [*c]B, arg_s: [*c]u8, arg_len: ptrdiff_t) void {
    var hist = arg_hist;
    _ = &hist;
    var s = arg_s;
    _ = &s;
    var len = arg_len;
    _ = &len;
    var q: [*c]P = pdup(hist.*.eof, "append_history");
    _ = &q;
    binsm(q, s, len);
    p_goto_eof(q);
    binsc(q, '\n');
    prm(q);
}
pub export fn promote_history(arg_hist: [*c]B, arg_line: off_t) void {
    var hist = arg_hist;
    _ = &hist;
    var line = arg_line;
    _ = &line;
    var q: [*c]P = pdup(hist.*.bof, "promote_history");
    _ = &q;
    var r: [*c]P = undefined;
    _ = &r;
    var t: [*c]P = undefined;
    _ = &t;
    _ = pline(q, line);
    r = pdup(q, "promote_history");
    _ = pnextl(r);
    t = pdup(hist.*.eof, "promote_history");
    binsb(t, bcpy(q, r));
    bdel(q, r);
    prm(q);
    prm(r);
    prm(t);
}
pub export fn ucmplt(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var pw_2: [*c]PW = undefined;
    _ = &pw_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    pw_2 = @ptrCast(@alignCast(bw_1.*.object));
    if (pw_2.*.tab != null) {
        return pw_2.*.tab.?(bw_1, k);
    } else {
        return -@as(c_int, 1);
    }
}
pub export var watompw: WATOM = WATOM{
    .context = "prompt",
    .disp = disppw,
    .follow = bwfllwt,
    .abort = abortpw,
    .rtn = rtnpw,
    .type = utypew,
    .resize = null,
    .move = null,
    .ins = inspw,
    .del = delpw,
    .what = TYPEPW,
};
pub export fn wmkpw(arg_w: [*c]W, arg_prompt: [*c]const u8, arg_history: [*c][*c]B, arg_func: ?*const fn (w: [*c]W, s: [*c]u8, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, arg_huh: [*c]const u8, arg_abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, arg_tab: ?*const fn (bw: [*c]BW, k: c_int) callconv(.c) c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int, arg_map: [*c]struct_charmap, arg_file_prompt: c_int) [*c]BW {
    var w = arg_w;
    _ = &w;
    var prompt = arg_prompt;
    _ = &prompt;
    var history = arg_history;
    _ = &history;
    var func = arg_func;
    _ = &func;
    var huh = arg_huh;
    _ = &huh;
    var abrt = arg_abrt;
    _ = &abrt;
    var tab = arg_tab;
    _ = &tab;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var map = arg_map;
    _ = &map;
    var file_prompt = arg_file_prompt;
    _ = &file_prompt;
    var neww: [*c]W = undefined;
    _ = &neww;
    var pw_1: [*c]PW = undefined;
    _ = &pw_1;
    var bw_2: [*c]BW = undefined;
    _ = &bw_2;
    neww = wcreate(w.*.t, &watompw, w, w, w.*.main, 1, huh, notify);
    if (!(neww != null)) {
        if (notify != null) {
            notify.* = 1;
        }
        return null;
    }
    w.*.t.*.curwin = neww;
    wfit(neww.*.t);
    neww.*.object = @ptrCast(@alignCast(blk: {
        const tmp = bwmk(neww, bmk(null), 1);
        bw_2 = tmp;
        break :blk tmp;
    }));
    bw_2.*.b.*.o.charmap = map;
    bw_2.*.object = @ptrCast(@alignCast(blk: {
        const tmp = @as([*c]PW, @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(PW)))))))));
        pw_1 = tmp;
        break :blk tmp;
    }));
    pw_1.*.abrt = abrt;
    pw_1.*.tab = tab;
    pw_1.*.object = object;
    pw_1.*.prompt = zdup(prompt);
    pw_1.*.promptlen = fmtlen(prompt);
    pw_1.*.promptofst = 0;
    pw_1.*.pfunc = func;
    pw_1.*.file_prompt = file_prompt;
    if ((pw_1.*.file_prompt & PWFLAG_FILENAME) != 0) {
        bw_2.*.b.*.o.syntax = load_syntax("filename");
        bw_2.*.b.*.o.highlight = 1;
        bw_2.*.o.syntax = bw_2.*.b.*.o.syntax;
        bw_2.*.o.highlight = bw_2.*.b.*.o.highlight;
    }
    if (history != null) {
        setup_history(history);
        pw_1.*.hist = history.*;
        binsb(bw_2.*.cursor, bcpy(pw_1.*.hist.*.bof, pw_1.*.hist.*.eof));
        bw_2.*.b.*.changed = 0;
        p_goto_eof(bw_2.*.cursor);
        p_goto_eof(bw_2.*.top);
        p_goto_bol(bw_2.*.top);
    } else {
        pw_1.*.hist = null;
    }
    if (((file_prompt & PWFLAG_SEED_CD) != 0) and !(nocurdir != 0)) {
        var curd: [*c]u8 = get_cd(w);
        _ = &curd;
        binsmq(bw_2.*.cursor, curd, if (curd != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(curd))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        p_goto_eof(bw_2.*.cursor);
        bw_2.*.cursor.*.xcol = piscol(bw_2.*.cursor);
    }
    return bw_2;
}
pub export fn regsub(arg_z: [*c][*c]u8, arg_len: ptrdiff_t, arg_s: [*c]u8) [*c][*c]u8 {
    var z = arg_z;
    _ = &z;
    var len = arg_len;
    _ = &len;
    var s = arg_s;
    _ = &s;
    var lst: [*c][*c]u8 = null;
    _ = &lst;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (@as(ptrdiff_t, x) != len) : (x += 1) if (rmatch(s, z[@bitCast(@as(isize, @intCast(x)))]) != 0) {
            lst = vaadd(lst, vsncpy(null, 0, z[@bitCast(@as(isize, @intCast(x)))], slen(z[@bitCast(@as(isize, @intCast(x)))])));
        };
    }
    return lst;
}
pub export fn cmplt_ins(arg_bw_1: [*c]BW, arg_line: [*c]u8) void {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var line = arg_line;
    _ = &line;
    var p_2: [*c]P = pdup(bw_1.*.cursor, "cmplt_ins");
    _ = &p_2;
    p_goto_bol(p_2);
    p_goto_eol(bw_1.*.cursor);
    bdel(p_2, bw_1.*.cursor);
    binsm(bw_1.*.cursor, line, if (line != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(line))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    p_goto_eol(bw_1.*.cursor);
    prm(p_2);
    bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
}
pub export fn cmplt_abrt(arg_w: [*c]W, arg_x: ptrdiff_t, arg_object: ?*anyopaque) c_int {
    var w = arg_w;
    _ = &w;
    var x = arg_x;
    _ = &x;
    var object = arg_object;
    _ = &object;
    var line: [*c]u8 = @ptrCast(@alignCast(object));
    _ = &line;
    if (line != null) {
        vsrm(line);
    }
    return -@as(c_int, 1);
}
pub export fn cmplt_rtn(arg_m: [*c]MENU, arg_x: ptrdiff_t, arg_object: ?*anyopaque, arg_k: c_int) c_int {
    var m = arg_m;
    _ = &m;
    var x = arg_x;
    _ = &x;
    var object = arg_object;
    _ = &object;
    var k = arg_k;
    _ = &k;
    var line: [*c]u8 = @ptrCast(@alignCast(object));
    _ = &line;
    cmplt_ins(@ptrCast(@alignCast(m.*.parent.*.win.*.object)), m.*.list[@bitCast(@as(isize, @intCast(x)))]);
    vsrm(line);
    m.*.object = null;
    _ = wabort(m.*.parent);
    return 0;
}
pub export fn simple_cmplt(arg_bw_1: [*c]BW, arg_list: [*c][*c]u8) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var list = arg_list;
    _ = &list;
    var m: [*c]MENU = undefined;
    _ = &m;
    var p_2: [*c]P = undefined;
    _ = &p_2;
    var q: [*c]P = undefined;
    _ = &q;
    var line: [*c]u8 = undefined;
    _ = &line;
    var line1: [*c]u8 = undefined;
    _ = &line1;
    var lst: [*c][*c]u8 = undefined;
    _ = &lst;
    p_2 = pdup(bw_1.*.cursor, "simple_cmplt");
    p_goto_bol(p_2);
    q = pdup(bw_1.*.cursor, "simple_cmplt");
    p_goto_eol(q);
    line = brvs(p_2, q.*.byte - p_2.*.byte);
    prm(p_2);
    prm(q);
    line1 = vsncpy(null, 0, line, if (line != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(line))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    line1 = vsadd(line1, '*');
    lst = regsub(list, if (list != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(list))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), line1);
    vsrm(line1);
    if (!(lst != null)) {
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
        vsrm(line);
        return -@as(c_int, 1);
    }
    if (menu_above != 0) {
        if (bw_1.*.parent.*.link.prev.*.watom == (&watommenu)) {
            _ = wabort(bw_1.*.parent.*.link.prev);
        }
    } else {
        if (bw_1.*.parent.*.link.next.*.watom == (&watommenu)) {
            _ = wabort(bw_1.*.parent.*.link.next);
        }
    }
    m = mkmenu(if (menu_above != 0) bw_1.*.parent.*.link.prev else bw_1.*.parent, bw_1.*.parent, lst, cmplt_rtn, cmplt_abrt, null, 0, @ptrCast(@alignCast(line)), null);
    if (!(m != null)) {
        varm(lst);
        vsrm(line);
        return -@as(c_int, 1);
    }
    if ((if (lst != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(lst))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) == @as(ptrdiff_t, 1)) return cmplt_rtn(m, 0, @ptrCast(@alignCast(line)), 0) else if ((smode != 0) or (isreg(line) != 0)) {
        if (!(menu_jump != 0)) {
            bw_1.*.parent.*.t.*.curwin = bw_1.*.parent;
        }
        return 0;
    } else {
        var com: [*c]u8 = mcomplete(m);
        _ = &com;
        vsrm(@ptrCast(@alignCast(m.*.object)));
        m.*.object = @ptrCast(@alignCast(com));
        cmplt_ins(bw_1, com);
        _ = wabort(m.*.parent);
        smode = 2;
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
    return undefined;
}
pub export fn simple_file_cmplt(arg_bw_1: [*c]BW, arg_list: [*c][*c]u8) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var list = arg_list;
    _ = &list;
    var c: c_int = undefined;
    _ = &c;
    var p_2: [*c]P = pdup(bw_1.*.cursor, "simple_file_cmplt");
    _ = &p_2;
    p_goto_bol(p_2);
    c = brc(p_2);
    prm(p_2);
    if ((c == @as(c_int, '/')) or (c == @as(c_int, '~'))) return cmplt_file(bw_1, '\t') else return simple_cmplt(bw_1, list);
}
pub export fn word_cmplt(arg_bw_1: [*c]BW, arg_list: [*c][*c]u8) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var list = arg_list;
    _ = &list;
    var m: [*c]MENU = undefined;
    _ = &m;
    var p_2: [*c]P = undefined;
    _ = &p_2;
    var q: [*c]P = undefined;
    _ = &q;
    var line: [*c]u8 = undefined;
    _ = &line;
    var line1: [*c]u8 = undefined;
    _ = &line1;
    var lst: [*c][*c]u8 = undefined;
    _ = &lst;
    p_2 = pdup(bw_1.*.cursor, "word_cmplt");
    p_goto_bow(p_2);
    q = pdup(bw_1.*.cursor, "word_cmplt");
    p_goto_eow(q);
    line = brvs(p_2, q.*.byte - p_2.*.byte);
    prm(p_2);
    prm(q);
    line1 = vsncpy(null, 0, line, if (line != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(line))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    line1 = vsadd(line1, '*');
    lst = regsub(list, if (list != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(list))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), line1);
    vsrm(line1);
    if (!(lst != null)) {
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
        vsrm(line);
        return -@as(c_int, 1);
    }
    if (menu_above != 0) {
        if (bw_1.*.parent.*.link.prev.*.watom == (&watommenu)) {
            _ = wabort(bw_1.*.parent.*.link.prev);
        }
    } else {
        if (bw_1.*.parent.*.link.next.*.watom == (&watommenu)) {
            _ = wabort(bw_1.*.parent.*.link.next);
        }
    }
    m = mkmenu(if (menu_above != 0) bw_1.*.parent.*.link.prev else bw_1.*.parent, bw_1.*.parent, lst, word_rtn, cmplt_abrt, null, 0, @ptrCast(@alignCast(line)), null);
    if (!(m != null)) {
        varm(lst);
        vsrm(line);
        return -@as(c_int, 1);
    }
    if ((if (lst != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(lst))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) == @as(ptrdiff_t, 1)) return word_rtn(m, 0, @ptrCast(@alignCast(line)), 0) else if ((smode != 0) or (isreg(line) != 0)) {
        if (!(menu_jump != 0)) {
            bw_1.*.parent.*.t.*.curwin = bw_1.*.parent;
        }
        return 0;
    } else {
        var com: [*c]u8 = mcomplete(m);
        _ = &com;
        vsrm(@ptrCast(@alignCast(m.*.object)));
        m.*.object = @ptrCast(@alignCast(com));
        word_ins(bw_1, com);
        _ = wabort(m.*.parent);
        smode = 2;
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
    return undefined;
}
