//! Terminal emulator — replaces `joe/vt.c`.
//!
//! Faithful C-ABI Path A port of JOE vt (mkvt/vtrm/vt_data/vt_resize). joe/vt.c is a tombstone; joe/vt.h remains the C declaration surface.

const std = @import("std");
const ptrdiff_t = c_long;

const DOUBLE_UNDERLINE: c_int = 8;
const CROSSED_OUT: c_int = 16;
const ITALIC: c_int = 32;
const INVERSE: c_int = 64;
const UNDERLINE: c_int = 128;
const BOLD: c_int = 256;
const BLINK: c_int = 512;
const DIM: c_int = 1024;
const BG_SHIFT: c_int = 11;
const FG_SHIFT: c_int = 21;
const MAXARGS: c_int = 2;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn fprintf(f: ?*anyopaque, fmt: [*c]const u8, ...) c_int;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn malloc(n: c_ulong) ?*anyopaque;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub const off_t = i64;
pub const FILE = anyopaque;
pub const B = struct_b;
const struct_unnamed_1 = extern struct {
    next: [*c]B = null,
    prev: [*c]B = null,
};
const struct_unnamed_2 = extern struct {
    next: [*c]P = null,
    prev: [*c]P = null,
};
pub const struct_p = extern struct {
    link: struct_unnamed_2 = std.mem.zeroes(struct_unnamed_2),
    b: [*c]B = null,
    _pad0: [24]u8 = std.mem.zeroes([24]u8),
    byte: off_t = 0,
    line: off_t = 0,
    col: off_t = 0,
    xcol: off_t = 0,
    valcol: c_int = 0,
    end: c_int = 0,
    attr: c_int = 0,
    valattr: c_int = 0,
    owner: [*c][*c]P = null,
    tracker: [*c]const u8 = null,
};
pub const P = struct_p;
pub const struct_options = extern struct {
    next: [*c]struct_options = null,
    ftype: [*c]const u8 = null,
    match: ?*anyopaque = null,
    overtype: c_int = 0,
    lmargin: off_t = 0,
    rmargin: off_t = 0,
    autoindent: c_int = 0,
    wordwrap: c_int = 0,
    nobackup: c_int = 0,
    _pad_tab: [4]u8 = std.mem.zeroes([4]u8),
    tab: off_t = 0,
    _pad_rest: [272]u8 = std.mem.zeroes([272]u8),
};
pub const OPTIONS = struct_options;
pub const struct_b = extern struct {
    link: struct_unnamed_1 = std.mem.zeroes(struct_unnamed_1),
    bof: [*c]P = null,
    eof: [*c]P = null,
    _pad1: [160]u8 = std.mem.zeroes([160]u8),
    o: OPTIONS = std.mem.zeroes(OPTIONS),
    _pad2: [96]u8 = std.mem.zeroes([96]u8),
};
pub const struct_kmap = opaque {
};
pub const KMAP = struct_kmap;
pub const struct_kbd = extern struct {
    curmap: ?*KMAP = null,
    topmap: ?*KMAP = null,
    seq: [16]c_int = std.mem.zeroes([16]c_int),
    x: ptrdiff_t = 0,
};
pub const KBD = struct_kbd;
pub const MACRO = struct_macro;
pub const struct_macro = extern struct {
    what: ptrdiff_t = 0,
    k: c_int = 0,
    flg: c_int = 0,
    cmd: ?*anyopaque = null,
    n: ptrdiff_t = 0,
    size: ptrdiff_t = 0,
    steps: [*c][*c]MACRO = null,
};
pub const struct_charmap = extern struct {
    next: [*c]struct_charmap = null,
    name: [*c]const u8 = null,
    type: c_int = 0,
};
pub const struct_utf8_sm = extern struct {
    buf: [8]u8 = std.mem.zeroes([8]u8),
    ptr: ptrdiff_t = 0,
    state: c_int = 0,
    accu: c_int = 0,
};
pub const vt_idle: c_int = 0;
pub const vt_esc: c_int = 1;
pub const vt_args: c_int = 2;
pub const vt_cmd: c_int = 3;
pub const vt_utf: c_int = 4;
pub const vt_osc: c_int = 5;
pub const vt_osce: c_int = 6;
pub const enum_vt_state = c_uint;
pub const struct_vt_context = extern struct {
    state: enum_vt_state = std.mem.zeroes(enum_vt_state),
    buf: [1024]u8 = std.mem.zeroes([1024]u8),
    bufx: ptrdiff_t = 0,
    argv: [3]ptrdiff_t = std.mem.zeroes([3]ptrdiff_t),
    argc: ptrdiff_t = 0,
    top: [*c]P = null,
    height: ptrdiff_t = 0,
    width: ptrdiff_t = 0,
    regn_top: ptrdiff_t = 0,
    regn_bot: ptrdiff_t = 0,
    vtcur: [*c]P = null,
    b: [*c]B = null,
    kbd: [*c]KBD = null,
    attr: c_int = 0,
    utf8_sm: struct_utf8_sm = std.mem.zeroes(struct_utf8_sm),
};
pub const VT = struct_vt_context;

comptime {
    if (@sizeOf(VT) != 1168) @compileError("VT size mismatch");
    if (@sizeOf(P) != 112) @compileError("P size mismatch");
    if (@sizeOf(B) != 632) @compileError("B size mismatch");
    if (@sizeOf(OPTIONS) != 344) @compileError("OPTIONS size mismatch");
    if (@sizeOf(KBD) != 88) @compileError("KBD size mismatch");
    if (@sizeOf(MACRO) != 48) @compileError("MACRO size mismatch");
    if (@sizeOf(struct_utf8_sm) != 24) @compileError("utf8_sm size mismatch");
    if (@offsetOf(VT, "bufx") != 1032) @compileError("VT.bufx offset mismatch");
    if (@offsetOf(VT, "attr") != 1136) @compileError("VT.attr offset mismatch");
    if (@offsetOf(VT, "utf8_sm") != 1144) @compileError("VT.utf8_sm offset mismatch");
    if (@offsetOf(B, "eof") != 24) @compileError("B.eof offset mismatch");
    if (@offsetOf(B, "o") != 192) @compileError("B.o offset mismatch");
    if (@offsetOf(OPTIONS, "tab") != 64) @compileError("OPTIONS.tab offset mismatch");
}

pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn pdup(p: [*c]P, tr: [*c]const u8) [*c]P;
pub extern fn prm(p: [*c]P) void;
pub extern fn pset(n: [*c]P, p: [*c]P) [*c]P;
pub extern fn pline(p: [*c]P, line: off_t) [*c]P;
pub extern fn pnextl(p: [*c]P) [*c]P;
pub extern fn p_goto_bol(p: [*c]P) [*c]P;
pub extern fn p_goto_eol(p: [*c]P) [*c]P;
pub extern fn p_goto_eof(p: [*c]P) [*c]P;
pub extern fn piscol(p: [*c]P) off_t;
pub extern fn piseol(p: [*c]P) c_int;
pub extern fn pgetc(p: [*c]P) c_int;
pub extern fn pgetb(p: [*c]P) c_int;
pub extern fn pfwrd(p: [*c]P, n: off_t) [*c]P;
pub extern fn pcol(p: [*c]P, goalcol: off_t) [*c]P;
pub extern fn pfill(p: [*c]P, to: off_t, usetabs: c_int) void;
pub extern fn binsc(p: [*c]P, c: c_int) [*c]P;
pub extern fn binss(p: [*c]P, s: [*c]const u8) [*c]P;
pub extern fn bdel(from: [*c]P, to: [*c]P) void;
pub extern fn mkkbd(kmap: ?*KMAP) [*c]KBD;
pub extern fn rmkbd(k: [*c]KBD) void;
pub extern fn kmap_getcontext(name: [*c]const u8) ?*KMAP;
pub extern fn utf8_init(utf8_sm: [*c]struct_utf8_sm) void;
pub extern fn utf8_decode(utf8_sm: [*c]struct_utf8_sm, c: u8) c_int;
pub extern var obuf: [*c]u8;
pub extern var obufp: ptrdiff_t;
pub extern var obufsiz: ptrdiff_t;
pub extern fn ttflsh() c_int;
/// JOE `ttputc` macro (`tty.h`) as a Zig fn — write one byte into `obuf`.
fn ttputc(c: c_int) callconv(.c) void {
    obuf[@intCast(obufp)] = @truncate(@as(c_uint, @bitCast(c)));
    obufp += 1;
    if (obufp == obufsiz) {
        _ = ttflsh();
    }
}
pub extern fn vt_scrdn() void;
pub extern fn mparse(m: [*c]MACRO, buf: [*c]const u8, sta: [*c]ptrdiff_t, secure: c_int) [*c]MACRO;
pub extern fn rmmacro(macro: [*c]MACRO) void;
pub extern var locale_map: [*c]struct_charmap;
pub export fn mkvt(arg_b_1: [*c]B, arg_top: [*c]P, arg_height: ptrdiff_t, arg_width: ptrdiff_t) [*c]VT {
    var b_1 = arg_b_1;
    _ = &b_1;
    var top = arg_top;
    _ = &top;
    var height = arg_height;
    _ = &height;
    var width = arg_width;
    _ = &width;
    var vt: [*c]VT = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(VT))))))));
    _ = &vt;
    vt.*.b = b_1;
    vt.*.vtcur = pdup(b_1.*.eof, "vt");
    vt.*.state = vt_idle;
    vt.*.top = pdup(top, "mkvt");
    vt.*.regn_top = 0;
    vt.*.regn_bot = height;
    vt.*.height = height;
    vt.*.width = width;
    vt.*.argc = 0;
    vt.*.kbd = mkkbd(kmap_getcontext("vtshell"));
    vt.*.attr = 0;
    utf8_init(&vt.*.utf8_sm);
    return vt;
}
pub export fn vt_resize(arg_vt: [*c]VT, arg_top: [*c]P, arg_height: ptrdiff_t, arg_width: ptrdiff_t) void {
    var vt = arg_vt;
    _ = &vt;
    var top = arg_top;
    _ = &top;
    var height = arg_height;
    _ = &height;
    var width = arg_width;
    _ = &width;
    var flag: c_int = 0;
    _ = &flag;
    if (vt.*.regn_bot == vt.*.height) {
        flag = 1;
    }
    vt.*.height = height;
    vt.*.width = width;
    _ = pset(vt.*.top, top);
    if (vt.*.regn_top > height) {
        vt.*.regn_top = height;
    }
    if (vt.*.regn_bot > height) {
        vt.*.regn_bot = height;
    }
    if (flag != 0) {
        vt.*.regn_bot = height;
    }
    if (vt.*.vtcur.*.line >= (vt.*.top.*.line + @as(off_t, height))) {
        _ = pline(vt.*.top, (vt.*.vtcur.*.line - @as(off_t, height)) + @as(off_t, 1));
    }
}
pub export fn vtrm(arg_vt: [*c]VT) void {
    var vt = arg_vt;
    _ = &vt;
    if (vt.*.vtcur != null) {
        prm(vt.*.vtcur);
    }
    if (vt.*.top != null) {
        prm(vt.*.top);
    }
    rmkbd(vt.*.kbd);
    joe_free(@ptrCast(@alignCast(vt)));
}
pub fn vt_beep(arg_bw: [*c]VT) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    ttputc(7);
}
pub fn pcurattr(arg_p_1: [*c]P) callconv(.c) c_int {
    var p_1 = arg_p_1;
    _ = &p_1;
    var attr: c_int = 0;
    _ = &attr;
    var state: c_int = 0;
    _ = &state;
    var arg: c_int = 0;
    _ = &arg;
    var q: [*c]P = undefined;
    _ = &q;
    if (p_1.*.valattr != 0) return p_1.*.attr;
    q = pdup(p_1, "pcurattr");
    _ = p_goto_bol(q);
    while (q.*.byte != p_1.*.byte) {
        var c: c_int = pgetb(q);
        _ = &c;
        while (true) {
            switch (state) {
                @as(c_int, 0) => {
                    if (c == @as(c_int, 27)) {
                        state = 1;
                    }
                    break;
                },
                @as(c_int, 1) => {
                    if (c == @as(c_int, 91)) {
                        state = 2;
                        arg = 0;
                    } else {
                        state = 0;
                    }
                    break;
                },
                @as(c_int, 2) => {
                    if ((c >= @as(c_int, '0')) and (c <= @as(c_int, '9'))) {
                        arg = ((arg * @as(c_int, 10)) + c) - @as(c_int, '0');
                    } else {
                        if (c == @as(c_int, 'm')) {
                            if (arg == @as(c_int, 0)) {
                                attr = 0;
                            } else if (arg == @as(c_int, 1)) {
                                attr |= BOLD;
                            } else if (arg == @as(c_int, 4)) {
                                attr |= UNDERLINE;
                            } else if (arg == @as(c_int, 7)) {
                                attr |= INVERSE;
                            } else if ((arg >= @as(c_int, 30)) and (arg <= @as(c_int, 37))) {
                                attr = (attr & ~(@as(c_int, 1023) << @intCast(FG_SHIFT))) | ((@as(c_int, 256) << @intCast(FG_SHIFT)) | ((arg - @as(c_int, 30)) << @intCast(FG_SHIFT)));
                            } else if ((arg >= @as(c_int, 40)) and (arg <= @as(c_int, 47))) {
                                attr = (attr & ~(@as(c_int, 1023) << @intCast(BG_SHIFT))) | ((@as(c_int, 256) << @intCast(BG_SHIFT)) | ((arg - @as(c_int, 40)) << @intCast(BG_SHIFT)));
                            }
                        }
                        state = 0;
                    }
                    break;
                },
                else => {},
            }
            break;
        }
    }
    prm(q);
    p_1.*.attr = attr;
    p_1.*.valattr = 1;
    return attr;
}
pub fn psetattr(arg_p_1: [*c]P, arg_attr: c_int, arg_cur: c_int, arg_adv: c_int) callconv(.c) void {
    var p_1 = arg_p_1;
    _ = &p_1;
    var attr = arg_attr;
    _ = &attr;
    var cur = arg_cur;
    _ = &cur;
    var adv = arg_adv;
    _ = &adv;
    var e: c_int = ((((((((((INVERSE + UNDERLINE) + BOLD) + BLINK) + DIM) + ITALIC) + DOUBLE_UNDERLINE) + CROSSED_OUT) | (@as(c_int, 256) << @intCast(FG_SHIFT))) | (@as(c_int, 256) << @intCast(BG_SHIFT))) & cur) & ~attr;
    _ = &e;
    if (!(adv != 0)) {
        p_1 = pdup(p_1, "psetattr");
    }
    if (e != 0) {
        _ = binss(p_1, "\x1b[m");
        _ = pfwrd(p_1, 3);
        cur = 0;
    }
    e = attr & ~cur;
    if ((e & INVERSE) != 0) {
        _ = binss(p_1, "\x1b[7m");
        _ = pfwrd(p_1, 4);
    }
    if ((e & BOLD) != 0) {
        _ = binss(p_1, "\x1b[1m");
        _ = pfwrd(p_1, 4);
    }
    if ((e & UNDERLINE) != 0) {
        _ = binss(p_1, "\x1b[4m");
        _ = pfwrd(p_1, 4);
    }
    if ((cur & (@as(c_int, 1023) << @intCast(FG_SHIFT))) != (attr & (@as(c_int, 1023) << @intCast(FG_SHIFT)))) {
        var color: c_int = (attr & (@as(c_int, 255) << @intCast(FG_SHIFT))) >> @intCast(FG_SHIFT);
        _ = &color;
        if ((color >= @as(c_int, 0)) and (color <= @as(c_int, 7))) {
            var bf: [10]u8 = undefined;
            _ = &bf;
            _ = snprintf(@ptrCast(@alignCast(&bf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))))), "\x1b[%dm", color + @as(c_int, 30));
            _ = binss(p_1, @ptrCast(@alignCast(&bf)));
            _ = pfwrd(p_1, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(@ptrCast(@alignCast(&bf))))))));
        }
    }
    if ((cur & (@as(c_int, 1023) << @intCast(BG_SHIFT))) != (attr & (@as(c_int, 1023) << @intCast(BG_SHIFT)))) {
        var color: c_int = (attr & (@as(c_int, 255) << @intCast(BG_SHIFT))) >> @intCast(BG_SHIFT);
        _ = &color;
        if ((color >= @as(c_int, 0)) and (color <= @as(c_int, 7))) {
            var bf: [10]u8 = undefined;
            _ = &bf;
            _ = snprintf(@ptrCast(@alignCast(&bf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))))), "\x1b[%dm", color + @as(c_int, 40));
            _ = binss(p_1, @ptrCast(@alignCast(&bf)));
            _ = pfwrd(p_1, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(@ptrCast(@alignCast(&bf))))))));
        }
    }
    if (!(adv != 0)) {
        prm(p_1);
    } else {
        p_1.*.attr = attr;
        p_1.*.valattr = 1;
    }
}
pub fn vt_type(arg_bw: [*c]VT, arg_c: c_int) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var c = arg_c;
    _ = &c;
    var col: off_t = undefined;
    _ = &col;
    var cur_attr: c_int = undefined;
    _ = &cur_attr;
    var org_attr: c_int = undefined;
    _ = &org_attr;
    col = piscol(bw.*.vtcur);
    if (col >= @as(off_t, bw.*.width)) {
        if (bw.*.b.*.eof.*.line != bw.*.vtcur.*.line) {
            _ = pnextl(bw.*.vtcur);
        } else {
            _ = pnextl(bw.*.vtcur);
            _ = binsc(bw.*.vtcur, '\n');
            _ = pgetc(bw.*.vtcur);
        }
    }
    cur_attr = pcurattr(bw.*.vtcur);
    if (piseol(bw.*.vtcur) != 0) {
        if (bw.*.attr != cur_attr) {
            psetattr(bw.*.vtcur, bw.*.attr, cur_attr, 1);
            cur_attr = bw.*.attr;
        }
        _ = binsc(bw.*.vtcur, c);
        _ = pgetc(bw.*.vtcur);
    } else {
        var q: [*c]P = undefined;
        _ = &q;
        var tcol: off_t = piscol(bw.*.vtcur);
        _ = &tcol;
        q = pdup(bw.*.vtcur, "vt_type");
        _ = pcol(q, tcol + @as(off_t, 1));
        org_attr = pcurattr(q);
        bdel(bw.*.vtcur, q);
        prm(q);
        if (bw.*.attr != cur_attr) {
            psetattr(bw.*.vtcur, bw.*.attr, cur_attr, 1);
            cur_attr = bw.*.attr;
        }
        _ = binsc(bw.*.vtcur, c);
        _ = pgetc(bw.*.vtcur);
        psetattr(bw.*.vtcur, org_attr, cur_attr, 0);
    }
}
pub fn vt_lf(arg_bw: [*c]VT) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var col: off_t = piscol(bw.*.vtcur);
    _ = &col;
    if (bw.*.vtcur.*.line == ((bw.*.top.*.line + @as(off_t, bw.*.regn_bot)) - @as(off_t, 1))) {
        if (bw.*.regn_top != @as(ptrdiff_t, 0)) {
            var p_1: [*c]P = pdup(bw.*.vtcur, "vt_lf");
            _ = &p_1;
            var q: [*c]P = undefined;
            _ = &q;
            _ = pline(p_1, bw.*.top.*.line + @as(off_t, bw.*.regn_top));
            q = pdup(p_1, "vt_lf");
            _ = pnextl(q);
            bdel(p_1, q);
            prm(q);
            prm(p_1);
        } else {
            _ = pnextl(bw.*.top);
            vt_scrdn();
        }
        if (!(pnextl(bw.*.vtcur) != null)) {
            _ = binsc(bw.*.vtcur, '\n');
            _ = pgetc(bw.*.vtcur);
        } else {
            _ = p_goto_bol(bw.*.vtcur);
            _ = binsc(bw.*.vtcur, '\n');
        }
    } else {
        if (!(pnextl(bw.*.vtcur) != null)) {
            _ = binsc(bw.*.vtcur, '\n');
            _ = pgetc(bw.*.vtcur);
        }
    }
    _ = pcol(bw.*.vtcur, col);
    pfill(bw.*.vtcur, col, ' ');
    if (bw.*.vtcur.*.line >= (bw.*.top.*.line + @as(off_t, bw.*.height))) {
        _ = pline(bw.*.top, (bw.*.vtcur.*.line - @as(off_t, bw.*.height)) + @as(off_t, 1));
    }
}
pub fn vt_insert_spaces(arg_bw: [*c]VT, arg_n: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var n = arg_n;
    _ = &n;
    while ((blk: {
        const ref = &n;
        const tmp = ref.*;
        ref.* -= 1;
        break :blk tmp;
    }) != 0) {
        _ = binsc(bw.*.vtcur, ' ');
    }
}
pub fn vt_cr(arg_bw: [*c]VT) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    _ = p_goto_bol(bw.*.vtcur);
}
pub fn vt_tab(arg_bw: [*c]VT) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    if (piseol(bw.*.vtcur) != 0) {
        _ = binsc(bw.*.vtcur, '\t');
        _ = pgetc(bw.*.vtcur);
    } else {
        var col: off_t = piscol(bw.*.vtcur);
        _ = &col;
        col += bw.*.vtcur.*.b.*.o.tab - @rem(col, bw.*.vtcur.*.b.*.o.tab);
        _ = pcol(bw.*.vtcur, col);
        pfill(bw.*.vtcur, col, ' ');
    }
}
pub fn vt_left(arg_bw: [*c]VT, arg_n: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var n = arg_n;
    _ = &n;
    var col: off_t = piscol(bw.*.vtcur);
    _ = &col;
    if (@as(off_t, n) > col) {
        col = 0;
    } else {
        col -= n;
    }
    _ = pcol(bw.*.vtcur, col);
    pfill(bw.*.vtcur, col, ' ');
}
pub fn vt_right(arg_bw: [*c]VT, arg_n: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var n = arg_n;
    _ = &n;
    var col: off_t = piscol(bw.*.vtcur);
    _ = &col;
    col += n;
    if (col >= @as(off_t, bw.*.width)) {
        col = bw.*.width - @as(ptrdiff_t, 1);
    }
    _ = pcol(bw.*.vtcur, col);
    pfill(bw.*.vtcur, col, ' ');
}
pub fn vt_up(arg_bw: [*c]VT, arg_n: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var n = arg_n;
    _ = &n;
    var line: off_t = bw.*.vtcur.*.line;
    _ = &line;
    var col: off_t = piscol(bw.*.vtcur);
    _ = &col;
    line -= n;
    if (line < bw.*.top.*.line) {
        line = bw.*.top.*.line;
    }
    _ = pline(bw.*.vtcur, line);
    _ = pcol(bw.*.vtcur, col);
    pfill(bw.*.vtcur, col, ' ');
}
pub fn vt_reverse_lf(arg_bw: [*c]VT) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    if (bw.*.vtcur.*.line >= bw.*.top.*.line) {
        if (bw.*.vtcur.*.line != (bw.*.top.*.line + @as(off_t, bw.*.regn_top))) {
            vt_up(bw, 1);
        } else {
            var col: off_t = undefined;
            _ = &col;
            if (bw.*.vtcur.*.b.*.eof.*.line >= ((bw.*.top.*.line + @as(off_t, bw.*.regn_bot)) - @as(off_t, 1))) {
                var q: [*c]P = pdup(bw.*.vtcur, "vt_reverse_lf");
                _ = &q;
                var r: [*c]P = undefined;
                _ = &r;
                _ = pline(q, (bw.*.top.*.line + @as(off_t, bw.*.regn_bot)) - @as(off_t, 1));
                r = pdup(q, "vt_reverse_lf1");
                _ = pnextl(r);
                bdel(q, r);
                prm(r);
                prm(q);
            }
            col = piscol(bw.*.vtcur);
            _ = p_goto_bol(bw.*.vtcur);
            _ = binsc(bw.*.vtcur, '\n');
            _ = pcol(bw.*.vtcur, col);
            pfill(bw.*.vtcur, col, ' ');
        }
    }
}
pub fn vt_down(arg_bw: [*c]VT, arg_n: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var n = arg_n;
    _ = &n;
    var line: off_t = bw.*.vtcur.*.line;
    _ = &line;
    var col: off_t = piscol(bw.*.vtcur);
    _ = &col;
    line += n;
    if (line >= (bw.*.top.*.line + @as(off_t, bw.*.height))) {
        line = (bw.*.top.*.line + @as(off_t, bw.*.height)) - @as(off_t, 1);
    }
    while (line > bw.*.b.*.eof.*.line) {
        _ = p_goto_eof(bw.*.vtcur);
        _ = binsc(bw.*.vtcur, '\n');
        _ = pgetc(bw.*.vtcur);
    }
    _ = pline(bw.*.vtcur, line);
    _ = pcol(bw.*.vtcur, col);
    pfill(bw.*.vtcur, col, ' ');
}
pub fn vt_col(arg_bw: [*c]VT, arg_col: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var col = arg_col;
    _ = &col;
    _ = pcol(bw.*.vtcur, col);
    pfill(bw.*.vtcur, col, ' ');
}
pub fn vt_row(arg_bw: [*c]VT, arg_row: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var row = arg_row;
    _ = &row;
    var col: off_t = piscol(bw.*.vtcur);
    _ = &col;
    var line: off_t = bw.*.top.*.line + @as(off_t, row);
    _ = &line;
    if (line >= (bw.*.top.*.line + @as(off_t, bw.*.height))) {
        line = (bw.*.top.*.line + @as(off_t, bw.*.height)) - @as(off_t, 1);
    }
    while (line > bw.*.b.*.eof.*.line) {
        _ = p_goto_eof(bw.*.vtcur);
        _ = binsc(bw.*.vtcur, '\n');
        _ = pgetc(bw.*.vtcur);
    }
    _ = pline(bw.*.vtcur, line);
    _ = pcol(bw.*.vtcur, col);
    pfill(bw.*.vtcur, col, ' ');
}
pub fn vt_erase_eos(arg_bw: [*c]VT) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var p_1: [*c]P = pdup(bw.*.b.*.eof, "vt_erase_line");
    _ = &p_1;
    bdel(bw.*.vtcur, p_1);
    prm(p_1);
}
pub fn vt_erase_bos(arg_bw: [*c]VT) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
}
pub fn vt_erase_screen(arg_bw: [*c]VT) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var li: off_t = bw.*.vtcur.*.line;
    _ = &li;
    var col: off_t = piscol(bw.*.vtcur);
    _ = &col;
    _ = pline(bw.*.vtcur, bw.*.top.*.line);
    bdel(bw.*.vtcur, bw.*.b.*.eof);
    while (bw.*.vtcur.*.line < li) {
        _ = binsc(bw.*.vtcur, '\n');
        _ = pgetc(bw.*.vtcur);
    }
    _ = pcol(bw.*.vtcur, col);
    pfill(bw.*.vtcur, col, ' ');
}
pub fn vt_erase_line(arg_bw: [*c]VT) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var p_1: [*c]P = pdup(bw.*.vtcur, "vt_erase_line");
    _ = &p_1;
    var col: off_t = piscol(bw.*.vtcur);
    _ = &col;
    _ = p_goto_bol(bw.*.vtcur);
    _ = pnextl(p_1);
    if (bw.*.vtcur.*.byte == p_1.*.byte) {} else {
        bdel(bw.*.vtcur, p_1);
    }
    prm(p_1);
    _ = pcol(bw.*.vtcur, col);
    pfill(bw.*.vtcur, col, ' ');
}
pub fn vt_erase_bol(arg_bw: [*c]VT) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
}
pub fn vt_erase_eol(arg_bw: [*c]VT) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var p_1: [*c]P = p_goto_eol(pdup(bw.*.vtcur, "vt_erase_eol"));
    _ = &p_1;
    if (bw.*.vtcur.*.byte == p_1.*.byte) {} else {
        bdel(bw.*.vtcur, p_1);
    }
    prm(p_1);
}
pub fn vt_insert_lines(arg_bw: [*c]VT, arg_n: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var n = arg_n;
    _ = &n;
    if (bw.*.vtcur.*.line < (bw.*.top.*.line + @as(off_t, bw.*.regn_bot))) while ((blk: {
        const ref = &n;
        const tmp = ref.*;
        ref.* -= 1;
        break :blk tmp;
    }) != 0) {
        var p_1: [*c]P = pdup(bw.*.vtcur, "vt_insert_lines");
        _ = &p_1;
        _ = p_goto_bol(p_1);
        _ = binsc(p_1, '\n');
        _ = pline(p_1, bw.*.top.*.line + @as(off_t, bw.*.regn_bot));
        if (p_1.*.line == (bw.*.top.*.line + @as(off_t, bw.*.regn_bot))) {
            var q: [*c]P = pdup(p_1, "vt_insert_lines");
            _ = &q;
            if (pnextl(q) != null) {
                bdel(p_1, q);
            }
            prm(q);
        }
        prm(p_1);
    };
}
pub fn vt_delete_lines(arg_bw: [*c]VT, arg_n: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var n = arg_n;
    _ = &n;
    if (bw.*.vtcur.*.line < (bw.*.top.*.line + @as(off_t, bw.*.regn_bot))) while ((blk: {
        const ref = &n;
        const tmp = ref.*;
        ref.* -= 1;
        break :blk tmp;
    }) != 0) {
        var col: off_t = piscol(bw.*.vtcur);
        _ = &col;
        var a: [*c]P = pdup(bw.*.vtcur, "vt_delete_lines");
        _ = &a;
        var p_1: [*c]P = undefined;
        _ = &p_1;
        var q: [*c]P = undefined;
        _ = &q;
        _ = pline(a, bw.*.top.*.line + @as(off_t, bw.*.regn_bot));
        if (a.*.line == (bw.*.top.*.line + @as(off_t, bw.*.regn_bot))) {
            _ = binsc(a, '\n');
        }
        prm(a);
        p_1 = pdup(bw.*.vtcur, "vt_delete_lines");
        q = pdup(p_1, "vt_delete_lines");
        _ = p_goto_bol(p_1);
        if (pnextl(q) != null) {
            bdel(p_1, q);
        }
        prm(q);
        prm(p_1);
        _ = pcol(bw.*.vtcur, col);
    };
}
pub fn vt_delete_chars(arg_bw: [*c]VT, arg_n: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var n = arg_n;
    _ = &n;
    while ((n != 0) and (@as(ptrdiff_t, @intFromBool(!(piseol(bw.*.vtcur) != 0))) != 0)) {
        var q: [*c]P = pdup(bw.*.vtcur, "vt_delete_chars");
        _ = &q;
        _ = pgetc(q);
        bdel(bw.*.vtcur, q);
        prm(q);
        n -= 1;
    }
}
pub fn vt_scroll_up(arg_bw: [*c]VT, arg_n: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var n = arg_n;
    _ = &n;
}
pub fn vt_scroll_down(arg_bw: [*c]VT, arg_n: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var n = arg_n;
    _ = &n;
}
pub fn vt_erase_chars(arg_bw: [*c]VT, arg_n: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var n = arg_n;
    _ = &n;
}
pub fn vt_set_region(arg_bw: [*c]VT, arg_top: ptrdiff_t, arg_bot: ptrdiff_t) callconv(.c) void {
    var bw = arg_bw;
    _ = &bw;
    var top = arg_top;
    _ = &top;
    var bot = arg_bot;
    _ = &bot;
    if (((top < bw.*.height) and (bot < bw.*.height)) and (top <= bot)) {
        bw.*.regn_top = top;
        bw.*.regn_bot = bot + @as(ptrdiff_t, 1);
    }
}
pub fn vt_arg(arg_vt: [*c]VT, arg_argn: ptrdiff_t, arg_dflt: ptrdiff_t) callconv(.c) ptrdiff_t {
    var vt = arg_vt;
    _ = &vt;
    var argn = arg_argn;
    _ = &argn;
    var dflt = arg_dflt;
    _ = &dflt;
    while (vt.*.argc <= argn) {
        @as([*]ptrdiff_t, @ptrCast(&vt.*.argv))[
            @bitCast(@as(isize, @intCast(blk: {
                const ref = &vt.*.argc;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            })))
        ] = 0;
    }
    if (!(@as([*]ptrdiff_t, @ptrCast(&vt.*.argv))[@bitCast(@as(isize, @intCast(argn)))] != 0)) {
        @as([*]ptrdiff_t, @ptrCast(&vt.*.argv))[@bitCast(@as(isize, @intCast(argn)))] = dflt;
    }
    return @as([*]ptrdiff_t, @ptrCast(&vt.*.argv))[@bitCast(@as(isize, @intCast(argn)))];
}
pub export fn vt_data(arg_vt: [*c]VT, arg_indat: [*c][*c]u8, arg_insiz: [*c]ptrdiff_t) [*c]MACRO {
    var vt = arg_vt;
    _ = &vt;
    var indat = arg_indat;
    _ = &indat;
    var insiz = arg_insiz;
    _ = &insiz;
    var dat: [*c]u8 = indat.*;
    _ = &dat;
    var siz: ptrdiff_t = insiz.*;
    _ = &siz;
    while ((blk: {
        const ref = &siz;
        const tmp = ref.*;
        ref.* -= 1;
        break :blk tmp;
    }) != 0) {
        var c: u8 = (blk: {
            const ref = &dat;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).*;
        _ = &c;
        while (true) {
            switch (vt.*.state) {
                @as(enum_vt_state, vt_idle) => {
                    {
                        while (true) {
                            switch (@as(c_int, @as(u8, c))) {
                                @as(c_int, 5) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 7) => {
                                    {
                                        vt_beep(vt);
                                        break;
                                    }
                                },
                                @as(c_int, 8) => {
                                    {
                                        vt_left(vt, 1);
                                        break;
                                    }
                                },
                                @as(c_int, 9) => {
                                    {
                                        vt_tab(vt);
                                        break;
                                    }
                                },
                                @as(c_int, 10) => {
                                    {
                                        vt_lf(vt);
                                        break;
                                    }
                                },
                                @as(c_int, 11) => {
                                    {
                                        vt_lf(vt);
                                        break;
                                    }
                                },
                                @as(c_int, 12) => {
                                    {
                                        vt_lf(vt);
                                        break;
                                    }
                                },
                                @as(c_int, 13) => {
                                    {
                                        vt_cr(vt);
                                        break;
                                    }
                                },
                                @as(c_int, 14) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 15) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 27) => {
                                    {
                                        vt.*.bufx = 0;
                                        @as([*]u8, @ptrCast(&vt.*.buf))[
                                            @bitCast(@as(isize, @intCast(blk: {
                                                const ref = &vt.*.bufx;
                                                const tmp = ref.*;
                                                ref.* += 1;
                                                break :blk tmp;
                                            })))
                                        ] = 27;
                                        vt.*.state = vt_esc;
                                        break;
                                    }
                                },
                                @as(c_int, 132) => {
                                    {
                                        vt_lf(vt);
                                        break;
                                    }
                                },
                                @as(c_int, 133) => {
                                    {
                                        vt_cr(vt);
                                        vt_lf(vt);
                                        break;
                                    }
                                },
                                @as(c_int, 136) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 141) => {
                                    {
                                        vt_reverse_lf(vt);
                                        break;
                                    }
                                },
                                @as(c_int, 142) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 143) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 144) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 150) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 151) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 152) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 154) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 155) => {
                                    {
                                        vt.*.argc = 0;
                                        @as([*]ptrdiff_t, @ptrCast(&vt.*.argv))[@as(c_int, 0)] = 0;
                                        vt.*.state = vt_args;
                                        vt.*.bufx = 0;
                                        @as([*]u8, @ptrCast(&vt.*.buf))[
                                            @bitCast(@as(isize, @intCast(blk: {
                                                const ref = &vt.*.bufx;
                                                const tmp = ref.*;
                                                ref.* += 1;
                                                break :blk tmp;
                                            })))
                                        ] = 27;
                                        @as([*]u8, @ptrCast(&vt.*.buf))[
                                            @bitCast(@as(isize, @intCast(blk: {
                                                const ref = &vt.*.bufx;
                                                const tmp = ref.*;
                                                ref.* += 1;
                                                break :blk tmp;
                                            })))
                                        ] = '[';
                                        break;
                                    }
                                },
                                @as(c_int, 156) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 157) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 158) => {
                                    {
                                        break;
                                    }
                                },
                                @as(c_int, 159) => {
                                    {
                                        break;
                                    }
                                },
                                else => {
                                    {
                                        if (locale_map.*.type != 0) {
                                            var ch: c_int = utf8_decode(&vt.*.utf8_sm, c);
                                            _ = &ch;
                                            if (ch >= @as(c_int, 0)) {
                                                vt_type(vt, ch);
                                            } else if (ch == -@as(c_int, 257)) {
                                                vt.*.state = vt_utf;
                                            }
                                        } else {
                                            if (!((@as(c_int, c) >= @as(c_int, 0)) and (@as(c_int, c) < @as(c_int, 32)))) {
                                                vt_type(vt, c);
                                            }
                                        }
                                        break;
                                    }
                                },
                            }
                            break;
                        }
                        break;
                    }
                },
                @as(enum_vt_state, vt_utf) => {
                    {
                        var ch: c_int = utf8_decode(&vt.*.utf8_sm, c);
                        _ = &ch;
                        if (ch >= @as(c_int, 0)) {
                            vt_type(vt, ch);
                            vt.*.state = vt_idle;
                        } else if (ch == -@as(c_int, 257)) {
                            vt.*.state = vt_utf;
                        } else {
                            vt.*.state = vt_idle;
                        }
                        break;
                    }
                },
                @as(enum_vt_state, vt_esc) => {
                    {
                        if (@as(c_int, c) == @as(c_int, 'c')) {
                            vt.*.state = vt_idle;
                            break;
                        } else if (@as(c_int, c) == @as(c_int, 'M')) {
                            vt_reverse_lf(vt);
                            vt.*.state = vt_idle;
                            break;
                        } else if (@as(c_int, c) == @as(c_int, 'D')) {
                            vt_lf(vt);
                            vt.*.state = vt_idle;
                            break;
                        } else if (@as(c_int, c) == @as(c_int, 'E')) {
                            vt_cr(vt);
                            vt_lf(vt);
                            vt.*.state = vt_idle;
                            break;
                        } else if (@as(c_int, c) == @as(c_int, 'F')) {
                            break;
                        } else if (@as(c_int, c) == @as(c_int, 'H')) {
                            break;
                        } else if (@as(c_int, c) == @as(c_int, '7')) {
                            break;
                        } else if (@as(c_int, c) == @as(c_int, '8')) {
                            break;
                        } else if (@as(c_int, c) == @as(c_int, ']')) {
                            vt.*.state = vt_osc;
                        } else if (@as(c_int, c) == @as(c_int, '[')) {
                            vt.*.argc = 0;
                            @as([*]ptrdiff_t, @ptrCast(&vt.*.argv))[@as(c_int, 0)] = 0;
                            vt.*.state = vt_args;
                            @as([*]u8, @ptrCast(&vt.*.buf))[
                                @bitCast(@as(isize, @intCast(blk: {
                                    const ref = &vt.*.bufx;
                                    const tmp = ref.*;
                                    ref.* += 1;
                                    break :blk tmp;
                                })))
                            ] = '[';
                        } else if (@as(c_int, c) == @as(c_int, '{')) {
                            vt.*.bufx = 0;
                            vt.*.state = vt_cmd;
                        } else {
                            vt.*.state = vt_idle;
                        }
                        break;
                    }
                },
                @as(enum_vt_state, vt_osc) => {
                    {
                        if (((@as(c_int, c) == @as(c_int, 7)) or (@as(c_int, c) == @as(c_int, 13))) or (@as(c_int, c) == @as(c_int, 10))) {
                            vt.*.state = vt_idle;
                        } else if (@as(c_int, c) == @as(c_int, 27)) {
                            vt.*.state = vt_osce;
                        }
                        break;
                    }
                },
                @as(enum_vt_state, vt_osce) => {
                    {
                        if (@as(c_int, c) == @as(c_int, '\\')) {
                            vt.*.state = vt_idle;
                        } else if (@as(c_int, c) == @as(c_int, 27)) {
                            vt.*.state = vt_osce;
                        } else {
                            vt.*.state = vt_osc;
                        }
                        break;
                    }
                },
                @as(enum_vt_state, vt_cmd) => {
                    {
                        if (@as(c_int, c) != @as(c_int, '}')) {
                            if (vt.*.bufx < (@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(vt.*.buf)))))) - @as(ptrdiff_t, 1))) {
                                @as([*]u8, @ptrCast(&vt.*.buf))[
                                    @bitCast(@as(isize, @intCast(blk: {
                                        const ref = &vt.*.bufx;
                                        const tmp = ref.*;
                                        ref.* += 1;
                                        break :blk tmp;
                                    })))
                                ] = c;
                            }
                        } else {
                            if (@as(c_int, c) == @as(c_int, '}')) {
                                var m: [*c]MACRO = undefined;
                                _ = &m;
                                var rtn: ptrdiff_t = undefined;
                                _ = &rtn;
                                @as([*]u8, @ptrCast(&vt.*.buf))[@bitCast(@as(isize, @intCast(vt.*.bufx)))] = 0;
                                m = mparse(null, @ptrCast(@alignCast(&vt.*.buf)), &rtn, 1);
                                if (rtn >= @as(ptrdiff_t, 0)) {
                                    insiz.* = siz;
                                    indat.* = dat;
                                    vt.*.state = vt_idle;
                                    return m;
                                }
                                rmmacro(m);
                            }
                            vt.*.state = vt_idle;
                        }
                        break;
                    }
                },
                @as(enum_vt_state, vt_args) => {
                    {
                        if (vt.*.bufx < (@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(vt.*.buf)))))) - @as(ptrdiff_t, 1))) {
                            @as([*]u8, @ptrCast(&vt.*.buf))[
                                @bitCast(@as(isize, @intCast(blk: {
                                    const ref = &vt.*.bufx;
                                    const tmp = ref.*;
                                    ref.* += 1;
                                    break :blk tmp;
                                })))
                            ] = c;
                        }
                        if ((@as(c_int, c) >= @as(c_int, '0')) and (@as(c_int, c) <= @as(c_int, '9'))) {
                            if (vt.*.argc < @as(ptrdiff_t, MAXARGS)) {
                                @as([*]ptrdiff_t, @ptrCast(&vt.*.argv))[@bitCast(@as(isize, @intCast(vt.*.argc)))] = ((@as([*]ptrdiff_t, @ptrCast(&vt.*.argv))[@bitCast(@as(isize, @intCast(vt.*.argc)))] * @as(ptrdiff_t, 10)) + @as(ptrdiff_t, @as(c_int, c))) - @as(ptrdiff_t, '0');
                            }
                        } else if (@as(c_int, c) == @as(c_int, ';')) {
                            if (vt.*.argc < @as(ptrdiff_t, MAXARGS)) {
                                vt.*.argc += 1;
                                @as([*]ptrdiff_t, @ptrCast(&vt.*.argv))[@bitCast(@as(isize, @intCast(vt.*.argc)))] = 0;
                            }
                        } else if (@as(c_int, c) == @as(c_int, '?')) {} else {
                            vt.*.state = vt_idle;
                            if (vt.*.argc < @as(ptrdiff_t, MAXARGS)) {
                                vt.*.argc += 1;
                            }
                            while (true) {
                                switch (@as(c_int, c)) {
                                    @as(c_int, '@') => {
                                        {
                                            vt_insert_spaces(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'A') => {
                                        {
                                            vt_up(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'B') => {
                                        {
                                            vt_down(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'C') => {
                                        {
                                            vt_right(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'D') => {
                                        {
                                            vt_left(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'E') => {
                                        {
                                            vt_cr(vt);
                                            vt_down(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'F') => {
                                        {
                                            vt_cr(vt);
                                            vt_up(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'G') => {
                                        {
                                            vt_col(vt, vt_arg(vt, 0, 1) - @as(ptrdiff_t, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'f'), @as(c_int, 'H') => {
                                        {
                                            vt_row(vt, vt_arg(vt, 0, 1) - @as(ptrdiff_t, 1));
                                            vt_col(vt, vt_arg(vt, 1, 1) - @as(ptrdiff_t, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'J') => {
                                        {
                                            while (true) {
                                                switch (vt_arg(vt, 0, 0)) {
                                                    @as(ptrdiff_t, 0) => {
                                                        {
                                                            vt_erase_eos(vt);
                                                            break;
                                                        }
                                                    },
                                                    @as(ptrdiff_t, 1) => {
                                                        {
                                                            vt_erase_bos(vt);
                                                            break;
                                                        }
                                                    },
                                                    @as(ptrdiff_t, 2) => {
                                                        {
                                                            vt_erase_screen(vt);
                                                            break;
                                                        }
                                                    },
                                                    else => {},
                                                }
                                                break;
                                            }
                                            break;
                                        }
                                    },
                                    @as(c_int, 'K') => {
                                        {
                                            while (true) {
                                                switch (vt_arg(vt, 0, 0)) {
                                                    @as(ptrdiff_t, 0) => {
                                                        {
                                                            vt_erase_eol(vt);
                                                            break;
                                                        }
                                                    },
                                                    @as(ptrdiff_t, 1) => {
                                                        {
                                                            vt_erase_bol(vt);
                                                            break;
                                                        }
                                                    },
                                                    @as(ptrdiff_t, 2) => {
                                                        {
                                                            vt_erase_line(vt);
                                                            break;
                                                        }
                                                    },
                                                    else => {},
                                                }
                                                break;
                                            }
                                            break;
                                        }
                                    },
                                    @as(c_int, 'L') => {
                                        {
                                            vt_insert_lines(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'M') => {
                                        {
                                            vt_delete_lines(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'P') => {
                                        {
                                            vt_delete_chars(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'S') => {
                                        {
                                            vt_scroll_up(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'T') => {
                                        {
                                            vt_scroll_down(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'X') => {
                                        {
                                            vt_erase_chars(vt, vt_arg(vt, 0, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'd') => {
                                        {
                                            vt_row(vt, vt_arg(vt, 0, 1) - @as(ptrdiff_t, 1));
                                            break;
                                        }
                                    },
                                    @as(c_int, 'h') => {
                                        {
                                            break;
                                        }
                                    },
                                    @as(c_int, 'k') => {
                                        {
                                            break;
                                        }
                                    },
                                    @as(c_int, 'l') => {
                                        {
                                            break;
                                        }
                                    },
                                    @as(c_int, 'm') => {
                                        {
                                            var x: ptrdiff_t = undefined;
                                            _ = &x;
                                            var y: ptrdiff_t = undefined;
                                            _ = &y;
                                            {
                                                y = 0;
                                                while (y != vt.*.argc) : (y += 1) {
                                                    x = vt_arg(vt, y, 0);
                                                    if (x == @as(ptrdiff_t, 0)) {
                                                        vt.*.attr = 0;
                                                    } else if (x == @as(ptrdiff_t, 1)) {
                                                        vt.*.attr |= BOLD;
                                                    } else if (x == @as(ptrdiff_t, 21)) {
                                                        vt.*.attr &= ~BOLD;
                                                    } else if (x == @as(ptrdiff_t, 4)) {
                                                        vt.*.attr |= UNDERLINE;
                                                    } else if (x == @as(ptrdiff_t, 24)) {
                                                        vt.*.attr &= ~UNDERLINE;
                                                    } else if (x == @as(ptrdiff_t, 7)) {
                                                        vt.*.attr |= INVERSE;
                                                    } else if (x == @as(ptrdiff_t, 27)) {
                                                        vt.*.attr &= ~INVERSE;
                                                    } else if ((x >= @as(ptrdiff_t, 30)) and (x <= @as(ptrdiff_t, 37))) {
                                                        vt.*.attr = (vt.*.attr & ~(@as(c_int, 1023) << @intCast(FG_SHIFT))) | ((@as(c_int, 256) << @intCast(FG_SHIFT)) | (@as(c_int, @truncate(x - @as(ptrdiff_t, 30))) << @intCast(FG_SHIFT)));
                                                    } else if (x == @as(ptrdiff_t, 39)) {
                                                        vt.*.attr &= ~(@as(c_int, 1023) << @intCast(FG_SHIFT));
                                                    } else if (x == @as(ptrdiff_t, 49)) {
                                                        vt.*.attr &= ~(@as(c_int, 1023) << @intCast(BG_SHIFT));
                                                    } else if ((x >= @as(ptrdiff_t, 40)) and (x <= @as(ptrdiff_t, 47))) {
                                                        vt.*.attr = (vt.*.attr & ~(@as(c_int, 1023) << @intCast(BG_SHIFT))) | ((@as(c_int, 256) << @intCast(BG_SHIFT)) | (@as(c_int, @truncate(x - @as(ptrdiff_t, 40))) << @intCast(BG_SHIFT)));
                                                    }
                                                }
                                            }
                                            break;
                                        }
                                    },
                                    @as(c_int, 'n') => {
                                        {
                                            break;
                                        }
                                    },
                                    @as(c_int, 'r') => {
                                        {
                                            if (vt.*.argc < @as(ptrdiff_t, 2)) {
                                                vt_set_region(vt, 0, vt.*.height - @as(ptrdiff_t, 1));
                                            } else {
                                                vt_set_region(vt, vt_arg(vt, 0, 1) - @as(ptrdiff_t, 1), vt_arg(vt, 1, vt.*.height) - @as(ptrdiff_t, 1));
                                            }
                                            vt_row(vt, 0);
                                            vt_col(vt, 0);
                                            break;
                                        }
                                    },
                                    @as(c_int, 's') => {
                                        {
                                            break;
                                        }
                                    },
                                    @as(c_int, 'u') => {
                                        {
                                            break;
                                        }
                                    },
                                    else => {},
                                }
                                break;
                            }
                        }
                        break;
                    }
                },
                else => {},
            }
            break;
        }
    }
    return null;
}
