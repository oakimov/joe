//! Search & replace — replaces `joe/usearch.c`.
//!
//! Faithful C-ABI Path A port of JOE search (mksrch/rmsrch/setpat/dopfnext/pffirst/pfnext/pqrepl/prfirst/ufinish/dofirst + globals).

const std = @import("std");
const ptrdiff_t = c_long;

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;
const NMATCHES: c_int = 26;
const MAX_WORD_SIZE: c_int = 64;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn fprintf(f: ?*anyopaque, fmt: [*c]const u8, ...) c_int;
pub extern fn fgets(buf: [*c]u8, n: c_int, f: ?*anyopaque) [*c]u8;
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
pub extern var ITEM: ?*anyopaque;
pub extern var QUEUE: ?*anyopaque;
pub extern var LAST: ?*anyopaque;
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
pub const struct_lattr_db = opaque {};
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
pub const struct_Cclass = opaque {};
pub const HENTRY = struct_entry;
pub const struct_entry = extern struct {
    next: [*c]HENTRY = null,
    name: [*c]const u8 = null,
    hash_val: ptrdiff_t = 0,
    val: ?*anyopaque = null,
};
pub const struct_Hash = extern struct {
    len: ptrdiff_t = 0,
    tab: [*c][*c]HENTRY = null,
    nentries: ptrdiff_t = 0,
};
pub const HASH = struct_Hash;
pub const struct_regcomp = extern struct {
    ptr: [*c]const u8 = null,
    l: ptrdiff_t = 0,
    cmap: [*c]struct_charmap = null,
    nodes: ?*anyopaque = null,
    len: c_int = 0,
    size: c_int = 0,
    prefix: [*c]u8 = null,
    prefix_len: ptrdiff_t = 0,
    prefix_size: ptrdiff_t = 0,
    bra_no: c_int = 0,
    _frag_pad: [32]u8 = std.mem.zeroes([32]u8),
    err: [*c]const u8 = null,
};
pub const struct_regmatch = extern struct {
    rm_so: off_t = 0,
    rm_eo: off_t = 0,
};
pub const Regmatch_t = struct_regmatch;
const struct_unnamed_4 = extern struct {
    next: [*c]SRCHREC = null,
    prev: [*c]SRCHREC = null,
};
pub const struct_srchrec = extern struct {
    link: struct_unnamed_4 = std.mem.zeroes(struct_unnamed_4),
    yn: c_int = 0,
    wrap_flag: c_int = 0,
    addr: off_t = 0,
    b: [*c]B = null,
    last_repl: off_t = 0,
};
pub const SRCHREC = struct_srchrec;
pub const struct_search = extern struct {
    pattern: [*c]u8 = null,
    comp: [*c]struct_regcomp = null,
    replacement: [*c]u8 = null,
    backwards: c_int = 0,
    ignore: c_int = 0,
    regex: c_int = 0,
    repeat: c_int = 0,
    replace: c_int = 0,
    debug: c_int = 0,
    rest: c_int = 0,
    pieces: [26]Regmatch_t = std.mem.zeroes([26]Regmatch_t),
    entire: Regmatch_t = std.mem.zeroes(Regmatch_t),
    flg: c_int = 0,
    recs: SRCHREC = std.mem.zeroes(SRCHREC),
    markb: [*c]P = null,
    markk: [*c]P = null,
    wrap_p: [*c]P = null,
    wrap_flag: c_int = 0,
    allow_wrap: c_int = 0,
    valid: c_int = 0,
    addr: off_t = 0,
    last_repl: off_t = 0,
    block_restrict: c_int = 0,
    all: c_int = 0,
    first: [*c]B = null,
    current: [*c]B = null,
};
pub const SRCH = struct_search;
pub const STDITEM = struct_stditem;
const struct_unnamed_5 = extern struct {
    next: [*c]STDITEM = null,
    prev: [*c]STDITEM = null,
};
pub const struct_stditem = extern struct {
    link: struct_unnamed_5 = std.mem.zeroes(struct_unnamed_5),
};
pub const struct_query = extern struct {
    parent: [*c]W = null,
    func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int = null,
    abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int = null,
    object: ?*anyopaque = null,
    prompt: [*c]u8 = null,
    promptlen: ptrdiff_t = 0,
    org_w: ptrdiff_t = 0,
    org_h: ptrdiff_t = 0,
};
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn vsmk(len: ptrdiff_t) [*c]u8;
pub extern fn vsadd(s: [*c]u8, c: c_int) [*c]u8;
pub extern fn vstrunc(s: [*c]u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsncpy(s: [*c]u8, len: ptrdiff_t, blk: [*c]const u8, blklen: ptrdiff_t) [*c]u8;
pub extern fn vsfill(s: [*c]u8, len: ptrdiff_t, c: c_int, amnt: ptrdiff_t) [*c]u8;
pub extern fn vsdup(s: [*c]u8) [*c]u8;
pub extern fn vsrm(s: [*c]u8) void;
pub extern fn vaadd(vary: [*c][*c]u8, element: [*c]u8) [*c][*c]u8;
pub extern fn vasort(ary: [*c][*c]u8, len: ptrdiff_t) [*c][*c]u8;
pub extern fn varm(vary: [*c][*c]u8) void;
pub extern fn htmk(len: ptrdiff_t) [*c]HASH;
pub extern fn htrm(ht: [*c]HASH) void;
pub extern fn htadd(ht: [*c]HASH, name: [*c]const u8, val: ?*anyopaque) ?*anyopaque;
pub extern fn htfind(ht: [*c]HASH, name: [*c]const u8) ?*anyopaque;
pub extern fn alitem(list: ?*anyopaque, itemsize: ptrdiff_t) ?*anyopaque;
pub extern fn frchn(list: ?*anyopaque, ch: ?*anyopaque) void;
pub extern fn wabort(w: [*c]W) c_int;
pub extern fn updall() void;
pub extern fn get_buffer_in_window(bw: [*c]BW, b: [*c]B) c_int;
pub extern fn msgnw(w: [*c]W, s: [*c]const u8) void;
pub extern fn wmkpw(w: [*c]W, prompt: [*c]const u8, history: [*c][*c]B, func: ?*const fn (w: [*c]W, s: [*c]u8, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, huh: [*c]const u8, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, tab: ?*const fn (bw: [*c]BW, k: c_int) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int, map: [*c]struct_charmap, file_prompt: c_int) [*c]BW;
pub extern fn urtn(w: [*c]W, k: c_int) c_int;
pub extern fn simple_cmplt(bw: [*c]BW, list: [*c][*c]u8) c_int;
pub extern fn utypebw(bw: [*c]BW, k: c_int) c_int;
pub extern fn mcomplete(m: [*c]MENU) [*c]u8;
pub extern fn mkmenu(loc: [*c]W, targ: [*c]W, s: [*c][*c]u8, func: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque, k: c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, backs: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, cursor: ptrdiff_t, object: ?*anyopaque, notify: [*c]c_int) [*c]MENU;
pub extern fn mkqw(w: [*c]W, prompt: [*c]const u8, len: ptrdiff_t, func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int) ?*QW;
pub extern fn mkqwnsr(w: [*c]W, prompt: [*c]const u8, len: ptrdiff_t, func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int) ?*QW;
pub extern fn pdup(p: [*c]P, where: [*c]const u8) [*c]P;
pub extern fn pdupown(p: [*c]P, o: [*c][*c]P, tr: [*c]const u8) [*c]P;
pub extern fn prm(p: [*c]P) void;
pub extern fn pset(d: [*c]P, s: [*c]P) void;
pub extern fn pgoto(p: [*c]P, loc: off_t) [*c]P;
pub extern fn p_goto_bol(p: [*c]P) void;
pub extern fn p_goto_eol(p: [*c]P) void;
pub extern fn p_goto_bof(p: [*c]P) [*c]P;
pub extern fn p_goto_eof(p: [*c]P) [*c]P;
pub extern fn piseol(p: [*c]P) c_int;
pub extern fn piseof(p: [*c]P) c_int;
pub extern fn piscol(p: [*c]P) off_t;
pub extern fn brch(p: [*c]P) c_int;
pub extern fn brc(p: [*c]P) c_int;
pub extern fn pgetc(p: [*c]P) c_int;
pub extern fn prgetc(p: [*c]P) c_int;
pub extern fn pfwrd(p: [*c]P, n: off_t) [*c]P;
pub extern fn pbkwd(p: [*c]P, n: off_t) [*c]P;
pub extern fn pfind(p: [*c]P, s: [*c]const u8, len: ptrdiff_t) [*c]P;
pub extern fn pifind(p: [*c]P, s: [*c]const u8, len: ptrdiff_t) [*c]P;
pub extern fn prfind(p: [*c]P, s: [*c]const u8, len: ptrdiff_t) [*c]P;
pub extern fn prifind(p: [*c]P, s: [*c]const u8, len: ptrdiff_t) [*c]P;
pub extern fn brvs(p: [*c]P, size: off_t) [*c]u8;
pub extern fn bdel(from: [*c]P, to: [*c]P) void;
pub extern fn binsb(p: [*c]P, b: [*c]B) void;
pub extern fn binsc(p: [*c]P, c: c_int) void;
pub extern fn binsm(p: [*c]P, blk: [*c]const u8, size: ptrdiff_t) void;
pub extern fn binss(p: [*c]P, s: [*c]const u8) void;
pub extern fn bcpy(from: [*c]P, to: [*c]P) [*c]B;
pub extern fn brm(b: [*c]B) void;
pub extern fn bafter(b: [*c]B) [*c]B;
pub extern fn beafter(b: [*c]B) [*c]B;
pub extern fn joe_regcomp(charmap: [*c]struct_charmap, s: [*c]const u8, len: ptrdiff_t, icase: c_int, stdfmt: c_int, debug: c_int) [*c]struct_regcomp;
pub extern fn joe_regfree(r: [*c]struct_regcomp) void;
pub extern fn joe_regexec(r: [*c]struct_regcomp, p: [*c]P, nmatch: c_int, matches: [*c]struct_regmatch, eflags: c_int) c_int;
pub extern fn escape(utf8: c_int, ptr: [*c][*c]const u8, len: [*c]ptrdiff_t, cat: [*c]?*struct_Cclass) c_int;
pub extern fn utf8_encode(buf: [*c]u8, c: c_int) ptrdiff_t;
pub extern fn fwrd_c(map: [*c]struct_charmap, s: [*c][*c]const u8, len: [*c]ptrdiff_t) c_int;
pub extern fn markv(r: c_int) c_int;
pub extern fn yncheck(string: [*c]const u8, c: c_int) c_int;
pub extern fn modify_logic(bw: [*c]BW, b: [*c]B) c_int;
pub extern fn uundo(w: [*c]W, k: c_int) c_int;
pub extern fn nungetc(c: c_int) void;
pub extern fn dofollows() void;
pub extern fn ttflsh() void;
pub extern fn regsub(z: [*c][*c]u8, len: ptrdiff_t, s: [*c]u8) [*c][*c]u8;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn parse_ws(p: [*c][*c]const u8, cmt: c_int) c_int;
pub extern fn parse_kw(p: [*c][*c]const u8, kw: [*c]const u8) c_int;
pub extern fn parse_int(p: [*c][*c]const u8, buf: [*c]c_int) c_int;
pub extern fn parse_string(p: [*c][*c]const u8, buf: [*c]u8, len: ptrdiff_t) ptrdiff_t;
pub extern fn emit_string(f: ?*FILE, s: [*c]const u8, len: ptrdiff_t) void;
pub extern var markb: [*c]P;
pub extern var markk: [*c]P;
pub extern var locale_map: [*c]struct_charmap;
pub extern var square: c_int;
pub extern var yes_key: [*c]const u8;
pub extern var no_key: [*c]const u8;
pub extern var opt_mid: c_int;
pub extern var berror: c_int;
pub const msgs: [*c]const [*c]const u8 = @extern([*c]const [*c]const u8, .{
    .name = "msgs",
});
pub extern var obufp: ptrdiff_t;
pub extern var obufsiz: ptrdiff_t;
pub extern var obuf: [*c]u8;
pub fn clrcomp(arg_srch: [*c]SRCH) callconv(.c) void {
    var srch = arg_srch;
    _ = &srch;
    if (srch.*.comp != null) {
        joe_regfree(srch.*.comp);
        srch.*.comp = null;
    }
}
pub fn get_word_list(arg_b_1: [*c]B, arg_ignore: off_t) callconv(.c) [*c][*c]u8 {
    var b_1 = arg_b_1;
    _ = &b_1;
    var ignore = arg_ignore;
    _ = &ignore;
    var buf: [64]u8 = undefined;
    _ = &buf;
    var s: [*c]u8 = undefined;
    _ = &s;
    var list: [*c][*c]u8 = null;
    _ = &list;
    var h: [*c]HASH = undefined;
    _ = &h;
    var t: [*c]HENTRY = undefined;
    _ = &t;
    var p_2: [*c]P = undefined;
    _ = &p_2;
    var c: c_int = undefined;
    _ = &c;
    var idx: ptrdiff_t = undefined;
    _ = &idx;
    var start: off_t = 0;
    _ = &start;
    h = htmk(1024);
    p_2 = pdup(b_1.*.bof, "get_word_list");
    idx = 0;
    while (true) {
        c = pgetc(p_2);
        if (idx != 0) {
            if (b_1.*.o.charmap.*.is_alnum_.?(b_1.*.o.charmap, c) != 0) {
                if (b_1.*.o.charmap.*.type != 0) {
                    if (idx < @as(ptrdiff_t, MAX_WORD_SIZE - @as(c_int, 8))) {
                        idx += utf8_encode(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(idx)))), c);
                    }
                } else {
                    if (idx != @as(ptrdiff_t, MAX_WORD_SIZE)) {
                        buf[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &idx;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = @as(u8, @bitCast(@as(i8, @truncate(c))));
                    }
                }
            } else {
                if ((idx != @as(ptrdiff_t, MAX_WORD_SIZE)) and (start != ignore)) {
                    buf[@bitCast(@as(isize, @intCast(idx)))] = 0;
                    if (!(htfind(h, @ptrCast(@alignCast(&buf))) != null)) {
                        s = vsncpy(null, 0, @ptrCast(@alignCast(&buf)), idx);
                        _ = htadd(h, s, @ptrCast(@alignCast(s)));
                    }
                }
                idx = 0;
            }
        } else {
            start = p_2.*.byte - @as(off_t, 1);
            if (b_1.*.o.charmap.*.is_alpha_.?(b_1.*.o.charmap, c) != 0) {
                if (b_1.*.o.charmap.*.type != 0) {
                    idx += utf8_encode(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(idx)))), c);
                } else {
                    buf[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &idx;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = @as(u8, @bitCast(@as(i8, @truncate(c))));
                }
            }
        }
        if (!(c != -@as(c_int, 256))) break;
    }
    prm(p_2);
    {
        idx = 0;
        while (idx != h.*.len) : (idx += 1) {
            t = h.*.tab[@bitCast(@as(isize, @intCast(idx)))];
            while (t != null) : (t = t.*.next) {
                list = vaadd(list, @ptrCast(@alignCast(t.*.val)));
            }
        }
    }
    if (list != null) {
        _ = vasort(list, if (list != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(list))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    }
    htrm(h);
    return list;
}
pub fn fcmplt_ins(arg_bw_1: [*c]BW, arg_line: [*c]u8) callconv(.c) void {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var line = arg_line;
    _ = &line;
    var p_2: [*c]P = undefined;
    _ = &p_2;
    var c: c_int = undefined;
    _ = &c;
    if (!(piseol(bw_1.*.cursor) != 0)) {
        c = brch(bw_1.*.cursor);
        if (bw_1.*.b.*.o.charmap.*.is_alnum_.?(bw_1.*.b.*.o.charmap, c) != 0) return;
    }
    p_2 = pdup(bw_1.*.cursor, "fcmplt_ins");
    while (true) {
        c = prgetc(p_2);
        if (!(bw_1.*.b.*.o.charmap.*.is_alnum_.?(bw_1.*.b.*.o.charmap, c) != 0)) break;
    }
    if (c != -@as(c_int, 256)) {
        _ = pgetc(p_2);
    }
    if ((bw_1.*.cursor.*.byte != p_2.*.byte) and ((bw_1.*.cursor.*.byte - p_2.*.byte) < @as(off_t, 64))) {
        bdel(p_2, bw_1.*.cursor);
        binsm(bw_1.*.cursor, line, if (line != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(line))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        _ = pfwrd(bw_1.*.cursor, if (line != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(line))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
        prm(p_2);
    } else {
        prm(p_2);
    }
}
pub fn fcmplt_abrt(arg_w: [*c]W, arg_x: ptrdiff_t, arg_obj: ?*anyopaque) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var x = arg_x;
    _ = &x;
    var obj = arg_obj;
    _ = &obj;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var line: [*c]u8 = @ptrCast(@alignCast(obj));
    _ = &line;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (line != null) {
        fcmplt_ins(bw_1, line);
        vsrm(line);
    }
    return -@as(c_int, 1);
}
pub fn fcmplt_rtn(arg_m: [*c]MENU, arg_x: ptrdiff_t, arg_obj: ?*anyopaque, arg_k: c_int) callconv(.c) c_int {
    var m = arg_m;
    _ = &m;
    var x = arg_x;
    _ = &x;
    var obj = arg_obj;
    _ = &obj;
    var k = arg_k;
    _ = &k;
    var line: [*c]u8 = @ptrCast(@alignCast(obj));
    _ = &line;
    fcmplt_ins(@ptrCast(@alignCast(m.*.parent.*.win.*.object)), m.*.list[@bitCast(@as(isize, @intCast(x)))]);
    vsrm(line);
    m.*.object = null;
    _ = wabort(m.*.parent);
    return 0;
}
pub fn srch_cmplt(arg_bw_1: [*c]BW, arg_k: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    if (word_list != null) {
        varm(word_list);
    }
    word_list = get_word_list(@as([*c]BW, @ptrCast(@alignCast(bw_1.*.parent.*.win.*.object))).*.b, -@as(c_int, 1));
    if (!(word_list != null)) {
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
    return simple_cmplt(bw_1, word_list);
}
pub fn searchf(arg_bw_1: [*c]BW, arg_srch: [*c]SRCH, arg_p_2: [*c]P) callconv(.c) [*c]P {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var srch = arg_srch;
    _ = &srch;
    var p_2 = arg_p_2;
    _ = &p_2;
    var start: [*c]P = undefined;
    _ = &start;
    var end: [*c]P = undefined;
    _ = &end;
    var flag: c_int = 0;
    _ = &flag;
    start = pdup(p_2, "searchf");
    end = pdup(p_2, "searchf");
    while (true) {
        var try_again: c_int = undefined;
        _ = &try_again;
        while (true) {
            try_again = 0;
            while ((if (srch.*.ignore != 0) pifind(start, srch.*.comp.*.prefix, srch.*.comp.*.prefix_len) else pfind(start, srch.*.comp.*.prefix, srch.*.comp.*.prefix_len)) != null) {
                pset(end, start);
                if ((srch.*.wrap_flag != 0) and (start.*.byte >= srch.*.wrap_p.*.byte)) break;
                if (!(joe_regexec(srch.*.comp, end, NMATCHES, @ptrCast(@alignCast(&srch.*.pieces)), srch.*.ignore) != 0)) {
                    if ((end.*.byte == srch.*.last_repl) and !(flag != 0)) {
                        pset(start, p_2);
                        if (pgetc(start) == -@as(c_int, 256)) break;
                        pset(end, start);
                        flag += 1;
                        try_again = 1;
                        break;
                    } else {
                        srch.*.entire.rm_so = start.*.byte;
                        srch.*.entire.rm_eo = end.*.byte;
                        pset(p_2, end);
                        prm(start);
                        prm(end);
                        srch.*.last_repl = p_2.*.byte;
                        return p_2;
                    }
                }
                if (pgetc(start) == -@as(c_int, 256)) break;
            }
            if (!(try_again != 0)) break;
        }
        if (((srch.*.allow_wrap != 0) and !(srch.*.wrap_flag != 0)) and (srch.*.wrap_p != null)) {
            msgnw(bw_1.*.parent, my_gettext("Wrapped"));
            srch.*.wrap_flag = 1;
            _ = p_goto_bof(start);
            continue;
        }
        break;
    }
    srch.*.last_repl = -@as(c_int, 1);
    prm(start);
    prm(end);
    return null;
}
pub fn searchb(arg_bw_1: [*c]BW, arg_srch: [*c]SRCH, arg_p_2: [*c]P) callconv(.c) [*c]P {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var srch = arg_srch;
    _ = &srch;
    var p_2 = arg_p_2;
    _ = &p_2;
    var start: [*c]P = undefined;
    _ = &start;
    var end: [*c]P = undefined;
    _ = &end;
    var flag: c_int = 0;
    _ = &flag;
    start = pdup(p_2, "searchb");
    end = pdup(p_2, "searchb");
    while (true) {
        var try_again: c_int = undefined;
        _ = &try_again;
        while (true) {
            try_again = 0;
            while ((pbkwd(start, 1) != null) and ((if (srch.*.ignore != 0) prifind(start, srch.*.comp.*.prefix, srch.*.comp.*.prefix_len) else prfind(start, srch.*.comp.*.prefix, srch.*.comp.*.prefix_len)) != null)) {
                pset(end, start);
                if ((srch.*.wrap_flag != 0) and (start.*.byte < srch.*.wrap_p.*.byte)) break;
                if (!(joe_regexec(srch.*.comp, end, NMATCHES, @ptrCast(@alignCast(&srch.*.pieces)), srch.*.ignore) != 0)) {
                    if ((start.*.byte == srch.*.last_repl) and !(flag != 0)) {
                        pset(start, p_2);
                        if (prgetc(start) == -@as(c_int, 256)) break;
                        pset(end, start);
                        flag += 1;
                        try_again = 1;
                        break;
                    } else {
                        srch.*.entire.rm_so = start.*.byte;
                        srch.*.entire.rm_eo = end.*.byte;
                        pset(p_2, start);
                        prm(start);
                        prm(end);
                        return p_2;
                    }
                }
            }
            if (!(try_again != 0)) break;
        }
        if (((srch.*.allow_wrap != 0) and !(srch.*.wrap_flag != 0)) and (srch.*.wrap_p != null)) {
            msgnw(bw_1.*.parent, my_gettext("Wrapped"));
            srch.*.wrap_flag = 1;
            _ = p_goto_eof(start);
            continue;
        }
        break;
    }
    srch.*.last_repl = -@as(c_int, 1);
    prm(start);
    prm(end);
    return null;
}
pub fn setmark(arg_srch: [*c]SRCH) callconv(.c) [*c]SRCH {
    var srch = arg_srch;
    _ = &srch;
    if (markv(0) != 0) {
        srch.*.valid = 1;
    }
    srch.*.markb = markb;
    if (srch.*.markb != null) {
        srch.*.markb.*.owner = &srch.*.markb;
    }
    markb = null;
    srch.*.markk = markk;
    if (srch.*.markk != null) {
        srch.*.markk.*.owner = &srch.*.markk;
    }
    markk = null;
    return srch;
}
pub fn insert(arg_srch: [*c]SRCH, arg_p_1: [*c]P, arg_s: [*c]const u8, arg_len: ptrdiff_t, arg_entire: [*c][*c]B, arg_pieces: [*c][*c]B) callconv(.c) [*c]P {
    var srch = arg_srch;
    _ = &srch;
    var p_1 = arg_p_1;
    _ = &p_1;
    var s = arg_s;
    _ = &s;
    var len = arg_len;
    _ = &len;
    var entire = arg_entire;
    _ = &entire;
    var pieces = arg_pieces;
    _ = &pieces;
    var x: ptrdiff_t = undefined;
    _ = &x;
    var starting: off_t = p_1.*.byte;
    _ = &starting;
    var nth: c_int = undefined;
    _ = &nth;
    var case_flag: c_int = 0;
    _ = &case_flag;
    var b_2: [*c]B = undefined;
    _ = &b_2;
    while (len != 0) {
        {
            x = 0;
            while ((x != len) and (@as(c_int, s[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\\'))) : (x += 1) {}
        }
        if (x != 0) {
            var t: [*c]const u8 = s;
            _ = &t;
            var y: ptrdiff_t = x;
            _ = &y;
            while (true) {
                switch (case_flag) {
                    @as(c_int, 1) => {
                        {
                            case_flag = 0;
                        }
                        {
                            while (y != 0) {
                                var ch: c_int = fwrd_c(p_1.*.b.*.o.charmap, &t, &y);
                                _ = &ch;
                                ch = p_1.*.b.*.o.charmap.*.to_lower.?(p_1.*.b.*.o.charmap, ch);
                                binsc(p_1, ch);
                                _ = pgetc(p_1);
                            }
                            break;
                        }
                    },
                    @as(c_int, 2) => {
                        {
                            while (y != 0) {
                                var ch: c_int = fwrd_c(p_1.*.b.*.o.charmap, &t, &y);
                                _ = &ch;
                                ch = p_1.*.b.*.o.charmap.*.to_lower.?(p_1.*.b.*.o.charmap, ch);
                                binsc(p_1, ch);
                                _ = pgetc(p_1);
                            }
                            break;
                        }
                    },
                    -@as(c_int, 1) => {
                        {
                            case_flag = 0;
                        }
                        {
                            while (y != 0) {
                                var ch: c_int = fwrd_c(p_1.*.b.*.o.charmap, &t, &y);
                                _ = &ch;
                                ch = p_1.*.b.*.o.charmap.*.to_upper.?(p_1.*.b.*.o.charmap, ch);
                                binsc(p_1, ch);
                                _ = pgetc(p_1);
                            }
                            break;
                        }
                    },
                    -@as(c_int, 2) => {
                        {
                            while (y != 0) {
                                var ch: c_int = fwrd_c(p_1.*.b.*.o.charmap, &t, &y);
                                _ = &ch;
                                ch = p_1.*.b.*.o.charmap.*.to_upper.?(p_1.*.b.*.o.charmap, ch);
                                binsc(p_1, ch);
                                _ = pgetc(p_1);
                            }
                            break;
                        }
                    },
                    else => {},
                }
                break;
            }
            if (y != 0) {
                binsm(p_1, t, y);
                _ = pfwrd(p_1, y);
            }
            len -= x;
            s += @as(usize, @bitCast(@as(isize, @intCast(x))));
        } else if (len >= @as(ptrdiff_t, 2)) {
            if (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'l')) {
                case_flag = 1;
                s += @as(usize, @bitCast(@as(isize, @intCast(2))));
                len -= 2;
            } else if (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'L')) {
                case_flag = 2;
                s += @as(usize, @bitCast(@as(isize, @intCast(2))));
                len -= 2;
            } else if (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'u')) {
                case_flag = -@as(c_int, 1);
                s += @as(usize, @bitCast(@as(isize, @intCast(2))));
                len -= 2;
            } else if (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'U')) {
                case_flag = -@as(c_int, 2);
                s += @as(usize, @bitCast(@as(isize, @intCast(2))));
                len -= 2;
            } else if (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'E')) {
                case_flag = 0;
                s += @as(usize, @bitCast(@as(isize, @intCast(2))));
                len -= 2;
            } else if ((@as(c_int, s[@as(c_int, 1)]) >= @as(c_int, '1')) and (@as(c_int, s[@as(c_int, 1)]) <= @as(c_int, '9'))) {
                nth = @as(c_int, s[@as(c_int, 1)]) - @as(c_int, '1');
                s += @as(usize, @bitCast(@as(isize, @intCast(2))));
                len -= 2;
                if (pieces[@bitCast(@as(isize, @intCast(nth)))] != null) {
                    b_2 = bcpy(pieces[@bitCast(@as(isize, @intCast(nth)))].*.bof, pieces[@bitCast(@as(isize, @intCast(nth)))].*.eof);
                    if (case_flag != 0) {
                        var q: [*c]P = pdup(b_2.*.bof, "insert");
                        _ = &q;
                        while (!(piseof(q) != 0)) {
                            var ch: c_int = pgetc(q);
                            _ = &ch;
                            while (true) {
                                switch (case_flag) {
                                    @as(c_int, 1) => {
                                        {
                                            case_flag = 0;
                                        }
                                        {
                                            ch = p_1.*.b.*.o.charmap.*.to_lower.?(p_1.*.b.*.o.charmap, ch);
                                            break;
                                        }
                                    },
                                    @as(c_int, 2) => {
                                        {
                                            ch = p_1.*.b.*.o.charmap.*.to_lower.?(p_1.*.b.*.o.charmap, ch);
                                            break;
                                        }
                                    },
                                    -@as(c_int, 1) => {
                                        {
                                            case_flag = 0;
                                        }
                                        {
                                            ch = p_1.*.b.*.o.charmap.*.to_upper.?(p_1.*.b.*.o.charmap, ch);
                                            break;
                                        }
                                    },
                                    -@as(c_int, 2) => {
                                        {
                                            ch = p_1.*.b.*.o.charmap.*.to_upper.?(p_1.*.b.*.o.charmap, ch);
                                            break;
                                        }
                                    },
                                    else => {},
                                }
                                break;
                            }
                            binsc(p_1, ch);
                            _ = pgetc(p_1);
                        }
                        prm(q);
                        brm(b_2);
                    } else {
                        var l: off_t = b_2.*.eof.*.byte;
                        _ = &l;
                        binsb(p_1, b_2);
                        _ = pfwrd(p_1, l);
                    }
                }
            } else if (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, '&')) {
                s += @as(usize, @bitCast(@as(isize, @intCast(2))));
                len -= 2;
                if (entire.* != null) {
                    b_2 = bcpy(entire[@as(c_int, 0)].*.bof, entire[@as(c_int, 0)].*.eof);
                    if (case_flag != 0) {
                        var q: [*c]P = pdup(b_2.*.bof, "insert");
                        _ = &q;
                        while (!(piseof(q) != 0)) {
                            var ch: c_int = pgetc(q);
                            _ = &ch;
                            while (true) {
                                switch (case_flag) {
                                    @as(c_int, 1) => {
                                        {
                                            case_flag = 0;
                                        }
                                        {
                                            ch = p_1.*.b.*.o.charmap.*.to_lower.?(p_1.*.b.*.o.charmap, ch);
                                            break;
                                        }
                                    },
                                    @as(c_int, 2) => {
                                        {
                                            ch = p_1.*.b.*.o.charmap.*.to_lower.?(p_1.*.b.*.o.charmap, ch);
                                            break;
                                        }
                                    },
                                    -@as(c_int, 1) => {
                                        {
                                            case_flag = 0;
                                        }
                                        {
                                            ch = p_1.*.b.*.o.charmap.*.to_upper.?(p_1.*.b.*.o.charmap, ch);
                                            break;
                                        }
                                    },
                                    -@as(c_int, 2) => {
                                        {
                                            ch = p_1.*.b.*.o.charmap.*.to_upper.?(p_1.*.b.*.o.charmap, ch);
                                            break;
                                        }
                                    },
                                    else => {},
                                }
                                break;
                            }
                            binsc(p_1, ch);
                            _ = pgetc(p_1);
                        }
                        prm(q);
                        brm(b_2);
                    } else {
                        var l: off_t = b_2.*.eof.*.byte;
                        _ = &l;
                        binsb(p_1, b_2);
                        _ = pfwrd(p_1, l);
                    }
                }
            } else {
                var a: [*c]const u8 = s + @as(usize, @bitCast(@as(isize, @intCast(x))));
                _ = &a;
                var l: ptrdiff_t = len - x;
                _ = &l;
                var ch: c_int = escape(p_1.*.b.*.o.charmap.*.type, &a, &l, null);
                _ = &ch;
                if (ch != -@as(c_int, 256)) {
                    while (true) {
                        switch (case_flag) {
                            @as(c_int, 1) => {
                                {
                                    case_flag = 0;
                                }
                                {
                                    ch = p_1.*.b.*.o.charmap.*.to_lower.?(p_1.*.b.*.o.charmap, ch);
                                    break;
                                }
                            },
                            @as(c_int, 2) => {
                                {
                                    ch = p_1.*.b.*.o.charmap.*.to_lower.?(p_1.*.b.*.o.charmap, ch);
                                    break;
                                }
                            },
                            -@as(c_int, 1) => {
                                {
                                    case_flag = 0;
                                }
                                {
                                    ch = p_1.*.b.*.o.charmap.*.to_upper.?(p_1.*.b.*.o.charmap, ch);
                                    break;
                                }
                            },
                            -@as(c_int, 2) => {
                                {
                                    ch = p_1.*.b.*.o.charmap.*.to_upper.?(p_1.*.b.*.o.charmap, ch);
                                    break;
                                }
                            },
                            else => {},
                        }
                        break;
                    }
                    binsc(p_1, ch);
                    _ = pgetc(p_1);
                }
                len -= @divExact(@as(c_long, @bitCast(@intFromPtr(a) -% @intFromPtr(s))), @sizeOf(u8));
                s = a;
            }
        } else {
            len = 0;
        }
    }
    if (srch.*.backwards != 0) {
        _ = pbkwd(p_1, p_1.*.byte - starting);
    }
    return p_1;
}
pub fn pfabort(arg_w: [*c]W, arg_obj: ?*anyopaque) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var obj = arg_obj;
    _ = &obj;
    var srch: [*c]SRCH = @ptrCast(@alignCast(obj));
    _ = &srch;
    if (srch != null) {
        rmsrch(srch);
    }
    return -@as(c_int, 1);
}
pub fn pfsave(arg_w: [*c]W, arg_obj: ?*anyopaque) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var obj = arg_obj;
    _ = &obj;
    var srch: [*c]SRCH = @ptrCast(@alignCast(obj));
    _ = &srch;
    if (srch != null) {
        if (globalsrch != null) {
            rmsrch(globalsrch);
        }
        globalsrch = srch;
        srch.*.rest = 0;
        srch.*.repeat = -@as(c_int, 1);
        srch.*.flg = 0;
        if ((srch.*.markb != null) or (srch.*.markk != null)) {
            prm(markb);
            prm(markk);
        }
        if (srch.*.markb != null) {
            markb = srch.*.markb;
            markb.*.owner = &markb;
            markb.*.xcol = piscol(markb);
        }
        if (srch.*.markk != null) {
            markk = srch.*.markk;
            markk.*.owner = &markk;
            markk.*.xcol = piscol(markk);
        }
        srch.*.markb = null;
        srch.*.markk = null;
        updall();
    }
    return -@as(c_int, 1);
}
pub fn set_replace(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var obj = arg_obj;
    _ = &obj;
    var notify = arg_notify;
    _ = &notify;
    var srch: [*c]SRCH = @ptrCast(@alignCast(obj));
    _ = &srch;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if ((((if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) != 0) or (@as(ptrdiff_t, @intFromBool(!(globalsrch != null))) != 0)) or !(pico != 0)) {
        srch.*.replacement = s;
    } else {
        srch.*.replacement = s;
    }
    return dopfnext(bw_1, setmark(srch), notify);
}
pub fn set_options(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var obj = arg_obj;
    _ = &obj;
    var notify = arg_notify;
    _ = &notify;
    var srch: [*c]SRCH = @ptrCast(@alignCast(obj));
    _ = &srch;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var buf: [80]u8 = undefined;
    _ = &buf;
    var t: [*c]const u8 = undefined;
    _ = &t;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    srch.*.ignore = opt_icase;
    t = s;
    while (@as(c_int, t.*) != 0) {
        var c: c_int = fwrd_c(locale_map, &t, null);
        _ = &c;
        if (yncheck(all_key, c) != 0) {
            srch.*.all = 1;
        } else if (yncheck(list_key, c) != 0) {
            srch.*.all = 2;
        } else if (yncheck(replace_key, c) != 0) {
            srch.*.replace = 1;
        } else if (yncheck(backwards_key, c) != 0) {
            srch.*.backwards = 1;
        } else if (yncheck(ignore_key, c) != 0) {
            srch.*.ignore = 1;
        } else if (yncheck(noignore_key, c) != 0) {
            srch.*.ignore = 0;
        } else if (yncheck(wrap_key, c) != 0) {
            srch.*.allow_wrap = 1;
        } else if (yncheck(nowrap_key, c) != 0) {
            srch.*.allow_wrap = 0;
        } else if (yncheck(block_key, c) != 0) {
            srch.*.block_restrict = 1;
        } else if (yncheck(regex_key, c) != 0) {
            srch.*.regex = 1;
        } else if (yncheck(regex_debug_key, c) != 0) {
            srch.*.debug = 1;
        } else if (yncheck(noregex_key, c) != 0) {
            srch.*.regex = 0;
        } else if ((c >= @as(c_int, '0')) and (c <= @as(c_int, '9'))) {
            if (srch.*.repeat == -@as(c_int, 1)) {
                srch.*.repeat = 0;
            }
            srch.*.repeat = ((srch.*.repeat * @as(c_int, 10)) + c) - @as(c_int, '0');
        }
    }
    vsrm(s);
    if (srch.*.replace != 0) {
        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), my_gettext("Replace with (%{help} for help): "));
        if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &replhist, set_replace, @ptrCast(@alignCast(&replstr)), pfabort, srch_cmplt, @ptrCast(@alignCast(srch)), notify, bw_1.*.b.*.o.charmap, 0) != null) return 0 else return -@as(c_int, 1);
    } else return dopfnext(bw_1, setmark(srch), notify);
}
pub fn set_pattern(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var obj = arg_obj;
    _ = &obj;
    var notify = arg_notify;
    _ = &notify;
    var srch: [*c]SRCH = @ptrCast(@alignCast(obj));
    _ = &srch;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var pbw: [*c]BW = undefined;
    _ = &pbw;
    var p_2: [*c]const u8 = undefined;
    _ = &p_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (opt_icase != 0) {
        p_2 = my_gettext("case (S)ensitive (R)eplace (B)ackwards Bloc(K) (%{help} for help): ");
    } else {
        p_2 = my_gettext("(I)gnore (R)eplace (B)ackwards Bloc(K) (%{help} for help): ");
    }
    if ((((if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) != 0) or (@as(ptrdiff_t, @intFromBool(!(globalsrch != null))) != 0)) or !(pico != 0)) {
        setpat(srch, s);
    } else {
        vsrm(s);
        setpat(srch, vsdup(globalsrch.*.pattern));
    }
    if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = wmkpw(bw_1.*.parent, p_2, null, set_options, @ptrCast(@alignCast(&srchopt)), pfabort, utypebw, @ptrCast(@alignCast(srch)), notify, locale_map, 0);
        pbw = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        var buf: [16]u8 = undefined;
        _ = &buf;
        if (srch.*.ignore != 0) {
            var t: [*c]const u8 = my_gettext(ignore_key);
            _ = &t;
            binsc(pbw.*.cursor, fwrd_c(locale_map, &t, null));
        }
        if (srch.*.replace != 0) {
            var t: [*c]const u8 = my_gettext(replace_key);
            _ = &t;
            binsc(pbw.*.cursor, fwrd_c(locale_map, &t, null));
        }
        if (srch.*.backwards != 0) {
            var t: [*c]const u8 = my_gettext(backwards_key);
            _ = &t;
            binsc(pbw.*.cursor, fwrd_c(locale_map, &t, null));
        }
        if (srch.*.repeat >= @as(c_int, 0)) {
            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%d", srch.*.repeat);
            binss(pbw.*.cursor, @ptrCast(@alignCast(&buf)));
        }
        pset(pbw.*.cursor, pbw.*.b.*.eof);
        pbw.*.cursor.*.xcol = piscol(pbw.*.cursor);
        srch.*.ignore = 0;
        srch.*.replace = 0;
        srch.*.backwards = 0;
        srch.*.repeat = -@as(c_int, 1);
        return 0;
    } else {
        rmsrch(srch);
        return -@as(c_int, 1);
    }
}
pub fn unesc_genfmt(arg_d: [*c]u8, arg_s: [*c]u8, arg_len: ptrdiff_t, arg_max: ptrdiff_t) callconv(.c) void {
    var d = arg_d;
    _ = &d;
    var s = arg_s;
    _ = &s;
    var len = arg_len;
    _ = &len;
    var max = arg_max;
    _ = &max;
    while ((@as(ptrdiff_t, @intFromBool(max > @as(ptrdiff_t, 0))) != 0) and (len != 0)) {
        if (!(@as(c_int, s.*) != 0)) {
            (blk: {
                const ref = &d;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).* = '\\';
            (blk: {
                const ref = &d;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).* = '@';
            s += 1;
        } else {
            if (@as(c_int, s.*) == @as(c_int, '\\')) {
                (blk: {
                    const ref = &d;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).* = '\\';
                max -= 1;
            }
            (blk: {
                const ref = &d;
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
        len -= 1;
        max -= 1;
    }
    if (len != 0) {
        (blk: {
            const ref = &d;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).* = '$';
    }
    d.* = 0;
}
pub fn doreplace(arg_bw_1: [*c]BW, arg_srch: [*c]SRCH) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var srch = arg_srch;
    _ = &srch;
    var from: [*c]P = undefined;
    _ = &from;
    var to: [*c]P = undefined;
    _ = &to;
    var q: [*c]P = undefined;
    _ = &q;
    var x: c_int = undefined;
    _ = &x;
    var pieces: [26][*c]B = undefined;
    _ = &pieces;
    var entire: [*c]B = undefined;
    _ = &entire;
    if (!(modify_logic(bw_1, bw_1.*.b) != 0)) return -@as(c_int, 1);
    if (markk != null) {
        markk.*.end = 1;
    }
    if (srch.*.markk != null) {
        srch.*.markk.*.end = 1;
    }
    from = pdup(bw_1.*.cursor, "doreplace:from");
    to = pdup(bw_1.*.cursor, "doreplace:to");
    {
        x = 0;
        while (x != NMATCHES) : (x += 1) {
            var m: [*c]Regmatch_t = @ptrCast(@alignCast(@as([*]Regmatch_t, @ptrCast(&srch.*.pieces)) + @as(usize, @intCast(x))));
            _ = &m;
            if (m.*.rm_eo > m.*.rm_so) {
                _ = pgoto(from, m.*.rm_so);
                _ = pgoto(to, m.*.rm_eo);
                pieces[@bitCast(@as(isize, @intCast(x)))] = bcpy(from, to);
            } else {
                pieces[@bitCast(@as(isize, @intCast(x)))] = null;
            }
        }
    }
    if (srch.*.entire.rm_eo > srch.*.entire.rm_so) {
        _ = pgoto(from, srch.*.entire.rm_so);
        _ = pgoto(to, srch.*.entire.rm_eo);
        entire = bcpy(from, to);
    } else {
        entire = null;
    }
    prm(from);
    prm(to);
    q = pdup(bw_1.*.cursor, "doreplace");
    if (srch.*.backwards != 0) {
        q = pfwrd(q, srch.*.entire.rm_eo - srch.*.entire.rm_so);
        bdel(bw_1.*.cursor, q);
        prm(q);
    } else {
        q = pbkwd(q, srch.*.entire.rm_eo - srch.*.entire.rm_so);
        bdel(q, bw_1.*.cursor);
        prm(q);
    }
    _ = insert(srch, bw_1.*.cursor, srch.*.replacement, if (srch.*.replacement != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(srch.*.replacement))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), &entire, @ptrCast(@alignCast(&pieces)));
    {
        x = 0;
        while (x != NMATCHES) : (x += 1) if (pieces[@bitCast(@as(isize, @intCast(x)))] != null) {
            brm(pieces[@bitCast(@as(isize, @intCast(x)))]);
        };
    }
    if (entire != null) {
        brm(entire);
    }
    srch.*.addr = bw_1.*.cursor.*.byte;
    srch.*.last_repl = bw_1.*.cursor.*.byte;
    if (markk != null) {
        markk.*.end = 0;
    }
    if (srch.*.markk != null) {
        srch.*.markk.*.end = 0;
    }
    return 0;
}
pub fn visit(arg_srch: [*c]SRCH, arg_bw_1: [*c]BW, arg_myyn: c_int) callconv(.c) void {
    var srch = arg_srch;
    _ = &srch;
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var myyn = arg_myyn;
    _ = &myyn;
    var r: [*c]SRCHREC = @ptrCast(@alignCast(alitem(@ptrCast(@alignCast(&fsr)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(SRCHREC))))))));
    _ = &r;
    r.*.addr = bw_1.*.cursor.*.byte;
    r.*.yn = myyn;
    r.*.wrap_flag = srch.*.wrap_flag;
    r.*.last_repl = srch.*.last_repl;
    r.*.b = bw_1.*.b;
    while (true) {
        ITEM = @ptrCast(@alignCast(r));
        QUEUE = @ptrCast(@alignCast(&srch.*.recs));
        @as([*c]SRCHREC, @ptrCast(@alignCast(ITEM))).*.link.next = @ptrCast(@alignCast(QUEUE));
        @as([*c]SRCHREC, @ptrCast(@alignCast(ITEM))).*.link.prev = @as([*c]SRCHREC, @ptrCast(@alignCast(QUEUE))).*.link.prev;
        @as([*c]SRCHREC, @ptrCast(@alignCast(QUEUE))).*.link.prev.*.link.next = @ptrCast(@alignCast(ITEM));
        @as([*c]SRCHREC, @ptrCast(@alignCast(QUEUE))).*.link.prev = @ptrCast(@alignCast(ITEM));
        if (!false) break;
    }
}
pub fn goback(arg_srch: [*c]SRCH, arg_bw_1: [*c]BW) callconv(.c) void {
    var srch = arg_srch;
    _ = &srch;
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var r: [*c]SRCHREC = srch.*.recs.link.prev;
    _ = &r;
    if (r != (&srch.*.recs)) {
        srch.*.current = r.*.b;
        if (r.*.yn != 0) {
            _ = uundo(bw_1.*.parent, 0);
        }
        if (r.*.b != bw_1.*.b) {
            var w: [*c]W = bw_1.*.parent;
            _ = &w;
            _ = get_buffer_in_window(bw_1, r.*.b);
            bw_1 = @ptrCast(@alignCast(w.*.object));
        }
        if (bw_1.*.cursor.*.byte != r.*.addr) {
            _ = pgoto(bw_1.*.cursor, r.*.addr);
        }
        srch.*.wrap_flag = r.*.wrap_flag;
        srch.*.last_repl = r.*.last_repl;
        while (true) {
            ITEM = @ptrCast(@alignCast(blk: {
                ITEM = @ptrCast(@alignCast(r));
                @as([*c]SRCHREC, @ptrCast(@alignCast(ITEM))).*.link.prev.*.link.next = @as([*c]SRCHREC, @ptrCast(@alignCast(ITEM))).*.link.next;
                @as([*c]SRCHREC, @ptrCast(@alignCast(ITEM))).*.link.next.*.link.prev = @as([*c]SRCHREC, @ptrCast(@alignCast(ITEM))).*.link.prev;
                break :blk @as(?*anyopaque, @ptrCast(@alignCast(ITEM)));
            }));
            QUEUE = @ptrCast(@alignCast(&fsr));
            @as([*c]SRCHREC, @ptrCast(@alignCast(ITEM))).*.link.next = @ptrCast(@alignCast(QUEUE));
            @as([*c]SRCHREC, @ptrCast(@alignCast(ITEM))).*.link.prev = @as([*c]SRCHREC, @ptrCast(@alignCast(QUEUE))).*.link.prev;
            @as([*c]SRCHREC, @ptrCast(@alignCast(QUEUE))).*.link.prev.*.link.next = @ptrCast(@alignCast(ITEM));
            @as([*c]SRCHREC, @ptrCast(@alignCast(QUEUE))).*.link.prev = @ptrCast(@alignCast(ITEM));
            if (!false) break;
        }
    }
}
pub fn dopfrepl(arg_w: [*c]W, arg_c: c_int, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
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
    var srch: [*c]SRCH = @ptrCast(@alignCast(obj));
    _ = &srch;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    srch.*.addr = bw_1.*.cursor.*.byte;
    if ((((c == -@as(c_int, 20)) or (c == @as(c_int, 8))) or (c == @as(c_int, 127))) or (yncheck(no_key, c) != 0)) return dopfnext(bw_1, srch, notify) else if (((c == -@as(c_int, 10)) or (yncheck(yes_key, c) != 0)) or (c == @as(c_int, ' '))) {
        srch.*.recs.link.prev.*.yn = 1;
        if (doreplace(bw_1, srch) != 0) {
            _ = pfsave(bw_1.*.parent, @ptrCast(@alignCast(srch)));
            return -@as(c_int, 1);
        } else return dopfnext(bw_1, srch, notify);
    } else if ((yncheck(rest_key, c) != 0) or (c == @as(c_int, '!'))) {
        if (doreplace(bw_1, srch) != 0) return -@as(c_int, 1);
        srch.*.rest = 1;
        return dopfnext(bw_1, srch, notify);
    } else if (yncheck(backup_key, c) != 0) {
        var tw_1: [*c]W = bw_1.*.parent;
        _ = &tw_1;
        goback(srch, bw_1);
        goback(srch, @ptrCast(@alignCast(tw_1.*.object)));
        return dopfnext(@ptrCast(@alignCast(tw_1.*.object)), srch, notify);
    } else if (c != -@as(c_int, 1)) {
        if (notify != null) {
            notify.* = 1;
        }
        _ = pfsave(bw_1.*.parent, @ptrCast(@alignCast(srch)));
        nungetc(c);
        return 0;
    }
    if (mkqwnsr(bw_1.*.parent, my_gettext("Replace (Y)es (N)o (R)est (B)ackup (%{abort} to abort)?"), slen(my_gettext("Replace (Y)es (N)o (R)est (B)ackup (%{abort} to abort)?")), dopfrepl, pfsave, @ptrCast(@alignCast(srch)), notify) != null) return 0 else return pfsave(bw_1.*.parent, @ptrCast(@alignCast(srch)));
}
pub fn restrict_to_block(arg_bw_1: [*c]BW, arg_srch: [*c]SRCH) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var srch = arg_srch;
    _ = &srch;
    if (!(srch.*.valid != 0) or !(srch.*.block_restrict != 0)) return 0;
    bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
    if (srch.*.backwards != 0) if (!(square != 0)) {
        if (bw_1.*.cursor.*.byte < srch.*.markb.*.byte) return 1 else if ((bw_1.*.cursor.*.byte + (srch.*.entire.rm_eo - srch.*.entire.rm_so)) > srch.*.markk.*.byte) return -@as(c_int, 1);
    } else {
        if (bw_1.*.cursor.*.line < srch.*.markb.*.line) return 1 else if (bw_1.*.cursor.*.line > srch.*.markk.*.line) return -@as(c_int, 1) else if (((piscol(bw_1.*.cursor) + (srch.*.entire.rm_eo - srch.*.entire.rm_so)) > srch.*.markk.*.xcol) or (piscol(bw_1.*.cursor) < srch.*.markb.*.xcol)) return -@as(c_int, 1);
    } else if (!(square != 0)) {
        if (bw_1.*.cursor.*.byte > srch.*.markk.*.byte) return 1 else if ((bw_1.*.cursor.*.byte - (srch.*.entire.rm_eo - srch.*.entire.rm_so)) < srch.*.markb.*.byte) return -@as(c_int, 1);
    } else {
        if (bw_1.*.cursor.*.line > srch.*.markk.*.line) return 1;
        if (bw_1.*.cursor.*.line < srch.*.markb.*.line) return -@as(c_int, 1);
        if ((piscol(bw_1.*.cursor) > srch.*.markk.*.xcol) or ((piscol(bw_1.*.cursor) - (srch.*.entire.rm_eo - srch.*.entire.rm_so)) < srch.*.markb.*.xcol)) return -@as(c_int, 1);
    }
    return 0;
}
pub fn fnext(arg_bw_1: [*c]BW, arg_srch: [*c]SRCH) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var srch = arg_srch;
    _ = &srch;
    var sta: [*c]P = undefined;
    _ = &sta;
    if (!(srch.*.first != null)) {
        srch.*.first = bw_1.*.b;
        srch.*.current = bw_1.*.b;
    }
    while (true) {
        if (srch.*.repeat != -@as(c_int, 1)) {
            if (!(srch.*.repeat != 0)) return 0 else {
                srch.*.repeat -= 1;
            }
        }
        while (true) {
            if ((srch.*.comp != null) and (srch.*.comp.*.cmap != bw_1.*.b.*.o.charmap)) {
                clrcomp(srch);
                msgnw(bw_1.*.parent, my_gettext("Character set of buffer does not match character set of search string"));
                return 4;
            }
            if (!(srch.*.comp != null)) {
                srch.*.comp = joe_regcomp(bw_1.*.b.*.o.charmap, srch.*.pattern, if (srch.*.pattern != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(srch.*.pattern))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), srch.*.ignore, srch.*.regex, srch.*.debug);
                if (srch.*.comp.*.err != null) {
                    msgnw(bw_1.*.parent, my_gettext(srch.*.comp.*.err));
                    return 4;
                }
            }
            if (srch.*.backwards != 0) {
                sta = searchb(bw_1, srch, bw_1.*.cursor);
            } else {
                sta = searchf(bw_1, srch, bw_1.*.cursor);
            }
            if (!(sta != null) and (srch.*.all != 0)) {
                var b_1: [*c]B = undefined;
                _ = &b_1;
                if (srch.*.all == @as(c_int, 2)) {
                    b_1 = beafter(srch.*.current);
                } else {
                    berror = 0;
                    b_1 = bafter(srch.*.current);
                }
                if (((b_1 != null) and (b_1 != srch.*.first)) and !(berror != 0)) {
                    var w: [*c]W = bw_1.*.parent;
                    _ = &w;
                    srch.*.current = b_1;
                    _ = get_buffer_in_window(bw_1, b_1);
                    bw_1 = @ptrCast(@alignCast(w.*.object));
                    _ = p_goto_bof(bw_1.*.cursor);
                    continue;
                } else if (berror != 0) {
                    msgnw(bw_1.*.parent, my_gettext(msgs[@bitCast(@as(isize, @intCast(-berror)))]));
                }
            }
            if (!(sta != null)) {
                srch.*.repeat = -@as(c_int, 1);
                return 1;
            }
            if ((srch.*.rest != 0) or ((srch.*.repeat != -@as(c_int, 1)) and (srch.*.replace != 0))) {
                if (srch.*.valid != 0) {
                    while (true) {
                        switch (restrict_to_block(bw_1, srch)) {
                            -@as(c_int, 1) => {
                                continue;
                            },
                            @as(c_int, 1) => {
                                if (srch.*.addr >= @as(off_t, 0)) {
                                    _ = pgoto(bw_1.*.cursor, srch.*.addr);
                                }
                                return @intFromBool(!(srch.*.rest != 0));
                            },
                            else => {},
                        }
                        break;
                    }
                }
                if (doreplace(bw_1, srch) != 0) return 0;
                break;
            } else if (srch.*.repeat != -@as(c_int, 1)) {
                if (srch.*.valid != 0) {
                    while (true) {
                        switch (restrict_to_block(bw_1, srch)) {
                            -@as(c_int, 1) => {
                                continue;
                            },
                            @as(c_int, 1) => {
                                if (srch.*.addr >= @as(off_t, 0)) {
                                    _ = pgoto(bw_1.*.cursor, srch.*.addr);
                                }
                                return 1;
                            },
                            else => {},
                        }
                        break;
                    }
                }
                srch.*.addr = bw_1.*.cursor.*.byte;
                break;
            } else return 2;
        }
    }
    return undefined;
}
pub export fn dopfnext(arg_bw_1: [*c]BW, arg_srch: [*c]SRCH, arg_notify: [*c]c_int) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var srch = arg_srch;
    _ = &srch;
    var notify = arg_notify;
    _ = &notify;
    var w: [*c]W = undefined;
    _ = &w;
    var fnr: c_int = undefined;
    _ = &fnr;
    var orgmid: c_int = opt_mid;
    _ = &orgmid;
    var ret: c_int = 0;
    _ = &ret;
    var do_bye: c_int = undefined;
    _ = &do_bye;
    opt_mid = 1;
    if (csmode != 0) {
        smode = 2;
    }
    if (srch.*.replace != 0) {
        visit(srch, bw_1, 0);
    }
    while (true) {
        do_bye = 0;
        w = bw_1.*.parent;
        fnr = fnext(bw_1, srch);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        while (true) {
            switch (fnr) {
                @as(c_int, 0) => {
                    break;
                },
                @as(c_int, 1) => {
                    do_bye = 1;
                    break;
                },
                @as(c_int, 3) => {
                    msgnw(bw_1.*.parent, my_gettext("Infinite loop aborted: your search repeatedly matched same place"));
                    ret = -@as(c_int, 1);
                    break;
                },
                @as(c_int, 4) => {
                    ret = -@as(c_int, 1);
                    break;
                },
                @as(c_int, 2) => {
                    if (srch.*.valid != 0) {
                        while (true) {
                            switch (restrict_to_block(bw_1, srch)) {
                                -@as(c_int, 1) => {
                                    continue;
                                },
                                @as(c_int, 1) => {
                                    if (srch.*.addr >= @as(off_t, 0)) {
                                        _ = pgoto(bw_1.*.cursor, srch.*.addr);
                                    }
                                    do_bye = 1;
                                    break;
                                },
                                else => {},
                            }
                            break;
                        }
                    }
                    if (do_bye != 0) break;
                    srch.*.addr = bw_1.*.cursor.*.byte;
                    if (srch.*.backwards != 0) {
                        bw_1.*.offset = 0;
                        _ = pfwrd(bw_1.*.cursor, srch.*.entire.rm_eo - srch.*.entire.rm_so);
                        bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
                        dofollows();
                        _ = pbkwd(bw_1.*.cursor, srch.*.entire.rm_eo - srch.*.entire.rm_so);
                    } else {
                        bw_1.*.offset = 0;
                        _ = pbkwd(bw_1.*.cursor, srch.*.entire.rm_eo - srch.*.entire.rm_so);
                        bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
                        dofollows();
                        _ = pfwrd(bw_1.*.cursor, srch.*.entire.rm_eo - srch.*.entire.rm_so);
                    }
                    if (srch.*.replace != 0) {
                        if (square != 0) {
                            bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
                        }
                        if (srch.*.backwards != 0) {
                            _ = pdupown(bw_1.*.cursor, &markb, "dopfnext");
                            markb.*.xcol = piscol(markb);
                            _ = pdupown(markb, &markk, "dopfnext");
                            _ = pfwrd(markk, srch.*.entire.rm_eo - srch.*.entire.rm_so);
                            markk.*.xcol = piscol(markk);
                        } else {
                            _ = pdupown(bw_1.*.cursor, &markk, "dopfnext");
                            markk.*.xcol = piscol(markk);
                            _ = pdupown(bw_1.*.cursor, &markb, "dopfnext");
                            _ = pbkwd(markb, srch.*.entire.rm_eo - srch.*.entire.rm_so);
                            markb.*.xcol = piscol(markb);
                        }
                        srch.*.flg = 1;
                        if (dopfrepl(bw_1.*.parent, -@as(c_int, 1), @ptrCast(@alignCast(srch)), notify) != 0) {
                            ret = -@as(c_int, 1);
                        }
                        notify = null;
                        srch = null;
                    }
                    break;
                },
                else => {},
            }
            break;
        }
        if (do_bye != 0) {
            if (!(srch.*.flg != 0) and !(srch.*.rest != 0)) {
                if ((srch.*.valid != 0) and (srch.*.block_restrict != 0)) {
                    msgnw(bw_1.*.parent, my_gettext("Not found (search restricted to marked block)"));
                } else {
                    msgnw(bw_1.*.parent, my_gettext("Not found"));
                }
                ret = -@as(c_int, 1);
            }
        }
        break;
    }
    bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
    dofollows();
    opt_mid = orgmid;
    if (notify != null) {
        notify.* = 1;
    }
    if (srch != null) {
        _ = pfsave(bw_1.*.parent, @ptrCast(@alignCast(srch)));
    } else {
        updall();
    }
    return ret;
}
pub export fn pfnext(arg_w: [*c]W, arg_k: c_int) c_int {
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
    if (!(globalsrch != null)) {
        return pffirst(bw_1.*.parent, 0);
    } else {
        var srch: [*c]SRCH = globalsrch;
        _ = &srch;
        globalsrch = null;
        srch.*.addr = bw_1.*.cursor.*.byte;
        if (!(srch.*.wrap_p != null) or (srch.*.wrap_p.*.b != bw_1.*.b)) {
            prm(srch.*.wrap_p);
            srch.*.wrap_p = pdup(bw_1.*.cursor, "pfnext");
            srch.*.wrap_p.*.owner = &srch.*.wrap_p;
            srch.*.wrap_flag = 0;
        }
        return dopfnext(bw_1, setmark(srch), null);
    }
}
pub export fn setpat(arg_srch: [*c]SRCH, arg_s: [*c]u8) void {
    var srch = arg_srch;
    _ = &srch;
    var s = arg_s;
    _ = &s;
    vsrm(srch.*.pattern);
    srch.*.pattern = s;
    clrcomp(srch);
}
pub export fn mksrch(arg_pattern: [*c]u8, arg_replacement: [*c]u8, arg_ignore: c_int, arg_backwards: c_int, arg_repeat: c_int, arg_replace: c_int, arg_rest: c_int, arg_all: c_int, arg_regex: c_int) [*c]SRCH {
    var pattern = arg_pattern;
    _ = &pattern;
    var replacement = arg_replacement;
    _ = &replacement;
    var ignore = arg_ignore;
    _ = &ignore;
    var backwards = arg_backwards;
    _ = &backwards;
    var repeat = arg_repeat;
    _ = &repeat;
    var replace = arg_replace;
    _ = &replace;
    var rest = arg_rest;
    _ = &rest;
    var all = arg_all;
    _ = &all;
    var regex = arg_regex;
    _ = &regex;
    var srch: [*c]SRCH = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(SRCH))))))));
    _ = &srch;
    var x: c_int = undefined;
    _ = &x;
    srch.*.first = null;
    srch.*.current = null;
    srch.*.all = all;
    srch.*.pattern = pattern;
    srch.*.comp = null;
    srch.*.replacement = replacement;
    srch.*.ignore = ignore;
    srch.*.regex = regex;
    srch.*.debug = 0;
    srch.*.backwards = backwards;
    srch.*.repeat = repeat;
    srch.*.replace = replace;
    srch.*.rest = rest;
    srch.*.flg = 0;
    srch.*.addr = -@as(c_int, 1);
    srch.*.last_repl = -@as(c_int, 1);
    srch.*.markb = null;
    srch.*.markk = null;
    srch.*.wrap_p = null;
    srch.*.allow_wrap = wrap;
    srch.*.wrap_flag = 0;
    srch.*.valid = 0;
    srch.*.block_restrict = 0;
    while (true) {
        QUEUE = @ptrCast(@alignCast(&srch.*.recs));
        @as([*c]SRCHREC, @ptrCast(@alignCast(QUEUE))).*.link.prev = @ptrCast(@alignCast(QUEUE));
        @as([*c]SRCHREC, @ptrCast(@alignCast(QUEUE))).*.link.next = @ptrCast(@alignCast(QUEUE));
        if (!false) break;
    }
    {
        const s: *SRCH = @ptrCast(srch);
        for (&s.pieces) |*m| {
            m.rm_so = -1;
            m.rm_eo = -1;
        }
        s.entire.rm_so = -1;
        s.entire.rm_eo = -1;
    }
    return srch;
}
pub export fn rmsrch(arg_srch: [*c]SRCH) void {
    var srch = arg_srch;
    _ = &srch;
    if (srch.*.comp != null) {
        joe_regfree(srch.*.comp);
    }
    prm(srch.*.wrap_p);
    if ((srch.*.markb != null) or (srch.*.markk != null)) {
        prm(markb);
        prm(markk);
    }
    if (srch.*.markb != null) {
        markb = srch.*.markb;
        markb.*.owner = &markb;
        markb.*.xcol = piscol(markb);
    }
    if (srch.*.markk != null) {
        markk = srch.*.markk;
        markk.*.owner = &markk;
        markk.*.xcol = piscol(markk);
    }
    frchn(@ptrCast(@alignCast(&fsr)), @ptrCast(@alignCast(&srch.*.recs)));
    vsrm(srch.*.pattern);
    vsrm(srch.*.replacement);
    joe_free(@ptrCast(@alignCast(srch)));
    updall();
}
pub export fn dofirst(arg_bw_1: [*c]BW, arg_back: c_int, arg_repl: c_int, arg_hint: [*c]u8) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var back = arg_back;
    _ = &back;
    var repl = arg_repl;
    _ = &repl;
    var hint = arg_hint;
    _ = &hint;
    var srch: [*c]SRCH = undefined;
    _ = &srch;
    var pbw: [*c]BW = undefined;
    _ = &pbw;
    var bf1: [80]u8 = undefined;
    _ = &bf1;
    var buf: [80]u8 = undefined;
    _ = &buf;
    if ((smode != 0) and (globalsrch != null)) {
        globalsrch.*.backwards = back;
        globalsrch.*.replace = repl;
        return pfnext(bw_1.*.parent, 0);
    }
    if (bw_1.*.parent.*.huh == @as([*c]u8, @ptrCast(@alignCast(&srchstr)))) {
        var byte: off_t = undefined;
        _ = &byte;
        p_goto_eol(bw_1.*.cursor);
        byte = bw_1.*.cursor.*.byte;
        p_goto_bol(bw_1.*.cursor);
        if (byte == bw_1.*.cursor.*.byte) {
            _ = prgetc(bw_1.*.cursor);
        }
        return urtn(bw_1.*.parent, -@as(c_int, 1));
    }
    srch = mksrch(null, null, 0, back, -@as(c_int, 1), repl, 0, 0, std_regex);
    srch.*.addr = bw_1.*.cursor.*.byte;
    srch.*.wrap_p = pdup(bw_1.*.cursor, "dofirst");
    srch.*.wrap_p.*.owner = &srch.*.wrap_p;
    if (((pico != 0) and (globalsrch != null)) and (globalsrch.*.pattern != null)) {
        unesc_genfmt(@ptrCast(@alignCast(&bf1)), globalsrch.*.pattern, if (globalsrch.*.pattern != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(globalsrch.*.pattern))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), 30);
        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), my_gettext("Find (%{help} for help) [%s]: "), @as([*c]u8, @ptrCast(@alignCast(&bf1))));
    } else {
        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), my_gettext("Find (%{help} for help): "));
    }
    if ((blk: {
        const tmp = wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &findhist, set_pattern, @ptrCast(@alignCast(&srchstr)), pfabort, srch_cmplt, @ptrCast(@alignCast(srch)), null, bw_1.*.b.*.o.charmap, 0);
        pbw = tmp;
        break :blk tmp;
    }) != null) {
        if (hint != null) {
            binss(pbw.*.cursor, hint);
            pset(pbw.*.cursor, pbw.*.b.*.eof);
            pbw.*.cursor.*.xcol = piscol(pbw.*.cursor);
        }
        return 0;
    } else {
        rmsrch(srch);
        return -@as(c_int, 1);
    }
}
pub export fn pffirst(arg_w: [*c]W, arg_k: c_int) c_int {
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
    return dofirst(bw_1, 0, 0, null);
}
pub export var wrap: c_int = 0;
pub export var smode: c_int = 0;
pub export var csmode: c_int = 0;
pub export var opt_icase: c_int = 0;
pub export var pico: c_int = 0;
pub export var findhist: [*c]B = null;
pub export var replhist: [*c]B = null;
pub export var globalsrch: [*c]SRCH = null;
pub var fsr: SRCHREC linksection("__DATA,__joe_fsr") = SRCHREC{
    .link = struct_unnamed_4{
        .next = &fsr,
        .prev = &fsr,
    },
    .yn = 0,
    .wrap_flag = 0,
    .addr = 0,
    .b = null,
    .last_repl = 0,
};
pub var word_list: [*c][*c]u8 = null;
pub export fn ufinish(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var line: [*c]u8 = undefined;
    _ = &line;
    var line1: [*c]u8 = undefined;
    _ = &line1;
    var lst: [*c][*c]u8 = undefined;
    _ = &lst;
    var p_1: [*c]P = undefined;
    _ = &p_1;
    var c: c_int = undefined;
    _ = &c;
    var m: [*c]MENU = undefined;
    _ = &m;
    var bw_2: [*c]BW = undefined;
    _ = &bw_2;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_2 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (!(piseol(bw_2.*.cursor) != 0)) {
        c = brch(bw_2.*.cursor);
        if (bw_2.*.b.*.o.charmap.*.is_alnum_.?(bw_2.*.b.*.o.charmap, c) != 0) return -@as(c_int, 1);
    }
    p_1 = pdup(bw_2.*.cursor, "ufinish");
    while (true) {
        c = prgetc(p_1);
        if (!(bw_2.*.b.*.o.charmap.*.is_alnum_.?(bw_2.*.b.*.o.charmap, c) != 0)) break;
    }
    if (c != -@as(c_int, 256)) {
        _ = pgetc(p_1);
    }
    if ((bw_2.*.cursor.*.byte != p_1.*.byte) and ((bw_2.*.cursor.*.byte - p_1.*.byte) < @as(off_t, 64))) {
        line = brvs(p_1, bw_2.*.cursor.*.byte - p_1.*.byte);
        if (word_list != null) {
            varm(word_list);
        }
        word_list = get_word_list(bw_2.*.b, p_1.*.byte);
        if (!(word_list != null)) {
            vsrm(line);
            prm(p_1);
            return -@as(c_int, 1);
        }
        line1 = vsncpy(null, 0, line, if (line != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(line))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        line1 = vsadd(line1, '*');
        lst = regsub(word_list, if (word_list != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(word_list))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), line1);
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
        m = mkmenu(bw_2.*.parent, bw_2.*.parent, lst, fcmplt_rtn, fcmplt_abrt, null, 0, @ptrCast(@alignCast(line)), null);
        if (!(m != null)) {
            varm(lst);
            vsrm(line);
            return -@as(c_int, 1);
        }
        if ((if (lst != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(lst))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) == @as(ptrdiff_t, 1)) return fcmplt_rtn(m, 0, @ptrCast(@alignCast(line)), 0) else if (smode != 0) return 0 else {
            var com: [*c]u8 = mcomplete(m);
            _ = &com;
            vsrm(@ptrCast(@alignCast(m.*.object)));
            m.*.object = @ptrCast(@alignCast(com));
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
    } else {
        prm(p_1);
        return -@as(c_int, 1);
    }
    return undefined;
}
pub export var srchstr: [6:0]u8 = "Search".*;
pub export var replstr: [7:0]u8 = "Replace".*;
pub export var srchopt: [13:0]u8 = "SearchOptions".*;
pub export var all_key: [*c]const u8 = "|all files|aA";
pub export var list_key: [*c]const u8 = "|error list files|eE";
pub export var replace_key: [*c]const u8 = "|search and replace|rR";
pub export var backwards_key: [*c]const u8 = "|backwards|bB";
pub export var ignore_key: [*c]const u8 = "|ignore case|iI";
pub export var block_key: [*c]const u8 = "|restrict to highlighted block|kK";
pub export var noignore_key: [*c]const u8 = "|don't ignore case|sS";
pub export var wrap_key: [*c]const u8 = "|wrap|wW";
pub export var nowrap_key: [*c]const u8 = "|don't wrap|nN";
pub export var regex_key: [*c]const u8 = "|regex|xX";
pub export var noregex_key: [*c]const u8 = "|no regex|yY";
pub export var regex_debug_key: [*c]const u8 = "|regex_debug|v";
pub export var std_regex: c_int = 0;
pub export fn prfirst(arg_w: [*c]W, arg_k: c_int) c_int {
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
    return dofirst(bw_1, 1, 0, null);
}
pub export fn pqrepl(arg_w: [*c]W, arg_k: c_int) c_int {
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
    return dofirst(bw_1, 0, 1, null);
}
pub export var rest_key: [*c]const u8 = "|rest of file|rR";
pub export var backup_key: [*c]const u8 = "|backup|bB";
pub export fn save_srch(arg_f: ?*FILE) void {
    var f = arg_f;
    _ = &f;
    if (globalsrch != null) {
        if (globalsrch.*.pattern != null) {
            _ = fprintf(f, "\tpattern ");
            emit_string(f, globalsrch.*.pattern, if (globalsrch.*.pattern != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(globalsrch.*.pattern))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
            _ = fprintf(f, "\n");
        }
        if (globalsrch.*.replacement != null) {
            _ = fprintf(f, "\treplacement ");
            emit_string(f, globalsrch.*.replacement, if (globalsrch.*.replacement != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(globalsrch.*.replacement))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
            _ = fprintf(f, "\n");
        }
        _ = fprintf(f, "\tbackwards %d\n", globalsrch.*.backwards);
        _ = fprintf(f, "\tignore %d\n", globalsrch.*.ignore);
        _ = fprintf(f, "\treplace %d\n", globalsrch.*.replace);
        _ = fprintf(f, "\tblock_restrict %d\n", globalsrch.*.block_restrict);
        _ = fprintf(f, "\tregex %d\n", globalsrch.*.regex);
    }
    _ = fprintf(f, "done\n");
}
pub export fn load_srch(arg_f: ?*FILE) void {
    var f = arg_f;
    _ = &f;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    var bf: [1024]u8 = undefined;
    _ = &bf;
    var pattern: [*c]u8 = null;
    _ = &pattern;
    var replacement: [*c]u8 = null;
    _ = &replacement;
    var backwards: c_int = 0;
    _ = &backwards;
    var ignore: c_int = 0;
    _ = &ignore;
    var regex: c_int = 0;
    _ = &regex;
    var replace: c_int = 0;
    _ = &replace;
    var block_restrict: c_int = 0;
    _ = &block_restrict;
    while ((fgets(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_uint, @truncate(@sizeOf(@TypeOf(buf))))), f) != null) and (strcmp(@ptrCast(@alignCast(&buf)), "done\n") != 0)) {
        var p_1: [*c]const u8 = @ptrCast(@alignCast(&buf));
        _ = &p_1;
        _ = parse_ws(&p_1, '#');
        if (!(parse_kw(&p_1, "pattern") != 0)) {
            var len: ptrdiff_t = undefined;
            _ = &len;
            _ = parse_ws(&p_1, '#');
            bf[@as(c_int, 0)] = 0;
            len = parse_string(&p_1, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))));
            if (len > @as(ptrdiff_t, 0)) {
                pattern = vsncpy(null, 0, @ptrCast(@alignCast(&bf)), len);
            }
        } else if (!(parse_kw(&p_1, "replacement") != 0)) {
            var len: ptrdiff_t = undefined;
            _ = &len;
            _ = parse_ws(&p_1, '#');
            bf[@as(c_int, 0)] = 0;
            len = parse_string(&p_1, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))));
            if (len > @as(ptrdiff_t, 0)) {
                replacement = vsncpy(null, 0, @ptrCast(@alignCast(&bf)), len);
            }
        } else if (!(parse_kw(&p_1, "backwards") != 0)) {
            _ = parse_ws(&p_1, '#');
            _ = parse_int(&p_1, &backwards);
        } else if (!(parse_kw(&p_1, "ignore") != 0)) {
            _ = parse_ws(&p_1, '#');
            _ = parse_int(&p_1, &ignore);
        } else if (!(parse_kw(&p_1, "regex") != 0)) {
            _ = parse_ws(&p_1, '#');
            _ = parse_int(&p_1, &ignore);
        } else if (!(parse_kw(&p_1, "replace") != 0)) {
            _ = parse_ws(&p_1, '#');
            _ = parse_int(&p_1, &replace);
        } else if (!(parse_kw(&p_1, "block_restrict") != 0)) {
            _ = parse_ws(&p_1, '#');
            _ = parse_int(&p_1, &block_restrict);
        }
    }
    globalsrch = mksrch(pattern, replacement, ignore, backwards, -@as(c_int, 1), replace, 0, 0, regex);
    globalsrch.*.block_restrict = block_restrict;
}
