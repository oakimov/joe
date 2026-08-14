//! JOE state file — replaces `joe/state.c`.
//!
//! Faithful C-ABI Path A port of JOE state load/save (`load_state`/`save_state` + `joe_state`).

const std = @import("std");
const ptrdiff_t = c_long;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn fprintf(f: ?*anyopaque, fmt: [*c]const u8, ...) c_int;
pub extern fn fgets(s: [*c]u8, n: c_int, f: ?*anyopaque) [*c]u8;
pub extern fn fopen(path: [*c]const u8, mode: [*c]const u8) ?*anyopaque;
pub extern fn fclose(f: ?*anyopaque) c_int;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;
pub extern fn umask(mask: c_uint) c_uint;
pub const off_t = i64;
pub const mode_t = c_uint;
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
pub const struct_b = extern struct {
    link: struct_unnamed_1 = std.mem.zeroes(struct_unnamed_1),
    bof: [*c]P = null,
    eof: [*c]P = null,
    _pad: [600]u8 = std.mem.zeroes([600]u8),
};
pub extern fn slen(s: [*c]const u8) ptrdiff_t;
pub extern fn vsncpy(d: [*c]u8, dlen: ptrdiff_t, s: [*c]const u8, sl: ptrdiff_t) [*c]u8;
pub extern fn vsrm(s: [*c]u8) void;
pub extern fn pdup(p: [*c]P, tr: [*c]const u8) [*c]P;
pub extern fn pset(n: [*c]P, p: [*c]P) [*c]P;
pub extern fn prm(p: [*c]P) void;
pub extern fn pline(p: [*c]P, line: off_t) [*c]P;
pub extern fn piseof(p: [*c]P) c_int;
pub extern fn pnextl(p: [*c]P) [*c]P;
pub extern fn brmem(p: [*c]P, buf: [*c]u8, size: ptrdiff_t) void;
pub extern fn binsm(p: [*c]P, blk: [*c]const u8, size: ptrdiff_t) [*c]P;
pub extern fn bmk(prop: [*c]B) [*c]B;
pub extern fn parse_ws(p: [*c][*c]const u8, cmt: c_int) c_int;
pub extern fn parse_string(p: [*c][*c]const u8, buf: [*c]u8, len: ptrdiff_t) ptrdiff_t;
pub extern fn emit_string(f: ?*FILE, s: [*c]const u8, len: ptrdiff_t) void;
pub extern fn xdg_state_dir() [*c]const u8;
pub extern fn mkpath(path: [*c]const u8) c_int;
pub extern fn save_srch(f: ?*FILE) void;
pub extern fn load_srch(f: ?*FILE) void;
pub extern fn save_macros(f: ?*FILE) void;
pub extern fn load_macros(f: ?*FILE) void;
pub extern fn save_yank(f: ?*FILE) void;
pub extern fn load_yank(f: ?*FILE) void;
pub extern fn save_file_pos(f: ?*FILE) void;
pub extern fn load_file_pos(f: ?*FILE) void;
pub extern fn save_colors_state(f: ?*FILE) void;
pub extern fn load_colors_state(f: ?*FILE) void;
pub extern var filehist: [*c]B;
pub extern var findhist: [*c]B;
pub extern var replhist: [*c]B;
pub extern var runhist: [*c]B;
pub extern var buildhist: [*c]B;
pub extern var grephist: [*c]B;
pub extern var filthist: [*c]B;
pub extern var cmdhist: [*c]B;
pub extern var mathhist: [*c]B;
pub export var joe_state: c_int = 0;
pub fn save_hist(arg_f: ?*FILE, arg_b_1: [*c]B) callconv(.c) void {
    var f = arg_f;
    _ = &f;
    var b_1 = arg_b_1;
    _ = &b_1;
    var buf: [512]u8 = undefined;
    _ = &buf;
    var len: ptrdiff_t = @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf))))));
    _ = &len;
    if (b_1 != null) {
        var p_1: [*c]P = pdup(b_1.*.bof, "save_hist");
        _ = &p_1;
        var q: [*c]P = pdup(b_1.*.bof, "save_hist");
        _ = &q;
        if (b_1.*.eof.*.line > @as(off_t, 10)) {
            _ = pline(p_1, b_1.*.eof.*.line - @as(off_t, 10));
        }
        _ = pset(q, p_1);
        while (!(piseof(p_1) != 0)) {
            _ = pnextl(q);
            if ((q.*.byte - p_1.*.byte) < @as(off_t, @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf)))))))) {
                len = @as(ptrdiff_t, @truncate(q.*.byte - p_1.*.byte));
                brmem(p_1, @ptrCast(@alignCast(&buf)), len);
            } else {
                len = @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(buf))))));
                brmem(p_1, @ptrCast(@alignCast(&buf)), len);
                buf[@bitCast(@as(isize, @intCast(len - @as(ptrdiff_t, 1))))] = '\n';
            }
            _ = fprintf(f, "\t");
            emit_string(f, @ptrCast(@alignCast(&buf)), len);
            _ = fprintf(f, "\n");
            _ = pset(p_1, q);
        }
        prm(p_1);
        prm(q);
    }
    _ = fprintf(f, "done\n");
}
pub fn load_hist(arg_f: ?*FILE, arg_bp: [*c][*c]B) callconv(.c) void {
    var f = arg_f;
    _ = &f;
    var bp = arg_bp;
    _ = &bp;
    var b_1: [*c]B = undefined;
    _ = &b_1;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    var bf: [1024]u8 = undefined;
    _ = &bf;
    var q: [*c]P = undefined;
    _ = &q;
    b_1 = bp.*;
    if (!(b_1 != null)) {
        bp.* = blk: {
            const tmp = bmk(null);
            b_1 = tmp;
            break :blk tmp;
        };
    }
    q = pdup(b_1.*.eof, "load_hist");
    while ((fgets(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_uint, @truncate(@sizeOf(@TypeOf(buf))))), f) != null) and (strcmp(@ptrCast(@alignCast(&buf)), "done\n") != 0)) {
        var p_1: [*c]const u8 = @ptrCast(@alignCast(&buf));
        _ = &p_1;
        var len: ptrdiff_t = undefined;
        _ = &len;
        _ = parse_ws(&p_1, '#');
        len = parse_string(&p_1, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))));
        if (len > @as(ptrdiff_t, 0)) {
            if (@as(c_int, bf[@bitCast(@as(isize, @intCast(len - @as(ptrdiff_t, 1))))]) != @as(c_int, '\n')) {
                bf[@bitCast(@as(isize, @intCast(len - @as(ptrdiff_t, 1))))] = '\n';
            }
            _ = binsm(q, @ptrCast(@alignCast(&bf)), len);
            _ = pset(q, b_1.*.eof);
        }
    }
    prm(q);
}
pub export fn save_state() void {
    var fullpath: [*c]u8 = null;
    _ = &fullpath;
    var home: [*c]u8 = getenv("HOME");
    _ = &home;
    var xdg: [*c]const u8 = xdg_state_dir();
    _ = &xdg;
    var old_mask: mode_t = undefined;
    _ = &old_mask;
    var f: ?*FILE = null;
    _ = &f;
    if (!(joe_state != 0)) return;
    if (xdg != null) {
        vsrm(fullpath);
        fullpath = vsncpy(null, 0, xdg, if (xdg != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(@constCast(xdg)))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        _ = mkpath(xdg);
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "joe_state", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("joe_state".*)) -% @as(c_ulong, 1))))));
        old_mask = umask(54);
        f = fopen(fullpath, "w");
        _ = umask(old_mask);
    }
    if (!(f != null) and (home != null)) {
        vsrm(fullpath);
        fullpath = vsncpy(null, 0, home, slen(home));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "/.joe_state", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("/.joe_state".*)) -% @as(c_ulong, 1))))));
        old_mask = umask(54);
        f = fopen(fullpath, "r");
        _ = umask(old_mask);
    }
    if (!(f != null)) {
        vsrm(fullpath);
        return;
    }
    _ = fprintf(f, "%s", @constCast("# JOE state file v1.0\n"));
    _ = fprintf(f, "search\n");
    save_srch(f);
    _ = fprintf(f, "macros\n");
    save_macros(f);
    _ = fprintf(f, "files\n");
    save_hist(f, filehist);
    _ = fprintf(f, "find\n");
    save_hist(f, findhist);
    _ = fprintf(f, "replace\n");
    save_hist(f, replhist);
    _ = fprintf(f, "run\n");
    save_hist(f, runhist);
    _ = fprintf(f, "build\n");
    save_hist(f, buildhist);
    _ = fprintf(f, "grep\n");
    save_hist(f, grephist);
    _ = fprintf(f, "filt\n");
    save_hist(f, filthist);
    _ = fprintf(f, "cmd\n");
    save_hist(f, cmdhist);
    _ = fprintf(f, "math\n");
    save_hist(f, mathhist);
    _ = fprintf(f, "yank\n");
    save_yank(f);
    _ = fprintf(f, "file_pos\n");
    save_file_pos(f);
    _ = fprintf(f, "colors\n");
    save_colors_state(f);
    _ = fclose(f);
    vsrm(fullpath);
}
pub export fn load_state() void {
    var home: [*c]const u8 = getenv("HOME");
    _ = &home;
    var xdg: [*c]const u8 = xdg_state_dir();
    _ = &xdg;
    var f: ?*FILE = null;
    _ = &f;
    var fullpath: [*c]u8 = null;
    _ = &fullpath;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    if (!(joe_state != 0)) return;
    if (xdg != null) {
        vsrm(fullpath);
        fullpath = vsncpy(null, 0, xdg, if (xdg != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(@constCast(xdg)))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "joe_state", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("joe_state".*)) -% @as(c_ulong, 1))))));
        f = fopen(fullpath, "r");
    }
    if (!(f != null) and (home != null)) {
        vsrm(fullpath);
        fullpath = vsncpy(null, 0, home, slen(home));
        fullpath = vsncpy(fullpath, if (fullpath != null) (@as([*c]ptrdiff_t, @ptrCast(@alignCast(fullpath))) - @as(usize, @bitCast(@as(isize, @intCast(@as(c_int, 1)))))).* else @as(ptrdiff_t, 0), "/.joe_state", @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf("/.joe_state".*)) -% @as(c_ulong, 1))))));
        f = fopen(fullpath, "r");
    }
    if (!(f != null)) {
        vsrm(fullpath);
        return;
    }
    if ((fgets(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_uint, @truncate(@sizeOf(@TypeOf(buf))))), f) != null) and !(strcmp(@ptrCast(@alignCast(&buf)), "# JOE state file v1.0\n") != 0)) {
        while (fgets(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_uint, @truncate(@sizeOf(@TypeOf(buf))))), f) != null) {
            if (!(strcmp(@ptrCast(@alignCast(&buf)), "search\n") != 0)) {
                load_srch(f);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "macros\n") != 0)) {
                load_macros(f);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "files\n") != 0)) {
                load_hist(f, &filehist);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "find\n") != 0)) {
                load_hist(f, &findhist);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "replace\n") != 0)) {
                load_hist(f, &replhist);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "run\n") != 0)) {
                load_hist(f, &runhist);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "build\n") != 0)) {
                load_hist(f, &buildhist);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "grep\n") != 0)) {
                load_hist(f, &grephist);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "filt\n") != 0)) {
                load_hist(f, &filthist);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "cmd\n") != 0)) {
                load_hist(f, &cmdhist);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "math\n") != 0)) {
                load_hist(f, &mathhist);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "yank\n") != 0)) {
                load_yank(f);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "file_pos\n") != 0)) {
                load_file_pos(f);
            } else if (!(strcmp(@ptrCast(@alignCast(&buf)), "colors\n") != 0)) {
                load_colors_state(f);
            } else {
                while ((fgets(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_uint, @truncate(@sizeOf(@TypeOf(buf))))), f) != null) and (strcmp(@ptrCast(@alignCast(&buf)), "done\n") != 0)) {}
            }
        }
    }
    _ = fclose(f);
    vsrm(fullpath);
}
