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
pub const Caps = terminfo.Caps;
pub const Tty = tty.Tty;
pub const Key = tty.Key;
pub const KeyParser = tty.KeyParser;
pub const MouseEvent = tty.MouseEvent;
pub const Pty = pty.Pty;
pub const Screen = screen.Screen;
pub const Attribute = screen.Attribute;
pub const Color = screen.Color;
pub const Rgb = screen.Rgb;
pub const displayWidth = screen.displayWidth;
pub const mouse_enable_sgr = tty.mouse_enable_sgr;
pub const mouse_disable_sgr = tty.mouse_disable_sgr;
pub const alt_screen_enter = tty.alt_screen_enter;
pub const alt_screen_leave = tty.alt_screen_leave;
pub const keypad_enable = tty.keypad_enable;
pub const keypad_disable = tty.keypad_disable;
pub const takeWinchPending = tty.takeWinchPending;
pub const noteWinch = tty.noteWinch;
pub const pollResize = tty.pollResize;
pub const installDefaultSigWinch = tty.installDefaultSigWinch;

test {
    _ = terminfo;
    _ = tty;
    _ = pty;
    _ = screen;
}
