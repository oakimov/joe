//! Zig-native query window (Phase 5 redesign).
//!
//! Parallel to hybrid `src/qw.zig`. Stub vtable only for now.

const screen = @import("screen.zig");

pub const vtable: screen.WindowVTable = .{
    .kind = .query,
    .context = "query",
};

pub const QueryWindow = struct {
    parent: *screen.Window,
};
