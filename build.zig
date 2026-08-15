const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Phase 8: optional Linux-only deps (never required on Darwin).
    const want_selinux = b.option(bool, "selinux", "Link libselinux and enable SELinux helpers") orelse false;
    const want_gpm = b.option(bool, "gpm", "Link libgpm and enable Linux console mouse") orelse false;
    // System config/data dirs (empty → builtins + ~/.joe / XDG; production installs should set these).
    const joerc = b.option([]const u8, "joerc", "JOERC system rc directory (trailing slash)") orelse "";
    const joedata = b.option([]const u8, "joedata", "JOEDATA system data directory (trailing slash)") orelse "";

    const is_linux = target.result.os.tag == .linux;
    const enable_selinux = want_selinux and is_linux;
    const enable_gpm = want_gpm and is_linux;

    const build_opts = b.addOptions();
    build_opts.addOption(bool, "selinux", enable_selinux);
    build_opts.addOption(bool, "gpm", enable_gpm);
    build_opts.addOption([]const u8, "joerc", joerc);
    build_opts.addOption([]const u8, "joedata", joedata);

    // Path A is fully Zig-owned. The executable is still linked as a libc
    // host with a Zig object providing every former joe/*.c export.
    const exe = b.addExecutable(.{
        .name = "joe",
        .root_module = b.createModule(.{
            .root_source_file = null,
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    const mod = exe.root_module;

    // ── System libraries ─────────────────────────────────────────────
    mod.linkSystemLibrary("ncurses", .{});
    if (enable_selinux) mod.linkSystemLibrary("selinux", .{});
    if (enable_gpm) mod.linkSystemLibrary("gpm", .{});

    // ── Include paths (C headers remain the JOE declaration surface) ─
    mod.addIncludePath(b.path("joe"));
    mod.addIncludePath(.{ .cwd_relative = "/opt/local/include" }); // MacPorts ncurses

    // Keep preprocessor macros for any residual C tooling / header guards.
    mod.addCMacro("JOERC", b.fmt("\"{s}\"", .{joerc}));
    mod.addCMacro("JOEDATA", b.fmt("\"{s}\"", .{joedata}));
    if (enable_selinux) mod.addCMacro("WITH_SELINUX", "1");
    if (enable_gpm) mod.addCMacro("MOUSE_GPM", "1");

    // ── Zig-native terminal redesign (Phase 3) ────────────────────
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
    const render_mod = b.createModule(.{
        .root_source_file = b.path("src/render/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    render_mod.addImport("terminal", terminal_mod);

    // ── Zig-native window redesign (Phase 5) ──────────────────────
    const window_mod = b.createModule(.{
        .root_source_file = b.path("src/window/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    window_mod.addImport("terminal", terminal_mod);
    window_mod.addImport("render", render_mod);

    // ── Live editor (Path A Zig) ───────────────────────────────────
    const ported_mod = b.createModule(.{
        .root_source_file = b.path("src/ported.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    ported_mod.addOptions("build_options", build_opts);
    ported_mod.addImport("terminal", terminal_mod);
    ported_mod.addImport("render", render_mod);
    if (enable_selinux) {
        ported_mod.linkSystemLibrary("selinux", .{});
        ported_mod.addCMacro("WITH_SELINUX", "1");
    }
    if (enable_gpm) {
        ported_mod.linkSystemLibrary("gpm", .{});
        ported_mod.addCMacro("MOUSE_GPM", "1");
    }
    const ported_obj = b.addObject(.{
        .name = "ported",
        .root_module = ported_mod,
    });
    mod.addObject(ported_obj);

    // ── Install binary + data (Phase 8) ───────────────────────────
    b.installArtifact(exe);

    // System data layout mirrors historical $(data_joedir) / $(sysconf_joedir).
    b.installDirectory(.{
        .source_dir = b.path("syntax"),
        .install_dir = .{ .custom = "share/joe/syntax" },
        .install_subdir = "",
        .exclude_extensions = &.{ ".am", ".in" },
    });
    b.installDirectory(.{
        .source_dir = b.path("colors"),
        .install_dir = .{ .custom = "share/joe/colors" },
        .install_subdir = "",
        .exclude_extensions = &.{ ".am", ".in" },
    });
    b.installDirectory(.{
        .source_dir = b.path("charmaps"),
        .install_dir = .{ .custom = "share/joe/charmaps" },
        .install_subdir = "",
        .exclude_extensions = &.{ ".am", ".in" },
    });
    // JOE reads translations as lang/<locale>.po (not GNU .mo).
    b.installDirectory(.{
        .source_dir = b.path("po"),
        .install_dir = .{ .custom = "share/joe/lang" },
        .install_subdir = "",
        .include_extensions = &.{".po"},
    });
    b.installDirectory(.{
        .source_dir = b.path("rc"),
        .install_dir = .{ .custom = "etc/joe" },
        .install_subdir = "",
        .exclude_extensions = &.{ ".am", ".in" },
    });

    // Personality aliases (jmacs/jstar/rjoe/jpico → joe) are created by
    // packagers / `tools/verify_rc.py` as needed; JOE selects rc via argv[0].


    // ── Unit-test steps (native redesign trees) ───────────────────
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

    // Phase 8 verification suite (rc/jsf/jcf/unicat/bench).
    const phase8 = b.addSystemCommand(&.{ "sh", "tools/phase8_verify.sh" });
        phase8.step.dependOn(b.getInstallStep());
    const phase8_step = b.step("phase8-verify", "Run Phase 8 compatibility verification tools");
    phase8_step.dependOn(&phase8.step);

    // ── Run step ─────────────────────────────────────────────────────
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the JOE editor");
    run_step.dependOn(&run_cmd.step);
}
