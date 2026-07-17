//! Variable-length arrays of strings — replaces `joe/va.c`

const std = @import("std");

// ═══════════════════════════════════════════════════════════════════════
// External C functions
// ═══════════════════════════════════════════════════════════════════════

extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn joe_realloc(ptr: ?*anyopaque, size: isize) ?*anyopaque;
extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn mmove(d: ?*anyopaque, s: ?*const anyopaque, sz: isize) ?*anyopaque;
extern fn vsdup(s: ?*anyopaque) ?*anyopaque;
extern fn vsrm(s: ?*anyopaque) void;
extern fn vscmp(a: ?*anyopaque, b: ?*anyopaque) c_int;
extern fn vsmk(len: isize) ?*anyopaque;
extern fn vsncpy(a: ?*anyopaque, pos: isize, s: ?*const anyopaque, len: isize) ?*anyopaque;
extern fn vsspan(s: ?*const anyopaque, len: isize, sep: ?*const anyopaque, seplen: isize) isize;
extern fn vsscan(s: ?*const anyopaque, len: isize, sep: ?*const anyopaque, seplen: isize) isize;
extern fn jsort(base: ?*anyopaque, nel: isize, width: isize, compar: ?*const anyopaque) void;

// ═══════════════════════════════════════════════════════════════════════
// Types (matching C)
// ═══════════════════════════════════════════════════════════════════════

/// aELEMENT = char * in C
pub const AELEM = ?*anyopaque;
pub const aterm: AELEM = null;
pub const ablank: AELEM = null;

/// Array header layout: [size: isize][len: isize][AELEM...]
/// The returned pointer points to the first element (AELEM).
/// vary[-2] = size, vary[-1] = len

fn aSize(vary: [*]AELEM) isize {
    const header = @as([*]isize, @ptrCast(vary)) - 2;
    return header[0];
}

fn aSetSize(vary: [*]AELEM, sz: isize) void {
    const header = @as([*]isize, @ptrCast(vary)) - 2;
    header[0] = sz;
}

fn aLen(vary: [*]AELEM) isize {
    const header = @as([*]isize, @ptrCast(vary)) - 2;
    return header[1];
}

fn aSetLen(vary: [*]AELEM, l: isize) void {
    const header = @as([*]isize, @ptrCast(vary)) - 2;
    header[1] = l;
}

// ═══════════════════════════════════════════════════════════════════════
// Exported API
// ═══════════════════════════════════════════════════════════════════════

export fn vamk(len: isize) [*]AELEM {
    const alloc_size = (1 + len) * @sizeOf(AELEM) + 2 * @sizeOf(isize);
    const newa = @as([*]isize, @alignCast(@ptrCast(joe_malloc(alloc_size) orelse unreachable)));
    newa[0] = len; // size
    newa[1] = 0;   // length
    const elems = @as([*]AELEM, @ptrCast(newa + 2));
    elems[0] = aterm;
    return elems;
}

export fn varm(vary: [*]AELEM) void {
    if (@intFromPtr(vary) != 0) {
        _ = vazap(vary, 0, aLen(vary));
        const header = @as([*]isize, @ptrCast(vary)) - 2;
        joe_free(@ptrCast(header));
    }
}

export fn alen(ary: [*]AELEM) isize {
    if (@intFromPtr(ary) == 0) return 0;
    var n: isize = 0;
    while (ary[@as(usize, @intCast(n))] != aterm) n += 1;
    return n;
}

export fn vaensure(vary: [*]AELEM, len: isize) [*]AELEM {
    if (@intFromPtr(vary) == 0) return vamk(len);
    if (len > aSize(vary)) {
        const new_len = len + (len >> 2); // 25% extra
        const old_header = @as([*]isize, @ptrCast(vary)) - 2;
        const new_header = @as([*]isize, @alignCast(@ptrCast(joe_realloc(@ptrCast(old_header), (new_len + 1) * @sizeOf(AELEM) + 2 * @sizeOf(isize)) orelse return vary)));
        const new_vary = @as([*]AELEM, @ptrCast(new_header + 2));
        aSetSize(new_vary, new_len);
        return new_vary;
    }
    return vary;
}

export fn vazap(vary: [*]AELEM, pos: isize, n: isize) [*]AELEM {
    if (@intFromPtr(vary) != 0) {
        const l = aLen(vary);
        const end = if (pos + n <= l) pos + n else l;
        var i = pos;
        while (i < end) : (i += 1) vsrm(vary[@as(usize, @intCast(i))]);
    }
    return vary;
}

export fn vatrunc(vary: [*]AELEM, len: isize) [*]AELEM {
    var v = if (@intFromPtr(vary) == 0 or len > aSize(vary)) vaensure(vary, len) else vary;
    const l = aLen(v);
    if (len < l) {
        _ = vazap(v, len, l - len);
        v[@as(usize, @intCast(len))] = v[@as(usize, @intCast(l))];
        aSetLen(v, len);
    } else if (len > l) {
        _ = vafill(v, l, ablank, len - l);
    }
    return v;
}

export fn vafill(vary: [*]AELEM, pos: isize, el: AELEM, len: isize) [*]AELEM {
    var v = vary;
    const olen = aLen(v);
    if (@intFromPtr(v) == 0 or pos + len > aSize(v)) v = vaensure(v, pos + len);
    const new_olen_val = if (@intFromPtr(vary) == @intFromPtr(v)) olen else @as(isize, 0);
    const real_olen = new_olen_val;
    if (pos + len > real_olen) {
        v[@as(usize, @intCast(pos + len))] = v[@as(usize, @intCast(real_olen))];
        aSetLen(v, pos + len);
    }
    var x = pos;
    while (x < pos + len) : (x += 1) {
        v[@as(usize, @intCast(x))] = vsdup(el);
    }
    if (pos > real_olen) _ = vafill(v, real_olen, ablank, pos - real_olen);
    return v;
}

export fn vandup(vary: [*]AELEM, pos: isize, array: [*]AELEM, len: isize) [*]AELEM {
    var v = vary;
    const olen = aLen(v);
    if (@intFromPtr(v) == 0 or pos + len > aSize(v)) v = vaensure(v, pos + len);
    const real_olen = if (@intFromPtr(vary) == @intFromPtr(v)) olen else @as(isize, 0);
    if (pos + len > real_olen) {
        v[@as(usize, @intCast(pos + len))] = v[@as(usize, @intCast(real_olen))];
        aSetLen(v, pos + len);
    }
    if (pos > real_olen) _ = vafill(v, real_olen, ablank, pos - real_olen);
    var x: isize = 0;
    while (x < len) : (x += 1) {
        v[@as(usize, @intCast(x + pos))] = vsdup(array[@as(usize, @intCast(x))]);
    }
    return v;
}

export fn vadup(vary: [*]AELEM) [*]AELEM {
    if (@intFromPtr(vary) == 0) return vamk(0); return vandup(vamk(0), 0, vary, aLen(vary));
}

export fn _vaset(vary: [*]AELEM, pos: isize, el: AELEM) [*]AELEM {
    var v = vary;
    if (@intFromPtr(v) == 0 or pos + 1 > aSize(v)) v = vaensure(v, pos + 1);
    const l = aLen(v);
    if (pos > l) {
        _ = vafill(v, l, ablank, pos - l);
        v[@as(usize, @intCast(pos + 1))] = v[@as(usize, @intCast(pos))];
        v[@as(usize, @intCast(pos))] = el;
        aSetLen(v, pos + 1);
    } else if (pos == l) {
        v[@as(usize, @intCast(pos + 1))] = v[@as(usize, @intCast(pos))];
        v[@as(usize, @intCast(pos))] = el;
        aSetLen(v, pos + 1);
    } else {
        vsrm(v[@as(usize, @intCast(pos))]);
        v[@as(usize, @intCast(pos))] = el;
    }
    return v;
}

fn _acmp(a: *AELEM, b: *AELEM) c_int {
    return vscmp(a.*, b.*);
}

export fn vasort(ary: [*]AELEM, len: isize) [*]AELEM {
    if (@intFromPtr(ary) == 0 or len == 0) return ary;
    jsort(@ptrCast(ary), len, @sizeOf(AELEM), @ptrCast(&_acmp));
    return ary;
}

export fn vadel(ary: [*]AELEM, ofst: isize, len: isize) void {
    if (@intFromPtr(ary) != 0 and ofst < aLen(ary)) {
        var l = len;
        const al = aLen(ary);
        if (ofst + l > al) l = al - ofst;
        var x = ofst;
        while (x < ofst + l) : (x += 1) vsrm(ary[@as(usize, @intCast(x))]);
        if (al - (ofst + l) > 0) {
            _ = mmove(
                @ptrCast(&ary[@as(usize, @intCast(ofst))]),
                @ptrCast(&ary[@as(usize, @intCast(ofst + l))]),
                (al - (ofst + l)) * @sizeOf(AELEM),
            );
        }
        aSetLen(ary, al - l);
        ary[@as(usize, @intCast(aLen(ary)))] = @as(?*anyopaque, @ptrFromInt(0));
    }
}

export fn vauniq(ary: [*]AELEM) void {
    if (@intFromPtr(ary) != 0) {
        var len = aLen(ary);
        var x: isize = 0;
        while (x < len - 1) : (x += 1) {
            var y: isize = x + 1;
            while (y < len and vscmp(ary[@as(usize, @intCast(x))], ary[@as(usize, @intCast(y))]) == 0) y += 1;
            vadel(ary, x + 1, y - (x + 1));
            len -= y - (x + 1);
        }
    }
}

export fn vawords(a: [*]AELEM, s: ?*const anyopaque, len: isize, sep: ?*const anyopaque, seplen: isize) [*]AELEM {
    var av = if (@intFromPtr(a) != 0) vatrunc(a, 0) else vamk(10);
    var remaining = len;
    var ptr = s;
    while (true) {
        const skip = vsspan(ptr, remaining, sep, seplen);
        ptr = @ptrFromInt(@intFromPtr(ptr) + @as(usize, @intCast(skip)));
        remaining -= skip;
        if (remaining <= 0) break;
        const word_len = vsscan(ptr, remaining, sep, seplen);
        if (word_len != ~@as(isize, 0)) {
            av = _vaadd(av, vsncpy(vsmk(word_len), 0, ptr, word_len));
            ptr = @ptrFromInt(@intFromPtr(ptr) + @as(usize, @intCast(word_len)));
            remaining -= word_len;
        } else {
            av = _vaadd(av, vsncpy(vsmk(remaining), 0, ptr, remaining));
            break;
        }
    }
    return av;
}

// The vaadd and vaset macros need to be accessible from C.
// vaadd(v, el) calls _vaset when the array is full or null.
// vaset(v, p, el) calls _vaset only when needed, else does inline.
// Since macros can't be exported, we provide _vaset and let the
// inline logic happen in C via the macro definitions.

/// `vaadd(v, el)` as a real function, taking/returning nullable opaque
/// pointers so it can be called from other Zig modules (and C) without
/// fighting the `[*]AELEM` non-null pointer type.  Implements the macro.
pub export fn vaadd(vary: ?*anyopaque, el: ?*anyopaque) ?*anyopaque {
    const v = @as([*]AELEM, @alignCast(@ptrCast(vary orelse @as(?*anyopaque, @ptrFromInt(0)))));
    const r = _vaadd(v, el);
    return @ptrCast(r);
}

// ═══════════════════════════════════════════════════════════════════════
// Internal helpers
// ═══════════════════════════════════════════════════════════════════════

/// Implements the vaadd() macro for use from Zig code.
fn _vaadd(vary: [*]AELEM, el: AELEM) [*]AELEM {
    if (@intFromPtr(vary) == 0 or aLen(vary) == aSize(vary))
        return _vaset(vary, aLen(vary), el);
    const l = aLen(vary);
    vary[@as(usize, @intCast(l + 1))] = vary[@as(usize, @intCast(l))];
    vary[@as(usize, @intCast(l))] = el;
    aSetLen(vary, l + 1);
    return vary;
}
