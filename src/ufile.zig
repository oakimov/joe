//! User file operations — replaces `joe/ufile.c`.
//!
//! Faithful C-ABI Path A port of JOE file cmds (usave/uedit/uswitch/ublksave/uexsve/ulose/ubufed/uquerysave/ukilljoe/ureload + doswitch/get_buffer_in_window/yncheck/genexmsg + file globals).

const std = @import("std");
const ptrdiff_t = c_long;

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;
const YES_CODE: c_int = -10;
const NO_CODE: c_int = -20;
const JOE_MSGBUFSIZE: c_int = 300;
const NO_MORE_DATA: c_int = -256;
const CANFLAG_NORESTART: c_int = 1;
const PWFLAG_FILENAME: c_int = 1;
const PWFLAG_UPDATE_CD: c_int = 2;
const PWFLAG_SEED_CD: c_int = 4;
const PWFLAG_COMMAND: c_int = 8;
const O_RDONLY: c_int = 0;
const S_ISUID: c_int = 0o4000;
const S_ISGID: c_int = 0o2000;
const stdsiz: ptrdiff_t = 31744;

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
pub extern fn strcpy(d: [*c]u8, s: [*c]const u8) [*c]u8;
pub const off_t = i64;
pub const time_t = i64;
pub const FILE = anyopaque;
pub const mode_t = c_int;
pub const uid_t = c_uint;
pub const gid_t = c_uint;
/// Darwin/`std.c.Stat`-compatible layout (arm64/macOS). Undersized fakes
/// overflow the stack when `fstat` writes the real 144-byte `struct stat`.
const Timespec = extern struct {
    tv_sec: time_t = 0,
    tv_nsec: c_long = 0,
};
pub const struct_stat = extern struct {
    st_dev: u32 = 0,
    st_mode: u16 = 0,
    st_nlink: u16 = 0,
    st_ino: u64 = 0,
    st_uid: u32 = 0,
    st_gid: u32 = 0,
    st_rdev: u32 = 0,
    _pad_rdev: u32 = 0,
    st_atimespec: Timespec = .{},
    st_mtimespec: Timespec = .{},
    st_ctimespec: Timespec = .{},
    st_birthtimespec: Timespec = .{},
    st_size: i64 = 0,
    st_blocks: i64 = 0,
    st_blksize: i32 = 0,
    st_flags: u32 = 0,
    st_gen: u32 = 0,
    st_lspare: i32 = 0,
    st_qspare: [2]i64 = .{ 0, 0 },
};
comptime {
    if (@sizeOf(struct_stat) != 144) @compileError("struct_stat size");
}
pub const struct_utimbuf = extern struct {
    actime: time_t = 0,
    modtime: time_t = 0,
};
pub extern fn open(path: [*c]const u8, flags: c_int, ...) c_int;
pub extern fn close(fd: c_int) c_int;
pub extern fn creat(path: [*c]const u8, mode: mode_t) c_int;
pub extern fn read(fd: c_int, buf: ?*anyopaque, n: c_ulong) ptrdiff_t;
pub extern fn joe_write(fd: c_int, buf: ?*const anyopaque, siz: ptrdiff_t) ptrdiff_t;
pub extern fn unlink(path: [*c]const u8) c_int;
pub extern fn fstat(fd: c_int, buf: [*c]struct_stat) c_int;
pub extern fn utime(path: [*c]const u8, times: [*c]const struct_utimbuf) c_int;
pub extern fn copy_security_context(from_file: [*c]const u8, to_file: [*c]const u8) c_int;
pub extern var ITEM: ?*anyopaque;
pub extern var QUEUE: ?*anyopaque;
pub extern var LAST: ?*anyopaque;
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
const struct_unnamed_3 = extern struct {
    next: [*c]UNDO = null,
    prev: [*c]UNDO = null,
};
const struct_unnamed_4 = extern struct {
    next: [*c]UNDOREC = null,
    prev: [*c]UNDOREC = null,
};
pub const struct_undorec = extern struct {
    link: struct_unnamed_4 = std.mem.zeroes(struct_unnamed_4),
    unit: [*c]UNDOREC = null,
    min: c_int = 0,
    changed: c_int = 0,
    where: off_t = 0,
    len: off_t = 0,
    del: c_int = 0,
    _pad_del: [4]u8 = std.mem.zeroes([4]u8),
    big: [*c]B = null,
    small: [*c]u8 = null,
};
pub const UNDOREC = struct_undorec;
pub const struct_undo = extern struct {
    link: struct_unnamed_3 = std.mem.zeroes(struct_unnamed_3),
    b: [*c]B = null,
    nrecs: ptrdiff_t = 0,
    recs: UNDOREC = std.mem.zeroes(UNDOREC),
    ptr: [*c]UNDOREC = null,
    first: [*c]UNDOREC = null,
    last: [*c]UNDOREC = null,
};
pub const UNDO = struct_undo;
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
    mnew: ?*MACRO = null,
    mold: ?*MACRO = null,
    msnew: ?*MACRO = null,
    msold: ?*MACRO = null,
    mfirst: ?*MACRO = null,
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
    undo: [*c]UNDO = null,
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
pub const struct_kbd = opaque {};
pub const KBD = struct_kbd;
pub const struct_kmap = opaque {};
pub const KMAP = struct_kmap;
pub const struct_bstack = extern struct {
    next: [*c]struct_bstack = null,
    b: [*c]B = null,
    cursor: [*c]P = null,
    top: [*c]P = null,
};
pub const W = struct_window;
const struct_unnamed_5 = extern struct {
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
    link: struct_unnamed_5 = std.mem.zeroes(struct_unnamed_5),
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
    kbd: ?*KBD = null,
    watom: [*c]const WATOM = null,
    object: ?*anyopaque = null,
    msgt: [*c]const u8 = null,
    msgb: [*c]const u8 = null,
    huh: [*c]const u8 = null,
    notify: [*c]c_int = null,
    bstack: [*c]struct_bstack = null,
};
pub const struct_lattr_db = opaque {};
const struct_unnamed_6 = extern struct {
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
    saved: struct_unnamed_6 = std.mem.zeroes(struct_unnamed_6),
};
pub const BW = struct_bw;
pub const struct_tw = opaque {};
pub const TW = struct_tw;
pub const struct_pw = opaque {};
pub const PW = struct_pw;
pub const struct_menu = opaque {};
pub const MENU = struct_menu;
pub const struct_qw = opaque {};
pub const QW = struct_qw;
pub const struct_cmd = opaque {
};
pub const CMD = struct_cmd;
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn zlcpy(a: [*c]u8, siz: ptrdiff_t, b: [*c]const u8) [*c]u8;
pub extern fn vsmk(len: ptrdiff_t) [*c]u8;
pub extern fn vsadd(s: [*c]u8, c: c_int) [*c]u8;
pub extern fn vstrunc(s: [*c]u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsncpy(s: [*c]u8, len: ptrdiff_t, blk: [*c]const u8, blklen: ptrdiff_t) [*c]u8;
pub extern fn vsdup(s: [*c]u8) [*c]u8;
pub extern fn vsrm(s: [*c]u8) void;
pub extern fn vaadd(vary: [*c][*c]u8, element: [*c]u8) [*c][*c]u8;
pub extern fn vasort(ary: [*c][*c]u8, len: ptrdiff_t) [*c][*c]u8;
pub extern fn varm(vary: [*c][*c]u8) void;
pub extern fn msgnw(w: [*c]W, s: [*c]const u8) void;
pub extern fn msgnwt(w: [*c]W, s: [*c]const u8) void;
pub extern fn wredraw(w: [*c]W) void;
pub extern fn wabort(w: [*c]W) c_int;
pub extern fn wmkpw(w: [*c]W, prompt: [*c]const u8, history: [*c][*c]B, func: ?*const fn (w: [*c]W, s: [*c]u8, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, huh: [*c]const u8, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, tab: ?*const fn (bw: [*c]BW, k: c_int) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int, map: [*c]struct_charmap, file_prompt: c_int) [*c]BW;
pub extern fn simple_cmplt(bw: [*c]BW, list: [*c][*c]u8) c_int;
pub extern fn mkqw(w: [*c]W, prompt: [*c]const u8, len: ptrdiff_t, func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int) ?*QW;
pub extern fn mkmenu(loc: [*c]W, targ: [*c]W, s: [*c][*c]u8, func: ?*const fn (m: ?*MENU, cursor: ptrdiff_t, object: ?*anyopaque, k: c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, backs: ?*const fn (m: ?*MENU, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, cursor: ptrdiff_t, object: ?*anyopaque, notify: [*c]c_int) ?*MENU;
pub extern fn bwmk(window: [*c]W, b: [*c]B, prompt: c_int) [*c]BW;
pub extern fn bwrm(bw: [*c]BW) void;
pub extern fn orphit(bw: [*c]BW) void;
pub extern fn bw_unlock(bw: [*c]BW) void;
pub extern fn set_current_dir(bw: [*c]BW, s: [*c]u8, simp: c_int) void;
pub extern fn get_file_pos(name: [*c]const u8) off_t;
pub extern fn set_file_pos_all(t: [*c]Screen) void;
pub extern fn uduptw(w: [*c]W, k: c_int) c_int;
pub extern fn upopabort(w: [*c]W, k: c_int) c_int;
pub extern fn uabort(w: [*c]W, k: c_int) c_int;
pub extern fn uabort1(w: [*c]W, k: c_int) c_int;
pub extern fn abortit(w: [*c]W, k: c_int) c_int;
pub extern fn ukillpid(w: [*c]W, k: c_int) c_int;
pub extern fn unmark(w: [*c]W, k: c_int) c_int;
pub extern fn pdup(p: [*c]P, where: [*c]const u8) [*c]P;
pub extern fn pdupown(p: [*c]P, o: [*c][*c]P, tr: [*c]const u8) [*c]P;
pub extern fn prm(p: [*c]P) void;
pub extern fn pset(d: [*c]P, s: [*c]P) void;
pub extern fn pline(p: [*c]P, line: off_t) c_int;
pub extern fn piscol(p: [*c]P) off_t;
pub extern fn binss(p: [*c]P, s: [*c]const u8) void;
pub extern fn brm(b: [*c]B) void;
pub extern fn bsave(p: [*c]P, s: [*c]const u8, size: off_t, flag: c_int) c_int;
pub extern fn bload(s: [*c]const u8) [*c]B;
pub extern fn bfind(s: [*c]const u8) [*c]B;
pub extern fn bfind_reload(s: [*c]const u8) [*c]B;
pub extern fn bfind_scratch(s: [*c]const u8) [*c]B;
pub extern fn bcheck_loaded(s: [*c]const u8) [*c]B;
pub extern fn bnext() [*c]B;
pub extern fn bprev() [*c]B;
pub extern fn borphan() [*c]B;
pub extern fn breplace(b: [*c]B, n: [*c]B) void;
pub extern fn getbufs() [*c][*c]u8;
pub extern fn plain_file(b: [*c]B) c_int;
pub extern fn check_mod(b: [*c]B) c_int;
pub extern fn dequote(s: [*c]const u8) [*c]u8;
pub extern fn dequotevs(s: [*c]u8) [*c]u8;
pub extern fn canonical(s: [*c]u8, flags: c_int) [*c]u8;
pub extern fn namepart(tmp: [*c]u8, tmpsiz: ptrdiff_t, path: [*c]const u8) [*c]u8;
pub extern fn joesep(path: [*c]u8) [*c]u8;
pub extern fn mkpath(path: [*c]const u8) c_int;
pub extern fn pextrect(org: [*c]P, height: off_t, right: off_t) [*c]B;
pub extern fn markv(r: c_int) c_int;
pub extern fn doinsf(w: [*c]W, s: [*c]u8, object: ?*anyopaque, notify: [*c]c_int) c_int;
pub extern fn nescape(t: [*c]SCRN) void;
pub extern fn nreturn(t: [*c]SCRN) void;
pub extern fn nredraw(t: [*c]SCRN) void;
pub extern fn ttshell(cmd: [*c]u8) c_int;
pub extern fn ttsusp() void;
pub extern fn dofollows() void;
pub extern fn duplicate_backslashes(s: [*c]const u8, len: ptrdiff_t) [*c]u8;
pub extern fn utf8_decode_fwrd(p: [*c][*c]const u8, plen: [*c]ptrdiff_t) c_int;
pub extern fn from_uni(cset: [*c]struct_charmap, c: c_int) c_int;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn exmacro(m: ?*MACRO, u: c_int, k: c_int) c_int;
pub extern fn findcmd(s: [*c]const u8) ?*const CMD;
pub extern fn execmd(cmd: ?*const CMD, k: c_int) c_int;
pub extern fn cmplt_file(bw: [*c]BW, k: c_int) c_int;
pub extern fn cmplt_file_in(bw: [*c]BW, k: c_int) c_int;
pub extern fn cmplt_file_out(bw: [*c]BW, k: c_int) c_int;
pub extern fn saverr(name: [*c]const u8) void;
pub extern var markb: [*c]P;
pub extern var markk: [*c]P;
pub extern var maint: [*c]Screen;
pub extern var msgbuf: [300]u8;
pub extern var berror: c_int;
pub extern var opt_mid: c_int;
pub extern var square: c_int;
pub extern var lightoff: c_int;
pub extern var leave: c_int;
pub extern var exmsg: [*c]u8;
pub extern var noexmsg: c_int;
pub const msgs: [*c]const [*c]const u8 = @extern([*c]const [*c]const u8, .{
    .name = "msgs",
});
pub const stdbuf: [*c]u8 = @extern([*c]u8, .{
    .name = "stdbuf",
});
pub extern var bufs: B;
pub extern var locale_map: [*c]struct_charmap;
pub export var orphan: c_int = 0;
pub export var backpath: [*c]const u8 = null;
pub export var backup_file_suffix: [*c]const u8 = "~";
pub export var filehist: [*c]B = null;
pub export var nobackups: c_int = 0;
pub export var exask: c_int = 0;
pub const struct_savereq = extern struct {
    callback: ?*const fn (bw: [*c]BW, req: [*c]struct_savereq, flg: c_int, notify: [*c]c_int) callconv(.c) c_int = null,
    name: [*c]u8 = null,
    first: [*c]B = null,
    not_saved: c_int = 0,
    rename: c_int = 0,
    block_save: c_int = 0,
    message: [*c]const u8 = null,
};
pub fn genexmsgmulti(arg_bw_1: [*c]BW, arg_saved: c_int, arg_skipped: c_int) callconv(.c) void {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var saved = arg_saved;
    _ = &saved;
    var skipped = arg_skipped;
    _ = &skipped;
    if (saved != 0) if (skipped != 0) {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(msgbuf)))))))), my_gettext("Some files have not been saved."));
    } else {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(msgbuf)))))))), my_gettext("All modified files have been saved."));
    } else {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(msgbuf)))))))), my_gettext("No modified files, so no updates needed."));
    }
    msgnw(bw_1.*.parent, @ptrCast(@alignCast(&msgbuf)));
    exmsg = vsncpy(null, 0, @ptrCast(@alignCast(&msgbuf)), slen(@ptrCast(@alignCast(&msgbuf))));
}
pub fn dosys(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var rtn: c_int = undefined;
    _ = &rtn;
    nescape(w.*.t.*.t);
    rtn = ttshell(s);
    nreturn(w.*.t.*.t);
    if (notify != null) {
        notify.* = 1;
    }
    vsrm(s);
    return rtn;
}
pub fn cp(arg_from: [*c]u8, arg_to: [*c]u8) callconv(.c) c_int {
    var from = arg_from;
    _ = &from;
    var to = arg_to;
    _ = &to;
    var f: c_int = undefined;
    _ = &f;
    var g: c_int = undefined;
    _ = &g;
    var amnt: ptrdiff_t = undefined;
    _ = &amnt;
    var sbuf: struct_stat = undefined;
    _ = &sbuf;
    var utbuf: struct_utimbuf = undefined;
    _ = &utbuf;
    f = open(from, O_RDONLY);
    if (f < @as(c_int, 0)) {
        return -@as(c_int, 1);
    }
    if (fstat(f, &sbuf) < @as(c_int, 0)) {
        return -@as(c_int, 1);
    }
    g = creat(to, @as(mode_t, @intCast(sbuf.st_mode)) & ~@as(mode_t, @intCast(S_ISUID | S_ISGID)));
    if (g < @as(c_int, 0)) {
        _ = close(f);
        return -@as(c_int, 1);
    }
    while ((blk: {
        const tmp = read(f, @ptrCast(@alignCast(stdbuf)), @as(c_ulong, @bitCast(@as(c_long, stdsiz))));
        amnt = tmp;
        break :blk tmp;
    }) > @as(ptrdiff_t, 0)) {
        if (amnt != joe_write(g, @ptrCast(@alignCast(stdbuf)), amnt)) {
            break;
        }
    }
    _ = close(f);
    _ = close(g);
    if (amnt != 0) {
        return -@as(c_int, 1);
    }
    utbuf.actime = sbuf.st_atimespec.tv_sec;
    utbuf.modtime = sbuf.st_mtimespec.tv_sec;
    _ = utime(to, &utbuf);
    // Always call Zig export (no-op when SELinux disabled / non-Linux).
    _ = copy_security_context(from, to);
    return 0;
}
pub fn backup(arg_bw_1: [*c]BW) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    if ((((!(bw_1.*.b.*.backup != 0) and !(nobackups != 0)) and !(bw_1.*.o.nobackup != 0)) and (bw_1.*.b.*.name != null)) and (@as(c_int, bw_1.*.b.*.name[@as(c_int, 0)]) != 0)) {
        var tmp: [1024]u8 = undefined;
        _ = &tmp;
        var name: [1024]u8 = undefined;
        _ = &name;
        if (backpath != null) {
            var t: [*c]u8 = vsncpy(null, 0, backpath, slen(backpath));
            _ = &t;
            t = canonical(t, CANFLAG_NORESTART);
            _ = mkpath(t);
            _ = snprintf(@ptrCast(@alignCast(&name)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(name)))))))), "%s/%s%s", t, namepart(@ptrCast(@alignCast(&tmp)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(tmp)))))), dequote(bw_1.*.b.*.name)), backup_file_suffix);
            vsrm(t);
        } else {
            _ = snprintf(@ptrCast(@alignCast(&name)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(name)))))))), "%s%s", dequote(bw_1.*.b.*.name), backup_file_suffix);
        }
        _ = unlink(@ptrCast(@alignCast(&name)));
        if (cp(dequote(bw_1.*.b.*.name), @ptrCast(@alignCast(&name))) != 0) {
            return 1;
        } else {
            bw_1.*.b.*.backup = 1;
            return 0;
        }
    } else {
        return 0;
    }
}
pub fn mksavereq(arg_callback: ?*const fn (bw: [*c]BW, req: [*c]struct_savereq, flg: c_int, notify: [*c]c_int) callconv(.c) c_int, arg_name: [*c]u8, arg_first: [*c]B, arg_myrename: c_int, arg_block_save: c_int) callconv(.c) [*c]struct_savereq {
    var callback = arg_callback;
    _ = &callback;
    var name = arg_name;
    _ = &name;
    var first = arg_first;
    _ = &first;
    var myrename = arg_myrename;
    _ = &myrename;
    var block_save = arg_block_save;
    _ = &block_save;
    var req: [*c]struct_savereq = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_savereq))))))));
    _ = &req;
    req.*.callback = callback;
    req.*.name = name;
    req.*.first = first;
    req.*.not_saved = 0;
    req.*.rename = myrename;
    req.*.block_save = block_save;
    return req;
}
pub fn rmsavereq(arg_req: [*c]struct_savereq) callconv(.c) void {
    var req = arg_req;
    _ = &req;
    vsrm(req.*.name);
    joe_free(@ptrCast(@alignCast(req)));
}
pub fn saver(arg_w: [*c]W, arg_c: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var req: [*c]struct_savereq = @ptrCast(@alignCast(object));
    _ = &req;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var fl: c_int = undefined;
    _ = &fl;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if ((c == -@as(c_int, 20)) or (yncheck(no_key, c) != 0)) {
        msgnw(bw_1.*.parent, my_gettext("Couldn't make backup file... file not saved"));
        if (req.*.callback != null) {
            return req.*.callback.?(bw_1, req, -@as(c_int, 1), notify);
        } else {
            if (notify != null) {
                notify.* = 1;
            }
            rmsavereq(req);
            return -@as(c_int, 1);
        }
    }
    if ((c != -@as(c_int, 10)) and !(yncheck(yes_key, c) != 0)) {
        if (mkqw(bw_1.*.parent, my_gettext("Could not make backup file.  Save anyway (y,n,%{abort})? "), slen(my_gettext("Could not make backup file.  Save anyway (y,n,%{abort})? ")), saver, null, @ptrCast(@alignCast(req)), notify) != null) {
            return 0;
        } else {
            rmsavereq(req);
            if (notify != null) {
                notify.* = 1;
            }
            return -@as(c_int, 1);
        }
    }
    if ((bw_1.*.b.*.er == -@as(c_int, 1)) and (bw_1.*.o.msnew != null)) {
        _ = exmacro(bw_1.*.o.msnew, 1, -@as(c_int, 256));
        bw_1.*.b.*.er = -@as(c_int, 3);
    }
    if ((bw_1.*.b.*.er == @as(c_int, 0)) and (bw_1.*.o.msold != null)) {
        _ = exmacro(bw_1.*.o.msold, 1, -@as(c_int, 256));
    }
    if (bw_1.*.b.*.o.purify != 0) {
        const static_local_trimlines = struct {
            var trimlines: ?*const CMD = null;
        };
        _ = &static_local_trimlines;
        if (!(static_local_trimlines.trimlines != null)) {
            static_local_trimlines.trimlines = findcmd("trimlines");
        }
        _ = execmd(static_local_trimlines.trimlines, -@as(c_int, 256));
    }
    if ((blk: {
        const tmp = bsave(bw_1.*.b.*.bof, req.*.name, bw_1.*.b.*.eof.*.byte, if (req.*.rename != 0) @as(c_int, 2) else @as(c_int, 1));
        fl = tmp;
        break :blk tmp;
    }) != @as(c_int, 0)) {
        msgnw(bw_1.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-fl)))]));
        if (req.*.callback != null) {
            return req.*.callback.?(bw_1, req, -@as(c_int, 1), notify);
        } else {
            rmsavereq(req);
            if (notify != null) {
                notify.* = 1;
            }
            return -@as(c_int, 1);
        }
    } else {
        if (((req.*.rename != 0) and (@as(c_int, req.*.name[@as(c_int, 0)]) != @as(c_int, '!'))) and (@as(c_int, req.*.name[@as(c_int, 0)]) != @as(c_int, '>'))) {
            bw_unlock(bw_1);
            joe_free(@ptrCast(@alignCast(bw_1.*.b.*.name)));
            bw_1.*.b.*.name = null;
        }
        if ((!(bw_1.*.b.*.name != null) and (@as(c_int, req.*.name[@as(c_int, 0)]) != @as(c_int, '!'))) and (@as(c_int, req.*.name[@as(c_int, 0)]) != @as(c_int, '>'))) {
            bw_1.*.b.*.name = joesep(zdup(req.*.name));
        }
        if ((bw_1.*.b.*.name != null) and !(strcmp(bw_1.*.b.*.name, req.*.name) != 0)) {
            bw_unlock(bw_1);
            bw_1.*.b.*.changed = 0;
            saverr(bw_1.*.b.*.name);
        }
        {
            var u: [*c]UNDO = bw_1.*.b.*.undo;
            _ = &u;
            var rec: [*c]UNDOREC = undefined;
            _ = &rec;
            var rec_start: [*c]UNDOREC = undefined;
            _ = &rec_start;
            rec_start = &u.*.recs;
            {
                rec = rec_start.*.link.prev;
                while (rec != rec_start) : (rec = rec.*.link.prev) {
                    rec.*.changed = 1;
                }
            }
        }
        genexmsg(bw_1, 1, req.*.name);
        if (req.*.callback != null) {
            return req.*.callback.?(bw_1, req, 0, notify);
        } else {
            rmsavereq(req);
            return 0;
        }
    }
    unreachable;
}
pub fn dosave(arg_bw_1: [*c]BW, arg_req: [*c]struct_savereq, arg_notify: [*c]c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var req = arg_req;
    _ = &req;
    var notify = arg_notify;
    _ = &notify;
    if (req.*.block_save != 0) {
        if (notify != null) {
            notify.* = 1;
        }
        if (markv(1) != 0) {
            if (square != 0) {
                var fl: c_int = undefined;
                _ = &fl;
                var ret: c_int = 0;
                _ = &ret;
                var tmp: [*c]B = pextrect(markb, (markk.*.line - markb.*.line) + @as(off_t, 1), markk.*.xcol);
                _ = &tmp;
                if ((blk: {
                    const tmp_1 = bsave(tmp.*.bof, req.*.name, tmp.*.eof.*.byte, 0);
                    fl = tmp_1;
                    break :blk tmp_1;
                }) != @as(c_int, 0)) {
                    msgnw(bw_1.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-fl)))]));
                    ret = -@as(c_int, 1);
                }
                brm(tmp);
                if (!(ret != 0)) {
                    _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("Block written to file %s"), req.*.name);
                    msgnw(bw_1.*.parent, @ptrCast(@alignCast(&msgbuf)));
                }
                if (lightoff != 0) {
                    _ = unmark(bw_1.*.parent, 0);
                }
                vsrm(req.*.name);
                return ret;
            } else {
                var fl: c_int = undefined;
                _ = &fl;
                var ret: c_int = 0;
                _ = &ret;
                if ((blk: {
                    const tmp = bsave(markb, req.*.name, markk.*.byte - markb.*.byte, 0);
                    fl = tmp;
                    break :blk tmp;
                }) != @as(c_int, 0)) {
                    msgnw(bw_1.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-fl)))]));
                    ret = -@as(c_int, 1);
                }
                if (!(ret != 0)) {
                    _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("Block written to file %s"), req.*.name);
                    msgnw(bw_1.*.parent, @ptrCast(@alignCast(&msgbuf)));
                }
                if (lightoff != 0) {
                    _ = unmark(bw_1.*.parent, 0);
                }
                vsrm(req.*.name);
                return ret;
            }
        } else {
            vsrm(req.*.name);
            msgnw(bw_1.*.parent, my_gettext("No block"));
            return -@as(c_int, 1);
        }
    } else {
        if (backup(bw_1) != 0) {
            return saver(bw_1.*.parent, 0, @ptrCast(@alignCast(req)), notify);
        } else {
            return saver(bw_1.*.parent, -@as(c_int, 10), @ptrCast(@alignCast(req)), notify);
        }
    }
}
pub fn dosave2(arg_w: [*c]W, arg_c: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var req: [*c]struct_savereq = @ptrCast(@alignCast(object));
    _ = &req;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if ((c == -@as(c_int, 10)) or (yncheck(yes_key, c) != 0)) {
        return dosave(bw_1, req, notify);
    } else if ((c == -@as(c_int, 20)) or (yncheck(no_key, c) != 0)) {
        if (notify != null) {
            notify.* = 1;
        }
        genexmsg(bw_1, 0, req.*.name);
        rmsavereq(req);
        return -@as(c_int, 1);
    } else if (mkqw(bw_1.*.parent, req.*.message, slen(req.*.message), dosave2, null, @ptrCast(@alignCast(req)), notify) != null) {
        return 0;
    } else {
        rmsavereq(req);
        return -@as(c_int, 1);
    }
}
pub fn dosave1(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
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
    var req: [*c]struct_savereq = @ptrCast(@alignCast(object));
    _ = &req;
    var f: c_int = undefined;
    _ = &f;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (req.*.name != null) {
        vsrm(req.*.name);
    }
    req.*.name = s;
    if ((@as(c_int, s[@as(c_int, 0)]) != @as(c_int, '!')) and !((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, '>')) and (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, '>')))) {
        if (!(bw_1.*.b.*.name != null) or (strcmp(s, bw_1.*.b.*.name) != 0)) {
            f = open(dequote(s), O_RDONLY);
            if (f != -@as(c_int, 1)) {
                _ = close(f);
                req.*.message = my_gettext("File exists. Overwrite (y,n,%{abort})? ");
                return dosave2(bw_1.*.parent, 0, @ptrCast(@alignCast(req)), notify);
            }
        } else {
            if (check_mod(bw_1.*.b) != 0) {
                req.*.message = my_gettext("File on disk is newer. Overwrite (y,n,%{abort})? ");
                return dosave2(bw_1.*.parent, 0, @ptrCast(@alignCast(req)), notify);
            }
        }
    }
    return dosave(bw_1, req, notify);
}
pub fn doedit1(arg_w: [*c]W, arg_c: c_int, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var obj = arg_obj;
    _ = &obj;
    var notify = arg_notify;
    _ = &notify;
    var s: [*c]u8 = @ptrCast(@alignCast(obj));
    _ = &s;
    var omid: c_int = undefined;
    _ = &omid;
    var ret: c_int = 0;
    _ = &ret;
    var er: c_int = undefined;
    _ = &er;
    var object: ?*anyopaque = undefined;
    _ = &object;
    var b_1: [*c]B = undefined;
    _ = &b_1;
    var current_dir: [*c]u8 = undefined;
    _ = &current_dir;
    var bw_2: [*c]BW = undefined;
    _ = &bw_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_2 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if ((c == -@as(c_int, 10)) or (yncheck(yes_key, c) != 0)) {
        if (notify != null) {
            notify.* = 1;
        }
        b_1 = bfind_reload(s);
        er = berror;
        current_dir = vsdup(bw_2.*.b.*.current_dir);
        if (bw_2.*.b.*.scratch != 0) {
            _ = upopabort(bw_2.*.parent, 0);
            bw_2 = @ptrCast(@alignCast(w.*.object));
        }
        if ((bw_2.*.b.*.count == @as(c_int, 1)) and ((bw_2.*.b.*.changed != 0) or (bw_2.*.b.*.name != null))) {
            if (orphan != 0) {
                orphit(bw_2);
            } else {
                if (uduptw(bw_2.*.parent, 0) != 0) {
                    brm(b_1);
                    return -@as(c_int, 1);
                }
                bw_2 = @ptrCast(@alignCast(maint.*.curwin.*.object));
            }
        }
        if (er != 0) {
            msgnwt(bw_2.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-er)))]));
            if (er != -@as(c_int, 1)) {
                ret = -@as(c_int, 1);
            }
        }
        object = bw_2.*.object;
        w = bw_2.*.parent;
        bwrm(bw_2);
        w.*.object = @ptrCast(@alignCast(blk: {
            const tmp = bwmk(w, b_1, 0);
            bw_2 = tmp;
            break :blk tmp;
        }));
        if (!(b_1.*.current_dir != null)) {
            b_1.*.current_dir = current_dir;
        } else {
            vsrm(current_dir);
        }
        wredraw(bw_2.*.parent);
        bw_2.*.object = object;
        vsrm(s);
        if ((er == -@as(c_int, 1)) and (bw_2.*.o.mnew != null)) {
            _ = exmacro(bw_2.*.o.mnew, 1, -@as(c_int, 256));
        }
        if ((er == @as(c_int, 0)) and (bw_2.*.o.mold != null)) {
            _ = exmacro(bw_2.*.o.mold, 1, -@as(c_int, 256));
        }
        _ = pline(bw_2.*.cursor, get_file_pos(bw_2.*.b.*.name));
        omid = opt_mid;
        opt_mid = 1;
        dofollows();
        opt_mid = omid;
        return ret;
    } else if ((c == -@as(c_int, 20)) or (yncheck(no_key, c) != 0)) {
        if (notify != null) {
            notify.* = 1;
        }
        b_1 = bfind(s);
        er = berror;
        if (bw_2.*.b.*.scratch != 0) {
            _ = upopabort(bw_2.*.parent, 0);
            bw_2 = @ptrCast(@alignCast(w.*.object));
        }
        if ((bw_2.*.b.*.count == @as(c_int, 1)) and ((bw_2.*.b.*.changed != 0) or (bw_2.*.b.*.name != null))) {
            if (orphan != 0) {
                orphit(bw_2);
            } else {
                if (uduptw(bw_2.*.parent, 0) != 0) {
                    brm(b_1);
                    return -@as(c_int, 1);
                }
                bw_2 = @ptrCast(@alignCast(maint.*.curwin.*.object));
            }
        }
        if (er != 0) {
            msgnwt(bw_2.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-er)))]));
            if (er != -@as(c_int, 1)) {
                ret = -@as(c_int, 1);
            }
        }
        object = bw_2.*.object;
        w = bw_2.*.parent;
        bwrm(bw_2);
        w.*.object = @ptrCast(@alignCast(blk: {
            const tmp = bwmk(w, b_1, 0);
            bw_2 = tmp;
            break :blk tmp;
        }));
        wredraw(bw_2.*.parent);
        bw_2.*.object = object;
        vsrm(s);
        if ((er == -@as(c_int, 1)) and (bw_2.*.o.mnew != null)) {
            _ = exmacro(bw_2.*.o.mnew, 1, -@as(c_int, 256));
        }
        if ((er == @as(c_int, 0)) and (bw_2.*.o.mold != null)) {
            _ = exmacro(bw_2.*.o.mold, 1, -@as(c_int, 256));
        }
        _ = pline(bw_2.*.cursor, get_file_pos(bw_2.*.b.*.name));
        omid = opt_mid;
        opt_mid = 1;
        dofollows();
        opt_mid = omid;
        return ret;
    } else {
        if (mkqw(bw_2.*.parent, my_gettext("Load original file from disk (y,n,%{abort})? "), slen(my_gettext("Load original file from disk (y,n,%{abort})? ")), doedit1, null, @ptrCast(@alignCast(s)), notify) != null) return 0 else {
            vsrm(s);
            return -@as(c_int, 1);
        }
    }
}
pub fn doedit(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var obj = arg_obj;
    _ = &obj;
    var notify = arg_notify;
    _ = &notify;
    var b_1: [*c]B = undefined;
    _ = &b_1;
    b_1 = bcheck_loaded(s);
    if (b_1 != null) {
        if ((b_1.*.changed != 0) and !(b_1.*.scratch != 0)) return doedit1(w, 0, @ptrCast(@alignCast(s)), notify) else return doedit1(w, -@as(c_int, 20), @ptrCast(@alignCast(s)), notify);
    } else return doedit1(w, -@as(c_int, 10), @ptrCast(@alignCast(s)), notify);
}
pub fn dosetcd(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var obj = arg_obj;
    _ = &obj;
    var notify = arg_notify;
    _ = &notify;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (notify != null) {
        notify.* = 1;
    }
    if ((if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) != 0) {
        if (@as(c_int, s[@bitCast(@as(isize, @intCast((if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) - @as(ptrdiff_t, 1))))]) != @as(c_int, '/')) {
            s = vsadd(s, '/');
        }
    }
    set_current_dir(bw_1, blk: {
        const tmp = dequotevs(s);
        s = tmp;
        break :blk tmp;
    }, 1);
    _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("Directory prefix set to %s"), s);
    msgnw(bw_1.*.parent, @ptrCast(@alignCast(&msgbuf)));
    vsrm(s);
    return 0;
}
pub fn wpush(arg_bw_1: [*c]BW) callconv(.c) void {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var e: [*c]struct_bstack = undefined;
    _ = &e;
    e = @ptrCast(@alignCast(malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_bstack))))))))));
    e.*.b = bw_1.*.b;
    bw_1.*.b.*.count += 1;
    e.*.cursor = null;
    e.*.top = null;
    _ = pdupown(bw_1.*.cursor, &e.*.cursor, "wpush");
    _ = pdupown(bw_1.*.top, &e.*.top, "wpush");
    e.*.next = bw_1.*.parent.*.bstack;
    bw_1.*.parent.*.bstack = e;
}
pub fn doscratch(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var obj = arg_obj;
    _ = &obj;
    var notify = arg_notify;
    _ = &notify;
    var ret: c_int = 0;
    _ = &ret;
    var er: c_int = undefined;
    _ = &er;
    var object: ?*anyopaque = undefined;
    _ = &object;
    var b_1: [*c]B = undefined;
    _ = &b_1;
    var current_dir: [*c]u8 = undefined;
    _ = &current_dir;
    var bw_2: [*c]BW = undefined;
    _ = &bw_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_2 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    current_dir = vsdup(bw_2.*.b.*.current_dir);
    if (notify != null) {
        notify.* = 1;
    }
    b_1 = bfind_scratch(s);
    if (!(b_1.*.current_dir != null)) {
        b_1.*.current_dir = current_dir;
    } else {
        vsrm(current_dir);
    }
    er = berror;
    if ((bw_2.*.b.*.count == @as(c_int, 1)) and ((bw_2.*.b.*.changed != 0) or (bw_2.*.b.*.name != null))) {
        if ((orphan != 0) or (bw_2.*.b.*.scratch != 0)) {
            orphit(bw_2);
        } else {
            if (uduptw(bw_2.*.parent, 0) != 0) {
                brm(b_1);
                return -@as(c_int, 1);
            }
            bw_2 = @ptrCast(@alignCast(maint.*.curwin.*.object));
        }
    }
    if (er != 0) {
        msgnwt(bw_2.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-er)))]));
        if (er != -@as(c_int, 1)) {
            ret = -@as(c_int, 1);
        }
    }
    object = bw_2.*.object;
    w = bw_2.*.parent;
    bwrm(bw_2);
    w.*.object = @ptrCast(@alignCast(blk: {
        const tmp = bwmk(w, b_1, 0);
        bw_2 = tmp;
        break :blk tmp;
    }));
    wredraw(bw_2.*.parent);
    bw_2.*.object = object;
    vsrm(s);
    if ((er == -@as(c_int, 1)) and (bw_2.*.o.mnew != null)) {
        _ = exmacro(bw_2.*.o.mnew, 1, -@as(c_int, 256));
    }
    if ((er == @as(c_int, 0)) and (bw_2.*.o.mold != null)) {
        _ = exmacro(bw_2.*.o.mold, 1, -@as(c_int, 256));
    }
    return ret;
}
pub fn doscratchpush(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var obj = arg_obj;
    _ = &obj;
    var notify = arg_notify;
    _ = &notify;
    var ret: c_int = 0;
    _ = &ret;
    var er: c_int = undefined;
    _ = &er;
    var object: ?*anyopaque = undefined;
    _ = &object;
    var b_1: [*c]B = undefined;
    _ = &b_1;
    var current_dir: [*c]u8 = undefined;
    _ = &current_dir;
    var bw_2: [*c]BW = undefined;
    _ = &bw_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_2 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    current_dir = vsdup(bw_2.*.b.*.current_dir);
    if (notify != null) {
        notify.* = 1;
    }
    b_1 = bfind_scratch(s);
    if (!(b_1.*.current_dir != null)) {
        b_1.*.current_dir = current_dir;
    } else {
        vsrm(current_dir);
    }
    er = berror;
    if (!(bw_2.*.b.*.scratch != 0)) {
        wpush(bw_2);
    }
    if ((bw_2.*.b.*.count == @as(c_int, 1)) and ((bw_2.*.b.*.changed != 0) or (bw_2.*.b.*.name != null))) {
        if ((orphan != 0) or (bw_2.*.b.*.scratch != 0)) {
            orphit(bw_2);
        } else {
            if (uduptw(bw_2.*.parent, 0) != 0) {
                brm(b_1);
                return -@as(c_int, 1);
            }
            bw_2 = @ptrCast(@alignCast(maint.*.curwin.*.object));
        }
    }
    if (er != 0) {
        msgnwt(bw_2.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-er)))]));
        if (er != -@as(c_int, 1)) {
            ret = -@as(c_int, 1);
        }
    }
    object = bw_2.*.object;
    w = bw_2.*.parent;
    bwrm(bw_2);
    w.*.object = @ptrCast(@alignCast(blk: {
        const tmp = bwmk(w, b_1, 0);
        bw_2 = tmp;
        break :blk tmp;
    }));
    wredraw(bw_2.*.parent);
    bw_2.*.object = object;
    vsrm(s);
    if ((er == -@as(c_int, 1)) and (bw_2.*.o.mnew != null)) {
        _ = exmacro(bw_2.*.o.mnew, 1, -@as(c_int, 256));
    }
    if ((er == @as(c_int, 0)) and (bw_2.*.o.mold != null)) {
        _ = exmacro(bw_2.*.o.mold, 1, -@as(c_int, 256));
    }
    return ret;
}
pub fn bufedcmplt(arg_bw_1: [*c]BW, arg_k: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    if (sbufs != null) {
        varm(sbufs);
        sbufs = null;
    }
    if (!(sbufs != null)) {
        sbufs = getbufs();
    }
    return simple_cmplt(bw_1, sbufs);
}
pub fn dorepl(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var obj = arg_obj;
    _ = &obj;
    var notify = arg_notify;
    _ = &notify;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var object: ?*anyopaque = undefined;
    _ = &object;
    var omid: c_int = undefined;
    _ = &omid;
    var ret: c_int = 0;
    _ = &ret;
    var er: c_int = undefined;
    _ = &er;
    var b_2: [*c]B = undefined;
    _ = &b_2;
    var current_dir: [*c]u8 = undefined;
    _ = &current_dir;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    object = bw_1.*.object;
    current_dir = vsdup(bw_1.*.b.*.current_dir);
    if (notify != null) {
        notify.* = 1;
    }
    b_2 = bfind(s);
    er = berror;
    if (berror != 0) {
        msgnwt(bw_1.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-berror)))]));
        if (berror != -@as(c_int, 1)) {
            ret = -@as(c_int, 1);
        }
    }
    if ((bw_1.*.b.*.count == @as(c_int, 1)) and ((bw_1.*.b.*.changed != 0) or (bw_1.*.b.*.name != null))) {
        orphit(bw_1);
    }
    bwrm(bw_1);
    w.*.object = @ptrCast(@alignCast(blk: {
        const tmp = bwmk(w, b_2, 0);
        bw_1 = tmp;
        break :blk tmp;
    }));
    if (!(b_2.*.current_dir != null)) {
        b_2.*.current_dir = current_dir;
    } else {
        vsrm(current_dir);
    }
    wredraw(bw_1.*.parent);
    bw_1.*.object = object;
    vsrm(s);
    if ((er == -@as(c_int, 1)) and (bw_1.*.o.mnew != null)) {
        _ = exmacro(bw_1.*.o.mnew, 1, -@as(c_int, 256));
    }
    if ((er == @as(c_int, 0)) and (bw_1.*.o.mold != null)) {
        _ = exmacro(bw_1.*.o.mold, 1, -@as(c_int, 256));
    }
    _ = pline(bw_1.*.cursor, get_file_pos(bw_1.*.b.*.name));
    omid = opt_mid;
    opt_mid = 1;
    dofollows();
    opt_mid = omid;
    return ret;
}
pub fn exdone(arg_bw_1: [*c]BW, arg_req: [*c]struct_savereq, arg_flg: c_int, arg_notify: [*c]c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var req = arg_req;
    _ = &req;
    var flg = arg_flg;
    _ = &flg;
    var notify = arg_notify;
    _ = &notify;
    if (notify != null) {
        notify.* = 1;
    }
    rmsavereq(req);
    if (flg != 0) {
        return -@as(c_int, 1);
    } else {
        bw_unlock(bw_1);
        bw_1.*.b.*.changed = 0;
        saverr(bw_1.*.b.*.name);
        return uabort1(bw_1.*.parent, -@as(c_int, 1));
    }
}
pub fn nask(arg_w: [*c]W, arg_c: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if ((c == -@as(c_int, 10)) or (yncheck(yes_key, c) != 0)) {
        if (notify != null) {
            notify.* = 1;
        }
        return 0;
    } else if ((c == -@as(c_int, 20)) or (yncheck(no_key, c) != 0)) {
        if (notify != null) {
            notify.* = -@as(c_int, 1);
        }
        genexmsg(bw_1, 0, null);
        _ = abortit(bw_1.*.parent, 0);
        return -@as(c_int, 1);
    } else if ((bw_1.*.b.*.changed != 0) and !(bw_1.*.b.*.scratch != 0)) {
        if (mkqw(bw_1.*.parent, my_gettext("Save changes to this file (y,n,%{abort})? "), slen(my_gettext("Save changes to this file (y,n,%{abort})? ")), nask, null, object, notify) != null) {
            return 0;
        } else {
            return -@as(c_int, 1);
        }
    } else {
        if (notify != null) {
            notify.* = 1;
        }
        return 0;
    }
}
pub fn dolose(arg_w: [*c]W, arg_c: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var b_1: [*c]B = undefined;
    _ = &b_1;
    var new_b: [*c]B = undefined;
    _ = &new_b;
    var cnt: c_int = undefined;
    _ = &cnt;
    var bw_2: [*c]BW = undefined;
    _ = &bw_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_2 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (notify != null) {
        notify.* = 1;
    }
    if ((c != -@as(c_int, 10)) and !(yncheck(yes_key, c) != 0)) {
        return -@as(c_int, 1);
    }
    b_1 = bw_2.*.b;
    cnt = b_1.*.count;
    b_1.*.count = 1;
    genexmsg(bw_2, 0, null);
    b_1.*.count = cnt;
    if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = maint.*.topwin;
        w = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        while (true) {
            if (((w.*.watom.*.what & TYPETW) != 0) and (@as([*c]BW, @ptrCast(@alignCast(w.*.object))).*.b == b_1)) {
                if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
                    const tmp = borphan();
                    new_b = tmp;
                    break :blk tmp;
                }))) != @as(?*anyopaque, null)) {
                    var tbw: [*c]BW = @ptrCast(@alignCast(w.*.object));
                    _ = &tbw;
                    var obj: ?*anyopaque = tbw.*.object;
                    _ = &obj;
                    bwrm(tbw);
                    w.*.object = @ptrCast(@alignCast(blk: {
                        const tmp = bwmk(w, new_b, 0);
                        tbw = tmp;
                        break :blk tmp;
                    }));
                    wredraw(w);
                    tbw.*.object = obj;
                } else {
                    var tbw: [*c]BW = @ptrCast(@alignCast(w.*.object));
                    _ = &tbw;
                    var obj: ?*anyopaque = tbw.*.object;
                    _ = &obj;
                    bwrm(tbw);
                    w.*.object = @ptrCast(@alignCast(blk: {
                        const tmp = bwmk(w, bfind(""), 0);
                        tbw = tmp;
                        break :blk tmp;
                    }));
                    wredraw(w);
                    tbw.*.object = obj;
                    if (tbw.*.o.mnew != null) {
                        _ = exmacro(tbw.*.o.mnew, 1, -@as(c_int, 256));
                    }
                }
            }
            w = w.*.link.next;
            if (!(w != maint.*.topwin)) break;
        }
    }
    return 0;
}
pub fn dobufed(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    return dorepl(w, s, null, notify);
}
pub fn doquerysave(arg_w: [*c]W, arg_c: c_int, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var obj = arg_obj;
    _ = &obj;
    var notify = arg_notify;
    _ = &notify;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var req: [*c]struct_savereq = @ptrCast(@alignCast(obj));
    _ = &req;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if ((c == -@as(c_int, 10)) or (yncheck(yes_key, c) != 0)) {
        if ((bw_1.*.b.*.name != null) and (@as(c_int, bw_1.*.b.*.name[@as(c_int, 0)]) != 0)) return dosave1(bw_1.*.parent, vsncpy(null, 0, bw_1.*.b.*.name, slen(bw_1.*.b.*.name)), @ptrCast(@alignCast(req)), notify) else {
            var pbw: [*c]BW = undefined;
            _ = &pbw;
            pbw = wmkpw(bw_1.*.parent, my_gettext("Name of file to save (%{help} for help): "), &filehist, dosave1, "Names", null, cmplt_file_out, @ptrCast(@alignCast(req)), notify, locale_map, (PWFLAG_FILENAME | PWFLAG_SEED_CD) | PWFLAG_UPDATE_CD);
            if (pbw != null) {
                return 0;
            } else {
                joe_free(@ptrCast(@alignCast(req)));
                return -@as(c_int, 1);
            }
        }
    } else if ((c == -@as(c_int, 20)) or (yncheck(no_key, c) != 0)) {
        if (bw_1.*.b.*.changed != 0) {
            req.*.not_saved = 1;
        }
        while (true) {
            if (unbuf(bw_1.*.parent, 0) != 0) {
                if (notify != null) {
                    notify.* = 1;
                }
                genexmsgmulti(bw_1, 1, req.*.not_saved);
                rmsavereq(req);
                return 0;
            }
            bw_1 = @ptrCast(@alignCast(w.*.object));
            if (bw_1.*.b == req.*.first) {
                if (notify != null) {
                    notify.* = 1;
                }
                genexmsgmulti(bw_1, 1, req.*.not_saved);
                rmsavereq(req);
                return 0;
            }
            if (!(bw_1.*.b.*.changed != 0) or (bw_1.*.b.*.scratch != 0)) continue;
            return doquerysave(bw_1.*.parent, 0, @ptrCast(@alignCast(req)), notify);
        }
    } else {
        var buf: [1024]u8 = undefined;
        _ = &buf;
        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(c_int, 1024))), my_gettext("File %s has been modified.  Save it (y,n,%{abort})? "), if (bw_1.*.b.*.name != null) bw_1.*.b.*.name else @as([*c]u8, @ptrCast(@constCast("(Unnamed)"))));
        if (mkqw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), slen(@ptrCast(@alignCast(&buf))), doquerysave, null, @ptrCast(@alignCast(req)), notify) != null) {
            return 0;
        } else {
            rmsavereq(req);
            return -@as(c_int, 1);
        }
    }
    unreachable;
}
pub fn query_next(arg_bw_1: [*c]BW, arg_req: [*c]struct_savereq, arg_flg: c_int, arg_notify: [*c]c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var req = arg_req;
    _ = &req;
    var flg = arg_flg;
    _ = &flg;
    var notify = arg_notify;
    _ = &notify;
    if (flg != 0) {
        if (notify != null) {
            notify.* = 1;
        }
        rmsavereq(req);
        return -@as(c_int, 1);
    } else return doquerysave(bw_1.*.parent, -@as(c_int, 20), @ptrCast(@alignCast(req)), notify);
}
pub fn doreload(arg_w: [*c]W, arg_c: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var n: [*c]B = undefined;
    _ = &n;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (notify != null) {
        notify.* = 1;
    }
    if ((c != -@as(c_int, 10)) and !(yncheck(yes_key, c) != 0)) {
        return -@as(c_int, 1);
    }
    n = bload(bw_1.*.b.*.name);
    if (berror != 0) {
        brm(n);
        msgnw(bw_1.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-berror)))]));
        return -@as(c_int, 1);
    }
    breplace(bw_1.*.b, n);
    nredraw(bw_1.*.parent.*.t.*.t);
    msgnw(bw_1.*.parent, my_gettext("File reloaded"));
    return 0;
}
pub export fn genexmsg(arg_bw_1: [*c]BW, arg_saved: c_int, arg_name: [*c]u8) void {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var saved = arg_saved;
    _ = &saved;
    var name = arg_name;
    _ = &name;
    var s: [*c]const u8 = undefined;
    _ = &s;
    if ((bw_1.*.b.*.name != null) and (@as(c_int, bw_1.*.b.*.name[@as(c_int, 0)]) != 0)) {
        s = bw_1.*.b.*.name;
    } else {
        s = my_gettext("(Unnamed)");
    }
    if (name != null) {
        if (saved != 0) {
            _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("File %s saved"), name);
        } else {
            _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("File %s not saved"), name);
        }
    } else if (bw_1.*.b.*.changed != 0) {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("File %s not saved"), s);
    } else if (saved != 0) {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("File %s saved"), s);
    } else {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("File %s not changed so no update needed"), s);
    }
    if (exmsg != null) {
        vsrm(exmsg);
    }
    exmsg = vsncpy(null, 0, @ptrCast(@alignCast(&msgbuf)), slen(@ptrCast(@alignCast(&msgbuf))));
    if (!(noexmsg != 0)) {
        var t: [*c]u8 = duplicate_backslashes(@ptrCast(@alignCast(&msgbuf)), slen(@ptrCast(@alignCast(&msgbuf))));
        _ = &t;
        _ = strcpy(@ptrCast(@alignCast(&msgbuf)), t);
        vsrm(t);
        msgnw(bw_1.*.parent, @ptrCast(@alignCast(&msgbuf)));
    }
}
pub export fn ushell(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    nescape(w.*.t.*.t);
    ttsusp();
    nreturn(w.*.t.*.t);
    return 0;
}
pub export fn usys(arg_w: [*c]W, arg_k: c_int) c_int {
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
    if (wmkpw(w, my_gettext("System (%{abort} to abort): "), null, dosys, null, null, null, null, null, bw_1.*.b.*.o.charmap, PWFLAG_COMMAND) != null) return 0 else return -@as(c_int, 1);
}
pub export var yes_key: [*c]const u8 = "|yes|yY";
pub export var no_key: [*c]const u8 = "|no|nN";
pub export fn yncheck(arg_key_set: [*c]const u8, arg_c: c_int) c_int {
    var key_set = arg_key_set;
    _ = &key_set;
    var c = arg_c;
    _ = &c;
    var set: [*c]const u8 = my_gettext(key_set);
    _ = &set;
    if (locale_map.*.type != 0) {
        while (@as(c_int, set.*) != 0) {
            if (c == utf8_decode_fwrd(&set, null)) return 1;
        }
        return 0;
    } else {
        c = from_uni(locale_map, c);
        while (@as(c_int, set[@as(c_int, 0)]) != 0) {
            if (@as(c_int, set[@as(c_int, 0)]) == c) return 1;
            set += 1;
        }
        return 0;
    }
    unreachable;
}
pub export fn usave(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var pbw: [*c]BW = undefined;
    _ = &pbw;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    pbw = wmkpw(bw_1.*.parent, my_gettext("Name of file to save (%{help} for help): "), &filehist, dosave1, "Names", null, cmplt_file_out, @ptrCast(@alignCast(mksavereq(null, null, null, 1, 0))), null, locale_map, if (bw_1.*.b.*.name != null) PWFLAG_FILENAME else (PWFLAG_FILENAME | PWFLAG_SEED_CD) | PWFLAG_UPDATE_CD);
    if ((pbw != null) and (bw_1.*.b.*.name != null)) {
        binss(pbw.*.cursor, bw_1.*.b.*.name);
        pset(pbw.*.cursor, pbw.*.b.*.eof);
        pbw.*.cursor.*.xcol = piscol(pbw.*.cursor);
    }
    if (pbw != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
pub export fn usavenow(arg_w: [*c]W, arg_k: c_int) c_int {
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
    if (bw_1.*.b.*.name != null) {
        return dosave1(w, vsncpy(null, 0, bw_1.*.b.*.name, slen(bw_1.*.b.*.name)), @ptrCast(@alignCast(mksavereq(null, null, null, 0, 0))), null);
    } else return usave(w, 0);
}
pub export fn ublksave(arg_w: [*c]W, arg_k: c_int) c_int {
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
    if (((((markb != null) and (markk != null)) and (markb.*.b == markk.*.b)) and (markk.*.byte > markb.*.byte)) and (!(square != 0) or (piscol(markk) > piscol(markb)))) {
        if (wmkpw(bw_1.*.parent, my_gettext("Name of file to write (%{help} for help): "), &filehist, dosave1, "Names", null, cmplt_file_out, @ptrCast(@alignCast(mksavereq(null, null, null, 0, 1))), null, locale_map, PWFLAG_FILENAME | PWFLAG_UPDATE_CD) != null) {
            return 0;
        } else {
            return -@as(c_int, 1);
        }
    } else {
        return usave(bw_1.*.parent, 0);
    }
}
pub export fn okrepl(arg_bw_1: [*c]BW) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    if ((bw_1.*.b.*.count == @as(c_int, 1)) and (bw_1.*.b.*.changed != 0)) {
        msgnw(bw_1.*.parent, my_gettext("Can't replace modified file"));
        return -@as(c_int, 1);
    } else {
        return 0;
    }
}
pub export fn uedit(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (wmkpw(w, my_gettext("Name of file to edit (%{help} for help): "), &filehist, doedit, "Names", null, cmplt_file_in, null, null, locale_map, (PWFLAG_FILENAME | PWFLAG_SEED_CD) | PWFLAG_UPDATE_CD) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
pub export fn usetcd(arg_w: [*c]W, arg_k: c_int) c_int {
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
    if (wmkpw(bw_1.*.parent, my_gettext("Set current directory (%{abort} to abort): "), &filehist, dosetcd, "Names", null, cmplt_file, null, null, locale_map, (PWFLAG_FILENAME | PWFLAG_SEED_CD) | PWFLAG_UPDATE_CD) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
pub export fn doswitch(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var obj = arg_obj;
    _ = &obj;
    var notify = arg_notify;
    _ = &notify;
    return doedit1(w, -@as(c_int, 20), @ptrCast(@alignCast(s)), notify);
}
pub export fn uswitch(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (wmkpw(w, my_gettext("Name of buffer to edit (%{abort} to abort): "), &filehist, doswitch, "Names", null, cmplt_file_in, null, null, locale_map, PWFLAG_FILENAME) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
pub export var sbufs: [*c][*c]u8 = null;
pub export fn uscratch(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (wmkpw(w, my_gettext("Name of scratch buffer to edit (%{abort} to abort): "), &filehist, doscratch, "Names", null, bufedcmplt, null, null, locale_map, 0) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
pub export fn uscratch_push(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (wmkpw(w, my_gettext("Name of scratch buffer to edit (%{abort} to abort): "), &filehist, doscratchpush, "Names", null, bufedcmplt, null, null, locale_map, 0) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
pub export fn get_buffer_in_window(arg_bw_1: [*c]BW, arg_b_2: [*c]B) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var b_2 = arg_b_2;
    _ = &b_2;
    var object: ?*anyopaque = bw_1.*.object;
    _ = &object;
    var w: [*c]W = bw_1.*.parent;
    _ = &w;
    if (b_2 == bw_1.*.b) {
        return 0;
    }
    if (!(b_2.*.orphan != 0)) {
        b_2.*.count += 1;
    } else {
        b_2.*.orphan = 0;
    }
    if (bw_1.*.b.*.count == @as(c_int, 1)) {
        orphit(bw_1);
    }
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
pub export fn unbuf(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var b_1: [*c]B = undefined;
    _ = &b_1;
    var bw_2: [*c]BW = undefined;
    _ = &bw_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_2 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    b_1 = bnext();
    if (!(b_1 != null)) return -@as(c_int, 1);
    if (b_1 == bw_2.*.b) {
        b_1 = bnext();
    }
    return get_buffer_in_window(bw_2, b_1);
}
pub export fn upbuf(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var b_1: [*c]B = undefined;
    _ = &b_1;
    var bw_2: [*c]BW = undefined;
    _ = &bw_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_2 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    b_1 = bprev();
    if (!(b_1 != null)) return -@as(c_int, 1);
    if (b_1 == bw_2.*.b) {
        b_1 = bprev();
    }
    return get_buffer_in_window(bw_2, b_1);
}
pub export fn uinsf(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (wmkpw(w, my_gettext("Name of file to insert (%{help} for help): "), &filehist, doinsf, "Names", null, cmplt_file_in, null, null, locale_map, PWFLAG_FILENAME | PWFLAG_UPDATE_CD) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
pub export fn uexsve(arg_w: [*c]W, arg_k: c_int) c_int {
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
    if (!(bw_1.*.b.*.changed != 0) or (bw_1.*.b.*.scratch != 0)) {
        if ((markv(0) != 0) and (markb.*.b == bw_1.*.b)) {
            prm(markk);
            markk = null;
        }
        _ = uabort(bw_1.*.parent, -@as(c_int, 1));
        return 0;
    } else if ((bw_1.*.b.*.name != null) and !(exask != 0)) {
        return dosave1(bw_1.*.parent, vsncpy(null, 0, bw_1.*.b.*.name, slen(bw_1.*.b.*.name)), @ptrCast(@alignCast(mksavereq(exdone, null, null, 0, 0))), null);
    } else {
        var pbw: [*c]BW = wmkpw(bw_1.*.parent, my_gettext("Name of file to save (%{help} for help): "), &filehist, dosave1, "Names", null, cmplt_file_out, @ptrCast(@alignCast(mksavereq(exdone, null, null, 1, 0))), null, locale_map, PWFLAG_FILENAME);
        _ = &pbw;
        if ((pbw != null) and (bw_1.*.b.*.name != null)) {
            binss(pbw.*.cursor, bw_1.*.b.*.name);
            pset(pbw.*.cursor, pbw.*.b.*.eof);
            pbw.*.cursor.*.xcol = piscol(pbw.*.cursor);
        }
        if (pbw != null) {
            return 0;
        } else {
            return -@as(c_int, 1);
        }
    }
}
pub export fn uask(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    return nask(w, 0, null, null);
}
pub export fn ulose(arg_w: [*c]W, arg_k: c_int) c_int {
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
    msgnw(bw_1.*.parent, null);
    if ((bw_1.*.b.*.count == @as(c_int, 1)) and (bw_1.*.b.*.pid != 0)) {
        return ukillpid(bw_1.*.parent, 0);
    }
    if ((bw_1.*.b.*.changed != 0) and !(bw_1.*.b.*.scratch != 0)) {
        if (mkqw(bw_1.*.parent, my_gettext("Lose changes to this file (y,n,%{abort})? "), slen(my_gettext("Lose changes to this file (y,n,%{abort})? ")), dolose, null, null, null) != null) {
            return 0;
        } else {
            return -@as(c_int, 1);
        }
    } else {
        return dolose(bw_1.*.parent, -@as(c_int, 10), null, null);
    }
}
pub export var bufhist: [*c]B = null;
pub export fn ubufed(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (wmkpw(w, my_gettext("Name of buffer to edit (%{abort} to abort): "), &bufhist, dobufed, "bufed", null, bufedcmplt, null, null, locale_map, 0) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
pub export fn uquerysave(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var first: [*c]B = undefined;
    _ = &first;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    _ = unbuf(bw_1.*.parent, 0);
    bw_1 = @ptrCast(@alignCast(w.*.object));
    first = bw_1.*.b;
    while (true) {
        if ((bw_1.*.b.*.changed != 0) and !(bw_1.*.b.*.scratch != 0)) return doquerysave(bw_1.*.parent, 0, @ptrCast(@alignCast(mksavereq(query_next, null, first, 0, 0))), null) else if (unbuf(bw_1.*.parent, 0) != 0) break;
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!(bw_1.*.b != first)) break;
    }
    genexmsgmulti(bw_1, 0, 0);
    return 0;
}
pub export fn ukilljoe(arg_w: [*c]W, arg_k: c_int) c_int {
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
    set_file_pos_all(bw_1.*.parent.*.t);
    leave = 1;
    return 0;
}
pub export fn ureload(arg_w: [*c]W, arg_k: c_int) c_int {
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
    if (!(plain_file(bw_1.*.b) != 0)) {
        msgnw(bw_1.*.parent, my_gettext("Can only reload plain files"));
        return -@as(c_int, 1);
    }
    if (bw_1.*.b.*.changed != 0) {
        if (mkqw(bw_1.*.parent, my_gettext("Lose changes to this file (y,n,%{abort})? "), slen(my_gettext("Lose changes to this file (y,n,%{abort})? ")), doreload, null, null, null) != null) {
            return 0;
        } else {
            return -@as(c_int, 1);
        }
    }
    return doreload(bw_1.*.parent, -@as(c_int, 10), null, null);
}
pub export fn ureload_all(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var count: c_int = 0;
    _ = &count;
    var er: c_int = 0;
    _ = &er;
    var b_1: [*c]B = undefined;
    _ = &b_1;
    var bw_2: [*c]BW = undefined;
    _ = &bw_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_2 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    {
        b_1 = bufs.link.next;
        while (b_1 != (&bufs)) : (b_1 = b_1.*.link.next) if (!(b_1.*.changed != 0) and (plain_file(b_1) != 0)) {
            var n: [*c]B = bload(b_1.*.name);
            _ = &n;
            if (berror != 0) {
                msgnw(bw_2.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-berror)))]));
                er = -@as(c_int, 1);
                brm(n);
            } else {
                breplace(b_1, n);
                count += 1;
            }
        };
    }
    nredraw(bw_2.*.parent.*.t.*.t);
    if (!(er != 0)) {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("%d files reloaded"), count);
        msgnw(bw_2.*.parent, @ptrCast(@alignCast(&msgbuf)));
    }
    return er;
}
