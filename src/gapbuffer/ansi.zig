//! Interned ANSI escape sequence cache — replaces the `ansi_code` /
//! `ansi_string` functions in `b.c`.

const intern = @import("intern.zig");

const ANSI_BIT: c_int = @bitCast(@as(u32, 0x80000000));

const AnsiEntry = extern struct {
    code: c_int,
    name: ?*anyopaque,
};

var ansi_hash: ?*anyopaque = null;
var ansi_table: ?*anyopaque = null; // [*c]?*AnsiEntry
var ansi_siz: c_int = 0;
var ansi_len: c_int = 0;

const std = @import("std");

/// Internal entry point (called by pointer.zig with a NUL-terminated
/// stack buffer).  Returns the interned code with the ANSI_BIT set.
pub fn ansi_code_(s: [*c]const u8) c_int {
    if (ansi_hash == null) ansi_hash = intern.htmk(128);
    const slen = std.mem.sliceTo(s, 0);
    if (intern.htfind(ansi_hash.?, s)) |e| {
        return @as(*AnsiEntry, @alignCast(@ptrCast(e))).code;
    }
    const e_ptr = intern.joe_malloc(@sizeOf(AnsiEntry)) orelse return 0;
    const e = @as(*AnsiEntry, @alignCast(@ptrCast(e_ptr)));
    const name = intern.joe_malloc(@as(isize, @intCast(slen.len + 1))) orelse return 0;
    @memcpy(@as([*]u8, @ptrCast(name))[0..slen.len], slen);
    @as([*]u8, @ptrCast(name))[slen.len] = 0;
    e.code = ansi_len;
    e.name = name;
    intern.htadd(ansi_hash.?, @ptrCast(name), e);
    if (ansi_siz == 0) {
        ansi_table = intern.joe_malloc(@as(isize, @intCast(128 * @sizeOf(?*AnsiEntry)))) orelse return e.code | ANSI_BIT;
        ansi_siz = 128;
    } else if (ansi_siz == ansi_len) {
        ansi_siz *= 2;
        ansi_table = intern.joe_realloc(ansi_table.?, @as(isize, @intCast(ansi_siz)) * @sizeOf(?*AnsiEntry)) orelse return e.code | ANSI_BIT;
    }
    const ta: [*c]?*AnsiEntry = @alignCast(@ptrCast(ansi_table.?));
    ta[@as(usize, @intCast(ansi_len))] = e;
    ansi_len += 1;
    return e.code | ANSI_BIT;
}

pub export fn ansi_code(s: [*c]const u8) c_int { return ansi_code_(s); }

pub export fn ansi_string(code: c_int) ?*anyopaque {
    const c = code & ~ANSI_BIT;
    if (c < 0 or c >= ansi_len) return null;
    const ta: [*c]?*AnsiEntry = @alignCast(@ptrCast(ansi_table.?));
    return ta[@as(usize, @intCast(c))].?.name;
}
