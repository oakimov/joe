//! Zig-native prompt window (Phase 5 redesign).
//!
//! Parallel to hybrid `src/pw.zig`. Stub vtable only for now.

const screen = @import("screen.zig");

pub const vtable: screen.WindowVTable = .{
    .kind = .prompt,
    .context = "prompt",
};

pub const PromptWindow = struct {
    parent: *screen.Window,
};
