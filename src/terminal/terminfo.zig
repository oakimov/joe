//! Zig-native terminfo binding.
//!
//! Thin wrappers around ncurses `setupterm` / `tiget*` for capability lookup.
//! Escape-sequence emission for common operations lives in `screen.zig`
//! (ANSI SGR/cursor/clear are standardized; terminfo is for rare caps).

const std = @import("std");
const posix = std.posix;
const testing = std.testing;

const c = struct {
    pub extern fn setupterm(term: ?[*:0]const u8, fildes: c_int, errret: ?*c_int) c_int;
    pub extern fn tigetflag(capname: [*:0]const u8) c_int;
    pub extern fn tigetnum(capname: [*:0]const u8) c_int;
    pub extern fn tigetstr(capname: [*:0]const u8) ?[*:0]u8;
};

pub const SetupError = error{
    TermEntryMissing,
    TermHardcopy,
    TermGeneric,
    Unknown,
};

/// Result of `tigetstr`: present / absent / cancelled.
pub const StrCap = union(enum) {
    present: [*:0]const u8,
    absent,
    cancelled,
};

/// Common rare/non-ANSI capabilities we may prefer over hard-coded sequences.
/// Everyday SGR/CUP/ED stay ANSI-direct in `screen.zig`.
pub const Caps = struct {
    cup: ?[:0]const u8 = null,
    clear: ?[:0]const u8 = null,
    smcup: ?[:0]const u8 = null,
    rmcup: ?[:0]const u8 = null,
    smkx: ?[:0]const u8 = null,
    rmkx: ?[:0]const u8 = null,
    bel: ?[:0]const u8 = null,
    flash: ?[:0]const u8 = null,
    /// Set scroll region / insert/delete line — useful before Phase 6 cell-diff.
    csr: ?[:0]const u8 = null,
    il1: ?[:0]const u8 = null,
    dl1: ?[:0]const u8 = null,
};

pub const TermInfo = struct {
    /// Terminal name used for setup (may be empty if `$TERM` was used).
    name: []const u8,
    ready: bool = false,
    caps: Caps = .{},

    /// Load terminfo for `term_name` (null → `$TERM`) against `fd`
    /// (usually stdout). Does not enter curses screen mode.
    pub fn init(term_name: ?[*:0]const u8, fd: posix.fd_t) SetupError!TermInfo {
        var errret: c_int = 0;
        const rc = c.setupterm(term_name, fd, &errret);
        if (rc != 0) {
            return switch (errret) {
                1 => error.TermHardcopy,
                0 => error.TermEntryMissing,
                -1 => error.TermGeneric,
                else => error.Unknown,
            };
        }
        const name: []const u8 = if (term_name) |t| std.mem.span(t) else blk: {
            if (std.c.getenv("TERM")) |t| break :blk std.mem.span(t);
            break :blk "";
        };
        var self: TermInfo = .{
            .name = name,
            .ready = true,
        };
        self.caps = cacheCommonCaps();
        return self;
    }

    fn cacheCommonCaps() Caps {
        return .{
            .cup = presentStr("cup"),
            .clear = presentStr("clear"),
            .smcup = presentStr("smcup"),
            .rmcup = presentStr("rmcup"),
            .smkx = presentStr("smkx"),
            .rmkx = presentStr("rmkx"),
            .bel = presentStr("bel"),
            .flash = presentStr("flash"),
            .csr = presentStr("csr"),
            .il1 = presentStr("il1"),
            .dl1 = presentStr("dl1"),
        };
    }

    fn presentStr(cap: [*:0]const u8) ?[:0]const u8 {
        return switch (getStrRaw(cap)) {
            .present => |p| std.mem.span(p),
            else => null,
        };
    }

    fn getStrRaw(cap: [*:0]const u8) StrCap {
        const p = c.tigetstr(cap);
        if (p == null) return .absent;
        // Cancelled capabilities are returned as (char *)-1.
        if (@intFromPtr(p) == std.math.maxInt(usize)) return .cancelled;
        return .{ .present = p.? };
    }

    pub fn getFlag(self: TermInfo, cap: [*:0]const u8) bool {
        _ = self;
        // ncurses: -1 absent, 0 false/cancelled, 1 true
        return c.tigetflag(cap) > 0;
    }

    pub fn getNum(self: TermInfo, cap: [*:0]const u8) ?i16 {
        _ = self;
        const n = c.tigetnum(cap);
        // ncurses: -2 absent, -1 cancelled, else value
        if (n < 0) return null;
        return @intCast(n);
    }

    pub fn getStr(self: TermInfo, cap: [*:0]const u8) StrCap {
        _ = self;
        return getStrRaw(cap);
    }

    pub fn columns(self: TermInfo) ?u16 {
        const n = self.getNum("cols") orelse return null;
        if (n <= 0) return null;
        return @intCast(n);
    }

    pub fn lines(self: TermInfo) ?u16 {
        const n = self.getNum("lines") orelse return null;
        if (n <= 0) return null;
        return @intCast(n);
    }

    pub fn colors(self: TermInfo) ?u16 {
        const n = self.getNum("colors") orelse return null;
        if (n <= 0) return null;
        return @intCast(n);
    }
};

test "StrCap cancelled sentinel" {
    // Document the ncurses cancelled-pointer convention used by getStr.
    const cancelled_ptr: ?[*:0]u8 = @ptrFromInt(std.math.maxInt(usize));
    try testing.expect(cancelled_ptr != null);
    try testing.expectEqual(@as(usize, std.math.maxInt(usize)), @intFromPtr(cancelled_ptr));
}

test "TermInfo.init against current TERM" {
    // Non-interactive CI / dumb terminals may lack a usable entry — skip then.
    const term_z = std.c.getenv("TERM") orelse return;
    const term = std.mem.span(term_z);
    if (std.mem.eql(u8, term, "dumb") or term.len == 0) return;

    const ti = TermInfo.init(null, posix.STDOUT_FILENO) catch |err| switch (err) {
        error.TermEntryMissing, error.TermHardcopy, error.TermGeneric => return,
        else => return err,
    };
    try testing.expect(ti.ready);
    // Most modern terminals expose cols/lines; treat absence as soft-skip.
    _ = ti.columns();
    _ = ti.lines();
    _ = ti.getFlag("am");
    _ = ti.getStr("cup");
    // Cached rare caps should agree with live tigetstr for cup when present.
    switch (ti.getStr("cup")) {
        .present => |p| {
            try testing.expect(ti.caps.cup != null);
            try testing.expectEqualStrings(std.mem.span(p), ti.caps.cup.?);
        },
        else => {},
    }
}