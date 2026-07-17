//! Key-map handler — replaces `joe/kbd.c`.
//!
//! Faithful C-ABI port of JOE's keymap / keyboard handler (radix-tree
//! bindings, context lookup, ukeymap). Generated from joe/kbd.c (non-MSDOS
//! path) via `zig translate-c`, then cleaned for the hybrid Zig+C build.

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
pub const FILE = anyopaque;

pub const KEY_MDOWN: c_int = 0x100000;
pub const KEY_MUP: c_int = 0x100001;
pub const KEY_MDRAG: c_int = 0x100002;
pub const KEY_M2DOWN: c_int = 0x100003;
pub const KEY_M2UP: c_int = 0x100004;
pub const KEY_M2DRAG: c_int = 0x100005;
pub const KEY_M3DOWN: c_int = 0x100006;
pub const KEY_M3UP: c_int = 0x100007;
pub const KEY_M3DRAG: c_int = 0x100008;
pub const KEY_MWUP: c_int = 0x100009;
pub const KEY_MWDOWN: c_int = 0x10000A;
pub const KEY_MIDDLEUP: c_int = 0x10000B;
pub const KEY_MIDDLEDOWN: c_int = 0x10000C;

pub const struct_Rtree = extern struct {
    _pad: [248]u8 = std.mem.zeroes([248]u8),
};
pub const struct_interval = extern struct {
    first: c_int = 0,
    last: c_int = 0,
};
pub const struct_interval_list = extern struct {
    next: [*c]struct_interval_list = null,
    interval: struct_interval = std.mem.zeroes(struct_interval),
    map: ?*anyopaque = null,
};
pub const struct_macro = opaque {};
pub const MACRO = struct_macro;
pub const struct_cmd = opaque {};
pub const CMD = struct_cmd;
pub const struct_cap = extern struct {
    _pad: [88]u8 = std.mem.zeroes([88]u8),
};
pub const CAP = struct_cap;
pub const struct_kmap = extern struct {
    what: ptrdiff_t = 0,
    rtree: struct_Rtree = std.mem.zeroes(struct_Rtree),
    src: [*c]struct_interval_list = null,
    dflt: ?*anyopaque = null,
    rtree_version: c_int = 0,
    src_version: c_int = 0,
};
pub const KMAP = struct_kmap;
pub const struct_kbd = extern struct {
    curmap: [*c]KMAP = null,
    topmap: [*c]KMAP = null,
    seq: [16]c_int = std.mem.zeroes([16]c_int),
    x: ptrdiff_t = 0,
};
pub const KBD = struct_kbd;
pub const struct_context = extern struct {
    next: [*c]struct_context = null,
    name: [*c]u8 = null,
    kmap: [*c]KMAP = null,
};
pub const struct_charmap = opaque {};
pub const struct_b = opaque {};
pub const B = struct_b;
pub const struct_bw = opaque {
};
pub const BW = struct_bw;
pub const struct_window = extern struct {
    _pad0: [136]u8 = std.mem.zeroes([136]u8),
    kbd: [*c]KBD = null,
    _pad1: [56]u8 = std.mem.zeroes([56]u8),
};
pub const W = struct_window;
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_calloc(nmemb: ptrdiff_t, size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn zhtoi(s: [*c]const u8) c_int;
pub extern fn slen(ary: [*c]const u8) ptrdiff_t;
pub extern fn vsncpy(vary: [*c]u8, pos: ptrdiff_t, array: [*c]const u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsrm(vary: [*c]u8) void;
pub extern fn vaadd(vary: [*c]?*anyopaque, el: ?*anyopaque) [*c]?*anyopaque;
pub extern fn utf8_decode_string(s: [*c]const u8) c_int;
pub extern fn jgetstr(cap: [*c]CAP, name: [*c]const u8) [*c]const u8;
pub extern fn tcompile(cap: [*c]CAP, s: [*c]const u8, a0: ptrdiff_t, a1: ptrdiff_t, a2: ptrdiff_t, a3: ptrdiff_t) [*c]u8;
pub extern fn rtree_init(r: [*c]struct_Rtree) void;
pub extern fn rtree_clr(r: [*c]struct_Rtree) void;
pub extern fn rtree_lookup(r: [*c]struct_Rtree, ch: c_int) ?*anyopaque;
pub extern fn rtree_opt(r: [*c]struct_Rtree) void;
pub extern fn rtree_build(r: [*c]struct_Rtree, l: [*c]struct_interval_list) void;
pub extern fn interval_add(list: [*c]struct_interval_list, first: c_int, last: c_int, map: ?*anyopaque) [*c]struct_interval_list;
pub extern fn interval_lookup(list: [*c]struct_interval_list, dflt: ?*anyopaque, ch: c_int) ?*anyopaque;
pub extern fn ttflsh() c_int;
pub extern var obuf: [*c]u8;
pub extern var obufp: ptrdiff_t;
pub extern var obufsiz: ptrdiff_t;
inline fn ttputc(c: u8) void {
    const seqp: [*c]u8 = obuf;
    const idx: usize = @intCast(blk: {
        const ref = &obufp;
        const tmp = ref.*;
        ref.* += 1;
        break :blk tmp;
    });
    seqp[idx] = c;
    if (obufp == obufsiz) {
        _ = ttflsh();
    }
}
pub extern fn msgnw(w: [*c]W, s: [*c]const u8) void;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn wmkpw(w: [*c]W, prompt: [*c]const u8, history: [*c]?*B, func: ?*const fn (w: [*c]W, s: [*c]u8, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, huh: [*c]const u8, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, tab: ?*const fn (bw: ?*BW, k: c_int) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int, map: ?*struct_charmap, file_prompt: c_int) ?*BW;
pub extern fn simple_cmplt(bw: ?*BW, list: [*c][*c]u8) c_int;
pub extern var locale_map: ?*struct_charmap;
pub export var contexts: [*c]struct_context = null;
pub export var keymap_list: [*c][*c]u8 = null;
pub export fn mkkbd(arg_kmap_1: [*c]KMAP) [*c]KBD {
    var kmap_1 = arg_kmap_1;
    _ = &kmap_1;
    var kbd_2: [*c]KBD = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(KBD))))))));
    _ = &kbd_2;
    kbd_2.*.topmap = kmap_1;
    kbd_2.*.curmap = kmap_1;
    kbd_2.*.x = 0;
    return kbd_2;
}
pub export fn rmkbd(arg_k: [*c]KBD) void {
    var k = arg_k;
    _ = &k;
    joe_free(@ptrCast(@alignCast(k)));
}
pub export fn dokey(arg_kbd_1: [*c]KBD, arg_n: c_int) ?*MACRO {
    var kbd_1 = arg_kbd_1;
    _ = &kbd_1;
    var n = arg_n;
    _ = &n;
    var bind: [*c]KMAP = undefined;
    _ = &bind;
    if (n < @as(c_int, 0)) {
        n += 256;
    }
    if (kbd_1.*.curmap == kbd_1.*.topmap) {
        kbd_1.*.x = 0;
    }
    if (kbd_1.*.curmap.*.rtree_version != kbd_1.*.curmap.*.src_version) {
        rtree_clr(&kbd_1.*.curmap.*.rtree);
        rtree_init(&kbd_1.*.curmap.*.rtree);
        rtree_build(&kbd_1.*.curmap.*.rtree, kbd_1.*.curmap.*.src);
        rtree_opt(&kbd_1.*.curmap.*.rtree);
        kbd_1.*.curmap.*.rtree_version = kbd_1.*.curmap.*.src_version;
    }
    bind = @ptrCast(@alignCast(rtree_lookup(&kbd_1.*.curmap.*.rtree, n)));
    if (!(bind != null)) {
        bind = @ptrCast(@alignCast(kbd_1.*.curmap.*.dflt));
    }
    if ((bind != null) and (bind.*.what == @as(ptrdiff_t, 1))) {
        {
            const idx: usize = @intCast(blk: {
                const ref = &kbd_1.*.x;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            });
            const seqp: *[16]c_int = &kbd_1.*.seq;
            seqp[idx] = n;
        }
        kbd_1.*.curmap = bind;
        bind = null;
    } else {
        kbd_1.*.x = 0;
        kbd_1.*.curmap = kbd_1.*.topmap;
    }
    return @ptrCast(@alignCast(bind));
}
pub fn keyval(arg_s: [*c]u8) callconv(.c) c_int {
    var s = arg_s;
    _ = &s;
    if ((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 'U')) and (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, '+'))) {
        return zhtoi(s + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 2))))));
    } else if (((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, '^')) and (@as(c_int, s[@as(c_int, 1)]) != 0)) and !(@as(c_int, s[@as(c_int, 2)]) != 0)) {
        while (true) {
            switch (@as(c_int, s[@as(c_int, 1)])) {
                @as(c_int, '?') => {
                    return 127;
                },
                @as(c_int, '#') => {
                    return 155;
                },
                else => {
                    return @as(c_int, s[@as(c_int, 1)]) & @as(c_int, 31);
                },
            }
            break;
        }
    } else if ((((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 'S')) or (@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 's'))) and ((@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'P')) or (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'p')))) and !(@as(c_int, s[@as(c_int, 2)]) != 0)) return ' ' else if (((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 'M')) or (@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 'm'))) and (@as(c_int, s[@as(c_int, 1)]) != 0)) {
        if (!(strcmp(s, "MDOWN") != 0)) return KEY_MDOWN else if (!(strcmp(s, "MWDOWN") != 0)) return KEY_MWDOWN else if (!(strcmp(s, "MWUP") != 0)) return KEY_MWUP else if (!(strcmp(s, "MUP") != 0)) return KEY_MUP else if (!(strcmp(s, "MDRAG") != 0)) return KEY_MDRAG else if (!(strcmp(s, "M2DOWN") != 0)) return KEY_M2DOWN else if (!(strcmp(s, "M2UP") != 0)) return KEY_M2UP else if (!(strcmp(s, "M2DRAG") != 0)) return KEY_M2DRAG else if (!(strcmp(s, "M3DOWN") != 0)) return KEY_M3DOWN else if (!(strcmp(s, "M3UP") != 0)) return KEY_M3UP else if (!(strcmp(s, "M3DRAG") != 0)) return KEY_M3DRAG else if (!(strcmp(s, "MIDDLEDOWN") != 0)) return KEY_MIDDLEDOWN else if (!(strcmp(s, "MIDDLEUP") != 0)) return KEY_MIDDLEUP else return s[@as(c_int, 0)];
    } else {
        var ch: c_int = utf8_decode_string(s);
        _ = &ch;
        if (ch < @as(c_int, 0)) {
            ch = -@as(c_int, 1);
        }
        return ch;
    }
    return undefined;
}
pub export fn mkkmap() [*c]KMAP {
    var kmap_1: [*c]KMAP = @ptrCast(@alignCast(joe_calloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(KMAP))))), 1)));
    _ = &kmap_1;
    kmap_1.*.what = 1;
    rtree_init(&kmap_1.*.rtree);
    return kmap_1;
}
pub export fn rmkmap(arg_kmap_1: [*c]KMAP) void {
    var kmap_1 = arg_kmap_1;
    _ = &kmap_1;
    var l: [*c]struct_interval_list = undefined;
    _ = &l;
    var n: [*c]struct_interval_list = undefined;
    _ = &n;
    if (!(kmap_1 != null)) return;
    {
        l = kmap_1.*.src;
        while (l != null) : (l = n) {
            n = l.*.next;
            if (@as([*c]KMAP, @ptrCast(@alignCast(l.*.map))).*.what == @as(ptrdiff_t, 1)) {
                rmkmap(@ptrCast(@alignCast(l.*.map)));
            }
            joe_free(@ptrCast(@alignCast(l)));
        }
    }
    if ((kmap_1.*.dflt != null) and (@as([*c]KMAP, @ptrCast(@alignCast(kmap_1.*.dflt))).*.what == @as(ptrdiff_t, 1))) {
        rmkmap(@ptrCast(@alignCast(kmap_1.*.dflt)));
    }
    rtree_clr(&kmap_1.*.rtree);
    joe_free(@ptrCast(@alignCast(kmap_1)));
}
pub fn range(arg_seq: [*c]u8, arg_vv: [*c]c_int, arg_ww: [*c]c_int) callconv(.c) [*c]u8 {
    var seq = arg_seq;
    _ = &seq;
    var vv = arg_vv;
    _ = &vv;
    var ww = arg_ww;
    _ = &ww;
    var c: u8 = undefined;
    _ = &c;
    var x: c_int = undefined;
    _ = &x;
    var v: c_int = undefined;
    _ = &v;
    var w: c_int = undefined;
    _ = &w;
    {
        x = 0;
        while ((@as(c_int, seq[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, seq[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, ' '))) : (x += 1) {}
    }
    c = seq[@bitCast(@as(isize, @intCast(x)))];
    seq[@bitCast(@as(isize, @intCast(x)))] = 0;
    v = keyval(seq);
    w = v;
    if (w < @as(c_int, 0)) return null;
    seq[@bitCast(@as(isize, @intCast(x)))] = c;
    {
        seq += @as(usize, @bitCast(@as(isize, @intCast(x))));
        while (@as(c_int, seq.*) == @as(c_int, ' ')) : (seq += 1) {}
    }
    if ((((@as(c_int, seq[@as(c_int, 0)]) == @as(c_int, 'T')) or (@as(c_int, seq[@as(c_int, 0)]) == @as(c_int, 't'))) and ((@as(c_int, seq[@as(c_int, 1)]) == @as(c_int, 'O')) or (@as(c_int, seq[@as(c_int, 1)]) == @as(c_int, 'o')))) and (@as(c_int, seq[@as(c_int, 2)]) == @as(c_int, ' '))) {
        {
            seq += @as(usize, @bitCast(@as(isize, @intCast(2))));
            while (@as(c_int, seq.*) == @as(c_int, ' ')) : (seq += 1) {}
        }
        {
            x = 0;
            while ((@as(c_int, seq[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, seq[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, ' '))) : (x += 1) {}
        }
        c = seq[@bitCast(@as(isize, @intCast(x)))];
        seq[@bitCast(@as(isize, @intCast(x)))] = 0;
        w = keyval(seq);
        if (w < @as(c_int, 0)) return null;
        seq[@bitCast(@as(isize, @intCast(x)))] = c;
        {
            seq += @as(usize, @bitCast(@as(isize, @intCast(x))));
            while (@as(c_int, seq.*) == @as(c_int, ' ')) : (seq += 1) {}
        }
    }
    if (v > w) return null;
    vv.* = v;
    ww.* = w;
    return seq;
}
pub fn kbuild(arg_cap_1: [*c]CAP, arg_kmap_2: [*c]KMAP, arg_seq: [*c]u8, arg_bind: ?*MACRO, arg_err: [*c]c_int, arg_capseq: [*c]const u8, arg_seql: ptrdiff_t) callconv(.c) [*c]KMAP {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var kmap_2 = arg_kmap_2;
    _ = &kmap_2;
    var seq = arg_seq;
    _ = &seq;
    var bind = arg_bind;
    _ = &bind;
    var err = arg_err;
    _ = &err;
    var capseq = arg_capseq;
    _ = &capseq;
    var seql = arg_seql;
    _ = &seql;
    var v: c_int = undefined;
    _ = &v;
    var w: c_int = undefined;
    _ = &w;
    if ((!(seql != 0) and (@as(c_int, seq[@as(c_int, 0)]) == @as(c_int, '.'))) and (@as(c_int, seq[@as(c_int, 1)]) != 0)) {
        var x: c_int = undefined;
        _ = &x;
        var c: u8 = undefined;
        _ = &c;
        var s: [*c]const u8 = undefined;
        _ = &s;
        var iv: [*c]u8 = undefined;
        _ = &iv;
        {
            x = 0;
            while ((@as(c_int, seq[@bitCast(@as(isize, @intCast(x)))]) != 0) and (@as(c_int, seq[@bitCast(@as(isize, @intCast(x)))]) != @as(c_int, ' '))) : (x += 1) {}
        }
        c = seq[@bitCast(@as(isize, @intCast(x)))];
        seq[@bitCast(@as(isize, @intCast(x)))] = 0;
        s = jgetstr(cap_1, seq + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))));
        seq[@bitCast(@as(isize, @intCast(x)))] = c;
        if (((s != null) and ((blk: {
            const tmp = tcompile(cap_1, s, 0, 0, 0, 0);
            iv = tmp;
            break :blk tmp;
        }) != null)) and (((if (iv != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(iv))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0)) > @as(ptrdiff_t, 1)) or (@as(c_int, @as(i8, @bitCast(iv[@as(c_int, 0)]))) < @as(c_int, 0)))) {
            capseq = iv;
            seql = if (iv != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(iv))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0);
            {
                seq += @as(usize, @bitCast(@as(isize, @intCast(x))));
                while (@as(c_int, seq.*) == @as(c_int, ' ')) : (seq += 1) {}
            }
        } else {
            err.* = -@as(c_int, 2);
            return kmap_2;
        }
    }
    if (seql != 0) {
        v = blk: {
            const tmp = @as(c_int, (blk_1: {
                const ref = &capseq;
                const tmp_2 = ref.*;
                ref.* += 1;
                break :blk_1 tmp_2;
            }).*);
            w = tmp;
            break :blk tmp;
        };
        seql -= 1;
    } else {
        seq = range(seq, &v, &w);
        if (!(seq != null)) {
            err.* = -@as(c_int, 1);
            return kmap_2;
        }
    }
    if (!(kmap_2 != null)) {
        kmap_2 = mkkmap();
    }
    if (v <= w) {
        if ((@as(ptrdiff_t, @as(c_int, seq.*)) != 0) or (seql != 0)) {
            var old: [*c]KMAP = @ptrCast(@alignCast(interval_lookup(kmap_2.*.src, null, v)));
            _ = &old;
            if (!(old != null) or !(old.*.what != 0)) {
                kmap_2.*.src = interval_add(kmap_2.*.src, v, w, @ptrCast(@alignCast(kbuild(cap_1, null, seq, bind, err, capseq, seql))));
                kmap_2.*.src_version += 1;
            } else {
                _ = kbuild(cap_1, old, seq, bind, err, capseq, seql);
            }
        } else {
            kmap_2.*.src = interval_add(kmap_2.*.src, v, w, @ptrCast(@alignCast(bind)));
            kmap_2.*.src_version += 1;
        }
    }
    return kmap_2;
}
pub export fn kadd(arg_cap_1: [*c]CAP, arg_kmap_2: [*c]KMAP, arg_seq: [*c]u8, arg_bind: ?*MACRO) c_int {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var kmap_2 = arg_kmap_2;
    _ = &kmap_2;
    var seq = arg_seq;
    _ = &seq;
    var bind = arg_bind;
    _ = &bind;
    var err: c_int = 0;
    _ = &err;
    _ = kbuild(cap_1, kmap_2, seq, bind, &err, null, 0);
    return err;
}
pub export fn kcpy(arg_dest: [*c]KMAP, arg_src: [*c]KMAP) void {
    var dest = arg_dest;
    _ = &dest;
    var src = arg_src;
    _ = &src;
    var l: [*c]struct_interval_list = undefined;
    _ = &l;
    {
        l = src.*.src;
        while (l != null) : (l = l.*.next) {
            if (@as([*c]KMAP, @ptrCast(@alignCast(l.*.map))).*.what == @as(ptrdiff_t, 1)) {
                var k: [*c]KMAP = mkkmap();
                _ = &k;
                kcpy(k, @ptrCast(@alignCast(l.*.map)));
                dest.*.src = interval_add(dest.*.src, l.*.interval.first, l.*.interval.last, @ptrCast(@alignCast(k)));
                dest.*.src_version += 1;
            } else {
                dest.*.src = interval_add(dest.*.src, l.*.interval.first, l.*.interval.last, l.*.map);
                dest.*.src_version += 1;
            }
        }
    }
}
pub export fn kdel(arg_kmap_1: [*c]KMAP, arg_seq: [*c]u8) c_int {
    var kmap_1 = arg_kmap_1;
    _ = &kmap_1;
    var seq = arg_seq;
    _ = &seq;
    var err: c_int = 1;
    _ = &err;
    var v: c_int = undefined;
    _ = &v;
    var w: c_int = undefined;
    _ = &w;
    seq = range(seq, &v, &w);
    if (!(seq != null)) return -@as(c_int, 1);
    if (v <= w) {
        if (@as(c_int, seq.*) != 0) {
            var old: [*c]KMAP = @ptrCast(@alignCast(interval_lookup(kmap_1.*.src, null, v)));
            _ = &old;
            if (old.*.what == @as(ptrdiff_t, 1)) {
                _ = kdel(old, seq);
            } else {
                kmap_1.*.src = interval_add(kmap_1.*.src, v, w, null);
                kmap_1.*.src_version += 1;
            }
        } else {
            kmap_1.*.src = interval_add(kmap_1.*.src, v, w, null);
            kmap_1.*.src_version += 1;
        }
    }
    return err;
}
pub export fn kmap_getcontext(arg_name: [*c]const u8) [*c]KMAP {
    var name = arg_name;
    _ = &name;
    var c: [*c]struct_context = undefined;
    _ = &c;
    {
        c = contexts;
        while (c != null) : (c = c.*.next) if (!(strcmp(c.*.name, name) != 0)) return c.*.kmap;
    }
    c = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_context))))))));
    c.*.next = contexts;
    c.*.name = zdup(name);
    contexts = c;
    return blk: {
        const tmp = mkkmap();
        c.*.kmap = tmp;
        break :blk tmp;
    };
}
pub export fn ngetcontext(arg_name: [*c]const u8) [*c]KMAP {
    var name = arg_name;
    _ = &name;
    var c: [*c]struct_context = undefined;
    _ = &c;
    {
        c = contexts;
        while (c != null) : (c = c.*.next) if (!(strcmp(c.*.name, name) != 0)) return c.*.kmap;
    }
    return null;
}
pub export fn kmap_empty(arg_k: [*c]KMAP) c_int {
    var k = arg_k;
    _ = &k;
    return @intFromBool((@as(?*anyopaque, @ptrCast(@alignCast(k.*.src))) == @as(?*anyopaque, null)) and (k.*.dflt == @as(?*anyopaque, null)));
}
pub export var keymaphist: ?*B = null;
pub fn dokeymap(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var k: [*c]KMAP = ngetcontext(s);
    _ = &k;
    vsrm(s);
    if (notify != null) {
        notify.* = 1;
    }
    if (!(k != null)) {
        msgnw(w, my_gettext("No such keymap"));
        return -@as(c_int, 1);
    }
    rmkbd(w.*.kbd);
    w.*.kbd = mkkbd(k);
    return 0;
}
pub fn get_keymap_list() callconv(.c) [*c][*c]u8 {
    var lst: [*c][*c]u8 = null;
    _ = &lst;
    var c: [*c]struct_context = undefined;
    _ = &c;
    {
        c = contexts;
        while (c != null) : (c = c.*.next) {
            lst = @ptrCast(@alignCast(vaadd(@ptrCast(@alignCast(lst)), @ptrCast(@alignCast(vsncpy(null, 0, c.*.name, slen(c.*.name)))))));
        }
    }
    return lst;
}
pub fn keymap_cmplt(arg_bw_1: ?*BW, arg_k: c_int) callconv(.c) c_int {
    var bw_1 = arg_bw_1;
    _ = &bw_1;
    var k = arg_k;
    _ = &k;
    if (!(keymap_list != null)) {
        keymap_list = get_keymap_list();
    }
    if (!(keymap_list != null)) {
        ttputc(7);
        return 0;
    }
    return simple_cmplt(bw_1, keymap_list);
}
pub export fn ukeymap(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (wmkpw(w, my_gettext("Change keymap: "), &keymaphist, dokeymap, "keymap", null, keymap_cmplt, null, null, locale_map, 0) != null) return 0 else return -@as(c_int, 1);
}


pub const Rtree = struct_Rtree;
pub const interval = struct_interval;
pub const interval_list = struct_interval_list;
pub const macro = struct_macro;
pub const cmd = struct_cmd;
pub const cap = struct_cap;
pub const kmap = struct_kmap;
pub const kbd = struct_kbd;
pub const context = struct_context;
pub const charmap = struct_charmap;
pub const b = struct_b;
pub const bw = struct_bw;
pub const window = struct_window;

comptime {
    if (@sizeOf(struct_kmap) != 280) @compileError("KMAP size mismatch");
    if (@sizeOf(struct_kbd) != 88) @compileError("KBD size mismatch");
    if (@sizeOf(struct_context) != 24) @compileError("context size mismatch");
    if (@sizeOf(struct_window) != 200) @compileError("W size mismatch");
    if (@offsetOf(struct_window, "kbd") != 136) @compileError("W.kbd offset mismatch");
    if (@sizeOf(struct_Rtree) != 248) @compileError("Rtree size mismatch");
    if (@sizeOf(struct_interval_list) != 24) @compileError("interval_list size mismatch");
    if (@sizeOf(struct_cap) != 88) @compileError("CAP size mismatch");
    if (@offsetOf(struct_kmap, "what") != 0) @compileError("KMAP.what offset mismatch");
    if (@offsetOf(struct_kmap, "rtree") != 8) @compileError("KMAP.rtree offset mismatch");
    if (@offsetOf(struct_kmap, "src") != 256) @compileError("KMAP.src offset mismatch");
    if (@offsetOf(struct_kmap, "dflt") != 264) @compileError("KMAP.dflt offset mismatch");
    if (@offsetOf(struct_kmap, "rtree_version") != 272) @compileError("KMAP.rtree_version offset mismatch");
    if (@offsetOf(struct_kmap, "src_version") != 276) @compileError("KMAP.src_version offset mismatch");
}
