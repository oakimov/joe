//! Ported modules collector.
//!
//! Root source for the "ported" Zig module.  Imports each ported
//! subsystem so its C ABI exports are compiled and linked.

const std = @import("std");

comptime {
    _ = @import("utf8.zig");
    _ = @import("unicode.zig");
    _ = @import("vfile.zig");
    _ = @import("hash.zig");
    _ = @import("va.zig");
    _ = @import("queue.zig");
    _ = @import("vs.zig");
    _ = @import("blocks.zig");
    _ = @import("utils.zig");
    _ = @import("frag.zig");
    _ = @import("builtin.zig");
    _ = @import("gapbuffer.zig");
    _ = @import("undo.zig");
    _ = @import("lattr.zig");
    _ = @import("charmap.zig");
    _ = @import("regex.zig");
    _ = @import("options.zig");
    _ = @import("rc.zig");
    _ = @import("colors.zig");
    _ = @import("syntax.zig");
    _ = @import("termcap.zig");
    _ = @import("tty.zig");
    _ = @import("scrn.zig");
    _ = @import("kbd.zig");
    _ = @import("macro.zig");
    _ = @import("cmd.zig");
    _ = @import("w.zig");
    _ = @import("tw.zig");
    _ = @import("pw.zig");
    _ = @import("qw.zig");
    _ = @import("menu.zig");
    _ = @import("mmenu.zig");
}
