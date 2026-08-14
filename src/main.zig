//! Editor startup and edit loop — replaces `joe/main.c`.
//!
//! Faithful C-ABI Path A port of JOE main (maint/edupd/edloop/nungetc/timer_play/ushowlog + entry + startup globals).

const std = @import("std");
const ptrdiff_t = c_long;

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;
const JOE_MSGBUFSIZE: c_int = 300;
const SHELL_TYPE_RAW: c_int = 2;
const NO_MORE_DATA: c_int = -256;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn fprintf(f: ?*anyopaque, fmt: [*c]const u8, ...) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn malloc(n: c_ulong) ?*anyopaque;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub extern fn strstr(h: [*c]const u8, n: [*c]const u8) [*c]u8;
pub extern fn strcpy(d: [*c]u8, s: [*c]const u8) [*c]u8;
pub const off_t = i64;
pub const time_t = i64;
pub const ino_t = u64;
pub const mode_t = c_uint;
pub const FILE = anyopaque;
// Darwin exposes stdin/stdout/stderr as __stdinp/__stdoutp/__stderrp.
pub extern var __stdinp: ?*FILE;
pub extern var __stderrp: ?*FILE;
pub extern fn fileno(f: ?*FILE) c_int;
pub extern fn isatty(fd: c_int) c_int;
pub extern fn fclose(f: ?*FILE) c_int;
pub extern fn freopen(path: [*c]const u8, mode: [*c]const u8, stream: ?*FILE) ?*FILE;
pub extern fn atexit(func: ?*const fn () callconv(.c) void) c_int;
pub extern fn time(t: [*c]time_t) time_t;
pub const struct_timespec_joe = extern struct {
    tv_sec: time_t = 0,
    tv_nsec: c_long = 0,
};
pub const struct_stat = extern struct {
    st_dev: c_uint = 0,
    st_mode: c_ushort = 0,
    st_nlink: c_ushort = 0,
    st_ino: ino_t = 0,
    st_uid: c_uint = 0,
    st_gid: c_uint = 0,
    st_rdev: c_uint = 0,
    _pad_rdev: c_uint = 0,
    st_atimespec: struct_timespec_joe = std.mem.zeroes(struct_timespec_joe),
    st_mtimespec: struct_timespec_joe = std.mem.zeroes(struct_timespec_joe),
    st_ctimespec: struct_timespec_joe = std.mem.zeroes(struct_timespec_joe),
    st_birthtimespec: struct_timespec_joe = std.mem.zeroes(struct_timespec_joe),
    st_size: i64 = 0,
    st_blocks: i64 = 0,
    st_blksize: c_int = 0,
    st_flags: c_uint = 0,
    st_gen: c_uint = 0,
    st_lspare: c_int = 0,
    st_qspare: [2]i64 = std.mem.zeroes([2]i64),
};
pub extern fn stat(path: [*c]const u8, buf: [*c]struct_stat) c_int;
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
const struct_unnamed_3 = extern struct {
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
pub const struct_kmap = opaque {
};
pub const KMAP = struct_kmap;
pub const struct_kbd = extern struct {
    curmap: ?*KMAP = null,
    topmap: ?*KMAP = null,
    seq: [16]c_int = std.mem.zeroes([16]c_int),
    x: ptrdiff_t = 0,
};
pub const KBD = struct_kbd;
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
pub const struct_bstack = opaque {};
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
pub const W = struct_window;
pub const struct_cmd = extern struct {
    name: [*c]const u8 = null,
    flag: c_int = 0,
    func: ?*const fn (w: [*c]W, k: c_int) callconv(.c) c_int = null,
    m: [*c]MACRO = null,
    arg: c_int = 0,
    negarg: [*c]const u8 = null,
};
pub const CMD = struct_cmd;
pub const struct_macro = extern struct {
    what: ptrdiff_t = 0,
    k: c_int = 0,
    flg: c_int = 0,
    cmd: [*c]const CMD = null,
    n: ptrdiff_t = 0,
    size: ptrdiff_t = 0,
    steps: [*c][*c]MACRO = null,
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
pub const vt_idle: c_int = 0;
pub const vt_esc: c_int = 1;
pub const vt_args: c_int = 2;
pub const vt_cmd: c_int = 3;
pub const vt_utf: c_int = 4;
pub const vt_osc: c_int = 5;
pub const vt_osce: c_int = 6;
pub const enum_vt_state = c_uint;
pub const struct_utf8_sm = extern struct {
    buf: [8]u8 = std.mem.zeroes([8]u8),
    ptr: ptrdiff_t = 0,
    state: c_int = 0,
    accu: c_int = 0,
};
pub const struct_vt_context = extern struct {
    state: enum_vt_state = std.mem.zeroes(enum_vt_state),
    buf: [1024]u8 = std.mem.zeroes([1024]u8),
    bufx: ptrdiff_t = 0,
    argv: [3]ptrdiff_t = std.mem.zeroes([3]ptrdiff_t),
    argc: ptrdiff_t = 0,
    top: [*c]P = null,
    height: ptrdiff_t = 0,
    width: ptrdiff_t = 0,
    regn_top: ptrdiff_t = 0,
    regn_bot: ptrdiff_t = 0,
    vtcur: [*c]P = null,
    b: [*c]B = null,
    kbd: [*c]KBD = null,
    attr: c_int = 0,
    utf8_sm: struct_utf8_sm = std.mem.zeroes(struct_utf8_sm),
};
pub const VT = struct_vt_context;
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
    vt: [*c]VT = null,
    raw: c_int = 0,
    _pad_raw: [4]u8 = std.mem.zeroes([4]u8),
    db: ?*anyopaque = null,
    parseone: ?*const fn (map: [*c]struct_charmap, s: [*c]const u8, rtn_name: [*c][*c]u8, rtn_line: [*c]off_t) callconv(.c) void = null,
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
pub const struct_cap = opaque {
};
pub const CAP = struct_cap;
pub const struct_jfile = opaque {};
pub const JFILE = struct_jfile;
pub const struct_vfile = opaque {
};
pub const VFILE = struct_vfile;
pub const struct_base = extern struct {
    parent: [*c]W = null,
};
pub const BASE = struct_base;
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn zlcpy(a: [*c]u8, siz: ptrdiff_t, b: [*c]const u8) [*c]u8;
pub extern fn ztoi(s: [*c]const u8) c_long;
pub extern fn ztoo(s: [*c]const u8) off_t;
pub extern fn vsncpy(s: [*c]u8, len: ptrdiff_t, blk: [*c]const u8, blklen: ptrdiff_t) [*c]u8;
pub extern fn vstrunc(s: [*c]u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsrm(s: [*c]u8) void;
pub extern fn namprt(path: [*c]const u8) [*c]u8;
pub extern fn joesep(path: [*c]u8) [*c]u8;
pub extern fn xdg_config_dir() [*c]const u8;
pub extern fn jfopen(name: [*c]const u8, mode: [*c]const u8) ?*JFILE;
pub extern fn procrc(cap: ?*CAP, f: ?*JFILE, name: [*c]u8) c_int;
pub extern fn validate_rc() c_int;
pub extern fn cmd_help(@"type": c_int) void;
pub extern fn glopt(s: [*c]u8, arg: [*c]u8, options: [*c]OPTIONS, set: c_int) c_int;
pub extern fn my_getcap(name: [*c]u8, baud: c_long, out: ?*const fn (outptr: ?*anyopaque, c: u8) callconv(.c) void, outptr: ?*anyopaque) ?*CAP;
pub extern fn nopen(cap: ?*CAP) [*c]SCRN;
pub extern fn nclose(t: [*c]SCRN) void;
pub extern fn nresize(t: [*c]SCRN, w: ptrdiff_t, h: ptrdiff_t) c_int;
pub extern fn nscroll(t: [*c]SCRN, atr: c_int) void;
pub extern fn cpos(t: [*c]SCRN, x: ptrdiff_t, y: ptrdiff_t) c_int;
pub extern fn zig_scrn_swap_flush(t: [*c]SCRN, x: ptrdiff_t, y: ptrdiff_t) void;
pub extern fn screate(scrn: [*c]SCRN) [*c]Screen;
pub extern fn sresize(t: [*c]Screen) void;
pub extern fn lastw(t: [*c]Screen) [*c]W;
pub extern fn wnext(t: [*c]Screen) c_int;
pub extern fn wshowall(t: [*c]Screen) void;
pub extern fn wredraw(w: [*c]W) void;
pub extern fn msgout(w: [*c]W) void;
pub extern fn msgclr(w: [*c]W) void;
pub extern fn msgnw(w: [*c]W, s: [*c]const u8) void;
pub extern fn msgnwt(w: [*c]W, s: [*c]const u8) void;
pub extern fn wmktw(t: [*c]Screen, b: [*c]B) [*c]BW;
pub extern fn bwmk(window: [*c]W, b: [*c]B, prompt: c_int) [*c]BW;
pub extern fn bwrm(bw: [*c]BW) void;
pub extern fn uduptw(w: [*c]W, k: c_int) c_int;
pub extern fn get_file_pos(name: [*c]const u8) off_t;
pub extern fn init_visiblews() void;
pub extern fn viewmode_cleanup() void;
pub extern fn bfind(s: [*c]const u8) [*c]B;
pub extern fn bfind_scratch(s: [*c]const u8) [*c]B;
pub extern fn bcpy(from: [*c]P, to: [*c]P) [*c]B;
pub extern fn brmall() void;
pub extern fn bsavefd(p: [*c]P, fd: c_int, size: off_t) c_int;
pub extern fn binss(p: [*c]P, s: [*c]const u8) void;
pub extern fn pdup(p: [*c]P, where: [*c]const u8) [*c]P;
pub extern fn prm(p: [*c]P) void;
pub extern fn pline(p: [*c]P, line: off_t) [*c]P;
pub extern fn p_goto_bol(p: [*c]P) void;
pub extern fn piseof(p: [*c]P) c_int;
pub extern fn lazy_opts(b: [*c]B, o: [*c]OPTIONS) void;
pub extern fn modify_logic(bw: [*c]BW, b: [*c]B) c_int;
pub extern fn cstart(bw: [*c]BW, name: [*c]const u8, s: [*c][*c]u8, obj: ?*anyopaque, notify: [*c]c_int, build: c_int, out_only: c_int, first_command: [*c]const u8, @"type": c_int) c_int;
pub extern fn setup_history(history: [*c][*c]B) void;
pub extern fn append_history(hist: [*c]B, s: [*c]u8, len: ptrdiff_t) void;
pub extern fn mparse(m: [*c]MACRO, buf: [*c]const u8, sta: [*c]ptrdiff_t, secure: c_int) [*c]MACRO;
pub extern fn dokey(kbd: [*c]KBD, n: c_int) [*c]MACRO;
pub extern fn exemac(m: [*c]MACRO, k: c_int) c_int;
pub extern fn exemac_pasting(state: c_int) void;
pub extern fn exmacro(m: [*c]MACRO, u: c_int, k: c_int) c_int;
pub extern fn chmac() void;
pub extern fn mkkbd(kmap: ?*KMAP) [*c]KBD;
pub extern fn kmap_getcontext(name: [*c]const u8) ?*KMAP;
pub extern fn help_on(t: [*c]Screen) c_int;
pub extern fn help_display(t: [*c]Screen) void;
pub extern fn init_colors() c_int;
pub extern fn load_state() void;
pub extern fn save_state() void;
pub extern fn joe_iswinit() void;
pub extern fn joe_locale() void;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn stagen(stalin: [*c]u8, bw: [*c]BW, s: [*c]const u8, fill: c_int) [*c]u8;
pub extern fn ttflsh() c_int;
pub extern fn ttgetch() c_int;
pub extern fn ttcheck() c_int;
pub extern fn ttgtsz(x: [*c]ptrdiff_t, y: [*c]ptrdiff_t) void;
pub extern fn vtmp() ?*VFILE;
pub extern fn vclose(v: ?*VFILE) void;
pub extern fn uquote(w: [*c]W, k: c_int) c_int;
pub extern fn utype(w: [*c]W, k: c_int) c_int;
pub extern fn urtn(w: [*c]W, k: c_int) c_int;
pub extern var staupd: c_int;
pub extern var have: c_int;
pub extern var havec: u8;
pub extern var leave: c_int;
pub extern var idleout: c_int;
pub extern var notite: c_int;
pub extern var noxon: c_int;
pub extern var Baud: c_int;
pub extern var dopadding: c_int;
pub extern var joeterm: [*c]u8;
pub extern var env_lines: c_int;
pub extern var env_columns: c_int;
pub extern var bg_text: c_int;
pub extern var zig_screen_swap_enabled: c_int;
pub extern var orphan: c_int;
pub extern var opt_mid: c_int;
pub extern var berror: c_int;
pub extern var filehist: [*c]B;
pub extern var msgbuf: [300]u8;
pub const msgs: [*c]const [*c]const u8 = @extern([*c]const [*c]const u8, .{
    .name = "msgs",
});
pub extern var locale_map: [*c]struct_charmap;
pub extern var locale_msgs: [*c]const u8;
pub extern var vmem: ?*VFILE;
pub export var exmsg: [*c]u8 = null;
pub export var xmsg: [*c]u8 = null;
pub export var usexmouse: c_int = 0;
pub export var xmouse: c_int = 0;
pub export var nonotice: c_int = 0;
pub export var noexmsg: c_int = 0;
pub export var pastehack: c_int = 0;
pub export var helpon: c_int = 0;
pub export var maint: [*c]Screen = null;
pub export var dostaupd: c_int = 1;
pub export fn dofollows() void {
    var w: [*c]W = maint.*.curwin;
    while (true) {
        if ((w.*.y != -1) and (w.*.h != 0) and (w.*.watom.*.follow != null) and (w.*.object != null)) {
            w.*.watom.*.follow.?(w);
        }
        w = w.*.link.next;
        if (w == maint.*.curwin) break;
    }
}
pub export fn edupd(arg_flg: c_int) void {
    const flg = arg_flg;
    var w: [*c]W = undefined;
    var wid: ptrdiff_t = undefined;
    var hei: ptrdiff_t = undefined;
    if (dostaupd != 0) {
        staupd = 1;
        dostaupd = 0;
    }
    ttgtsz(&wid, &hei);
    if (nresize(maint.*.t, wid, hei) != 0) {
        sresize(maint);
    }
    dofollows();
    _ = ttflsh();
    nscroll(maint.*.t, bg_text);
    help_display(maint);
    w = maint.*.curwin;
    while (true) {
        if (w.*.y != @as(ptrdiff_t, -@as(c_int, 1))) {
            if ((w.*.object != null) and (w.*.watom.*.disp != null)) {
                w.*.watom.*.disp.?(w, flg);
            }
            msgout(w);
        }
        w = w.*.link.next;
        if (!(w != maint.*.curwin)) break;
    }
    if (zig_screen_swap_enabled != 0) {
        zig_scrn_swap_flush(maint.*.t, maint.*.curwin.*.x + maint.*.curwin.*.curx, maint.*.curwin.*.y + maint.*.curwin.*.cury);
    } else {
        _ = cpos(maint.*.t, maint.*.curwin.*.x + maint.*.curwin.*.curx, maint.*.curwin.*.y + maint.*.curwin.*.cury);
    }
    staupd = 0;
}
pub var ahead: c_int = 0;
pub var ungot: c_int = 0;
pub var ungotc: c_int = 0;
pub export fn nungetc(arg_c: c_int) void {
    var c = arg_c;
    _ = &c;
    if ((c != (@as(c_int, 'C') - @as(c_int, '@'))) and (c != (@as(c_int, 'M') - @as(c_int, '@')))) {
        chmac();
        ungot = 1;
        ungotc = c;
    }
}
pub export fn edloop(arg_flg: c_int) c_int {
    var flg = arg_flg;
    _ = &flg;
    var term: c_int = 0;
    _ = &term;
    var ret: c_int = 0;
    _ = &ret;
    if (flg != 0) {
        if (maint.*.curwin.*.watom.*.what == TYPETW) return 0 else {
            maint.*.curwin.*.notify = &term;
        }
    }
    while (!(leave != 0) and (!(flg != 0) or !(term != 0))) {
        var w: [*c]W = undefined;
        _ = &w;
        var m: [*c]MACRO = undefined;
        _ = &m;
        var bw_1: [*c]BW = undefined;
        _ = &bw_1;
        var c: c_int = undefined;
        _ = &c;
        var auto_off: c_int = 0;
        _ = &auto_off;
        var word_off: c_int = 0;
        _ = &word_off;
        var spaces_off: c_int = 0;
        _ = &spaces_off;
        if ((exmsg != null) and !(flg != 0)) {
            vsrm(exmsg);
            exmsg = null;
        }
        edupd(1);
        if (!(ahead != 0) and !(have != 0)) {
            ahead = 1;
        }
        if (ungot != 0) {
            c = ungotc;
            ungot = 0;
        } else {
            c = ttgetch();
        }
        w = maint.*.curwin;
        while (true) {
            if (w.*.y != @as(ptrdiff_t, -@as(c_int, 1))) {
                msgclr(w);
            }
            w = w.*.link.next;
            if (!(w != maint.*.curwin)) break;
        }
        while (true) {
            if ((maint.*.curwin.*.watom.*.what & (TYPETW | TYPEPW)) != 0) {
                bw_1 = @ptrCast(@alignCast(maint.*.curwin.*.object));
            } else {
                bw_1 = null;
            }
            if ((c == @as(c_int, 10)) and (!(ahead != 0) or ((bw_1 != null) and (bw_1.*.pasting != 0)))) {
                c = 13;
            }
            if ((((((shell_kbd != null) and ((maint.*.curwin.*.watom.*.what & TYPETW) != 0)) and (bw_1.*.b.*.pid != 0)) and !(bw_1.*.b.*.vt != null)) and !(bw_1.*.b.*.raw != 0)) and (piseof(bw_1.*.cursor) != 0)) {
                m = dokey(shell_kbd, c);
            } else if (((((maint.*.curwin.*.watom.*.what & TYPETW) != 0) and (bw_1.*.b.*.pid != 0)) and (bw_1.*.b.*.vt != null)) and (bw_1.*.cursor.*.byte == bw_1.*.b.*.vt.*.vtcur.*.byte)) {
                m = dokey(bw_1.*.b.*.vt.*.kbd, c);
            } else {
                m = dokey(maint.*.curwin.*.kbd, c);
            }
            if (((((pastehack != 0) and (m != null)) and (m.*.cmd != null)) and (m.*.cmd.*.func == uquote)) and (ttcheck() != 0)) {
                m = type_backtick;
            }
            if (((((((pastehack != 0) and (m != null)) and (m.*.cmd != null)) and ((m.*.cmd.*.func == utype) or (m.*.cmd.*.func == urtn))) and ((maint.*.curwin.*.watom.*.what & TYPETW) != 0)) and (((bw_1.*.o.autoindent != 0) or (bw_1.*.o.wordwrap != 0)) or (bw_1.*.o.spaces != 0))) and (ttcheck() != 0)) {
                auto_off = bw_1.*.o.autoindent;
                bw_1.*.o.autoindent = 0;
                word_off = bw_1.*.o.wordwrap;
                bw_1.*.o.wordwrap = 0;
                spaces_off = bw_1.*.o.spaces;
                bw_1.*.o.spaces = 0;
            }
            if ((bw_1 != null) and (bw_1.*.pasting != 0)) {
                exemac_pasting(1);
            }
            if ((maint.*.curwin.*.main != null) and (maint.*.curwin.*.main != maint.*.curwin)) {
                // Keep kbd prefix in sync with the main window (C main.c).
                // Index via [*]c_int: Zig Debug `[16]c_int` field indexing here
                // corrupted TW BW state and aborted in zig_bw_bwfllwt on menu tests.
                const x: ptrdiff_t = maint.*.curwin.*.kbd.*.x;
                maint.*.curwin.*.main.*.kbd.*.x = x;
                if (x != 0) {
                    const from: [*]c_int = @ptrCast(&maint.*.curwin.*.kbd.*.seq);
                    const to: [*]c_int = @ptrCast(&maint.*.curwin.*.main.*.kbd.*.seq);
                    to[@intCast(x - 1)] = from[@intCast(x - 1)];
                }
            }
            if (!(m != null)) {
                m = timer_play();
                c = -@as(c_int, 256);
            }
            if (m != null) {
                ret = exemac(m, c);
            }
            while (((((((pastehack != 0) and !(leave != 0)) and (!(flg != 0) or !(term != 0))) and (m != null)) and ((m == type_backtick) or ((m.*.cmd != null) and ((m.*.cmd.*.func == utype) or (m.*.cmd.*.func == urtn))))) and (ttcheck() != 0)) and (@as(c_int, havec) == @as(c_int, '`'))) {
                _ = ttgetch();
                ret = exemac(type_backtick, -@as(c_int, 256));
            }
            if (!(leave != 0) and ((maint.*.curwin.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) {
                bw_1 = @ptrCast(@alignCast(maint.*.curwin.*.object));
            } else {
                bw_1 = null;
            }
            if ((bw_1 != null) and !(bw_1.*.pasting != 0)) {
                exemac_pasting(0);
            }
            if ((((((pastehack != 0) and !(leave != 0)) and (!(flg != 0) or !(term != 0))) and (m != null)) and ((m == type_backtick) or ((m.*.cmd != null) and ((m.*.cmd.*.func == utype) or (m.*.cmd.*.func == urtn))))) and (ttcheck() != 0)) {
                if (ungot != 0) {
                    c = ungotc;
                    ungot = 0;
                } else {
                    c = ttgetch();
                }
                continue;
            }
            if (!(leave != 0) and ((maint.*.curwin.*.watom.*.what & TYPETW) != 0)) {
                bw_1 = @ptrCast(@alignCast(maint.*.curwin.*.object));
                if (auto_off != 0) {
                    auto_off = 0;
                    bw_1.*.o.autoindent = 1;
                }
                if (word_off != 0) {
                    word_off = 0;
                    bw_1.*.o.wordwrap = 1;
                }
                if (spaces_off != 0) {
                    spaces_off = 0;
                    bw_1.*.o.spaces = 1;
                }
            }
            break;
        }
    }
    if (term == -@as(c_int, 1)) return -@as(c_int, 1) else return ret;
}

pub export var type_backtick: [*c]MACRO = null;
pub export var last_timer_time: time_t = 0;
pub export var cur_time: time_t = 0;
pub export var timer_macro_delay: time_t = 0;
pub export var timer_macro: [*c]MACRO = null;
pub export fn timer_play() [*c]MACRO {
    cur_time = time(null);
    if (((timer_macro != null) and (timer_macro_delay != 0)) and (cur_time >= (last_timer_time + timer_macro_delay))) {
        last_timer_time = cur_time;
        return timer_macro;
    }
    return null;
}
pub export var shell_kbd: [*c]KBD = null;
pub export var mainenv: [*c]const [*c]const u8 = null;
pub export var startup_log: [*c]B = null;
pub var logerrors: c_int = 0;
pub export var i_msg: [128]u8 = std.mem.zeroes([128]u8);
pub export fn internal_msg(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var t: [*c]P = pdup(startup_log.*.eof, "internal_msg");
    _ = &t;
    binss(t, s);
    prm(t);
}
pub export fn setlogerrs() void {
    logerrors = 1;
}
pub export fn ushowlog(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (startup_log != null) {
        var copied: [*c]B = undefined;
        _ = &copied;
        var newbw: [*c]BW = undefined;
        _ = &newbw;
        var object: ?*anyopaque = undefined;
        _ = &object;
        if (uduptw(w, k) != 0) {
            return -@as(c_int, 1);
        }
        copied = bcpy(startup_log.*.bof, startup_log.*.eof);
        copied.*.name = zdup("* Startup Log *");
        copied.*.internal = 1;
        newbw = @ptrCast(@alignCast(maint.*.curwin.*.object));
        object = newbw.*.object;
        w = newbw.*.parent;
        bwrm(newbw);
        w.*.object = @ptrCast(@alignCast(blk: {
            const tmp = bwmk(w, copied, 0);
            newbw = tmp;
            break :blk tmp;
        }));
        wredraw(newbw.*.parent);
        newbw.*.object = object;
        return 0;
    }
    return 1;
}
pub fn exit_with_errors() callconv(.c) c_int {
    if ((startup_log != null) and (startup_log.*.eof.*.byte != 0)) {
        _ = bsavefd(startup_log.*.bof, 2, startup_log.*.eof.*.byte);
    }
    return 1;
}
pub export fn main(arg_argc: c_int, arg_real_argv: [*c][*c]u8, arg_envv: [*c]const [*c]const u8) c_int {
    var argc = arg_argc;
    _ = &argc;
    var real_argv = arg_real_argv;
    _ = &real_argv;
    var envv = arg_envv;
    _ = &envv;
    var home: [*c]const u8 = getenv("HOME");
    _ = &home;
    var xdg: [*c]const u8 = xdg_config_dir();
    _ = &xdg;
    var f: ?*JFILE = undefined;
    _ = &f;
    var cap_1: ?*CAP = undefined;
    _ = &cap_1;
    var argv: [*c][*c]u8 = real_argv;
    _ = &argv;
    var sbuf: struct_stat = undefined;
    _ = &sbuf;
    var s: [*c]u8 = undefined;
    _ = &s;
    var t: [*c]u8 = undefined;
    _ = &t;
    var time_rc: time_t = undefined;
    _ = &time_rc;
    var run: [*c]u8 = undefined;
    _ = &run;
    var n: [*c]SCRN = undefined;
    _ = &n;
    var opened: c_int = 0;
    _ = &opened;
    var omid: c_int = undefined;
    _ = &omid;
    var backopt: c_int = undefined;
    _ = &backopt;
    var c: c_int = undefined;
    _ = &c;
    var filesonly: c_int = undefined;
    _ = &filesonly;
    var rc_done: c_int = undefined;
    _ = &rc_done;
    joe_iswinit();
    joe_locale();
    _ = atexit(viewmode_cleanup);
    mainenv = envv;
    vmem = vtmp();
    startup_log = bfind_scratch("* Startup Log *");
    startup_log.*.internal = 1;
    startup_log.*.current_dir = vsncpy(null, 0, null, 0);
    run = namprt(argv[@as(c_int, 0)]);
    if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = getenv("LINES");
        s = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        env_lines = @truncate(ztoi(s));
    }
    if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = getenv("COLUMNS");
        s = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        env_columns = @truncate(ztoi(s));
    }
    if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = getenv("BAUD");
        s = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        Baud = @truncate(ztoi(s));
    }
    if (getenv("DOPADDING") != null) {
        dopadding = 1;
    }
    if (getenv("NOXON") != null) {
        noxon = 1;
    }
    if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = getenv("JOETERM");
        s = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        joeterm = s;
    }
    if (!((blk: {
        const tmp = my_getcap(null, 9600, null, null);
        cap_1 = tmp;
        break :blk tmp;
    }) != null)) {
        _ = zlcpy(@ptrCast(@alignCast(&i_msg)), @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(i_msg))))), my_gettext("Couldn't load termcap/terminfo entry\n"));
        internal_msg(@ptrCast(@alignCast(&i_msg)));
        setlogerrs();
        return exit_with_errors();
    }
    rc_done = 0;
    while (true) {
        t = null;
        s = null;
        t = vsncpy(null, 0, "", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("".*)) -% @as(c_ulong, 1))))));
        t = vsncpy(t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), run, if (run != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(run))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        t = vsncpy(t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "rc.", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("rc.".*)) -% @as(c_ulong, 1))))));
        t = vsncpy(t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), locale_msgs, slen(locale_msgs));
        if (!(stat(t, &sbuf) != 0)) {
            time_rc = sbuf.st_mtimespec.tv_sec;
        } else {
            var need_nope: c_int = 0;
            _ = &need_nope;
            if (((@as(c_int, locale_msgs[@as(c_int, 0)]) != 0) and (@as(c_int, locale_msgs[@as(c_int, 1)]) != 0)) and (@as(c_int, locale_msgs[@as(c_int, 2)]) == @as(c_int, '_'))) {
                vsrm(t);
                t = vsncpy(null, 0, "", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("".*)) -% @as(c_ulong, 1))))));
                t = vsncpy(t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), run, if (run != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(run))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
                t = vsncpy(t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "rc.", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("rc.".*)) -% @as(c_ulong, 1))))));
                t = vsncpy(t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), locale_msgs, 2);
                if (!(stat(t, &sbuf) != 0)) {
                    time_rc = sbuf.st_mtimespec.tv_sec;
                } else {
                    need_nope = 1;
                }
            } else {
                need_nope = 1;
            }
            if (need_nope != 0) {
                vsrm(t);
                t = vsncpy(null, 0, "", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("".*)) -% @as(c_ulong, 1))))));
                t = vsncpy(t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), run, if (run != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(run))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
                t = vsncpy(t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "rc", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("rc".*)) -% @as(c_ulong, 1))))));
                if (!(stat(t, &sbuf) != 0)) {
                    time_rc = sbuf.st_mtimespec.tv_sec;
                } else {
                    time_rc = 0;
                    vsrm(t);
                    t = null;
                }
            }
        }
        if (xdg != null) {
            s = vsncpy(null, 0, xdg, if (xdg != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(@constCast(xdg)))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
            s = vsncpy(s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), run, if (run != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(run))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
            s = vsncpy(s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "rc", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("rc".*)) -% @as(c_ulong, 1))))));
            if (!(stat(s, &sbuf) != 0)) {
                if (sbuf.st_mtimespec.tv_sec < time_rc) {
                    _ = snprintf(@ptrCast(@alignCast(&i_msg)), @sizeOf(@TypeOf(i_msg)), my_gettext("Warning: %s is newer than your %s.\n"), t, s);
                    internal_msg(@ptrCast(@alignCast(&i_msg)));
                }
                f = jfopen(s, "r");
                if (f != null) {
                    c = procrc(cap_1, f, s);
                    if (c == @as(c_int, 0)) {
                        vsrm(t);
                        t = null;
                        {
                            rc_done = 1;
                            break;
                        }
                    }
                    if (c == @as(c_int, 1)) {
                        _ = snprintf(@ptrCast(@alignCast(&i_msg)), @sizeOf(@TypeOf(i_msg)), my_gettext("There were errors in '%s'.  Falling back on default.\n"), s);
                        internal_msg(@ptrCast(@alignCast(&i_msg)));
                        setlogerrs();
                    }
                }
            }
            vsrm(s);
            s = null;
        }
        if (home != null) {
            s = vsncpy(null, 0, home, slen(home));
            s = vsncpy(s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "/.", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("/.".*)) -% @as(c_ulong, 1))))));
            s = vsncpy(s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), run, if (run != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(run))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
            s = vsncpy(s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "rc", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("rc".*)) -% @as(c_ulong, 1))))));
            if (!(stat(s, &sbuf) != 0)) {
                if (sbuf.st_mtimespec.tv_sec < time_rc) {
                    _ = snprintf(@ptrCast(@alignCast(&i_msg)), @sizeOf(@TypeOf(i_msg)), my_gettext("Warning: %s is newer than your %s.\n"), t, s);
                    internal_msg(@ptrCast(@alignCast(&i_msg)));
                }
                f = jfopen(s, "r");
                if (f != null) {
                    c = procrc(cap_1, f, s);
                    if (c == @as(c_int, 0)) {
                        vsrm(t);
                        t = null;
                        {
                            rc_done = 1;
                            break;
                        }
                    }
                    if (c == @as(c_int, 1)) {
                        _ = snprintf(@ptrCast(@alignCast(&i_msg)), @sizeOf(@TypeOf(i_msg)), my_gettext("There were errors in '%s'.  Falling back on default.\n"), s);
                        internal_msg(@ptrCast(@alignCast(&i_msg)));
                        setlogerrs();
                    }
                }
            }
            vsrm(s);
            s = null;
        }
        s = t;
        t = null;
        if (s != null) {
            f = jfopen(s, "r");
            if (f != null) {
                c = procrc(cap_1, f, s);
                if (c == @as(c_int, 0)) {
                    rc_done = 1;
                    break;
                }
                if (c == @as(c_int, 1)) {
                    _ = snprintf(@ptrCast(@alignCast(&i_msg)), @sizeOf(@TypeOf(i_msg)), my_gettext("There were errors in '%s'.  Falling back on default.\n"), s);
                    internal_msg(@ptrCast(@alignCast(&i_msg)));
                    setlogerrs();
                }
            }
            vsrm(s);
            s = null;
        }
        s = vsncpy(null, 0, "*", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("*".*)) -% @as(c_ulong, 1))))));
        s = vsncpy(s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), run, if (run != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(run))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        s = vsncpy(s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "rc", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("rc".*)) -% @as(c_ulong, 1))))));
        f = jfopen(s, "r");
        if (f != null) {
            c = procrc(cap_1, f, s);
        } else {
            s = vstrunc(s, 0);
            s = vsncpy(s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "*joerc", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("*joerc".*)) -% @as(c_ulong, 1))))));
            f = jfopen(s, "r");
            c = procrc(cap_1, f, s);
        }
        if (c == @as(c_int, 0)) {
            rc_done = 1;
            break;
        }
        if (c == @as(c_int, 1)) {
            _ = snprintf(@ptrCast(@alignCast(&i_msg)), @sizeOf(@TypeOf(i_msg)), my_gettext("There were errors in '%s'.  Falling back on default.\n"), s);
            internal_msg(@ptrCast(@alignCast(&i_msg)));
            setlogerrs();
        }
        _ = snprintf(@ptrCast(@alignCast(&i_msg)), @sizeOf(@TypeOf(i_msg)), my_gettext("Couldn't open '%s'\n"), s);
        internal_msg(@ptrCast(@alignCast(&i_msg)));
        setlogerrs();
        return exit_with_errors();
    }
    if (!(rc_done != 0)) return exit_with_errors();
    if (validate_rc() != 0) {
        _ = zlcpy(@ptrCast(@alignCast(&i_msg)), @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(i_msg))))), my_gettext("rc file has no :main key binding section or no bindings.  Bye.\n"));
        internal_msg(@ptrCast(@alignCast(&i_msg)));
        setlogerrs();
        return exit_with_errors();
    }
    {
        var buf: [10]u8 = undefined;
        _ = &buf;
        var x: ptrdiff_t = undefined;
        _ = &x;
        _ = zlcpy(@ptrCast(@alignCast(&buf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))), "\"`\"\t`  ");
        type_backtick = mparse(null, @ptrCast(@alignCast(&buf)), &x, 0);
    }
    shell_kbd = mkkbd(kmap_getcontext("shell"));
    if (!(isatty(fileno(__stdinp)) != 0)) {
        idleout = 0;
    }
    {
        c = 1;
        while (argv[@bitCast(@as(isize, @intCast(c)))] != null) : (c += 1) {
            if ((!(strcmp(argv[@bitCast(@as(isize, @intCast(c)))], "-h") != 0) or !(strcmp(argv[@bitCast(@as(isize, @intCast(c)))], "-help") != 0)) or !(strcmp(argv[@bitCast(@as(isize, @intCast(c)))], "--help") != 0)) {
                _ = printf("Joe's Own Editor v%s\n", @constCast("4.8"));
                _ = printf("\nUsage: %s [global-options] [ [local-options] filename ]...\n\n", argv[@as(c_int, 0)]);
                _ = printf("Global options:\n");
                cmd_help(0);
                _ = printf("\nLocal options:\n");
                _ = printf("    %-23s Start cursor on specified line\n", @constCast("+nnn"));
                cmd_help(1);
                return 0;
            } else if ((!(strcmp(argv[@bitCast(@as(isize, @intCast(c)))], "-v") != 0) or !(strcmp(argv[@bitCast(@as(isize, @intCast(c)))], "-version") != 0)) or !(strcmp(argv[@bitCast(@as(isize, @intCast(c)))], "--version") != 0)) {
                _ = printf("Joe's Own Editor v%s\n", @constCast("4.8"));
                return 0;
            } else if (@as(c_int, argv[@bitCast(@as(isize, @intCast(c)))][@as(c_int, 0)]) == @as(c_int, '-')) {
                if ((@as(c_int, argv[@bitCast(@as(isize, @intCast(c)))][@as(c_int, 1)]) == @as(c_int, '-')) and !(@as(c_int, argv[@bitCast(@as(isize, @intCast(c)))][@as(c_int, 2)]) != 0)) break;
                if (@as(c_int, argv[@bitCast(@as(isize, @intCast(c)))][@as(c_int, 1)]) != 0) {
                    while (true) {
                        switch (glopt(argv[@bitCast(@as(isize, @intCast(c)))] + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), argv[@bitCast(@as(isize, @intCast(c + @as(c_int, 1))))], null, 1)) {
                            @as(c_int, 0) => {
                                _ = snprintf(@ptrCast(@alignCast(&i_msg)), @sizeOf(@TypeOf(i_msg)), my_gettext("Unknown option '%s'\n"), argv[@bitCast(@as(isize, @intCast(c)))]);
                                internal_msg(@ptrCast(@alignCast(&i_msg)));
                                setlogerrs();
                                break;
                            },
                            @as(c_int, 1) => {
                                break;
                            },
                            @as(c_int, 2) => {
                                c += 1;
                                break;
                            },
                            else => {},
                        }
                        break;
                    }
                } else {
                    idleout = 0;
                }
            }
        }
    }
    if (((xmouse != 0) and ((blk: {
        const tmp = getenv("TERM");
        s = tmp;
        break :blk tmp;
    }) != null)) and (strstr(s, "xterm") != null)) {
        usexmouse = 1;
    }
    if (!((blk: {
        const tmp = nopen(cap_1);
        n = tmp;
        break :blk tmp;
    }) != null)) return exit_with_errors();
    maint = screate(n);
    load_state();
    {
        c = 1;
        backopt = 0;
        filesonly = 0;
        while (argv[@bitCast(@as(isize, @intCast(c)))] != null) : (c += 1) if (((!(filesonly != 0) and (@as(c_int, argv[@bitCast(@as(isize, @intCast(c)))][@as(c_int, 0)]) == @as(c_int, '+'))) and (@as(c_int, argv[@bitCast(@as(isize, @intCast(c)))][@as(c_int, 1)]) >= @as(c_int, '0'))) and (@as(c_int, argv[@bitCast(@as(isize, @intCast(c)))][@as(c_int, 1)]) <= @as(c_int, '9'))) {
            if (!(backopt != 0)) {
                backopt = c;
            }
        } else if ((!(filesonly != 0) and (@as(c_int, argv[@bitCast(@as(isize, @intCast(c)))][@as(c_int, 0)]) == @as(c_int, '-'))) and (@as(c_int, argv[@bitCast(@as(isize, @intCast(c)))][@as(c_int, 1)]) != 0)) {
            if ((@as(c_int, argv[@bitCast(@as(isize, @intCast(c)))][@as(c_int, 1)]) == @as(c_int, '-')) and !(@as(c_int, argv[@bitCast(@as(isize, @intCast(c)))][@as(c_int, 2)]) != 0)) {
                filesonly = 1;
            } else {
                if (!(backopt != 0)) {
                    backopt = c;
                }
                if (glopt(argv[@bitCast(@as(isize, @intCast(c)))] + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), argv[@bitCast(@as(isize, @intCast(c + @as(c_int, 1))))], null, 0) == @as(c_int, 2)) {
                    c += 1;
                }
            }
        } else {
            var b_1: [*c]B = bfind(argv[@bitCast(@as(isize, @intCast(c)))]);
            _ = &b_1;
            var bw_2: [*c]BW = null;
            _ = &bw_2;
            var er: c_int = berror;
            _ = &er;
            setup_history(&filehist);
            append_history(filehist, argv[@bitCast(@as(isize, @intCast(c)))], slen(argv[@bitCast(@as(isize, @intCast(c)))]));
            if (!(orphan != 0) or !(opened != 0)) {
                bw_2 = wmktw(maint, b_1);
                if (er != 0) {
                    msgnwt(bw_2.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-er)))]));
                }
            } else {
                var line: off_t = undefined;
                _ = &line;
                b_1.*.orphan = 1;
                b_1.*.oldcur = pdup(b_1.*.bof, "main");
                _ = pline(b_1.*.oldcur, get_file_pos(b_1.*.name));
                p_goto_bol(b_1.*.oldcur);
                line = b_1.*.oldcur.*.line - @as(off_t, @divTrunc(maint.*.h - @as(ptrdiff_t, 1), @as(ptrdiff_t, 2)));
                if (line < @as(off_t, 0)) {
                    line = 0;
                }
                b_1.*.oldtop = pdup(b_1.*.oldcur, "main");
                _ = pline(b_1.*.oldtop, line);
                p_goto_bol(b_1.*.oldtop);
            }
            if (bw_2 != null) {
                var lnum: off_t = 0;
                _ = &lnum;
                bw_2.*.o.readonly = bw_2.*.b.*.rdonly;
                if (backopt != 0) {
                    while (backopt != c) {
                        if (@as(c_int, argv[@bitCast(@as(isize, @intCast(backopt)))][@as(c_int, 0)]) == @as(c_int, '+')) {
                            lnum = ztoo(argv[@bitCast(@as(isize, @intCast(backopt)))] + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))));
                            backopt += 1;
                        } else {
                            if (glopt(argv[@bitCast(@as(isize, @intCast(backopt)))] + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), argv[@bitCast(@as(isize, @intCast(backopt + @as(c_int, 1))))], &bw_2.*.o, 0) == @as(c_int, 2)) {
                                backopt += 2;
                            } else {
                                backopt += 1;
                            }
                        }
                    }
                }
                lazy_opts(bw_2.*.b, &bw_2.*.o);
                bw_2.*.o = bw_2.*.b.*.o;
                bw_2.*.b.*.rdonly = bw_2.*.o.readonly;
                maint.*.curwin = bw_2.*.parent;
                if (lnum > @as(off_t, 0)) {
                    _ = pline(bw_2.*.cursor, lnum - @as(off_t, 1));
                } else {
                    _ = pline(bw_2.*.cursor, get_file_pos(bw_2.*.b.*.name));
                }
                p_goto_bol(bw_2.*.cursor);
                if ((er == -@as(c_int, 1)) and (bw_2.*.o.mnew != null)) {
                    _ = exmacro(bw_2.*.o.mnew, 1, -@as(c_int, 256));
                }
                if ((er == @as(c_int, 0)) and (bw_2.*.o.mold != null)) {
                    _ = exmacro(bw_2.*.o.mold, 1, -@as(c_int, 256));
                }
                if (opened != 0) {
                    _ = wnext(maint);
                }
            }
            opened = 1;
            backopt = 0;
        };
    }
    if (opened != 0) {
        wshowall(maint);
        omid = opt_mid;
        opt_mid = 1;
        dofollows();
        opt_mid = omid;
    } else {
        var bw_1: [*c]BW = wmktw(maint, bfind(""));
        _ = &bw_1;
        if (bw_1.*.o.mnew != null) {
            _ = exmacro(bw_1.*.o.mnew, 1, -@as(c_int, 256));
        }
    }
    maint.*.curwin = maint.*.topwin;
    if (logerrors != 0) {
        var copied: [*c]B = bcpy(startup_log.*.bof, startup_log.*.eof);
        _ = &copied;
        var bw_1: [*c]BW = wmktw(maint, copied);
        _ = &bw_1;
        copied.*.name = zdup(startup_log.*.name);
        copied.*.internal = 1;
        maint.*.curwin = bw_1.*.parent;
        wshowall(maint);
    }
    _ = init_colors();
    init_visiblews();
    if (helpon != 0) {
        _ = help_on(maint);
    }
    if (!(nonotice != 0)) {
        if (xmsg != null) {
            xmsg = stagen(null, @ptrCast(@alignCast(lastw(maint).*.object)), my_gettext(xmsg), ' ');
            msgnw(@as([*c]BASE, @ptrCast(@alignCast(lastw(maint).*.object))).*.parent, xmsg);
        } else {
            _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("\\i** Joe's Own Editor v%s ** (%s) ** Copyright %s 1992 - 2026 **\\i"), @as([*c]u8, @ptrCast(@constCast("4.8"))), locale_map.*.name, if (locale_map.*.type != 0) @as([*c]const u8, "\xc2\xa9") else @as([*c]const u8, "(C)"));
            msgnw(@as([*c]BASE, @ptrCast(@alignCast(lastw(maint).*.object))).*.parent, @ptrCast(@alignCast(&msgbuf)));
        }
    }
    if (!(idleout != 0)) {
        if (!(isatty(fileno(__stdinp)) != 0) and (modify_logic(@ptrCast(@alignCast(maint.*.curwin.*.object)), @as([*c]BW, @ptrCast(@alignCast(maint.*.curwin.*.object))).*.b) != 0)) {
            _ = cstart(@ptrCast(@alignCast(maint.*.curwin.*.object)), null, null, null, null, 0, 1, null, SHELL_TYPE_RAW);
            _ = fclose(__stdinp);
            if (!(freopen("/dev/tty", "rb", __stdinp) != null)) {}
        }
    }
    _ = edloop(0);
    save_state();
    brmall();
    vclose(vmem);
    nclose(n);
    if (noexmsg != 0) {
        if (notite != 0) {
            _ = fprintf(__stderrp, "\n");
        }
    } else {
        if (exmsg != null) {
            _ = fprintf(__stderrp, "\n%s\n", exmsg);
        } else if (notite != 0) {
            _ = fprintf(__stderrp, "\n");
        }
    }
    return 0;
}

comptime {
    if (@sizeOf(struct_stat) != 144) @compileError("struct_stat size mismatch");
    if (@offsetOf(struct_stat, "st_mtimespec") != 48) @compileError("st_mtimespec offset mismatch");
    if (@offsetOf(struct_window, "watom") != 144) @compileError("W.watom offset mismatch");
    if (@offsetOf(struct_window, "object") != 152) @compileError("W.object offset mismatch");
    if (@offsetOf(struct_window, "kbd") != 136) @compileError("W.kbd offset mismatch");
    if (@sizeOf(struct_window) != 200) @compileError("W size mismatch");
    if (@offsetOf(KBD, "x") != 80) @compileError("KBD.x offset mismatch");
    if (@offsetOf(KBD, "seq") != 16) @compileError("KBD.seq offset mismatch");
    if (@sizeOf(struct_b) != 632) @compileError("B size mismatch");
    if (@offsetOf(struct_b, "o") != 192) @compileError("B.o offset mismatch");
    if (@sizeOf(OPTIONS) != 344) @compileError("OPTIONS size mismatch");
    if (@offsetOf(struct_watom, "what") != 80) @compileError("WATOM.what offset mismatch");
    if (@offsetOf(struct_bw, "top") != 16) @compileError("BW.top offset mismatch");
    if (@offsetOf(struct_bw, "o") != 80) @compileError("BW.o offset mismatch");
    if (@sizeOf(struct_bw) != 488) @compileError("BW size mismatch");
    if (@offsetOf(struct_bw, "object") != 424) @compileError("BW.object offset mismatch");
}
