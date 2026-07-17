//! Various utilities — replaces `joe/utils.c`.
//!
//! min/max, EINTR-retrying read/write/ioctl, malloc wrappers, string and
//! numeric helpers, config-line parsers, and qsort wrapper.

const std = @import("std");

// ═══════════════════════════════════════════════════════════════════════
// libc bindings
// ═══════════════════════════════════════════════════════════════════════

extern fn malloc(size: usize) ?*anyopaque;
extern fn calloc(nmemb: usize, size: usize) ?*anyopaque;
extern fn realloc(ptr: ?*anyopaque, size: usize) ?*anyopaque;
extern fn free(ptr: ?*anyopaque) void;
extern fn memcpy(a: ?*anyopaque, b: ?*const anyopaque, n: usize) ?*anyopaque;
extern fn strncpy(a: [*c]u8, b: [*c]const u8, n: usize) [*c]u8;
extern fn strncmp(a: [*c]const u8, b: [*c]const u8, n: usize) c_int;
extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
extern fn strlen(s: [*c]const u8) usize;
extern fn read(fd: c_int, buf: ?*anyopaque, n: usize) isize;
extern fn write(fd: c_int, buf: ?*const anyopaque, n: usize) isize;
extern fn ioctl(fd: c_int, req: c_ulong, ...) c_int;
extern fn qsort(base: ?*anyopaque, n: usize, sz: usize, cmp: ?*const anyopaque) void;
extern fn fprintf(f: ?*anyopaque, fmt: [*c]const u8, ...) c_int;
extern fn fputc(c: c_int, f: ?*anyopaque) c_int;
extern fn exit(status: c_int) noreturn;
extern fn __error() [*c]c_int;
fn errno_() c_int { return __error().*; }
const EINTR: c_int = 4;

extern fn ttsig(sig: c_int) void;

// escape() lives in regex.c
extern fn escape(utf8: c_int, ptr: [*c][*c]const u8, len: ?*isize, cat: ?*?*anyopaque) c_int;

// utf8_map + charmap vtable (joe_isalpha_ macro)
extern var utf8_map: ?*anyopaque;
extern fn utf8_decode_fwrd(pos: [*c][*c]const u8, len: ?*isize) c_int;
extern fn utf8_decode_string(s: [*c]const u8) c_int;
extern fn utf8_encode(buf: [*c]u8, c: c_int) isize;

const CharmapFn = ?*const fn (?*anyopaque, c_int) callconv(.c) c_int;
const Charmap = extern struct {
    next: ?*anyopaque,
    name: ?*const anyopaque,
    @"type": c_int,
    _pad: c_int,
    is_punct: CharmapFn,
    is_print: CharmapFn,
    is_space: CharmapFn,
    is_alpha_: CharmapFn,
    is_alnum_: CharmapFn,
    to_lower: CharmapFn,
    to_upper: CharmapFn,
};
fn joe_isalpha_(map: ?*anyopaque, c: c_int) c_int {
    const m = @as(*const Charmap, @alignCast(@ptrCast(map orelse return 0)));
    if (m.is_alpha_) |f| return f(map, c);
    return 0;
}
fn joe_isalnum_(map: ?*anyopaque, c: c_int) c_int {
    const m = @as(*const Charmap, @alignCast(@ptrCast(map orelse return 0)));
    if (m.is_alnum_) |f| return f(map, c);
    return 0;
}

// C class (for parse_class)
const Interval = extern struct { first: c_int, last: c_int };
const Cclass = extern struct {
    size: isize,
    len: isize,
    intervals: ?*Interval,
    rset: [1]extern struct { _opaque: [128]u8 } align(8),
};

// ═══════════════════════════════════════════════════════════════════════
// min / max
// ═══════════════════════════════════════════════════════════════════════

export fn uns_min(a: c_uint, b: c_uint) c_uint { return if (a < b) a else b; }
export fn int_min(a: c_int, b: c_int) c_int { return if (a < b) a else b; }
export fn long_max(a: c_long, b: c_long) c_long { return if (a > b) a else b; }
export fn long_min(a: c_long, b: c_long) c_long { return if (a < b) a else b; }
export fn off_max(a: i64, b: i64) i64 { return if (a > b) a else b; }
export fn off_min(a: i64, b: i64) i64 { return if (a < b) a else b; }
export fn diff_max(a: isize, b: isize) isize { return if (a > b) a else b; }
export fn diff_min(a: isize, b: isize) isize { return if (a < b) a else b; }

// ═══════════════════════════════════════════════════════════════════════
// joe_read / joe_write / joe_ioctl — retry on EINTR
// ═══════════════════════════════════════════════════════════════════════

export fn joe_read(fd: c_int, buf: ?*anyopaque, size: isize) isize {
    var rt: isize = 0;
    while (true) {
        rt = read(fd, buf, @intCast(size));
        if (!(rt < 0 and errno_() == EINTR)) break;
    }
    return rt;
}

export fn joe_write(fd: c_int, buf: ?*const anyopaque, size: isize) isize {
    var rt: isize = 0;
    while (true) {
        rt = write(fd, buf, @intCast(size));
        if (!(rt < 0 and errno_() == EINTR)) break;
    }
    return rt;
}

export fn joe_ioctl(fd: c_int, req: c_ulong, ptr: ?*anyopaque) c_int {
    var rt: c_int = 0;
    while (true) {
        rt = ioctl(fd, req, ptr);
        if (!(rt == -1 and errno_() == EINTR)) break;
    }
    return rt;
}

// ═══════════════════════════════════════════════════════════════════════
// malloc wrappers
// ═══════════════════════════════════════════════════════════════════════

export fn joe_malloc(size: isize) ?*anyopaque {
    const p = malloc(@intCast(size));
    if (p == null) ttsig(-1);
    return p;
}
export fn joe_calloc(nmemb: isize, size: isize) ?*anyopaque {
    const p = calloc(@intCast(nmemb), @intCast(size));
    if (p == null) ttsig(-1);
    return p;
}
export fn joe_realloc(ptr: ?*anyopaque, size: isize) ?*anyopaque {
    const p = realloc(ptr, @intCast(size));
    if (p == null) ttsig(-1);
    return p;
}
export fn joe_free(ptr: ?*anyopaque) void {
    free(ptr);
}

// ═══════════════════════════════════════════════════════════════════════
// String utilities
// ═══════════════════════════════════════════════════════════════════════

export fn zicmp(a_in: [*c]const u8, b_in: [*c]const u8) c_int {
    var a = a_in;
    var b = b_in;
    while (a[0] != 0 and b[0] != 0) {
        var ca = a[0];
        var cb = b[0];
        if (ca >= 'a' and ca <= 'z') ca = ca - ('a' - 'A');
        if (cb >= 'a' and cb <= 'z') cb = cb - ('a' - 'A');
        if (ca > cb) return 1;
        if (ca < cb) return -1;
        a += 1;
        b += 1;
    }
    if (a[0] != 0) return 1;
    if (b[0] != 0) return -1;
    return 0;
}

export fn zmcmp(a: [*c]const u8, b: [*c]const u8) c_int {
    var x: isize = @intCast(strlen(a));
    while (true) {
        if (a[@as(usize, @intCast(x))] == ':' and a[@as(usize, @intCast(x + 1))] == ':') {
            if ((b[0] == ':' and strcmp(@ptrCast(a + @as(usize, @intCast(x))), b) == 0) or
                strcmp(@ptrCast(a + @as(usize, @intCast(x + 2))), b) == 0) return 0;
        }
        if (x == 0) break;
        x -= 1;
    }
    return strcmp(a, b);
}

export fn zncmp(a: [*c]const u8, b: [*c]const u8, len: isize) c_int {
    return strncmp(a, b, @intCast(len));
}

export fn zdup(bf: [*c]const u8) [*c]u8 {
    const size: usize = @intCast(strlen(bf));
    const p = joe_malloc(@intCast(size + 1)) orelse return null;
    _ = memcpy(p, bf, @intCast(size + 1));
    return @ptrCast(p);
}

export fn zncpy(a: [*c]u8, b: [*c]const u8, len: isize) [*c]u8 {
    _ = strncpy(a, b, @intCast(len));
    return a;
}

export fn zlcpy(a_in: [*c]u8, len_in: isize, b_in: [*c]const u8) [*c]u8 {
    var b = b_in;
    const org = a_in;
    var len = len_in;
    if (len == 0) {
        _ = fprintf(null, "zlcpy called with len == 0\n");
        exit(1);
    }
    len -= 1;
    var a = a_in;
    while (len != 0 and b[0] != 0) {
        a[0] = b[0];
        a += 1;
        b += 1;
        len -= 1;
    }
    a[0] = 0;
    return org;
}

export fn mcpy(a: ?*anyopaque, b: ?*const anyopaque, len: isize) ?*anyopaque {
    if (len != 0) _ = memcpy(a, b, @intCast(len));
    return a;
}

export fn zlcat(a_in: [*c]u8, siz_in: isize, b: [*c]const u8) [*c]u8 {
    const org = a_in;
    var a = a_in;
    var siz = siz_in;
    while (a[0] != 0 and siz != 0) {
        a += 1;
        siz -= 1;
    }
    _ = zlcpy(a, siz, b);
    return org;
}

// ═══════════════════════════════════════════════════════════════════════
// Numeric parsers
// ═══════════════════════════════════════════════════════════════════════

export fn zhtoo(s_in: [*c]const u8) i64 {
    var s = s_in;
    var val: i64 = 0;
    var flg: c_int = 0;
    if (s[0] == '-') {
        s += 1;
        flg = 1;
    } else if (s[0] == '+') {
        s += 1;
    }
    while ((s[0] >= '0' and s[0] <= '9') or (s[0] >= 'a' and s[0] <= 'f') or (s[0] >= 'A' and s[0] <= 'F')) {
        if (s[0] >= '0' and s[0] <= '9') {
            val = val * 16 + @as(i64, s[0] - '0');
        } else if (s[0] >= 'a' and s[0] <= 'f') {
            val = val * 16 + @as(i64, s[0] - 'a' + 10);
        } else {
            val = val * 16 + @as(i64, s[0] - 'A' + 10);
        }
        s += 1;
    }
    return if (flg != 0) -val else val;
}

export fn ztoo(s_in: [*c]const u8) i64 {
    var s = s_in;
    var val: i64 = 0;
    var flg: c_int = 0;
    if (s[0] == '-') {
        s += 1;
        flg = 1;
    } else if (s[0] == '+') {
        s += 1;
    }
    if (s[0] == '0' and (s[1] == 'x' or s[1] == 'X')) {
        s += 2;
        while ((s[0] >= '0' and s[0] <= '9') or (s[0] >= 'a' and s[0] <= 'f') or (s[0] >= 'A' and s[0] <= 'F')) {
            if (s[0] >= '0' and s[0] <= '9') {
                val = val * 16 + @as(i64, s[0] - '0');
            } else if (s[0] >= 'a' and s[0] <= 'f') {
                val = val * 16 + @as(i64, s[0] - 'a' + 10);
            } else {
                val = val * 16 + @as(i64, s[0] - 'A' + 10);
            }
            s += 1;
        }
    } else if (s[0] == '0') {
        while (s[0] >= '0' and s[0] <= '7') {
            val = val * 8 + @as(i64, s[0] - '0');
            s += 1;
        }
    } else {
        while (s[0] >= '0' and s[0] <= '9') {
            val = val * 10 + @as(i64, s[0] - '0');
            s += 1;
        }
    }
    return if (flg != 0) -val else val;
}

export fn ztol(s: [*c]const u8) c_long { return @intCast(ztoo(s)); }
export fn ztoi(s: [*c]const u8) c_int { return @intCast(ztoo(s)); }
export fn ztodiff(s: [*c]const u8) isize { return @intCast(ztoo(s)); }
export fn zhtol(s: [*c]const u8) c_long { return @intCast(zhtoo(s)); }
export fn zhtoi(s: [*c]const u8) c_int { return @intCast(zhtoo(s)); }
export fn zhtodiff(s: [*c]const u8) isize { return @intCast(zhtoo(s)); }

// ═══════════════════════════════════════════════════════════════════════
// Z-string (int) utilities
// ═══════════════════════════════════════════════════════════════════════

export fn Zcmp(a_in: [*c]const c_int, b_in: [*c]const c_int) c_int {
    var a = a_in;
    var b = b_in;
    while (a[0] != 0 and b[0] != 0 and a[0] == b[0]) {
        a += 1;
        b += 1;
    }
    if (a[0] > b[0]) return 1;
    if (a[0] < b[0]) return -1;
    return 0;
}

export fn Zlcpy(a_in: [*c]c_int, len_in: isize, b_in: [*c]const c_int) [*c]c_int {
    const org = a_in;
    var len = len_in;
    if (len == 0) exit(1);
    len -= 1;
    var a = a_in;
    var b = b_in;
    while (len != 0 and b[0] != 0) {
        a[0] = b[0];
        a += 1;
        b += 1;
        len -= 1;
    }
    a[0] = 0;
    return org;
}

export fn Ztoz(a_in: [*c]u8, len_in: isize, b_in: [*c]const c_int) [*c]u8 {
    const org = a_in;
    var len = len_in;
    if (len == 0) exit(1);
    len -= 1;
    var a = a_in;
    var b = b_in;
    while (len != 0 and b[0] != 0) {
        a[0] = @intCast(b[0] & 0xFF);
        a += 1;
        b += 1;
        len -= 1;
    }
    a[0] = 0;
    return org;
}

export fn Ztoutf8(a_in: [*c]u8, len_in: isize, b_in: [*c]const c_int) [*c]u8 {
    const org = a_in;
    var len = len_in;
    if (len == 0) exit(1);
    len -= 1;
    var a = a_in;
    var b = b_in;
    while (len != 0 and b[0] != 0) {
        var bf: [8]u8 = undefined;
        const enc = utf8_encode(&bf, b[0]);
        b += 1;
        if (enc < len) {
            var x: isize = 0;
            while (x != enc) : (x += 1) {
                a[0] = bf[@intCast(x)];
                a += 1;
                len -= 1;
            }
        }
    }
    a[0] = 0;
    return org;
}

export fn Zlen(s_in: [*c]const c_int) isize {
    var s = s_in;
    var len: isize = 0;
    while (true) {
        if (s[0] == 0) return 0 + len;
        if (s[1] == 0) return 1 + len;
        if (s[2] == 0) return 2 + len;
        if (s[3] == 0) return 3 + len;
        if (s[4] == 0) return 4 + len;
        if (s[5] == 0) return 5 + len;
        if (s[6] == 0) return 6 + len;
        if (s[7] == 0) return 7 + len;
        s += 8;
        len += 8;
    }
}

export fn Zdup(bf: [*c]const c_int) [*c]c_int {
    const size = (1 + Zlen(bf)) * @sizeOf(c_int);
    const p = joe_malloc(@intCast(size)) orelse return null;
    _ = memcpy(p, bf, @intCast(size));
    return @alignCast(@ptrCast(p));
}

// ═══════════════════════════════════════════════════════════════════════
// joe_set_signal — wrapper around sigaction
// ═══════════════════════════════════════════════════════════════════════

const Sigaction = extern struct {
    sa_handler: ?*const fn (c_int) callconv(.c) void,
    sa_mask: [128]u8 align(8),
    sa_flags: c_int,
    _pad: c_int = 0,
};

extern fn sigaction(signum: c_int, act: ?*const Sigaction, old: ?*Sigaction) c_int;

export fn joe_set_signal(signum: c_int, handler: ?*const fn (c_int) callconv(.c) void) c_int {
    var sact: Sigaction = undefined;
    @memset(@as([*]u8, @ptrCast(&sact))[0..@sizeOf(Sigaction)], 0);
    sact.sa_handler = handler;
    sact.sa_flags = 0;
    return sigaction(signum, &sact, null);
}

// ═══════════════════════════════════════════════════════════════════════
// Config-line parsers
// ═══════════════════════════════════════════════════════════════════════

export fn parse_ws(pp: [*c][*c]const u8, cmt: c_int) c_int {
    var p = pp.*;
    while (p[0] == ' ' or p[0] == '\t') p += 1;
    if (p[0] == cmt or p[0] == '\n' or p[0] == '\r') {
        while (p[0] != 0) p += 1;
    }
    pp.* = p;
    return p[0];
}

export fn parse_wsn(pp: [*c][*c]const u8, cmt: c_int) c_int {
    var p = pp.*;
    while (p[0] == ' ' or p[0] == '\t') p += 1;
    if (p[0] == cmt) {
        while (p[0] != 0 and p[0] != '\r' and p[0] != '\n') p += 1;
    }
    pp.* = p;
    return p[0];
}

export fn parse_wsl(pp: [*c][*c]const u8, cmt: c_int) c_int {
    var p = pp.*;
    while (true) {
        while (p[0] == ' ' or p[0] == '\t' or p[0] == '\r' or p[0] == '\n') p += 1;
        if (p[0] == cmt) {
            while (p[0] != 0 and p[0] != '\r' and p[0] != '\n') p += 1;
        } else break;
    }
    pp.* = p;
    return p[0];
}

export fn parse_ident(pp: [*c][*c]const u8, buf_in: [*c]u8, len_in: isize) c_int {
    var p = pp.*;
    var q = p;
    var buf = buf_in;
    var len = len_in;
    var c = utf8_decode_fwrd(&q, null);
    if (joe_isalpha_(utf8_map, c) != 0) {
        while (true) {
            var bf: [8]u8 = undefined;
            const enc = utf8_encode(&bf, c);
            if (enc + 1 <= len) {
                var x: isize = 0;
                while (x != enc) : (x += 1) {
                    buf[0] = bf[@intCast(x)];
                    buf += 1;
                    len -= 1;
                }
                buf[0] = 0;
            }
            p = q;
            c = utf8_decode_fwrd(&q, null);
            if (joe_isalnum_(utf8_map, c) == 0) break;
        }
        pp.* = p;
        return 0;
    }
    return -1;
}

export fn parse_tows(pp: [*c][*c]const u8, buf_in: [*c]u8) c_int {
    var p = pp.*;
    var buf = buf_in;
    while (p[0] != 0 and p[0] != ' ' and p[0] != '\t' and p[0] != '\n' and p[0] != '\r' and p[0] != '#') {
        buf[0] = p[0];
        buf += 1;
        p += 1;
    }
    pp.* = p;
    buf[0] = 0;
    return 0;
}

export fn parse_kw(pp: [*c][*c]const u8, kw_in: [*c]const u8) c_int {
    var p = pp.*;
    var kw = kw_in;
    while (kw[0] != 0 and kw[0] == p[0]) {
        kw += 1;
        p += 1;
    }
    if (kw[0] == 0 and joe_isalnum_(utf8_map, utf8_decode_string(p)) == 0) {
        pp.* = p;
        return 0;
    }
    return -1;
}

export fn parse_field(pp: [*c][*c]const u8, kw_in: [*c]const u8) c_int {
    var p = pp.*;
    var kw = kw_in;
    while (kw[0] != 0 and kw[0] == p[0]) {
        kw += 1;
        p += 1;
    }
    if (kw[0] == 0 and (p[0] == 0 or p[0] == ' ' or p[0] == '\t' or p[0] == '#' or p[0] == '\n' or p[0] == '\r')) {
        pp.* = p;
        return 0;
    }
    return -1;
}

export fn parse_char(pp: [*c][*c]const u8, c: u8) c_int {
    const p = pp.*;
    if (p[0] == c) {
        pp.* = p + 1;
        return 0;
    }
    return -1;
}

export fn skip_digits(p_in: [*c]const u8) [*c]const u8 {
    var p = p_in;
    if (p[0] == '-') p += 1 else if (p[0] == '+') p += 1;
    if (p[0] == '0' and (p[1] == 'x' or p[1] == 'X')) {
        p += 2;
        while ((p[0] >= '0' and p[0] <= '9') or ((p[0] & ~@as(u8, 32)) >= 'A' and (p[0] & ~@as(u8, 32)) <= 'F')) p += 1;
    } else if (p[0] == '0') {
        while (p[0] >= '0' and p[0] <= '7') p += 1;
    } else {
        while (p[0] >= '0' and p[0] <= '9') p += 1;
    }
    return p;
}

export fn parse_int(pp: [*c][*c]const u8, buf: [*c]c_int) c_int {
    const p = pp.*;
    if ((p[0] >= '0' and p[0] <= '9') or p[0] == '-') {
        buf.* = ztoi(p);
        pp.* = skip_digits(p);
        return 0;
    }
    return -1;
}

export fn parse_diff(pp: [*c][*c]const u8, buf: [*c]isize) c_int {
    const p = pp.*;
    if ((p[0] >= '0' and p[0] <= '9') or p[0] == '-') {
        buf.* = ztodiff(p);
        pp.* = skip_digits(p);
        return 0;
    }
    return -1;
}

export fn parse_off_t(pp: [*c][*c]const u8, buf: [*c]i64) c_int {
    var p = pp.*;
    var val: i64 = 0;
    var flg: c_int = 0;
    if ((p[0] >= '0' and p[0] <= '9') or p[0] == '-') {
        if (p[0] == '-') {
            p += 1;
            flg = 1;
        }
        while (p[0] >= '0' and p[0] <= '9') {
            val = val * 10 + @as(i64, p[0] - '0');
            p += 1;
        }
        if (flg != 0) val = -val;
        buf.* = val;
        pp.* = p;
        return 0;
    }
    return -1;
}

export fn parse_string(pp: [*c][*c]const u8, buf_in: [*c]u8, len_in: isize) isize {
    const start = buf_in;
    var p = pp.*;
    var buf = buf_in;
    var len = len_in;
    if (p[0] == '"') {
        p += 1;
        while (len > 1 and p[0] != 0 and p[0] != '"') {
            const c = escape(0, &p, null, null);
            buf[0] = @intCast(c & 0xFF);
            buf += 1;
            len -= 1;
        }
        buf[0] = 0;
        while (p[0] != 0 and p[0] != '"') {
            _ = escape(0, &p, null, null);
        }
        if (p[0] == '"') {
            pp.* = p + 1;
            return @intCast(@intFromPtr(buf) - @intFromPtr(start));
        }
    }
    return -1;
}

export fn parse_Zstring(pp: [*c][*c]const u8, buf_in: [*c]c_int, len_in: isize) isize {
    const start = buf_in;
    var p = pp.*;
    var buf = buf_in;
    var len = len_in;
    if (p[0] == '"') {
        p += 1;
        while (len > 1 and p[0] != 0 and p[0] != '"') {
            buf[0] = escape(1, &p, null, null);
            buf += 1;
            len -= 1;
        }
        buf[0] = 0;
        while (p[0] != 0 and p[0] != '"') {
            _ = escape(1, &p, null, null);
        }
        if (p[0] == '"') {
            pp.* = p + 1;
            return @as(isize, @intCast((@intFromPtr(buf) - @intFromPtr(start)) / @sizeOf(c_int)));
        }
    }
    return -1;
}

export fn emit_string(f: ?*anyopaque, s_in: [*c]const u8, len_in: isize) void {
    _ = fputc('"', f);
    var s = s_in;
    var len = len_in;
    while (len != 0) {
        if (s[0] == '"' or s[0] == '\\') {
            _ = fputc('\\', f);
            _ = fputc(s[0], f);
        } else if (s[0] == '\n') {
            _ = fputc('\\', f);
            _ = fputc('n', f);
        } else if (s[0] == '\r') {
            _ = fputc('\\', f);
            _ = fputc('r', f);
        } else if (s[0] == 0) {
            _ = fputc('\\', f);
            _ = fputc('0', f);
            _ = fputc('0', f);
            _ = fputc('0', f);
        } else {
            _ = fputc(s[0], f);
        }
        s += 1;
        len -= 1;
    }
    _ = fputc('"', f);
}

export fn parse_range(pp: [*c][*c]const u8, first: [*c]c_int, second: [*c]c_int) c_int {
    var p = pp.*;
    var a: c_int = 0;
    var b: c_int = 0;
    if (p[0] == 0) return -1;
    if (p[0] == '\\' and p[1] != 0) {
        p += 1;
        if (p[0] == 'n') a = '\n' else if (p[0] == 't') a = '\t' else a = p[0];
        p += 1;
    } else {
        a = p[0];
        p += 1;
    }
    if (p[0] == '-' and p[1] != 0) {
        p += 1;
        if (p[0] == '\\' and p[1] != 0) {
            p += 1;
            if (p[0] == 'n') b = '\n' else if (p[0] == 't') b = '\t' else b = p[0];
            p += 1;
        } else {
            b = p[0];
            p += 1;
        }
    } else b = a;
    first.* = a;
    second.* = b;
    pp.* = p;
    return 0;
}

var simple_interval: Interval = .{ .first = 0, .last = 0 };

export fn parse_class(pp: [*c][*c]const u8, array: [*c]?*Interval, size: [*c]isize) c_int {
    var p = pp.*;
    var cat: ?*anyopaque = null;
    if (p[0] == 0) return -1;
    const a = escape(1, &p, null, &cat);
    if (a == -256 and cat != null) {
        const c = @as(*Cclass, @alignCast(@ptrCast(cat.?)));
        array.* = c.intervals;
        size.* = c.len;
        pp.* = p;
        return 0;
    }
    var b: c_int = a;
    if (p[0] == '-' and p[1] != 0 and p[1] != '"') {
        p += 1;
        b = escape(1, &p, null, null);
    }
    if (b < a) b = a;
    simple_interval.first = a;
    simple_interval.last = b;
    array.* = &simple_interval;
    size.* = 1;
    pp.* = p;
    return 0;
}

// ═══════════════════════════════════════════════════════════════════════
// jsort / oabs
// ═══════════════════════════════════════════════════════════════════════

export fn jsort(base: ?*anyopaque, num: isize, size: isize, compar: ?*const anyopaque) void {
    qsort(base, @intCast(num), @intCast(size), compar);
}

export fn oabs(a: i64) i64 {
    return if (a < 0) -a else a;
}
