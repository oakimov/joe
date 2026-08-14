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

    // ── Zig-native terminal redesign (Phase 3) ────────────────────
    // Parallel module tree; hybrid `src/tty.zig` may import it for the
    // gated `Screen.out` → obuf drain (default off). Not a screen swap.
    const terminal_mod = b.createModule(.{
        .root_source_file = b.path("src/terminal/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    terminal_mod.linkSystemLibrary("ncurses", .{});
    terminal_mod.addIncludePath(.{ .cwd_relative = "/opt/local/include" });
    terminal_mod.addLibraryPath(.{ .cwd_relative = "/opt/local/lib" });

    // ── Zig-native rendering pipeline (Phase 6) ─────────────────
    // Native render pipeline (parallel Path A lives in bw_lgen.zig).
    const render_mod = b.createModule(.{
        .root_source_file = b.path("src/render/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    render_mod.addImport("terminal", terminal_mod);

    // ── Zig-native window redesign (Phase 5) ──────────────────────
    // Parallel module tree; hybrid `src/{w,tw,pw,qw,menu,mmenu}.zig`
    // remain the live path. Not wired into joe yet.
    const window_mod = b.createModule(.{
        .root_source_file = b.path("src/window/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    // Paint bridge may write into Zig-native terminal.Screen cells (tests-only).
    window_mod.addImport("terminal", terminal_mod);
    window_mod.addImport("render", render_mod);

    // ── Pure Zig modules (replacing ported C files) ──────────────────
    // Each Zig module is compiled as an object and linked into the executable.
    // The Zig code exports C ABI functions that the remaining C code calls,
    // enabling gradual per-module replacement.
    const ported_mod = b.createModule(.{
        .root_source_file = b.path("src/ported.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    ported_mod.addImport("terminal", terminal_mod);
    // Path A: gated live `lgen` bridge (`src/bw_lgen.zig`) paints via Phase 6.
    ported_mod.addImport("render", render_mod);
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
            // REMOVED: joe/bw.c — replaced by src/bw_lgen.zig JOE bw.h ABI exports
            // REMOVED: joe/cmd.c — replaced by src/cmd.zig
            // REMOVED: joe/hash.c — replaced by src/hash.zig
            "joe/help.c",
            // REMOVED: joe/kbd.c — replaced by src/kbd.zig
            // REMOVED: joe/macro.c — replaced by src/macro.zig
            "joe/main.c",
            // REMOVED: joe/menu.c — replaced by src/menu.zig
            "joe/path.c",
            "joe/poshist.c",
            // REMOVED: joe/pw.c — replaced by src/pw.zig
            // REMOVED: joe/queue.c — replaced by src/queue.zig
            // REMOVED: joe/qw.c — replaced by src/qw.zig
            // REMOVED: joe/rc.c — replaced by src/rc.zig
            // REMOVED: joe/regex.c — replaced by src/regex.zig
            // REMOVED: joe/scrn.c — replaced by src/scrn.zig
            "joe/tab.c",
            // REMOVED: joe/termcap.c — replaced by src/termcap.zig
            // REMOVED: joe/tty.c — replaced by src/tty.zig
            // REMOVED: joe/tw.c — replaced by src/tw.zig
            // REMOVED: joe/ublock.c — replaced by src/ublock.zig JOE ublock.h ABI exports
            // REMOVED: joe/uedit.c — replaced by src/uedit.zig JOE uedit.h ABI exports
            "joe/uerror.c",
            "joe/ufile.c",
            // REMOVED: joe/uformat.c — replaced by src/uformat.zig JOE uformat.h ABI exports
            "joe/uisrch.c",
            "joe/umath.c",
            // REMOVED: joe/undo.c — replaced by src/undo.zig
            "joe/usearch.c",
            // REMOVED: joe/ushell.c — replaced by src/ushell.zig JOE ushell.h ABI exports
            // REMOVED: joe/utag.c — replaced by src/utag.zig JOE utag.h ABI exports
            // REMOVED: joe/va.c — replaced by src/va.zig
            // REMOVED: joe/vfile.c — replaced by src/vfile.zig
            // REMOVED: joe/vs.c — replaced by src/vs.zig
            // REMOVED: joe/w.c — replaced by src/w.zig
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
            // REMOVED: joe/mmenu.c — replaced by src/mmenu.zig
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

    const terminal_tests = b.addTest(.{
        .name = "terminal-tests",
        .root_module = terminal_mod,
    });
    const run_terminal_tests = b.addRunArtifact(terminal_tests);
    const terminal_test_step = b.step("terminal-test", "Run Zig-native terminal unit tests");
    terminal_test_step.dependOn(&run_terminal_tests.step);

    const render_tests = b.addTest(.{
        .name = "render-tests",
        .root_module = render_mod,
    });
    const run_render_tests = b.addRunArtifact(render_tests);
    const render_test_step = b.step("render-test", "Run Zig-native render unit tests");
    render_test_step.dependOn(&run_render_tests.step);

    const window_tests = b.addTest(.{
        .name = "window-tests",
        .root_module = window_mod,
    });
    const run_window_tests = b.addRunArtifact(window_tests);
    const window_test_step = b.step("window-test", "Run Zig-native window unit tests");
    window_test_step.dependOn(&run_window_tests.step);

    // ── Run step ─────────────────────────────────────────────────────
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the JOE editor");
    run_step.dependOn(&run_cmd.step);
}