//! Zig-native terminal layer (Phase 3 redesign).
//!
//! Parallel to the hybrid C-ABI ports in `src/{tty,termcap,scrn}.zig`.
//! These modules are not yet wired into the live `joe` binary; they grow
//! behind unit tests until the editor loop can switch over.

pub const terminfo = @import("terminfo.zig");
pub const tty = @import("tty.zig");
pub const pty = @import("pty.zig");
pub const screen = @import("screen.zig");

pub const TermInfo = terminfo.TermInfo;
pub const Tty = tty.Tty;
pub const Pty = pty.Pty;
pub const Screen = screen.Screen;
pub const Attribute = screen.Attribute;

test {
    _ = terminfo;
    _ = tty;
    _ = pty;
    _ = screen;
}
