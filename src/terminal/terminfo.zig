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
    /// Parameterize a terminfo string. Result points at a static ncurses buffer.
    pub extern fn tiparm(fmt: [*:0]const u8, ...) ?[*:0]u8;
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
    /// Parameterized insert/delete lines (`il`/`dl`); prefer over repeating `il1`/`dl1`.
    il: ?[:0]const u8 = null,
    dl: ?[:0]const u8 = null,
    il1: ?[:0]const u8 = null,
    dl1: ?[:0]const u8 = null,
    /// Clear to end of line / end of display (`el`/`ed`); ANSI CSI K/J are fallbacks.
    el: ?[:0]const u8 = null,
    ed: ?[:0]const u8 = null,
    /// Parameterized insert/delete characters (`ich`/`dch`); prefer over `ich1`/`dch1`.
    ich: ?[:0]const u8 = null,
    dch: ?[:0]const u8 = null,
    ich1: ?[:0]const u8 = null,
    dch1: ?[:0]const u8 = null,
    /// Relative cursor motion (`cuu`/`cud`/`cuf`/`cub`) and single-step variants.
    cuu: ?[:0]const u8 = null,
    cud: ?[:0]const u8 = null,
    cuf: ?[:0]const u8 = null,
    cub: ?[:0]const u8 = null,
    cuu1: ?[:0]const u8 = null,
    cud1: ?[:0]const u8 = null,
    cuf1: ?[:0]const u8 = null,
    cub1: ?[:0]const u8 = null,
    /// Save / restore cursor position (`sc`/`rc`).
    sc: ?[:0]const u8 = null,
    rc: ?[:0]const u8 = null,
    /// Forward / back tab (`ta`/`bt`) for relative cursor costing.
    ta: ?[:0]const u8 = null,
    bt: ?[:0]const u8 = null,
    /// Absolute column / row address (`hpa`/`vpa`) — JOE `ch`/`cv`.
    hpa: ?[:0]const u8 = null,
    vpa: ?[:0]const u8 = null,
    /// Home / last-line (`home`/`ll`) — JOE `ho`/`ll`.
    home: ?[:0]const u8 = null,
    ll: ?[:0]const u8 = null,
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
            .il = presentStr("il"),
            .dl = presentStr("dl"),
            .il1 = presentStr("il1"),
            .dl1 = presentStr("dl1"),
            .el = presentStr("el"),
            .ed = presentStr("ed"),
            .ich = presentStr("ich"),
            .dch = presentStr("dch"),
            .ich1 = presentStr("ich1"),
            .dch1 = presentStr("dch1"),
            .cuu = presentStr("cuu"),
            .cud = presentStr("cud"),
            .cuf = presentStr("cuf"),
            .cub = presentStr("cub"),
            .cuu1 = presentStr("cuu1"),
            .cud1 = presentStr("cud1"),
            .cuf1 = presentStr("cuf1"),
            .cub1 = presentStr("cub1"),
            .sc = presentStr("sc"),
            .rc = presentStr("rc"),
            .ta = presentStr("ta"),
            .bt = presentStr("bt"),
            .hpa = presentStr("hpa"),
            .vpa = presentStr("vpa"),
            .home = presentStr("home"),
            .ll = presentStr("ll"),
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

    /// Format cursor-address (`cup`) for 0-based (x, y).
    /// Returns null when the cap is missing or tiparm fails — caller should
    /// fall back to ANSI `CSI row;col H`.
    pub fn formatCup(self: TermInfo, x: u16, y: u16) ?[:0]const u8 {
        const fmt = self.caps.cup orelse return null;
        // terminfo cup takes row then column; %i in the string makes them 1-based.
        const p = c.tiparm(fmt.ptr, @as(c_int, y), @as(c_int, x)) orelse return null;
        return std.mem.span(p);
    }

    /// Format scroll-region (`csr`) for 0-based inclusive first/last rows.
    /// Returns null when the cap is missing or tiparm fails — caller should
    /// fall back to ANSI `CSI top;bot r`.
    pub fn formatCsr(self: TermInfo, top: u16, last: u16) ?[:0]const u8 {
        const fmt = self.caps.csr orelse return null;
        const p = c.tiparm(fmt.ptr, @as(c_int, top), @as(c_int, last)) orelse return null;
        return std.mem.span(p);
    }

    /// Format insert-n-lines (`il`). Falls back to repeating `il1` when `il`
    /// is absent. Returns null when neither cap works.
    pub fn formatIl(self: TermInfo, count: u16) ?[]const u8 {
        if (count == 0) return "";
        if (self.caps.il) |fmt| {
            const p = c.tiparm(fmt.ptr, @as(c_int, count)) orelse return null;
            return std.mem.span(p);
        }
        if (count == 1) return self.caps.il1;
        return null; // caller should emit ANSI CSI n L
    }

    /// Format delete-n-lines (`dl`). Falls back to `dl1` for count==1.
    pub fn formatDl(self: TermInfo, count: u16) ?[]const u8 {
        if (count == 0) return "";
        if (self.caps.dl) |fmt| {
            const p = c.tiparm(fmt.ptr, @as(c_int, count)) orelse return null;
            return std.mem.span(p);
        }
        if (count == 1) return self.caps.dl1;
        return null;
    }

    /// Format insert-n-characters (`ich`). Falls back to `ich1` for count==1.
    /// Returns null when neither cap works — caller should emit ANSI `CSI n @`.
    pub fn formatIch(self: TermInfo, count: u16) ?[]const u8 {
        if (count == 0) return "";
        if (self.caps.ich) |fmt| {
            const p = c.tiparm(fmt.ptr, @as(c_int, count)) orelse return null;
            return std.mem.span(p);
        }
        if (count == 1) return self.caps.ich1;
        return null;
    }

    /// Format delete-n-characters (`dch`). Falls back to `dch1` for count==1.
    /// Returns null when neither cap works — caller should emit ANSI `CSI n P`.
    pub fn formatDch(self: TermInfo, count: u16) ?[]const u8 {
        if (count == 0) return "";
        if (self.caps.dch) |fmt| {
            const p = c.tiparm(fmt.ptr, @as(c_int, count)) orelse return null;
            return std.mem.span(p);
        }
        if (count == 1) return self.caps.dch1;
        return null;
    }

    /// Format cursor-up-n (`cuu`). Falls back to `cuu1` for count==1.
    /// Returns null when neither cap works — caller should emit ANSI `CSI n A`.
    pub fn formatCuu(self: TermInfo, count: u16) ?[]const u8 {
        if (count == 0) return "";
        if (self.caps.cuu) |fmt| {
            const p = c.tiparm(fmt.ptr, @as(c_int, count)) orelse return null;
            return std.mem.span(p);
        }
        if (count == 1) return self.caps.cuu1;
        return null;
    }

    /// Format cursor-down-n (`cud`). Falls back to `cud1` for count==1.
    /// Returns null when neither cap works — caller should emit ANSI `CSI n B`.
    pub fn formatCud(self: TermInfo, count: u16) ?[]const u8 {
        if (count == 0) return "";
        if (self.caps.cud) |fmt| {
            const p = c.tiparm(fmt.ptr, @as(c_int, count)) orelse return null;
            return std.mem.span(p);
        }
        if (count == 1) return self.caps.cud1;
        return null;
    }

    /// Format cursor-forward-n (`cuf`). Falls back to `cuf1` for count==1.
    /// Returns null when neither cap works — caller should emit ANSI `CSI n C`.
    pub fn formatCuf(self: TermInfo, count: u16) ?[]const u8 {
        if (count == 0) return "";
        if (self.caps.cuf) |fmt| {
            const p = c.tiparm(fmt.ptr, @as(c_int, count)) orelse return null;
            return std.mem.span(p);
        }
        if (count == 1) return self.caps.cuf1;
        return null;
    }

    /// Format cursor-back-n (`cub`). Falls back to `cub1` for count==1.
    /// Returns null when neither cap works — caller should emit ANSI `CSI n D`.
    pub fn formatCub(self: TermInfo, count: u16) ?[]const u8 {
        if (count == 0) return "";
        if (self.caps.cub) |fmt| {
            const p = c.tiparm(fmt.ptr, @as(c_int, count)) orelse return null;
            return std.mem.span(p);
        }
        if (count == 1) return self.caps.cub1;
        return null;
    }

    /// Tab width from terminfo `it` (or `tw`). Null when absent/invalid.
    pub fn tabWidth(self: TermInfo) ?u16 {
        if (self.getNum("it")) |n| {
            if (n > 0) return @intCast(n);
        }
        if (self.getNum("tw")) |n| {
            if (n > 0) return @intCast(n);
        }
        return null;
    }

    /// True when tabs are destructive (`xt`) and should not be used for motion.
    pub fn destructiveTabs(self: TermInfo) bool {
        return self.getFlag("xt");
    }

    /// True when the terminal has hardware tabs (`pt`) — JOE falls back to `\t`.
    pub fn hasHardwareTabs(self: TermInfo) bool {
        return self.getFlag("pt");
    }

    /// Format horizontal position absolute (`hpa`) for 0-based column `x`.
    /// Returns null when the cap is missing or tiparm fails — caller should
    /// fall back to ANSI `CSI col G` (CHA).
    pub fn formatHpa(self: TermInfo, x: u16) ?[:0]const u8 {
        const fmt = self.caps.hpa orelse return null;
        const p = c.tiparm(fmt.ptr, @as(c_int, x)) orelse return null;
        return std.mem.span(p);
    }

    /// Format vertical position absolute (`vpa`) for 0-based row `y`.
    /// Returns null when the cap is missing or tiparm fails — caller should
    /// fall back to ANSI `CSI row d` (VPA).
    pub fn formatVpa(self: TermInfo, y: u16) ?[:0]const u8 {
        const fmt = self.caps.vpa orelse return null;
        const p = c.tiparm(fmt.ptr, @as(c_int, y)) orelse return null;
        return std.mem.span(p);
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
            // tiparm should produce a CSI-like address for (0,0).
            if (ti.formatCup(0, 0)) |cup| {
                try testing.expect(cup.len > 0);
                try testing.expect(std.mem.indexOfScalar(u8, cup, 'H') != null or std.mem.indexOfScalar(u8, cup, 'f') != null);
            }
        },
        else => {},
    }
    // Soft-check scroll-region / insert-line parameterization when caps exist.
    if (ti.caps.csr != null) {
        if (ti.formatCsr(0, 23)) |csr| {
            try testing.expect(csr.len > 0);
        }
    }
    if (ti.caps.il != null or ti.caps.il1 != null) {
        _ = ti.formatIl(1);
    }
    if (ti.caps.dl != null or ti.caps.dl1 != null) {
        _ = ti.formatDl(1);
    }
    // Soft-check clear-to-EOL/EOS rare caps when present.
    _ = ti.caps.el;
    _ = ti.caps.ed;
    // Soft-check insert/delete character parameterization when caps exist.
    if (ti.caps.ich != null or ti.caps.ich1 != null) {
        _ = ti.formatIch(1);
    }
    if (ti.caps.dch != null or ti.caps.dch1 != null) {
        _ = ti.formatDch(1);
    }
    // Soft-check relative cursor motion / save-restore when caps exist.
    if (ti.caps.cuu != null or ti.caps.cuu1 != null) {
        _ = ti.formatCuu(1);
    }
    if (ti.caps.cud != null or ti.caps.cud1 != null) {
        _ = ti.formatCud(1);
    }
    if (ti.caps.cuf != null or ti.caps.cuf1 != null) {
        _ = ti.formatCuf(1);
    }
    if (ti.caps.cub != null or ti.caps.cub1 != null) {
        _ = ti.formatCub(1);
    }
    _ = ti.caps.sc;
    _ = ti.caps.rc;
    // Soft-check tab / back-tab caps + width when present.
    _ = ti.caps.ta;
    _ = ti.caps.bt;
    _ = ti.tabWidth();
    _ = ti.destructiveTabs();
    _ = ti.hasHardwareTabs();
    // Soft-check absolute column/row + home/last-line caps when present.
    _ = ti.caps.hpa;
    _ = ti.caps.vpa;
    _ = ti.caps.home;
    _ = ti.caps.ll;
    if (ti.caps.hpa != null) _ = ti.formatHpa(0);
    if (ti.caps.vpa != null) _ = ti.formatVpa(0);
}