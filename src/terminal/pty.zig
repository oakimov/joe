//! Zig-native pseudo-terminal helpers for shell windows.
//!
//! Wraps BSD `openpty` / `forkpty` / `login_tty` (libSystem on macOS).

const std = @import("std");
const posix = std.posix;
const builtin = @import("builtin");
const testing = std.testing;

const c = struct {
    pub extern fn openpty(
        amaster: *c_int,
        aslave: *c_int,
        name: ?[*]u8,
        termp: ?*posix.termios,
        winp: ?*posix.winsize,
    ) c_int;
    pub extern fn forkpty(
        amaster: *c_int,
        name: ?[*]u8,
        termp: ?*posix.termios,
        winp: ?*posix.winsize,
    ) posix.pid_t;
    pub extern fn login_tty(fd: c_int) c_int;
};

pub const Pty = struct {
    master: posix.fd_t,
    slave: posix.fd_t,
    /// Optional child from `fork`, or null if only `open` was used.
    child_pid: ?posix.pid_t = null,
    name_buf: [128]u8 = undefined,
    name_len: usize = 0,

    pub fn name(self: *const Pty) []const u8 {
        return self.name_buf[0..self.name_len];
    }

    /// Allocate a pty pair. Does not fork.
    pub fn open(termp: ?*posix.termios, winp: ?*posix.winsize) !Pty {
        var master: c_int = undefined;
        var slave: c_int = undefined;
        var self: Pty = .{
            .master = undefined,
            .slave = undefined,
        };
        if (c.openpty(&master, &slave, &self.name_buf, termp, winp) != 0) {
            return error.OpenPtyFailed;
        }
        self.master = master;
        self.slave = slave;
        self.name_len = std.mem.indexOfScalar(u8, &self.name_buf, 0) orelse self.name_buf.len;
        return self;
    }

    /// `forkpty`-style: parent keeps master; child becomes session leader on slave.
    /// Returns the parent-side Pty with `child_pid` set. In the child this
    /// never returns (caller should `exec` immediately after a 0 pid path —
    /// use `forkWith` when you need an in-Zig child body).
    pub fn fork(termp: ?*posix.termios, winp: ?*posix.winsize) !Pty {
        var master: c_int = undefined;
        var self: Pty = .{
            .master = undefined,
            .slave = -1,
        };
        const pid = c.forkpty(&master, &self.name_buf, termp, winp);
        if (pid < 0) return error.ForkPtyFailed;
        self.master = master;
        self.child_pid = pid;
        self.name_len = std.mem.indexOfScalar(u8, &self.name_buf, 0) orelse self.name_buf.len;
        if (pid == 0) {
            // Child: slave is already controlling tty / stdio via forkpty.
            return self;
        }
        return self;
    }

    pub fn close(self: *Pty) void {
        if (self.master >= 0) {
            _ = std.c.close(self.master);
            self.master = -1;
        }
        if (self.slave >= 0) {
            _ = std.c.close(self.slave);
            self.slave = -1;
        }
    }

    pub fn deinit(self: *Pty) void {
        self.close();
    }
};

pub fn loginTty(fd: posix.fd_t) !void {
    if (c.login_tty(fd) != 0) return error.LoginTtyFailed;
}

test "openpty allocates master/slave pair" {
    if (builtin.os.tag == .windows) return;

    var ws: posix.winsize = .{
        .row = 24,
        .col = 80,
        .xpixel = 0,
        .ypixel = 0,
    };
    var pty = try Pty.open(null, &ws);
    defer pty.deinit();

    try testing.expect(pty.master >= 0);
    try testing.expect(pty.slave >= 0);
    try testing.expect(pty.master != pty.slave);
    // Name is typically /dev/ttysNNN on macOS or /dev/pts/N on Linux.
    try testing.expect(pty.name().len > 0);
}