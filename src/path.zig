//! Directory and path helpers — replaces `joe/path.c`.
//!
//! Faithful C-ABI Path A port of JOE path/directory helpers (`joesep`/`namprt`/`mkpath`/`mktmp`/`rmatch`/`rexpnd*`/`chpwd`/`pwd`/`xdg_*`/`open_*_file`).

const std = @import("std");
const build_options = @import("build_options");
const ptrdiff_t = c_long;

/// System data/config roots from `-Djoedata=` / `-Djoerc=` (empty → skip, use builtins/XDG).
fn joedataPtr() [*c]const u8 {
    return (build_options.joedata ++ "\x00").ptr;
}
fn joercPtr() [*c]const u8 {
    return (build_options.joerc ++ "\x00").ptr;
}

const X_OK: c_int = 1;
const S_IFMT: c_int = 0o170000;
const S_IFREG: c_int = 0o100000;
const PATH_MAX: c_int = 4096;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn malloc(n: c_ulong) ?*anyopaque;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub extern fn strcpy(d: [*c]u8, s: [*c]const u8) [*c]u8;
pub const off_t = i64;
pub const time_t = i64;
pub const ino_t = u64;
pub const mode_t = c_uint;
pub const struct_timespec_joe = extern struct {
    tv_sec: time_t = 0,
    tv_nsec: c_long = 0,
};
pub const struct_stat = extern struct {
    st_dev: c_uint = 0,
    st_mode: c_ushort = 0,
    st_nlink: c_ushort = 0,
    st_ino: ino_t = 0,
    st_uid: c_uint = 0,
    st_gid: c_uint = 0,
    st_rdev: c_uint = 0,
    _pad_rdev: c_uint = 0,
    st_atimespec: struct_timespec_joe = std.mem.zeroes(struct_timespec_joe),
    st_mtimespec: struct_timespec_joe = std.mem.zeroes(struct_timespec_joe),
    st_ctimespec: struct_timespec_joe = std.mem.zeroes(struct_timespec_joe),
    st_birthtimespec: struct_timespec_joe = std.mem.zeroes(struct_timespec_joe),
    st_size: i64 = 0,
    st_blocks: i64 = 0,
    st_blksize: c_int = 0,
    st_flags: c_uint = 0,
    st_gen: c_uint = 0,
    st_lspare: c_int = 0,
    st_qspare: [2]i64 = std.mem.zeroes([2]i64),
};
pub extern fn stat(path: [*c]const u8, buf: [*c]struct_stat) c_int;
pub extern fn access(path: [*c]const u8, mode: c_int) c_int;
pub extern fn chdir(path: [*c]const u8) c_int;
pub extern fn getcwd(buf: [*c]u8, size: c_ulong) [*c]u8;
pub extern fn mkdir(path: [*c]const u8, mode: mode_t) c_int;
pub extern fn mkstemp(tmpl: [*c]u8) c_int;
pub extern fn fchmod(fd: c_int, mode: mode_t) c_int;
pub extern fn close(fd: c_int) c_int;
pub extern fn open(path: [*c]const u8, flags: c_int, ...) c_int;
pub const struct_DIR = opaque {
};
pub const DIR = struct_DIR;
pub const struct_dirent = extern struct {
    _pad0: [21]u8 = std.mem.zeroes([21]u8),
    d_name: [1027]u8 = std.mem.zeroes([1027]u8),
};
pub extern fn opendir(name: [*c]const u8) ?*DIR;
pub extern fn readdir(dirp: ?*DIR) [*c]struct_dirent;
pub extern fn closedir(dirp: ?*DIR) c_int;
pub const struct_passwd = extern struct {
    pw_name: [*c]u8 = null,
};
pub extern fn getpwent() [*c]struct_passwd;
pub extern fn endpwent() void;
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn vsmk(len: ptrdiff_t) [*c]u8;
pub extern fn vsrm(s: [*c]u8) void;
pub extern fn vsensure(s: [*c]u8, len: ptrdiff_t) [*c]u8;
pub extern fn vsadd(s: [*c]u8, c: u8) [*c]u8;
pub extern fn vsncpy(d: [*c]u8, dlen: ptrdiff_t, s: [*c]const u8, sl: ptrdiff_t) [*c]u8;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn zlcpy(d: [*c]u8, dlen: ptrdiff_t, s: [*c]const u8) [*c]u8;
pub extern fn zncmp(a: [*c]const u8, b: [*c]const u8, n: ptrdiff_t) c_int;
pub extern fn joe_free(p: ?*anyopaque) void;
pub extern fn vaadd(a: [*c][*c]u8, s: [*c]u8) [*c][*c]u8;
pub extern fn varm(a: [*c][*c]u8) void;
pub extern fn vawords(a: [*c][*c]u8, s: [*c]const u8, sl: ptrdiff_t, sep: [*c]const u8, sepl: ptrdiff_t) [*c][*c]u8;
pub const JFILE = anyopaque;
pub extern fn jfopen(name: [*c]const u8, mode: [*c]const u8) ?*anyopaque;
pub extern fn canonical(s: [*c]u8, flags: c_int) [*c]u8;
pub export fn pwd() [*c]u8 {
    const static_local_buf = struct {
        var buf: [4096]u8 = std.mem.zeroes([4096]u8);
    };
    _ = &static_local_buf;
    var ret: [*c]u8 = undefined;
    _ = &ret;
    ret = getcwd(@ptrCast(@alignCast(&static_local_buf.buf)), @bitCast(@as(c_long, PATH_MAX - @as(c_int, 1))));
    static_local_buf.buf[PATH_MAX - @as(c_int, 1)] = '\x00';
    return ret;
}
pub export fn chpwd(arg_path: [*c]const u8) c_int {
    var path = arg_path;
    _ = &path;
    if (!(path != null) or !(@as(c_int, path[@as(c_int, 0)]) != 0)) return 0;
    return chdir(path);
}
pub fn open_configrc_file(arg_result: [*c]?*JFILE, arg_sys: [*c]const u8, arg_prefix: [*c]const u8, arg_name: [*c]const u8, arg_suffix: [*c]const u8) callconv(.c) [*c]u8 {
    var result = arg_result;
    _ = &result;
    var sys = arg_sys;
    _ = &sys;
    var prefix = arg_prefix;
    _ = &prefix;
    var name = arg_name;
    _ = &name;
    var suffix = arg_suffix;
    _ = &suffix;
    var f: ?*JFILE = null;
    _ = &f;
    var fullpath: [*c]u8 = null;
    _ = &fullpath;
    var home: [*c]const u8 = getenv("HOME");
    _ = &home;
    var xdg: [*c]const u8 = xdg_config_dir();
    _ = &xdg;
    result.* = null;
    if ((@as(c_int, name[@as(c_int, 0)]) == @as(c_int, '/')) or (@as(c_int, name[@as(c_int, 0)]) == @as(c_int, '~'))) {
        vsrm(fullpath);
        fullpath = vsncpy(null, 0, name, slen(name));
        fullpath = canonical(fullpath, 0);
        f = jfopen(fullpath, "r");
        if (f != null) {
            result.* = f;
            return fullpath;
        } else {
            vsrm(fullpath);
            return null;
        }
    }
    if (xdg != null) {
        vsrm(fullpath);
        fullpath = vsncpy(null, 0, xdg, if (xdg != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(@constCast(xdg)))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), prefix, slen(prefix));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), name, slen(name));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), suffix, slen(suffix));
        f = jfopen(fullpath, "r");
        if (f != null) {
            result.* = f;
            return fullpath;
        }
    }
    if (!(f != null) and (home != null)) {
        vsrm(fullpath);
        fullpath = vsncpy(null, 0, home, slen(home));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "/.joe/", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("/.joe/".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), prefix, slen(prefix));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), name, slen(name));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), suffix, slen(suffix));
        f = jfopen(fullpath, "r");
        if (f != null) {
            result.* = f;
            return fullpath;
        }
    }
    if (!(f != null)) {
        vsrm(fullpath);
        fullpath = vsncpy(null, 0, sys, slen(sys));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), prefix, slen(prefix));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), name, slen(name));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), suffix, slen(suffix));
        f = jfopen(fullpath, "r");
        if (f != null) {
            result.* = f;
            return fullpath;
        }
    }
    if (!(f != null)) {
        vsrm(fullpath);
        fullpath = vsncpy(null, 0, "*", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("*".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), name, slen(name));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), suffix, slen(suffix));
        f = jfopen(fullpath, "r");
        if (f != null) {
            result.* = f;
            return fullpath;
        }
    }
    vsrm(fullpath);
    return null;
}
pub export fn joesep(arg_path: [*c]u8) [*c]u8 {
    var path = arg_path;
    _ = &path;
    return path;
}
pub export fn namprt(arg_path: [*c]const u8) [*c]u8 {
    var path = arg_path;
    _ = &path;
    var z: [*c]const u8 = undefined;
    _ = &z;
    while (true) {
        if (!false) break;
    }
    z = path + @as(usize, @bitCast(@as(isize, @intCast(slen(path)))));
    while ((z != path) and (@as(c_int, z[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))]) != @as(c_int, '/'))) {
        z -= 1;
    }
    return vsncpy(null, 0, z, slen(z));
}
pub export fn namepart(arg_tmp: [*c]u8, arg_tmpsiz: ptrdiff_t, arg_path: [*c]const u8) [*c]u8 {
    var tmp = arg_tmp;
    _ = &tmp;
    var tmpsiz = arg_tmpsiz;
    _ = &tmpsiz;
    var path = arg_path;
    _ = &path;
    var z: [*c]const u8 = undefined;
    _ = &z;
    while (true) {
        if (!false) break;
    }
    z = path + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(path)))))))));
    while ((z != path) and (@as(c_int, z[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))]) != @as(c_int, '/'))) {
        z -= 1;
    }
    return zlcpy(tmp, tmpsiz, z);
}
pub export fn dirprt(arg_path: [*c]const u8) [*c]u8 {
    var path = arg_path;
    _ = &path;
    var b: [*c]const u8 = path;
    _ = &b;
    var z: [*c]const u8 = path + @as(usize, @bitCast(@as(isize, @intCast(slen(path)))));
    _ = &z;
    while (true) {
        if (!false) break;
    }
    while ((z != b) and (@as(c_int, z[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))]) != @as(c_int, '/'))) {
        z -= 1;
    }
    return vsncpy(null, 0, path, @divExact(@as(c_long, @bitCast(@intFromPtr(z) -% @intFromPtr(path))), @sizeOf(u8)));
}
pub export fn begprt(arg_path: [*c]const u8) [*c]u8 {
    var path = arg_path;
    _ = &path;
    var z: [*c]const u8 = path + @as(usize, @bitCast(@as(isize, @intCast(slen(path)))));
    _ = &z;
    var drv: c_int = 0;
    _ = &drv;
    while (true) {
        if (!false) break;
    }
    while ((z != (path + @as(usize, @bitCast(@as(isize, @intCast(drv)))))) and (@as(c_int, z[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))]) == @as(c_int, '/'))) {
        z -= 1;
    }
    if (z == (path + @as(usize, @bitCast(@as(isize, @intCast(drv)))))) return vsncpy(null, 0, path, slen(path)) else {
        while ((z != (path + @as(usize, @bitCast(@as(isize, @intCast(drv)))))) and (@as(c_int, z[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))]) != @as(c_int, '/'))) {
            z -= 1;
        }
        return vsncpy(null, 0, path, @divExact(@as(c_long, @bitCast(@intFromPtr(z) -% @intFromPtr(path))), @sizeOf(u8)));
    }
    unreachable;
}
pub export fn endprt(arg_path: [*c]const u8) [*c]u8 {
    var path = arg_path;
    _ = &path;
    var z: [*c]const u8 = path + @as(usize, @bitCast(@as(isize, @intCast(slen(path)))));
    _ = &z;
    var drv: c_int = 0;
    _ = &drv;
    while (true) {
        if (!false) break;
    }
    while ((z != (path + @as(usize, @bitCast(@as(isize, @intCast(drv)))))) and (@as(c_int, z[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))]) == @as(c_int, '/'))) {
        z -= 1;
    }
    if (z == (path + @as(usize, @bitCast(@as(isize, @intCast(drv)))))) return vsncpy(null, 0, "", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("".*)) / @sizeOf(u8)) -% @as(c_ulong, 1)))))) else {
        while ((z != (path + @as(usize, @bitCast(@as(isize, @intCast(drv)))))) and (@as(c_int, z[@bitCast(@as(isize, @intCast(-@as(c_int, 1))))]) != @as(c_int, '/'))) {
            z -= 1;
        }
        return vsncpy(null, 0, z, slen(z));
    }
    unreachable;
}
pub export fn mkpath(arg_path_in: [*c]const u8) c_int {
    var path_in = arg_path_in;
    _ = &path_in;
    var path_cpy: [*c]u8 = zdup(path_in);
    _ = &path_cpy;
    var path: [*c]u8 = path_cpy;
    _ = &path;
    var err: c_int = 0;
    _ = &err;
    var org: [*c]u8 = pwd();
    _ = &org;
    var s: [*c]u8 = undefined;
    _ = &s;
    if (@as(c_int, path[@as(c_int, 0)]) == @as(c_int, '/')) {
        if (chpwd("/") != 0) {
            err = -@as(c_int, 1);
        } else {
            s = path;
            while (@as(c_int, s.*) == @as(c_int, '/')) {
                s += 1;
            }
            path = s;
            while (!(err != 0) and (@as(c_int, path[@as(c_int, 0)]) != 0)) {
                var c: u8 = undefined;
                _ = &c;
                {
                    s = path;
                    while ((@as(c_int, s.*) != 0) and (@as(c_int, s.*) != @as(c_int, '/'))) : (s += 1) {}
                }
                c = s.*;
                s.* = 0;
                if (chpwd(path) != 0) {
                    if (mkdir(path, 448) != 0) {
                        err = -@as(c_int, 1);
                    } else if (chpwd(path) != 0) {
                        err = -@as(c_int, 1);
                    }
                }
                s.* = c;
                while (@as(c_int, s.*) == @as(c_int, '/')) {
                    s += 1;
                }
                path = s;
            }
        }
    } else {
        while (!(err != 0) and (@as(c_int, path[@as(c_int, 0)]) != 0)) {
            var c: u8 = undefined;
            _ = &c;
            {
                s = path;
                while ((@as(c_int, s.*) != 0) and (@as(c_int, s.*) != @as(c_int, '/'))) : (s += 1) {}
            }
            c = s.*;
            s.* = 0;
            if (chpwd(path) != 0) {
                if (mkdir(path, 448) != 0) {
                    err = -@as(c_int, 1);
                } else if (chpwd(path) != 0) {
                    err = -@as(c_int, 1);
                }
            }
            s.* = c;
            while (@as(c_int, s.*) == @as(c_int, '/')) {
                s += 1;
            }
            path = s;
        }
    }
    _ = chpwd(org);
    joe_free(@ptrCast(@alignCast(path_cpy)));
    return err;
}
pub export fn mktmp(arg_where: [*c]const u8) [*c]u8 {
    var where = arg_where;
    _ = &where;
    var name: [*c]u8 = undefined;
    _ = &name;
    var fd: c_int = undefined;
    _ = &fd;
    var namesize: ptrdiff_t = undefined;
    _ = &namesize;
    if (!(where != null)) {
        where = getenv("TEMP");
    }
    if (!(where != null)) {
        where = "/tmp/";
    }
    namesize = @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(where))))) + @as(ptrdiff_t, 16);
    name = vsmk(namesize);
    _ = snprintf(name, @as(usize, @bitCast(@as(c_long, namesize))), "%s/joe.tmp.XXXXXX", where);
    if ((blk: {
        const tmp = mkstemp(name);
        fd = tmp;
        break :blk tmp;
    }) == -@as(c_int, 1)) return null;
    _ = fchmod(fd, 384);
    _ = close(fd);
    return name;
}
pub export fn rmatch(arg_a: [*c]const u8, arg_b: [*c]const u8) c_int {
    var a = arg_a;
    _ = &a;
    var b = arg_b;
    _ = &b;
    var flag: c_int = undefined;
    _ = &flag;
    var inv: c_int = undefined;
    _ = &inv;
    var c: c_int = undefined;
    _ = &c;
    while (true) {
        while (true) {
            switch (@as(c_int, a.*)) {
                @as(c_int, '*') => {
                    a += 1;
                    while (true) {
                        if (rmatch(a, b) != 0) return 1;
                        if (!(@as(c_int, (blk: {
                            const ref = &b;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        }).*) != 0)) break;
                    }
                    return 0;
                },
                @as(c_int, '[') => {
                    a += 1;
                    flag = 0;
                    if (@as(c_int, a.*) == @as(c_int, '^')) {
                        a += 1;
                        inv = 1;
                    } else {
                        inv = 0;
                    }
                    if (@as(c_int, a.*) == @as(c_int, ']')) if (@as(c_int, b.*) == @as(c_int, (blk: {
                        const ref = &a;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    }).*)) {
                        flag = 1;
                    };
                    while ((@as(c_int, a.*) != 0) and ((blk: {
                        const tmp = @as(c_int, @as([*c]const u8, @ptrCast(@alignCast(blk_1: {
                            const ref = &a;
                            const tmp_2 = ref.*;
                            ref.* += 1;
                            break :blk_1 tmp_2;
                        }))).*);
                        c = tmp;
                        break :blk tmp;
                    }) != @as(c_int, ']'))) if (((c == @as(c_int, '-')) and (@as(c_int, a[@bitCast(@as(isize, @intCast(-@as(c_int, 2))))]) != @as(c_int, '['))) and (@as(c_int, a.*) != 0)) {
                        if ((@as(c_int, @as([*c]const u8, @ptrCast(@alignCast(b))).*) >= @as(c_int, @as([*c]const u8, @ptrCast(@alignCast(a)))[@bitCast(@as(isize, @intCast(-@as(c_int, 2))))])) and (@as(c_int, @as([*c]const u8, @ptrCast(@alignCast(b))).*) <= @as(c_int, @as([*c]const u8, @ptrCast(@alignCast(a))).*))) {
                            flag = 1;
                        }
                    } else if (@as(c_int, @as([*c]const u8, @ptrCast(@alignCast(b))).*) == c) {
                        flag = 1;
                    };
                    if (((!(flag != 0) and !(inv != 0)) or ((flag != 0) and (inv != 0))) or !(@as(c_int, b.*) != 0)) return 0;
                    b += 1;
                    break;
                },
                @as(c_int, '?') => {
                    a += 1;
                    if (!(@as(c_int, b.*) != 0)) return 0;
                    b += 1;
                    break;
                },
                @as(c_int, 0) => {
                    if (!(@as(c_int, b.*) != 0)) return 1 else return 0;
                    if (@as(c_int, (blk: {
                        const ref = &a;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    }).*) != @as(c_int, (blk: {
                        const ref = &b;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    }).*)) return 0;
                },
                else => {
                    if (@as(c_int, (blk: {
                        const ref = &a;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    }).*) != @as(c_int, (blk: {
                        const ref = &b;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    }).*)) return 0;
                },
            }
            break;
        }
    }
    unreachable;
}
pub export fn isreg(arg_s: [*c]const u8) c_int {
    var s = arg_s;
    _ = &s;
    var x: c_int = undefined;
    _ = &x;
    {
        x = 0;
        while (@as(c_int, s[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) if (((@as(c_int, s[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, '*')) or (@as(c_int, s[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, '?'))) or (@as(c_int, s[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, '['))) return 1;
    }
    return 0;
}
pub export fn rexpnd(arg_word: [*c]const u8) [*c][*c]u8 {
    var word = arg_word;
    _ = &word;
    var dir: ?*DIR = undefined;
    _ = &dir;
    var lst: [*c][*c]u8 = null;
    _ = &lst;
    var de: [*c]struct_dirent = undefined;
    _ = &de;
    dir = opendir(".");
    if (dir != null) {
        while (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
            const tmp = readdir(dir);
            de = tmp;
            break :blk tmp;
        }))) != @as(?*anyopaque, null)) if (strcmp(".", @ptrCast(@alignCast(&de.*.d_name))) != 0) if (rmatch(word, @ptrCast(@alignCast(&de.*.d_name))) != 0) {
            lst = vaadd(lst, vsncpy(null, 0, @ptrCast(@alignCast(&de.*.d_name)), slen(@ptrCast(@alignCast(&de.*.d_name)))));
        };
        _ = closedir(dir);
    }
    return lst;
}
pub export fn rexpnd_cmd_cd(arg_word: [*c]const u8) [*c][*c]u8 {
    var word = arg_word;
    _ = &word;
    var dir: ?*DIR = undefined;
    _ = &dir;
    var lst: [*c][*c]u8 = null;
    _ = &lst;
    var de: [*c]struct_dirent = undefined;
    _ = &de;
    dir = opendir(".");
    if (dir != null) {
        while (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
            const tmp = readdir(dir);
            de = tmp;
            break :blk tmp;
        }))) != @as(?*anyopaque, null)) if (strcmp(".", @ptrCast(@alignCast(&de.*.d_name))) != 0) if ((rmatch(word, @ptrCast(@alignCast(&de.*.d_name))) != 0) and !(access(@ptrCast(@alignCast(&de.*.d_name)), X_OK) != 0)) {
            lst = vaadd(lst, vsncpy(null, 0, @ptrCast(@alignCast(&de.*.d_name)), slen(@ptrCast(@alignCast(&de.*.d_name)))));
        };
        _ = closedir(dir);
    }
    return lst;
}
pub export fn rexpnd_cmd_path(arg_word: [*c]const u8) [*c][*c]u8 {
    var word = arg_word;
    _ = &word;
    var raw_path: [*c]u8 = getenv("PATH");
    _ = &raw_path;
    var lst: [*c][*c]u8 = null;
    _ = &lst;
    var de: [*c]struct_dirent = undefined;
    _ = &de;
    var path: [*c][*c]u8 = undefined;
    _ = &path;
    var x: ptrdiff_t = undefined;
    _ = &x;
    if (raw_path != null) {
        path = vawords(null, raw_path, slen(raw_path), ":", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf(":".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
        {
            x = 0;
            while (path[@bitCast(@as(isize, @intCast(x)))] != null) : (x += 1) {
                var dir: ?*DIR = undefined;
                _ = &dir;
                if (!(chpwd(path[@bitCast(@as(isize, @intCast(x)))]) != 0)) {
                    dir = opendir(".");
                    if (dir != null) {
                        while (@as(?*anyopaque, @ptrCast(@alignCast(blk: {
                            const tmp = readdir(dir);
                            de = tmp;
                            break :blk tmp;
                        }))) != @as(?*anyopaque, null)) {
                            var buf: [1]struct_stat = undefined;
                            _ = &buf;
                            if ((((rmatch(word, @ptrCast(@alignCast(&de.*.d_name))) != 0) and !(stat(@ptrCast(@alignCast(&de.*.d_name)), @ptrCast(@alignCast(&buf))) != 0)) and ((@as(c_int, @as([*c]struct_stat, @ptrCast(@alignCast(&buf))).*.st_mode) & S_IFMT) == S_IFREG)) and !(access(@ptrCast(@alignCast(&de.*.d_name)), X_OK) != 0)) {
                                lst = vaadd(lst, vsncpy(null, 0, @ptrCast(@alignCast(&de.*.d_name)), slen(@ptrCast(@alignCast(&de.*.d_name)))));
                            }
                        }
                        _ = closedir(dir);
                    }
                }
            }
        }
        varm(path);
    }
    return lst;
}
pub export fn rexpnd_users(arg_word: [*c]const u8) [*c][*c]u8 {
    var word = arg_word;
    _ = &word;
    var lst: [*c][*c]u8 = null;
    _ = &lst;
    var pw: [*c]struct_passwd = undefined;
    _ = &pw;
    while ((blk: {
        const tmp = getpwent();
        pw = tmp;
        break :blk tmp;
    }) != null) if (rmatch(word + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), pw.*.pw_name) != 0) {
        var t: [*c]u8 = vsncpy(null, 0, "~", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("~".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
        _ = &t;
        lst = vaadd(lst, vsncpy(t, if (t != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(t))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), pw.*.pw_name, slen(pw.*.pw_name)));
    };
    endpwent();
    return lst;
}
pub export fn simplify_prefix(arg_s: [*c]const u8) [*c]u8 {
    var s = arg_s;
    _ = &s;
    var t: [*c]const u8 = getenv("HOME");
    _ = &t;
    var n: [*c]u8 = undefined;
    _ = &n;
    if (((t != null) and !(zncmp(s, t, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(t)))))) != 0)) and (!(@as(c_int, s[@bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(t))))))))]) != 0) or (@as(c_int, s[@bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(t))))))))]) == @as(c_int, '/')))) {
        n = vsncpy(null, 0, "~/", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("~/".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
        if (@as(c_int, s[@bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(t))))))))]) != 0) {
            n = vsncpy(n, if (n != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(n))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), (s + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(t)))))))))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen((s + @as(usize, @bitCast(@as(isize, @intCast(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(t)))))))))) + @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))))))));
        }
    } else {
        n = vsncpy(null, 0, s, slen(s));
    }
    return n;
}
pub export fn dequotevs(arg_s: [*c]u8) [*c]u8 {
    var s = arg_s;
    _ = &s;
    var x: ptrdiff_t = undefined;
    _ = &x;
    var d: [*c]u8 = vsensure(null, if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
    _ = &d;
    {
        x = 0;
        while (x != (if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0))) : (x += 1) if (@as(c_int, s[@bitCast(@as(isize, @intCast(x)))]) == @as(c_int, '\\')) {
            if ((x + @as(ptrdiff_t, 1)) != (if (s != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(s))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0))) {
                x += 1;
                d = vsadd(d, s[@bitCast(@as(isize, @intCast(x)))]);
            }
        } else {
            d = vsadd(d, s[@bitCast(@as(isize, @intCast(x)))]);
        };
    }
    vsrm(s);
    return d;
}
pub export fn xdg_config_dir() [*c]const u8 {
    const static_local_xdg = struct {
        var xdg: [*c]u8 = null;
    };
    _ = &static_local_xdg;
    if (!(static_local_xdg.xdg != null)) {
        var home: [*c]const u8 = getenv("HOME");
        _ = &home;
        var x: [*c]const u8 = getenv("XDG_CONFIG_HOME");
        _ = &x;
        if ((x != null) and (@as(c_int, x[@as(c_int, 0)]) != 0)) {
            static_local_xdg.xdg = vsncpy(null, 0, x, slen(x));
            static_local_xdg.xdg = vsncpy(static_local_xdg.xdg, if (static_local_xdg.xdg != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(static_local_xdg.xdg))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "/joe/", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("/joe/".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
        } else {
            if (home != null) {
                static_local_xdg.xdg = vsncpy(null, 0, home, slen(home));
                static_local_xdg.xdg = vsncpy(static_local_xdg.xdg, if (static_local_xdg.xdg != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(static_local_xdg.xdg))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "/.config/joe/", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("/.config/joe/".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
            }
        }
    }
    return static_local_xdg.xdg;
}
pub export fn xdg_state_dir() [*c]const u8 {
    const static_local_xdg = struct {
        var xdg: [*c]u8 = null;
    };
    _ = &static_local_xdg;
    if (!(static_local_xdg.xdg != null)) {
        var home: [*c]const u8 = getenv("HOME");
        _ = &home;
        var x: [*c]const u8 = getenv("XDG_STATE_HOME");
        _ = &x;
        if (!(x != null)) {
            if (home != null) {
                static_local_xdg.xdg = vsncpy(null, 0, home, slen(home));
                static_local_xdg.xdg = vsncpy(static_local_xdg.xdg, if (static_local_xdg.xdg != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(static_local_xdg.xdg))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "/.local/state/joe/", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("/.local/state/joe/".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
            }
        } else {
            static_local_xdg.xdg = vsncpy(null, 0, x, slen(x));
            static_local_xdg.xdg = vsncpy(static_local_xdg.xdg, if (static_local_xdg.xdg != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(static_local_xdg.xdg))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "/joe/", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate((@sizeOf(@TypeOf("/joe/".*)) / @sizeOf(u8)) -% @as(c_ulong, 1))))));
        }
    }
    return static_local_xdg.xdg;
}
pub export fn open_config_file(arg_result: [*c]?*JFILE, arg_prefix: [*c]const u8, arg_name: [*c]const u8, arg_suffix: [*c]const u8) [*c]u8 {
    return open_configrc_file(arg_result, joedataPtr(), arg_prefix, arg_name, arg_suffix);
}
pub export fn open_rc_file(arg_result: [*c]?*JFILE, arg_prefix: [*c]const u8, arg_name: [*c]const u8, arg_suffix: [*c]const u8) [*c]u8 {
    return open_configrc_file(arg_result, joercPtr(), arg_prefix, arg_name, arg_suffix);
}
