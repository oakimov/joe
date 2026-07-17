//! Variable-length strings — replaces `joe/vs.c`
//!
//! Dynamic strings stored as `[bksize][length]<chars><0>`.  The exposed
//! pointer addresses the chars (so they are C‑string compatible), with
//! the header two `ptrdiff_t`s back: `s[-2]`=capacity, `s[-1]`=length.

const std = @import("std");

extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn joe_realloc(ptr: ?*anyopaque, size: isize) ?*anyopaque;
extern fn joe_free(ptr: ?*anyopaque) void;
extern fn mmove(d: ?*anyopaque, s: ?*const anyopaque, sz: isize) ?*anyopaque;

const sterm: u8 = 0;
const sblank: u8 = ' ';

/// scmp(a, b): a>b → 1, a==b → 0, else -1
fn scmp(a: u8, b: u8) c_int {
    if (a > b) return 1;
    if (a == b) return 0;
    return -1;
}

fn sSize(vary: [*c]u8) isize {
    if (@intFromPtr(vary) == 0) return 0;
    const hdr = @as([*c]isize, @alignCast(@ptrCast(vary))) - 2;
    return hdr[0];
}
fn sSetSize(vary: [*c]u8, sz: isize) void {
    const hdr = @as([*c]isize, @alignCast(@ptrCast(vary))) - 2;
    hdr[0] = sz;
}
fn sLen(vary: [*c]u8) isize {
    const hdr = @as([*c]isize, @alignCast(@ptrCast(vary))) - 2;
    return hdr[1];
}
fn sLEN(vary: [*c]u8) isize {
    if (@intFromPtr(vary) == 0) return 0;
    return sLen(vary);
}
fn sSetLen(vary: [*c]u8, l: isize) void {
    const hdr = @as([*c]isize, @alignCast(@ptrCast(vary))) - 2;
    hdr[1] = l;
}

export fn sicmp(a_in: u8, b_in: u8) c_int {
    var a = a_in;
    var b = b_in;
    if (a >= 'A' and a <= 'Z') a = a + 'a' - 'A';
    if (b >= 'A' and b <= 'Z') b = b + 'a' - 'A';
    return scmp(a, b);
}

export fn vsmk(len: isize) [*c]u8 {
    const alloc = (1 + len) * @sizeOf(u8) + 2 * @sizeOf(isize);
    const news = @as([*c]isize, @alignCast(@ptrCast(joe_malloc(alloc) orelse return null)));
    news[0] = len;
    news[1] = 0;
    const elems: [*c]u8 = @ptrCast(news + 2);
    elems[0] = sterm;
    return elems;
}

export fn vsrm(vary: [*c]u8) void {
    if (@intFromPtr(vary) != 0) {
        const hdr = @as([*c]isize, @alignCast(@ptrCast(vary))) - 2;
        joe_free(@ptrCast(hdr));
    }
}

export fn slen(ary: [*c]const u8) isize {
    if (@intFromPtr(ary) == 0) return 0;
    var p = ary;
    while (p[0] != sterm) p += 1;
    return @as(isize, @intCast(@intFromPtr(p) - @intFromPtr(ary)));
}

export fn vsensure(vary_in: [*c]u8, len: isize) [*c]u8 {
    var vary = vary_in;
    if (@intFromPtr(vary) == 0) {
        vary = vsmk(len);
        return vary;
    }
    if (len > sSize(vary)) {
        const new_len = len + (len >> 2);
        const old_hdr = @as([*c]isize, @alignCast(@ptrCast(vary))) - 2;
        const new_hdr = @as([*c]isize, @alignCast(@ptrCast(joe_realloc(@ptrCast(old_hdr), (new_len + 1) * @sizeOf(u8) + 2 * @sizeOf(isize)) orelse return vary)));
        vary = @ptrCast(new_hdr + 2);
        sSetSize(vary, new_len);
    }
    return vary;
}

export fn vstrunc(vary_in: [*c]u8, len: isize) [*c]u8 {
    var vary = vary_in;
    if (@intFromPtr(vary) == 0 or len > sLen(vary)) vary = vsensure(vary, len + 16);
    if (len < sLen(vary)) {
        vary[@as(usize, @intCast(len))] = vary[@as(usize, @intCast(sLen(vary)))];
        sSetLen(vary, len);
    } else if (len > sLen(vary)) {
        vary = vsfill(vary, sLen(vary), sblank, len - sLen(vary));
    }
    return vary;
}

export fn vsfill(vary_in: [*c]u8, pos: isize, el: u8, len: isize) [*c]u8 {
    var vary = vary_in;
    const olen = sLEN(vary);
    if (@intFromPtr(vary) == 0 or pos + len > sSize(vary)) vary = vsensure(vary, pos + len);
    if (pos + len > olen) {
        vary[@as(usize, @intCast(pos + len))] = vary[@as(usize, @intCast(olen))];
        sSetLen(vary, pos + len);
    }
    var x = pos;
    while (x != pos + len) : (x += 1) vary[@as(usize, @intCast(x))] = el;
    if (pos > olen) vary = vsfill(vary, pos, sblank, pos - olen);
    return vary;
}

export fn vsncpy(vary_in: [*c]u8, pos: isize, array: [*c]const u8, len: isize) [*c]u8 {
    var vary = vary_in;
    const olen = sLEN(vary);
    if (@intFromPtr(vary) == 0 or pos + len > sSize(vary)) vary = vsensure(vary, pos + len);
    if (pos + len > olen) {
        vary[@as(usize, @intCast(pos + len))] = vary[@as(usize, @intCast(olen))];
        sSetLen(vary, pos + len);
    }
    if (pos > olen) vary = vsfill(vary, olen, sblank, pos - olen);
    _ = mmove(@ptrCast(&vary[@as(usize, @intCast(pos))]), @ptrCast(array), len * @sizeOf(u8));
    return vary;
}

export fn vsndup(vary_in: [*c]u8, pos: isize, array: [*c]u8, len: isize) [*c]u8 {
    var vary = vary_in;
    const olen = sLEN(vary);
    if (@intFromPtr(vary) == 0 or pos + len > sSize(vary)) vary = vsensure(vary, pos + len);
    if (pos + len > olen) {
        vary[@as(usize, @intCast(pos + len))] = vary[@as(usize, @intCast(olen))];
        sSetLen(vary, pos + len);
    }
    if (pos > olen) vary = vsfill(vary, olen, sblank, pos - olen);
    var x = pos;
    while (x != len) : (x += 1) vary[@as(usize, @intCast(x))] = array[@as(usize, @intCast(x))];
    return vary;
}

export fn vsdup(vary: [*c]u8) [*c]u8 {
    if (@intFromPtr(vary) == 0) return vsmk(0);
    return vsndup(vsmk(0), 0, vary, sLen(vary));
}

export fn _vsset(vary_in: [*c]u8, pos: isize, el: u8) [*c]u8 {
    var vary = vary_in;
    if (@intFromPtr(vary) == 0 or pos + 1 > sSize(vary)) vary = vsensure(vary, pos + 1);
    if (pos > sLen(vary)) {
        vary = vsfill(vary, sLen(vary), sblank, pos - sLen(vary));
        vary[@as(usize, @intCast(pos + 1))] = vary[@as(usize, @intCast(pos))];
        vary[@as(usize, @intCast(pos))] = el;
        sSetLen(vary, pos + 1);
    } else if (pos == sLen(vary)) {
        vary[@as(usize, @intCast(pos + 1))] = vary[@as(usize, @intCast(pos))];
        vary[@as(usize, @intCast(pos))] = el;
        sSetLen(vary, pos + 1);
    } else {
        vary[@as(usize, @intCast(pos))] = el;
    }
    return vary;
}

export fn vsbsearch(ary: [*c]const u8, len: isize, el: u8) isize {
    if (@intFromPtr(ary) == 0 or len == 0) return 0;
    var y = len;
    var x: isize = 0;
    var z: isize = ~@as(isize, 0);
    while (z != @divTrunc(x + y, 2)) {
        z = @divTrunc(x + y, 2);
        switch (scmp(el, ary[@as(usize, @intCast(z))])) {
            1 => x = z,
            -1 => y = z,
            else => return z,
        }
    }
    return y;
}

export fn vscmpn(a: [*c]u8, myalen: isize, b: [*c]u8, blen: isize) c_int {
    if (@intFromPtr(a) == 0 and @intFromPtr(b) == 0) return 0;
    if (@intFromPtr(a) == 0) return -1;
    if (@intFromPtr(b) == 0) return 1;
    const l = if (myalen > blen) sLen(a) else blen;
    var x: isize = 0;
    while (x != l) : (x += 1) {
        const t = scmp(a[@as(usize, @intCast(x))], b[@as(usize, @intCast(x))]);
        if (t != 0) return t;
    }
    if (myalen > blen) return 1;
    if (myalen < blen) return -1;
    return 0;
}

export fn vscmp(a: [*c]u8, b: [*c]u8) c_int {
    return vscmpn(a, sLen(a), b, sLen(b));
}

export fn vsscan(a: [*c]const u8, myalen: isize, b: [*c]const u8, blen: isize) isize {
    var x: isize = 0;
    while (x != myalen) : (x += 1) {
        const z = vsbsearch(b, blen, a[@as(usize, @intCast(x))]);
        if (z < blen and scmp(b[@as(usize, @intCast(z))], a[@as(usize, @intCast(x))]) == 0) return x;
    }
    return ~@as(isize, 0);
}

export fn vsspan(a: [*c]const u8, myalen: isize, b: [*c]const u8, blen: isize) isize {
    var x: isize = 0;
    while (x != myalen) : (x += 1) {
        const z = vsbsearch(b, blen, a[@as(usize, @intCast(x))]);
        if (z == blen or scmp(b[@as(usize, @intCast(z))], a[@as(usize, @intCast(x))]) != 0) break;
    }
    return x;
}
