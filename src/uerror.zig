//! Compiler error handler — replaces `joe/uerror.c`.
//!
//! Faithful C-ABI Path A port of JOE error nav (unxterr/uprverr/parserrb/uparserr/ugparse/urelease/ujump/inserr/delerr/abrerr/saverr/beafter/parseone_grep/ucurrent_msg/kill_ansi + errbuf/parserr_homeonly).

const std = @import("std");
const ptrdiff_t = c_long;

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;
const JOE_MSGBUFSIZE: c_int = 300;
const CANFLAG_NORESTART: c_int = 1;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub extern fn strstr(haystack: [*c]const u8, needle: [*c]const u8) [*c]u8;
pub extern fn strchr(s: [*c]const u8, c: c_int) [*c]u8;
pub extern fn strncmp(a: [*c]const u8, b: [*c]const u8, n: c_ulong) c_int;
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
    _pad1: [36]u8 = std.mem.zeroes([36]u8),
    orphan: c_int = 0,
    count: c_int = 0,
    changed: c_int = 0,
    _pad2: [104]u8 = std.mem.zeroes([104]u8),
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
pub const struct_bstack = opaque {};
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
    kbd: ?*KBD = null,
    watom: [*c]const WATOM = null,
    object: ?*anyopaque = null,
    msgt: [*c]const u8 = null,
    msgb: [*c]const u8 = null,
    huh: [*c]const u8 = null,
    notify: [*c]c_int = null,
    bstack: ?*struct_bstack = null,
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
pub const struct_tw = opaque {};
pub const TW = struct_tw;
pub const struct_pw = opaque {};
pub const PW = struct_pw;
pub const struct_menu = opaque {};
pub const MENU = struct_menu;
pub const struct_qw = opaque {};
pub const QW = struct_qw;
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn zncmp(a: [*c]const u8, b: [*c]const u8, len: ptrdiff_t) c_int;
pub extern fn ztoo(s: [*c]const u8) off_t;
pub extern fn vsmk(len: ptrdiff_t) [*c]u8;
pub extern fn vsadd(s: [*c]u8, c: c_int) [*c]u8;
pub extern fn vstrunc(s: [*c]u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsncpy(s: [*c]u8, len: ptrdiff_t, blk: [*c]const u8, blklen: ptrdiff_t) [*c]u8;
pub extern fn vsdup(s: [*c]u8) [*c]u8;
pub extern fn vsrm(s: [*c]u8) void;
pub extern fn alitem(list: ?*anyopaque, itemsize: ptrdiff_t) ?*anyopaque;
pub extern fn updall() void;
pub extern fn msgnw(w: [*c]W, s: [*c]const u8) void;
pub extern fn unmark(w: [*c]W, k: c_int) c_int;
pub extern fn uprevw(w: [*c]W, k: c_int) c_int;
pub extern fn doswitch(w: [*c]W, s: [*c]u8, obj: ?*anyopaque, notify: [*c]c_int) c_int;
pub extern fn setline(b: [*c]B, line: off_t) void;
pub extern fn get_cd(w: [*c]W) [*c]u8;
pub extern fn duplicate_backslashes(s: [*c]const u8, len: ptrdiff_t) [*c]u8;
pub extern fn dofollows() void;
pub extern fn pdup(p: [*c]P, where: [*c]const u8) [*c]P;
pub extern fn prm(p: [*c]P) void;
pub extern fn pset(d: [*c]P, s: [*c]P) void;
pub extern fn p_goto_bol(p: [*c]P) void;
pub extern fn p_goto_eol(p: [*c]P) void;
pub extern fn pgetc(p: [*c]P) c_int;
pub extern fn pline(p: [*c]P, line: off_t) c_int;
pub extern fn piscol(p: [*c]P) off_t;
pub extern fn brvs(p: [*c]P, size: off_t) [*c]u8;
pub extern fn bfind(s: [*c]const u8) [*c]B;
pub extern fn canonical(s: [*c]u8, flags: c_int) [*c]u8;
pub extern fn hack_check(name: [*c]const u8) c_int;
pub extern fn utf8_encode(buf: [*c]u8, c: c_int) ptrdiff_t;
pub extern fn fwrd_c(map: [*c]struct_charmap, s: [*c][*c]const u8, len: [*c]ptrdiff_t) c_int;
pub extern fn markv(r: c_int) c_int;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern var markb: [*c]P;
pub extern var markk: [*c]P;
pub extern var maint: [*c]Screen;
pub extern var msgbuf: [300]u8;
pub extern var berror: c_int;
pub extern var opt_mid: c_int;
pub const ERROR = struct_error;
const struct_unnamed_4 = extern struct {
    next: [*c]ERROR = null,
    prev: [*c]ERROR = null,
};
pub const struct_error = extern struct {
    link: struct_unnamed_4 = std.mem.zeroes(struct_unnamed_4),
    line: off_t = 0,
    org: off_t = 0,
    file: [*c]u8 = null,
    src: off_t = 0,
    msg: [*c]u8 = null,
};
pub export var errors: struct_error linksection("__DATA,__joe_errors") = struct_error{
    .link = struct_unnamed_4{
        .next = &errors,
        .prev = &errors,
    },
    .line = 0,
    .org = 0,
    .file = null,
    .src = 0,
    .msg = null,
};
pub export var errptr: [*c]ERROR linksection("__DATA,__joe_errptr") = &errors;
pub export var errbuf: [*c]B = null;
pub export var parserr_homeonly: c_int = 1;
pub export fn beafter(arg_b_1: [*c]B) [*c]B {
    var b_1 = arg_b_1;
    _ = &b_1;
    var e: [*c]struct_error = undefined;
    _ = &e;
    var name: [*c]const u8 = b_1.*.name;
    _ = &name;
    if (!(name != null)) {
        name = "";
    }
    {
        e = errors.link.next;
        while (e != (&errors)) : (e = e.*.link.next) if (!(strcmp(name, e.*.file) != 0)) break;
    }
    if (e == (&errors)) {
        e = errors.link.next;
    }
    while ((e != (&errors)) and !(strcmp(name, e.*.file) != 0)) {
        e = e.*.link.next;
    }
    berror = 0;
    if (e != (&errors)) {
        b_1 = bfind(e.*.file);
        if (b_1.*.count == @as(c_int, 1)) {
            b_1.*.orphan = 1;
        } else {
            b_1.*.count -= 1;
        }
        return b_1;
    }
    return null;
}
pub export fn inserr(arg_name: [*c]const u8, arg_where: off_t, arg_n: off_t, arg_bol: c_int) void {
    var name = arg_name;
    _ = &name;
    var where = arg_where;
    _ = &where;
    var n = arg_n;
    _ = &n;
    var bol = arg_bol;
    _ = &bol;
    var e: [*c]ERROR = undefined;
    _ = &e;
    if (!(n != 0)) return;
    if (name != null) {
        {
            e = errors.link.next;
            while (e != (&errors)) : (e = e.*.link.next) {
                if (!(strcmp(e.*.file, name) != 0)) {
                    if (e.*.line > where) {
                        e.*.line += n;
                    } else if ((e.*.line == where) and (bol != 0)) {
                        e.*.line += n;
                    }
                }
            }
        }
    }
}
pub export fn delerr(arg_name: [*c]const u8, arg_where: off_t, arg_n: off_t) void {
    var name = arg_name;
    _ = &name;
    var where = arg_where;
    _ = &where;
    var n = arg_n;
    _ = &n;
    var e: [*c]ERROR = undefined;
    _ = &e;
    if (!(n != 0)) return;
    if (name != null) {
        {
            e = errors.link.next;
            while (e != (&errors)) : (e = e.*.link.next) {
                if (!(strcmp(e.*.file, name) != 0)) {
                    if (e.*.line > (where + n)) {
                        e.*.line -= n;
                    } else if (e.*.line > where) {
                        e.*.line = where;
                    }
                }
            }
        }
    }
}
pub export fn abrerr(arg_name: [*c]const u8) void {
    var name = arg_name;
    _ = &name;
    var e: [*c]ERROR = undefined;
    _ = &e;
    if (name != null) {
        e = errors.link.next;
        while (e != (&errors)) : (e = e.*.link.next) if (!(strcmp(e.*.file, name) != 0)) {
            e.*.line = e.*.org;
        };
    }
}
pub export fn saverr(arg_name: [*c]const u8) void {
    var name = arg_name;
    _ = &name;
    var e: [*c]ERROR = undefined;
    _ = &e;
    if (name != null) {
        e = errors.link.next;
        while (e != (&errors)) : (e = e.*.link.next) if (!(strcmp(e.*.file, name) != 0)) {
            e.*.org = e.*.line;
        };
    }
}
pub export var errnodes: ERROR linksection("__DATA,__joe_errnodes") = ERROR{
    .link = struct_unnamed_4{
        .next = &errnodes,
        .prev = &errnodes,
    },
    .line = 0,
    .org = 0,
    .file = null,
    .src = 0,
    .msg = null,
};
pub fn freeerr(arg_n: [*c]ERROR) callconv(.c) void {
    var n = arg_n;
    _ = &n;
    vsrm(n.*.file);
    vsrm(n.*.msg);
    while (true) {
        ITEM = @ptrCast(@alignCast(n));
        QUEUE = @ptrCast(@alignCast(&errnodes));
        @as([*c]ERROR, @ptrCast(@alignCast(ITEM))).*.link.next = @as([*c]ERROR, @ptrCast(@alignCast(QUEUE))).*.link.next;
        @as([*c]ERROR, @ptrCast(@alignCast(ITEM))).*.link.prev = @ptrCast(@alignCast(QUEUE));
        @as([*c]ERROR, @ptrCast(@alignCast(QUEUE))).*.link.next.*.link.prev = @ptrCast(@alignCast(ITEM));
        @as([*c]ERROR, @ptrCast(@alignCast(QUEUE))).*.link.next = @ptrCast(@alignCast(ITEM));
        if (!false) break;
    }
}
pub fn freeall() callconv(.c) c_int {
    var count: c_int = 0;
    _ = &count;
    while (!((blk: {
        QUEUE = @ptrCast(@alignCast(&errors));
        break :blk @intFromBool(@as([*c]ERROR, @ptrCast(@alignCast(QUEUE))) == @as([*c]ERROR, @ptrCast(@alignCast(QUEUE))).*.link.next);
    }) != 0)) {
        freeerr(blk: {
            ITEM = @ptrCast(@alignCast(errors.link.next));
            @as([*c]ERROR, @ptrCast(@alignCast(ITEM))).*.link.prev.*.link.next = @as([*c]ERROR, @ptrCast(@alignCast(ITEM))).*.link.next;
            @as([*c]ERROR, @ptrCast(@alignCast(ITEM))).*.link.next.*.link.prev = @as([*c]ERROR, @ptrCast(@alignCast(ITEM))).*.link.prev;
            break :blk @ptrCast(@alignCast(ITEM));
        });
        count += 1;
    }
    errptr = &errors;
    return count;
}
pub fn parsedir(arg_map: [*c]struct_charmap, arg_s: [*c]const u8, arg_rtn_dir: [*c][*c]u8) callconv(.c) void {
    var map = arg_map;
    _ = &map;
    var s = arg_s;
    _ = &s;
    var rtn_dir = arg_rtn_dir;
    _ = &rtn_dir;
    var u: [*c]const u8 = undefined;
    _ = &u;
    var v: [*c]const u8 = undefined;
    _ = &v;
    var vv: [*c]const u8 = undefined;
    _ = &vv;
    u = strstr(s, "make[");
    if (!(u != null)) return;
    {
        v = s;
        while (v < u) : (v += 1) {
            if ((@as(c_int, v.*) & @as(c_int, 223)) < @as(c_int, 'A')) return;
            if (((@as(c_int, v.*) & @as(c_int, 223)) > @as(c_int, 'Z')) and (@as(c_int, v.*) != @as(c_int, '_'))) return;
        }
    }
    if (!(zncmp(u, "make[", 5) != 0)) {
        var quote: [2][4]u8 = [1][4]u8{std.mem.zeroes([4]u8)} ** 2;
        _ = &quote;
        u = strchr(s, '[') + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))));
        while ((@as(c_int, u.*) >= @as(c_int, '0')) and (@as(c_int, u.*) <= @as(c_int, '9'))) {
            u += 1;
        }
        if (((u == (s + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 5))))))) or (@as(c_int, u[@as(c_int, 0)]) != @as(c_int, ']'))) or (@as(c_int, u[@as(c_int, 1)]) != @as(c_int, ':'))) return;
        while ((@as(c_int, u.*) != 0) and !(@as(c_int, quote[@as(c_int, 0)][@as(c_int, 0)]) != 0)) {
            var c: c_int = fwrd_c(map, &u, null);
            _ = &c;
            while (true) {
                switch (c) {
                    @as(c_int, 34) => {
                        quote[@as(c_int, 0)][@as(c_int, 0)] = '"';
                        break;
                    },
                    @as(c_int, 39) => {
                        quote[@as(c_int, 0)][@as(c_int, 0)] = '\'';
                        break;
                    },
                    @as(c_int, 96) => {
                        quote[@as(c_int, 1)][@as(c_int, 0)] = '`';
                        quote[@as(c_int, 0)][@as(c_int, 0)] = '\'';
                        break;
                    },
                    @as(c_int, 171) => {
                        if (map.*.type != 0) {
                            _ = utf8_encode(@ptrCast(@alignCast(&quote[@as(c_int, 0)])), 187);
                        } else {
                            quote[@as(c_int, 0)][@as(c_int, 0)] = @bitCast(@as(i8, @truncate(@as(c_int, 187))));
                        }
                        break;
                    },
                    @as(c_int, 8220) => {
                        _ = utf8_encode(@ptrCast(@alignCast(&quote[@as(c_int, 0)])), 8221);
                        break;
                    },
                    @as(c_int, 8221) => {
                        _ = utf8_encode(@ptrCast(@alignCast(&quote[@as(c_int, 0)])), 8221);
                        break;
                    },
                    @as(c_int, 8222) => {
                        _ = utf8_encode(@ptrCast(@alignCast(&quote[@as(c_int, 1)])), 8220);
                        _ = utf8_encode(@ptrCast(@alignCast(&quote[@as(c_int, 0)])), 8221);
                        break;
                    },
                    @as(c_int, 12300) => {
                        _ = utf8_encode(@ptrCast(@alignCast(&quote[@as(c_int, 0)])), 12301);
                        break;
                    },
                    else => {},
                }
                break;
            }
        }
        if (!(@as(c_int, quote[@as(c_int, 0)][@as(c_int, 0)]) != 0)) return;
        v = u - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))));
        while (true) {
            vv = strstr(v + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), @ptrCast(@alignCast(&quote[@as(c_int, 0)])));
            if (!(vv != null) and (@as(c_int, quote[@as(c_int, 1)][@as(c_int, 0)]) != 0)) {
                vv = strstr(v + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), @ptrCast(@alignCast(&quote[@as(c_int, 1)])));
            }
            if (vv != null) {
                v = vv;
            }
            if (!(vv != null)) break;
        }
        if (v > (u + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))))) {
            var t: [*c]u8 = rtn_dir.*;
            _ = &t;
            t = vstrunc(t, 0);
            t = vsncpy(t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), @ptrCast(@alignCast(u)), @divExact(@as(c_long, @bitCast(@intFromPtr(v) -% @intFromPtr(u))), @sizeOf(u8)));
            if (((if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, t[@bitCast(@as(isize, @intCast((if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) - @as(ptrdiff_t, 1))))]) != @as(c_int, '/'))) != 0)) {
                t = vsadd(t, '/');
            }
            rtn_dir.* = t;
        }
    }
}
pub fn parseone(arg_map: [*c]struct_charmap, arg_s: [*c]const u8, arg_rtn_name: [*c][*c]u8, arg_rtn_line: [*c]off_t) callconv(.c) void {
    var map = arg_map;
    _ = &map;
    var s = arg_s;
    _ = &s;
    var rtn_name = arg_rtn_name;
    _ = &rtn_name;
    var rtn_line = arg_rtn_line;
    _ = &rtn_line;
    var flg: c_int = undefined;
    _ = &flg;
    var c: c_int = undefined;
    _ = &c;
    var name: [*c]u8 = null;
    _ = &name;
    var line: off_t = -@as(c_int, 1);
    _ = &line;
    var u: [*c]const u8 = undefined;
    _ = &u;
    var v: [*c]const u8 = undefined;
    _ = &v;
    var t: [*c]const u8 = undefined;
    _ = &t;
    v = s;
    flg = 0;
    if (!((((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 'J')) and (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'O'))) and (@as(c_int, s[@as(c_int, 2)]) == @as(c_int, 'E'))) and (@as(c_int, s[@as(c_int, 3)]) == @as(c_int, ':')))) {
        while (true) {
            {
                u = v;
                while ((@as(c_int, u.*) != 0) and !((blk: {
                    t = u;
                    c = fwrd_c(map, &t, null);
                    break :blk @intFromBool(((((c >= @as(c_int, 0)) and (map.*.is_alnum_.?(map, c) != 0)) or (c == @as(c_int, '.'))) or (c == @as(c_int, '/'))) or (c == @as(c_int, '~')));
                }) != 0)) : (u = t) {}
            }
            {
                v = u;
                while ((blk: {
                    t = v;
                    c = fwrd_c(map, &t, null);
                    break :blk @intFromBool((((((c >= @as(c_int, 0)) and (map.*.is_alnum_.?(map, c) != 0)) or (c == @as(c_int, '.'))) or (c == @as(c_int, '/'))) or (c == @as(c_int, '-'))) or (c == @as(c_int, '~')));
                }) != 0) : (v = t) if (c == @as(c_int, '.')) {
                    flg = 1;
                };
            }
            if (!(!(flg != 0) and (u != v))) break;
        }
        if (u != v) {
            name = vsncpy(null, 0, u, @divExact(@as(c_long, @bitCast(@intFromPtr(v) -% @intFromPtr(u))), @sizeOf(u8)));
        }
        {
            u = v;
            while ((@as(c_int, u.*) != 0) and ((@as(c_int, u.*) < @as(c_int, '0')) or (@as(c_int, u.*) > @as(c_int, '9')))) : (u += 1) {}
        }
        {
            v = u;
            while ((@as(c_int, v.*) >= @as(c_int, '0')) and (@as(c_int, v.*) <= @as(c_int, '9'))) : (v += 1) {}
        }
        if (u != v) {
            line = ztoo(u);
        }
        if (line != @as(off_t, -@as(c_int, 1))) {
            line -= 1;
        }
        flg = 0;
        while (@as(c_int, v.*) != 0) {
            if (@as(c_int, v.*) == @as(c_int, ':')) {
                flg = 1;
                break;
            }
            v += 1;
        }
    }
    if (!(flg != 0)) {
        line = -@as(c_int, 1);
    }
    rtn_name.* = name;
    rtn_line.* = line;
}
pub fn parseit(arg_map: [*c]struct_charmap, arg_s: [*c]const u8, arg_row: off_t, arg_parseline: ?*const fn (map: [*c]struct_charmap, s: [*c]const u8, rtn_name: [*c][*c]u8, rtn_line: [*c]off_t) callconv(.c) void, arg_current_dir: [*c]u8) callconv(.c) c_int {
    var map = arg_map;
    _ = &map;
    var s = arg_s;
    _ = &s;
    var row = arg_row;
    _ = &row;
    var parseline = arg_parseline;
    _ = &parseline;
    var current_dir = arg_current_dir;
    _ = &current_dir;
    var name: [*c]u8 = null;
    _ = &name;
    var home: [*c]const u8 = @ptrCast(@alignCast(if (parserr_homeonly != 0) @as(?*anyopaque, @ptrCast(@alignCast(getenv("HOME")))) else @as(?*anyopaque, null)));
    _ = &home;
    var line: off_t = -@as(c_int, 1);
    _ = &line;
    var err: [*c]ERROR = undefined;
    _ = &err;
    parseline.?(map, s, &name, &line);
    if (name != null) {
        if (line != @as(off_t, -@as(c_int, 1))) {
            var t: [*c]u8 = undefined;
            _ = &t;
            if ((current_dir != null) and (@as(c_int, name.*) != @as(c_int, '/'))) {
                t = vsncpy(null, 0, current_dir, if (current_dir != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(current_dir))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
                t = vsncpy(t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), name, if (name != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(name))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
                t = canonical(t, CANFLAG_NORESTART);
                vsrm(name);
            } else {
                t = name;
            }
            if (((home != null) and (@as(c_int, t[@as(c_int, 0)]) == @as(c_int, '/'))) and (zncmp(t, home, slen(home)) != 0)) {
                vsrm(t);
                return 0;
            }
            err = @ptrCast(@alignCast(alitem(@ptrCast(@alignCast(&errnodes)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(ERROR))))))));
            err.*.file = t;
            err.*.org = blk: {
                const tmp = line;
                err.*.line = tmp;
                break :blk tmp;
            };
            err.*.src = row;
            err.*.msg = vsncpy(null, 0, "\\i", @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("\\i".*)) / @sizeOf(u8)) -% @as(c_ulong, 1)))));
            t = duplicate_backslashes(s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(@constCast(s)))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
            err.*.msg = vsncpy(err.*.msg, if (err.*.msg != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(err.*.msg))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
            vsrm(t);
            while (true) {
                ITEM = @ptrCast(@alignCast(err));
                QUEUE = @ptrCast(@alignCast(&errors));
                @as([*c]ERROR, @ptrCast(@alignCast(ITEM))).*.link.next = @ptrCast(@alignCast(QUEUE));
                @as([*c]ERROR, @ptrCast(@alignCast(ITEM))).*.link.prev = @as([*c]ERROR, @ptrCast(@alignCast(QUEUE))).*.link.prev;
                @as([*c]ERROR, @ptrCast(@alignCast(QUEUE))).*.link.prev.*.link.next = @ptrCast(@alignCast(ITEM));
                @as([*c]ERROR, @ptrCast(@alignCast(QUEUE))).*.link.prev = @ptrCast(@alignCast(ITEM));
                if (!false) break;
            }
            return 1;
        } else {
            vsrm(name);
        }
    }
    return 0;
}
pub fn parserr(arg_b_1: [*c]B) callconv(.c) off_t {
    var b_1 = arg_b_1;
    _ = &b_1;
    if (markv(1) != 0) {
        var curdir: [*c]u8 = null;
        _ = &curdir;
        var p_1: [*c]P = pdup(markb, "parserr1");
        _ = &p_1;
        var q: [*c]P = pdup(markb, "parserr2");
        _ = &q;
        var nerrs: off_t = 0;
        _ = &nerrs;
        errbuf = markb.*.b;
        _ = freeall();
        p_goto_bol(p_1);
        while (true) {
            var s: [*c]u8 = undefined;
            _ = &s;
            pset(q, p_1);
            p_goto_eol(p_1);
            s = brvs(q, p_1.*.byte - q.*.byte);
            if (s != null) {
                kill_ansi(s);
                parsedir(q.*.b.*.o.charmap, s, &curdir);
                nerrs += parseit(q.*.b.*.o.charmap, s, q.*.line, if (q.*.b.*.parseone != null) q.*.b.*.parseone else parseone, if (curdir != null) curdir else q.*.b.*.current_dir);
                vsrm(s);
            }
            _ = pgetc(p_1);
            if (!(p_1.*.byte < markk.*.byte)) break;
        }
        vsrm(curdir);
        prm(p_1);
        prm(q);
        return nerrs;
    } else {
        var curdir: [*c]u8 = null;
        _ = &curdir;
        var p_1: [*c]P = pdup(b_1.*.bof, "parserr3");
        _ = &p_1;
        var q: [*c]P = pdup(p_1, "parserr4");
        _ = &q;
        var nerrs: off_t = 0;
        _ = &nerrs;
        errbuf = b_1;
        _ = freeall();
        while (true) {
            var s: [*c]u8 = undefined;
            _ = &s;
            pset(q, p_1);
            p_goto_eol(p_1);
            s = brvs(q, p_1.*.byte - q.*.byte);
            if (s != null) {
                kill_ansi(s);
                parsedir(q.*.b.*.o.charmap, s, &curdir);
                nerrs += parseit(q.*.b.*.o.charmap, s, q.*.line, if (q.*.b.*.parseone != null) q.*.b.*.parseone else parseone, if (curdir != null) curdir else q.*.b.*.current_dir);
                vsrm(s);
            }
            if (!(pgetc(p_1) != -@as(c_int, 256))) break;
        }
        vsrm(curdir);
        prm(p_1);
        prm(q);
        return nerrs;
    }
    return undefined;
}
pub fn find_a_good_bw(arg_b_1: [*c]B) callconv(.c) [*c]BW {
    var b_1 = arg_b_1;
    _ = &b_1;
    var w: [*c]W = undefined;
    _ = &w;
    var bw_2: [*c]BW = null;
    _ = &bw_2;
    if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = maint.*.topwin;
        w = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        while (true) {
            if ((((w.*.watom.*.what & TYPETW) != 0) and (@as([*c]BW, @ptrCast(@alignCast(w.*.object))).*.b == b_1)) and (w.*.y >= @as(ptrdiff_t, 0))) {
                bw_2 = @ptrCast(@alignCast(w.*.object));
            }
            w = w.*.link.next;
            if (!(w != maint.*.topwin)) break;
        }
    }
    if (bw_2 != null) return bw_2;
    if (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
        const tmp = maint.*.topwin;
        w = tmp;
        break :blk tmp;
    }))) != @as(?*anyopaque, null)) {
        while (true) {
            if (((w.*.watom.*.what & TYPETW) != 0) and (w.*.y >= @as(ptrdiff_t, 0))) {
                bw_2 = @ptrCast(@alignCast(w.*.object));
            }
            w = w.*.link.next;
            if (!(w != maint.*.topwin)) break;
        }
    }
    return bw_2;
}
pub fn jump_to_file_line(arg_bw_1: [*c]BW, arg_file: [*c]u8, arg_line: off_t, arg_msg: [*c]u8) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var file = arg_file;
    _ = &file;
    var line = arg_line;
    _ = &line;
    var msg = arg_msg;
    _ = &msg;
    var omid: c_int = undefined;
    _ = &omid;
    if (hack_check(file) != 0) return -@as(c_int, 1);
    if (!(bw_1.*.b.*.name != null) or (strcmp(file, bw_1.*.b.*.name) != 0)) {
        if (doswitch(bw_1.*.parent, vsdup(file), null, null) != 0) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(maint.*.curwin.*.object));
    }
    omid = opt_mid;
    opt_mid = 1;
    _ = pline(bw_1.*.cursor, line);
    dofollows();
    opt_mid = omid;
    bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
    msgnw(bw_1.*.parent, msg);
    return 0;
}
pub fn srcherr(arg_bw_1: [*c]BW, arg_file: [*c]u8, arg_line: off_t) callconv(.c) [*c]ERROR {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var file = arg_file;
    _ = &file;
    var line = arg_line;
    _ = &line;
    var p_2: [*c]ERROR = undefined;
    _ = &p_2;
    {
        p_2 = errors.link.next;
        while (p_2 != (&errors)) : (p_2 = p_2.*.link.next) if (!(strcmp(p_2.*.file, file) != 0) and (p_2.*.org == line)) {
            errptr = p_2;
            setline(errbuf, errptr.*.src);
            return errptr;
        };
    }
    return null;
}
pub export fn kill_ansi(arg_s: [*c]u8) void {
    var s = arg_s;
    _ = &s;
    var d: [*c]u8 = s;
    _ = &d;
    while (@as(c_int, s.*) != 0) if (@as(c_int, s.*) == @as(c_int, 27)) {
        while ((@as(c_int, s.*) != 0) and ((((@as(c_int, s.*) == @as(c_int, 27)) or (@as(c_int, s.*) == @as(c_int, '['))) or ((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9')))) or (@as(c_int, s.*) == @as(c_int, ';')))) {
            s += 1;
        }
        if (@as(c_int, s.*) != 0) {
            s += 1;
        }
    } else {
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
    };
    d.* = 0;
}
pub export fn parseone_grep(arg_map: [*c]struct_charmap, arg_s: [*c]const u8, arg_rtn_name: [*c][*c]u8, arg_rtn_line: [*c]off_t) void {
    var map = arg_map;
    _ = &map;
    var s = arg_s;
    _ = &s;
    var rtn_name = arg_rtn_name;
    _ = &rtn_name;
    var rtn_line = arg_rtn_line;
    _ = &rtn_line;
    var y: c_int = undefined;
    _ = &y;
    var name: [*c]u8 = null;
    _ = &name;
    var line: off_t = -@as(c_int, 1);
    _ = &line;
    if (!((((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 'J')) and (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'O'))) and (@as(c_int, s[@as(c_int, 2)]) == @as(c_int, 'E'))) and (@as(c_int, s[@as(c_int, 3)]) == @as(c_int, ':')))) {
        {
            y = 0;
            while ((@as(c_int, s[@bitCast(@as(isize, @intCast(y)))]) != 0) and (@as(c_int, s[@bitCast(@as(isize, @intCast(y)))]) != @as(c_int, ':'))) : (y += 1) {}
        }
        if (y != 0) {
            name = vsncpy(null, 0, s, y);
            line = 0;
            if (@as(c_int, s[@bitCast(@as(isize, @intCast(y)))]) == @as(c_int, ':')) {
                y += 1;
                while ((@as(c_int, s[@bitCast(@as(isize, @intCast(y)))]) >= @as(c_int, '0')) and (@as(c_int, s[@bitCast(@as(isize, @intCast(y)))]) <= @as(c_int, '9'))) {
                    line = (line * @as(off_t, 10)) + @as(off_t, @as(c_int, s[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &y;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ]) - @as(c_int, '0'));
                }
                line -= 1;
                if ((line < @as(off_t, 0)) or (@as(c_int, s[@bitCast(@as(isize, @intCast(y)))]) != @as(c_int, ':'))) {
                    line = 0;
                }
            }
        }
    }
    rtn_name.* = name;
    rtn_line.* = line;
}
pub export fn parserrb(arg_b_1: [*c]B) c_int {
    var b_1 = arg_b_1;
    _ = &b_1;
    var bw_2: [*c]BW = undefined;
    _ = &bw_2;
    var n: off_t = undefined;
    _ = &n;
    _ = freeall();
    bw_2 = find_a_good_bw(b_1);
    _ = unmark(bw_2.*.parent, 0);
    n = parserr(b_1);
    if (n != 0) {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("%d messages found"), @as(c_int, @truncate(n)));
    } else {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(msgbuf)))))))), my_gettext("No messages found"));
    }
    msgnw(bw_2.*.parent, @ptrCast(@alignCast(&msgbuf)));
    return 0;
}
pub export fn urelease(arg_w: [*c]W, arg_k: c_int) c_int {
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
    bw_1.*.b.*.parseone = null;
    if (((blk: {
        QUEUE = @ptrCast(@alignCast(&errors));
        break :blk @intFromBool(@as([*c]ERROR, @ptrCast(@alignCast(QUEUE))) == @as([*c]ERROR, @ptrCast(@alignCast(QUEUE))).*.link.next);
    }) != 0) and !(errbuf != null)) {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(msgbuf)))))))), my_gettext("No messages"));
    } else {
        var count: c_int = freeall();
        _ = &count;
        errbuf = null;
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(msgbuf)))))))), my_gettext("%d messages cleared"), count);
    }
    msgnw(bw_1.*.parent, @ptrCast(@alignCast(&msgbuf)));
    updall();
    return 0;
}
pub export fn uparserr(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var n: off_t = undefined;
    _ = &n;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    _ = freeall();
    bw_1.*.b.*.parseone = parseone;
    n = parserr(bw_1.*.b);
    if (n != 0) {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("%d messages found"), @as(c_int, @truncate(n)));
    } else {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(msgbuf)))))))), my_gettext("No messages found"));
    }
    msgnw(bw_1.*.parent, @ptrCast(@alignCast(&msgbuf)));
    return 0;
}
pub export fn ugparse(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var n: off_t = undefined;
    _ = &n;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    _ = freeall();
    bw_1.*.b.*.parseone = parseone_grep;
    n = parserr(bw_1.*.b);
    if (n != 0) {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("%d messages found"), @as(c_int, @truncate(n)));
    } else {
        _ = snprintf(@ptrCast(@alignCast(&msgbuf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(msgbuf)))))))), my_gettext("No messages found"));
    }
    msgnw(bw_1.*.parent, @ptrCast(@alignCast(&msgbuf)));
    return 0;
}
pub export fn ucurrent_msg(arg_w: [*c]W, arg_k: c_int) c_int {
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
    if (errptr != (&errors)) {
        msgnw(bw_1.*.parent, errptr.*.msg);
        return 0;
    } else {
        msgnw(bw_1.*.parent, my_gettext("No messages"));
        return -@as(c_int, 1);
    }
}
pub export fn ujump(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var curdir: [*c]u8 = null;
    _ = &curdir;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var rtn: c_int = -@as(c_int, 1);
    _ = &rtn;
    var p_2: [*c]P = undefined;
    _ = &p_2;
    var q: [*c]P = undefined;
    _ = &q;
    var s: [*c]u8 = undefined;
    _ = &s;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    p_2 = pdup(bw_1.*.b.*.bof, "ujump");
    q = pdup(p_2, "ujump");
    while (p_2.*.line != bw_1.*.cursor.*.line) {
        pset(q, p_2);
        p_goto_eol(p_2);
        s = brvs(q, p_2.*.byte - q.*.byte);
        if (s != null) {
            kill_ansi(s);
            parsedir(bw_1.*.b.*.o.charmap, s, &curdir);
            vsrm(s);
        }
        if (-@as(c_int, 256) == pgetc(p_2)) break;
    }
    pset(p_2, bw_1.*.cursor);
    pset(q, bw_1.*.cursor);
    p_goto_bol(p_2);
    p_goto_eol(q);
    s = brvs(p_2, q.*.byte - p_2.*.byte);
    prm(p_2);
    prm(q);
    if (s != null) {
        var name: [*c]u8 = null;
        _ = &name;
        var fullname: [*c]u8 = null;
        _ = &fullname;
        var curd: [*c]u8 = get_cd(bw_1.*.parent);
        _ = &curd;
        var line: off_t = -@as(c_int, 1);
        _ = &line;
        kill_ansi(s);
        if (bw_1.*.b.*.parseone != null) {
            bw_1.*.b.*.parseone.?(bw_1.*.b.*.o.charmap, s, &name, &line);
        } else {
            parseone_grep(bw_1.*.b.*.o.charmap, s, &name, &line);
        }
        if (curdir != null) {
            fullname = vsncpy(null, 0, curdir, if (curdir != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(curdir))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        } else {
            fullname = vsncpy(null, 0, curd, if (curd != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(curd))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        }
        fullname = vsncpy(fullname, if (fullname != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullname))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), name, if (name != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(name))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        vsrm(name);
        name = canonical(fullname, CANFLAG_NORESTART);
        if ((name != null) and (line != @as(off_t, -@as(c_int, 1)))) {
            var er: [*c]ERROR = srcherr(bw_1, name, line);
            _ = &er;
            _ = uprevw(bw_1.*.parent, 0);
            if (er != null) {
                rtn = jump_to_file_line(@ptrCast(@alignCast(maint.*.curwin.*.object)), name, er.*.line, null);
            } else {
                rtn = jump_to_file_line(@ptrCast(@alignCast(maint.*.curwin.*.object)), name, line, null);
            }
            vsrm(name);
        }
        vsrm(s);
    }
    vsrm(curdir);
    return rtn;
}
pub export fn unxterr(arg_w: [*c]W, arg_k: c_int) c_int {
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
    if (errptr.*.link.next == (&errors)) {
        msgnw(bw_1.*.parent, my_gettext("No more errors"));
        return -@as(c_int, 1);
    }
    errptr = errptr.*.link.next;
    setline(errbuf, errptr.*.src);
    return jump_to_file_line(bw_1, errptr.*.file, errptr.*.line, null);
}
pub export fn uprverr(arg_w: [*c]W, arg_k: c_int) c_int {
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
    if (errptr.*.link.prev == (&errors)) {
        msgnw(bw_1.*.parent, my_gettext("No more errors"));
        return -@as(c_int, 1);
    }
    errptr = errptr.*.link.prev;
    setline(errbuf, errptr.*.src);
    return jump_to_file_line(bw_1, errptr.*.file, errptr.*.line, null);
}
