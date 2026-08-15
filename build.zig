const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Phase 8: optional Linux-only deps (never required on Darwin).
    const want_selinux = b.option(bool, "selinux", "Link libselinux and enable SELinux helpers") orelse false;
    const want_gpm = b.option(bool, "gpm", "Link libgpm and enable Linux console mouse") orelse false;
    // System dirs: default from --prefix (like classic make install). Pass -Djoerc= / -Djoedata=
    // explicitly empty to force builtins-only + ~/.joe / XDG.
    const joerc_opt = b.option([]const u8, "joerc", "JOERC system rc directory (trailing slash; default: PREFIX/etc/joe/)");
    const joedata_opt = b.option([]const u8, "joedata", "JOEDATA system data directory (trailing slash; default: PREFIX/share/joe/)");
    const spell = b.option([]const u8, "spell", "Spell checker command embedded in installed rc files") orelse "ispell";

    const joerc = ensureTrailingSlash(b, joerc_opt orelse b.fmt("{s}/etc/joe/", .{b.install_prefix}));
    const joedata = ensureTrailingSlash(b, joedata_opt orelse b.fmt("{s}/share/joe/", .{b.install_prefix}));
    const joedoc = b.fmt("{s}/share/doc/joe", .{b.install_prefix});
    const bindir = b.exe_dir;

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
    // Darwin + ReleaseFast: Zig/LLVM GlobalMerge emits size-0 Mach-O BSS aliases;
    // the linker then truncates merge blobs and globals alias (segfault at startup).
    // Use Debug codegen for the ported object on macOS until GlobalMerge/BSS is fixed upstream.
    const ported_optimize: std.builtin.OptimizeMode = if (target.result.os.tag == .macos and optimize == .ReleaseFast)
        .Debug
    else
        optimize;
    const ported_mod = b.createModule(.{
        .root_source_file = b.path("src/ported.zig"),
        .target = target,
        .optimize = ported_optimize,
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

    // Unicode BSS globals (C): avoid Zig/LLVM GlobalMerge size-0 alias bugs on Darwin.
    mod.addCSourceFile(.{ .file = b.path("src/unicode_globals.c"), .flags = &.{ "-std=c99", "-fno-common" } });

    // ── Install binary + data (classic make install layout) ───────
    // Personality names are installed copies of the joe binary (argv[0]
    // selects jmacsrc/jstarrc/…).
    b.installArtifact(exe);
    for ([_][]const u8{ "jmacs", "jstar", "rjoe", "jpico" }) |name| {
        const inst = b.addInstallArtifact(exe, .{ .dest_sub_path = name });
        b.getInstallStep().dependOn(&inst.step);
    }

    b.installDirectory(.{
        .source_dir = b.path("syntax"),
        .install_dir = .{ .custom = "share/joe/syntax" },
        .install_subdir = "",
        .include_extensions = &.{".jsf"},
    });
    b.installDirectory(.{
        .source_dir = b.path("colors"),
        .install_dir = .{ .custom = "share/joe/colors" },
        .install_subdir = "",
        .include_extensions = &.{".jcf"},
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

    // Substituted rc files (from *.in) + helpers — same as Automake rc/.
    const joerc_sub = stripTrailingSlash(joerc);
    const joedata_sub = stripTrailingSlash(joedata);
    const generated_rc = b.addWriteFiles();
    const rc_ins = [_]struct { in_path: []const u8, out_name: []const u8 }{
        .{ .in_path = "rc/joerc.in", .out_name = "joerc" },
        .{ .in_path = "rc/jmacsrc.in", .out_name = "jmacsrc" },
        .{ .in_path = "rc/jstarrc.in", .out_name = "jstarrc" },
        .{ .in_path = "rc/rjoerc.in", .out_name = "rjoerc" },
        .{ .in_path = "rc/jpicorc.in", .out_name = "jpicorc" },
        .{ .in_path = "rc/joerc.zh_TW.in", .out_name = "joerc.zh_TW" },
        .{ .in_path = "rc/jicerc.ru.in", .out_name = "jicerc.ru" },
    };
    for (rc_ins) |rc| {
        const body = substituteInstallPaths(b, readSrc(b, rc.in_path), .{
            .joerc = joerc_sub,
            .joedata = joedata_sub,
            .joedoc = joedoc,
            .spell = spell,
            .bindir = null,
        });
        const generated = generated_rc.add(rc.out_name, body);
        b.getInstallStep().dependOn(&b.addInstallFile(generated, b.fmt("etc/joe/{s}", .{rc.out_name})).step);
    }
    b.installFile("rc/ftyperc", "etc/joe/ftyperc");
    b.installFile("rc/shell.sh", "etc/joe/shell.sh");
    b.installFile("rc/shell.csh", "etc/joe/shell.csh");

    // Man pages (paths substituted like man/Makefile.am).
    const man_body = substituteInstallPaths(b, readSrc(b, "man/joe.1.in"), .{
        .joerc = joerc_sub,
        .joedata = joedata_sub,
        .joedoc = joedoc,
        .spell = spell,
        .bindir = bindir,
    });
    const generated_man = b.addWriteFiles();
    const man1 = generated_man.add("joe.1", man_body);
    b.getInstallStep().dependOn(&b.addInstallFile(man1, "share/man/man1/joe.1").step);
    // Russian translation is prebuilt (no @JOERC@ placeholders).
    b.installFile("man/ru/joe.1", "share/man/ru/man1/joe.1");

    // Docs + desktop entries (classic data_doc_DATA / desktopdir).
    b.installFile("README.md", "share/doc/joe/README.md");
    b.installFile("docs/README.old", "share/doc/joe/README.old");
    b.installFile("docs/man.md", "share/doc/joe/man.md");
    b.installFile("ChangeLog", "share/doc/joe/ChangeLog");
    b.installFile("docs/hacking.md", "share/doc/joe/hacking.md");
    b.installFile("NEWS.md", "share/doc/joe/NEWS.md");

    const desktop_files = [_][]const u8{ "joe.desktop", "jmacs.desktop", "jstar.desktop", "jpico.desktop" };
    const generated_desktop = b.addWriteFiles();
    for (desktop_files) |name| {
        const src = readSrc(b, b.fmt("desktop/{s}", .{name}));
        const body = replaceAll(b, src, "/usr/bin/joe", b.fmt("{s}/joe", .{bindir}));
        const generated = generated_desktop.add(name, body);
        b.getInstallStep().dependOn(&b.addInstallFile(generated, b.fmt("share/applications/{s}", .{name})).step);
    }

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

fn ensureTrailingSlash(b: *std.Build, path: []const u8) []const u8 {
    if (path.len == 0) return path;
    if (path[path.len - 1] == '/') return path;
    return b.fmt("{s}/", .{path});
}

fn stripTrailingSlash(path: []const u8) []const u8 {
    if (path.len > 1 and path[path.len - 1] == '/') return path[0 .. path.len - 1];
    return path;
}

fn readSrc(b: *std.Build, rel: []const u8) []const u8 {
    return b.build_root.handle.readFileAlloc(b.graph.io, rel, b.allocator, .limited(16 * 1024 * 1024)) catch |err| {
        std.debug.panic("failed to read {s}: {s}", .{ rel, @errorName(err) });
    };
}

fn replaceAll(b: *std.Build, haystack: []const u8, needle: []const u8, replacement: []const u8) []const u8 {
    return std.mem.replaceOwned(u8, b.allocator, haystack, needle, replacement) catch @panic("OOM");
}

const InstallSubst = struct {
    joerc: []const u8,
    joedata: []const u8,
    joedoc: []const u8,
    spell: []const u8,
    bindir: ?[]const u8,
};

fn substituteInstallPaths(b: *std.Build, src: []const u8, paths: InstallSubst) []const u8 {
    var out = replaceAll(b, src, "@JOERC@", paths.joerc);
    out = replaceAll(b, out, "@JOEDATA@", paths.joedata);
    out = replaceAll(b, out, "@JOEDOC@", paths.joedoc);
    out = replaceAll(b, out, "@SPELL@", paths.spell);
    if (paths.bindir) |bindir| {
        out = replaceAll(b, out, "@BINDIR@", bindir);
    }
    return out;
}
