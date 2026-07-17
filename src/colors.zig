//! Color scheme handler — replaces `joe/colors.c`.
//!
//! Faithful C-ABI port of JOE's color scheme system.
//! Generated from colors.c (already goto-free) via `zig translate-c`,
//! then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;

pub const COLORSPEC_TYPE_NONE = @as(c_int, 0);
pub const COLORSPEC_TYPE_ATTR = @as(c_int, 1);
pub const COLORSPEC_TYPE_GUI = @as(c_int, 2);
pub const COLORSET_GUI: c_int = 0x1000000;
pub const COLORDEF_VISITED = @as(c_int, 1);
pub const COLORDEF_VISITING = @as(c_int, 2);
pub const CONTEXT_MASK = @as(c_int, 3);
pub const INVERSE = @as(c_int, 64);
pub const DIM = @as(c_int, 1024);
pub const AT_MASK = ((((((@as(c_int, 64) + @as(c_int, 128)) + @as(c_int, 256)) + @as(c_int, 512)) + @as(c_int, 1024)) + @as(c_int, 32)) + @as(c_int, 8)) + @as(c_int, 16);
pub const BG_SHIFT = @as(c_int, 11);
pub const BG_VALUE = @as(c_int, 255) << BG_SHIFT;
pub const BG_NOT_DEFAULT = @as(c_int, 256) << BG_SHIFT;
pub const BG_TRUECOLOR = @as(c_int, 512) << BG_SHIFT;
pub const BG_MASK = @as(c_int, 1023) << BG_SHIFT;
pub const FG_SHIFT = @as(c_int, 21);
pub const FG_VALUE = @as(c_int, 255) << FG_SHIFT;
pub const FG_NOT_DEFAULT = @as(c_int, 256) << FG_SHIFT;
pub const FG_TRUECOLOR = @as(c_int, 512) << FG_SHIFT;
pub const FG_MASK = @as(c_int, 1023) << FG_SHIFT;
pub inline fn SWAP_COLOR(c: anytype) @TypeOf(((c & ~(FG_MASK | BG_MASK)) | (((c & BG_MASK) >> BG_SHIFT) << FG_SHIFT)) | (((c & FG_MASK) >> FG_SHIFT) << BG_SHIFT)) {
    _ = &c;
    return ((c & ~(FG_MASK | BG_MASK)) | (((c & BG_MASK) >> BG_SHIFT) << FG_SHIFT)) | (((c & FG_MASK) >> FG_SHIFT) << BG_SHIFT);
}

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn fprintf(f: ?*anyopaque, fmt: [*c]const u8, ...) c_int;
pub extern fn fgets(s: [*c]u8, n: c_int, stream: ?*anyopaque) [*c]u8;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub const off_t = i64;
pub const FILE = anyopaque;
pub extern var ITEM: ?*anyopaque;
pub extern var QUEUE: ?*anyopaque;
pub const COLORSET = struct_color_set;
pub const struct_hash = extern struct {
    _pad: [24]u8 = std.mem.zeroes([24]u8),
};
pub const HASH = struct_hash;
pub const struct_color_ref = extern struct {
    name: [*c]const u8 = null,
    next: [*c]struct_color_ref = null,
};
pub const struct_color_spec = extern struct {
    @"type": c_int = 0,
    atr: c_int = 0,
    mask: c_int = 0,
    gui_fg: c_int = 0,
    gui_bg: c_int = 0,
};
pub const struct_color_def = extern struct {
    name: [*c]const u8 = null,
    refs: [*c]struct_color_ref = null,
    next: [*c]struct_color_def = null,
    spec: struct_color_spec = std.mem.zeroes(struct_color_spec),
    orig: struct_color_spec = std.mem.zeroes(struct_color_spec),
    visited: c_int = 0,
};
pub const struct_color_set = extern struct {
    next: [*c]COLORSET = null,
    colors: c_int = 0,
    syntax: [*c]HASH = null,
    palette: [*c]c_int = null,
    alldefs: [*c]struct_color_def = null,
    builtins: [*c]struct_color_spec = null,
    termcolors: [16]struct_color_spec = std.mem.zeroes([16]struct_color_spec),
};
pub const SCHEME = struct_color_scheme;
const struct_unnamed_1 = extern struct {
    next: [*c]SCHEME = null,
    prev: [*c]SCHEME = null,
};
pub const struct_color_scheme = extern struct {
    link: struct_unnamed_1 = std.mem.zeroes(struct_unnamed_1),
    name: [*c]const u8 = null,
    sets: [*c]struct_color_set = null,
};
pub const struct_jfile = extern struct {
    _pad: [16]u8 = std.mem.zeroes([16]u8),
};
pub const JFILE = struct_jfile;
pub const struct_point = extern struct {
    _pad: [112]u8 = std.mem.zeroes([112]u8),
};
pub const P = struct_point;
pub const struct_bw = extern struct {
    _pad0: [24]u8 = std.mem.zeroes([24]u8),
    cursor: [*c]P = null,
    _pad1: [456]u8 = std.mem.zeroes([456]u8),
};
pub const BW = struct_bw;
pub const struct_scrn = extern struct {
    _pad0: [232]u8 = std.mem.zeroes([232]u8),
    Co: c_int = 0,
    _pad1: [468]u8 = std.mem.zeroes([468]u8),
    assume_256: c_int = 0,
    truecolor: c_int = 0,
    _pad2: [128]u8 = std.mem.zeroes([128]u8),
};
pub const SCRN = struct_scrn;
pub const struct_screen = extern struct {
    t: [*c]SCRN = null,
    _pad: [40]u8 = std.mem.zeroes([40]u8),
};
pub const Screen = struct_screen;
pub const struct_high_state = extern struct {
    _pad0: [12]u8 = std.mem.zeroes([12]u8),
    color: c_int = 0,
    colorp: [*c]struct_color_def = null,
    _pad1: [272]u8 = std.mem.zeroes([272]u8),
};
pub const struct_high_syntax = extern struct {
    next: [*c]struct_high_syntax = null,
    name: [*c]u8 = null,
    _pad0: [16]u8 = std.mem.zeroes([16]u8),
    states: [*c][*c]struct_high_state = null,
    _pad1: [8]u8 = std.mem.zeroes([8]u8),
    nstates: ptrdiff_t = 0,
    _pad2: [8]u8 = std.mem.zeroes([8]u8),
    color: [*c]struct_color_def = null,
    _pad3: [64]u8 = std.mem.zeroes([64]u8),
};
pub const high_syntax = struct_high_syntax;
pub const high_state = struct_high_state;
pub extern var bg_text: c_int;
pub extern var bg_linum: c_int;
pub extern var bg_curlin: c_int;
pub extern var curlinmask: c_int;
pub extern var bg_curlinum: c_int;
pub extern var selectatr: c_int;
pub extern var selectmask: c_int;
pub extern var bg_help: c_int;
pub extern var bg_stalin: c_int;
pub extern var bg_menu: c_int;
pub extern var bg_menusel: c_int;
pub extern var bg_menumask: c_int;
pub extern var bg_prompt: c_int;
pub extern var bg_msg: c_int;
pub extern var vwsatr: c_int;
pub extern var vwsmask: c_int;
pub extern var maint: [*c]Screen;
pub extern var syntax_list: [*c]struct_high_syntax;
pub const i_msg: [*c]u8 = @extern([*c]u8, .{
    .name = "i_msg",
});
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn internal_msg(s: [*c]const u8) void;
pub extern fn setlogerrs() void;
pub extern fn joe_malloc(n: ptrdiff_t) ?*anyopaque;
pub extern fn joe_calloc(n: ptrdiff_t, sz: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(p: ?*anyopaque) void;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn zicmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn zhtoi(s: [*c]const u8) c_int;
pub extern fn meta_color(s: [*c]const u8) c_int;
pub extern fn htmk(len: ptrdiff_t) [*c]HASH;
pub extern fn htadd(ht: [*c]HASH, name: [*c]const u8, val: ?*anyopaque) ?*anyopaque;
pub extern fn htfind(ht: [*c]HASH, name: [*c]const u8) ?*anyopaque;
pub extern fn atom_add(name: [*c]const u8) [*c]const u8;
pub extern fn jfgets(buf: [*c]u8, len: c_int, f: [*c]JFILE) [*c]u8;
pub extern fn jfclose(f: [*c]JFILE) c_int;
pub extern fn open_config_file(result: [*c][*c]JFILE, prefix: [*c]const u8, name: [*c]const u8, suffix: [*c]const u8) [*c]u8;
pub extern fn find_configs(ary: [*c][*c]u8, prefix: [*c]const u8, extension: [*c]const u8) [*c][*c]u8;
pub extern fn setextpal(t: [*c]SCRN, palette: [*c]c_int) void;
pub extern fn emit_string(f: ?*FILE, s: [*c]const u8, len: ptrdiff_t) void;
pub extern fn jsort(base: ?*anyopaque, num: ptrdiff_t, size: ptrdiff_t, compar: ?*const fn (a: ?*const anyopaque, b: ?*const anyopaque) callconv(.c) c_int) void;
pub extern fn parse_ws(p: [*c][*c]const u8, cmt: c_int) c_int;
pub extern fn parse_ident(p: [*c][*c]const u8, buf: [*c]u8, len: ptrdiff_t) c_int;
pub extern fn parse_char(p: [*c][*c]const u8, c: u8) c_int;
pub extern fn parse_int(p: [*c][*c]const u8, buf: [*c]c_int) c_int;
pub extern fn parse_string(p: [*c][*c]const u8, buf: [*c]u8, len: ptrdiff_t) ptrdiff_t;
pub extern fn vsncpy(vary: [*c]u8, pos: ptrdiff_t, array: [*c]const u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsrm(v: [*c]u8) void;
pub extern fn vstrunc(vary: [*c]u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsensure(vary: [*c]u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsadd(vary: [*c]u8, element: u8) [*c]u8;
pub extern fn binss(p: [*c]P, s: [*c]const u8) [*c]P;
pub extern fn pnextl(p: [*c]P) [*c]P;
pub extern fn p_goto_eol(p: [*c]P) [*c]P;
pub export fn parse_color_spec(arg_p: [*c][*c]const u8, arg_dest: [*c]struct_color_spec) c_int {
    var p = arg_p;
    _ = &p;
    var dest = arg_dest;
    _ = &dest;
    var buf: [128]u8 = undefined;
    _ = &buf;
    var fg: c_int = 1;
    _ = &fg;
    var bg: c_int = 0;
    _ = &bg;
    var fg_read: c_int = 0;
    _ = &fg_read;
    var bg_read: c_int = 0;
    _ = &bg_read;
    var color: c_int = undefined;
    _ = &color;
    dest.*.@"type" = COLORSPEC_TYPE_NONE;
    dest.*.atr = 0;
    dest.*.mask = 0;
    dest.*.gui_fg = 0;
    dest.*.gui_bg = 0;
    while (true) {
        if (!(parse_ws(p, '#') != 0)) {
            return 0;
        }
        if (!(parse_char(p, '/') != 0)) {
            if (!(fg != 0)) {
                return 1;
            }
            fg = 0;
            bg = 1;
        } else if (!(parse_char(p, '$') != 0)) {
            var i: c_int = undefined;
            _ = &i;
            if ((dest.*.@"type" != COLORSPEC_TYPE_NONE) and (dest.*.@"type" != COLORSPEC_TYPE_GUI)) {
                return 1;
            }
            dest.*.@"type" = COLORSPEC_TYPE_GUI;
            i = 0;
            while ((@as(c_int, p.*.*) != 0) and ((((@as(c_int, p.*.*) >= @as(c_int, 'a')) and (@as(c_int, p.*.*) <= @as(c_int, 'f'))) or ((@as(c_int, p.*.*) >= @as(c_int, '0')) and (@as(c_int, p.*.*) <= @as(c_int, '9')))) or ((@as(c_int, p.*.*) >= @as(c_int, 'A')) and (@as(c_int, p.*.*) <= @as(c_int, 'F'))))) {
                buf[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &i;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = (blk: {
                    const ref = &p.*;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).*;
            }
            buf[@as(usize, @intCast(i))] = 0;
            color = zhtoi(@ptrCast(@alignCast(&buf)));
            if ((fg != 0) and !(fg_read != 0)) {
                dest.*.gui_fg = color;
                dest.*.mask |= @as(c_int, 1023) << @intCast(FG_SHIFT);
                fg_read = 1;
            } else if ((bg != 0) and !(bg_read != 0)) {
                dest.*.gui_bg = color;
                dest.*.mask |= @as(c_int, 1023) << @intCast(BG_SHIFT);
                bg_read = 1;
            }
        } else if (!(parse_int(p, &color) != 0)) {
            if ((dest.*.@"type" != COLORSPEC_TYPE_NONE) and (dest.*.@"type" != COLORSPEC_TYPE_ATTR)) {
                return 1;
            }
            dest.*.@"type" = COLORSPEC_TYPE_ATTR;
            if ((fg != 0) and !(fg_read != 0)) {
                dest.*.atr |= (color << @intCast(FG_SHIFT)) | (@as(c_int, 256) << @intCast(FG_SHIFT));
                dest.*.mask |= @as(c_int, 1023) << @intCast(FG_SHIFT);
                fg_read = 1;
            } else if ((bg != 0) and !(bg_read != 0)) {
                dest.*.atr |= (color << @intCast(BG_SHIFT)) | (@as(c_int, 256) << @intCast(BG_SHIFT));
                dest.*.mask |= @as(c_int, 1023) << @intCast(BG_SHIFT);
                bg_read = 1;
            } else {
                return 1;
            }
        } else if (!(parse_ident(p, @ptrCast(@alignCast(&buf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf))))))) != 0)) {
            var dflt: c_int = 0;
            _ = &dflt;
            if (!(strcmp(@ptrCast(@alignCast(&buf)), "default") != 0)) {
                dflt = 1;
                color = 0;
            } else if (!((blk: {
                const tmp = meta_color(@ptrCast(@alignCast(&buf)));
                color = tmp;
                break :blk tmp;
            }) != 0)) {
                return 1;
            }
            if ((color & ((@as(c_int, 1023) << @intCast(FG_SHIFT)) | (@as(c_int, 1023) << @intCast(BG_SHIFT)))) != @as(c_int, 0)) {
                if ((dest.*.@"type" != COLORSPEC_TYPE_NONE) and (dest.*.@"type" != COLORSPEC_TYPE_ATTR)) {
                    return 1;
                }
            }
            if (dest.*.@"type" == COLORSPEC_TYPE_NONE) {
                dest.*.@"type" = COLORSPEC_TYPE_ATTR;
            }
            if (((bg != 0) and !(bg_read != 0)) and (((@as(c_int, 1023) << @intCast(FG_SHIFT)) & color) != 0)) {
                dest.*.atr |= (@as(c_int, 256) << @intCast(BG_SHIFT)) | (((((@as(c_int, 1023) << @intCast(FG_SHIFT)) & color) & ~((@as(c_int, 1023) << @intCast(FG_SHIFT)) | (@as(c_int, 1023) << @intCast(BG_SHIFT)))) | (((((@as(c_int, 1023) << @intCast(FG_SHIFT)) & color) & (@as(c_int, 1023) << @intCast(BG_SHIFT))) >> @intCast(BG_SHIFT)) << @intCast(FG_SHIFT))) | (((((@as(c_int, 1023) << @intCast(FG_SHIFT)) & color) & (@as(c_int, 1023) << @intCast(FG_SHIFT))) >> @intCast(FG_SHIFT)) << @intCast(BG_SHIFT)));
                dest.*.mask |= @as(c_int, 1023) << @intCast(BG_SHIFT);
                bg_read = 1;
            } else if (((fg != 0) and !(fg_read != 0)) and (((@as(c_int, 1023) << @intCast(FG_SHIFT)) & color) != 0)) {
                dest.*.atr |= color | (@as(c_int, 256) << @intCast(FG_SHIFT));
                dest.*.mask |= @as(c_int, 1023) << @intCast(FG_SHIFT);
                fg_read = 1;
            } else if (((bg != 0) and !(bg_read != 0)) and (dflt != 0)) {
                dest.*.mask |= @as(c_int, 1023) << @intCast(BG_SHIFT);
                bg_read = 1;
            } else if (((fg != 0) and !(fg_read != 0)) and (dflt != 0)) {
                dest.*.mask |= @as(c_int, 1023) << @intCast(FG_SHIFT);
                fg_read = 1;
            } else {
                if (!(fg_read != 0) and (((@as(c_int, 1023) << @intCast(FG_SHIFT)) & color) != 0)) {
                    dest.*.atr |= color;
                    dest.*.mask |= @as(c_int, 1023) << @intCast(FG_SHIFT);
                    fg_read = 1;
                } else if (!(bg_read != 0) and (((@as(c_int, 1023) << @intCast(BG_SHIFT)) & color) != 0)) {
                    dest.*.atr |= color;
                    dest.*.mask |= @as(c_int, 1023) << @intCast(BG_SHIFT);
                    bg_read = 1;
                } else if (((((((((@as(c_int, 64) + @as(c_int, 128)) + @as(c_int, 256)) + @as(c_int, 512)) + @as(c_int, 1024)) + @as(c_int, 32)) + @as(c_int, 8)) + @as(c_int, 16)) & color) != 0) {
                    dest.*.atr |= color;
                    dest.*.mask |= ((((((@as(c_int, 64) + @as(c_int, 128)) + @as(c_int, 256)) + @as(c_int, 512)) + @as(c_int, 1024)) + @as(c_int, 32)) + @as(c_int, 8)) + @as(c_int, 16);
                } else {
                    return 1;
                }
            }
        } else {
            return 1;
        }
    }
    return undefined;
}
pub export fn parse_color_def(arg_p: [*c][*c]const u8, arg_dest: [*c]struct_color_def) c_int {
    var p = arg_p;
    _ = &p;
    var dest = arg_dest;
    _ = &dest;
    var buf: [256]u8 = undefined;
    _ = &buf;
    var last: [*c][*c]struct_color_ref = &dest.*.refs;
    _ = &last;
    dest.*.spec.@"type" = COLORSPEC_TYPE_NONE;
    dest.*.visited = 0;
    dest.*.refs = null;
    last.* = null;
    while (true) {
        if (!(parse_ws(p, '#') != 0)) {
            return 0;
        }
        if (!(parse_char(p, '+') != 0)) {
            if (!(parse_scoped_ident(p, @ptrCast(@alignCast(&buf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf))))))) != 0)) {
                var cref: [*c]struct_color_ref = @ptrCast(@alignCast(joe_calloc(1, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_color_ref))))))));
                _ = &cref;
                cref.*.name = atom_add(@ptrCast(@alignCast(&buf)));
                cref.*.next = null;
                last.* = cref;
                last = &cref.*.next;
            } else {
                return 1;
            }
        } else {
            return parse_color_spec(p, &dest.*.spec);
        }
    }
    return undefined;
}
pub const struct_color_macro = extern struct {
    next: [*c]struct_color_macro = null,
    name: [*c]u8 = null,
    value: [*c]u8 = null,
};
pub export fn load_scheme(arg_name: [*c]const u8) [*c]SCHEME {
    var name = arg_name;
    _ = &name;
    var colors: [*c]SCHEME = undefined;
    _ = &colors;
    var curset: [*c]COLORSET = undefined;
    _ = &curset;
    var lastdef: [*c][*c]struct_color_def = null;
    _ = &lastdef;
    var macros: [*c]struct_color_macro = null;
    _ = &macros;
    var p: [*c]const u8 = undefined;
    _ = &p;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    var bf: [256]u8 = undefined;
    _ = &bf;
    var b: [*c]u8 = null;
    _ = &b;
    var f: [*c]JFILE = null;
    _ = &f;
    var fullpath: [*c]u8 = null;
    _ = &fullpath;
    var line: c_int = undefined;
    _ = &line;
    var i: c_int = undefined;
    _ = &i;
    {
        colors = allcolors.link.next;
        while (colors != (&allcolors)) : (colors = colors.*.link.next) {
            if (!(strcmp(name, colors.*.name) != 0)) {
                return colors;
            }
        }
    }
    fullpath = open_config_file(&f, "colors/", name, ".jcf");
    if (!(f != null)) return null;
    colors = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_color_scheme))))))));
    colors.*.sets = null;
    colors.*.name = zdup(name);
    while (true) {
        ITEM = @ptrCast(@alignCast(colors));
        QUEUE = @ptrCast(@alignCast(&allcolors));
        @as([*c]SCHEME, @ptrCast(@alignCast(ITEM))).*.link.next = @as([*c]SCHEME, @ptrCast(@alignCast(QUEUE))).*.link.next;
        @as([*c]SCHEME, @ptrCast(@alignCast(ITEM))).*.link.prev = @ptrCast(@alignCast(QUEUE));
        @as([*c]SCHEME, @ptrCast(@alignCast(QUEUE))).*.link.next.*.link.prev = @ptrCast(@alignCast(ITEM));
        @as([*c]SCHEME, @ptrCast(@alignCast(QUEUE))).*.link.next = @ptrCast(@alignCast(ITEM));
        if (!false) break;
    }
    curset = null;
    line = 0;
    while (jfgets(@ptrCast(@alignCast(&buf)), @truncate(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf))))))), f) != null) {
        line += 1;
        b = preprocess_line(b, @ptrCast(@alignCast(&buf)), macros);
        p = b;
        _ = parse_ws(&p, '#');
        if (!(parse_char(&p, '.') != 0)) {
            if (!(parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0)) {
                if (!(strcmp(@ptrCast(@alignCast(&bf)), "colors") != 0)) {
                    var count: c_int = -@as(c_int, 1);
                    _ = &count;
                    _ = parse_ws(&p, '#');
                    if (!(parse_char(&p, '*') != 0)) {
                        curset = colorset_alloc();
                        curset.*.colors = COLORSET_GUI;
                        curset.*.next = colors.*.sets;
                        colors.*.sets = curset;
                        lastdef = &curset.*.alldefs;
                    } else if (!(parse_int(&p, &count) != 0)) {
                        curset = colorset_alloc();
                        curset.*.colors = count;
                        curset.*.next = colors.*.sets;
                        colors.*.sets = curset;
                        lastdef = &curset.*.alldefs;
                    } else {
                        _ = snprintf(i_msg, 128, my_gettext("%s: %d: Invalid .colors specification\n"), name, line);
                        internal_msg(i_msg);
                        setlogerrs();
                    }
                } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "set") != 0)) {
                    _ = parse_ws(&p, '#');
                    if (!(parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0)) {
                        var newmacro: [*c]struct_color_macro = undefined;
                        _ = &newmacro;
                        var q: [*c]const u8 = undefined;
                        _ = &q;
                        _ = parse_ws(&p, '#');
                        q = p;
                        while ((((@as(c_int, p.*) != 0) and (@as(c_int, p.*) != @as(c_int, '#'))) and (@as(c_int, p.*) != @as(c_int, '\n'))) and (@as(c_int, p.*) != @as(c_int, '\r'))) {
                            p += 1;
                        }
                        newmacro = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_color_macro))))))));
                        newmacro.*.next = macros;
                        newmacro.*.name = zdup(@ptrCast(@alignCast(&bf)));
                        newmacro.*.value = vsncpy(null, 0, q, @divExact(@as(c_long, @bitCast(@intFromPtr(p) -% @intFromPtr(q))), @sizeOf(u8)));
                        macros = newmacro;
                    } else {
                        _ = snprintf(i_msg, 128, my_gettext("%s: %d: Invalid .set directive\n"), name, line);
                        internal_msg(i_msg);
                        setlogerrs();
                    }
                } else {
                    _ = snprintf(i_msg, 128, my_gettext("%s: %d: Unexpected directive %s\n"), name, line, @as([*c]u8, @ptrCast(@alignCast(&bf))));
                    internal_msg(i_msg);
                    setlogerrs();
                }
            } else {
                _ = snprintf(i_msg, 128, my_gettext("%s: %d: Syntax error\n"), name, line);
                internal_msg(i_msg);
                setlogerrs();
            }
        } else if (!(curset != null) and (parse_ws(&p, '#') != 0)) {
            _ = snprintf(i_msg, 128, my_gettext("%s: %d: Unexpected declaration outside of color block\n"), name, line);
            internal_msg(i_msg);
            setlogerrs();
        } else if (!(parse_char(&p, '-') != 0)) {
            if (!(parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0)) {
                if (!(zicmp(@ptrCast(@alignCast(&bf)), "term") != 0)) {
                    var termcolor: c_int = undefined;
                    _ = &termcolor;
                    _ = parse_ws(&p, '#');
                    if ((!(parse_int(&p, &termcolor) != 0) and (termcolor >= @as(c_int, 0))) and (termcolor <= @as(c_int, 15))) {
                        if (parse_color_spec(&p, &@as(*COLORSET, curset).termcolors[@as(usize, @intCast(termcolor))]) != 0) {
                            _ = snprintf(i_msg, 128, my_gettext("%s: %d: Invalid color spec\n"), name, line);
                            internal_msg(i_msg);
                            setlogerrs();
                        }
                    } else {
                        _ = snprintf(i_msg, 128, my_gettext("%s: %d: Invalid terminal color\n"), name, line);
                        internal_msg(i_msg);
                        setlogerrs();
                    }
                } else {
                    {
                        i = 0;
                        while (color_builtins[@as(usize, @intCast(i))].name != null) : (i += 1) {
                            if (!(zicmp(@ptrCast(@alignCast(&bf)), color_builtins[@as(usize, @intCast(i))].name) != 0)) {
                                if (parse_color_spec(&p, &curset.*.builtins[@as(usize, @intCast(i))]) != 0) {
                                    _ = snprintf(i_msg, 128, my_gettext("%s: %d: Invalid color spec\n"), name, line);
                                    internal_msg(i_msg);
                                    setlogerrs();
                                }
                                break;
                            }
                        }
                    }
                    if (!(color_builtins[@as(usize, @intCast(i))].name != null)) {
                        _ = snprintf(i_msg, 128, my_gettext("%s: %d: Unknown builtin color %s\n"), name, line, @as([*c]u8, @ptrCast(@alignCast(&bf))));
                        internal_msg(i_msg);
                        setlogerrs();
                    }
                }
            } else {
                _ = snprintf(i_msg, 128, my_gettext("%s: %d: Expected identifier\n"), name, line);
                internal_msg(i_msg);
                setlogerrs();
            }
        } else if (!(parse_char(&p, '=') != 0)) {
            if (!(parse_scoped_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0)) {
                var cdef: [*c]struct_color_def = undefined;
                _ = &cdef;
                cdef = @ptrCast(@alignCast(joe_calloc(1, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_color_def))))))));
                cdef.*.name = atom_add(@ptrCast(@alignCast(&bf)));
                if (!(parse_color_def(&p, cdef) != 0)) {
                    _ = htadd(curset.*.syntax, cdef.*.name, @ptrCast(@alignCast(cdef)));
                    lastdef.* = cdef;
                    lastdef = &cdef.*.next;
                } else {
                    _ = snprintf(i_msg, 128, my_gettext("%s: %d: Invalid color spec\n"), name, line);
                    internal_msg(i_msg);
                    setlogerrs();
                    joe_free(@ptrCast(@alignCast(cdef)));
                }
            } else {
                _ = snprintf(i_msg, 128, my_gettext("%s: %d: Expected identifier\n"), name, line);
                internal_msg(i_msg);
                setlogerrs();
            }
        }
    }
    _ = vsrm(b);
    _ = jfclose(f);
    while (macros != null) {
        var next: [*c]struct_color_macro = macros.*.next;
        _ = &next;
        joe_free(@ptrCast(@alignCast(macros.*.name)));
        _ = vsrm(macros.*.value);
        joe_free(@ptrCast(@alignCast(macros)));
        macros = next;
    }
    {
        curset = colors.*.sets;
        while (curset != null) : (curset = curset.*.next) {
            var cdef: [*c]struct_color_def = undefined;
            _ = &cdef;
            {
                cdef = curset.*.alldefs;
                while (cdef != null) : (cdef = cdef.*.next) {
                    cdef.*.visited = 0;
                }
            }
            {
                cdef = curset.*.alldefs;
                while (cdef != null) : (cdef = cdef.*.next) {
                    var cref: [*c]struct_color_ref = cdef.*.refs;
                    _ = &cref;
                    visit_colordef(curset, null, cdef);
                    while (cref != null) {
                        var prev: [*c]struct_color_ref = cref;
                        _ = &prev;
                        cref = cref.*.next;
                        joe_free(@ptrCast(@alignCast(prev)));
                    }
                    cdef.*.refs = null;
                    if (cdef.*.spec.@"type" == COLORSPEC_TYPE_NONE) {
                        cdef.*.spec.@"type" = COLORSPEC_TYPE_ATTR;
                        cdef.*.spec.atr = 0;
                    }
                }
            }
            if (curset.*.colors == COLORSET_GUI) {
                _ = build_palette(curset, 1);
            } else {
                curset.*.palette = null;
            }
        }
    }
    _ = vsrm(fullpath);
    return colors;
}
pub export fn get_colors() [*c][*c]u8 {
    return find_configs(null, "colors", ".jcf");
}
pub export fn apply_scheme(arg_colors: [*c]SCHEME) c_int {
    var colors = arg_colors;
    _ = &colors;
    var stx: [*c]struct_high_syntax = undefined;
    _ = &stx;
    var best: [*c]struct_color_set = null;
    _ = &best;
    var p: [*c]struct_color_set = undefined;
    _ = &p;
    var i: c_int = undefined;
    _ = &i;
    var supported: c_int = if (maint.*.t.*.truecolor != 0) @as(c_int, 16777216) else if (maint.*.t.*.assume_256 != 0) @as(c_int, 256) else maint.*.t.*.Co;
    _ = &supported;
    if (!(colors != null)) return 1;
    {
        p = colors.*.sets;
        while (p != null) : (p = p.*.next) {
            if ((p.*.colors <= supported) and (!(best != null) or (best.*.colors < p.*.colors))) {
                best = p;
            }
        }
    }
    if (!(best != null)) {
        return 1;
    }
    {
        i = 0;
        while (color_builtins[@as(usize, @intCast(i))].name != null) : (i += 1) {
            var defatr: c_int = undefined;
            _ = &defatr;
            if (color_builtins[@as(usize, @intCast(i))].default_ptr != null) {
                defatr = color_builtins[@as(usize, @intCast(i))].default_ptr.*;
            } else {
                defatr = color_builtins[@as(usize, @intCast(i))].default_attr;
            }
            if (best.*.builtins[@as(usize, @intCast(i))].@"type" == COLORSPEC_TYPE_NONE) {
                if (color_builtins[@as(usize, @intCast(i))].attribute != null) {
                    color_builtins[@as(usize, @intCast(i))].attribute.* = defatr;
                }
                if (color_builtins[@as(usize, @intCast(i))].mask != null) {
                    color_builtins[@as(usize, @intCast(i))].mask.* = color_builtins[@as(usize, @intCast(i))].default_mask;
                }
            } else {
                var atr: c_int = best.*.builtins[@as(usize, @intCast(i))].atr;
                _ = &atr;
                var mask: c_int = best.*.builtins[@as(usize, @intCast(i))].mask;
                _ = &mask;
                atr = (mask & atr) | ((~mask & ~(((((((@as(c_int, 64) + @as(c_int, 128)) + @as(c_int, 256)) + @as(c_int, 512)) + @as(c_int, 1024)) + @as(c_int, 32)) + @as(c_int, 8)) + @as(c_int, 16))) & defatr);
                if (color_builtins[@as(usize, @intCast(i))].invert != 0) {
                    atr = ((atr & ~((@as(c_int, 1023) << @intCast(FG_SHIFT)) | (@as(c_int, 1023) << @intCast(BG_SHIFT)))) | (((atr & (@as(c_int, 1023) << @intCast(BG_SHIFT))) >> @intCast(BG_SHIFT)) << @intCast(FG_SHIFT))) | (((atr & (@as(c_int, 1023) << @intCast(FG_SHIFT))) >> @intCast(FG_SHIFT)) << @intCast(BG_SHIFT));
                    mask = ((mask & ~((@as(c_int, 1023) << @intCast(FG_SHIFT)) | (@as(c_int, 1023) << @intCast(BG_SHIFT)))) | (((mask & (@as(c_int, 1023) << @intCast(BG_SHIFT))) >> @intCast(BG_SHIFT)) << @intCast(FG_SHIFT))) | (((mask & (@as(c_int, 1023) << @intCast(FG_SHIFT))) >> @intCast(FG_SHIFT)) << @intCast(BG_SHIFT));
                }
                if (color_builtins[@as(usize, @intCast(i))].attribute != null) {
                    color_builtins[@as(usize, @intCast(i))].attribute.* = atr;
                }
                if (color_builtins[@as(usize, @intCast(i))].mask != null) {
                    color_builtins[@as(usize, @intCast(i))].mask.* = ~mask;
                }
            }
        }
    }
    {
        stx = syntax_list;
        while (stx != null) : (stx = stx.*.next) {
            resolve_syntax_colors(best, stx);
        }
    }
    curscheme = colors;
    curschemeset = best;
    scheme_name = curscheme.*.name;
    setextpal(maint.*.t, best.*.palette);
    return 0;
}
pub export fn resolve_syntax_colors(arg_cset: [*c]COLORSET, arg_syntax: [*c]struct_high_syntax) void {
    var cset = arg_cset;
    _ = &cset;
    var syntax = arg_syntax;
    _ = &syntax;
    var i: c_int = undefined;
    _ = &i;
    var scdef: [*c]struct_color_def = undefined;
    _ = &scdef;
    {
        scdef = syntax.*.color;
        while (scdef != null) : (scdef = scdef.*.next) {
            _ = memset(@ptrCast(@alignCast(&scdef.*.spec)), 0, @sizeOf(struct_color_spec));
            scdef.*.spec.@"type" = COLORSPEC_TYPE_NONE;
            scdef.*.visited = 0;
        }
    }
    if (cset != null) {
        {
            scdef = syntax.*.color;
            while (scdef != null) : (scdef = scdef.*.next) {
                var cdef: [*c]struct_color_def = undefined;
                _ = &cdef;
                var buf: [128]u8 = undefined;
                _ = &buf;
                _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%s.%s", syntax.*.name, scdef.*.name);
                cdef = @ptrCast(@alignCast(htfind(cset.*.syntax, @ptrCast(@alignCast(&buf)))));
                if (!(cdef != null)) {
                    cdef = @ptrCast(@alignCast(htfind(cset.*.syntax, scdef.*.name)));
                }
                if (cdef != null) {
                    _ = memcpy(@ptrCast(@alignCast(&scdef.*.spec)), @ptrCast(@alignCast(&cdef.*.spec)), @sizeOf(struct_color_spec));
                    scdef.*.visited = COLORDEF_VISITED;
                }
            }
        }
        {
            scdef = syntax.*.color;
            while (scdef != null) : (scdef = scdef.*.next) {
                visit_colordef(cset, syntax, scdef);
                if (((scdef.*.spec.@"type" == COLORSPEC_TYPE_NONE) and !(scdef.*.refs != null)) and (scdef.*.orig.@"type" == COLORSPEC_TYPE_ATTR)) {
                    var a: c_int = scdef.*.orig.atr;
                    _ = &a;
                    var c: c_int = (a & (@as(c_int, 255) << @intCast(FG_SHIFT))) >> @intCast(FG_SHIFT);
                    _ = &c;
                    if ((((a & (@as(c_int, 256) << @intCast(FG_SHIFT))) != 0) and (c < @as(c_int, 16))) and ((@as(*COLORSET, cset).termcolors[@as(usize, @intCast(c))].atr & (@as(c_int, 256) << @intCast(FG_SHIFT))) != 0)) {
                        a = (a & ~(@as(c_int, 1023) << @intCast(FG_SHIFT))) | (@as(*COLORSET, cset).termcolors[@as(usize, @intCast(c))].atr & (@as(c_int, 1023) << @intCast(FG_SHIFT)));
                    } else {
                        a = a & ~(@as(c_int, 1023) << @intCast(FG_SHIFT));
                    }
                    c = (a & (@as(c_int, 255) << @intCast(BG_SHIFT))) >> @intCast(BG_SHIFT);
                    if ((((a & (@as(c_int, 256) << @intCast(BG_SHIFT))) != 0) and (c < @as(c_int, 16))) and ((@as(*COLORSET, cset).termcolors[@as(usize, @intCast(c))].atr & (@as(c_int, 256) << @intCast(FG_SHIFT))) != 0)) {
                        a = (a & ~(@as(c_int, 1023) << @intCast(BG_SHIFT))) | (((@as(*COLORSET, cset).termcolors[@as(usize, @intCast(c))].atr & (@as(c_int, 1023) << @intCast(FG_SHIFT))) >> @intCast(FG_SHIFT)) << @intCast(BG_SHIFT));
                    } else {
                        a = a & ~(@as(c_int, 1023) << @intCast(BG_SHIFT));
                    }
                    scdef.*.spec.atr = a;
                    scdef.*.spec.@"type" = COLORSPEC_TYPE_ATTR;
                }
            }
        }
    }
    {
        i = 0;
        while (@as(ptrdiff_t, i) < syntax.*.nstates) : (i += 1) {
            var st: [*c]struct_high_state = syntax.*.states[@as(usize, @intCast(i))];
            _ = &st;
            if (st.*.colorp != null) {
                st.*.color = st.*.colorp.*.spec.atr | (st.*.color & CONTEXT_MASK);
            } else {
                st.*.color &= CONTEXT_MASK;
            }
        }
    }
}
pub export fn dump_colors(arg_bw_1: [*c]BW) void {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var buf: [256]u8 = undefined;
    _ = &buf;
    var colors: [*c]SCHEME = undefined;
    _ = &colors;
    {
        colors = allcolors.link.next;
        while (colors != (&allcolors)) : (colors = colors.*.link.next) {
            var cset: [*c]COLORSET = undefined;
            _ = &cset;
            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "Color scheme [%s]\n", colors.*.name);
            _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
            _ = pnextl(bw_1.*.cursor);
            {
                cset = colors.*.sets;
                while (cset != null) : (cset = cset.*.next) {
                    var cdef: [*c]struct_color_def = undefined;
                    _ = &cdef;
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "* Color set [%d]\n", cset.*.colors);
                    _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
                    _ = pnextl(bw_1.*.cursor);
                    if (cset.*.palette != null) {
                        var i: c_int = undefined;
                        _ = &i;
                        _ = binss(bw_1.*.cursor, "  * Palette: ");
                        _ = p_goto_eol(bw_1.*.cursor);
                        {
                            i = 0;
                            while ((i < @as(c_int, 256)) and (cset.*.palette[@as(usize, @intCast(i))] == -@as(c_int, 1))) : (i += 1) {}
                        }
                        _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "[start %d] ", i);
                        _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
                        _ = p_goto_eol(bw_1.*.cursor);
                        while ((i < @as(c_int, 256)) and (cset.*.palette[@as(usize, @intCast(i))] != -@as(c_int, 1))) : (i += 1) {
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%06x ", cset.*.palette[@as(usize, @intCast(i))]);
                            _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
                            _ = p_goto_eol(bw_1.*.cursor);
                        }
                        _ = binss(bw_1.*.cursor, "\n");
                        _ = pnextl(bw_1.*.cursor);
                    }
                    {
                        cdef = cset.*.alldefs;
                        while (cdef != null) : (cdef = cdef.*.next) {
                            var cref: [*c]struct_color_ref = undefined;
                            _ = &cref;
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "  * Color Definition [%s]\n", cdef.*.name);
                            _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
                            _ = pnextl(bw_1.*.cursor);
                            {
                                cref = cdef.*.refs;
                                while (cref != null) : (cref = cref.*.next) {
                                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "    * Color Reference [%s]\n", cref.*.name);
                                    _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
                                    _ = pnextl(bw_1.*.cursor);
                                }
                            }
                            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "    * Spec type=%d [%d/%d]\n", cdef.*.spec.@"type", ((cdef.*.spec.atr & (@as(c_int, 1023) << @intCast(FG_SHIFT))) & ~(@as(c_int, 256) << @intCast(FG_SHIFT))) >> @intCast(FG_SHIFT), ((cdef.*.spec.atr & (@as(c_int, 1023) << @intCast(BG_SHIFT))) & ~(@as(c_int, 256) << @intCast(FG_SHIFT))) >> @intCast(BG_SHIFT));
                            _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
                            _ = pnextl(bw_1.*.cursor);
                        }
                    }
                }
            }
        }
    }
}
pub const struct_color_states = extern struct {
    next: [*c]struct_color_states = null,
    term: [*c]u8 = null,
    scheme: [*c]u8 = null,
};
pub export fn load_colors_state(arg_fp: ?*FILE) void {
    var fp = arg_fp;
    _ = &fp;
    var buf: [256]u8 = undefined;
    _ = &buf;
    var bf: [256]u8 = undefined;
    _ = &bf;
    while ((fgets(@ptrCast(@alignCast(&buf)), @truncate(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))) - @as(ptrdiff_t, 1)), fp) != null) and (strcmp(@ptrCast(@alignCast(&buf)), "done\n") != 0)) {
        var p: [*c]const u8 = @ptrCast(@alignCast(&buf));
        _ = &p;
        var len: ptrdiff_t = undefined;
        _ = &len;
        var term: [*c]u8 = undefined;
        _ = &term;
        _ = parse_ws(&p, '#');
        term = null;
        len = parse_string(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))));
        if (len <= @as(ptrdiff_t, 0)) continue;
        term = zdup(@ptrCast(@alignCast(&bf)));
        _ = parse_ws(&p, '#');
        len = parse_string(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))));
        if (len > @as(ptrdiff_t, 0)) {
            var st: [*c]struct_color_states = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_color_states))))))));
            _ = &st;
            st.*.term = term;
            st.*.scheme = zdup(@ptrCast(@alignCast(&bf)));
            st.*.next = saved_scheme_configs;
            saved_scheme_configs = st;
        } else if (term != null) {
            free(@ptrCast(@alignCast(term)));
        }
    }
}
pub export fn save_colors_state(arg_fp: ?*FILE) void {
    var fp = arg_fp;
    _ = &fp;
    var st: [*c]struct_color_states = undefined;
    _ = &st;
    var myterm: [*c]const u8 = getenv("TERM");
    _ = &myterm;
    {
        st = saved_scheme_configs;
        while (st != null) : (st = st.*.next) {
            if (strcmp(myterm, st.*.term) != 0) {
                _ = fprintf(fp, "\t");
                emit_string(fp, st.*.term, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(st.*.term))))));
                _ = fprintf(fp, " ");
                emit_string(fp, st.*.scheme, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(st.*.scheme))))));
                _ = fprintf(fp, "\n");
            }
        }
    }
    if (scheme_name != null) {
        _ = fprintf(fp, "\t");
        emit_string(fp, myterm, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(myterm))))));
        _ = fprintf(fp, " ");
        emit_string(fp, scheme_name, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(scheme_name))))));
        _ = fprintf(fp, "\n");
    }
    _ = fprintf(fp, "done\n");
}
pub export fn init_colors() c_int {
    var myterm: [*c]const u8 = getenv("TERM");
    _ = &myterm;
    var st: [*c]struct_color_states = undefined;
    _ = &st;
    if (scheme_name != null) {
        if (!(apply_scheme(load_scheme(scheme_name)) != 0)) return 0;
    }
    {
        st = saved_scheme_configs;
        while (st != null) : (st = st.*.next) {
            if ((st.*.term != null) and !(strcmp(st.*.term, myterm) != 0)) {
                if (!(apply_scheme(load_scheme(st.*.scheme)) != 0)) return 0;
            }
        }
    }
    return apply_scheme(load_scheme("default"));
}
pub export var scheme_name: [*c]const u8 = null;
pub export var curscheme: [*c]struct_color_scheme = null;
pub export var curschemeset: [*c]struct_color_set = null;
pub export var bg_cursor: c_int = 0;
pub var allcolors: SCHEME = SCHEME{
    .link = struct_unnamed_1{
        .next = &allcolors,
        .prev = &allcolors,
    },
    .name = null,
    .sets = null,
};
pub const struct_color_builtin_specs = extern struct {
    name: [*c]const u8 = null,
    attribute: [*c]c_int = null,
    mask: [*c]c_int = null,
    invert: c_int = 0,
    default_attr: c_int = 0,
    default_mask: c_int = 0,
    default_ptr: [*c]c_int = null,
};
pub const color_builtins: [14]struct_color_builtin_specs = [14]struct_color_builtin_specs{
    struct_color_builtin_specs{
        .name = "text",
        .attribute = &bg_text,
        .mask = null,
        .invert = 0,
        .default_attr = 0,
        .default_mask = 0,
        .default_ptr = null,
    },
    struct_color_builtin_specs{
        .name = "linum",
        .attribute = &bg_linum,
        .mask = null,
        .invert = 0,
        .default_attr = 0,
        .default_mask = 0,
        .default_ptr = &bg_text,
    },
    struct_color_builtin_specs{
        .name = "curlin",
        .attribute = &bg_curlin,
        .mask = &curlinmask,
        .invert = 0,
        .default_attr = 0,
        .default_mask = -@as(c_int, 1),
        .default_ptr = &bg_text,
    },
    struct_color_builtin_specs{
        .name = "curlinum",
        .attribute = &bg_curlinum,
        .mask = null,
        .invert = 0,
        .default_attr = 0,
        .default_mask = 0,
        .default_ptr = &bg_linum,
    },
    struct_color_builtin_specs{
        .name = "selection",
        .attribute = &selectatr,
        .mask = &selectmask,
        .invert = 0,
        .default_attr = INVERSE,
        .default_mask = ~INVERSE,
        .default_ptr = null,
    },
    struct_color_builtin_specs{
        .name = "help",
        .attribute = &bg_help,
        .mask = null,
        .invert = 0,
        .default_attr = 0,
        .default_mask = 0,
        .default_ptr = &bg_text,
    },
    struct_color_builtin_specs{
        .name = "status",
        .attribute = &bg_stalin,
        .mask = null,
        .invert = 1,
        .default_attr = 0,
        .default_mask = 0,
        .default_ptr = &bg_text,
    },
    struct_color_builtin_specs{
        .name = "menu",
        .attribute = &bg_menu,
        .mask = null,
        .invert = 0,
        .default_attr = 0,
        .default_mask = 0,
        .default_ptr = &bg_text,
    },
    struct_color_builtin_specs{
        .name = "menusel",
        .attribute = &bg_menusel,
        .mask = &bg_menumask,
        .invert = 0,
        .default_attr = INVERSE,
        .default_mask = ~INVERSE,
        .default_ptr = null,
    },
    struct_color_builtin_specs{
        .name = "prompt",
        .attribute = &bg_prompt,
        .mask = null,
        .invert = 0,
        .default_attr = 0,
        .default_mask = 0,
        .default_ptr = &bg_text,
    },
    struct_color_builtin_specs{
        .name = "message",
        .attribute = &bg_msg,
        .mask = null,
        .invert = 0,
        .default_attr = 0,
        .default_mask = 0,
        .default_ptr = &bg_text,
    },
    struct_color_builtin_specs{
        .name = "cursor",
        .attribute = &bg_cursor,
        .mask = null,
        .invert = 0,
        .default_attr = INVERSE,
        .default_mask = ~INVERSE,
        .default_ptr = null,
    },
    struct_color_builtin_specs{
        .name = "visiblews",
        .attribute = &vwsatr,
        .mask = &vwsmask,
        .invert = 0,
        .default_attr = DIM,
        .default_mask = ~(DIM | (@as(c_int, 1023) << @intCast(FG_SHIFT))),
        .default_ptr = &bg_text,
    },
    struct_color_builtin_specs{
        .name = null,
        .attribute = null,
        .mask = null,
        .invert = 0,
        .default_attr = 0,
        .default_mask = 0,
        .default_ptr = null,
    },
};
pub var saved_scheme_configs: [*c]struct_color_states = null;
pub fn visit_colordef(arg_cset: [*c]COLORSET, arg_syntax: [*c]struct_high_syntax, arg_cdef: [*c]struct_color_def) callconv(.c) void {
    var cset = arg_cset;
    _ = &cset;
    var syntax = arg_syntax;
    _ = &syntax;
    var cdef = arg_cdef;
    _ = &cdef;
    var cref: [*c]struct_color_ref = undefined;
    _ = &cref;
    if (cdef.*.visited == COLORDEF_VISITED) return;
    if (cdef.*.visited == COLORDEF_VISITING) {
        _ = snprintf(i_msg, 128, my_gettext("%s: Recursive color definition found involving %s\n"), syntax.*.name, cdef.*.name);
        internal_msg(i_msg);
        setlogerrs();
        return;
    }
    if (cdef.*.spec.@"type" != COLORSPEC_TYPE_NONE) {
        cdef.*.visited = COLORDEF_VISITED;
        return;
    }
    cdef.*.visited = COLORDEF_VISITING;
    {
        cref = cdef.*.refs;
        while (cref != null) : (cref = cref.*.next) {
            var rcdef: [*c]struct_color_def = null;
            _ = &rcdef;
            if (syntax != null) {
                {
                    rcdef = syntax.*.color;
                    while (rcdef != null) : (rcdef = rcdef.*.next) {
                        if (!(strcmp(rcdef.*.name, cref.*.name) != 0)) {
                            break;
                        }
                    }
                }
                if (!(rcdef != null)) {
                    var buf: [128]u8 = undefined;
                    _ = &buf;
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "%s.%s", syntax.*.name, cref.*.name);
                    rcdef = @ptrCast(@alignCast(htfind(cset.*.syntax, @ptrCast(@alignCast(&buf)))));
                }
            }
            if (!(rcdef != null)) {
                rcdef = @ptrCast(@alignCast(htfind(cset.*.syntax, cref.*.name)));
            }
            if (rcdef != null) {
                visit_colordef(cset, syntax, rcdef);
                if (rcdef.*.spec.@"type" != COLORSPEC_TYPE_NONE) {
                    _ = memcpy(@ptrCast(@alignCast(&cdef.*.spec)), @ptrCast(@alignCast(&rcdef.*.spec)), @sizeOf(struct_color_spec));
                    break;
                }
            }
        }
    }
    cdef.*.visited = COLORDEF_VISITED;
}
pub fn build_palette(arg_cset: [*c]COLORSET, arg_startidx: c_int) callconv(.c) c_int {
    var cset = arg_cset;
    _ = &cset;
    var startidx = arg_startidx;
    _ = &startidx;
    const SIZE: c_int = 256;
    _ = &SIZE;
    var cdef: [*c]struct_color_def = undefined;
    _ = &cdef;
    var palette: [*c]c_int = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))) * @as(ptrdiff_t, SIZE))));
    _ = &palette;
    var i: c_int = undefined;
    _ = &i;
    var t: c_int = undefined;
    _ = &t;
    {
        i = 0;
        while (i < startidx) : (i += 1) {
            palette[@as(usize, @intCast(i))] = -@as(c_int, 1);
        }
    }
    i = startidx;
    {
        cdef = cset.*.alldefs;
        while (cdef != null) : (cdef = cdef.*.next) {
            if (add_palette(palette, &cdef.*.spec, &i, startidx, SIZE) != 0) {
                joe_free(@ptrCast(@alignCast(palette)));
                return 1;
            }
        }
    }
    {
        t = 0;
        while (color_builtins[@as(usize, @intCast(t))].name != null) : (t += 1) {
            if (add_palette(palette, &cset.*.builtins[@as(usize, @intCast(t))], &i, startidx, SIZE) != 0) {
                joe_free(@ptrCast(@alignCast(palette)));
                return 1;
            }
        }
    }
    {
        t = 0;
        while (t < @as(c_int, 16)) : (t += 1) {
            if (add_palette(palette, &@as(*COLORSET, cset).termcolors[@as(usize, @intCast(t))], &i, startidx, SIZE) != 0) {
                joe_free(@ptrCast(@alignCast(palette)));
                return 1;
            }
        }
    }
    i = sort_palette(palette, startidx, i);
    {
        cdef = cset.*.alldefs;
        while (cdef != null) : (cdef = cdef.*.next) {
            get_palette(palette, &cdef.*.spec, startidx, i);
        }
    }
    {
        t = 0;
        while (color_builtins[@as(usize, @intCast(t))].name != null) : (t += 1) {
            get_palette(palette, &cset.*.builtins[@as(usize, @intCast(t))], startidx, i);
        }
    }
    {
        t = 0;
        while (t < @as(c_int, 16)) : (t += 1) {
            get_palette(palette, &@as(*COLORSET, cset).termcolors[@as(usize, @intCast(t))], startidx, i);
        }
    }
    {
        t = i;
        while (t < SIZE) : (t += 1) {
            palette[@as(usize, @intCast(t))] = -@as(c_int, 1);
        }
    }
    cset.*.palette = palette;
    return 0;
}
pub fn get_palette(arg_palette: [*c]c_int, arg_spec: [*c]struct_color_spec, arg_startidx: c_int, arg_endidx: c_int) callconv(.c) void {
    var palette = arg_palette;
    _ = &palette;
    var spec = arg_spec;
    _ = &spec;
    var startidx = arg_startidx;
    _ = &startidx;
    var endidx = arg_endidx;
    _ = &endidx;
    if (spec.*.@"type" == COLORSPEC_TYPE_GUI) {
        if ((spec.*.mask & (@as(c_int, 1023) << @intCast(FG_SHIFT))) != 0) {
            spec.*.atr = (((spec.*.atr & ~(@as(c_int, 1023) << @intCast(FG_SHIFT))) | (findpal(palette, startidx, endidx, spec.*.gui_fg) << @intCast(FG_SHIFT))) | (@as(c_int, 512) << @intCast(FG_SHIFT))) | (@as(c_int, 256) << @intCast(FG_SHIFT));
        }
        if ((spec.*.mask & (@as(c_int, 1023) << @intCast(BG_SHIFT))) != 0) {
            spec.*.atr = (((spec.*.atr & ~(@as(c_int, 1023) << @intCast(BG_SHIFT))) | (findpal(palette, startidx, endidx, spec.*.gui_bg) << @intCast(BG_SHIFT))) | (@as(c_int, 512) << @intCast(BG_SHIFT))) | (@as(c_int, 256) << @intCast(BG_SHIFT));
        }
        spec.*.@"type" = COLORSPEC_TYPE_ATTR;
    }
}
pub fn findpal(arg_palette: [*c]c_int, arg_startidx: c_int, arg_endidx: c_int, arg_color: c_int) callconv(.c) c_int {
    var palette = arg_palette;
    _ = &palette;
    var startidx = arg_startidx;
    _ = &startidx;
    var endidx = arg_endidx;
    _ = &endidx;
    var color = arg_color;
    _ = &color;
    var start: c_int = startidx;
    _ = &start;
    var end: c_int = endidx - @as(c_int, 1);
    _ = &end;
    while (start <= end) {
        var mid: c_int = @divTrunc(start + end, @as(c_int, 2));
        _ = &mid;
        if (palette[@as(usize, @intCast(mid))] < color) {
            start = mid + @as(c_int, 1);
        } else if (palette[@as(usize, @intCast(mid))] > color) {
            end = mid - @as(c_int, 1);
        } else {
            return mid;
        }
    }
    return -@as(c_int, 1);
}
pub fn add_palette(arg_palette: [*c]c_int, arg_spec: [*c]struct_color_spec, arg_idx: [*c]c_int, arg_startidx: c_int, arg_size: c_int) callconv(.c) c_int {
    var palette = arg_palette;
    _ = &palette;
    var spec = arg_spec;
    _ = &spec;
    var idx = arg_idx;
    _ = &idx;
    var startidx = arg_startidx;
    _ = &startidx;
    var size = arg_size;
    _ = &size;
    if (spec.*.@"type" == COLORSPEC_TYPE_GUI) {
        var i: c_int = idx.*;
        _ = &i;
        if ((spec.*.mask & (@as(c_int, 1023) << @intCast(FG_SHIFT))) != 0) {
            palette[
                @bitCast(@as(isize, @intCast(blk: {
                    const ref = &i;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                })))
            ] = spec.*.gui_fg;
        }
        if (i == size) {
            i = sort_palette(&palette[@as(usize, @intCast(startidx))], startidx, i);
            if (i >= size) return 1;
        }
        if ((spec.*.mask & (@as(c_int, 1023) << @intCast(BG_SHIFT))) != 0) {
            palette[
                @bitCast(@as(isize, @intCast(blk: {
                    const ref = &i;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                })))
            ] = spec.*.gui_bg;
        }
        if (i == size) {
            i = sort_palette(&palette[@as(usize, @intCast(startidx))], startidx, i);
            if (i >= size) return 1;
        }
        idx.* = i;
    }
    return 0;
}
pub fn sort_palette(arg_palette: [*c]c_int, arg_start: c_int, arg_end: c_int) callconv(.c) c_int {
    var palette = arg_palette;
    _ = &palette;
    var start = arg_start;
    _ = &start;
    var end = arg_end;
    _ = &end;
    var i: c_int = undefined;
    _ = &i;
    var t: c_int = undefined;
    _ = &t;
    jsort(@ptrCast(@alignCast(&palette[@as(usize, @intCast(start))])), end - start, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))), palcmp);
    {
        i = start + @as(c_int, 1);
        while ((i < end) and (palette[@bitCast(@as(isize, @intCast(i - @as(c_int, 1))))] != palette[@as(usize, @intCast(i))])) : (i += 1) {}
    }
    {
        t = i - @as(c_int, 1);
        while (i < end) : (i += 1) {
            while ((i < end) and (palette[@as(usize, @intCast(t))] == palette[@as(usize, @intCast(i))])) : (i += 1) {}
            if (i < end) {
                palette[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &t;
                        ref.* += 1;
                        break :blk ref.*;
                    })))
                ] = palette[@as(usize, @intCast(i))];
            }
        }
    }
    return t + @as(c_int, 1);
}
pub fn palcmp(arg_a: ?*const anyopaque, arg_b: ?*const anyopaque) callconv(.c) c_int {
    var a = arg_a;
    _ = &a;
    var b = arg_b;
    _ = &b;
    return if (@as([*c]const c_int, @ptrCast(@alignCast(a))).* < @as([*c]const c_int, @ptrCast(@alignCast(b))).*) -@as(c_int, 1) else @as(c_int, 1);
}
pub fn preprocess_line(arg_p: [*c]u8, arg_bf: [*c]u8, arg_macros: [*c]struct_color_macro) callconv(.c) [*c]u8 {
    var p = arg_p;
    _ = &p;
    var bf = arg_bf;
    _ = &bf;
    var macros = arg_macros;
    _ = &macros;
    var i: ptrdiff_t = undefined;
    _ = &i;
    p = vstrunc(p, 0);
    p = vsensure(p, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(bf))))));
    {
        i = 0;
        while ((@as(c_int, bf[@as(usize, @intCast(i))]) != 0) and (@as(c_int, bf[@as(usize, @intCast(i))]) != @as(c_int, '#'))) : (i += 1) {
            if (@as(c_int, bf[@as(usize, @intCast(i))]) == @as(c_int, '[')) {
                var t: ptrdiff_t = undefined;
                _ = &t;
                {
                    t = i + @as(ptrdiff_t, 1);
                    while (((@as(c_int, bf[@as(usize, @intCast(t))]) != 0) and (@as(c_int, bf[@as(usize, @intCast(t))]) != @as(c_int, '#'))) and (@as(c_int, bf[@as(usize, @intCast(t))]) != @as(c_int, ']'))) : (t += 1) {}
                }
                if (@as(c_int, bf[@as(usize, @intCast(t))]) == @as(c_int, ']')) {
                    var m: [*c]struct_color_macro = macros;
                    _ = &m;
                    bf[@as(usize, @intCast(t))] = 0;
                    while (m != null) : (m = m.*.next) {
                        if (!(strcmp(m.*.name, &bf[@bitCast(@as(isize, @intCast(i + @as(ptrdiff_t, 1))))]) != 0)) {
                            break;
                        }
                    }
                    bf[@as(usize, @intCast(t))] = ']';
                    if (m != null) {
                        p = vsncpy(p, if (p != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(p))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), m.*.value, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(m.*.value))))));
                        i = t;
                    }
                }
            } else {
                p = vsadd(p, bf[@as(usize, @intCast(i))]);
            }
        }
    }
    return p;
}
pub fn colorset_alloc() callconv(.c) [*c]COLORSET {
    var colorset: [*c]COLORSET = undefined;
    _ = &colorset;
    var i: c_int = undefined;
    _ = &i;
    colorset = @ptrCast(@alignCast(joe_calloc(1, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_color_set))))))));
    colorset.*.syntax = htmk(64);
    colorset.*.builtins = @ptrCast(@alignCast(joe_calloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(color_builtins)))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))));
    colorset.*.alldefs = null;
    {
        i = 0;
        while (i < @as(c_int, 16)) : (i += 1) {
            @as(*COLORSET, colorset).termcolors[@as(usize, @intCast(i))].@"type" = COLORSPEC_TYPE_NONE;
        }
    }
    {
        i = 0;
        while (color_builtins[@as(usize, @intCast(i))].name != null) : (i += 1) {
            colorset.*.builtins[@as(usize, @intCast(i))].@"type" = COLORSPEC_TYPE_NONE;
        }
    }
    return colorset;
}
pub fn parse_scoped_ident(arg_p: [*c][*c]const u8, arg_dest: [*c]u8, arg_sz_1: ptrdiff_t) callconv(.c) c_int {
    var p = arg_p;
    _ = &p;
    var dest = arg_dest;
    _ = &dest;
    var sz_1 = arg_sz_1;
    _ = &sz_1;
    if (!(parse_ident(p, dest, sz_1) != 0)) {
        if (!(parse_char(p, '.') != 0)) {
            var n: ptrdiff_t = @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(dest)))));
            _ = &n;
            dest[
                @bitCast(@as(isize, @intCast(blk: {
                    const ref = &n;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                })))
            ] = '.';
            if (!(parse_ident(p, &dest[@as(usize, @intCast(n))], sz_1 - n) != 0)) {
                return 0;
            }
        } else {
            return 0;
        }
    }
    return 1;
}

comptime {
    if (@sizeOf(struct_color_spec) != 20) @compileError("color_spec size mismatch");
    if (@sizeOf(struct_color_ref) != 16) @compileError("color_ref size mismatch");
    if (@sizeOf(struct_color_def) != 72) @compileError("color_def size mismatch");
    if (@sizeOf(struct_color_set) != 368) @compileError("color_set size mismatch");
    if (@sizeOf(struct_color_scheme) != 32) @compileError("color_scheme size mismatch");
    if (@sizeOf(HASH) != 24) @compileError("HASH size mismatch");
    if (@sizeOf(JFILE) != 16) @compileError("JFILE size mismatch");
    if (@sizeOf(BW) != 488) @compileError("BW size mismatch");
    if (@sizeOf(SCRN) != 840) @compileError("SCRN size mismatch");
    if (@sizeOf(Screen) != 48) @compileError("Screen size mismatch");
    if (@sizeOf(struct_high_syntax) != 136) @compileError("high_syntax size mismatch");
    if (@sizeOf(struct_high_state) != 296) @compileError("high_state size mismatch");
    if (@sizeOf(P) != 112) @compileError("P size mismatch");
}
