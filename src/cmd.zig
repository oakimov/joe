//! Command table and execution — replaces `joe/cmd.c`.
//!
//! Faithful C-ABI port of JOE's cmds[] table, findcmd/addcmd/execmd,
//! lock dialogs, and uexecmd. Generated from a goto-free rewrite of
//! cmd.c via `zig translate-c`, then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;

pub const off_t = i64;
pub const time_t = i64;
pub const FILE = anyopaque;

pub const NO_MORE_DATA: c_int = -256;
pub const TYPETW: c_int = 0x0100;
pub const TYPEPW: c_int = 0x0200;
pub const TYPEMENU: c_int = 0x0800;
pub const TYPEQW: c_int = 0x1000;
pub const EMID: c_int = 1;
pub const ECHKXCOL: c_int = 2;
pub const EFIXXCOL: c_int = 4;
pub const EMINOR: c_int = 8;
pub const EPOS: c_int = 16;
pub const EMOVE: c_int = 32;
pub const EKILL: c_int = 64;
pub const EMOD: c_int = 128;
pub const EBLOCK: c_int = 0x4000;
pub const EMETA: c_int = 0x10000;
pub const CHECK_INTERVAL: c_int = 15;

pub const struct_watom = extern struct {
    _pad0: [80]u8 = std.mem.zeroes([80]u8),
    what: c_int = 0,
    _pad1: [4]u8 = std.mem.zeroes([4]u8),
};
pub const WATOM = struct_watom;
pub const struct_window = extern struct {
    _pad0: [144]u8 = std.mem.zeroes([144]u8),
    watom: [*c]const WATOM = null,
    object: ?*anyopaque = null,
    _pad1: [40]u8 = std.mem.zeroes([40]u8),
};
pub const W = struct_window;
pub const struct_b = extern struct {
    _pad0: [32]u8 = std.mem.zeroes([32]u8),
    name: [*c]u8 = null,
    locked: c_int = 0,
    ignored_lock: c_int = 0,
    didfirst: c_int = 0,
    _pad1: [12]u8 = std.mem.zeroes([12]u8),
    check_time: time_t = 0,
    gave_notice: c_int = 0,
    _pad2: [8]u8 = std.mem.zeroes([8]u8),
    changed: c_int = 0,
    _pad3: [484]u8 = std.mem.zeroes([484]u8),
    rdonly: c_int = 0,
    _pad4: [56]u8 = std.mem.zeroes([56]u8),
};
pub const B = struct_b;
pub const struct_p = extern struct {
    _pad0: [64]u8 = std.mem.zeroes([64]u8),
    col: off_t = 0,
    xcol: off_t = 0,
    valcol: c_int = 0,
    _pad1: [28]u8 = std.mem.zeroes([28]u8),
};
pub const P = struct_p;
pub const struct_macro = opaque {
};
pub const MACRO = struct_macro;
pub const struct_options = extern struct {
    _pad0: [264]u8 = std.mem.zeroes([264]u8),
    hex: c_int = 0,
    viewmode: c_int = 0,
    _pad1: [32]u8 = std.mem.zeroes([32]u8),
    mnew: ?*MACRO = null,
    _pad2: [24]u8 = std.mem.zeroes([24]u8),
    mfirst: ?*MACRO = null,
};
pub const OPTIONS = struct_options;
pub const struct_bw = extern struct {
    parent: [*c]W = null,
    b: [*c]B = null,
    _pad0: [8]u8 = std.mem.zeroes([8]u8),
    cursor: [*c]P = null,
    _pad1: [48]u8 = std.mem.zeroes([48]u8),
    o: OPTIONS = std.mem.zeroes(OPTIONS),
    _pad2: [64]u8 = std.mem.zeroes([64]u8),
};
pub const BW = struct_bw;
pub const struct_qw = opaque {};
pub const QW = struct_qw;
pub const struct_charmap = opaque {};
pub const struct_cmd = extern struct {
    name: [*c]const u8 = null,
    flag: c_int = 0,
    func: ?*const fn (w: [*c]W, k: c_int) callconv(.c) c_int = null,
    m: ?*MACRO = null,
    arg: c_int = 0,
    negarg: [*c]const u8 = null,
};
pub const CMD = struct_cmd;
pub const struct_kbd = extern struct {
    _pad: [88]u8 = std.mem.zeroes([88]u8),
};
pub const KBD = struct_kbd;
pub const struct_screen = extern struct {
    _pad0: [24]u8 = std.mem.zeroes([24]u8),
    curwin: [*c]W = null,
    _pad1: [16]u8 = std.mem.zeroes([16]u8),
};
pub const Screen = struct_screen;
pub const struct_centry = extern struct {
    next: [*c]struct_centry = null,
    name: [*c]const u8 = null,
    hash_val: ptrdiff_t = 0,
    val: ?*const anyopaque = null,
};
pub const CHENTRY = struct_centry;
pub const struct_CHash = extern struct {
    len: ptrdiff_t = 0,
    tab: [*c][*c]CHENTRY = null,
    nentries: ptrdiff_t = 0,
};
pub const CHASH = struct_CHash;
pub extern fn pffirst(w: [*c]W, k: c_int) c_int;
pub extern fn pfnext(w: [*c]W, k: c_int) c_int;
pub extern fn pqrepl(w: [*c]W, k: c_int) c_int;
pub extern fn prfirst(w: [*c]W, k: c_int) c_int;
pub extern fn u_goto_bof(w: [*c]W, k: c_int) c_int;
pub extern fn u_goto_bol(w: [*c]W, k: c_int) c_int;
pub extern fn u_goto_eof(w: [*c]W, k: c_int) c_int;
pub extern fn u_goto_eol(w: [*c]W, k: c_int) c_int;
pub extern fn u_goto_left(w: [*c]W, k: c_int) c_int;
pub extern fn u_goto_next(w: [*c]W, k: c_int) c_int;
pub extern fn u_goto_prev(w: [*c]W, k: c_int) c_int;
pub extern fn u_goto_right(w: [*c]W, k: c_int) c_int;
pub extern fn u_help(w: [*c]W, k: c_int) c_int;
pub extern fn u_help_next(w: [*c]W, k: c_int) c_int;
pub extern fn u_help_prev(w: [*c]W, k: c_int) c_int;
pub extern fn u_word_delete(w: [*c]W, k: c_int) c_int;
pub extern fn uabort(w: [*c]W, k: c_int) c_int;
pub extern fn uabortbuf(w: [*c]W, k: c_int) c_int;
pub extern fn uarg(w: [*c]W, k: c_int) c_int;
pub extern fn uask(w: [*c]W, k: c_int) c_int;
pub extern fn ubacks(w: [*c]W, k: c_int) c_int;
pub extern fn ubackw(w: [*c]W, k: c_int) c_int;
pub extern fn ubegin_marking(w: [*c]W, k: c_int) c_int;
pub extern fn ubknd(w: [*c]W, k: c_int) c_int;
pub extern fn ubkwdc(w: [*c]W, k: c_int) c_int;
pub extern fn ublkcpy(w: [*c]W, k: c_int) c_int;
pub extern fn ublkdel(w: [*c]W, k: c_int) c_int;
pub extern fn ublkmove(w: [*c]W, k: c_int) c_int;
pub extern fn ublksave(w: [*c]W, k: c_int) c_int;
pub extern fn ubop(w: [*c]W, k: c_int) c_int;
pub extern fn ubos(w: [*c]W, k: c_int) c_int;
pub extern fn ubrpaste(w: [*c]W, k: c_int) c_int;
pub extern fn ubrpaste_done(w: [*c]W, k: c_int) c_int;
pub extern fn ubufed(w: [*c]W, k: c_int) c_int;
pub extern fn ubuild(w: [*c]W, k: c_int) c_int;
pub extern fn ubyte(w: [*c]W, k: c_int) c_int;
pub extern fn ucancel(w: [*c]W, k: c_int) c_int;
pub extern fn ucenter(w: [*c]W, k: c_int) c_int;
pub extern fn ucharset(w: [*c]W, k: c_int) c_int;
pub extern fn ucmplt(w: [*c]W, k: c_int) c_int;
pub extern fn ucol(w: [*c]W, k: c_int) c_int;
pub extern fn ucopy(w: [*c]W, k: c_int) c_int;
pub extern fn ucrawll(w: [*c]W, k: c_int) c_int;
pub extern fn ucrawlr(w: [*c]W, k: c_int) c_int;
pub extern fn uctrl(w: [*c]W, k: c_int) c_int;
pub extern fn ucurrent_msg(w: [*c]W, k: c_int) c_int;
pub extern fn udebug_joe(w: [*c]W, k: c_int) c_int;
pub extern fn udefm2down(w: [*c]W, k: c_int) c_int;
pub extern fn udefm2drag(w: [*c]W, k: c_int) c_int;
pub extern fn udefm2up(w: [*c]W, k: c_int) c_int;
pub extern fn udefm3down(w: [*c]W, k: c_int) c_int;
pub extern fn udefm3drag(w: [*c]W, k: c_int) c_int;
pub extern fn udefm3up(w: [*c]W, k: c_int) c_int;
pub extern fn udefmdown(w: [*c]W, k: c_int) c_int;
pub extern fn udefmdrag(w: [*c]W, k: c_int) c_int;
pub extern fn udefmiddledown(w: [*c]W, k: c_int) c_int;
pub extern fn udefmiddleup(w: [*c]W, k: c_int) c_int;
pub extern fn udefmup(w: [*c]W, k: c_int) c_int;
pub extern fn udelbl(w: [*c]W, k: c_int) c_int;
pub extern fn udelch(w: [*c]W, k: c_int) c_int;
pub extern fn udelel(w: [*c]W, k: c_int) c_int;
pub extern fn udelln(w: [*c]W, k: c_int) c_int;
pub extern fn udnarw(w: [*c]W, k: c_int) c_int;
pub extern fn udnslide(w: [*c]W, k: c_int) c_int;
pub extern fn udrop(w: [*c]W, k: c_int) c_int;
pub extern fn uduptw(w: [*c]W, k: c_int) c_int;
pub extern fn uedit(w: [*c]W, k: c_int) c_int;
pub extern fn uelse(w: [*c]W, k: c_int) c_int;
pub extern fn uelsif(w: [*c]W, k: c_int) c_int;
pub extern fn uendif(w: [*c]W, k: c_int) c_int;
pub extern fn ueop(w: [*c]W, k: c_int) c_int;
pub export fn uexecmd(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (wmkpw(w, my_gettext("Command: "), &cmdhist, docmd, "cmd", null, cmdcmplt, null, null, utf8_map, 0) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}
pub extern fn uexpld(w: [*c]W, k: c_int) c_int;
pub extern fn uexsve(w: [*c]W, k: c_int) c_int;
pub extern fn uextmouse(w: [*c]W, k: c_int) c_int;
pub extern fn ufilt(w: [*c]W, k: c_int) c_int;
pub extern fn ufinish(w: [*c]W, k: c_int) c_int;
pub extern fn ufmtblk(w: [*c]W, k: c_int) c_int;
pub extern fn uformat(w: [*c]W, k: c_int) c_int;
pub extern fn ufwrdc(w: [*c]W, k: c_int) c_int;
pub extern fn ugomark(w: [*c]W, k: c_int) c_int;
pub extern fn ugparse(w: [*c]W, k: c_int) c_int;
pub extern fn ugrep(w: [*c]W, k: c_int) c_int;
pub extern fn ugroww(w: [*c]W, k: c_int) c_int;
pub extern fn uhome(w: [*c]W, k: c_int) c_int;
pub extern fn uif(w: [*c]W, k: c_int) c_int;
pub extern fn uinsc(w: [*c]W, k: c_int) c_int;
pub extern fn uinsf(w: [*c]W, k: c_int) c_int;
pub extern fn uisrch(w: [*c]W, k: c_int) c_int;
pub extern fn ujump(w: [*c]W, k: c_int) c_int;
pub extern fn ukeymap(w: [*c]W, k: c_int) c_int;
pub extern fn ukilljoe(w: [*c]W, k: c_int) c_int;
pub extern fn ukillpid(w: [*c]W, k: c_int) c_int;
pub extern fn ulanguage(w: [*c]W, k: c_int) c_int;
pub extern fn ulindent(w: [*c]W, k: c_int) c_int;
pub extern fn uline(w: [*c]W, k: c_int) c_int;
pub extern fn ulose(w: [*c]W, k: c_int) c_int;
pub extern fn ulower(w: [*c]W, k: c_int) c_int;
pub extern fn umacros(w: [*c]W, k: c_int) c_int;
pub extern fn umarkb(w: [*c]W, k: c_int) c_int;
pub extern fn umarkk(w: [*c]W, k: c_int) c_int;
pub extern fn umarkl(w: [*c]W, k: c_int) c_int;
pub extern fn umath(w: [*c]W, k: c_int) c_int;
pub extern fn umbacks(w: [*c]W, k: c_int) c_int;
pub extern fn umbof(w: [*c]W, k: c_int) c_int;
pub extern fn umbol(w: [*c]W, k: c_int) c_int;
pub extern fn umdnarw(w: [*c]W, k: c_int) c_int;
pub extern fn umenu(w: [*c]W, k: c_int) c_int;
pub extern fn umeof(w: [*c]W, k: c_int) c_int;
pub extern fn umeol(w: [*c]W, k: c_int) c_int;
pub extern fn umfit(w: [*c]W, k: c_int) c_int;
pub extern fn umltarw(w: [*c]W, k: c_int) c_int;
pub extern fn umode(w: [*c]W, k: c_int) c_int;
pub extern fn umpgdn(w: [*c]W, k: c_int) c_int;
pub extern fn umpgup(w: [*c]W, k: c_int) c_int;
pub extern fn umrtarw(w: [*c]W, k: c_int) c_int;
pub extern fn umscrdn(w: [*c]W, k: c_int) c_int;
pub extern fn umscrup(w: [*c]W, k: c_int) c_int;
pub extern fn umsg(w: [*c]W, k: c_int) c_int;
pub extern fn umtab(w: [*c]W, k: c_int) c_int;
pub extern fn umuparw(w: [*c]W, k: c_int) c_int;
pub extern fn umwind(w: [*c]W, k: c_int) c_int;
pub extern fn uname_joe(w: [*c]W, k: c_int) c_int;
pub extern fn unbuf(w: [*c]W, k: c_int) c_int;
pub extern fn unedge(w: [*c]W, k: c_int) c_int;
pub extern fn unextpos(w: [*c]W, k: c_int) c_int;
pub extern fn unextw(w: [*c]W, k: c_int) c_int;
pub extern fn unmark(w: [*c]W, k: c_int) c_int;
pub extern fn unotmod(w: [*c]W, k: c_int) c_int;
pub extern fn unxterr(w: [*c]W, k: c_int) c_int;
pub extern fn uopen(w: [*c]W, k: c_int) c_int;
pub extern fn uparserr(w: [*c]W, k: c_int) c_int;
pub extern fn upaste(w: [*c]W, k: c_int) c_int;
pub extern fn upbuf(w: [*c]W, k: c_int) c_int;
pub extern fn upedge(w: [*c]W, k: c_int) c_int;
pub extern fn upgdn(w: [*c]W, k: c_int) c_int;
pub extern fn upgup(w: [*c]W, k: c_int) c_int;
pub extern fn upicokill(w: [*c]W, k: c_int) c_int;
pub extern fn uplay(w: [*c]W, k: c_int) c_int;
pub extern fn upop(w: [*c]W, k: c_int) c_int;
pub extern fn upopabort(w: [*c]W, k: c_int) c_int;
pub extern fn uprevpos(w: [*c]W, k: c_int) c_int;
pub extern fn uprevw(w: [*c]W, k: c_int) c_int;
pub extern fn uprverr(w: [*c]W, k: c_int) c_int;
pub extern fn upsh(w: [*c]W, k: c_int) c_int;
pub extern fn uquery(w: [*c]W, k: c_int) c_int;
pub extern fn uquerysave(w: [*c]W, k: c_int) c_int;
pub extern fn uquote(w: [*c]W, k: c_int) c_int;
pub extern fn uquote8(w: [*c]W, k: c_int) c_int;
pub extern fn urecord(w: [*c]W, k: c_int) c_int;
pub extern fn uredo(w: [*c]W, k: c_int) c_int;
pub extern fn urelease(w: [*c]W, k: c_int) c_int;
pub extern fn ureload(w: [*c]W, k: c_int) c_int;
pub extern fn ureload_all(w: [*c]W, k: c_int) c_int;
pub extern fn uretyp(w: [*c]W, k: c_int) c_int;
pub extern fn urindent(w: [*c]W, k: c_int) c_int;
pub extern fn ursrch(w: [*c]W, k: c_int) c_int;
pub extern fn urtn(w: [*c]W, k: c_int) c_int;
pub extern fn urun(w: [*c]W, k: c_int) c_int;
pub extern fn usave(w: [*c]W, k: c_int) c_int;
pub extern fn usavenow(w: [*c]W, k: c_int) c_int;
pub extern fn uscratch(w: [*c]W, k: c_int) c_int;
pub extern fn uscratch_push(w: [*c]W, k: c_int) c_int;
pub extern fn uselect(w: [*c]W, k: c_int) c_int;
pub extern fn usetcd(w: [*c]W, k: c_int) c_int;
pub extern fn usetmark(w: [*c]W, k: c_int) c_int;
pub extern fn ushell(w: [*c]W, k: c_int) c_int;
pub extern fn ushowlog(w: [*c]W, k: c_int) c_int;
pub extern fn ushrnk(w: [*c]W, k: c_int) c_int;
pub extern fn usmath(w: [*c]W, k: c_int) c_int;
pub extern fn usplitw(w: [*c]W, k: c_int) c_int;
pub extern fn ustat(w: [*c]W, k: c_int) c_int;
pub extern fn ustop(w: [*c]W, k: c_int) c_int;
pub extern fn uswap(w: [*c]W, k: c_int) c_int;
pub extern fn uswitch(w: [*c]W, k: c_int) c_int;
pub extern fn usys(w: [*c]W, k: c_int) c_int;
pub extern fn utag(w: [*c]W, k: c_int) c_int;
pub extern fn utagjump(w: [*c]W, k: c_int) c_int;
pub extern fn utimer(w: [*c]W, k: c_int) c_int;
pub extern fn utoggle_marking(w: [*c]W, k: c_int) c_int;
pub extern fn utomarkb(w: [*c]W, k: c_int) c_int;
pub extern fn utomarkbk(w: [*c]W, k: c_int) c_int;
pub extern fn utomarkk(w: [*c]W, k: c_int) c_int;
pub extern fn utomatch(w: [*c]W, k: c_int) c_int;
pub extern fn utomouse(w: [*c]W, k: c_int) c_int;
pub extern fn utos(w: [*c]W, k: c_int) c_int;
pub extern fn utrimlines(w: [*c]W, k: c_int) c_int;
pub extern fn utw0(w: [*c]W, k: c_int) c_int;
pub extern fn utw1(w: [*c]W, k: c_int) c_int;
pub extern fn utxt(w: [*c]W, k: c_int) c_int;
pub extern fn utype(w: [*c]W, k: c_int) c_int;
pub extern fn uuarg(w: [*c]W, k: c_int) c_int;
pub extern fn uundo(w: [*c]W, k: c_int) c_int;
pub extern fn uuparw(w: [*c]W, k: c_int) c_int;
pub extern fn uupper(w: [*c]W, k: c_int) c_int;
pub extern fn uupslide(w: [*c]W, k: c_int) c_int;
pub extern fn uvtbknd(w: [*c]W, k: c_int) c_int;
pub extern fn uxtmouse(w: [*c]W, k: c_int) c_int;
pub extern fn uyank(w: [*c]W, k: c_int) c_int;
pub extern fn uyankpop(w: [*c]W, k: c_int) c_int;
pub extern fn uyapp(w: [*c]W, k: c_int) c_int;
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn slen(ary: [*c]const u8) ptrdiff_t;
pub extern fn vsrm(vary: [*c]u8) void;
pub extern fn vaadd(vary: [*c]?*anyopaque, el: ?*anyopaque) [*c]?*anyopaque;
pub extern fn vsncpy(vary: [*c]u8, pos: ptrdiff_t, array: [*c]const u8, len: ptrdiff_t) [*c]u8;
pub extern fn mkmacro(k: c_int, flg: c_int, n: ptrdiff_t, cmd: [*c]const CMD) ?*MACRO;
pub extern fn rmmacro(macro: ?*MACRO) void;
pub extern fn exmacro(m: ?*MACRO, u: c_int, k: c_int) c_int;
pub extern fn chtmk(len: ptrdiff_t) [*c]CHASH;
pub extern fn chtadd(ht: [*c]CHASH, name: [*c]const u8, val: ?*const anyopaque) ?*const anyopaque;
pub extern fn chtfind(ht: [*c]CHASH, name: [*c]const u8) ?*const anyopaque;
pub extern fn pfcol(p: [*c]P) [*c]P;
inline fn piscol(p: [*c]P) off_t {
    if (p.*.valcol != 0) return p.*.col;
    _ = pfcol(p);
    return p.*.col;
}
pub extern fn afterpos() void;
pub extern fn aftermove(w: [*c]W, p: [*c]P) void;
pub extern fn dofollows() void;
pub extern fn plain_file(b: [*c]B) c_int;
pub extern fn lock_it(path: [*c]const u8, buf: [*c]u8) c_int;
pub extern fn unlock_it(path: [*c]const u8) void;
pub extern fn yncheck(set: [*c]const u8, c: c_int) c_int;
pub extern fn msgnw(w: [*c]W, s: [*c]const u8) void;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn wmkpw(w: [*c]W, prompt: [*c]const u8, history: [*c][*c]B, func: ?*const fn (w: [*c]W, s: [*c]u8, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, huh: [*c]const u8, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, tab: ?*const fn (bw: [*c]BW, k: c_int) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int, map: ?*struct_charmap, file_prompt: c_int) [*c]BW;
pub extern fn mkqw(w: [*c]W, prompt: [*c]const u8, len: ptrdiff_t, func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int) ?*QW;
pub extern fn simple_cmplt(bw: [*c]BW, list: [*c][*c]u8) c_int;
pub extern var maint: [*c]Screen;
pub extern var leave: c_int;
pub extern var smode: c_int;
pub extern var nowmarking: c_int;
pub extern var justkilled: c_int;
pub extern var opt_mid: c_int;
pub extern var utf8_map: ?*struct_charmap;
pub extern var auto_scroll: c_int;
pub extern fn reset_trig_time() void;
pub extern fn vaensure(vary: [*c]?*anyopaque, len: ptrdiff_t) [*c]?*anyopaque;
pub extern fn vasort(ary: [*c]?*anyopaque, len: ptrdiff_t) void;
pub export fn findcmd(arg_s: [*c]const u8) [*c]const CMD {
    var s = arg_s;
    _ = &s;
    if (!(cmdhash != null)) {
        izcmds();
    }
    return @ptrCast(@alignCast(chtfind(cmdhash, s)));
}
pub extern fn mparse(m: ?*MACRO, buf: [*c]const u8, sta: [*c]ptrdiff_t, secure: c_int) ?*MACRO;
pub extern fn check_mod(b: [*c]B) c_int;
pub extern var last_time: time_t;
pub extern var obufp: ptrdiff_t;
pub extern var obufsiz: ptrdiff_t;
pub extern var obuf: [*c]u8;
pub extern fn ttflsh() void;
pub export var joe_beep: c_int = 0;
pub fn ubeep(arg_w: [*c]W, arg_k: c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
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
pub export const cmds: [204]CMD = [204]CMD{
    CMD{
        .name = "abort",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = uabort,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "abortbuf",
        .flag = TYPETW,
        .func = uabortbuf,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "arg",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = uarg,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "ask",
        .flag = TYPETW + TYPEPW,
        .func = uask,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "uarg",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = uuarg,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "backs",
        .flag = (((((TYPETW + TYPEPW) + ECHKXCOL) + EFIXXCOL) + EMINOR) + EKILL) + EMOD,
        .func = ubacks,
        .m = null,
        .arg = 1,
        .negarg = "delch",
    },
    CMD{
        .name = "backsmenu",
        .flag = TYPEMENU,
        .func = umbacks,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "backw",
        .flag = ((((TYPETW + TYPEPW) + ECHKXCOL) + EFIXXCOL) + EKILL) + EMOD,
        .func = ubackw,
        .m = null,
        .arg = 1,
        .negarg = "delw",
    },
    CMD{
        .name = "beep",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = ubeep,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "begin_marking",
        .flag = TYPETW + TYPEPW,
        .func = ubegin_marking,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "bknd",
        .flag = TYPETW,
        .func = ubknd,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "bkwdc",
        .flag = TYPETW + TYPEPW,
        .func = ubkwdc,
        .m = null,
        .arg = 1,
        .negarg = "fwrdc",
    },
    CMD{
        .name = "blkcpy",
        .flag = (((TYPETW + TYPEPW) + EFIXXCOL) + EMOD) + EBLOCK,
        .func = ublkcpy,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "blkdel",
        .flag = ((((TYPETW + TYPEPW) + EFIXXCOL) + EKILL) + EMOD) + EBLOCK,
        .func = ublkdel,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "blkmove",
        .flag = (((TYPETW + TYPEPW) + EFIXXCOL) + EMOD) + EBLOCK,
        .func = ublkmove,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "blksave",
        .flag = (TYPETW + TYPEPW) + EBLOCK,
        .func = ublksave,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "bof",
        .flag = ((TYPETW + TYPEPW) + EMOVE) + EFIXXCOL,
        .func = u_goto_bof,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "bofmenu",
        .flag = TYPEMENU,
        .func = umbof,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "bol",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = u_goto_bol,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "bolmenu",
        .flag = TYPEMENU,
        .func = umbol,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "bop",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = ubop,
        .m = null,
        .arg = 1,
        .negarg = "eop",
    },
    CMD{
        .name = "bos",
        .flag = (TYPETW + TYPEPW) + EMOVE,
        .func = ubos,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "brpaste",
        .flag = ((TYPETW + TYPEPW) + EMOD) + EFIXXCOL,
        .func = ubrpaste,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "brpaste_done",
        .flag = ((TYPETW + TYPEPW) + EMOD) + EFIXXCOL,
        .func = ubrpaste_done,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "bufed",
        .flag = TYPETW,
        .func = ubufed,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "build",
        .flag = TYPETW + TYPEPW,
        .func = ubuild,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "byte",
        .flag = TYPETW + TYPEPW,
        .func = ubyte,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "cancel",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = ucancel,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "cd",
        .flag = TYPETW,
        .func = usetcd,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "center",
        .flag = ((TYPETW + TYPEPW) + EFIXXCOL) + EMOD,
        .func = ucenter,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "charset",
        .flag = TYPETW + TYPEPW,
        .func = ucharset,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "ctrl",
        .flag = (TYPETW + TYPEPW) + EMOD,
        .func = uctrl,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "col",
        .flag = TYPETW + TYPEPW,
        .func = ucol,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "complete",
        .flag = (TYPEPW + EMINOR) + EMOD,
        .func = ucmplt,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "copy",
        .flag = TYPETW + TYPEPW,
        .func = ucopy,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "crawll",
        .flag = TYPETW + TYPEPW,
        .func = ucrawll,
        .m = null,
        .arg = 1,
        .negarg = "crawlr",
    },
    CMD{
        .name = "crawlr",
        .flag = TYPETW + TYPEPW,
        .func = ucrawlr,
        .m = null,
        .arg = 1,
        .negarg = "crawll",
    },
    CMD{
        .name = "defmdown",
        .flag = ((TYPETW + TYPEPW) + TYPEQW) + TYPEMENU,
        .func = udefmdown,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "defmup",
        .flag = TYPETW + TYPEPW,
        .func = udefmup,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "defmdrag",
        .flag = TYPETW + TYPEPW,
        .func = udefmdrag,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "defm2down",
        .flag = (TYPETW + TYPEPW) + TYPEMENU,
        .func = udefm2down,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "defm2up",
        .flag = TYPETW + TYPEPW,
        .func = udefm2up,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "defm2drag",
        .flag = TYPETW + TYPEPW,
        .func = udefm2drag,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "defm3down",
        .flag = TYPETW + TYPEPW,
        .func = udefm3down,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "defm3up",
        .flag = TYPETW + TYPEPW,
        .func = udefm3up,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "defm3drag",
        .flag = TYPETW + TYPEPW,
        .func = udefm3drag,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "defmiddledown",
        .flag = TYPETW + TYPEPW,
        .func = udefmiddledown,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "defmiddleup",
        .flag = TYPETW + TYPEPW,
        .func = udefmiddleup,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "delbol",
        .flag = (((TYPETW + TYPEPW) + EFIXXCOL) + EKILL) + EMOD,
        .func = udelbl,
        .m = null,
        .arg = 1,
        .negarg = "deleol",
    },
    CMD{
        .name = "delch",
        .flag = (((((TYPETW + TYPEPW) + ECHKXCOL) + EFIXXCOL) + EMINOR) + EKILL) + EMOD,
        .func = udelch,
        .m = null,
        .arg = 1,
        .negarg = "backs",
    },
    CMD{
        .name = "deleol",
        .flag = ((TYPETW + TYPEPW) + EKILL) + EMOD,
        .func = udelel,
        .m = null,
        .arg = 1,
        .negarg = "delbol",
    },
    CMD{
        .name = "dellin",
        .flag = (((TYPETW + TYPEPW) + EFIXXCOL) + EKILL) + EMOD,
        .func = udelln,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "delw",
        .flag = ((((TYPETW + TYPEPW) + EFIXXCOL) + ECHKXCOL) + EKILL) + EMOD,
        .func = u_word_delete,
        .m = null,
        .arg = 1,
        .negarg = "backw",
    },
    CMD{
        .name = "dnarw",
        .flag = (TYPETW + TYPEPW) + EMOVE,
        .func = udnarw,
        .m = null,
        .arg = 1,
        .negarg = "uparw",
    },
    CMD{
        .name = "dnarwmenu",
        .flag = TYPEMENU,
        .func = umdnarw,
        .m = null,
        .arg = 1,
        .negarg = "uparwmenu",
    },
    CMD{
        .name = "dnslide",
        .flag = (((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW) + EMOVE,
        .func = udnslide,
        .m = null,
        .arg = 1,
        .negarg = "upslide",
    },
    CMD{
        .name = "dnslidemenu",
        .flag = TYPEMENU,
        .func = umscrdn,
        .m = null,
        .arg = 1,
        .negarg = "upslidemenu",
    },
    CMD{
        .name = "drop",
        .flag = TYPETW + TYPEPW,
        .func = udrop,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "dupw",
        .flag = TYPETW,
        .func = uduptw,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "edit",
        .flag = TYPETW,
        .func = uedit,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "else",
        .flag = (((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW) + EMETA,
        .func = uelse,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "elsif",
        .flag = (((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW) + EMETA,
        .func = uelsif,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "endif",
        .flag = (((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW) + EMETA,
        .func = uendif,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "eof",
        .flag = ((TYPETW + TYPEPW) + EFIXXCOL) + EMOVE,
        .func = u_goto_eof,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "eofmenu",
        .flag = TYPEMENU,
        .func = umeof,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "eol",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = u_goto_eol,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "eolmenu",
        .flag = TYPEMENU,
        .func = umeol,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "eop",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = ueop,
        .m = null,
        .arg = 1,
        .negarg = "bop",
    },
    CMD{
        .name = "execmd",
        .flag = TYPETW + TYPEPW,
        .func = uexecmd,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "explode",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = uexpld,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "exsave",
        .flag = TYPETW + TYPEPW,
        .func = uexsve,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "extmouse",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = uextmouse,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "ffirst",
        .flag = TYPETW + TYPEPW,
        .func = pffirst,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "filt",
        .flag = ((TYPETW + TYPEPW) + EMOD) + EBLOCK,
        .func = ufilt,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "finish",
        .flag = (TYPETW + TYPEPW) + EMOD,
        .func = ufinish,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "fnext",
        .flag = TYPETW + TYPEPW,
        .func = pfnext,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "format",
        .flag = ((TYPETW + TYPEPW) + EFIXXCOL) + EMOD,
        .func = uformat,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "fmtblk",
        .flag = ((TYPETW + EMOD) + EFIXXCOL) + EBLOCK,
        .func = ufmtblk,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "fwrdc",
        .flag = TYPETW + TYPEPW,
        .func = ufwrdc,
        .m = null,
        .arg = 1,
        .negarg = "bkwdc",
    },
    CMD{
        .name = "gomark",
        .flag = (TYPETW + TYPEPW) + EMOVE,
        .func = ugomark,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "gparse",
        .flag = TYPETW,
        .func = ugparse,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "grep",
        .flag = TYPETW,
        .func = ugrep,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "groww",
        .flag = TYPETW,
        .func = ugroww,
        .m = null,
        .arg = 1,
        .negarg = "shrinkw",
    },
    CMD{
        .name = "if",
        .flag = (((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW) + EMETA,
        .func = uif,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "isrch",
        .flag = TYPETW + TYPEPW,
        .func = uisrch,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "jump",
        .flag = TYPETW,
        .func = ujump,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "killjoe",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = ukilljoe,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "killproc",
        .flag = TYPETW + TYPEPW,
        .func = ukillpid,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "help",
        .flag = (TYPETW + TYPEPW) + TYPEQW,
        .func = u_help,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "home",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = uhome,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "hnext",
        .flag = (TYPETW + TYPEPW) + TYPEQW,
        .func = u_help_next,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "hprev",
        .flag = (TYPETW + TYPEPW) + TYPEQW,
        .func = u_help_prev,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "insc",
        .flag = ((TYPETW + TYPEPW) + EFIXXCOL) + EMOD,
        .func = uinsc,
        .m = null,
        .arg = 1,
        .negarg = "delch",
    },
    CMD{
        .name = "keymap",
        .flag = TYPETW,
        .func = ukeymap,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "insf",
        .flag = (TYPETW + TYPEPW) + EMOD,
        .func = uinsf,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "language",
        .flag = TYPETW + TYPEPW,
        .func = ulanguage,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "lindent",
        .flag = (((TYPETW + TYPEPW) + EFIXXCOL) + EMOD) + EBLOCK,
        .func = ulindent,
        .m = null,
        .arg = 1,
        .negarg = "rindent",
    },
    CMD{
        .name = "line",
        .flag = TYPETW + TYPEPW,
        .func = uline,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "lose",
        .flag = TYPETW + TYPEPW,
        .func = ulose,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "lower",
        .flag = ((TYPETW + TYPEPW) + EMOD) + EBLOCK,
        .func = ulower,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "ltarw",
        .flag = TYPETW + TYPEPW,
        .func = u_goto_left,
        .m = null,
        .arg = 1,
        .negarg = "rtarw",
    },
    CMD{
        .name = "ltarwmenu",
        .flag = TYPEMENU,
        .func = umltarw,
        .m = null,
        .arg = 1,
        .negarg = "rtarwmenu",
    },
    CMD{
        .name = "macros",
        .flag = TYPETW + EFIXXCOL,
        .func = umacros,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "debug_joe",
        .flag = TYPETW + EFIXXCOL,
        .func = udebug_joe,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "markb",
        .flag = TYPETW + TYPEPW,
        .func = umarkb,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "markk",
        .flag = TYPETW + TYPEPW,
        .func = umarkk,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "markl",
        .flag = TYPETW + TYPEPW,
        .func = umarkl,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "math",
        .flag = TYPETW + TYPEPW,
        .func = umath,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "maths",
        .flag = TYPETW + TYPEPW,
        .func = usmath,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "menu",
        .flag = (TYPETW + TYPEPW) + TYPEQW,
        .func = umenu,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "mode",
        .flag = (TYPETW + TYPEPW) + TYPEQW,
        .func = umode,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "msg",
        .flag = ((TYPETW + TYPEPW) + TYPEQW) + TYPEMENU,
        .func = umsg,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "mfit",
        .flag = TYPETW,
        .func = umfit,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "mwind",
        .flag = TYPETW,
        .func = umwind,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "name",
        .flag = TYPETW + TYPEPW,
        .func = uname_joe,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "nbuf",
        .flag = TYPETW + EFIXXCOL,
        .func = unbuf,
        .m = null,
        .arg = 1,
        .negarg = "pbuf",
    },
    CMD{
        .name = "nedge",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = unedge,
        .m = null,
        .arg = 1,
        .negarg = "pedge",
    },
    CMD{
        .name = "nextpos",
        .flag = (((TYPETW + TYPEPW) + EFIXXCOL) + EMID) + EPOS,
        .func = unextpos,
        .m = null,
        .arg = 1,
        .negarg = "prevpos",
    },
    CMD{
        .name = "nextw",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = unextw,
        .m = null,
        .arg = 1,
        .negarg = "prevw",
    },
    CMD{
        .name = "nextword",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = u_goto_next,
        .m = null,
        .arg = 1,
        .negarg = "prevword",
    },
    CMD{
        .name = "nmark",
        .flag = TYPETW + TYPEPW,
        .func = unmark,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "notmod",
        .flag = TYPETW + TYPEPW,
        .func = unotmod,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "nxterr",
        .flag = TYPETW,
        .func = unxterr,
        .m = null,
        .arg = 1,
        .negarg = "prverr",
    },
    CMD{
        .name = "open",
        .flag = ((TYPETW + TYPEPW) + EFIXXCOL) + EMOD,
        .func = uopen,
        .m = null,
        .arg = 1,
        .negarg = "deleol",
    },
    CMD{
        .name = "parserr",
        .flag = TYPETW,
        .func = uparserr,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "paste",
        .flag = (TYPETW + TYPEPW) + EMOD,
        .func = upaste,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "pbuf",
        .flag = TYPETW + EFIXXCOL,
        .func = upbuf,
        .m = null,
        .arg = 1,
        .negarg = "nbuf",
    },
    CMD{
        .name = "pedge",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = upedge,
        .m = null,
        .arg = 1,
        .negarg = "nedge",
    },
    CMD{
        .name = "pgdn",
        .flag = (((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW) + EMOVE,
        .func = upgdn,
        .m = null,
        .arg = 1,
        .negarg = "pgup",
    },
    CMD{
        .name = "pgdnmenu",
        .flag = TYPEMENU,
        .func = umpgdn,
        .m = null,
        .arg = 1,
        .negarg = "pgupmenu",
    },
    CMD{
        .name = "pgup",
        .flag = (((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW) + EMOVE,
        .func = upgup,
        .m = null,
        .arg = 1,
        .negarg = "pgdn",
    },
    CMD{
        .name = "pgupmenu",
        .flag = TYPEMENU,
        .func = umpgup,
        .m = null,
        .arg = 1,
        .negarg = "pgdnmenu",
    },
    CMD{
        .name = "picokill",
        .flag = (((TYPETW + TYPEPW) + EFIXXCOL) + EKILL) + EMOD,
        .func = upicokill,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "play",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = uplay,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "prevpos",
        .flag = (((TYPETW + TYPEPW) + EPOS) + EMID) + EFIXXCOL,
        .func = uprevpos,
        .m = null,
        .arg = 1,
        .negarg = "nextpos",
    },
    CMD{
        .name = "prevw",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = uprevw,
        .m = null,
        .arg = 1,
        .negarg = "nextw",
    },
    CMD{
        .name = "prevword",
        .flag = ((TYPETW + TYPEPW) + EFIXXCOL) + ECHKXCOL,
        .func = u_goto_prev,
        .m = null,
        .arg = 1,
        .negarg = "nextword",
    },
    CMD{
        .name = "prverr",
        .flag = TYPETW,
        .func = uprverr,
        .m = null,
        .arg = 1,
        .negarg = "nxterr",
    },
    CMD{
        .name = "psh",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = upsh,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "pop",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = upop,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "popabort",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = upopabort,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "qrepl",
        .flag = (TYPETW + TYPEPW) + EMOD,
        .func = pqrepl,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "query",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = uquery,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "querysave",
        .flag = TYPETW,
        .func = uquerysave,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "quote",
        .flag = (TYPETW + TYPEPW) + EMOD,
        .func = uquote,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "quote8",
        .flag = (TYPETW + TYPEPW) + EMOD,
        .func = uquote8,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "record",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = urecord,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "redo",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = uredo,
        .m = null,
        .arg = 1,
        .negarg = "undo",
    },
    CMD{
        .name = "release",
        .flag = TYPETW,
        .func = urelease,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "reload",
        .flag = TYPETW,
        .func = ureload,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "reloadall",
        .flag = TYPETW,
        .func = ureload_all,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "retype",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = uretyp,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "rfirst",
        .flag = TYPETW + TYPEPW,
        .func = prfirst,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "rindent",
        .flag = (((TYPETW + TYPEPW) + EFIXXCOL) + EMOD) + EBLOCK,
        .func = urindent,
        .m = null,
        .arg = 1,
        .negarg = "lindent",
    },
    CMD{
        .name = "run",
        .flag = TYPETW + TYPEPW,
        .func = urun,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "rsrch",
        .flag = TYPETW + TYPEPW,
        .func = ursrch,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "rtarw",
        .flag = TYPETW + TYPEPW,
        .func = u_goto_right,
        .m = null,
        .arg = 1,
        .negarg = "ltarw",
    },
    CMD{
        .name = "rtarwmenu",
        .flag = TYPEMENU,
        .func = umrtarw,
        .m = null,
        .arg = 1,
        .negarg = "ltarwmenu",
    },
    CMD{
        .name = "rtn",
        .flag = (((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW) + EMOD,
        .func = urtn,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "save",
        .flag = TYPETW + TYPEPW,
        .func = usave,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "savenow",
        .flag = TYPETW + TYPEPW,
        .func = usavenow,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "scratch",
        .flag = TYPETW + TYPEPW,
        .func = uscratch,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "scratch_push",
        .flag = TYPETW + TYPEPW,
        .func = uscratch_push,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "secure_type",
        .flag = (((TYPEPW + TYPEQW) + TYPEMENU) + EMINOR) + EMOD,
        .func = utype,
        .m = null,
        .arg = 1,
        .negarg = "backs",
    },
    CMD{
        .name = "select",
        .flag = TYPETW + TYPEPW,
        .func = uselect,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "setmark",
        .flag = TYPETW + TYPEPW,
        .func = usetmark,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "shell",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = ushell,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "showerr",
        .flag = TYPETW + TYPEPW,
        .func = ucurrent_msg,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "showlog",
        .flag = TYPETW,
        .func = ushowlog,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "shrinkw",
        .flag = TYPETW,
        .func = ushrnk,
        .m = null,
        .arg = 1,
        .negarg = "groww",
    },
    CMD{
        .name = "splitw",
        .flag = TYPETW,
        .func = usplitw,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "stat",
        .flag = TYPETW + TYPEPW,
        .func = ustat,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "stop",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = ustop,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "swap",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = uswap,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "switch",
        .flag = TYPETW + TYPEPW,
        .func = uswitch,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "sys",
        .flag = TYPETW + TYPEPW,
        .func = usys,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "tabmenu",
        .flag = TYPEMENU,
        .func = umtab,
        .m = null,
        .arg = 1,
        .negarg = "ltarwmenu",
    },
    CMD{
        .name = "tag",
        .flag = TYPETW + TYPEPW,
        .func = utag,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "tagjump",
        .flag = TYPETW + TYPEPW,
        .func = utagjump,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "toggle_marking",
        .flag = TYPETW + TYPEPW,
        .func = utoggle_marking,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "then",
        .flag = TYPEPW + EMOD,
        .func = urtn,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "timer",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = utimer,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "tomarkb",
        .flag = ((TYPETW + TYPEPW) + EFIXXCOL) + EBLOCK,
        .func = utomarkb,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "tomarkbk",
        .flag = ((TYPETW + TYPEPW) + EFIXXCOL) + EBLOCK,
        .func = utomarkbk,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "tomarkk",
        .flag = ((TYPETW + TYPEPW) + EFIXXCOL) + EBLOCK,
        .func = utomarkk,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "tomatch",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = utomatch,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "tomouse",
        .flag = ((TYPETW + TYPEPW) + TYPEQW) + TYPEMENU,
        .func = utomouse,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "tos",
        .flag = (TYPETW + TYPEPW) + EMOVE,
        .func = utos,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "trimlines",
        .flag = TYPETW,
        .func = utrimlines,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "tw0",
        .flag = ((TYPETW + TYPEPW) + TYPEQW) + TYPEMENU,
        .func = utw0,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "tw1",
        .flag = ((TYPETW + TYPEPW) + TYPEQW) + TYPEMENU,
        .func = utw1,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "txt",
        .flag = TYPETW + TYPEPW,
        .func = utxt,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "type",
        .flag = ((((TYPETW + TYPEPW) + TYPEQW) + TYPEMENU) + EMINOR) + EMOD,
        .func = utype,
        .m = null,
        .arg = 1,
        .negarg = "backs",
    },
    CMD{
        .name = "undo",
        .flag = (TYPETW + TYPEPW) + EFIXXCOL,
        .func = uundo,
        .m = null,
        .arg = 1,
        .negarg = "redo",
    },
    CMD{
        .name = "uparw",
        .flag = (TYPETW + TYPEPW) + EMOVE,
        .func = uuparw,
        .m = null,
        .arg = 1,
        .negarg = "dnarw",
    },
    CMD{
        .name = "uparwmenu",
        .flag = TYPEMENU,
        .func = umuparw,
        .m = null,
        .arg = 1,
        .negarg = "dnarwmenu",
    },
    CMD{
        .name = "upper",
        .flag = ((TYPETW + TYPEPW) + EMOD) + EBLOCK,
        .func = uupper,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "upslide",
        .flag = (((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW) + EMOVE,
        .func = uupslide,
        .m = null,
        .arg = 1,
        .negarg = "dnslide",
    },
    CMD{
        .name = "upslidemenu",
        .flag = TYPEMENU,
        .func = umscrup,
        .m = null,
        .arg = 1,
        .negarg = "dnslidemenu",
    },
    CMD{
        .name = "vtbknd",
        .flag = TYPETW,
        .func = uvtbknd,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "xtmouse",
        .flag = ((TYPETW + TYPEPW) + TYPEMENU) + TYPEQW,
        .func = uxtmouse,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "yank",
        .flag = ((TYPETW + TYPEPW) + EFIXXCOL) + EMOD,
        .func = uyank,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
    CMD{
        .name = "yapp",
        .flag = (TYPETW + TYPEPW) + EKILL,
        .func = uyapp,
        .m = null,
        .arg = 0,
        .negarg = null,
    },
    CMD{
        .name = "yankpop",
        .flag = ((TYPETW + TYPEPW) + EFIXXCOL) + EMOD,
        .func = uyankpop,
        .m = null,
        .arg = 1,
        .negarg = null,
    },
};
pub export var nolocks: c_int = 0;
pub export var steallock_key: [*c]const u8 = "|steal the lock|sS";
pub export var canceledit_key: [*c]const u8 = "|cancel edit due to lock|qQ";
pub export var ignorelock_key: [*c]const u8 = "|ignore lock, continue with edit|iI";
pub fn steal_lock(arg_w: [*c]W, arg_c: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var b_1: [*c]B = @ptrCast(@alignCast(object));
    _ = &b_1;
    if (yncheck(steallock_key, c) != 0) {
        var bf1: [256]u8 = undefined;
        _ = &bf1;
        var bf: [300]u8 = undefined;
        _ = &bf;
        unlock_it(b_1.*.name);
        if (lock_it(b_1.*.name, @ptrCast(@alignCast(&bf1))) != 0) {
            var x: c_int = undefined;
            _ = &x;
            {
                x = 0;
                while ((@as(c_int, bf1[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, bf1[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, ':'))) : (x += 1) {}
            }
            bf1[@bitCast(@as(isize, @intCast(x)))] = 0;
            if (@as(c_int, bf1[@as(c_int, 0)]) != 0) {
                _ = snprintf(@ptrCast(@alignCast(&bf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))))), my_gettext("Locked by %s. (S)teal lock, (I) edit anyway, (Q) cancel edit? "), @as([*c]u8, @ptrCast(@alignCast(&bf1))));
            } else {
                _ = snprintf(@ptrCast(@alignCast(&bf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))))), my_gettext("Could not create lock. (I) edit anyway, (Q) cancel edit? "));
            }
            if (mkqw(w, @ptrCast(@alignCast(&bf)), slen(@ptrCast(@alignCast(&bf))), steal_lock, null, @ptrCast(@alignCast(b_1)), notify) != null) {
                return 0;
            } else {
                if (notify != null) {
                    notify.* = -@as(c_int, 1);
                }
                return -@as(c_int, 1);
            }
        } else {
            b_1.*.locked = 1;
            if (notify != null) {
                notify.* = 1;
            }
            return 0;
        }
    } else if (yncheck(ignorelock_key, c) != 0) {
        b_1.*.locked = 1;
        b_1.*.ignored_lock = 1;
        if (notify != null) {
            notify.* = 1;
        }
        return 0;
    } else if (yncheck(canceledit_key, c) != 0) {
        if (notify != null) {
            notify.* = 1;
        }
        return 0;
    } else {
        if (mkqw(w, my_gettext("Could not create lock. (I) edit anyway, (Q) cancel edit? "), slen(my_gettext("Could not create lock. (I) edit anyway, (Q) cancel edit? ")), steal_lock, null, @ptrCast(@alignCast(b_1)), notify) != null) {
            return 0;
        } else return -@as(c_int, 1);
    }
    return undefined;
}
pub fn file_changed(arg_w: [*c]W, arg_c: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var b_1: [*c]B = @ptrCast(@alignCast(object));
    _ = &b_1;
    if (mkqw(w, my_gettext("Notice: File on disk changed! (hit %{abort} to continue)  "), slen(my_gettext("Notice: File on disk changed! (hit %{abort} to continue)  ")), file_changed, null, @ptrCast(@alignCast(b_1)), notify) != null) {
        b_1.*.gave_notice = 1;
        return 0;
    } else return -@as(c_int, 1);
}
pub export fn try_lock(arg_bw_1: [*c]BW, arg_b_2: [*c]B) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var b_2 = arg_b_2;
    _ = &b_2;
    if (!(nolocks != 0) and (plain_file(b_2) != 0)) {
        var bf1: [256]u8 = undefined;
        _ = &bf1;
        var bf: [300]u8 = undefined;
        _ = &bf;
        var x: c_int = undefined;
        _ = &x;
        if (lock_it(b_2.*.name, @ptrCast(@alignCast(&bf1))) != 0) {
            {
                x = 0;
                while ((@as(c_int, bf1[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, bf1[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, ':'))) : (x += 1) {}
            }
            bf1[@bitCast(@as(isize, @intCast(x)))] = 0;
            if (@as(c_int, bf1[@as(c_int, 0)]) != 0) {
                _ = snprintf(@ptrCast(@alignCast(&bf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))))), my_gettext("Locked by %s. (S)teal lock, (I) edit anyway, (Q) cancel edit? "), @as([*c]u8, @ptrCast(@alignCast(&bf1))));
            } else {
                _ = snprintf(@ptrCast(@alignCast(&bf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))))), my_gettext("Could not create lock. (I) edit anyway, (Q) cancel edit? "));
            }
            if (mkqw(bw_1.*.parent, @ptrCast(@alignCast(&bf)), slen(@ptrCast(@alignCast(&bf))), steal_lock, null, @ptrCast(@alignCast(b_2)), null) != null) {
                _ = uquery(bw_1.*.parent, 0);
                if (!(b_2.*.locked != 0)) return 0;
            } else return 0;
        } else {
            b_2.*.locked = 1;
        }
    }
    return 1;
}
pub export var nomodcheck: c_int = 0;
pub export fn modify_logic(arg_bw_1: [*c]BW, arg_b_2: [*c]B) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var b_2 = arg_b_2;
    _ = &b_2;
    if (last_time > (b_2.*.check_time + @as(time_t, CHECK_INTERVAL))) {
        b_2.*.check_time = last_time;
        if ((!(nomodcheck != 0) and !(b_2.*.gave_notice != 0)) and (check_mod(b_2) != 0)) {
            _ = file_changed(bw_1.*.parent, 0, @ptrCast(@alignCast(b_2)), null);
            return 0;
        }
    }
    if (b_2 != bw_1.*.b) {
        if (!(b_2.*.didfirst != 0)) {
            if (bw_1.*.o.mfirst != null) {
                msgnw(bw_1.*.parent, my_gettext("Modify other window first for macro"));
                return 0;
            }
            b_2.*.didfirst = 1;
            if (bw_1.*.o.mfirst != null) {
                _ = exmacro(bw_1.*.o.mfirst, 1, -@as(c_int, 256));
            }
        }
        if (b_2.*.rdonly != 0) {
            msgnw(bw_1.*.parent, my_gettext("Other buffer is read only"));
            if (joe_beep != 0) while (true) {
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
            };
            return 0;
        } else if (!(b_2.*.changed != 0) and !(b_2.*.locked != 0)) {
            if (!(try_lock(bw_1, b_2) != 0)) return 0;
        }
    } else {
        if (!(b_2.*.didfirst != 0)) {
            b_2.*.didfirst = 1;
            if (bw_1.*.o.mfirst != null) {
                _ = exmacro(bw_1.*.o.mfirst, 1, -@as(c_int, 256));
            }
        }
        if (b_2.*.rdonly != 0) {
            msgnw(bw_1.*.parent, my_gettext("Read only"));
            if (joe_beep != 0) while (true) {
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
            };
            return 0;
        } else if (!(b_2.*.changed != 0) and !(b_2.*.locked != 0)) {
            if (!(try_lock(bw_1, b_2) != 0)) return 0;
        }
    }
    return 1;
}
pub export fn execmd(arg_cmd_1: [*c]const CMD, arg_k: c_int) c_int {
    var cmd_1 = arg_cmd_1;
    _ = &cmd_1;
    var k = arg_k;
    _ = &k;
    var bw_2: [*c]BW = @ptrCast(@alignCast(maint.*.curwin.*.object));
    _ = &bw_2;
    var ret: c_int = -@as(c_int, 1);
    _ = &ret;
    var do_skip: c_int = 0;
    _ = &do_skip;
    if (cmd_1.*.m != null) return exmacro(cmd_1.*.m, 0, k);
    if ((cmd_1.*.flag & ECHKXCOL) != 0) {
        if (bw_2.*.o.hex != 0) {
            bw_2.*.cursor.*.xcol = piscol(bw_2.*.cursor);
        } else if (!(bw_2.*.o.viewmode != 0) and (bw_2.*.cursor.*.xcol != piscol(bw_2.*.cursor))) {
            do_skip = 1;
        }
    }
    if (!(do_skip != 0) and !((cmd_1.*.flag & maint.*.curwin.*.watom.*.what) != 0)) {
        do_skip = 1;
    }
    if (!(do_skip != 0)) {
        if (((cmd_1.*.flag & EBLOCK) != 0) and (nowmarking != 0)) {
            _ = utoggle_marking(maint.*.curwin, 0);
        }
        if (((maint.*.curwin.*.watom.*.what & TYPETW) != 0) and ((cmd_1.*.flag & EMOD) != 0)) {
            if (!(modify_logic(bw_2, bw_2.*.b) != 0)) {
                do_skip = 1;
            }
        }
    }
    if (!(do_skip != 0)) {
        ret = cmd_1.*.func.?(maint.*.curwin, k);
        if (smode != 0) {
            smode -= 1;
        }
        if (leave != 0) return 0;
        bw_2 = @ptrCast(@alignCast(maint.*.curwin.*.object));
        if (!((cmd_1.*.flag & EPOS) != 0) and ((maint.*.curwin.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) {
            afterpos();
        }
        if (!((cmd_1.*.flag & (EMOVE | EPOS)) != 0) and ((maint.*.curwin.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) {
            aftermove(maint.*.curwin, bw_2.*.cursor);
        }
        if ((cmd_1.*.flag & EKILL) != 0) {
            justkilled = 1;
        } else {
            justkilled = 0;
        }
    }
    if (((cmd_1.*.flag & EFIXXCOL) != 0) and ((maint.*.curwin.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) if (!(bw_2.*.o.viewmode != 0)) {
        bw_2.*.cursor.*.xcol = piscol(bw_2.*.cursor);
    };
    if ((cmd_1.*.flag & EMID) != 0) {
        var omid: c_int = opt_mid;
        _ = &omid;
        opt_mid = 1;
        dofollows();
        opt_mid = omid;
    }
    if ((joe_beep != 0) and (ret != 0)) while (true) {
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
    };
    return ret;
}
pub export fn do_auto_scroll() void {
    const static_local_myscrup = struct {
        var myscrup: [*c]const CMD = null;
    };
    _ = &static_local_myscrup;
    const static_local_myscrdn = struct {
        var myscrdn: [*c]const CMD = null;
    };
    _ = &static_local_myscrdn;
    const static_local_drag = struct {
        var drag: [*c]const CMD = null;
    };
    _ = &static_local_drag;
    if (!(static_local_myscrup.myscrup != null)) {
        static_local_myscrup.myscrup = findcmd("upslide");
        static_local_myscrdn.myscrdn = findcmd("dnslide");
        static_local_drag.drag = findcmd("defmdrag");
    }
    if (auto_scroll > @as(c_int, 0)) {
        _ = execmd(static_local_myscrdn.myscrdn, 0);
    } else if (auto_scroll < @as(c_int, 0)) {
        _ = execmd(static_local_myscrup.myscrup, 0);
    }
    _ = execmd(static_local_drag.drag, 0);
    reset_trig_time();
}
pub export var cmdhash: [*c]CHASH = null;
pub fn izcmds() callconv(.c) void {
    var x: c_int = undefined;
    _ = &x;
    cmdhash = chtmk(256);
    {
        x = 0;
        while (@as(ptrdiff_t, x) != @divTrunc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(cmds)))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(CMD))))))) : (x += 1) {
            _ = chtadd(cmdhash, cmds[@bitCast(@as(isize, @intCast(x)))].name, @ptrCast(@alignCast(@as([*c]const CMD, @ptrCast(@alignCast(&cmds))) + @as(usize, @bitCast(@as(isize, @intCast(x)))))));
        }
    }
}
pub export fn addcmd(arg_s: [*c]const u8, arg_m: ?*MACRO) void {
    var s = arg_s;
    _ = &s;
    var m = arg_m;
    _ = &m;
    var cmd_1: [*c]CMD = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(CMD))))))));
    _ = &cmd_1;
    if (!(cmdhash != null)) {
        izcmds();
    }
    cmd_1.*.name = zdup(s);
    cmd_1.*.flag = 0;
    cmd_1.*.func = null;
    cmd_1.*.m = m;
    cmd_1.*.arg = 1;
    cmd_1.*.negarg = null;
    _ = chtadd(cmdhash, cmd_1.*.name, @ptrCast(@alignCast(cmd_1)));
}
pub fn getcmds() callconv(.c) [*c][*c]u8 {
    var s: [*c][*c]u8 = @ptrCast(@alignCast(vaensure(null, @divTrunc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(cmds)))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(CMD)))))))));
    _ = &s;
    var x: c_int = undefined;
    _ = &x;
    var e: [*c]CHENTRY = undefined;
    _ = &e;
    {
        x = 0;
        while (@as(ptrdiff_t, x) != cmdhash.*.len) : (x += 1) {
            e = cmdhash.*.tab[@bitCast(@as(isize, @intCast(x)))];
            while (e != null) : (e = e.*.next) {
                s = @ptrCast(@alignCast(vaadd(@ptrCast(@alignCast(s)), @ptrCast(@alignCast(vsncpy(null, 0, e.*.name, slen(e.*.name)))))));
            }
        }
    }
    vasort(@ptrCast(@alignCast(s)), (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 2)))))).*);
    return s;
}
pub export var scmds: [*c][*c]u8 = null;
pub fn cmdcmplt(arg_bw_1: [*c]BW, arg_k: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    if (!(scmds != null)) {
        scmds = getcmds();
    }
    return simple_cmplt(bw_1, scmds);
}
pub fn docmd(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var mac: ?*MACRO = undefined;
    _ = &mac;
    var ret: c_int = -@as(c_int, 1);
    _ = &ret;
    var sta: ptrdiff_t = -@as(c_int, 1);
    _ = &sta;
    mac = mparse(null, s, &sta, 0);
    if (sta < @as(ptrdiff_t, 0)) {
        msgnw(w, my_gettext("No such command"));
    } else {
        ret = exmacro(mac, 1, -@as(c_int, 256));
        rmmacro(mac);
    }
    if (notify != null) {
        notify.* = 1;
    }
    return ret;
}
pub export var cmdhist: [*c]B = null;


comptime {
    if (@sizeOf(struct_cmd) != 48) @compileError("CMD size mismatch");
    if (@sizeOf(struct_window) != 200) @compileError("W size mismatch");
    if (@sizeOf(struct_bw) != 488) @compileError("BW size mismatch");
    if (@sizeOf(struct_options) != 344) @compileError("OPTIONS size mismatch");
    if (@sizeOf(struct_p) != 112) @compileError("P size mismatch");
    if (@sizeOf(struct_b) != 632) @compileError("B size mismatch");
    if (@sizeOf(struct_CHash) != 24) @compileError("CHASH size mismatch");
    if (@offsetOf(struct_options, "hex") != 264) @compileError("OPTIONS.hex offset mismatch");
    if (@offsetOf(struct_options, "viewmode") != 268) @compileError("OPTIONS.viewmode offset mismatch");
    if (@offsetOf(struct_options, "mfirst") != 336) @compileError("OPTIONS.mfirst offset mismatch");
    if (@offsetOf(struct_b, "name") != 32) @compileError("B.name offset mismatch");
    if (@offsetOf(struct_b, "rdonly") != 572) @compileError("B.rdonly offset mismatch");
    if (@offsetOf(struct_bw, "o") != 80) @compileError("BW.o offset mismatch");
    if (@offsetOf(struct_p, "xcol") != 72) @compileError("P.xcol offset mismatch");
}
