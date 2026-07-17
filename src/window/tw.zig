//! Zig-native text window (Phase 5 redesign).
//!
//! Parallel to hybrid `src/tw.zig`. Layout lives in `screen.zig`; this module
//! owns text-window vtable + JOE-compatible status-line formatting (`stagen`).
//! Not wired into the live `joe` binary yet — unit-tested only.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const screen = @import("screen.zig");

pub const vtable: screen.WindowVTable = .{
    .kind = .text,
    .context = "main",
};

pub const TextWindow = struct {
    parent: *screen.Window,
};

/// Snapshot of the values JOE's `stagen()` reads from `BW` / options / globals.
/// No live buffer pointers — callers fill this from editor state (or tests).
pub const StatusContext = struct {
    /// Buffer path/name; `null` ⇒ `"Unnamed"`.
    name: ?[]const u8 = null,
    /// `$HOME` for `~/…` shortening of `%n`; `null` skips shortening.
    home: ?[]const u8 = null,
    changed: bool = false,
    rdonly: bool = false,
    overtype: bool = false,
    wordwrap: bool = false,
    autoindent: bool = false,
    square: bool = false,
    /// Non-null shell pid ⇒ `%S` prints `*SHELL*`.
    shell: bool = false,
    /// 0-based cursor line (JOE `cursor->line`); displayed as `line + 1`.
    line: u64 = 0,
    /// 0-based display column (JOE `piscol`); displayed as `col + 1`.
    col: u64 = 0,
    /// Byte offset (JOE `cursor->byte`).
    byte: u64 = 0,
    /// 0-based last line index (JOE `eof->line`); `%l` shows `total_lines + 1`.
    total_lines: u64 = 0,
    /// File size in bytes (JOE `eof->byte`).
    total_bytes: u64 = 0,
    /// Codepoint under cursor; `null` ⇒ at EOF.
    char_at_cursor: ?u32 = null,
    /// Display width of that codepoint (`%w`); ignored when `char_at_cursor` is null.
    char_width: u8 = 1,
    syntax_name: ?[]const u8 = null,
    /// Autoindent context title string for `%x` (already locale-encoded).
    context_str: ?[]const u8 = null,
    /// Shown for `%x` only when this is non-null (JOE `o.title` gate).
    title: ?[]const u8 = null,
    version: []const u8 = "4.0",
    charmap_name: []const u8 = "utf-8",
    locale_map_name: []const u8 = "utf-8",
    /// `%M` macro number when recording; `null` ⇒ omit.
    macro_n: ?u32 = null,
    /// Partial key sequence bytes for `%k` (7-bit; controls shown as `^X`).
    keyseq: []const u8 = &.{},
    /// Optional Unix time for `%t` / `%u` / `%d*`; `null` ⇒ omit time codes.
    unix_time: ?i64 = null,
    /// `%Ename%` lookup; return `null` to omit.
    getenv: ?*const fn ([]const u8) ?[]const u8 = null,
    /// `%Zname%` syntax-status lookup; return `null` to omit.
    get_status: ?*const fn (*const StatusContext, []const u8) ?[]const u8 = null,
};

fn appendFillSpaces(buf: []u8, fill: u8) void {
    for (buf) |*c| {
        if (c.* == ' ') c.* = fill;
    }
}

fn appendNumber(out: *std.ArrayList(u8), allocator: Allocator, value: u64, pad_width: u8, use_pad: bool, fill: u8, hex: bool, hex_upper: bool) !void {
    var tmp: [32]u8 = undefined;
    const slice = if (hex)
        if (hex_upper)
            if (use_pad)
                try std.fmt.bufPrint(&tmp, "{X:<[1]}", .{ value, pad_width })
            else
                try std.fmt.bufPrint(&tmp, "{X}", .{value})
        else if (use_pad)
            try std.fmt.bufPrint(&tmp, "{x:<[1]}", .{ value, pad_width })
        else
            try std.fmt.bufPrint(&tmp, "{x}", .{value})
    else if (use_pad)
        try std.fmt.bufPrint(&tmp, "{d:<[1]}", .{ value, pad_width })
    else
        try std.fmt.bufPrint(&tmp, "{d}", .{value});
    appendFillSpaces(slice, fill);
    try out.appendSlice(allocator, slice);
}

fn appendDecPad3(out: *std.ArrayList(u8), allocator: Allocator, value: u64, fill: u8) !void {
    var tmp: [16]u8 = undefined;
    const slice = try std.fmt.bufPrint(&tmp, "{d: >3}", .{value});
    appendFillSpaces(slice, fill);
    try out.appendSlice(allocator, slice);
}

/// Double every `\` so `genfmt` later treats path backslashes as literals (JOE `duplicate_backslashes`).
pub fn duplicateBackslashes(allocator: Allocator, s: []const u8) ![]u8 {
    var count: usize = 0;
    for (s) |c| {
        if (c == '\\') count += 1;
    }
    var out = try allocator.alloc(u8, s.len + count);
    var i: usize = 0;
    for (s) |c| {
        out[i] = c;
        i += 1;
        if (c == '\\') {
            out[i] = '\\';
            i += 1;
        }
    }
    return out;
}

/// JOE `simplify_prefix`: replace `$HOME` prefix with `~/`.
pub fn simplifyPrefix(allocator: Allocator, path: []const u8, home: ?[]const u8) ![]u8 {
    if (home) |h| {
        if (h.len > 0 and std.mem.startsWith(u8, path, h) and (path.len == h.len or path[h.len] == '/')) {
            if (path.len == h.len) {
                return try allocator.dupe(u8, "~/");
            }
            return try std.fmt.allocPrint(allocator, "~/{s}", .{path[h.len + 1 ..]});
        }
    }
    return try allocator.dupe(u8, path);
}

/// Display column width of a JOE format string: `\[iudfbIUDFb]` escapes are zero-width.
/// ASCII/byte width only (native scaffold; full UTF-8 width comes with render).
pub fn fmtLen(s: []const u8) usize {
    var col: usize = 0;
    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        if (s[i] == '\\' and i + 1 < s.len) {
            switch (s[i + 1]) {
                'u', 'i', 'd', 'f', 'b', 'U', 'I', 'D', 'F', 'B' => {
                    i += 1;
                    continue;
                },
                else => {
                    col += 1;
                    i += 1;
                    continue;
                },
            }
        }
        col += 1;
    }
    return col;
}

/// Byte offset into `s` at display column `goal` (JOE `fmtpos`).
pub fn fmtPos(s: []const u8, goal: usize) usize {
    if (goal == 0) return 0;
    var col: usize = 0;
    var i: usize = 0;
    while (i < s.len and col < goal) {
        if (s[i] == '\\' and i + 1 < s.len) {
            switch (s[i + 1]) {
                'u', 'i', 'd', 'f', 'b', 'U', 'I', 'D', 'F', 'B' => {
                    i += 2;
                    continue;
                },
                else => {
                    i += 2;
                    col += 1;
                    continue;
                },
            }
        }
        i += 1;
        col += 1;
    }
    return i;
}

fn appendKeyseq(out: *std.ArrayList(u8), allocator: Allocator, keyseq: []const u8, fill: u8) !void {
    const start = out.items.len;
    for (keyseq) |raw| {
        const c = raw & 0x7f;
        if (c < 32) {
            try out.append(allocator, '^');
            try out.append(allocator, c + '@');
        } else if (c == 127) {
            try out.appendSlice(allocator, "^?");
        } else {
            try out.append(allocator, c);
        }
    }
    try out.append(allocator, fill);
    while (out.items.len - start < 4) {
        try out.append(allocator, fill);
    }
}

const CivilTime = struct {
    tm_sec: i32,
    tm_min: i32,
    tm_hour: i32,
    tm_mday: i32,
    tm_mon: i32,
    tm_year: i32,
    tm_wday: i32,
    tm_yday: i32,
};

fn epochToTm(unix_time: i64) CivilTime {
    // Civil-from-days algorithm (Howard Hinnant), UTC.
    const z = unix_time + 719468 * 86400;
    const days = @divFloor(z, 86400);
    const rem = @mod(z, 86400);
    const hour: i32 = @intCast(@divFloor(rem, 3600));
    const min: i32 = @intCast(@divFloor(@mod(rem, 3600), 60));
    const sec: i32 = @intCast(@mod(rem, 60));

    const era = if (days >= 0) @divFloor(days, 146097) else @divFloor(days - 146096, 146097);
    const doe: i64 = days - era * 146097;
    const yoe: i64 = @divFloor(doe - @divFloor(doe, 1460) + @divFloor(doe, 36524) - @divFloor(doe, 146096), 365);
    var y: i64 = yoe + era * 400;
    const doy: i64 = doe - (365 * yoe + @divFloor(yoe, 4) - @divFloor(yoe, 100));
    const mp: i64 = @divFloor(5 * doy + 2, 153);
    const d: i32 = @intCast(doy - @divFloor(153 * mp + 2, 5) + 1);
    const m: i32 = @intCast(if (mp < 10) mp + 3 else mp - 9);
    if (m <= 2) y += 1;

    // 1970-01-01 was Thursday.
    const wday: i32 = @intCast(@mod(days + 4, 7));
    const mdays = [_]i32{ 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };
    var yday = mdays[@intCast(m - 1)] + d - 1;
    const leap = (@mod(y, 4) == 0 and (@mod(y, 100) != 0 or @mod(y, 400) == 0));
    if (leap and m > 2) yday += 1;

    return .{
        .tm_sec = sec,
        .tm_min = min,
        .tm_hour = hour,
        .tm_mday = d,
        .tm_mon = m - 1,
        .tm_year = @intCast(y - 1900),
        .tm_wday = wday,
        .tm_yday = yday,
    };
}

/// JOE `stagen`: expand `%` codes from `fmt` into a newly allocated string.
/// Pass-through for attribute escapes (`\i`, …) — `genfmt` consumes them later.
pub fn stagen(allocator: Allocator, fmt: []const u8, ctx: *const StatusContext, fill: u8) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    errdefer out.deinit(allocator);

    var i: usize = 0;
    while (i < fmt.len) : (i += 1) {
        if (fmt[i] == '%' and i + 1 < fmt.len) {
            i += 1;
            var field: u32 = 0;
            while (i < fmt.len and fmt[i] >= '0' and fmt[i] <= '9' and i + 1 < fmt.len) {
                field = field * 10 + (fmt[i] - '0');
                i += 1;
            }
            if (i >= fmt.len) break;
            const code = fmt[i];
            switch (code) {
                'v' => try out.appendSlice(allocator, ctx.version),
                'x' => {
                    if (ctx.title != null) {
                        if (ctx.context_str) |cs| try out.appendSlice(allocator, cs);
                    }
                },
                'y' => {
                    if (ctx.syntax_name) |syn| {
                        try out.append(allocator, '(');
                        try out.appendSlice(allocator, syn);
                        try out.append(allocator, ')');
                    }
                },
                't' => {
                    if (ctx.unix_time) |ts| {
                        const tm = epochToTm(ts);
                        var hour = tm.tm_hour;
                        if (hour > 12) hour -= 12;
                        if (hour == 0) hour = 12;
                        var tmp: [8]u8 = undefined;
                        const hs = try std.fmt.bufPrint(&tmp, "{d:0>2}", .{hour});
                        if (hs[0] == '0') hs[0] = fill;
                        try out.appendSlice(allocator, hs);
                        try out.append(allocator, ':');
                        var mins: [2]u8 = undefined;
                        const ms = try std.fmt.bufPrint(&mins, "{d:0>2}", .{tm.tm_min});
                        try out.appendSlice(allocator, ms);
                    }
                },
                'u' => {
                    if (ctx.unix_time) |ts| {
                        const tm = epochToTm(ts);
                        var tmp: [8]u8 = undefined;
                        const slice = try std.fmt.bufPrint(&tmp, "{d:0>2}:{d:0>2}", .{ tm.tm_hour, tm.tm_min });
                        try out.appendSlice(allocator, slice);
                    }
                },
                'd' => {
                    if (ctx.unix_time) |ts| {
                        if (i + 1 < fmt.len) {
                            i += 1;
                            const tm = epochToTm(ts);
                            var tmp: [16]u8 = undefined;
                            const slice = switch (fmt[i]) {
                                'd' => try std.fmt.bufPrint(&tmp, "{d:0>2}", .{tm.tm_mday}),
                                'm' => try std.fmt.bufPrint(&tmp, "{d:0>2}", .{tm.tm_mon + 1}),
                                'y' => try std.fmt.bufPrint(&tmp, "{d:0>2}", .{@mod(tm.tm_year, 100)}),
                                'Y' => try std.fmt.bufPrint(&tmp, "{d:0>4}", .{tm.tm_year + 1900}),
                                'w' => try std.fmt.bufPrint(&tmp, "{d}", .{tm.tm_wday}),
                                'D' => try std.fmt.bufPrint(&tmp, "{d:0>3}", .{tm.tm_yday}),
                                else => blk: {
                                    tmp[0] = 'd';
                                    tmp[1] = fmt[i];
                                    break :blk tmp[0..2];
                                },
                            };
                            try out.appendSlice(allocator, slice);
                        } else {
                            try out.append(allocator, 'd');
                        }
                    } else if (i + 1 < fmt.len) {
                        // Consume the date qualifier so formats stay aligned.
                        i += 1;
                    }
                },
                'E' => {
                    const start = i + 1;
                    var j = start;
                    while (j < fmt.len and fmt[j] != '%') : (j += 1) {}
                    if (j < fmt.len and j > start) {
                        const key = fmt[start..j];
                        i = j;
                        if (ctx.getenv) |getenv| {
                            if (getenv(key)) |val| try out.appendSlice(allocator, val);
                        }
                    }
                },
                'Z' => {
                    const start = i + 1;
                    var j = start;
                    while (j < fmt.len and fmt[j] != '%') : (j += 1) {}
                    if (j < fmt.len and j > start) {
                        const key = fmt[start..j];
                        i = j;
                        if (ctx.get_status) |get_status| {
                            if (get_status(ctx, key)) |val| try out.appendSlice(allocator, val);
                        }
                    }
                },
                'T' => try out.append(allocator, if (ctx.overtype) 'O' else 'I'),
                'W' => try out.append(allocator, if (ctx.wordwrap) 'W' else fill),
                'I' => try out.append(allocator, if (ctx.autoindent) 'A' else fill),
                'X' => try out.append(allocator, if (ctx.square) 'X' else fill),
                'n' => {
                    if (ctx.name) |name| {
                        const simplified = try simplifyPrefix(allocator, name, ctx.home);
                        defer allocator.free(simplified);
                        const duped = try duplicateBackslashes(allocator, simplified);
                        defer allocator.free(duped);
                        try out.appendSlice(allocator, duped);
                    } else {
                        try out.appendSlice(allocator, "Unnamed");
                    }
                },
                'm' => {
                    if (ctx.changed) try out.appendSlice(allocator, "(Modified)");
                },
                'R' => {
                    if (ctx.rdonly) try out.appendSlice(allocator, "(Read only)");
                },
                '*' => try out.append(allocator, if (ctx.changed) '*' else fill),
                'r' => try appendNumber(&out, allocator, ctx.line + 1, 4, field != 0, fill, false, false),
                'o' => try appendNumber(&out, allocator, ctx.byte, 4, field != 0, fill, false, false),
                'O' => try appendNumber(&out, allocator, ctx.byte, 4, field != 0, fill, true, true),
                'c' => try appendNumber(&out, allocator, ctx.col + 1, 3, field != 0, fill, false, false),
                'l' => try appendNumber(&out, allocator, ctx.total_lines + 1, 4, field != 0, fill, false, false),
                'p' => {
                    const pct: u64 = if (ctx.total_bytes >= 1024 * 1024)
                        ((ctx.byte >> 10) * 100) / (ctx.total_bytes >> 10)
                    else if (ctx.total_bytes > 0)
                        (ctx.byte * 100) / ctx.total_bytes
                    else
                        100;
                    try appendDecPad3(&out, allocator, pct, fill);
                },
                'a' => {
                    var tmp: [8]u8 = undefined;
                    const slice = if (ctx.char_at_cursor) |ch|
                        try std.fmt.bufPrint(&tmp, "{d: >3}", .{ch})
                    else
                        try std.fmt.bufPrint(&tmp, "   ", .{});
                    appendFillSpaces(slice, fill);
                    try out.appendSlice(allocator, slice);
                },
                'A' => {
                    var tmp: [8]u8 = undefined;
                    const slice = if (ctx.char_at_cursor) |ch|
                        if (field != 0)
                            try std.fmt.bufPrint(&tmp, "{X:0>2}", .{ch})
                        else
                            try std.fmt.bufPrint(&tmp, "{x}", .{ch})
                    else if (field != 0)
                        try std.fmt.bufPrint(&tmp, "  ", .{})
                    else
                        tmp[0..0];
                    appendFillSpaces(slice, fill);
                    try out.appendSlice(allocator, slice);
                },
                'k' => try appendKeyseq(&out, allocator, ctx.keyseq, fill),
                'S' => {
                    if (ctx.shell) try out.appendSlice(allocator, "*SHELL*");
                },
                'M' => {
                    if (ctx.macro_n) |n| {
                        var tmp: [64]u8 = undefined;
                        const slice = try std.fmt.bufPrint(&tmp, "(Macro {d} recording...)", .{n});
                        try out.appendSlice(allocator, slice);
                    }
                },
                'e' => try out.appendSlice(allocator, ctx.charmap_name),
                'b' => try out.appendSlice(allocator, ctx.locale_map_name),
                'w' => {
                    if (ctx.char_at_cursor != null) {
                        var tmp: [8]u8 = undefined;
                        const slice = try std.fmt.bufPrint(&tmp, "{d}", .{ctx.char_width});
                        try out.appendSlice(allocator, slice);
                    }
                },
                else => try out.append(allocator, code),
            }
        } else {
            try out.append(allocator, fmt[i]);
        }
    }

    return try out.toOwnedSlice(allocator);
}

/// Combine left + right status messages into one `width`-column line (JOE `disptw` merge).
/// `fill` pads between left and right. Attribute escapes are width-aware via `fmtLen`/`fmtPos`.
pub fn composeStatus(allocator: Allocator, left: []const u8, right: []const u8, width: usize, fill: u8) ![]u8 {
    const right_cols = fmtLen(right);
    if (right_cols >= width) {
        const cut = fmtPos(right, width);
        return try allocator.dupe(u8, right[0..cut]);
    }
    const left_budget = width - right_cols;
    const left_cut = fmtPos(left, left_budget);
    var out: std.ArrayList(u8) = .empty;
    errdefer out.deinit(allocator);
    try out.appendSlice(allocator, left[0..@min(left_cut, left.len)]);
    const have = fmtLen(out.items);
    if (have < left_budget) {
        try out.appendNTimes(allocator, fill, left_budget - have);
    }
    try out.appendSlice(allocator, right);
    // Truncate to width columns.
    const final_cut = fmtPos(out.items, width);
    if (final_cut < out.items.len) {
        try out.resize(allocator, final_cut);
    }
    return try out.toOwnedSlice(allocator);
}

test "duplicateBackslashes doubles separators" {
    const got = try duplicateBackslashes(testing.allocator, "a\\b\\c");
    defer testing.allocator.free(got);
    try testing.expectEqualStrings("a\\\\b\\\\c", got);
}

test "simplifyPrefix replaces HOME" {
    const got = try simplifyPrefix(testing.allocator, "/Users/me/proj/file", "/Users/me");
    defer testing.allocator.free(got);
    try testing.expectEqualStrings("~/proj/file", got);

    const home_only = try simplifyPrefix(testing.allocator, "/Users/me", "/Users/me");
    defer testing.allocator.free(home_only);
    try testing.expectEqualStrings("~/", home_only);
}

test "stagen %n Unnamed and path" {
    const unnamed = try stagen(testing.allocator, "%n", &.{}, ' ');
    defer testing.allocator.free(unnamed);
    try testing.expectEqualStrings("Unnamed", unnamed);

    const named = try stagen(testing.allocator, "\\i%n", &.{
        .name = "/Users/me/x\\y",
        .home = "/Users/me",
    }, ' ');
    defer testing.allocator.free(named);
    try testing.expectEqualStrings("\\i~/x\\\\y", named);
}

test "stagen row/col field padding and flags" {
    const ctx = StatusContext{
        .line = 4, // display 5
        .col = 2, // display 3
        .changed = true,
        .overtype = false,
        .wordwrap = true,
        .autoindent = false,
        .square = true,
    };
    const got = try stagen(testing.allocator, "%T%W%I%X %4r %3c %*", &ctx, '-');
    defer testing.allocator.free(got);
    // I + W + fill-for-I + X + space + "5---" + space + "3--" + space + '*'
    try testing.expectEqualStrings("IW-X 5--- 3-- *", got);
}

test "stagen modified readonly shell macro syntax" {
    const got = try stagen(testing.allocator, "%n %m%y%R %M %S", &.{
        .name = "foo",
        .changed = true,
        .rdonly = true,
        .syntax_name = "c",
        .macro_n = 1,
        .shell = true,
    }, ' ');
    defer testing.allocator.free(got);
    try testing.expectEqualStrings("foo (Modified)(c)(Read only) (Macro 1 recording...) *SHELL*", got);
}

test "stagen percent and hex byte" {
    const got = try stagen(testing.allocator, "%p %o %O %l", &.{
        .byte = 50,
        .total_bytes = 200,
        .total_lines = 9, // display 10
    }, ' ');
    defer testing.allocator.free(got);
    try testing.expectEqualStrings(" 25 50 32 10", got);
}

test "stagen default lmsg/rmsg pair" {
    const ctx = StatusContext{
        .name = "readme",
        .changed = false,
        .line = 0,
        .col = 0,
    };
    const left = try stagen(testing.allocator, "\\i%n %m %M", &ctx, ' ');
    defer testing.allocator.free(left);
    const right = try stagen(testing.allocator, " %S Ctrl-K H for help", &ctx, ' ');
    defer testing.allocator.free(right);
    try testing.expectEqualStrings("\\ireadme  ", left);
    try testing.expectEqualStrings("  Ctrl-K H for help", right);

    const line = try composeStatus(testing.allocator, left, right, 40, ' ');
    defer testing.allocator.free(line);
    try testing.expectEqual(@as(usize, 40), fmtLen(line));
    try testing.expect(std.mem.endsWith(u8, line, "  Ctrl-K H for help"));
    try testing.expect(std.mem.startsWith(u8, line, "\\ireadme  "));
}

test "fmtLen skips attribute escapes" {
    try testing.expectEqual(@as(usize, 3), fmtLen("\\iabc"));
    try testing.expectEqual(@as(usize, 1), fmtLen("\\i\\uA\\I"));
    // `\i` + a,b,c → 3 cols occupies bytes 0..5 (index past 'c')
    try testing.expectEqual(@as(usize, 5), fmtPos("\\iabcd", 3));
}

test "stagen keyseq and char codes" {
    const got = try stagen(testing.allocator, "%k%a%A", &.{
        .keyseq = &.{ 1, 'x' }, // ^A x
        .char_at_cursor = 0x4f,
    }, ' ');
    defer testing.allocator.free(got);
    // "^Ax " (already 4 cols) + " 79" + "4f"
    try testing.expectEqualStrings("^Ax  794f", got);
}