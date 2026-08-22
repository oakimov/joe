//! File I/O — replaces the file loading/saving portions of `b.c`:
//! `bread`, `bload`, `bsave`, `bsavefd`, plus `bfind` family, `parsens`,
//! `canonical`, `ttsig`, `lock_it`/`unlock_it`, `plain_file`, etc.

const std = @import("std");
const types = @import("types.zig");
const intern = @import("intern.zig");
const pointer = @import("pointer.zig");
const buffer = @import("buffer.zig");

const P = types.P;
const B = types.B;
const H = types.H;
const Link = types.Link;
const SEGSIZ = types.SEGSIZ;
const NO_MORE_DATA = types.NO_MORE_DATA;

const ptrEq = intern.ptrEq;
const Hlink = intern.Hlink;
const Blink = intern.Blink;
const Plink = intern.Plink;
const link2B = intern.link2B;
const link2H = intern.link2H;
const link2P = intern.link2P;
const izque = intern.izque;
const deque_ = intern.deque_;
const enqueb_ = intern.enqueb_;
const qempty_ = intern.qempty_;
const halloc = intern.halloc;
const hfree = intern.hfree;
const count_nl = intern.count_nl;
const gsize_ = intern.gsize_;
const gchar = intern.gchar;
const vlock = intern.vlock;
const vunlock_page = intern.vunlock_page;
const vchanged_page = intern.vchanged_page;
const mmove = intern.mmove;
const mcpy = intern.mcpy;
const joe_malloc = intern.joe_malloc;
const joe_free = intern.joe_free;
const berror = &intern.berror;
const force = &intern.force;
const nodeadjoe = &intern.nodeadjoe;
const break_links = &intern.break_links;
const break_symlinks = &intern.break_symlinks;
const guesscrlf = &intern.guesscrlf;
const guessindent = &intern.guessindent;
const guess_utf16 = &intern.guess_utf16;
const found_space = &intern.found_space;
const found_tab = &intern.found_tab;
const setopt = intern.setopt;
const time = intern.time;
const strcmp = intern.strcmp;

const pdup_ = pointer.pdup_;
const prm = pointer.prm;
const pnext_ = pointer.pnext_;
const pfwrd_ = pointer.pfwrd_;
const pgetc_ = pointer.pgetc_;
const prgetc_ = pointer.prgetc_;
const p_goto_bol = pointer.p_goto_bol;
const pline_ = pointer.pline;
const brc_ = pointer.brc_;
const brmem = pointer.brmem;
const bmk = buffer.bmk;
const bmkchn = buffer.bmkchn;

// ═══════════════════════════════════════════════════════════════════════
// Extern C functions / globals
// ═══════════════════════════════════════════════════════════════════════

extern fn joe_read(fd: c_int, buf: ?*anyopaque, siz: isize) isize;
extern fn joe_write(fd: c_int, buf: ?*const anyopaque, siz: isize) isize;
extern fn mcnt(blk: ?*const anyopaque, c: u8, len: isize) isize;
extern fn open(path: [*c]const u8, flags: c_int, ...) c_int;
extern fn close(fd: c_int) c_int;
extern fn lseek(fd: c_int, offset: i64, whence: c_int) i64;
extern fn unlink(path: [*c]const u8) c_int;
extern fn creat(path: [*c]const u8, mode: c_uint) c_int;
extern fn fopen(path: [*c]const u8, mode: [*c]const u8) ?*anyopaque;
extern fn fclose(f: ?*anyopaque) c_int;
extern fn fdopen(fd: c_int, mode: [*c]const u8) ?*anyopaque;
extern fn fileno(f: ?*anyopaque) c_int;
extern fn fflush(f: ?*anyopaque) c_int;
extern fn fprintf(f: ?*anyopaque, fmt: [*c]const u8, ...) c_int;
extern fn fputs(s: [*c]const u8, f: ?*anyopaque) c_int;
extern fn fstat(fd: c_int, buf: *struct_stat) c_int;
extern fn stat(path: [*c]const u8, buf: *struct_stat) c_int;
extern fn lstat(path: [*c]const u8, buf: *struct_stat) c_int;
extern fn fchmod(fd: c_int, mode: c_uint) c_int;
extern fn access(path: [*c]const u8, mode: c_int) c_int;
extern fn symlink(target: [*c]const u8, linkpath: [*c]const u8) c_int;
extern fn readlink(path: [*c]const u8, buf: [*c]u8, sz: usize) isize;
extern fn geteuid() c_uint;
extern fn getpid() c_int;
extern fn ctime(t: ?*const i64) [*c]const u8;
extern fn _exit(status: c_int) noreturn;
extern fn pipe(fds: [*c]c_int) c_int;
extern fn fork() c_int;
extern fn dup2(o: c_int, n: c_int) c_int;
extern fn execlp(file: [*c]const u8, arg: [*c]const u8, ...) c_int;
extern fn wait(s: [*c]c_int) c_int;
extern fn signrm() void;
extern fn getenv(name: [*c]const u8) ?*anyopaque;
extern fn getpwnam(name: [*c]const u8) ?*struct_passwd;
const struct_passwd = switch (builtin.os.tag) {
    .macos => extern struct {
        pw_name: [*c]u8 = null,
        pw_passwd: [*c]u8 = null,
        pw_uid: c_uint = 0,
        pw_gid: c_uint = 0,
        pw_change: time_t_joe = 0,
        pw_class: [*c]u8 = null,
        pw_gecos: [*c]u8 = null,
        pw_dir: [*c]u8 = null,
        pw_shell: [*c]u8 = null,
        pw_expire: time_t_joe = 0,
    },
    else => extern struct {
        pw_name: [*c]u8 = null,
        pw_passwd: [*c]u8 = null,
        pw_uid: c_uint = 0,
        pw_gid: c_uint = 0,
        pw_gecos: [*c]u8 = null,
        pw_dir: [*c]u8 = null,
        pw_shell: [*c]u8 = null,
    },
};

extern fn utf16_init(sm: ?*anyopaque) void;
extern fn utf16_decode(sm: ?*anyopaque, w: c_int) c_int;
extern fn utf16r_decode(sm: ?*anyopaque, w: c_int) c_int;
extern fn utf8_encode(buf: [*c]u8, c: c_int) isize;
extern fn utf16_encode(buf: [*c]u8, c: c_int) isize;
extern fn utf16r_encode(buf: [*c]u8, c: c_int) isize;

extern fn zcmp(a: ?*const anyopaque, b: ?*const anyopaque) c_int;
extern fn match_default_security_context(from_file: [*c]const u8) c_int;
extern fn reset_default_security_context() c_int;
extern fn zdup(s: ?*const anyopaque) ?*anyopaque;
extern fn ztoo(s: [*c]const u8) i64;
extern fn skip_digits(s: [*c]const u8) [*c]const u8;
extern fn vsncpy(a: ?*anyopaque, pos: isize, s: ?*const anyopaque, len: isize) ?*anyopaque;
extern fn vsmk(len: isize) ?*anyopaque;
extern fn vsrm(s: ?*anyopaque) void;
extern fn vsadd(a: ?*anyopaque, c: u8) ?*anyopaque;
extern fn slen(s: ?*const anyopaque) isize;
extern fn dirprt(path: ?*const anyopaque) ?*anyopaque;
extern fn namprt(path: ?*const anyopaque) ?*anyopaque;
extern fn joesep(s: ?*const anyopaque) void;
extern fn snprintf(buf: [*c]u8, sz: usize, fmt: [*c]const u8, ...) c_int;

extern var locale_map: ?*anyopaque;
extern var utf16_map: ?*types.Charmap;
extern var utf16r_map: ?*types.Charmap;
extern fn find_charmap(name: [*c]const u8) ?*types.Charmap;
extern fn guess_map(buf: ?*const anyopaque, len: isize) ?*types.Charmap;
extern fn nescape(t: ?*anyopaque) void;
extern fn nreturn(t: ?*anyopaque) void;
extern fn ttclsn() void;
extern fn ttopnn() void;
extern var maint: ?*anyopaque;

const O_RDWR: c_int = 2;
const O_CREAT: c_int = 0x40;
const O_EXCL: c_int = 0x80;
const O_APPEND: c_int = 0x400;
const MAXOFF: i64 = std.math.maxInt(u64) / 2 - 1;
const CANFLAG_NORESTART: c_int = 1;
const S_IRUSR: c_uint = 0x100;
const S_IWUSR: c_uint = 0x80;
const ENOENT: c_int = 2;
const EEXIST: c_int = 17;

// Typed stat/passwd layouts matching the OS ABI (verified via offsetof probe:
// Darwin struct stat is 144 bytes with st_mtimespec.tv_sec at offset 48;
// struct passwd.pw_dir sits at offset 48). Undersized fakes smash stacks when
// passed to libc fstat/lstat/stat — keep these in sync per-platform.
const time_t_joe = i64;
const struct_timespec_joe = extern struct {
    tv_sec: time_t_joe = 0,
    tv_nsec: c_long = 0,
};
const struct_stat = switch (builtin.os.tag) {
    .macos => extern struct {
        st_dev: c_uint = 0,
        st_mode: c_ushort = 0,
        st_nlink: c_ushort = 0,
        st_ino: u64 = 0,
        st_uid: c_uint = 0,
        st_gid: c_uint = 0,
        st_rdev: c_uint = 0,
        st_atimespec: struct_timespec_joe = .{},
        st_mtimespec: struct_timespec_joe = .{},
        st_ctimespec: struct_timespec_joe = .{},
        st_birthtimespec: struct_timespec_joe = .{},
        st_size: i64 = 0,
        st_blocks: i64 = 0,
        st_blksize: c_int = 0,
        st_flags: c_uint = 0,
        st_gen: c_uint = 0,
        st_lspare: c_int = 0,
        st_qspare: [2]i64 = .{ 0, 0 },
    },
    else => extern struct {
        st_dev: u64 = 0,
        st_ino: u64 = 0,
        st_nlink: u64 = 0,
        st_mode: c_uint = 0,
        st_uid: c_uint = 0,
        st_gid: c_uint = 0,
        __pad0: c_int = 0,
        st_rdev: u64 = 0,
        st_size: i64 = 0,
        st_blksize: c_long = 0,
        st_blocks: i64 = 0,
        st_atim: struct_timespec_joe = .{},
        st_mtim: struct_timespec_joe = .{},
        st_ctim: struct_timespec_joe = .{},
        __unused: [3]c_long = .{ 0, 0, 0 },
    },
};
fn stat_mtime(sbuf: *const struct_stat) i64 {
    return if (builtin.os.tag == .macos)
        sbuf.st_mtimespec.tv_sec
    else
        sbuf.st_mtim.tv_sec;
}

// Darwin: __error() returns int*; Linux: __errno_location().
// Declaring __error as a variable (old bug) never yields real errno, so ENOENT
// on a missing path was misreported as "Error opening file" instead of "New File".
const builtin = @import("builtin");
const errno_fn = if (builtin.os.tag == .linux)
    struct {
        extern fn __errno_location() [*c]c_int;
        fn get() c_int {
            return __errno_location().*;
        }
    }
else
    struct {
        extern fn __error() [*c]c_int;
        fn get() c_int {
            return __error().*;
        }
    };
fn errno_() c_int {
    return errno_fn.get();
}

// Cast an opaque C string pointer to [*c]const u8 for libc calls.
fn dq(s: ?*const anyopaque) [*c]const u8 {
    return @ptrCast(dequote(s));
}
fn C(p: ?*anyopaque) [*c]const u8 {
    return @ptrCast(p);
}
fn Cm(p: ?*anyopaque) [*c]u8 {
    return @ptrCast(p);
}

// ═══════════════════════════════════════════════════════════════════════
// bkread — read up to `size` bytes, set berror
// ═══════════════════════════════════════════════════════════════════════

fn bkread_(fi: c_int, buf: [*]u8, size: isize) isize {
    if (size == 0) {
        berror.* = 0;
        return 0;
    }
    var a: isize = 0;
    var b: isize = 0;
    while (a < size) {
        b = joe_read(fi, @ptrCast(buf + @as(usize, @intCast(a))), size - a);
        if (b <= 0) break;
        a += b;
    }
    berror.* = if (b < 0) -2 else 0;
    return a;
}

// ═══════════════════════════════════════════════════════════════════════
// UTF-16 detection
// ═══════════════════════════════════════════════════════════════════════

fn detect_utf16(inbuf: [*c]const u16, amnt_in: isize) c_int {
    var amnt = amnt_in;
    var len: isize = 0;
    if (amnt > 300) amnt = 300;
    var x: isize = 0;
    while (x < amnt) : (x += 1) {
        const c = inbuf[@as(usize, @intCast(x))];
        if (c == 0x000A) {
            if (len > 3 and len < 120) return 1;
            len = 0;
        } else if (c != 0x000D and c != 0x0009 and c < 0x0020) {
            return 0;
        } else {
            len += 1;
        }
    }
    return 0;
}

fn detect_utf16r(inbuf: [*c]const u16, amnt_in: isize) c_int {
    var amnt = amnt_in;
    var len: isize = 0;
    if (amnt > 300) amnt = 300;
    var x: isize = 0;
    while (x < amnt) : (x += 1) {
        var c = inbuf[@as(usize, @intCast(x))];
        c = @as(u16, @truncate((@as(c_uint, c) << 8) | (@as(c_uint, c) >> 8)));
        if (c == 0x000A) {
            if (len > 3 and len < 120) return 1;
            len = 0;
        } else if (c != 0x000D and c != 0x0009 and c < 0x0020) {
            return 0;
        } else {
            len += 1;
        }
    }
    return 0;
}

// ═══════════════════════════════════════════════════════════════════════
// bread — read up to `max` bytes from fd into a new buffer
// ═══════════════════════════════════════════════════════════════════════

pub export fn bread(fi: c_int, max: i64, binary: c_int) ?*B {
    var anchor: H = undefined;
    izque(Hlink(&anchor));
    var lines: i64 = 0;
    var total: i64 = 0;
    berror.* = 0;
    var type_: c_int = 0;

    var l: *H = halloc();
    var seg: ?*anyopaque = vlock(intern.vmem, l.seg);
    var max_rem = max;

    // `pending` holds a chunk already loaded into `seg` (UTF-16 detect fallback).
    var pending: isize = -1;
    var done = false;

    if (binary == 0 and guess_utf16.* != 0) {
        var inbuf: [SEGSIZ]u8 = undefined;
        const to_read: i64 = if (max_rem >= SEGSIZ) SEGSIZ else max_rem;
        const amnt = bkread_(fi, &inbuf, @as(isize, @intCast(to_read)));
        if (berror.* != 0 and amnt == 0) {
            done = true;
        } else if (detect_utf16(@ptrCast(@alignCast(&inbuf)), amnt >> 1) != 0) {
            type_ = 2;
            recode_utf16(fi, &inbuf, amnt, seg, &l, &total, &lines, &max_rem, false, &anchor);
            done = true;
        } else if (detect_utf16r(@ptrCast(@alignCast(&inbuf)), amnt >> 1) != 0) {
            type_ = 3;
            recode_utf16(fi, &inbuf, amnt, seg, &l, &total, &lines, &max_rem, true, &anchor);
            done = true;
        } else {
            const cpy: i64 = if (max_rem >= SEGSIZ) SEGSIZ else max_rem;
            _ = mcpy(seg, @ptrCast(&inbuf), @as(isize, @intCast(cpy)));
            pending = amnt;
        }
    }

    if (!done) {
        // Process any pending first chunk, then read the rest.
        while (true) {
            var amnt: isize = 0;
            if (pending >= 0) {
                amnt = pending;
                pending = -1;
            } else {
                // Allocate a fresh segment and read into it.
                l = halloc();
                seg = vlock(intern.vmem, l.seg);
                const to_read: i64 = if (max_rem >= SEGSIZ) SEGSIZ else if (max_rem > 0) max_rem else 0;
                if (to_read == 0) break;
                amnt = bkread_(fi, @as([*]u8, @ptrCast(seg)), @as(isize, @intCast(to_read)));
                if (berror.* != 0 or amnt == 0) break;
            }
            total += amnt;
            max_rem -= amnt;
            l.hole = @as(i16, @intCast(amnt));
            const nl = mcnt(seg, '\n', amnt);
            l.nlines = @as(i16, @intCast(nl));
            lines += nl;
            vchanged_page(seg);
            vunlock_page(seg);
            enqueb_(Hlink(&anchor), Hlink(l));
            if (max_rem <= 0) {
                // Allocate one more (as C does) so `done:` frees the empty tail.
                l = halloc();
                seg = vlock(intern.vmem, l.seg);
                break;
            }
        }
    }

    // done:
    hfree(l);
    if (seg) |s| vunlock_page(s);

    if (total == 0) return bmk(null);

    const result_h = link2H(@ptrCast(@alignCast(anchor.link.next.?)));
    deque_(Hlink(&anchor));
    const b = bmkchn(result_h, null, total, lines);

    if (type_ == 2) {
        b.o.charmap = utf16_map;
    } else if (type_ == 3) {
        b.o.charmap = utf16r_map;
    } else if (binary == 0) {
        var gbuf: [1024]u8 = undefined;
        var glen: isize = @sizeOf(@TypeOf(gbuf));
        if (b.eof.?.byte < glen) glen = @as(isize, @intCast(b.eof.?.byte));
        _ = brmem(b.bof, @ptrCast(&gbuf), glen);
        b.o.charmap = guess_map(@ptrCast(&gbuf), glen);
        // C: b->o.map_name = b->o.charmap->name;
        b.o.map_name = charmapName(b.o.charmap);
    } else {
        b.o.charmap = find_charmap("ascii");
        b.o.map_name = charmapName(b.o.charmap);
        b.o.hex = 1;
    }
    return b;
}

/// Read `struct charmap::name` without pulling the full charmap ABI into types.zig.
fn charmapName(cm: ?*types.Charmap) ?*anyopaque {
    return if (cm) |p| @ptrCast(@constCast(p.name)) else null;
}

fn recode_utf16(
    fi: c_int,
    inbuf: *[SEGSIZ]u8,
    amnt_first: isize,
    seg_in: ?*anyopaque,
    l_ptr: **H,
    total: *i64,
    lines: *i64,
    max_remaining: *i64,
    rev: bool,
    anchor: *H,
) void {
    _ = seg_in;
    var sm: [4]u8 = undefined;
    utf16_init(@ptrCast(&sm));
    var outbuf: [SEGSIZ + 8]u8 = undefined;
    var y: isize = 0;
    var l = l_ptr.*;
    var seg = vlock(intern.vmem, l.seg);
    var inbuf_local: [SEGSIZ]u8 = inbuf.*;
    var amnt: isize = amnt_first;

    while (berror.* == 0 and amnt > 0) {
        var x: isize = 0;
        while (x + 1 < amnt) : (x += 2) {
            const wp = @as([*]const u16, @ptrCast(@alignCast(@as([*]const u8, @ptrCast(&inbuf_local)) + @as(usize, @intCast(x)))));
            const c = if (rev) utf16r_decode(@ptrCast(&sm), @as(c_int, wp[0])) else utf16_decode(@ptrCast(&sm), @as(c_int, wp[0]));
            if (c >= 0) y += utf8_encode(@ptrCast(&outbuf[@as(usize, @intCast(y))]), c);
            if (y >= SEGSIZ) {
                _ = mcpy(seg, @ptrCast(&outbuf), SEGSIZ);
                total.* += SEGSIZ;
                l.hole = SEGSIZ;
                const nl = mcnt(seg, '\n', SEGSIZ);
                l.nlines = @as(i16, @intCast(nl));
                lines.* += nl;
                vchanged_page(seg);
                vunlock_page(seg);
                enqueb_(Hlink(anchor), Hlink(l));
                l = halloc();
                seg = vlock(intern.vmem, l.seg);
                _ = mmove(@ptrCast(&outbuf), @ptrCast(&outbuf[SEGSIZ]), y - SEGSIZ);
                y -= SEGSIZ;
            }
        }
        max_remaining.* -= x;
        const to_read: i64 = if (max_remaining.* >= SEGSIZ) SEGSIZ else max_remaining.*;
        amnt = bkread_(fi, &inbuf_local, @as(isize, @intCast(to_read)));
    }
    if (y > 0) {
        _ = mcpy(seg, @ptrCast(&outbuf), y);
        total.* += y;
        l.hole = @as(i16, @intCast(y));
        const nl = mcnt(seg, '\n', y);
        l.nlines = @as(i16, @intCast(nl));
        lines.* += nl;
        vchanged_page(seg);
        vunlock_page(seg);
        enqueb_(Hlink(anchor), Hlink(l));
        l = halloc();
        seg = vlock(intern.vmem, l.seg);
    }
    l_ptr.* = l;
}

// ═══════════════════════════════════════════════════════════════════════
// parsens / canonical / dequote / hack_check
// ═══════════════════════════════════════════════════════════════════════

pub export fn parsens(s: [*c]const u8, skip: ?*i64, amnt: ?*i64, binary: ?*c_int) ?*anyopaque {
    if (skip) |p| p.* = 0;
    if (amnt) |p| p.* = MAXOFF;
    if (binary) |p| p.* = 0;
    const n = vsncpy(vsmk(0), 0, @ptrCast(s), intern.zlen(@ptrCast(s)));
    const nlen = intern.zlen(n);
    if (nlen > 1) {
        const np = @as([*c]u8, @ptrCast(n));
        var x = nlen - 1;
        while (x > 0 and np[@as(usize, @intCast(x))] != ',') : (x -= 1) {}
        if (np[@as(usize, @intCast(x))] == ',' and x > 0 and np[@as(usize, @intCast(x - 1))] != '\\' and
            skip_digits(@ptrCast(&np[@as(usize, @intCast(x + 1))])) == @as([*c]const u8, @ptrCast(np)) + @as(usize, @intCast(nlen)))
        {
            binary.?.* = 1;
            np[@as(usize, @intCast(x))] = 0;
            if (skip) |p| p.* = ztoo(@ptrCast(&np[@as(usize, @intCast(x + 1))]));
            const y = x;
            if (x > 0) {
                x -= 1;
                while (x > 0 and np[@as(usize, @intCast(x))] != ',') : (x -= 1) {}
                if (np[@as(usize, @intCast(x))] == ',' and x > 0 and np[@as(usize, @intCast(x - 1))] != '\\' and
                    skip_digits(@ptrCast(&np[@as(usize, @intCast(x + 1))])) == @as([*c]const u8, @ptrCast(np)) + @as(usize, @intCast(y)))
                {
                    np[@as(usize, @intCast(x))] = 0;
                    if (amnt) |p| p.* = skip.?.*;
                    if (skip) |p| p.* = ztoo(@ptrCast(&np[@as(usize, @intCast(x + 1))]));
                }
            }
        }
    }
    return n;
}

pub export fn canonical(n_in: ?*anyopaque, flags: c_int) ?*anyopaque {
    const n = @as([*c]u8, @ptrCast(n_in));
    var y: isize = 0;
    if ((flags & CANFLAG_NORESTART) == 0) {
        y = intern.zlen(@ptrCast(n));
        while (true) {
            if (y <= 2) {
                y = 0;
                break;
            } else if (n[@as(usize, @intCast(y - 2))] == '/' and (n[@as(usize, @intCast(y - 1))] == '/' or n[@as(usize, @intCast(y - 1))] == '~')) {
                y -= 1;
                break;
            }
            y -= 1;
        }
    }
    if (n[@as(usize, @intCast(y))] == '~') {
        var x = y + 1;
        while (n[@as(usize, @intCast(x))] != 0 and n[@as(usize, @intCast(x))] != '/') : (x += 1) {}
        if (n[@as(usize, @intCast(x))] == '/') {
            if (x == y + 1) {
                const home = getenv("HOME") orelse return n_in;
                var z = vsncpy(vsmk(0), 0, home, intern.zlen(home));
                z = vsncpy(z, intern.zlen(z), @ptrCast(&n[@as(usize, @intCast(x))]), intern.zlen(@ptrCast(&n[@as(usize, @intCast(x))])));
                vsrm(@ptrCast(n));
                return z;
            } else {
                n[@as(usize, @intCast(x))] = 0;
                const pw = getpwnam(@ptrCast(&n[@as(usize, @intCast(y + 1))]));
                n[@as(usize, @intCast(x))] = '/';
                if (pw) |p| {
                    const dir = p.pw_dir orelse return n_in;
                    var z = vsncpy(vsmk(0), 0, dir, intern.zlen(dir));
                    z = vsncpy(z, intern.zlen(z), @ptrCast(&n[@as(usize, @intCast(x))]), intern.zlen(@ptrCast(&n[@as(usize, @intCast(x))])));
                    vsrm(@ptrCast(n));
                    return z;
                }
            }
        }
    }
    if (y != 0) {
        const z = vsncpy(vsmk(0), 0, @ptrCast(&n[@as(usize, @intCast(y))]), intern.zlen(@ptrCast(&n[@as(usize, @intCast(y))])));
        vsrm(@ptrCast(n));
        return z;
    }
    return n_in;
}

pub export fn dequote(s_in: ?*const anyopaque) ?*anyopaque {
    var s = @as([*c]const u8, @ptrCast(s_in));
    var buf: ?*anyopaque = vsmk(32);
    while (s[0] != 0) {
        if (s[0] == '\\') s += 1;
        if (s[0] != 0) {
            buf = vsadd(buf, s[0]);
            s += 1;
        }
    }
    return buf;
}

pub export fn hack_check(name: [*c]const u8) c_int {
    if (name[0] == '!') return 1;
    if (name[0] == '>' and name[1] == '>') return 1;
    return 0;
}

// ═══════════════════════════════════════════════════════════════════════
// joe_popen / joe_pclose
// ═══════════════════════════════════════════════════════════════════════

fn joe_popen(s: [*c]const u8, write_mode: c_int) ?*anyopaque {
    var fds: [2]c_int = undefined;
    if (pipe(&fds) == -1) return null;
    if (fork() == 0) {
        signrm();
        if (write_mode != 0) {
            if (dup2(fds[0], 0) == -1) _exit(1);
        } else {
            if (dup2(fds[1], 1) == -1) _exit(1);
        }
        _ = close(fds[0]);
        _ = close(fds[1]);
        _ = execlp("/bin/sh", "/bin/sh", "-c", s, @as(?*const anyopaque, null));
        _exit(0);
    }
    if (write_mode != 0) {
        _ = close(fds[0]);
        return fdopen(fds[1], "w");
    } else {
        _ = close(fds[1]);
        return fdopen(fds[0], "r");
    }
}

fn joe_pclose(f: ?*anyopaque) void {
    _ = fclose(f);
    var s: c_int = 0;
    _ = wait(&s);
}

// ═══════════════════════════════════════════════════════════════════════
// bload
// ═══════════════════════════════════════════════════════════════════════

pub export fn bload(s_in: [*c]const u8) ?*B {
    var buf_: [SEGSIZ]u8 = undefined;
    var fi: ?*anyopaque = null;
    var b: ?*B = null;
    var skip: i64 = 0;
    var amnt: i64 = 0;
    var binary: c_int = 0;
    var nowrite: c_int = 0;
    var mod_time: i64 = 0;
    var sbuf: struct_stat = .{};
    berror.* = 0;
    const s = s_in;

    if (s[0] == 0) {
        berror.* = -1;
        b = bmk(null);
        setopt(@ptrCast(b.?), "");
        b.?.rdonly = b.?.o.readonly;
        b.?.er = berror.*;
        return b;
    }

    const n = parsens(s, &skip, &amnt, &binary);
    const np = @as([*c]const u8, @ptrCast(n));

    if (np[0] == '!') {
        nescape(maint);
        ttclsn();
        fi = joe_popen(np + 1, 0);
    } else if (strcmp(np, "-") == 0) {
        b = bmk(null);
        return bload_finish(b, n, s, mod_time, binary, skip, amnt, nowrite);
    } else {
        if (access(@ptrCast(dequote(@ptrCast(np))), 2) != 0) nowrite = 1;
        fi = fopen(dq(@ptrCast(np)), "r");
        if (fi == null) nowrite = 0;
        if (fi) |f| {
            if (fstat(fileno(f), &sbuf) == 0) {
                mod_time = read_mtime(&sbuf);
            }
        }
    }

    joesep(@ptrCast(np));
    if (fi == null) {
        if (errno_() == ENOENT) berror.* = -1 else berror.* = -4;
        b = bmk(null);
        setopt(@ptrCast(b.?), @ptrCast(np));
        b.?.rdonly = b.?.o.readonly;
        return bload_opnerr(b, n, s);
    }

    if (skip != 0 and lseek(fileno(fi), skip, 0) < 0) {
        var r: isize = 0;
        while (skip > SEGSIZ) {
            r = bkread_(fileno(fi), &buf_, SEGSIZ);
            if (r != SEGSIZ or berror.* != 0) {
                berror.* = -3;
                return bload_err(b, fi, n, s);
            }
            skip -= SEGSIZ;
        }
        skip -= bkread_(fileno(fi), &buf_, @as(isize, @intCast(skip)));
        if (skip != 0 or berror.* != 0) {
            berror.* = -3;
            return bload_err(b, fi, n, s);
        }
    }

    b = bread(fileno(fi), amnt, binary);
    return bload_finish(b, n, s, mod_time, binary, skip, amnt, nowrite);
}

fn read_mtime(sbuf: *const struct_stat) i64 {
    return stat_mtime(sbuf);
}

fn bload_finish(b_in: ?*B, n: ?*anyopaque, s: [*c]const u8, mod_time: i64, binary: c_int, skip: i64, amnt: i64, nowrite: c_int) ?*B {
    const b = b_in;
    if (b) |bp| {
        bp.mod_time = mod_time;
        setopt(@ptrCast(bp), @ptrCast(n));
        bp.rdonly = bp.o.readonly;
    }
    const bval = b orelse return null;
    if (berror.* != 0 or s[0] == '!' or skip != 0 or amnt != MAXOFF or binary != 0) {
        bval.backup = 1;
        bval.changed = 0;
    } else if (strcmp(@ptrCast(n), "-") == 0) {
        bval.backup = 1;
        bval.changed = 1;
    } else {
        bval.backup = 0;
        bval.changed = 0;
    }
    if (nowrite != 0) {
        bval.rdonly = 1;
        bval.o.readonly = 1;
    }
    bval.name = zdup(@ptrCast(s));
    joesep(bval.name);
    vsrm(n);
    bval.er = berror.*;
    return b;
}

fn bload_err(b: ?*B, fi: ?*anyopaque, n: ?*anyopaque, s: [*c]const u8) ?*B {
    if (s[0] == '!') {
        joe_pclose(fi);
    } else if (strcmp(@ptrCast(n), "-") != 0) {
        _ = fclose(fi);
    }
    return bload_opnerr(b, n, s);
}

fn bload_opnerr(b_in: ?*B, n: ?*anyopaque, s: [*c]const u8) ?*B {
    const b = b_in orelse {
        vsrm(n);
        return null;
    };
    if (s[0] == '!') {
        ttopnn();
        nreturn(maint);
    }
    b.name = zdup(@ptrCast(s));
    joesep(b.name);
    b.er = berror.*;
    vsrm(n);
    return b;
}

// ═══════════════════════════════════════════════════════════════════════
// bfind family
// ═══════════════════════════════════════════════════════════════════════

pub export fn bfind(s: [*c]const u8) ?*B {
    _ = intern.ensureBufs();
    if (s[0] == 0) {
        berror.* = -1;
        const b = bmk(null);
        setopt(@ptrCast(b), "");
        b.rdonly = b.o.readonly;
        b.internal = 0;
        b.er = berror.*;
        return b;
    }
    var b = link2B(@ptrCast(@alignCast(intern.bufs.link.next.?)));
    while (!ptrEq(b, &intern.bufs)) : (b = link2B(@ptrCast(@alignCast(b.link.next.?)))) {
        if (b.name != null and strcmp(@ptrCast(b.name), s) == 0) {
            if (b.orphan == 0) b.count += 1 else b.orphan = 0;
            berror.* = 0;
            b.internal = 0;
            return b;
        }
    }
    b = bload(s).?;
    b.internal = 0;
    return b;
}

pub export fn bfind_scratch(s: [*c]const u8) ?*B {
    _ = intern.ensureBufs();
    if (s[0] == 0) {
        berror.* = -1;
        const b = bmk(null);
        setopt(@ptrCast(b), "");
        b.rdonly = b.o.readonly;
        b.internal = 0;
        b.er = berror.*;
        return b;
    }
    var b = link2B(@ptrCast(@alignCast(intern.bufs.link.next.?)));
    while (!ptrEq(b, &intern.bufs)) : (b = link2B(@ptrCast(@alignCast(b.link.next.?)))) {
        if (b.scratch != 0 and b.name != null and strcmp(@ptrCast(b.name), s) == 0) {
            if (b.orphan == 0) b.count += 1 else b.orphan = 0;
            berror.* = 0;
            b.internal = 0;
            return b;
        }
    }
    b = bmk(null);
    berror.* = -1;
    setopt(@ptrCast(b), s);
    b.internal = 0;
    b.rdonly = b.o.readonly;
    b.er = berror.*;
    b.name = zdup(@ptrCast(s));
    b.scratch = 1;
    return b;
}

pub export fn bfind_reload(s: [*c]const u8) ?*B {
    const b = bload(s).?;
    b.internal = 0;
    return b;
}

pub export fn bcheck_loaded(s: [*c]const u8) ?*B {
    _ = intern.ensureBufs();
    if (s[0] == 0) return null;
    var b = link2B(@ptrCast(@alignCast(intern.bufs.link.next.?)));
    while (!ptrEq(b, &intern.bufs)) : (b = link2B(@ptrCast(@alignCast(b.link.next.?)))) {
        if (b.name != null and strcmp(@ptrCast(b.name), s) == 0) return b;
    }
    return null;
}

pub export fn getbufs() ?*anyopaque {
    _ = intern.ensureBufs();
    var result: ?*anyopaque = null;
    var b = link2B(@ptrCast(@alignCast(intern.bufs.link.next.?)));
    while (!ptrEq(b, &intern.bufs)) : (b = link2B(@ptrCast(@alignCast(b.link.next.?)))) {
        if (b.name != null and b.internal == 0) {
            const tmp = vsncpy(vsmk(0), 0, b.name, intern.zlen(b.name));
            result = @import("../va.zig").vaadd(result, tmp);
        }
    }
    return result;
}

// ═══════════════════════════════════════════════════════════════════════
// bsavefd / bsavefd_utf16 / bsave
// ═══════════════════════════════════════════════════════════════════════

pub export fn bsavefd(p: ?*P, fd: c_int, size: i64) c_int {
    const np = pdup_(p.?, "bsavefd");
    var remaining = size;
    while (remaining > @as(i64, @intCast(gsize_(np.hdr.?) - np.ofst))) {
        const amnt: i16 = gsize_(np.hdr.?) - np.ofst;
        if (np.ofst < np.hdr.?.hole) {
            if (joe_write(fd, @ptrFromInt(@intFromPtr(np.ptr) + @as(usize, @intCast(np.ofst))), np.hdr.?.hole - np.ofst) < 0) return bsavefd_err(np);
            if (joe_write(fd, @ptrFromInt(@intFromPtr(np.ptr) + @as(usize, @intCast(np.hdr.?.ehole))), SEGSIZ - np.hdr.?.ehole) < 0) return bsavefd_err(np);
        } else if (joe_write(fd, @ptrFromInt(@intFromPtr(np.ptr) + @as(usize, @intCast(np.ofst + (np.hdr.?.ehole - np.hdr.?.hole)))), amnt) < 0) {
            return bsavefd_err(np);
        }
        remaining -= amnt;
        _ = pnext_(np);
    }
    if (remaining > 0) {
        if (np.ofst < np.hdr.?.hole) {
            if (remaining > np.hdr.?.hole - np.ofst) {
                if (joe_write(fd, @ptrFromInt(@intFromPtr(np.ptr) + @as(usize, @intCast(np.ofst))), np.hdr.?.hole - np.ofst) < 0) return bsavefd_err(np);
                if (joe_write(fd, @ptrFromInt(@intFromPtr(np.ptr) + @as(usize, @intCast(np.hdr.?.ehole))), remaining - (np.hdr.?.hole - np.ofst)) < 0) return bsavefd_err(np);
            } else {
                if (joe_write(fd, @ptrFromInt(@intFromPtr(np.ptr) + @as(usize, @intCast(np.ofst))), remaining) < 0) return bsavefd_err(np);
            }
        } else {
            if (joe_write(fd, @ptrFromInt(@intFromPtr(np.ptr) + @as(usize, @intCast(np.ofst + (np.hdr.?.ehole - np.hdr.?.hole)))), remaining) < 0) return bsavefd_err(np);
        }
    }
    prm(np);
    berror.* = 0;
    return 0;
}

fn bsavefd_err(np: *P) c_int {
    prm(np);
    berror.* = -5;
    return -5;
}

fn bsavefd_utf16(p: ?*P, fd: c_int, size: i64, rev: c_int) c_int {
    const np = pdup_(p.?, "bsavefd");
    var buf: [SEGSIZ + 8]u8 = undefined;
    const e = np.byte + size;
    var y: isize = 0;
    while (np.byte < e) {
        const c = pgetc_(np);
        if (c == NO_MORE_DATA) break;
        const n: isize = if (rev != 0) utf16r_encode(@ptrCast(&buf[@as(usize, @intCast(y))]), c) else utf16_encode(@ptrCast(&buf[@as(usize, @intCast(y))]), c);
        if (n >= 0) y += n;
        if (y >= SEGSIZ) {
            if (joe_write(fd, @ptrCast(&buf), y) < 0) return bsavefd_err(np);
            y = 0;
        }
    }
    if (y > 0 and joe_write(fd, @ptrCast(&buf), y) < 0) return bsavefd_err(np);
    prm(np);
    berror.* = 0;
    return 0;
}

pub export fn bsave(p: ?*P, as: [*c]const u8, size_in: i64, flag: c_int) c_int {
    var sbuf: struct_stat = .{};
    var have_stat: c_int = 0;
    var norm: c_int = 0;
    var skip: i64 = 0;
    var amnt: i64 = 0;
    var binary: c_int = 0;
    var size = size_in;
    const pp = p.?;

    const n = parsens(as, &skip, &amnt, &binary);
    const s = @as([*c]const u8, @ptrCast(n));
    if (amnt < size) size = amnt;

    var f: ?*anyopaque = null;
    if (s[0] == '!') {
        nescape(maint);
        ttclsn();
        f = joe_popen(s + 1, 1);
    } else if (s[0] == '>' and s[1] == '>') {
        f = fopen(dq(@ptrCast(s + 2)), "a");
    } else if (strcmp(s, "-") == 0) {
        nescape(maint);
        ttclsn();
        f = fdopen(1, "w");
    } else if (skip != 0 or amnt != MAXOFF) {
        f = fopen(dq(@ptrCast(s)), "r+");
    } else {
        have_stat = if (stat(dq(@ptrCast(s)), &sbuf) == 0) 1 else 0;
        if (have_stat == 0) sbuf.st_mode = 0o666;
        if (break_links.* != 0 or break_symlinks.* != 0) {
            var lsbuf: struct_stat = .{};
            if (lstat(dq(@ptrCast(s)), &lsbuf) == 0) {
                // Preserve SELinux label across unlink+creat (C b.c used getfilecon/
                // setfilecon; helpers are no-ops when SELinux is off).
                _ = match_default_security_context(dq(@ptrCast(s)));
                _ = unlink(dq(@ptrCast(s)));
                const g = creat(dq(@ptrCast(s)), @intCast(sbuf.st_mode & ~@as(c_uint, 0o6000)));
                _ = close(g);
                _ = reset_default_security_context();
            } else {
                _ = unlink(dq(@ptrCast(s)));
            }
        }
        f = fopen(dq(@ptrCast(s)), "w");
        norm = 1;
    }

    joesep(@ptrCast(s));
    if (f == null) {
        berror.* = -4;
        return bsave_opnerr(s);
    }
    _ = fflush(f);

    if (skip != 0 and lseek(fileno(f), skip, 0) < 0) {
        berror.* = -3;
        return bsave_err(f, s);
    }

    if (pp.b.?.o.charmap == utf16_map) {
        _ = bsavefd_utf16(pp, fileno(f), size, 0);
    } else if (pp.b.?.o.charmap == utf16r_map) {
        _ = bsavefd_utf16(pp, fileno(f), size, 1);
    } else {
        _ = bsavefd(pp, fileno(f), size);
    }

    if (berror.* == 0 and force.* != 0 and size != 0 and skip == 0 and amnt == MAXOFF) {
        const q = pdup_(pp, "bsave");
        var nl: u8 = '\n';
        _ = pfwrd_(q, size - 1);
        if (brc_(q) != '\n' and joe_write(fileno(f), @ptrCast(&nl), 1) < 0) berror.* = -5;
        prm(q);
    }

    // Restore setuid/setgid/sticky bits (creat dropped them).
    if (berror.* == 0 and have_stat != 0) {
        _ = fchmod(fileno(f), @intCast(sbuf.st_mode));
    }

    const rv = bsave_err(f, s);

    // Update original date of file (when the buffer was written under its own
    // name, so change notifications compare against the right timestamp).
    if (berror.* == 0 and norm != 0 and flag != 0 and
        (pp.b.?.name == null or flag == 2 or strcmp(s, @ptrCast(pp.b.?.name)) != 0))
    {
        if (stat(dq(@ptrCast(s)), &sbuf) == 0)
            pp.b.?.mod_time = stat_mtime(&sbuf);
    }

    return rv;
}

fn bsave_err(f: ?*anyopaque, s: [*c]const u8) c_int {
    if (s[0] == '!') {
        joe_pclose(f);
    } else if (strcmp(s, "-") != 0) {
        _ = fclose(f);
    } else {
        _ = fflush(f);
    }
    return berror.*;
}

fn bsave_opnerr(s: [*c]const u8) c_int {
    if (s[0] == '!' or strcmp(s, "-") == 0) {
        ttopnn();
        nreturn(maint);
    }
    return berror.*;
}

// ═══════════════════════════════════════════════════════════════════════
// ttsig — emergency save on crash
// ═══════════════════════════════════════════════════════════════════════

var ttsig_handled: c_int = 0;

pub export fn ttsig(sig: c_int) void {
    const tim = time(null);
    if (ttsig_handled != 0) _exit(1);
    ttsig_handled = 1;

    var ttsig_f: ?*anyopaque = null;

    if (nodeadjoe.* == 0) {
        var tmpfd = open("DEADJOE", O_RDWR | O_EXCL | O_CREAT, @as(c_uint, 0o600));
        if (tmpfd < 0) {
            var sbuf: struct_stat = .{};
            if (lstat("DEADJOE", &sbuf) < 0) _exit(1);
            tmpfd = open("DEADJOE", O_RDWR | O_APPEND);
            if (tmpfd < 0) _exit(1);
            if (fchmod(tmpfd, S_IRUSR | S_IWUSR) < 0) _exit(1);
        }
        ttsig_f = fdopen(tmpfd, "a");
        if (ttsig_f == null) _exit(1);

        _ = fprintf(ttsig_f, "\n*** These modified files were found in JOE when it aborted on %s", ctime(&tim));
        if (sig == -2) {
            _ = fprintf(ttsig_f, "*** JOE was aborted due to swap file I/O error\n");
        } else if (sig == -1) {
            _ = fprintf(ttsig_f, "*** JOE was aborted due to malloc returning NULL\n");
        } else if (sig != 0) {
            _ = fprintf(ttsig_f, "*** JOE was aborted by UNIX signal %d\n", sig);
        } else {
            _ = fprintf(ttsig_f, "*** JOE was aborted because the terminal closed\n");
        }
        _ = fflush(ttsig_f);

        var b = link2B(@ptrCast(@alignCast(intern.bufs.link.next.?)));
        while (!ptrEq(b, &intern.bufs)) : (b = link2B(@ptrCast(@alignCast(b.link.next.?)))) {
            if (b.changed != 0) {
                if (b.name) |nm| {
                    _ = fprintf(ttsig_f, "\n*** File '%s'\n", @as([*c]const u8, @ptrCast(nm)));
                } else {
                    _ = fputs("\n*** File '(Unnamed)'\n", ttsig_f);
                }
                _ = fflush(ttsig_f);
                _ = bsavefd(b.bof, fileno(ttsig_f), b.eof.?.byte);
            }
        }
    }

    if (sig != 0) ttclsn();
    {
        const m = "\n*** JOE aborted\n";
        _ = joe_write(2, @ptrCast(m), m.len);
    }
    _exit(1);
}

// ═══════════════════════════════════════════════════════════════════════
// lock_it / unlock_it / plain_file / check_mod / file_exists
// ═══════════════════════════════════════════════════════════════════════

pub export fn lock_it(qpath: [*c]const u8, bf: ?*anyopaque) c_int {
    var lock_name = dirprt(dequote(@ptrCast(qpath)));
    const name = namprt(dequote(@ptrCast(qpath)));
    var buf: [1024]u8 = undefined;
    var user = getenv("USER");
    if (user == null) user = @ptrCast(@constCast(@as([*c]const u8, "me")));
    var host = getenv("HOSTNAME");
    if (host == null) host = @ptrCast(@constCast(@as([*c]const u8, "here")));
    lock_name = vsncpy(lock_name, intern.zlen(lock_name), @ptrCast(@as(*const [3]u8, ".#\x00")), 2);
    lock_name = vsncpy(lock_name, intern.zlen(lock_name), name, intern.zlen(name));
    _ = snprintf(&buf, 1024, "%s@%s.%ld", user, host, @as(c_long, getpid()));
    if (symlink(@ptrCast(&buf), @ptrCast(lock_name)) == 0 or errno_() != EEXIST) {
        vsrm(lock_name);
        vsrm(name);
        return 0;
    }
    if (bf) |b| {
        const bbuf = @as([*c]u8, @ptrCast(b));
        var len = readlink(@ptrCast(lock_name), bbuf, 255);
        if (len < 0) len = 0;
        bbuf[@as(usize, @intCast(len))] = 0;
    }
    vsrm(lock_name);
    vsrm(name);
    return -1;
}

pub export fn unlock_it(qpath: [*c]const u8) void {
    var lock_name = dirprt(dequote(@ptrCast(qpath)));
    const name = namprt(dequote(@ptrCast(qpath)));
    lock_name = vsncpy(lock_name, intern.zlen(lock_name), @ptrCast(@as(*const [3]u8, ".#\x00")), 2);
    lock_name = vsncpy(lock_name, intern.zlen(lock_name), name, intern.zlen(name));
    _ = unlink(@ptrCast(lock_name));
    vsrm(lock_name);
    vsrm(name);
}

pub export fn plain_file(b: ?*B) c_int {
    const bp = b.?;
    if (bp.name != null and strcmp(@ptrCast(bp.name), "-") != 0 and
        @as([*c]const u8, @ptrCast(bp.name))[0] != '!' and
        @as([*c]const u8, @ptrCast(bp.name))[0] != '>' and bp.scratch == 0) return 1;
    return 0;
}

pub export fn check_mod(b: ?*B) c_int {
    const bp = b.?;
    if (plain_file(bp) == 0) return 0;
    var sbuf: struct_stat = .{};
    if (stat(@ptrCast(bp.name), &sbuf) == 0) {
        if (read_mtime(&sbuf) > bp.mod_time) return 1;
    }
    return 0;
}

pub export fn file_exists(path: [*c]const u8) c_int {
    var sbuf: struct_stat = .{};
    return @intFromBool(stat(path, &sbuf) == 0);
}
