//! Syntax highlighting DFA interpreter — replaces `joe/syntax.c`.
//!
//! Faithful C-ABI port of JOE's .jsf parser + DFA engine.
//! Generated from a goto-free / bitfield-free rewrite of syntax.c via
//! `zig translate-c`, then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;
pub const off_t = i64;


pub const NO_MORE_DATA = -@as(c_int, 256);
pub const SAVED_SIZE = @as(c_int, 80);
pub const COLORSPEC_TYPE_NONE = @as(c_int, 0);
pub const CONTEXT_COMMENT = @as(c_int, 1);
pub const CONTEXT_STRING = @as(c_int, 2);
pub const CONTEXT_MASK = CONTEXT_COMMENT + CONTEXT_STRING;
pub const INVERSE = @as(c_int, 64);
pub const UNDERLINE = @as(c_int, 128);
pub const BOLD = @as(c_int, 256);
pub const BLINK = @as(c_int, 512);
pub const DIM = @as(c_int, 1024);
pub const DOUBLE_UNDERLINE = @as(c_int, 8);
pub const CROSSED_OUT = @as(c_int, 16);
pub const AT_MASK = ((((((INVERSE + UNDERLINE) + BOLD) + BLINK) + DIM) + @as(c_int, 32)) + DOUBLE_UNDERLINE) + CROSSED_OUT;
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
pub const CMD_F_NOEAT = @as(c_uint, 1) << @as(c_int, 0);
pub const CMD_F_START_BUFFERING = @as(c_uint, 1) << @as(c_int, 1);
pub const CMD_F_STOP_BUFFERING = @as(c_uint, 1) << @as(c_int, 2);
pub const CMD_F_SAVE_C = @as(c_uint, 1) << @as(c_int, 3);
pub const CMD_F_SAVE_S = @as(c_uint, 1) << @as(c_int, 4);
pub const CMD_F_PUSH_C = @as(c_uint, 1) << @as(c_int, 5);
pub const CMD_F_PUSH_S = @as(c_uint, 1) << @as(c_int, 6);
pub const CMD_F_POP_C = @as(c_uint, 1) << @as(c_int, 7);
pub const CMD_F_POP_S = @as(c_uint, 1) << @as(c_int, 8);
pub const CMD_F_IGNORE = @as(c_uint, 1) << @as(c_int, 9);
pub const CMD_F_START_MARK = @as(c_uint, 1) << @as(c_int, 10);
pub const CMD_F_STOP_MARK = @as(c_uint, 1) << @as(c_int, 11);
pub const CMD_F_RECOLOR_MARK = @as(c_uint, 1) << @as(c_int, 12);
pub const CMD_F_RTN = @as(c_uint, 1) << @as(c_int, 13);
pub const CMD_F_RESET = @as(c_uint, 1) << @as(c_int, 14);
pub const IDLE = @as(c_int, 0);
pub const AFTER_ESC = @as(c_int, 1);
pub const AFTER_BRACK = @as(c_int, 2);
pub const IN_NUMBER = @as(c_int, 3);

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn free(p: ?*anyopaque) void;


pub inline fn logerror_2(fmt: anytype, a: anytype, b: anytype) @TypeOf(setlogerrs()) {
    _ = snprintf(i_msg, @as(c_int, 128), fmt, a, b);
    _ = internal_msg(i_msg);
    return setlogerrs();
}
pub inline fn logmessage_3(fmt: anytype, a: anytype, b: anytype, c: anytype) void {
    _ = snprintf(i_msg, @as(c_int, 128), fmt, a, b, c);
    _ = internal_msg(i_msg);
}
pub inline fn zcmp(a: anytype, b: anytype) @TypeOf(strcmp(a, b)) {
    return strcmp(a, b);
}

pub const struct_entry = extern struct {
    next: [*c]struct_entry = null,
    name: [*c]const u8 = null,
    hash_val: ptrdiff_t = 0,
    val: ?*anyopaque = null,
};
pub const HENTRY = struct_entry;
pub const struct_Hash = extern struct {
    len: ptrdiff_t = 0,
    tab: [*c][*c]HENTRY = null,
    nentries: ptrdiff_t = 0,
};
pub const HASH = struct_Hash;
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
pub const COLORSET = struct_color_set;
pub const struct_color_set = extern struct {
    next: [*c]COLORSET = null,
    colors: c_int = 0,
    syntax: [*c]HASH = null,
    palette: [*c]c_int = null,
    alldefs: [*c]struct_color_def = null,
    builtins: [*c]struct_color_spec = null,
    termcolors: [16]struct_color_spec = std.mem.zeroes([16]struct_color_spec),
};
pub const struct_color_scheme = opaque {};
pub const SCHEME = struct_color_scheme;
pub const struct_Zhash = extern struct {
    _pad: [24]u8 = std.mem.zeroes([24]u8),
};
pub const ZHASH = struct_Zhash;
pub const struct_jfile = extern struct {
    _pad: [16]u8 = std.mem.zeroes([16]u8),
};
pub const JFILE = struct_jfile;
pub const struct_options_match = extern struct {
    _pad: [32]u8 = std.mem.zeroes([32]u8),
};
pub const struct_high_param = extern struct {
    next: [*c]struct_high_param = null,
    name: [*c]u8 = null,
};
pub const struct_Rtree = extern struct {
    _pad: [248]u8 = std.mem.zeroes([248]u8),
};
pub const struct_high_cmd = extern struct {
    flags: c_uint = 0,
    recolor: ptrdiff_t = 0,
    new_state: [*c]struct_high_state = null,
    keywords: [*c]ZHASH = null,
    delim: [*c]struct_high_cmd = null,
    call: [*c]struct_high_syntax = null,
};
pub const struct_high_state = extern struct {
    no: ptrdiff_t = 0,
    name: c_int = 0,
    color: c_int = 0,
    colorp: [*c]struct_color_def = null,
    rtree: struct_Rtree = std.mem.zeroes(struct_Rtree),
    dflt: [*c]struct_high_cmd = null,
    same_delim: [*c]struct_high_cmd = null,
    delim: [*c]struct_high_cmd = null,
};
pub const struct_high_frame = extern struct {
    parent: [*c]struct_high_frame = null,
    child: [*c]struct_high_frame = null,
    sibling: [*c]struct_high_frame = null,
    syntax: [*c]struct_high_syntax = null,
    return_state: [*c]struct_high_state = null,
};
pub const struct_high_delim_frame = extern struct {
    parent: [*c]struct_high_delim_frame = null,
    child: [*c]struct_high_delim_frame = null,
    sibling: [*c]struct_high_delim_frame = null,
    saved_s: [*c]const c_int = null,
};
pub const struct_high_syntax = extern struct {
    next: [*c]struct_high_syntax = null,
    name: [*c]u8 = null,
    subr: [*c]u8 = null,
    params: [*c]struct_high_param = null,
    states: [*c][*c]struct_high_state = null,
    ht_states: [*c]HASH = null,
    nstates: ptrdiff_t = 0,
    szstates: ptrdiff_t = 0,
    color: [*c]struct_color_def = null,
    default_cmd: struct_high_cmd = std.mem.zeroes(struct_high_cmd),
    stack_base: [*c]struct_high_frame = null,
    delim_stack_base: [*c]struct_high_delim_frame = null,
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
pub const OPTIONS = struct_options;
pub const struct_buffer = extern struct {
    _pad0: [192]u8 = std.mem.zeroes([192]u8),
    o: OPTIONS = std.mem.zeroes(OPTIONS),
    _pad1: [96]u8 = std.mem.zeroes([96]u8),
};
pub const B = struct_buffer;
pub const struct_point = extern struct {
    link_next: ?*anyopaque = null,
    link_prev: ?*anyopaque = null,
    b: [*c]B = null,
    _pad: [88]u8 = std.mem.zeroes([88]u8),
};
pub const P = struct_point;
pub const struct_bw = extern struct {
    _pad0: [24]u8 = std.mem.zeroes([24]u8),
    cursor: [*c]P = null,
    _pad1: [456]u8 = std.mem.zeroes([456]u8),
};
pub const BW = struct_bw;
pub const attr_data = c_int;
pub const struct_interval = extern struct {
    first: c_int = 0,
    last: c_int = 0,
};
pub const struct_highlight_state = extern struct {
    stack: [*c]struct_high_frame = null,
    delim_stack: [*c]struct_high_delim_frame = null,
    saved_s: [*c]const c_int = null,
    state: ptrdiff_t = 0,
};
pub const HIGHLIGHT_STATE = struct_highlight_state;
pub const struct_state_debug_data = extern struct {
    name: c_int = 0,
    recolor: c_int = 0,
};
pub const i_msg: [*c]u8 = @extern([*c]u8, .{
    .name = "i_msg",
});
pub extern var curschemeset: [*c]struct_color_set;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn internal_msg(s: [*c]const u8) void;
pub extern fn setlogerrs() void;
pub extern fn joe_malloc(n: ptrdiff_t) ?*anyopaque;
pub extern fn joe_realloc(p: ?*anyopaque, n: ptrdiff_t) ?*anyopaque;
pub extern fn joe_calloc(n: ptrdiff_t, sz: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(p: ?*anyopaque) void;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn zlcpy(a: [*c]u8, siz: ptrdiff_t, b: [*c]const u8) [*c]u8;
pub extern fn zlcat(a: [*c]u8, siz: ptrdiff_t, b: [*c]const u8) [*c]u8;
pub extern fn vsrm(v: [*c]u8) void;
pub extern fn htmk(len: ptrdiff_t) [*c]HASH;
pub extern fn htadd(ht: [*c]HASH, name: [*c]const u8, val: ?*anyopaque) ?*anyopaque;
pub extern fn htfind(ht: [*c]HASH, name: [*c]const u8) ?*anyopaque;
pub extern fn htrm(ht: [*c]HASH) void;
pub extern fn atom_add(name: [*c]const u8) [*c]const u8;
pub extern fn Zhtmk(len: ptrdiff_t) [*c]ZHASH;
pub extern fn Zhtadd(ht: [*c]ZHASH, name: [*c]const c_int, val: ?*anyopaque) ?*anyopaque;
pub extern fn Zhtfind(ht: [*c]ZHASH, name: [*c]const c_int) ?*anyopaque;
pub extern fn Zatom_add(name: [*c]const c_int) [*c]const c_int;
pub extern fn Zcmp(a: [*c]const c_int, b: [*c]const c_int) c_int;
pub extern fn Zdup(s: [*c]const c_int) [*c]c_int;
pub extern fn jfgets(buf: [*c]u8, len: c_int, f: [*c]JFILE) [*c]u8;
pub extern fn jfclose(f: [*c]JFILE) c_int;
pub extern fn open_config_file(result: [*c][*c]JFILE, prefix: [*c]const u8, name: [*c]const u8, suffix: [*c]const u8) [*c]u8;
pub extern fn parse_ws(p: [*c][*c]const u8, cmt: c_int) c_int;
pub extern fn parse_ident(p: [*c][*c]const u8, buf: [*c]u8, len: ptrdiff_t) c_int;
pub extern fn parse_char(p: [*c][*c]const u8, c: u8) c_int;
pub extern fn parse_tows(p: [*c][*c]const u8, buf: [*c]u8) c_int;
pub extern fn parse_field(p: [*c][*c]const u8, field: [*c]const u8) c_int;
pub extern fn parse_diff(p: [*c][*c]const u8, buf: [*c]ptrdiff_t) c_int;
pub extern fn parse_Zstring(p: [*c][*c]const u8, buf: [*c]c_int, len: ptrdiff_t) ptrdiff_t;
pub extern fn parse_class(p: [*c][*c]const u8, array: [*c][*c]struct_interval, size: [*c]ptrdiff_t) c_int;
pub extern fn parse_color_def(p: [*c][*c]const u8, dest: [*c]struct_color_def) c_int;
pub extern fn resolve_syntax_colors(cset: [*c]COLORSET, syntax: [*c]struct_high_syntax) void;
pub extern fn pgetc(p: [*c]P) c_int;
pub extern fn binss(p: [*c]P, s: [*c]const u8) [*c]P;
pub extern fn pnextl(p: [*c]P) [*c]P;
pub extern fn to_uni(cset: [*c]struct_charmap, c: c_int) c_int;
pub extern fn lowerize(d: [*c]c_int, len: ptrdiff_t, s: [*c]const c_int) [*c]c_int;
pub extern fn rtree_init(r: [*c]struct_Rtree) void;
pub extern fn rtree_lookup(r: [*c]struct_Rtree, ch: c_int) ?*anyopaque;
pub extern fn rtree_opt(r: [*c]struct_Rtree) void;
pub extern fn rtree_set(r: [*c]struct_Rtree, array: [*c]struct_interval, len: ptrdiff_t, map: ?*anyopaque) void;
pub extern fn rtree_show(r: [*c]struct_Rtree) void;
pub export var attr_buf: [*c]attr_data = null;
pub export var syndebug_buf: [*c]struct_state_debug_data = null;
pub export var attr_size: c_int = 0;
pub export var stack_count: c_int = 0;
pub export var delim_stack_count: c_int = 0;
pub var state_count: c_int = 0;
pub export var ansi_syntax: [*c]struct_high_syntax = null;
pub export var syntax_list: [*c]struct_high_syntax = null;
pub export var state_names: [*c][*c]const u8 = null;
pub var num_state_names: c_int = 0;
pub var alloc_state_names: c_int = 0;
pub fn check_alloc_attr_bufs(arg_attrp: [*c][*c]attr_data, arg_attr_endp: [*c][*c]attr_data, arg_syndebugp: [*c][*c]struct_state_debug_data) callconv(.c) void {
    var attrp = arg_attrp;
    _ = &attrp;
    var attr_endp = arg_attr_endp;
    _ = &attr_endp;
    var syndebugp = arg_syndebugp;
    _ = &syndebugp;
    if (!(attr_buf != null)) {
        attr_size = 1024;
        attr_buf = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(attr_data))))) * @as(ptrdiff_t, attr_size))));
    }
    attrp.* = attr_buf;
    attr_endp.* = attr_buf + @as(usize, @bitCast(@as(isize, @intCast(attr_size))));
    if (!(syndebugp != null)) {
        joe_free(@ptrCast(@alignCast(syndebug_buf)));
        syndebug_buf = null;
    } else if (!(syndebug_buf != null)) {
        syndebug_buf = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_state_debug_data))))) * @as(ptrdiff_t, attr_size))));
    }
    if (syndebugp != null) {
        syndebugp.* = syndebug_buf;
    }
}
pub fn realloc_attr_bufs(arg_attrp: [*c][*c]attr_data, arg_attr_endp: [*c][*c]attr_data, arg_syndebugp: [*c][*c]struct_state_debug_data) callconv(.c) void {
    var attrp = arg_attrp;
    _ = &attrp;
    var attr_endp = arg_attr_endp;
    _ = &attr_endp;
    var syndebugp = arg_syndebugp;
    _ = &syndebugp;
    var new_size: c_int = attr_size * @as(c_int, 2);
    _ = &new_size;
    attr_buf = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(attr_buf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(attr_data))))) * @as(ptrdiff_t, new_size))));
    attrp.* = attr_buf + @as(usize, @bitCast(@as(isize, @intCast(attr_size))));
    attr_endp.* = attr_buf + @as(usize, @bitCast(@as(isize, @intCast(new_size))));
    if (syndebugp != null) {
        syndebug_buf = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(attr_buf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_state_debug_data))))) * @as(ptrdiff_t, new_size))));
        syndebugp.* = syndebug_buf + @as(usize, @bitCast(@as(isize, @intCast(attr_size))));
    }
    attr_size = new_size;
}
pub fn syntax_error_invalidate(arg_h_state: HIGHLIGHT_STATE, arg_attr: [*c]attr_data, arg_attr_end: [*c]attr_data, arg_syndebug: [*c]struct_state_debug_data) callconv(.c) HIGHLIGHT_STATE {
    var h_state = arg_h_state;
    _ = &h_state;
    var attr = arg_attr;
    _ = &attr;
    var attr_end = arg_attr_end;
    _ = &attr_end;
    var syndebug = arg_syndebug;
    _ = &syndebug;
    (&h_state).*.state = -@as(c_int, 1);
    (&h_state).*.saved_s = null;
    (&h_state).*.stack = null;
    (&h_state).*.delim_stack = null;
    _ = memset(@ptrCast(@alignCast(attr)), 0, @as(usize, @bitCast(@as(c_long, @divExact(@as(c_long, @bitCast(@intFromPtr(attr_end) -% @intFromPtr(attr))), @sizeOf(attr_data))))) *% @sizeOf(@TypeOf(attr.*)));
    if (syndebug != null) {
        _ = memset(@ptrCast(@alignCast(syndebug)), 255, @as(usize, @bitCast(@as(c_long, @divExact(@as(c_long, @bitCast(@intFromPtr(attr_end) -% @intFromPtr(attr))), @sizeOf(attr_data))))) *% @sizeOf(@TypeOf(syndebug.*)));
    }
    return h_state;
}
pub fn ansi_parse(arg_line: [*c]P, arg_h_state: HIGHLIGHT_STATE) callconv(.c) HIGHLIGHT_STATE {
    var line = arg_line;
    _ = &line;
    var h_state = arg_h_state;
    _ = &h_state;
    var attr: [*c]attr_data = undefined;
    _ = &attr;
    var attr_end: [*c]attr_data = undefined;
    _ = &attr_end;
    var c: c_int = undefined;
    _ = &c;
    var bold: c_int = 0;
    _ = &bold;
    var state: c_int = IDLE;
    _ = &state;
    var accu: c_int = 0;
    _ = &accu;
    var current_attr: attr_data = 0;
    _ = &current_attr;
    check_alloc_attr_bufs(&attr, &attr_end, null);
    var ansi_mode: c_int = line.*.b.*.o.ansi;
    _ = &ansi_mode;
    line.*.b.*.o.ansi = 0;
    while ((blk: {
        const tmp = pgetc(line);
        c = tmp;
        break :blk tmp;
    }) != -@as(c_int, 256)) {
        if (attr == attr_end) {
            realloc_attr_bufs(&attr, &attr_end, null);
        }
        (blk: {
            const ref = &attr;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).* = current_attr;
        while (true) {
            switch (state) {
                IDLE => {
                    {
                        if (c == @as(c_int, 27)) {
                            state = AFTER_ESC;
                        }
                        break;
                    }
                },
                AFTER_ESC => {
                    {
                        if (c == @as(c_int, '[')) {
                            state = AFTER_BRACK;
                        } else {
                            state = IDLE;
                        }
                        break;
                    }
                },
                AFTER_BRACK => {
                    {
                        if (c == @as(c_int, ';')) {
                            current_attr = 0;
                        } else if ((c >= @as(c_int, '0')) and (c <= @as(c_int, '9'))) {
                            accu = @as(u8, @bitCast(@as(i8, @truncate(c - @as(c_int, '0')))));
                            state = IN_NUMBER;
                        } else if (c == @as(c_int, 'm')) {
                            current_attr = 0;
                            state = IDLE;
                        } else {
                            state = IDLE;
                        }
                        break;
                    }
                },
                IN_NUMBER => {
                    {
                        if ((c == @as(c_int, ';')) or (c == @as(c_int, 'm'))) {
                            if (accu == @as(c_int, 0)) {
                                current_attr = 0;
                                bold = 0;
                            } else if (accu == @as(c_int, 1)) {
                                current_attr |= BOLD;
                                bold = 1;
                            } else if (accu == @as(c_int, 4)) {
                                current_attr |= UNDERLINE;
                            } else if (accu == @as(c_int, 5)) {
                                current_attr |= BLINK;
                            } else if (accu == @as(c_int, 7)) {
                                current_attr |= INVERSE;
                            } else if (accu == @as(c_int, 9)) {
                                current_attr |= CROSSED_OUT;
                            } else if (accu == @as(c_int, 21)) {
                                current_attr |= DOUBLE_UNDERLINE;
                            } else if ((accu >= @as(c_int, 30)) and (accu <= @as(c_int, 37))) {
                                if (((bold != 0) and (curschemeset != null)) and (@as(*COLORSET, curschemeset).termcolors[@as(usize, @intCast(accu - @as(c_int, 22)))].@"type" != COLORSPEC_TYPE_NONE)) {
                                    current_attr = (current_attr & ~(@as(c_int, 1023) << @intCast(FG_SHIFT))) | ((@as(*COLORSET, curschemeset).termcolors[@as(usize, @intCast(accu - @as(c_int, 22)))].atr & (@as(c_int, 1023) << @intCast(FG_SHIFT))) & ~BOLD);
                                } else if ((curschemeset != null) and (@as(*COLORSET, curschemeset).termcolors[@as(usize, @intCast(accu - @as(c_int, 30)))].@"type" != COLORSPEC_TYPE_NONE)) {
                                    current_attr = (current_attr & ~(@as(c_int, 1023) << @intCast(FG_SHIFT))) | (@as(*COLORSET, curschemeset).termcolors[@as(usize, @intCast(accu - @as(c_int, 30)))].atr & (@as(c_int, 1023) << @intCast(FG_SHIFT)));
                                } else {
                                    current_attr = (((current_attr & ~(@as(c_int, 1023) << @intCast(FG_SHIFT))) | (@as(c_int, 256) << @intCast(FG_SHIFT))) | ((accu - @as(c_int, 30)) << @intCast(FG_SHIFT))) | (-bold & BOLD);
                                }
                            } else if ((accu >= @as(c_int, 40)) and (accu <= @as(c_int, 47))) {
                                if ((curschemeset != null) and (@as(*COLORSET, curschemeset).termcolors[@as(usize, @intCast(accu - @as(c_int, 40)))].@"type" != COLORSPEC_TYPE_NONE)) {
                                    current_attr = (current_attr & ~(@as(c_int, 1023) << @intCast(BG_SHIFT))) | (((@as(*COLORSET, curschemeset).termcolors[@as(usize, @intCast(accu - @as(c_int, 40)))].atr & (@as(c_int, 1023) << @intCast(FG_SHIFT))) >> @intCast(FG_SHIFT)) << @intCast(BG_SHIFT));
                                } else {
                                    current_attr = ((current_attr & ~(@as(c_int, 1023) << @intCast(BG_SHIFT))) | (@as(c_int, 256) << @intCast(BG_SHIFT))) | ((accu - @as(c_int, 40)) << @intCast(BG_SHIFT));
                                }
                            }
                            if (c == @as(c_int, ';')) {
                                accu = 0;
                                state = IN_NUMBER;
                            } else if (c == @as(c_int, 'm')) {
                                state = IDLE;
                            }
                        } else if ((c >= @as(c_int, '0')) and (c <= @as(c_int, '9'))) {
                            accu = @as(u8, @bitCast(@as(i8, @truncate(((accu * @as(c_int, 10)) + c) - @as(c_int, '0')))));
                        } else {
                            state = IDLE;
                        }
                    }
                },
                else => {},
            }
            break;
        }
        if (c == @as(c_int, '\n')) break;
    }
    line.*.b.*.o.ansi = ansi_mode;
    h_state.state = current_attr;
    return h_state;
}
pub export fn parse(arg_syntax: [*c]struct_high_syntax, arg_line: [*c]P, arg_h_state: HIGHLIGHT_STATE, arg_charmap_1: [*c]struct_charmap) HIGHLIGHT_STATE {
    var syntax = arg_syntax;
    _ = &syntax;
    var line = arg_line;
    _ = &line;
    var h_state = arg_h_state;
    _ = &h_state;
    var charmap_1 = arg_charmap_1;
    _ = &charmap_1;
    var stack: [*c]struct_high_frame = undefined;
    _ = &stack;
    var delim_stack: [*c]struct_high_delim_frame = undefined;
    _ = &delim_stack;
    var h: [*c]struct_high_state = undefined;
    _ = &h;
    var buf: [80]c_int = undefined;
    _ = &buf;
    var lbuf: [240]c_int = undefined;
    _ = &lbuf;
    var lsaved_s: [240]c_int = undefined;
    _ = &lsaved_s;
    var buf_idx: c_int = undefined;
    _ = &buf_idx;
    var c: c_int = undefined;
    _ = &c;
    var attr: [*c]attr_data = undefined;
    _ = &attr;
    var attr_end: [*c]attr_data = undefined;
    _ = &attr_end;
    var syndebug: [*c]struct_state_debug_data = null;
    _ = &syndebug;
    const syndebugp: [*c][*c]struct_state_debug_data = @ptrCast(@alignCast(if (line.*.b.*.o.syntax_debug != 0) @as(?*anyopaque, @ptrCast(@alignCast(&syndebug))) else @as(?*anyopaque, null)));
    _ = &syndebugp;
    var buf_en: c_int = undefined;
    _ = &buf_en;
    var ofst: c_int = undefined;
    _ = &ofst;
    var mark1: c_int = undefined;
    _ = &mark1;
    var mark2: c_int = undefined;
    _ = &mark2;
    var mark_en: c_int = undefined;
    _ = &mark_en;
    var recolor_delimiter_or_keyword: c_int = undefined;
    _ = &recolor_delimiter_or_keyword;
    if (h_state.state < @as(ptrdiff_t, 0)) {
        return h_state;
    }
    if (syntax == ansi_syntax) return ansi_parse(line, h_state);
    stack = h_state.stack;
    delim_stack = h_state.delim_stack;
    h = (if (stack != null) stack.*.syntax else syntax).*.states[@bitCast(@as(isize, @intCast(h_state.state)))];
    buf_idx = 0;
    attr = attr_buf;
    attr_end = attr_buf + @as(usize, @bitCast(@as(isize, @intCast(attr_size))));
    buf_en = 0;
    ofst = 0;
    mark1 = 0;
    mark2 = 0;
    mark_en = 0;
    buf[@as(c_int, 0)] = 0;
    check_alloc_attr_bufs(&attr, &attr_end, syndebugp);
    while ((blk: {
        const tmp = pgetc(line);
        c = tmp;
        break :blk tmp;
    }) != -@as(c_int, 256)) {
        var cmd: [*c]struct_high_cmd = undefined;
        _ = &cmd;
        var kw_cmd: [*c]struct_high_cmd = undefined;
        _ = &kw_cmd;
        var iters: c_int = -@as(c_int, 8);
        _ = &iters;
        var x: ptrdiff_t = undefined;
        _ = &x;
        if (!(charmap_1.*.@"type" != 0)) {
            c = to_uni(charmap_1, c);
        }
        if (attr == attr_end) {
            realloc_attr_bufs(&attr, &attr_end, syndebugp);
        }
        attr += 1;
        if (syndebug != null) {
            syndebug += 1;
        }
        while (true) {
            if ((blk: {
                const ref = &iters;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }) > state_count) {
                return syntax_error_invalidate(h_state, attr, attr_end, syndebug);
            }
            attr[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))] = h.*.color;
            if (syndebug != null) {
                syndebug[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))].recolor = blk: {
                    const tmp = h.*.name;
                    syndebug[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))].name = tmp;
                    break :blk tmp;
                };
            }
            if (((((h.*.delim != null) and (h_state.saved_s != null)) and (c == h_state.saved_s[@as(c_int, 0)])) and (h_state.saved_s[@as(c_int, 1)] != 0)) and (h_state.saved_s[@as(c_int, 2)] == @as(c_int, 0))) {
                cmd = h.*.delim;
            } else if (((((h.*.same_delim != null) and (h_state.saved_s != null)) and (h_state.saved_s[@as(c_int, 0)] != 0)) and (c == h_state.saved_s[@as(c_int, 1)])) and (h_state.saved_s[@as(c_int, 2)] == @as(c_int, 0))) {
                cmd = h.*.same_delim;
            } else {
                cmd = @ptrCast(@alignCast(rtree_lookup(&h.*.rtree, c)));
                if (!(cmd != null)) {
                    cmd = h.*.dflt;
                }
            }
            if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 9)))) != 0) {
                _ = lowerize(@ptrCast(@alignCast(&lbuf)), @divTrunc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(lbuf)))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(lbuf[@as(c_int, 0)]))))))), @ptrCast(@alignCast(&buf)));
                if (cmd.*.delim != null) {
                    if (h_state.saved_s != null) {
                        _ = lowerize(@ptrCast(@alignCast(&lsaved_s)), @divTrunc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(lsaved_s)))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(lsaved_s[@as(c_int, 0)]))))))), h_state.saved_s);
                    } else {
                        lsaved_s[@as(c_int, 0)] = 0;
                    }
                }
            }
            recolor_delimiter_or_keyword = 0;
            if ((cmd.*.delim != null) and ((if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 9)))) != 0) @intFromBool(!(Zcmp(@ptrCast(@alignCast(&lsaved_s)), @ptrCast(@alignCast(&lbuf))) != 0)) else @intFromBool((h_state.saved_s != null) and !(Zcmp(h_state.saved_s, @ptrCast(@alignCast(&buf))) != 0))) != 0)) {
                cmd = cmd.*.delim;
                recolor_delimiter_or_keyword = 1;
            } else if ((cmd.*.keywords != null) and ((if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 9)))) != 0) blk: {
                const tmp = @as([*c]struct_high_cmd, @ptrCast(@alignCast(Zhtfind(cmd.*.keywords, @ptrCast(@alignCast(&lbuf))))));
                kw_cmd = tmp;
                break :blk tmp;
            } else blk: {
                const tmp = @as([*c]struct_high_cmd, @ptrCast(@alignCast(Zhtfind(cmd.*.keywords, @ptrCast(@alignCast(&buf))))));
                kw_cmd = tmp;
                break :blk tmp;
            }) != null)) {
                cmd = kw_cmd;
                recolor_delimiter_or_keyword = 1;
            }
            if (cmd.*.call != null) {
                var frame_ptr: [*c][*c]struct_high_frame = if (stack != null) &stack.*.child else &syntax.*.stack_base;
                _ = &frame_ptr;
                while ((frame_ptr.* != null) and !((frame_ptr.*.*.syntax == cmd.*.call) and (frame_ptr.*.*.return_state == cmd.*.new_state))) {
                    frame_ptr = &frame_ptr.*.*.sibling;
                }
                if (frame_ptr.* != null) {
                    stack = frame_ptr.*;
                } else {
                    var frame: [*c]struct_high_frame = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_high_frame))))))));
                    _ = &frame;
                    frame.*.parent = stack;
                    frame.*.child = null;
                    frame.*.sibling = null;
                    frame.*.syntax = cmd.*.call;
                    frame.*.return_state = cmd.*.new_state;
                    frame_ptr.* = frame;
                    stack = frame;
                    stack_count += 1;
                }
                h = stack.*.syntax.*.states[@as(c_int, 0)];
            } else if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 13)))) != 0) {
                if (stack != null) {
                    h = stack.*.return_state;
                    stack = stack.*.parent;
                } else {
                    h = cmd.*.new_state;
                }
            } else if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 14)))) != 0) {
                h = syntax.*.states[@as(c_int, 0)];
            } else {
                h = cmd.*.new_state;
                if (!(h != null)) return syntax_error_invalidate(h_state, attr, attr_end, syndebug);
            }
            if (recolor_delimiter_or_keyword != 0) {
                x = -(buf_idx + @as(c_int, 1));
                while (x < @as(ptrdiff_t, -@as(c_int, 1))) : (x += 1) {
                    attr[@bitCast(@as(isize, @intCast(x - @as(ptrdiff_t, ofst))))] = h.*.color;
                    if (syndebug != null) {
                        syndebug[@bitCast(@as(isize, @intCast(x - @as(ptrdiff_t, ofst))))].recolor = h.*.name;
                    }
                }
            }
            {
                x = cmd.*.recolor;
                while (x < @as(ptrdiff_t, 0)) : (x += 1) if ((attr + @as(usize, @bitCast(@as(isize, @intCast(x))))) >= attr_buf) {
                    attr[@bitCast(@as(isize, @intCast(x)))] = h.*.color;
                    if (syndebug != null) {
                        syndebug[@bitCast(@as(isize, @intCast(x)))].recolor = h.*.name;
                    }
                };
            }
            if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 12)))) != 0) {
                x = -mark1;
                while (x < @as(ptrdiff_t, -mark2)) : (x += 1) {
                    attr[@bitCast(@as(isize, @intCast(x)))] = h.*.color;
                    if (syndebug != null) {
                        syndebug[@bitCast(@as(isize, @intCast(x)))].recolor = h.*.name;
                    }
                }
            }
            if (((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 6)))) != 0) or ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 5)))) != 0)) {
                var frame_ptr: [*c][*c]struct_high_delim_frame = if (delim_stack != null) &delim_stack.*.child else &syntax.*.delim_stack_base;
                _ = &frame_ptr;
                while ((((frame_ptr.* != null) and (frame_ptr.*.*.saved_s != null)) and (h_state.saved_s != null)) and (Zcmp(frame_ptr.*.*.saved_s, h_state.saved_s) != 0)) {
                    frame_ptr = &frame_ptr.*.*.sibling;
                }
                if (frame_ptr.* != null) {
                    delim_stack = frame_ptr.*;
                } else {
                    var frame: [*c]struct_high_delim_frame = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_high_delim_frame))))))));
                    _ = &frame;
                    frame.*.parent = delim_stack;
                    frame.*.child = null;
                    frame.*.sibling = null;
                    frame.*.saved_s = h_state.saved_s;
                    frame_ptr.* = frame;
                    delim_stack = frame;
                    delim_stack_count += 1;
                }
            }
            if (((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 4)))) != 0) or ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 6)))) != 0)) {
                h_state.saved_s = Zatom_add(@ptrCast(@alignCast(&buf)));
            }
            if (((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 3)))) != 0) or ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 5)))) != 0)) {
                var bf: [3]c_int = undefined;
                _ = &bf;
                bf[@as(c_int, 1)] = c;
                bf[@as(c_int, 2)] = 0;
                if (c == @as(c_int, '<')) {
                    bf[@as(c_int, 0)] = '>';
                } else if (c == @as(c_int, '(')) {
                    bf[@as(c_int, 0)] = ')';
                } else if (c == @as(c_int, '[')) {
                    bf[@as(c_int, 0)] = ']';
                } else if (c == @as(c_int, '{')) {
                    bf[@as(c_int, 0)] = '}';
                } else if (c == @as(c_int, '`')) {
                    bf[@as(c_int, 0)] = '\'';
                } else {
                    bf[@as(c_int, 0)] = c;
                }
                h_state.saved_s = Zatom_add(@ptrCast(@alignCast(&bf)));
            }
            if (((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 7)))) != 0) or ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 8)))) != 0)) {
                if (delim_stack != null) {
                    h_state.saved_s = delim_stack.*.saved_s;
                    delim_stack = delim_stack.*.parent;
                } else {}
            }
            if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 1)))) != 0) {
                buf_idx = 0;
                buf_en = 1;
                ofst = 0;
            }
            if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 2)))) != 0) {
                buf_en = 0;
            }
            if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 10)))) != 0) {
                mark2 = 1;
                mark1 = 1;
                mark_en = 1;
            }
            if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 11)))) != 0) {
                mark_en = 0;
                mark2 = 1;
            }
            if (!((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 0)))) != 0)) break;
        }
        if ((buf_idx < (SAVED_SIZE - @as(c_int, 1))) and (buf_en != 0)) {
            buf[
                @bitCast(@as(isize, @intCast(blk: {
                    const ref = &buf_idx;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                })))
            ] = c;
        }
        if (!(buf_en != 0)) {
            ofst += 1;
        }
        buf[@bitCast(@as(isize, @intCast(buf_idx)))] = 0;
        mark1 += 1;
        if (!(mark_en != 0)) {
            mark2 += 1;
        }
        if (c == @as(c_int, '\n')) break;
    }
    h_state.stack = stack;
    h_state.delim_stack = delim_stack;
    h_state.state = h.*.no;
    return h_state;
}
pub export fn find_state(arg_syntax: [*c]struct_high_syntax, arg_name: [*c]u8) callconv(.c) [*c]struct_high_state {
    var syntax = arg_syntax;
    _ = &syntax;
    var name = arg_name;
    _ = &name;
    var state: [*c]struct_high_state = undefined;
    _ = &state;
    state = @ptrCast(@alignCast(htfind(syntax.*.ht_states, name)));
    if (!(state != null)) {
        if (!(state_names != null)) {
            alloc_state_names = 128;
            state_names = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, alloc_state_names) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(state_names.*)))))))));
        }
        if (num_state_names == alloc_state_names) {
            alloc_state_names *= 2;
            state_names = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(state_names)), @as(ptrdiff_t, alloc_state_names) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(state_names.*)))))))));
        }
        var i: c_int = undefined;
        _ = &i;
        {
            i = 0;
            while (i < num_state_names) : (i += 1) if (!(strcmp(name, state_names[@bitCast(@as(isize, @intCast(i)))]) != 0)) break;
        }
        state_names[@bitCast(@as(isize, @intCast(num_state_names)))] = if (i < num_state_names) state_names[@bitCast(@as(isize, @intCast(i)))] else @as([*c]const u8, @ptrCast(@alignCast(zdup(name))));
        state = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_high_state))))))));
        state.*.name = blk: {
            const ref = &num_state_names;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        };
        state.*.no = syntax.*.nstates;
        state.*.color = 0;
        state.*.colorp = null;
        if (syntax.*.nstates == syntax.*.szstates) {
            syntax.*.states = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(syntax.*.states)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]struct_high_state))))) * (blk: {
                const ref = &syntax.*.szstates;
                ref.* *= 2;
                break :blk ref.*;
            }))));
        }
        syntax.*.states[
            @bitCast(@as(isize, @intCast(blk: {
                const ref = &syntax.*.nstates;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            })))
        ] = state;
        rtree_init(&state.*.rtree);
        state.*.dflt = &syntax.*.default_cmd;
        state.*.delim = null;
        state.*.same_delim = null;
        _ = htadd(syntax.*.ht_states, state_names[@bitCast(@as(isize, @intCast(state.*.name)))], @ptrCast(@alignCast(state)));
        state_count += 1;
    }
    return state;
}
pub fn build_cmaps(arg_syntax: [*c]struct_high_syntax) callconv(.c) void {
    var syntax = arg_syntax;
    _ = &syntax;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (@as(ptrdiff_t, x) != syntax.*.ht_states.*.len) : (x += 1) {
            var p: [*c]HENTRY = undefined;
            _ = &p;
            {
                p = syntax.*.ht_states.*.tab[@bitCast(@as(isize, @intCast(x)))];
                while (p != null) : (p = p.*.next) {
                    var st: [*c]struct_high_state = @ptrCast(@alignCast(p.*.val));
                    _ = &st;
                    rtree_opt(&st.*.rtree);
                }
            }
        }
    }
}
pub fn iz_cmd(arg_cmd: [*c]struct_high_cmd) callconv(.c) void {
    var cmd = arg_cmd;
    _ = &cmd;
    cmd.*.flags = 0;
    cmd.*.recolor = 0;
    cmd.*.new_state = null;
    cmd.*.keywords = null;
    cmd.*.delim = null;
    cmd.*.call = null;
}
pub fn mkcmd() callconv(.c) [*c]struct_high_cmd {
    var cmd: [*c]struct_high_cmd = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_high_cmd))))))));
    _ = &cmd;
    iz_cmd(cmd);
    return cmd;
}
pub fn find_color(arg_colors: [*c]struct_color_def, arg_name: [*c]u8, arg_syn: [*c]u8) callconv(.c) [*c]struct_color_def {
    var colors = arg_colors;
    _ = &colors;
    var name = arg_name;
    _ = &name;
    var syn = arg_syn;
    _ = &syn;
    var bf: [264]u8 = undefined;
    _ = &bf;
    var color: [*c]struct_color_def = undefined;
    _ = &color;
    _ = snprintf(@ptrCast(@alignCast(&bf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))))), "%s.%s", syn, name);
    {
        color = colors;
        while (color != null) : (color = color.*.next) if (!(strcmp(color.*.name, @ptrCast(@alignCast(&bf))) != 0)) break;
    }
    if (color != null) return color;
    {
        color = colors;
        while (color != null) : (color = color.*.next) if (!(strcmp(color.*.name, name) != 0)) break;
    }
    return color;
}
pub fn parse_syntax_color_def(arg_color_list: [*c][*c]struct_color_def, arg_p: [*c]const u8, arg_name: [*c]u8, arg_line: c_int) callconv(.c) void {
    var color_list = arg_color_list;
    _ = &color_list;
    var p = arg_p;
    _ = &p;
    var name = arg_name;
    _ = &name;
    var line = arg_line;
    _ = &line;
    var bf: [256]u8 = undefined;
    _ = &bf;
    if (!(parse_tows(&p, @ptrCast(@alignCast(&bf))) != 0)) {
        var color: [*c]struct_color_def = undefined;
        _ = &color;
        color = find_color(color_list.*, @ptrCast(@alignCast(&bf)), name);
        if (!(color != null)) {
            color = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_color_def))))))));
            color.*.name = atom_add(@ptrCast(@alignCast(&bf)));
            color.*.next = color_list.*;
            color_list.* = color;
        } else {
            _ = snprintf(i_msg, 128, my_gettext("%s %d: Class already defined\n"), name, line);
            internal_msg(i_msg);
            setlogerrs();
        }
        _ = parse_color_def(&p, color);
        _ = memcpy(@ptrCast(@alignCast(&color.*.orig)), @ptrCast(@alignCast(&color.*.spec)), @sizeOf(struct_color_spec));
    } else {
        _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing class name\n"), name, line);
        internal_msg(i_msg);
        setlogerrs();
    }
}
pub export fn dump_syntax(arg_bw_1: [*c]BW) void {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var syntax: [*c]struct_high_syntax = undefined;
    _ = &syntax;
    var params: [*c]struct_high_param = undefined;
    _ = &params;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "Allocated %d state stack frames\n", stack_count);
    _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
    _ = pnextl(bw_1.*.cursor);
    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "Allocated %d delimiter buffer stack frames\n", delim_stack_count);
    _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
    _ = pnextl(bw_1.*.cursor);
    {
        syntax = syntax_list;
        while (syntax != null) : (syntax = syntax.*.next) {
            var x: c_int = undefined;
            _ = &x;
            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "Syntax name=%s, subr=%s, nstates=%d\n", syntax.*.name, syntax.*.subr, @as(c_int, @truncate(syntax.*.nstates)));
            _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
            _ = pnextl(bw_1.*.cursor);
            _ = zlcpy(@ptrCast(@alignCast(&buf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))), "params=(");
            {
                params = syntax.*.params;
                while (params != null) : (params = params.*.next) {
                    _ = zlcat(@ptrCast(@alignCast(&buf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))), " ");
                    _ = zlcat(@ptrCast(@alignCast(&buf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))), params.*.name);
                }
            }
            _ = zlcat(@ptrCast(@alignCast(&buf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))), " )\n");
            _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
            _ = pnextl(bw_1.*.cursor);
            {
                x = 0;
                while (@as(ptrdiff_t, x) != syntax.*.nstates) : (x += 1) {
                    var s: [*c]struct_high_state = syntax.*.states[@bitCast(@as(isize, @intCast(x)))];
                    _ = &s;
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "   state %s %x\n", state_names[@bitCast(@as(isize, @intCast(s.*.name)))], s.*.color);
                    _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
                    _ = pnextl(bw_1.*.cursor);
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "     default -> %s %d\n", if (s.*.dflt.*.new_state != null) state_names[@bitCast(@as(isize, @intCast(s.*.dflt.*.new_state.*.name)))] else @as([*c]const u8, @ptrCast(@alignCast(@constCast("ERROR! Unknown state!")))), @as(c_int, @truncate(s.*.dflt.*.recolor)));
                    _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
                    _ = pnextl(bw_1.*.cursor);
                }
            }
        }
    }
}
pub fn parse_params(arg_current_params: [*c]struct_high_param, arg_ptr: [*c][*c]const u8, arg_name: [*c]u8, arg_line: c_int) callconv(.c) [*c]struct_high_param {
    var current_params = arg_current_params;
    _ = &current_params;
    var ptr = arg_ptr;
    _ = &ptr;
    var name = arg_name;
    _ = &name;
    var line = arg_line;
    _ = &line;
    var p: [*c]const u8 = ptr.*;
    _ = &p;
    var bf: [256]u8 = undefined;
    _ = &bf;
    var params: [*c]struct_high_param = undefined;
    _ = &params;
    var param_ptr: [*c][*c]struct_high_param = undefined;
    _ = &param_ptr;
    param_ptr = &params;
    while (current_params != null) {
        param_ptr.* = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_high_param))))))));
        param_ptr.*.*.name = zdup(current_params.*.name);
        param_ptr = &param_ptr.*.*.next;
        current_params = current_params.*.next;
    }
    param_ptr.* = null;
    _ = parse_ws(&p, '#');
    if (!(parse_char(&p, '(') != 0)) {
        while (true) {
            _ = parse_ws(&p, '#');
            if (!(parse_char(&p, ')') != 0)) break else if (!(parse_char(&p, '-') != 0)) {
                if (!(parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0)) {
                    var cmp: c_int = 0;
                    _ = &cmp;
                    param_ptr = &params;
                    while ((param_ptr.* != null) and ((blk: {
                        const tmp = strcmp(@ptrCast(@alignCast(&bf)), param_ptr.*.*.name);
                        cmp = tmp;
                        break :blk tmp;
                    }) > @as(c_int, 0))) {
                        param_ptr = &param_ptr.*.*.next;
                    }
                    if ((param_ptr.* != null) and !(cmp != 0)) {
                        var param: [*c]struct_high_param = param_ptr.*;
                        _ = &param;
                        param_ptr.* = param.*.next;
                        joe_free(@ptrCast(@alignCast(param)));
                    }
                } else {
                    _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing parameter name\n"), name, line);
                    internal_msg(i_msg);
                    setlogerrs();
                }
            } else if (!(parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0)) {
                var cmp: c_int = 0;
                _ = &cmp;
                param_ptr = &params;
                while ((param_ptr.* != null) and ((blk: {
                    const tmp = strcmp(@ptrCast(@alignCast(&bf)), param_ptr.*.*.name);
                    cmp = tmp;
                    break :blk tmp;
                }) > @as(c_int, 0))) {
                    param_ptr = &param_ptr.*.*.next;
                }
                if (!(param_ptr.* != null) or (cmp != 0)) {
                    var param: [*c]struct_high_param = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_high_param))))))));
                    _ = &param;
                    param.*.name = zdup(@ptrCast(@alignCast(&bf)));
                    param.*.next = param_ptr.*;
                    param_ptr.* = param;
                }
            } else {
                _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing )\n"), name, line);
                internal_msg(i_msg);
                setlogerrs();
                break;
            }
        }
    }
    ptr.* = p;
    return params;
}
pub export fn load_syntax_subr(arg_name: [*c]const u8, arg_subr: [*c]u8, arg_params: [*c]struct_high_param) [*c]struct_high_syntax {
    var name = arg_name;
    _ = &name;
    var subr = arg_subr;
    _ = &subr;
    var params = arg_params;
    _ = &params;
    var syntax: [*c]struct_high_syntax = undefined;
    _ = &syntax;
    {
        syntax = syntax_list;
        while (syntax != null) : (syntax = syntax.*.next) if (syntax_match(syntax, name, subr, params) != 0) return syntax;
    }
    syntax = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_high_syntax))))))));
    syntax.*.name = zdup(name);
    syntax.*.subr = if (subr != null) zdup(subr) else @as([*c]u8, null);
    syntax.*.params = params;
    syntax.*.next = syntax_list;
    syntax.*.nstates = 0;
    syntax.*.color = null;
    syntax.*.states = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]struct_high_state))))) * (blk: {
        const tmp = @as(ptrdiff_t, 64);
        syntax.*.szstates = tmp;
        break :blk tmp;
    }))));
    syntax.*.ht_states = htmk(syntax.*.szstates);
    iz_cmd(&syntax.*.default_cmd);
    syntax.*.default_cmd.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 14));
    syntax.*.stack_base = null;
    syntax.*.delim_stack_base = null;
    syntax_list = syntax;
    if (load_dfa(syntax) != null) {
        resolve_syntax_colors(curschemeset, syntax);
        return syntax;
    } else {
        if (syntax_list == syntax) {
            syntax_list = syntax_list.*.next;
        } else {
            var syn: [*c]struct_high_syntax = undefined;
            _ = &syn;
            {
                syn = syntax_list;
                while (syn.*.next != syntax) : (syn = syn.*.next) {}
            }
            syn.*.next = syntax.*.next;
        }
        htrm(syntax.*.ht_states);
        joe_free(@ptrCast(@alignCast(syntax.*.name)));
        joe_free(@ptrCast(@alignCast(syntax.*.states)));
        joe_free(@ptrCast(@alignCast(syntax)));
        return null;
    }
    return undefined;
}
pub fn parse_options(arg_syntax: [*c]struct_high_syntax, arg_cmd: [*c]struct_high_cmd, arg_f: [*c]JFILE, arg_p: [*c]const u8, arg_parsing_strings: c_int, arg_name: [*c]u8, arg_line: c_int) callconv(.c) c_int {
    var syntax = arg_syntax;
    _ = &syntax;
    var cmd = arg_cmd;
    _ = &cmd;
    var f = arg_f;
    _ = &f;
    var p = arg_p;
    _ = &p;
    var parsing_strings = arg_parsing_strings;
    _ = &parsing_strings;
    var name = arg_name;
    _ = &name;
    var line = arg_line;
    _ = &line;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    var bf: [256]u8 = undefined;
    _ = &bf;
    var bf1: [256]u8 = undefined;
    _ = &bf1;
    while ((blk: {
        _ = parse_ws(&p, '#');
        break :blk @intFromBool(!(parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0));
    }) != 0) if (!(strcmp(@ptrCast(@alignCast(&bf)), "buffer") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 1));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "hold") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 2));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "save_c") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 3));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "save_s") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 4));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "push_c") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 5));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "push_s") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 6));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "pop_c") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 7));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "pop_s") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 8));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "recolor") != 0)) {
        _ = parse_ws(&p, '#');
        if (!(parse_char(&p, '=') != 0)) {
            _ = parse_ws(&p, '#');
            if (parse_diff(&p, &cmd.*.recolor) != 0) {
                _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing value for option\n"), name, line);
                internal_msg(i_msg);
                setlogerrs();
            }
        } else {
            _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing value for option\n"), name, line);
            internal_msg(i_msg);
            setlogerrs();
        }
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "call") != 0)) {
        _ = parse_ws(&p, '#');
        if (!(parse_char(&p, '=') != 0)) {
            _ = parse_ws(&p, '#');
            if (!(parse_char(&p, '.') != 0)) {
                _ = zlcpy(@ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))), syntax.*.name);
                if (parse_ident(&p, @ptrCast(@alignCast(&bf1)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf1))))))) != 0) {
                    _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing subroutine name\n"), name, line);
                    internal_msg(i_msg);
                    setlogerrs();
                } else {
                    cmd.*.call = load_syntax_subr(@ptrCast(@alignCast(&bf)), @ptrCast(@alignCast(&bf1)), parse_params(syntax.*.params, &p, name, line));
                }
            } else if (parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0) {
                _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing value for option\n"), name, line);
                internal_msg(i_msg);
                setlogerrs();
            } else {
                if (!(parse_char(&p, '.') != 0)) {
                    if (parse_ident(&p, @ptrCast(@alignCast(&bf1)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf1))))))) != 0) {
                        _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing subroutine name\n"), name, line);
                        internal_msg(i_msg);
                        setlogerrs();
                    } else {
                        cmd.*.call = load_syntax_subr(@ptrCast(@alignCast(&bf)), @ptrCast(@alignCast(&bf1)), parse_params(syntax.*.params, &p, name, line));
                    }
                } else {
                    cmd.*.call = load_syntax_subr(@ptrCast(@alignCast(&bf)), null, parse_params(syntax.*.params, &p, name, line));
                }
            }
        } else {
            _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing value for option\n"), name, line);
            internal_msg(i_msg);
            setlogerrs();
        }
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "return") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 13));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "reset") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 14));
    } else if (!(parsing_strings != 0) and (!(strcmp(@ptrCast(@alignCast(&bf)), "strings") != 0) or !(strcmp(@ptrCast(@alignCast(&bf)), "istrings") != 0))) {
        if (@as(c_int, bf[@as(c_int, 0)]) == @as(c_int, 'i')) {
            cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 9));
        }
        while (jfgets(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_uint, @truncate(@sizeOf(@TypeOf(buf))))), f) != null) {
            line += 1;
            p = @ptrCast(@alignCast(&buf));
            _ = parse_ws(&p, '#');
            if (@as(c_int, p.*) != 0) {
                var kwbuf: [256]c_int = undefined;
                _ = &kwbuf;
                var lkwbuf: [768]c_int = undefined;
                _ = &lkwbuf;
                if (!(parse_field(&p, "done") != 0)) break;
                if (parse_Zstring(&p, @ptrCast(@alignCast(&kwbuf)), @divTrunc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(kwbuf)))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(kwbuf[@as(c_int, 0)])))))))) >= @as(ptrdiff_t, 0)) {
                    _ = parse_ws(&p, '#');
                    if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 9)))) != 0) {
                        _ = lowerize(@ptrCast(@alignCast(&lkwbuf)), @divTrunc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(lkwbuf)))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(lkwbuf[@as(c_int, 0)]))))))), @ptrCast(@alignCast(&kwbuf)));
                    }
                    if (!(parse_ident(&p, @ptrCast(@alignCast(&bf1)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf1))))))) != 0)) {
                        var kw_cmd: [*c]struct_high_cmd = mkcmd();
                        _ = &kw_cmd;
                        kw_cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 0));
                        kw_cmd.*.new_state = find_state(syntax, @ptrCast(@alignCast(&bf1)));
                        if ((kwbuf[@as(c_int, 0)] == @as(c_int, '&')) and !(kwbuf[@as(c_int, 1)] != 0)) {
                            cmd.*.delim = kw_cmd;
                        } else {
                            if (!(cmd.*.keywords != null)) {
                                cmd.*.keywords = Zhtmk(64);
                            }
                            _ = Zhtadd(cmd.*.keywords, if ((cmd.*.flags & (@as(c_uint, 1) << @intCast(@as(c_uint, 9)))) != 0) Zdup(@ptrCast(@alignCast(&lkwbuf))) else Zdup(@ptrCast(@alignCast(&kwbuf))), @ptrCast(@alignCast(kw_cmd)));
                        }
                        line = parse_options(syntax, kw_cmd, f, p, 1, name, line);
                    } else {
                        _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing state name\n"), name, line);
                        internal_msg(i_msg);
                        setlogerrs();
                    }
                } else {
                    _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing string\n"), name, line);
                    internal_msg(i_msg);
                    setlogerrs();
                }
            }
        }
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "noeat") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 0));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "mark") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 10));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "markend") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 11));
    } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "recolormark") != 0)) {
        cmd.*.flags |= @as(c_uint, 1) << @intCast(@as(c_uint, 12));
    } else {
        _ = snprintf(i_msg, 128, my_gettext("%s %d: Unknown option\n"), name, line);
        internal_msg(i_msg);
        setlogerrs();
    };
    return line;
}
pub const struct_ifstack = extern struct {
    next: [*c]struct_ifstack = null,
    ignore: c_int = 0,
    skip: c_int = 0,
    else_part: c_int = 0,
    line: c_int = 0,
};
pub fn load_dfa(arg_syntax: [*c]struct_high_syntax) callconv(.c) [*c]struct_high_state {
    var syntax = arg_syntax;
    _ = &syntax;
    var fullpath: [*c]u8 = null;
    _ = &fullpath;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    var bf: [256]u8 = undefined;
    _ = &bf;
    var p: [*c]const u8 = undefined;
    _ = &p;
    var c: ptrdiff_t = undefined;
    _ = &c;
    var f: [*c]JFILE = null;
    _ = &f;
    var stack: [*c]struct_ifstack = null;
    _ = &stack;
    var state: [*c]struct_high_state = null;
    _ = &state;
    var first: [*c]struct_high_state = null;
    _ = &first;
    var line: c_int = 0;
    _ = &line;
    var this_one: c_int = 0;
    _ = &this_one;
    var inside_subr: c_int = 0;
    _ = &inside_subr;
    fullpath = open_config_file(&f, "syntax/", syntax.*.name, ".jsf");
    if (!(fullpath != null)) return null;
    while (jfgets(@ptrCast(@alignCast(&buf)), @truncate(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf))))))), f) != null) {
        line += 1;
        p = @ptrCast(@alignCast(&buf));
        c = parse_ws(&p, '#');
        if (!(parse_char(&p, '.') != 0)) {
            if (!(parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0)) {
                if (!(strcmp(@ptrCast(@alignCast(&bf)), "ifdef") != 0)) {
                    var st: [*c]struct_ifstack = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_ifstack))))))));
                    _ = &st;
                    st.*.next = stack;
                    st.*.else_part = 0;
                    st.*.ignore = 1;
                    st.*.skip = 1;
                    st.*.line = line;
                    if (!(stack != null) or !(stack.*.ignore != 0)) {
                        _ = parse_ws(&p, '#');
                        if (!(parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0)) {
                            var param: [*c]struct_high_param = undefined;
                            _ = &param;
                            {
                                param = syntax.*.params;
                                while (param != null) : (param = param.*.next) if (!(strcmp(param.*.name, @ptrCast(@alignCast(&bf))) != 0)) {
                                    st.*.ignore = 0;
                                    break;
                                };
                            }
                            st.*.skip = 0;
                        } else {
                            _ = snprintf(i_msg, 128, my_gettext("%s %d: missing parameter for ifdef\n"), fullpath, line);
                            internal_msg(i_msg);
                            setlogerrs();
                        }
                    }
                    stack = st;
                } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "else") != 0)) {
                    if ((stack != null) and !(stack.*.else_part != 0)) {
                        stack.*.else_part = 1;
                        if (!(stack.*.skip != 0)) {
                            stack.*.ignore = @intFromBool(!(stack.*.ignore != 0));
                        }
                    } else {
                        _ = snprintf(i_msg, 128, my_gettext("%s %d: else with no matching if\n"), fullpath, line);
                        internal_msg(i_msg);
                        setlogerrs();
                    }
                } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "endif") != 0)) {
                    if (stack != null) {
                        var st: [*c]struct_ifstack = stack;
                        _ = &st;
                        stack = st.*.next;
                        joe_free(@ptrCast(@alignCast(st)));
                    } else {
                        _ = snprintf(i_msg, 128, my_gettext("%s %d: endif with no matching if\n"), fullpath, line);
                        internal_msg(i_msg);
                        setlogerrs();
                    }
                } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "subr") != 0)) {
                    _ = parse_ws(&p, '#');
                    if (parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0) {
                        _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing subroutine name\n"), fullpath, line);
                        internal_msg(i_msg);
                        setlogerrs();
                    } else {
                        if (!(stack != null) or !(stack.*.ignore != 0)) {
                            inside_subr = 1;
                            this_one = 0;
                            if ((syntax.*.subr != null) and !(strcmp(@ptrCast(@alignCast(&bf)), syntax.*.subr) != 0)) {
                                this_one = 1;
                            }
                        }
                    }
                } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "end") != 0)) {
                    if (!(stack != null) or !(stack.*.ignore != 0)) {
                        this_one = 0;
                        inside_subr = 0;
                    }
                } else {
                    _ = snprintf(i_msg, 128, my_gettext("%s %d: Unknown control statement\n"), fullpath, line);
                    internal_msg(i_msg);
                    setlogerrs();
                }
            } else {
                _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing control statement name\n"), fullpath, line);
                internal_msg(i_msg);
                setlogerrs();
            }
        } else if ((stack != null) and (stack.*.ignore != 0)) {} else if (!(parse_char(&p, '=') != 0)) {
            parse_syntax_color_def(&syntax.*.color, p, fullpath, line);
        } else if (((syntax.*.subr != null) and !(this_one != 0)) or (!(syntax.*.subr != null) and (inside_subr != 0))) {} else if (!(parse_char(&p, ':') != 0)) {
            if (!(parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0)) {
                state = find_state(syntax, @ptrCast(@alignCast(&bf)));
                if (!(first != null)) {
                    first = state;
                }
                _ = parse_ws(&p, '#');
                if (!(parse_tows(&p, @ptrCast(@alignCast(&bf))) != 0)) {
                    var color: [*c]struct_color_def = undefined;
                    _ = &color;
                    {
                        color = syntax.*.color;
                        while (color != null) : (color = color.*.next) if (!(strcmp(color.*.name, @ptrCast(@alignCast(&bf))) != 0)) break;
                    }
                    if (!(color != null)) {
                        _ = snprintf(i_msg, 128, my_gettext("%s %d: Unknown class\n"), fullpath, line);
                        internal_msg(i_msg);
                        setlogerrs();
                    }
                    state.*.color = 0;
                    state.*.colorp = color;
                    while ((blk: {
                        _ = parse_ws(&p, '#');
                        break :blk @intFromBool(!(parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0));
                    }) != 0) {
                        if (!(strcmp(@ptrCast(@alignCast(&bf)), "comment") != 0)) {
                            state.*.color |= CONTEXT_COMMENT;
                        } else if (!(strcmp(@ptrCast(@alignCast(&bf)), "string") != 0)) {
                            state.*.color |= CONTEXT_STRING;
                        } else {
                            _ = snprintf(i_msg, 128, my_gettext("%s %d: Unknown context\n"), fullpath, line);
                            internal_msg(i_msg);
                            setlogerrs();
                        }
                    }
                } else {
                    _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing color for state definition\n"), fullpath, line);
                    internal_msg(i_msg);
                    setlogerrs();
                }
            } else {
                _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing state name\n"), fullpath, line);
                internal_msg(i_msg);
                setlogerrs();
            }
        } else if (!(parse_char(&p, '-') != 0)) {} else {
            c = parse_ws(&p, '#');
            if (!(c != 0)) {} else if ((((c == @as(ptrdiff_t, '"')) or (c == @as(ptrdiff_t, '*'))) or (c == @as(ptrdiff_t, '&'))) or (c == @as(ptrdiff_t, '%'))) {
                if (state != null) {
                    var cmd: [*c]struct_high_cmd = mkcmd();
                    _ = &cmd;
                    if (!(parse_field(&p, "*") != 0)) {
                        state.*.dflt = cmd;
                    } else if (!(parse_field(&p, "&") != 0)) {
                        state.*.delim = cmd;
                    } else if (!(parse_field(&p, "%") != 0)) {
                        state.*.same_delim = cmd;
                    } else {
                        var array: [*c]struct_interval = undefined;
                        _ = &array;
                        var size: ptrdiff_t = undefined;
                        _ = &size;
                        p += 1;
                        while ((@as(c_int, p.*) != @as(c_int, '"')) and !(parse_class(&p, &array, &size) != 0)) {
                            rtree_set(&state.*.rtree, array, size, @ptrCast(@alignCast(cmd)));
                        }
                        if (@as(c_int, p.*) != @as(c_int, '"')) {
                            _ = snprintf(i_msg, 128, my_gettext("%s %d: Bad string\n"), fullpath, line);
                            internal_msg(i_msg);
                            setlogerrs();
                        } else {
                            p += 1;
                        }
                    }
                    _ = parse_ws(&p, '#');
                    if (!(parse_ident(&p, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf))))))) != 0)) {
                        cmd.*.new_state = find_state(syntax, @ptrCast(@alignCast(&bf)));
                        line = parse_options(syntax, cmd, f, p, 0, fullpath, line);
                    } else {
                        _ = snprintf(i_msg, 128, my_gettext("%s %d: Missing jump\n"), fullpath, line);
                        internal_msg(i_msg);
                        setlogerrs();
                    }
                } else {
                    _ = snprintf(i_msg, 128, my_gettext("%s %d: No state\n"), fullpath, line);
                    internal_msg(i_msg);
                    setlogerrs();
                }
            } else {
                _ = snprintf(i_msg, 128, my_gettext("%s %d: Unknown character\n"), fullpath, line);
                internal_msg(i_msg);
                setlogerrs();
            }
        }
    }
    while (stack != null) {
        var st: [*c]struct_ifstack = stack;
        _ = &st;
        stack = st.*.next;
        _ = snprintf(i_msg, 128, my_gettext("%s %d: ifdef with no matching endif\n"), fullpath, st.*.line);
        internal_msg(i_msg);
        setlogerrs();
        joe_free(@ptrCast(@alignCast(st)));
    }
    _ = jfclose(f);
    build_cmaps(syntax);
    vsrm(fullpath);
    return first;
}
pub fn syntax_match(arg_syntax: [*c]struct_high_syntax, arg_name: [*c]const u8, arg_subr: [*c]const u8, arg_params: [*c]struct_high_param) callconv(.c) c_int {
    var syntax = arg_syntax;
    _ = &syntax;
    var name = arg_name;
    _ = &name;
    var subr = arg_subr;
    _ = &subr;
    var params = arg_params;
    _ = &params;
    var syntax_params: [*c]struct_high_param = undefined;
    _ = &syntax_params;
    if (strcmp(syntax.*.name, name) != 0) return 0;
    if ((@intFromBool(!(syntax.*.subr != null)) ^ @intFromBool(!(subr != null))) != 0) return 0;
    if ((subr != null) and (strcmp(syntax.*.subr, subr) != 0)) return 0;
    syntax_params = syntax.*.params;
    while ((syntax_params != null) and (params != null)) {
        if (strcmp(syntax_params.*.name, params.*.name) != 0) return 0;
        syntax_params = syntax_params.*.next;
        params = params.*.next;
    }
    return @intFromBool(syntax_params == params);
}
pub export fn load_syntax(arg_name: [*c]const u8) [*c]struct_high_syntax {
    var name = arg_name;
    _ = &name;
    if (!(ansi_syntax != null)) {
        ansi_syntax = @ptrCast(@alignCast(joe_calloc(1, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_high_syntax))))))));
        ansi_syntax.*.name = zdup("ansi");
    }
    if (!(name != null)) return null;
    if (!(strcmp(name, "ansi") != 0)) return ansi_syntax;
    return load_syntax_subr(name, null, null);
}


comptime {
    if (@sizeOf(struct_high_cmd) != 48) @compileError("high_cmd size mismatch");
    if (@sizeOf(struct_high_state) != 296) @compileError("high_state size mismatch");
    if (@sizeOf(struct_high_syntax) != 136) @compileError("high_syntax size mismatch");
    if (@sizeOf(HIGHLIGHT_STATE) != 32) @compileError("HIGHLIGHT_STATE size mismatch");
    if (@sizeOf(struct_high_frame) != 40) @compileError("high_frame size mismatch");
    if (@sizeOf(struct_high_delim_frame) != 32) @compileError("high_delim_frame size mismatch");
    if (@sizeOf(struct_Rtree) != 248) @compileError("Rtree size mismatch");
    if (@sizeOf(HASH) != 24) @compileError("HASH size mismatch");
    if (@sizeOf(struct_color_def) != 72) @compileError("color_def size mismatch");
    if (@sizeOf(COLORSET) != 368) @compileError("COLORSET size mismatch");
    if (@sizeOf(OPTIONS) != 344) @compileError("OPTIONS size mismatch");
    if (@sizeOf(B) != 632) @compileError("B size mismatch");
    if (@sizeOf(P) != 112) @compileError("P size mismatch");
    if (@sizeOf(BW) != 488) @compileError("BW size mismatch");
}
