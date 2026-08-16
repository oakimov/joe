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

- [x] **2.1** Inline `[a](u)` → `a`: conceal `[`, `]`, `(`, destination, `)`
- [x] **2.2** Inline with title `[a](u "T")` → `a`: conceal the title too. `applyLinks`
      (`src/render/view.zig`) doesn't distinguish destination from title — it conceals the whole
      `(...)` span verbatim, same as it always stored the whole span as `link_url`
- [x] **2.3** Reference `[a][r]` → `a` (conceal `[`, `]`, and the label)
- [x] **2.4** Collapsed `[a][]` and shortcut `[a]` → `a`. Shortcut (`[a]` with no following
      `(...)`/`[...]`) was previously **unhandled entirely** (rendered as literal `[a]`) — added,
      using the label text itself as the link name, matching CommonMark shortcut-reference
      semantics
- [x] **2.5** Image `![alt](u)` → `alt` only (no image chrome; roadmap 2.6). Same delimiter scan
      as inline/reference links with a leading `!` check; images aren't styled as clickable text
      (no underline/color) since there's no click target semantics yet
- [x] **2.6** Autolinks `<u>` and bare URLs stay **visible** — never matched the `[` entry
      condition in the first place, so no code change; added the negative test
- [x] **2.7** HTML entities: `&nbsp;`/`&ensp;`/`&emsp;`→`" "`, `&lt;`→`<`, `&gt;`→`>`,
      `&amp;`→`&`, `&quot;`→`"`. New `applyEntities` (`src/render/view.zig`), same
      substitute-first-hide-rest mechanism as task checkboxes/HR; skips code spans like
      `applyEmphasis` does. Unknown/unlisted entities (e.g. `&frobnicate;`) are left untouched —
      no attempt at the full HTML5 entity table, matching this phase's explicit scope
- [x] **2.8** List markers: normalise `*`/`+`/`-` → `-`. Folded into the existing task-checkbox
      line-start block (both need the same leading-whitespace-then-marker scan). A
      `* * *`-shaped thematic break also matches this bullet shape, but the HR check immediately
      after unconditionally re-substitutes the whole line when it recognizes a real HR, so this
      normalisation is harmlessly overwritten in that case — no special-casing needed
- [x] **2.9** ~~Ordered marker right-alignment~~ — **dropped** (plan R6). Left-align as authored;
      no list-extent region. Unordered `-` normalisation (2.8) still applies
- [x] **2.10** Attach `link_url` / OSC 8 to the surviving label cells (URL cells no longer exist).
      Verified rather than changed: `lgen.zig`'s `linkAt(byte_idx)` lookup only ever runs for
      **visible** bytes (hidden bytes `continue` before reaching it, since Phase 1.2), so once the
      destination bytes are hidden the existing OSC 8 emission automatically follows the label —
      confirmed by the pre-existing `lgenLine applies viewmode link urls onto cells` test, still
      green unmodified
- [x] **2.11** Soak fixtures for each of the above at collapsed positions, including an explicit
      "screen does not contain the URL" assertion for 2.1–2.5 (via `readLine` + `assertNotIn`,
      no dedicated helper existed), and a paired edit-mode assertion (`self.mode("viewmode")`
      toggled back off) that the same fixture still shows the raw source. Soak count 201 → 206

---

## Phase 3 — Native colour scheme (Cursor Dark) + style mapping

- [x] **3.1** `syntax/md.jsf` — six state retargets per plan R4 applied. **Also required a
      seventh change not in the plan**: `md.jsf`'s own top-of-file `=ClassName [+fallback]` block
      is a *class registry* that the file's `:state ClassName` declarations are validated
      against at parse time (`src/syntax.zig` — completely separate from which `.jcf` color
      scheme happens to be active). Retargeting six states to reference `MdText`/`MdListEnum`/
      `MdImageUrl` without also registering those three names there breaks the whole syntax file
      (`Unknown class` parse errors → the file's `high_syntax` doesn't resolve as usable → **both
      highlighting and viewmode conceal silently stop working**, since `syntaxNameIsMd` no longer
      matches). Added `=MdText +Idle`, `=MdListEnum +MdList`, `=MdImageUrl +MdLinkUrl` alongside
      the existing entries. `MdConceal` is **not** needed (table grid uses the existing
      `MdTableSeparator`), confirmed.

      **Also discovered**: `src/builtins_data.zig` embeds a compiled-in copy of `md.jsf` (and
      every other builtin rc/syntax/color file) used when `-Djoerc=`/`-Djoedata=` are empty
      (AGENTS.md's documented "empty forces builtins" mode) — normal `zig build` testing doesn't
      exercise it (the `sys` tier in `open_configrc_file`'s fallback chain finds the real
      `zig-out/share/joe/...` copy first), so it's easy to silently drift out of sync. Kept it in
      sync with a regeneration script (comment/blank-line stripping to match the existing
      convention) rather than hand-patching twice.
- [x] **3.2** Created `colors/cursor-dark.jcf` from plan §6.2 — markdown mapping (§6.2.3), general
      syntax (§6.2.5), UI keys (§6.2.6), 16 `-term` entries (§6.2.7), **both** `.colors 256` and
      `.colors *` sections, generated programmatically (palette table → file) to avoid
      hand-transcription drift between the two sections.
- [x] **3.2f** Status bar darker than the editor (`#141414`/`#9A9A9A`) per §6.2.6 — done.
- [x] **3.2a** Alpha flattening per §6.2.1 — done (`.set` values match the flattened hex table
      exactly; truecolor section uses the flattened hex, 256 section uses the given index).
- [x] **3.2b** Deleted the nine existing schemes. **Verified, not assumed**, that this is a true
      no-op for `-colors default` specifically: diffed `colors/default.jcf`'s content against the
      embedded builtin `default.jcf` in `builtins_data.zig` before deleting — functionally
      identical, so the embedded copy picks up the slack seamlessly. `-colors gruvbox` (and the
      other six removed non-default names) now fail to resolve, which is expected —
      `apply_scheme(null)` is a documented no-op, doesn't crash, covered by
      `test_removed_scheme_name_degrades_gracefully` in the new `tests/colors.py`.
      `-colors cursor-dark` is **opt-in**, matching how the eight non-default schemes always
      worked — `rc/joerc.in`'s `-colors scheme` line stays commented out, so out-of-box behavior
      is genuinely unchanged (plan §6.2.8's claim, now verified rather than assumed).
- [x] **3.2c** `colors/Makefile.am` `data_color_DATA` now just `cursor-dark.jcf`.
- [x] **3.2d** `NEWS.md` — added a removal note right after the seven-author credit list rather
      than deleting it, naming what replaced them and that `-colors default` still works.
- [x] **3.2e** Researched (could not find definitive license text for the specific
      `cursor-official-themes` package). Found: the exact palette is independently republished by
      multiple unrelated third parties under permissive licenses (MIT ×3, one GPL-3.0) with no
      apparent objection from Cursor/Anysphere; `cursor-dark.jcf` is a derived translation of
      color *values* into JOE's own class names/file format, not a copy of the theme JSON or any
      other copyrightable expression. Judged reasonable to ship on that basis — not a legal
      opinion. Full note in `colors/reference/README.md`.
- [x] **3.3** View attrs match plan exactly: H1 bold+underline, H2–H6 bold (`+MdH2` inheritance),
      strong(`MdBold`) bold, emph(`MdItalic`) italic, quote(`MdBlockquote`) italic, link label
      and URL both underlined.
- [x] **3.4** Exact colours per §6.2.3/§6.2.5, including the OpenCode-inverted link colours
      (label lavender, URL teal).
- [x] **3.5** Edit mode (viewmode off) verified to apply the same classes/colors to the raw,
      unconcealed delimiters as viewmode applies to the concealed-then-revealed text —
      `test_heading_colored_in_edit_mode` in `tests/colors.py`. "Soft-align highlight" reduces to
      `MdTableAlign`, already covered by the scheme; no separate mechanism found anywhere else in
      the codebase for that phrase.
- [x] **3.6** `.colors 16` section added (plan asks for a degradation check; the plan's own §3.2
      checklist item only explicitly required 256+truecolor, but `apply_scheme` picks the best
      color-set whose depth fits the terminal and returns a no-op if *none* fit — without a 16
      tier, a 16-color terminal would render with **no scheme applied at all**, not a degraded
      one). Verified the whole file parses cleanly. **Also discovered**, while testing this: the
      soak suite's pinned test dependency (`pyte==0.5.2`) doesn't parse extended 256-color/
      truecolor SGR sequences into its `Char.fg` field (confirmed by diffing against pyte 0.8.2
      locally, where the same JOE output does show the real fg hex) — bold/underline parse
      correctly in both. `tests/colors.py`'s color tests assert on bold/underscore, not fg value,
      documented inline; a fg-value assertion would have been a false negative under the pinned
      dependency, not a real bug. Have not separately verified on an actual light-background
      terminal (§3.6's other explicit ask) — out of scope for what's automatable here.
- [ ] **3.7** Visual check against Cursor Dark side by side, and against OpenCode for
      conceal/layout — needs a human looking at a real terminal; not attempted.

---

## Phase 4 — In-tree `md_event` layer

Scoped down from a full event-sourced parser to what the plan's ship-order note actually asks for
("4 in parallel once conceal is stable" — a lower-priority quality pass, not a rewrite): a
documented taxonomy plus a concrete, tested fix for `applyEmphasis`'s worst known gap
(flanking rules), landed with zero soak regressions. A full delimiter-stack rewrite for nested
emphasis was considered and deliberately **not** attempted — see 4.4/4.5 below.

- [x] **4.1** Added `src/render/md_event.zig`. **Scoped from "MD4C-shaped enter/leave block/span
      callbacks" to what's actually used**: JOE parses line-by-line with carried block state, not
      a full-document AST (plan §8 says as much — "prefer line/region + carried state before a
      full-doc AST"), so a real enter/leave callback tree sitting over nothing would be dead
      scaffolding. What's real and wired in: `classifyRun`/`classifyAt`, a byte-oriented
      implementation of CommonMark §6.2's flanking-delimiter-run rule (including the `_`
      intraword restriction), used by `applyEmphasis`.
- [x] **4.2** `NodeKind` taxonomy added (koino-inspired: document, heading, paragraph,
      block_quote, list, item, task_item, code_block, thematic_break, table/table_row/table_cell,
      text, soft_break, line_break, emph, strong, strikethrough, code_span, link, escape).
      **Documents the shape** a future full event layer would use — `view.zig`'s line-scanners
      already detect all of these constructs today, just not through this enum yet. `Image`
      absent per plan roadmap 2.6.
- [~] **4.3** No separate "sink events into `ViewTables`" step exists, because there's no event
      stream yet to sink — `classifyRun`/`classifyAt`'s boolean results feed directly into
      `applyEmphasis`'s existing `tables.hide[...]` calls at the two points that needed gating
      (open-check, close-check).
- [x] **4.4** Migrated `applyEmphasis`'s open/close decisions (not the whole 140-line scanner
      structure — the nested 3-star/2-star/1-star dispatch and code-span exclusion stay, they
      aren't broken) to consult `classifyAt` before treating a `*`/`_` as an opener or closer.
      Fixes two confirmed, reproduced-before-fix bugs: `x * a * y` (space-flanked stars) and
      `snake_case_word` (intraword `_`) were both wrongly concealed as emphasis; both now render
      literally. Verified `a*b*c` (star has no intraword restriction) and `foo _bar_ baz`
      (word-boundary underscore) still correctly become emphasis. Zero regressions in the
      existing render-test/soak emphasis coverage.

      **Deliberately not fixed**: nested emphasis (`**bold *italic* more**`) — already an
      explicitly-documented, accepted limitation before this phase
      (`test_viewmode_nested_bold_italic`: "Linear scanner limitation — nested emphasis not fully
      supported yet"). Fixing it needs a real delimiter-stack matcher (CommonMark's Rule 9, the
      part MD4C/koino spend the most code on) layered under the ~40 existing emphasis soak tests
      that encode the current scanner's exact output — judged high regression risk for a
      documented-and-accepted gap, not worth it in this pass.
- [ ] **4.5** Autolinks (`<url>`/bare URL) have **zero** styling today — confirmed no code
      anywhere applies `MdLinkUrl`-shaped attrs to them, despite plan §3.1 saying they should be
      styled (just not concealed). This is a real gap, but it's *adding* a feature, not migrating
      existing scanner code to fix a bug in it — tracked as Phase 6's top-priority item instead
      (which is explicitly about scoped CM/GFM feature gaps), not duplicated here.
- [x] **4.6** Unit tests for the flanking classifier (`md_event.zig`, 6 tests covering the spec
      example cases + the two bugs) plus soak fixtures (`tests/viewmode.py`, 4 tests). `table.zig`
      untouched — stays the layout backend, no event-layer involvement needed there.
- [x] **4.7** No separate wiring step needed — `applyEmphasis` is already called from both
      `analyzeLine` and `analyzeLineInline`, both already wired through `bw_lgen`'s view entry
      since Phase 1. Soak 215/215 (211 → 215, four new fixtures); render-test/terminal-test/
      window-test green.

---

## Phase 5 — Clickable links (OSC 8 + mouse open)

- [x] **5.1** Verified — the C0/C1/DEL strip in `appendSanitizedUrl` (`src/terminal/screen.zig`)
      already covers ESC (0x1B) and the whole C0/C1 range, so a malicious URL can't break out of
      the OSC 8 wrapper or inject further escape sequences. No further hardening needed.
- [x] **5.2** `zig_bw_viewmode_click_byte_offset` (`src/bw_lgen.zig`) — reverse of the Phase 1.5b
      `zig_bw_viewmode_cursor_col`: given a display column, finds the buffer byte whose collapsed
      `col_map` entry matches. Wired into `utomouse`'s text-window branch (`src/mouse.zig`),
      replacing the raw/uncollapsed `pcol` call when viewmode+md — **this was a real, previously
      unnoticed bug**: clicking a concealed markdown line (e.g. a heading) landed on the wrong
      byte, the same class of bug Phase 1.5b fixed for arrow keys but for mouse clicks. Verified:
      clicking display column 1 of "Heading" (from "# Heading") now lands on 'e' (byte offset 2),
      not the space after the raw '#' where uncollapsed `pcol` would have put it.
- [x] **5.2b** Reference-link definitions resolved lazily at click time, not cached —
      `resolveReferenceUrl` (`src/bw_lgen.zig`) scans the buffer once via `parseReferenceDef`
      (`src/render/md_event.zig`, unit-tested: 7 cases covering case-insensitivity, 3-space
      indent limit, trailing-title stripping, non-matches) only when the byte under the cursor's
      `link_url` isn't already a safe-scheme URL (i.e. it's a reference *label*, per Phase 2's
      "no cache" design — inline links skip this scan entirely).
- [x] **5.3** Hooked `udefmup` (`src/mouse.zig`): `selecting == 0` branch now calls
      `zig_bw_try_open_link_at_cursor` (gated to text windows only, matching the existing
      `TYPEPW|TYPETW` check pattern in this file).
- [x] **5.4** `execlp` + argv directly, never `/bin/sh -c` — verified via unit test
      (`isSafeUrlScheme` test explicitly documents that a URL with shell metacharacters is
      "safe" *by this check* only because the caller never invokes a shell).
- [x] **5.5** Scheme allowlist (`isSafeUrlScheme`, `src/render/md_event.zig`, moved there
      specifically so it's unit-testable — `bw_lgen.zig` isn't part of `zig build test`):
      `http://`, `https://`, `mailto:`, `file://`; 4 unit tests for accept/reject including
      `javascript:`/`data:`/case-sensitivity.
- [x] **5.6** Double-fork (`spawnOpenUrl`, `src/bw_lgen.zig`): tries `open` (macOS) then
      `xdg-open` (Linux); the intermediate child exits immediately so the actual opener process
      is reparented to init rather than becoming a zombie joe has to reap, and the single
      `waitpid` only waits for that near-instant intermediate child — never blocks on the
      URL-opener itself.
- [x] **5.7** Verified by inspection — only the `selecting == 0` branch of `udefmup` (left-button
      mouseup, no preceding drag) was touched; `udefm2up`/`udefm3up`/wheel bindings and
      `udefmdrag`'s drag-sets-`selecting=1` path are untouched.
- [x] Optional rc/help note: added to `docs/man.md` (click-to-open + terminal Cmd/Ctrl-click via
      the OSC 8 JOE already emits, independent of JOE's own click handling).
- [x] Test coverage: 5 new `tests/viewmode.py` fixtures (collapsed-column click hit-test,
      unsafe-scheme no-crash, reference-link resolve, undefined-reference no-crash) using raw SGR
      mouse escape sequences (`\x1b[<0;COL;ROWM`/`m`) injected via `self.joe.write` — no existing
      precedent for this in the test harness, added fresh. **Deliberately did not** write a test
      that clicks a real http(s)/mailto/file link end-to-end, since that would actually spawn
      `open`/`xdg-open` on the test machine — verified the spawn-gating logic thoroughly (schemes,
      reference resolution) without ever triggering a real spawn during automated tests.
      Soak 219/219 (215 → 219, four new fixtures); render-test/terminal-test/window-test green.
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
