//! Termcap/terminfo database interface — replaces `joe/termcap.c`.
//!
//! Faithful C-ABI port of JOE's termcap loader and string capability
//! executor. Generated from a goto-free rewrite of termcap.c (non-TERMINFO
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
pub const struct_stat = extern struct {
    st_mtime: c_long = 0,
    _pad: [128]u8 = std.mem.zeroes([128]u8),
};
pub const struct_sortentry = extern struct {
    name: [*c]u8 = null,
    value: [*c]u8 = null,
};
pub const struct_cap = extern struct {
    tbuf: [*c]u8 = null,
    sort: [*c]struct_sortentry = null,
    sortlen: ptrdiff_t = 0,
    abuf: [*c]u8 = null,
    abufp: [*c]u8 = null,
    div: c_long = 0,
    baud: c_long = 0,
    pad: [*c]const u8 = null,
    out: ?*const fn (?*anyopaque, u8) callconv(.c) void = null,
    outptr: ?*anyopaque = null,
    dopadding: c_int = 0,
};
pub const CAP = struct_cap;
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_realloc(ptr: ?*anyopaque, size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn mmove(d: ?*anyopaque, s: ?*const anyopaque, sz: ptrdiff_t) ?*anyopaque;
pub extern fn ztoi(s: [*c]const u8) c_int;
pub extern fn zhtoi(s: [*c]const u8) c_int;
pub extern fn slen(ary: [*c]const u8) ptrdiff_t;
pub extern fn vsmk(len: ptrdiff_t) [*c]u8;
pub extern fn vsrm(vary: [*c]u8) void;
pub extern fn vstrunc(vary: [*c]u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsncpy(vary: [*c]u8, pos: ptrdiff_t, array: [*c]const u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsset(vary: [*c]u8, pos: ptrdiff_t, el: u8) [*c]u8;
pub extern fn vsadd(vary: [*c]u8, el: u8) [*c]u8;
pub extern fn vawords(a: [*c][*c]u8, s: [*c]const u8, len: ptrdiff_t, sep: [*c]const u8, seplen: ptrdiff_t) [*c][*c]u8;
pub extern fn varm(vary: [*c][*c]u8) void;
pub extern fn fopen(path: [*c]const u8, mode: [*c]const u8) ?*FILE;
pub extern fn fclose(stream: ?*FILE) c_int;
pub extern fn fgets(s: [*c]u8, n: c_int, stream: ?*FILE) [*c]u8;
pub extern fn getc(stream: ?*FILE) c_int;
pub extern fn ungetc(c: c_int, stream: ?*FILE) c_int;
pub extern fn fseek(stream: ?*FILE, offset: c_long, whence: c_int) c_int;
pub extern fn fseeko(stream: ?*FILE, offset: off_t, whence: c_int) c_int;
pub extern fn fstat(fd: c_int, buf: [*c]struct_stat) c_int;
pub extern fn fileno(stream: ?*FILE) c_int;
pub extern fn stat(path: [*c]const u8, buf: [*c]struct_stat) c_int;
pub export fn my_getcap(arg_name: [*c]u8, arg_baud: c_long, arg_out: ?*const fn (?*anyopaque, u8) callconv(.c) void, arg_outptr: ?*anyopaque) [*c]CAP {
    var name = arg_name;
    _ = &name;
    var baud = arg_baud;
    _ = &baud;
    var out = arg_out;
    _ = &out;
    var outptr = arg_outptr;
    _ = &outptr;
    var cap_1: [*c]CAP = undefined;
    _ = &cap_1;
    var f: ?*FILE = undefined;
    _ = &f;
    var f1: ?*FILE = undefined;
    _ = &f1;
    var idx: off_t = undefined;
    _ = &idx;
    var c: c_int = undefined;
    _ = &c;
    var ti: ptrdiff_t = undefined;
    _ = &ti;
    var x: ptrdiff_t = undefined;
    _ = &x;
    var y: ptrdiff_t = undefined;
    _ = &y;
    var z: ptrdiff_t = undefined;
    _ = &z;
    var tp: [*c]u8 = undefined;
    _ = &tp;
    var pp: [*c]u8 = undefined;
    _ = &pp;
    var qq: [*c]u8 = undefined;
    _ = &qq;
    var namebuf: [*c]u8 = undefined;
    _ = &namebuf;
    var npbuf: [*c][*c]u8 = undefined;
    _ = &npbuf;
    var idxname: [*c]u8 = undefined;
    _ = &idxname;
    var sortsiz: c_int = undefined;
    _ = &sortsiz;
    var from_env: c_int = undefined;
    _ = &from_env;
    if ((!(name != null) and !((blk: {
        const tmp = joeterm;
        name = tmp;
        break :blk tmp;
    }) != null)) and !((blk: {
        const tmp = getenv("TERM");
        name = tmp;
        break :blk tmp;
    }) != null)) return null;
    cap_1 = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(CAP))))))));
    cap_1.*.tbuf = vsmk(4096);
    cap_1.*.abuf = null;
    cap_1.*.sort = null;
    name = vsncpy(null, 0, name, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(name))))));
    cap_1.*.sort = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_sortentry))))) * @as(ptrdiff_t, blk: {
        const tmp = @as(c_int, 64);
        sortsiz = tmp;
        break :blk tmp;
    }))));
    cap_1.*.sortlen = 0;
    tp = getenv("TERMCAP");
    if ((tp != null) and (@as(c_int, tp[@as(c_int, 0)]) == @as(c_int, '/'))) {
        namebuf = vsncpy(null, 0, tp, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(tp))))));
    } else {
        if (tp != null) {
            cap_1.*.tbuf = vsncpy(cap_1.*.tbuf, if (cap_1.*.tbuf != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(cap_1.*.tbuf))) - @as(usize, @as(usize, @intCast(@as(c_int, 1))))).* else @as(ptrdiff_t, 0), tp, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(tp))))));
        }
        if ((blk: {
            const tmp = getenv("TERMPATH");
            tp = tmp;
            break :blk tmp;
        }) != null) {
            namebuf = vsncpy(null, 0, tp, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(tp))))));
        } else {
            if ((blk: {
                const tmp = getenv("HOME");
                tp = tmp;
                break :blk tmp;
            }) != null) {
                namebuf = vsncpy(null, 0, tp, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(tp))))));
                namebuf = vsadd(namebuf, '/');
            } else {
                namebuf = null;
            }
            namebuf = vsncpy(namebuf, if (namebuf != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(namebuf))) - @as(usize, @as(usize, @intCast(@as(c_int, 1))))).* else @as(ptrdiff_t, 0), ".termcap ", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf(".termcap ".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
            namebuf = vsncpy(namebuf, if (namebuf != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(namebuf))) - @as(usize, @as(usize, @intCast(@as(c_int, 1))))).* else @as(ptrdiff_t, 0), "", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
            namebuf = vsncpy(namebuf, if (namebuf != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(namebuf))) - @as(usize, @as(usize, @intCast(@as(c_int, 1))))).* else @as(ptrdiff_t, 0), "termcap /etc/termcap", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("termcap /etc/termcap".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
        }
    }
    npbuf = vawords(null, namebuf, if (namebuf != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(namebuf))) - @as(usize, @as(usize, @intCast(@as(c_int, 1))))).* else @as(ptrdiff_t, 0), "\t :", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("\t :".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
    vsrm(namebuf);
    y = 0;
    ti = 0;
    from_env = match(cap_1.*.tbuf, name);
    if (!(from_env != 0)) {
        cap_1.*.tbuf = vstrunc(cap_1.*.tbuf, 0);
    }
    while (true) {
        if (!(from_env != 0)) {
            if (!(npbuf[@as(usize, @intCast(y))] != null)) {
                _ = @constCast("Couldn't load termcap entry.  Using ansi default\n");
                ti = 0;
                cap_1.*.tbuf = vsncpy(cap_1.*.tbuf, 0, @ptrCast(@alignCast(&defentry)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf(defentry)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
            } else {
                idx = 0;
                idxname = vsncpy(null, 0, npbuf[@as(usize, @intCast(y))], @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(npbuf[@as(usize, @intCast(y))]))))));
                idxname = vsncpy(idxname, if (idxname != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(idxname))) - @as(usize, @as(usize, @intCast(@as(c_int, 1))))).* else @as(ptrdiff_t, 0), ".idx", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf(".idx".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
                f1 = fopen(npbuf[@as(usize, @intCast(y))], "r");
                y += 1;
                if (!(f1 != null)) continue;
                f = fopen(idxname, "r");
                if (f != null) {
                    var buf: struct_stat = undefined;
                    _ = &buf;
                    var buf1: struct_stat = undefined;
                    _ = &buf1;
                    _ = fstat(fileno(f), &buf);
                    _ = fstat(fileno(f1), &buf1);
                    if (buf.st_mtime > buf1.st_mtime) {
                        idx = findidx(f, name);
                    } else {
                        _ = @constCast("termcap: %s is out of date\n");
                        _ = &idxname;
                    }
                    _ = fclose(f);
                }
                vsrm(idxname);
                _ = fseek(f1, @truncate(idx), 0);
                cap_1.*.tbuf = lfind(cap_1.*.tbuf, ti, f1, name);
                _ = fclose(f1);
                if ((if (cap_1.*.tbuf != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(cap_1.*.tbuf))) - @as(usize, @as(usize, @intCast(@as(c_int, 1))))).* else @as(ptrdiff_t, 0)) == ti) continue;
            }
        }
        from_env = 0;
        x = if (cap_1.*.tbuf != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(cap_1.*.tbuf))) - @as(usize, @as(usize, @intCast(@as(c_int, 1))))).* else @as(ptrdiff_t, 0);
        while (true) {
            cap_1.*.tbuf[@as(usize, @intCast(x))] = 0;
            while ((x != 0) and (@as(ptrdiff_t, @intFromBool(@as(c_int, cap_1.*.tbuf[
                @bitCast(@as(isize, @intCast(blk: {
                    const ref = &x;
                    ref.* -= 1;
                    break :blk ref.*;
                })))
            ]) != @as(c_int, ':'))) != 0)) {}
            if (!((x != 0) and (@as(ptrdiff_t, @intFromBool(!(@as(c_int, cap_1.*.tbuf[@as(usize, @intCast(x + @as(ptrdiff_t, 1)))]) != 0) or (@as(c_int, cap_1.*.tbuf[@as(usize, @intCast(x + @as(ptrdiff_t, 1)))]) == @as(c_int, ':')))) != 0))) break;
        }
        if (((@as(c_int, cap_1.*.tbuf[@as(usize, @intCast(x + @as(ptrdiff_t, 1)))]) == @as(c_int, 't')) and (@as(c_int, cap_1.*.tbuf[@as(usize, @intCast(x + @as(ptrdiff_t, 2)))]) == @as(c_int, 'c'))) and (@as(c_int, cap_1.*.tbuf[@as(usize, @intCast(x + @as(ptrdiff_t, 3)))]) == @as(c_int, '='))) {
            name = vsncpy(null, 0, (cap_1.*.tbuf + @as(usize, @as(usize, @intCast(x)))) + @as(usize, @as(usize, @intCast(@as(c_int, 4)))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen((cap_1.*.tbuf + @as(usize, @as(usize, @intCast(x)))) + @as(usize, @as(usize, @intCast(@as(c_int, 4))))))))));
            cap_1.*.tbuf[@as(usize, @intCast(x))] = 0;
            cap_1.*.tbuf[@as(usize, @intCast(x + @as(ptrdiff_t, 1)))] = 0;
            ti = x + @as(ptrdiff_t, 1);
            (@as([*c]ptrdiff_t, @ptrCast(@alignCast(cap_1.*.tbuf))) - @as(usize, @as(usize, @intCast(@as(c_int, 1))))).* = x + @as(ptrdiff_t, 1);
            if (y != 0) {
                y -= 1;
            }
            continue;
        }
        while (true) {
            pp = cap_1.*.tbuf + @as(usize, @as(usize, @intCast(ti)));
            while (@as(c_int, pp.*) != 0) {
                while ((@as(c_int, pp.*) != 0) and (@as(c_int, pp.*) != @as(c_int, ':'))) {
                    pp += 1;
                }
                if (!(@as(c_int, pp.*) != 0)) break;
                (blk: {
                    const ref = &pp;
                    const tmp = ref.*;
                    ref.* += 1;
                    break :blk tmp;
                }).* = 0;
                while (true) {
                    var q: c_int = undefined;
                    _ = &q;
                    var found_existing: c_int = undefined;
                    _ = &found_existing;
                    if ((@as(c_int, pp[@as(c_int, 0)]) == @as(c_int, ' ')) or (@as(c_int, pp[@as(c_int, 0)]) == @as(c_int, '\t'))) break;
                    {
                        q = 0;
                        while (((((@as(c_int, pp[@as(usize, @intCast(q))]) != 0) and (@as(c_int, pp[@as(usize, @intCast(q))]) != @as(c_int, '#'))) and (@as(c_int, pp[@as(usize, @intCast(q))]) != @as(c_int, '='))) and (@as(c_int, pp[@as(usize, @intCast(q))]) != @as(c_int, '@'))) and (@as(c_int, pp[@as(usize, @intCast(q))]) != @as(c_int, ':'))) : (q += 1) {}
                    }
                    qq = pp;
                    c = pp[@as(usize, @intCast(q))];
                    pp[@as(usize, @intCast(q))] = 0;
                    if (c != 0) {
                        pp += @as(usize, @as(usize, @intCast(q + @as(c_int, 1))));
                    } else {
                        pp += @as(usize, @as(usize, @intCast(q)));
                    }
                    x = 0;
                    y = cap_1.*.sortlen;
                    z = -@as(c_int, 1);
                    found_existing = 0;
                    if (y != 0) {
                        while (z != @divTrunc(x + y, @as(ptrdiff_t, 2))) {
                            var found: c_int = undefined;
                            _ = &found;
                            z = @divTrunc(x + y, @as(ptrdiff_t, 2));
                            found = strcmp(qq, cap_1.*.sort[@as(usize, @intCast(z))].name);
                            if (found > @as(c_int, 0)) {
                                x = z;
                            } else if (found < @as(c_int, 0)) {
                                y = z;
                            } else {
                                found_existing = 1;
                                if (c == @as(c_int, '@')) {
                                    _ = mmove(@ptrCast(@alignCast(cap_1.*.sort + @as(usize, @as(usize, @intCast(z))))), @ptrCast(@alignCast((cap_1.*.sort + @as(usize, @as(usize, @intCast(z)))) + @as(usize, @as(usize, @intCast(@as(c_int, 1)))))), ((blk: {
                                        const ref = &cap_1.*.sortlen;
                                        const tmp = ref.*;
                                        ref.* -= 1;
                                        break :blk tmp;
                                    }) - (z + @as(ptrdiff_t, 1))) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_sortentry))))));
                                } else if ((c != 0) and (c != @as(c_int, ':'))) {
                                    cap_1.*.sort[@as(usize, @intCast(z))].value = (qq + @as(usize, @as(usize, @intCast(q)))) + @as(usize, @as(usize, @intCast(@as(c_int, 1))));
                                } else {
                                    cap_1.*.sort[@as(usize, @intCast(z))].value = null;
                                }
                                break;
                            }
                        }
                    }
                    if (!(found_existing != 0)) {
                        if (cap_1.*.sortlen == @as(ptrdiff_t, sortsiz)) {
                            cap_1.*.sort = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(cap_1.*.sort)), @as(ptrdiff_t, blk: {
                                const ref = &sortsiz;
                                ref.* += 32;
                                break :blk ref.*;
                            }) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_sortentry))))))));
                        }
                        _ = mmove(@ptrCast(@alignCast((cap_1.*.sort + @as(usize, @as(usize, @intCast(y)))) + @as(usize, @as(usize, @intCast(@as(c_int, 1)))))), @ptrCast(@alignCast(cap_1.*.sort + @as(usize, @as(usize, @intCast(y))))), ((blk: {
                            const ref = &cap_1.*.sortlen;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        }) - y) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_sortentry))))));
                        cap_1.*.sort[@as(usize, @intCast(y))].name = qq;
                        if ((c != 0) and (c != @as(c_int, ':'))) {
                            cap_1.*.sort[@as(usize, @intCast(y))].value = (qq + @as(usize, @as(usize, @intCast(q)))) + @as(usize, @as(usize, @intCast(@as(c_int, 1))));
                        } else {
                            cap_1.*.sort[@as(usize, @intCast(y))].value = null;
                        }
                    }
                    if (c == @as(c_int, ':')) continue else break;
                }
            }
            if (ti != 0) {
                {
                    ti -= 1;
                    while (ti != 0) : (ti -= 1) if (!(@as(c_int, cap_1.*.tbuf[@bitCast(@as(isize, @intCast(ti - @as(ptrdiff_t, 1))))]) != 0)) break;
                }
                continue;
            }
            break;
        }
        break;
    }
    varm(npbuf);
    vsrm(name);
    cap_1.*.pad = jgetstr(cap_1, "pc");
    if (dopadding != 0) {
        cap_1.*.dopadding = 1;
    } else {
        cap_1.*.dopadding = 0;
    }
    return setcap(cap_1, baud, out, outptr);
}
pub export fn setcap(arg_cap_1: [*c]CAP, arg_baud: c_long, arg_out: ?*const fn (?*anyopaque, u8) callconv(.c) void, arg_outptr: ?*anyopaque) [*c]CAP {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var baud = arg_baud;
    _ = &baud;
    var out = arg_out;
    _ = &out;
    var outptr = arg_outptr;
    _ = &outptr;
    cap_1.*.baud = baud;
    cap_1.*.div = @divTrunc(@as(c_long, 100000), baud);
    cap_1.*.out = out;
    cap_1.*.outptr = outptr;
    return cap_1;
}
pub export fn jgetstr(arg_cap_1: [*c]CAP, arg_name: [*c]const u8) [*c]const u8 {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var name = arg_name;
    _ = &name;
    var s: [*c]struct_sortentry = undefined;
    _ = &s;
    s = findcap(cap_1, name);
    if (s != null) return s.*.value else return null;
}
pub export fn getflag(arg_cap_1: [*c]CAP, arg_name: [*c]const u8) c_int {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var name = arg_name;
    _ = &name;
    return @intFromBool(@as(?*anyopaque, @ptrCast(@alignCast(findcap(cap_1, name)))) != @as(?*anyopaque, null));
}
pub export fn getnum(arg_cap_1: [*c]CAP, arg_name: [*c]const u8) c_int {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var name = arg_name;
    _ = &name;
    var s: [*c]struct_sortentry = undefined;
    _ = &s;
    s = findcap(cap_1, name);
    if ((s != null) and (s.*.value != null)) return ztoi(s.*.value);
    return -@as(c_int, 1);
}
pub export fn rmcap(arg_cap_1: [*c]CAP) void {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    vsrm(cap_1.*.tbuf);
    if (cap_1.*.abuf != null) {
        joe_free(@ptrCast(@alignCast(cap_1.*.abuf)));
    }
    if (cap_1.*.sort != null) {
        joe_free(@ptrCast(@alignCast(cap_1.*.sort)));
    }
    joe_free(@ptrCast(@alignCast(cap_1)));
}
pub export fn texec(arg_cap_1: [*c]CAP, arg_s: [*c]const u8, arg_l: ptrdiff_t, arg_a0: ptrdiff_t, arg_a1: ptrdiff_t, arg_a2: ptrdiff_t, arg_a3: ptrdiff_t) void {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var s = arg_s;
    _ = &s;
    var l = arg_l;
    _ = &l;
    var a0 = arg_a0;
    _ = &a0;
    var a1 = arg_a1;
    _ = &a1;
    var a2 = arg_a2;
    _ = &a2;
    var a3 = arg_a3;
    _ = &a3;
    var c: c_int = undefined;
    _ = &c;
    var x: ptrdiff_t = undefined;
    _ = &x;
    var tenth: c_long = 0;
    _ = &tenth;
    var args: [4]ptrdiff_t = undefined;
    _ = &args;
    var vars: [256]ptrdiff_t = undefined;
    _ = &vars;
    var a: [*c]ptrdiff_t = @ptrCast(@alignCast(&args));
    _ = &a;
    if (!(s != null)) return;
    args[@as(c_int, 0)] = a0;
    args[@as(c_int, 1)] = a1;
    args[@as(c_int, 2)] = a2;
    args[@as(c_int, 3)] = a3;
    while ((@as(c_int, s.*) >= @as(c_int, '0')) and (@as(c_int, s.*) <= @as(c_int, '9'))) {
        tenth = ((tenth * @as(c_long, 10)) + @as(c_long, @as(c_int, (blk: {
            const ref = &s;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).*))) - @as(c_long, '0');
    }
    tenth *= 10;
    if (@as(c_int, s.*) == @as(c_int, '.')) {
        s += 1;
        tenth += @as(c_int, (blk: {
            const ref = &s;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).*) - @as(c_int, '0');
    }
    if (@as(c_int, s.*) == @as(c_int, '*')) {
        s += 1;
        tenth *= l;
    }
    while ((blk: {
        const tmp = @as(c_int, (blk_1: {
            const ref = &s;
            const tmp_2 = ref.*;
            ref.* += 1;
            break :blk_1 tmp_2;
        }).*);
        c = tmp;
        break :blk tmp;
    }) != @as(c_int, '\x00')) if ((c == @as(c_int, '%')) and (@as(c_int, s.*) != 0)) {
        while (true) {
            switch (blk: {
                x = a[@as(c_int, 0)];
                break :blk blk_1: {
                    const tmp = @as(c_int, escape1(&s));
                    c = tmp;
                    break :blk_1 tmp;
                };
            }) {
                @as(c_int, 'C') => {
                    if (x >= @as(ptrdiff_t, 96)) {
                        cap_1.*.out.?(cap_1.*.outptr, @bitCast(@as(i8, @truncate(@divTrunc(x, @as(ptrdiff_t, 96))))));
                        {
                            const ref = &x;
                            ref.* = @rem(ref.*, @as(ptrdiff_t, 96));
                        }
                    }
                    if (@as(c_int, s.*) != 0) {
                        x += @as(c_int, escape1(&s));
                    }
                    cap_1.*.out.?(cap_1.*.outptr, @bitCast(@as(i8, @truncate(x))));
                    a += 1;
                    break;
                },
                @as(c_int, '+') => {
                    if (@as(c_int, s.*) != 0) {
                        x += @as(c_int, escape1(&s));
                    }
                    cap_1.*.out.?(cap_1.*.outptr, @bitCast(@as(i8, @truncate(x))));
                    a += 1;
                    break;
                },
                @as(c_int, '.') => {
                    cap_1.*.out.?(cap_1.*.outptr, @bitCast(@as(i8, @truncate(x))));
                    a += 1;
                    break;
                },
                @as(c_int, 'd'), @as(c_int, '2'), @as(c_int, '3') => {
                    {
                        var fmt: c_int = c;
                        _ = &fmt;
                        var digs: c_int = undefined;
                        _ = &digs;
                        if (fmt == @as(c_int, 'd')) {
                            digs = if (x < @as(ptrdiff_t, 10)) @as(c_int, 1) else if (x < @as(ptrdiff_t, 100)) @as(c_int, 2) else @as(c_int, 3);
                        } else if (fmt == @as(c_int, '2')) {
                            digs = if (x < @as(ptrdiff_t, 100)) @as(c_int, 2) else @as(c_int, 3);
                        } else {
                            digs = 3;
                        }
                        if (digs >= @as(c_int, 3)) {
                            c = '0';
                            while (x >= @as(ptrdiff_t, 100)) {
                                c += 1;
                                x -= 100;
                            }
                            cap_1.*.out.?(cap_1.*.outptr, @bitCast(@as(i8, @truncate(c))));
                        }
                        if (digs >= @as(c_int, 2)) {
                            c = '0';
                            while (x >= @as(ptrdiff_t, 10)) {
                                c += 1;
                                x -= 10;
                            }
                            cap_1.*.out.?(cap_1.*.outptr, @bitCast(@as(i8, @truncate(c))));
                        }
                        cap_1.*.out.?(cap_1.*.outptr, @bitCast(@as(i8, @truncate(@as(ptrdiff_t, '0') + x))));
                        a += 1;
                        break;
                    }
                },
                @as(c_int, 'r') => {
                    a[@as(c_int, 0)] = a[@as(c_int, 1)];
                    a[@as(c_int, 1)] = x;
                    break;
                },
                @as(c_int, 'i') => {
                    a[@as(c_int, 0)] += 1;
                    a[@as(c_int, 1)] += 1;
                    break;
                },
                @as(c_int, 'n') => {
                    a[@as(c_int, 0)] ^= 96;
                    a[@as(c_int, 1)] ^= 96;
                    break;
                },
                @as(c_int, 'm') => {
                    a[@as(c_int, 0)] ^= 127;
                    a[@as(c_int, 1)] ^= 127;
                    break;
                },
                @as(c_int, 'f') => {
                    a += 1;
                    break;
                },
                @as(c_int, 'b') => {
                    a -= 1;
                    break;
                },
                @as(c_int, 'a') => {
                    x = @as(u8, s[@as(c_int, 2)]);
                    if (@as(c_int, s[@as(c_int, 1)]) == @as(c_int, 'p')) {
                        x = a[@bitCast(@as(isize, @intCast(x - @as(ptrdiff_t, 64))))];
                    }
                    while (true) {
                        switch (@as(c_int, s.*)) {
                            @as(c_int, '+') => {
                                a[@as(c_int, 0)] += x;
                                break;
                            },
                            @as(c_int, '-') => {
                                a[@as(c_int, 0)] -= x;
                                break;
                            },
                            @as(c_int, '*') => {
                                a[@as(c_int, 0)] *= x;
                                break;
                            },
                            @as(c_int, '/') => {
                                {
                                    const ref = &a[@as(c_int, 0)];
                                    ref.* = @divTrunc(ref.*, x);
                                }
                                break;
                            },
                            @as(c_int, '%') => {
                                {
                                    const ref = &a[@as(c_int, 0)];
                                    ref.* = @rem(ref.*, x);
                                }
                                break;
                            },
                            @as(c_int, 'l') => {
                                a[@as(c_int, 0)] = vars[@as(usize, @intCast(x))];
                                break;
                            },
                            @as(c_int, 's') => {
                                vars[@as(usize, @intCast(x))] = a[@as(c_int, 0)];
                                break;
                            },
                            else => {
                                a[@as(c_int, 0)] = x;
                            },
                        }
                        break;
                    }
                    s += @as(usize, @as(usize, @intCast(3)));
                    break;
                },
                @as(c_int, 'D') => {
                    a[@as(c_int, 0)] = a[@as(c_int, 0)] - (@as(ptrdiff_t, 2) * (a[@as(c_int, 0)] & @as(ptrdiff_t, 15)));
                    break;
                },
                @as(c_int, 'B') => {
                    a[@as(c_int, 0)] = (@as(ptrdiff_t, 16) * @divTrunc(a[@as(c_int, 0)], @as(ptrdiff_t, 10))) + @rem(a[@as(c_int, 0)], @as(ptrdiff_t, 10));
                    break;
                },
                @as(c_int, '>') => {
                    if (a[@as(c_int, 0)] > @as(ptrdiff_t, @as(c_int, escape1(&s)))) {
                        a[@as(c_int, 0)] += @as(c_int, escape1(&s));
                    } else {
                        _ = escape1(&s);
                    }
                    break;
                },
                else => {
                    cap_1.*.out.?(cap_1.*.outptr, '%');
                    cap_1.*.out.?(cap_1.*.outptr, @bitCast(@as(i8, @truncate(c))));
                },
            }
            break;
        }
    } else {
        s -= 1;
        cap_1.*.out.?(cap_1.*.outptr, escape1(&s));
    };
    if (cap_1.*.dopadding != 0) {
        if (cap_1.*.pad != null) {
            while (tenth >= cap_1.*.div) {
                s = cap_1.*.pad;
                while (@as(c_int, s.*) != 0) : (s += 1) {
                    cap_1.*.out.?(cap_1.*.outptr, s.*);
                    tenth -= cap_1.*.div;
                }
            }
        } else while (tenth >= cap_1.*.div) {
            cap_1.*.out.?(cap_1.*.outptr, 0);
            tenth -= cap_1.*.div;
        }
    }
}
pub export fn tcost(arg_cap_1: [*c]CAP, arg_s: [*c]const u8, arg_l: ptrdiff_t, arg_a0: ptrdiff_t, arg_a1: ptrdiff_t, arg_a2: ptrdiff_t, arg_a3: ptrdiff_t) ptrdiff_t {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var s = arg_s;
    _ = &s;
    var l = arg_l;
    _ = &l;
    var a0 = arg_a0;
    _ = &a0;
    var a1 = arg_a1;
    _ = &a1;
    var a2 = arg_a2;
    _ = &a2;
    var a3 = arg_a3;
    _ = &a3;
    var out: ?*const fn (?*anyopaque, u8) callconv(.c) void = cap_1.*.out;
    _ = &out;
    if (!(s != null)) return 10000;
    total = 0;
    cap_1.*.out = cst;
    texec(cap_1, s, l, a0, a1, a2, a3);
    cap_1.*.out = out;
    return total;
}
pub export fn tcompile(arg_cap_1: [*c]CAP, arg_s: [*c]const u8, arg_a0: ptrdiff_t, arg_a1: ptrdiff_t, arg_a2: ptrdiff_t, arg_a3: ptrdiff_t) [*c]u8 {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var s = arg_s;
    _ = &s;
    var a0 = arg_a0;
    _ = &a0;
    var a1 = arg_a1;
    _ = &a1;
    var a2 = arg_a2;
    _ = &a2;
    var a3 = arg_a3;
    _ = &a3;
    var out: ?*const fn (?*anyopaque, u8) callconv(.c) void = cap_1.*.out;
    _ = &out;
    var mydiv: c_long = cap_1.*.div;
    _ = &mydiv;
    if (!(s != null)) return null;
    cap_1.*.out = cpl;
    cap_1.*.div = 10000;
    ssp = vsmk(10);
    texec(cap_1, s, 0, a0, a1, a2, a3);
    cap_1.*.out = out;
    cap_1.*.div = mydiv;
    return ssp;
}
pub export var dopadding: c_int = 0;
pub export var joeterm: [*c]u8 = null;
pub const defentry: [334:0]u8 = ":co#80:li#25:am::ho=\\E[H:cm=\\E[%i%d;%dH:cV=\\E[%i%dH::up=\\E[A:UP=\\E[%dA:DO=\\E[%dB:nd=\\E[C:RI=\\E[%dC:LE=\\E[%dD::cd=\\E[J:ce=\\E[K:cl=\\E[H\\E[J::so=\\E[7m:se=\\E[m:us=\\E[4m:ue=\\E[m::mb=\\E[5m:md=\\E[1m:mh=\\E[2m:me=\\E[m::ZH=\\E[3m:ZR=\\E[m::ku=\\E[A:kd=\\E[B:kl=\\E[D:kr=\\E[C::al=\\E[L:AL=\\E[%dL:dl=\\E[M:DL=\\E[%dM::ic=\\E[@:IC=\\E[%d@:dc=\\E[P:DC=\\E[%dP:".*;
pub fn match(arg_s: [*c]const u8, arg_name: [*c]const u8) callconv(.c) c_int {
    var s = arg_s;
    _ = &s;
    var name = arg_name;
    _ = &name;
    if ((@as(c_int, s[@as(c_int, 0)]) == @as(c_int, 0)) or (@as(c_int, s[@as(c_int, 0)]) == @as(c_int, '#'))) return 0;
    while (true) {
        var x: c_int = undefined;
        _ = &x;
        {
            x = 0;
            while (((@as(c_int, s[@as(usize, @intCast(x))]) == @as(c_int, name[@as(usize, @intCast(x))])) and (@as(c_int, name[@as(usize, @intCast(x))]) != 0)) and (@as(c_int, s[@as(usize, @intCast(x))]) != 0)) : (x += 1) {}
        }
        if ((@as(c_int, name[@as(usize, @intCast(x))]) == @as(c_int, 0)) and ((@as(c_int, s[@as(usize, @intCast(x))]) == @as(c_int, ':')) or (@as(c_int, s[@as(usize, @intCast(x))]) == @as(c_int, '|')))) return 1;
        while (((@as(c_int, s[@as(usize, @intCast(x))]) != @as(c_int, ':')) and (@as(c_int, s[@as(usize, @intCast(x))]) != @as(c_int, '|'))) and (@as(c_int, s[@as(usize, @intCast(x))]) != 0)) {
            x += 1;
        }
        s += @as(usize, @as(usize, @intCast(x + @as(c_int, 1))));
        if (!(@as(c_int, s[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))]) == @as(c_int, '|'))) break;
    }
    return 0;
}
pub fn lfind(arg_s: [*c]u8, arg_pos: ptrdiff_t, arg_fd: ?*FILE, arg_name: [*c]const u8) callconv(.c) [*c]u8 {
    var s = arg_s;
    _ = &s;
    var pos = arg_pos;
    _ = &pos;
    var fd = arg_fd;
    _ = &fd;
    var name = arg_name;
    _ = &name;
    var c: c_int = undefined;
    _ = &c;
    var x: ptrdiff_t = undefined;
    _ = &x;
    if (!(s != null)) {
        s = vsmk(1024);
    }
    while (true) {
        var cont: c_int = 0;
        _ = &cont;
        while ((blk: {
            c = getc(fd);
            break :blk @intFromBool(((c == @as(c_int, ' ')) or (c == @as(c_int, '\t'))) or (c == @as(c_int, '#')));
        }) != 0) while (true) {
            c = getc(fd);
            if (!!((c == -@as(c_int, 1)) or (c == @as(c_int, '\n')))) break;
        };
        if (c == -@as(c_int, 1)) return blk: {
            const tmp = vstrunc(s, pos);
            s = tmp;
            break :blk tmp;
        };
        _ = ungetc(c, fd);
        s = vstrunc(s, blk: {
            const tmp = pos;
            x = tmp;
            break :blk tmp;
        });
        while (true) {
            c = getc(fd);
            if ((c == -@as(c_int, 1)) or (c == @as(c_int, '\n'))) if ((x != pos) and (@as(c_int, s[@bitCast(@as(isize, @intCast(x - @as(ptrdiff_t, 1))))]) == @as(c_int, '\\'))) {
                x -= 1;
                if (!(match(s + @as(usize, @as(usize, @intCast(pos))), name) != 0)) {
                    cont = 1;
                    break;
                } else break;
            } else if (!(match(s + @as(usize, @as(usize, @intCast(pos))), name) != 0)) {
                cont = 1;
                break;
            } else return vstrunc(s, x) else if (c == @as(c_int, '\r')) {} else {
                s = vsset(s, x, @as(u8, @bitCast(@as(i8, @truncate(c)))));
                x += 1;
            }
        }
        if (cont != 0) continue;
        while ((blk: {
            c = getc(fd);
            break :blk @intFromBool(c != -@as(c_int, 1));
        }) != 0) if (c == @as(c_int, '\n')) if (@as(c_int, s[@bitCast(@as(isize, @intCast(x - @as(ptrdiff_t, 1))))]) == @as(c_int, '\\')) {
            x -= 1;
        } else break else if (c == @as(c_int, '\r')) {} else {
            s = vsset(s, x, @as(u8, @bitCast(@as(i8, @truncate(c)))));
            x += 1;
        };
        s = vstrunc(s, x);
        return s;
    }
    return undefined;
}
pub fn findidx(arg_file: ?*FILE, arg_name: [*c]const u8) callconv(.c) off_t {
    var file = arg_file;
    _ = &file;
    var name = arg_name;
    _ = &name;
    var buf: [80]u8 = undefined;
    _ = &buf;
    var addr: off_t = 0;
    _ = &addr;
    while (fgets(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_uint, @truncate(@sizeOf(@TypeOf(buf))))), file) != null) {
        var x: c_int = 0;
        _ = &x;
        var flg: c_int = 0;
        _ = &flg;
        var c: c_int = undefined;
        _ = &c;
        var y: c_int = undefined;
        _ = &y;
        var z: c_int = undefined;
        _ = &z;
        while (true) {
            {
                y = x;
                while (((@as(c_int, buf[@as(usize, @intCast(y))]) != 0) and (@as(c_int, buf[@as(usize, @intCast(y))]) != @as(c_int, ' '))) and (@as(c_int, buf[@as(usize, @intCast(y))]) != @as(c_int, '\n'))) : (y += 1) {}
            }
            c = buf[@as(usize, @intCast(y))];
            buf[@as(usize, @intCast(y))] = 0;
            if ((c == @as(c_int, '\n')) or !(c != 0)) {
                z = zhtoi(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @as(usize, @intCast(x))));
                addr += z;
            } else if (!(strcmp(@as([*c]u8, @ptrCast(@alignCast(&buf))) + @as(usize, @as(usize, @intCast(x))), name) != 0)) {
                flg = 1;
            }
            x = y + @as(c_int, 1);
            if (!((c != 0) and (c != @as(c_int, '\n')))) break;
        }
        if (flg != 0) return addr;
    }
    return 0;
}
pub fn findcap(arg_cap_1: [*c]CAP, arg_name: [*c]const u8) callconv(.c) [*c]struct_sortentry {
    var cap_1 = arg_cap_1;
    _ = &cap_1;
    var name = arg_name;
    _ = &name;
    var x: ptrdiff_t = undefined;
    _ = &x;
    var y: ptrdiff_t = undefined;
    _ = &y;
    var z: ptrdiff_t = undefined;
    _ = &z;
    var found: c_int = undefined;
    _ = &found;
    x = 0;
    y = cap_1.*.sortlen;
    z = -@as(c_int, 1);
    while (z != @divTrunc(x + y, @as(ptrdiff_t, 2))) {
        z = @divTrunc(x + y, @as(ptrdiff_t, 2));
        found = strcmp(name, cap_1.*.sort[@as(usize, @intCast(z))].name);
        if (found > @as(c_int, 0)) {
            x = z;
        } else if (found < @as(c_int, 0)) {
            y = z;
        } else return cap_1.*.sort + @as(usize, @as(usize, @intCast(z)));
    }
    return null;
}
pub fn escape1(arg_s: [*c][*c]const u8) callconv(.c) u8 {
    var s = arg_s;
    _ = &s;
    var c: u8 = (blk: {
        const ref = &s.*;
        const tmp = ref.*;
        ref.* += 1;
        break :blk tmp;
    }).*;
    _ = &c;
    if ((@as(c_int, c) == @as(c_int, '^')) and (@as(c_int, s.*.*) != 0)) if (@as(c_int, s.*.*) != @as(c_int, '?')) return @bitCast(@as(i8, @truncate(@as(c_int, 31) & @as(c_int, (blk: {
        const ref = &s.*;
        const tmp = ref.*;
        ref.* += 1;
        break :blk tmp;
    }).*)))) else {
        s.* += 1;
        return 127;
    } else if ((@as(c_int, c) == @as(c_int, '\\')) and (@as(c_int, s.*.*) != 0)) {
        while (true) {
            switch (@as(c_int, blk: {
                const tmp = (blk_1: {
                    const ref = &s.*;
                    const tmp_2 = ref.*;
                    ref.* += 1;
                    break :blk_1 tmp_2;
                }).*;
                c = tmp;
                break :blk tmp;
            })) {
                @as(c_int, '0'), @as(c_int, '1'), @as(c_int, '2'), @as(c_int, '3'), @as(c_int, '4'), @as(c_int, '5'), @as(c_int, '6'), @as(c_int, '7') => {
                    c = @bitCast(@as(i8, @truncate(@as(c_int, c) - @as(c_int, '0'))));
                    if ((@as(c_int, s.*.*) >= @as(c_int, '0')) and (@as(c_int, s.*.*) <= @as(c_int, '7'))) {
                        c = @bitCast(@as(i8, @truncate(((@as(c_int, c) << @intCast(@as(c_int, 3))) + @as(c_int, (blk: {
                            const ref = &s.*;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        }).*)) - @as(c_int, '0'))));
                    }
                    if ((@as(c_int, s.*.*) >= @as(c_int, '0')) and (@as(c_int, s.*.*) <= @as(c_int, '7'))) {
                        c = @bitCast(@as(i8, @truncate(((@as(c_int, c) << @intCast(@as(c_int, 3))) + @as(c_int, (blk: {
                            const ref = &s.*;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        }).*)) - @as(c_int, '0'))));
                    }
                    return c;
                },
                @as(c_int, 'e'), @as(c_int, 'E') => {
                    return 27;
                },
                @as(c_int, 'n'), @as(c_int, 'l') => {
                    return 10;
                },
                @as(c_int, 'r') => {
                    return 13;
                },
                @as(c_int, 't') => {
                    return 9;
                },
                @as(c_int, 'b') => {
                    return 8;
                },
                @as(c_int, 'f') => {
                    return 12;
                },
                @as(c_int, 's') => {
                    return 32;
                },
                else => {
                    return c;
                },
            }
            break;
        }
    } else return c;
    return undefined;
}
pub var total: ptrdiff_t = 0;
pub fn cst(arg_ptr: ?*anyopaque, arg_c: u8) callconv(.c) void {
    var ptr = arg_ptr;
    _ = &ptr;
    var c = arg_c;
    _ = &c;
    total += 1;
}
pub var ssp: [*c]u8 = null;
pub fn cpl(arg_ptr: ?*anyopaque, arg_c: u8) callconv(.c) void {
    var ptr = arg_ptr;
    _ = &ptr;
    var c = arg_c;
    _ = &c;
    ssp = vsadd(ssp, c);
}


pub const sortentry = struct_sortentry;

comptime {
    if (@sizeOf(struct_cap) != 88) @compileError("CAP size mismatch");
    if (@sizeOf(struct_sortentry) != 16) @compileError("sortentry size mismatch");
    if (@sizeOf(struct_stat) != 136) @compileError("struct_stat stub size mismatch");
}
