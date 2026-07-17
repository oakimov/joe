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
- 🚧 Phase 3 redesign deepen: Zig-native `src/terminal/{terminfo,tty,pty,screen,adapter}.zig` unit-tested (`zig build terminal-test` **45/45**); UTF-8 `writeText` + display-width, `Key`/`KeyParser`/`readKey` CSI+SS3+SGR-mouse+bracketed-paste+focus, mouse/alt-screen/keypad/paste/focus enter-leave, truecolor/`Color` SGR, SIGWINCH pending/`pollResize`, terminfo rare-cap cache + `formatCup`/`formatCsr`/`formatIl`/`formatDl`/`formatIch`/`formatDch`/`formatCuu`/`formatCud`/`formatCuf`/`formatCub` + scroll-region/IL/DL + clear-to-EOL/EOS (`el`/`ed`) + within-line ICH/DCH (`ich`/`dch`) + relative cursor CUU/CUD/CUF/CUB + save/restore (`sc`/`rc`) + thin hybrid↔native adapter (`attributeFromHybrid`/`attributeToHybrid` + obuf-style `OutSink`/`drainScreenOut`); not yet replacing hybrid tty/termcap/scrn in the live binary
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

#### `window/pw.zig` — Prompt Window
- Replaces `pw.c` (~532 lines).
- History, tab completion, callback on Enter.

#### `window/qw.zig` — Query Window
- Replaces `qw.c` (~290 lines).
- Key-capture callbacks for one-character queries.

#### `menu.zig` — Menu System
- Replaces `menu.c` (~720 lines) + `mmenu.c` (~174 lines).
- Generic grid menu + macro-defined menus from rc file.
- Same rendering (INVERSE highlight, column-major layout), same key dispatch.

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
- ✅ `terminal/terminfo.zig` — Zig-native terminfo binding (`setupterm`/`tiget*`/`tiparm` + cached rare caps incl. `el`/`ed`/`ich`/`dch`/`cuu`/`cud`/`cuf`/`cub`/`sc`/`rc` + `formatCup`/`formatCsr`/`formatIl`/`formatDl`/`formatIch`/`formatDch`/`formatCuu`/`formatCud`/`formatCuf`/`formatCub`; unit-tested; not wired into live joe yet)
- ✅ `terminal/tty.zig` — Zig-native raw mode + size + SIGWINCH pending/`pollResize` + `Key`/`KeyParser`/`readKey` (CSI/SS3/UTF-8/SGR-mouse/bracketed-paste/focus) + mouse/alt-screen/keypad/paste/focus enable/disable sequences (unit-tested; parallel to hybrid `src/tty.zig`)
- ✅ `terminal/pty.zig` — Zig-native `openpty`/`forkpty`/`login_tty` wrappers (unit-tested)
- ✅ `terminal/screen.zig` — Zig-native cell grid + dirty-row flush via ANSI/terminfo-cup + UTF-8 `writeText` with display-width + `Attribute`/`Color` (indexed + truecolor SGR) + alt-screen/keypad + scroll-region/IL/DL + clear-to-EOL/EOS + within-line ICH/DCH + relative cursor CUU/CUD/CUF/CUB/`moveBy` + save/restore cursor helpers (obuf-style out buffer; cell-diff deferred to Phase 6; unit-tested)
- ✅ `terminal/adapter.zig` — thin hybrid↔native spike: JOE packed-atr ↔ `Attribute`/`Color` (styles + indexed + truecolor palette) + obuf-style `OutSink`/`drainScreenOut` (unit-tested; not wired into live joe)
- ✅ `colors.zig` — hybrid C-ABI port of jcf parser + attribute resolution (replaces `joe/colors.c`, 196 tests pass)
- ✅ `syntax.zig` — hybrid C-ABI port of jsf parser + DFA engine (replaces `joe/syntax.c`, 196 tests pass)
- ✅ `termcap.zig` — hybrid C-ABI port of termcap loader + `texec`/`tcost`/`tcompile` (replaces `joe/termcap.c`, non-TERMINFO path, 196 tests pass)
- ✅ `tty.zig` — hybrid C-ABI port replacing `joe/tty.c` (macOS POSIX termios+openpty+setitimer path: raw mode, signals, timers, mpx/pty; 196 tests)
- ✅ `scrn.zig` — hybrid C-ABI port replacing `joe/scrn.c` (screen buffer, attributes, cursor/scroll, genfmt; non-TERMINFO path; 196 tests)
- Unit tests per module
- At this point: can display text with syntax highlighting

### Phase 4: Keyboard & Macros (2-3 weeks) — COMPLETE
- ✅ `kbd.zig` — hybrid C-ABI port replacing `joe/kbd.c` (KBD/KMAP/context, dokey/kadd/kcpy/kdel/ukeymap; 196 tests)
- ✅ `macro.zig` — hybrid C-ABI port replacing `joe/macro.c` (recording/playback, mparse/mtext, uarg/uif; 196 tests)
- ✅ `cmd.zig` — hybrid C-ABI port replacing `joe/cmd.c` (cmds[]/findcmd/execmd/locks/uexecmd; 196 tests)
- Unit tests
- At this point: can type, navigate, edit with keyboard

### Phase 5: Windows (3-4 weeks) — NOT STARTED
- ⬜ `screen.zig` — Screen + window tree + wfit algorithm
- ⬜ `window/tw.zig` — text window + status line
- ⬜ `window/pw.zig` — prompt window
- ⬜ `window/qw.zig` — query window
- ⬜ `menu.zig` — menu widget + rc menus
- At this point: multi-window editing works

### Phase 6: Rendering (4-6 weeks) — NOT STARTED
- ⬜ `render.zig` — lgen_core + lgen_view (full markdown viewmode)
- ⬜ Screen buffer diff + dirty-cell-only flush
- ⬜ Viewmode: table borders, link URLs, delimiter hiding, cursor mapping
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