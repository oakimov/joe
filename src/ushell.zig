//! Path A live port of JOE shell-window commands (`joe/ushell.c`).
//!
//! JOE `ushell.h` ABI lives here (bknd/vtbknd/run/build/grep/killpid,
//! `cstart`, `vt_scrdn`, history buffers). `joe/ushell.c` is a tombstone.

const std = @import("std");
const gap_types = @import("gapbuffer/types.zig");

const GapP = gap_types.P;
const GapB = gap_types.B;
const GapOptions = gap_types.OPTIONS;
const NO_MORE_DATA = gap_types.NO_MORE_DATA;

const TYPETW: c_int = 0x0100;
const TYPEPW: c_int = 0x0200;
const SHELL_TYPE_DUMB: c_int = 0;
const SHELL_TYPE_VT: c_int = 1;
const SHELL_TYPE_RAW: c_int = 2;
const PWFLAG_COMMAND: c_int = 8;
const YES_CODE: c_int = -10;

/// System rc dir from `-Djoerc=` (empty → relative shell scripts / builtins).
const JOERC = @import("build_options").joerc;

export var runhist: ?*GapB = null;
export var buildhist: ?*GapB = null;
export var grephist: ?*GapB = null;

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

const ScreenRec = extern struct {
    t: ?*anyopaque,
    wind: isize,
    topwin: ?*WinRec,
    curwin: ?*WinRec,
    w: isize,
    h: isize,
};

const Utf8SmRec = extern struct {
    buf: [8]u8,
    ptr: isize,
    state: c_int,
    accu: c_int,
};

const VtRec = extern struct {
    state: c_int,
    buf: [1024]u8,
    bufx: isize,
    argv: [3]isize,
    argc: isize,
    top: ?*GapP,
    height: isize,
    width: isize,
    regn_top: isize,
    regn_bot: isize,
    vtcur: ?*GapP,
    b: ?*GapB,
    kbd: ?*anyopaque,
    attr: c_int,
    utf8_sm: Utf8SmRec,
};

const KbdRec = extern struct {
    curmap: ?*anyopaque,
    topmap: ?*anyopaque,
    seq: [16]c_int,
    x: isize,
};

const MpxRec = extern struct {
    ackfd: c_int,
    kpid: c_int,
    pid: c_int,
    func: ?*const fn (?*anyopaque, [*c]u8, isize) callconv(.c) void,
    object: ?*anyopaque,
    die: ?*const fn (?*anyopaque) callconv(.c) void,
    dieobj: ?*anyopaque,
};

comptime {
    if (@sizeOf(WinRec) != 200) @compileError("WinRec size mismatch");
    if (@sizeOf(BwRec) != 488) @compileError("BwRec size mismatch");
    if (@sizeOf(GapP) != 112) @compileError("GapP size mismatch");
    if (@sizeOf(ScreenRec) != 48) @compileError("ScreenRec size mismatch");
    if (@sizeOf(VtRec) != 1168) @compileError("VtRec size mismatch");
}

extern var maint: ?*ScreenRec;
extern var shell_kbd: ?*KbdRec;
extern var locale_map: ?*anyopaque;
extern var yes_key: [*c]const u8;
extern var obuf: [*c]u8;
extern var obufp: isize;
extern var obufsiz: isize;

extern fn pdup(p: ?*GapP, tr: [*:0]const u8) ?*GapP;
extern fn prm(p: ?*GapP) void;
extern fn pset(n: ?*GapP, p: ?*GapP) ?*GapP;
extern fn pnextl(p: ?*GapP) ?*GapP;
extern fn pline(p: ?*GapP, line: i64) ?*GapP;
extern fn pgoto(p: ?*GapP, loc: i64) ?*GapP;
extern fn piscol(p: ?*GapP) i64;
extern fn pgetc(p: ?*GapP) c_int;
extern fn prgetc(p: ?*GapP) c_int;
extern fn bdel(from: ?*GapP, to: ?*GapP) void;
extern fn binsm(p: ?*GapP, blk: ?*const anyopaque, amnt: isize) ?*GapP;
extern fn modify_logic(bw: ?*anyopaque, b: ?*GapB) c_int;
extern fn msgnw(w: ?*anyopaque, s: [*c]const u8) void;
extern fn my_gettext(s: [*c]const u8) [*c]const u8;
extern fn dofollows() void;
extern fn undomark() void;
extern fn edupd(flg: c_int) void;
extern fn nscrlup(t: ?*anyopaque, top: isize, bot: isize, amnt: isize) void;
extern fn ttflsh() c_int;
extern fn load_syntax(name: [*c]const u8) ?*anyopaque;
extern fn vtmaster(t: ?*anyopaque, b: ?*GapB) ?*BwRec;
extern fn mkvt(b: ?*GapB, top: ?*GapP, height: isize, width: isize) ?*VtRec;
extern fn vtrm(vt: ?*VtRec) void;
extern fn vt_data(vt: ?*VtRec, indat: *[*c]u8, insiz: *isize) ?*anyopaque;
extern fn exmacro(m: ?*anyopaque, u: c_int, k: c_int) c_int;
extern fn rmmacro(m: ?*anyopaque) void;
extern fn parserrb(b: ?*GapB) c_int;
extern fn parseone_grep(map: ?*anyopaque, s: [*c]const u8, rtn_name: *[*c]u8, rtn_line: *i64) void;
extern fn file_exists(path: [*c]const u8) c_int;
extern fn kmap_empty(k: ?*anyopaque) c_int;
extern fn kmap_getcontext(name: [*:0]const u8) ?*anyopaque;
extern fn yncheck(set: [*c]const u8, ch: c_int) c_int;
extern fn cmplt_command(bw: ?*anyopaque, k: c_int) c_int;
extern fn uuparw(w: ?*anyopaque, k: c_int) c_int;
extern fn u_goto_eol(w: ?*anyopaque, k: c_int) c_int;
extern fn slen(s: [*c]const u8) isize;
extern fn vsrm(s: [*c]u8) void;
extern fn vsncpy(vary: [*c]u8, pos: isize, array: [*c]const u8, len: isize) [*c]u8;
extern fn vamk(len: isize) [*c][*c]u8;
extern fn vaadd(vary: [*c][*c]u8, el: [*c]u8) [*c][*c]u8;
extern fn varm(v: [*c][*c]u8) void;
extern fn mpxmk(
    ptyfd: *c_int,
    cmd: [*c]const u8,
    args: [*c][*c]u8,
    func: ?*const fn (?*anyopaque, [*c]u8, isize) callconv(.c) void,
    object: ?*anyopaque,
    die: ?*const fn (?*anyopaque) callconv(.c) void,
    dieobj: ?*anyopaque,
    copy_in: c_int,
    w: isize,
    h: isize,
    use_pipe: c_int,
) ?*MpxRec;
extern fn wmkpw(
    w: ?*anyopaque,
    prompt: [*c]const u8,
    history: ?*?*GapB,
    func: ?*const fn (?*anyopaque, [*c]u8, ?*anyopaque, ?*c_int) callconv(.c) c_int,
    huh: ?[*:0]const u8,
    abrt: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) c_int,
    tab: ?*const fn (?*anyopaque, c_int) callconv(.c) c_int,
    object: ?*anyopaque,
    notify: ?*c_int,
    map: ?*anyopaque,
    file_prompt: c_int,
) ?*BwRec;
extern fn mkqw(
    w: ?*anyopaque,
    prompt: [*c]const u8,
    len: isize,
    func: ?*const fn (?*anyopaque, c_int, ?*anyopaque, ?*c_int) callconv(.c) c_int,
    abrt: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) c_int,
    object: ?*anyopaque,
    notify: ?*c_int,
) ?*anyopaque;

extern fn getenv(name: [*c]const u8) [*c]u8;
extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
extern fn strstr(hay: [*c]const u8, needle: [*c]const u8) [*c]u8;
extern fn close(fd: c_int) c_int;
extern fn write(fd: c_int, buf: ?*const anyopaque, n: usize) isize;
extern fn kill(pid: c_int, sig: c_int) c_int;

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

fn vsLen(s: [*c]u8) isize {
    if (s == null) return 0;
    return (@as([*]align(1) const isize, @ptrCast(s)) - 1)[0];
}

fn zlen(s: [*c]const u8) isize {
    if (s == null) return 0;
    return @intCast(std.mem.len(@as([*:0]const u8, @ptrCast(s))));
}

fn zcmp(a: [*c]const u8, b: [*:0]const u8) c_int {
    return strcmp(a, b);
}

fn zstr(hay: [*c]const u8, needle: [*:0]const u8) bool {
    return strstr(hay, needle) != null;
}

fn ttputcBell() void {
    if (obuf == null) return;
    const idx: usize = @intCast(obufp);
    obuf[idx] = 7;
    obufp += 1;
    if (obufp == obufsiz) _ = ttflsh();
}

fn cdone(obj: ?*anyopaque) callconv(.c) void {
    const b: *GapB = @ptrCast(@alignCast(obj orelse return));
    b.pid = 0;
    _ = close(b.out);
    b.out = -1;
    if (b.vt) |vt_raw| {
        vtrm(@ptrCast(@alignCast(vt_raw)));
        b.vt = null;
    }
}

fn cdoneParse(obj: ?*anyopaque) callconv(.c) void {
    const b: *GapB = @ptrCast(@alignCast(obj orelse return));
    b.pid = 0;
    _ = close(b.out);
    b.out = -1;
    if (b.vt) |vt_raw| {
        vtrm(@ptrCast(@alignCast(vt_raw)));
        b.vt = null;
    }
    _ = parserrb(b);
}

fn ansiall(b: *GapB) void {
    const screen = maint orelse return;
    var w = screen.topwin orelse return;
    while (true) {
        if (w.watom) |wa| {
            if ((wa.what & TYPETW) != 0) {
                if (w.object) |obj| {
                    const bw: *BwRec = @ptrCast(@alignCast(obj));
                    if (bw.b == b) {
                        bw.o.ansi = b.o.ansi;
                        bw.o.syntax = b.o.syntax;
                    }
                }
            }
        }
        w = w.link.next orelse break;
        if (w == screen.topwin) break;
    }
}

fn cready(b: *GapB, byte: i64) void {
    if (b.oldcur) |oc| {
        b.shell_flag = if (oc.byte == byte) 1 else 0;
    } else {
        b.shell_flag = 0;
    }
    const screen = maint orelse return;
    var w = screen.topwin orelse return;
    while (true) {
        if (w.watom) |wa| {
            if ((wa.what & TYPETW) != 0) {
                if (w.object) |obj| {
                    const bw: *BwRec = @ptrCast(@alignCast(obj));
                    if (bw.b == b) {
                        if (bw.cursor) |cur| {
                            bw.shell_flag = if (cur.byte == byte) 1 else 0;
                        } else {
                            bw.shell_flag = 0;
                        }
                    } else {
                        bw.shell_flag = 0;
                    }
                }
            }
        }
        w = w.link.next orelse break;
        if (w == screen.topwin) break;
    }
}

fn cfollow(b: *GapB, vt: ?*VtRec, byte: i64) void {
    var xn: c_int = 0;
    if (vt) |v| {
        if (v.vtcur) |cur| {
            if (piscol(cur) >= v.width) xn = 1;
        }
    }
    if (b.oldcur) |oc| {
        if (b.shell_flag != 0) {
            b.shell_flag = 0;
            _ = pgoto(oc, byte);
            oc.xcol = piscol(oc);
            if (xn != 0) {
                if (vt) |v| oc.xcol = v.width - 1;
            }
        }
    }
    const screen = maint orelse return;
    var w = screen.topwin orelse return;
    while (true) {
        if (w.watom) |wa| {
            if ((wa.what & TYPETW) != 0) {
                if (w.object) |obj| {
                    const bw: *BwRec = @ptrCast(@alignCast(obj));
                    if (bw.shell_flag != 0) {
                        bw.shell_flag = 0;
                        if (bw.cursor) |cur| {
                            _ = pgoto(cur, byte);
                            cur.xcol = piscol(cur);
                            if (xn != 0) {
                                if (vt) |v| cur.xcol = v.width - 1;
                            }
                        }
                        if (vt) |v| {
                            if (bw.top) |top| {
                                if (v.top) |vtop| {
                                    if (top.line != vtop.line) {
                                        if (v.vtcur) |vtcur| {
                                            if ((1 + vtcur.line - vtop.line) <= bw.h)
                                                _ = pline(top, vtop.line);
                                        }
                                    }
                                }
                            }
                        }
                        dofollows();
                    }
                }
            }
        }
        w = w.link.next orelse break;
        if (w == screen.topwin) break;
    }
}

pub export fn vt_scrdn() void {
    const screen = maint orelse return;
    var w = screen.topwin orelse return;
    while (true) {
        if (w.watom) |wa| {
            if ((wa.what & TYPETW) != 0) {
                if (w.object) |obj| {
                    const bw: *BwRec = @ptrCast(@alignCast(obj));
                    if (bw.shell_flag != 0) {
                        _ = pnextl(bw.top);
                        if (bw.parent) |parent| {
                            if (parent.y != -1) {
                                if (parent.t) |t_raw| {
                                    const scr: *ScreenRec = @ptrCast(@alignCast(t_raw));
                                    nscrlup(scr.t, bw.y, bw.y + bw.h, 1);
                                }
                            }
                        }
                    }
                }
            }
        }
        w = w.link.next orelse break;
        if (w == screen.topwin) break;
    }
}

fn cdata(obj: ?*anyopaque, dat_in: [*c]u8, siz_in: isize) callconv(.c) void {
    const b: *GapB = @ptrCast(@alignCast(obj orelse return));
    var dat = dat_in;
    var siz = siz_in;

    if (b.vt) |vt_raw| {
        const vt: *VtRec = @ptrCast(@alignCast(vt_raw));
        while (true) {
            if (vt.vtcur) |vtcur| cready(b, vtcur.byte);
            const m = vt_data(vt, &dat, &siz);
            if (vt.vtcur) |vtcur| cfollow(b, vt, vtcur.byte);
            undomark();
            if (m) |mac| {
                if (maint) |screen| {
                    if (screen.curwin) |cw| {
                        if (cw.watom) |wa| {
                            if ((wa.what & TYPETW) != 0) {
                                if (cw.object) |cobj| {
                                    const cbw: *BwRec = @ptrCast(@alignCast(cobj));
                                    if (cbw.b == b) {
                                        _ = exmacro(mac, 1, NO_MORE_DATA);
                                        edupd(1);
                                    }
                                }
                            }
                        }
                    }
                }
                rmmacro(mac);
                continue;
            }
            break;
        }
    } else if (b.raw != 0) {
        const q = pdup(b.eof, "cdata") orelse return;
        const byte = q.byte;
        cready(b, byte);
        if (siz != 0) _ = binsm(q, dat, siz);
        prm(q);
        if (b.eof) |eof| cfollow(b, null, eof.byte);
        undomark();
    } else {
        const q = pdup(b.eof, "cdata") orelse return;
        const r = pdup(b.eof, "cdata") orelse {
            prm(q);
            return;
        };
        var byte = q.byte;
        var bf: [1024]u8 = undefined;
        var y: isize = 0;
        cready(b, byte);
        var x: isize = 0;
        while (x != siz) : (x += 1) {
            const ch = dat[@intCast(x)];
            if (ch == 13 or ch == 0) {
                // ignore
            } else if (ch == 8 or ch == 127) {
                if (y != 0) {
                    y -= 1;
                } else {
                    _ = pset(q, r);
                    _ = prgetc(q);
                    bdel(q, r);
                    byte -= 1;
                }
            } else if (ch == 7) {
                ttputcBell();
            } else {
                bf[@intCast(y)] = ch;
                y += 1;
            }
        }
        if (y != 0) _ = binsm(r, &bf, y);
        prm(r);
        prm(q);
        if (b.eof) |eof| cfollow(b, null, eof.byte);
        undomark();
    }
}

pub export fn cstart(
    bw_in: ?*anyopaque,
    name: [*c]const u8,
    s_in: [*c][*c]u8,
    obj: ?*anyopaque,
    notify: ?*c_int,
    build: c_int,
    out_only: c_int,
    first_command: [*c]const u8,
    shell_type: c_int,
) c_int {
    _ = obj;
    const bw: *BwRec = @ptrCast(@alignCast(bw_in orelse return -1));
    const b = bw.b orelse return -1;
    const s = s_in;
    var shell_w: isize = -1;
    var shell_h: isize = -1;

    if (notify) |n| n.* = 1;
    if (b.pid != 0) {
        if (shell_type != SHELL_TYPE_VT) {
            msgnw(@ptrCast(bw.parent), my_gettext("Program already running in this window"));
        }
        varm(s);
        return -1;
    }

    if (shell_type == SHELL_TYPE_VT) {
        const parent = bw.parent orelse {
            varm(s);
            return -1;
        };
        var master = vtmaster(parent.t, b);
        if (master == null) master = bw;
        const mst = master.?;
        shell_w = mst.w;
        shell_h = mst.h;
        b.vt = @ptrCast(mkvt(b, mst.top, mst.h, mst.w));
        b.o.ansi = 1;
        b.o.syntax = load_syntax("ansi");
        ansiall(b);
    }
    b.raw = if (shell_type == SHELL_TYPE_RAW) 1 else 0;

    const die_fn: ?*const fn (?*anyopaque) callconv(.c) void = if (build != 0) &cdoneParse else &cdone;
    const m = mpxmk(&b.out, name, s, &cdata, b, die_fn, b, out_only, shell_w, shell_h, if (shell_type == SHELL_TYPE_RAW) 1 else 0);
    if (m == null) {
        varm(s);
        msgnw(@ptrCast(bw.parent), my_gettext("No ptys available"));
        return -1;
    }
    b.pid = m.?.pid;
    if (first_command != null) {
        const n = zlen(first_command);
        if (write(b.out, first_command, @intCast(n)) == -1)
            msgnw(@ptrCast(bw.parent), my_gettext("Write failed when writing first command to shell"));
    }
    return 0;
}

fn dobknd(bw: *BwRec, shell_type: c_int) c_int {
    if (modify_logic(@ptrCast(bw), bw.b) == 0) return -1;

    var sh: [*c]const u8 = getenv("SHELL");
    var ok = false;
    if (sh != null and file_exists(sh) != 0 and zcmp(sh, "/bin/sh") != 0) {
        ok = true;
    } else if (file_exists("/bin/bash") != 0) {
        sh = "/bin/bash";
        ok = true;
    } else if (file_exists("/usr/bin/bash") != 0) {
        sh = "/usr/bin/bash";
        ok = true;
    } else if (file_exists("/bin/sh") != 0) {
        sh = "/bin/sh";
        ok = true;
    }
    if (!ok) {
        msgnw(@ptrCast(bw.parent), my_gettext("\"SHELL\" environment variable not defined or exported"));
        return -1;
    }

    var a = vamk(3);
    var s = vsncpy(null, 0, sh, zlen(sh));
    a = vaadd(a, s);
    s = vsncpy(null, 0, "-i", 2);
    a = vaadd(a, s);

    const start_sh = ". " ++ JOERC ++ "shell.sh\n";
    const start_csh = "source " ++ JOERC ++ "shell.csh\n";
    const first: [*c]const u8 = blk: {
        if (shell_type != SHELL_TYPE_VT) break :blk null;
        if (zstr(sh, "csh")) break :blk start_csh;
        break :blk start_sh;
    };
    return cstart(bw, sh, a, null, null, 0, 0, first, shell_type);
}

pub export fn uvtbknd(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    if (kmap_empty(kmap_getcontext("vtshell")) != 0) {
        msgnw(@ptrCast(bw.parent), my_gettext(":vtshell keymap is missing"));
        return -1;
    }
    return dobknd(bw, SHELL_TYPE_VT);
}

pub export fn ubknd(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    if (shell_kbd) |kbd| {
        if (kmap_empty(kbd.topmap) != 0) {
            msgnw(@ptrCast(bw.parent), my_gettext(":shell keymap is missing"));
            return -1;
        }
    } else {
        msgnw(@ptrCast(bw.parent), my_gettext(":shell keymap is missing"));
        return -1;
    }
    return dobknd(bw, SHELL_TYPE_DUMB);
}

fn dorun(w: ?*anyopaque, s: [*c]u8, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    const bw = windBw(w) orelse return -1;
    if (modify_logic(@ptrCast(bw), bw.b) == 0) return -1;
    var a = vamk(10);
    var cmd = vsncpy(null, 0, "/bin/sh", 7);
    a = vaadd(a, cmd);
    cmd = vsncpy(null, 0, "-c", 2);
    a = vaadd(a, cmd);
    a = vaadd(a, s);
    return cstart(bw, "/bin/sh", a, null, notify, 0, 0, null, SHELL_TYPE_RAW);
}

pub export fn urun(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    if (wmkpw(w, my_gettext("Program to run: "), &runhist, &dorun, "Run", null, &cmplt_command, null, null, locale_map, PWFLAG_COMMAND) != null)
        return 0;
    return -1;
}

fn dobuild(w: ?*anyopaque, s_in: [*c]u8, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    const bw = windBw(w) orelse return -1;
    const b = bw.b orelse return -1;
    var s = s_in;
    var a = vamk(10);
    var cmd = vsncpy(null, 0, "/bin/sh", 7);
    var t: [*c]u8 = null;

    b.o.ansi = 1;
    b.o.syntax = load_syntax("ansi");
    ansiall(b);

    a = vaadd(a, cmd);
    cmd = vsncpy(null, 0, "-c", 2);
    a = vaadd(a, cmd);

    if (b.current_dir) |cd_raw| {
        const cd: [*c]u8 = @ptrCast(cd_raw);
        if (cd[0] != 0) {
            t = vsncpy(t, vsLen(t), "cd '", 4);
            t = vsncpy(t, vsLen(t), cd, vsLen(cd));
            t = vsncpy(t, vsLen(t), "' && ", 5);
        }
    }
    t = vsncpy(t, vsLen(t), "echo \"\nJOE: cd `pwd`\n\" && if (", "echo \"\nJOE: cd `pwd`\n\" && if (".len);
    t = vsncpy(t, vsLen(t), s, vsLen(s));
    // Keep the ANSI color escapes from C (`PASS`/`FAIL` messages).
    const pass_fail = "); then echo \"\nJOE: \x1b[32mPASS\x1b[0m (exit status = $?)\n\"; else echo \"\nJOE: \x1b[31mFAIL\x1b[0m (exit status = $?)\n\"; fi";
    t = vsncpy(t, vsLen(t), pass_fail, pass_fail.len);
    vsrm(s);
    s = t;
    a = vaadd(a, s);
    return cstart(bw, "/bin/sh", a, null, notify, 1, 0, null, SHELL_TYPE_DUMB);
}

pub export fn ubuild(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw0 = windBw(w) orelse return -1;
    if (buildhist != null) {
        if (wmkpw(@ptrCast(bw0.parent), my_gettext("Build command: "), &buildhist, &dobuild, "Run", null, &cmplt_command, null, null, locale_map, PWFLAG_COMMAND)) |bw| {
            _ = uuparw(@ptrCast(bw.parent), 0);
            _ = u_goto_eol(@ptrCast(bw.parent), 0);
            if (bw.cursor) |cur| cur.xcol = piscol(cur);
            return 0;
        }
        return -1;
    }
    if (wmkpw(@ptrCast(bw0.parent), my_gettext("Enter build command (for example, 'make'): "), &buildhist, &dobuild, "Run", null, &cmplt_command, null, null, locale_map, PWFLAG_COMMAND) != null)
        return 0;
    return -1;
}

pub export fn ugrep(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw0 = windBw(w) orelse return -1;
    const b = bw0.b orelse return -1;
    b.parseone = @ptrCast(@constCast(&parseone_grep));
    if (grephist != null) {
        if (wmkpw(@ptrCast(bw0.parent), my_gettext("Grep command: "), &grephist, &dobuild, "Run", null, &cmplt_command, null, null, locale_map, PWFLAG_COMMAND)) |bw| {
            _ = uuparw(@ptrCast(bw.parent), 0);
            _ = u_goto_eol(@ptrCast(bw.parent), 0);
            if (bw.cursor) |cur| cur.xcol = piscol(cur);
            return 0;
        }
        return -1;
    }
    if (wmkpw(@ptrCast(bw0.parent), my_gettext("Enter grep command (for example, 'grep -n foo *.c'): "), &grephist, &dobuild, "Run", null, &cmplt_command, null, null, locale_map, PWFLAG_COMMAND) != null)
        return 0;
    return -1;
}

fn pidabort(w: ?*anyopaque, ch: c_int, object: ?*anyopaque, notify: ?*c_int) callconv(.c) c_int {
    _ = object;
    const bw = windBw(w) orelse return -1;
    if (notify) |n| n.* = 1;
    if (ch != YES_CODE and yncheck(yes_key, ch) == 0) return -1;
    if (bw.b) |b| {
        if (b.pid != 0) _ = kill(b.pid, 1);
    }
    return -1;
}

pub export fn ukillpid(w: ?*anyopaque, k: c_int) c_int {
    _ = k;
    const bw = windBw(w) orelse return -1;
    const b = bw.b orelse return 0;
    if (b.pid != 0) {
        const prompt = my_gettext("Kill program (y,n,%{abort})?");
        if (mkqw(@ptrCast(bw.parent), prompt, slen(prompt), &pidabort, null, null, null) != null)
            return 0;
        return -1;
    }
    return 0;
}
