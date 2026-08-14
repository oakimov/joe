//! File selection / tab completion — replaces `joe/tab.c`.
//!
//! Faithful C-ABI Path A port of JOE tab completion (`cmplt_file`/`cmplt_file_in`/`cmplt_file_out`/`cmplt_command` + `menu_explorer`/`menu_jump`).

const std = @import("std");
const ptrdiff_t = c_long;

const F_DIR: c_int = 1;
const F_NORMAL: c_int = 2;
const F_EXEC: c_int = 4;
const PATH_QUOTE: c_int = 1;
const PATH_CMD: c_int = 2;
const PATH_EDIT: c_int = 4;
const PATH_SAVE: c_int = 8;
const S_IFMT: c_int = 0o170000;
const S_IFDIR: c_int = 0o040000;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
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
pub const ino_t = u64;
pub const mode_t = c_uint;
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
pub const struct_undo = opaque {};
pub const UNDO = struct_undo;
pub const struct_options = extern struct {
    _pad: [344]u8 = std.mem.zeroes([344]u8),
};
pub const OPTIONS = struct_options;
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
    undo: ?*UNDO = null,
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
    pid: c_int = 0,
    out: c_int = 0,
    vt: ?*anyopaque = null,
    raw: c_int = 0,
    _pad_raw: [4]u8 = std.mem.zeroes([4]u8),
    db: ?*anyopaque = null,
    parseone: ?*const fn (map: [*c]struct_charmap, s: [*c]const u8, rtn_name: [*c][*c]u8, rtn_line: [*c]off_t) callconv(.c) void = null,
};
pub const struct_undorec = opaque {};
pub const UNDOREC = struct_undorec;
pub const struct_kbd = opaque {};
pub const KBD = struct_kbd;
pub const struct_kmap = opaque {};
pub const KMAP = struct_kmap;
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
    kbd: ?*KBD = null,
    watom: [*c]const WATOM = null,
    object: ?*anyopaque = null,
    msgt: [*c]const u8 = null,
    msgb: [*c]const u8 = null,
    huh: [*c]const u8 = null,
    notify: [*c]c_int = null,
    bstack: ?*struct_bstack = null,
};
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
pub const struct_bw = extern struct {
    parent: [*c]W = null,
    b: [*c]B = null,
    top: [*c]P = null,
    cursor: [*c]P = null,
    _pad: [456]u8 = std.mem.zeroes([456]u8),
};
pub const BW = struct_bw;
pub const struct_high_syntax = opaque {};
pub const struct_macro = opaque {};
pub const MACRO = struct_macro;
pub const struct_pw = opaque {};
pub const PW = struct_pw;
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn mset(d: ?*anyopaque, c: u8, sz: ptrdiff_t) ?*anyopaque;
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn vsncpy(s: [*c]u8, len: ptrdiff_t, blk: [*c]const u8, blklen: ptrdiff_t) [*c]u8;
pub extern fn vsadd(s: [*c]u8, ch: u8) [*c]u8;
pub extern fn vsrm(s: [*c]u8) void;
pub extern fn vatrunc(a: [*c][*c]u8, len: ptrdiff_t) [*c][*c]u8;
pub extern fn _vaset(a: [*c][*c]u8, idx: ptrdiff_t, s: [*c]u8) [*c][*c]u8;
pub extern fn varm(a: [*c][*c]u8) void;
pub extern fn vasort(a: [*c][*c]u8, len: ptrdiff_t) void;
pub extern fn vauniq(a: [*c][*c]u8) void;
pub extern fn pdup(p: [*c]P, tr: [*c]const u8) [*c]P;
pub extern fn pset(d: [*c]P, s: [*c]P) [*c]P;
pub extern fn prm(p: [*c]P) void;
pub extern fn p_goto_eol(p: [*c]P) void;
pub extern fn p_goto_bol(p: [*c]P) void;
pub extern fn pgoto(p: [*c]P, loc: off_t) void;
pub extern fn pgetc(p: [*c]P) c_int;
pub extern fn prgetc(p: [*c]P) c_int;
pub extern fn brch(p: [*c]P) c_int;
pub extern fn piscol(p: [*c]P) off_t;
pub extern fn brvs(p: [*c]P, amnt: off_t) [*c]u8;
pub extern fn bdel(from: [*c]P, to: [*c]P) void;
pub extern fn binsm(p: [*c]P, blk: [*c]const u8, amnt: ptrdiff_t) [*c]P;
pub extern fn binsmq(p: [*c]P, blk: [*c]const u8, amnt: ptrdiff_t) [*c]P;
pub extern fn pwd() [*c]u8;
pub extern fn chpwd(path: [*c]const u8) c_int;
pub extern fn rexpnd(word: [*c]const u8) [*c][*c]u8;
pub extern fn rexpnd_users(word: [*c]const u8) [*c][*c]u8;
pub extern fn rexpnd_cmd_cd(word: [*c]const u8) [*c][*c]u8;
pub extern fn rexpnd_cmd_path(word: [*c]const u8) [*c][*c]u8;
pub extern fn namprt(path: [*c]const u8) [*c]u8;
pub extern fn dirprt(path: [*c]const u8) [*c]u8;
pub extern fn begprt(path: [*c]const u8) [*c]u8;
pub extern fn endprt(path: [*c]const u8) [*c]u8;
pub extern fn isreg(s: [*c]const u8) c_int;
pub extern fn canonical(s: [*c]u8, flags: c_int) [*c]u8;
pub extern fn dequotevs(s: [*c]u8) [*c]u8;
pub extern fn mkmenu(loc: [*c]W, targ: [*c]W, s: [*c][*c]u8, func: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque, k: c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, backs: ?*const fn (m: [*c]MENU, cursor: ptrdiff_t, object: ?*anyopaque) callconv(.c) c_int, cursor: ptrdiff_t, object: ?*anyopaque, notify: [*c]c_int) [*c]MENU;
pub extern fn ldmenu(m: [*c]MENU, s: [*c][*c]u8, cursor: ptrdiff_t) void;
pub extern fn mcomplete(m: [*c]MENU) [*c]u8;
pub extern fn wabort(w: [*c]W) c_int;
pub extern fn msgnw(w: [*c]W, s: [*c]const u8) void;
pub extern fn ttflsh() c_int;
pub extern var obuf: [*c]u8;
pub extern var obufp: ptrdiff_t;
pub extern var obufsiz: ptrdiff_t;
inline fn ttputc(c: c_int) void {
    if (obuf == null) return;
    const idx: usize = @intCast(obufp);
    obuf[idx] = @intCast(c);
    obufp += 1;
    if (obufp == obufsiz) _ = ttflsh();
}
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern var watommenu: WATOM;
pub extern var menu_above: c_int;
pub extern var smode: c_int;
pub const struct_tab = extern struct {
    first_len: ptrdiff_t = 0,
    path_loc: [*c]P = null,
    path: [*c]u8 = null,
    pattern: [*c]u8 = null,
    len: ptrdiff_t = 0,
    files: [*c][*c]u8 = null,
    list: [*c][*c]u8 = null,
    type: [*c]u8 = null,
    prv: ino_t = 0,
    orgpath: [*c]u8 = null,
    orgnam: [*c]u8 = null,
    quote: c_int = 0,
    cmd: c_int = 0,
};
pub const TAB = struct_tab;
pub export var menu_explorer: c_int = 0;
pub export var menu_jump: c_int = 0;
pub fn get_entries(arg_tab_1: [*c]TAB, arg_prv: ino_t) callconv(.c) c_int {
    var tab_1 = arg_tab_1;
    _ = &tab_1;
    var prv = arg_prv;
    _ = &prv;
    var a: c_int = undefined;
    _ = &a;
    var which: c_int = 0;
    _ = &which;
    var oldpwd: [*c]u8 = pwd();
    _ = &oldpwd;
    var files: [*c][*c]u8 = undefined;
    _ = &files;
    var tmp: [*c]u8 = undefined;
    _ = &tmp;
    var users_flg: c_int = 0;
    _ = &users_flg;
    var only_cmds: c_int = 0;
    _ = &only_cmds;
    tmp = vsncpy(null, 0, tab_1.*.path, if (tab_1.*.path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tab_1.*.path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    tmp = canonical(tmp, 0);
    if (chpwd(tmp) != 0) {
        vsrm(tmp);
        return -@as(c_int, 1);
    }
    vsrm(tmp);
    if (!(@as(c_int, tab_1.*.path[@as(c_int, 0)]) != 0) and (@as(c_int, tab_1.*.pattern[@as(c_int, 0)]) == @as(c_int, '~'))) {
        files = rexpnd_users(tab_1.*.pattern);
        users_flg = 1;
    } else if (tab_1.*.cmd != 0) {
        if (@as(c_int, tab_1.*.path[@as(c_int, 0)]) != 0) {
            files = rexpnd_cmd_cd(tab_1.*.pattern);
        } else {
            files = rexpnd_cmd_path(tab_1.*.pattern);
            only_cmds = 1;
        }
    } else {
        files = rexpnd(tab_1.*.pattern);
    }
    if (!(files != null)) {
        _ = chpwd(oldpwd);
        return -@as(c_int, 1);
    }
    if (!((if (files != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(files))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) != 0)) {
        _ = chpwd(oldpwd);
        return -@as(c_int, 1);
    }
    vasort(files, if (files != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(files))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    if (only_cmds != 0) {
        vauniq(files);
    }
    tab_1.*.len = if (files != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(files))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0);
    varm(tab_1.*.files);
    tab_1.*.files = files;
    if (tab_1.*.type != null) {
        joe_free(@ptrCast(@alignCast(tab_1.*.type)));
    }
    tab_1.*.type = @ptrCast(@alignCast(joe_malloc(tab_1.*.len)));
    {
        a = 0;
        while (@as(ptrdiff_t, a) != tab_1.*.len) : (a += 1) if (users_flg != 0) {
            tab_1.*.type[@bitCast(@as(isize, @intCast(a)))] = F_DIR;
        } else if (only_cmds != 0) {
            tab_1.*.type[@bitCast(@as(isize, @intCast(a)))] = 0;
        } else {
            var buf: struct_stat = undefined;
            _ = &buf;
            _ = mset(@ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&buf))))), 0, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_stat))))));
            _ = stat(files[@bitCast(@as(isize, @intCast(a)))], &buf);
            if (buf.st_ino == prv) {
                which = a;
            }
            if ((@as(c_int, buf.st_mode) & S_IFMT) == S_IFDIR) {
                tab_1.*.type[@bitCast(@as(isize, @intCast(a)))] = F_DIR;
            } else if ((@as(c_int, buf.st_mode) & ((@as(c_int, 64) | @as(c_int, 8)) | @as(c_int, 1))) != 0) {
                tab_1.*.type[@bitCast(@as(isize, @intCast(a)))] = F_EXEC;
            } else {
                tab_1.*.type[@bitCast(@as(isize, @intCast(a)))] = F_NORMAL;
            }
        };
    }
    _ = chpwd(oldpwd);
    return which;
}
pub fn insnam(arg_bw_1: [*c]BW, arg_path: [*c]u8, arg_nam: [*c]u8, arg_dir: c_int, arg_path_loc: [*c]P, arg_quote: c_int) callconv(.c) void {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var path = arg_path;
    _ = &path;
    var nam = arg_nam;
    _ = &nam;
    var dir = arg_dir;
    _ = &dir;
    var path_loc = arg_path_loc;
    _ = &path_loc;
    var quote = arg_quote;
    _ = &quote;
    var rstr: off_t = path_loc.*.byte;
    _ = &rstr;
    _ = pset(bw_1.*.cursor, path_loc);
    p_goto_eol(bw_1.*.cursor);
    bdel(path_loc, bw_1.*.cursor);
    if ((if (path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) != 0) {
        if (quote != 0) {
            _ = binsmq(bw_1.*.cursor, path, if (path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        } else {
            _ = binsm(bw_1.*.cursor, path, if (path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        }
        p_goto_eol(bw_1.*.cursor);
        if (@as(c_int, path[@bitCast(@as(isize, @intCast((if (path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) - @as(ptrdiff_t, 1))))]) != @as(c_int, '/')) {
            _ = binsm(bw_1.*.cursor, "/", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("/".*)) / @sizeOf(@TypeOf(@constCast("/").*))) -% @as(c_ulong, 1))))));
            p_goto_eol(bw_1.*.cursor);
        }
    }
    if (quote != 0) {
        _ = binsmq(bw_1.*.cursor, nam, if (nam != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(nam))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    } else {
        _ = binsm(bw_1.*.cursor, nam, if (nam != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(nam))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    }
    p_goto_eol(bw_1.*.cursor);
    if (dir != 0) {
        _ = binsm(bw_1.*.cursor, "/", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("/".*)) / @sizeOf(@TypeOf(@constCast("/").*))) -% @as(c_ulong, 1))))));
        p_goto_eol(bw_1.*.cursor);
    }
    pgoto(path_loc, rstr);
    bw_1.*.cursor.*.xcol = piscol(bw_1.*.cursor);
}
pub fn treload(arg_tab_1: [*c]TAB, arg_m: [*c]MENU, arg_bw_2: [*c]BW, arg_flg: c_int, arg_defer: [*c]c_int) callconv(.c) [*c][*c]u8 {
    var tab_1 = arg_tab_1;
    _ = &tab_1;
    var m = arg_m;
    _ = &m;
    var bw_2 = arg_bw_2;
    _ = &bw_2;
    var flg = arg_flg;
    _ = &flg;
    var @"defer" = arg_defer;
    _ = &@"defer";
    var x: c_int = undefined;
    _ = &x;
    var which: c_int = undefined;
    _ = &which;
    var buf: struct_stat = undefined;
    _ = &buf;
    if ((blk: {
        const tmp = get_entries(tab_1, tab_1.*.prv);
        which = tmp;
        break :blk tmp;
    }) < @as(c_int, 0)) return null;
    if ((tab_1.*.path != null) and (@as(c_int, tab_1.*.path[@as(c_int, 0)]) != 0)) {
        _ = stat(tab_1.*.path, &buf);
    } else {
        _ = stat(".", &buf);
    }
    tab_1.*.prv = buf.st_ino;
    if (!(flg != 0)) {
        which = 0;
    }
    tab_1.*.list = vatrunc(tab_1.*.list, if (tab_1.*.files != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tab_1.*.files))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    {
        x = 0;
        while (tab_1.*.files[@bitCast(@as(isize, @intCast(x)))] != null) : (x += 1) {
            var s: [*c]u8 = vsncpy(null, 0, tab_1.*.files[@bitCast(@as(isize, @intCast(x)))], if (tab_1.*.files[@bitCast(@as(isize, @intCast(x)))] != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tab_1.*.files[@bitCast(@as(isize, @intCast(x)))]))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
            _ = &s;
            tab_1.*.list = _vaset(tab_1.*.list, x, s);
            if (@as(c_int, tab_1.*.type[@bitCast(@as(isize, @intCast(x)))]) == F_DIR) {
                tab_1.*.list[@bitCast(@as(isize, @intCast(x)))] = vsadd(tab_1.*.list[@bitCast(@as(isize, @intCast(x)))], '/');
            } else if (@as(c_int, tab_1.*.type[@bitCast(@as(isize, @intCast(x)))]) == F_EXEC) {
                tab_1.*.list[@bitCast(@as(isize, @intCast(x)))] = vsadd(tab_1.*.list[@bitCast(@as(isize, @intCast(x)))], '*');
            }
        }
    }
    if (@"defer" != null) {
        @"defer".* = which;
        return tab_1.*.list;
    } else {
        ldmenu(m, tab_1.*.list, which);
        return tab_1.*.list;
    }
}
pub fn rmtab(arg_tab_1: [*c]TAB) callconv(.c) void {
    var tab_1 = arg_tab_1;
    _ = &tab_1;
    vsrm(tab_1.*.orgpath);
    vsrm(tab_1.*.orgnam);
    varm(tab_1.*.list);
    vsrm(tab_1.*.path);
    vsrm(tab_1.*.pattern);
    varm(tab_1.*.files);
    prm(tab_1.*.path_loc);
    if (tab_1.*.type != null) {
        joe_free(@ptrCast(@alignCast(tab_1.*.type)));
    }
    joe_free(@ptrCast(@alignCast(tab_1)));
}
pub fn tabrtn(arg_m: [*c]MENU, arg_cursor: ptrdiff_t, arg_object: ?*anyopaque, arg_op: c_int) callconv(.c) c_int {
    var m = arg_m;
    _ = &m;
    var cursor = arg_cursor;
    _ = &cursor;
    var object = arg_object;
    _ = &object;
    var op = arg_op;
    _ = &op;
    var tab_1: [*c]TAB = @ptrCast(@alignCast(object));
    _ = &tab_1;
    if ((menu_explorer != 0) and (@as(c_int, tab_1.*.type[@bitCast(@as(isize, @intCast(cursor)))]) == F_DIR)) {
        var orgpath: [*c]u8 = tab_1.*.path;
        _ = &orgpath;
        var orgpattern: [*c]u8 = tab_1.*.pattern;
        _ = &orgpattern;
        var e: [*c]u8 = endprt(tab_1.*.path);
        _ = &e;
        {
            tab_1.*.path = vsncpy(null, 0, tab_1.*.path, if (tab_1.*.path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tab_1.*.path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
            tab_1.*.path = vsncpy(tab_1.*.path, if (tab_1.*.path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tab_1.*.path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), m.*.list[@bitCast(@as(isize, @intCast(cursor)))], if (m.*.list[@bitCast(@as(isize, @intCast(cursor)))] != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(m.*.list[@bitCast(@as(isize, @intCast(cursor)))]))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        }
        vsrm(e);
        tab_1.*.pattern = vsncpy(null, 0, "*", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("*".*)) / @sizeOf(@TypeOf(@constCast("*").*))) -% @as(c_ulong, 1))))));
        if (!(treload(@ptrCast(@alignCast(m.*.object)), m, @ptrCast(@alignCast(m.*.parent.*.win.*.object)), 0, null) != null)) {
            msgnw(m.*.parent, my_gettext("Couldn't read directory "));
            vsrm(tab_1.*.pattern);
            tab_1.*.pattern = orgpattern;
            vsrm(tab_1.*.path);
            tab_1.*.path = orgpath;
            return -@as(c_int, 1);
        } else {
            vsrm(orgpattern);
            vsrm(orgpath);
            return 0;
        }
    } else {
        var bw_1: [*c]BW = @ptrCast(@alignCast(m.*.parent.*.win.*.object));
        _ = &bw_1;
        insnam(bw_1, tab_1.*.path, tab_1.*.files[@bitCast(@as(isize, @intCast(cursor)))], @intFromBool(@as(c_int, tab_1.*.type[@bitCast(@as(isize, @intCast(cursor)))]) == F_DIR), tab_1.*.path_loc, tab_1.*.quote);
        rmtab(tab_1);
        m.*.object = null;
        m.*.abrt = null;
        _ = wabort(m.*.parent);
        return 0;
    }
}
pub fn tabrtn1(arg_m: [*c]MENU, arg_cursor: c_int, arg_tab_1: [*c]TAB) callconv(.c) c_int {
    var m = arg_m;
    _ = &m;
    var cursor = arg_cursor;
    _ = &cursor;
    var tab_1 = arg_tab_1;
    _ = &tab_1;
    var bw_2: [*c]BW = @ptrCast(@alignCast(m.*.parent.*.win.*.object));
    _ = &bw_2;
    insnam(bw_2, tab_1.*.path, tab_1.*.files[@bitCast(@as(isize, @intCast(cursor)))], if (@as(c_int, tab_1.*.type[@bitCast(@as(isize, @intCast(cursor)))]) == F_DIR) @as(c_int, 1) else @as(c_int, 0), tab_1.*.path_loc, tab_1.*.quote);
    rmtab(tab_1);
    m.*.object = null;
    m.*.abrt = null;
    _ = wabort(m.*.parent);
    return 0;
}
pub fn tabbacks(arg_m: [*c]MENU, arg_cursor: ptrdiff_t, arg_object: ?*anyopaque) callconv(.c) c_int {
    var m = arg_m;
    _ = &m;
    var cursor = arg_cursor;
    _ = &cursor;
    var object = arg_object;
    _ = &object;
    var tab_1: [*c]TAB = @ptrCast(@alignCast(object));
    _ = &tab_1;
    var orgpath: [*c]u8 = tab_1.*.path;
    _ = &orgpath;
    var orgpattern: [*c]u8 = tab_1.*.pattern;
    _ = &orgpattern;
    var e: [*c]u8 = endprt(tab_1.*.path);
    _ = &e;
    if (((if (e != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(e))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) != 0) and (@as(ptrdiff_t, @intFromBool((if (tab_1.*.path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tab_1.*.path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) != tab_1.*.first_len)) != 0)) {
        tab_1.*.path = begprt(tab_1.*.path);
    } else {
        _ = wabort(m.*.parent);
        return 0;
    }
    vsrm(e);
    tab_1.*.pattern = vsncpy(null, 0, "*", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("*".*)) / @sizeOf(@TypeOf(@constCast("*").*))) -% @as(c_ulong, 1))))));
    if (!(treload(@ptrCast(@alignCast(m.*.object)), m, @ptrCast(@alignCast(m.*.parent.*.win.*.object)), 1, null) != null)) {
        msgnw(m.*.parent, my_gettext("Couldn't read directory "));
        vsrm(tab_1.*.pattern);
        tab_1.*.pattern = orgpattern;
        vsrm(tab_1.*.path);
        tab_1.*.path = orgpath;
        return -@as(c_int, 1);
    } else {
        vsrm(orgpattern);
        vsrm(orgpath);
        return 0;
    }
}
pub fn tababrt(arg_w: [*c]W, arg_cursor: ptrdiff_t, arg_object: ?*anyopaque) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var cursor = arg_cursor;
    _ = &cursor;
    var object = arg_object;
    _ = &object;
    var tab_1: [*c]TAB = @ptrCast(@alignCast(object));
    _ = &tab_1;
    rmtab(tab_1);
    return -@as(c_int, 1);
}
pub fn p_goto_start_of_path(arg_p_1: [*c]P, arg_flags: c_int) callconv(.c) c_int {
    var p_1 = arg_p_1;
    _ = &p_1;
    var flags = arg_flags;
    _ = &flags;
    var rtn: c_int = flags & PATH_QUOTE;
    _ = &rtn;
    var fin: off_t = p_1.*.byte;
    _ = &fin;
    var start: off_t = undefined;
    _ = &start;
    var q: [*c]P = undefined;
    _ = &q;
    var c: c_int = undefined;
    _ = &c;
    var d: c_int = undefined;
    _ = &d;
    var maybe_cmd: c_int = @intFromBool(!!((flags & PATH_CMD) != 0));
    _ = &maybe_cmd;
    p_goto_bol(p_1);
    start = p_1.*.byte;
    if ((((flags & PATH_EDIT) != 0) and (p_1.*.byte < fin)) and (brch(p_1) == @as(c_int, '!'))) {
        _ = pgetc(p_1);
        start = p_1.*.byte;
        rtn |= PATH_QUOTE;
        maybe_cmd = 1;
    } else if ((((flags & PATH_SAVE) != 0) and (p_1.*.byte < fin)) and (brch(p_1) == @as(c_int, '>'))) {
        _ = pgetc(p_1);
        if ((p_1.*.byte < fin) and (brch(p_1) == @as(c_int, '>'))) {
            _ = pgetc(p_1);
            start = p_1.*.byte;
        } else {
            _ = prgetc(p_1);
        }
    }
    q = pdup(p_1, "p_goto_start_of_path");
    c = -@as(c_int, 256);
    while (q.*.byte < fin) {
        d = c;
        c = brch(q);
        if (((d == @as(c_int, ' ')) or (d == @as(c_int, '\t'))) and !((c == @as(c_int, ' ')) or (c == @as(c_int, '\t')))) {
            _ = pset(p_1, q);
        }
        if ((((rtn & PATH_QUOTE) != 0) and (d == @as(c_int, '\\'))) and ((c == @as(c_int, ' ')) or (c == @as(c_int, '\t')))) {
            c = 'x';
        }
        _ = pgetc(q);
    }
    if ((maybe_cmd != 0) and (p_1.*.byte == start)) {
        rtn |= PATH_CMD;
    }
    prm(q);
    return rtn;
}
pub fn cmplt(arg_bw_1: [*c]BW, arg_k: c_int, arg_flags_in: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    var flags_in = arg_flags_in;
    _ = &flags_in;
    var newmenu: [*c]MENU = undefined;
    _ = &newmenu;
    var tab_2: [*c]TAB = undefined;
    _ = &tab_2;
    var p_3: [*c]P = undefined;
    _ = &p_3;
    var q: [*c]P = undefined;
    _ = &q;
    var cline: [*c]u8 = undefined;
    _ = &cline;
    var which: c_int = undefined;
    _ = &which;
    var l: [*c][*c]u8 = undefined;
    _ = &l;
    var flags: c_int = undefined;
    _ = &flags;
    tab_2 = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(TAB))))))));
    tab_2.*.files = null;
    tab_2.*.type = null;
    tab_2.*.list = null;
    tab_2.*.prv = 0;
    tab_2.*.len = 0;
    tab_2.*.quote = 0;
    tab_2.*.cmd = 0;
    q = pdup(bw_1.*.cursor, "cmplt");
    p_goto_eol(q);
    p_3 = pdup(q, "cmplt");
    tab_2.*.path_loc = p_3;
    flags = p_goto_start_of_path(p_3, flags_in);
    cline = brvs(p_3, q.*.byte - p_3.*.byte);
    if ((flags & PATH_QUOTE) != 0) {
        cline = dequotevs(cline);
        tab_2.*.quote = 1;
    }
    if ((flags & PATH_CMD) != 0) {
        tab_2.*.cmd = 1;
    }
    prm(q);
    tab_2.*.pattern = namprt(cline);
    tab_2.*.path = dirprt(cline);
    tab_2.*.first_len = if (tab_2.*.path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tab_2.*.path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0);
    tab_2.*.orgnam = vsncpy(null, 0, tab_2.*.pattern, if (tab_2.*.pattern != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tab_2.*.pattern))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    tab_2.*.orgpath = vsncpy(null, 0, tab_2.*.path, if (tab_2.*.path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tab_2.*.path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    tab_2.*.pattern = vsadd(tab_2.*.pattern, '*');
    vsrm(cline);
    l = treload(tab_2, null, bw_1, 0, &which);
    if (menu_above != 0) {
        if (bw_1.*.parent.*.link.prev.*.watom == (&watommenu)) {
            _ = wabort(bw_1.*.parent.*.link.prev);
        }
    } else {
        if (bw_1.*.parent.*.link.next.*.watom == (&watommenu)) {
            _ = wabort(bw_1.*.parent.*.link.next);
        }
    }
    if ((l != null) and ((blk: {
        const tmp = mkmenu(if (menu_above != 0) bw_1.*.parent.*.link.prev else bw_1.*.parent, bw_1.*.parent, l, tabrtn, tababrt, tabbacks, which, @ptrCast(@alignCast(tab_2)), null);
        newmenu = tmp;
        break :blk tmp;
    }) != null)) {
        if (((if (tab_2.*.files != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(tab_2.*.files))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) == @as(ptrdiff_t, 1)) and (strcmp(tab_2.*.files[@as(c_int, 0)], "..") != 0)) return tabrtn1(newmenu, 0, tab_2) else if ((smode != 0) or (isreg(tab_2.*.orgnam) != 0)) {
            if (!(menu_jump != 0)) {
                bw_1.*.parent.*.t.*.curwin = bw_1.*.parent;
            }
            return 0;
        } else {
            var com: [*c]u8 = mcomplete(newmenu);
            _ = &com;
            vsrm(tab_2.*.orgnam);
            tab_2.*.orgnam = com;
            insnam(bw_1, tab_2.*.orgpath, tab_2.*.orgnam, 0, tab_2.*.path_loc, tab_2.*.quote);
            _ = wabort(newmenu.*.parent);
            smode = 2;
            ttputc(7);
            return 0;
        }
    } else {
        ttputc(7);
        rmtab(tab_2);
        return -@as(c_int, 1);
    }
}
pub export fn cmplt_file(arg_bw_1: [*c]BW, arg_k: c_int) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    return cmplt(bw_1, k, PATH_QUOTE);
}
pub export fn cmplt_file_in(arg_bw_1: [*c]BW, arg_k: c_int) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    return cmplt(bw_1, k, PATH_EDIT | PATH_QUOTE);
}
pub export fn cmplt_file_out(arg_bw_1: [*c]BW, arg_k: c_int) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    return cmplt(bw_1, k, (PATH_EDIT | PATH_SAVE) | PATH_QUOTE);
}
pub export fn cmplt_command(arg_bw_1: [*c]BW, arg_k: c_int) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    return cmplt(bw_1, k, PATH_QUOTE | PATH_CMD);
}
