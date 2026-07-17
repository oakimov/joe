//! Boyer-Moore search — replaces `ffind`/`fifind`/`frfind`/`frifind`
//! and the public `pfind`/`pifind`/`prfind`/`prifind` wrappers in `b.c`.
//!
//! Faithful translation of the C; `TO_DIFF_OK(x)` is an identity cast
//! on platforms where `off_t` and `ptrdiff_t` are both 64-bit.

const types = @import("types.zig");
const intern = @import("intern.zig");
const pointer = @import("pointer.zig");

const P = types.P;

const ptrEq = intern.ptrEq;
const gsize_ = intern.gsize_;
const gchar = intern.gchar;

const pnext_ = pointer.pnext_;
const pprev_ = pointer.pprev_;
const pdup_ = pointer.pdup_;
const prm = pointer.prm;

// ═══════════════════════════════════════════════════════════════════════
// Raw byte stepping helpers (no column/line bookkeeping)
// ═══════════════════════════════════════════════════════════════════════

fn frgetc_(p: *P) c_int {
    if (p.ofst == 0) _ = pprev_(p);
    p.ofst -= 1;
    return gchar(p);
}

fn fpgetc_(p: *P) c_int {
    if (p.ofst == gsize_(p.hdr.?)) return types.NO_MORE_DATA;
    const c = gchar(p);
    p.ofst += 1;
    if (p.ofst == gsize_(p.hdr.?)) _ = pnext_(p);
    return c;
}

fn ffwrd_(p: *P, n: isize) void {
    var rem = n;
    while (rem > @as(isize, @intCast(gsize_(p.hdr.?) - p.ofst))) {
        rem -= @as(isize, @intCast(gsize_(p.hdr.?) - p.ofst));
        if (pnext_(p) == 0) return;
    }
    p.ofst += @as(i16, @intCast(rem));
    if (p.ofst == gsize_(p.hdr.?)) _ = pnext_(p);
}

fn fbkwd_(p: *P, n: isize) void {
    var rem = n;
    while (rem > @as(isize, @intCast(p.ofst))) {
        rem -= @as(isize, @intCast(p.ofst));
        if (pprev_(p) == 0) return;
    }
    if (p.ofst >= @as(i16, @intCast(rem))) {
        p.ofst -= @as(i16, @intCast(rem));
    } else {
        p.ofst = 0;
    }
}

// ═══════════════════════════════════════════════════════════════════════
// Forward Boyer-Moore
// ═══════════════════════════════════════════════════════════════════════

fn ffind_(p: *P, s: [*c]const u8, len: isize) ?*P {
    var amnt = p.b.?.eof.?.byte - p.byte;
    if (len > amnt) return null;
    if (len == 0) return p;
    p.valcol = 0;
    p.valattr = 0;
    var table: [256]isize = @splat(-1);
    var x: isize = 0;
    while (x < len - 1) : (x += 1) {
        table[@as(usize, @intCast(s[@as(usize, @intCast(x))]))] = x;
    }
    ffwrd_(p, len);
    amnt -= len;
    x = len;
    while (x != 0) {
        x -= 1;
        const c = @as(u8, @intCast(frgetc_(p)));
        if (c != s[@as(usize, @intCast(x))]) {
            if (table[c] == -1) {
                ffwrd_(p, len + 1);
                amnt -= x + 1;
            } else if (x <= table[c]) {
                ffwrd_(p, len - x + 1);
                amnt -= 1;
            } else {
                ffwrd_(p, len - table[c]);
                amnt -= x - table[c];
            }
            if (amnt < 0) return null;
            x = len;
        }
    }
    return p;
}

fn fifind_(p: *P, s: [*c]const u8, len: isize) ?*P {
    var amnt = p.b.?.eof.?.byte - p.byte;
    if (len > amnt) return null;
    if (len == 0) return p;
    p.valcol = 0;
    p.valattr = 0;
    const map = p.b.?.o.charmap;
    var table: [256]isize = @splat(-1);
    var x: isize = 0;
    while (x < len - 1) : (x += 1) {
        table[@as(usize, @intCast(s[@as(usize, @intCast(x))]))] = x;
    }
    ffwrd_(p, len);
    amnt -= len;
    x = len;
    while (x != 0) {
        x -= 1;
        const c = @as(u8, @intCast(intern.joe_tolower_v(map, frgetc_(p))));
        if (c != s[@as(usize, @intCast(x))]) {
            if (table[c] == -1) {
                ffwrd_(p, len + 1);
                amnt -= x + 1;
            } else if (x <= table[c]) {
                ffwrd_(p, len - x + 1);
                amnt -= 1;
            } else {
                ffwrd_(p, len - table[c]);
                amnt -= x - table[c];
            }
            if (amnt < 0) return null;
            x = len;
        }
    }
    return p;
}

// ═══════════════════════════════════════════════════════════════════════
// Backward Boyer-Moore
// ═══════════════════════════════════════════════════════════════════════

fn frfind_(p: *P, s: [*c]const u8, len: isize) ?*P {
    var amnt = p.byte;
    if (len > p.b.?.eof.?.byte - p.byte) {
        const diff = len - (p.b.?.eof.?.byte - p.byte);
        if (amnt < diff) return null;
        amnt -= diff;
        fbkwd_(p, diff);
    }
    if (len == 0) return p;
    p.valcol = 0;
    p.valattr = 0;
    var table: [256]isize = @splat(-1);
    {
        var xi = len;
        while (xi > 0) {
            xi -= 1;
            table[@as(usize, @intCast(s[@as(usize, @intCast(xi))]))] = len - xi - 1;
        }
    }
    var x: isize = 0;
    while (x != len) {
        const c = @as(u8, @intCast(fpgetc_(p)));
        if (c != s[@as(usize, @intCast(x))]) {
            x += 1;
            if (table[c] == -1) {
                fbkwd_(p, len + 1);
                amnt -= len - x + 1;
            } else if (len - table[c] <= x) {
                fbkwd_(p, x + 1);
                amnt -= 1;
            } else {
                fbkwd_(p, len - table[c]);
                amnt -= len - table[c] - x;
            }
            if (amnt < 0) return null;
            x = 0;
        } else {
            x += 1;
        }
    }
    fbkwd_(p, len);
    return p;
}

fn frifind_(p: *P, s: [*c]const u8, len: isize) ?*P {
    var amnt = p.byte;
    if (len > p.b.?.eof.?.byte - p.byte) {
        const diff = len - (p.b.?.eof.?.byte - p.byte);
        if (amnt < diff) return null;
        amnt -= diff;
        fbkwd_(p, diff);
    }
    if (len == 0) return p;
    p.valcol = 0;
    p.valattr = 0;
    const map = p.b.?.o.charmap;
    var table: [256]isize = @splat(-1);
    {
        var xi = len;
        while (xi > 0) {
            xi -= 1;
            table[@as(usize, @intCast(s[@as(usize, @intCast(xi))]))] = len - xi - 1;
        }
    }
    var x: isize = 0;
    while (x != len) {
        const c = @as(u8, @intCast(intern.joe_tolower_v(map, fpgetc_(p))));
        if (c != s[@as(usize, @intCast(x))]) {
            x += 1;
            if (table[c] == -1) {
                fbkwd_(p, len + 1);
                amnt -= len - x + 1;
            } else if (len - table[c] <= x) {
                fbkwd_(p, x + 1);
                amnt -= 1;
            } else {
                fbkwd_(p, len - table[c]);
                amnt -= len - table[c] - x;
            }
            if (amnt < 0) return null;
            x = 0;
        } else {
            x += 1;
        }
    }
    fbkwd_(p, len);
    return p;
}

// ═══════════════════════════════════════════════════════════════════════
// getto / rgetto — walk p to q's position, updating line counters
// ═══════════════════════════════════════════════════════════════════════

fn getto_(p: *P, q: *P) void {
    while (!ptrEq(p.hdr, q.hdr) or p.ofst != q.ofst) {
        if (gchar(p) == '\n') p.line += 1;
        p.byte += 1;
        p.ofst += 1;
        if (p.ofst == gsize_(p.hdr.?)) _ = pnext_(p);
        while (p.ofst == 0 and !ptrEq(p.hdr, q.hdr)) {
            p.byte += @as(i64, @intCast(gsize_(p.hdr.?)));
            p.line += @as(i64, @intCast(p.hdr.?.nlines));
            _ = pnext_(p);
        }
    }
}

fn rgetto_(p: *P, q: *P) void {
    while (!ptrEq(p.hdr, q.hdr) or p.ofst != q.ofst) {
        if (p.ofst == 0) {
            while (!ptrEq(p.hdr, q.hdr)) {
                if (p.ofst != 0) {
                    p.byte -= @as(i64, @intCast(p.ofst));
                    p.line -= @as(i64, @intCast(p.hdr.?.nlines));
                }
                _ = pprev_(p);
            }
        }
        p.ofst -= 1;
        p.byte -= 1;
        if (gchar(p) == '\n') p.line -= 1;
    }
}

// ═══════════════════════════════════════════════════════════════════════
// Public search API
// ═══════════════════════════════════════════════════════════════════════

pub export fn pfind(p: ?*P, s: [*c]const u8, len: isize) ?*P {
    const pp = p.?;
    const q = pdup_(pp, "pfind");
    if (ffind_(q, s, len)) |_| {
        getto_(pp, q);
        prm(q);
        return pp;
    }
    prm(q);
    return null;
}

pub export fn pifind(p: ?*P, s: [*c]const u8, len: isize) ?*P {
    const pp = p.?;
    const q = pdup_(pp, "pifind");
    if (fifind_(q, s, len)) |_| {
        getto_(pp, q);
        prm(q);
        return pp;
    }
    prm(q);
    return null;
}

pub export fn prfind(p: ?*P, s: [*c]const u8, len: isize) ?*P {
    const pp = p.?;
    const q = pdup_(pp, "prfind");
    if (frfind_(q, s, len)) |_| {
        rgetto_(pp, q);
        prm(q);
        return pp;
    }
    prm(q);
    return null;
}

pub export fn prifind(p: ?*P, s: [*c]const u8, len: isize) ?*P {
    const pp = p.?;
    const q = pdup_(pp, "prifind");
    if (frifind_(q, s, len)) |_| {
        rgetto_(pp, q);
        prm(q);
        return pp;
    }
    prm(q);
    return null;
}
