//! Regular expression engine — replaces `joe/regex.c`.
//!
//! Faithful C-ABI port of JOE's NFA regex compiler/matcher.
//! Generated from a goto-free rewrite of regex.c via `zig translate-c`,
//! then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;
const off_t = i64;
const FOLDMAGIC: c_int = 0x4000000;
const NO_MORE_DATA: c_int = -256;
const MAX_MATCHES: c_int = 10;
const MAX_THREADS: c_int = 50;
const STACK_SIZE: c_int = 8;

pub const struct_interval = extern struct {
    first: c_int = 0,
    last: c_int = 0,
};
const union_unnamed_3 = extern union {
    b: ?*anyopaque,
    c: ?*anyopaque,
    d: ?*anyopaque,
    e: ?*anyopaque,
};
pub const struct_Level = extern struct {
    alloc: c_int = 0,
    size: c_int = 0,
    table: union_unnamed_3 = @import("std").mem.zeroes(union_unnamed_3),
};
pub const struct_Rset = extern struct {
    top: [68]c_short = @import("std").mem.zeroes([68]c_short),
    second: struct_Level = @import("std").mem.zeroes(struct_Level),
    mid: [32]c_short = @import("std").mem.zeroes([32]c_short),
    third: struct_Level = @import("std").mem.zeroes(struct_Level),
};
pub const struct_Cclass = extern struct {
    size: ptrdiff_t = 0,
    len: ptrdiff_t = 0,
    intervals: [*c]struct_interval = null,
    rset: [1]struct_Rset = @import("std").mem.zeroes([1]struct_Rset),
};
pub const Cclass = struct_Cclass;
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
pub const charmap = struct_charmap;
pub const struct_Frag = extern struct {
    start: [*c]u8 = null,
    len: ptrdiff_t = 0,
    size: ptrdiff_t = 0,
    @"align": ptrdiff_t = 0,
};
pub const Frag = struct_Frag;
const P = @import("gapbuffer/types.zig").P;
pub const struct_Rtree = extern struct {
    top: [68]c_short = @import("std").mem.zeroes([68]c_short),
    second: struct_Level = @import("std").mem.zeroes(struct_Level),
    mid: [32]c_short = @import("std").mem.zeroes([32]c_short),
    third: struct_Level = @import("std").mem.zeroes(struct_Level),
    leaf: struct_Level = @import("std").mem.zeroes(struct_Level),
};
pub const Rtree = struct_Rtree;
pub const interval = struct_interval;
pub const struct_regmatch = extern struct {
    rm_so: off_t = 0,
    rm_eo: off_t = 0,
};
pub const Regmatch_t = struct_regmatch;
pub const iDOT: c_int = -512;
pub const iEXPR: c_int = -511;
pub const iBOL: c_int = -510;
pub const iEOL: c_int = -509;
pub const iBOW: c_int = -508;
pub const iEOW: c_int = -507;
pub const iBRA: c_int = -506;
pub const iKET: c_int = -505;
pub const iFORK: c_int = -504;
pub const iJUMP: c_int = -503;
pub const iCLASS: c_int = -502;
pub const iEND: c_int = -501;
const enum_unnamed_4 = c_int;
pub const struct_node = extern struct {
    @"type": c_int = 0,
    r: c_int = 0,
    l: c_int = 0,
    cclass: [1]struct_Cclass = @import("std").mem.zeroes([1]struct_Cclass),
};
pub const struct_regcomp = extern struct {
    ptr: [*c]const u8 = null,
    l: ptrdiff_t = 0,
    cmap: [*c]struct_charmap = null,
    nodes: [*c]struct_node = null,
    len: c_int = 0,
    size: c_int = 0,
    prefix: [*c]u8 = null,
    prefix_len: ptrdiff_t = 0,
    prefix_size: ptrdiff_t = 0,
    bra_no: c_int = 0,
    frag: [1]Frag = @import("std").mem.zeroes([1]Frag),
    err: [*c]const u8 = null,
};

comptime {
    if (@sizeOf(struct_Cclass) != 256) @compileError("Cclass size mismatch");
    if (@sizeOf(struct_node) != 272) @compileError("node size mismatch");
    if (@sizeOf(struct_regcomp) != 112) @compileError("regcomp size mismatch");
    if (@sizeOf(Frag) != 32) @compileError("Frag size mismatch");
    if (@sizeOf(Regmatch_t) != 16) @compileError("Regmatch size mismatch");
    if (@sizeOf(P) != 112) @compileError("P size mismatch");
}

pub extern fn joe_malloc(ptrdiff_t) ?*anyopaque;
pub extern fn joe_realloc(?*anyopaque, ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(?*anyopaque) void;
pub extern fn cclass_init([*c]Cclass) void;
pub extern fn cclass_add([*c]Cclass, c_int, c_int) void;
pub extern fn cclass_union([*c]Cclass, [*c]Cclass) void;
pub extern fn cclass_inv([*c]Cclass) void;
pub extern fn cclass_opt([*c]Cclass) void;
pub extern fn cclass_lookup([*c]Cclass, c_int) c_int;
pub extern fn cclass_show([*c]Cclass) void;
pub extern fn cclass_remap([*c]Cclass, [*c]charmap) [*c]Cclass;
pub extern fn unicode([*c]const u8) [*c]Cclass;
pub extern fn utf8_decode_fwrd([*c][*c]const u8, [*c]ptrdiff_t) c_int;
pub extern fn utf8_encode([*c]u8, c_int) ptrdiff_t;
pub extern fn rmap_lookup([*c]Rtree, c_int, c_int) c_int;
pub extern fn iz_frag([*c]Frag, ptrdiff_t) void;
pub extern fn fin_code([*c]Frag) void;
pub extern fn clr_frag([*c]Frag) void;
pub extern fn emiti([*c]Frag, c_int) ptrdiff_t;
pub extern fn emitp([*c]Frag, ?*anyopaque) ptrdiff_t;
pub extern fn emit_branch([*c]Frag, ptrdiff_t) ptrdiff_t;
pub extern fn fixup_branch([*c]Frag, ptrdiff_t) void;
pub extern fn frag_link([*c]Frag, ptrdiff_t) void;
pub extern fn align_frag([*c]Frag, ptrdiff_t) void;
pub extern fn fetchi([*c]Frag, [*c]ptrdiff_t) c_int;
pub extern fn fetchp([*c]Frag, [*c]ptrdiff_t) ?*anyopaque;
pub extern fn pgetc([*c]P) c_int;
pub extern fn prgetc([*c]P) c_int;
pub extern fn pisbol([*c]P) c_int;
pub extern fn memcmp(a: ?*const anyopaque, b: ?*const anyopaque, n: usize) c_int;
pub extern fn printf(fmt: [*:0]const u8, ...) c_int;
pub extern fn exit(code: c_int) noreturn;
pub extern var cclass_alpha_: Cclass;
pub extern var cclass_notalpha_: Cclass;
pub extern var cclass_alnum_: Cclass;
pub extern var cclass_notalnum_: Cclass;
pub extern var cclass_word: Cclass;
pub extern var cclass_notword: Cclass;
pub extern var cclass_space: Cclass;
pub extern var cclass_notspace: Cclass;
pub extern var cclass_digit: Cclass;
pub extern var cclass_notdigit: Cclass;
pub extern var rtree_fold: Rtree;
pub const fold_repl: [*c][3]c_int = @extern([*c][3]c_int, .{
    .name = "fold_repl",
});
pub export fn escape(arg_utf8: c_int, arg_a: [*c][*c]const u8, arg_b: [*c]ptrdiff_t, arg_cat: [*c][*c]struct_Cclass) c_int {
    var utf8 = arg_utf8;
    _ = &utf8;
    var a = arg_a;
    _ = &a;
    var b = arg_b;
    _ = &b;
    var cat = arg_cat;
    _ = &cat;
    var c: c_int = 0;
    _ = &c;
    var s: [*c]const u8 = a.*;
    _ = &s;
    var l: ptrdiff_t = undefined;
    _ = &l;
    if (cat != null) {
        cat.* = null;
    }
    if (b != null) {
        l = b.*;
    } else {
        l = -@as(c_int, 1);
    }
    if (((if (b != null) @intFromBool(l >= @as(ptrdiff_t, 2)) else @as(c_int, s[@as(c_int, 1)])) != 0) and (@as(c_int, s.*) == @as(c_int, '\\'))) {
        s += 1;
        l -= 1;
        while (true) {
            switch (@as(c_int, s.*)) {
                @as(c_int, 'i') => {
                    {
                        s += 1;
                        l -= 1;
                        c = -@as(c_int, 256);
                        if (cat != null) {
                            cat.* = @ptrCast(@alignCast(&cclass_alpha_));
                        }
                        break;
                    }
                },
                @as(c_int, 'I') => {
                    {
                        s += 1;
                        l -= 1;
                        c = -@as(c_int, 256);
                        if (cat != null) {
                            cat.* = @ptrCast(@alignCast(&cclass_notalpha_));
                        }
                        break;
                    }
                },
                @as(c_int, 'c') => {
                    {
                        s += 1;
                        l -= 1;
                        c = -@as(c_int, 256);
                        if (cat != null) {
                            cat.* = @ptrCast(@alignCast(&cclass_alnum_));
                        }
                        break;
                    }
                },
                @as(c_int, 'C') => {
                    {
                        s += 1;
                        l -= 1;
                        c = -@as(c_int, 256);
                        if (cat != null) {
                            cat.* = @ptrCast(@alignCast(&cclass_notalnum_));
                        }
                        break;
                    }
                },
                @as(c_int, 'w') => {
                    {
                        s += 1;
                        l -= 1;
                        c = -@as(c_int, 256);
                        if (cat != null) {
                            cat.* = @ptrCast(@alignCast(&cclass_word));
                        }
                        break;
                    }
                },
                @as(c_int, 'W') => {
                    {
                        s += 1;
                        l -= 1;
                        c = -@as(c_int, 256);
                        if (cat != null) {
                            cat.* = @ptrCast(@alignCast(&cclass_notword));
                        }
                        break;
                    }
                },
                @as(c_int, 's') => {
                    {
                        s += 1;
                        l -= 1;
                        c = -@as(c_int, 256);
                        if (cat != null) {
                            cat.* = @ptrCast(@alignCast(&cclass_space));
                        }
                        break;
                    }
                },
                @as(c_int, 'S') => {
                    {
                        s += 1;
                        l -= 1;
                        c = -@as(c_int, 256);
                        if (cat != null) {
                            cat.* = @ptrCast(@alignCast(&cclass_notspace));
                        }
                        break;
                    }
                },
                @as(c_int, 'd') => {
                    {
                        s += 1;
                        l -= 1;
                        c = -@as(c_int, 256);
                        if (cat != null) {
                            cat.* = @ptrCast(@alignCast(&cclass_digit));
                        }
                        break;
                    }
                },
                @as(c_int, 'D') => {
                    {
                        s += 1;
                        l -= 1;
                        c = -@as(c_int, 256);
                        if (cat != null) {
                            cat.* = @ptrCast(@alignCast(&cclass_notdigit));
                        }
                        break;
                    }
                },
                @as(c_int, 'n') => {
                    {
                        c = 10;
                        s += 1;
                        l -= 1;
                        break;
                    }
                },
                @as(c_int, 't'), @as(c_int, '9') => {
                    {
                        c = 9;
                        s += 1;
                        l -= 1;
                        break;
                    }
                },
                @as(c_int, 'a') => {
                    {
                        c = 7;
                        s += 1;
                        l -= 1;
                        break;
                    }
                },
                @as(c_int, 'b'), @as(c_int, '8') => {
                    {
                        c = 8;
                        s += 1;
                        l -= 1;
                        break;
                    }
                },
                @as(c_int, 'f') => {
                    {
                        c = 12;
                        s += 1;
                        l -= 1;
                        break;
                    }
                },
                @as(c_int, 'e') => {
                    {
                        c = 27;
                        s += 1;
                        l -= 1;
                        break;
                    }
                },
                @as(c_int, 'r') => {
                    {
                        c = 13;
                        s += 1;
                        l -= 1;
                        break;
                    }
                },
                @as(c_int, '0'), @as(c_int, '1'), @as(c_int, '2'), @as(c_int, '3'), @as(c_int, '4'), @as(c_int, '5'), @as(c_int, '6'), @as(c_int, '7') => {
                    {
                        c = @as(c_int, s.*) - @as(c_int, '0');
                        s += 1;
                        l -= 1;
                        if (((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) >= @as(c_int, '0'))) and (@as(c_int, s.*) <= @as(c_int, '7'))) {
                            c = ((c * @as(c_int, 8)) + @as(c_int, s[@as(c_int, 1)])) - @as(c_int, '0');
                            s += 1;
                            l -= 1;
                        }
                        if (((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) >= @as(c_int, '0'))) and (@as(c_int, s.*) <= @as(c_int, '7'))) {
                            c = ((c * @as(c_int, 8)) + @as(c_int, s[@as(c_int, 1)])) - @as(c_int, '0');
                            s += 1;
                            l -= 1;
                        }
                        break;
                    }
                },
                @as(c_int, 'p') => {
                    {
                        s += 1;
                        l -= 1;
                        c = 'X';
                        if ((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) == @as(c_int, '{'))) {
                            var buf: [80]u8 = undefined;
                            _ = &buf;
                            var idx: ptrdiff_t = 0;
                            _ = &idx;
                            s += 1;
                            l -= 1;
                            while (((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) != 0)) and (@as(c_int, s.*) != @as(c_int, '}'))) {
                                if (idx != (@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))) - @as(ptrdiff_t, 1))) {
                                    buf[
                                        @bitCast(@as(isize, @intCast(blk: {
                                            const ref = &idx;
                                            const tmp = ref.*;
                                            ref.* += 1;
                                            break :blk tmp;
                                        })))
                                    ] = s.*;
                                }
                                s += 1;
                                l -= 1;
                            }
                            if ((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) == @as(c_int, '}'))) {
                                s += 1;
                                l -= 1;
                            }
                            buf[@bitCast(@as(isize, @intCast(idx)))] = 0;
                            c = -@as(c_int, 256);
                            if (cat != null) {
                                cat.* = unicode(@ptrCast(@alignCast(&buf)));
                            }
                        }
                        break;
                    }
                },
                @as(c_int, 'x'), @as(c_int, 'X') => {
                    {
                        c = 0;
                        s += 1;
                        l -= 1;
                        if ((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) == @as(c_int, '{'))) {
                            s += 1;
                            l -= 1;
                            while (!(b != null) or (l > @as(ptrdiff_t, 0))) {
                                if ((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
                                    c = ((c * @as(c_int, 16)) + @as(c_int, s.*)) - @as(c_int, '0');
                                    s += 1;
                                    l -= 1;
                                } else if ((@as(c_int, s.*) >= @as(c_int, 'A')) and (@as(c_int, s.*) <= @as(c_int, 'F'))) {
                                    c = (((c * @as(c_int, 16)) + @as(c_int, s.*)) - @as(c_int, 'A')) + @as(c_int, 10);
                                    s += 1;
                                    l -= 1;
                                } else if ((@as(c_int, s.*) >= @as(c_int, 'a')) and (@as(c_int, s.*) <= @as(c_int, 'f'))) {
                                    c = (((c * @as(c_int, 16)) + @as(c_int, s.*)) - @as(c_int, 'a')) + @as(c_int, 10);
                                    s += 1;
                                    l -= 1;
                                } else {
                                    break;
                                }
                            }
                            if ((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) == @as(c_int, '}'))) {
                                s += 1;
                                l -= 1;
                            }
                        } else {
                            if (((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) >= @as(c_int, '0'))) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
                                c = ((c * @as(c_int, 16)) + @as(c_int, s.*)) - @as(c_int, '0');
                                s += 1;
                                l -= 1;
                            } else if (((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) >= @as(c_int, 'A'))) and (@as(c_int, s.*) <= @as(c_int, 'F'))) {
                                c = (((c * @as(c_int, 16)) + @as(c_int, s.*)) - @as(c_int, 'A')) + @as(c_int, 10);
                                s += 1;
                                l -= 1;
                            } else if (((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) >= @as(c_int, 'a'))) and (@as(c_int, s.*) <= @as(c_int, 'f'))) {
                                c = (((c * @as(c_int, 16)) + @as(c_int, s.*)) - @as(c_int, 'a')) + @as(c_int, 10);
                                s += 1;
                                l -= 1;
                            }
                            if (((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) >= @as(c_int, '0'))) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
                                c = ((c * @as(c_int, 16)) + @as(c_int, s.*)) - @as(c_int, '0');
                                s += 1;
                                l -= 1;
                            } else if (((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) >= @as(c_int, 'A'))) and (@as(c_int, s.*) <= @as(c_int, 'F'))) {
                                c = (((c * @as(c_int, 16)) + @as(c_int, s.*)) - @as(c_int, 'A')) + @as(c_int, 10);
                                s += 1;
                                l -= 1;
                            } else if (((!(b != null) or (l > @as(ptrdiff_t, 0))) and (@as(c_int, s.*) >= @as(c_int, 'a'))) and (@as(c_int, s.*) <= @as(c_int, 'f'))) {
                                c = (((c * @as(c_int, 16)) + @as(c_int, s.*)) - @as(c_int, 'a')) + @as(c_int, 10);
                                s += 1;
                                l -= 1;
                            }
                        }
                        break;
                    }
                },
                else => {
                    {
                        if (utf8 != 0) {
                            c = utf8_decode_fwrd(&s, @ptrCast(@alignCast(if (b != null) @as(?*anyopaque, @ptrCast(@alignCast(&l))) else @as(?*anyopaque, null))));
                        } else {
                            c = @as([*c]const u8, @ptrCast(@alignCast(blk: {
                                const ref = &s;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            }))).*;
                            l -= 1;
                        }
                        break;
                    }
                },
            }
            break;
        }
    } else if (!(b != null) or (l > @as(ptrdiff_t, 0))) {
        if (utf8 != 0) {
            c = utf8_decode_fwrd(&s, @ptrCast(@alignCast(if (b != null) @as(?*anyopaque, @ptrCast(@alignCast(&l))) else @as(?*anyopaque, null))));
        } else {
            c = @as([*c]const u8, @ptrCast(@alignCast(blk: {
                const ref = &s;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }))).*;
            l -= 1;
        }
    }
    a.* = s;
    if (b != null) {
        b.* = l;
    }
    return c;
}
pub fn mk_node(arg_r: [*c]struct_regcomp, arg_ty: c_int, arg_nl: c_int, arg_nr: c_int) callconv(.c) c_int {
    var r = arg_r;
    _ = &r;
    var ty = arg_ty;
    _ = &ty;
    var nl = arg_nl;
    _ = &nl;
    var nr = arg_nr;
    _ = &nr;
    var no: c_int = undefined;
    _ = &no;
    if (r.*.len == r.*.size) {
        r.*.size *= 2;
        r.*.nodes = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(r.*.nodes)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_node))))) * @as(ptrdiff_t, r.*.size))));
    }
    no = blk: {
        const ref = &r.*.len;
        const tmp = ref.*;
        ref.* += 1;
        break :blk tmp;
    };
    r.*.nodes[@bitCast(@as(isize, @intCast(no)))].@"type" = ty;
    r.*.nodes[@bitCast(@as(isize, @intCast(no)))].r = nr;
    r.*.nodes[@bitCast(@as(isize, @intCast(no)))].l = nl;
    cclass_init(@ptrCast(@alignCast(&r.*.nodes[@bitCast(@as(isize, @intCast(no)))].cclass)));
    return no;
}
pub fn ind(arg_x: c_int) callconv(.c) void {
    var x = arg_x;
    _ = &x;
    while ((blk: {
        const ref = &x;
        const tmp = ref.*;
        ref.* -= 1;
        break :blk tmp;
    }) != 0) {
        _ = @as(c_int, 0);
    }
}
pub fn show(arg_r: [*c]struct_regcomp, arg_no: c_int, arg_x: c_int) callconv(.c) void {
    var r = arg_r;
    _ = &r;
    var no = arg_no;
    _ = &no;
    var x = arg_x;
    _ = &x;
    if (no != -@as(c_int, 1)) {
        if (r.*.nodes[@bitCast(@as(isize, @intCast(no)))].@"type" >= @as(c_int, 0)) {
            ind(x);
            _ = @as(c_int, 0);
        } else {
            ind(x);
            _ = @as(c_int, 0);
        }
        if (r.*.nodes[@bitCast(@as(isize, @intCast(no)))].@"type" == -@as(c_int, '[')) {
            ind(x + @as(c_int, 1));
            cclass_show(@ptrCast(@alignCast(&r.*.nodes[@bitCast(@as(isize, @intCast(no)))].cclass)));
        }
        show(r, r.*.nodes[@bitCast(@as(isize, @intCast(no)))].l, x + @as(c_int, 1));
        show(r, r.*.nodes[@bitCast(@as(isize, @intCast(no)))].r, x + @as(c_int, 1));
    }
}
pub fn do_parse_conventional(arg_g: [*c]struct_regcomp, arg_prec: c_int, arg_fold: c_int) callconv(.c) c_int {
    var g = arg_g;
    _ = &g;
    var prec = arg_prec;
    _ = &prec;
    var fold = arg_fold;
    _ = &fold;
    var no: c_int = -@as(c_int, 1);
    _ = &no;
    while (true) {
        if ((!(g.*.l != 0) or (@as(c_int, g.*.ptr.*) == @as(c_int, ')'))) or (@as(c_int, g.*.ptr.*) == @as(c_int, '|'))) {
            no = -@as(c_int, 1);
        } else if (@as(c_int, g.*.ptr.*) == @as(c_int, '(')) {
            g.*.ptr += 1;
            g.*.l -= 1;
            if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '?'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '#'))) {
                g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
                g.*.l -= 2;
                while ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) != @as(c_int, ')'))) != 0)) {
                    g.*.ptr += 1;
                    g.*.l -= 1;
                }
                if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, ')'))) != 0)) {
                    g.*.ptr += 1;
                    g.*.l -= 1;
                }
                continue;
            } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '?'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, ':'))) {
                g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
                no = mk_node(g, -@as(c_int, '('), -@as(c_int, 1), do_parse_conventional(g, 0, fold));
            } else {
                no = mk_node(g, -@as(c_int, '{'), -@as(c_int, 1), do_parse_conventional(g, 0, fold));
            }
            if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, ')'))) != 0)) {
                g.*.ptr += 1;
                g.*.l -= 1;
            } else {
                _ = printf("Unbalanced parenthesis\n");
                return 0;
            }
        } else if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(((@as(c_int, g.*.ptr.*) == @as(c_int, '.')) or (@as(c_int, g.*.ptr.*) == @as(c_int, '^'))) or (@as(c_int, g.*.ptr.*) == @as(c_int, '$')))) != 0)) {
            no = mk_node(g, -@as(c_int, (blk: {
                const ref = &g.*.ptr;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).*), -@as(c_int, 1), -@as(c_int, 1));
            g.*.l -= 1;
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '!'))) {
            no = mk_node(g, -@as(c_int, 'e'), -@as(c_int, 1), -@as(c_int, 1));
            g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            g.*.l -= 2;
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, 'y'))) {
            no = mk_node(g, -@as(c_int, '{'), -@as(c_int, 1), mk_node(g, -@as(c_int, '*'), -@as(c_int, 1), mk_node(g, -@as(c_int, '.'), -@as(c_int, 1), -@as(c_int, 1))));
            g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            g.*.l -= 2;
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, 'Y'))) {
            no = mk_node(g, -@as(c_int, '{'), -@as(c_int, 1), mk_node(g, -@as(c_int, '*'), -@as(c_int, 1), mk_node(g, -@as(c_int, 'e'), -@as(c_int, 1), -@as(c_int, 1))));
            g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            g.*.l -= 2;
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (((((((@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, 'b')) or (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, 'B'))) or (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, 'A'))) or (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, 'Z'))) or (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, 'z'))) or (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '>'))) or (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '<')))) {
            g.*.ptr += 1;
            g.*.l -= 1;
            no = mk_node(g, -@as(c_int, (blk: {
                const ref = &g.*.ptr;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            }).*), -@as(c_int, 1), -@as(c_int, 1));
            g.*.l -= 1;
        } else if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '['))) != 0)) {
            var m: [*c]struct_Cclass = undefined;
            _ = &m;
            var inv: c_int = 0;
            _ = &inv;
            no = mk_node(g, -@as(c_int, '['), -@as(c_int, 1), -@as(c_int, 1));
            m = @ptrCast(@alignCast(&g.*.nodes[@bitCast(@as(isize, @intCast(no)))].cclass));
            g.*.ptr += 1;
            g.*.l -= 1;
            if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '^'))) != 0)) {
                inv = 1;
                g.*.ptr += 1;
                g.*.l -= 1;
            }
            if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, ']'))) != 0)) {
                cclass_add(m, ']', ']');
                g.*.ptr += 1;
                g.*.l -= 1;
            }
            while ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) != @as(c_int, ']'))) != 0)) {
                var cat: [*c]struct_Cclass = undefined;
                _ = &cat;
                var first: c_int = undefined;
                _ = &first;
                var last: c_int = undefined;
                _ = &last;
                first = escape(g.*.cmap.*.@"type", &g.*.ptr, &g.*.l, &cat);
                if (first == -@as(c_int, 256)) {
                    cclass_union(m, cclass_remap(cat, g.*.cmap));
                } else {
                    if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '-'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) != @as(c_int, ']'))) {
                        g.*.ptr += 1;
                        g.*.l -= 1;
                        last = escape(g.*.cmap.*.@"type", &g.*.ptr, &g.*.l, &cat);
                    } else {
                        last = first;
                    }
                    if (fold != 0) {
                        if (first >= @as(c_int, 0)) {
                            first = g.*.cmap.*.to_lower.?(g.*.cmap, first);
                        }
                        if (last >= @as(c_int, 0)) {
                            last = g.*.cmap.*.to_lower.?(g.*.cmap, last);
                        }
                    }
                    cclass_add(m, first, last);
                }
            }
            if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, ']'))) != 0)) {
                g.*.ptr += 1;
                g.*.l -= 1;
            }
            if (inv != 0) {
                cclass_inv(m);
            }
        } else {
            var cat: [*c]struct_Cclass = undefined;
            _ = &cat;
            var ch: c_int = escape(g.*.cmap.*.@"type", &g.*.ptr, &g.*.l, &cat);
            _ = &ch;
            if (ch == -@as(c_int, 256)) {
                no = mk_node(g, -@as(c_int, '['), -@as(c_int, 1), -@as(c_int, 1));
                if (cat != null) {
                    cat = cclass_remap(cat, g.*.cmap);
                }
                cclass_union(@ptrCast(@alignCast(&g.*.nodes[@bitCast(@as(isize, @intCast(no)))].cclass)), cat);
            } else {
                if (fold != 0) {
                    if (g.*.cmap.*.@"type" != 0) {
                        var idx: c_int = rmap_lookup(@ptrCast(@alignCast(&rtree_fold)), ch, 0);
                        _ = &idx;
                        if (idx < FOLDMAGIC) {
                            no = mk_node(g, ch + idx, -@as(c_int, 1), -@as(c_int, 1));
                        } else {
                            idx -= FOLDMAGIC;
                            no = mk_node(g, fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 0)], -@as(c_int, 1), -@as(c_int, 1));
                            if (fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 1)] != 0) {
                                no = mk_node(g, -@as(c_int, ','), no, mk_node(g, fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 1)], -@as(c_int, 1), -@as(c_int, 1)));
                            }
                            if (fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 2)] != 0) {
                                no = mk_node(g, -@as(c_int, ','), no, mk_node(g, fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 2)], -@as(c_int, 1), -@as(c_int, 1)));
                            }
                        }
                    } else {
                        no = mk_node(g, g.*.cmap.*.to_lower.?(g.*.cmap, ch), -@as(c_int, 1), -@as(c_int, 1));
                    }
                } else {
                    no = mk_node(g, ch, -@as(c_int, 1), -@as(c_int, 1));
                }
            }
        }
        break;
    }
    while (true) {
        if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '*'))) != 0)) {
            while ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '*'))) != 0)) {
                g.*.ptr += 1;
                g.*.l -= 1;
            }
            no = mk_node(g, -@as(c_int, '*'), -@as(c_int, 1), no);
        } else if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '+'))) != 0)) {
            while ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '+'))) != 0)) {
                g.*.ptr += 1;
                g.*.l -= 1;
            }
            no = mk_node(g, -@as(c_int, '+'), -@as(c_int, 1), no);
        } else if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '?'))) != 0)) {
            while ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '?'))) != 0)) {
                g.*.ptr += 1;
                g.*.l -= 1;
            }
            no = mk_node(g, -@as(c_int, '?'), -@as(c_int, 1), no);
        } else if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '{'))) != 0)) {
            var org: c_int = no;
            _ = &org;
            var min: c_int = 0;
            _ = &min;
            var max: c_int = 0;
            _ = &max;
            g.*.ptr += 1;
            g.*.l -= 1;
            while (((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) >= @as(c_int, '0'))) != 0)) and (@as(c_int, g.*.ptr.*) <= @as(c_int, '9'))) {
                min = ((min * @as(c_int, 10)) + @as(c_int, (blk: {
                    const ref = &g.*.ptr;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).*)) - @as(c_int, '0');
                g.*.l -= 1;
            }
            if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, ','))) != 0)) {
                g.*.ptr += 1;
                g.*.l -= 1;
                if (((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) >= @as(c_int, '0'))) != 0)) and (@as(c_int, g.*.ptr.*) <= @as(c_int, '9'))) {
                    while (((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) >= @as(c_int, '0'))) != 0)) and (@as(c_int, g.*.ptr.*) <= @as(c_int, '9'))) {
                        max = ((max * @as(c_int, 10)) + @as(c_int, (blk: {
                            const ref = &g.*.ptr;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        }).*)) - @as(c_int, '0');
                        g.*.l -= 1;
                    }
                } else {
                    max = -@as(c_int, 1);
                }
            }
            if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '}'))) != 0)) {
                g.*.ptr += 1;
                g.*.l -= 1;
            }
            if (max > min) {
                max -= min;
            }
            no = -@as(c_int, 1);
            while ((blk: {
                const ref = &min;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                if (no == -@as(c_int, 1)) {
                    no = org;
                } else {
                    no = mk_node(g, -@as(c_int, ','), no, org);
                }
            }
            if (max == @as(c_int, 0)) {} else if (max == -@as(c_int, 1)) {
                no = mk_node(g, -@as(c_int, ','), no, mk_node(g, -@as(c_int, '*'), -@as(c_int, 1), org));
            } else {
                var q: c_int = -@as(c_int, 1);
                _ = &q;
                while ((blk: {
                    const ref = &max;
                    const tmp = ref.*;
                    ref.* -= 1;
                    break :blk tmp;
                }) != 0) {
                    if (q == -@as(c_int, 1)) {
                        q = mk_node(g, -@as(c_int, '?'), -@as(c_int, 1), org);
                    } else {
                        q = mk_node(g, -@as(c_int, '?'), -@as(c_int, 1), mk_node(g, -@as(c_int, ','), q, org));
                    }
                }
                no = mk_node(g, -@as(c_int, ','), no, q);
            }
        } else if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '|'))) != 0)) {
            if (prec < @as(c_int, 1)) {
                g.*.ptr += 1;
                g.*.l -= 1;
                no = mk_node(g, -@as(c_int, '|'), no, do_parse_conventional(g, 1, fold));
            } else {
                break;
            }
        } else if (!(g.*.l != 0) or (@as(c_int, g.*.ptr.*) == @as(c_int, ')'))) {
            break;
        } else if (prec < @as(c_int, 2)) {
            no = mk_node(g, -@as(c_int, ','), no, do_parse_conventional(g, 2, fold));
        } else break;
    }
    return no;
}
pub fn do_parse(arg_g: [*c]struct_regcomp, arg_prec: c_int, arg_fold: c_int) callconv(.c) c_int {
    var g = arg_g;
    _ = &g;
    var prec = arg_prec;
    _ = &prec;
    var fold = arg_fold;
    _ = &fold;
    var no: c_int = -@as(c_int, 1);
    _ = &no;
    while (true) {
        if ((!(g.*.l != 0) or (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, ')')))) or (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '|')))) {
            no = -@as(c_int, 1);
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '('))) {
            g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            g.*.l -= 2;
            if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '?'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '#'))) {
                g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
                g.*.l -= 2;
                while ((g.*.l >= @as(ptrdiff_t, 2)) and !((@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\')) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, ')')))) {
                    g.*.ptr += 1;
                    g.*.l -= 1;
                }
                if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, ')'))) {
                    g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
                    g.*.l -= 2;
                } else if (!(g.*.err != null)) {
                    g.*.err = "Missing \\\\)";
                }
                continue;
            } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '?'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, ':'))) {
                g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
                no = mk_node(g, -@as(c_int, '('), -@as(c_int, 1), do_parse(g, 0, fold));
            } else {
                no = mk_node(g, -@as(c_int, '{'), -@as(c_int, 1), do_parse(g, 0, fold));
            }
            if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, ')'))) {
                g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
                g.*.l -= 2;
            } else if (!(g.*.err != null)) {
                g.*.err = "Missing \\\\)";
            }
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and ((((@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '^')) or (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '$'))) or (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '>'))) or (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '<')))) {
            no = mk_node(g, -@as(c_int, g.*.ptr[@as(c_int, 1)]), -@as(c_int, 1), -@as(c_int, 1));
            g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            g.*.l -= 2;
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '.'))) {
            no = mk_node(g, -@as(c_int, '.'), -@as(c_int, 1), -@as(c_int, 1));
            g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            g.*.l -= 2;
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, 'y'))) {
            no = mk_node(g, -@as(c_int, '{'), -@as(c_int, 1), mk_node(g, -@as(c_int, '*'), -@as(c_int, 1), mk_node(g, -@as(c_int, '.'), -@as(c_int, 1), -@as(c_int, 1))));
            g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            g.*.l -= 2;
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, 'Y'))) {
            no = mk_node(g, -@as(c_int, '{'), -@as(c_int, 1), mk_node(g, -@as(c_int, '*'), -@as(c_int, 1), mk_node(g, -@as(c_int, 'e'), -@as(c_int, 1), -@as(c_int, 1))));
            g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            g.*.l -= 2;
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '!'))) {
            no = mk_node(g, -@as(c_int, 'e'), -@as(c_int, 1), -@as(c_int, 1));
            g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            g.*.l -= 2;
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '['))) {
            var m: [*c]struct_Cclass = undefined;
            _ = &m;
            var inv: c_int = 0;
            _ = &inv;
            no = mk_node(g, -@as(c_int, '['), -@as(c_int, 1), -@as(c_int, 1));
            m = @ptrCast(@alignCast(&g.*.nodes[@bitCast(@as(isize, @intCast(no)))].cclass));
            g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            g.*.l -= 2;
            if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '^'))) != 0)) {
                inv = 1;
                g.*.ptr += 1;
                g.*.l -= 1;
            }
            if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, ']'))) != 0)) {
                cclass_add(m, ']', ']');
                g.*.ptr += 1;
                g.*.l -= 1;
            }
            while ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) != @as(c_int, ']'))) != 0)) {
                var cat: [*c]struct_Cclass = undefined;
                _ = &cat;
                var first: c_int = undefined;
                _ = &first;
                var last: c_int = undefined;
                _ = &last;
                first = escape(g.*.cmap.*.@"type", &g.*.ptr, &g.*.l, &cat);
                if (first == -@as(c_int, 256)) {
                    cclass_union(m, cclass_remap(cat, g.*.cmap));
                } else {
                    if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '-'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) != @as(c_int, ']'))) {
                        g.*.ptr += 1;
                        g.*.l -= 1;
                        last = escape(g.*.cmap.*.@"type", &g.*.ptr, &g.*.l, &cat);
                    } else {
                        last = first;
                    }
                    if (fold != 0) {
                        if (first >= @as(c_int, 0)) {
                            first = g.*.cmap.*.to_lower.?(g.*.cmap, first);
                        }
                        if (last >= @as(c_int, 0)) {
                            last = g.*.cmap.*.to_lower.?(g.*.cmap, last);
                        }
                    }
                    cclass_add(m, first, last);
                }
            }
            if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, ']'))) != 0)) {
                g.*.ptr += 1;
                g.*.l -= 1;
            } else if (!(g.*.err != null)) {
                g.*.err = "Missing ]";
            }
            if (inv != 0) {
                cclass_inv(m);
            }
        } else {
            var cat: [*c]struct_Cclass = undefined;
            _ = &cat;
            var ch: c_int = escape(g.*.cmap.*.@"type", &g.*.ptr, &g.*.l, &cat);
            _ = &ch;
            if (ch == -@as(c_int, 256)) {
                no = mk_node(g, -@as(c_int, '['), -@as(c_int, 1), -@as(c_int, 1));
                cclass_union(@ptrCast(@alignCast(&g.*.nodes[@bitCast(@as(isize, @intCast(no)))].cclass)), cclass_remap(cat, g.*.cmap));
            } else {
                if (fold != 0) {
                    if (g.*.cmap.*.@"type" != 0) {
                        var idx: c_int = rmap_lookup(@ptrCast(@alignCast(&rtree_fold)), ch, 0);
                        _ = &idx;
                        if (idx < FOLDMAGIC) {
                            no = mk_node(g, ch + idx, -@as(c_int, 1), -@as(c_int, 1));
                        } else {
                            idx -= FOLDMAGIC;
                            no = mk_node(g, fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 0)], -@as(c_int, 1), -@as(c_int, 1));
                            if (fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 1)] != 0) {
                                no = mk_node(g, -@as(c_int, ','), no, mk_node(g, fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 1)], -@as(c_int, 1), -@as(c_int, 1)));
                            }
                            if (fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 2)] != 0) {
                                no = mk_node(g, -@as(c_int, ','), no, mk_node(g, fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 2)], -@as(c_int, 1), -@as(c_int, 1)));
                            }
                        }
                    } else {
                        no = mk_node(g, g.*.cmap.*.to_lower.?(g.*.cmap, ch), -@as(c_int, 1), -@as(c_int, 1));
                    }
                } else {
                    no = mk_node(g, ch, -@as(c_int, 1), -@as(c_int, 1));
                }
            }
        }
        break;
    }
    while (true) {
        if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '*'))) {
            while (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '*'))) {
                g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
                g.*.l -= 2;
            }
            no = mk_node(g, -@as(c_int, '*'), -@as(c_int, 1), no);
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '+'))) {
            while (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '+'))) {
                g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
                g.*.l -= 2;
            }
            no = mk_node(g, -@as(c_int, '+'), -@as(c_int, 1), no);
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '?'))) {
            while (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '?'))) {
                g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
                g.*.l -= 2;
            }
            no = mk_node(g, -@as(c_int, '?'), -@as(c_int, 1), no);
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '{'))) {
            var org: c_int = no;
            _ = &org;
            var min: c_int = 0;
            _ = &min;
            var max: c_int = 0;
            _ = &max;
            g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
            g.*.l -= 2;
            while (((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) >= @as(c_int, '0'))) != 0)) and (@as(c_int, g.*.ptr.*) <= @as(c_int, '9'))) {
                min = ((min * @as(c_int, 10)) + @as(c_int, (blk: {
                    const ref = &g.*.ptr;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).*)) - @as(c_int, '0');
                g.*.l -= 1;
            }
            if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, ','))) != 0)) {
                g.*.ptr += 1;
                g.*.l -= 1;
                if (((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) >= @as(c_int, '0'))) != 0)) and (@as(c_int, g.*.ptr.*) <= @as(c_int, '9'))) {
                    while (((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) >= @as(c_int, '0'))) != 0)) and (@as(c_int, g.*.ptr.*) <= @as(c_int, '9'))) {
                        max = ((max * @as(c_int, 10)) + @as(c_int, (blk: {
                            const ref = &g.*.ptr;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        }).*)) - @as(c_int, '0');
                        g.*.l -= 1;
                    }
                } else {
                    max = -@as(c_int, 1);
                }
            }
            if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, g.*.ptr.*) == @as(c_int, '}'))) != 0)) {
                g.*.ptr += 1;
                g.*.l -= 1;
            } else if (!(g.*.err != null)) {
                g.*.err = "Missing }";
            }
            if (max > min) {
                max -= min;
            }
            no = -@as(c_int, 1);
            while ((blk: {
                const ref = &min;
                const tmp = ref.*;
                ref.* -= 1;
                break :blk tmp;
            }) != 0) {
                if (no == -@as(c_int, 1)) {
                    no = org;
                } else {
                    no = mk_node(g, -@as(c_int, ','), no, org);
                }
            }
            if (max == @as(c_int, 0)) {} else if (max == -@as(c_int, 1)) {
                no = mk_node(g, -@as(c_int, ','), no, mk_node(g, -@as(c_int, '*'), -@as(c_int, 1), org));
            } else {
                var q: c_int = -@as(c_int, 1);
                _ = &q;
                while ((blk: {
                    const ref = &max;
                    const tmp = ref.*;
                    ref.* -= 1;
                    break :blk tmp;
                }) != 0) {
                    if (q == -@as(c_int, 1)) {
                        q = mk_node(g, -@as(c_int, '?'), -@as(c_int, 1), org);
                    } else {
                        q = mk_node(g, -@as(c_int, '?'), -@as(c_int, 1), mk_node(g, -@as(c_int, ','), q, org));
                    }
                }
                no = mk_node(g, -@as(c_int, ','), no, q);
            }
        } else if (((g.*.l >= @as(ptrdiff_t, 2)) and (@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\'))) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, '|'))) {
            if (prec < @as(c_int, 1)) {
                g.*.ptr += @as(usize, @bitCast(@as(isize, @intCast(2))));
                g.*.l -= 2;
                no = mk_node(g, -@as(c_int, '|'), no, do_parse(g, 1, fold));
            } else {
                break;
            }
        } else if (!(g.*.l != 0) or ((@as(c_int, g.*.ptr[@as(c_int, 0)]) == @as(c_int, '\\')) and (@as(c_int, g.*.ptr[@as(c_int, 1)]) == @as(c_int, ')')))) {
            break;
        } else if (prec < @as(c_int, 2)) {
            no = mk_node(g, -@as(c_int, ','), no, do_parse(g, 2, fold));
        } else break;
    }
    return no;
}
pub fn unasm(arg_f: [*c]Frag) callconv(.c) void {
    var f = arg_f;
    _ = &f;
    var pc: ptrdiff_t = 0;
    _ = &pc;
    _ = @as(c_int, 0);
    _ = @as(c_int, 0);
    while (true) {
        var i: ptrdiff_t = pc;
        _ = &i;
        var c: c_int = fetchi(f, &pc);
        _ = &c;
        if (c >= @as(c_int, 0)) {
            _ = @as(c_int, 0);
        } else {
            while (true) {
                switch (c) {
                    iDOT => {
                        _ = @as(c_int, 0);
                        break;
                    },
                    iEXPR => {
                        _ = @as(c_int, 0);
                        break;
                    },
                    iBOL => {
                        _ = @as(c_int, 0);
                        break;
                    },
                    iEOL => {
                        _ = @as(c_int, 0);
                        break;
                    },
                    iBOW => {
                        _ = @as(c_int, 0);
                        break;
                    },
                    iEOW => {
                        _ = @as(c_int, 0);
                        break;
                    },
                    iBRA => {
                        _ = @as(c_int, 0);
                        break;
                    },
                    iKET => {
                        _ = @as(c_int, 0);
                        break;
                    },
                    iFORK => {
                        {
                            var arg: c_int = fetchi(f, &pc);
                            _ = &arg;
                            _ = @as(c_int, 0);
                            break;
                        }
                    },
                    iJUMP => {
                        {
                            var arg: c_int = fetchi(f, &pc);
                            _ = &arg;
                            _ = @as(c_int, 0);
                            break;
                        }
                    },
                    iCLASS => {
                        {
                            var r: [*c]struct_Cclass = @ptrCast(@alignCast(fetchp(f, &pc)));
                            _ = &r;
                            _ = @as(c_int, 0);
                            cclass_show(r);
                            break;
                        }
                    },
                    iEND => {
                        _ = @as(c_int, 0);
                        return;
                    },
                    else => {},
                }
                break;
            }
        }
    }
}
pub fn extract(arg_g: [*c]struct_regcomp, arg_no: c_int, arg_fold: c_int) callconv(.c) c_int {
    var g = arg_g;
    _ = &g;
    var no = arg_no;
    _ = &no;
    var fold = arg_fold;
    _ = &fold;
    while (no != -@as(c_int, 1)) {
        if (g.*.nodes[@bitCast(@as(isize, @intCast(no)))].@"type" == -@as(c_int, ',')) {
            if (!(extract(g, g.*.nodes[@bitCast(@as(isize, @intCast(no)))].l, fold) != 0)) {
                no = g.*.nodes[@bitCast(@as(isize, @intCast(no)))].r;
                continue;
            } else {
                return -@as(c_int, 1);
            }
        } else if ((g.*.nodes[@bitCast(@as(isize, @intCast(no)))].@"type" >= @as(c_int, 0)) and (((g.*.nodes[@bitCast(@as(isize, @intCast(no)))].@"type" < @as(c_int, 128)) or !(g.*.cmap.*.@"type" != 0)) or !(fold != 0))) {
            if (g.*.cmap.*.@"type" != 0) {
                var buf: [8]u8 = undefined;
                _ = &buf;
                var x: ptrdiff_t = undefined;
                _ = &x;
                _ = utf8_encode(@ptrCast(@alignCast(&buf)), g.*.nodes[@bitCast(@as(isize, @intCast(no)))].@"type");
                {
                    x = 0;
                    while (@as(c_int, buf[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) {
                        if ((g.*.prefix_len + @as(ptrdiff_t, 1)) == g.*.prefix_size) {
                            g.*.prefix_size *= 2;
                            g.*.prefix = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(g.*.prefix)), g.*.prefix_size)));
                        }
                        g.*.prefix[
                            @bitCast(@as(isize, @intCast(blk: {
                                const ref = &g.*.prefix_len;
                                const tmp = ref.*;
                                ref.* += 1;
                                break :blk tmp;
                            })))
                        ] = buf[@bitCast(@as(isize, @intCast(x)))];
                    }
                }
            } else {
                if ((g.*.prefix_len + @as(ptrdiff_t, 1)) == g.*.prefix_size) {
                    g.*.prefix_size *= 2;
                    g.*.prefix = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(g.*.prefix)), g.*.prefix_size)));
                }
                g.*.prefix[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &g.*.prefix_len;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = @as(u8, @bitCast(@as(i8, @truncate(g.*.nodes[@bitCast(@as(isize, @intCast(no)))].@"type"))));
            }
            return 0;
        } else {
            return -@as(c_int, 1);
        }
    }
    return 0;
}
pub fn codegen(arg_g: [*c]struct_regcomp, arg_no: c_int, arg_end: [*c]c_int) callconv(.c) void {
    var g = arg_g;
    _ = &g;
    var no = arg_no;
    _ = &no;
    var end = arg_end;
    _ = &end;
    while (no != -@as(c_int, 1)) {
        while (true) {
            switch (g.*.nodes[@bitCast(@as(isize, @intCast(no)))].@"type") {
                -@as(c_int, '{') => {
                    {
                        var my_bra_no: c_int = blk: {
                            const ref = &g.*.bra_no;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        };
                        _ = &my_bra_no;
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iBRA);
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), my_bra_no);
                        codegen(g, g.*.nodes[@bitCast(@as(isize, @intCast(no)))].r, null);
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iKET);
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), my_bra_no);
                        break;
                    }
                },
                -@as(c_int, '(') => {
                    {
                        no = g.*.nodes[@bitCast(@as(isize, @intCast(no)))].r;
                        continue;
                    }
                },
                -@as(c_int, '*') => {
                    {
                        var targ: ptrdiff_t = undefined;
                        _ = &targ;
                        var start: ptrdiff_t = undefined;
                        _ = &start;
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iFORK);
                        targ = emiti(@ptrCast(@alignCast(&g.*.frag)), 0);
                        align_frag(@ptrCast(@alignCast(&g.*.frag)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))));
                        start = @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.len;
                        codegen(g, g.*.nodes[@bitCast(@as(isize, @intCast(no)))].r, null);
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iFORK);
                        _ = emit_branch(@ptrCast(@alignCast(&g.*.frag)), start);
                        fixup_branch(@ptrCast(@alignCast(&g.*.frag)), targ);
                        break;
                    }
                },
                -@as(c_int, '+') => {
                    {
                        var start: ptrdiff_t = undefined;
                        _ = &start;
                        align_frag(@ptrCast(@alignCast(&g.*.frag)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))));
                        start = @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.len;
                        codegen(g, g.*.nodes[@bitCast(@as(isize, @intCast(no)))].r, null);
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iFORK);
                        _ = emit_branch(@ptrCast(@alignCast(&g.*.frag)), start);
                        break;
                    }
                },
                -@as(c_int, '?') => {
                    {
                        var targ: ptrdiff_t = undefined;
                        _ = &targ;
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iFORK);
                        targ = emiti(@ptrCast(@alignCast(&g.*.frag)), 0);
                        codegen(g, g.*.nodes[@bitCast(@as(isize, @intCast(no)))].r, null);
                        fixup_branch(@ptrCast(@alignCast(&g.*.frag)), targ);
                        break;
                    }
                },
                -@as(c_int, '|') => {
                    {
                        var alt: ptrdiff_t = undefined;
                        _ = &alt;
                        var first: c_int = undefined;
                        _ = &first;
                        var my_end: c_int = 0;
                        _ = &my_end;
                        if (!(end != null)) {
                            end = &my_end;
                            first = 1;
                        } else {
                            first = 0;
                        }
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iFORK);
                        alt = emiti(@ptrCast(@alignCast(&g.*.frag)), 0);
                        codegen(g, g.*.nodes[@bitCast(@as(isize, @intCast(no)))].l, null);
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iJUMP);
                        end.* = @truncate(emiti(@ptrCast(@alignCast(&g.*.frag)), end.*));
                        fixup_branch(@ptrCast(@alignCast(&g.*.frag)), alt);
                        codegen(g, g.*.nodes[@bitCast(@as(isize, @intCast(no)))].r, end);
                        if (first != 0) {
                            frag_link(@ptrCast(@alignCast(&g.*.frag)), end.*);
                        }
                        break;
                    }
                },
                -@as(c_int, ',') => {
                    {
                        codegen(g, g.*.nodes[@bitCast(@as(isize, @intCast(no)))].l, null);
                        no = g.*.nodes[@bitCast(@as(isize, @intCast(no)))].r;
                        continue;
                    }
                },
                -@as(c_int, '.') => {
                    {
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iDOT);
                        break;
                    }
                },
                -@as(c_int, 'e') => {
                    {
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iEXPR);
                        break;
                    }
                },
                -@as(c_int, '^') => {
                    {
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iBOL);
                        break;
                    }
                },
                -@as(c_int, '$') => {
                    {
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iEOL);
                        break;
                    }
                },
                -@as(c_int, '<') => {
                    {
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iBOW);
                        break;
                    }
                },
                -@as(c_int, '>') => {
                    {
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iEOW);
                        break;
                    }
                },
                -@as(c_int, '[') => {
                    {
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iCLASS);
                        _ = emitp(@ptrCast(@alignCast(&g.*.frag)), @ptrCast(@alignCast(@as([*c]struct_Cclass, @ptrCast(@alignCast(&g.*.nodes[@bitCast(@as(isize, @intCast(no)))].cclass))))));
                        cclass_opt(@ptrCast(@alignCast(&g.*.nodes[@bitCast(@as(isize, @intCast(no)))].cclass)));
                        break;
                    }
                },
                else => {
                    {
                        _ = emiti(@ptrCast(@alignCast(&g.*.frag)), g.*.nodes[@bitCast(@as(isize, @intCast(no)))].@"type");
                        break;
                    }
                },
            }
            break;
        }
        break;
    }
}
pub export fn joe_regcomp(arg_cmap: [*c]struct_charmap, arg_s: [*c]const u8, arg_len: ptrdiff_t, arg_fold: c_int, arg_stdfmt: c_int, arg_debug: c_int) [*c]struct_regcomp {
    var cmap = arg_cmap;
    _ = &cmap;
    var s = arg_s;
    _ = &s;
    var len = arg_len;
    _ = &len;
    var fold = arg_fold;
    _ = &fold;
    var stdfmt = arg_stdfmt;
    _ = &stdfmt;
    var debug = arg_debug;
    _ = &debug;
    var no: c_int = undefined;
    _ = &no;
    var g: [*c]struct_regcomp = undefined;
    _ = &g;
    g = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_regcomp))))))));
    g.*.len = 0;
    g.*.size = 10;
    g.*.nodes = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_node))))) * @as(ptrdiff_t, g.*.size))));
    g.*.cmap = cmap;
    iz_frag(@ptrCast(@alignCast(&g.*.frag)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))));
    g.*.bra_no = 0;
    g.*.err = null;
    g.*.prefix_len = 0;
    g.*.prefix_size = 32;
    g.*.prefix = @ptrCast(@alignCast(joe_malloc(g.*.prefix_size)));
    g.*.ptr = s;
    g.*.l = len;
    if (stdfmt != 0) {
        no = do_parse_conventional(g, 0, fold);
    } else {
        no = do_parse(g, 0, fold);
    }
    if ((g.*.l != 0) and (@as(ptrdiff_t, @intFromBool(!(g.*.err != null))) != 0)) {
        g.*.err = "Extra junk at end of expression";
    }
    _ = extract(g, no, fold);
    g.*.prefix[@bitCast(@as(isize, @intCast(g.*.prefix_len)))] = 0;
    if (debug != 0) {
        _ = @as(c_int, 0);
        show(g, no, 0);
        _ = @as(c_int, 0);
    }
    codegen(g, no, null);
    _ = emiti(@ptrCast(@alignCast(&g.*.frag)), iEND);
    fin_code(@ptrCast(@alignCast(&g.*.frag)));
    if (debug != 0) {
        _ = @as(c_int, 0);
        unasm(@ptrCast(@alignCast(&g.*.frag)));
        _ = @as(c_int, 0);
    }
    return g;
}
pub export fn joe_regfree(arg_g: [*c]struct_regcomp) void {
    var g = arg_g;
    _ = &g;
    if (g.*.nodes != null) {
        joe_free(@ptrCast(@alignCast(g.*.nodes)));
    }
    clr_frag(@ptrCast(@alignCast(&g.*.frag)));
    joe_free(@ptrCast(@alignCast(g.*.prefix)));
    joe_free(@ptrCast(@alignCast(g)));
}
pub const struct_thread = extern struct {
    pc: [*c]u8 = null,
    pos: [10]Regmatch_t = @import("std").mem.zeroes([10]Regmatch_t),
    sp: c_int = 0,
    stack: [8]c_int = @import("std").mem.zeroes([8]c_int),
};
pub fn better(arg_a: [*c]Regmatch_t, arg_b: [*c]Regmatch_t, arg_bra_no: c_int) callconv(.c) c_int {
    var a = arg_a;
    _ = &a;
    var b = arg_b;
    _ = &b;
    var bra_no = arg_bra_no;
    _ = &bra_no;
    var y: c_int = undefined;
    _ = &y;
    {
        y = 0;
        while (y != bra_no) : (y += 1) {
            if (a[@bitCast(@as(isize, @intCast(y)))].rm_so < b[@bitCast(@as(isize, @intCast(y)))].rm_so) return 1;
            if (a[@bitCast(@as(isize, @intCast(y)))].rm_so > b[@bitCast(@as(isize, @intCast(y)))].rm_so) return 0;
            if (a[@bitCast(@as(isize, @intCast(y)))].rm_eo < b[@bitCast(@as(isize, @intCast(y)))].rm_eo) return 1;
            if (a[@bitCast(@as(isize, @intCast(y)))].rm_eo > b[@bitCast(@as(isize, @intCast(y)))].rm_eo) return 0;
        }
    }
    return 0;
}
pub fn add_thread(arg_pool: [*c]struct_thread, arg_start: [*c]u8, arg_l: c_int, arg_le: c_int, arg_pc: [*c]u8, arg_pos: [*c]Regmatch_t, arg_bra_no: c_int, arg_stack: [*c]c_int, arg_sp: c_int) callconv(.c) c_int {
    var pool = arg_pool;
    _ = &pool;
    var start = arg_start;
    _ = &start;
    var l = arg_l;
    _ = &l;
    var le = arg_le;
    _ = &le;
    var pc = arg_pc;
    _ = &pc;
    var pos = arg_pos;
    _ = &pos;
    var bra_no = arg_bra_no;
    _ = &bra_no;
    var stack = arg_stack;
    _ = &stack;
    var sp = arg_sp;
    _ = &sp;
    var x: c_int = undefined;
    _ = &x;
    var d: [*c]Regmatch_t = undefined;
    _ = &d;
    var t: c_int = undefined;
    _ = &t;
    {
        t = l;
        while (t != le) : (t += 1) {
            if (((pool[@bitCast(@as(isize, @intCast(t)))].pc == pc) and (pool[@bitCast(@as(isize, @intCast(t)))].sp == sp)) and (!(sp != 0) or !(memcmp(@ptrCast(@alignCast(@as([*c]c_int, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack))))), @ptrCast(@alignCast(stack)), @bitCast(@as(c_long, @as(ptrdiff_t, sp) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))) != 0))) {
                var y: c_int = undefined;
                _ = &y;
                {
                    y = 0;
                    while (y != bra_no) : (y += 1) {
                        if ((pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_so == pos[@bitCast(@as(isize, @intCast(y)))].rm_so) and (pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_eo == pos[@bitCast(@as(isize, @intCast(y)))].rm_eo)) {} else if ((pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_eo != @as(off_t, -@as(c_int, 1))) and (pos[@bitCast(@as(isize, @intCast(y)))].rm_eo != @as(off_t, -@as(c_int, 1)))) {
                            if (pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_so < pos[@bitCast(@as(isize, @intCast(y)))].rm_so) return le else if (pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_so > pos[@bitCast(@as(isize, @intCast(y)))].rm_so) {
                                {
                                    x = 0;
                                    while (x != bra_no) : (x += 1) {
                                        pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(x)))] = pos[@bitCast(@as(isize, @intCast(x)))];
                                    }
                                }
                                return le;
                            } else if (pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_eo < pos[@bitCast(@as(isize, @intCast(y)))].rm_eo) {
                                return le;
                            } else if (pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_eo > pos[@bitCast(@as(isize, @intCast(y)))].rm_eo) {
                                {
                                    x = 0;
                                    while (x != bra_no) : (x += 1) {
                                        pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(x)))] = pos[@bitCast(@as(isize, @intCast(x)))];
                                    }
                                }
                                return le;
                            }
                        } else if ((pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_so != @as(off_t, -@as(c_int, 1))) and (pos[@bitCast(@as(isize, @intCast(y)))].rm_so != @as(off_t, -@as(c_int, 1)))) {
                            if (pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_so < pos[@bitCast(@as(isize, @intCast(y)))].rm_so) return le else if (pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_so > pos[@bitCast(@as(isize, @intCast(y)))].rm_so) {
                                {
                                    x = 0;
                                    while (x != bra_no) : (x += 1) {
                                        pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(x)))] = pos[@bitCast(@as(isize, @intCast(x)))];
                                    }
                                }
                                return le;
                            }
                        } else {
                            break;
                        }
                    }
                }
                if (y == bra_no) return le;
            }
        }
    }
    if ((le - l) == MAX_THREADS) {
        _ = printf("ran out of threads\n");
        exit(-@as(c_int, 1));
        return le;
    }
    pool[@bitCast(@as(isize, @intCast(le)))].pc = pc;
    d = @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(le)))].pos));
    {
        x = 0;
        while (x != bra_no) : (x += 1) {
            d[@bitCast(@as(isize, @intCast(x)))] = pos[@bitCast(@as(isize, @intCast(x)))];
        }
    }
    pool[@bitCast(@as(isize, @intCast(le)))].sp = sp;
    {
        x = 0;
        while (x != sp) : (x += 1) {
            pool[@bitCast(@as(isize, @intCast(le)))].stack[@bitCast(@as(isize, @intCast(x)))] = stack[@bitCast(@as(isize, @intCast(x)))];
        }
    }
    return le + @as(c_int, 1);
}
pub fn add_thread1(arg_pool: [*c]struct_thread, arg_start: [*c]u8, arg_l: c_int, arg_le: c_int, arg_pc: [*c]u8, arg_pos: [*c]Regmatch_t, arg_bra_no: c_int, arg_stack: [*c]c_int, arg_sp: c_int) callconv(.c) c_int {
    var pool = arg_pool;
    _ = &pool;
    var start = arg_start;
    _ = &start;
    var l = arg_l;
    _ = &l;
    var le = arg_le;
    _ = &le;
    var pc = arg_pc;
    _ = &pc;
    var pos = arg_pos;
    _ = &pos;
    var bra_no = arg_bra_no;
    _ = &bra_no;
    var stack = arg_stack;
    _ = &stack;
    var sp = arg_sp;
    _ = &sp;
    var x: c_int = undefined;
    _ = &x;
    var d: [*c]Regmatch_t = undefined;
    _ = &d;
    var t: c_int = undefined;
    _ = &t;
    {
        t = l;
        while (t != le) : (t += 1) {
            if (((pool[@bitCast(@as(isize, @intCast(t)))].pc == pc) and (pool[@bitCast(@as(isize, @intCast(t)))].sp == sp)) and (!(sp != 0) or !(memcmp(@ptrCast(@alignCast(@as([*c]c_int, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack))))), @ptrCast(@alignCast(stack)), @bitCast(@as(c_long, @as(ptrdiff_t, sp) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))) != 0))) {
                var y: c_int = undefined;
                _ = &y;
                {
                    y = 0;
                    while (y != bra_no) : (y += 1) {
                        if ((pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_so == pos[@bitCast(@as(isize, @intCast(y)))].rm_so) and (pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(y)))].rm_eo == pos[@bitCast(@as(isize, @intCast(y)))].rm_eo)) {} else break;
                    }
                }
                if (y == bra_no) return le;
            }
        }
    }
    if ((le - l) == MAX_THREADS) {
        _ = printf("ran out of threads\n");
        exit(-@as(c_int, 1));
        return le;
    }
    pool[@bitCast(@as(isize, @intCast(le)))].pc = pc;
    d = @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(le)))].pos));
    {
        x = 0;
        while (x != bra_no) : (x += 1) {
            d[@bitCast(@as(isize, @intCast(x)))] = pos[@bitCast(@as(isize, @intCast(x)))];
        }
    }
    pool[@bitCast(@as(isize, @intCast(le)))].sp = sp;
    {
        x = 0;
        while (x != sp) : (x += 1) {
            pool[@bitCast(@as(isize, @intCast(le)))].stack[@bitCast(@as(isize, @intCast(x)))] = stack[@bitCast(@as(isize, @intCast(x)))];
        }
    }
    return le + @as(c_int, 1);
}
pub export fn joe_regexec(arg_g: [*c]struct_regcomp, arg_p: [*c]P, arg_nmatch: c_int, arg_matches: [*c]Regmatch_t, arg_fold: c_int) c_int {
    var g = arg_g;
    _ = &g;
    var p = arg_p;
    _ = &p;
    var nmatch = arg_nmatch;
    _ = &nmatch;
    var matches = arg_matches;
    _ = &matches;
    var fold = arg_fold;
    _ = &fold;
    var pool: [100]struct_thread = undefined;
    _ = &pool;
    var start_bol: c_int = pisbol(p);
    _ = &start_bol;
    var repl1: c_int = 0;
    _ = &repl1;
    var repl2: c_int = 0;
    _ = &repl2;
    var cl: c_int = undefined;
    _ = &cl;
    var cle: c_int = undefined;
    _ = &cle;
    var nl: c_int = undefined;
    _ = &nl;
    var nle: c_int = undefined;
    _ = &nle;
    var t: c_int = undefined;
    _ = &t;
    var c: c_int = undefined;
    _ = &c;
    var d: c_int = undefined;
    _ = &d;
    var match: c_int = -@as(c_int, 1);
    _ = &match;
    var bra_no: c_int = g.*.bra_no;
    _ = &bra_no;
    var byte: off_t = undefined;
    _ = &byte;
    if (nmatch < bra_no) {
        bra_no = nmatch;
    }
    cl = 0;
    cle = 1;
    nl = MAX_THREADS;
    nle = nl;
    c = '^';
    pool[@bitCast(@as(isize, @intCast(cl)))].pc = @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start;
    pool[@bitCast(@as(isize, @intCast(cl)))].sp = 0;
    {
        c = 0;
        while (c != bra_no) : (c += 1) {
            pool[@bitCast(@as(isize, @intCast(cl)))].pos[@bitCast(@as(isize, @intCast(c)))].rm_so = -@as(c_int, 1);
            pool[@bitCast(@as(isize, @intCast(cl)))].pos[@bitCast(@as(isize, @intCast(c)))].rm_eo = -@as(c_int, 1);
        }
    }
    c = prgetc(p);
    if (c != -@as(c_int, 256)) {
        _ = pgetc(p);
    }
    while (true) {
        d = c;
        byte = p.*.byte;
        if (fold != 0) {
            if (g.*.cmap.*.@"type" != 0) {
                if (repl1 != 0) {
                    c = repl1;
                    repl1 = 0;
                } else if (repl2 != 0) {
                    c = repl2;
                    repl2 = 0;
                } else {
                    var idx: c_int = undefined;
                    _ = &idx;
                    c = pgetc(p);
                    idx = rmap_lookup(@ptrCast(@alignCast(&rtree_fold)), c, 0);
                    if (idx < FOLDMAGIC) {
                        c += idx;
                    } else {
                        idx -= FOLDMAGIC;
                        c = fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 0)];
                        repl1 = fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 1)];
                        repl2 = fold_repl[@bitCast(@as(isize, @intCast(idx)))][@as(c_int, 2)];
                    }
                }
            } else {
                c = g.*.cmap.*.to_lower.?(g.*.cmap, pgetc(p));
            }
        } else {
            c = pgetc(p);
        }
        {
            t = cl;
            while (t != cle) : (t += 1) {
                var pc: [*c]u8 = pool[@bitCast(@as(isize, @intCast(t)))].pc;
                _ = &pc;
                {
                    var _keep: c_int = 1;
                    _ = &_keep;
                    while (_keep != 0) {
                        var i: c_int = undefined;
                        _ = &i;
                        _keep = 0;
                        i = @as([*c]c_int, @ptrCast(@alignCast(pc))).*;
                        if (i >= @as(c_int, 0)) {
                            if (c == i) {
                                nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))), @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                            }
                        } else {
                            while (true) {
                                switch (i) {
                                    iEXPR => {
                                        {
                                            if (c != -@as(c_int, 256)) {
                                                var _rexpr: c_int = 1;
                                                _ = &_rexpr;
                                                while (_rexpr != 0) {
                                                    var e: c_int = undefined;
                                                    _ = &e;
                                                    _rexpr = 0;
                                                    if (pool[@bitCast(@as(isize, @intCast(t)))].sp != 0) {
                                                        e = pool[@bitCast(@as(isize, @intCast(t)))].stack[@bitCast(@as(isize, @intCast(pool[@bitCast(@as(isize, @intCast(t)))].sp - @as(c_int, 1))))];
                                                    } else {
                                                        e = 0;
                                                    }
                                                    while (true) {
                                                        switch (e) {
                                                            @as(c_int, 0) => {
                                                                {
                                                                    var psh: c_int = undefined;
                                                                    _ = &psh;
                                                                    psh = 0;
                                                                    while (true) {
                                                                        switch (c) {
                                                                            @as(c_int, '(') => {
                                                                                psh = '(';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '[') => {
                                                                                psh = '[';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '{') => {
                                                                                psh = '{';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '"') => {
                                                                                psh = '"';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '\'') => {
                                                                                psh = '\'';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '/') => {
                                                                                psh = '/';
                                                                                break;
                                                                            },
                                                                            else => {},
                                                                        }
                                                                        break;
                                                                    }
                                                                    if (psh != 0) {
                                                                        pool[@bitCast(@as(isize, @intCast(t)))].stack[
                                                                            @bitCast(@as(isize, @intCast(blk: {
                                                                                const ref = &pool[@bitCast(@as(isize, @intCast(t)))].sp;
                                                                                const tmp = ref.*;
                                                                                ref.* += 1;
                                                                                break :blk tmp;
                                                                            })))
                                                                        ] = psh;
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    } else {
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))), @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    }
                                                                    break;
                                                                }
                                                            },
                                                            @as(c_int, '(') => {
                                                                {
                                                                    var psh: c_int = 0;
                                                                    _ = &psh;
                                                                    while (true) {
                                                                        switch (c) {
                                                                            @as(c_int, '(') => {
                                                                                psh = '(';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '[') => {
                                                                                psh = '[';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '{') => {
                                                                                psh = '{';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '"') => {
                                                                                psh = '"';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '\'') => {
                                                                                psh = '\'';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '/') => {
                                                                                psh = '/';
                                                                                break;
                                                                            },
                                                                            else => {},
                                                                        }
                                                                        break;
                                                                    }
                                                                    if (psh != 0) {
                                                                        pool[@bitCast(@as(isize, @intCast(t)))].stack[
                                                                            @bitCast(@as(isize, @intCast(blk: {
                                                                                const ref = &pool[@bitCast(@as(isize, @intCast(t)))].sp;
                                                                                const tmp = ref.*;
                                                                                ref.* += 1;
                                                                                break :blk tmp;
                                                                            })))
                                                                        ] = psh;
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    } else if (c == @as(c_int, ')')) {
                                                                        if (pool[@bitCast(@as(isize, @intCast(t)))].sp == @as(c_int, 1)) {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))), @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), 0);
                                                                        } else {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp - @as(c_int, 1));
                                                                        }
                                                                    } else {
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    }
                                                                    break;
                                                                }
                                                            },
                                                            @as(c_int, '[') => {
                                                                {
                                                                    var psh: c_int = 0;
                                                                    _ = &psh;
                                                                    while (true) {
                                                                        switch (c) {
                                                                            @as(c_int, '(') => {
                                                                                psh = '(';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '[') => {
                                                                                psh = '[';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '{') => {
                                                                                psh = '{';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '"') => {
                                                                                psh = '"';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '\'') => {
                                                                                psh = '\'';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '/') => {
                                                                                psh = '/';
                                                                                break;
                                                                            },
                                                                            else => {},
                                                                        }
                                                                        break;
                                                                    }
                                                                    if (psh != 0) {
                                                                        pool[@bitCast(@as(isize, @intCast(t)))].stack[
                                                                            @bitCast(@as(isize, @intCast(blk: {
                                                                                const ref = &pool[@bitCast(@as(isize, @intCast(t)))].sp;
                                                                                const tmp = ref.*;
                                                                                ref.* += 1;
                                                                                break :blk tmp;
                                                                            })))
                                                                        ] = psh;
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    } else if (c == @as(c_int, ']')) {
                                                                        if (pool[@bitCast(@as(isize, @intCast(t)))].sp == @as(c_int, 1)) {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))), @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), 0);
                                                                        } else {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp - @as(c_int, 1));
                                                                        }
                                                                    } else {
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    }
                                                                    break;
                                                                }
                                                            },
                                                            @as(c_int, '{') => {
                                                                {
                                                                    var psh: c_int = 0;
                                                                    _ = &psh;
                                                                    while (true) {
                                                                        switch (c) {
                                                                            @as(c_int, '(') => {
                                                                                psh = '(';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '[') => {
                                                                                psh = '[';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '{') => {
                                                                                psh = '{';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '"') => {
                                                                                psh = '"';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '\'') => {
                                                                                psh = '\'';
                                                                                break;
                                                                            },
                                                                            @as(c_int, '/') => {
                                                                                psh = '/';
                                                                                break;
                                                                            },
                                                                            else => {},
                                                                        }
                                                                        break;
                                                                    }
                                                                    if (psh != 0) {
                                                                        pool[@bitCast(@as(isize, @intCast(t)))].stack[
                                                                            @bitCast(@as(isize, @intCast(blk: {
                                                                                const ref = &pool[@bitCast(@as(isize, @intCast(t)))].sp;
                                                                                const tmp = ref.*;
                                                                                ref.* += 1;
                                                                                break :blk tmp;
                                                                            })))
                                                                        ] = psh;
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    } else if (c == @as(c_int, '}')) {
                                                                        if (pool[@bitCast(@as(isize, @intCast(t)))].sp == @as(c_int, 1)) {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))), @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), 0);
                                                                        } else {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp - @as(c_int, 1));
                                                                        }
                                                                    } else {
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    }
                                                                    break;
                                                                }
                                                            },
                                                            @as(c_int, '"') => {
                                                                {
                                                                    if (c == @as(c_int, '"')) {
                                                                        if (pool[@bitCast(@as(isize, @intCast(t)))].sp == @as(c_int, 1)) {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))), @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), 0);
                                                                        } else {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp - @as(c_int, 1));
                                                                        }
                                                                    } else if (c == @as(c_int, '\\')) {
                                                                        pool[@bitCast(@as(isize, @intCast(t)))].stack[
                                                                            @bitCast(@as(isize, @intCast(blk: {
                                                                                const ref = &pool[@bitCast(@as(isize, @intCast(t)))].sp;
                                                                                const tmp = ref.*;
                                                                                ref.* += 1;
                                                                                break :blk tmp;
                                                                            })))
                                                                        ] = '\\';
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    } else {
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    }
                                                                    break;
                                                                }
                                                            },
                                                            @as(c_int, '\'') => {
                                                                {
                                                                    if (c == @as(c_int, '\'')) {
                                                                        if (pool[@bitCast(@as(isize, @intCast(t)))].sp == @as(c_int, 1)) {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))), @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), 0);
                                                                        } else {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp - @as(c_int, 1));
                                                                        }
                                                                    } else if (c == @as(c_int, '\\')) {
                                                                        pool[@bitCast(@as(isize, @intCast(t)))].stack[
                                                                            @bitCast(@as(isize, @intCast(blk: {
                                                                                const ref = &pool[@bitCast(@as(isize, @intCast(t)))].sp;
                                                                                const tmp = ref.*;
                                                                                ref.* += 1;
                                                                                break :blk tmp;
                                                                            })))
                                                                        ] = '\\';
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    } else {
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    }
                                                                    break;
                                                                }
                                                            },
                                                            @as(c_int, '/') => {
                                                                {
                                                                    if (c == @as(c_int, '*')) {
                                                                        pool[@bitCast(@as(isize, @intCast(t)))].stack[@bitCast(@as(isize, @intCast(pool[@bitCast(@as(isize, @intCast(t)))].sp - @as(c_int, 1))))] = '*';
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    } else {
                                                                        pool[@bitCast(@as(isize, @intCast(t)))].sp -= 1;
                                                                        _rexpr = 1;
                                                                        break;
                                                                    }
                                                                    break;
                                                                }
                                                            },
                                                            @as(c_int, '\\') => {
                                                                {
                                                                    if (pool[@bitCast(@as(isize, @intCast(t)))].sp == @as(c_int, 1)) {
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))), @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), 0);
                                                                    } else {
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp - @as(c_int, 1));
                                                                    }
                                                                    break;
                                                                }
                                                            },
                                                            @as(c_int, '*') => {
                                                                {
                                                                    if (c == @as(c_int, '*')) {
                                                                        pool[@bitCast(@as(isize, @intCast(t)))].stack[@bitCast(@as(isize, @intCast(pool[@bitCast(@as(isize, @intCast(t)))].sp - @as(c_int, 1))))] = 'E';
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    } else {
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    }
                                                                    break;
                                                                }
                                                            },
                                                            @as(c_int, 'E') => {
                                                                {
                                                                    if (c == @as(c_int, '*')) {
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    } else if (c == @as(c_int, '/')) {
                                                                        if (pool[@bitCast(@as(isize, @intCast(t)))].sp == @as(c_int, 1)) {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))), @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), 0);
                                                                        } else {
                                                                            nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp - @as(c_int, 1));
                                                                        }
                                                                    } else {
                                                                        pool[@bitCast(@as(isize, @intCast(t)))].stack[@bitCast(@as(isize, @intCast(pool[@bitCast(@as(isize, @intCast(t)))].sp - @as(c_int, 1))))] = '*';
                                                                        nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                                                    }
                                                                    break;
                                                                }
                                                            },
                                                            else => {},
                                                        }
                                                        break;
                                                    }
                                                }
                                            }
                                            break;
                                        }
                                    },
                                    iDOT => {
                                        {
                                            if ((c != -@as(c_int, 256)) and (c != @as(c_int, '\n'))) {
                                                nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))), @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                            }
                                            break;
                                        }
                                    },
                                    iBOL => {
                                        {
                                            if ((start_bol != 0) or (d == @as(c_int, '\n'))) {
                                                pc += @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))));
                                                _keep = 1;
                                                break;
                                            }
                                            break;
                                        }
                                    },
                                    iEOL => {
                                        {
                                            if ((c == -@as(c_int, 256)) or (c == @as(c_int, '\n'))) {
                                                pc += @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))));
                                                _keep = 1;
                                                break;
                                            }
                                            break;
                                        }
                                    },
                                    iBOW => {
                                        {
                                            if ((g.*.cmap.*.is_alnum_.?(g.*.cmap, c) != 0) and !(g.*.cmap.*.is_alnum_.?(g.*.cmap, d) != 0)) {
                                                pc += @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))));
                                                _keep = 1;
                                                break;
                                            }
                                            break;
                                        }
                                    },
                                    iEOW => {
                                        {
                                            if (!(g.*.cmap.*.is_alnum_.?(g.*.cmap, c) != 0) and (g.*.cmap.*.is_alnum_.?(g.*.cmap, d) != 0)) {
                                                pc += @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))));
                                                _keep = 1;
                                                break;
                                            }
                                            break;
                                        }
                                    },
                                    iBRA => {
                                        {
                                            var idx: c_int = @as([*c]c_int, @ptrCast(@alignCast(pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))))))).*;
                                            _ = &idx;
                                            if (idx < bra_no) {
                                                pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(idx)))].rm_so = byte;
                                            }
                                            pc += @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, 2) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))));
                                            _keep = 1;
                                            break;
                                        }
                                    },
                                    iKET => {
                                        {
                                            var idx: c_int = @as([*c]c_int, @ptrCast(@alignCast(pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))))))).*;
                                            _ = &idx;
                                            if (idx < bra_no) {
                                                pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(idx)))].rm_eo = byte;
                                            }
                                            pc += @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, 2) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))));
                                            _keep = 1;
                                            break;
                                        }
                                    },
                                    iFORK => {
                                        {
                                            cle = add_thread1(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, cl, cle, (pc + @as(usize, @bitCast(@as(isize, @intCast(@as([*c]c_int, @ptrCast(@alignCast(pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))))))).*))))) + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))))))), @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                            pc += @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, 2) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))));
                                            _keep = 1;
                                            break;
                                        }
                                    },
                                    iJUMP => {
                                        {
                                            pc += @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @as([*c]c_int, @ptrCast(@alignCast(pc + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))))))).*) + @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))));
                                            _keep = 1;
                                            break;
                                        }
                                    },
                                    iCLASS => {
                                        {
                                            var cclass: [*c]struct_Cclass = undefined;
                                            _ = &cclass;
                                            pc += @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))));
                                            pc += @as(usize, @bitCast(@as(isize, @intCast((@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]struct_Cclass))))) - @as(ptrdiff_t, 1)) & -@divExact(@as(c_long, @bitCast(@intFromPtr(pc) -% @intFromPtr(@as([*c]u8, null)))), @sizeOf(u8))))));
                                            cclass = @as([*c][*c]struct_Cclass, @ptrCast(@alignCast(pc))).*;
                                            if (cclass_lookup(cclass, c) != 0) {
                                                pc += @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]struct_Cclass)))))))));
                                                pc += @as(usize, @bitCast(@as(isize, @intCast((@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))) - @as(ptrdiff_t, 1)) & -@divExact(@as(c_long, @bitCast(@intFromPtr(pc) -% @intFromPtr(@as([*c]u8, null)))), @sizeOf(u8))))));
                                                nle = add_thread(@ptrCast(@alignCast(&pool)), @as([*c]Frag, @ptrCast(@alignCast(&g.*.frag))).*.start, nl, nle, pc, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), bra_no, @ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].stack)), pool[@bitCast(@as(isize, @intCast(t)))].sp);
                                            }
                                            break;
                                        }
                                    },
                                    iEND => {
                                        {
                                            if ((match != 0) or (better(@ptrCast(@alignCast(&pool[@bitCast(@as(isize, @intCast(t)))].pos)), matches, bra_no) != 0)) {
                                                var x: c_int = undefined;
                                                _ = &x;
                                                {
                                                    x = 0;
                                                    while (x != bra_no) : (x += 1) {
                                                        matches[@bitCast(@as(isize, @intCast(x)))] = pool[@bitCast(@as(isize, @intCast(t)))].pos[@bitCast(@as(isize, @intCast(x)))];
                                                    }
                                                }
                                                match = 0;
                                            }
                                            break;
                                        }
                                    },
                                    else => {},
                                }
                                break;
                            }
                        }
                    }
                }
            }
        }
        cl = nl;
        cle = nle;
        if ((cle - cl) == MAX_THREADS) return -@as(c_int, 2);
        if (nl == MAX_THREADS) {
            nl = 0;
        } else {
            nl = MAX_THREADS;
        }
        nle = nl;
        start_bol = 0;
        if (!(((match != 0) and (c != -@as(c_int, 256))) and (cl != cle))) break;
    }
    if (!(match != 0) and (c != -@as(c_int, 256))) {
        _ = prgetc(p);
    }
    {
        c = bra_no;
        while (c < nmatch) : (c += 1) {
            matches[@bitCast(@as(isize, @intCast(c)))].rm_so = -@as(c_int, 1);
        }
    }
    return match;
}
