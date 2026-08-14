//! Option system — replaces `joe/options.c`.
//!
//! Faithful C-ABI port of JOE's options / glopt / setopt subsystem.
//! Generated from a goto-free rewrite of options.c via `zig translate-c`,
//! then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;
const HEX_RESTORE_UTF8: c_int = 2;
const HEX_RESTORE_CRLF: c_int = 4;
const HEX_RESTORE_INSERT: c_int = 8;
const HEX_RESTORE_WORDWRAP: c_int = 16;
const HEX_RESTORE_AUTOINDENT: c_int = 32;
const HEX_RESTORE_ANSI: c_int = 64;
const HEX_RESTORE_PICTURE: c_int = 128;
const OPT_BUF_SIZE: c_int = 300;
const TYPETW: c_int = 256;
const TYPEPW: c_int = 512;
const JOE_MSGBUFSIZE: c_int = 300;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn strcmp(__s1: [*c]const u8, __s2: [*c]const u8) c_int;
pub extern fn strcpy(__dst: [*c]u8, __src: [*c]const u8) [*c]u8;
pub extern fn strlen(__s: [*c]const u8) usize;
pub extern fn strrchr(__s: [*c]const u8, __c: c_int) [*c]u8;

pub const off_t = i64;
pub extern fn _vaset(vary: [*c][*c]u8, pos: ptrdiff_t, el: [*c]u8) [*c][*c]u8;
pub const OPTIONS = struct_options;
pub const struct_regcomp = extern struct {
    _pad: c_int = 0,
};
pub const struct_options_match = extern struct {
    next: [*c]struct_options_match = null,
    name_regex: [*c]const u8 = null,
    contents_regex: [*c]const u8 = null,
    r_contents_regex: [*c]struct_regcomp = null,
};
pub const struct_high_syntax = extern struct {
    _pad: c_int = 0,
};
pub const struct_charmap = extern struct {
    next: [*c]struct_charmap = null,
    name: [*c]const u8 = null,
    @"type": c_int = 0,
    is_punct: ?*const fn ([*c]struct_charmap, c_int) callconv(.c) c_int = null,
    is_print: ?*const fn ([*c]struct_charmap, c_int) callconv(.c) c_int = null,
    is_space: ?*const fn ([*c]struct_charmap, c_int) callconv(.c) c_int = null,
    is_alpha_: ?*const fn ([*c]struct_charmap, c_int) callconv(.c) c_int = null,
    is_alnum_: ?*const fn ([*c]struct_charmap, c_int) callconv(.c) c_int = null,
    to_lower: ?*const fn ([*c]struct_charmap, c_int) callconv(.c) c_int = null,
    to_upper: ?*const fn ([*c]struct_charmap, c_int) callconv(.c) c_int = null,
};
pub const struct_macro = extern struct {
    _pad: [48]u8 = std.mem.zeroes([48]u8),
};
pub const MACRO = struct_macro;
pub const struct_options = extern struct {
    next: [*c]OPTIONS = null,
    ftype: [*c]const u8 = null,
    match: [*c]struct_options_match = null,
    overtype: c_int = 0,
    lmargin: off_t = 0,
    rmargin: off_t = 0,
    autoindent: c_int = 0,
    wordwrap: c_int = 0,
    nobackup: c_int = 0,
    tab: off_t = 0,
    indentc: c_int = 0,
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
    mnew: [*c]MACRO = null,
    mold: [*c]MACRO = null,
    msnew: [*c]MACRO = null,
    msold: [*c]MACRO = null,
    mfirst: [*c]MACRO = null,
};
pub const options_match = struct_options_match;
pub const struct_point = extern struct {
    _pad0: [64]u8 = std.mem.zeroes([64]u8),
    col: off_t = 0,
    xcol: off_t = 0,
    valcol: c_int = 0,
    end: c_int = 0,
    _pad1: [24]u8 = std.mem.zeroes([24]u8),
};
pub const P = struct_point;
pub const struct_buffer = extern struct {
    _pad0: [16]u8 = std.mem.zeroes([16]u8),
    bof: [*c]P = null,
    _pad1: [168]u8 = std.mem.zeroes([168]u8),
    o: OPTIONS = std.mem.zeroes(OPTIONS),
    _pad2: [36]u8 = std.mem.zeroes([36]u8),
    rdonly: c_int = 0,
    _pad3: [56]u8 = std.mem.zeroes([56]u8),
};
pub const B = struct_buffer;
pub const struct_scrn = extern struct {
    _pad: c_int = 0,
};
pub const SCRN = struct_scrn;
pub const struct_screen = extern struct {
    t: [*c]SCRN = null,
    _pad: [64]u8 = std.mem.zeroes([64]u8),
};
pub const Screen = struct_screen;
pub const struct_watom = extern struct {
    _pad: [80]u8 = std.mem.zeroes([80]u8),
    what: c_int = 0,
};
pub const WATOM = struct_watom;
pub const struct_window = extern struct {
    link_next: [*c]W = null,
    link_prev: [*c]W = null,
    t: [*c]Screen = null,
    _pad_geom: [80]u8 = std.mem.zeroes([80]u8),
    main: [*c]W = null,
    _pad1: [32]u8 = std.mem.zeroes([32]u8),
    watom: [*c]const WATOM = null,
    object: ?*anyopaque = null,
    _pad2: [40]u8 = std.mem.zeroes([40]u8),
};
pub const W = struct_window;
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
    _pad: [56]u8 = std.mem.zeroes([56]u8),
};
pub const BW = struct_bw;
pub const charmap = struct_charmap;
pub const struct_hash = extern struct {
    _pad: [24]u8 = std.mem.zeroes([24]u8),
};
pub const HASH = struct_hash;
pub const high_syntax = struct_high_syntax;
pub const regcomp = struct_regcomp;
pub const struct_color_scheme = extern struct {
    _pad: c_int = 0,
};
pub const SCHEME = struct_color_scheme;
pub extern var locale_map: [*c]struct_charmap;
pub extern var ascii_map: [*c]struct_charmap;
pub extern var utf8_map: [*c]struct_charmap;
pub extern var locale_msgs: [*c]const u8;
pub extern var scheme_name: [*c]u8;
pub extern var xmsg: [*c]u8;
pub extern var backpath: [*c]const u8;
pub extern var backup_file_suffix: [*c]const u8;
pub const msgbuf: [*c]u8 = @extern([*c]u8, .{
    .name = "msgbuf",
});
pub extern var merr: [*c]u8;
pub extern var joe_beep: c_int;
pub extern var staen: c_int;
pub extern var keepup: c_int;
pub extern var undo_keep: c_int;
pub extern var csmode: c_int;
pub extern var floatmouse: c_int;
pub extern var rtbutton: c_int;
pub extern var nonotice: c_int;
pub extern var noexmsg: c_int;
pub extern var help_is_utf8: c_int;
pub extern var noxon: c_int;
pub extern var orphan: c_int;
pub extern var helpon: c_int;
pub extern var dopadding: c_int;
pub extern var env_lines: c_int;
pub extern var Baud: c_int;
pub extern var env_columns: c_int;
pub extern var skiptop: c_int;
pub extern var notite: c_int;
pub extern var brpaste: c_int;
pub extern var pastehack: c_int;
pub extern var nolinefeeds: c_int;
pub extern var xmouse: c_int;
pub extern var opt_usetabs: c_int;
pub extern var assume_color: c_int;
pub extern var assume_256color: c_int;
pub extern var joexterm: c_int;
pub extern var restore_file_pos: c_int;
pub extern var std_regex: c_int;
pub extern var square: c_int;
pub extern var opt_icase: c_int;
pub extern var wrap: c_int;
pub extern var menu_explorer: c_int;
pub extern var menu_above: c_int;
pub extern var menu_jump: c_int;
pub extern var menu_flg: c_int;
pub extern var pgamnt: c_int;
pub extern var dspasis: c_int;
pub extern var opt_mid: c_int;
pub extern var opt_left: c_int;
pub extern var opt_right: c_int;
pub extern var marking: c_int;
pub extern var guesscrlf: c_int;
pub extern var guessindent: c_int;
pub extern var guess_utf8: c_int;
pub extern var guess_non_utf8: c_int;
pub extern var guess_utf16: c_int;
pub extern var nobackups: c_int;
pub extern var break_links: c_int;
pub extern var break_symlinks: c_int;
pub extern var lightoff: c_int;
pub extern var force: c_int;
pub extern var autoswap: c_int;
pub extern var exask: c_int;
pub extern var nocurdir: c_int;
pub extern var nodeadjoe: c_int;
pub extern var nolocks: c_int;
pub extern var nomodcheck: c_int;
pub extern var notagsmenu: c_int;
pub extern var pico: c_int;
pub extern var transpose: c_int;
pub extern var parserr_homeonly: c_int;
pub extern var bg_text: c_int;
pub extern var bg_help: c_int;
pub extern var bg_menu: c_int;
pub extern var bg_msg: c_int;
pub extern var bg_prompt: c_int;
pub extern var bg_stalin: c_int;
pub extern var watomtw: WATOM;
pub extern var watompw: WATOM;
pub extern var filehist: [*c]B;
pub extern var maint: [*c]Screen;
pub extern fn cmplt_file(bw: [*c]BW, k: c_int) c_int;
pub extern fn math_cmplt(bw: [*c]BW, k: c_int) c_int;
pub extern fn simple_file_cmplt(bw: [*c]BW, list: [*c][*c]u8) c_int;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn joe_malloc(n: usize) ?*anyopaque;
pub extern fn joe_free(p: ?*anyopaque) void;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn ztoi(s: [*c]const u8) c_int;
pub extern fn ztoo(s: [*c]const u8) off_t;
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn vsncpy(v: [*c]u8, len: ptrdiff_t, s: [*c]const u8, n: ptrdiff_t) [*c]u8;
pub extern fn vsrm(v: [*c]u8) void;
pub extern fn vaensure(v: [*c][*c]u8, n: ptrdiff_t) [*c][*c]u8;
pub extern fn vasort(v: [*c][*c]u8, n: ptrdiff_t) void;
pub extern fn varm(v: [*c][*c]u8) void;
pub extern fn htmk(n: c_int) [*c]HASH;
pub extern fn htadd(h: [*c]HASH, name: [*c]const u8, val: ?*anyopaque) void;
pub extern fn htfind(h: [*c]HASH, name: [*c]const u8) ?*anyopaque;
pub extern fn find_charmap(name: [*c]const u8) [*c]struct_charmap;
pub extern fn get_encodings() ?*anyopaque;
pub extern fn load_syntax(name: [*c]const u8) [*c]struct_high_syntax;
pub extern fn load_scheme(name: [*c]const u8) [*c]SCHEME;
pub extern fn apply_scheme(s: [*c]SCHEME) c_int;
pub extern fn mparse(m: [*c]MACRO, s: [*c]u8, sta: [*c]ptrdiff_t, n: c_int) [*c]MACRO;
pub extern fn rmatch(regex: [*c]const u8, name: [*c]const u8) c_int;
pub extern fn joe_regcomp(m: [*c]struct_charmap, s: [*c]const u8, len: ptrdiff_t, fold: c_int, stdfmt: c_int, debug: c_int) [*c]struct_regcomp;
pub extern fn joe_regexec(g: [*c]struct_regcomp, p: [*c]P, nmatch: c_int, matches: ?*anyopaque, fold: c_int) c_int;
pub extern fn pdup(p: [*c]P, where: [*c]const u8) [*c]P;
pub extern fn prm(p: [*c]P) void;
pub extern fn pfcol(p: [*c]P) off_t;
pub extern fn utypebw(bw: [*c]BW, c: c_int) c_int;
pub extern fn msgnw(w: [*c]W, s: [*c]const u8) void;
pub extern fn wmkpw(w: [*c]W, prompt: [*c]u8, hist: [*c][*c]B, func: ?*const fn ([*c]W, [*c]u8, ?*anyopaque, [*c]c_int) callconv(.c) c_int, huh: [*c]u8, abrt: ?*const fn ([*c]W, ?*anyopaque) callconv(.c) c_int, cmplt: ?*const fn ([*c]BW, c_int) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int, map: [*c]struct_charmap, instant: c_int) ?*anyopaque;
pub extern fn simple_cmplt(bw: [*c]BW, list: [*c][*c]u8) c_int;
pub extern fn jgetbuiltins(suffix: [*c]const u8) [*c][*c]u8;
pub extern fn rexpnd(word: [*c]const u8) [*c][*c]u8;
pub extern fn joe_state() void;
pub extern fn updall() void;
pub extern fn wfit(t: [*c]Screen) void;
pub extern fn nredraw(t: [*c]SCRN) void;
pub extern fn chpwd(path: [*c]const u8) c_int;
pub extern fn pwd() [*c]u8;
pub extern fn xdg_config_dir() [*c]const u8;
pub extern fn meta_color(s: [*c]const u8) c_int;
pub extern fn calc(bw: [*c]BW, s: [*c]u8, secure: c_int) f64;
pub export var aborthint: [*c]const u8 = "^C";
pub export var helphint: [*c]const u8 = "^K H";
pub export var options_list: [*c]OPTIONS = null;
pub export var pdefault: OPTIONS = OPTIONS{
    .next = null,
    .ftype = "prompt",
    .match = null,
    .overtype = 0,
    .lmargin = 0,
    .rmargin = 76,
    .autoindent = 0,
    .wordwrap = 0,
    .nobackup = 0,
    .tab = 8,
    .indentc = ' ',
    .istep = 1,
    .context = null,
    .lmsg = null,
    .rmsg = null,
    .smsg = null,
    .zmsg = null,
    .linums = 0,
    .hiline = 0,
    .readonly = 0,
    .french = 0,
    .flowed = 0,
    .spaces = 0,
    .crlf = 0,
    .highlight = 0,
    .visiblews = 0,
    .syntax_debug = 0,
    .syntax_name = null,
    .syntax = null,
    .map_name = null,
    .charmap = null,
    .language = null,
    .smarthome = 0,
    .indentfirst = 0,
    .smartbacks = 0,
    .purify = 0,
    .picture = 0,
    .highlighter_context = 0,
    .single_quoted = 0,
    .no_double_quoted = 0,
    .c_comment = 0,
    .cpp_comment = 0,
    .hash_comment = 0,
    .vhdl_comment = 0,
    .semi_comment = 0,
    .tex_comment = 0,
    .hex = 0,
    .viewmode = 0,
    .ansi = 0,
    .title = 0,
    .text_delimiters = null,
    .cpara = null,
    .cnotpara = null,
    .mnew = null,
    .mold = null,
    .msnew = null,
    .msold = null,
    .mfirst = null,
};
pub export var fdefault: OPTIONS = OPTIONS{
    .next = null,
    .ftype = "default",
    .match = null,
    .overtype = 0,
    .lmargin = 0,
    .rmargin = 76,
    .autoindent = 0,
    .wordwrap = 0,
    .nobackup = 0,
    .tab = 8,
    .indentc = ' ',
    .istep = 1,
    .context = "main",
    .lmsg = "\\i%n %m %M",
    .rmsg = " %S Ctrl-K H for help",
    .smsg = null,
    .zmsg = null,
    .linums = 0,
    .hiline = 0,
    .readonly = 0,
    .french = 0,
    .flowed = 0,
    .spaces = 0,
    .crlf = 0,
    .highlight = 0,
    .visiblews = 0,
    .syntax_debug = 0,
    .syntax_name = null,
    .syntax = null,
    .map_name = null,
    .charmap = null,
    .language = null,
    .smarthome = 0,
    .indentfirst = 0,
    .smartbacks = 0,
    .purify = 0,
    .picture = 0,
    .highlighter_context = 0,
    .single_quoted = 0,
    .no_double_quoted = 0,
    .c_comment = 0,
    .cpp_comment = 0,
    .hash_comment = 0,
    .vhdl_comment = 0,
    .semi_comment = 0,
    .tex_comment = 0,
    .hex = 0,
    .viewmode = 0,
    .ansi = 0,
    .title = 0,
    .text_delimiters = null,
    .cpara = ">;!#%/",
    .cnotpara = ".",
    .mnew = null,
    .mold = null,
    .msnew = null,
    .msold = null,
    .mfirst = null,
};
pub export fn ucharset(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var s: [*c]const u8 = undefined;
    _ = &s;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    w = w.*.main;
    s = @as([*c]BW, @ptrCast(@alignCast(w.*.object))).*.o.charmap.*.name;
    if (!(s != null) or !(@as(c_int, s.*) != 0)) return -@as(c_int, 1);
    while (@as(c_int, s.*) != 0) if (utypebw(bw_1, @as([*c]const u8, @ptrCast(@alignCast(blk: {
        const ref = &s;
        const tmp = ref.*;
        ref.* += 1;
        break :blk tmp;
    }))).*) != 0) return -@as(c_int, 1);
    return 0;
}
pub export fn ulanguage(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var s: [*c]const u8 = undefined;
    _ = &s;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    w = bw_1.*.parent.*.main;
    s = @as([*c]BW, @ptrCast(@alignCast(w.*.object))).*.o.language;
    if (!(s != null) or !(@as(c_int, s.*) != 0)) return -@as(c_int, 1);
    while (@as(c_int, s.*) != 0) if (utypebw(bw_1, @as([*c]const u8, @ptrCast(@alignCast(blk: {
        const ref = &s;
        const tmp = ref.*;
        ref.* += 1;
        break :blk tmp;
    }))).*) != 0) return -@as(c_int, 1);
    return 0;
}
pub export fn lazy_opts(arg_b: [*c]B, arg_o: [*c]OPTIONS) void {
    var b = arg_b;
    _ = &b;
    var o = arg_o;
    _ = &o;
    var orgmap: [*c]struct_charmap = b.*.o.charmap;
    _ = &orgmap;
    o.*.syntax = load_syntax(o.*.syntax_name);
    b.*.o = o.*;
    if (!(b.*.o.map_name != null) or !((blk: {
        const tmp = find_charmap(b.*.o.map_name);
        b.*.o.charmap = tmp;
        break :blk tmp;
    }) != null)) {
        b.*.o.charmap = orgmap;
        if (orgmap != null) {
            b.*.o.map_name = orgmap.*.name;
        }
    }
    if (!(b.*.o.charmap != null)) {
        b.*.o.charmap = locale_map;
    }
    if (!(b.*.o.language != null)) {
        b.*.o.language = locale_msgs;
    }
    if (b.*.o.hex != 0) {
        if (b.*.o.charmap.*.@"type" != 0) {
            b.*.o.charmap = find_charmap("c");
            b.*.o.hex |= HEX_RESTORE_UTF8;
        }
        if (b.*.o.crlf != 0) {
            b.*.o.crlf = 0;
            b.*.o.hex |= HEX_RESTORE_CRLF;
        }
        if (!(b.*.o.overtype != 0)) {
            b.*.o.overtype = 1;
            b.*.o.hex |= HEX_RESTORE_INSERT;
        }
        if (b.*.o.wordwrap != 0) {
            b.*.o.wordwrap = 0;
            b.*.o.hex |= HEX_RESTORE_WORDWRAP;
        }
        if (b.*.o.autoindent != 0) {
            b.*.o.autoindent = 0;
            b.*.o.hex |= HEX_RESTORE_AUTOINDENT;
        }
        if (b.*.o.ansi != 0) {
            b.*.o.ansi = 0;
            b.*.o.hex |= HEX_RESTORE_ANSI;
        }
        if (b.*.o.picture != 0) {
            b.*.o.picture = 0;
            b.*.o.hex |= HEX_RESTORE_PICTURE;
        }
    }
}
pub export fn setopt(arg_b: [*c]B, arg_parsed_name: [*c]const u8) void {
    var b = arg_b;
    _ = &b;
    var parsed_name = arg_parsed_name;
    _ = &parsed_name;
    var o: [*c]OPTIONS = undefined;
    _ = &o;
    var done_flag: c_int = 0;
    _ = &done_flag;
    {
        o = options_list;
        while ((o != null) and !(done_flag != 0)) : (o = o.*.next) {
            var match: [*c]struct_options_match = undefined;
            _ = &match;
            {
                match = o.*.match;
                while ((match != null) and !(done_flag != 0)) : (match = match.*.next) {
                    if (rmatch(match.*.name_regex, parsed_name) != 0) {
                        if (match.*.contents_regex != null) {
                            var p: [*c]P = pdup(b.*.bof, "setopt");
                            _ = &p;
                            if (!(match.*.r_contents_regex != null)) {
                                match.*.r_contents_regex = joe_regcomp(ascii_map, match.*.contents_regex, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(match.*.contents_regex))))), 0, 1, 0);
                            }
                            if ((match.*.r_contents_regex != null) and !(joe_regexec(match.*.r_contents_regex, p, 0, null, 0) != 0)) {
                                prm(p);
                                lazy_opts(b, o);
                                done_flag = 1;
                            } else {
                                prm(p);
                            }
                        } else {
                            lazy_opts(b, o);
                            done_flag = 1;
                        }
                    }
                }
            }
        }
    }
    if (!(done_flag != 0)) {
        lazy_opts(b, &fdefault);
    }
}
pub const GLO_OPT_BOOL: c_int = 0;
pub const GLO_OPT_INT: c_int = 1;
pub const GLO_OPT_STRING: c_int = 2;
pub const GLO_OPT_PATH: c_int = 3;
pub const LOC_OPT_BOOL: c_int = 4;
pub const LOC_OPT_INT: c_int = 5;
pub const LOC_OPT_OFFSET: c_int = 6;
pub const LOC_OPT_STRING: c_int = 7;
pub const LOC_OPT_RANGE: c_int = 8;
pub const LOC_OPT_SYNTAX: c_int = 9;
pub const LOC_OPT_ENCODING: c_int = 10;
pub const LOC_OPT_FILE_TYPE: c_int = 11;
pub const LOC_OPT_COLORS: c_int = 12;
pub const enum_opt_type = c_uint;
pub const union_opt_storage_p = extern union {
    v: ?*anyopaque,
    c: [*c]u8,
    b: [*c]c_int,
    i: [*c]c_int,
    o: [*c]off_t,
    s: [*c][*c]u8,
};
pub const struct_glopts = extern struct {
    name: [*c]const u8 = null,
    @"type": enum_opt_type = std.mem.zeroes(enum_opt_type),
    set: union_opt_storage_p = std.mem.zeroes(union_opt_storage_p),
    addr: [*c]const u8 = null,
    yes: [*c]const u8 = null,
    no: [*c]const u8 = null,
    menu: [*c]const u8 = null,
    ofst: ptrdiff_t = 0,
    low: c_int = 0,
    high: c_int = 0,
};
pub export var glopts: [111]struct_glopts = [111]struct_glopts{
    struct_glopts{
        .name = "overwrite",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.overtype)),
        .yes = "Overtype mode",
        .no = "Insert mode",
        .menu = "Overtype mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "hex",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.hex)),
        .yes = "Hex edit mode",
        .no = "Text edit mode",
        .menu = "Hex edit display mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "viewmode",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.viewmode)),
        .yes = "Markdown view mode",
        .no = "Normal edit mode",
        .menu = "Markdown WYSIWYG view mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "ansi",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.ansi)),
        .yes = "Hide ANSI sequences",
        .no = "Reveal ANSI sequences",
        .menu = "Hide ANSI mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "title",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.title)),
        .yes = "Status line context enabled",
        .no = "Status line context disabled",
        .menu = "Status line context display mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "autoindent",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.autoindent)),
        .yes = "Autoindent enabled",
        .no = "Autoindent disabled",
        .menu = "Autoindent mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "wordwrap",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.wordwrap)),
        .yes = "Wordwrap enabled",
        .no = "Wordwrap disabled",
        .menu = "Word wrap mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "tab",
        .@"type" = LOC_OPT_OFFSET,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.tab)),
        .yes = "Tab width (%lld): ",
        .no = null,
        .menu = "Tab width",
        .ofst = 0,
        .low = 1,
        .high = 64,
    },
    struct_glopts{
        .name = "lmargin",
        .@"type" = LOC_OPT_RANGE,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.lmargin)),
        .yes = "Left margin (%d): ",
        .no = null,
        .menu = "Left margin ",
        .ofst = 0,
        .low = 0,
        .high = 63,
    },
    struct_glopts{
        .name = "rmargin",
        .@"type" = LOC_OPT_RANGE,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.rmargin)),
        .yes = "Right margin (%d): ",
        .no = null,
        .menu = "Right margin ",
        .ofst = 0,
        .low = 7,
        .high = 255,
    },
    struct_glopts{
        .name = "restore",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&restore_file_pos)),
        },
        .addr = null,
        .yes = "Restore cursor position when files loaded",
        .no = "Don't restore cursor when files loaded",
        .menu = "Restore cursor mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "regex",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&std_regex)),
        },
        .addr = null,
        .yes = "Standard regular expression format",
        .no = "JOE regular expression format",
        .menu = "Standard or JOE regular expression syntax",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "square",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&square)),
        },
        .addr = null,
        .yes = "Rectangle mode",
        .no = "Text-stream mode",
        .menu = "Rectangular region mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "icase",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&opt_icase)),
        },
        .addr = null,
        .yes = "Search ignores case by default",
        .no = "Case sensitive search by default",
        .menu = "Case insensitive search mode ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "wrap",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&wrap)),
        },
        .addr = null,
        .yes = "Search wraps",
        .no = "Search doesn't wrap",
        .menu = "Search wraps mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "menu_explorer",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&menu_explorer)),
        },
        .addr = null,
        .yes = "Menu explorer mode",
        .no = "Simple completion mode",
        .menu = "Menu explorer mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "menu_above",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&menu_above)),
        },
        .addr = null,
        .yes = "Menu above prompt",
        .no = "Menu below prompt",
        .menu = "Menu above/below mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "notagsmenu",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&notagsmenu)),
        },
        .addr = null,
        .yes = "Tags menu disabled",
        .no = "Tags menu enabled",
        .menu = "Tags menu mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "parserr_homeonly",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&parserr_homeonly)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Error logs: home dir only",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "search_prompting",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&pico)),
        },
        .addr = null,
        .yes = "Search prompting on",
        .no = "Search prompting off",
        .menu = "Search prompting mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "menu_jump",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&menu_jump)),
        },
        .addr = null,
        .yes = "Jump into menu is on",
        .no = "Jump into menu is off",
        .menu = "Jump into menu mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "autoswap",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&autoswap)),
        },
        .addr = null,
        .yes = "Autoswap ^KB and ^KK",
        .no = "Autoswap off ",
        .menu = "Autoswap mode ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "indentc",
        .@"type" = LOC_OPT_INT,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.indentc)),
        .yes = "Indent char %d (SPACE=32, TAB=9, %{abort} to abort): ",
        .no = null,
        .menu = "Indent char ",
        .ofst = 0,
        .low = 0,
        .high = 255,
    },
    struct_glopts{
        .name = "istep",
        .@"type" = LOC_OPT_OFFSET,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.istep)),
        .yes = "Indent step %lld (%{abort} to abort): ",
        .no = null,
        .menu = "Indent step ",
        .ofst = 0,
        .low = 1,
        .high = 64,
    },
    struct_glopts{
        .name = "french",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.french)),
        .yes = "One space after periods for paragraph reformat",
        .no = "Two spaces after periods for paragraph reformat",
        .menu = "French spacing mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "flowed",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.flowed)),
        .yes = "One space after paragraph line",
        .no = "No spaces after paragraph lines",
        .menu = "Flowed text mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "highlight",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.highlight)),
        .yes = "Highlighting enabled",
        .no = "Highlighting disabled",
        .menu = "Syntax highlighting mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "spaces",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.spaces)),
        .yes = "Inserting spaces when tab key is hit",
        .no = "Inserting tabs when tab key is hit",
        .menu = "No tabs mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "mid",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&opt_mid)),
        },
        .addr = null,
        .yes = "Cursor will be recentered on scrolls",
        .no = "Cursor will not be recentered on scroll",
        .menu = "Center on scroll mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "left",
        .@"type" = GLO_OPT_INT,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&opt_left)),
        },
        .addr = null,
        .yes = "Columns to scroll left or -1 for 1/2 window (%d): ",
        .no = null,
        .menu = "Left scroll amount",
        .ofst = 0,
        .low = -@as(c_int, 128),
        .high = 127,
    },
    struct_glopts{
        .name = "right",
        .@"type" = GLO_OPT_INT,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&opt_right)),
        },
        .addr = null,
        .yes = "Columns to scroll right or -1 for 1/2 window (%d): ",
        .no = null,
        .menu = "Right scroll amount",
        .ofst = 0,
        .low = -@as(c_int, 128),
        .high = 127,
    },
    struct_glopts{
        .name = "guess_crlf",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&guesscrlf)),
        },
        .addr = null,
        .yes = "Automatically detect MS-DOS files",
        .no = "Do not automatically detect MS-DOS files",
        .menu = "Auto detect CR-LF mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "guess_indent",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&guessindent)),
        },
        .addr = null,
        .yes = "Automatically detect indentation",
        .no = "Do not automatically detect indentation",
        .menu = "Guess indent mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "guess_non_utf8",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&guess_non_utf8)),
        },
        .addr = null,
        .yes = "Automatically detect non-UTF-8 in UTF-8 locale",
        .no = "Do not automatically detect non-UTF-8",
        .menu = "Guess non-UTF-8 mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "guess_utf8",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&guess_utf8)),
        },
        .addr = null,
        .yes = "Automatically detect UTF-8 in non-UTF-8 locale",
        .no = "Do not automatically detect UTF-8",
        .menu = "Guess UTF-8 mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "guess_utf16",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&guess_utf16)),
        },
        .addr = null,
        .yes = "Automatically detect UTF-16",
        .no = "Do not automatically detect UTF-16",
        .menu = "Guess UTF-16 mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "transpose",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&transpose)),
        },
        .addr = null,
        .yes = "Menu is transposed",
        .no = "Menus are not transposed",
        .menu = "Transpose menus mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "crlf",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.crlf)),
        .yes = "CR-LF is line terminator",
        .no = "LF is line terminator",
        .menu = "CR-LF (MS-DOS) mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "linums",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.linums)),
        .yes = "Line numbers enabled",
        .no = "Line numbers disabled",
        .menu = "Line numbers mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "hiline",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.hiline)),
        .yes = "Highlighting cursor line",
        .no = "Not highlighting cursor line",
        .menu = "Highlight cursor line",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "marking",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&marking)),
        },
        .addr = null,
        .yes = "Anchored block marking on",
        .no = "Anchored block marking off",
        .menu = "Region marking mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "asis",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&dspasis)),
        },
        .addr = null,
        .yes = "Characters above 127 shown as-is",
        .no = "Characters above 127 shown in inverse",
        .menu = "Display meta chars as-is mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "force",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&force)),
        },
        .addr = null,
        .yes = "Last line forced to have NL when file saved",
        .no = "Last line not forced to have NL",
        .menu = "Force last NL mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "joe_state",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(@constCast(&joe_state))),
        },
        .addr = null,
        .yes = "~/.joe_state file will be updated",
        .no = "~/.joe_state file will not be updated",
        .menu = "Joe_state file mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "nobackup",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.nobackup)),
        .yes = "Nobackup enabled",
        .no = "Nobackup disabled",
        .menu = "No backup mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "nobackups",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&nobackups)),
        },
        .addr = null,
        .yes = "Backup files will not be made",
        .no = "Backup files will be made",
        .menu = "Disable backups mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "nodeadjoe",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&nodeadjoe)),
        },
        .addr = null,
        .yes = "DEADJOE files will not be made",
        .no = "DEADJOE files will be made",
        .menu = "Disable DEADJOE mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "nolocks",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&nolocks)),
        },
        .addr = null,
        .yes = "Files will not be locked",
        .no = "Files will be locked",
        .menu = "Disable locks mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "nomodcheck",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&nomodcheck)),
        },
        .addr = null,
        .yes = "No file modification time check",
        .no = "File modification time checking enabled",
        .menu = "Disable mtime check mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "nocurdir",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&nocurdir)),
        },
        .addr = null,
        .yes = "No current dir",
        .no = "Current dir enabled",
        .menu = "Disable current dir ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "break_hardlinks",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&break_links)),
        },
        .addr = null,
        .yes = "Hardlinks will be broken",
        .no = "Hardlinks not broken",
        .menu = "Break hard links ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "break_links",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&break_symlinks)),
        },
        .addr = null,
        .yes = "Links will be broken",
        .no = "Links not broken",
        .menu = "Break links ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "lightoff",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&lightoff)),
        },
        .addr = null,
        .yes = "Highlighting turned off after block operations",
        .no = "Highlighting not turned off after block operations",
        .menu = "Auto unmark ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "exask",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&exask)),
        },
        .addr = null,
        .yes = "Prompt for filename in save & exit command",
        .no = "Don't prompt for filename in save & exit command",
        .menu = "Exit ask ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "beep",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&joe_beep)),
        },
        .addr = null,
        .yes = "Warning bell enabled",
        .no = "Warning bell disabled",
        .menu = "Beeps ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "nosta",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&staen)),
        },
        .addr = null,
        .yes = "Top-most status line disabled",
        .no = "Top-most status line enabled",
        .menu = "Disable status line ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "keepup",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&keepup)),
        },
        .addr = null,
        .yes = "Status line updated constantly",
        .no = "Status line updated once/sec",
        .menu = "Fast status line ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "pg",
        .@"type" = GLO_OPT_INT,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&pgamnt)),
        },
        .addr = null,
        .yes = "Lines to keep for PgUp/PgDn or -1 for 1/2 window (%d): ",
        .no = null,
        .menu = "No. PgUp/PgDn lines ",
        .ofst = 0,
        .low = -@as(c_int, 1),
        .high = 64,
    },
    struct_glopts{
        .name = "undo_keep",
        .@"type" = GLO_OPT_INT,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&undo_keep)),
        },
        .addr = null,
        .yes = "No. undo records to keep, or (0 for infinite): ",
        .no = null,
        .menu = "No. undo records ",
        .ofst = 0,
        .low = -@as(c_int, 1),
        .high = 64,
    },
    struct_glopts{
        .name = "csmode",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&csmode)),
        },
        .addr = null,
        .yes = "Start search after a search repeats previous search",
        .no = "Start search always starts a new search",
        .menu = "Continued search ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "rdonly",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.readonly)),
        .yes = "Read only",
        .no = "Full editing",
        .menu = "Read only ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "smarthome",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.smarthome)),
        .yes = "Smart home key enabled",
        .no = "Smart home key disabled",
        .menu = "Smart home key ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "indentfirst",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.indentfirst)),
        .yes = "Smart home goes to indentation first",
        .no = "Smart home goes home first",
        .menu = "To indent first ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "smartbacks",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.smartbacks)),
        .yes = "Smart backspace key enabled",
        .no = "Smart backspace key disabled",
        .menu = "Smart backspace ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "purify",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.purify)),
        .yes = "Indentation clean up enabled",
        .no = "Indentation clean up disabled",
        .menu = "Clean up indents ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "picture",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.picture)),
        .yes = "Picture drawing mode enabled",
        .no = "Picture drawing mode disabled",
        .menu = "Picture mode ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "backpath",
        .@"type" = GLO_OPT_PATH,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&backpath)),
        },
        .addr = null,
        .yes = "Backup files stored in (%s): ",
        .no = null,
        .menu = "Path to backup files ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "backup_file_suffix",
        .@"type" = GLO_OPT_STRING,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&backup_file_suffix)),
        },
        .addr = null,
        .yes = "Backup file suffix (%s): ",
        .no = null,
        .menu = "Backup file suffix ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "syntax_debug",
        .@"type" = LOC_OPT_INT,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.syntax_debug)),
        .yes = "Syntax debug info %d (0=off, 1=state, 2=recolor, 3=both)",
        .no = null,
        .menu = "Syntax debug mode",
        .ofst = 0,
        .low = 0,
        .high = 3,
    },
    struct_glopts{
        .name = "syntax",
        .@"type" = LOC_OPT_SYNTAX,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = null,
        .yes = "Select syntax (%{abort} to abort): ",
        .no = null,
        .menu = "Syntax",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "colors",
        .@"type" = LOC_OPT_COLORS,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = null,
        .yes = "Select color scheme (%{abort} to abort): ",
        .no = null,
        .menu = "Scheme ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "encoding",
        .@"type" = LOC_OPT_ENCODING,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = null,
        .yes = "Select file character set (%{abort} to abort): ",
        .no = null,
        .menu = "Encoding ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "type",
        .@"type" = LOC_OPT_FILE_TYPE,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = null,
        .yes = "Select file type (%{abort} to abort): ",
        .no = null,
        .menu = "File type ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "highlighter_context",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.highlighter_context)),
        .yes = "Highlighter context enabled",
        .no = "Highlighter context disabled",
        .menu = "^G uses highlighter context ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "single_quoted",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.single_quoted)),
        .yes = "Single quoting enabled",
        .no = "Single quoting disabled",
        .menu = "^G ignores '... ' ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "no_double_quoted",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.no_double_quoted)),
        .yes = "Double quoting disabled",
        .no = "Double quoting enabled",
        .menu = "^G ignores \"... \" ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "c_comment",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.c_comment)),
        .yes = "/* comments enabled",
        .no = "/* comments disabled",
        .menu = "^G ignores /*...*/ ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "cpp_comment",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.cpp_comment)),
        .yes = "// comments enabled",
        .no = "// comments disabled",
        .menu = "^G ignores //... ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "pound_comment",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.hash_comment)),
        .yes = "# comments enabled",
        .no = "# comments disabled",
        .menu = "^G ignores #... ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "hash_comment",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.hash_comment)),
        .yes = "# comments enabled",
        .no = "# comments disabled",
        .menu = "^G ignores #... ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "vhdl_comment",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.vhdl_comment)),
        .yes = "-- comments enabled",
        .no = "-- comments disabled",
        .menu = "^G ignores --... ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "semi_comment",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.semi_comment)),
        .yes = "; comments enabled",
        .no = "; comments disabled",
        .menu = "^G ignores ;... ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "tex_comment",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.tex_comment)),
        .yes = "% comments enabled",
        .no = "% comments disabled",
        .menu = "^G ignores %... ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "text_delimiters",
        .@"type" = LOC_OPT_STRING,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.text_delimiters)),
        .yes = "Text delimiters (%s): ",
        .no = null,
        .menu = "Text delimiters ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "language",
        .@"type" = LOC_OPT_STRING,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.language)),
        .yes = "Language (%s): ",
        .no = null,
        .menu = "Language ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "cpara",
        .@"type" = LOC_OPT_STRING,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.cpara)),
        .yes = "Characters which can indent paragraphs (%s): ",
        .no = null,
        .menu = "Paragraph indent chars ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "cnotpara",
        .@"type" = LOC_OPT_STRING,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.cnotpara)),
        .yes = "Characters which begin non-paragraph lines (%s): ",
        .no = null,
        .menu = "Non-paragraph chars ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "floatmouse",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&floatmouse)),
        },
        .addr = null,
        .yes = "Clicking can move the cursor past end of line",
        .no = "Clicking past end of line moves cursor to the end",
        .menu = "Click past end ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "rtbutton",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&rtbutton)),
        },
        .addr = null,
        .yes = "Mouse action is done with the right button",
        .no = "Mouse action is done with the left button",
        .menu = "Right button ",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "nonotice",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&nonotice)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Suppress startup notice",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "noexmsg",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&noexmsg)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Suppress exit message",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "help_is_utf8",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&help_is_utf8)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Help is UTF-8",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "noxon",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&noxon)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Disable XON/XOFF",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "orphan",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&orphan)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Orphan extra files",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "helpon",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&helpon)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Start editor with help displayed",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "dopadding",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&dopadding)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Emit padding NULs",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "lines",
        .@"type" = GLO_OPT_INT,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&env_lines)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "No. screen lines (if no window size ioctl)",
        .ofst = 0,
        .low = 2,
        .high = 1024,
    },
    struct_glopts{
        .name = "baud",
        .@"type" = GLO_OPT_INT,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&Baud)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Baud rate",
        .ofst = 0,
        .low = 50,
        .high = 32767,
    },
    struct_glopts{
        .name = "columns",
        .@"type" = GLO_OPT_INT,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&env_columns)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "No. screen columns (if no window size ioctl)",
        .ofst = 0,
        .low = 2,
        .high = 1024,
    },
    struct_glopts{
        .name = "skiptop",
        .@"type" = GLO_OPT_INT,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&skiptop)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "No. screen lines to skip",
        .ofst = 0,
        .low = 0,
        .high = 64,
    },
    struct_glopts{
        .name = "notite",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&notite)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Suppress tty init sequence",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "brpaste",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&brpaste)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Bracketed paste mode",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "pastehack",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&pastehack)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Paste quoting hack",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "nolinefeeds",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&nolinefeeds)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Suppress history preserving linefeeds",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "mouse",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&xmouse)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Enable mouse",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "usetabs",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&opt_usetabs)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Screen update uses tabs",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "assume_color",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&assume_color)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Assume terminal supports color",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "assume_256color",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&assume_256color)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Assume terminal supports 256 colors",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "joexterm",
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = @ptrCast(@alignCast(&joexterm)),
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = "Assume xterm patched for JOE",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = "visiblews",
        .@"type" = LOC_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = @ptrCast(@alignCast(&fdefault.visiblews)),
        .yes = "Visible whitespace enabled",
        .no = "Visible whitespace disabled",
        .menu = "Visible whitespace",
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
    struct_glopts{
        .name = null,
        .@"type" = GLO_OPT_BOOL,
        .set = union_opt_storage_p{
            .v = null,
        },
        .addr = null,
        .yes = null,
        .no = null,
        .menu = null,
        .ofst = 0,
        .low = 0,
        .high = 0,
    },
};
pub export fn cmd_help(arg_type: c_int) void {
    var @"type" = arg_type;
    _ = &@"type";
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (glopts[@bitCast(@as(isize, @intCast(x)))].name != null) : (x += 1) {
            var buf: [80]u8 = undefined;
            _ = &buf;
            buf[@as(c_int, 0)] = 0;
            if (@"type" == @as(c_int, 0)) {
                var y: c_int = 0;
                _ = &y;
                while (true) {
                    switch (glopts[@bitCast(@as(isize, @intCast(x)))].@"type") {
                        @as(enum_opt_type, LOC_OPT_BOOL) => {
                            {
                                _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "-[-]%s", glopts[@bitCast(@as(isize, @intCast(x)))].name);
                                y = 1;
                                break;
                            }
                        },
                        @as(enum_opt_type, LOC_OPT_INT), @as(enum_opt_type, LOC_OPT_OFFSET), @as(enum_opt_type, LOC_OPT_RANGE) => {
                            {
                                _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "-%s nnn", glopts[@bitCast(@as(isize, @intCast(x)))].name);
                                y = 1;
                                break;
                            }
                        },
                        @as(enum_opt_type, LOC_OPT_STRING), @as(enum_opt_type, LOC_OPT_SYNTAX), @as(enum_opt_type, LOC_OPT_ENCODING), @as(enum_opt_type, LOC_OPT_FILE_TYPE), @as(enum_opt_type, LOC_OPT_COLORS) => {
                            {
                                _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "-%s sss", glopts[@bitCast(@as(isize, @intCast(x)))].name);
                                y = 1;
                                break;
                            }
                        },
                        @as(enum_opt_type, GLO_OPT_BOOL), @as(enum_opt_type, GLO_OPT_INT), @as(enum_opt_type, GLO_OPT_STRING), @as(enum_opt_type, GLO_OPT_PATH) => {
                            {
                                break;
                            }
                        },
                        else => {},
                    }
                    break;
                }
                if (y != 0) {
                    if (glopts[@bitCast(@as(isize, @intCast(x)))].menu != null) {
                        _ = printf("    %-23s %s\n", @as([*c]u8, @ptrCast(@alignCast(&buf))), glopts[@bitCast(@as(isize, @intCast(x)))].menu);
                    } else {
                        _ = printf("    %-23s\n", @as([*c]u8, @ptrCast(@alignCast(&buf))));
                    }
                }
            } else if (@"type" == @as(c_int, 1)) {
                var y: c_int = 0;
                _ = &y;
                while (true) {
                    switch (glopts[@bitCast(@as(isize, @intCast(x)))].@"type") {
                        @as(enum_opt_type, GLO_OPT_BOOL) => {
                            {
                                _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "-[-]%s", glopts[@bitCast(@as(isize, @intCast(x)))].name);
                                y = 1;
                                break;
                            }
                        },
                        @as(enum_opt_type, GLO_OPT_INT) => {
                            {
                                _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "-%s nnn", glopts[@bitCast(@as(isize, @intCast(x)))].name);
                                y = 1;
                                break;
                            }
                        },
                        @as(enum_opt_type, GLO_OPT_STRING), @as(enum_opt_type, GLO_OPT_PATH) => {
                            {
                                _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "-%s sss", glopts[@bitCast(@as(isize, @intCast(x)))].name);
                                y = 1;
                                break;
                            }
                        },
                        @as(enum_opt_type, LOC_OPT_BOOL), @as(enum_opt_type, LOC_OPT_INT), @as(enum_opt_type, LOC_OPT_OFFSET), @as(enum_opt_type, LOC_OPT_RANGE), @as(enum_opt_type, LOC_OPT_STRING), @as(enum_opt_type, LOC_OPT_SYNTAX), @as(enum_opt_type, LOC_OPT_ENCODING), @as(enum_opt_type, LOC_OPT_FILE_TYPE), @as(enum_opt_type, LOC_OPT_COLORS) => {
                            {
                                break;
                            }
                        },
                        else => {},
                    }
                    break;
                }
                if (y != 0) {
                    if (glopts[@bitCast(@as(isize, @intCast(x)))].menu != null) {
                        _ = printf("    %-23s %s\n", @as([*c]u8, @ptrCast(@alignCast(&buf))), glopts[@bitCast(@as(isize, @intCast(x)))].menu);
                    } else {
                        _ = printf("    %-23s\n", @as([*c]u8, @ptrCast(@alignCast(&buf))));
                    }
                }
            }
        }
    }
    if (@"type" == @as(c_int, 0)) {
        _ = printf("    %-23s %s\n", @constCast("-xmsg sss"), @constCast("Exit message"));
        _ = printf("    %-23s %s\n", @constCast("-aborthint sss"), @constCast("Abort hint"));
        _ = printf("    %-23s %s\n", @constCast("-helphint sss"), @constCast("Help hint"));
        _ = printf("    %-23s %s\n", @constCast("-lmsg sss"), @constCast("Left side status line format"));
        _ = printf("    %-23s %s\n", @constCast("-rmsg sss"), @constCast("Right side status line format"));
        _ = printf("    %-23s %s\n", @constCast("-smsg sss"), @constCast("Status command format"));
        _ = printf("    %-23s %s\n", @constCast("-zmsg sss"), @constCast("Status command format EOF"));
        _ = printf("    %-23s %s\n", @constCast("-keymap sss"), @constCast("Keymap to use"));
        _ = printf("    %-23s %s\n", @constCast("-mnew sss"), @constCast("Macro to execute for new files"));
        _ = printf("    %-23s %s\n", @constCast("-mfirst sss"), @constCast("Macro to execute on first change"));
        _ = printf("    %-23s %s\n", @constCast("-mold sss"), @constCast("Macro to execute on existing files"));
        _ = printf("    %-23s %s\n", @constCast("-msnew sss"), @constCast("Macro to execute when new files are saved"));
        _ = printf("    %-23s %s\n", @constCast("-msold sss"), @constCast("Macro to execute when existing files are saved"));
        _ = printf("    %-23s %s\n", @constCast("-text_color sss"), @constCast("Text color"));
        _ = printf("    %-23s %s\n", @constCast("-help_color sss"), @constCast("Help color"));
        _ = printf("    %-23s %s\n", @constCast("-status_color sss"), @constCast("Status bar color"));
        _ = printf("    %-23s %s\n", @constCast("-menu_color sss"), @constCast("Menu color"));
        _ = printf("    %-23s %s\n", @constCast("-prompt_color sss"), @constCast("Prompt color"));
        _ = printf("    %-23s %s\n", @constCast("-msg_color sss"), @constCast("Message color"));
    }
}
pub export var isiz: c_int = 0;
pub export var opt_tab: [*c]HASH = null;
pub fn izopts() callconv(.c) void {
    var x: c_int = undefined;
    _ = &x;
    opt_tab = htmk(128);
    {
        x = 0;
        while (glopts[@bitCast(@as(isize, @intCast(x)))].name != null) : (x += 1) {
            htadd(opt_tab, glopts[@bitCast(@as(isize, @intCast(x)))].name, @ptrCast(@alignCast(@as([*c]struct_glopts, @ptrCast(@alignCast(&glopts))) + @as(usize, @bitCast(@as(isize, @intCast(x)))))));
            while (true) {
                switch (glopts[@bitCast(@as(isize, @intCast(x)))].@"type") {
                    @as(enum_opt_type, LOC_OPT_BOOL), @as(enum_opt_type, LOC_OPT_INT), @as(enum_opt_type, LOC_OPT_STRING), @as(enum_opt_type, LOC_OPT_RANGE), @as(enum_opt_type, LOC_OPT_OFFSET) => {
                        glopts[@bitCast(@as(isize, @intCast(x)))].ofst = @divExact(@as(c_long, @bitCast(@intFromPtr(glopts[@bitCast(@as(isize, @intCast(x)))].addr) -% @intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&fdefault)))))), @sizeOf(u8));
                        {}
                    },
                    else => {
                        {}
                    },
                }
                break;
            }
        }
    }
    isiz = 1;
}
pub fn getftypes() callconv(.c) [*c][*c]u8 {
    var o: [*c]OPTIONS = undefined;
    _ = &o;
    var s: [*c][*c]u8 = vaensure(null, 20);
    _ = &s;
    {
        o = options_list;
        while (o != null) : (o = o.*.next) {
            s = _vaset(s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), vsncpy(null, 0, o.*.ftype, slen(o.*.ftype)));
        }
    }
    vasort(s, (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).*);
    return s;
}
pub export var ftypes: [*c][*c]u8 = null;
pub fn ftypecmplt(arg_bw_1: [*c]BW, arg_k: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    if (!(ftypes != null)) {
        ftypes = getftypes();
    }
    return simple_cmplt(bw_1, ftypes);
}
pub fn find_ftype(arg_s: [*c]const u8) callconv(.c) [*c]OPTIONS {
    var s = arg_s;
    _ = &s;
    var o: [*c]OPTIONS = undefined;
    _ = &o;
    {
        o = options_list;
        while (o != null) : (o = o.*.next) if (!(strcmp(o.*.ftype, s) != 0)) break;
    }
    return o;
}
pub fn doftype(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
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
    var o: [*c]OPTIONS = find_ftype(s);
    _ = &o;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    vsrm(s);
    if (!(o != null)) {
        msgnw(bw_1.*.parent, my_gettext("No such file type"));
        if (notify != null) {
            notify.* = 1;
        }
        return -@as(c_int, 1);
    } else {
        lazy_opts(bw_1.*.b, o);
        bw_1.*.o = bw_1.*.b.*.o;
        return 0;
    }
}
pub export var ftypehist: [*c]B = null;
pub export var encodinghist: [*c]B = null;
pub export var colorhist: [*c]B = null;
pub export var syntaxhist: [*c]B = null;
pub export fn glopt(arg_s: [*c]u8, arg_arg: [*c]u8, arg_options_1: [*c]OPTIONS, arg_set: c_int) c_int {
    var s = arg_s;
    _ = &s;
    var arg = arg_arg;
    _ = &arg;
    var options_1 = arg_options_1;
    _ = &options_1;
    var set = arg_set;
    _ = &set;
    var val: c_int = undefined;
    _ = &val;
    var ret: c_int = 0;
    _ = &ret;
    var st: c_int = 1;
    _ = &st;
    var opt: [*c]struct_glopts = undefined;
    _ = &opt;
    if (!(isiz != 0)) {
        izopts();
    }
    if (@as(c_int, s[@as(c_int, 0)]) == @as(c_int, '-')) {
        st = 0;
        s += 1;
    }
    opt = @ptrCast(@alignCast(htfind(opt_tab, s)));
    if (opt != null) {
        while (true) {
            switch (opt.*.@"type") {
                @as(enum_opt_type, GLO_OPT_BOOL) => {
                    if (set != 0) {
                        opt.*.set.b.* = st;
                    }
                    ret = 1;
                    break;
                },
                @as(enum_opt_type, GLO_OPT_INT) => {
                    if ((set != 0) and (arg != null)) {
                        val = ztoi(arg);
                        if ((val >= opt.*.low) and (val <= opt.*.high)) {
                            opt.*.set.i.* = val;
                        }
                    }
                    ret = if (arg != null) @as(c_int, 2) else @as(c_int, 1);
                    break;
                },
                @as(enum_opt_type, GLO_OPT_STRING), @as(enum_opt_type, GLO_OPT_PATH) => {
                    if (set != 0) {
                        opt.*.set.s.* = @ptrCast(@alignCast(if (arg != null) @as(?*anyopaque, @ptrCast(@alignCast(zdup(arg)))) else @as(?*anyopaque, null)));
                    }
                    ret = if (arg != null) @as(c_int, 2) else @as(c_int, 1);
                    break;
                },
                @as(enum_opt_type, LOC_OPT_BOOL) => {
                    if (options_1 != null) {
                        @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(options_1))) + @as(usize, @bitCast(@as(isize, @intCast(opt.*.ofst))))))).* = st;
                    }
                    ret = 1;
                    break;
                },
                @as(enum_opt_type, LOC_OPT_INT) => {
                    if (arg != null) {
                        if (options_1 != null) {
                            val = ztoi(arg);
                            if ((val >= opt.*.low) and (val <= opt.*.high)) {
                                @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(options_1))) + @as(usize, @bitCast(@as(isize, @intCast(opt.*.ofst))))))).* = val;
                            }
                        }
                    }
                    ret = if (arg != null) @as(c_int, 2) else @as(c_int, 1);
                    break;
                },
                @as(enum_opt_type, LOC_OPT_OFFSET) => {
                    if (arg != null) {
                        if (options_1 != null) {
                            var zz: off_t = ztoo(arg);
                            _ = &zz;
                            if ((zz >= @as(off_t, opt.*.low)) and (zz <= @as(off_t, opt.*.high))) {
                                @as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(options_1))) + @as(usize, @bitCast(@as(isize, @intCast(opt.*.ofst))))))).* = zz;
                            }
                        }
                    }
                    ret = if (arg != null) @as(c_int, 2) else @as(c_int, 1);
                    break;
                },
                @as(enum_opt_type, LOC_OPT_FILE_TYPE) => {
                    if ((arg != null) and (options_1 != null)) {
                        var o: [*c]OPTIONS = find_ftype(arg);
                        _ = &o;
                        if (o != null) {
                            options_1.* = o.*;
                        }
                    }
                    ret = if (arg != null) @as(c_int, 2) else @as(c_int, 1);
                    break;
                },
                @as(enum_opt_type, LOC_OPT_STRING) => {
                    if (options_1 != null) {
                        @as([*c][*c]u8, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(options_1))) + @as(usize, @bitCast(@as(isize, @intCast(opt.*.ofst))))))).* = @ptrCast(@alignCast(if (arg != null) @as(?*anyopaque, @ptrCast(@alignCast(zdup(arg)))) else @as(?*anyopaque, null)));
                    }
                    ret = if (arg != null) @as(c_int, 2) else @as(c_int, 1);
                    break;
                },
                @as(enum_opt_type, LOC_OPT_RANGE) => {
                    if (arg != null) {
                        var zz: off_t = ztoo(arg);
                        _ = &zz;
                        if ((zz >= @as(off_t, opt.*.low)) and (zz <= @as(off_t, opt.*.high))) {
                            zz -= 1;
                            if (options_1 != null) {
                                @as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(options_1))) + @as(usize, @bitCast(@as(isize, @intCast(opt.*.ofst))))))).* = zz;
                            }
                        }
                    }
                    ret = if (arg != null) @as(c_int, 2) else @as(c_int, 1);
                    break;
                },
                @as(enum_opt_type, LOC_OPT_SYNTAX) => {
                    if ((arg != null) and (options_1 != null)) {
                        options_1.*.syntax_name = zdup(arg);
                    }
                    ret = if (arg != null) @as(c_int, 2) else @as(c_int, 1);
                    break;
                },
                @as(enum_opt_type, LOC_OPT_ENCODING) => {
                    if ((arg != null) and (options_1 != null)) {
                        options_1.*.map_name = zdup(arg);
                    }
                    ret = if (arg != null) @as(c_int, 2) else @as(c_int, 1);
                    break;
                },
                @as(enum_opt_type, LOC_OPT_COLORS) => {
                    if (arg != null) {
                        scheme_name = zdup(arg);
                        ret = 2;
                    } else {
                        ret = 1;
                    }
                    break;
                },
                else => {},
            }
            break;
        }
    } else {
        if (!(strcmp(s, "xmsg") != 0)) {
            if (arg != null) {
                xmsg = zdup(arg);
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "aborthint") != 0)) {
            if (arg != null) {
                aborthint = zdup(arg);
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "helphint") != 0)) {
            if (arg != null) {
                helphint = zdup(arg);
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "lmsg") != 0)) {
            if (arg != null) {
                if (options_1 != null) {
                    options_1.*.lmsg = zdup(arg);
                }
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "rmsg") != 0)) {
            if (arg != null) {
                if (options_1 != null) {
                    options_1.*.rmsg = zdup(arg);
                }
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "smsg") != 0)) {
            if (arg != null) {
                if (options_1 != null) {
                    options_1.*.smsg = zdup(arg);
                }
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "zmsg") != 0)) {
            if (arg != null) {
                if (options_1 != null) {
                    options_1.*.zmsg = zdup(arg);
                }
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "keymap") != 0)) {
            if (arg != null) {
                var y: c_int = undefined;
                _ = &y;
                {
                    y = 0;
                    while (!(locale_map.*.is_space.?(locale_map, arg[@bitCast(@as(isize, @intCast(y)))]) != 0)) : (y += 1) {}
                }
                if (!(@as(c_int, arg[@bitCast(@as(isize, @intCast(y)))]) != 0)) {
                    arg[@bitCast(@as(isize, @intCast(y)))] = 0;
                }
                if ((options_1 != null) and (y != 0)) {
                    options_1.*.context = zdup(arg);
                }
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "mnew") != 0)) {
            if (arg != null) {
                var sta: ptrdiff_t = undefined;
                _ = &sta;
                if (options_1 != null) {
                    options_1.*.mnew = mparse(null, arg, &sta, 0);
                }
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "mfirst") != 0)) {
            if (arg != null) {
                var sta: ptrdiff_t = undefined;
                _ = &sta;
                if (options_1 != null) {
                    options_1.*.mfirst = mparse(null, arg, &sta, 0);
                }
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "mold") != 0)) {
            if (arg != null) {
                var sta: ptrdiff_t = undefined;
                _ = &sta;
                if (options_1 != null) {
                    options_1.*.mold = mparse(null, arg, &sta, 0);
                }
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "msnew") != 0)) {
            if (arg != null) {
                var sta: ptrdiff_t = undefined;
                _ = &sta;
                if (options_1 != null) {
                    options_1.*.msnew = mparse(null, arg, &sta, 0);
                }
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "msold") != 0)) {
            if (arg != null) {
                var sta: ptrdiff_t = undefined;
                _ = &sta;
                if (options_1 != null) {
                    options_1.*.msold = mparse(null, arg, &sta, 0);
                }
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "text_color") != 0)) {
            if (arg != null) {
                bg_text = meta_color(arg);
                bg_help = bg_text;
                bg_prompt = bg_text;
                bg_menu = bg_text;
                bg_msg = bg_text;
                bg_stalin = bg_text;
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "help_color") != 0)) {
            if (arg != null) {
                bg_help = meta_color(arg);
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "status_color") != 0)) {
            if (arg != null) {
                bg_stalin = meta_color(arg);
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "menu_color") != 0)) {
            if (arg != null) {
                bg_menu = meta_color(arg);
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "prompt_color") != 0)) {
            if (arg != null) {
                bg_prompt = meta_color(arg);
                ret = 2;
            } else {
                ret = 1;
            }
        } else if (!(strcmp(s, "msg_color") != 0)) {
            if (arg != null) {
                bg_msg = meta_color(arg);
                ret = 2;
            } else {
                ret = 1;
            }
        }
    }
    return ret;
}
pub fn doabrt1(arg_w: [*c]W, arg_obj: ?*anyopaque) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var obj = arg_obj;
    _ = &obj;
    var xx: [*c]c_int = @ptrCast(@alignCast(obj));
    _ = &xx;
    joe_free(@ptrCast(@alignCast(xx)));
    return -@as(c_int, 1);
}
pub fn doopt1(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
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
    var ret: c_int = 0;
    _ = &ret;
    var xx: [*c]c_int = @ptrCast(@alignCast(obj));
    _ = &xx;
    var x: c_int = xx.*;
    _ = &x;
    var v: c_int = undefined;
    _ = &v;
    var vv: off_t = undefined;
    _ = &vv;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    joe_free(@ptrCast(@alignCast(xx)));
    while (true) {
        switch (glopts[@bitCast(@as(isize, @intCast(x)))].@"type") {
            @as(enum_opt_type, GLO_OPT_INT) => {
                v = @intFromFloat(calc(bw_1, s, 0));
                if (merr != null) {
                    msgnw(bw_1.*.parent, merr);
                    ret = -@as(c_int, 1);
                } else if ((v >= glopts[@bitCast(@as(isize, @intCast(x)))].low) and (v <= glopts[@bitCast(@as(isize, @intCast(x)))].high)) {
                    glopts[@bitCast(@as(isize, @intCast(x)))].set.i.* = v;
                } else {
                    msgnw(bw_1.*.parent, my_gettext("Value out of range"));
                    ret = -@as(c_int, 1);
                }
                break;
            },
            @as(enum_opt_type, GLO_OPT_STRING), @as(enum_opt_type, GLO_OPT_PATH) => {
                if (@as(c_int, s[@as(c_int, 0)]) != 0) {
                    glopts[@bitCast(@as(isize, @intCast(x)))].set.s.* = zdup(s);
                }
                break;
            },
            @as(enum_opt_type, LOC_OPT_STRING) => {
                @as([*c][*c]u8, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(x)))].ofst))))))).* = zdup(s);
                break;
            },
            @as(enum_opt_type, LOC_OPT_INT) => {
                v = @intFromFloat(calc(bw_1, s, 0));
                if (merr != null) {
                    msgnw(bw_1.*.parent, merr);
                    ret = -@as(c_int, 1);
                } else if ((v >= glopts[@bitCast(@as(isize, @intCast(x)))].low) and (v <= glopts[@bitCast(@as(isize, @intCast(x)))].high)) {
                    @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(x)))].ofst))))))).* = v;
                } else {
                    msgnw(bw_1.*.parent, my_gettext("Value out of range"));
                    ret = -@as(c_int, 1);
                }
                break;
            },
            @as(enum_opt_type, LOC_OPT_OFFSET) => {
                vv = @intFromFloat(calc(bw_1, s, 0));
                if (merr != null) {
                    msgnw(bw_1.*.parent, merr);
                    ret = -@as(c_int, 1);
                } else if ((vv >= @as(off_t, glopts[@bitCast(@as(isize, @intCast(x)))].low)) and (vv <= @as(off_t, glopts[@bitCast(@as(isize, @intCast(x)))].high))) {
                    @as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(x)))].ofst))))))).* = vv;
                } else {
                    msgnw(bw_1.*.parent, my_gettext("Value out of range"));
                    ret = -@as(c_int, 1);
                }
                break;
            },
            @as(enum_opt_type, LOC_OPT_RANGE) => {
                vv = @intFromFloat(calc(bw_1, s, 0) - @as(f64, 1.0));
                if (merr != null) {
                    msgnw(bw_1.*.parent, merr);
                    ret = -@as(c_int, 1);
                } else if ((vv >= @as(off_t, glopts[@bitCast(@as(isize, @intCast(x)))].low)) and (vv <= @as(off_t, glopts[@bitCast(@as(isize, @intCast(x)))].high))) {
                    @as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(x)))].ofst))))))).* = vv;
                } else {
                    msgnw(bw_1.*.parent, my_gettext("Value out of range"));
                    ret = -@as(c_int, 1);
                }
                break;
            },
            else => {
                {}
            },
        }
        break;
    }
    vsrm(s);
    bw_1.*.b.*.o = bw_1.*.o;
    wfit(bw_1.*.parent.*.t);
    updall();
    if (notify != null) {
        notify.* = 1;
    }
    return ret;
}
pub fn dosyntax(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
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
    var ret: c_int = 0;
    _ = &ret;
    var syn: [*c]struct_high_syntax = undefined;
    _ = &syn;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    syn = load_syntax(s);
    if (syn != null) {
        bw_1.*.o.syntax = syn;
    } else {
        msgnw(bw_1.*.parent, my_gettext("Syntax definition file not found"));
    }
    vsrm(s);
    bw_1.*.b.*.o = bw_1.*.o;
    updall();
    if (notify != null) {
        notify.* = 1;
    }
    return ret;
}
pub fn docolors(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
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
    var scheme: [*c]SCHEME = undefined;
    _ = &scheme;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    scheme = load_scheme(s);
    if (scheme != null) {
        if (apply_scheme(scheme) != 0) {
            msgnw(bw_1.*.parent, my_gettext("Color scheme failed to apply"));
        }
    } else {
        msgnw(bw_1.*.parent, my_gettext("Color scheme file not found"));
    }
    vsrm(s);
    nredraw(maint.*.t);
    if (notify != null) {
        notify.* = 1;
    }
    return 0;
}
pub fn merge_options(arg_dst: [*c][*c]u8, arg_src: [*c][*c]u8, arg_trim: c_int) callconv(.c) [*c][*c]u8 {
    var dst = arg_dst;
    _ = &dst;
    var src = arg_src;
    _ = &src;
    var trim = arg_trim;
    _ = &trim;
    if (src != null) {
        var x: c_int = undefined;
        _ = &x;
        {
            x = 0;
            while (@as(ptrdiff_t, x) < (if (src != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(src))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0))) : (x += 1) {
                var y: c_int = undefined;
                _ = &y;
                if (trim != 0) {
                    var e: [*c]u8 = strrchr(src[@bitCast(@as(isize, @intCast(x)))], @as(c_int, '.'));
                    _ = &e;
                    if (e != null) {
                        e.* = 0;
                    }
                }
                if (strcmp(src[@bitCast(@as(isize, @intCast(x)))], "..") != 0) {
                    {
                        y = 0;
                        while (@as(ptrdiff_t, y) < (if (dst != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(dst))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0))) : (y += 1) if (!(strcmp(src[@bitCast(@as(isize, @intCast(x)))], dst[@bitCast(@as(isize, @intCast(y)))]) != 0)) break;
                    }
                    if (@as(ptrdiff_t, y) == (if (dst != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(dst))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0))) {
                        dst = _vaset(dst, if (dst != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(dst))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), vsncpy(null, 0, src[@bitCast(@as(isize, @intCast(x)))], if (src[@bitCast(@as(isize, @intCast(x)))] != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(src[@bitCast(@as(isize, @intCast(x)))]))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)));
                    }
                }
            }
        }
    }
    return dst;
}
pub export fn find_configs(arg_ary: [*c][*c]u8, arg_prefix: [*c]const u8, arg_extension: [*c]const u8) [*c][*c]u8 {
    var ary = arg_ary;
    _ = &ary;
    var prefix = arg_prefix;
    _ = &prefix;
    var extension = arg_extension;
    _ = &extension;
    var wildcard: [32]u8 = undefined;
    _ = &wildcard;
    var oldpwd: [*c]u8 = pwd();
    _ = &oldpwd;
    var home: [*c]const u8 = getenv("HOME");
    _ = &home;
    var xdg: [*c]const u8 = xdg_config_dir();
    _ = &xdg;
    var path: [*c]u8 = undefined;
    _ = &path;
    var t: [*c][*c]u8 = undefined;
    _ = &t;
    if (extension != null) {
        _ = snprintf(@ptrCast(@alignCast(&wildcard)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(wildcard)))))))), "*%s", extension);
    } else {
        _ = strcpy(@ptrCast(@alignCast(&wildcard)), "*");
    }
    path = vsncpy(null, 0, "", @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("".*)) / @sizeOf(u8)) -% @as(c_ulong, 1)))));
    path = vsncpy(path, if (path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), prefix, slen(prefix));
    if (!(chpwd(path) != 0) and ((blk: {
        const tmp = rexpnd(@ptrCast(@alignCast(&wildcard)));
        t = tmp;
        break :blk tmp;
    }) != null)) {
        ary = merge_options(ary, t, @intFromBool(!!(extension != null)));
        varm(t);
    }
    vsrm(path);
    if (home != null) {
        path = vsncpy(null, 0, home, slen(home));
        path = vsncpy(path, if (path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "/.joe/", @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("/.joe/".*)) / @sizeOf(u8)) -% @as(c_ulong, 1)))));
        path = vsncpy(path, if (path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), prefix, slen(prefix));
        if (!(chpwd(path) != 0) and ((blk: {
            const tmp = rexpnd(@ptrCast(@alignCast(&wildcard)));
            t = tmp;
            break :blk tmp;
        }) != null)) {
            ary = merge_options(ary, t, @intFromBool(!!(extension != null)));
            varm(t);
        }
        vsrm(path);
    }
    if (xdg != null) {
        path = vsncpy(null, 0, xdg, if (xdg != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(@constCast(xdg)))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        path = vsncpy(path, if (path != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(path))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), prefix, slen(prefix));
        if (!(chpwd(path) != 0) and ((blk: {
            const tmp = rexpnd(@ptrCast(@alignCast(&wildcard)));
            t = tmp;
            break :blk tmp;
        }) != null)) {
            ary = merge_options(ary, t, @intFromBool(!!(extension != null)));
            varm(t);
        }
        vsrm(path);
    }
    if (extension != null) {
        t = jgetbuiltins(extension);
        if (t != null) {
            ary = merge_options(ary, t, @intFromBool(!!(extension != null)));
        }
        varm(t);
    }
    _ = chpwd(oldpwd);
    if ((if (ary != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(ary))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) != 0) {
        vasort(ary, if (ary != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(ary))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    }
    return ary;
}
pub export var syntaxes: [*c][*c]u8 = null;
pub fn syntaxcmplt(arg_bw_1: [*c]BW, arg_k: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    if (!(syntaxes != null)) {
        syntaxes = find_configs(null, "syntax", ".jsf");
    }
    return simple_file_cmplt(bw_1, syntaxes);
}
pub export var colorfiles: [*c][*c]u8 = null;
pub fn colorscmplt(arg_bw_1: [*c]BW, arg_k: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    if (!(colorfiles != null)) {
        colorfiles = find_configs(null, "colors", ".jcf");
    }
    return simple_file_cmplt(bw_1, colorfiles);
}
pub fn check_for_hex(arg_bw_1: [*c]BW) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var w: [*c]W = undefined;
    _ = &w;
    if (bw_1.*.o.hex != 0) return 1;
    {
        w = bw_1.*.parent.*.link_next;
        while (w != bw_1.*.parent) : (w = w.*.link_next) if ((((w.*.watom == (&watomtw)) or (w.*.watom == (&watompw))) and (@as([*c]BW, @ptrCast(@alignCast(w.*.object))).*.b == bw_1.*.b)) and (@as([*c]BW, @ptrCast(@alignCast(w.*.object))).*.o.hex != 0)) return 1;
    }
    return 0;
}
pub fn doencoding(arg_w: [*c]W, arg_s: [*c]u8, arg_obj: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
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
    var ret: c_int = 0;
    _ = &ret;
    var map: [*c]struct_charmap = undefined;
    _ = &map;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    map = find_charmap(s);
    if (((map != null) and (map.*.@"type" != 0)) and (check_for_hex(bw_1) != 0)) {
        msgnw(bw_1.*.parent, my_gettext("UTF-8 encoding not allowed with hexadecimal windows"));
        if (notify != null) {
            notify.* = 1;
        }
        return -@as(c_int, 1);
    }
    if (map != null) {
        bw_1.*.o.charmap = map;
        _ = snprintf(msgbuf, @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("%s encoding assumed for this file"), map.*.name);
        msgnw(bw_1.*.parent, msgbuf);
    } else {
        msgnw(bw_1.*.parent, my_gettext("Character set not found"));
    }
    vsrm(s);
    bw_1.*.b.*.o = bw_1.*.o;
    bw_1.*.cursor.*.valcol = 0;
    bw_1.*.cursor.*.xcol = if (bw_1.*.cursor.*.valcol != 0) bw_1.*.cursor.*.col else blk: {
        _ = pfcol(bw_1.*.cursor);
        break :blk bw_1.*.cursor.*.col;
    };
    updall();
    if (notify != null) {
        notify.* = 1;
    }
    return ret;
}
pub export var encodings: [*c][*c]u8 = null;
pub fn encodingcmplt(arg_bw_1: [*c]BW, arg_k: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    if (!(encodings != null)) {
        encodings = @ptrCast(@alignCast(get_encodings()));
        vasort(encodings, if (encodings != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(encodings))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    }
    return simple_file_cmplt(bw_1, encodings);
}
pub fn find_option(arg_s: [*c]u8) callconv(.c) c_int {
    var s = arg_s;
    _ = &s;
    var y: c_int = undefined;
    _ = &y;
    {
        y = 0;
        while (glopts[@bitCast(@as(isize, @intCast(y)))].name != null) : (y += 1) if (!(strcmp(glopts[@bitCast(@as(isize, @intCast(y)))].name, s) != 0)) return y;
    }
    return -@as(c_int, 1);
}
pub fn applyopt(arg_bw_1: [*c]BW, arg_optp: [*c]c_int, arg_y: c_int, arg_flg: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var optp = arg_optp;
    _ = &optp;
    var y = arg_y;
    _ = &y;
    var flg = arg_flg;
    _ = &flg;
    var oldval: c_int = undefined;
    _ = &oldval;
    var newval: c_int = undefined;
    _ = &newval;
    var msg: [*c]const u8 = undefined;
    _ = &msg;
    oldval = optp.*;
    if (flg == @as(c_int, 0)) {
        newval = @intFromBool(!(oldval != 0));
    } else if (flg == @as(c_int, 1)) {
        newval = if (oldval != 0) oldval else @as(c_int, 1);
    } else {
        newval = 0;
    }
    optp.* = newval;
    msg = if (newval != 0) glopts[@bitCast(@as(isize, @intCast(y)))].yes else glopts[@bitCast(@as(isize, @intCast(y)))].no;
    if (msg != null) {
        msgnw(bw_1.*.parent, my_gettext(msg));
    } else {
        msg = if (newval != 0) @constCast("ON") else @constCast("OFF");
        if (glopts[@bitCast(@as(isize, @intCast(y)))].menu != null) {
            _ = snprintf(msgbuf, @bitCast(@as(c_long, JOE_MSGBUFSIZE)), "%s: %s", my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].menu), msg);
            msgnw(bw_1.*.parent, msgbuf);
        } else {
            msgnw(bw_1.*.parent, msg);
        }
    }
    return oldval;
}
pub fn olddoopt(arg_bw_1: [*c]BW, arg_y: c_int, arg_flg: c_int, arg_notify: [*c]c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var y = arg_y;
    _ = &y;
    var flg = arg_flg;
    _ = &flg;
    var notify = arg_notify;
    _ = &notify;
    var xx: [*c]c_int = undefined;
    _ = &xx;
    var oldval: c_int = undefined;
    _ = &oldval;
    var buf: [300]u8 = undefined;
    _ = &buf;
    if (y >= @as(c_int, 0)) {
        while (true) {
            switch (glopts[@bitCast(@as(isize, @intCast(y)))].@"type") {
                @as(enum_opt_type, GLO_OPT_BOOL) => {
                    _ = applyopt(bw_1, glopts[@bitCast(@as(isize, @intCast(y)))].set.b, y, flg);
                    break;
                },
                @as(enum_opt_type, LOC_OPT_BOOL) => {
                    oldval = applyopt(bw_1, @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))), y, flg);
                    if (@as(c_ulong, @bitCast(@as(c_long, glopts[@bitCast(@as(isize, @intCast(y)))].ofst))) == @intFromPtr(&@as(*allowzero OPTIONS, @ptrFromInt(0)).readonly)) {
                        bw_1.*.b.*.rdonly = bw_1.*.o.readonly;
                    }
                    if (@as(c_ulong, @bitCast(@as(c_long, glopts[@bitCast(@as(isize, @intCast(y)))].ofst))) == @intFromPtr(&@as(*allowzero OPTIONS, @ptrFromInt(0)).hex)) {
                        if ((bw_1.*.o.hex != 0) and !(oldval != 0)) {
                            bw_1.*.o.hex = 1;
                            if (bw_1.*.b.*.o.charmap.*.@"type" != 0) {
                                _ = doencoding(bw_1.*.parent, vsncpy(null, 0, "C", @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("C".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))), null, null);
                                bw_1.*.o.hex |= HEX_RESTORE_UTF8;
                            }
                            if (bw_1.*.o.crlf != 0) {
                                bw_1.*.o.crlf = 0;
                                bw_1.*.o.hex |= HEX_RESTORE_CRLF;
                            }
                            if (!(bw_1.*.o.overtype != 0)) {
                                bw_1.*.o.overtype = 1;
                                bw_1.*.o.hex |= HEX_RESTORE_INSERT;
                            }
                            if (bw_1.*.o.wordwrap != 0) {
                                bw_1.*.o.wordwrap = 0;
                                bw_1.*.o.hex |= HEX_RESTORE_WORDWRAP;
                            }
                            if (bw_1.*.o.autoindent != 0) {
                                bw_1.*.o.autoindent = 0;
                                bw_1.*.o.hex |= HEX_RESTORE_AUTOINDENT;
                            }
                            if (bw_1.*.o.ansi != 0) {
                                bw_1.*.o.ansi = 0;
                                bw_1.*.o.hex |= HEX_RESTORE_ANSI;
                            }
                            if (bw_1.*.o.picture != 0) {
                                bw_1.*.o.picture = 0;
                                bw_1.*.o.hex |= HEX_RESTORE_PICTURE;
                            }
                            bw_1.*.offset = 0;
                        } else if (!(bw_1.*.o.hex != 0) and (oldval != 0)) {
                            if (((oldval & HEX_RESTORE_UTF8) != 0) and !(strcmp(bw_1.*.b.*.o.charmap.*.name, "ascii") != 0)) {
                                _ = doencoding(bw_1.*.parent, vsncpy(null, 0, "UTF-8", @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("UTF-8".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))), null, null);
                            }
                            if ((oldval & HEX_RESTORE_CRLF) != 0) {
                                bw_1.*.o.crlf = 1;
                            }
                            if ((oldval & HEX_RESTORE_INSERT) != 0) {
                                bw_1.*.o.overtype = 0;
                            }
                            if ((oldval & HEX_RESTORE_WORDWRAP) != 0) {
                                bw_1.*.o.wordwrap = 1;
                            }
                            if ((oldval & HEX_RESTORE_AUTOINDENT) != 0) {
                                bw_1.*.o.autoindent = 1;
                            }
                            if ((oldval & HEX_RESTORE_ANSI) != 0) {
                                bw_1.*.o.ansi = 1;
                            }
                            if ((oldval & HEX_RESTORE_PICTURE) != 0) {
                                bw_1.*.o.picture = 1;
                            }
                            bw_1.*.cursor.*.xcol = if (bw_1.*.cursor.*.valcol != 0) bw_1.*.cursor.*.col else blk: {
                                _ = pfcol(bw_1.*.cursor);
                                break :blk bw_1.*.cursor.*.col;
                            };
                        }
                    }
                    break;
                },
                @as(enum_opt_type, LOC_OPT_STRING) => {
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (@as([*c][*c]u8, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).* != null) {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), glopts[@bitCast(@as(isize, @intCast(y)))].yes, @as([*c][*c]u8, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    } else {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), glopts[@bitCast(@as(isize, @intCast(y)))].yes, @constCast(""));
                    }
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, utypebw, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), glopts[@bitCast(@as(isize, @intCast(y)))].set.i.*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    if (glopts[@bitCast(@as(isize, @intCast(y)))].set.s.* != null) {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), glopts[@bitCast(@as(isize, @intCast(y)))].set.s.*);
                    } else {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    }
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, utypebw, @ptrCast(@alignCast(xx)), notify, locale_map, 0) != null) return 0 else return -@as(c_int, 1);
                    if (glopts[@bitCast(@as(isize, @intCast(y)))].set.s.* != null) {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), glopts[@bitCast(@as(isize, @intCast(y)))].set.s.*);
                    } else {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    }
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &filehist, doopt1, null, doabrt1, cmplt_file, @ptrCast(@alignCast(xx)), notify, locale_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).* + @as(c_int, 1));
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &syntaxhist, dosyntax, null, null, syntaxcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &encodinghist, doencoding, null, null, encodingcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &ftypehist, doftype, @constCast("ftype"), null, ftypecmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &colorhist, docolors, null, null, colorscmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                },
                @as(enum_opt_type, GLO_OPT_INT) => {
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), glopts[@bitCast(@as(isize, @intCast(y)))].set.i.*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    if (glopts[@bitCast(@as(isize, @intCast(y)))].set.s.* != null) {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), glopts[@bitCast(@as(isize, @intCast(y)))].set.s.*);
                    } else {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    }
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, utypebw, @ptrCast(@alignCast(xx)), notify, locale_map, 0) != null) return 0 else return -@as(c_int, 1);
                    if (glopts[@bitCast(@as(isize, @intCast(y)))].set.s.* != null) {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), glopts[@bitCast(@as(isize, @intCast(y)))].set.s.*);
                    } else {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    }
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &filehist, doopt1, null, doabrt1, cmplt_file, @ptrCast(@alignCast(xx)), notify, locale_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).* + @as(c_int, 1));
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &syntaxhist, dosyntax, null, null, syntaxcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &encodinghist, doencoding, null, null, encodingcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &ftypehist, doftype, @constCast("ftype"), null, ftypecmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &colorhist, docolors, null, null, colorscmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                },
                @as(enum_opt_type, GLO_OPT_STRING) => {
                    if (glopts[@bitCast(@as(isize, @intCast(y)))].set.s.* != null) {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), glopts[@bitCast(@as(isize, @intCast(y)))].set.s.*);
                    } else {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    }
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, utypebw, @ptrCast(@alignCast(xx)), notify, locale_map, 0) != null) return 0 else return -@as(c_int, 1);
                    if (glopts[@bitCast(@as(isize, @intCast(y)))].set.s.* != null) {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), glopts[@bitCast(@as(isize, @intCast(y)))].set.s.*);
                    } else {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    }
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &filehist, doopt1, null, doabrt1, cmplt_file, @ptrCast(@alignCast(xx)), notify, locale_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).* + @as(c_int, 1));
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &syntaxhist, dosyntax, null, null, syntaxcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &encodinghist, doencoding, null, null, encodingcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &ftypehist, doftype, @constCast("ftype"), null, ftypecmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &colorhist, docolors, null, null, colorscmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                },
                @as(enum_opt_type, GLO_OPT_PATH) => {
                    if (glopts[@bitCast(@as(isize, @intCast(y)))].set.s.* != null) {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), glopts[@bitCast(@as(isize, @intCast(y)))].set.s.*);
                    } else {
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    }
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &filehist, doopt1, null, doabrt1, cmplt_file, @ptrCast(@alignCast(xx)), notify, locale_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).* + @as(c_int, 1));
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &syntaxhist, dosyntax, null, null, syntaxcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &encodinghist, doencoding, null, null, encodingcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &ftypehist, doftype, @constCast("ftype"), null, ftypecmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &colorhist, docolors, null, null, colorscmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                },
                @as(enum_opt_type, LOC_OPT_INT) => {
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).* + @as(c_int, 1));
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &syntaxhist, dosyntax, null, null, syntaxcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &encodinghist, doencoding, null, null, encodingcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &ftypehist, doftype, @constCast("ftype"), null, ftypecmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &colorhist, docolors, null, null, colorscmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                },
                @as(enum_opt_type, LOC_OPT_OFFSET) => {
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).* + @as(c_int, 1));
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &syntaxhist, dosyntax, null, null, syntaxcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &encodinghist, doencoding, null, null, encodingcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &ftypehist, doftype, @constCast("ftype"), null, ftypecmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &colorhist, docolors, null, null, colorscmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                },
                @as(enum_opt_type, LOC_OPT_RANGE) => {
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).* + @as(c_int, 1));
                    xx = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))));
                    xx.* = y;
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), null, doopt1, null, doabrt1, math_cmplt, @ptrCast(@alignCast(xx)), notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &syntaxhist, dosyntax, null, null, syntaxcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &encodinghist, doencoding, null, null, encodingcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &ftypehist, doftype, @constCast("ftype"), null, ftypecmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &colorhist, docolors, null, null, colorscmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                },
                @as(enum_opt_type, LOC_OPT_SYNTAX) => {
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &syntaxhist, dosyntax, null, null, syntaxcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &encodinghist, doencoding, null, null, encodingcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &ftypehist, doftype, @constCast("ftype"), null, ftypecmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &colorhist, docolors, null, null, colorscmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                },
                @as(enum_opt_type, LOC_OPT_ENCODING) => {
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &encodinghist, doencoding, null, null, encodingcmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &ftypehist, doftype, @constCast("ftype"), null, ftypecmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &colorhist, docolors, null, null, colorscmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                },
                @as(enum_opt_type, LOC_OPT_FILE_TYPE) => {
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &ftypehist, doftype, @constCast("ftype"), null, ftypecmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &colorhist, docolors, null, null, colorscmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                },
                @as(enum_opt_type, LOC_OPT_COLORS) => {
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), my_gettext(glopts[@bitCast(@as(isize, @intCast(y)))].yes), @constCast(""));
                    if (wmkpw(bw_1.*.parent, @ptrCast(@alignCast(&buf)), &colorhist, docolors, null, null, colorscmplt, null, notify, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
                },
                else => {},
            }
            break;
        }
    }
    if (notify != null) {
        notify.* = 1;
    }
    bw_1.*.b.*.o = bw_1.*.o;
    wfit(bw_1.*.parent.*.t);
    updall();
    return 0;
}
pub export fn get_status(arg_bw_1: [*c]BW, arg_s: [*c]u8) [*c]const u8 {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var s = arg_s;
    _ = &s;
    const static_local_buf = struct {
        var buf: [300]u8 = std.mem.zeroes([300]u8);
    };
    _ = &static_local_buf;
    var y: c_int = find_option(s);
    _ = &y;
    if (y == -@as(c_int, 1)) return "???" else {
        while (true) {
            switch (glopts[@bitCast(@as(isize, @intCast(y)))].@"type") {
                @as(enum_opt_type, GLO_OPT_BOOL) => {
                    return if (glopts[@bitCast(@as(isize, @intCast(y)))].set.b.* != 0) @constCast("ON") else @constCast("OFF");
                },
                @as(enum_opt_type, GLO_OPT_INT) => {
                    _ = snprintf(@ptrCast(@alignCast(&static_local_buf.buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), "%d", glopts[@bitCast(@as(isize, @intCast(y)))].set.i.*);
                    return @ptrCast(@alignCast(&static_local_buf.buf));
                },
                @as(enum_opt_type, GLO_OPT_STRING), @as(enum_opt_type, GLO_OPT_PATH) => {
                    _ = snprintf(@ptrCast(@alignCast(&static_local_buf.buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), "%s", if (glopts[@bitCast(@as(isize, @intCast(y)))].set.s.* != null) glopts[@bitCast(@as(isize, @intCast(y)))].set.s.* else @as([*c]u8, @ptrCast(@constCast(""))));
                    return @ptrCast(@alignCast(&static_local_buf.buf));
                },
                @as(enum_opt_type, LOC_OPT_BOOL) => {
                    return if (@as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).* != 0) @constCast("ON") else @constCast("OFF");
                },
                @as(enum_opt_type, LOC_OPT_INT) => {
                    _ = snprintf(@ptrCast(@alignCast(&static_local_buf.buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), "%d", @as([*c]c_int, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*);
                    return @ptrCast(@alignCast(&static_local_buf.buf));
                },
                @as(enum_opt_type, LOC_OPT_STRING) => {
                    _ = snprintf(@ptrCast(@alignCast(&static_local_buf.buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), "%s", if (@as([*c][*c]u8, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).* != null) @as([*c][*c]u8, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).* else @as([*c]u8, @ptrCast(@constCast(""))));
                    return @ptrCast(@alignCast(&static_local_buf.buf));
                },
                @as(enum_opt_type, LOC_OPT_RANGE) => {
                    _ = snprintf(@ptrCast(@alignCast(&static_local_buf.buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), "%ld", @as(c_long, @truncate(@as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*)) + @as(c_long, 1));
                    return @ptrCast(@alignCast(&static_local_buf.buf));
                },
                @as(enum_opt_type, LOC_OPT_SYNTAX) => {
                    _ = snprintf(@ptrCast(@alignCast(&static_local_buf.buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), "%s", if (bw_1.*.o.syntax_name != null) bw_1.*.o.syntax_name else @as([*c]const u8, @ptrCast(@alignCast(@constCast("")))));
                    return @ptrCast(@alignCast(&static_local_buf.buf));
                },
                @as(enum_opt_type, LOC_OPT_ENCODING) => {
                    _ = snprintf(@ptrCast(@alignCast(&static_local_buf.buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), "%s", if (bw_1.*.o.map_name != null) bw_1.*.o.map_name else @as([*c]const u8, @ptrCast(@alignCast(@constCast("")))));
                    return @ptrCast(@alignCast(&static_local_buf.buf));
                },
                @as(enum_opt_type, LOC_OPT_OFFSET) => {
                    _ = snprintf(@ptrCast(@alignCast(&static_local_buf.buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), "%ld", @as(c_long, @truncate(@as([*c]off_t, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&bw_1.*.o))) + @as(usize, @bitCast(@as(isize, @intCast(glopts[@bitCast(@as(isize, @intCast(y)))].ofst))))))).*)));
                    return @ptrCast(@alignCast(&static_local_buf.buf));
                },
                @as(enum_opt_type, LOC_OPT_FILE_TYPE) => {
                    return bw_1.*.o.ftype;
                },
                @as(enum_opt_type, LOC_OPT_COLORS) => {
                    _ = snprintf(@ptrCast(@alignCast(&static_local_buf.buf)), @bitCast(@as(c_long, OPT_BUF_SIZE)), "%s", if (scheme_name != null) scheme_name else @as([*c]u8, @ptrCast(@constCast(""))));
                    return @ptrCast(@alignCast(&static_local_buf.buf));
                },
                else => {
                    return "";
                },
            }
            break;
        }
    }
    return undefined;
}
pub fn getoptions() callconv(.c) [*c][*c]u8 {
    var s: [*c][*c]u8 = vaensure(null, 20);
    _ = &s;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (glopts[@bitCast(@as(isize, @intCast(x)))].name != null) : (x += 1) {
            s = _vaset(s, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), vsncpy(null, 0, glopts[@bitCast(@as(isize, @intCast(x)))].name, slen(glopts[@bitCast(@as(isize, @intCast(x)))].name)));
        }
    }
    vasort(s, (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).*);
    return s;
}
pub export var sopts: [*c][*c]u8 = null;
pub fn optcmplt(arg_bw_1: [*c]BW, arg_k: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    if (!(sopts != null)) {
        sopts = getoptions();
    }
    return simple_cmplt(bw_1, sopts);
}
pub fn doopt(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
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
    var y: c_int = find_option(s);
    _ = &y;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    vsrm(s);
    if (y == -@as(c_int, 1)) {
        msgnw(bw_1.*.parent, my_gettext("No such option"));
        if (notify != null) {
            notify.* = 1;
        }
        return -@as(c_int, 1);
    } else {
        var flg: c_int = menu_flg;
        _ = &flg;
        menu_flg = 0;
        return olddoopt(bw_1, y, flg, notify);
    }
}
pub export var opthist: [*c]B = null;
pub export fn umode(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (wmkpw(w, @ptrCast(@alignCast(@constCast(my_gettext("Option: ")))), &opthist, doopt, @constCast("opt"), null, optcmplt, null, null, locale_map, 0) != null) {
        return 0;
    } else {
        return -@as(c_int, 1);
    }
}

comptime {
    if (@sizeOf(OPTIONS) != 344) @compileError("OPTIONS size mismatch");
    if (@sizeOf(struct_options_match) != 32) @compileError("options_match size mismatch");
    if (@sizeOf(B) != 632) @compileError("B size mismatch");
    if (@sizeOf(BW) != 488) @compileError("BW size mismatch");
    if (@sizeOf(W) != 200) @compileError("W size mismatch");
    if (@sizeOf(P) != 112) @compileError("P size mismatch");
}
