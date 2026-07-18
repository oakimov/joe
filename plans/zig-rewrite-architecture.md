# JOE Editor — Zig Rewrite Architecture Plan

**Goal:** Ground-up redesign of JOE in Zig, preserving all features, UX, and look-and-feel.
**Target binary name:** `joe` (drop-in replacement)
**Estimated effort:** 4–8 months for one developer

**Progress:**
- ✅ Phase 0: `build.zig` wraps all C sources | C files + 13 Zig modules
- ✅ Phase 1: `utf8`, `unicode`, `vfile`, `gapbuffer` complete
- ✅ Phase 2 (complete core utilities): `hash`, `va`, `vs`, `queue`, `builtin`, `blocks`, `utils`, `frag`, `undo`, `lattr`, `charmap`, `regex`, `options`, `rc` (196/196 green)
- ✅ Phase 2 complete (`rc` landed)
- ✅ Hybrid Phase 3: `colors` + `syntax` + `termcap` + `tty` + `scrn` landed (replaces `joe/colors.c` + `joe/syntax.c` + `joe/termcap.c` + `joe/tty.c` + `joe/scrn.c`, 196/196 green)
- ✅ Hybrid Phase 4: `kbd` + `macro` + `cmd` landed (replaces `joe/kbd.c` + `joe/macro.c` + `joe/cmd.c`, 196/196 green)
- ✅ Hybrid Phase 5 start: `w` landed (replaces `joe/w.c` — window tree/wfit/create/abort/messages, 196/196 green)
- ✅ Hybrid Phase 5: `tw` landed (replaces `joe/tw.c` — text window + status line, 196/196 green)
- ✅ Hybrid Phase 5: `pw` landed (replaces `joe/pw.c` — prompt window/history/completion, 196/196 green)
- ✅ Hybrid Phase 5: `qw` landed (replaces `joe/qw.c` — single-key query windows, 196/196 green)
- ✅ Hybrid Phase 5: `menu` landed (replaces `joe/menu.c` — grid menu widget, 196/196 green)
- ✅ Hybrid Phase 5: `mmenu` landed (replaces `joe/mmenu.c` — rc macro menus, 196/196 green)
- 🚧 Phase 5 redesign: Zig-native `src/window/{root,screen,tw,pw,qw,menu,paint}.zig` — Screen layout + grow/shrink/split/showAll/help-wind + `tw.stagen` status-line + `msg_top`/`msg_bot` helpers + harder layout (off-screen families, next/prev bring-into-view, `layout` child abort-to-fit) + `pw` history/submit/abort/tab callbacks + `qw` `breakHeight`/accept/abort + QueryMode + menu grid/nav/rc-menu/scroll + menu/query/prompt/text watom resize/move(/abort) hooks + create helpers attach typed objects + family `getminh` for `showAll`/`showOne` + `createQuery`/`createMenu` auto-height + tests-only paint shapes (`menu.paint`/`cursorPos`, `qw.paint`, `pw.computeLayout`/`visiblePrompt`) + `TextWindow` content geometry (`movetw`/`resizetw`: status/`lincols`) + paint→`terminal.Screen` bridge + `Screen.term` attach/`paintAll`/`update` edupd-shaped pass + text-body via Phase 6 `render.lgenLine`/`lgenPoint` + per-byte `attr_buf` (`body_lines` or live `GapBuffer`/`line_attrs`/`top_line`/`offset` display-col/`tab`/`cursor_*`/`linums` + `paintBody`/`paintLinum`/`contentCursor`) + help/`wind` chrome (`help_text`/`helpOn`/`helpOff`/`paintHelp`/`paintHelpLine` with `\|` springs; `paintAll` mirrors edupd `help_display`) + shared `fmt.zig` genfmt attr escapes; `zig build window-test` **92/92**; not wired into live joe
- 🚧 Phase 3 redesign deepen: Zig-native `src/terminal/{terminfo,tty,pty,screen,adapter}.zig` unit-tested (`zig build terminal-test` **68/68**); UTF-8 `writeText` + display-width, `Key`/`KeyParser`/`readKey` CSI+SS3+SGR-mouse+bracketed-paste+focus, mouse/alt-screen/keypad/paste/focus enter-leave, truecolor/`Color` SGR, SIGWINCH pending/`pollResize`, terminfo rare-cap cache + `formatCup`/`formatCsr`/`formatIl`/`formatDl`/`formatIch`/`formatDch`/`formatCuu`/`formatCud`/`formatCuf`/`formatCub`/`formatHpa`/`formatVpa` + scroll-region/IL/DL + clear-to-EOL/EOS (`el`/`ed`) + within-line ICH/DCH (`ich`/`dch`) + relative cursor CUU/CUD/CUF/CUB + save/restore (`sc`/`rc`) + smarter `moveTo` (full JOE `cposs` matrix: relative/CUP/CR/home/ll/hpa/vpa/cV/vpa+hpa + CR+vpa/ll+hpa/ll+vpa/home+hpa/home+vpa, scroll-region-relative `rr` home/ll/vpa, `has_cup`/`has_cr`) + tab-aware column costing (`ta`/`bt`/`it`/`xt`/`pt`, `use_tabs` default off) + thin hybrid↔native adapter (`attributeFromHybrid`/`attributeToHybrid` + obuf-style `OutSink`/`drainScreenOut`/`drainScreenOutGated`) + gated hybrid `ttWrite`/`drainZigScreen` (`JOE_ZIG_SCREEN_DRAIN` / `zig_screen_drain_enabled`, default off — live `obuf` path unchanged; not a screen swap); cell-diff `flush` (changed runs + EL blank tails; `display` sync; within-line ICH/DCH magic when pure insert/delete shift); gated hybrid `scrn` swap (`JOE_ZIG_SCREEN_SWAP` / `zig_screen_swap_enabled`, **default on** — paint updates shadow only; `zig_scrn_swap_flush` syncs→Zig cell-diff→drain; `flush_cup_only` + `cursor_valid` fix stale-cursor paints; opt out `=0`); Cell compose slots (`COMPOSE_MARKS=3`) + `writeText`/`syncHybridGridToScreen` combining + flush IL/DL scroll magic (`use_scroll`); `zig build terminal-test` **85/85**)
- **Integration tests:** full suite **196/196 OK** (including viewmode)
- **Recent hybrid fixes:** `binsb` uses `hallocFresh()` so freelist corruption cannot reclaim a still-live gap header and zero its `hole` (was wiping history into NULs/`@` on Command: prompt after 2× `blkcpy`); `inschn` skips `hfree` when `p.hdr == a`; `brm` uses `vsrm(current_dir)`; plus prior `brvs`/`vstrunc`, `binsmq`, `charmap->type`, unicode/`p_goto_bol`/`binsm`/`iskey` fixes
- **Binary size:** Debug hybrid build via `zig build`

---

## 1. Architecture Overview

### Module Dependency Graph (bottom-up)

```
  ┌─────────────────────────────────────────────────────────┐
  │  main.zig — entry point, init sequence, edloop          │
  ├─────────────────────────────────────────────────────────┤
  │  edit.zig — high-level commands, user-facing actions     │
  ├─────────────────────────────────────────────────────────┤
  │  render.zig — lgen(), lgen_core(), lgen_view(), bwgen() │
  ├─────────────────────────────────────────────────────────┤
  │  window.zig — W, BW, TW, PW, QW, MENU window types      │
  ├─────────────────────┬───────────────────────────────────┤
  │  screen.zig         │  menu.zig    │  search.zig        │
  ├─────────────────────┴──────────────┴────────────────────┤
  │  keyboard.zig + macro.zig — KBD, KMAP, MACRO, recording │
  ├─────────────────────────────────────────────────────────┤
  │  terminal.zig — scrn + tty: raw mode, escape sequences, │
  │                 terminfo, signals, ptys, mouse           │
  ├─────────────────────────────────────────────────────────┤
  │  options.zig — glopts table, rc override, file matching  │
  ├─────────────────────────────────────────────────────────┤
  │  rc.zig — parse .joerc (keybindings, menus, options)    │
  ├────────────┬────────────┬───────────────┬───────────────┤
  │  syntax.zig│  color.zig │  regex.zig    │  fileio.zig   │
  │  (.jsf DFA)│  (.jcf     │  (NFA/DFA     │  (load/save)  │
  │            │   schemes) │   engine)     │               │
  ├────────────┴────────────┴───────────────┴───────────────┤
  │  gapbuffer.zig — B, P, H: gap buffer + segment chain    │
  │  vfile.zig — VFILE: swap-backed page storage            │
  │  undo.zig — UNDO/UNDOREC: undo tree + yank              │
  │  lattr.zig — per-line HIGHLIGHT_STATE cache             │
  ├─────────────────────────────────────────────────────────┤
  │  unicode.zig — character categories, widths, case maps   │
  │  utf8.zig — UTF-8 encode/decode                         │
  │  charmap.zig — locale character maps                    │
  └─────────────────────────────────────────────────────────┘
```

### Key Design Principles

| Principle | C (current) | Zig (rewrite) |
|---|---|---|
| Memory | implicit malloc/free via wrappers | Explicit allocator passing everywhere |
| Error handling | global errno-style + sentinel values | Error union types + `!` propagation |
| Null/optional | `NULL` sentinel pointers | `?T` optionals |
| String handling | `char*` + length args | Slices `[]const u8` |
| Tagged unions | manual `union { ... }` + type field | `union(enum) { ... }` |
| Iterator pattern | manual P struct operations | `for (line.iter()) \|c\| { }` |
| Embedded data | generated builtins.c + stringify tool | `@embedFile` at compile time |
| Build system | autoconf + automake + make | Single `build.zig` |
| Tests | external Python unittest | `zig test` per module |

---

## 2. Build System

```zig
// build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "joe",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link system libraries (C ABI, separable)
    exe.linkSystemLibrary("ncurses");        // terminfo queries only
    exe.linkSystemLibrary("selinux");     // SELinux security contexts
    exe.linkSystemLibrary("gpm");         // Linux console mouse
    exe.linkLibC();                          // for libc interop

    // Embed default config files
    // embedFile returns a compile-time known []const u8
    inline for (.{
        "rc/joerc", "rc/ftyperc",
        "syntax/c.jsf", "syntax/md.jsf",
        "syntax/comment_todo.jsf", "syntax/filename.jsf",
        "syntax/context.jsf",
        "colors/default.jcf",
    }) |path| {
        exe.root_module.addAnonymousImport(path, .{ .root_source_file = b.path(path) });
    }

    // Embed Unicode tables as binary blob
    exe.root_module.addAnonymousImport("unicat", .{
        .root_source_file = b.path("src/data/unicat.bin"),
    });

    b.installArtifact(exe);

    // Tests: each module gets `zig test`
    const test_step = b.step("test", "Run all tests");
    for (MODULES) |mod| {
        const t = b.addTest(.{
            .root_source_file = b.path("src/" ++ mod ++ ".zig"),
            .target = target,
        });
        test_step.dependOn(&t.step);
    }
}
```

**Key choices:**
- Link `libc` and `libncurses` only — the rest (termios, sigaction, forkpty, pipe, read/write) come from Zig `std.os` / `std.posix`
- Replace the 67K-line generated `unicat-*.c` with a **binary blob** (`unicat.bin`) loaded at compile time via `@embedFile`, parsed by a small `unicode.zig` reader. The blob is generated from the same source data the current `uniproc` tool uses, but in a compact binary format instead of C literals.
- Config files (`joerc`, `jsf`, `jcf`) embedded via `@embedFile` at comptime — no `stringify` tool needed
- **No autoconf**, no automake, no `stringify`, no generated files in the source tree at all

---

## 3. External Dependencies — C Interop Strategy

| Library | Usage | Zig Approach |
|---|---|---|
| **ncurses** | `tgoto()`, `tgetstr()`, setupterm, terminfo booleans/numbers | Minimal: only `setupterm` + `tigetstr`/`tigetflag`/`tigetnum` for capability lookup. All escape sequence emission done directly. Thin `extern fn` wrappers in `terminal/terminfo.zig` |
| **libutil / util.h** | `forkpty()`, `openpty()`, `login_tty()` | `extern fn forkpty(...) c_int`. Wrapped in `terminal/pty.zig` |
| **SELinux** | `getfilecon()` | `extern fn` in `fileio.zig`, gated by compile-time platform check. Implement for Linux; no-op on other platforms |
| **GPM** | Mouse on Linux console | Open `/dev/gpmctl` directly, parse protocol. Linux-specific; xterm mouse sequences as universal fallback |
| **libintl** | `gettext()` localization | Zig `std.i18n` + `.mo` file parser, or thin C wrapper |
| **libm** | `floor()`, `ceil()`, `sqrt()` | Zig `std.math` — no C dependency needed |
| **POSIX** | `read`, `write`, `open`, `sigaction`, `ioctl`, `fork`, `exec`, `waitpid`, `setpgid`, `tcgetattr`, `tcsetattr`, `stat`, `fstat`, `utimensat`, `pipe`, `dup2` | Zig `std.posix` and `std.os` — no C interop needed |

**Result:** All features are preserved. ncurses provides terminfo access; SELinux and GPM are platform-gated but implemented where applicable.

---

## 4. Module-by-Module Design

### 4.1 Foundation Layer

#### `utf8.zig`
- Direct port of `utf8.c` (~323 lines).
- Functions: `encode(codepoint, out[])`, `decode(bytes[], *pos)` → `?u21`, `valid(bytes[])` `bool`
- No allocations; pure stack/register state machine.

#### `unicode.zig`
- Replaces `unicode.c` + all 7 `unicat-*.c` files (~60K lines of generated C → ~2K Zig + 200K binary blob).
- **Binary blob format** for `unicat.bin`:
  ```
  [4 bytes]  magic "UNIC"
  [4 bytes]  version
  [4 bytes]  num_blocks       (count of interval blocks)
  [8*N bytes] block records   (each: 4-byte lo, 4-byte hi)
  [4 bytes]  num_categories   (count of Unicode general category entries)
  [8*N bytes] category records (each: 4-byte codepoint, 1-byte category,
                                1-byte width, 2-byte padding)
  ```
- Functions: `codepoint_category(cp) Category`, `codepoint_width(cp) u8`, `is_wide(cp) bool`, `case_fold(cp) ?u21`
- Binary data loaded at comptime: `const data = @embedFile("unicat.bin");`

#### `charmap.zig`
- Replaces `charmap.c` (~1823 lines — mostly table parsing).
- Maps between Unicode and locale-specific encodings.
- Simpler design: focus on UTF-8 + UTF-16 as first-class citizens.
- Legacy 8-bit charmap support from the same character map file format.

#### `vfile.zig` — Virtual Memory File
- Replaces `vfile.c` (~796 lines).
- **Page-based virtual memory** with a fixed-size in-memory cache.
- Pages: 4096 bytes each (64-bit). Hash-table lookup, LRU eviction.
- **Simplify:** Instead of the custom cache eviction, use `mmap(MAP_ANONYMOUS)` for the address space and let the OS page. For the swap backing file, use a temp file that grows as needed — same as current `vfile.c` does.
- Key exports:
  ```zig
  const VFile = struct {
      allocator: Allocator,
      backing_fd: ?os.fd_t,          // temp file fd, null when everything is in memory
      pages: std.AutoHashMap(u64, Page),
      // ...
      pub fn read(self, addr: u64, buf: []u8) !usize;
      pub fn write(self, addr: u64, data: []const u8) !void;
  };
  ```

#### `gapbuffer.zig` — Text Buffer
- Replaces `b.c` (~3572 lines — the largest single file).
- Core types:
  ```zig
  pub const B = struct {
      allocator: Allocator,
      vfile: *VFile,
      segments: std.DoublyLinkedList(Segment),
      bof: P,
      eof: P,
      points: std.ArrayList(*P),     // all active points for adjustment
      name: ?[]const u8,
      undo: *Undo,
      lattr: LattrDb,
      options: Options,
      // ...
  };
  
  pub const P = struct {
      buf: *B,
      segment: *Segment,
      offset_in_segment: u16,        // 0..4095
      byte: u64,
      line: u64,
      col: u64,
      // ...
      pub fn getc(self: *P) !?u21;   // pgetc replacement
      pub fn getb(self: *P) !?u8;    // pgetb replacement
      pub fn advance(self: *P, n: i64) !void;  // pfwrd/pbkwd replacement
      pub fn iter(self: *P) PIterator;          → for (p.iter()) |c| { }
      pub fn insert(self: *P, data: []const u8) !void;
      pub fn delete(self: *P, len: u64) !void;
  };
  ```
- **Simplifications over C version:**
  - No custom `SEGSIZ`/`PGSIZE` — use OS page size (4096 on 64-bit)
  - Segment chain uses `std.DoublyLinkedList` instead of hand-rolled LINK macro
  - Points store pointer to `*Segment` directly instead of raw VFILE address + gap arithmetic
  - Gap buffer logic is the same, but expressed more cleanly
  - Use `std.ArrayList` for point tracking instead of linked list embedded in each point

#### `lattr.zig` — Line Attribute Cache
- Replaces `lattr.c` (~364 lines).
- Gap buffer of `HighlightState` structs per line.
- Key optimization: after recomputing, scan forward until `eq_state` matches cached state (same as current).
- `HighlightState` becomes a proper Zig struct instead of a C packed struct.

#### `undo.zig`
- Replaces `undo.c` (~534 lines).
- Types:
  ```zig
  const UndoRecord = struct {
      where: u64,           // byte position
      len: u64,             // length
      is_delete: bool,
      data: union(enum) {   // deleted text storage
          small: []const u8,  // < 1024 bytes: direct copy
          big: *B,            // >= 1024 bytes: separate buffer
      },
      min: bool,            // merge-enable flag
      changed_before: bool, // buffer changed state before this edit
      unit: struct{ first: *UndoRecord, last: *UndoRecord },
      link: std.TailQueue(UndoRecord).Node,
  };
  
  const Undo = struct {
      allocator: Allocator,
      buffer: *B,
      records: std.TailQueue(UndoRecord),
      ptr: ?*UndoRecord,    // for redo
      in_progress: ?Group,
      yank_ring: YankRing,
      // ...
  };
  ```
- Same merge logic, same small/big cutoff.
- Yank ring capped at 100 entries.

---

### 4.2 Syntax Highlighting & Color

#### `syntax.zig` — DFA Engine
- Replaces `syntax.c` (~1107 lines) + `syntax.h`.
- Design:
  ```zig
  const Syntax = struct {
      allocator: Allocator,
      name: []const u8,
      states: []State,
      colors: std.StringHashMap(ColorDef),
      stack_base: ?*Frame,
      delim_stack_base: ?*DelimFrame,
  };
  
  const State = struct {
      color: Attribute,
      default_cmd: ?Command,
      rtree: Rtree(Command),        // radix tree for Unicode-range dispatch
  };
  
  const Command = struct {
      action: Action,               // tagged union
      new_state: *State,
      recolor: i8,
  };
  
  const Action = union(enum) {
      noop,
      goto: *State,
      call: *Syntax,
      ret,
      reset,
      buffer,
      save_c, save_s,
      push_c, push_s, pop_c, pop_s,
      mark, markend, recolor_mark,
  };
  ```
- **Parser:** Reads `.jsf` files structurally. The DFA is the same — but in Zig the transitions are a tagged union instead of a bitfield-bloated C struct.
- **Rtree:** Same 4-level radix tree algorithm, but Zig can use `comptime` to generate optimal lookup tables for the top levels.
- **Keyword lookup:** Replace C Zht (Z-ordered hash) with `std.HashMap` (or better: a `comptime`-generated perfect hash/crit-bit tree).
- **Call mechanism:** Same recursive call-tree with frame sharing, but Frame nodes are arena-allocated.

#### `color.zig` — Color Scheme System
- Replaces `colors.c` (~1073 lines) + `colors.h`.
- **.jcf parser:** Same parsing logic (`.colors 256`, `.set`, `=ClassName`, `-text`), but produces Zig structs instead of C arrays.
- **Attribute packing:** Keep the same packed `int` format for compatibility. Use `std.bitpacked` or manual bit operations.
- **Color resolution:** Cycle-detected inheritance chain (`+ReferenceName`), fallback from scoped → unscoped name.
- **Builtin UI colors:** `-text`, `-status`, `-selection`, etc. — map to enum fields instead of global int pointers.
- **Depth reduction:** truecolor → 256 → 16 → mono, same selection logic.
- **Simplify:** The palette building for truecolor can use `std.AutoArrayHashMap(ColorRGB, u8)` instead of sort-dedup in-place.

#### `regex.zig`
- Replaces `regex.c` (~1623 lines).
- Port the NFA/DFA hybrid engine directly — it's well-tested and self-contained.
- Key improvements:
  - `Result` tagged union instead of fixed-size result array
  - Slices for capture groups
  - Proper error handling for malformed patterns
  - Comptime syntax checking via `regex.compile()`

---

### 4.3 File I/O & Edit Operations

#### `fileio.zig`
- Replaces `ufile.c` (~1444 lines) + the load/save portion of `b.c`.
- Functions:
  ```zig
  pub fn load(allocator, vfile, path: []const u8) !*B;
  pub fn save(buffer: *B, path: []const u8) !void;
  pub fn save_fd(buffer: *B, fd: os.fd_t) !void;
  ```
- UTF-16 detection, CRLF detection, indentation guessing — all ported directly.
- **Simplify:** Use `os.File` instead of `FILE*`. `os.File.writeAll()` handles buffering.
- Pipe support: `std.ChildProcess` for `!command` save/load.

#### `edit.zig`
- Ports: `uedit.c` (~2650 lines), `ublock.c` (~1594 lines), `uformat.c` (~841 lines), `ushell.c` (~465 lines), `utag.c`, `umath.c`, `uisrch.c` (partially), `uerr.c`.
- All edit commands become methods on `B` or free functions taking `*B` + args.
- Key types:
  ```zig
  pub const Block = struct { from: u64, to: u64 };
  pub fn insert(buf: *B, pos: u64, data: []const u8) !void;
  pub fn delete(buf: *B, from: u64, len: u64) !void;
  pub fn copy(buf: *B, block: Block) !B;
  pub fn cut(buf: *B, block: Block) !B;
  pub fn paste(buf: *B, pos: u64, clip: *B) !void;
  pub fn indent(buf: *B, block: Block, amount: u8) !void;
  pub fn format_paragraph(buf: *B, pos: u64, width: u8) !void;
  // ... ~60 command functions
  ```
- Each command is wrapped in `undo.zig` boundary markers.

---

### 4.4 Terminal & Screen

#### `terminal.zig` — scrn + tty
- Replaces `scrn.c` (~2509 lines) + `tty.c` (~1369 lines).
- Major sub-modules:

```zig
const terminal = struct {
    // Terminfo database
    const TermInfo = struct {
        bool_caps: BitFlags(TERMINFO_BOOLS),
        num_caps: [TERMINFO_NUMS]i16,
        str_caps: [TERMINFO_STRS][]const u8,
        pub fn init() !TermInfo;     // wraps setupterm/tiget*
    };

    // Raw-mode terminal driver
    const Tty = struct {
        fd: os.fd_t,
        orig_termios: os.termios,
        pub fn enterRaw() !Tty;
        pub fn leaveRaw(self) void;
        pub fn getSize(self) !struct { rows: u16, cols: u16 };
        pub fn readKey(self) !u21;   // Unicode key, handles escape sequences
    };

    // Pseudo-terminal for shell windows
    const Pty = struct {
        master: os.fd_t,
        slave: os.fd_t,
        child_pid: os.pid_t,
        pub fn open() !Pty;
        pub fn close(self) void;
    };

    // Escape sequence emitter (replaces most of scrn.c)
    const Screen = struct {
        tty: Tty,
        terminfo: TermInfo,
        width: u16,
        height: u16,
        cursor_x: u16,
        cursor_y: u16,
        current_attr: Attribute,
        dirty_rows: std.DynamicBitSet,
        char_buf: [][]u8,           // what's currently on screen
        attr_buf: [][]Attribute,    // what attributes are on screen
        
        pub fn clear(self) void;
        pub fn setAttr(self, attr: Attribute) void;
        pub fn writeChar(self, x: u16, y: u16, char: []const u8, attr: Attribute) void;
        pub fn flush(self) void;     // writes dirty regions via write()
        pub fn scroll(self, region: ...) void;
        pub fn setCursor(self, x: u16, y: u16) void;
    };
    
    // Mouse handler
    const Mouse = struct {
        enabled: bool,
        // Parse GPM protocol or XTerm SGR mouse sequences
        pub fn decodeEvent(buf: []const u8) ?Event;
    };
};
```

**Critical architecture choice:** Instead of the current approach (build an `obuf[]` of raw escape sequences, flush via a single `write`), use a **stateful screen buffer**:
- `char_buf[][]` holds the visible characters
- `attr_buf[][]` holds the visible attributes
- `setAttr()` / `writeChar()` record to the buffer but don't flush
- `flush()` diffs the new state against the buffer and emits only the changed cells — *much* more efficient for scrolling terminals
- Signal handling: `std.posix.sigaction` and `SigSet`

**Simplify:** ANSI escape sequence generation is done directly (no need for terminfo strings for SGR, cursor movement, clear, etc. — they're standardized). Only use terminfo for rare/non-standard capabilities.

---

### 4.5 Keyboard & Macros

#### `keyboard.zig`
- Replaces `kbd.c` (~459 lines).
- Types:
  ```zig
  const Kmap = struct {
      rtree: Rtree(Binding),
      default_binding: ?Binding,
  };
  
  const Binding = union(enum) {
      prefix: *Kmap,        // multi-key sequence (what == 1 in C)
      command: *Command,    // leaf binding (what == 0 in C)
  };
  
  const Kbd = struct {
      current_map: *Kmap,
      top_map: *Kmap,
      sequence: [16]u21,    // chars typed in current prefix sequence
      seq_len: u8,
      pub fn keyPress(self, key: u21) ?*Command;
  };
  ```

- Same radix tree lookup as C version.
- Simplify keymap loading: parse the rc file section directly into Zig structs instead of going through C's interval_list → rtree pipeline.

#### `macro.zig`
- Replaces `macro.c` (~864 lines).
- Types:
  ```zig
  const Macro = struct {
      steps: []const Step,
      allocator: Allocator,
  };
  
  const Step = union(enum) {
      command: *const Command,
      sub_macro: *Macro,
      character: u21,        // for "type" steps
  };
  
  const Recorder = struct {
      recording: *Macro.Builder,
      slot: ?u8,
      // ...
  };
  ```
- Same semantics (recording, playback, conditional, repeat count).
- `Command` struct with function pointer + name + flags remains.

---

### 4.6 Window System

#### `screen.zig`
- Replaces `w.c` (~917 lines).
- Types:
  ```zig
  const Window = struct {
      screen: *Screen,
      x: u16, y: i16, w: u16, h: u16,
      parent: ?*Window,
      children: std.SinglyLinkedList(*Window),
      vtable: *const WindowVTable,
      kbd: *Kbd,
      messages: Messages,
      // ...
  };
  
  const Screen = struct {
      terminal: *terminal.Screen,
      top_win: *Window,
      cur_win: *Window,
      // ...
      pub fn layout(self) void;    // replaces wfit()
      pub fn nextWindow(self) void;
      pub fn prevWindow(self) void;
      pub fn split(self, w: *Window) !*Window;
      pub fn close(self, w: *Window) void;
  };
  ```

- **Simplify:** Give each window a unique ID; use `std.AutoArrayHashMap` for lookups. Use `std.ArrayList` for window ordering instead of circular linked list.
- Window types: TextWindow, PromptWindow, QueryWindow, MenuWindow — each is a Zig struct with a vtable.

#### `window/tw.zig` — Text Window
- Replaces `tw.c` (~997 lines).
- Handles: status line rendering (`stagen()`), text body display via `render.zig`, cursor positioning.
- Status line format strings (`%n`, `%r`, `%c`, etc.) — same logic, Zig string formatting.
- ✅ Native scaffold: `StatusContext` + `stagen` / `composeStatus` / `fmtLen` / `fmtPos` / `simplifyPrefix` (unit-tested; no live BW yet).
- ✅ Native messages: `Window.setMsgBot`/`setMsgTop`/`clearMsgs`/`msgBotRow`/`msgTopRow`, `Screen.composeMsg`/`msg_buf`, main-`close` message transfer (unit-tested).
- ✅ Native paint bridge: `paint.paintMsgs` writes msg top/bot into `terminal.Screen` cells (`mdisp`/`msgout` ofst; unit-tested; not live joe).
- ✅ Native Screen↔terminal attach: `Screen.term` + `attachTerm`/`detachTerm`/`resize` sync + `cursor_x`/`cursor_y` (unit-tested; not live joe).
- ✅ Native edupd-shaped pass: `paint.paintAll` / `paintWindow` / `paintText` + `Screen.update` walk on-screen order → cells + msgs (unit-tested).
- ✅ Native text-body via Phase 6: `TextWindow.body_lines` or live `buffer: *GapBuffer`/`line_attrs`/`top_line`/`offset` (display col)/`tab`/`cursor_*`/`linums`/`syntax`/`viewmode`/`lattr` + `contentCursor`/`bodyLine`/`bodyLineCount`/`lineAttrRow` + `paint.paintBody` → `render.lgenLine`/`lgenPoint` + per-byte `attr_buf` (`render/attr.zig` merge/fromHybridRow) + optional JSF `syntax` fill (+ `hold`) + `LineAttrCache` + markdown `viewmode` (`render/view.zig` `analyzeLine`/`bindScratch` → `Options.view`) + `paintLinum` (tabs/UTF-8/controls/wide clip; unit-tested; table padded box-drawing via `render/table.zig`; OSC 8 via `Cell.url`/flush; no mark yet).
- ✅ Native genfmt attr-escape helper: `window/fmt.zig` (`isAttrEsc`/`applyStyleEsc`) shared by `fmtLen`/`fmtPos`/`writeFmt`/`paintHelpLine` (unit-tested).
- ✅ Native deepen: `TextWindow` content geometry + watom `on_move`/`on_resize` (`movetw`/`resizetw`: `status_enabled`/`status_on`/`lincols`; no SCRN scroll); `splitText` attaches object (unit-tested; no live BW yet).
- ✅ Native paint bridge: `paint.paintStatus` + `writeFmt` (`genfmt` attr escapes) compose `stagen`/`composeStatus` into `terminal.Screen` cells (unit-tested; not live joe).

#### `window/pw.zig` — Prompt Window
- Replaces `pw.c` (~532 lines).
- History, tab completion, callback on Enter.
- ✅ Native deepen: `History` (append/promote) + `PromptWindow` submit/abort/tab callback shapes + `PromptFlags` (unit-tested; no live BW/completion UI yet).
- ✅ Native paint shape: `computeLayout` / `visiblePrompt` (`disppw` scroll + ofst; unit-tested).
- ✅ Native paint bridge: `paint.paintPrompt` writes prompt+edit into `terminal.Screen` cells (unit-tested; no live BW yet).

#### `window/qw.zig` — Query Window
- Replaces `qw.c` (~290 lines).
- Key-capture callbacks for one-character queries.
- ✅ Native deepen: `breakHeight`/`promptHeight` wrap + `QueryMode` (`mkqw`/`mkqwna`/`mkqwnsr`) + acceptKey/abort callbacks (unit-tested; no live paint yet).
- ✅ Native paint shape: `QueryWindow.paint` wrapped prompt rows + cursor (`dispqw`; unit-tested).
- ✅ Native paint bridge: `paint.paintQuery` / `blitQuery` → `terminal.Screen` cells (unit-tested; not live joe).

#### `menu.zig` — Menu System
- Replaces `menu.c` (~720 lines) + `mmenu.c` (~174 lines).
- Generic grid menu + macro-defined menus from rc file.
- Same rendering (INVERSE highlight, column-major layout), same key dispatch.
- ✅ Native paint shape: `MenuWindow.paint` / `cursorPos` / `paintField` (`menudisp` grid + inverse selection; unit-tested).
- ✅ Native paint bridge: `paint.paintMenu` / `blitMenu` → `terminal.Screen` cells with inverse selection (unit-tested; not live joe).

---

### 4.7 Rendering Pipeline

#### `render.zig`
- Replaces `bw.c` (~2997 lines) — the most complex subsystem.
- Submodules:

```zig
// Cell-level attribute (replaces int bitfield)
const Attr = packed struct(u32) {
    inverse: bool = false,
    underline: bool = false,
    bold: bool = false,
    blink: bool = false,
    dim: bool = false,
    italic: bool = false,
    double_underline: bool = false,
    strikethrough: bool = false,
    _unused: u2 = 0,
    bg_color: Color = .default,
    fg_color: Color = .default,
};

// Per-line rendering
fn lgenCore(line: *Line, buf: []Cell, attr_source: *AttrSource) void;
fn lgenView(line: *Line, buf: []Cell, md_state: *MdState) void;  // markdown viewmode

// Full screen render (replaces bwgen)
fn renderWindow(win: *TextWindow, terminal: *Screen, dirty_lines: BitSet) void;

// Viewmode markdown syntax
const MdState = struct {
    hide_mask: std.DynamicBitSet,
    substitute: []Cell,        // Unicode substitution chars
    link_urls: [][]const u8,   // OSC 8 hyperlink targets
};
```

**Key improvements over C:**
- `Attr` as packed struct — compiler checks every field, no manual bit shifting
- `Cell` type combines `char: []const u8` + `attr: Attr` — no parallel arrays
- Screen buffer diffing: only emit escape sequences for changed cells, not the full line
- Viewmode logic (table borders, bullet substitution, heading hiding) is ported directly but expressed as Zig slice operations

---

### 4.8 Configuration & Startup

#### `options.zig`
- Replaces `options.c` (~1596 lines).
- Option descriptor table using `comptime` reflection instead of runtime `offsetof`:
  ```zig
  const OptDesc = struct {
      name: []const u8,
      type: enum { bool, int, string, syntax, encoding, ... },
      field: enum { lmargin, rmargin, tab, autoindent, ... },
      help: []const u8,
      range: ?struct { min: i64, max: i64 },
  };
  const opt_table = comptime blk: {
      // Build from field metadata
  };
  ```
- File-type matching: regex-based, same as current but using `regex.zig`.
- Default OPTIONS are compile-time constants.

#### `rc.zig`
- Replaces `rc.c` (~350 lines).
- Parses `joerc` format line by line.
- Produces: keyboard maps, menu definitions, option defaults, macros.
- Embedded default: `const default_rc = @embedFile("rc/joerc");`.

#### `main.zig`
- Replaces `main.c` (~801 lines).
- Startup sequence:
  1. Parse CLI args (`std.process.args`)
  2. Open terminal → enter raw mode
  3. Load terminfo
  4. Load embedded rc file (or user file)
  5. Create Screen with default window
  6. Open files from argv
  7. Enter `edloop()` (same structure: key → dispatch → render → flush)
- `edloop()` same structure — no changes to the UX loop:
  ```zig
  fn edloop(screen: *Screen) void {
      while (!screen.should_exit) {
          screen.update();             // edupd
          const key = screen.terminal.readKey() catch continue;
          screen.current_window.kbd.keyPress(key);  // dispatch
          screen.flush();              // ttflsh
      }
  }
  ```

---

## 5. Memory Management Strategy

One of the biggest architectural improvements:

| Lifetime | Allocator | Used For |
|---|---|---|
| Program lifetime | `GeneralPurposeAllocator` | Screen, window tree, all KBD maps |
| Per-buffer | `ArenaAllocator` | Buffer metadata, syntax state, color defs |
| Per-command | `ArenaAllocator` (nested) | Temporary strings during edit commands |
| Per-line render | `StackFallbackAllocator` | Render buffers for a single line |
| Per-undo-record | `GeneralPurposeAllocator` (bucketed) | Undo records, small/large text storage |

- **No malloc wrappers needed.** Each function takes `Allocator` as a parameter.
- **No global allocated pointers.** `main.zig` owns a single `GeneralPurposeAllocator` and passes arena allocators downward.

---

## 6. Embedded Data

| Data | Current Approach | Zig Approach |
|---|---|---|
| Default `joerc` | `builtins.c` via `stringify` | `@embedFile("rc/joerc")` |
| Default `ftyperc` | `builtins.c` via `stringify` | `@embedFile("rc/ftyperc")` |
| Syntax files (6) | `builtins.c` via `stringify` | `@embedFile("syntax/*.jsf")` |
| Color schemes | `builtins.c` via `stringify` | `@embedFile("colors/*.jcf")` |
| Unicode tables | 7 `unicat-*.c` files, 67K lines | `@embedFile("data/unicat.bin")` → binary parse |
| Help text | linked in `builtins.c` | `@embedFile("docs/help.txt")` |

**Totally removes:** `joe/util/stringify.c`, `builtins.c`, all `unicat-*.c` files.
**Replaces:** autoconf/automake → `build.zig`.

---

## 7. Implementation Order

The build is always working — start with a binary that compiles and runs, then replace subsystems one at a time.

### Phase 0: Scaffold ✅ DONE
- ✅ `build.zig` that compiles all existing C unchanged
- ✅ Verify binary identical to autoconf build
- ✅ autoconf/automake retained for reference, Zig build is primary

### Phase 1: Foundation (3-4 weeks) — In Progress
- ✅ `utf8.zig` — port UTF-8/16 encode/decode (4 unit tests, replaces `joe/utf8.c`)
- ✅ `unicode.zig` — port character property lookups (replaces `joe/unicode.c`, 196 integration tests pass)
- ✅ `vfile.zig` — port virtual memory file (replaces `joe/vfile.c`, 196 tests pass)
- ✅ `gapbuffer.zig` — port B/P/H gap buffer (replaces `joe/b.c`; multi-file module: types/intern/ansi/pointer/search/buffer/fileio; 196 tests pass)
- ✅ Unit tests for each module (zig test + existing Python integration suite)

### Phase 2: Core (4-6 weeks) — COMPLETE
- ✅ `hash.zig` — port hash tables and atom tables (replaces `joe/hash.c`, 196 tests pass)
- ✅ `va.zig` — variable-length string arrays (replaces `joe/va.c`)
- ✅ `vs.zig` — variable-length strings (replaces `joe/vs.c`)
- ✅ `queue.zig` — doubly-linked list allocator (replaces `joe/queue.c`)
- ✅ `builtin.zig` — built-in config file I/O (replaces `joe/builtin.c`)
- ✅ `blocks.zig` — block memory ops mset/mmove/mcnt (replaces `joe/blocks.c`)
- ✅ `utils.zig` — utilities, malloc wrappers, parsers (replaces `joe/utils.c`)
- ✅ `frag.zig` — bytecode fragment construction (replaces `joe/frag.c`)
- ✅ `undo.zig` — undo/redo/yank (replaces `joe/undo.c`)
- ✅ `lattr.zig` — line attribute cache (replaces `joe/lattr.c`, 196 tests pass)
- ✅ `charmap.zig` — character map support (replaces `joe/charmap.c`, 196 tests pass)
- ✅ `regex.zig` — regex engine (replaces `joe/regex.c`, 196 tests pass)
- ✅ `options.zig` — option system (replaces `joe/options.c`, 196 tests pass)
- ✅ `rc.zig` — parse .joerc (replaces `joe/rc.c`, 196 tests pass)
- Unit tests for each
- At this point: can load config, parse key bindings, but no rendering

### Phase 3: Terminal & Color (4-5 weeks) — IN PROGRESS
- ✅ `terminal/terminfo.zig` — Zig-native terminfo binding (`setupterm`/`tiget*`/`tiparm` + cached rare caps incl. `el`/`ed`/`ich`/`dch`/`cuu`/`cud`/`cuf`/`cub`/`sc`/`rc`/`ta`/`bt`/`hpa`/`vpa`/`home`/`ll` + `formatCup`/`formatCsr`/`formatIl`/`formatDl`/`formatIch`/`formatDch`/`formatCuu`/`formatCud`/`formatCuf`/`formatCub`/`formatHpa`/`formatVpa` + `tabWidth`/`destructiveTabs`/`hasHardwareTabs`; unit-tested; not wired into live joe yet)
- ✅ `terminal/tty.zig` — Zig-native raw mode + size + SIGWINCH pending/`pollResize` + `Key`/`KeyParser`/`readKey` (CSI/SS3/UTF-8/SGR-mouse/bracketed-paste/focus) + mouse/alt-screen/keypad/paste/focus enable/disable sequences (unit-tested; parallel to hybrid `src/tty.zig`)
- ✅ `terminal/pty.zig` — Zig-native `openpty`/`forkpty`/`login_tty` wrappers (unit-tested)
- ✅ `terminal/screen.zig` — Zig-native cell grid + dirty-row tracking + UTF-8 `writeText` with display-width + `Attribute`/`Color` (indexed + truecolor SGR) + alt-screen/keypad + scroll-region/IL/DL + clear-to-EOL/EOS + within-line ICH/DCH + relative cursor CUU/CUD/CUF/CUB/`moveBy` + save/restore cursor helpers + smarter `moveTo` (full JOE `cposs` matrix incl. CR+vpa/ll+hpa/ll+vpa/home+hpa/home+vpa + scroll-region-relative `rr` + tab-aware `ta`/`bt` when `use_tabs`) + cell-diff `flush` (`cells` vs `display`, changed runs + EL blank tails + within-line ICH/DCH magic + IL/DL scroll magic; `COMPOSE_MARKS` combining slots; obuf-style out buffer; unit-tested)
- ✅ `terminal/adapter.zig` — thin hybrid↔native spike: JOE packed-atr ↔ `Attribute`/`Color` (styles + indexed + truecolor palette) + obuf-style `OutSink`/`drainScreenOut`/`drainScreenOutGated`/`writeIntoObuf` + `syncHybridGridToScreen` (base + combining marks) (unit-tested)
- ✅ gated hybrid drain — `src/tty.zig` `ttWrite` + `drainZigScreen` behind `zig_screen_drain_enabled` / env `JOE_ZIG_SCREEN_DRAIN` (default off); `ported` imports `terminal` module; live screen model still C-ABI `scrn`
- ✅ gated hybrid `scrn` swap — `JOE_ZIG_SCREEN_SWAP` / `zig_screen_swap_enabled` (**default on**); paint (`outatr`/`eraeol`/scroll) updates hybrid shadow only; `edupd` calls `zig_scrn_swap_flush` → `syncHybridGridToScreen` → `Screen.flush` → `drainZigScreen`; companion Screen lifecycle in `nresize`/`nclose`; `flush_cup_only` + `cursor_valid=false` before flush (stale physical cursor after prompts); full `./runtests` soak **196/196** with swap on
- ✅ `colors.zig` — hybrid C-ABI port of jcf parser + attribute resolution (replaces `joe/colors.c`, 196 tests pass)
- ✅ `syntax.zig` — hybrid C-ABI port of jsf parser + DFA engine (replaces `joe/syntax.c`, 196 tests pass)
- ✅ `termcap.zig` — hybrid C-ABI port of termcap loader + `texec`/`tcost`/`tcompile` (replaces `joe/termcap.c`, non-TERMINFO path, 196 tests pass)
- ✅ `tty.zig` — hybrid C-ABI port replacing `joe/tty.c` (macOS POSIX termios+openpty+setitimer path: raw mode, signals, timers, mpx/pty; plus gated native `Screen.out`→`obuf` drain via `ttWrite`/`drainZigScreen`; 196 tests)
- ✅ `scrn.zig` — hybrid C-ABI port replacing `joe/scrn.c` (screen buffer, attributes, cursor/scroll, genfmt; non-TERMINFO path; 196 tests)
- Unit tests per module
- At this point: can display text with syntax highlighting

### Phase 4: Keyboard & Macros (2-3 weeks) — COMPLETE
- ✅ `kbd.zig` — hybrid C-ABI port replacing `joe/kbd.c` (KBD/KMAP/context, dokey/kadd/kcpy/kdel/ukeymap; 196 tests)
- ✅ `macro.zig` — hybrid C-ABI port replacing `joe/macro.c` (recording/playback, mparse/mtext, uarg/uif; 196 tests)
- ✅ `cmd.zig` — hybrid C-ABI port replacing `joe/cmd.c` (cmds[]/findcmd/execmd/locks/uexecmd; 196 tests)
- Unit tests
- At this point: can type, navigate, edit with keyboard

### Phase 5: Windows (3-4 weeks) — HYBRID COMPLETE
- ✅ `w.zig` — hybrid C-ABI port replacing `joe/w.c` (Screen/window tree, wfit, create/abort, messages; fixed translate-c comma-`for` in getgrouph/getminh; 196/196)
- ✅ `tw.zig` — hybrid C-ABI port replacing `joe/tw.c` (text window, status line/`stagen`, split/dup/abort; goto-free `utw1`; exported `piscol` glue; 196/196)
- ✅ `pw.zig` — hybrid C-ABI port replacing `joe/pw.c` (prompt window, history, tab completion; 196/196)
- ✅ `qw.zig` — hybrid C-ABI port replacing `joe/qw.c` (single-key query windows; 196/196)
- ✅ `menu.zig` — hybrid C-ABI port replacing `joe/menu.c` (grid menu widget; 196/196)
- ✅ `mmenu.zig` — hybrid C-ABI port replacing `joe/mmenu.c` (rc macro menus; 196/196)
- 🚧 redesign `src/window/{root,screen,tw,pw,qw,menu,paint}.zig` — Zig-native window types (Screen layout + grow/shrink/splitText/showAll/setHelpLines + `tw.stagen`/`composeStatus` + `msg_top`/`msg_bot` + off-screen families / child abort-to-fit in `layout` + `pw.History`/submit/abort/tab + `qw.breakHeight`/acceptKey/abort + QueryMode + menu grid/nav/rc-menu + `scrollUp`/`scrollDown`/`pageUp`/`pageDown` + menu/query/prompt/text watom `on_resize`/`on_move`(/`on_abort`) + `createText`/`createPrompt`/`createQuery`/`createMenu` attach typed objects + family `minHeight` (`getminh`) driving `showAll`/`showOne` + query/menu create heights from wrap/`linesFor` + tests-only paint shapes (`menudisp`/`dispqw`/`disppw`: `menu.paint`/`cursorPos`, `qw.paint`, `pw.computeLayout`/`visiblePrompt`) + `TextWindow` content geometry (`movetw`/`resizetw` status/`lincols`; `splitText` attaches object) + paint→`terminal.Screen` bridge + `Screen.term` attach/`paintAll`/`Screen.update` edupd-shaped pass + text-body via Phase 6 `render.lgenLine`/`lgenPoint` + per-byte `attr_buf` (`body_lines` or live `GapBuffer`/`line_attrs`/`top_line`/`offset` display-col/`tab`/`cursor_*`/`linums` + `paintBody`/`paintLinum`/`contentCursor`) + help/`wind` chrome (`help_text`/`helpOn`/`helpOff`/`countHelpLines` + `paintHelp`/`paintHelpLine` `\|` springs in `paintAll`) + shared `window/fmt.zig` genfmt attr escapes; `zig build window-test` **92/92**; hybrid ports remain live)
- ✅ `mmenu.zig` — hybrid rc menus (`joe/mmenu.c`; 196/196)
- At this point: multi-window editing works

### Phase 6: Rendering (4-6 weeks) — IN PROGRESS
- 🚧 `src/render/{root,lgen,gap,attr,syntax,view,table,lattr}.zig` — `lgen*` + `GapBuffer`/`Point` + per-byte `attr_buf` apply + Zig-native JSF subset DFA (`load`/`loadWithLibrary`/`parseLine`/`stateAfterLines`; `conf.jsf` + keywords/`buffer`/`hold`/`strings`/`"&"` + local/external `call=`/`return` + `.ifdef` params + `reset` + mark/recolormark + `\i`/`\c` + delimiter `save_*`/`push_*`/`pop_*`/`%`/`&`) + Zig-native `lgen_view` Feature 1.x (`ViewTables` hide/substitute/link_url/col_map; headings/fences/HR/blockquote/task/emphasis/links; `Options.view` + `paintBody`/`TextWindow.viewmode` via stack `bindScratch`) + Feature 2.1/2.2 table box-drawing (`table.zig` region detect, col widths/align, padded `│`/`├─┼─┤` paint; `paintBody` prefers table rows) + OSC 8 hyperlink emit (`Cell.url` + `Screen.internUrl`/`writeCharLink`; flush emits `ESC]8;;urlST`) + lattr-style `LineAttrCache` (`first_invalid`/`invalid_window`; `TextWindow.lattr` + incremental `paintBody`); `TextWindow.buffer`/`syntax`/`line_attrs`/`viewmode`/`lattr` + `paintBody` auto-fill; `zig build render-test` **67/67**; `window-test` **92/92**; Path A gated live bridge landed (below)
- ✅ `lgen` syntax `attr_buf` consumption (native Attribute rows; hybrid packed-int conversion via `fromHybridRow`)
- ✅ Live JSF subset DFA → `attr_buf` fill (native `render/syntax.zig`; hybrid `syntax.parse` bridge still optional)
- ✅ JSF deepen: keywords/`buffer`/`strings` + local `.subr` `call=`/`return` + `reset` + `\i`/`\c` + `mark`/`markend`/`recolormark`
- ✅ JSF deepen: delimiter match buffer+stack (`save_c`/`save_s`/`push_c`/`push_s`/`pop_c`/`pop_s`), bare `%`/`&`, strings `"&"`
- ✅ JSF deepen: external-file `call=file.subr()` / `call=file()` via in-memory `SyntaxLibrary` (`loadWithLibrary`)
- ✅ JSF deepen: `.ifdef` / `.else` / `.endif` with `call=…(params)` / `-param` (per-param-set cache instances)
- ✅ JSF `hold` (`stop_buffering`) + `ofst`-aware keyword recolor
- ✅ Zig-native lattr-style `LineAttrCache` + `TextWindow.lattr` / `paintBody` integration
- ✅ `lgen_view` Feature 1.x (headings/fences/HR/blockquote/task/emphasis/inline code/links + hide/substitute/link_url/col_map; `paintBody` wired; unit-tested)
- ✅ `lgen_view` Feature 2.1/2.2 table box-drawing (`table.zig`: region detect, widths/align, padded borders; `paintBody` wired; unit-tested)
- ✅ OSC 8 hyperlink emit (`Cell.url` / `Screen.writeCharLink` + flush `ESC]8;;urlST`; viewmode `link_url` → lgen; unit-tested)
- ✅ Screen buffer diff + dirty-cell-only flush — redesign `Screen.flush` cell-diff + EL + within-line ICH/DCH magic + IL/DL scroll magic + combining slots + gated hybrid `scrn` swap landed (**default on**)
- ✅ Path A gated live bridge: `src/bw_lgen.zig` (always on; `JOE_ZIG_BW_LGEN` gate removed) — `lgen_core` body paint (UTF-8 + non-UTF-8 `byte_mode`) via hybrid `syntax.parse` → per-byte `attr_buf` expand → `render.lgenLine` → hybrid `outatr`; linear mark inverse (`from`/`to` byte range); square mark inverse (display-column `xcol`; byte-mode safe); viewmode hide/substitute/link tables (+ OSC 8 via `ttputs`); `-visiblews` via C `vspace`/`vtab`/`vrtn` + `vwsatr` merge; `-ansi` ESC hide via `stripAnsiEscapes` (aligned with `ansi_parse` attrs); Feature 2.2 padded table rows via `zig_bw_table_row` → `render.table.paintRow` (widths/aligns from Path A `zig_bw_table_detect`/`layoutAt` when gated, else C; `fillTableColMap` for cursor xcol; C `render_padded_table_row` fallback); table region detect via `zig_bw_table_detect` → `table.layoutAt` (C scan fallback retained); Feature 2.1 residual simple pipe substitute via `zig_bw_table_simple` → `table.applySimpleBorders` (separator-only; C fallback retained; UTF-8 viewmode); line-number gutters via `zig_bw_gennum` (JOE `" %21lld "` trailing `lincols`; past-EOF blanks; C `gennum` fallback); thin `zig_bw_bwgen` paint loops + `zig_bw_bwgen_entry` (lattr/viewmode/mark setup + loops + Feature 1.10 cursor; loops call C `getto`/`lgen`/`gennum`); hex dump via `zig_bw_bwgenh` + `zig_bw_bwgenh_entry` (mark setup + paint; loop calls C `genfield`/`pgetb`); cursor follow via `zig_bw_bwfllwt`/`zig_bw_bwfllwh` (text+hex; C `nscrldn`/`nscrlup`/`msetI` helpers; C fallback retained); post-edit scroll via `zig_bw_bwins`/`zig_bw_bwdel` (C fallback retained); `lgen_view` Feature 1.x via `zig_bw_view_line_start` / `zig_bw_view_inline` / `zig_bw_view_table_hl` / `zig_bw_view_finish` + thin `zig_bw_lgen_view` dispatcher + `zig_bw_lgen_view_entry` + Zig-owned `zig_bw_vm_*` statics; C Feature chrome deleted; `lgen_view`/`bwgen`/`bwgenh` are thin Zig-entry wrappers that abort on `-1`
- ✅ Path A soak: `./runtests` **196/196** (always-on; env gate removed); critical EOF semantics — do **not** `p_goto_bol` before paint (past-EOF `getto` leaves `p` at EOF so C paints blank; bol rewind broke `test_bos_short` / `test_isearch_resume`); advance with `pnextl` only after successful paint
- ✅ Path A linear marks: byte-range `SELECT_IF` inverse via `applyLinearMarkInverse` (square still C)
- ✅ Path A viewmode tables: reuse C `lgen_view` hide/substitute/link_url; skip re-parse; OSC 8 emit around `outatr`
- ✅ Path A visiblews: `VisibleWs` + `mergeVisibleWsAttr` in `render/lgen.zig`; bridge appends trailing `\n` only when enabled (EOF-without-NL omits `vrtn`); C gate dropped
- ✅ Path A square marks: `applySquareMarkInverse` (tab end-col `(from,to]`, char start-col `[from,to)`); `bwgen` still scopes by line; C gate dropped
- ✅ Path A ansi: `stripAnsiEscapes` removes ESC…letter spans after attr/linear-mark apply; square marks use post-strip columns; C gate dropped
- ✅ Path A Feature 2.2 padded table rows: gated `zig_bw_table_row` with widths/aligns from detect + `viewmode_col_map` fill; C fallback retained
- ✅ Path A table region detect: gated `zig_bw_table_detect` → `table.layoutAt` (fills C widths/aligns/region bounds; `max_scan_lines` 200; C scan + negative-cache fallback retained)
- ✅ Path A cursor follow: always-on `zig_bw_bwfllwt` / `zig_bw_bwfllwh` (vertical recenter/`opt_mid`, horizontal `opt_left`/`opt_right`, hiline dirty; C scroll helpers via Zig; C fallback bodies deleted — abort on `-1`)
- ✅ Path A post-edit scroll: always-on `zig_bw_bwins` / `zig_bw_bwdel` (highlight dirty + `nscrldn`/`nscrlup`/`sary`; C fallback bodies deleted — abort on `-1`)
- ✅ Path A `lgen_view` inline: gated `zig_bw_view_inline` → `analyzeLineInline` (emphasis / inline code / links+OSC attrs / col_map; preserves C task/table hide/subst; C fallback retained)
- ✅ Path A `lgen_view` line-start: gated `zig_bw_view_line_start` → `analyzeLineStart` (heading/fence/blockquote/HR/task; `1` ⇒ done, `0` ⇒ continue tables/inline; C fallback retained)
- ✅ Path A Feature 1.9: gated `zig_bw_view_table_hl` (dim/bold for pipe lines outside table region; C fallback retained)
- ✅ Path A `gennum`: always-on `zig_bw_gennum` mirrors C `" %21lld "` trailing `lincols` via hybrid `outatr`; C fallback body deleted — abort on `-1`
- ✅ Path A thin `bwgen`: gated `zig_bw_bwgen` owns the two screen-row paint loops; C keeps mark/errbuf/lattr/viewmode-invalidate + Feature 1.10 cursor `xcol`; loops call C `zig_c_bw_{getto,lgen,gennum,get_highlight_state}`
- ✅ Path A thin `bwgen` entry: gated `zig_bw_bwgen_entry` owns lattr/viewmode/mark setup + paint loops + Feature 1.10 cursor; C helpers (`zig_c_bw_bwgen_setup` / screen field getters) + full `bwgen` fallback retained
- ✅ Path A thin `bwgenh`: gated `zig_bw_bwgenh` owns hex dump rows; C keeps mark setup; loop calls C `genfield` + `zig_c_bw_pbyte`/`pgetb`
- ✅ Path A thin `bwgenh` entry: gated `zig_bw_bwgenh_entry` owns mark setup + hex paint; C helpers (`zig_c_bw_bwgenh_setup` / bg getters) + full `bwgenh` fallback retained
- ✅ Path A Feature 2.1 residual: gated `zig_bw_table_simple` (separator-only `applySimpleBorders`; header/body/last no-op; C fallback retained)
- ✅ Path A non-UTF-8 body: `Options.byte_mode` / `SliceIter.byte_mode`; C `lgen_core` UTF-8-only gate dropped; square marks honor byte-mode
- ✅ Path A `bwgenh`: gated `zig_bw_bwgenh` owns hex dump row formatting + `genfield` emit; C keeps mark setup + `dosquare` zeroing; C fallback retained
- ✅ Path A `bwgenh` entry: gated `zig_bw_bwgenh_entry` (mark setup + paint; C fallback retained)
- ✅ Path A Feature 1.10: gated `zig_bw_view_finish` (col_map ensure + cursor xcol; shared `done`/`table_rendered` epilogue; C fallback retained)
- ✅ Path A thin `lgen_view` dispatcher: gated `zig_bw_lgen_view` composes line-start → table detect/row/simple → table_hl → inline → finish; C keeps parse/line buffer/side-table alloc + `paint_and_cleanup` (`lgen_core`/`pnextl` + map clear); piecemeal Path A + C chrome retained as fallback
- ✅ Path A thin `lgen_view` entry: gated `zig_bw_lgen_view_entry` owns prelude (len-cap/`parse`/line buffer) + dispatcher + paint cleanup; under the gate paints via Zig-owned `zig_bw_vm_*` tables (`paintViewBodyWithVm` → `zig_bw_lgen`); C keeps Feature fallback body + `zig_c_bw_view_col_map*` when gate off / Path A returns `-1`; `defatr` computed in Zig
- ✅ Path A Zig-owned viewmode statics: gated `zig_bw_vm_{prepare,hide,subst,urls,col_map,*,after,display_col,cleanup}` in `src/bw_lgen.zig`; C wires `viewmode_display_col` / `viewmode_cleanup` / Feature 1.10 `bwgen` cursor + `zig_c_bw_get_{visiblews,ansi}`; C Feature statics retained as fallback
- ✅ Path A C Feature chrome shrink: removed piecemeal C→Zig bridges inside `lgen_view` (`zig_bw_lgen_view` / `zig_bw_view_*` / `zig_bw_table_{detect,row,simple}`); gated path is entry-only; pure-C Feature body remains for gate-off / `-1`
- ✅ Path A dead `zig_c_bw_view_*` wrapper shrink: removed unused `paint_body`/`prepare`/`hide`/`subst`/`urls`/table-ptr/`after` bridges from `joe/bw.c` + matching Zig externs
- ✅ Path A `defatr` in Zig: `viewDefatr` uses `zig_c_bw_get_hiline`/`pline_no` + `bg_text`/`bg_curlin`/`curlinmask`; deleted `zig_c_bw_view_defatr`
- ✅ Path A bg attr getters in Zig: `bwgenh_entry` reads `bg_text`/`bg_linum`/`bg_curlinum`/`bg_cursor` directly (`BG_COLOR` identity); deleted `zig_c_bw_bg_*`
- ✅ Path A always-on: removed `JOE_ZIG_BW_LGEN` / `zig_bw_lgen_enabled` / `zig_bw_lgen_apply_env`; C call sites always try Zig first
- ✅ Path A C Feature retirement: deleted ~1100-line `lgen_view` Feature body + `render_padded_table_row` + parallel table/col_map statics; `lgen_view`/`bwgen`/`bwgenh` are thin Zig-entry wrappers (`abort` on `-1`); deleted `zig_c_bw_view_col_map*`
- ✅ Path A lifecycle: always-on `zig_bw_bwmove` / `zig_bw_bwresz` / `zig_bw_bwmk` / `zig_bw_bwrm` / `zig_bw_orphit` / `zig_bw_calclincols` (C helpers for field/VT/kbd/file-pos; C fallback bodies deleted — abort on `-1`)
- ✅ Path A non-paint helpers: always-on `zig_bw_get_file_pos` / `zig_bw_set_file_pos` / `zig_bw_save_file_pos` / `zig_bw_load_file_pos` / `zig_bw_set_file_pos_all` / `zig_bw_vtmaster` / `zig_bw_ustat` / `zig_bw_ucrawlr` / `zig_bw_ucrawll` / `zig_bw_init_visiblews` (C keeps file_pos list + window-walk/VT/status helpers called from Zig; C public fallback bodies deleted — abort on `-1`)
- ✅ Path A follow/scroll/lifecycle/helper retirement: deleted C safety-net bodies for `bwfllwt`/`bwfllwh`/`bwins`/`bwdel`/`bwmove`/`bwresz`/`bwmk`/`bwrm`/`orphit`/`calclincols`/`file_pos*`/`vtmaster`/`ustat`/`ucrawl*`/`init_visiblews`; thin wrappers abort on Zig `-1`; soak **196/196**; `joe/bw.c` ~1772 lines
- ✅ Path A `lgen_core`/`gennum` retirement: deleted C body-paint + ansi/OSC8 debug helpers + viewmode stubs + `gennum` C body + dead `zig_c_bw_lgen_core`; pathological view lines paint raw via Zig; soak **196/196**; `joe/bw.c` ~1128 lines
- ✅ Path A body + gutter + thin `bwgen`/`bwgenh` + `bwgen` entry + table detect + follow + post-edit scroll + full `lgen_view` Feature 1.x + thin `lgen_view` dispatcher/entry + Zig-owned viewmode statics (`zig_bw_vm_*`) + C Feature chrome + follow/scroll/lifecycle/helper + `lgen_core`/`gennum` safety nets retired (UTF-8 + byte charmaps / marks / viewmode tables / visiblews / square / ansi / Feature 2.1 residual / Feature 2.2 / `gennum` / paint loops / hex / region detect / `bwfllw*` / `bwins`/`bwdel` / Feature 1.3–1.10 / `bwmk`/`bwmove`/`bwresz`/`bwrm`/`orphit`/`calclincols` / `file_pos*` / `ustat` / `ucrawl*` / `vtmaster` / `init_visiblews` / `bwgen` setup entry); still C: mark-setup/`file_pos` list helpers + Zig bridge helpers in `joe/bw.c` (thin `lgen`/`lgen_core`/`gennum`/`bwgen*` wrappers abort on Zig `-1`; `defatr` in Zig)
- At this point: fully functional editor with markdown viewmode

### Phase 7: File I/O & Commands (3-4 weeks) — NOT STARTED
- ⬜ `fileio.zig` — load, save, UTF-16 conversion
- ⬜ `edit.zig` — all edit commands (uedit, ublock, uformat)
- ⬜ `search.zig` — search/replace
- ⬜ Shell window, tags, math, error navigation
- At this point: feature-complete in Zig

### Phase 8: Polish & Compatibility (2-3 weeks) — NOT STARTED
- ⬜ SELinux support (Linux: getfilecon integration)
- ⬜ GPM mouse support (Linux console)
- ⬜ i18n / .mo file parsing
- ⬜ Unicode 16.0 table generation tool
- ⬜ Verify: all .joerc files from C version work identically
- ⬜ Verify: all .jsf/.jcf files resolve identically
- ⬜ Performance benchmarks vs C version

**Total: ~24-36 weeks (5-9 months)**

---

## 8. Testing Strategy

```
zig build                 → builds joe binary
zig build test            → runs all module tests
```

**Per-module tests** (in each `.zig` file):
```zig
test "gapbuffer insert/delete" {
    var buf = try B.init(testing.allocator);
    defer buf.deinit();
    try buf.insert(0, "hello");
    try testing.expectEqual(@as(u64, 5), buf.len());
    try buf.delete(0, 5);
    try testing.expectEqual(@as(u64, 0), buf.len());
}
```

**Integration tests** (existing Python harness, adapted):
- Run `tests/tests.py` against the Zig binary once it's far enough along

**Compatibility tests:**
- Load the same rc/jsf/jcf files the C version uses → same parse results
- Edit a known file in both versions → same undo/redo behavior
- Benchmark throughput (keys/sec) — target parity with C

---

## 9. Risks and Mitigations

| Risk | Mitigation |
|---|---|
| **Performance regression** | Zig compiles to native code via LLVM; benchmarks after each phase. Hot paths (lgen, syntax, gap buffer) are identical algorithms. |
| **Unicode table correctness** | Generate `unicat.bin` from the *same* `UnicodeData.txt` source, verify check hash. |
| **Feature gap** | Parallel testing: C version and Zig version side-by-side. Run the same key sequences, compare output. |
| **Terminal compatibility** | Keep C's `obuf` emission approach for Phase 0-5, switch to cell-diff approach in Phase 6. Diff method sends *fewer* bytes to the terminal so it's strictly better. |
| **.jsf/.jcf parser divergence** | Write a JSF test that loads every syntax file and renders known text — compare attribute arrays between C and Zig. |
| **Recipe for failure** | Massive monolithic port. Mitigation: every phase ends with a working binary. Phase 1+2 have no terminal dependency — test by printing buffer stats. |

---

## 10. What Gets Removed vs Preserved

### Removed (replaced by Zig stdlib):
- `joe/queue.h` → `std.TailQueue`, `std.SinglyLinkedList`
- `joe/hash.c` → `std.HashMap`
- `joe/path.c` → `std.fs.path`
- `joe/va.c`, `joe/vs.c` → `std.ArrayList`
- `joe/builtin.c` → `@embedFile`
- `joe/util/stringify.c` → `@embedFile` at comptime
- `joe/EngNotation.c` → `std.fmt` (or small inline impl)
- `joe/gettext.c` → `std.i18n`
- `joe/utils.c` → `std.mem`, `std.unicode`
- autoconf/automake → `build.zig`

### Preserved (algorithmic source ports):
- `joe/b.c` (gap buffer algorithm — identical)
- `joe/bw.c` (rendering pipeline — same cell-by-cell model)
- `joe/scrn.c` (escape sequence emission — same ANSI/OSC 8)
- `joe/tty.c` (signal handling, raw mode, Pty management)
- `joe/syntax.c` (DFA interpreter — same state machine)
- `joe/colors.c` (jcf parser, color resolution — identical logic)
- `joe/options.c` (option definitions, matching — ported with comptime)
- `joe/kbd.c` (radix tree key lookup — ported)
- `joe/macro.c` (recording/playback semantics — same)
- `joe/regex.c` (NFA/DFA engine — ported)
- `joe/undo.c` (undo tree — same record structure)
- `joe/w.c` (window tiling — same families, fit algorithm)
- `joe/menu.c` (grid menu — same layout)
- `joe/lattr.c` (line cache — same gap buffer + re-sync pattern)

### Enhanced (Zig brings improvements):
- Attribute packing: manual bitfields → `packed struct(u32)` with named fields
- Allocator: implicit `malloc` → explicit parameter with arena choice
- Error handling: global `berror` → `!` error propagation
- Pointers: `void*` casts → typed pointers
- String handling: `char*` + length → `[]const u8`
- Embedded data: `stringify` tool → `@embedFile`
- Screen buffer: raw escape sequence buffer → cell-diff dirty-region flush
