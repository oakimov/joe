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
    // Path A: gated live bw lgen → Zig-native render.lgenLine (default off).
    _ = @import("bw_lgen.zig");
    // Path A: live uedit motion slice → Zig JOE uedit.h ABI exports.
    _ = @import("uedit.zig");
    // Path A: live ublock mark slice → Zig JOE ublock.h ABI exports.
    _ = @import("ublock.zig");
    // Path A: live uformat → Zig JOE uformat.h ABI exports.
    _ = @import("uformat.zig");
    // Path A: live ushell → Zig JOE ushell.h ABI exports.
    _ = @import("ushell.zig");
    // Path A: live utag → Zig JOE utag.h ABI exports.
    _ = @import("utag.zig");
    // Path A: live umath → Zig JOE umath.h ABI exports.
    _ = @import("umath.zig");
    // Path A: live uisrch → Zig JOE uisrch.h ABI exports.
    _ = @import("uisrch.zig");
    // Path A: live usearch → Zig JOE usearch.h ABI exports.
    _ = @import("usearch.zig");
    // Path A: live uerror → Zig JOE uerror.h ABI exports.
    _ = @import("uerror.zig");
    // Path A: live ufile → Zig JOE ufile.h ABI exports.
    _ = @import("ufile.zig");
    // Path A: live tab → Zig JOE tab.h ABI exports.
    _ = @import("tab.zig");
    // Path A: live path → Zig JOE path.h ABI exports.
    _ = @import("path.zig");
    // Path A: live poshist → Zig JOE poshist.h ABI exports.
    _ = @import("poshist.zig");
    // Path A: live help → Zig JOE help.h ABI exports.
    _ = @import("help.zig");
    // Path A: live mouse → Zig JOE mouse.h ABI exports.
    _ = @import("mouse.zig");
}
