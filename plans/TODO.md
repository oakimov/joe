# Markdown rich viewmode — Task List

> **Branch:** work on **`markdown`** (synced from `zig-rewrite`).
> **Source:** `plans/markdown-wysiwyg-feasibility.md` (Zig Path A)
> **Status:** Phase 1–2 baseline **shipped**. Active work = Phases 1–7 below (Phase 0 done).
> **Constraint:** Self-contained Zig — borrow ideas from koino/MD4C/OpenCode; **no** vendored markdown libs.
> **References:** conceal + layout from OpenCode (`~/Projects/opencode-research`, plan §2);
> **all colours from Cursor Dark** (`cursor-official-themes-0.0.5.vsix`, plan §6.2).
> **Deferred:** nested fence HL + images → `plans/future-roadmap.md` (2.5 / 2.6)

---

## Read first

Three facts that change how you implement this. Full detail in the plan.

1. **`hide` currently paints a space, not zero width** (`src/render/view.zig:568`). Conceal must
   *collapse*. Plan §4.
2. **JOE conceals link destinations — a deliberate deviation from OpenCode.** `[a](u)` → `a`.
   OpenCode renders `a (u)`; we don't. Autolinks and bare URLs stay visible (no label to fall
   back on). `^T A` to edit mode shows the source. Plan §3.2.
3. **62 of 125 `tests/viewmode.py` tests encode the space-padded layout** and must be rewritten in
   the Phase 1 commit. Link tests change again in Phase 2. Plan §4.3.

---

## Completed baseline (archive)

Shipped on the Zig paint path (`src/bw_lgen.zig`, `src/render/{view,table,lgen}.zig`,
`syntax/md.jsf`, `colors/*.jcf`, `^T A` viewmode). Do not re-implement.

| Area | Done |
|---|---|
| Viewmode toggle + hide/subst/`col_map` | yes |
| ATX headings, emphasis, strike, inline/fenced code | yes |
| Blockquotes, lists, tasks, HR | yes |
| OSC 8 **emit** on link text | yes |
| Unicode padded tables (2.1 + most of 2.2) | yes |
| Cursor mapping / buffer integrity soak | yes |

**Closed as out-of-scope** (plan §5 — they change row count, which breaks
`buf_line = top_line + y - win_y`):

- ~~2.2.6 Multiline wrapped table cells~~
- ~~2.3.* Smart paragraph spacing~~

Still open, still in scope:

- [ ] **2.2.5** Narrow-terminal table wrap / horizontal-scroll fallback

---

## Phase 0 — Spec freeze ✅

- [x] **0.1** OpenCode token/attr matrix verified against the reference checkout (plan §2, §6)
- [x] **0.2** `Md*` inventory vs target tokens, incl. the 7 schemes with no markdown tokens (§6.1)
- [x] **0.3** Conceal semantics transcribed from the tree-sitter queries (§3.1)
- [x] **0.4** Link-conceal decision corrected to match OpenCode (§3.2)
- [x] **0.5** Line-grid constraint decided — no block margins, no dropped lines (§5)

---

## Phase 1 — Zero-width conceal (foundation)

Ship alone. No style changes in this commit.

- [x] **1.0a** Fence statics (`vm_fence_region_start` / `_end` / `_cached_for_line`) added next to
      the table statics; reset in `zig_bw_vm_prepare` when `vm_last_bw` changes. **No
      `_no_region_line` field** — the table detector's `±10`-line negative-cache shortcut turned
      out unsound for fences (a delimiter line correctly reporting "not a body line" says nothing
      about whether the *next* line is body); found via a throwaway debug log, then removed rather
      than worked around. See plan §4.2.1.
- [x] **1.0b** `zig_bw_fence_detect` added — forward simulation (not backward scan) over the `P`
      pointer via `bwReadLine`, bounded `fence_scan_window_lines = 300`. An earlier attempt used a
      single-pass `pgetb`-advancing reader to avoid `bwReadLine`'s O(window²) reseek cost, but it
      corrupted state on a separate, unrelated `P` after a multi-line scan — reverted to the proven
      `bwReadLine` pattern; correctness over the optimization.
- [x] **1.0c** Wired into `zig_bw_lgen_view` as step 0, before line-start dispatch: delimiter line
      → falls through to the existing single-line check; **body** → skips
      `zig_bw_view_line_start`/`_table_hl`/`_inline` entirely, `col_map_line` invalidated so
      `zig_bw_view_finish` rebuilds `col_map` fresh from the all-zero hide/subst state.
- [x] **1.0d** Indented (4+ column) code — early bail in `analyzeLineStart` (`src/render/view.zig`),
      guarded against swallowing a nested bullet marker.

      *Verified bug (plan §4.2.1) confirmed and fixed: inside a ```python fence, `# c` → `  c`,
      `a ** b` → `a    b`, `---` → `───` before this landed.*
- [x] **1.1** Column-identity unit test added in `src/render/lgen.zig` (wired to `render-test`,
      unlike most tests in this file) — confirmed RED before 1.2, GREEN after, no further edits.
- [x] **1.2** `src/render/lgen.zig` `lgenUnits` — hidden-without-substitute bytes now `continue`
      before ever reaching `paintUnit` (no emit, no `sx`/`logical` advance). `resolveCp` in
      `view.zig` dropped its `' '` fallback; substitute still wins.
- [x] **1.3** `applySquareMarkInverse` (`src/bw_lgen.zig`) takes an optional `view: ?*const
      ViewTables`; a hidden-without-substitute byte is skipped (no column advance, never marked
      inverse), matching `lgenUnits` exactly. `applyLinearMarkInverse` needed **no change** — it
      marks by absolute byte offset, independent of display width, so a hidden byte simply has
      nothing to invert.
- [x] **1.4** Verified: `col_map`/`xcol` already treated hidden as zero-width before this phase, and
      1.2's `logical`-counter skip keeps the paint loop consistent with it — horizontal scroll was
      already correct, just unverified. Confirmed with a 100-column run after a concealed heading
      prefix, scrolled to EOL: no ghost `#`, no misalignment.
- [x] **1.5** *Partially done — see the follow-up flagged below.* Added a **deterministic**
      backward clamp to `zig_bw_view_finish`: when the forward skip hits end-of-line with nothing
      visible after the hidden run (or the whole line is concealed), it now clamps to the last
      visible byte before the run (or offset 0) instead of leaving the cursor stuck on a hidden
      byte with a stale `xcol`. This needed no movement-direction context, so it was safe to add
      here.

      **Not done: full direction-aware skip** ("left lands before the run, right lands after").
      `zig_bw_view_finish` runs at *paint* time, not from the arrow-key handlers, so it has no way
      to know which direction the cursor was moving — genuinely needs direction threaded through
      the cursor-movement call chain, a larger change than this fixup. Documented in a code comment
      at the fix site.
- [x] **1.5b** Root cause turned out to be **two separate gaps**, both fixed:
      1. Movement commands (`u_goto_right`/`u_goto_left`/`u_goto_bol`/`uuparw`/`udnarw` in
         `src/uedit.zig`) set `cursor.xcol` via raw `piscol`/`pcol`
         (`src/gapbuffer/pointer.zig`), unaware of hide/collapse — as suspected. Added
         `zig_bw_viewmode_fixup_cursor` (`src/bw_lgen.zig`), re-analyzes the cursor's line fresh
         and re-applies `clampHiddenOffset` (factored out of `zig_bw_view_finish` so paint-time and
         interactive fixups agree by construction) plus the collapsed `xcol`; wired into the five
         movement commands above. `u_goto_eol` deliberately excluded — `col_map` has no entry past
         the last byte.
      2. **The actual on-screen cursor column never used `cursor.xcol` in the first place.**
         `tw.zig`'s `disptw` (the real screen-cursor placement code, found while verifying (1) did
         nothing visible) always recomputes the rendered column fresh from raw `piscol` — by
         original-C design `xcol` is only the *sticky goal column* for up/down, not a real glyph
         position, so `disptw` ignores it outside `-picture` mode. Added
         `zig_bw_viewmode_cursor_col` (`src/bw_lgen.zig`, read-only sibling of the fixup above, no
         cursor movement) and wired it into `disptw`'s `cur_col` computation as the
         markdown-viewmode-aware first choice, falling back to raw `piscol` for EOL / non-viewmode
         / non-markdown.

      **Still not done: full direction-aware skip** (same gap as 1.5's paint-time clamp —
      `clampHiddenOffset` only skips forward, so left-arrow into a hidden run "bounces" to the
      visible byte *after* it rather than stopping before). **Also not done:** up/down movement
      reinterprets the old line's *collapsed* `xcol` as a *raw* target column on the new line via
      `pcol`, then re-corrects whatever raw-byte position that lands on — not a true "preserve
      visual column across lines with different concealment," just no longer wrong on the new
      line's own terms. Both documented in code comments at the fix sites; out of scope for this
      pass.
- [x] **1.6** Rewrote the 39 failing `tests/viewmode.py` assertions using a Python port of the exact
      conceal logic to compute expectations mechanically (a hand-traced first attempt had an
      arithmetic error, caught by cross-checking against the real binary's output before writing
      anything down). Also fixed one `render-test` assertion and one `window-test` assertion that
      encoded the same stale space-padded layout.
- [x] **1.7** Source byte-fidelity across the rewrite is covered by the pre-existing
      `test_viewmode_no_file_modification[_complex]` and the `test_viewmode_cursor_*`
      `assertFileContents` checks — none needed rewriting since they check the underlying file, not
      screen layout. No new paired assertions were added beyond that; the existing coverage already
      satisfies the intent.
- [x] **1.8** `AGENTS.md` soak count updated (197 → 201).
- [x] **1.8a** `AGENTS.md:163` — "hides" language corrected to "conceals at zero width"; the
      phase-numbering collision warning near the top removed now that current Phase 1 has actually
      landed.
- [x] **1.8b** Three new soak tests: markdown-shaped content inside a fence body stays byte-exact
      (`# c`, `a ** b`, `---`), a mismatched fence character (`~~~` inside a ` ``` ` fence) stays
      body text rather than closing early, and the same byte-exactness for indented code blocks.
- [x] **1.9** Stale header comment in `src/render/view.zig:7` fixed — it says "not wired into live
      joe"; it is, via `zig_bw_view_line_start`.

---

## Phase 2 — Conceal coverage + link destinations

Target = plan §3.1 "JOE result" column, with the §3.2 deviation.

- [ ] **2.1** Inline `[a](u)` → `a`: conceal `[`, `]`, `(`, destination, `)`
- [ ] **2.2** Inline with title `[a](u "T")` → `a`: conceal the title too
- [ ] **2.3** Reference `[a][r]` → `a` (conceal `[`, `]`, and the label)
- [ ] **2.4** Collapsed `[a][]` and shortcut `[a]` → `a`
- [ ] **2.5** Image `![alt](u)` → `alt` only (no image chrome; roadmap 2.6)
- [ ] **2.6** Autolinks `<u>` and bare URLs stay **visible** — the deliberate exception; add a
      negative test so a later refactor can't quietly conceal them
- [ ] **2.7** HTML entities: `&nbsp;`/`&ensp;`/`&emsp;`→`" "`, `&lt;`→`<`, `&gt;`→`>`,
      `&amp;`→`&`, `&quot;`→`"`
- [ ] **2.8** List markers: normalise `*`/`+`/`-` → `-`
- [ ] **2.9** ~~Ordered marker right-alignment~~ — **dropped** (plan R6). Left-align as authored;
      no list-extent region. Unordered `-` normalisation (2.8) still applies
- [ ] **2.10** Attach `link_url` / OSC 8 to the surviving label cells (URL cells no longer exist)
- [ ] **2.11** Soak fixtures for each of the above at collapsed positions, including an explicit
      "screen does not contain the URL" assertion for 2.1–2.5, and a paired edit-mode assertion
      that the same fixture still shows the URL

---

## Phase 3 — Native colour scheme (Cursor Dark) + style mapping

- [ ] **3.1** `syntax/md.jsf` — six state retargets per plan R4: `:ordered_list` and
      `:ordered_mark` → `MdListEnum`; `:image_url` → `MdImageUrl`; `:idle`, `:line_start`,
      `:list_content` → `MdText`. `MdConceal` is **not** needed (table grid uses the existing
      `MdTableSeparator`)
- [ ] **3.2** Create `colors/cursor-dark.jcf` from plan §6.2 — markdown mapping (§6.2.3), general
      syntax (§6.2.5), UI keys (§6.2.6), 16 `-term` entries (§6.2.7). **Both** `.colors 256` and
      `.colors *` sections
- [ ] **3.2f** Status bar is **darker** than the editor (`#141414` bg, `#9A9A9A` fg) — not JOE's
      conventional inverted light bar (§6.2.6)
- [ ] **3.2a** Alpha handling per §6.2.1: flattened hex in the truecolor section
      (`#F0F0F099`→`#9A9A9A`, `#F0F0F05C`→`#666666`, `#40404099`→`#303030`); base colour + `dim`
      in the 256 section
- [ ] **3.2b** Delete the nine existing schemes (`default`, `gruvbox`, `ir_black`, `molokai`,
      `solarized`, `wombat`, `xoria`, `zenburn`, `zenburn-hc`)
- [ ] **3.2c** Update `colors/Makefile.am` `data_color_DATA` (autoconf path breaks otherwise);
      `build.zig:138` installs the directory wholesale and needs no change
- [ ] **3.2d** Rewrite `NEWS.md:231-243` — it credits the seven upstream scheme authors by name.
      Record the removal; do not silently drop the attributions
- [ ] **3.2e** Check Cursor's licence terms for the theme package before vendoring its colours;
      record the outcome next to the scheme
- [ ] **3.3** View attrs: H1 bold+underline; H2–H6 bold; strong bold; emph italic; quote italic;
      link label and URL underlined
- [ ] **3.4** Exact colours per plan §6.2.3 / §6.2.5. Note Cursor inverts OpenCode's link
      colours: label = lavender `#AAA0FA`, URL = teal `#82D2CE`
- [ ] **3.5** Edit mode: all source visible; soft-align highlight to the same palette
- [ ] **3.6** Degradation check: truecolor → 256 → 16 → attributes; every `Md*` legible at 16.
      Cursor Dark is a dark-background theme — verify on a light terminal too
- [ ] **3.7** Visual check against Cursor Dark side by side (colours), and against OpenCode for
      conceal/layout (§3)

---

## Phase 4 — In-tree `md_event` layer

- [ ] **4.1** Add `src/render/md_event.zig` with MD4C-shaped enter/leave block/span/text callbacks
- [ ] **4.2** Node taxonomy (koino-inspired): Heading, Emph, Strong, Strike, Code, CodeBlock, Link,
      List/Item/Task, BlockQuote, HR, Table/*, Text, breaks; **ignore Image**
- [ ] **4.3** Sink events into existing `ViewTables` + attr overrides (no HTML backend)
- [ ] **4.4** Migrate `applyEmphasis` (`src/render/view.zig:301`, ~140 lines of unrolled delimiter
      cases) to events; add CommonMark flanking rules
- [ ] **4.5** Migrate remaining `view.zig` scanners where it fixes nesting/autolink
- [ ] **4.6** Unit tests for events → tables; keep `table.zig` as layout backend
- [ ] **4.7** Wire through `bw_lgen` view entry; full viewmode soak green

---

## Phase 5 — Clickable links (OSC 8 + mouse open)

- [ ] **5.1** Harden OSC 8 emit on concealed labels (C0/C1 strip exists at
      `src/terminal/screen.zig:1438`)
- [ ] **5.2** Hit-test display cell → buffer byte → URL using the collapsed `col_map`
- [ ] **5.2b** Reference-link definitions per plan R2: **no cache**. OSC 8 on paint covers inline
      links only; on *click*, scan the buffer once for `^[ \t]{0,3}\[<label>\]:[ \t]*<dest>`
      (label match case-insensitive). Conceal already works without this
- [ ] **5.3** Hook `udefmup` (`src/mouse.zig:1246`); simple click = `mouseup` with `selecting == 0`
- [ ] **5.4** Open via `execlp` + argv — **never** `/bin/sh -c` with the URL interpolated
      (injection: `[x](http://a;rm -rf ~)`); precedent at `src/ublock.zig:1323`
- [ ] **5.5** Scheme allowlist: `http`, `https`, `mailto`, `file` — reject everything else
- [ ] **5.6** macOS `open` / Linux `xdg-open`; fork + `_exit` on failure, never block the editor
- [ ] **5.7** Do not steal selection drag, right-click paste (`udefm3up`), or wheel
- [ ] **5.8** Optional rc/help note (click + terminal Cmd/Ctrl-click)
- [ ] **5.9** Unit-test hit-test and scheme rejection; soak or hook for open if practical

---

## Phase 6 — Scoped CM/GFM gaps

- [ ] **6.1** Autolinks / bare URLs: detect and attach OSC 8 + click. Text stays the URL itself —
      conceal does not apply (task 2.6)
- [ ] **6.2** Setext headings (both lines visible, heading-styled — matches OpenCode)
- [ ] **6.3** Table header cells styled `markup.heading` (bold + heading color)
- [ ] **6.4** Table pipes / delimiter row muted (`punctuation.special`)

**Out of scope here:** images, footnotes, raw HTML, math, nested fence language HL (roadmap 2.5),
block margins, dropped fence lines, wrapped table cells (plan §5).

---

## Phase 7 — Docs & gate

- [ ] **7.1** Keep plan + this TODO aligned with code
- [ ] **7.2** User-facing note (help and/or `docs/`) for viewmode + clickable links
- [ ] **7.3** Document the deliberate deviations from OpenCode so they read as choices — the full
      list is in the plan appendix (link conceal §3.2, line grid §5). Note that viewmode hides
      link URLs and `^T A` shows the source
- [ ] **7.4** `cp -f zig-out/bin/joe joe/joe && ./runtests` green at the updated count

---

## Cross-cutting (still open)

- [ ] **T.2–T.6** Multi-TERM / multi-emulator checks (16 / 256 / truecolor)
- [ ] **T.7** Large-file viewmode performance smoke (≈10k lines)
- [ ] **D.3** Maintain comments on `md.jsf` DFA for edit-mode highlight

---

## Execution notes for agents

1. Read `plans/markdown-wysiwyg-feasibility.md` before coding — especially §3 (conceal
   semantics), §4 (the space-padding gap), and §5 (line-grid constraint).
2. **Phase 1 is a prerequisite for everything visual.** Do not start Phase 3 styling before
   conceal collapses; you would be tuning colors on a layout that is about to change.
3. Reuse `ViewTables`, `table.zig`, OSC 8 emit, and soak tests — extend, don't fork a second
   paint path.
4. When `viewmode` is off, rendering must stay source-faithful (edit highlight only).
5. **Key files:** `src/render/lgen.zig`, `src/render/view.zig`, `src/render/table.zig`,
   `src/bw_lgen.zig`, `src/mouse.zig`, `syntax/md.jsf`, `colors/cursor-dark.jcf`,
   `tests/viewmode.py`, `rc/joerc.in`.
6. No new dependency in `build.zig` for markdown parsing.
7. Verify OpenCode claims against `~/Projects/opencode-research` rather than trusting this doc —
   the reference moves.
