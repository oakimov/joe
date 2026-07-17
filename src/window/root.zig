//! Zig-native window layer (Phase 5 redesign).
//!
//! Parallel to the hybrid C-ABI ports in `src/{w,tw,pw,qw,menu,mmenu}.zig`.
//! These modules are not yet wired into the live `joe` binary; they grow
//! behind unit tests until the editor loop can switch over.

pub const screen = @import("screen.zig");
pub const tw = @import("tw.zig");
pub const pw = @import("pw.zig");
pub const qw = @import("qw.zig");
pub const menu = @import("menu.zig");

pub const Screen = screen.Screen;
pub const Window = screen.Window;
pub const WindowId = screen.WindowId;
pub const WindowKind = screen.WindowKind;
pub const WindowVTable = screen.WindowVTable;
pub const fit_min = screen.fit_min;
pub const fit_height = screen.fit_height;
pub const StatusContext = tw.StatusContext;
pub const stagen = tw.stagen;
pub const composeStatus = tw.composeStatus;
pub const fmtLen = tw.fmtLen;
pub const fmtPos = tw.fmtPos;

test {
    _ = screen;
    _ = tw;
    _ = pw;
    _ = qw;
    _ = menu;
}