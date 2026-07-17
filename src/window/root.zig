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
pub const paint = @import("paint.zig");

pub const Screen = screen.Screen;
pub const Window = screen.Window;
pub const WindowId = screen.WindowId;
pub const WindowKind = screen.WindowKind;
pub const WindowVTable = screen.WindowVTable;
pub const fit_min = screen.fit_min;
pub const fit_height = screen.fit_height;
pub const msg_buf_size = screen.msg_buf_size;
pub const TextWindow = tw.TextWindow;
pub const StatusContext = tw.StatusContext;
pub const stagen = tw.stagen;
pub const composeStatus = tw.composeStatus;
pub const fmtLen = tw.fmtLen;
pub const fmtPos = tw.fmtPos;

pub const PromptFlags = pw.PromptFlags;
pub const PromptWindow = pw.PromptWindow;
pub const History = pw.History;

pub const QueryMode = qw.QueryMode;
pub const QueryWindow = qw.QueryWindow;
pub const breakHeight = qw.breakHeight;
pub const promptHeight = qw.promptHeight;

pub const MenuWindow = menu.MenuWindow;
pub const GridConfig = menu.GridConfig;
pub const RcMenu = menu.RcMenu;
pub const RcMenuEntry = menu.RcMenuEntry;
pub const MenuRegistry = menu.MenuRegistry;
pub const configureGrid = menu.configureGrid;
pub const linesFor = menu.linesFor;
pub const commonPrefix = menu.commonPrefix;
pub const completePrefix = menu.completePrefix;

pub const TermScreen = paint.TermScreen;
pub const CursorPos = paint.CursorPos;
pub const writeFmt = paint.writeFmt;
pub const paintMenu = paint.paintMenu;
pub const paintQuery = paint.paintQuery;
pub const paintPrompt = paint.paintPrompt;
pub const paintStatus = paint.paintStatus;
pub const paintMsgs = paint.paintMsgs;
pub const paintLinum = paint.paintLinum;
pub const paintBody = paint.paintBody;
pub const paintText = paint.paintText;
pub const paintWindow = paint.paintWindow;
pub const paintAll = paint.paintAll;

test {
    _ = screen;
    _ = tw;
    _ = pw;
    _ = qw;
    _ = menu;
    _ = paint;
}