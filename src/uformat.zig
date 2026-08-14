//! Path A live port of JOE text formatting commands (`joe/uformat.c`).
//!
//! JOE `uformat.h` ABI lives here (center, paragraph motion, wrapword,
//! format/fmtblk, trimlines). `joe/uformat.c` is a tombstone.

const std = @import("std");
const gap_types = @import("gapbuffer/types.zig");

const GapP = gap_types.P;
const GapB = gap_types.B;
const GapOptions = gap_types.OPTIONS;
const NO_MORE_DATA = gap_types.NO_MORE_DATA;

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;

/// Restrict paragraph motion/format to current block marks (`ufmtblk`).
export var within: c_int = 0;

const Watom = extern struct {
    context: ?[*:0]const u8,
    disp: ?*const fn (?*anyopaque, c_int) callconv(.c) void,
    follow: ?*const fn (?*anyopaque) callconv(.c) void,
    abort: ?*const fn (?*anyopaque) callconv(.c) c_int,
    rtn: ?*const fn (?*anyopaque) callconv(.c) c_int,
    @"type": ?*const fn (?*anyopaque, c_int) callconv(.c) c_int,
    resize: ?*const fn (?*anyopaque, isize, isize) callconv(.c) void,
    move: ?*const fn (?*anyopaque, isize, isize) callconv(.c) void,
    ins: ?*const fn (?*anyopaque, ?*anyopaque, i64, i64, c_int) callconv(.c) void,
    del: ?*const fn (?*anyopaque, ?*anyopaque, i64, i64, c_int) callconv(.c) void,
    what: c_int,
};

const WinLink = extern struct {
    next: ?*WinRec,
    prev: ?*WinRec,
};

const WinRec = extern struct {
    link: WinLink,
    t: ?*anyopaque,
    x: isize,
    y: isize,
    w: isize,
    h: isize,
    ny: isize,
    nh: isize,
    reqh: isize,
    fixed: isize,
    hh: isize,
    win: ?*WinRec,
    main: ?*WinRec,
    orgwin: ?*WinRec,
    curx: isize,
    cury: isize,
    kbd: ?*anyopaque,
    watom: ?*const Watom,
    object: ?*anyopaque,
    msgt: ?[*:0]const u8,
    msgb: ?[*:0]const u8,
    huh: ?[*:0]const u8,
    notify: ?*c_int,
    bstack: ?*anyopaque,
};

const BwSaved = extern struct {
    ww: c_int,
    ai: c_int,
    sp: c_int,
};

const BwRec = extern struct {
    parent: ?*WinRec,
    b: ?*GapB,
    top: ?*GapP,
    cursor: ?*GapP,
    offset: i64,
    t: ?*anyopaque,
    h: isize,
    w: isize,
    x: isize,
    y: isize,
    o: GapOptions,
    object: ?*anyopaque,
    lincols: c_int,
    curlin: i64,
    top_changed: c_int,
    db: ?*anyopaque,
    shell_flag: c_int,
    pasting: c_int,
    last_viewmode: c_int,
    saved: BwSaved,
};

comptime {
    if (@sizeOf(WinRec) != 200) @compileError("WinRec size mismatch");
    if (@sizeOf(BwRec) != 488) @compileError("BwRec size mismatch");
    if (@sizeOf(GapP) != 112) @compileError("GapP size mismatch");
}

extern fn pdup(p: ?*GapP, tr: [*:0]const u8) ?*GapP;
extern fn prm(p: ?*GapP) void;
extern fn pset(n: ?*GapP, p: ?*GapP) ?*GapP;
extern fn p_goto_bol(p: ?*GapP) ?*GapP;
extern fn p_goto_eol(p: ?*GapP) ?*GapP;
extern fn pnextl(p: ?*GapP) ?*GapP;
extern fn pprevl(p: ?*GapP) ?*GapP;
extern fn pcol(p: ?*GapP, goalcol: i64) ?*GapP;
extern fn piscol(p: ?*GapP) i64;
extern fn pfwrd(p: ?*GapP, n: i64) ?*GapP;
extern fn pgetc(p: ?*GapP) c_int;
extern fn prgetc(p: ?*GapP) c_int;
extern fn brc(p: ?*GapP) c_int;
extern fn brch(p: ?*GapP) c_int;
extern fn pisbol(p: ?*GapP) c_int;
extern fn pisbof(p: ?*GapP) c_int;
extern fn piseof(p: ?*GapP) c_int;
extern fn piseolblank(p: ?*GapP) c_int;
extern fn bdel(from: ?*GapP, to: ?*GapP) void;
extern fn brm(b: ?*GapB) void;
extern fn bcpy(from: ?*GapP, to: ?*GapP) ?*GapB;
extern fn binsc(p: ?*GapP, c: c_int) ?*GapP;
extern fn binss(p: ?*GapP, s: [*c]const u8) ?*GapP;
extern fn brs(p: ?*GapP, size: isize) ?*anyopaque;
extern fn joe_isblank(charmap: ?*anyopaque, c: c_int) c_int;
extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn joe_free(ptr: ?*anyopaque) void;
extern fn utf8_decode_fwrd(pos: *[*c]const u8, len: ?*isize) c_int;
extern fn txtwidth1(map: ?*anyopaque, tabwidth: i64, s: [*c]const u8, len: isize) i64;

extern var markb: ?*GapP;
extern var markk: ?*GapP;
extern var lightoff: c_int;
extern fn markv(r: c_int) c_int;
extern fn utomarkk(w: ?*anyopaque, k: c_int) c_int;
extern fn unmark(w: ?*anyopaque, k: c_int) c_int;

fn asWin(w: ?*anyopaque) *WinRec {
    return @ptrCast(@alignCast(w.?));
}

fn windBw(w_in: ?*anyopaque) ?*BwRec {
    if (w_in == null) return null;
    const win = asWin(w_in);
    const wa = win.watom orelse return null;
    if ((wa.what & (TYPETW | TYPEPW)) == 0) return null;
    return @ptrCast(@alignCast(win.object orelse return null));
}

fn zlen(s: [*c]const u8) isize {
    if (s == null) return 0;
    return @intCast(std.mem.len(@as([*:0]const u8, @ptrCast(s))));
}

fn mapOfBw(bw: *BwRec) ?*anyopaque {
    return @ptrCast(bw.o.charmap);
}

fn mapOfP(p: *GapP) ?*anyopaque {
    const b = p.b orelse return null;
    return @ptrCast(b.o.charmap);
}

/// Center line cursor is on and move cursor to beginning of next line.
pub export fn ucenter(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const p = bw.cursor orelse return -1;
    const map = mapOfBw(bw);

    _ = p_goto_eol(p);
    var c: c_int = undefined;
    while (true) {
        c = prgetc(p);
        if (joe_isblank(map, c) == 0) break;
    }
    if (c == '\n') {
        _ = pgetc(p);
        return ucenterDone(p);
    }
    if (c == NO_MORE_DATA) return ucenterDone(p);
    _ = pgetc(p);
    const endcol = piscol(p);

    _ = p_goto_bol(p);
    while (true) {
        c = pgetc(p);
        if (joe_isblank(map, c) == 0) break;
    }
    if (c == '\n') {
        _ = prgetc(p);
        return ucenterDone(p);
    }
    if (c == NO_MORE_DATA) return ucenterDone(p);
    _ = prgetc(p);
    const begcol = piscol(p);

    if (endcol - begcol > bw.o.rmargin + bw.o.lmargin) return ucenterDone(p);

    const q = pdup(p, "ucenter") orelse return ucenterDone(p);
    _ = p_goto_bol(q);
    bdel(q, p);
    prm(q);

    var x: i64 = 0;
    const limit = @divTrunc(bw.o.lmargin + bw.o.rmargin, 2) - @divTrunc(endcol - begcol, 2);
    while (x != limit) : (x += 1) {
        _ = binsc(p, ' ');
    }
    return ucenterDone(p);
}

fn ucenterDone(p: *GapP) c_int {
    if (pnextl(p) == null) {
        _ = binsc(p, '\n');
        _ = pgetc(p);
        return -1;
    }
    return 0;
}

/// Return true if c is a character which can indent a paragraph.
fn cpara(bw: *BwRec, c: c_int) c_int {
    if (c == ' ' or c == '\t') return 1;
    if (bw.o.cpara) |raw| {
        var s: [*c]const u8 = @ptrCast(raw);
        while (s.* != 0) {
            if (utf8_decode_fwrd(&s, null) == c) return 1;
        }
    }
    return 0;
}

/// Return true if this first non-whitespace character means we are not a paragraph.
fn cnotpara(bw: *BwRec, c: c_int) c_int {
    if (bw.o.cnotpara) |raw| {
        var s: [*c]const u8 = @ptrCast(raw);
        while (s.* != 0) {
            if (c == utf8_decode_fwrd(&s, null)) return 1;
        }
    }
    return 0;
}

/// Return true if line is definitely not a paragraph line.
fn pisnpara(bw: *BwRec, p: *GapP) c_int {
    const q = pdup(p, "pisnpara") orelse return 1;
    defer prm(q);
    _ = p_goto_bol(q);
    var c: c_int = undefined;
    while (true) {
        c = pgetc(q);
        if (cpara(bw, c) == 0) break;
    }
    if (cnotpara(bw, c) != 0 or c == '\r' or c == '\n') return 1;
    return 0;
}

/// Determine amount of indentation on current line.
fn nindent(bw: *BwRec, p: *GapP, first: c_int) i64 {
    const q = pdup(p, "nindent") orelse return 0;
    defer prm(q);
    _ = p_goto_bol(q);
    var col: i64 = 0;
    var c: c_int = undefined;
    while (true) {
        col = q.col;
        c = pgetc(q);
        if (cpara(bw, c) == 0) break;
    }
    if (first != 0 and (c == '-' or c == '*')) {
        c = pgetc(q);
        if (c == ' ') col = q.col;
    }
    return col;
}

/// Get indentation prefix column.
fn prefix(bw: *BwRec, p: *GapP, up: c_int) i64 {
    _ = up;
    const q = pdup(p, "prefix") orelse return 0;
    defer prm(q);
    _ = p_goto_bol(q);
    while (cpara(bw, brch(q)) != 0) _ = pgetc(q);
    while (pisbol(q) == 0) {
        if (joe_isblank(mapOfP(p), prgetc(q)) == 0) break;
    }
    return piscol(q);
}

/// Move pointer to beginning of paragraph.
pub export fn pbop(bw_in: ?*anyopaque, p_in: ?*GapP) ?*GapP {
    const bw: *BwRec = @ptrCast(@alignCast(bw_in orelse return p_in));
    const p = p_in orelse return null;
    _ = p_goto_bol(p);
    const indent = nindent(bw, p, 0);
    const prelen = prefix(bw, p, 0);
    const last = pdup(p, "pbop") orelse return p;
    while (pisbof(p) == 0 and (within == 0 or markb == null or p.byte > markb.?.byte)) {
        _ = pprevl(p);
        _ = p_goto_bol(p);
        const ind = nindent(bw, p, 0);
        const len = prefix(bw, p, 0);
        if (pisnpara(bw, p) != 0 or len != prelen) {
            _ = pset(p, last);
            break;
        }
        if (ind > indent) break;
        if (ind < indent) {
            _ = pset(p, last);
            break;
        }
        _ = pset(last, p);
    }
    prm(last);
    return p;
}

/// Move pointer to end of paragraph.
pub export fn peop(bw_in: ?*anyopaque, p_in: ?*GapP) ?*GapP {
    const bw: *BwRec = @ptrCast(@alignCast(bw_in orelse return p_in));
    const p = p_in orelse return null;
    if (pnextl(p) == null or pisnpara(bw, p) != 0 or (within != 0 and markk != null and p.byte >= markk.?.byte))
        return p;
    const indent = nindent(bw, p, 0);
    const prelen = prefix(bw, p, 0);
    while (pnextl(p) != null and (within == 0 or markk == null or p.byte < markk.?.byte)) {
        const ind = nindent(bw, p, 0);
        const len = prefix(bw, p, 0);
        if (ind != indent or len != prelen or pisnpara(bw, p) != 0) break;
    }
    return p;
}

pub export fn ubop(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    const q = pdup(cur, "ubop") orelse return -1;
    while (true) {
        while (pisnpara(bw, q) != 0 and pisbof(q) == 0 and (within == 0 or markb == null or q.byte > markb.?.byte))
            _ = pprevl(q);
        _ = pbop(bw, q);
        if (q.byte != cur.byte) {
            _ = pset(cur, q);
            prm(q);
            return 0;
        } else if (pisbof(q) == 0) {
            _ = prgetc(q);
            continue;
        } else {
            prm(q);
            return -1;
        }
    }
}

pub export fn ueop(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    const q = pdup(cur, "ueop") orelse return -1;
    while (true) {
        while (pisnpara(bw, q) != 0 and piseof(q) == 0) _ = pnextl(q);
        _ = pbop(bw, q);
        _ = peop(bw, q);
        if (q.byte != cur.byte) {
            _ = pset(cur, q);
            prm(q);
            return 0;
        } else if (piseof(q) == 0) {
            _ = pnextl(q);
            continue;
        } else {
            prm(q);
            return -1;
        }
    }
}

/// Wrap word. If `french` is set, only one space after . ? or !.
pub export fn wrapword(bw_in: ?*anyopaque, p_in: ?*GapP, indent_in: i64, french: c_int, no_over: c_int, indents_in: [*c]u8) void {
    const bw: *BwRec = @ptrCast(@alignCast(bw_in orelse return));
    const p = p_in orelse return;
    var indent = indent_in;
    var indents = indents_in;
    var my_indents: c_int = 0;
    var to = p.byte;

    if (indents == null) {
        const s = pdup(p, "wrapword") orelse return;
        _ = p_goto_bol(s);
        _ = pbop(bw, s);
        const q = pdup(s, "wrapword") orelse {
            prm(s);
            return;
        };
        _ = pnextl(q);
        if (q.line < p.line) {
            const tr = pdup(q, "wrapword") orelse {
                prm(q);
                prm(s);
                return;
            };
            indent = nindent(bw, q, 0);
            _ = pcol(tr, indent);
            indents = @ptrCast(brs(q, @intCast(tr.byte - q.byte)));
            prm(tr);
        } else {
            const tr = pdup(s, "uformat") orelse {
                prm(q);
                prm(s);
                return;
            };
            indent = nindent(bw, s, 1);
            _ = pcol(tr, indent);
            indents = @ptrCast(brs(s, @intCast(tr.byte - s.byte)));
            prm(tr);
            if (indents != null and bw.o.autoindent == 0) {
                var tx = zlen(indents);
                const orgx = tx;
                while (tx != 0 and (indents[@intCast(tx - 1)] == ' ' or indents[@intCast(tx - 1)] == '\t')) {
                    tx -= 1;
                    indents[@intCast(tx)] = 0;
                }
                if (tx != 0 and orgx != tx) {
                    indents[@intCast(tx)] = ' ';
                    tx += 1;
                    indents[@intCast(tx)] = 0;
                }
                indent = txtwidth1(mapOfBw(bw), bw.o.tab, indents, tx);
            }
            if (indents != null) {
                var x: isize = 0;
                while (indents[@intCast(x)] != 0 and (indents[@intCast(x)] == ' ' or indents[@intCast(x)] == '\t')) : (x += 1) {}
                var y = zlen(indents);
                while (y != 0 and (indents[@intCast(y - 1)] == ' ' or indents[@intCast(y - 1)] == '\t')) : (y -= 1) {}
                if (y != 0 and ((indents[@intCast(y - 1)] == '*' and cpara(bw, '*') == 0) or (indents[@intCast(y - 1)] == '-' and cpara(bw, '-') == 0)) and
                    (y == 1 or indents[@intCast(y - 2)] == ' ' or indents[@intCast(y - 2)] == '\t'))
                {
                    indents[@intCast(y - 1)] = ' ';
                }
                if (indents[@intCast(x)] == '/' and indents[@intCast(x + 1)] == '*')
                    indents[@intCast(x)] = ' ';
            }
        }
        if (indents != null and bw.o.lmargin > indent) {
            var x: isize = 0;
            while (indents[@intCast(x)] == ' ' or indents[@intCast(x)] == '\t') : (x += 1) {}
            if (indents[@intCast(x)] == 0) {
                joe_free(indents);
                indent = bw.o.lmargin;
                indents = @ptrCast(joe_malloc(@intCast(indent + 1)));
                if (indents != null) {
                    x = 0;
                    while (x != indent) : (x += 1) indents[@intCast(x)] = ' ';
                    indents[@intCast(x)] = 0;
                }
            }
        }
        my_indents = 1;
        prm(q);
        prm(s);
    }

    while (pisbol(p) == 0 and piscol(p) > indent and joe_isblank(mapOfP(p), prgetc(p)) == 0) {}

    if (pisbol(p) == 0 and piscol(p) > indent) {
        const q = pdup(p, "wrapword") orelse {
            if (my_indents != 0) joe_free(indents);
            return;
        };
        while (pisbol(q) == 0) {
            const c = prgetc(q);
            if (joe_isblank(mapOfP(p), c) == 0) {
                _ = pgetc(q);
                if ((c == '.' or c == '?' or c == '!') and q.byte != p.byte and french == 0)
                    _ = pgetc(q);
                break;
            }
        }
        _ = pgetc(p);

        to -= p.byte - q.byte;
        bdel(q, p);
        prm(q);

        if (bw.o.flowed != 0) {
            _ = binsc(p, ' ');
            _ = pgetc(p);
            to += 1;
        }

        _ = binsc(p, '\n');

        if (no_over == 0) {
            const b = p.b orelse {
                if (my_indents != 0) joe_free(indents);
                return;
            };
            if (b.o.overtype != 0) {
                const r = pdup(p, "wrapword") orelse {
                    if (my_indents != 0) joe_free(indents);
                    return;
                };
                _ = pgetc(r);
                _ = p_goto_eol(r);
                var s2 = pdup(r, "wrapword") orelse {
                    prm(r);
                    if (my_indents != 0) joe_free(indents);
                    return;
                };
                _ = pgetc(r);
                bdel(s2, r);
                _ = binsc(r, ' ');
                _ = pfwrd(r, r.b.?.o.rmargin - r.col);
                prm(s2);
                s2 = pdup(r, "wrapword") orelse {
                    prm(r);
                    if (my_indents != 0) joe_free(indents);
                    return;
                };
                _ = p_goto_eol(s2);
                prm(s2);
                prm(r);
            }
        }

        to += 1;
        if (p.b) |b| {
            if (b.o.crlf != 0) to += 1;
        }
        _ = pgetc(p);

        if (indents != null) {
            _ = binss(p, indents);
            to += zlen(indents);
        } else {
            var rem = indent;
            while (rem > 0) : (rem -= 1) {
                _ = binsc(p, ' ');
                to += 1;
            }
        }
    }

    _ = pfwrd(p, to - p.byte);
    if (my_indents != 0) joe_free(indents);
}

/// Reformat paragraph.
pub export fn uformat(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;

    const p = pdup(cur, "uformat") orelse return -1;
    _ = p_goto_bol(p);

    if (pisnpara(bw, p) != 0) {
        prm(p);
        return 0;
    }

    _ = pbop(bw, p);
    const curoff = cur.byte - p.byte;
    _ = pset(cur, p);
    _ = peop(bw, cur);

    if (pisbol(cur) == 0) {
        _ = binsc(cur, '\n');
        _ = pgetc(cur);
    }

    const q = pdup(p, "uformat") orelse {
        prm(p);
        return -1;
    };
    _ = pnextl(q);

    var indent: i64 = 0;
    var indents: [*c]u8 = undefined;
    if (q.line != cur.line) {
        const r = pdup(q, "uformat") orelse {
            prm(q);
            prm(p);
            return -1;
        };
        indent = nindent(bw, q, 0);
        _ = pcol(r, indent);
        indents = @ptrCast(brs(q, @intCast(r.byte - q.byte)));
        prm(r);
    } else {
        const r = pdup(p, "uformat") orelse {
            prm(q);
            prm(p);
            return -1;
        };
        indent = nindent(bw, p, 1);
        _ = pcol(r, indent);
        indents = @ptrCast(brs(p, @intCast(r.byte - p.byte)));
        prm(r);
        if (indents != null and bw.o.autoindent == 0) {
            var tx = zlen(indents);
            while (tx != 0 and (indents[@intCast(tx - 1)] == ' ' or indents[@intCast(tx - 1)] == '\t')) {
                tx -= 1;
                indents[@intCast(tx)] = 0;
            }
            if (tx != 0) {
                indents[@intCast(tx)] = ' ';
                tx += 1;
                indents[@intCast(tx)] = 0;
            }
            indent = txtwidth1(mapOfBw(bw), bw.o.tab, indents, tx);
        }
        if (indents != null) {
            var x: isize = 0;
            while (indents[@intCast(x)] != 0 and (indents[@intCast(x)] == ' ' or indents[@intCast(x)] == '\t')) : (x += 1) {}
            var y = zlen(indents);
            while (y != 0 and (indents[@intCast(y - 1)] == ' ' or indents[@intCast(y - 1)] == '\t')) : (y -= 1) {}
            if (y != 0 and ((indents[@intCast(y - 1)] == '*' and cpara(bw, '*') == 0) or (indents[@intCast(y - 1)] == '-' and cpara(bw, '-') == 0)) and
                (y == 1 or indents[@intCast(y - 2)] == ' ' or indents[@intCast(y - 2)] == '\t'))
            {
                indents[@intCast(y - 1)] = ' ';
            }
            if (indents[@intCast(x)] == '/' and indents[@intCast(x + 1)] == '*')
                indents[@intCast(x)] = ' ';
        }
    }
    prm(q);

    if (indents == null) {
        prm(p);
        return -1;
    }

    if (bw.o.lmargin > indent) {
        var x: isize = 0;
        while (indents[@intCast(x)] == ' ' or indents[@intCast(x)] == '\t') : (x += 1) {}
        if (indents[@intCast(x)] == 0) {
            joe_free(indents);
            indent = bw.o.lmargin;
            indents = @ptrCast(joe_malloc(@intCast(indent + 1)));
            if (indents == null) {
                prm(p);
                return -1;
            }
            x = 0;
            while (x != indent) : (x += 1) indents[@intCast(x)] = ' ';
            indents[@intCast(x)] = 0;
        }
    }

    const buf = bcpy(p, cur) orelse {
        joe_free(indents);
        prm(p);
        return -1;
    };
    if (p.b) |srcb| {
        buf.o.crlf = srcb.o.crlf;
        buf.o.charmap = srcb.o.charmap;
    }
    bdel(p, cur);

    const b = pdup(buf.bof, "uformat") orelse {
        brm(buf);
        joe_free(indents);
        prm(p);
        return -1;
    };

    var flag: c_int = 0;
    while (piseof(b) == 0) {
        const c = brch(b);
        if (joe_isblank(mapOfP(b), c) != 0 or c == '\n') {
            var f: c_int = 0;
            if (flag != 0 and piscol(p) > bw.o.rmargin)
                wrapword(bw, p, indent, bw.o.french, 1, indents);
            flag = 0;
            if (c == '\n' or piseolblank(b) != 0) break;
            if (pisbof(b) == 0) {
                const d = pdup(b, "uformat");
                if (d) |dd| {
                    const g = prgetc(dd);
                    if (g == '.' or g == '?' or g == '!') f = 1;
                    prm(dd);
                }
            }
            if (f != 0) {
                while (joe_isblank(mapOfP(b), brc(b)) != 0) {
                    if (b.byte == curoff) _ = pset(cur, p);
                    _ = pgetc(b);
                }
                if (piseof(b) == 0) {
                    if (bw.o.french == 0) {
                        _ = binsc(p, ' ');
                        _ = pgetc(p);
                    }
                    _ = binsc(p, ' ');
                    _ = pgetc(p);
                }
            } else {
                _ = binsc(p, pgetc(b));
                _ = pgetc(p);
            }
        } else {
            if (b.byte == curoff) _ = pset(cur, p);
            _ = binsc(p, pgetc(b));
            _ = pgetc(p);
            flag = 1;
        }
    }

    flag = 0;
    while (piseof(b) == 0) {
        var c = brc(b);
        if (joe_isblank(mapOfP(b), c) != 0 or c == '\n') {
            var f: c_int = 0;
            if (flag != 0 and piscol(p) > bw.o.rmargin)
                wrapword(bw, p, indent, bw.o.french, 1, indents);
            flag = 0;
            const d = pdup(b, "uformat");
            if (d) |dd| {
                const g = prgetc(dd);
                if (g == '.' or g == '?' or g == '!') f = 1;
                prm(dd);
            }
            while (true) {
                c = brc(b);
                if (c == '\n') {
                    if (b.byte == curoff) _ = pset(cur, p);
                    _ = pgetc(b);
                    while (true) {
                        const cc = brch(b);
                        if (cpara(bw, cc) == 0) {
                            c = cc;
                            break;
                        }
                        if (b.byte == curoff) _ = pset(cur, p);
                        _ = pgetc(b);
                    }
                }
                if (joe_isblank(mapOfP(b), c) != 0) {
                    if (b.byte == curoff) _ = pset(cur, p);
                    _ = pgetc(b);
                    continue;
                }
                break;
            }
            if (piseof(b) == 0) {
                if (f != 0 and bw.o.french == 0) {
                    _ = binsc(p, ' ');
                    _ = pgetc(p);
                }
                _ = binsc(p, ' ');
                _ = pgetc(p);
            }
        } else {
            if (b.byte == curoff) _ = pset(cur, p);
            _ = binsc(p, pgetc(b));
            _ = pgetc(p);
            flag = 1;
        }
    }

    if (flag != 0 and piscol(p) > bw.o.rmargin)
        wrapword(bw, p, indent, bw.o.french, 1, indents);

    _ = binsc(p, '\n');
    prm(p);
    prm(b);
    brm(buf);
    joe_free(indents);
    return 0;
}

/// Format entire block.
pub export fn ufmtblk(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const cur = bw.cursor orelse return -1;
    if (markv(1) != 0 and markb != null and markk != null and
        cur.byte >= markb.?.byte and cur.byte <= markk.?.byte)
    {
        markk.?.end = 1;
        _ = utomarkk(w, 0);
        within = 1;
        while (true) {
            _ = ubop(w, 0);
            _ = uformat(w, 0);
            if (!(cur.byte > markb.?.byte)) break;
        }
        within = 0;
        markk.?.end = 0;
        if (lightoff != 0) _ = unmark(w, 0);
        return 0;
    }
    return uformat(w, 0);
}

/// Clean up indentation: remove indentation from blank lines.
pub export fn utrimlines(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const b = bw.b orelse return -1;
    const p = pdup(b.bof, "utrimlines") orelse return -1;
    const map = mapOfBw(bw);

    while (piseof(p) == 0) {
        p.valcol = 0;
        _ = p_goto_eol(p);
        const q = pdup(p, "utrimlines") orelse {
            prm(p);
            return -1;
        };
        var c: c_int = undefined;
        while (true) {
            c = prgetc(q);
            if (joe_isblank(map, c) == 0) break;
        }
        if (c != NO_MORE_DATA) _ = pgetc(q);
        if (q.byte < p.byte) bdel(q, p);
        prm(q);
        _ = pgetc(p);
    }
    prm(p);
    return 0;
}
