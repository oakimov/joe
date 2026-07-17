//! Zig-native text window (Phase 5 redesign).
//!
//! Parallel to hybrid `src/tw.zig`. Stub vtable + helpers only for now.

const screen = @import("screen.zig");

pub const vtable: screen.WindowVTable = .{
    .kind = .text,
    .context = "main",
};

pub const TextWindow = struct {
    parent: *screen.Window,
};
