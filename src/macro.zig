//! Keyboard macros — replaces `joe/macro.c`.
//!
//! Faithful C-ABI port of JOE's macro recording/playback, mparse/mtext,
//! and related user commands. Generated from a goto-free rewrite of
//! macro.c via `zig translate-c`, then cleaned for the hybrid Zig+C build.

const std = @import("std");
const ptrdiff_t = c_long;

pub extern fn printf(fmt: [*c]const u8, ...) c_int;
pub extern fn snprintf(buf: [*c]u8, n: c_ulong, fmt: [*c]const u8, ...) c_int;
pub extern fn fprintf(stream: ?*anyopaque, fmt: [*c]const u8, ...) c_int;
pub extern fn fgets(s: [*c]u8, n: c_int, stream: ?*anyopaque) [*c]u8;
pub extern fn getenv(name: [*c]const u8) [*c]u8;
pub extern fn free(p: ?*anyopaque) void;
pub extern fn memcpy(d: ?*anyopaque, s: ?*const anyopaque, n: c_ulong) ?*anyopaque;
pub extern fn memset(s: ?*anyopaque, c: c_int, n: c_ulong) ?*anyopaque;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn strlen(s: [*c]const u8) c_ulong;

pub const off_t = i64;
pub const time_t = i64;
pub const FILE = anyopaque;

pub const NO_MORE_DATA: c_int = -256;
pub const JOE_MSGBUFSIZE: c_int = 300;
pub const TYPETW: c_int = 0x0100;
pub const TYPEPW: c_int = 0x0200;
pub const TYPEMENU: c_int = 0x0800;
pub const TYPEQW: c_int = 0x1000;
pub const EMINOR: c_int = 8;
pub const EMETA: c_int = 0x10000;

pub const struct_charmap = opaque {};
pub const struct_watom = extern struct {
    _pad0: [80]u8 = std.mem.zeroes([80]u8),
    what: c_int = 0,
    _pad1: [4]u8 = std.mem.zeroes([4]u8),
};
pub const WATOM = struct_watom;
pub const struct_window = extern struct {
    _pad0: [144]u8 = std.mem.zeroes([144]u8),
    watom: [*c]const WATOM = null,
    object: ?*anyopaque = null,
    _pad1: [40]u8 = std.mem.zeroes([40]u8),
};
pub const struct_p = opaque {};
pub const P = struct_p;
pub const struct_b = opaque {};
pub const B = struct_b;
pub const CMD = struct_cmd;
pub const struct_macro = extern struct {
    what: ptrdiff_t = 0,
    k: c_int = 0,
    flg: c_int = 0,
    cmd: [*c]const CMD = null,
    n: ptrdiff_t = 0,
    size: ptrdiff_t = 0,
    steps: [*c][*c]struct_macro = null,
};
pub const struct_cmd = extern struct {
    name: [*c]const u8 = null,
    flag: c_int = 0,
    func: ?*const fn (w: [*c]struct_window, k: c_int) callconv(.c) c_int = null,
    m: [*c]struct_macro = null,
    arg: c_int = 0,
    negarg: [*c]const u8 = null,
};
pub const MACRO = struct_macro;
pub const struct_recmac = extern struct {
    next: [*c]struct_recmac = null,
    n: c_int = 0,
    m: [*c]MACRO = null,
};
pub const struct_kbd = extern struct {
    _pad: [88]u8 = std.mem.zeroes([88]u8),
};
pub const KBD = struct_kbd;
pub const W = struct_window;
pub const struct_bw = extern struct {
    parent: [*c]W = null,
    _pad0: [16]u8 = std.mem.zeroes([16]u8),
    cursor: ?*P = null,
    _pad1: [456]u8 = std.mem.zeroes([456]u8),
};
pub const BW = struct_bw;
pub const struct_screen = extern struct {
    _pad0: [24]u8 = std.mem.zeroes([24]u8),
    curwin: [*c]W = null,
    _pad1: [16]u8 = std.mem.zeroes([16]u8),
};
pub const Screen = struct_screen;
pub const struct_qw = opaque {};
pub const QW = struct_qw;
pub extern fn joe_malloc(size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_realloc(ptr: ?*anyopaque, size: ptrdiff_t) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn zdup(s: [*c]const u8) [*c]u8;
pub extern fn zncmp(a: [*c]const u8, b: [*c]const u8, len: ptrdiff_t) c_int;
pub extern fn slen(ary: [*c]const u8) ptrdiff_t;
pub extern fn vsrm(vary: [*c]u8) void;
pub extern fn parse_ws(p: [*c][*c]const u8, cmt: c_int) c_int;
pub extern fn parse_int(p: [*c][*c]const u8, buf: [*c]c_int) c_int;
pub extern fn parse_string(p: [*c][*c]const u8, buf: [*c]u8, len: ptrdiff_t) ptrdiff_t;
pub extern fn parse_Zstring(p: [*c][*c]const u8, buf: [*c]c_int, len: ptrdiff_t) ptrdiff_t;
pub extern fn emit_string(f: ?*FILE, s: [*c]const u8, len: ptrdiff_t) void;
pub extern fn findcmd(s: [*c]const u8) [*c]const CMD;
pub extern fn execmd(cmd: [*c]const CMD, k: c_int) c_int;
pub extern fn umclear() void;
pub extern fn undomark() void;
pub extern fn nungetc(c: c_int) void;
pub extern fn binsc(p: ?*P, c: c_int) ?*P;
pub extern fn binss(p: ?*P, s: [*c]const u8) ?*P;
pub extern fn pgetc(p: ?*P) c_int;
pub extern fn p_goto_eol(p: ?*P) ?*P;
pub extern fn msgnw(w: [*c]W, s: [*c]const u8) void;
pub extern fn my_gettext(s: [*c]const u8) [*c]const u8;
pub extern fn wmkpw(w: [*c]W, prompt: [*c]const u8, history: [*c]?*B, func: ?*const fn (w: [*c]W, s: [*c]u8, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, huh: [*c]const u8, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, tab: ?*const fn (bw: [*c]BW, k: c_int) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int, map: ?*struct_charmap, file_prompt: c_int) [*c]BW;
pub extern fn mkqw(w: [*c]W, prompt: [*c]const u8, len: ptrdiff_t, func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int) ?*QW;
pub extern fn mkqwna(w: [*c]W, prompt: [*c]const u8, len: ptrdiff_t, func: ?*const fn (w: [*c]W, k: c_int, object: ?*anyopaque, notify: [*c]c_int) callconv(.c) c_int, abrt: ?*const fn (w: [*c]W, object: ?*anyopaque) callconv(.c) c_int, object: ?*anyopaque, notify: [*c]c_int) ?*QW;
pub extern fn calc(bw: [*c]BW, s: [*c]u8, secure: c_int) f64;
pub extern fn math_cmplt(bw: [*c]BW, k: c_int) c_int;
pub extern var maint: [*c]Screen;
pub extern var leave: c_int;
pub extern var nstack: c_int;
pub extern var locale_map: ?*struct_charmap;
pub extern var utf8_map: ?*struct_charmap;
pub extern var merr: [*c]const u8;
pub extern var timer_macro_delay: time_t;
pub extern var timer_macro: [*c]MACRO;
pub const msgbuf: [*c]u8 = @extern([*c]u8, .{
    .name = "msgbuf",
});
pub extern fn utf8_encode(buf: [*c]u8, c: c_int) ptrdiff_t;
pub extern fn edloop(flg: c_int) c_int;
pub extern fn upop(w: [*c]W, k: c_int) c_int;
pub extern var dostaupd: c_int;
pub export var freemacros: [*c]MACRO = null;
pub export fn mkmacro(arg_k: c_int, arg_flg: c_int, arg_n: ptrdiff_t, arg_cmd_1: [*c]const CMD) [*c]MACRO {
    var k = arg_k;
    _ = &k;
    var flg = arg_flg;
    _ = &flg;
    var n = arg_n;
    _ = &n;
    var cmd_1 = arg_cmd_1;
    _ = &cmd_1;
    var macro_2: [*c]MACRO = undefined;
    _ = &macro_2;
    if (!(freemacros != null)) {
        var x: ptrdiff_t = undefined;
        _ = &x;
        macro_2 = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(MACRO))))) * @as(ptrdiff_t, 64))));
        {
            x = 0;
            while (x != @as(ptrdiff_t, 64)) : (x += 1) {
                macro_2[@bitCast(@as(isize, @intCast(x)))].steps = @ptrCast(@alignCast(freemacros));
                freemacros = macro_2 + @as(usize, @bitCast(@as(isize, @intCast(x))));
            }
        }
    }
    macro_2 = freemacros;
    freemacros = @ptrCast(@alignCast(macro_2.*.steps));
    macro_2.*.steps = null;
    macro_2.*.size = 0;
    macro_2.*.flg = flg;
    macro_2.*.n = n;
    macro_2.*.cmd = cmd_1;
    macro_2.*.k = k;
    macro_2.*.what = 0;
    return macro_2;
}
pub export fn rmmacro(arg_macro_1: [*c]MACRO) void {
    var macro_1 = arg_macro_1;
    _ = &macro_1;
    if (macro_1 != null) {
        if (macro_1.*.steps != null) {
            var x: ptrdiff_t = undefined;
            _ = &x;
            {
                x = 0;
                while (x != macro_1.*.n) : (x += 1) {
                    rmmacro(macro_1.*.steps[@bitCast(@as(isize, @intCast(x)))]);
                }
            }
            joe_free(@ptrCast(@alignCast(macro_1.*.steps)));
        }
        macro_1.*.steps = @ptrCast(@alignCast(freemacros));
        freemacros = macro_1;
    }
}
pub export fn addmacro(arg_macro_1: [*c]MACRO, arg_m: [*c]MACRO) void {
    var macro_1 = arg_macro_1;
    _ = &macro_1;
    var m = arg_m;
    _ = &m;
    if (macro_1.*.n == macro_1.*.size) {
        if (macro_1.*.steps != null) {
            macro_1.*.steps = @ptrCast(@alignCast(joe_realloc(@ptrCast(@alignCast(macro_1.*.steps)), (blk: {
                const ref = &macro_1.*.size;
                ref.* += 8;
                break :blk ref.*;
            }) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]MACRO))))))));
        } else {
            macro_1.*.steps = @ptrCast(@alignCast(joe_malloc((blk: {
                const tmp = @as(ptrdiff_t, 8);
                macro_1.*.size = tmp;
                break :blk tmp;
            }) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]MACRO))))))));
        }
    }
    macro_1.*.steps[
        @bitCast(@as(isize, @intCast(blk: {
            const ref = &macro_1.*.n;
            const tmp = ref.*;
            ref.* += 1;
            break :blk tmp;
        })))
    ] = m;
}
pub export fn dupmacro(arg_mac: [*c]MACRO) [*c]MACRO {
    var mac = arg_mac;
    _ = &mac;
    var m: [*c]MACRO = mkmacro(mac.*.k, mac.*.flg, mac.*.n, mac.*.cmd);
    _ = &m;
    if (mac.*.steps != null) {
        var x: ptrdiff_t = undefined;
        _ = &x;
        m.*.steps = @ptrCast(@alignCast(joe_malloc((blk: {
            const tmp = mac.*.n;
            m.*.size = tmp;
            break :blk tmp;
        }) * @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf([*c]MACRO))))))));
        {
            x = 0;
            while (x != m.*.n) : (x += 1) {
                m.*.steps[@bitCast(@as(isize, @intCast(x)))] = dupmacro(mac.*.steps[@bitCast(@as(isize, @intCast(x)))]);
            }
        }
    }
    return m;
}
pub export fn macstk(arg_m: [*c]MACRO, arg_k: c_int) [*c]MACRO {
    var m = arg_m;
    _ = &m;
    var k = arg_k;
    _ = &k;
    if (k != -@as(c_int, 1)) {
        m.*.k = k;
    }
    return m;
}
pub export fn macsta(arg_m: [*c]MACRO, arg_a: c_int) [*c]MACRO {
    var m = arg_m;
    _ = &m;
    var a = arg_a;
    _ = &a;
    m.*.flg = a;
    return m;
}
pub export fn mparse(arg_m: [*c]MACRO, arg_buf: [*c]const u8, arg_sta: [*c]ptrdiff_t, arg_secure: c_int) [*c]MACRO {
    var m = arg_m;
    _ = &m;
    var buf = arg_buf;
    _ = &buf;
    var sta = arg_sta;
    _ = &sta;
    var secure = arg_secure;
    _ = &secure;
    var org: [*c]const u8 = buf;
    _ = &org;
    var bf: [1024]c_int = undefined;
    _ = &bf;
    var bf1: [1024]u8 = undefined;
    _ = &bf1;
    var x: c_int = undefined;
    _ = &x;
    while (true) {
        _ = parse_ws(&buf, 0);
        if (!(@as(c_int, buf.*) != 0)) {
            sta.* = -@as(c_int, 1);
            return null;
        }
        if (parse_Zstring(&buf, @ptrCast(@alignCast(&bf)), @divTrunc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf[@as(c_int, 0)])))))))) >= @as(ptrdiff_t, 0)) {
            {
                x = 0;
                while (bf[@bitCast(@as(isize, @intCast(x)))] != 0) : (x += 1) {
                    if (m != null) {
                        if (!(m.*.steps != null)) {
                            var macro_1: [*c]MACRO = m;
                            _ = &macro_1;
                            m = mkmacro(-@as(c_int, 256), 0, 0, null);
                            addmacro(m, macro_1);
                        }
                    } else {
                        m = mkmacro(-@as(c_int, 256), 0, 0, null);
                    }
                    addmacro(m, mkmacro(bf[@bitCast(@as(isize, @intCast(x)))], 0, 0, if (secure != 0) findcmd("secure_type") else findcmd("type")));
                }
            }
        } else {
            x = 0;
            while ((((((((((@as(c_int, buf.*) != 0) and (@as(c_int, buf.*) != @as(c_int, '#'))) and (@as(c_int, buf.*) != @as(c_int, '!'))) and (@as(c_int, buf.*) != @as(c_int, '~'))) and (@as(c_int, buf.*) != @as(c_int, '-'))) and (@as(c_int, buf.*) != @as(c_int, ','))) and (@as(c_int, buf.*) != @as(c_int, ' '))) and (@as(c_int, buf.*) != @as(c_int, '\t'))) and (@as(c_int, buf.*) != @as(c_int, '\n'))) and (@as(c_int, buf.*) != @as(c_int, '\r'))) {
                if (@as(ptrdiff_t, x) != (@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf1)))))) - @as(ptrdiff_t, 1))) {
                    bf1[
                        @bitCast(@as(isize, @intCast(blk: {
                            const ref = &x;
                            const tmp = ref.*;
                            ref.* += 1;
                            break :blk tmp;
                        })))
                    ] = buf.*;
                }
                buf += 1;
            }
            bf1[@bitCast(@as(isize, @intCast(x)))] = 0;
            if (x != 0) {
                var cmd_1: [*c]const CMD = undefined;
                _ = &cmd_1;
                var flg: c_int = 0;
                _ = &flg;
                if (!(secure != 0) or !(zncmp(@ptrCast(@alignCast(&bf1)), "shell_", 6) != 0)) {
                    cmd_1 = findcmd(@ptrCast(@alignCast(&bf1)));
                } else {
                    cmd_1 = null;
                }
                while ((((@as(c_int, buf.*) == @as(c_int, '-')) or (@as(c_int, buf.*) == @as(c_int, '!'))) or (@as(c_int, buf.*) == @as(c_int, '#'))) or (@as(c_int, buf.*) == @as(c_int, '~'))) {
                    if (@as(c_int, buf.*) == @as(c_int, '-')) {
                        flg |= 1;
                    }
                    if (@as(c_int, buf.*) == @as(c_int, '!')) {
                        flg |= 2;
                    }
                    if (@as(c_int, buf.*) == @as(c_int, '#')) {
                        flg |= 4;
                    }
                    if (@as(c_int, buf.*) == @as(c_int, '~')) {
                        flg |= 8;
                    }
                    buf += 1;
                }
                if (!(cmd_1 != null)) {
                    sta.* = -@as(c_int, 1);
                    return null;
                } else if (m != null) {
                    if (!(m.*.steps != null)) {
                        var macro_1: [*c]MACRO = m;
                        _ = &macro_1;
                        m = mkmacro(-@as(c_int, 256), 0, 0, null);
                        addmacro(m, macro_1);
                    }
                    addmacro(m, mkmacro(-@as(c_int, 256), flg, 0, cmd_1));
                } else {
                    m = mkmacro(-@as(c_int, 256), flg, 0, cmd_1);
                }
            } else {
                sta.* = -@as(c_int, 1);
                return null;
            }
        }
        _ = parse_ws(&buf, 0);
        if (@as(c_int, buf.*) == @as(c_int, ',')) {
            buf += 1;
            _ = parse_ws(&buf, 0);
            if (((@as(c_int, buf.*) != 0) and (@as(c_int, buf.*) != @as(c_int, '\r'))) and (@as(c_int, buf.*) != @as(c_int, '\n'))) continue;
            sta.* = -@as(c_int, 2);
            return m;
        }
        sta.* = @divExact(@as(c_long, @bitCast(@intFromPtr(buf) -% @intFromPtr(org))), @sizeOf(u8));
        return m;
    }
    return undefined;
}
/// Bytes of space left between write cursor and buffer end.
inline fn room_left(end: [*c]u8, ptr: [*c]u8) isize {
    return @as(isize, @bitCast(@intFromPtr(end) -% @intFromPtr(ptr)));
}
pub fn unescape_b(arg_ptr: [*c]u8, end: [*c]u8, arg_c: c_int) [*c]u8 {
    var ptr = arg_ptr;
    _ = &ptr;
    var c = arg_c;
    _ = &c;
    if (c == @as(c_int, '"')) {
        if (room_left(end, ptr) < 2) return ptr;
        ptr[0] = '\\';
        ptr[1] = '"';
        ptr += 2;
    } else if (c == @as(c_int, '\\')) {
        if (room_left(end, ptr) < 2) return ptr;
        ptr[0] = '\\';
        ptr[1] = '\\';
        ptr += 2;
    } else if (c == @as(c_int, '\'')) {
        if (room_left(end, ptr) < 2) return ptr;
        ptr[0] = '\\';
        ptr[1] = '\'';
        ptr += 2;
    } else if ((c < @as(c_int, 32)) or (c == @as(c_int, 127))) {
        if (room_left(end, ptr) < 4) return ptr;
        ptr[0] = '\\';
        ptr[1] = 'x';
        ptr[2] = "0123456789ABCDEF"[@bitCast(@as(isize, @intCast(@as(c_int, 15) & (c >> @intCast(@as(c_int, 4))))))];
        ptr[3] = "0123456789ABCDEF"[@bitCast(@as(isize, @intCast(@as(c_int, 15) & c)))];
        ptr += 4;
    } else {
        if (room_left(end, ptr) < 4) return ptr; // max UTF-8 width; check BEFORE encode
        const n: isize = @intCast(utf8_encode(ptr, c));
        if (n > 0) ptr += @as(usize, @intCast(n));
    }
    return ptr;
}
pub export fn unescape(arg_ptr: [*c]u8, arg_c: c_int) [*c]u8 {
    return unescape_b(arg_ptr, arg_ptr + 1024, arg_c);
}
pub fn domtext_b(arg_m: [*c]MACRO, arg_ptr: [*c]u8, arg_end: [*c]u8, arg_first: [*c]c_int, arg_instr: [*c]c_int) [*c]u8 {
    var m = arg_m;
    _ = &m;
    var ptr = arg_ptr;
    _ = &ptr;
    const end = arg_end;
    var first = arg_first;
    _ = &first;
    var instr = arg_instr;
    _ = &instr;
    var x: ptrdiff_t = undefined;
    _ = &x;
    if (!(m != null)) return ptr;
    if (m.*.steps != null) {
        {
            x = 0;
            while (x != m.*.n) : (x += 1) {
                ptr = domtext_b(m.*.steps[@bitCast(@as(isize, @intCast(x)))], ptr, end, first, instr);
                if (room_left(end, ptr) <= 0) return ptr;
            }
        }
    } else {
        if ((instr.* != 0) and (strcmp(m.*.cmd.*.name, "type") != 0)) {
            if (room_left(end, ptr) < 1) return ptr;
            ptr[0] = '"';
            ptr += 1;
            instr.* = 0;
        }
        if (first.* != 0) {
            first.* = 0;
        } else if (!(instr.* != 0)) {
            if (room_left(end, ptr) < 1) return ptr;
            ptr[0] = ',';
            ptr += 1;
        }
        if (!(strcmp(m.*.cmd.*.name, "type") != 0)) {
            if (!(instr.* != 0)) {
                if (room_left(end, ptr) < 1) return ptr;
                ptr[0] = '"';
                ptr += 1;
                instr.* = 1;
            }
            ptr = unescape_b(ptr, end, m.*.k);
        } else {
            {
                x = 0;
                while (@as(c_int, m.*.cmd.*.name[@bitCast(@as(isize, @intCast(x)))]) != 0) : (x += 1) {
                    if (room_left(end, ptr) < 2) return ptr; // keep room for the NUL
                    ptr[0] = m.*.cmd.*.name[@bitCast(@as(isize, @intCast(x)))];
                    ptr += 1;
                }
            }
            if ((((!(strcmp(m.*.cmd.*.name, "play") != 0) or !(strcmp(m.*.cmd.*.name, "gomark") != 0)) or !(strcmp(m.*.cmd.*.name, "setmark") != 0)) or !(strcmp(m.*.cmd.*.name, "record") != 0)) or !(strcmp(m.*.cmd.*.name, "uarg") != 0)) {
                if (room_left(end, ptr) < 3) return ptr;
                ptr[0] = ',';
                ptr[1] = '"';
                ptr += 2;
                ptr = unescape_b(ptr, end, m.*.k);
                if (room_left(end, ptr) < 1) return ptr;
                ptr[0] = '"';
                ptr += 1;
            }
        }
    }
    return ptr;
}
pub export fn mtext(arg_s: [*c]u8, arg_m: [*c]MACRO) [*c]u8 {
    var s = arg_s;
    _ = &s;
    var m = arg_m;
    _ = &m;
    var first: c_int = 1;
    _ = &first;
    var instr: c_int = 0;
    _ = &instr;
    // Reserve one byte at the end for the closing quote / NUL.
    const limit: [*c]u8 = s + 1023;
    var e: [*c]u8 = domtext_b(m, s, limit, &first, &instr);
    _ = &e;
    if (instr != 0 and room_left(limit, e) >= 1) {
        e[0] = '"';
        e += 1;
    }
    e.* = 0;
    return s;
}
pub var kbdmacro: [10][*c]MACRO = std.mem.zeroes([10][*c]MACRO);
pub var playmode: [10]c_int = std.mem.zeroes([10]c_int);
pub export var recmac: [*c]struct_recmac = null;
pub fn unmac() callconv(.c) void {
    if (recmac != null) {
        rmmacro(recmac.*.m.*.steps[
            @bitCast(@as(isize, @intCast(blk: {
                const ref = &recmac.*.m.*.n;
                ref.* -= 1;
                break :blk ref.*;
            })))
        ]);
    }
}
pub export fn chmac() void {
    if ((recmac != null) and (recmac.*.m.*.n != 0)) {
        recmac.*.m.*.steps[@bitCast(@as(isize, @intCast(recmac.*.m.*.n - @as(ptrdiff_t, 1))))].*.k = 3;
    }
}
pub fn record(arg_m: [*c]MACRO, arg_k: c_int) callconv(.c) void {
    var m = arg_m;
    _ = &m;
    var k = arg_k;
    _ = &k;
    if (recmac != null) {
        addmacro(recmac.*.m, macstk(dupmacro(m), k));
    }
}
pub var ifdepth: c_int = 0;
pub var ifflag: c_int = 1;
pub var iffail: c_int = 0;
pub export fn uquery(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var ret: c_int = undefined;
    _ = &ret;
    var oid: c_int = ifdepth;
    _ = &oid;
    var oifl: c_int = ifflag;
    _ = &oifl;
    var oifa: c_int = iffail;
    _ = &oifa;
    var tmp: [*c]struct_recmac = recmac;
    _ = &tmp;
    recmac = null;
    ret = edloop(1);
    recmac = tmp;
    ifdepth = oid;
    ifflag = oifl;
    iffail = oifa;
    return ret;
}
pub var paste_undo: c_int = 1;
pub export var curmacro: [*c]MACRO = null;
pub var macroptr: c_int = 0;
pub var arg: c_int = 0;
pub var argset: c_int = 0;
pub fn exsimple(arg_m: [*c]MACRO, arg_myarg: c_int, arg_u: c_int, arg_k: c_int) callconv(.c) c_int {
    var m = arg_m;
    _ = &m;
    var myarg = arg_myarg;
    _ = &myarg;
    var u = arg_u;
    _ = &u;
    var k = arg_k;
    _ = &k;
    var cmd_1: [*c]const CMD = m.*.cmd;
    _ = &cmd_1;
    var flg: c_int = 0;
    _ = &flg;
    var ret: c_int = 0;
    _ = &ret;
    if (myarg < @as(c_int, 0)) {
        myarg = -myarg;
        if (cmd_1.*.negarg != null) {
            cmd_1 = findcmd(cmd_1.*.negarg);
        } else {
            myarg = 0;
        }
    }
    if ((myarg != @as(c_int, 1)) and !(cmd_1.*.arg != 0)) {
        myarg = 0;
    }
    if (((myarg != @as(c_int, 1)) or !((cmd_1.*.flag & EMINOR) != 0)) or (maint.*.curwin.*.watom.*.what == TYPEQW)) {
        flg = 1;
    }
    if ((ifflag != 0) or ((cmd_1.*.flag & EMETA) != 0)) {
        if ((flg != 0) and (u != 0)) {
            umclear();
        }
        while ((((blk: {
            const ref = &myarg;
            const tmp = ref.*;
            ref.* -= 1;
            break :blk tmp;
        }) != 0) and !(leave != 0)) and !(ret != 0)) {
            ret = execmd(cmd_1, if (m.*.k != -@as(c_int, 256)) m.*.k else k);
        }
        if (leave != 0) return ret;
        if ((flg != 0) and (u != 0)) {
            umclear();
        }
        if (u != 0) {
            undomark();
        }
    }
    return ret;
}
pub export var current_arg: c_int = 1;
pub export var current_arg_set: c_int = 0;
pub export fn exmacro(arg_m: [*c]MACRO, arg_u: c_int, arg_k: c_int) c_int {
    var m = arg_m;
    _ = &m;
    var u = arg_u;
    _ = &u;
    var k = arg_k;
    _ = &k;
    var larg: c_int = undefined;
    _ = &larg;
    var negarg_1: c_int = 0;
    _ = &negarg_1;
    var oid: c_int = 0;
    _ = &oid;
    var oifl: c_int = 0;
    _ = &oifl;
    var oifa: c_int = 0;
    _ = &oifa;
    var ret: c_int = 0;
    _ = &ret;
    var main_ret: c_int = 0;
    _ = &main_ret;
    var o_arg_set: c_int = argset;
    _ = &o_arg_set;
    var o_arg: c_int = arg;
    _ = &o_arg;
    if (argset != 0) {
        larg = arg;
        arg = 0;
        argset = 0;
    } else {
        larg = 1;
    }
    if (!(m.*.steps != null)) {
        return exsimple(m, larg, u, k);
    }
    if (larg < @as(c_int, 0)) {
        larg = -larg;
        negarg_1 = 1;
    }
    if (ifflag != 0) {
        if (u != 0) {
            umclear();
        }
        while (((larg != 0) and !(leave != 0)) and !(ret != 0)) {
            var tmpmac: [*c]MACRO = curmacro;
            _ = &tmpmac;
            var tmpptr: c_int = macroptr;
            _ = &tmpptr;
            var x: c_int = 0;
            _ = &x;
            var stk: c_int = nstack;
            _ = &stk;
            while ((((m != null) and (@as(ptrdiff_t, x) != m.*.n)) and !(leave != 0)) and !(ret != 0)) {
                var d: [*c]MACRO = undefined;
                _ = &d;
                var tmp_arg: c_int = undefined;
                _ = &tmp_arg;
                var tmp_set: c_int = undefined;
                _ = &tmp_set;
                d = m.*.steps[
                    @bitCast(@as(isize, @intCast(blk: {
                        const ref = &x;
                        const tmp = ref.*;
                        ref.* += 1;
                        break :blk tmp;
                    })))
                ];
                curmacro = m;
                macroptr = x;
                tmp_arg = current_arg;
                tmp_set = current_arg_set;
                current_arg = o_arg;
                current_arg_set = o_arg_set;
                if (d.*.steps != null) {
                    oid = ifdepth;
                    oifl = ifflag;
                    oifa = iffail;
                    ifdepth = blk: {
                        const tmp = @as(c_int, 0);
                        iffail = tmp;
                        break :blk tmp;
                    };
                }
                if ((d.*.flg & @as(c_int, 4)) != 0) {
                    argset = o_arg_set;
                    arg = o_arg;
                    larg = 1;
                } else if (((d.*.flg & @as(c_int, 1)) != 0) and (negarg_1 != 0)) {
                    if (argset != 0) {
                        arg = -arg;
                    } else {
                        argset = 1;
                        arg = -@as(c_int, 1);
                    }
                }
                if ((d.*.flg & @as(c_int, 8)) != 0) {
                    larg = 1;
                }
                if ((d.*.flg & @as(c_int, 2)) != 0) {
                    main_ret = exmacro(d, 0, k);
                } else {
                    ret = exmacro(d, 0, k);
                }
                if (d.*.steps != null) {
                    ifdepth = oid;
                    ifflag = oifl;
                    iffail = oifa;
                }
                current_arg = tmp_arg;
                current_arg_set = tmp_set;
                m = curmacro;
                x = macroptr;
            }
            curmacro = tmpmac;
            macroptr = tmpptr;
            while (nstack > stk) {
                _ = upop(null, 0);
            }
            larg -= 1;
        }
        ret |= main_ret;
        if (leave != 0) return ret;
        if (u != 0) {
            umclear();
        }
        if (u != 0) {
            undomark();
        }
    }
    return ret;
}
pub export fn exemac(arg_m: [*c]MACRO, arg_k: c_int) c_int {
    var m = arg_m;
    _ = &m;
    var k = arg_k;
    _ = &k;
    var ret: c_int = undefined;
    _ = &ret;
    record(m, k);
    ifflag = 1;
    ifdepth = blk: {
        const tmp = @as(c_int, 0);
        iffail = tmp;
        break :blk tmp;
    };
    ret = exmacro(m, paste_undo, k);
    return ret;
}
pub export fn exemac_pasting(arg_state: c_int) void {
    var state = arg_state;
    _ = &state;
    if ((state != 0) and (paste_undo != 0)) {
        paste_undo = 0;
        umclear();
        undomark();
    } else if (!(state != 0) and !(paste_undo != 0)) {
        paste_undo = 1;
        umclear();
        undomark();
    }
}
pub fn dorecord(arg_w: [*c]W, arg_c: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var n: c_int = undefined;
    _ = &n;
    var r: [*c]struct_recmac = undefined;
    _ = &r;
    if (notify != null) {
        notify.* = 1;
    }
    if ((c > @as(c_int, '9')) or (c < @as(c_int, '0'))) {
        nungetc(c);
        return -@as(c_int, 1);
    }
    {
        n = 0;
        while (n != @as(c_int, 10)) : (n += 1) if (playmode[@bitCast(@as(isize, @intCast(n)))] != 0) return -@as(c_int, 1);
    }
    r = @ptrCast(@alignCast(joe_malloc(@as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(struct_recmac))))))));
    r.*.m = mkmacro(-@as(c_int, 256), 0, 0, null);
    r.*.next = recmac;
    r.*.n = c - @as(c_int, '0');
    recmac = r;
    return 0;
}
pub export fn urecord(arg_w: [*c]W, arg_c: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    if ((c >= @as(c_int, '0')) and (c <= @as(c_int, '9'))) return dorecord(w, c, null, null) else if (mkqw(w, my_gettext("Macro to record (0-9 or %{abort} to abort): "), slen(my_gettext("Macro to record (0-9 or %{abort} to abort): ")), dorecord, null, null, null) != null) return 0 else return -@as(c_int, 1);
}
pub fn dotimer1(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var num: c_long = undefined;
    _ = &num;
    if (notify != null) {
        notify.* = 1;
    }
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    num = @intFromFloat(calc(bw_1, s, 0));
    if (merr != null) {
        msgnw(w, merr);
        return -@as(c_int, 1);
    }
    timer_macro_delay = num;
    vsrm(s);
    return 0;
}
pub fn dotimer(arg_w: [*c]W, arg_c: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    if ((c < @as(c_int, '0')) or (c > @as(c_int, '9'))) return -@as(c_int, 1);
    c -= '0';
    if (kbdmacro[@bitCast(@as(isize, @intCast(c)))] != null) {
        if (timer_macro != null) {
            rmmacro(timer_macro);
        }
        timer_macro = dupmacro(kbdmacro[@bitCast(@as(isize, @intCast(c)))]);
        timer_macro_delay = 0;
        if (wmkpw(w, my_gettext("Delay in seconds between macro invocation (%{abort} to abort): "), null, dotimer1, null, null, math_cmplt, null, null, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
    } else {
        return -@as(c_int, 1);
    }
}
pub export fn utimer(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    timer_macro_delay = 0;
    if (timer_macro != null) {
        rmmacro(timer_macro);
        timer_macro = null;
    }
    if (mkqw(w, my_gettext("Macro to play (0-9 or %{abort} to abort): "), slen(my_gettext("Macro to play (0-9 or %{abort} to abort): ")), dotimer, null, null, null) != null) return 0 else return -@as(c_int, 1);
}
pub export fn ustop(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    unmac();
    if (recmac != null) {
        var r: [*c]struct_recmac = recmac;
        _ = &r;
        var m: [*c]MACRO = undefined;
        _ = &m;
        dostaupd = 1;
        recmac = r.*.next;
        if (kbdmacro[@bitCast(@as(isize, @intCast(r.*.n)))] != null) {
            rmmacro(kbdmacro[@bitCast(@as(isize, @intCast(r.*.n)))]);
        }
        kbdmacro[@bitCast(@as(isize, @intCast(r.*.n)))] = r.*.m;
        if (recmac != null) {
            record(blk: {
                const tmp = mkmacro(r.*.n + @as(c_int, '0'), 0, 0, findcmd("play"));
                m = tmp;
                break :blk tmp;
            }, -@as(c_int, 256));
            rmmacro(m);
        }
        joe_free(@ptrCast(@alignCast(r)));
    }
    return 0;
}
pub fn doplay(arg_w: [*c]W, arg_c: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    if (notify != null) {
        notify.* = 1;
    }
    if ((c >= @as(c_int, '0')) and (c <= @as(c_int, '9'))) {
        var ret: c_int = undefined;
        _ = &ret;
        c -= '0';
        if ((playmode[@bitCast(@as(isize, @intCast(c)))] != 0) or !(kbdmacro[@bitCast(@as(isize, @intCast(c)))] != null)) return -@as(c_int, 1);
        playmode[@bitCast(@as(isize, @intCast(c)))] = 1;
        ret = exmacro(kbdmacro[@bitCast(@as(isize, @intCast(c)))], 0, c);
        playmode[@bitCast(@as(isize, @intCast(c)))] = 0;
        return ret;
    } else {
        nungetc(c);
        return -@as(c_int, 1);
    }
}
pub export fn umacros(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    var x: c_int = undefined;
    _ = &x;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    _ = p_goto_eol(bw_1.*.cursor);
    {
        x = 0;
        while (x != @as(c_int, 10)) : (x += 1) if (kbdmacro[@bitCast(@as(isize, @intCast(x)))] != null) {
            _ = mtext(@ptrCast(@alignCast(&buf)), kbdmacro[@bitCast(@as(isize, @intCast(x)))]);
            _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
            _ = p_goto_eol(bw_1.*.cursor);
            _ = snprintf(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_long, JOE_MSGBUFSIZE)), "\t^K %c\tMacro %d", x + @as(c_int, '0'), x);
            _ = binss(bw_1.*.cursor, @ptrCast(@alignCast(&buf)));
            _ = p_goto_eol(bw_1.*.cursor);
            _ = binsc(bw_1.*.cursor, '\n');
            _ = pgetc(bw_1.*.cursor);
        };
    }
    return 0;
}
pub export fn save_macros(arg_f: ?*FILE) void {
    var f = arg_f;
    _ = &f;
    var x: c_int = undefined;
    _ = &x;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    {
        x = 0;
        while (x != @as(c_int, 10)) : (x += 1) if (kbdmacro[@bitCast(@as(isize, @intCast(x)))] != null) {
            _ = mtext(@ptrCast(@alignCast(&buf)), kbdmacro[@bitCast(@as(isize, @intCast(x)))]);
            _ = fprintf(f, "\t%d ", x);
            emit_string(f, @ptrCast(@alignCast(&buf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(strlen(@ptrCast(@alignCast(&buf))))))));
            _ = fprintf(f, "\n");
        };
    }
    _ = fprintf(f, "done\n");
}
pub export fn load_macros(arg_f: ?*FILE) void {
    var f = arg_f;
    _ = &f;
    var buf: [1024]u8 = undefined;
    _ = &buf;
    var bf: [1024]u8 = undefined;
    _ = &bf;
    while ((fgets(@ptrCast(@alignCast(&buf)), @bitCast(@as(c_uint, @truncate(@sizeOf(@TypeOf(buf))))), f) != null) and (strcmp(@ptrCast(@alignCast(&buf)), "done\n") != 0)) {
        var p_1: [*c]const u8 = @ptrCast(@alignCast(&buf));
        _ = &p_1;
        var n: c_int = undefined;
        _ = &n;
        var len: ptrdiff_t = undefined;
        _ = &len;
        var sta: ptrdiff_t = undefined;
        _ = &sta;
        _ = parse_ws(&p_1, '#');
        if (!(parse_int(&p_1, &n) != 0)) {
            _ = parse_ws(&p_1, '#');
            len = parse_string(&p_1, @ptrCast(@alignCast(&bf)), @as(ptrdiff_t, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(bf)))))));
            if (len > @as(ptrdiff_t, 0)) {
                kbdmacro[@bitCast(@as(isize, @intCast(n)))] = mparse(null, @ptrCast(@alignCast(&bf)), &sta, 0);
            }
        }
    }
}
pub export fn uplay(arg_w: [*c]W, arg_c: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    if ((c >= @as(c_int, '0')) and (c <= @as(c_int, '9'))) return doplay(w, c, null, null) else if (mkqwna(w, my_gettext("Play-"), slen(my_gettext("Play-")), doplay, null, null, null) != null) return 0 else return -@as(c_int, 1);
}
pub fn doarg(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    var num: c_int = undefined;
    _ = &num;
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    if (notify != null) {
        notify.* = 1;
    }
    num = @intFromFloat(calc(bw_1, s, 1));
    if (merr != null) {
        msgnw(w, merr);
        return -@as(c_int, 1);
    }
    arg = num;
    argset = 1;
    vsrm(s);
    return 0;
}
pub export fn uarg(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (wmkpw(w, my_gettext("No. times to repeat next command (%{abort} to abort): "), null, doarg, null, null, math_cmplt, null, null, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
}
pub fn doif(arg_w: [*c]W, arg_s: [*c]u8, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var s = arg_s;
    _ = &s;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    var num: c_int = undefined;
    _ = &num;
    var bw_1: [*c]BW = undefined;
    _ = &bw_1;
    if (notify != null) {
        notify.* = 1;
    }
    while (true) {
        if (!((w.*.watom.*.what & (TYPETW | TYPEPW)) != 0)) return -@as(c_int, 1);
        bw_1 = @ptrCast(@alignCast(w.*.object));
        if (!false) break;
    }
    num = @intFromFloat(calc(bw_1, s, 0));
    if (merr != null) {
        msgnw(w, merr);
        return -@as(c_int, 1);
    }
    ifflag = if (num != 0) @as(c_int, 1) else @as(c_int, 0);
    iffail = ifdepth;
    vsrm(s);
    return 0;
}
pub fn ifabrt(arg_w: [*c]W, arg_object: ?*anyopaque) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var object = arg_object;
    _ = &object;
    ifdepth -= 1;
    return 0;
}
pub export fn uif(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    ifdepth += 1;
    if (!(ifflag != 0)) return 0;
    if (wmkpw(w, my_gettext("If (%{abort} to abort): "), null, doif, null, ifabrt, math_cmplt, null, null, utf8_map, 0) != null) return 0 else return -@as(c_int, 1);
}
pub export fn uelsif(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (!(ifdepth != 0)) {
        msgnw(w, my_gettext("Elsif without if"));
        return -@as(c_int, 1);
    } else if (ifflag != 0) {
        ifflag = blk: {
            const tmp = @as(c_int, 0);
            iffail = tmp;
            break :blk tmp;
        };
    } else if (ifdepth == iffail) {
        ifflag = 1;
        if (wmkpw(w, my_gettext("Else if: "), null, doif, null, null, math_cmplt, null, null, locale_map, 0) != null) return 0 else return -@as(c_int, 1);
    }
    return 0;
}
pub export fn uelse(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (!(ifdepth != 0)) {
        msgnw(w, my_gettext("Else without if"));
        return -@as(c_int, 1);
    } else if (ifdepth == iffail) {
        ifflag = @intFromBool(!(ifflag != 0));
    }
    return 0;
}
pub export fn uendif(arg_w: [*c]W, arg_k: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var k = arg_k;
    _ = &k;
    if (!(ifdepth != 0)) {
        msgnw(w, my_gettext("Endif without if"));
        return -@as(c_int, 1);
    }
    if (iffail == ifdepth) {
        iffail -= 1;
        ifflag = 1;
    }
    ifdepth -= 1;
    if (ifdepth == @as(c_int, 0)) {
        ifflag = 1;
    }
    return 0;
}
pub export var unaarg: c_int = 0;
pub export var negarg: c_int = 0;
pub fn douarg(arg_w: [*c]W, arg_c: c_int, arg_object: ?*anyopaque, arg_notify: [*c]c_int) callconv(.c) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    var object = arg_object;
    _ = &object;
    var notify = arg_notify;
    _ = &notify;
    if (c == @as(c_int, '-')) {
        negarg = @intFromBool(!(negarg != 0));
    } else if ((c >= @as(c_int, '0')) and (c <= @as(c_int, '9'))) {
        unaarg = ((unaarg * @as(c_int, 10)) + c) - @as(c_int, '0');
    } else if (c == (@as(c_int, 'U') - @as(c_int, '@'))) if (unaarg != 0) {
        unaarg *= 4;
    } else {
        unaarg = 16;
    } else if (((c == @as(c_int, 7)) or (c == @as(c_int, 3))) or (c == @as(c_int, 32))) {
        if (notify != null) {
            notify.* = 1;
        }
        return -@as(c_int, 1);
    } else {
        nungetc(c);
        if (unaarg != 0) {
            arg = unaarg;
        } else if (negarg != 0) {
            arg = 1;
        } else {
            arg = 4;
        }
        if (negarg != 0) {
            arg = -arg;
        }
        argset = 1;
        if (notify != null) {
            notify.* = 1;
        }
        return 0;
    }
    _ = snprintf(msgbuf, @bitCast(@as(c_long, JOE_MSGBUFSIZE)), my_gettext("Repeat %s%d"), if (negarg != 0) @as([*c]const u8, "-") else @as([*c]const u8, ""), unaarg);
    if (mkqwna(w, msgbuf, slen(msgbuf), douarg, null, null, notify) != null) return 0 else return -@as(c_int, 1);
}
pub export fn uuarg(arg_w: [*c]W, arg_c: c_int) c_int {
    var w = arg_w;
    _ = &w;
    var c = arg_c;
    _ = &c;
    unaarg = 0;
    negarg = 0;
    if (((c >= @as(c_int, '0')) and (c <= @as(c_int, '9'))) or (c == @as(c_int, '-'))) return douarg(w, c, null, null) else if (mkqwna(w, my_gettext("Repeat"), slen(my_gettext("Repeat")), douarg, null, null, null) != null) return 0 else return -@as(c_int, 1);
}

comptime {
    if (@sizeOf(struct_macro) != 48) @compileError("MACRO size mismatch");
    if (@sizeOf(struct_cmd) != 48) @compileError("CMD size mismatch");
    if (@sizeOf(struct_recmac) != 24) @compileError("recmac size mismatch");
    if (@sizeOf(struct_window) != 200) @compileError("W size mismatch");
    if (@sizeOf(struct_bw) != 488) @compileError("BW size mismatch");
    if (@sizeOf(struct_screen) != 48) @compileError("Screen size mismatch");
    if (@sizeOf(struct_watom) != 88) @compileError("WATOM size mismatch");
    if (@offsetOf(struct_window, "watom") != 144) @compileError("W.watom offset mismatch");
    if (@offsetOf(struct_window, "object") != 152) @compileError("W.object offset mismatch");
    if (@offsetOf(struct_bw, "cursor") != 24) @compileError("BW.cursor offset mismatch");
    if (@offsetOf(struct_screen, "curwin") != 24) @compileError("Screen.curwin offset mismatch");
    if (@offsetOf(struct_watom, "what") != 80) @compileError("WATOM.what offset mismatch");
}
