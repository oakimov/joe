//! TTY and process interface — replaces `joe/tty.c`.
//!
//! Faithful C-ABI port of JOE's terminal I/O, signals, timers, and
//! multiplexed async process support. Generated from a goto-free rewrite
//! of tty.c (macOS/POSIX path) via `zig translate-c`, then cleaned for the
//! hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn fputs(s: [*c]const u8, stream: ?*anyopaque) c_int;
pub extern fn fflush(stream: ?*anyopaque) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub extern fn exit(status: c_int) void;
pub extern fn _exit(status: c_int) void;
pub extern fn sleep(seconds: c_uint) c_uint;
pub extern fn alarm(seconds: c_uint) c_uint;
pub extern fn time(t: [*c]c_long) c_long;
pub const off_t = i64;
pub const time_t = i64;
pub const pid_t = i32;
pub const suseconds_t = i32;
pub const FILE = anyopaque;
// Darwin exposes stdin/stdout/stderr as __stdinp/__stdoutp/__stderrp.
pub extern var __stdinp: ?*FILE;
pub extern var __stdoutp: ?*FILE;
pub extern var __stderrp: ?*FILE;
pub extern fn fopen(path: [*c]const u8, mode: [*c]const u8) ?*FILE;
pub extern var errno: c_int;
pub const tcflag_t = c_ulong;
pub const cc_t = u8;
pub const speed_t = c_ulong;
pub const struct_termios = extern struct {
    c_iflag: tcflag_t = 0,
    c_oflag: tcflag_t = 0,
    c_cflag: tcflag_t = 0,
    c_lflag: tcflag_t = 0,
    c_cc: [20]cc_t = std.mem.zeroes([20]cc_t),
    _pad: [4]u8 = std.mem.zeroes([4]u8),
    c_ispeed: speed_t = 0,
    c_ospeed: speed_t = 0,
};
pub extern fn tcgetattr(fd: c_int, t: [*c]struct_termios) c_int;
pub extern fn tcsetattr(fd: c_int, optional_actions: c_int, t: [*c]const struct_termios) c_int;
pub extern fn cfgetospeed(t: [*c]const struct_termios) speed_t;
pub const struct_timeval = extern struct {
    tv_sec: time_t = 0,
    tv_usec: suseconds_t = 0,
    _pad: c_int = 0,
};
pub const struct_itimerval = extern struct {
    it_interval: struct_timeval = std.mem.zeroes(struct_timeval),
    it_value: struct_timeval = std.mem.zeroes(struct_timeval),
};
pub extern fn setitimer(which: c_int, value: [*c]const struct_itimerval, ovalue: [*c]struct_itimerval) c_int;
pub const struct_winsize = extern struct {
    ws_row: c_ushort = 0,
    ws_col: c_ushort = 0,
    ws_xpixel: c_ushort = 0,
    ws_ypixel: c_ushort = 0,
};
pub const sighandler_t = ?*const fn (c_int) callconv(.c) void;

fn sig_special(n: usize) sighandler_t {
    // libc SIG_DFL=0 / SIG_IGN=1 are sentinel values, not callable pointers.
    // memcpy into the pointer avoids Zig's ptrFromInt alignment panic.
    var result: sighandler_t = undefined;
    const bytes = std.mem.asBytes(&n);
    @memcpy(@as([*]u8, @ptrCast(&result))[0..@sizeOf(usize)], bytes);
    return result;
}


pub const sigset_t = c_uint;
pub extern fn sigemptyset(set: [*c]sigset_t) c_int;
pub extern fn sigaddset(set: [*c]sigset_t, signo: c_int) c_int;
pub extern fn sigprocmask(how: c_int, set: [*c]const sigset_t, oset: [*c]sigset_t) c_int;
pub extern fn sigsuspend(set: [*c]const sigset_t) c_int;
pub extern fn open(path: [*c]const u8, flags: c_int, ...) c_int;
pub extern fn close(fd: c_int) c_int;
pub extern fn fcntl(fd: c_int, cmd: c_int, ...) c_int;
pub extern fn pipe(fds: [*c]c_int) c_int;
pub extern fn dup2(oldfd: c_int, newfd: c_int) c_int;
pub extern fn fork() pid_t;
pub extern fn wait(status: [*c]c_int) pid_t;
pub extern fn kill(pid: pid_t, sig: c_int) c_int;
pub extern fn setsid() pid_t;
pub extern fn setpgrp() c_int;
pub extern fn execve(path: [*c]const u8, argv: [*c]const [*c]u8, envp: [*c]const [*c]u8) c_int;
pub extern fn execl(path: [*c]const u8, arg: [*c]const u8, ...) c_int;
pub extern fn read(fd: c_int, buf: ?*anyopaque, n: c_ulong) ptrdiff_t;
pub extern fn write(fd: c_int, buf: ?*const anyopaque, n: c_ulong) ptrdiff_t;
pub extern fn fileno(stream: ?*FILE) c_int;
pub extern fn openpty(amaster: [*c]c_int, aslave: [*c]c_int, name: [*c]u8, termp: [*c]struct_termios, winp: [*c]struct_winsize) c_int;
pub extern fn login_tty(fd: c_int) c_int;
pub const struct_mpx = extern struct {
    ackfd: c_int = 0,
    kpid: c_int = 0,
    pid: c_int = 0,
    func: ?*const fn (object: ?*anyopaque, data: [*c]u8, len: ptrdiff_t) callconv(.c) void = null,
    object: ?*anyopaque = null,
    die: ?*const fn (object: ?*anyopaque) callconv(.c) void = null,
    dieobj: ?*anyopaque = null,
};
pub const MPX = struct_mpx;
pub const struct_utf8_sm = extern struct {
    buf: [8]u8 = std.mem.zeroes([8]u8),
    ptr: ptrdiff_t = 0,
    state: c_int = 0,
    accu: c_int = 0,
};
pub const struct_macro = extern struct {
    _pad: [48]u8 = std.mem.zeroes([48]u8),
};
pub const MACRO = struct_macro;
pub const struct_charmap = extern struct {
    _pad0: [16]u8 = std.mem.zeroes([16]u8),
    @"type": c_int = 0,
    _pad1: [2732]u8 = std.mem.zeroes([2732]u8),
};
pub const struct_scrn = extern struct {
    _pad: [840]u8 = std.mem.zeroes([840]u8),
};
pub const SCRN = struct_scrn;
pub const struct_screen = extern struct {
    t: [*c]SCRN = null,
    _pad: [40]u8 = std.mem.zeroes([40]u8),
};
pub const Screen = struct_screen;
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn joe_read(fd: c_int, buf: ?*anyopaque, siz: ptrdiff_t) ptrdiff_t;
pub extern fn joe_write(fd: c_int, buf: ?*const anyopaque, siz: ptrdiff_t) ptrdiff_t;
pub extern fn joe_ioctl(fd: c_int, req: c_ulong, ptr: ?*anyopaque) c_int;
pub extern fn joe_set_signal(signum: c_int, handler: sighandler_t) c_int;
pub extern fn ttsig(sig: c_int) void;
pub extern var nodeadjoe: c_int;
pub extern fn set_attr(t: [*c]SCRN, c: c_int) c_int;
pub extern fn edupd(flg: c_int) void;
pub extern fn exemac(m: [*c]MACRO, k: c_int) c_int;
pub extern fn timer_play() [*c]MACRO;
pub extern fn do_auto_scroll() void;
pub extern fn mnow() c_long;
pub extern fn utf8_decode(sm: [*c]struct_utf8_sm, c: u8) c_int;
pub extern fn to_uni(map: [*c]struct_charmap, c: c_int) c_int;
pub extern var maint: [*c]Screen;
pub extern var locale_map: [*c]struct_charmap;
pub extern var dostaupd: c_int;
pub extern var auto_scroll: c_int;
pub extern var auto_trig_time: c_long;
pub extern var mainenv: [*c]const [*c]const u8;
pub export fn ttopen() void {
    sigjoe();
    ttopnn();
}
pub export fn ttopnn() void {
    var x: ptrdiff_t = undefined;
    _ = &x;
    var bbaud: speed_t = undefined;
    _ = &bbaud;
    var newterm: struct_termios = undefined;
    _ = &newterm;
    if (!(termin != null)) {
        if ((if (idleout != 0) @intFromBool(!((blk: {
            const tmp = __stdinp;
            termin = tmp;
            break :blk tmp;
        }) != null) or !((blk: {
            const tmp = __stdoutp;
            termout = tmp;
            break :blk tmp;
        }) != null)) else @intFromBool(!((blk: {
            const tmp = fopen("/dev/tty", "r");
            termin = tmp;
            break :blk tmp;
        }) != null) or !((blk: {
            const tmp = fopen("/dev/tty", "w");
            termout = tmp;
            break :blk tmp;
        }) != null))) != 0) {
            _ = fputs("Couldn't open /dev/tty\n", __stderrp);
            exit(1);
        } else {
            _ = joe_set_signal(SIGWINCH, winchd);
        }
    }
    if (ttymode != 0) return;
    ttymode = 1;
    _ = fflush(termout);
    _ = tcgetattr(fileno(termin), &oldterm);
    newterm = oldterm;
    newterm.c_lflag = 0;
    if (noxon != 0) {
        newterm.c_iflag &= ~@as(c_uint, @bitCast(@as(c_int, (((ICRNL | IGNCR) | INLCR) | IXON) | IXOFF)));
    } else {
        newterm.c_iflag &= ~@as(c_uint, @bitCast(@as(c_int, (ICRNL | IGNCR) | INLCR)));
    }
    newterm.c_oflag = 0;
    newterm.c_cc[VMIN] = 1;
    newterm.c_cc[VTIME] = 0;
    _ = tcsetattr(fileno(termin), TCSADRAIN, &newterm);
    bbaud = cfgetospeed(&newterm);
    tty_baud = 9600;
    upc = 0;
    {
        x = 0;
        while (@as(c_ulong, @bitCast(@as(c_long, x))) != (@sizeOf(@TypeOf(speeds_in)) / @sizeOf(speed_t))) : (x += 1) if (bbaud == speeds_in[@bitCast(@as(isize, @intCast(x)))]) {
            tty_baud = speeds_out[@bitCast(@as(isize, @intCast(x)))];
            break;
        };
    }
    if (Baud != 0) {
        tty_baud = Baud;
    }
    upc = @divTrunc(@as(c_long, DIVIDEND), tty_baud);
    if (obuf != null) {
        joe_free(@ptrCast(@alignCast(obuf)));
    }
    if (!(upc != 0)) {
        obufsiz = 4096;
    } else {
        obufsiz = @divTrunc(@as(c_long, 1000000), @as(c_long, TIMES) * upc);
        if (obufsiz > @as(ptrdiff_t, 4096)) {
            obufsiz = 4096;
        }
    }
    if (!(obufsiz != 0)) {
        obufsiz = 1;
    }
    obuf = @ptrCast(@alignCast(joe_malloc(obufsiz)));
}
pub export fn ttclose() void {
    ttclsn();
    signrm();
}
pub export fn ttclsn() void {
    var oleave: c_int = undefined;
    _ = &oleave;
    if (ttymode != 0) {
        ttymode = 0;
    } else return;
    oleave = leave;
    leave = 1;
    _ = ttflsh();
    _ = tcsetattr(fileno(termin), TCSADRAIN, &oldterm);
    leave = oleave;
}
pub export fn ttgetc() u8 {
    var m: [*c]MACRO = undefined;
    _ = &m;
    var mystat: ptrdiff_t = undefined;
    _ = &mystat;
    var new_time: time_t = undefined;
    _ = &new_time;
    var flg: c_int = undefined;
    _ = &flg;
    tickon();
    while (true) {
        flg = 0;
        new_time = time(null);
        if (new_time != last_time) {
            last_time = new_time;
            dostaupd = 1;
            ticked = 1;
        }
        if ((auto_scroll != 0) and (mnow() >= auto_trig_time)) {
            do_auto_scroll();
            ticked = 1;
            flg = 1;
        }
        _ = ttflsh();
        m = timer_play();
        if (m != null) {
            _ = exemac(m, -@as(c_int, 256));
            edupd(1);
            _ = ttflsh();
        }
        while (winched != 0) {
            winched = 0;
            dostaupd = 1;
            edupd(1);
            _ = ttflsh();
        }
        if (ticked != 0) {
            edupd(flg);
            _ = ttflsh();
            tickon();
        }
        if (ackkbd != -@as(c_int, 1)) {
            if (!(have != 0)) {
                mystat = read(mpxfd, @ptrCast(@alignCast(&pack)), @bitCast(@as(c_long, @divExact(@as(c_long, @bitCast(@intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&pack.data)))) -% @intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&pack)))))), @sizeOf(u8)))));
                if ((pack.size != 0) and (@as(ptrdiff_t, @intFromBool(mystat > @as(ptrdiff_t, 0))) != 0)) {
                    if ((pack.size < @as(ptrdiff_t, 0)) or (@as(c_ulong, @bitCast(@as(c_long, pack.size))) > @sizeOf(@TypeOf(pack.data)))) {
                        pack.size = @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(pack.data)))));
                    }
                    _ = joe_read(mpxfd, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&pack.data))))), pack.size);
                } else if (mystat < @as(ptrdiff_t, 1)) {
                    if ((winched != 0) or (ticked != 0)) continue else {
                        ttsig(0);
                    }
                }
                acceptch = pack.ch;
            }
            have = 0;
            if (pack.who != null) {
                if (acceptch != -@as(c_int, 256)) {
                    if (pack.who.*.func != null) {
                        pack.who.*.func.?(pack.who.*.object, @ptrCast(@alignCast(&pack.data)), pack.size);
                        edupd(1);
                    }
                } else {
                    mpxdied(pack.who);
                }
                continue;
            } else {
                if (acceptch != -@as(c_int, 256)) {
                    tickoff();
                    return @as(u8, @bitCast(@as(i8, @truncate(acceptch))));
                } else {
                    tickoff();
                    ttsig(0);
                    return 0;
                }
            }
        }
        if (have != 0) {
            have = 0;
        } else {
            if (read(fileno(termin), @ptrCast(@alignCast(&havec)), 1) < @as(ptrdiff_t, 1)) {
                if ((winched != 0) or (ticked != 0)) continue else {
                    ttsig(0);
                }
            }
        }
        tickoff();
        return havec;
    }
    return undefined;
}
pub export fn ttgetch() c_int {
    if (locale_map.*.@"type" != 0) {
        var utf8_char: c_int = undefined;
        _ = &utf8_char;
        while (true) {
            var c: u8 = ttgetc();
            _ = &c;
            utf8_char = utf8_decode(&main_utf8_sm, c);
            if (!(utf8_char < @as(c_int, 0))) break;
        }
        return utf8_char;
    } else {
        var c: u8 = ttgetc();
        _ = &c;
        var utf8_char: c_int = to_uni(locale_map, c);
        _ = &utf8_char;
        if (utf8_char == -@as(c_int, 1)) {
            utf8_char = '?';
        }
        return utf8_char;
    }
    return undefined;
}
pub export fn ttcheck() c_int {
    if (((ackkbd != -@as(c_int, 1)) and (acceptch != -@as(c_int, 256))) and !(have != 0)) {
        var c: u8 = 0;
        _ = &c;
        if ((pack.who != null) and (pack.who.*.func != null)) {
            _ = joe_write(pack.who.*.ackfd, @ptrCast(@alignCast(&c)), 1);
        } else {
            _ = joe_write(ackkbd, @ptrCast(@alignCast(&c)), 1);
        }
        acceptch = -@as(c_int, 256);
    }
    if (!(have != 0) and !(leave != 0)) {
        if (ackkbd != -@as(c_int, 1)) {
            _ = fcntl(mpxfd, F_SETFL, @as(c_int, O_NDELAY));
            if (read(mpxfd, @ptrCast(@alignCast(&pack)), @bitCast(@as(c_long, @divExact(@as(c_long, @bitCast(@intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&pack.data)))) -% @intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&pack)))))), @sizeOf(u8))))) > @as(ptrdiff_t, 0)) {
                _ = fcntl(mpxfd, F_SETFL, @as(c_int, 0));
                if ((pack.size < @as(ptrdiff_t, 0)) or (@as(c_ulong, @bitCast(@as(c_long, pack.size))) > @sizeOf(@TypeOf(pack.data)))) {
                    pack.size = @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(pack.data)))));
                }
                _ = joe_read(mpxfd, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&pack.data))))), pack.size);
                have = 1;
                acceptch = pack.ch;
            } else {
                _ = fcntl(mpxfd, F_SETFL, @as(c_int, 0));
            }
        } else {
            _ = fcntl(fileno(termin), F_SETFL, @as(c_int, O_NDELAY));
            if (read(fileno(termin), @ptrCast(@alignCast(&havec)), 1) == @as(ptrdiff_t, 1)) {
                have = 1;
            }
            _ = fcntl(fileno(termin), F_SETFL, @as(c_int, 0));
        }
    }
    return have;
}
pub export fn ttputs(arg_s: [*c]const u8) void {
    var s = arg_s;
    _ = &s;
    while (@as(c_int, s.*) != 0) {
        obuf[
            @bitCast(@as(isize, @intCast(blk: {
                const ref = &obufp;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            })))
        ] = (blk: {
            const ref = &s;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        }).*;
        if (obufp == obufsiz) {
            _ = ttflsh();
        }
    }
}
pub export fn ttshell(arg_cmd: [*c]u8) c_int {
    var cmd = arg_cmd;
    _ = &cmd;
    var x: c_int = undefined;
    _ = &x;
    var omode: c_int = ttymode;
    _ = &omode;
    var mystat: c_int = -@as(c_int, 1);
    _ = &mystat;
    var s: [*c]const u8 = getenv("SHELL");
    _ = &s;
    if (!(s != null)) {
        s = "/bin/sh";
    }
    ttclsn();
    if ((blk: {
        const tmp = fork();
        x = tmp;
        break :blk tmp;
    }) != @as(c_int, 0)) {
        if (x != -@as(c_int, 1)) {
            _ = wait(&mystat);
        }
        if (omode != 0) {
            ttopnn();
        }
        return mystat;
    } else {
        signrm();
        if (cmd != null) {
            _ = execl(s, s, @constCast("-c"), cmd, @as(?*anyopaque, null));
        } else {
            _ = fputs("You are at the command shell.  Type 'exit' to return\n", __stderrp);
            _ = execl(s, s, @as(?*anyopaque, null));
        }
        _exit(0);
        return 0;
    }
}
pub export fn ttsusp() void {
    var omode: c_int = undefined;
    _ = &omode;
    omode = ttymode;
    mpxsusp();
    ttclsn();
    _ = fputs("You have suspended the program.  Type 'fg' to return\n", __stderrp);
    _ = kill(0, SIGTSTP);
    if (omode != 0) {
        ttopnn();
    }
    if (ackkbd != -@as(c_int, 1)) {
        _ = mpxresume();
    }
}
pub export fn ttflsh() c_int {
    if (obufp != 0) {
        var usec: c_long = obufp * upc;
        _ = &usec;
        if ((usec >= @as(c_long, 50000)) and (tty_baud < @as(c_long, 9600))) {
            var a: struct_itimerval = undefined;
            _ = &a;
            var b: struct_itimerval = undefined;
            _ = &b;
            a.it_value.tv_sec = @divTrunc(usec, @as(c_long, 1000000));
            a.it_value.tv_usec = @truncate(@rem(usec, @as(c_long, 1000000)));
            a.it_interval.tv_usec = 0;
            a.it_interval.tv_sec = 0;
            _ = alarm(0);
            _ = joe_set_signal(SIGALRM, dosig);
            yep = 0;
            maskit();
            _ = setitimer(ITIMER_REAL, &a, &b);
            _ = joe_write(fileno(termout), @ptrCast(@alignCast(obuf)), obufp);
            while (!(yep != 0)) {
                pauseit();
            }
            unmaskit();
        } else {
            _ = joe_write(fileno(termout), @ptrCast(@alignCast(obuf)), obufp);
        }
        obufp = 0;
    }
    _ = ttcheck();
    return 0;
}
pub export fn ttgtsz(arg_x: [*c]ptrdiff_t, arg_y: [*c]ptrdiff_t) void {
    var x = arg_x;
    _ = &x;
    var y = arg_y;
    _ = &y;
    var getit: struct_winsize = undefined;
    _ = &getit;
    x.* = 0;
    y.* = 0;
    if (joe_ioctl(fileno(termout), TIOCGWINSZ, @ptrCast(@alignCast(&getit))) != -@as(c_int, 1)) {
        x.* = getit.ws_col;
        y.* = getit.ws_row;
    }
}
pub export fn ttstsz(arg_fd: c_int, arg_w: ptrdiff_t, arg_h: ptrdiff_t) void {
    var fd = arg_fd;
    _ = &fd;
    var w = arg_w;
    _ = &w;
    var h = arg_h;
    _ = &h;
    var getit: struct_winsize = undefined;
    _ = &getit;
    getit.ws_col = @bitCast(@as(c_short, @truncate(w)));
    getit.ws_row = @bitCast(@as(c_short, @truncate(h)));
    _ = joe_ioctl(fd, TIOCSWINSZ, @ptrCast(@alignCast(&getit)));
}
pub export fn sigjoe() void {
    if (ttysig != 0) return;
    ttysig = 1;
    _ = joe_set_signal(SIGHUP, ttsig);
    _ = joe_set_signal(SIGTERM, ttsig);
    _ = joe_set_signal(SIGABRT, ttsig);
    _ = joe_set_signal(SIGINT, sig_special(1));
    _ = joe_set_signal(SIGPIPE, sig_special(1));
}
pub export fn signrm() void {
    if (!(ttysig != 0)) return;
    ttysig = 0;
    _ = joe_set_signal(SIGABRT, null);
    _ = joe_set_signal(SIGHUP, null);
    _ = joe_set_signal(SIGTERM, null);
    _ = joe_set_signal(SIGINT, null);
    _ = joe_set_signal(SIGPIPE, null);
}
pub export fn mpxmk(arg_ptyfd: [*c]c_int, arg_cmd: [*c]const u8, arg_args: [*c][*c]u8, arg_func: ?*const fn (object: ?*anyopaque, data: [*c]u8, len: ptrdiff_t) callconv(.c) void, arg_object: ?*anyopaque, arg_die: ?*const fn (object: ?*anyopaque) callconv(.c) void, arg_dieobj: ?*anyopaque, arg_copy_in: c_int, arg_w: ptrdiff_t, arg_h: ptrdiff_t, arg_use_pipe: c_int) [*c]MPX {
    var ptyfd = arg_ptyfd;
    _ = &ptyfd;
    var cmd = arg_cmd;
    _ = &cmd;
    var args = arg_args;
    _ = &args;
    var func = arg_func;
    _ = &func;
    var object = arg_object;
    _ = &object;
    var die = arg_die;
    _ = &die;
    var dieobj = arg_dieobj;
    _ = &dieobj;
    var copy_in = arg_copy_in;
    _ = &copy_in;
    var w = arg_w;
    _ = &w;
    var h = arg_h;
    _ = &h;
    var use_pipe = arg_use_pipe;
    _ = &use_pipe;
    var buf: [80]u8 = undefined;
    _ = &buf;
    var fds: [2]c_int = undefined;
    _ = &fds;
    var comm: [2]c_int = undefined;
    _ = &comm;
    var pid: pid_t = undefined;
    _ = &pid;
    var x: c_int = undefined;
    _ = &x;
    var m: [*c]MPX = null;
    _ = &m;
    var name: [*c]u8 = null;
    _ = &name;
    var ttyfd: c_int = -@as(c_int, 1);
    _ = &ttyfd;
    {
        x = 0;
        while (x != NPROC) : (x += 1) if (!(asyncs[@bitCast(@as(isize, @intCast(x)))].func != null)) {
            m = @as([*c]MPX, @ptrCast(@alignCast(&asyncs))) + @as(usize, @bitCast(@as(isize, @intCast(x))));
            break;
        };
    }
    if (x == NPROC) return null;
    if (use_pipe != 0) {
        var p: [2]c_int = undefined;
        _ = &p;
        if (pipe(@ptrCast(@alignCast(&p))) != 0) return null;
        ptyfd.* = p[@as(c_int, 0)];
        ttyfd = p[@as(c_int, 1)];
    } else {
        if (!((blk: {
            const tmp = getpty(ptyfd, &ttyfd);
            name = tmp;
            break :blk tmp;
        }) != null)) return null;
    }
    _ = set_attr(maint.*.t, 0);
    _ = ttflsh();
    if (ackkbd == -@as(c_int, 1)) if (mpxstart() != 0) return null;
    m.*.func = func;
    m.*.object = object;
    m.*.die = die;
    m.*.dieobj = dieobj;
    if (-@as(c_int, 1) == pipe(@ptrCast(@alignCast(&fds)))) return null;
    m.*.ackfd = fds[@as(c_int, 1)];
    if (-@as(c_int, 1) == pipe(@ptrCast(@alignCast(&comm)))) return null;
    nmpx += 1;
    if (!((blk: {
        const tmp = fork();
        m.*.kpid = tmp;
        break :blk tmp;
    }) != 0)) {
        _ = close(fds[@as(c_int, 1)]);
        _ = close(comm[@as(c_int, 0)]);
        dead = 0;
        death_fd = ptyfd.*;
        _ = joe_set_signal(SIGCHLD, death);
        if (!((blk: {
            const tmp = fork();
            pid = tmp;
            break :blk tmp;
        }) != 0)) {
            signrm();
            _ = close(ptyfd.*);
            if (ttyfd == -@as(c_int, 1)) {
                ttyfd = open(name, O_RDWR);
            }
            if (ttyfd != -@as(c_int, 1)) {
                var enva: [*c][*c]const u8 = undefined;
                _ = &enva;
                var env: [*c][*c]const u8 = undefined;
                _ = &env;
                if (!(copy_in != 0)) {
                    _ = dup2(ttyfd, 0);
                }
                _ = dup2(ttyfd, 1);
                _ = dup2(ttyfd, 2);
                {
                    x = 3;
                    while (x != @as(c_int, 32)) : (x += 1) {
                        _ = close(x);
                    }
                }
                if (w == @as(ptrdiff_t, -@as(c_int, 1))) {
                    enva = newenv(mainenv, "TERM=");
                } else {
                    enva = newenv(mainenv, "TERM=linux");
                }
                env = newenv(enva, "JOE=1");
                if (!(copy_in != 0)) {
                    _ = login_tty(1);
                    if (!(use_pipe != 0)) {
                        _ = tcsetattr(1, TCSADRAIN, &oldterm);
                        if (w != @as(ptrdiff_t, -@as(c_int, 1))) {
                            ttstsz(1, w, h);
                        }
                    }
                    _ = execve(cmd, args, @ptrCast(@alignCast(env)));
                    _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))), "Couldn't execute shell '%s'\n", cmd);
                    if (@as(ptrdiff_t, -@as(c_int, 1)) == joe_write(1, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&buf))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(@ptrCast(@alignCast(&buf))))))))) {
                        _ = sleep(2);
                    } else {
                        _ = sleep(1);
                    }
                } else {
                    var ibuf: [1024]u8 = undefined;
                    _ = &ibuf;
                    var len: ptrdiff_t = undefined;
                    _ = &len;
                    while (true) {
                        len = joe_read(0, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&ibuf))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(ibuf)))))));
                        if (len > @as(ptrdiff_t, 0)) {
                            if (@as(ptrdiff_t, -@as(c_int, 1)) == joe_write(1, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&ibuf))))), len)) break;
                        } else {
                            break;
                        }
                    }
                }
            }
            _exit(0);
        }
        _ = joe_write(comm[@as(c_int, 1)], @ptrCast(@alignCast(&pid)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(pid)))))));
        while (true) {
            pack.who = m;
            pack.ch = 0;
            pack.size = joe_read(ptyfd.*, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&pack.data))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(pack.data)))))));
            if (!(pack.size != 0)) {
                pack.size = joe_read(ptyfd.*, @ptrCast(@alignCast(@as([*c]u8, @ptrCast(@alignCast(&pack.data))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(pack.data)))))));
            }
            if (pack.size > @as(ptrdiff_t, 0)) {
                _ = joe_write(mpxsfd, @ptrCast(@alignCast(&pack)), @divExact(@as(c_long, @bitCast(@intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&pack.data)))) -% @intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&pack)))))), @sizeOf(u8)) + pack.size);
                _ = joe_read(fds[@as(c_int, 0)], @ptrCast(@alignCast(&pack)), 1);
            } else {
                pack.ch = -@as(c_int, 256);
                pack.size = 0;
                _ = joe_write(mpxsfd, @ptrCast(@alignCast(&pack)), @divExact(@as(c_long, @bitCast(@intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&pack.data)))) -% @intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&pack)))))), @sizeOf(u8)));
                _exit(0);
            }
        }
    }
    _ = joe_read(comm[@as(c_int, 0)], @ptrCast(@alignCast(&m.*.pid)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(m.*.pid)))))));
    if (-@as(c_int, 1) != ttyfd) {
        _ = close(ttyfd);
    }
    _ = close(comm[@as(c_int, 0)]);
    _ = close(comm[@as(c_int, 1)]);
    _ = close(fds[@as(c_int, 0)]);
    return m;
}
pub export fn tickoff() void {
    var val: struct_itimerval = undefined;
    _ = &val;
    val.it_value.tv_sec = 0;
    val.it_value.tv_usec = 0;
    val.it_interval.tv_sec = 0;
    val.it_interval.tv_usec = 0;
    _ = setitimer(ITIMER_REAL, &val, null);
}
pub export fn tickon() void {
    var val: struct_itimerval = undefined;
    _ = &val;
    val.it_interval.tv_sec = 0;
    val.it_interval.tv_usec = 0;
    if (auto_scroll != 0) {
        var tim: c_long = auto_trig_time - mnow();
        _ = &tim;
        if (tim < @as(c_long, 0)) {
            tim = 1;
        }
        tim *= 1000;
        val.it_value.tv_sec = 0;
        val.it_value.tv_usec = @truncate(tim);
    } else {
        val.it_value.tv_sec = 1;
        val.it_value.tv_usec = 0;
    }
    ticked = 0;
    _ = joe_set_signal(SIGALRM, dotick);
    _ = setitimer(ITIMER_REAL, &val, null);
}
pub export fn mpxdied(arg_m: [*c]MPX) void {
    var m = arg_m;
    _ = &m;
    if (!((blk: {
        const ref = &nmpx;
        ref.* -= 1;
        break :blk ref.*;
    }) != 0)) {
        mpxend();
    }
    while ((wait(null) < @as(c_int, 0)) and (errno == EINTR)) {}
    if (m.*.die != null) {
        m.*.die.?(m.*.dieobj);
    }
    m.*.func = null;
    _ = close(m.*.ackfd);
    edupd(1);
}
pub export var idleout: c_int = 1;
pub export var noxon: c_int = 0;
pub export var Baud: c_int = 0;
pub export var termin: ?*FILE = null;
pub export var termout: ?*FILE = null;
pub export var oldterm: struct_termios = std.mem.zeroes(struct_termios);
pub export var obuf: [*c]u8 = null;
pub export var obufp: ptrdiff_t = 0;
pub export var obufsiz: ptrdiff_t = 0;
pub export var tty_baud: c_long = 0;
pub export var upc: c_long = 0;
pub const speeds_in: [15]speed_t = [15]speed_t{
    B50,
    B75,
    B110,
    B134,
    B150,
    B200,
    B300,
    B600,
    B1200,
    B1800,
    B2400,
    B4800,
    B9600,
    B19200,
    B38400,
};
pub const speeds_out: [15]c_long = [15]c_long{
    50,
    75,
    110,
    134,
    150,
    200,
    300,
    600,
    1200,
    1800,
    2400,
    4800,
    9600,
    19200,
    38400,
};
pub export var have: c_int = 0;
pub export var havec: u8 = 0;
pub export var leave: c_int = 0;
pub var ttymode: c_int = 0;
pub var ttysig: c_int = 0;
pub var kbdpid: pid_t = 0;
pub var ackkbd: c_int = -@as(c_int, 1);
pub var mpxfd: c_int = 0;
pub var mpxsfd: c_int = 0;
pub var nmpx: c_int = 0;
pub var acceptch: c_int = -@as(c_int, 256);
pub const struct_packet = extern struct {
    who: [*c]MPX = null,
    size: ptrdiff_t = 0,
    ch: c_int = 0,
    data: [1024]u8 = std.mem.zeroes([1024]u8),
};
pub export var pack: struct_packet = std.mem.zeroes(struct_packet);
pub export var asyncs: [8]MPX = std.mem.zeroes([8]MPX);
pub var winched: c_int = 0;
pub fn winchd(arg_unused: c_int) callconv(.c) void {
    var unused = arg_unused;
    _ = &unused;
    winched += 1;
    _ = joe_set_signal(SIGWINCH, winchd);
}
pub export var ticked: c_int = 0;
pub fn dotick(arg_unused: c_int) callconv(.c) void {
    var unused = arg_unused;
    _ = &unused;
    ticked = 1;
}
pub var yep: c_int = 0;
pub fn dosig(arg_unused: c_int) callconv(.c) void {
    var unused = arg_unused;
    _ = &unused;
    yep = 1;
}
pub fn maskit() callconv(.c) void {
    var set: sigset_t = undefined;
    _ = &set;
    _ = sigemptyset(&set);
    _ = sigaddset(&set, SIGALRM);
    _ = sigprocmask(SIG_SETMASK, &set, null);
}
pub fn unmaskit() callconv(.c) void {
    var set: sigset_t = undefined;
    _ = &set;
    _ = sigemptyset(&set);
    _ = sigprocmask(SIG_SETMASK, &set, null);
}
pub fn pauseit() callconv(.c) void {
    var set: sigset_t = undefined;
    _ = &set;
    _ = sigemptyset(&set);
    _ = sigsuspend(&set);
}
pub export var last_time: time_t = 0;
pub var main_utf8_sm: struct_utf8_sm = std.mem.zeroes(struct_utf8_sm);
pub fn mpxresume() callconv(.c) c_int {
    var fds: [2]c_int = undefined;
    _ = &fds;
    if (-@as(c_int, 1) == pipe(@ptrCast(@alignCast(&fds)))) return -@as(c_int, 1);
    acceptch = -@as(c_int, 256);
    have = 0;
    if (!((blk: {
        const tmp = fork();
        kbdpid = tmp;
        break :blk tmp;
    }) != 0)) {
        _ = close(fds[@as(c_int, 1)]);
        while (true) {
            var c: u8 = undefined;
            _ = &c;
            var sta: ptrdiff_t = undefined;
            _ = &sta;
            pack.who = null;
            sta = joe_read(fileno(termin), @ptrCast(@alignCast(&c)), 1);
            if (sta == @as(ptrdiff_t, 0)) {
                pack.ch = -@as(c_int, 256);
            } else {
                pack.ch = c;
            }
            pack.size = 0;
            _ = joe_write(mpxsfd, @ptrCast(@alignCast(&pack)), @divExact(@as(c_long, @bitCast(@intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&pack.data)))) -% @intFromPtr(@as([*c]u8, @ptrCast(@alignCast(&pack)))))), @sizeOf(u8)));
            if (!(joe_read(fds[@as(c_int, 0)], @ptrCast(@alignCast(&pack)), 1) == @as(ptrdiff_t, 1))) break;
        }
        _exit(0);
    }
    _ = close(fds[@as(c_int, 0)]);
    ackkbd = fds[@as(c_int, 1)];
    return 0;
}
pub fn mpxsusp() callconv(.c) void {
    if (ackkbd != -@as(c_int, 1)) {
        _ = kill(kbdpid, 9);
        while ((wait(null) < @as(c_int, 0)) and (errno == EINTR)) {}
        _ = close(ackkbd);
    }
}
pub fn mpxstart() callconv(.c) c_int {
    var fds: [2]c_int = undefined;
    _ = &fds;
    if (-@as(c_int, 1) == pipe(@ptrCast(@alignCast(&fds)))) return -@as(c_int, 1);
    mpxfd = fds[@as(c_int, 0)];
    mpxsfd = fds[@as(c_int, 1)];
    return mpxresume();
}
pub fn mpxend() callconv(.c) void {
    mpxsusp();
    ackkbd = -@as(c_int, 1);
    _ = close(mpxfd);
    _ = close(mpxsfd);
    if (have != 0) {
        havec = @bitCast(@as(i8, @truncate(pack.ch)));
    }
}
pub fn getpty(arg_ptyfd: [*c]c_int, arg_ttyfd: [*c]c_int) callconv(.c) [*c]u8 {
    var ptyfd = arg_ptyfd;
    _ = &ptyfd;
    var ttyfd = arg_ttyfd;
    _ = &ttyfd;
    const static_local_name = struct {
        var name: [32]u8 = std.mem.zeroes([32]u8);
    };
    _ = &static_local_name;
    if (openpty(ptyfd, ttyfd, @ptrCast(@alignCast(&static_local_name.name)), null, null) == @as(c_int, 0)) {
        return @ptrCast(@alignCast(&static_local_name.name));
    } else {
        return null;
    }
}
pub export var dead: c_int = 0;
pub export var death_fd: c_int = 0;
pub fn death(arg_unused: c_int) callconv(.c) void {
    var unused = arg_unused;
    _ = &unused;
    _ = fcntl(death_fd, F_SETFL, @as(c_int, O_NDELAY));
    _ = wait(null);
    dead = 1;
}
pub fn newenv(arg_old: [*c]const [*c]const u8, arg_s: [*c]const u8) callconv(.c) [*c][*c]const u8 {
    var old = arg_old;
    _ = &old;
    var s = arg_s;
    _ = &s;
    var newv: [*c][*c]const u8 = undefined;
    _ = &newv;
    var x: c_int = undefined;
    _ = &x;
    var y: c_int = undefined;
    _ = &y;
    var z: c_int = undefined;
    _ = &z;
    {
        x = 0;
        while (old[@bitCast(@as(isize, @intCast(x)))] != null) : (x += 1) {}
    }
    newv = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, x + @as(c_int, 2)) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]u8))))))));
    {
        x = 0;
        y = 0;
        while (old[@bitCast(@as(isize, @intCast(x)))] != null) : (x += 1) {
            {
                z = 0;
                while (@as(c_int, s[@bitCast(@as(isize, @intCast(z)))]) != @as(c_int, '=')) : (z += 1) if (@as(c_int, s[@bitCast(@as(isize, @intCast(z)))]) != @as(c_int, old[@bitCast(@as(isize, @intCast(x)))][@bitCast(@as(isize, @intCast(z)))])) break;
            }
            if (@as(c_int, s[@bitCast(@as(isize, @intCast(z)))]) == @as(c_int, '=')) {
                if (@as(c_int, s[@bitCast(@as(isize, @intCast(z + @as(c_int, 1))))]) != 0) {
                    newv[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &y;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = s;
                }
            } else {
                newv[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &y;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ] = old[@bitCast(@as(isize, @intCast(x)))];
            }
        }
    }
    if (x == y) {
        newv[
            @bitCast(@as(isize, @intCast(blk: {
                const ref = &y;
                const tmp = ref.*;
                ref.* += 1;
                break :blk tmp;
            })))
        ] = s;
    }
    newv[@bitCast(@as(isize, @intCast(y)))] = null;
    return newv;
}

pub const TIMES = 3;
pub const DIVIDEND = 10000000;
pub const NO_MORE_DATA = -256;
pub const NPROC = 8;
pub const NCCS = 20;
pub const VMIN = 16;
pub const VTIME = 17;
pub const TCSADRAIN = 1;
pub const ICRNL = 256;
pub const IGNCR = 128;
pub const INLCR = 64;
pub const IXON = 512;
pub const IXOFF = 1024;
pub const B50 = 50;
pub const B75 = 75;
pub const B110 = 110;
pub const B134 = 134;
pub const B150 = 150;
pub const B200 = 200;
pub const B300 = 300;
pub const B600 = 600;
pub const B1200 = 1200;
pub const B1800 = 1800;
pub const B2400 = 2400;
pub const B4800 = 4800;
pub const B9600 = 9600;
pub const B19200 = 19200;
pub const B38400 = 38400;
pub const ITIMER_REAL = 0;
pub const SIGHUP = 1;
pub const SIGINT = 2;
pub const SIGABRT = 6;
pub const SIGPIPE = 13;
pub const SIGALRM = 14;
pub const SIGTERM = 15;
pub const SIGTSTP = 18;
pub const SIGCHLD = 20;
pub const SIGWINCH = 28;
pub const SIG_SETMASK = 3;
pub const F_SETFL = 4;
pub const O_NDELAY = 4;
pub const O_NONBLOCK = 4;
pub const O_RDWR = 2;
pub const EINTR = 4;
pub const TIOCGWINSZ: c_ulong = 1074295912;
pub const TIOCSWINSZ: c_ulong = 2148037735;
