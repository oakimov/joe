# JOE Editor — Agent Guide (Zig rewrite)

## Project Overview

JOE (Joe's Own Editor) is a terminal text editor. This fork’s **live editor** on
branch **`zig-rewrite`** is a **Zig Path A** port: all former `joe/*.c` editor
sources are Zig under `src/`, exporting the historical JOE C ABI so behavior and
the Python soak suite stay intact.

**Repository:** https://github.com/oakimov/joe (fork of joe-editor/joe)  
**Architecture plan:** `plans/zig-rewrite-architecture.md`  
**Install (Zig):** see top of `INSTALL.md`

### Branches

| Branch | Role |
|---|---|
| `zig-rewrite` | Zig Path A port — the live editor baseline |
| **`markdown`** | **Markdown rich viewmode work happens here.** Synced with `zig-rewrite`; the markdown plan lives on this branch |

`markdown` was the original (C-era) viewmode branch, later fast-forwarded onto
`zig-rewrite`. Rebase or merge it forward from `zig-rewrite` rather than the
other way round.

A markdown viewmode is **landed** in the live Zig paint path
(`src/bw_lgen.zig` + `src/render/`): zero-width conceal (Phase 1), link/image/
entity/list-marker conceal coverage (Phase 2), the native `cursor-dark` color
scheme (Phase 3), a flanking-delimiter-rule fix for emphasis (Phase 4),
click-to-open links via OSC 8 and the mouse (Phase 5), and autolink styling,
table header/border colors, and setext headings (`Text\n===`/`Text\n---`)
(Phase 6). User-facing
docs: `docs/man.md` "Markdown viewmode" section (deviations from OpenCode,
known limitations). Plan/status: `plans/markdown-wysiwyg-feasibility.md` +
`plans/TODO.md` (OpenCode-style rich viewmode; self-contained Zig — no
vendored markdown libs).

## Current state (read this first)

| Fact | Detail |
|---|---|
| Live JOE C sources | **None.** No `joe/*.c` on disk for the editor; none linked in `build.zig` |
| Editor implementation | Zig under `src/`, wired via `src/ported.zig` |
| Headers | `joe/*.h` remain the **C declaration / layout surface** |
| Default link deps | **libc** + **ncurses** (terminfo). Optional Linux: `-Dselinux`, `-Dgpm` |
| Phases 7–8 | **DONE** (Path A zero-C + polish/verify tools) |
| Style | Path A = C-ABI Zig (`export fn`, `[*c]`, `extern struct`). Idiomatic Path B trees in `src/terminal`, `src/window`, `src/render` are parallel / partially gated — not a full replacement of Path A yet |
| Platforms | **macOS + Linux**. Windows native: **not supported** (POSIX TTY/PTY) |

Offline C tools only (not linked into `joe`): `joe/util/{uniproc,stringify,termidx,checkwidths}.c`.

## How to start working (Zig)

### Build

```sh
zig build                          # Debug → zig-out/bin/joe (+ data under zig-out/)
zig build -Doptimize=ReleaseFast
./zig-out/bin/joe -help
```

Copy into the path the soak suite expects:

```sh
cp -f zig-out/bin/joe joe/joe
```

Release install (bin + etc/joe + share/joe + man/doc/desktop):

```sh
# User-writable prefix (no sudo), e.g. MacPorts tree you own:
zig build -Doptimize=ReleaseFast --prefix /opt/local

# System prefix — sudo so install can write under bin/etc/share:
sudo zig build -Doptimize=ReleaseFast --prefix /usr/local
```

`JOERC`/`JOEDATA` default to `PREFIX/etc/joe/` and `PREFIX/share/joe/`. Override with
`-Djoerc=` / `-Djoedata=` (empty forces builtins + `~/.joe` / XDG). Also: `-Dspell=`,
`-Dselinux=true`, `-Dgpm=true` (Linux). Steps: `zig build run`, `terminal-test`,
`render-test`, `window-test`, `phase8-verify`, `uninstall` (use `sudo` with the same
`--prefix` when the install needed root).

### Soak gate (mandatory before claiming done)

```sh
cp -f zig-out/bin/joe joe/joe
./runtests
# Expect: Ran 222 tests ... OK
```

Do **not** use `pytest`. Root `./runtests` (or `cd tests && python3 -m unittest …` per project habit) only.

Notes:

- Paint is hybrid-only (incremental `scrn`/`ttputs`). The experimental Zig screen-swap gate was removed.
- One flake has been seen on a viewmode table exit; re-run once before chasing ghosts.
- Help coverage was historically missing (`# TODO: help` in `tests/commands.py`); a translate-c `continue` bug garbled `^K H` until fixed — prefer adding a screen assertion if you touch help again.

### Where code lives

| Area | Path |
|---|---|
| Live Path A modules | `src/*.zig` (e.g. `main.zig`, `help.zig`, `ufile.zig`, `bw_lgen.zig`) |
| Module import root | `src/ported.zig` |
| Build | `build.zig` |
| Native terminal redesign | `src/terminal/` |
| Native window redesign | `src/window/` |
| Native render redesign | `src/render/` |
| Builtins embed | `src/builtins_data.zig` + `src/builtin.zig` |
| Unicode tables | `src/unicat.zig` (+ `tools/gen_unicat.py`, `src/data/unicat_meta.zig`) |
| Headers / layouts | `joe/*.h` |
| Config / syntax / colors | `rc/`, `syntax/`, `colors/`, `po/` (installed as `lang/*.po`) |
| Phase 8 tools | `tools/phase8_verify.sh`, `verify_rc.py`, `verify_syntax_colors.py`, `bench_joe.py` |

`src/ported.zig` pulls every live module so exports land in the binary. After adding a new top-level module, import it there and keep layouts matching `joe/*.h` (verify with `offsetof` / clang when unsure).

## Architecture (Path A)

```
zig build
  → exe (link libc + ncurses)
  → object from src/ported.zig
       → all Path A modules export JOE ABI
  → install bin/{joe,jmacs,jstar,rjoe,jpico} + etc/joe + share/joe/{syntax,colors,charmaps,lang} + man/doc/desktop
```

**Paint / viewmode (live):** `src/bw_lgen.zig` owns buffer-window paint, Markdown
viewmode, tables, OSC 8, etc., using `src/render/` pieces. Screen emission is
hybrid Path A (`src/scrn.zig` / `src/tty.zig`).

**Entry / loop:** `src/main.zig` (`main`, `edloop`, `edupd`, …).

**Help:** `src/help.zig` — help text uses `\b`/`\u`/`\|` escapes; do not wrap
for-loop `switch` in `while (true)` such that Zig `continue` restarts the while
(eats the next glyph).

### Path A vs Path B

- **Path A (live):** faithful C-ABI port; goal was zero live `joe/*.c` + soak green.
- **Path B (parallel):** idiomatic Zig (`std.posix`, slices, native screen/window).
  Unit-tested; only partially wired into the live binary. Do not rip out Path A
  without an explicit soak plan.

## Working rules for agents

1. **Assume Zig is the product.** Do not revive Automake for the live binary.
2. **Preserve quirks** when changing Path A (off-by-ones, global state, help escapes).
3. **Layouts matter.** Mismatched `extern struct` vs `joe/*.h` → silent corruption.
4. **Darwin `struct_stat`:** must match the real OS size/offsets if used with `fstat`
   (undersized fakes smash stacks — see Path A `ufile` history).
5. **translate-c footguns:** `sc("...")` lengths, `while(true)+continue`, fake libc
   types, `return undefined`. Prefer hand-fixing control flow after translate-c.
6. **Always soak** (`./runtests` → 222/222) before “done.”
7. **Commits:** focused messages; update `plans/zig-rewrite-architecture.md` when
   finishing a phase-sized chunk.
8. **Parallelism:** independent modules/tests can use subagents; keep one soak gate
   on the integrated binary.

## Post-change review checklist

- Soak **222/222** (and relevant `zig build *-test` if you touched those trees)
- No new unbounded `[*c]` writes; check help/status/paint paths manually if UI chrome
- SELinux/GPM remain no-ops unless Linux + `-D` flags
- Do not reintroduce linked `joe/*.c`
- Avoid relying on MacPorts-only paths when changing `build.zig` (note `/opt/local`
  is currently hardcoded for ncurses on this machine)

## Markdown / rendering (already in tree)

Viewmode conceals markdown delimiters at zero width, paints emphasis/headings/tables,
autolinks, OSC 8 links (click-to-open via the mouse too), Unicode table borders — implemented
on the Zig paint path, not by editing deleted `joe/bw.c`. Syntax still driven by
`syntax/md.jsf` + the native `cursor-dark` color scheme under `colors/` (the nine legacy
schemes were removed; `-colors default` still resolves via an embedded builtin fallback).
`src/render/md_event.zig` holds the CommonMark flanking-rule classifier and link-safety/
reference-resolution helpers, kept there specifically so they're covered by `zig build
render-test` (`src/bw_lgen.zig` itself isn't part of that target). Setext headings
(`Text\n===`/`Text\n---`) get heading styling too (`docs/man.md` "Markdown viewmode" has
the full user-facing list of remaining known limitations).

## Classic Autoconf (reference only)

Historical C build (`./configure && make install`) is documented **below** the Zig
section in `INSTALL.md`. The `zig-rewrite` editor binary is **not** produced that
way. CI may still mention Autoconf for other branches.

## Key constraints

- Mouse: **default on** via xterm/SGR (`-mouse`); `-nomouse` to disable; `-mouseclip` on by default (OSC 52 copy-on-select; selection stays; right-click pastes); `-mousewheel N` (vertical = up/down arrow, horizontal = left/right arrow). GPM remains Linux-only (`-Dgpm`).
- Live binary deps: **libc + ncurses** (+ optional Linux selinux/gpm)
- Terminal degradation: truecolor → 256 → 16 → attributes
- Viewmode must not modify buffer text
- Preserve edit-mode behavior when viewmode is off
- Prefer soak parity over premature “idiomatic” rewrites

## External references

- Architecture: `plans/zig-rewrite-architecture.md`
- Install: `INSTALL.md` (Zig section first)
- Manual: `docs/man.md`
- OSC 8: https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
- CommonMark / GFM for markdown DFA behavior
