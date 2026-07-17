//! RC file parser — replaces `joe/rc.c`.
//!
//! Faithful C-ABI port of JOE's joerc processor (`procrc` / `validate_rc`).
//! Generated from rc.c (already goto-free) via `zig translate-c`,
//! then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;
pub const off_t = i64;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn strcmp(__s1: [*c]const u8, __s2: [*c]const u8) c_int;

pub const struct_regcomp = extern struct {
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
pub const struct_options_match = extern struct {
    next: [*c]struct_options_match = null,
    name_regex: [*c]const u8 = null,
    contents_regex: [*c]const u8 = null,
    r_contents_regex: [*c]struct_regcomp = null,
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
    syntax: ?*anyopaque = null,
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
pub const struct_cap = extern struct {
    _pad: [88]u8 = std.mem.zeroes([88]u8),
};
pub const CAP = struct_cap;
pub const struct_jfile = extern struct {
    _pad: [16]u8 = std.mem.zeroes([16]u8),
};
pub const JFILE = struct_jfile;
pub const struct_kmap = extern struct {
    _pad: [280]u8 = std.mem.zeroes([280]u8),
};
pub const KMAP = struct_kmap;
pub const struct_rc_menu = extern struct {
    _pad: [48]u8 = std.mem.zeroes([48]u8),
};

pub extern var fdefault: OPTIONS;
pub extern var options_list: [*c]OPTIONS;
pub extern var locale_map: [*c]struct_charmap;
const i_msg: [*c]u8 = @extern([*c]u8, .{ .name = "i_msg" });

pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn internal_msg(s: [*c]const u8) void;
pub extern fn setlogerrs() void;
pub extern fn joe_malloc(n: usize) ?*anyopaque;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn zlcpy(a: [*c]u8, siz: ptrdiff_t, b: [*c]const u8) [*c]u8;
pub extern fn vsrm(v: [*c]u8) void;
pub extern fn joe_isblank(map: [*c]struct_charmap, c: c_int) c_int;
pub extern fn joe_isspace_eos(map: [*c]struct_charmap, c: c_int) c_int;
pub extern fn jfgets(buf: [*c]u8, len: c_int, f: [*c]JFILE) [*c]u8;
pub extern fn jfclose(f: [*c]JFILE) c_int;
pub extern fn open_rc_file(result: [*c][*c]JFILE, prefix: [*c]const u8, name: [*c]const u8, suffix: [*c]const u8) [*c]u8;
pub extern fn mparse(m: [*c]MACRO, buf: [*c]const u8, sta: [*c]ptrdiff_t, secure: c_int) [*c]MACRO;
pub extern fn addcmd(s: [*c]const u8, m: [*c]MACRO) void;
pub extern fn help_init(fd: [*c]JFILE, bf: [*c]u8, line: c_int) c_int;
pub extern fn glopt(s: [*c]u8, arg: [*c]u8, options: [*c]OPTIONS, set: c_int) c_int;
pub extern fn kmap_getcontext(name: [*c]const u8) [*c]KMAP;
pub extern fn ngetcontext(name: [*c]const u8) [*c]KMAP;
pub extern fn kmap_empty(k: [*c]KMAP) c_int;
pub extern fn kadd(cap: [*c]CAP, kmap: [*c]KMAP, seq: [*c]u8, bind: [*c]MACRO) c_int;
pub extern fn kcpy(dest: [*c]KMAP, src: [*c]KMAP) void;
pub extern fn kdel(kmap: [*c]KMAP, seq: [*c]u8) c_int;
pub extern fn create_menu(name: [*c]u8, bs: [*c]MACRO) [*c]struct_rc_menu;
pub extern fn add_menu_entry(menu: [*c]struct_rc_menu, entry_name: [*c]u8, m: [*c]MACRO) void;

pub export fn validate_rc() c_int {
    var k: [*c]KMAP = undefined;
    _ = &k;
    if (!((blk: {
        const tmp = ngetcontext("main");
        k = tmp;
        break :blk tmp;
    }) != null) or (kmap_empty(k) != 0)) {
        _ = zlcpy(i_msg, 128, my_gettext("Missing or empty :main keymap\n"));
        internal_msg(i_msg);
        setlogerrs();
        return -@as(c_int, 1);
    }
    if (!((blk: {
        const tmp = ngetcontext("prompt");
        k = tmp;
        break :blk tmp;
    }) != null) or (kmap_empty(k) != 0)) {
        _ = zlcpy(i_msg, 128, my_gettext("Missing or empty :prompt keymap\n"));
        internal_msg(i_msg);
        setlogerrs();
        return -@as(c_int, 1);
    }
    if (!((blk: {
        const tmp = ngetcontext("query");
        k = tmp;
        break :blk tmp;
    }) != null) or (kmap_empty(k) != 0)) {
        _ = zlcpy(i_msg, 128, my_gettext("Missing or empty :query keymap\n"));
        internal_msg(i_msg);
        setlogerrs();
        return -@as(c_int, 1);
    }
    if (!((blk: {
        const tmp = ngetcontext("querya");
        k = tmp;
        break :blk tmp;
    }) != null) or (kmap_empty(k) != 0)) {
        _ = zlcpy(i_msg, 128, my_gettext("Missing or empty :querya keymap\n"));
        internal_msg(i_msg);
        setlogerrs();
        return -@as(c_int, 1);
    }
    if (!((blk: {
        const tmp = ngetcontext("querysr");
        k = tmp;
        break :blk tmp;
    }) != null) or (kmap_empty(k) != 0)) {
        _ = zlcpy(i_msg, 128, my_gettext("Missing or empty :querysr keymap\n"));
        internal_msg(i_msg);
        setlogerrs();
        return -@as(c_int, 1);
    }
    if (!((blk: {
        const tmp = ngetcontext("shell");
        k = tmp;
        break :blk tmp;
    }) != null) or (kmap_empty(k) != 0)) {
        _ = zlcpy(i_msg, 128, my_gettext("Missing or empty :shell keymap\n"));
        internal_msg(i_msg);
        setlogerrs();
    }
    if (!((blk: {
        const tmp = ngetcontext("vtshell");
        k = tmp;
        break :blk tmp;
    }) != null) or (kmap_empty(k) != 0)) {
        _ = zlcpy(i_msg, 128, my_gettext("Missing or empty :vtshell keymap\n"));
        internal_msg(i_msg);
        setlogerrs();
    }
    return 0;
}
pub fn multiparse(arg_fd: [*c]JFILE, arg_refline: [*c]c_int, arg_buf: [*c]u8, arg_ofst: [*c]ptrdiff_t, arg_referr: [*c]c_int, arg_name: [*c]u8) callconv(.c) [*c]MACRO {
    var fd = arg_fd;
    _ = &fd;
    var refline = arg_refline;
    _ = &refline;
    var buf = arg_buf;
    _ = &buf;
    var ofst = arg_ofst;
    _ = &ofst;
    var referr = arg_referr;
    _ = &referr;
    var name = arg_name;
    _ = &name;
    var m: [*c]MACRO = undefined;
    _ = &m;
    var x: ptrdiff_t = ofst.*;
    _ = &x;
    var err: c_int = referr.*;
    _ = &err;
    var line: c_int = refline.*;
    _ = &line;
    m = null;
    while (true) {
        m = mparse(m, buf + @as(usize, @bitCast(@as(isize, @intCast(x)))), &x, 0);
        if (x == @as(ptrdiff_t, -@as(c_int, 1))) {
            err = -@as(c_int, 1);
            _ = snprintf(i_msg, 128, my_gettext("%s %d: Unknown command in macro\n"), name, line);
            internal_msg(i_msg);
            setlogerrs();
            break;
        } else if (x == @as(ptrdiff_t, -@as(c_int, 2))) {
            _ = jfgets(buf, 1024, fd);
            line += 1;
            x = 0;
        } else break;
    }
    referr.* = err;
    refline.* = line;
    ofst.* = x;
    return m;
}
pub export fn procrc(arg_cap_1: [*c]CAP, arg_fd: [*c]JFILE, arg_name: [*c]u8) c_int {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var fd = arg_fd;
    _ = &fd;
    var name = arg_name;
    _ = &name;
    var o: [*c]OPTIONS = &fdefault;
    _ = &o;
    var context: [*c]KMAP = null;
    _ = &context;
    var current_menu: [*c]struct_rc_menu = null;
    _ = &current_menu;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    var buf1: [1024]u8 = undefined;
    _ = &buf1;
    var line: c_int = 0;
    _ = &line;
    var err: c_int = 0;
    _ = &err;
    _ = snprintf(i_msg, 128, my_gettext("Processing '%s'...\n"), name);
    internal_msg(i_msg);
    while (jfgets(@ptrCast(@alignCast(&buf)), @truncate(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf))))))), fd) != null) {
        line += 1;
        while (true) {
            switch (@as(c_int, buf[@as(c_int, 0)])) {
                @as(c_int, ' '), @as(c_int, '\t'), @as(c_int, '\n'), @as(c_int, '\x0c'), @as(c_int, 0) => {
                    break;
                },
                @as(c_int, '[') => {
                    {
                        var x: c_int = undefined;
                        _ = &x;
                        o = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(OPTIONS))))))))));
                        o.* = fdefault;
                        o.*.match = null;
                        {
                            x = 0;
                            while ((((((@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, ']'))) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\r'))) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\n'))) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, ' '))) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\t'))) : (x += 1) {}
                        }
                        buf[@bitCast(@as(isize, @intCast(x)))] = 0;
                        o.*.next = options_list;
                        options_list = o;
                        o.*.ftype = zdup(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))));
                    }
                    break;
                },
                @as(c_int, '*') => {
                    {
                        if (o != null) {
                            var m: [*c]struct_options_match = undefined;
                            _ = &m;
                            var x: c_int = undefined;
                            _ = &x;
                            {
                                x = 0;
                                while ((((@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\n'))) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, ' '))) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\t'))) : (x += 1) {}
                            }
                            buf[@bitCast(@as(isize, @intCast(x)))] = 0;
                            m = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_options_match))))))))));
                            m.*.next = null;
                            m.*.name_regex = zdup(@ptrCast(@alignCast(&buf)));
                            m.*.contents_regex = null;
                            m.*.r_contents_regex = null;
                            m.*.next = o.*.match;
                            o.*.match = m;
                        }
                    }
                    break;
                },
                @as(c_int, '+') => {
                    {
                        var x: c_int = undefined;
                        _ = &x;
                        {
                            x = 0;
                            while (((@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\n'))) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\r'))) : (x += 1) {}
                        }
                        buf[@bitCast(@as(isize, @intCast(x)))] = 0;
                        if ((o != null) and (o.*.match != null)) {
                            if (o.*.match.*.contents_regex != null) {
                                var m: [*c]struct_options_match = @ptrCast(@alignCast(joe_malloc(@bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_options_match))))))))));
                                _ = &m;
                                m.* = o.*.match.*;
                                m.*.next = o.*.match;
                                o.*.match = m;
                            }
                            o.*.match.*.contents_regex = zdup(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))));
                        }
                    }
                    break;
                },
                @as(c_int, '-') => {
                    {
                        var opt: [*c]u8 = @as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))));
                        _ = &opt;
                        var x: c_int = undefined;
                        _ = &x;
                        var arg: [*c]u8 = null;
                        _ = &arg;
                        {
                            x = 0;
                            while ((((@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\n'))) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, ' '))) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\t'))) : (x += 1) {}
                        }
                        if ((@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\n'))) {
                            buf[@bitCast(@as(isize, @intCast(x)))] = 0;
                            {
                                arg = @as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(blk: {
                                    const ref = &x;
                                    ref.* += 1;
                                    break :blk ref.*;
                                }))));
                                while ((@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, '\n'))) : (x += 1) {}
                            }
                        }
                        buf[@bitCast(@as(isize, @intCast(x)))] = 0;
                        if (!(glopt(opt, arg, o, 2) != 0)) {
                            err = 1;
                            _ = snprintf(i_msg, 128, my_gettext("%s %d: Unknown option %s\n"), name, line, opt);
                            internal_msg(i_msg);
                            setlogerrs();
                        }
                    }
                    break;
                },
                @as(c_int, '{') => {
                    {
                        line = help_init(fd, @ptrCast(@alignCast(&buf)), line);
                    }
                    break;
                },
                @as(c_int, ':') => {
                    {
                        var x: ptrdiff_t = undefined;
                        _ = &x;
                        var c: ptrdiff_t = undefined;
                        _ = &c;
                        var ch: u8 = undefined;
                        _ = &ch;
                        {
                            x = 1;
                            while (!(joe_isspace_eos(locale_map, buf[@bitCast(@as(isize, @intCast(x)))]) != 0)) : (x += 1) {}
                        }
                        ch = buf[@bitCast(@as(isize, @intCast(x)))];
                        buf[@bitCast(@as(isize, @intCast(x)))] = 0;
                        if (x != @as(ptrdiff_t, 1)) if (!(strcmp(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), "def") != 0)) {
                            var y: ptrdiff_t = undefined;
                            _ = &y;
                            {
                                buf[@bitCast(@as(isize, @intCast(x)))] = ch;
                                while (joe_isblank(locale_map, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) {}
                            }
                            {
                                y = x;
                                while (!(joe_isspace_eos(locale_map, buf[@bitCast(@as(isize, @intCast(y)))]) != 0)) : (y += 1) {}
                            }
                            ch = buf[@bitCast(@as(isize, @intCast(y)))];
                            buf[@bitCast(@as(isize, @intCast(y)))] = 0;
                            _ = zlcpy(@ptrCast(@alignCast(&buf1)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf1)))))), @as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(x)))));
                            if (y != x) {
                                var sta: ptrdiff_t = y + @as(ptrdiff_t, 1);
                                _ = &sta;
                                var m: [*c]MACRO = undefined;
                                _ = &m;
                                if ((joe_isblank(locale_map, ch) != 0) and ((blk: {
                                    const tmp = multiparse(fd, &line, @ptrCast(@alignCast(&buf)), &sta, &err, name);
                                    m = tmp;
                                    break :blk tmp;
                                }) != null)) {
                                    addcmd(@ptrCast(@alignCast(&buf1)), m);
                                } else {
                                    err = 1;
                                    _ = snprintf(i_msg, 128, my_gettext("%s %d: macro missing from :def\n"), name, line);
                                    internal_msg(i_msg);
                                    setlogerrs();
                                }
                            } else {
                                err = 1;
                                _ = snprintf(i_msg, 128, my_gettext("%s %d: command name missing from :def\n"), name, line);
                                internal_msg(i_msg);
                                setlogerrs();
                            }
                        } else if (!(strcmp(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), "inherit") != 0)) {
                            if (context != null) {
                                {
                                    buf[@bitCast(@as(isize, @intCast(x)))] = ch;
                                    while (joe_isblank(locale_map, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) {}
                                }
                                {
                                    c = x;
                                    while (!(joe_isspace_eos(locale_map, buf[@bitCast(@as(isize, @intCast(c)))]) != 0)) : (c += 1) {}
                                }
                                buf[@bitCast(@as(isize, @intCast(c)))] = 0;
                                if (c != x) {
                                    kcpy(context, kmap_getcontext(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(x))))));
                                } else {
                                    err = 1;
                                    _ = snprintf(i_msg, 128, my_gettext("%s %d: context name missing from :inherit\n"), name, line);
                                    internal_msg(i_msg);
                                    setlogerrs();
                                }
                            } else {
                                err = 1;
                                _ = snprintf(i_msg, 128, my_gettext("%s %d: No context selected for :inherit\n"), name, line);
                                internal_msg(i_msg);
                                setlogerrs();
                            }
                        } else if (!(strcmp(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), "include") != 0)) {
                            {
                                buf[@bitCast(@as(isize, @intCast(x)))] = ch;
                                while (joe_isblank(locale_map, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) {}
                            }
                            {
                                c = x;
                                while (!(joe_isspace_eos(locale_map, buf[@bitCast(@as(isize, @intCast(c)))]) != 0)) : (c += 1) {}
                            }
                            buf[@bitCast(@as(isize, @intCast(c)))] = 0;
                            if (c != x) {
                                var incname: [*c]u8 = @as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(x))));
                                _ = &incname;
                                var fullpath: [*c]u8 = null;
                                _ = &fullpath;
                                var f: [*c]JFILE = null;
                                _ = &f;
                                var rtn: c_int = -@as(c_int, 1);
                                _ = &rtn;
                                fullpath = open_rc_file(&f, "", incname, "");
                                if (fullpath != null) {
                                    rtn = procrc(cap_1, f, fullpath);
                                }
                                while (true) {
                                    switch (rtn) {
                                        @as(c_int, 1) => {
                                            err = 1;
                                            break;
                                        },
                                        -@as(c_int, 1) => {
                                            _ = snprintf(i_msg, 128, my_gettext("%s %d: Couldn't open %s\n"), name, line, incname);
                                            internal_msg(i_msg);
                                            setlogerrs();
                                            err = 1;
                                            break;
                                        },
                                        else => {},
                                    }
                                    break;
                                }
                                context = null;
                                o = &fdefault;
                                vsrm(fullpath);
                            } else {
                                err = 1;
                                _ = snprintf(i_msg, 128, my_gettext("%s %d: :include missing file name\n"), name, line);
                                internal_msg(i_msg);
                                setlogerrs();
                            }
                        } else if (!(strcmp(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), "delete") != 0)) {
                            if (context != null) {
                                var y: ptrdiff_t = undefined;
                                _ = &y;
                                {
                                    buf[@bitCast(@as(isize, @intCast(x)))] = ch;
                                    while (joe_isblank(locale_map, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) {}
                                }
                                {
                                    y = x;
                                    while ((((@as(c_int, buf[@bitCast(@as(isize, @intCast(y)))]) != @as(c_int, 0)) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(y)))]) != @as(c_int, '\t'))) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(y)))]) != @as(c_int, '\n'))) and ((@as(c_int, buf[@bitCast(@as(isize, @intCast(y)))]) != @as(c_int, ' ')) or (@as(c_int, buf[@bitCast(@as(isize, @intCast(y + @as(ptrdiff_t, 1))))]) != @as(c_int, ' ')))) : (y += 1) {}
                                }
                                buf[@bitCast(@as(isize, @intCast(y)))] = 0;
                                _ = kdel(context, @as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(x)))));
                            } else {
                                err = 1;
                                _ = snprintf(i_msg, 128, my_gettext("%s %d: No context selected for :delete\n"), name, line);
                                internal_msg(i_msg);
                                setlogerrs();
                            }
                        } else if (!(strcmp(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), "defmap") != 0)) {
                            {
                                buf[@bitCast(@as(isize, @intCast(x)))] = ch;
                                while (joe_isblank(locale_map, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) {}
                            }
                            {
                                c = x;
                                while (!(joe_isspace_eos(locale_map, buf[@bitCast(@as(isize, @intCast(c)))]) != 0)) : (c += 1) {}
                            }
                            buf[@bitCast(@as(isize, @intCast(c)))] = 0;
                            if (c != x) {
                                context = kmap_getcontext(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(x)))));
                                current_menu = null;
                            } else {
                                err = 1;
                                _ = snprintf(i_msg, 128, my_gettext("%s %d: :defmap missing name\n"), name, line);
                                internal_msg(i_msg);
                                setlogerrs();
                            }
                        } else if (!(strcmp(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), "defmenu") != 0)) {
                            var m: [*c]MACRO = null;
                            _ = &m;
                            var d: u8 = undefined;
                            _ = &d;
                            var y: ptrdiff_t = undefined;
                            _ = &y;
                            {
                                buf[@bitCast(@as(isize, @intCast(x)))] = ch;
                                while (joe_isblank(locale_map, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) {}
                            }
                            {
                                c = x;
                                while (!(joe_isspace_eos(locale_map, buf[@bitCast(@as(isize, @intCast(c)))]) != 0)) : (c += 1) {}
                            }
                            d = buf[@bitCast(@as(isize, @intCast(c)))];
                            buf[@bitCast(@as(isize, @intCast(c)))] = 0;
                            _ = zlcpy(@ptrCast(@alignCast(&buf1)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf1)))))), @as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(x)))));
                            buf[@bitCast(@as(isize, @intCast(c)))] = d;
                            {
                                y = c;
                                while (joe_isblank(locale_map, buf[@bitCast(@as(isize, @intCast(y)))]) != 0) : (y += 1) {}
                            }
                            if (!(joe_isspace_eos(locale_map, buf[@bitCast(@as(isize, @intCast(y)))]) != 0)) {
                                m = multiparse(fd, &line, @ptrCast(@alignCast(&buf)), &y, &err, name);
                            }
                            current_menu = create_menu(@ptrCast(@alignCast(&buf1)), m);
                            context = null;
                        } else {
                            context = kmap_getcontext(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))));
                            current_menu = null;
                        } else {
                            err = 1;
                            _ = snprintf(i_msg, 128, my_gettext("%s %d: Invalid context name\n"), name, line);
                            internal_msg(i_msg);
                            setlogerrs();
                        }
                    }
                    break;
                },
                else => {
                    {
                        var x: ptrdiff_t = undefined;
                        _ = &x;
                        var y: ptrdiff_t = undefined;
                        _ = &y;
                        var m: [*c]MACRO = undefined;
                        _ = &m;
                        if (!(context != null) and !(current_menu != null)) {
                            err = 1;
                            _ = snprintf(i_msg, 128, my_gettext("%s %d: No context selected for macro to key-sequence binding\n"), name, line);
                            internal_msg(i_msg);
                            setlogerrs();
                            break;
                        }
                        x = 0;
                        m = multiparse(fd, &line, @ptrCast(@alignCast(&buf)), &x, &err, name);
                        if (x == @as(ptrdiff_t, -@as(c_int, 1))) break;
                        if (!(m != null)) break;
                        {
                            y = x;
                            while ((((@as(c_int, buf[@bitCast(@as(isize, @intCast(y)))]) != @as(c_int, 0)) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(y)))]) != @as(c_int, '\t'))) and (@as(c_int, buf[@bitCast(@as(isize, @intCast(y)))]) != @as(c_int, '\n'))) and ((@as(c_int, buf[@bitCast(@as(isize, @intCast(y)))]) != @as(c_int, ' ')) or (@as(c_int, buf[@bitCast(@as(isize, @intCast(y + @as(ptrdiff_t, 1))))]) != @as(c_int, ' ')))) : (y += 1) {}
                        }
                        buf[@bitCast(@as(isize, @intCast(y)))] = 0;
                        if (current_menu != null) {
                            add_menu_entry(current_menu, @as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(x)))), m);
                        } else {
                            if (kadd(cap_1, context, @as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(x)))), m) == -@as(c_int, 1)) {
                                _ = snprintf(i_msg, 128, my_gettext("%s %d: Bad key sequence '%s'\n"), name, line, @as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @bitCast(@as(isize, @intCast(x)))));
                                internal_msg(i_msg);
                                setlogerrs();
                                err = 1;
                            }
                        }
                    }
                    break;
                },
            }
            break;
        }
    }
    _ = jfclose(fd);
    _ = snprintf(i_msg, 128, my_gettext("Finished processing %s\n"), name);
    internal_msg(i_msg);
    return err;
}


comptime {
    if (@sizeOf(OPTIONS) != 344) @compileError("OPTIONS size mismatch");
    if (@sizeOf(struct_options_match) != 32) @compileError("options_match size mismatch");
    if (@sizeOf(MACRO) != 48) @compileError("MACRO size mismatch");
    if (@sizeOf(KMAP) != 280) @compileError("KMAP size mismatch");
    if (@sizeOf(CAP) != 88) @compileError("CAP size mismatch");
    if (@sizeOf(JFILE) != 16) @compileError("JFILE size mismatch");
    if (@sizeOf(struct_rc_menu) != 48) @compileError("rc_menu size mismatch");
}
