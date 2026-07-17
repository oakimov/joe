//! Zig-native raw-mode TTY driver.
//!
//! Uses `std.posix` termios — no C tty.c ABI. Signal helpers are available
//! but SIGWINCH/etc. wiring into the editor loop comes later.

const std = @import("std");
const posix = std.posix;
const builtin = @import("builtin");
const testing = std.testing;

pub const Size = struct {
    rows: u16,
    cols: u16,
};

pub const Tty = struct {
    fd: posix.fd_t,
    orig_termios: posix.termios,
    raw: bool = false,

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

    /// Blocking single-byte read. Higher-level key parsing lives elsewhere.
    pub fn readByte(self: Tty) !u8 {
        var buf: [1]u8 = undefined;
        const n = try posix.read(self.fd, &buf);
        if (n == 0) return error.EndOfStream;
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