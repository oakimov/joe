//! Fast block move/copy/set subroutines — replaces `joe/blocks.c`.
//!
//! The C original uses Duff's-device switch fallthrough for manual
//! unrolling.  Here we use plain loops over typed slices; LLVM's
//! auto-vectorizer produces equivalent (often better) code, and the
//! observable behaviour is identical.

const std = @import("std");

// ═══════════════════════════════════════════════════════════════════════
// mmove — copy `sz` bytes, overlap-safe (memmove semantics)
// ═══════════════════════════════════════════════════════════════════════

export fn mmove(d: ?*anyopaque, s: ?*const anyopaque, sz: isize) ?*anyopaque {
    if (d == null or s == null or sz <= 0) return d;
    const dp: [*]u8 = @ptrCast(d.?);
    const sp: [*]const u8 = @ptrCast(s.?);
    const n: usize = @intCast(sz);
    if (@intFromPtr(d) == @intFromPtr(s)) return d;
    if (@intFromPtr(d) > @intFromPtr(s)) {
        // copy backwards
        var i: usize = n;
        while (i > 0) {
            i -= 1;
            dp[i] = sp[i];
        }
    } else {
        // copy forwards
        var i: usize = 0;
        while (i < n) : (i += 1) dp[i] = sp[i];
    }
    return d;
}

// ═══════════════════════════════════════════════════════════════════════
// mset / msetI / msetD / msetP
// ═══════════════════════════════════════════════════════════════════════

export fn mset(dest: ?*anyopaque, c: u8, sz: isize) ?*anyopaque {
    if (dest == null or sz <= 0) return dest;
    const dp: [*]u8 = @ptrCast(dest.?);
    const n: usize = @intCast(sz);
    var i: usize = 0;
    while (i < n) : (i += 1) dp[i] = c;
    return dest;
}

export fn msetI(dest: ?*anyopaque, c: c_int, sz: isize) ?*anyopaque {
    if (dest == null or sz <= 0) return dest;
    const dp: [*]c_int = @alignCast(@ptrCast(dest.?));
    const n: usize = @intCast(sz);
    var i: usize = 0;
    while (i < n) : (i += 1) dp[i] = c;
    return dest;
}

export fn msetD(dest: ?*anyopaque, c: isize, sz: isize) ?*anyopaque {
    if (dest == null or sz <= 0) return dest;
    const dp: [*]isize = @alignCast(@ptrCast(dest.?));
    const n: usize = @intCast(sz);
    var i: usize = 0;
    while (i < n) : (i += 1) dp[i] = c;
    return dest;
}

export fn msetP(dest: ?*anyopaque, c: ?*anyopaque, sz: isize) ?*anyopaque {
    if (dest == null or sz <= 0) return dest;
    const dp: [*]?*anyopaque = @alignCast(@ptrCast(dest.?));
    const n: usize = @intCast(sz);
    var i: usize = 0;
    while (i < n) : (i += 1) dp[i] = c;
    return dest;
}

// ═══════════════════════════════════════════════════════════════════════
// mcnt — count occurrences of `c` in `blk[0..size]`
// ═══════════════════════════════════════════════════════════════════════

export fn mcnt(blk: ?*const anyopaque, c: u8, size: isize) isize {
    if (blk == null or size <= 0) return 0;
    const bp: [*]const u8 = @ptrCast(blk.?);
    const n: usize = @intCast(size);
    var nlines: isize = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        if (bp[i] == c) nlines += 1;
    }
    return nlines;
}
