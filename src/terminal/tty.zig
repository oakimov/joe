//! Zig-native raw-mode TTY driver + keyboard input parser.
//!
//! Uses `std.posix` termios — no C tty.c ABI. Signal helpers are available
//! but SIGWINCH/etc. wiring into the editor loop comes later.
//!
//! `KeyParser` is byte-driven and unit-testable without a real TTY.
//! `Tty.readKey` feeds the live fd into the same parser.

const std = @import("std");
const posix = std.posix;
const builtin = @import("builtin");
const testing = std.testing;

pub const Size = struct {
    rows: u16,
    cols: u16,
};

/// Logical key events produced by the input parser.
/// Special keys are a Zig-native union (not JOE's 0x10000x mouse codes).
pub const Key = union(enum) {
    char: u21,
    escape,
    up,
    down,
    left,
    right,
    home,
    end,
    page_up,
    page_down,
    insert,
    delete,
    /// Function key F1..F12 (1..=12).
    f: u8,

    pub fn eql(a: Key, b: Key) bool {
        return switch (a) {
            .char => |c| b == .char and b.char == c,
            .f => |n| b == .f and b.f == n,
            else => std.meta.activeTag(a) == std.meta.activeTag(b),
        };
    }
};

/// Incremental parser for UTF-8 + common xterm CSI/SS3 sequences.
pub const KeyParser = struct {
    state: State = .ground,
    utf8_need: u3 = 0,
    utf8_cp: u21 = 0,
    /// CSI parameter/intermediate bytes between ESC [ and final byte.
    csi_buf: [32]u8 = undefined,
    csi_len: usize = 0,

    const State = enum { ground, esc, csi, ss3, utf8 };

    pub fn reset(self: *KeyParser) void {
        self.* = .{};
    }

    pub fn awaitingMore(self: KeyParser) bool {
        return self.state != .ground;
    }

    /// Feed one byte. Returns a complete key, or null if more input is needed.
    pub fn feed(self: *KeyParser, byte: u8) ?Key {
        switch (self.state) {
            .ground => {
                if (byte == 0x1b) {
                    self.state = .esc;
                    return null;
                }
                if (byte < 0x80) {
                    return .{ .char = byte };
                }
                // UTF-8 lead
                const need: u3 = std.unicode.utf8ByteSequenceLength(byte) catch {
                    return .{ .char = 0xFFFD };
                };
                if (need == 1) return .{ .char = byte };
                self.state = .utf8;
                self.utf8_need = need - 1;
                self.utf8_cp = byte & switch (need) {
                    2 => @as(u21, 0x1F),
                    3 => @as(u21, 0x0F),
                    4 => @as(u21, 0x07),
                    else => @as(u21, 0),
                };
                return null;
            },
            .utf8 => {
                if ((byte & 0xC0) != 0x80) {
                    // Invalid continuation — resync on this byte.
                    self.state = .ground;
                    self.utf8_need = 0;
                    return self.feed(byte) orelse .{ .char = 0xFFFD };
                }
                self.utf8_cp = (self.utf8_cp << 6) | (byte & 0x3F);
                self.utf8_need -= 1;
                if (self.utf8_need == 0) {
                    self.state = .ground;
                    const cp = self.utf8_cp;
                    self.utf8_cp = 0;
                    if (cp > 0x10FFFF) return .{ .char = 0xFFFD };
                    return .{ .char = cp };
                }
                return null;
            },
            .esc => {
                if (byte == '[') {
                    self.state = .csi;
                    self.csi_len = 0;
                    return null;
                }
                if (byte == 'O') {
                    self.state = .ss3;
                    return null;
                }
                // ESC <other>: treat as Meta-<other> by returning the char;
                // lone-ESC completion is via `flushPending`.
                self.state = .ground;
                if (byte == 0x1b) {
                    // ESC ESC → Escape then start another ESC sequence.
                    self.state = .esc;
                    return .escape;
                }
                return .{ .char = byte };
            },
            .csi => {
                // CSI final byte is 0x40..=0x7E.
                if (byte >= 0x40 and byte <= 0x7E) {
                    self.state = .ground;
                    const params = self.csi_buf[0..self.csi_len];
                    return decodeCsi(params, byte);
                }
                if (self.csi_len < self.csi_buf.len) {
                    self.csi_buf[self.csi_len] = byte;
                    self.csi_len += 1;
                }
                return null;
            },
            .ss3 => {
                self.state = .ground;
                return decodeSs3(byte);
            },
        }
    }

    /// If a lone ESC is pending (no follower yet), emit `.escape`.
    /// Call after a read timeout when no more bytes arrived.
    pub fn flushPending(self: *KeyParser) ?Key {
        if (self.state == .esc) {
            self.state = .ground;
            return .escape;
        }
        // Incomplete UTF-8 / CSI → replacement / drop.
        if (self.state == .utf8) {
            self.reset();
            return .{ .char = 0xFFFD };
        }
        if (self.state == .csi or self.state == .ss3) {
            self.reset();
            return null;
        }
        return null;
    }

    fn decodeCsi(params: []const u8, final: u8) Key {
        // Arrow / home / end letter forms: ESC [ A/B/C/D/H/F
        if (params.len == 0) {
            return switch (final) {
                'A' => .up,
                'B' => .down,
                'C' => .right,
                'D' => .left,
                'H' => .home,
                'F' => .end,
                else => .{ .char = final },
            };
        }
        // Number forms: ESC [ n ~  and ESC [ 1 ; N R (modifiers ignored for now)
        if (final == '~') {
            const n = parseLeadingUint(params) orelse return .{ .char = '~' };
            return switch (n) {
                1, 7 => .home,
                2 => .insert,
                3 => .delete,
                4, 8 => .end,
                5 => .page_up,
                6 => .page_down,
                11 => .{ .f = 1 },
                12 => .{ .f = 2 },
                13 => .{ .f = 3 },
                14 => .{ .f = 4 },
                15 => .{ .f = 5 },
                17 => .{ .f = 6 },
                18 => .{ .f = 7 },
                19 => .{ .f = 8 },
                20 => .{ .f = 9 },
                21 => .{ .f = 10 },
                23 => .{ .f = 11 },
                24 => .{ .f = 12 },
                else => .{ .char = '~' },
            };
        }
        // ESC [ 1 ; mod R style — take letter final as arrow/home/end.
        return switch (final) {
            'A' => .up,
            'B' => .down,
            'C' => .right,
            'D' => .left,
            'H' => .home,
            'F' => .end,
            'P' => .{ .f = 1 },
            'Q' => .{ .f = 2 },
            'R' => .{ .f = 3 },
            'S' => .{ .f = 4 },
            else => .{ .char = final },
        };
    }

    fn decodeSs3(final: u8) Key {
        // ESC O A/B/C/D and ESC O P/Q/R/S (vt100 keypad / F1–F4)
        return switch (final) {
            'A' => .up,
            'B' => .down,
            'C' => .right,
            'D' => .left,
            'H' => .home,
            'F' => .end,
            'P' => .{ .f = 1 },
            'Q' => .{ .f = 2 },
            'R' => .{ .f = 3 },
            'S' => .{ .f = 4 },
            else => .{ .char = final },
        };
    }

    fn parseLeadingUint(s: []const u8) ?u16 {
        var i: usize = 0;
        while (i < s.len and s[i] >= '0' and s[i] <= '9') : (i += 1) {}
        if (i == 0) return null;
        return std.fmt.parseInt(u16, s[0..i], 10) catch null;
    }
};

pub const Tty = struct {
    fd: posix.fd_t,
    orig_termios: posix.termios,
    raw: bool = false,
    parser: KeyParser = .{},

    /// Take over `fd` (usually stdin), saving the original termios state
    /// and switching to character-at-a-time raw mode.
    pub fn enterRaw(fd: posix.fd_t) !Tty {
        const orig = try posix.tcgetattr(fd);
        var raw_mode = orig;

        // Match JOE's "disable everything except optional XON/XOFF" intent,
        // but prefer the common modern raw profile (no IXON either).
        raw_mode.iflag.BRKINT = false;
        raw_mode.iflag.INPCK = false;
        raw_mode.iflag.ISTRIP = false;
        raw_mode.iflag.ICRNL = false;
        raw_mode.iflag.IXON = false;

        raw_mode.oflag.OPOST = false;

        raw_mode.lflag.ECHO = false;
        raw_mode.lflag.ICANON = false;
        raw_mode.lflag.ISIG = false;
        raw_mode.lflag.IEXTEN = false;

        raw_mode.cc[@intFromEnum(posix.V.MIN)] = 1;
        raw_mode.cc[@intFromEnum(posix.V.TIME)] = 0;

        try posix.tcsetattr(fd, .FLUSH, raw_mode);

        return .{
            .fd = fd,
            .orig_termios = orig,
            .raw = true,
        };
    }

    pub fn leaveRaw(self: *Tty) void {
        if (!self.raw) return;
        posix.tcsetattr(self.fd, .FLUSH, self.orig_termios) catch {};
        self.raw = false;
    }

    pub fn deinit(self: *Tty) void {
        self.leaveRaw();
    }

    pub fn getSize(self: Tty) !Size {
        return getSizeFd(self.fd);
    }

    pub fn writeAll(self: Tty, bytes: []const u8) !void {
        var written: usize = 0;
        while (written < bytes.len) {
            const n = std.c.write(self.fd, bytes[written..].ptr, bytes.len - written);
            if (n < 0) return error.WriteFailed;
            if (n == 0) return error.EndOfStream;
            written += @intCast(n);
        }
    }

    /// Blocking single-byte read. Higher-level key parsing: `readKey`.
    pub fn readByte(self: Tty) !u8 {
        var buf: [1]u8 = undefined;
        const n = try posix.read(self.fd, &buf);
        if (n == 0) return error.EndOfStream;
        return buf[0];
    }

    /// Read bytes until the parser yields a key.
    /// After ESC/partial UTF-8, uses a short timed read so lone Escape can resolve.
    pub fn readKey(self: *Tty) !Key {
        while (true) {
            const byte: u8 = if (self.parser.awaitingMore()) blk: {
                if (try self.readByteTimed(10)) |b| break :blk b;
                if (self.parser.flushPending()) |key| return key;
                // Still incomplete (UTF-8/CSI) — block for the next byte.
                break :blk try self.readByte();
            } else try self.readByte();

            if (self.parser.feed(byte)) |key| return key;
        }
    }

    /// VMIN=0 VTIME≈deciseconds timed read; restores blocking mode after.
    fn readByteTimed(self: *Tty, tenths: u8) !?u8 {
        var attrs = try posix.tcgetattr(self.fd);
        const saved_min = attrs.cc[@intFromEnum(posix.V.MIN)];
        const saved_time = attrs.cc[@intFromEnum(posix.V.TIME)];
        attrs.cc[@intFromEnum(posix.V.MIN)] = 0;
        attrs.cc[@intFromEnum(posix.V.TIME)] = tenths;
        try posix.tcsetattr(self.fd, .DRAIN, attrs);
        defer {
            attrs.cc[@intFromEnum(posix.V.MIN)] = saved_min;
            attrs.cc[@intFromEnum(posix.V.TIME)] = saved_time;
            posix.tcsetattr(self.fd, .DRAIN, attrs) catch {};
        }

        var buf: [1]u8 = undefined;
        const n = try posix.read(self.fd, &buf);
        if (n == 0) return null;
        return buf[0];
    }
};

pub fn getSizeFd(fd: posix.fd_t) !Size {
    var ws: posix.winsize = .{
        .row = 0,
        .col = 0,
        .xpixel = 0,
        .ypixel = 0,
    };
    const rc = std.c.ioctl(fd, @intCast(posix.T.IOCGWINSZ), &ws);
    if (rc < 0) return error.NotATerminal;
    if (ws.row == 0 or ws.col == 0) return error.NotATerminal;
    return .{ .rows = ws.row, .cols = ws.col };
}

/// Install a SIGWINCH handler; returns the previous action.
pub fn installSigWinch(handler: posix.Sigaction.handler_fn) posix.Sigaction {
    const act = posix.Sigaction{
        .handler = .{ .handler = handler },
        .mask = posix.sigemptyset(),
        .flags = 0,
    };
    var old: posix.Sigaction = undefined;
    posix.sigaction(posix.SIG.WINCH, &act, &old);
    return old;
}

fn feedAll(parser: *KeyParser, bytes: []const u8) ?Key {
    var last: ?Key = null;
    for (bytes) |b| {
        if (parser.feed(b)) |k| last = k;
    }
    return last;
}

test "getSizeFd rejects non-tty when possible" {
    // Opening a pipe ensures NotATerminal on platforms that enforce it.
    var fds: [2]posix.fd_t = undefined;
    if (std.c.pipe(&fds) != 0) return error.Unexpected;
    defer {
        _ = std.c.close(fds[0]);
        _ = std.c.close(fds[1]);
    }
    try testing.expectError(error.NotATerminal, getSizeFd(fds[0]));
}

test "enterRaw/leaveRaw roundtrip on controlling tty" {
    // Skip when stdin isn't a terminal (typical for `zig build test`).
    if (builtin.os.tag == .windows) return;
    _ = posix.tcgetattr(posix.STDIN_FILENO) catch return;

    var tty = try Tty.enterRaw(posix.STDIN_FILENO);
    defer tty.deinit();
    try testing.expect(tty.raw);
    tty.leaveRaw();
    try testing.expect(!tty.raw);

    // Original settings should still be restorable / readable.
    _ = try posix.tcgetattr(posix.STDIN_FILENO);
}

test "KeyParser ASCII and UTF-8" {
    var p: KeyParser = .{};
    try testing.expectEqual(Key{ .char = 'a' }, p.feed('a').?);
    // é = C3 A9
    try testing.expect(p.feed(0xC3) == null);
    try testing.expectEqual(Key{ .char = 0xE9 }, p.feed(0xA9).?);
}

test "KeyParser CSI arrows and specials" {
    var p: KeyParser = .{};
    try testing.expectEqual(@as(?Key, .up), feedAll(&p, "\x1b[A"));
    p.reset();
    try testing.expectEqual(@as(?Key, .down), feedAll(&p, "\x1b[B"));
    p.reset();
    try testing.expectEqual(@as(?Key, .right), feedAll(&p, "\x1b[C"));
    p.reset();
    try testing.expectEqual(@as(?Key, .left), feedAll(&p, "\x1b[D"));
    p.reset();
    try testing.expectEqual(@as(?Key, .home), feedAll(&p, "\x1b[H"));
    p.reset();
    try testing.expectEqual(@as(?Key, .delete), feedAll(&p, "\x1b[3~"));
    p.reset();
    try testing.expectEqual(@as(?Key, .page_up), feedAll(&p, "\x1b[5~"));
    p.reset();
    try testing.expectEqual(Key{ .f = 5 }, feedAll(&p, "\x1b[15~").?);
}

test "KeyParser SS3 and lone Escape flush" {
    var p: KeyParser = .{};
    try testing.expectEqual(Key{ .f = 1 }, feedAll(&p, "\x1bOP").?);
    p.reset();
    try testing.expectEqual(@as(?Key, .up), feedAll(&p, "\x1bOA"));
    p.reset();
    try testing.expect(p.feed(0x1b) == null);
    try testing.expectEqual(@as(?Key, .escape), p.flushPending());
}