# Markdown rich viewmode — Task List

> **Branch:** work on **`markdown`** (synced from `zig-rewrite`).
> **Source:** `plans/markdown-wysiwyg-feasibility.md` (OpenCode-style plan; Zig Path A)
> **Status:** Phase 1–2 baseline **shipped**. Active work = Phases 1–7 below (Phase 0 done).
> **Constraint:** Self-contained Zig — borrow ideas from koino/MD4C/OpenCode; **no** vendored markdown libs.
> **Reference checkout:** `~/Projects/opencode-research` — see plan §2 for exact file paths.
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

- [ ] **1.0a** Add fence statics (`vm_fence_region_start` / `_end` / `_cached_for_line` /
      `_no_region_line` / `_char` / `_len`) next to the table statics at `src/bw_lgen.zig:1227`;
      reset them in `zig_bw_vm_prepare` when `vm_last_bw` changes
- [ ] **1.0b** Add `zig_bw_fence_detect`, shaped like `zig_bw_table_detect` — backward scan over
      the `P` pointer, `±10`-line window, positive **and** negative caching
- [ ] **1.0c** Wire into `zig_bw_lgen_view` between steps 1 and 2: delimiter line → keep marker
      conceal; **body** → skip `zig_bw_view_line_start`, `_table_hl`, `_inline`, build `col_map`
      from raw bytes, return
- [ ] **1.0d** Indented (4-space) code blocks — early bail in `zig_bw_view_line_start`, no region
      scan needed

      *Verified bug (plan §4.2.1): inside a ```python fence, `# c` → `  c`, `a ** b` → `a    b`,
      `---` → `───`. **Must land before or with 1.2** — collapse turns a cosmetic misalignment
      into deleted characters.*
- [ ] **1.1** Add the column-identity unit test **first** (painted column == `col_map[byte]`) so it
      fails before the change and passes after
- [ ] **1.2** `src/render/lgen.zig` — in the `lgenLine` loop (~L344-366), skip hidden bytes without
      advancing `sx`; drop the `' '` branch from `resolveCp` (keep `substitute`)
- [ ] **1.3** `src/bw_lgen.zig` — recompute `applyLinearMarkInverse` (~L2728) and
      `applySquareMarkInverse` (~L2844) against collapsed display columns
- [ ] **1.4** Verify horizontal scroll (`scr` / `bw->offset`) on long concealed lines
- [ ] **1.5** Cursor semantics per plan R5: forward skip already exists in `zig_bw_view_finish`
      (`src/bw_lgen.zig:860`); **add the backward case**, clamp at end of line, column 0 for a
      fully concealed line
- [ ] **1.5b** Round-trip test: left-then-right across a concealed span returns to the same byte
      (the two skip directions must agree)
- [ ] **1.6** Rewrite the 62 space-padded assertions in `tests/viewmode.py`
- [ ] **1.7** Add paired edit-mode assertions pinning source byte-fidelity
- [ ] **1.8** `AGENTS.md`: update the soak count (currently 197)
- [ ] **1.8a** `AGENTS.md:163` says *"Viewmode **hides** markdown delimiters"* — after this phase
      that is wrong in the exact way §4 is about. Reword to "conceals at zero width". Also drop
      the phase-numbering warning near the top once the old/new Phase 1 collision is gone
- [ ] **1.8b** Soak: markdown-ish content inside a fenced body stays byte-exact on screen
      (`# c`, `a ** b`, `---`, `[a](u)`) — currently untested; every existing fence test uses a
      body with no markdown characters
- [ ] **1.9** Fix the stale header comment in `src/render/view.zig:7` ("not wired into live joe" —
      it is; `zig_bw_view_line_start` calls it)

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

## Phase 3 — OpenCode style mapping

- [ ] **3.1** `syntax/md.jsf` — six state retargets per plan R4: `:ordered_list` and
      `:ordered_mark` → `MdListEnum`; `:image_url` → `MdImageUrl`; `:idle`, `:line_start`,
      `:list_content` → `MdText`. `MdConceal` is **not** needed (table grid uses the existing
      `MdTableSeparator`)
- [ ] **3.2** Expand the plan §6.2.1 template with §6.2.2 values into **all 9** `colors/*.jcf`,
      **both** `.colors` sections each (`default` 16-only, `xoria` 256-only, `solarized` uses
      `.set` names so one text works for both). Rewrite the existing `default`/`gruvbox` blocks
      from the template rather than patching them
- [ ] **3.2b** Optional: try `=MdCode +String bold` on one line — if the parser accepts a `+Ref`
      chain plus a spec (plan §6.2.3, unverified), collapse the block to inheritance
- [ ] **3.3** View attrs: H1 bold+underline; H2–H6 bold; strong bold; emph italic; quote italic;
      link label and URL underlined
- [ ] **3.4** Exact colors per plan §6 (note `markdownLink` `#fab283` and
      `markdownListEnumeration` `#56b6c2`, both missing from the old matrix)
- [ ] **3.5** Edit mode: all source visible; soft-align highlight to the same palette
- [ ] **3.6** Degradation check: truecolor → 256 → 16 → attributes, every `Md*` legible at 16
- [ ] **3.7** Visual check against OpenCode default dark side by side

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
   `src/bw_lgen.zig`, `src/mouse.zig`, `syntax/md.jsf`, `colors/*.jcf` (all 9),
   `tests/viewmode.py`, `rc/joerc.in`.
6. No new dependency in `build.zig` for markdown parsing.
7. Verify OpenCode claims against `~/Projects/opencode-research` rather than trusting this doc —
   the reference moves.
