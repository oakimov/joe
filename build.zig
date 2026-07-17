const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "joe",
        .root_module = b.createModule(.{
            .root_source_file = null, // C-only build
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    const mod = exe.root_module;

    // ── System libraries ─────────────────────────────────────────────
    mod.linkSystemLibrary("ncurses", .{});

    // ── Include paths ────────────────────────────────────────────────
    mod.addIncludePath(b.path("joe")); // for #include "b.h", "config.h" etc.
    mod.addIncludePath(.{ .cwd_relative = "/opt/local/include" }); // MacPorts ncurses

    // ── Preprocessor defines ─────────────────────────────────────────
    mod.addCMacro("JOERC", "\"\"");
    mod.addCMacro("JOEDATA", "\"\"");

    // ── Pure Zig modules (replacing ported C files) ──────────────────
    // Each Zig module is compiled as an object and linked into the executable.
    // The Zig code exports C ABI functions that the remaining C code calls,
    // enabling gradual per-module replacement.
    const ported_mod = b.createModule(.{
        .root_source_file = b.path("src/ported.zig"),
        .target = target,
        .optimize = optimize,
    });
    const ported_obj = b.addObject(.{
        .name = "ported",
        .root_module = ported_mod,
    });
    mod.addObject(ported_obj);

    // ── C source files ───────────────────────────────────────────────
    // From joe_SOURCES in joe/Makefile.am. Remove files as they are
    // ported to Zig (they get added to ported_mod instead).
    mod.addCSourceFiles(.{
        .files = &.{
            // REMOVED: joe/b.c — replaced by src/gapbuffer.zig
            // REMOVED: joe/blocks.c — replaced by src/blocks.zig
            "joe/bw.c",
            // REMOVED: joe/cmd.c — replaced by src/cmd.zig
            // REMOVED: joe/hash.c — replaced by src/hash.zig
            "joe/help.c",
            // REMOVED: joe/kbd.c — replaced by src/kbd.zig
            // REMOVED: joe/macro.c — replaced by src/macro.zig
            "joe/main.c",
            "joe/menu.c",
            "joe/path.c",
            "joe/poshist.c",
            "joe/pw.c",
            // REMOVED: joe/queue.c — replaced by src/queue.zig
            "joe/qw.c",
            // REMOVED: joe/rc.c — replaced by src/rc.zig
            // REMOVED: joe/regex.c — replaced by src/regex.zig
            // REMOVED: joe/scrn.c — replaced by src/scrn.zig
            "joe/tab.c",
            // REMOVED: joe/termcap.c — replaced by src/termcap.zig
            // REMOVED: joe/tty.c — replaced by src/tty.zig
            "joe/tw.c",
            "joe/ublock.c",
            "joe/uedit.c",
            "joe/uerror.c",
            "joe/ufile.c",
            "joe/uformat.c",
            "joe/uisrch.c",
            "joe/umath.c",
            // REMOVED: joe/undo.c — replaced by src/undo.zig
            "joe/usearch.c",
            "joe/ushell.c",
            "joe/utag.c",
            // REMOVED: joe/va.c — replaced by src/va.zig
            // REMOVED: joe/vfile.c — replaced by src/vfile.zig
            // REMOVED: joe/vs.c — replaced by src/vs.zig
            "joe/w.c",
            // REMOVED: joe/utils.c — replaced by src/utils.zig
            // REMOVED: joe/syntax.c — replaced by src/syntax.zig
            // REMOVED: joe/utf8.c — replaced by src/utf8.zig
            "joe/selinux.c",
            // REMOVED: joe/charmap.c — replaced by src/charmap.zig
            "joe/mouse.c",
            // REMOVED: joe/lattr.c — replaced by src/lattr.zig
            "joe/gettext.c",
            // REMOVED: joe/builtin.c — replaced by src/builtin.zig
            "joe/builtins.c",
            "joe/vt.c",
            "joe/mmenu.c",
            "joe/state.c",
            // REMOVED: joe/options.c — replaced by src/options.zig
            "joe/cclass.c",
            // REMOVED: joe/frag.c — replaced by src/frag.zig
            // REMOVED: joe/colors.c — replaced by src/colors.zig
            "joe/unicat-17.0.0.c",
        },
        .flags = &.{
            // Match GCC/Clang default for signed overflow
            "-fwrapv",
        },
    });

    // ── Install ──────────────────────────────────────────────────────
    b.installArtifact(exe);

    // ── Run step ─────────────────────────────────────────────────────
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the JOE editor");
    run_step.dependOn(&run_cmd.step);
}