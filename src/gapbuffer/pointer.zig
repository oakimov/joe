//! Pointer (P) operations — creation, destruction, movement, predicates,
//! and read-only access.  Replaces the corresponding functions in `b.c`.

const types = @import("types.zig");
const intern = @import("intern.zig");

const P = types.P;
const H = types.H;
const B = types.B;
const NO_MORE_DATA = types.NO_MORE_DATA;
const ANSIMAX = types.ANSIMAX;

const ptrEq = intern.ptrEq;
const charmapIsUtf8 = intern.charmapIsUtf8;
const Plink = intern.Plink;
const Hlink = intern.Hlink;
const link2P = intern.link2P;
const izque = intern.izque;
const deque_ = intern.deque_;
const enquef_ = intern.enquef_;
const palloc = intern.palloc;
const pfree = intern.pfree;
const gsize_ = intern.gsize_;
const gchar = intern.gchar;
const vlock = intern.vlock;
const vunlock_page = intern.vunlock_page;
const vupcount_page = intern.vupcount_page;
const joe_isblank = intern.joe_isblank;

// ═══════════════════════════════════════════════════════════════════════
// Internal byte-level movement (used by pgetc / prgetc / search)
// ═══════════════════════════════════════════════════════════════════════

pub fn pnext_(p: *P) c_int {
    if (ptrEq(p.hdr, p.b.?.eof.?.hdr)) {
        p.ofst = gsize_(p.hdr.?);
        return 0;
    }
    p.hdr = @as(*H, @ptrCast(@alignCast(p.hdr.?.link.next)));
    p.ofst = 0;
    vunlock_page(p.ptr);
    p.ptr = vlock(intern.vmem, p.hdr.?.seg);
    return 1;
}

pub fn pprev_(p: *P) c_int {
    if (ptrEq(p.hdr, p.b.?.bof.?.hdr)) {
        p.ofst = 0;
        return 0;
    }
    p.hdr = @as(*H, @ptrCast(@alignCast(p.hdr.?.link.prev)));
    p.ofst = gsize_(p.hdr.?);
    vunlock_page(p.ptr);
    p.ptr = vlock(intern.vmem, p.hdr.?.seg);
    return 1;
}

pub fn pgetb_(p: *P) c_int {
    if (p.ofst == gsize_(p.hdr.?)) return NO_MORE_DATA;
    const c = gchar(p);
    p.ofst += 1;
    p.byte += 1;
    if (p.ofst == gsize_(p.hdr.?)) _ = pnext_(p);
    if (c == '\n') {
        p.line += 1;
        p.col = 0;
        p.valcol = 1;
        p.attr = 0;
        p.valattr = 1;
    } else if (p.b.?.o.crlf != 0 and c == '\r') {
        if (brc_(p) == '\n') return pgetb_(p);
    } else {
        p.valcol = 0;
        p.valattr = 0;
    }
    return c;
}

pub fn prgetb1_(p: *P) c_int {
    if (p.ofst == 0 and pprev_(p) == 0) return NO_MORE_DATA;
    p.ofst -= 1;
    const c = gchar(p);
    p.byte -= 1;
    p.valcol = 0;
    p.valattr = 0;
    if (c == '\n') p.line -= 1;
    return c;
}

pub fn prgetb_(p: *P) c_int {
    var c = prgetb1_(p);
    if (p.b.?.o.crlf != 0 and c == '\n') {
        c = prgetb1_(p);
        if (c == '\r') return '\n';
        if (c != NO_MORE_DATA) _ = pgetb_(p);
        c = '\n';
    }
    return c;
}

pub fn brc_(p: *P) c_int {
    if (p.ofst == gsize_(p.hdr.?)) return NO_MORE_DATA;
    return gchar(p);
}

pub fn brch_(p: *P) c_int {
    // Match C: UTF-8 path peeks via pgetc on a duplicate pointer.
    if (charmapIsUtf8(p.b.?.o.charmap)) {
        const q = pdup_(p, "brch");
        const c = pgetc_(q);
        prm(q);
        return c;
    }
    return brc_(p);
}

// ═══════════════════════════════════════════════════════════════════════
// pset / pdup / prm / poffline / ponline
// ═══════════════════════════════════════════════════════════════════════

pub fn pset_(n: *P, p: *P) *P {
    if (n != p) {
        n.b = p.b;
        n.ofst = p.ofst;
        n.hdr = p.hdr;
        if (n.ptr) |np| vunlock_page(np);
        n.ptr = if (p.ptr) |pp| blk: {
            vupcount_page(pp);
            break :blk pp;
        } else vlock(intern.vmem, n.hdr.?.seg);
        n.byte = p.byte;
        n.line = p.line;
        n.col = p.col;
        n.valcol = p.valcol;
        n.attr = p.attr;
        n.valattr = p.valattr;
    }
    return n;
}

pub fn pdup_(p: *P, tr: [*c]const u8) *P {
    const n = palloc();
    n.end = 0;
    n.ptr = null;
    n.owner = null;
    n.tracker = @ptrCast(tr);
    enquef_(Plink(p), Plink(n));
    return pset_(n, p);
}

// ═══════════════════════════════════════════════════════════════════════
// Exported pointer API
// ═══════════════════════════════════════════════════════════════════════

pub export fn pset(n: ?*P, p: ?*P) ?*P {
    return @ptrCast(pset_(n.?, p.?));
}

pub export fn pdup(p: ?*P, tr: [*c]const u8) ?*P {
    return @ptrCast(pdup_(p.?, tr));
}

pub export fn pdupown(p: ?*P, owner: ?*?*P, tr: [*c]const u8) ?*P {
    const pp = p.?;
    const n = palloc();
    n.end = 0;
    n.ptr = null;
    n.owner = @ptrCast(owner);
    n.tracker = @ptrCast(tr);
    enquef_(Plink(pp), Plink(n));
    _ = pset_(n, pp);
    if (owner.?.*) |old| prm(old);
    owner.?.* = n;
    return @ptrCast(n);
}

pub export fn prm(p: ?*P) void {
    const pp = p orelse return;
    if (pp.owner) |o| o.* = null;
    if (pp.ptr) |pt| vunlock_page(pt);
    // Match C: pfree(deque_f(P, link, p)) — remove from buffer's pointer ring
    // before placing on the freelist, otherwise fixupins walks forever.
    deque_(Plink(pp));
    pfree(pp);
}

pub export fn pnext(p: ?*P) c_int {
    return pnext_(p.?);
}
pub export fn pprev(p: ?*P) c_int {
    return pprev_(p.?);
}
pub export fn pgetb(p: ?*P) c_int {
    return pgetb_(p.?);
}
pub export fn prgetb(p: ?*P) c_int {
    return prgetb_(p.?);
}
pub export fn brc(p: ?*P) c_int {
    return brc_(p.?);
}
pub export fn brch(p: ?*P) c_int {
    return brch_(p.?);
}

// ═══════════════════════════════════════════════════════════════════════
// pgetc — return current char and advance (UTF-8 / ANSI / CRLF aware)
// ═══════════════════════════════════════════════════════════════════════

const ansi_mod = @import("ansi.zig");

pub fn pgetc_(p: *P) c_int {
    const o = p.b.?.o;
    if (charmapIsUtf8(o.charmap)) {
        const val = p.valcol;
        const valattr = p.valattr;
        var c = pgetb_(p);
        if (c == NO_MORE_DATA) return c;

        // ANSI escape sequence hiding
        if (o.ansi != 0 and c == 0x1b) {
            var buf: [ANSIMAX]u8 = undefined;
            var bx: usize = 0;
            buf[bx] = @as(u8, @intCast(c));
            bx += 1;
            while (true) {
                const d = pgetb_(p);
                if (d == NO_MORE_DATA) break;
                if (bx < ANSIMAX - 1) {
                    buf[bx] = @as(u8, @intCast(d));
                    bx += 1;
                }
                if ((d >= 'A' and d <= 'Z') or (d >= 'a' and d <= 'z') or d == '\n') break;
            }
            p.valcol |= val;
            p.valattr = 0;
            buf[bx] = 0;
            return ansi_mod.ansi_code_(&buf);
        }

        // UTF-8 decode
        if ((c & 0x80) == 0) {
            // one byte
        } else if ((c & 0xE0) == 0xC0) {
            var n: usize = 1;
            c &= 0x1F;
            while (n > 0) {
                const d = brc_(p);
                if ((d & 0xC0) != 0x80) break;
                _ = pgetb_(p);
                c = (c << 6) | (d & 0x3F);
                n -= 1;
            }
        } else if ((c & 0xF0) == 0xE0) {
            var n: usize = 2;
            c &= 0x0F;
            while (n > 0) {
                const d = brc_(p);
                if ((d & 0xC0) != 0x80) break;
                _ = pgetb_(p);
                c = (c << 6) | (d & 0x3F);
                n -= 1;
            }
        } else if ((c & 0xF8) == 0xF0) {
            var n: usize = 3;
            c &= 0x07;
            while (n > 0) {
                const d = brc_(p);
                if ((d & 0xC0) != 0x80) break;
                _ = pgetb_(p);
                c = (c << 6) | (d & 0x3F);
                n -= 1;
            }
        } else {
            c = 'X';
        }

        if (val != 0) {
            p.valcol = 1;
            if (c == '\t') {
                p.col += o.tab - @rem(p.col, o.tab);
            } else if (c == '\n') {
                p.col = 0;
            } else {
                p.col += intern.wcw(c);
            }
        }
        p.valattr |= valattr;
        return c;
    } else {
        // single-byte charmap
        if (p.ofst == gsize_(p.hdr.?)) return NO_MORE_DATA;
        const c = gchar(p);
        p.ofst += 1;
        p.byte += 1;
        if (p.ofst == gsize_(p.hdr.?)) _ = pnext_(p);
        if (c == '\n') {
            p.line += 1;
            p.col = 0;
            p.valcol = 1;
            p.attr = 0;
            p.valattr = 1;
        } else if (o.ansi != 0 and c == 0x1b) {
            var buf: [ANSIMAX]u8 = undefined;
            const v = p.valcol;
            var bx: usize = 0;
            buf[bx] = c;
            bx += 1;
            while (true) {
                const d = pgetb_(p);
                if (d == NO_MORE_DATA) break;
                if (bx < ANSIMAX - 1) {
                    buf[bx] = @as(u8, @intCast(d));
                    bx += 1;
                }
                if ((d >= 'A' and d <= 'Z') or (d >= 'a' and d <= 'z') or d == '\n') break;
            }
            buf[bx] = 0;
            p.valcol |= v;
            p.valattr = 0;
            return ansi_mod.ansi_code_(&buf);
        } else if (o.crlf != 0 and c == '\r') {
            if (brc_(p) == '\n') return pgetc_(p);
            p.col += 1;
        } else {
            if (c == '\t') {
                p.col += o.tab - @rem(p.col, o.tab);
            } else {
                p.col += 1;
            }
        }
        return c;
    }
}

pub export fn pgetc(p: ?*P) c_int {
    return pgetc_(p.?);
}

pub fn prgetc_(p: *P) c_int {
    const o = p.b.?.o;
    if (!charmapIsUtf8(o.charmap) or pisbol(p) != 0) return prgetb_(p);

    const val = p.valcol;
    const startbyte = p.byte;
    var left: usize = 6;
    var c: c_int = 0;
    while (left > 0) {
        c = prgetb_(p);
        if (c == NO_MORE_DATA) return c;
        if ((c & 0xC0) != 0x80) break;
        left -= 1;
    }
    if (c == NO_MORE_DATA) return c;
    const q = pdup_(p, "prgetc");
    const cc = pgetc_(q);
    if (val != 0 and cc != '\n' and cc != '\t' and q.byte == startbyte) {
        p.valcol = 1;
        p.col -= intern.wcw(cc);
    }
    prm(q);
    return cc;
}

pub export fn prgetc(p: ?*P) c_int {
    return prgetc_(p.?);
}

// ═══════════════════════════════════════════════════════════════════════
// poffline / ponline / boffline / bonline
// ═══════════════════════════════════════════════════════════════════════

pub fn poffline_(p: *P) *P {
    if (p.ptr) |pt| {
        vunlock_page(pt);
        p.ptr = null;
    }
    return p;
}

pub fn ponline_(p: *P) *P {
    if (p.ptr == null) p.ptr = vlock(intern.vmem, p.hdr.?.seg);
    return p;
}

pub export fn poffline(p: ?*P) ?*P {
    return @ptrCast(poffline_(p.?));
}
pub export fn ponline(p: ?*P) ?*P {
    return @ptrCast(ponline_(p.?));
}

// ═══════════════════════════════════════════════════════════════════════
// Position predicates
// ═══════════════════════════════════════════════════════════════════════

pub export fn pisbof(p: ?*P) c_int {
    const pp = p.?;
    return @intFromBool(ptrEq(pp.hdr, pp.b.?.bof.?.hdr) and pp.ofst == 0);
}

pub export fn piseof(p: ?*P) c_int {
    const pp = p.?;
    return @intFromBool(pp.ofst == gsize_(pp.hdr.?));
}

pub fn piseol_(p: *P) c_int {
    if (piseof(@ptrCast(p)) != 0) return 1;
    const c = brc_(p);
    if (c == '\n') return 1;
    if (p.b.?.o.crlf != 0 and c == '\r') {
        const q = pdup_(p, "piseol");
        _ = pfwrd_(q, 1);
        const r = pgetb_(q);
        prm(q);
        return @intFromBool(r == '\n');
    }
    return 0;
}

pub export fn piseol(p: ?*P) c_int {
    return piseol_(p.?);
}

pub export fn pisbol(p: ?*P) c_int {
    const pp = p.?;
    if (pisbof(pp) != 0) return 1;
    if (pp.ofst == 0) _ = pprev_(pp);
    pp.ofst -= 1;
    const c = gchar(pp);
    pp.ofst += 1;
    if (pp.ofst == gsize_(pp.hdr.?)) _ = pnext_(pp);
    return @intFromBool(c == '\n');
}

pub export fn pisbow(p: ?*P) c_int {
    const pp = p.?;
    const q = pdup_(pp, "pisbow");
    const c = brch_(pp);
    const d = prgetc_(q);
    prm(q);
    return @intFromBool(intern.joe_isalnum_v(pp.b.?.o.charmap, c) != 0 and
        (intern.joe_isalnum_v(pp.b.?.o.charmap, d) == 0 or pisbof(pp) != 0));
}

pub export fn piseow(p: ?*P) c_int {
    const pp = p.?;
    const q = pdup_(pp, "piseow");
    const d = brch_(q);
    const c = prgetc_(q);
    prm(q);
    return @intFromBool(intern.joe_isalnum_v(pp.b.?.o.charmap, c) != 0 and
        (intern.joe_isalnum_v(pp.b.?.o.charmap, d) == 0 or piseof(pp) != 0));
}

pub export fn pisblank(p: ?*P) c_int {
    const pp = p.?;
    const q = pdup_(pp, "pisblank");
    _ = p_goto_bol(q);
    while (joe_isblank(pp.b.?.o.charmap, brc_(q)) != 0) _ = pgetb_(q);
    const r = if (piseol_(q) != 0) @as(c_int, 1) else 0;
    prm(q);
    return r;
}

pub export fn piseolblank(p: ?*P) c_int {
    const pp = p.?;
    const q = pdup_(pp, "piseolblank");
    while (joe_isblank(pp.b.?.o.charmap, brc_(q)) != 0) _ = pgetb_(q);
    const r = if (piseol_(q) != 0) @as(c_int, 1) else 0;
    prm(q);
    return r;
}

pub export fn pisindent(p: ?*P) i64 {
    const pp = p.?;
    const q = pdup_(pp, "pisindent");
    _ = p_goto_bol(q);
    while (joe_isblank(pp.b.?.o.charmap, brc_(q)) != 0) _ = pgetc_(q);
    const col = q.col;
    prm(q);
    return col;
}

pub export fn pispure(p: ?*P, c: c_int) c_int {
    var cc = c;
    const pp = p.?;
    if (cc < 0) cc += 256;
    const q = pdup_(pp, "pispure");
    _ = p_goto_bol(q);
    while (q.byte != pp.byte) {
        if (pgetc_(q) != cc) {
            prm(q);
            return 0;
        }
    }
    prm(q);
    return 1;
}

// ═══════════════════════════════════════════════════════════════════════
// Forward / backward byte/char movement
// ═══════════════════════════════════════════════════════════════════════

pub fn pfwrd_(p: *P, n: i64) ?*P {
    if (n == 0) return p;
    p.valcol = 0;
    p.valattr = 0;
    var r = n;
    while (r > 0) {
        if (p.ofst == gsize_(p.hdr.?)) {
            while (r > 0) {
                if (p.ofst == 0) {
                    p.byte += @as(i64, @intCast(gsize_(p.hdr.?)));
                    r -= @as(i64, @intCast(gsize_(p.hdr.?)));
                    p.line += @as(i64, @intCast(p.hdr.?.nlines));
                }
                if (pnext_(p) == 0) return null;
                if (r <= gsize_(p.hdr.?)) break;
            }
        }
        if (gchar(p) == '\n') p.line += 1;
        p.byte += 1;
        p.ofst += 1;
        r -= 1;
    }
    if (p.ofst == gsize_(p.hdr.?)) _ = pnext_(p);
    return p;
}

pub fn pbkwd_(p: *P, n: i64) ?*P {
    if (n == 0) return p;
    p.valcol = 0;
    p.valattr = 0;
    var r = n;
    while (r > 0) {
        if (p.ofst == 0) {
            while (r > 0) {
                if (p.ofst != 0) {
                    p.byte -= @as(i64, @intCast(p.ofst));
                    r -= @as(i64, @intCast(p.ofst));
                    p.line -= @as(i64, @intCast(p.hdr.?.nlines));
                }
                if (pprev_(p) == 0) return null;
                if (r <= gsize_(p.hdr.?)) break;
            }
        }
        p.ofst -= 1;
        p.byte -= 1;
        if (gchar(p) == '\n') p.line -= 1;
        r -= 1;
    }
    return p;
}

pub export fn pfwrd(p: ?*P, n: i64) ?*P {
    return @ptrCast(pfwrd_(p.?, n));
}
pub export fn pbkwd(p: ?*P, n: i64) ?*P {
    return @ptrCast(pbkwd_(p.?, n));
}

pub export fn pgoto(p: ?*P, loc: i64) ?*P {
    const pp = p.?;
    if (loc > pp.byte) return pfwrd_(pp, loc - pp.byte);
    if (loc < pp.byte) return pbkwd_(pp, pp.byte - loc);
    return pp;
}

pub export fn pfcol(p: ?*P) ?*P {
    const pp = p.?;
    const pos = pp.byte;
    _ = p_goto_bol(pp);
    while (pp.byte < pos) _ = pgetc_(pp);
    return pp;
}

// ═══════════════════════════════════════════════════════════════════════
// p_goto_* / pnextl / pprevl / pline
// ═══════════════════════════════════════════════════════════════════════

pub export fn p_goto_bof(p: ?*P) ?*P {
    return pset_(p.?, p.?.b.?.bof.?);
}
pub export fn p_goto_eof(p: ?*P) ?*P {
    return pset_(p.?, p.?.b.?.eof.?);
}

pub export fn p_goto_bol(p: ?*P) ?*P {
    const pp = p.?;
    // Match C: only consume the preceding newline when pprevl succeeds.
    // At bof, pprevl fails — calling pgetb anyway would eat the first character.
    if (pprevl_(pp) != null) {
        _ = pgetb_(pp);
    }
    pp.col = 0;
    pp.valcol = 1;
    pp.attr = 0;
    pp.valattr = 1;
    return pp;
}

pub export fn p_goto_eol(p: ?*P) ?*P {
    const pp = p.?;
    const o = pp.b.?.o;
    if (o.crlf != 0 or charmapIsUtf8(o.charmap) or o.ansi != 0) {
        while (piseol_(pp) == 0) _ = pgetc_(pp);
    } else {
        while (pp.ofst != gsize_(pp.hdr.?)) {
            const c = gchar(pp);
            if (c == '\n') break;
            pp.byte += 1;
            pp.ofst += 1;
            if (c == '\t') {
                pp.col += o.tab - @rem(pp.col, o.tab);
            } else {
                pp.col += 1;
            }
            if (pp.ofst == gsize_(pp.hdr.?)) _ = pnext_(pp);
        }
    }
    return pp;
}

pub export fn p_goto_indent(p: ?*P, c: c_int) ?*P {
    const pp = p.?;
    _ = p_goto_bol(pp);
    while (true) {
        const d = brc_(pp);
        if (d == c or ((c == ' ' or c == '\t') and (d == ' ' or d == '\t'))) {
            _ = pgetc_(pp);
        } else {
            break;
        }
    }
    return pp;
}

pub fn pnextl_(p: *P) ?*P {
    while (true) {
        if (p.ofst == gsize_(p.hdr.?)) {
            while (true) {
                p.byte += @as(i64, @intCast(gsize_(p.hdr.?) - p.ofst));
                if (pnext_(p) == 0) return null;
                if (p.hdr.?.nlines != 0) break;
            }
        }
        const c = gchar(p);
        p.byte += 1;
        p.ofst += 1;
        if (c == '\n') break;
    }
    p.line += 1;
    p.col = 0;
    p.valcol = 1;
    p.attr = 0;
    p.valattr = 1;
    if (p.ofst == gsize_(p.hdr.?)) _ = pnext_(p);
    return p;
}

pub fn pprevl_(p: *P) ?*P {
    p.valcol = 0;
    p.valattr = 0;
    while (true) {
        if (p.ofst == 0) {
            while (true) {
                p.byte -= @as(i64, @intCast(p.ofst));
                if (pprev_(p) == 0) return null;
                if (p.hdr.?.nlines != 0) break;
            }
        }
        p.ofst -= 1;
        p.byte -= 1;
        if (gchar(p) == '\n') break;
    }
    p.line -= 1;
    if (p.b.?.o.crlf != 0) {
        const k = prgetb1_(p);
        if (k != '\r' and k != NO_MORE_DATA) _ = pgetb_(p);
    }
    return p;
}

pub export fn pnextl(p: ?*P) ?*P {
    return @ptrCast(pnextl_(p.?));
}
pub export fn pprevl(p: ?*P) ?*P {
    return @ptrCast(pprevl_(p.?));
}

pub export fn pline(p: ?*P, line: i64) ?*P {
    const pp = p.?;
    if (line > pp.b.?.eof.?.line) {
        _ = pset_(pp, pp.b.?.eof.?);
        return pp;
    }
    if (line < @abs(pp.line - line)) _ = pset_(pp, pp.b.?.bof.?);
    if (@abs(pp.b.?.eof.?.line - line) < @abs(pp.line - line)) _ = pset_(pp, pp.b.?.eof.?);
    if (pp.line == line) return p_goto_bol(pp);
    while (line > pp.line) _ = pnextl_(pp);
    while (line < pp.line) _ = pprevl_(pp);
    return p_goto_bol(pp);
}

// ═══════════════════════════════════════════════════════════════════════
// Column movement
// ═══════════════════════════════════════════════════════════════════════

pub fn pcol_(p: *P, goalcol: i64) ?*P {
    _ = p_goto_bol(p);
    const o = p.b.?.o;
    if (charmapIsUtf8(o.charmap) or o.ansi != 0) {
        while (true) {
            const c = brch_(p);
            if (c == NO_MORE_DATA or c == '\n') break;
            if (o.crlf != 0 and c == '\r' and piseol_(p) != 0) break;
            const wid = if (c == '\t') o.tab - @rem(p.col, o.tab) else intern.wcw(c);
            if (p.col + wid > goalcol) break;
            _ = pgetc_(p);
        }
    } else {
        while (true) {
            if (p.ofst == gsize_(p.hdr.?)) break;
            const c = gchar(p);
            if (c == '\n') break;
            if (o.crlf != 0 and c == '\r' and piseol_(p) != 0) break;
            const wid = if (c == '\t') o.tab - @rem(p.col, o.tab) else @as(i64, 1);
            if (p.col + wid > goalcol) break;
            p.ofst += 1;
            p.byte += 1;
            p.col += wid;
            if (p.ofst == gsize_(p.hdr.?)) _ = pnext_(p);
        }
    }
    return p;
}

pub export fn pcol(p: ?*P, goalcol: i64) ?*P {
    return pcol_(p.?, goalcol);
}

pub export fn pcolwse(p: ?*P, goalcol: i64) ?*P {
    const pp = p.?;
    _ = pcol_(pp, goalcol);
    while (true) {
        const c = prgetc_(pp);
        if (c != ' ' and c != '\t') break;
    }
    if (prgetc_(pp) != NO_MORE_DATA) _ = pgetc_(pp);
    return pp;
}

pub export fn pcoli(p: ?*P, goalcol: i64) ?*P {
    const pp = p.?;
    _ = p_goto_bol(pp);
    const o = pp.b.?.o;
    if (charmapIsUtf8(o.charmap) or o.ansi != 0) {
        while (pp.col < goalcol) {
            const c = brc_(pp);
            if (c == NO_MORE_DATA or c == '\n') break;
            if (o.crlf != 0 and c == '\r' and piseol_(pp) != 0) break;
            _ = pgetc_(pp);
        }
    } else {
        while (pp.col < goalcol) {
            if (pp.ofst == gsize_(pp.hdr.?)) break;
            const c = gchar(pp);
            if (c == '\n') break;
            if (o.crlf != 0 and c == '\r' and piseol_(pp) != 0) break;
            if (c == '\t') {
                pp.col += o.tab - @rem(pp.col, o.tab);
            } else {
                pp.col += 1;
            }
            pp.ofst += 1;
            pp.byte += 1;
            if (pp.ofst == gsize_(pp.hdr.?)) _ = pnext_(pp);
        }
    }
    return pp;
}

pub fn piscol_(p: *P) i64 {
    if (p.valcol != 0) return p.col;
    _ = pfcol(p);
    return p.col;
}

pub export fn piscol(p: ?*P) i64 {
    return piscol_(p.?);
}

// ═══════════════════════════════════════════════════════════════════════
// pfill / pbackws
// ═══════════════════════════════════════════════════════════════════════

const buffer_mod = @import("buffer.zig");

pub export fn pfill(p: ?*P, to: i64, usetabs: c_int) void {
    const pp = p.?;
    const o = pp.b.?.o;
    if (usetabs == '\t') {
        while (piscol_(pp) < to) {
            if (pp.col + o.tab - @rem(pp.col, o.tab) <= to) {
                _ = buffer_mod.binsc_(pp, '\t');
                _ = pgetc_(pp);
            } else {
                _ = buffer_mod.binsc_(pp, ' ');
                _ = pgetc_(pp);
            }
        }
    } else {
        while (piscol_(pp) < to) {
            _ = buffer_mod.binsc_(pp, @as(c_int, usetabs));
            _ = pgetc_(pp);
        }
    }
}

pub export fn pbackws(p: ?*P) void {
    const pp = p.?;
    const q = pdup_(pp, "pbackws");
    while (true) {
        const c = prgetc_(q);
        if (c != ' ' and c != '\t') break;
    }
    if (prgetc_(q) != NO_MORE_DATA) _ = pgetc_(q);
    buffer_mod.bdel_(q, pp);
    prm(q);
}

// ═══════════════════════════════════════════════════════════════════════
// Read-only block extraction
// ═══════════════════════════════════════════════════════════════════════

pub export fn brmem(p: ?*P, blk: ?*anyopaque, size: isize) ?*anyopaque {
    const pp = p.?;
    var dst = @as([*]u8, @ptrCast(blk));
    var remain = size;
    const q = pdup_(pp, "brmem");
    while (remain > 0) {
        const pt = vlock(intern.vmem, q.hdr.?.seg);
        const available = @as(isize, @intCast(gsize_(q.hdr.?) - q.ofst));
        const copy = @min(remain, available);
        if (copy <= 0) {
            vunlock_page(pt);
            break;
        }
        grmem_(q.hdr.?, pt, q.ofst, @ptrCast(dst), @as(i16, @intCast(copy)));
        vunlock_page(pt);
        dst += @as(usize, @intCast(copy));
        remain -= copy;
        // advance q past the copied region
        var adv = copy;
        while (adv > 0) {
            if (q.ofst == gsize_(q.hdr.?)) {
                if (pnext_(q) == 0) break;
            }
            const step = @min(adv, @as(isize, @intCast(gsize_(q.hdr.?) - q.ofst)));
            q.ofst += @as(i16, @intCast(step));
            q.byte += @as(i64, @intCast(step));
            adv -= step;
        }
    }
    prm(q);
    return blk;
}

const grmem_ = intern.grmem;

extern fn vstrunc(vary: [*c]u8, len: isize) [*c]u8;

pub export fn brs(p: ?*P, size: isize) ?*anyopaque {
    const buf = intern.joe_malloc(size + 1) orelse return null;
    _ = brmem(p, buf, size);
    @as([*]u8, @ptrCast(buf))[@as(usize, @intCast(size))] = 0;
    return buf;
}

pub export fn brvs(p: ?*P, size: isize) ?*anyopaque {
    // Match C: allocate a vs-string (with sSIZ/sLEN header), then fill via brmem.
    // Returning a plain joe_malloc buffer makes sv()/sLEN read heap garbage.
    const s = vstrunc(null, size);
    return brmem(p, s, size);
}

pub export fn brzs(p: ?*P, buf: ?*anyopaque, size: isize) ?*anyopaque {
    _ = brmem(p, buf, size);
    @as([*]u8, @ptrCast(buf))[@as(usize, @intCast(size))] = 0;
    return buf;
}
