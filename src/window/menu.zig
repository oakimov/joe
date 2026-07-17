//! Zig-native menu window (Phase 5 redesign).
//!
//! Parallel to hybrid `src/menu.zig` + `src/mmenu.zig`. Stub vtable only for now.

const screen = @import("screen.zig");

pub const vtable: screen.WindowVTable = .{
    .kind = .menu,
    .context = "menu",
};

pub const MenuWindow = struct {
    parent: *screen.Window,
};
