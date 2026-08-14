//! Character classes and radix maps — replaces `joe/cclass.c`.
//!
//! Faithful C-ABI Path A port of JOE cclass/rmap/rtree/rset/interval helpers. joe/cclass.c is a tombstone; joe/cclass.h remains the C declaration surface.

const std = @import("std");
const ptrdiff_t = c_long;

const LEAFSIZE: c_int = 16;
const LEAFMASK: c_int = 0xF;
const LEAFSHIFT: c_int = 0;
const THIRDSIZE: c_int = 32;
const THIRDMASK: c_int = 0x1f;
const THIRDSHIFT: c_int = 4;
const SECONDSIZE: c_int = 32;
const SECONDMASK: c_int = 0x1f;
const SECONDSHIFT: c_int = 9;
const TOPSIZE: c_int = 68;
const TOPMASK: c_int = 0x7f;
const TOPSHIFT: c_int = 14;
const UNICODE_LAST: c_int = 0x10FFFF;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn fprintf(f: ?*anyopaque, fmt: [*c]const u8, ...) c_int;
pub extern fn sprintf(buf: [*c]u8, fmt: [*c]const u8, ...) c_int;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn malloc(n: c_ulong) ?*anyopaque;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn memcmp(a: ?*const anyopaque, b: ?*const anyopaque, n: c_ulong) c_int;
pub extern fn exit(status: c_int) void;
pub const off_t = i64;
pub const FILE = anyopaque;
pub extern var __stderrp: ?*FILE;
pub const struct_interval = extern struct {
    first: c_int = 0,
    last: c_int = 0,
};
pub const struct_interval_list = extern struct {
    next: [*c]struct_interval_list = null,
    interval: struct_interval = std.mem.zeroes(struct_interval),
    map: ?*anyopaque = null,
};
pub const struct_First = extern struct {
    entry: [68]c_short = std.mem.zeroes([68]c_short),
};
pub const struct_Mid = extern struct {
    entry: [32]c_short = std.mem.zeroes([32]c_short),
};
pub const struct_Leaf = extern struct {
    entry: [16]?*anyopaque = std.mem.zeroes([16]?*anyopaque),
    refcount: c_int = 0,
};
pub const struct_Ileaf = extern struct {
    entry: [16]c_int = std.mem.zeroes([16]c_int),
    refcount: c_int = 0,
};
const union_unnamed_1 = extern union {
    b: [*c]struct_Mid,
    c: [*c]struct_Mid,
    d: [*c]struct_Leaf,
    e: [*c]struct_Ileaf,
};
pub const struct_Level = extern struct {
    alloc: c_int = 0,
    size: c_int = 0,
    table: union_unnamed_1 = std.mem.zeroes(union_unnamed_1),
};
pub const struct_Rset = extern struct {
    top: struct_First = std.mem.zeroes(struct_First),
    second: struct_Level = std.mem.zeroes(struct_Level),
    mid: struct_Mid = std.mem.zeroes(struct_Mid),
    third: struct_Level = std.mem.zeroes(struct_Level),
};
pub const struct_Rtree = extern struct {
    top: struct_First = std.mem.zeroes(struct_First),
    second: struct_Level = std.mem.zeroes(struct_Level),
    mid: struct_Mid = std.mem.zeroes(struct_Mid),
    third: struct_Level = std.mem.zeroes(struct_Level),
    leaf: struct_Level = std.mem.zeroes(struct_Level),
};
pub const struct_Cclass = extern struct {
    size: ptrdiff_t = 0,
    len: ptrdiff_t = 0,
    intervals: [*c]struct_interval = null,
    rset: [1]struct_Rset = std.mem.zeroes([1]struct_Rset),
};
pub const struct_charmap = extern struct {
    next: [*c]struct_charmap = null,
    name: [*c]const u8 = null,
    type: c_int = 0,
};
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_calloc(nmemb: ptrdiff_t, size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_realloc(ptr: ?*anyopaque, size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn mcpy(a: ?*anyopaque, b: ?*const anyopaque, len: ptrdiff_t) ?*anyopaque;
pub extern fn mmove(d: ?*anyopaque, s: ?*const anyopaque, sz: ptrdiff_t) ?*anyopaque;
pub extern fn jsort(base: ?*anyopaque, num: ptrdiff_t, size: ptrdiff_t, compar: ?*const fn (a: ?*const anyopaque, b: ?*const anyopaque) callconv(.c) c_int) void;
pub extern fn ttsig(sig: c_int) void;
pub extern fn from_uni(cset: [*c]struct_charmap, c: c_int) c_int;
pub fn itest(arg_ia: ?*const anyopaque, arg_ib: ?*const anyopaque) callconv(.c) c_int {
    var ia = arg_ia;
    _ = &ia;
    var ib = arg_ib;
    _ = &ib;
    var a: [*c]const struct_interval = @ptrCast(@alignCast(ia));
    _ = &a;
    var b: [*c]const struct_interval = @ptrCast(@alignCast(ib));
    _ = &b;
    if (a.*.first > b.*.first) return 1 else if (a.*.first < b.*.first) return -@as(c_int, 1) else return 0;
}
pub export fn interval_sort(arg_array: [*c]struct_interval, arg_num: ptrdiff_t) void {
    var array = arg_array;
    _ = &array;
    var num = arg_num;
    _ = &num;
    jsort(@ptrCast(@alignCast(array)), num, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_interval))))), itest);
}
pub export fn interval_test(arg_array: [*c]const struct_interval, arg_size: ptrdiff_t, arg_ch: c_int) ptrdiff_t {
    var array = arg_array;
    _ = &array;
    var size = arg_size;
    _ = &size;
    var ch = arg_ch;
    _ = &ch;
    if (size != 0) {
        var min: ptrdiff_t = 0;
        _ = &min;
        var mid: ptrdiff_t = undefined;
        _ = &mid;
        var max: ptrdiff_t = size - @as(ptrdiff_t, 1);
        _ = &max;
        if ((ch >= array[@bitCast(@as(isize, @intCast(min)))].first) and (ch <= array[@bitCast(@as(isize, @intCast(max)))].last)) {
            while (max >= min) {
                mid = @divTrunc(min + max, @as(ptrdiff_t, 2));
                if (ch > array[@bitCast(@as(isize, @intCast(mid)))].last) {
                    min = mid + @as(ptrdiff_t, 1);
                } else if (ch < array[@bitCast(@as(isize, @intCast(mid)))].first) {
                    max = mid - @as(ptrdiff_t, 1);
                } else return mid;
            }
        }
    }
    return -@as(c_int, 1);
}
pub export fn mkinterval(arg_next: [*c]struct_interval_list, arg_first: c_int, arg_last: c_int, arg_map: ?*anyopaque) [*c]struct_interval_list {
    var next = arg_next;
    _ = &next;
    var first = arg_first;
    _ = &first;
    var last = arg_last;
    _ = &last;
    var map = arg_map;
    _ = &map;
    var interval_list_1: [*c]struct_interval_list = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_interval_list))))))));
    _ = &interval_list_1;
    interval_list_1.*.next = next;
    interval_list_1.*.interval.first = first;
    interval_list_1.*.interval.last = last;
    interval_list_1.*.map = map;
    return interval_list_1;
}
pub export fn rminterval(arg_interval_list_1: [*c]struct_interval_list) void {
    var interval_list_1 = arg_interval_list_1;
    _ = &interval_list_1;
    while (interval_list_1 != null) {
        var n: [*c]struct_interval_list = interval_list_1.*.next;
        _ = &n;
        free(@ptrCast(@alignCast(interval_list_1)));
        interval_list_1 = n;
    }
}
pub export fn interval_add(arg_interval_list_1: [*c]struct_interval_list, arg_first: c_int, arg_last: c_int, arg_map: ?*anyopaque) [*c]struct_interval_list {
    var interval_list_1 = arg_interval_list_1;
    _ = &interval_list_1;
    var first = arg_first;
    _ = &first;
    var last = arg_last;
    _ = &last;
    var map = arg_map;
    _ = &map;
    var e: [*c]struct_interval_list = undefined;
    _ = &e;
    var p: [*c][*c]struct_interval_list = undefined;
    _ = &p;
    {
        p = &interval_list_1;
        while (p.* != null) {
            e = p.*;
            if ((first > (e.*.interval.last + @as(c_int, 1))) or ((first > e.*.interval.last) and (map != e.*.map))) {
                p = &e.*.next;
            } else if ((e.*.interval.first > (last + @as(c_int, 1))) or ((e.*.interval.first > last) and (map != e.*.map))) {
                break;
            } else if (e.*.map == map) {
                if (e.*.interval.first <= first) {
                    if (e.*.interval.last >= last) {
                        return interval_list_1;
                    } else {
                        first = e.*.interval.first;
                        p.* = e.*.next;
                        e.*.next = null;
                        rminterval(e);
                    }
                } else {
                    if (e.*.interval.last <= last) {
                        p.* = e.*.next;
                        e.*.next = null;
                        rminterval(e);
                    } else {
                        e.*.interval.first = first;
                        return interval_list_1;
                    }
                }
            } else {
                if (e.*.interval.first < first) {
                    if (e.*.interval.last <= last) {
                        e.*.interval.last = first - @as(c_int, 1);
                    } else {
                        var org: c_int = e.*.interval.last;
                        _ = &org;
                        var orgmap: ?*anyopaque = e.*.map;
                        _ = &orgmap;
                        e.*.interval.last = first - @as(c_int, 1);
                        p = &e.*.next;
                        p.* = mkinterval(p.*, first, last, map);
                        p = &p.*.*.next;
                        p.* = mkinterval(p.*, last + @as(c_int, 1), org, orgmap);
                        return interval_list_1;
                    }
                } else {
                    if (e.*.interval.last <= last) {
                        p.* = e.*.next;
                        e.*.next = null;
                        rminterval(e);
                    } else {
                        e.*.interval.first = last + @as(c_int, 1);
                        break;
                    }
                }
            }
        }
    }
    p.* = mkinterval(p.*, first, last, map);
    return interval_list_1;
}
pub export fn interval_set(arg_interval_list_1: [*c]struct_interval_list, arg_list: [*c]struct_interval, arg_size: c_int, arg_map: ?*anyopaque) [*c]struct_interval_list {
    var interval_list_1 = arg_interval_list_1;
    _ = &interval_list_1;
    var list = arg_list;
    _ = &list;
    var size = arg_size;
    _ = &size;
    var map = arg_map;
    _ = &map;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (x != size) : (x += 1) {
            interval_list_1 = interval_add(interval_list_1, list[@bitCast(@as(isize, @intCast(x)))].first, list[@bitCast(@as(isize, @intCast(x)))].last, map);
        }
    }
    return interval_list_1;
}
pub export fn interval_lookup(arg_list: [*c]struct_interval_list, arg_dflt: ?*anyopaque, arg_item: c_int) ?*anyopaque {
    var list = arg_list;
    _ = &list;
    var dflt = arg_dflt;
    _ = &dflt;
    var item = arg_item;
    _ = &item;
    if (item < @as(c_int, 0)) {
        item += 256;
    }
    while (list != null) {
        if ((item >= list.*.interval.first) and (item <= list.*.interval.last)) return list.*.map;
        list = list.*.next;
    }
    return dflt;
}
pub export fn interval_show(arg_list: [*c]struct_interval_list) void {
    var list = arg_list;
    _ = &list;
    _ = printf("Interval list at %p\n", list);
    while (list != null) {
        _ = printf("%p show %x..%x -> %p\n", list, list.*.interval.first, list.*.interval.last, list.*.map);
        list = list.*.next;
    }
}
pub export fn rset_lookup(arg_r: [*c]struct_Rset, arg_ch: c_int) c_int {
    var r = arg_r;
    _ = &r;
    var ch = arg_ch;
    _ = &ch;
    var a: c_int = undefined;
    _ = &a;
    var b: c_int = undefined;
    _ = &b;
    var c: c_int = undefined;
    _ = &c;
    var d: c_int = undefined;
    _ = &d;
    if (ch < @as(c_int, 0)) {
        ch += 256;
    }
    a = ch >> @intCast(TOPSHIFT);
    b = SECONDMASK & (ch >> @intCast(SECONDSHIFT));
    c = THIRDMASK & (ch >> @intCast(THIRDSHIFT));
    d = LEAFMASK & (ch >> @intCast(LEAFSHIFT));
    if ((a < @as(c_int, 0)) or (a >= TOPSIZE)) return 0;
    if ((a != 0) or (b != 0)) {
        var idx: c_int = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
        _ = &idx;
        if (idx != -@as(c_int, 1)) {
            idx = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(b)))];
            if (idx != -@as(c_int, 1)) {
                idx = @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(c)))];
                return @intFromBool(((@as(c_int, 1) << @intCast(d)) & idx) != @as(c_int, 0));
            }
        }
    } else {
        var idx: c_int = @as([*]c_short, @ptrCast(&r.*.mid.entry))[@bitCast(@as(isize, @intCast(c)))];
        _ = &idx;
        return @intFromBool(((@as(c_int, 1) << @intCast(d)) & idx) != @as(c_int, 0));
    }
    return 0;
}
pub export fn rset_lookup_unopt(arg_r: [*c]struct_Rset, arg_ch: c_int) c_int {
    var r = arg_r;
    _ = &r;
    var ch = arg_ch;
    _ = &ch;
    var a: c_int = undefined;
    _ = &a;
    var b: c_int = undefined;
    _ = &b;
    var c: c_int = undefined;
    _ = &c;
    var d: c_int = undefined;
    _ = &d;
    var idx: c_int = undefined;
    _ = &idx;
    if (ch < @as(c_int, 0)) {
        ch += 256;
    }
    a = ch >> @intCast(TOPSHIFT);
    b = SECONDMASK & (ch >> @intCast(SECONDSHIFT));
    c = THIRDMASK & (ch >> @intCast(THIRDSHIFT));
    d = LEAFMASK & (ch >> @intCast(LEAFSHIFT));
    if (a >= TOPSIZE) return 0;
    idx = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
    if (idx != -@as(c_int, 1)) {
        idx = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(b)))];
        if (idx != -@as(c_int, 1)) {
            idx = @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(c)))];
            return @intFromBool(((@as(c_int, 1) << @intCast(d)) & idx) != @as(c_int, 0));
        }
    }
    return 0;
}
pub export fn rset_init(arg_r: [*c]struct_Rset) void {
    var r = arg_r;
    _ = &r;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (x != TOPSIZE) : (x += 1) {
            @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(x)))] = @truncate(-@as(c_int, 1));
        }
    }
    r.*.second.alloc = 0;
    r.*.second.size = 1;
    r.*.second.table.b = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, r.*.second.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
    r.*.third.alloc = 0;
    r.*.third.size = 1;
    r.*.third.table.c = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, r.*.third.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
}
pub export fn rset_clr(arg_r: [*c]struct_Rset) void {
    var r = arg_r;
    _ = &r;
    joe_free(@ptrCast(@alignCast(r.*.second.table.b)));
    joe_free(@ptrCast(@alignCast(r.*.third.table.c)));
}
pub fn rset_alloc(arg_l: [*c]struct_Level, arg_levelno: c_int) callconv(.c) c_short {
    var l = arg_l;
    _ = &l;
    var levelno = arg_levelno;
    _ = &levelno;
    var x: c_int = undefined;
    _ = &x;
    if (l.*.alloc == l.*.size) {
        l.*.size *= 2;
        while (true) {
            switch (levelno) {
                @as(c_int, 1) => {
                    {
                        l.*.table.b = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(l.*.table.b)), @as(ptrdiff_t, l.*.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
                        break;
                    }
                },
                @as(c_int, 2) => {
                    {
                        l.*.table.c = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(l.*.table.c)), @as(ptrdiff_t, l.*.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
                        break;
                    }
                },
                else => {},
            }
            break;
        }
    }
    while (true) {
        switch (levelno) {
            @as(c_int, 1) => {
                {
                    {
                        x = 0;
                        while (x != SECONDSIZE) : (x += 1) {
                            @as([*]c_short, @ptrCast(&l.*.table.b[@bitCast(@as(isize, @intCast(l.*.alloc)))].entry))[@bitCast(@as(isize, @intCast(x)))] = @truncate(-@as(c_int, 1));
                        }
                    }
                    break;
                }
            },
            @as(c_int, 2) => {
                {
                    {
                        x = 0;
                        while (x != THIRDSIZE) : (x += 1) {
                            @as([*]c_short, @ptrCast(&l.*.table.c[@bitCast(@as(isize, @intCast(l.*.alloc)))].entry))[@bitCast(@as(isize, @intCast(x)))] = 0;
                        }
                    }
                    break;
                }
            },
            else => {},
        }
        break;
    }
    if (l.*.alloc == @as(c_int, 32768)) {
        _ = fprintf(__stderrp, "rset_alloc overflow\r\n");
        exit(-@as(c_int, 1));
    }
    return @truncate(blk: {
        const ref = &l.*.alloc;
        const tmp = ref.*;
        ref.* += 1;
        break :blk tmp;
    });
}
pub export fn rset_add(arg_r: [*c]struct_Rset, arg_ch: c_int, arg_che: c_int) void {
    var r = arg_r;
    _ = &r;
    var ch = arg_ch;
    _ = &ch;
    var che = arg_che;
    _ = &che;
    var a: c_int = TOPMASK & (ch >> @intCast(TOPSHIFT));
    _ = &a;
    var b: c_int = SECONDMASK & (ch >> @intCast(SECONDSHIFT));
    _ = &b;
    var c: c_int = THIRDMASK & (ch >> @intCast(THIRDSHIFT));
    _ = &c;
    var d: c_int = LEAFMASK & (ch >> @intCast(LEAFSHIFT));
    _ = &d;
    var ib: c_short = undefined;
    _ = &ib;
    var ic: c_short = undefined;
    _ = &ic;
    while (ch <= che) {
        if (a >= TOPSIZE) return;
        ib = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
        if (@as(c_int, ib) == -@as(c_int, 1)) {
            @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))] = blk: {
                const tmp = rset_alloc(&r.*.second, 1);
                ib = tmp;
                break :blk tmp;
            };
        }
        while (ch <= che) {
            ic = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(ib)))].entry))[@bitCast(@as(isize, @intCast(b)))];
            if (@as(c_int, ic) == -@as(c_int, 1)) {
                @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(ib)))].entry))[@bitCast(@as(isize, @intCast(b)))] = blk: {
                    const tmp = rset_alloc(&r.*.third, 2);
                    ic = tmp;
                    break :blk tmp;
                };
            }
            while (ch <= che) {
                {
                    const ref = &@as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))];
                    ref.* = @truncate(@as(c_int, ref.*) | @as(c_int, @as(c_short, @truncate(@as(c_int, 1) << @intCast(d)))));
                }
                ch += 1;
                if ((blk: {
                    const ref = &d;
                    ref.* += 1;
                    break :blk ref.*;
                }) == LEAFSIZE) {
                    d = 0;
                    if ((blk: {
                        const ref = &c;
                        ref.* += 1;
                        break :blk ref.*;
                    }) == THIRDSIZE) {
                        c = 0;
                        break;
                    }
                }
            }
            if ((blk: {
                const ref = &b;
                ref.* += 1;
                break :blk ref.*;
            }) == SECONDSIZE) {
                b = 0;
                break;
            }
        }
        a += 1;
    }
}
pub export fn rset_opt(arg_r: [*c]struct_Rset) void {
    var r = arg_r;
    _ = &r;
    var x: c_int = undefined;
    _ = &x;
    var idx: c_int = undefined;
    _ = &idx;
    {
        x = 0;
        while (x != THIRDSIZE) : (x += 1) {
            @as([*]c_short, @ptrCast(&r.*.mid.entry))[@bitCast(@as(isize, @intCast(x)))] = 0;
        }
    }
    idx = @as([*]c_short, @ptrCast(&r.*.top.entry))[@as(c_int, 0)];
    if (idx != -@as(c_int, 1)) {
        idx = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(idx)))].entry))[@as(c_int, 0)];
        if (idx != -@as(c_int, 1)) {
            _ = mcpy(@ptrCast(@alignCast(@as([*c]c_short, @ptrCast(@alignCast(&r.*.mid.entry))))), @ptrCast(@alignCast(@as([*c]c_short, @ptrCast(@alignCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(idx)))].entry))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(r.*.mid.entry)))))));
        }
    }
}
pub export fn rset_set(arg_r: [*c]struct_Rset, arg_array: [*c]struct_interval, arg_size: ptrdiff_t) void {
    var r = arg_r;
    _ = &r;
    var array = arg_array;
    _ = &array;
    var size = arg_size;
    _ = &size;
    var y: ptrdiff_t = undefined;
    _ = &y;
    {
        y = 0;
        while (y != size) : (y += 1) {
            rset_add(r, array[@bitCast(@as(isize, @intCast(y)))].first, array[@bitCast(@as(isize, @intCast(y)))].last);
        }
    }
}
pub export fn rset_show(arg_r: [*c]struct_Rset) void {
    var r = arg_r;
    _ = &r;
    var first: c_int = -@as(c_int, 2);
    _ = &first;
    var last: c_int = -@as(c_int, 2);
    _ = &last;
    var a: c_int = undefined;
    _ = &a;
    var len: ptrdiff_t = 0;
    _ = &len;
    var total: ptrdiff_t = 0;
    _ = &total;
    _ = printf("Rset at %p\n", r);
    len = @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Rset)))));
    _ = printf("Top level size = %lld\n", @as(c_longlong, len));
    total += len;
    len = @as(ptrdiff_t, r.*.second.alloc) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid)))));
    _ = printf("Second level size = %lld (%d entries)\n", @as(c_longlong, len), r.*.second.alloc);
    total += len;
    len = @as(ptrdiff_t, r.*.third.alloc) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid)))));
    _ = printf("Third level size = %lld (%d entries)\n", @as(c_longlong, len), r.*.third.alloc);
    total += len;
    _ = printf("Total size = %lld bytes\n", @as(c_longlong, total));
    {
        a = 0;
        while (a != TOPSIZE) : (a += 1) {
            var ib: c_int = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
            _ = &ib;
            if (ib != -@as(c_int, 1)) {
                var b: c_int = undefined;
                _ = &b;
                {
                    b = 0;
                    while (b != SECONDSIZE) : (b += 1) {
                        var ic: c_int = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(ib)))].entry))[@bitCast(@as(isize, @intCast(b)))];
                        _ = &ic;
                        if (ic != -@as(c_int, 1)) {
                            var c: c_int = undefined;
                            _ = &c;
                            {
                                c = 0;
                                while (c != THIRDSIZE) : (c += 1) {
                                    var id: c_int = @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))];
                                    _ = &id;
                                    var d: c_int = undefined;
                                    _ = &d;
                                    {
                                        d = 0;
                                        while (d != LEAFSIZE) : (d += 1) {
                                            if ((id & (@as(c_int, 1) << @intCast(d))) != 0) {
                                                var ch: c_int = (((a << @intCast(TOPSHIFT)) + (b << @intCast(SECONDSHIFT))) + (c << @intCast(THIRDSHIFT))) + d;
                                                _ = &ch;
                                                if (ch == (last + @as(c_int, 1))) {
                                                    last = ch;
                                                } else if (first != -@as(c_int, 2)) {
                                                    _ = printf("\t{ 0x%4.4X, 0x%4.4X },\n", first, last);
                                                    first = blk: {
                                                        const tmp = ch;
                                                        last = tmp;
                                                        break :blk tmp;
                                                    };
                                                } else {
                                                    first = blk: {
                                                        const tmp = ch;
                                                        last = tmp;
                                                        break :blk tmp;
                                                    };
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if (first != -@as(c_int, 2)) {
        _ = printf("\t{ 0x%4.4X, 0x%4.4X },\n", first, last);
    }
}
pub export fn rtree_lookup(arg_r: [*c]struct_Rtree, arg_ch: c_int) ?*anyopaque {
    var r = arg_r;
    _ = &r;
    var ch = arg_ch;
    _ = &ch;
    var a: c_int = undefined;
    _ = &a;
    var b: c_int = undefined;
    _ = &b;
    var c: c_int = undefined;
    _ = &c;
    var d: c_int = undefined;
    _ = &d;
    if (ch < @as(c_int, 0)) {
        ch += 256;
    }
    a = ch >> @intCast(TOPSHIFT);
    b = SECONDMASK & (ch >> @intCast(SECONDSHIFT));
    c = THIRDMASK & (ch >> @intCast(THIRDSHIFT));
    d = LEAFMASK & (ch >> @intCast(LEAFSHIFT));
    if (a >= TOPSIZE) return null;
    if ((a != 0) or (b != 0)) {
        var idx: c_int = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
        _ = &idx;
        if (idx != -@as(c_int, 1)) {
            idx = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(b)))];
            if (idx != -@as(c_int, 1)) {
                idx = @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(c)))];
                if (idx != -@as(c_int, 1)) return @as([*]?*anyopaque, @ptrCast(&r.*.leaf.table.d[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(d)))];
            }
        }
    } else {
        var idx: c_int = @as([*]c_short, @ptrCast(&r.*.mid.entry))[@bitCast(@as(isize, @intCast(c)))];
        _ = &idx;
        if (idx != -@as(c_int, 1)) return @as([*]?*anyopaque, @ptrCast(&r.*.leaf.table.d[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(d)))];
    }
    return null;
}
pub export fn rtree_lookup_unopt(arg_r: [*c]struct_Rtree, arg_ch: c_int) ?*anyopaque {
    var r = arg_r;
    _ = &r;
    var ch = arg_ch;
    _ = &ch;
    var a: c_int = undefined;
    _ = &a;
    var b: c_int = undefined;
    _ = &b;
    var c: c_int = undefined;
    _ = &c;
    var d: c_int = undefined;
    _ = &d;
    var idx: c_int = undefined;
    _ = &idx;
    if (ch < @as(c_int, 0)) {
        ch += 256;
    }
    a = ch >> @intCast(TOPSHIFT);
    b = SECONDMASK & (ch >> @intCast(SECONDSHIFT));
    c = THIRDMASK & (ch >> @intCast(THIRDSHIFT));
    d = LEAFMASK & (ch >> @intCast(LEAFSHIFT));
    if (a >= TOPSIZE) return null;
    idx = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
    if (idx != -@as(c_int, 1)) {
        idx = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(b)))];
        if (idx != -@as(c_int, 1)) {
            idx = @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(c)))];
            if (idx != -@as(c_int, 1)) return @as([*]?*anyopaque, @ptrCast(&r.*.leaf.table.d[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(d)))];
        }
    }
    return null;
}
pub export fn rtree_init(arg_r: [*c]struct_Rtree) void {
    var r = arg_r;
    _ = &r;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (x != TOPSIZE) : (x += 1) {
            @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(x)))] = @truncate(-@as(c_int, 1));
        }
    }
    r.*.second.alloc = 0;
    r.*.second.size = 1;
    r.*.second.table.b = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, r.*.second.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
    r.*.third.alloc = 0;
    r.*.third.size = 1;
    r.*.third.table.c = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, r.*.third.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
    r.*.leaf.alloc = 0;
    r.*.leaf.size = 1;
    r.*.leaf.table.d = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, r.*.leaf.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Leaf))))))));
}
pub export fn rtree_clr(arg_r: [*c]struct_Rtree) void {
    var r = arg_r;
    _ = &r;
    joe_free(@ptrCast(@alignCast(r.*.second.table.b)));
    joe_free(@ptrCast(@alignCast(r.*.third.table.c)));
    joe_free(@ptrCast(@alignCast(r.*.leaf.table.d)));
}
pub fn rtree_alloc(arg_l: [*c]struct_Level, arg_levelno: c_int) callconv(.c) c_short {
    var l = arg_l;
    _ = &l;
    var levelno = arg_levelno;
    _ = &levelno;
    var x: c_int = undefined;
    _ = &x;
    if (l.*.alloc == l.*.size) {
        l.*.size *= 2;
        while (true) {
            switch (levelno) {
                @as(c_int, 1) => {
                    {
                        l.*.table.b = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(l.*.table.b)), @as(ptrdiff_t, l.*.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
                        break;
                    }
                },
                @as(c_int, 2) => {
                    {
                        l.*.table.c = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(l.*.table.c)), @as(ptrdiff_t, l.*.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
                        break;
                    }
                },
                @as(c_int, 3) => {
                    {
                        l.*.table.d = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(l.*.table.d)), @as(ptrdiff_t, l.*.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Leaf))))))));
                        break;
                    }
                },
                else => {},
            }
            break;
        }
    }
    while (true) {
        switch (levelno) {
            @as(c_int, 1) => {
                {
                    {
                        x = 0;
                        while (x != SECONDSIZE) : (x += 1) {
                            @as([*]c_short, @ptrCast(&l.*.table.b[@bitCast(@as(isize, @intCast(l.*.alloc)))].entry))[@bitCast(@as(isize, @intCast(x)))] = @truncate(-@as(c_int, 1));
                        }
                    }
                    break;
                }
            },
            @as(c_int, 2) => {
                {
                    {
                        x = 0;
                        while (x != THIRDSIZE) : (x += 1) {
                            @as([*]c_short, @ptrCast(&l.*.table.c[@bitCast(@as(isize, @intCast(l.*.alloc)))].entry))[@bitCast(@as(isize, @intCast(x)))] = @truncate(-@as(c_int, 1));
                        }
                    }
                    break;
                }
            },
            @as(c_int, 3) => {
                {
                    {
                        x = 0;
                        while (x != LEAFSIZE) : (x += 1) {
                            @as([*]?*anyopaque, @ptrCast(&l.*.table.d[@bitCast(@as(isize, @intCast(l.*.alloc)))].entry))[@bitCast(@as(isize, @intCast(x)))] = null;
                        }
                    }
                    l.*.table.d[@bitCast(@as(isize, @intCast(l.*.alloc)))].refcount = 1;
                    break;
                }
            },
            else => {},
        }
        break;
    }
    if (l.*.alloc == @as(c_int, 32768)) {
        _ = fprintf(__stderrp, "rtree_alloc overflow\r\n");
        exit(-@as(c_int, 1));
    }
    return @truncate(blk: {
        const ref = &l.*.alloc;
        const tmp = ref.*;
        ref.* += 1;
        break :blk tmp;
    });
}
pub export fn rtree_add(arg_r: [*c]struct_Rtree, arg_ch: c_int, arg_che: c_int, arg_map: ?*anyopaque) void {
    var r = arg_r;
    _ = &r;
    var ch = arg_ch;
    _ = &ch;
    var che = arg_che;
    _ = &che;
    var map = arg_map;
    _ = &map;
    var a: c_int = TOPMASK & (ch >> @intCast(TOPSHIFT));
    _ = &a;
    var b: c_int = SECONDMASK & (ch >> @intCast(SECONDSHIFT));
    _ = &b;
    var c: c_int = THIRDMASK & (ch >> @intCast(THIRDSHIFT));
    _ = &c;
    var d: c_int = LEAFMASK & (ch >> @intCast(LEAFSHIFT));
    _ = &d;
    var ib: c_short = undefined;
    _ = &ib;
    var ic: c_short = undefined;
    _ = &ic;
    var id: c_short = undefined;
    _ = &id;
    while (ch <= che) {
        if (a >= TOPSIZE) return;
        ib = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
        if (@as(c_int, ib) == -@as(c_int, 1)) {
            @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))] = blk: {
                const tmp = rtree_alloc(&r.*.second, 1);
                ib = tmp;
                break :blk tmp;
            };
        }
        while (ch <= che) {
            ic = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(ib)))].entry))[@bitCast(@as(isize, @intCast(b)))];
            if (@as(c_int, ic) == -@as(c_int, 1)) {
                @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(ib)))].entry))[@bitCast(@as(isize, @intCast(b)))] = blk: {
                    const tmp = rtree_alloc(&r.*.third, 2);
                    ic = tmp;
                    break :blk tmp;
                };
            }
            while (ch <= che) {
                id = @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))];
                if (@as(c_int, id) == -@as(c_int, 1)) {
                    @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))] = blk: {
                        const tmp = rtree_alloc(&r.*.leaf, 3);
                        id = tmp;
                        break :blk tmp;
                    };
                }
                while (ch <= che) {
                    var l: [*c]struct_Leaf = r.*.leaf.table.d + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, id)))));
                    _ = &l;
                    if (l.*.refcount != @as(c_int, 1)) {
                        var org: [*c]struct_Leaf = l;
                        _ = &org;
                        @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))] = blk: {
                            const tmp = rtree_alloc(&r.*.leaf, 3);
                            id = tmp;
                            break :blk tmp;
                        };
                        l = r.*.leaf.table.d + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, id)))));
                        _ = mcpy(@ptrCast(@alignCast(l)), @ptrCast(@alignCast(org)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Leaf))))));
                        org.*.refcount -= 1;
                        l.*.refcount = 1;
                    }
                    @as([*]?*anyopaque, @ptrCast(&l.*.entry))[@bitCast(@as(isize, @intCast(d)))] = map;
                    if ((((d == (LEAFSIZE - @as(c_int, 1))) and (@as(c_int, id) != 0)) and (@as(c_int, id) == (r.*.leaf.alloc - @as(c_int, 1)))) and !(memcmp(@ptrCast(@alignCast(@as([*c]?*anyopaque, @ptrCast(@alignCast(&l.*.entry))))), @ptrCast(@alignCast(@as([*c]?*anyopaque, @ptrCast(@alignCast(&r.*.leaf.table.d[@bitCast(@as(isize, @intCast(@as(c_int, id) - @as(c_int, 1))))].entry))))), @bitCast(@as(c_long, @as(ptrdiff_t, LEAFSIZE) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(?*anyopaque)))))))) != 0)) {
                        r.*.leaf.alloc -= 1;
                        id -= 1;
                        l = r.*.leaf.table.d + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, id)))));
                        l.*.refcount += 1;
                        @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))] = id;
                    }
                    ch += 1;
                    if ((blk: {
                        const ref = &d;
                        ref.* += 1;
                        break :blk ref.*;
                    }) == LEAFSIZE) {
                        d = 0;
                        break;
                    }
                }
                if ((blk: {
                    const ref = &c;
                    ref.* += 1;
                    break :blk ref.*;
                }) == THIRDSIZE) {
                    c = 0;
                    break;
                }
            }
            if ((blk: {
                const ref = &b;
                ref.* += 1;
                break :blk ref.*;
            }) == SECONDSIZE) {
                b = 0;
                break;
            }
        }
        a += 1;
    }
}
pub const struct_rhentry = extern struct {
    next: [*c]struct_rhentry = null,
    leaf: [*c]struct_Leaf = null,
    idx: c_int = 0,
};
pub fn rhhash(arg_l: [*c]struct_Leaf) callconv(.c) ptrdiff_t {
    var l = arg_l;
    _ = &l;
    var hval: ptrdiff_t = 0;
    _ = &hval;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (x != LEAFSIZE) : (x += 1) {
            hval = ((hval << @intCast(@as(ptrdiff_t, 4))) + (hval >> @intCast(@as(ptrdiff_t, 28)))) + @as(ptrdiff_t, @intCast(@intFromPtr(@as([*]?*anyopaque, @ptrCast(&l.*.entry))[@bitCast(@as(isize, @intCast(x)))])));
        }
    }
    return hval;
}
pub export fn rtree_opt(arg_r: [*c]struct_Rtree) void {
    var r = arg_r;
    _ = &r;
    var idx: ptrdiff_t = undefined;
    _ = &idx;
    var x: c_int = undefined;
    _ = &x;
    var rhsize: c_int = undefined;
    _ = &rhsize;
    var rhtable: [*c][*c]struct_rhentry = undefined;
    _ = &rhtable;
    var equiv: [*c]c_int = undefined;
    _ = &equiv;
    var repl: [*c]c_short = undefined;
    _ = &repl;
    var dupcount: c_int = undefined;
    _ = &dupcount;
    var newalloc: c_int = undefined;
    _ = &newalloc;
    var l: [*c]struct_Leaf = undefined;
    _ = &l;
    equiv = @ptrCast(@alignCast(if (r.*.leaf.alloc != 0) @as(?*anyopaque, @ptrCast(@alignCast(@as([*c]c_int, @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))) * @as(ptrdiff_t, r.*.leaf.alloc)))))))) else @as(?*anyopaque, null)));
    repl = @ptrCast(@alignCast(if (r.*.leaf.alloc != 0) @as(?*anyopaque, @ptrCast(@alignCast(@as([*c]c_short, @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_short))))) * @as(ptrdiff_t, r.*.leaf.alloc)))))))) else @as(?*anyopaque, null)));
    dupcount = 0;
    rhsize = 1024;
    rhtable = @ptrCast(@alignCast(joe_calloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]struct_rhentry))))), rhsize)));
    {
        x = 0;
        while (x != r.*.leaf.alloc) : (x += 1) {
            var rh: [*c]struct_rhentry = undefined;
            _ = &rh;
            idx = @as(ptrdiff_t, rhsize - @as(c_int, 1)) & rhhash(r.*.leaf.table.d + @as(usize, @bitCast(@as(isize, @intCast(x)))));
            {
                rh = rhtable[@bitCast(@as(isize, @intCast(idx)))];
                while (rh != null) : (rh = rh.*.next) if (!(memcmp(@ptrCast(@alignCast(@as([*c]?*anyopaque, @ptrCast(@alignCast(&rh.*.leaf.*.entry))))), @ptrCast(@alignCast(@as([*c]?*anyopaque, @ptrCast(@alignCast(&r.*.leaf.table.d[@bitCast(@as(isize, @intCast(x)))].entry))))), @bitCast(@as(c_long, @as(ptrdiff_t, LEAFSIZE) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(?*anyopaque)))))))) != 0)) break;
            }
            if (rh != null) {
                equiv[@bitCast(@as(isize, @intCast(x)))] = rh.*.idx;
                dupcount += 1;
            } else {
                equiv[@bitCast(@as(isize, @intCast(x)))] = -@as(c_int, 1);
                rh = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_rhentry))))))));
                rh.*.next = rhtable[@bitCast(@as(isize, @intCast(idx)))];
                rh.*.idx = x;
                rh.*.leaf = r.*.leaf.table.d + @as(usize, @bitCast(@as(isize, @intCast(x))));
                rhtable[@bitCast(@as(isize, @intCast(idx)))] = rh;
            }
        }
    }
    {
        x = 0;
        while (x != @as(c_int, 1024)) : (x += 1) {
            var rh: [*c]struct_rhentry = undefined;
            _ = &rh;
            var nh: [*c]struct_rhentry = undefined;
            _ = &nh;
            {
                rh = rhtable[@bitCast(@as(isize, @intCast(x)))];
                while (rh != null) : (rh = nh) {
                    nh = rh.*.next;
                    joe_free(@ptrCast(@alignCast(rh)));
                }
            }
        }
    }
    joe_free(@ptrCast(@alignCast(rhtable)));
    newalloc = r.*.leaf.alloc - dupcount;
    l = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Leaf))))) * @as(ptrdiff_t, newalloc))));
    idx = 0;
    {
        x = 0;
        while (x != r.*.leaf.alloc) : (x += 1) if (equiv[@bitCast(@as(isize, @intCast(x)))] == -@as(c_int, 1)) {
            _ = mcpy(@ptrCast(@alignCast(l + @as(usize, @bitCast(@as(isize, @intCast(idx)))))), @ptrCast(@alignCast(r.*.leaf.table.d + @as(usize, @bitCast(@as(isize, @intCast(x)))))), @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Leaf)))));
            l[@bitCast(@as(isize, @intCast(idx)))].refcount = 1;
            if (idx > @as(ptrdiff_t, 32767)) {
                _ = fprintf(__stderrp, "cclass too complex\r\n");
                ttsig(-@as(c_int, 1));
            }
            repl[@bitCast(@as(isize, @intCast(x)))] = @truncate(idx);
            idx += 1;
        };
    }
    {
        x = 0;
        while (x != r.*.leaf.alloc) : (x += 1) if (equiv[@bitCast(@as(isize, @intCast(x)))] != -@as(c_int, 1)) {
            repl[@bitCast(@as(isize, @intCast(x)))] = repl[@bitCast(@as(isize, @intCast(equiv[@bitCast(@as(isize, @intCast(x)))])))];
            l[@bitCast(@as(isize, @intCast(repl[@bitCast(@as(isize, @intCast(equiv[@bitCast(@as(isize, @intCast(x)))])))])))].refcount += 1;
        };
    }
    joe_free(@ptrCast(@alignCast(r.*.leaf.table.d)));
    r.*.leaf.table.d = l;
    r.*.leaf.alloc = newalloc;
    r.*.leaf.size = newalloc;
    {
        x = 0;
        while (x != r.*.third.alloc) : (x += 1) {
            idx = 0;
            while (idx != @as(ptrdiff_t, THIRDSIZE)) : (idx += 1) if (@as(c_int, @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(x)))].entry))[@bitCast(@as(isize, @intCast(idx)))]) != -@as(c_int, 1)) {
                @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(x)))].entry))[@bitCast(@as(isize, @intCast(idx)))] = repl[@bitCast(@as(isize, @intCast(@as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(x)))].entry))[@bitCast(@as(isize, @intCast(idx)))])))];
            };
        }
    }
    joe_free(@ptrCast(@alignCast(equiv)));
    joe_free(@ptrCast(@alignCast(repl)));
    {
        x = 0;
        while (x != THIRDSIZE) : (x += 1) {
            @as([*]c_short, @ptrCast(&r.*.mid.entry))[@bitCast(@as(isize, @intCast(x)))] = @truncate(-@as(c_int, 1));
        }
    }
    idx = @as([*]c_short, @ptrCast(&r.*.top.entry))[@as(c_int, 0)];
    if (idx != @as(ptrdiff_t, -@as(c_int, 1))) {
        idx = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(idx)))].entry))[@as(c_int, 0)];
        if (idx != @as(ptrdiff_t, -@as(c_int, 1))) {
            _ = mcpy(@ptrCast(@alignCast(@as([*c]c_short, @ptrCast(@alignCast(&r.*.mid.entry))))), @ptrCast(@alignCast(@as([*c]c_short, @ptrCast(@alignCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(idx)))].entry))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(r.*.mid.entry)))))));
        }
    }
}
pub export fn rtree_set(arg_r: [*c]struct_Rtree, arg_array: [*c]struct_interval, arg_len: ptrdiff_t, arg_map: ?*anyopaque) void {
    var r = arg_r;
    _ = &r;
    var array = arg_array;
    _ = &array;
    var len = arg_len;
    _ = &len;
    var map = arg_map;
    _ = &map;
    var y: ptrdiff_t = undefined;
    _ = &y;
    {
        y = 0;
        while (y != len) : (y += 1) {
            rtree_add(r, array[@bitCast(@as(isize, @intCast(y)))].first, array[@bitCast(@as(isize, @intCast(y)))].last, map);
        }
    }
}
pub export fn rtree_build(arg_r: [*c]struct_Rtree, arg_l: [*c]struct_interval_list) void {
    var r = arg_r;
    _ = &r;
    var l = arg_l;
    _ = &l;
    while (l != null) {
        rtree_add(r, l.*.interval.first, l.*.interval.last, l.*.map);
        l = l.*.next;
    }
}
pub export fn rtree_show(arg_r: [*c]struct_Rtree) void {
    var r = arg_r;
    _ = &r;
    var first: c_int = -@as(c_int, 2);
    _ = &first;
    var last: c_int = -@as(c_int, 2);
    _ = &last;
    var val: ?*anyopaque = null;
    _ = &val;
    var a: c_int = undefined;
    _ = &a;
    var len: ptrdiff_t = 0;
    _ = &len;
    var total: ptrdiff_t = 0;
    _ = &total;
    _ = printf("Rtree at %p\n", r);
    len = @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Rtree)))));
    _ = printf("Top level size = %lld\n", @as(c_longlong, len));
    total += len;
    len = @as(ptrdiff_t, r.*.second.alloc) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid)))));
    _ = printf("Second level size = %lld (%d entries)\n", @as(c_longlong, len), r.*.second.alloc);
    total += len;
    len = @as(ptrdiff_t, r.*.third.alloc) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid)))));
    _ = printf("Third level size = %lld (%d entries)\n", @as(c_longlong, len), r.*.third.alloc);
    total += len;
    len = @as(ptrdiff_t, r.*.leaf.alloc) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Leaf)))));
    _ = printf("Fourth level size = %lld (%d entries)\n", @as(c_longlong, len), r.*.leaf.alloc);
    total += len;
    _ = printf("Total size = %lld bytes\n", @as(c_longlong, total));
    {
        a = 0;
        while (a != TOPSIZE) : (a += 1) {
            var ib: c_int = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
            _ = &ib;
            if (ib != -@as(c_int, 1)) {
                var b: c_int = undefined;
                _ = &b;
                {
                    b = 0;
                    while (b != SECONDSIZE) : (b += 1) {
                        var ic: c_int = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(ib)))].entry))[@bitCast(@as(isize, @intCast(b)))];
                        _ = &ic;
                        if (ic != -@as(c_int, 1)) {
                            var c: c_int = undefined;
                            _ = &c;
                            {
                                c = 0;
                                while (c != THIRDSIZE) : (c += 1) {
                                    var id: c_int = @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))];
                                    _ = &id;
                                    if (id != -@as(c_int, 1)) {
                                        var d: c_int = undefined;
                                        _ = &d;
                                        {
                                            d = 0;
                                            while (d != LEAFSIZE) : (d += 1) {
                                                var ie: ?*anyopaque = @as([*]?*anyopaque, @ptrCast(&r.*.leaf.table.d[@bitCast(@as(isize, @intCast(id)))].entry))[@bitCast(@as(isize, @intCast(d)))];
                                                _ = &ie;
                                                var ch: c_int = (((a << @intCast(TOPSHIFT)) + (b << @intCast(SECONDSHIFT))) + (c << @intCast(THIRDSHIFT))) + d;
                                                _ = &ch;
                                                if ((ch == (last + @as(c_int, 1))) and (ie == val)) {
                                                    last = ch;
                                                } else if (first != -@as(c_int, 2)) {
                                                    _ = printf("%p show %x %x %p\n", r, first, last, val);
                                                    first = blk: {
                                                        const tmp = ch;
                                                        last = tmp;
                                                        break :blk tmp;
                                                    };
                                                    val = ie;
                                                } else {
                                                    first = blk: {
                                                        const tmp = ch;
                                                        last = tmp;
                                                        break :blk tmp;
                                                    };
                                                    val = ie;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if (first != -@as(c_int, 2)) {
        _ = printf("%p show %x %x %p\n", r, first, last, val);
    }
}
pub export fn rmap_lookup(arg_r: [*c]struct_Rtree, arg_ch: c_int, arg_dflt: c_int) c_int {
    var r = arg_r;
    _ = &r;
    var ch = arg_ch;
    _ = &ch;
    var dflt = arg_dflt;
    _ = &dflt;
    var a: c_int = undefined;
    _ = &a;
    var b: c_int = undefined;
    _ = &b;
    var c: c_int = undefined;
    _ = &c;
    var d: c_int = undefined;
    _ = &d;
    if (ch < @as(c_int, 0)) {
        ch += 256;
    }
    a = ch >> @intCast(TOPSHIFT);
    b = SECONDMASK & (ch >> @intCast(SECONDSHIFT));
    c = THIRDMASK & (ch >> @intCast(THIRDSHIFT));
    d = LEAFMASK & (ch >> @intCast(LEAFSHIFT));
    if (a >= TOPSIZE) return dflt;
    if ((a != 0) or (b != 0)) {
        var idx: c_int = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
        _ = &idx;
        if (idx != -@as(c_int, 1)) {
            idx = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(b)))];
            if (idx != -@as(c_int, 1)) {
                idx = @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(c)))];
                if (idx != -@as(c_int, 1)) return @as([*]c_int, @ptrCast(&r.*.leaf.table.e[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(d)))];
            }
        }
    } else {
        var idx: c_int = @as([*]c_short, @ptrCast(&r.*.mid.entry))[@bitCast(@as(isize, @intCast(c)))];
        _ = &idx;
        if (idx != -@as(c_int, 1)) return @as([*]c_int, @ptrCast(&r.*.leaf.table.e[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(d)))];
    }
    return dflt;
}
pub export fn rmap_lookup_unopt(arg_r: [*c]struct_Rtree, arg_ch: c_int, arg_dflt: c_int) c_int {
    var r = arg_r;
    _ = &r;
    var ch = arg_ch;
    _ = &ch;
    var dflt = arg_dflt;
    _ = &dflt;
    var a: c_int = undefined;
    _ = &a;
    var b: c_int = undefined;
    _ = &b;
    var c: c_int = undefined;
    _ = &c;
    var d: c_int = undefined;
    _ = &d;
    var idx: c_int = undefined;
    _ = &idx;
    if (ch < @as(c_int, 0)) {
        ch += 256;
    }
    a = ch >> @intCast(TOPSHIFT);
    b = SECONDMASK & (ch >> @intCast(SECONDSHIFT));
    c = THIRDMASK & (ch >> @intCast(THIRDSHIFT));
    d = LEAFMASK & (ch >> @intCast(LEAFSHIFT));
    if (a >= TOPSIZE) return dflt;
    idx = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
    if (idx != -@as(c_int, 1)) {
        idx = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(b)))];
        if (idx != -@as(c_int, 1)) {
            idx = @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(c)))];
            if (idx != -@as(c_int, 1)) return @as([*]c_int, @ptrCast(&r.*.leaf.table.e[@bitCast(@as(isize, @intCast(idx)))].entry))[@bitCast(@as(isize, @intCast(d)))];
        }
    }
    return dflt;
}
pub export fn rmap_init(arg_r: [*c]struct_Rtree) void {
    var r = arg_r;
    _ = &r;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (x != TOPSIZE) : (x += 1) {
            @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(x)))] = @truncate(-@as(c_int, 1));
        }
    }
    r.*.second.alloc = 0;
    r.*.second.size = 1;
    r.*.second.table.b = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, r.*.second.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
    r.*.third.alloc = 0;
    r.*.third.size = 1;
    r.*.third.table.c = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, r.*.third.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
    r.*.leaf.alloc = 0;
    r.*.leaf.size = 1;
    r.*.leaf.table.e = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, r.*.leaf.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Ileaf))))))));
}
pub export fn rmap_clr(arg_r: [*c]struct_Rtree) void {
    var r = arg_r;
    _ = &r;
    joe_free(@ptrCast(@alignCast(r.*.second.table.b)));
    joe_free(@ptrCast(@alignCast(r.*.third.table.c)));
    joe_free(@ptrCast(@alignCast(r.*.leaf.table.e)));
}
pub fn rmap_alloc(arg_l: [*c]struct_Level, arg_levelno: c_int, arg_dflt: c_int) callconv(.c) c_short {
    var l = arg_l;
    _ = &l;
    var levelno = arg_levelno;
    _ = &levelno;
    var dflt = arg_dflt;
    _ = &dflt;
    var x: c_int = undefined;
    _ = &x;
    if (l.*.alloc == l.*.size) {
        l.*.size *= 2;
        while (true) {
            switch (levelno) {
                @as(c_int, 1) => {
                    {
                        l.*.table.b = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(l.*.table.b)), @as(ptrdiff_t, l.*.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
                        break;
                    }
                },
                @as(c_int, 2) => {
                    {
                        l.*.table.c = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(l.*.table.c)), @as(ptrdiff_t, l.*.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid))))))));
                        break;
                    }
                },
                @as(c_int, 3) => {
                    {
                        l.*.table.e = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(l.*.table.e)), @as(ptrdiff_t, l.*.size) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Ileaf))))))));
                        break;
                    }
                },
                else => {},
            }
            break;
        }
    }
    while (true) {
        switch (levelno) {
            @as(c_int, 1) => {
                {
                    {
                        x = 0;
                        while (x != SECONDSIZE) : (x += 1) {
                            @as([*]c_short, @ptrCast(&l.*.table.b[@bitCast(@as(isize, @intCast(l.*.alloc)))].entry))[@bitCast(@as(isize, @intCast(x)))] = @truncate(-@as(c_int, 1));
                        }
                    }
                    break;
                }
            },
            @as(c_int, 2) => {
                {
                    {
                        x = 0;
                        while (x != THIRDSIZE) : (x += 1) {
                            @as([*]c_short, @ptrCast(&l.*.table.c[@bitCast(@as(isize, @intCast(l.*.alloc)))].entry))[@bitCast(@as(isize, @intCast(x)))] = @truncate(-@as(c_int, 1));
                        }
                    }
                    break;
                }
            },
            @as(c_int, 3) => {
                {
                    {
                        x = 0;
                        while (x != LEAFSIZE) : (x += 1) {
                            @as([*]c_int, @ptrCast(&l.*.table.e[@bitCast(@as(isize, @intCast(l.*.alloc)))].entry))[@bitCast(@as(isize, @intCast(x)))] = dflt;
                        }
                    }
                    l.*.table.e[@bitCast(@as(isize, @intCast(l.*.alloc)))].refcount = 1;
                    break;
                }
            },
            else => {},
        }
        break;
    }
    if (l.*.alloc == @as(c_int, 32768)) {
        _ = fprintf(__stderrp, "rmap_alloc overflow\r\n");
        ttsig(-@as(c_int, 1));
    }
    return @truncate(blk: {
        const ref = &l.*.alloc;
        const tmp = ref.*;
        ref.* += 1;
        break :blk tmp;
    });
}
pub export fn rmap_add(arg_r: [*c]struct_Rtree, arg_ch: c_int, arg_che: c_int, arg_map: c_int, arg_dflt: c_int) void {
    var r = arg_r;
    _ = &r;
    var ch = arg_ch;
    _ = &ch;
    var che = arg_che;
    _ = &che;
    var map = arg_map;
    _ = &map;
    var dflt = arg_dflt;
    _ = &dflt;
    var a: c_int = TOPMASK & (ch >> @intCast(TOPSHIFT));
    _ = &a;
    var b: c_int = SECONDMASK & (ch >> @intCast(SECONDSHIFT));
    _ = &b;
    var c: c_int = THIRDMASK & (ch >> @intCast(THIRDSHIFT));
    _ = &c;
    var d: c_int = LEAFMASK & (ch >> @intCast(LEAFSHIFT));
    _ = &d;
    var ib: c_short = undefined;
    _ = &ib;
    var ic: c_short = undefined;
    _ = &ic;
    var id: c_short = undefined;
    _ = &id;
    while (ch <= che) {
        if (a >= TOPSIZE) return;
        ib = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
        if (@as(c_int, ib) == -@as(c_int, 1)) {
            @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))] = blk: {
                const tmp = rmap_alloc(&r.*.second, 1, dflt);
                ib = tmp;
                break :blk tmp;
            };
        }
        while (ch <= che) {
            ic = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(ib)))].entry))[@bitCast(@as(isize, @intCast(b)))];
            if (@as(c_int, ic) == -@as(c_int, 1)) {
                @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(ib)))].entry))[@bitCast(@as(isize, @intCast(b)))] = blk: {
                    const tmp = rmap_alloc(&r.*.third, 2, dflt);
                    ic = tmp;
                    break :blk tmp;
                };
            }
            while (ch <= che) {
                id = @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))];
                if (@as(c_int, id) == -@as(c_int, 1)) {
                    @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))] = blk: {
                        const tmp = rmap_alloc(&r.*.leaf, 3, dflt);
                        id = tmp;
                        break :blk tmp;
                    };
                }
                while (ch <= che) {
                    var l: [*c]struct_Ileaf = r.*.leaf.table.e + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, id)))));
                    _ = &l;
                    if (l.*.refcount != @as(c_int, 1)) {
                        var org: [*c]struct_Ileaf = l;
                        _ = &org;
                        @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))] = blk: {
                            const tmp = rmap_alloc(&r.*.leaf, 3, dflt);
                            id = tmp;
                            break :blk tmp;
                        };
                        l = r.*.leaf.table.e + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, id)))));
                        _ = mcpy(@ptrCast(@alignCast(l)), @ptrCast(@alignCast(org)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Ileaf))))));
                        org.*.refcount -= 1;
                        l.*.refcount = 1;
                    }
                    @as([*]c_int, @ptrCast(&l.*.entry))[@bitCast(@as(isize, @intCast(d)))] = map;
                    if ((((d == (LEAFSIZE - @as(c_int, 1))) and (@as(c_int, id) != 0)) and (@as(c_int, id) == (r.*.leaf.alloc - @as(c_int, 1)))) and !(memcmp(@ptrCast(@alignCast(@as([*c]c_int, @ptrCast(@alignCast(&l.*.entry))))), @ptrCast(@alignCast(@as([*c]c_int, @ptrCast(@alignCast(&r.*.leaf.table.e[@bitCast(@as(isize, @intCast(@as(c_int, id) - @as(c_int, 1))))].entry))))), @bitCast(@as(c_long, @as(ptrdiff_t, LEAFSIZE) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int)))))))) != 0)) {
                        r.*.leaf.alloc -= 1;
                        id -= 1;
                        l = r.*.leaf.table.e + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, id)))));
                        l.*.refcount += 1;
                        @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))] = id;
                    }
                    ch += 1;
                    if ((blk: {
                        const ref = &d;
                        ref.* += 1;
                        break :blk ref.*;
                    }) == LEAFSIZE) {
                        d = 0;
                        break;
                    }
                }
                if ((blk: {
                    const ref = &c;
                    ref.* += 1;
                    break :blk ref.*;
                }) == THIRDSIZE) {
                    c = 0;
                    break;
                }
            }
            if ((blk: {
                const ref = &b;
                ref.* += 1;
                break :blk ref.*;
            }) == SECONDSIZE) {
                b = 0;
                break;
            }
        }
        a += 1;
    }
}
pub const struct_rmaphentry = extern struct {
    next: [*c]struct_rmaphentry = null,
    leaf: [*c]struct_Ileaf = null,
    idx: c_int = 0,
};
pub fn rmaphash(arg_l: [*c]struct_Ileaf) callconv(.c) ptrdiff_t {
    var l = arg_l;
    _ = &l;
    var hval: ptrdiff_t = 0;
    _ = &hval;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (x != LEAFSIZE) : (x += 1) {
            hval = ((hval << @intCast(@as(ptrdiff_t, 4))) + (hval >> @intCast(@as(ptrdiff_t, 28)))) + @as(ptrdiff_t, @as([*]c_int, @ptrCast(&l.*.entry))[@bitCast(@as(isize, @intCast(x)))]);
        }
    }
    return hval;
}
pub export fn rmap_opt(arg_r: [*c]struct_Rtree) void {
    var r = arg_r;
    _ = &r;
    var idx: ptrdiff_t = undefined;
    _ = &idx;
    var x: c_int = undefined;
    _ = &x;
    var rhsize: c_int = undefined;
    _ = &rhsize;
    var rhtable: [*c][*c]struct_rmaphentry = undefined;
    _ = &rhtable;
    var equiv: [*c]c_int = undefined;
    _ = &equiv;
    var repl: [*c]c_short = undefined;
    _ = &repl;
    var dupcount: c_int = undefined;
    _ = &dupcount;
    var newalloc: c_int = undefined;
    _ = &newalloc;
    var l: [*c]struct_Ileaf = undefined;
    _ = &l;
    equiv = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_int))))) * @as(ptrdiff_t, r.*.leaf.alloc))));
    repl = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(c_short))))) * @as(ptrdiff_t, r.*.leaf.alloc))));
    dupcount = 0;
    rhsize = 1024;
    rhtable = @ptrCast(@alignCast(joe_calloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]struct_rmaphentry))))), rhsize)));
    {
        x = 0;
        while (x != r.*.leaf.alloc) : (x += 1) {
            var rh: [*c]struct_rmaphentry = undefined;
            _ = &rh;
            idx = @as(ptrdiff_t, rhsize - @as(c_int, 1)) & rmaphash(r.*.leaf.table.e + @as(usize, @bitCast(@as(isize, @intCast(x)))));
            {
                rh = rhtable[@bitCast(@as(isize, @intCast(idx)))];
                while (rh != null) : (rh = rh.*.next) if (!(memcmp(@ptrCast(@alignCast(rh.*.leaf)), @ptrCast(@alignCast(r.*.leaf.table.e + @as(usize, @bitCast(@as(isize, @intCast(x)))))), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Ileaf)))))))) != 0)) break;
            }
            if (rh != null) {
                equiv[@bitCast(@as(isize, @intCast(x)))] = rh.*.idx;
                dupcount += 1;
            } else {
                equiv[@bitCast(@as(isize, @intCast(x)))] = -@as(c_int, 1);
                rh = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_rmaphentry))))))));
                rh.*.next = rhtable[@bitCast(@as(isize, @intCast(idx)))];
                rh.*.idx = x;
                rh.*.leaf = r.*.leaf.table.e + @as(usize, @bitCast(@as(isize, @intCast(x))));
                rhtable[@bitCast(@as(isize, @intCast(idx)))] = rh;
            }
        }
    }
    {
        x = 0;
        while (x != @as(c_int, 1024)) : (x += 1) {
            var rh: [*c]struct_rmaphentry = undefined;
            _ = &rh;
            var nh: [*c]struct_rmaphentry = undefined;
            _ = &nh;
            {
                rh = rhtable[@bitCast(@as(isize, @intCast(x)))];
                while (rh != null) : (rh = nh) {
                    nh = rh.*.next;
                    joe_free(@ptrCast(@alignCast(rh)));
                }
            }
        }
    }
    joe_free(@ptrCast(@alignCast(rhtable)));
    newalloc = r.*.leaf.alloc - dupcount;
    l = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Ileaf))))) * @as(ptrdiff_t, newalloc))));
    idx = 0;
    {
        x = 0;
        while (x != r.*.leaf.alloc) : (x += 1) if (equiv[@bitCast(@as(isize, @intCast(x)))] == -@as(c_int, 1)) {
            _ = mcpy(@ptrCast(@alignCast(l + @as(usize, @bitCast(@as(isize, @intCast(idx)))))), @ptrCast(@alignCast(r.*.leaf.table.e + @as(usize, @bitCast(@as(isize, @intCast(x)))))), @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Ileaf)))));
            l[@bitCast(@as(isize, @intCast(idx)))].refcount = 1;
            if (idx > @as(ptrdiff_t, 32767)) {
                _ = fprintf(__stderrp, "Oops, cclass too complex\n");
                ttsig(-@as(c_int, 1));
            }
            repl[@bitCast(@as(isize, @intCast(x)))] = @truncate(idx);
            idx += 1;
        };
    }
    {
        x = 0;
        while (x != r.*.leaf.alloc) : (x += 1) if (equiv[@bitCast(@as(isize, @intCast(x)))] != -@as(c_int, 1)) {
            repl[@bitCast(@as(isize, @intCast(x)))] = repl[@bitCast(@as(isize, @intCast(equiv[@bitCast(@as(isize, @intCast(x)))])))];
            l[@bitCast(@as(isize, @intCast(repl[@bitCast(@as(isize, @intCast(equiv[@bitCast(@as(isize, @intCast(x)))])))])))].refcount += 1;
        };
    }
    joe_free(@ptrCast(@alignCast(r.*.leaf.table.e)));
    r.*.leaf.table.e = l;
    r.*.leaf.alloc = newalloc;
    r.*.leaf.size = newalloc;
    {
        x = 0;
        while (x != r.*.third.alloc) : (x += 1) {
            idx = 0;
            while (idx != @as(ptrdiff_t, THIRDSIZE)) : (idx += 1) if (@as(c_int, @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(x)))].entry))[@bitCast(@as(isize, @intCast(idx)))]) != -@as(c_int, 1)) {
                @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(x)))].entry))[@bitCast(@as(isize, @intCast(idx)))] = repl[@bitCast(@as(isize, @intCast(@as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(x)))].entry))[@bitCast(@as(isize, @intCast(idx)))])))];
            };
        }
    }
    joe_free(@ptrCast(@alignCast(equiv)));
    joe_free(@ptrCast(@alignCast(repl)));
    {
        x = 0;
        while (x != THIRDSIZE) : (x += 1) {
            @as([*]c_short, @ptrCast(&r.*.mid.entry))[@bitCast(@as(isize, @intCast(x)))] = @truncate(-@as(c_int, 1));
        }
    }
    idx = @as([*]c_short, @ptrCast(&r.*.top.entry))[@as(c_int, 0)];
    if (idx != @as(ptrdiff_t, -@as(c_int, 1))) {
        idx = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(idx)))].entry))[@as(c_int, 0)];
        if (idx != @as(ptrdiff_t, -@as(c_int, 1))) {
            _ = mcpy(@ptrCast(@alignCast(@as([*c]c_short, @ptrCast(@alignCast(&r.*.mid.entry))))), @ptrCast(@alignCast(@as([*c]c_short, @ptrCast(@alignCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(idx)))].entry))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(r.*.mid.entry)))))));
        }
    }
}
pub export fn rmap_set(arg_r: [*c]struct_Rtree, arg_array: [*c]struct_interval, arg_len: ptrdiff_t, arg_map: c_int, arg_dflt: c_int) void {
    var r = arg_r;
    _ = &r;
    var array = arg_array;
    _ = &array;
    var len = arg_len;
    _ = &len;
    var map = arg_map;
    _ = &map;
    var dflt = arg_dflt;
    _ = &dflt;
    var y: ptrdiff_t = undefined;
    _ = &y;
    {
        y = 0;
        while (y != len) : (y += 1) {
            rmap_add(r, array[@bitCast(@as(isize, @intCast(y)))].first, array[@bitCast(@as(isize, @intCast(y)))].last, map, dflt);
        }
    }
}
pub export fn rmap_show(arg_r: [*c]struct_Rtree) void {
    var r = arg_r;
    _ = &r;
    var first: c_int = -@as(c_int, 2);
    _ = &first;
    var last: c_int = -@as(c_int, 2);
    _ = &last;
    var val: c_int = 0;
    _ = &val;
    var a: c_int = undefined;
    _ = &a;
    var len: ptrdiff_t = 0;
    _ = &len;
    var total: ptrdiff_t = 0;
    _ = &total;
    _ = printf("Rmap at %p\n", r);
    len = @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Rtree)))));
    _ = printf("Top level size = %lld\n", @as(c_longlong, len));
    total += len;
    len = @as(ptrdiff_t, r.*.second.alloc) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid)))));
    _ = printf("Second level size = %lld (%d entries)\n", @as(c_longlong, len), r.*.second.alloc);
    total += len;
    len = @as(ptrdiff_t, r.*.third.alloc) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Mid)))));
    _ = printf("Third level size = %lld (%d entries)\n", @as(c_longlong, len), r.*.third.alloc);
    total += len;
    len = @as(ptrdiff_t, r.*.leaf.alloc) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Ileaf)))));
    _ = printf("Fourth level size = %lld (%d entries)\n", @as(c_longlong, len), r.*.leaf.alloc);
    total += len;
    _ = printf("Total size = %lld bytes\n", @as(c_longlong, total));
    {
        a = 0;
        while (a != TOPSIZE) : (a += 1) {
            var ib: c_int = @as([*]c_short, @ptrCast(&r.*.top.entry))[@bitCast(@as(isize, @intCast(a)))];
            _ = &ib;
            if (ib != -@as(c_int, 1)) {
                var b: c_int = undefined;
                _ = &b;
                {
                    b = 0;
                    while (b != SECONDSIZE) : (b += 1) {
                        var ic: c_int = @as([*]c_short, @ptrCast(&r.*.second.table.b[@bitCast(@as(isize, @intCast(ib)))].entry))[@bitCast(@as(isize, @intCast(b)))];
                        _ = &ic;
                        if (ic != -@as(c_int, 1)) {
                            var c: c_int = undefined;
                            _ = &c;
                            {
                                c = 0;
                                while (c != THIRDSIZE) : (c += 1) {
                                    var id: c_int = @as([*]c_short, @ptrCast(&r.*.third.table.c[@bitCast(@as(isize, @intCast(ic)))].entry))[@bitCast(@as(isize, @intCast(c)))];
                                    _ = &id;
                                    if (id != -@as(c_int, 1)) {
                                        var d: c_int = undefined;
                                        _ = &d;
                                        {
                                            d = 0;
                                            while (d != LEAFSIZE) : (d += 1) {
                                                var ie: c_int = @as([*]c_int, @ptrCast(&r.*.leaf.table.e[@bitCast(@as(isize, @intCast(id)))].entry))[@bitCast(@as(isize, @intCast(d)))];
                                                _ = &ie;
                                                var ch: c_int = (((a << @intCast(TOPSHIFT)) + (b << @intCast(SECONDSHIFT))) + (c << @intCast(THIRDSHIFT))) + d;
                                                _ = &ch;
                                                if ((ch == (last + @as(c_int, 1))) and (ie == val)) {
                                                    last = ch;
                                                } else if (first != -@as(c_int, 2)) {
                                                    _ = printf("%p show %x %x -> %d\n", r, first, last, val);
                                                    first = blk: {
                                                        const tmp = ch;
                                                        last = tmp;
                                                        break :blk tmp;
                                                    };
                                                    val = ie;
                                                } else {
                                                    first = blk: {
                                                        const tmp = ch;
                                                        last = tmp;
                                                        break :blk tmp;
                                                    };
                                                    val = ie;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if (first != -@as(c_int, 2)) {
        _ = printf("%p show %x %x -> %d\n", r, first, last, val);
    }
}
pub export fn cclass_init(arg_m: [*c]struct_Cclass) void {
    var m = arg_m;
    _ = &m;
    m.*.size = 0;
    m.*.len = 0;
    m.*.intervals = null;
}
pub export fn cclass_clr(arg_m: [*c]struct_Cclass) void {
    var m = arg_m;
    _ = &m;
    if (m.*.intervals != null) {
        joe_free(@ptrCast(@alignCast(m.*.intervals)));
    }
    m.*.size = 0;
    m.*.len = 0;
    m.*.intervals = null;
}
pub fn cclass_del(arg_m: [*c]struct_Cclass, arg_x: c_int) callconv(.c) void {
    var m = arg_m;
    _ = &m;
    var x = arg_x;
    _ = &x;
    _ = mmove(@ptrCast(@alignCast(m.*.intervals + @as(usize, @bitCast(@as(isize, @intCast(x)))))), @ptrCast(@alignCast((m.*.intervals + @as(usize, @bitCast(@as(isize, @intCast(x))))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_interval))))) * (m.*.len - @as(ptrdiff_t, x + @as(c_int, 1))));
    m.*.len -= 1;
}
pub fn cclass_grow(arg_m: [*c]struct_Cclass) callconv(.c) void {
    var m = arg_m;
    _ = &m;
    if (m.*.len == m.*.size) {
        if (!(m.*.size != 0)) {
            m.*.size = 1;
            m.*.intervals = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_interval))))) * m.*.size)));
        } else {
            m.*.size *= 2;
            m.*.intervals = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(m.*.intervals)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_interval))))) * m.*.size)));
        }
    }
}
pub fn cclass_ins(arg_m: [*c]struct_Cclass, arg_x: c_int, arg_first: c_int, arg_last: c_int) callconv(.c) void {
    var m = arg_m;
    _ = &m;
    var x = arg_x;
    _ = &x;
    var first = arg_first;
    _ = &first;
    var last = arg_last;
    _ = &last;
    cclass_grow(m);
    _ = mmove(@ptrCast(@alignCast((m.*.intervals + @as(usize, @bitCast(@as(isize, @intCast(x))))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))))), @ptrCast(@alignCast(m.*.intervals + @as(usize, @bitCast(@as(isize, @intCast(x)))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_interval))))) * (m.*.len - @as(ptrdiff_t, x)));
    m.*.len += 1;
    m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first = first;
    m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last = last;
}
pub export fn cclass_add(arg_m: [*c]struct_Cclass, arg_first: c_int, arg_last: c_int) void {
    var m = arg_m;
    _ = &m;
    var first = arg_first;
    _ = &first;
    var last = arg_last;
    _ = &last;
    var x: c_int = undefined;
    _ = &x;
    if ((last < first) or (first < @as(c_int, 0))) return;
    {
        x = 0;
        while (@as(ptrdiff_t, x) != m.*.len) : (x += 1) {
            if (first > (m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last + @as(c_int, 1))) {} else if (m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first > (last + @as(c_int, 1))) {
                break;
            } else if (m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first <= first) {
                if (m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last >= last) {
                    return;
                } else {
                    first = m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first;
                    cclass_del(m, x);
                    x -= 1;
                }
            } else {
                if (m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last <= last) {
                    cclass_del(m, x);
                    x -= 1;
                } else {
                    m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first = first;
                    return;
                }
            }
        }
    }
    cclass_ins(m, x, first, last);
}
pub export fn cclass_union(arg_m: [*c]struct_Cclass, arg_n: [*c]struct_Cclass) void {
    var m = arg_m;
    _ = &m;
    var n = arg_n;
    _ = &n;
    var x: c_int = undefined;
    _ = &x;
    if (n != null) {
        x = 0;
        while (@as(ptrdiff_t, x) != n.*.len) : (x += 1) {
            cclass_add(m, n.*.intervals[@bitCast(@as(isize, @intCast(x)))].first, n.*.intervals[@bitCast(@as(isize, @intCast(x)))].last);
        }
    }
}
pub export fn cclass_merge(arg_m: [*c]struct_Cclass, arg_array: [*c]const struct_interval, arg_len: c_int) void {
    var m = arg_m;
    _ = &m;
    var array = arg_array;
    _ = &array;
    var len = arg_len;
    _ = &len;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (x != len) : (x += 1) {
            cclass_add(m, array[@bitCast(@as(isize, @intCast(x)))].first, array[@bitCast(@as(isize, @intCast(x)))].last);
        }
    }
}
pub export fn cclass_sub(arg_m: [*c]struct_Cclass, arg_first: c_int, arg_last: c_int) void {
    var m = arg_m;
    _ = &m;
    var first = arg_first;
    _ = &first;
    var last = arg_last;
    _ = &last;
    var x: c_int = undefined;
    _ = &x;
    if (last < first) return;
    {
        x = 0;
        while (@as(ptrdiff_t, x) != m.*.len) : (x += 1) {
            if (first > m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last) {} else if (m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first > last) {
                break;
            } else if (first <= m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first) {
                if (last >= m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last) {
                    cclass_del(m, x);
                    x -= 1;
                } else {
                    m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first = last + @as(c_int, 1);
                }
            } else {
                if (last >= m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last) {
                    m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last = first - @as(c_int, 1);
                } else {
                    cclass_ins(m, x, m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first, first - @as(c_int, 1));
                    m.*.intervals[@bitCast(@as(isize, @intCast(x + @as(c_int, 1))))].first = last + @as(c_int, 1);
                    x += 1;
                }
            }
        }
    }
}
pub export fn cclass_diff(arg_m: [*c]struct_Cclass, arg_n: [*c]struct_Cclass) void {
    var m = arg_m;
    _ = &m;
    var n = arg_n;
    _ = &n;
    var x: c_int = undefined;
    _ = &x;
    if (n != null) {
        x = 0;
        while (@as(ptrdiff_t, x) != n.*.len) : (x += 1) {
            cclass_sub(m, n.*.intervals[@bitCast(@as(isize, @intCast(x)))].first, n.*.intervals[@bitCast(@as(isize, @intCast(x)))].last);
        }
    }
}
pub export fn cclass_inv(arg_m: [*c]struct_Cclass) void {
    var m = arg_m;
    _ = &m;
    if ((m.*.len != 0) and (@as(ptrdiff_t, @intFromBool(!(m.*.intervals[@as(c_int, 0)].first != 0))) != 0)) {
        var x: c_int = undefined;
        _ = &x;
        var last: c_int = m.*.intervals[@as(c_int, 0)].last;
        _ = &last;
        {
            x = 0;
            while (@as(ptrdiff_t, x) != (m.*.len - @as(ptrdiff_t, 1))) : (x += 1) {
                m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first = last + @as(c_int, 1);
                m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last = m.*.intervals[@bitCast(@as(isize, @intCast(x + @as(c_int, 1))))].first - @as(c_int, 1);
                last = m.*.intervals[@bitCast(@as(isize, @intCast(x + @as(c_int, 1))))].last;
            }
        }
        if (last == UNICODE_LAST) {
            m.*.len -= 1;
        } else {
            m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first = last + @as(c_int, 1);
            m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last = UNICODE_LAST;
        }
    } else {
        var x: c_int = undefined;
        _ = &x;
        var first: c_int = 0;
        _ = &first;
        {
            x = 0;
            while (@as(ptrdiff_t, x) != m.*.len) : (x += 1) {
                var new_first: c_int = m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last + @as(c_int, 1);
                _ = &new_first;
                m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last = m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first - @as(c_int, 1);
                m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first = first;
                first = new_first;
            }
        }
        if (first != UNICODE_LAST) {
            cclass_grow(m);
            m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first = first;
            m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last = UNICODE_LAST;
            m.*.len += 1;
        }
    }
}
pub export fn cclass_lookup_unopt(arg_m: [*c]struct_Cclass, arg_ch: c_int) c_int {
    var m = arg_m;
    _ = &m;
    var ch = arg_ch;
    _ = &ch;
    return @intFromBool(interval_test(m.*.intervals, m.*.len, ch) != @as(ptrdiff_t, -@as(c_int, 1)));
}
pub export fn cclass_opt(arg_m: [*c]struct_Cclass) void {
    var m = arg_m;
    _ = &m;
    rset_init(@ptrCast(@alignCast(&m.*.rset)));
    rset_set(@ptrCast(@alignCast(&m.*.rset)), m.*.intervals, m.*.len);
    rset_opt(@ptrCast(@alignCast(&m.*.rset)));
}
pub export fn cclass_lookup(arg_m: [*c]struct_Cclass, arg_ch: c_int) c_int {
    var m = arg_m;
    _ = &m;
    var ch = arg_ch;
    _ = &ch;
    return rset_lookup(@ptrCast(@alignCast(&m.*.rset)), ch);
}
pub export fn cclass_show(arg_m: [*c]struct_Cclass) void {
    var m = arg_m;
    _ = &m;
    var x: c_int = undefined;
    _ = &x;
    var first: c_int = 0;
    _ = &first;
    {
        x = 0;
        while (@as(ptrdiff_t, x) != m.*.len) : (x += 1) {
            if (!(first != 0)) {
                first = 1;
            } else {
                _ = printf(" ");
            }
            _ = printf("[%x..%x]", @as(c_uint, @bitCast(@as(c_int, m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first))), @as(c_uint, @bitCast(@as(c_int, m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last))));
        }
    }
    _ = printf("\n");
}
pub const struct_Cclass_list = extern struct {
    next: [*c]struct_Cclass_list = null,
    m: [*c]struct_Cclass = null,
    map: [*c]struct_charmap = null,
    n: [1]struct_Cclass = std.mem.zeroes([1]struct_Cclass),
};
pub export var cclass_list: [*c]struct_Cclass_list = null;
pub export fn cclass_remap(arg_m: [*c]struct_Cclass, arg_map: [*c]struct_charmap) [*c]struct_Cclass {
    var m = arg_m;
    _ = &m;
    var map = arg_map;
    _ = &map;
    if (!(map != null)) return null;
    if (!(map.*.type != 0)) {
        var l: [*c]struct_Cclass_list = undefined;
        _ = &l;
        var x: ptrdiff_t = undefined;
        _ = &x;
        var low: c_int = undefined;
        _ = &low;
        var high: c_int = undefined;
        _ = &high;
        {
            l = cclass_list;
            while (l != null) : (l = l.*.next) {
                if ((l.*.m == m) and (l.*.map == map)) return @ptrCast(@alignCast(&l.*.n));
            }
        }
        l = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_Cclass_list))))))));
        l.*.next = cclass_list;
        cclass_list = l;
        l.*.m = m;
        l.*.map = map;
        cclass_init(@ptrCast(@alignCast(&l.*.n)));
        low = -@as(c_int, 2);
        high = -@as(c_int, 2);
        {
            x = 0;
            while (x != m.*.len) : (x += 1) {
                var a: c_int = undefined;
                _ = &a;
                {
                    a = m.*.intervals[@bitCast(@as(isize, @intCast(x)))].first;
                    while (a <= m.*.intervals[@bitCast(@as(isize, @intCast(x)))].last) : (a += 1) {
                        var b: c_int = from_uni(map, a);
                        _ = &b;
                        if (b != -@as(c_int, 1)) {
                            if (b == (high + @as(c_int, 1))) {
                                high = b;
                            } else {
                                cclass_add(@ptrCast(@alignCast(&l.*.n)), low, high);
                                low = blk: {
                                    const tmp = b;
                                    high = tmp;
                                    break :blk tmp;
                                };
                            }
                        }
                    }
                }
            }
        }
        if (low != -@as(c_int, 2)) {
            cclass_add(@ptrCast(@alignCast(&l.*.n)), low, high);
        }
        return @ptrCast(@alignCast(&l.*.n));
    } else {
        return m;
    }
    unreachable;
}
