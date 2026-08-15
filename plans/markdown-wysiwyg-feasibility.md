# Markdown rich viewmode (OpenCode-style) — Plan

> **Branch:** all markdown work happens on **`markdown`**, kept in sync with `zig-rewrite`
> (fast-forward `markdown` from `zig-rewrite`, never the reverse).
> **Live path:** Zig Path A (`src/bw_lgen.zig`, `src/render/*`). Self-contained —
> **borrow ideas** from external libraries; **do not vendor** koino, MD4C, OpenTUI, or marked.
> **Toggle:** `^T A` / `mode,"viewmode"` for buffers with `syntax md` only.
> **Invariant:** viewmode never mutates buffer text.
>
> **Task list:** `plans/TODO.md`
> **Deferred (images, nested fence HL):** `plans/future-roadmap.md`
> **Reference checkout:** `~/Projects/opencode-research` (see §2 for exact paths)

This document **replaces** the old C-era feasibility essay as the active plan. A Phase 1–2
viewmode already ships on the Zig paint path; the work below brings **OpenCode-like** rich
rendering, correct conceal, and clickable links.

---

## 1. Goal

| Mode | Behavior |
|---|---|
| **Edit** (`viewmode` off) | Plain Markdown source + `syntax/md.jsf` highlight |
| **View** (`viewmode` on) | Concealed rich render (OpenCode visual cues) + OSC 8 + mouse-open links |

No inline images in this plan (future hook only).

---

## 2. Verified OpenCode reference

Everything in §3–§5 was read out of the reference checkout, not inferred. Re-verify against
these paths when OpenCode is updated; **cite them in code comments** rather than vendoring.

| What | Path (under `~/Projects/opencode-research`) |
|---|---|
| Theme token names + `getSyntaxRules()` attrs | `packages/tui/src/theme/index.ts` (tokens ~L66-79, markdown rules ~L793-905) |
| Default theme colors | `packages/ui/src/theme/themes/opencode.json` (`dark.overrides`) |
| Markdown renderer | `node_modules/.bun/@opentui+core@0.4.3+*/node_modules/@opentui/core/index.js` (`MarkdownRenderable`, ~L7945-9020) |
| Renderer public contract | `.../@opentui/core/renderables/Markdown.d.ts` |
| **Conceal rules (authoritative)** | `.../@opentui/core/assets/markdown/highlights.scm`, `.../assets/markdown_inline/highlights.scm` |
| Production render options | `packages/tui/src/routes/session/index.tsx:1700-1706` |

Production settings OpenCode actually uses:

```tsx
<markdown internalBlockMode="top-level" tableOptions={{ style: "grid" }} conceal={ctx.conceal()} />
// conceal defaults to true (index.tsx:259); user-toggleable via "session.toggle.conceal"
```

OpenCode's stack is `marked` + tree-sitter + Yoga flexbox. JOE copies the **look and conceal
semantics only**.

---

## 3. Conceal semantics (the load-bearing detail)

OpenCode's tree-sitter queries use three directives. This is the exact vocabulary JOE must
reproduce:

| Directive | Meaning | JOE equivalent |
|---|---|---|
| `(#set! conceal "")` | Bytes render at **zero width**; following text shifts left | **does not exist yet** — see §4 |
| `(#set! conceal "X")` | Bytes render as the single glyph `X` | `vm_subst` (exists) |
| `(#set! conceal_lines "")` | The **entire line** is dropped from output | conflicts with JOE's line grid — see §5 |

### 3.1 Exact per-construct rules

Transcribed from `assets/markdown*/highlights.scm`:

The **JOE** column is what we build. It matches OpenCode everywhere except link destinations
(§3.2).

| Construct | OpenCode rule | OpenCode result | JOE result |
|---|---|---|---|
| ATX heading `## T` | `atx_hN_marker` → `conceal ""` | `T` at column 0 | same |
| Setext heading | underline line styled as heading (no conceal) | both lines visible | same |
| `**bold**`, `*em*`, `~~del~~` | `emphasis_delimiter` → `conceal ""` | `bold` | same |
| `` `code` `` | `code_span_delimiter` → `conceal ""` | `code` | same |
| Fenced code | delimiter **and** `info_string` → `conceal ""` + `conceal_lines ""` | fence lines removed | markers concealed **in place** (§5) |
| **Inline link `[a](u)`** | `[`→`""`; `]`→`" "`; `(`, `u`, `)` **visible** | `a (u)` | **`a` — URL concealed (§3.2)** |
| Ref link `[a][r]` | `[`, `]`, `link_label` → `conceal ""` | `a` | same |
| Collapsed/shortcut `[a]` | `[`, `]` → `conceal ""` | `a` | same |
| Image `![alt](u)` | `!`, `[`, `]`, `(`, dest, `)` → `conceal ""` | `alt` | same |
| **Autolink `<u>` / bare URL** | `uri_autolink` → `markup.link.url` (no conceal) | URL visible | URL visible (§3.2) |
| List marker | styled `markup.list`; bullet conceal commented out upstream | marker visible | same |
| Task marker | `markup.list.checked` / `.unchecked` styled; no substitution | `[x]` / `[ ]` | `☑` / `☐` (already shipped) |
| Blockquote `>` | `block_quote_marker` → `punctuation.special`; bar is a box border | see §3.3 | `│` substitute (already shipped) |
| Thematic break | `thematic_break` → `punctuation.special`; rule is a box border | see §3.3 | `─` substitute (already shipped) |
| HTML entities | `&nbsp;`→`" "`, `&lt;`→`<`, `&gt;`→`>`, `&amp;`→`&`, `&quot;`→`"`, `&ensp;`/`&emsp;`→`" "` | substituted | same |

### 3.2 Deliberate deviation — conceal link destinations

**Decision (locked): JOE conceals inline link URLs. `[a](u)` renders as `a`.**

This is a knowing divergence from OpenCode, which renders `a (u)`:

```js
case "link":
  if (this._conceal) {
    for (const child of token.tokens)
      this.renderInlineTokenWithStyle(child, chunks, "markup.link.label", linkHref)
    chunks.push(this.createChunk(" (",         "markup.link",     linkHref))
    chunks.push(this.createChunk(token.href,   "markup.link.url", linkHref))   // ← JOE conceals this
    chunks.push(this.createChunk(")",          "markup.link",     linkHref))
  }
```

Rationale: OpenCode renders a transcript that scrolls past once. JOE is an **editor** — the user
reads and re-reads the same document, and raw URLs inline are the single biggest source of visual
noise in a prose Markdown file. A clean reading surface is worth more here than it is in a chat
log. So: conceal `[`, `]`, `(`, the destination, any title, and `)`. Only the label survives.

Scope of the deviation — conceal applies to **bracketed link syntax only**:

- `[a](u)`, `[a](u "title")` → `a`
- `[a][r]`, `[a][]`, `[a]` → `a`
- `![alt](u)` → `alt`
- **Autolinks `<https://x>` and bare URLs stay visible.** There is no label to fall back on;
  concealing them would delete the content. This matches OpenCode.

### 3.2.1 Seeing the destination

`^T A`. Edit mode shows the full source, URLs included — that is what the dual-mode design is
for, and it is a complete answer. Viewmode conceals; edit mode reveals.

OSC 8 and click-to-open (Phase 5) are conveniences on top, not compensations for something
missing.

### 3.3 Block layout OpenCode applies on top of conceal

These are **not** character substitutions — they are flexbox boxes:

| Construct | Implementation | Constants |
|---|---|---|
| Blockquote | `BoxRenderable border:["left"] paddingLeft:1` | border color = `conceal` style fg (muted) |
| Thematic break | `BoxRenderable border:["top"] width:"100%" height:1` | full-width rule, muted |
| List item | row = marker `TextRenderable` + content column | marker `-` (unordered) or `N.` (ordered), `padStart(markerWidth)` + one space; content is a flex column ⇒ **hanging indent** |
| Inter-block gap | `marginBottom = 1` between separately-rendered blocks | one blank row |
| Fenced code | `CodeRenderable`, `conceal = concealCode` (**default false**) | fence lines already dropped by `conceal_lines` |
| Table | `TextTable`, `style:"grid"`, `borderStyle:"single"` | `cellPadding 0`, `wrapMode "word"`, `columnWidthMode "full"`, border color = muted |

Note the list-marker normalisation: `*`, `+`, `-` all render as `-`, and ordered markers are
**right-aligned** to the widest marker in the list.

---

## 4. The blocking gap: `hide` means *space*, not *zero width*

This is the single most important thing an implementer must know, and the previous plan did not
mention it.

**Today, live:** `src/render/lgen.zig:28` → `src/render/view.zig:568`

```zig
pub fn resolveCp(tables: *const ViewTables, byte_idx: usize, cp: u21) u21 {
    const sub = tables.subAt(byte_idx);
    if (sub != 0) return sub;
    if (tables.isHidden(byte_idx)) return ' ';   // ← one blank cell per hidden byte
    return cp;
}
```

So `# Heading` paints as `␠␠Heading`, and `[a](http://x)` paints as `␠a␠␠http://x␠`. Existing
soak tests encode exactly that (`tests/viewmode.py:341` asserts `"Click  here  http:/"`).

**Consequence:** simply extending `hide` to cover URL bytes — the previous Phase 1 — would
replace a URL with a long run of spaces. That is *worse* than the status quo, not closer to
OpenCode. Conceal must **collapse**.

### 4.1 There is already an inconsistency to fix

`buildColMap` (`src/render/view.zig:532`) **already** treats hidden bytes as zero width:

```zig
tables.col_map[i] = display_col;
if (tables.hide[i] != 0) continue;   // no advance
```

So `col_map` (cursor mapping, `xcol`) and the painted output disagree on column positions for
every line containing a hidden byte. Collapsing the paint makes the two agree; it is a bug fix,
not only a feature.

### 4.2 Implementation direction

Introduce an explicit distinction rather than overloading `hide`:

| Table | Semantics | Status |
|---|---|---|
| `hide[i] != 0` | zero-width — emit nothing, advance no column | **behavior change** |
| `substitute[i] != 0` | emit that codepoint (covers `conceal "X"`) | exists |
| *(retire)* space-padding | — | replaced by the above |

Touch points, in dependency order:

1. `src/render/lgen.zig` — `lgenLine` loop (~L344-366) and `paintUnit`: when
   `vt.isHidden(byte_idx)`, `continue` without calling `emitGlyph`/advancing `sx`.
   `resolveCp` loses its `' '` branch; keep it for `substitute` only.
2. `src/render/view.zig:532` `buildColMap` — already correct; add a test asserting paint columns
   equal `col_map` values.
3. `src/bw_lgen.zig` — `zig_bw_lgen` viewmode path (~L2743-2795) passes `hide` through
   unchanged, so no change; but **`applySquareMarkInverse` and `applyLinearMarkInverse`
   (~L2728, ~L2844) operate on display columns** and must be recomputed against collapsed
   columns, or selection highlight will smear.
4. `src/bw_lgen.zig` — horizontal scroll (`scr` / `bw->offset`) is a display-column offset;
   verify long concealed lines scroll correctly.
5. `zig_bw_view_finish` (`src/bw_lgen.zig:860`, `skip_hidden` arg) already advances the cursor
   past hidden runs — re-check it against collapsed columns.

### 4.2.1 Prerequisite: fenced code bodies have no block context (verified bug)

The analyzers are **purely per-line**. `analyzeLineStart` recognises a fence *delimiter* line but
nothing carries "we are inside a fence body", so every markdown transform runs on code.

Reproduced against `zig-out/bin/joe` (2026-08-15 build) with
`` ```python / # a comment / x = a ** b / --- / plain / ``` ``:

| Buffer line | Painted in viewmode | Wrong because |
|---|---|---|
| `# a comment` | `␠␠a comment` | `#` treated as an ATX heading marker |
| `x = a ** b` | `x = a␠␠␠␠b` | `**` treated as bold delimiters |
| `---` | `───` | treated as a thematic break |

(The closing fence *is* concealed correctly — an earlier reading to the contrary was a repaint
artifact in the probe, not a defect.)

**This must be fixed with or before Phase 1.** Today `#` becomes a space, so code stays aligned
and the damage is cosmetic. After zero-width conceal the `#` *disappears* and the line shifts
left — the editor would be actively lying about the contents of a code block.

**Resolved (R1) — mirror the table-region cache.** Add fence statics alongside the table ones
(`src/bw_lgen.zig:1227-1231`) and a `zig_bw_fence_detect` shaped like `zig_bw_table_detect`:

```zig
var vm_fence_region_start: i64 = -1;   // line of the opening fence
var vm_fence_region_end:   i64 = -1;   // line after the closing fence (exclusive)
var vm_fence_cached_for_line: i64 = -1;
var vm_fence_no_region_line:  i64 = -1; // negative cache, as tables do
var vm_fence_char: u8 = 0;             // '`' or '~'
var vm_fence_len:  c_int = 0;          // opening run length; closing must be >=
```

Detection scans backward from `buf_line` over the same `P` pointer the table detector uses,
bounded by the existing `±10`-line window convention, and caches both hits and misses. Reset the
statics in `zig_bw_vm_prepare` when `vm_last_bw` changes, exactly as the table fields are.

Wiring in `zig_bw_lgen_view` (`src/bw_lgen.zig:958`), between step 1 and step 2:

- `buf_line == vm_fence_region_start` or `== vm_fence_region_end - 1` → fence delimiter line;
  keep today's marker conceal.
- `vm_fence_region_start < buf_line < vm_fence_region_end - 1` → **body**: skip
  `zig_bw_view_line_start`, `zig_bw_view_table_hl`, and `zig_bw_view_inline` entirely; build
  `col_map` from raw bytes and return. No hide, no substitute, no link URLs.
- Otherwise → today's path.

Indented (4-space) code blocks need the same guard; they are cheaper — a single line-start test,
no region scan — so handle them as an early bail in `zig_bw_view_line_start`.

**Rejected alternative:** reusing the `md.jsf` DFA, which already distinguishes
`fence_bt_body` / `fence_tl_body` / `indented_code` (`syntax/md.jsf:442,481,517`). It would be
O(1) instead of a backward scan, and `zig_bw_lgen_view_entry` already has the parse state in
hand. But `attr_buf` carries *hybrid attribute ints*, not class identities, so "is this
`MdCodeBlock`" can only be answered by comparing against scheme-dependent colour values — fragile
across the 9 palettes. Matching on DFA state names would need `high_syntax`'s state table
exposed, which is new surface. Revisit as an optimisation once state names are reachable; the
region cache is the low-risk choice today because it copies code already proven by the soak.

### 4.3 Test migration is part of the work, not an afterthought

`tests/viewmode.py` has **125 tests, of which 62 assert the space-padded layout**. Collapsing
conceal invalidates all 62. They must be rewritten in the same commit, and the soak gate number
in `AGENTS.md` (197) updated to whatever the new total is. Any plan step that claims "soak
green" without budgeting for this is wrong.

Suggested approach: convert the affected assertions to the collapsed expectation
(`"Heading One"` at `x=0`), and add a paired `assertTextAt` for the *edit* mode of the same
fixture to pin that source stays byte-faithful.

**Link tests change twice.** Phase 1 collapses them (`"Click here http://example.com"`), then
Phase 2 conceals the destination (`"Click here"`). To avoid rewriting them twice, either land the
link cases directly at their Phase 2 expectation and gate that block until Phase 2, or accept the
churn on the ~8 link tests. Prefer the latter — a test that passes for the wrong reason in
between is worse than a second edit.

---

## 5. Line-grid constraint (decide before Phase 3)

JOE's paint is **one buffer line = one screen row**. `buf_line = top_line + y - win_y` is
assumed throughout `src/bw_lgen.zig` (e.g. L1487, L1694, L1823), by cursor mapping, by scrolling,
and by every `col_map` consumer.

Three OpenCode behaviors break that identity:

| Behavior | Effect on row count | Verdict |
|---|---|---|
| `conceal_lines ""` on fence + info lines | removes rows | **out of scope** — keep fence lines, conceal the markers in place (current behavior) |
| `marginBottom: 1` between blocks | inserts rows | **out of scope** for now; tracked as old task 2.3, revisit only behind a proven line↔row mapping |
| Wrapped table cells / word wrap | inserts rows | **out of scope** (old 2.2.6) |

Everything else in §3 is achievable **within** the line grid:

- zero-width conceal (§4) — shortens rows, never removes them
- all colors and attributes (§6)
- blockquote left bar via `substitute` `│` (already shipped) — visually equal to OpenCode's
  left border at 1-column width
- thematic break via `substitute` `─` across the row (already shipped)
- list-marker normalisation to `-` / right-aligned `N.` via `substitute` + `hide`
- table grid via the existing `src/render/table.zig` padded painter

**Decision: JOE targets OpenCode's *visual vocabulary* at line-grid fidelity.** Block margins
and line removal are explicitly not attempted. Say so in the user docs so the difference is a
documented choice rather than a bug.

---

## 6. Visual target — exact tokens

Colors are `opencode.json` → `dark.overrides`; attributes are `getSyntaxRules()` in
`packages/tui/src/theme/index.ts`.

| Construct | Scope | Color | Attrs |
|---|---|---|---|
| Body text | `markup` default | `markdownText` `#eeeeee` | — |
| H1 | `markup.heading.1` | `markdownHeading` `#9d7cd8` | **bold + underline** |
| H2–H6 | `markup.heading.2..6` | `markdownHeading` `#9d7cd8` | bold |
| Bold | `markup.bold` / `markup.strong` | `markdownStrong` `#f5a742` | bold |
| Italic | `markup.italic` | `markdownEmph` `#e5c07b` | italic |
| Strikethrough | `markup.strikethrough` | (no explicit rule; use muted `#808080`) | strike if available |
| Inline code | `markup.raw.inline` | `markdownCode` `#7fd88f` | bg = theme background |
| Fenced code body | `markup.raw.block` | `markdownCodeBlock` `#eeeeee` | — (no bg tint) |
| Fence info string | `label` | `markdownLinkText` `#56b6c2` | — |
| Link label | `markup.link.label` | `markdownLinkText` `#56b6c2` | **underline** |
| Autolink / bare URL | `markup.link.url` | `markdownLink` `#fab283` | **underline** |
| Link URL (bracketed) | `markup.link.url` | — | **concealed in view** (§3.2); `markdownLink` `#fab283` in *edit* mode |
| Link brackets | `markup.link` | — | concealed in view; `MdDelim` in edit mode |
| Bullet list marker | `markup.list` | `markdownListItem` `#fab283` | — |
| Ordered list number | `markup.list` | `markdownListEnumeration` `#56b6c2` | — |
| Blockquote | `markup.quote` | `markdownBlockQuote` `#e5c07b` | **italic** |
| Blockquote bar / HR / table border | `conceal` | muted `#808080` | — |
| Thematic break | `punctuation.special` | `markdownHorizontalRule` `#808080` | — |
| Table header cell | `markup.heading` | `markdownHeading` `#9d7cd8` | bold |
| Table pipes / delimiter row | `punctuation.special` | muted `#808080` | — |
| Image alt | `markup.link.label` | `markdownImageText` `#56b6c2` | — |
| Image URL | `markup.link.url` | `markdownImage` `#fab283` | — (concealed anyway) |

Note `markdownLink` (`#fab283`) and `markdownListEnumeration` (`#56b6c2`) were **absent** from
the previous revision of this table.

### 6.1 Current JOE token inventory (Phase 0.2, done)

`syntax/md.jsf` defines: `MdH1`–`MdH6`, `MdBold`, `MdItalic`, `MdBoldItalic`, `MdStrike`,
`MdCode`, `MdCodeBlock`, `MdCodeFence`, `MdBlockquote`, `MdList`, `MdRule`, `MdLinkText`,
`MdLinkUrl`, `MdImageAlt`, `MdTableHeader`, `MdTableSeparator`, `MdTableBody`, `MdTableAlign`,
`MdDelim`, `MdEscape`.

Gaps against §6:

- **No `MdText`** (explicit body color), **no `MdListEnum`** (ordered-list numbering),
  **no `MdImageUrl`**. These three are the only genuinely new classes — see R4.
- `MdDelim` exists and is the natural home for *edit-mode* delimiter styling.
- **Only 2 of 9 color schemes define any `Md*` token.** `colors/default.jcf` (16-color) and
  `colors/gruvbox.jcf` have them; `ir_black`, `molokai`, `solarized`, `wombat`, `xoria`,
  `zenburn`, `zenburn-hc` have **none** and fall through to `Idle`. Resolved in §6.2 with a
  template plus per-scheme values for all nine.

---

## 6.2 Resolved (R3) — palettes for all 9 schemes

OpenCode uses only **eight** distinct markdown colors and reuses them across constructs
(`markdownLink` = `markdownListItem` = `markdownImage`; `markdownLinkText` =
`markdownListEnumeration` = `markdownImageText`). JOE adopts the same eight-slot structure, so
each scheme fills eight values instead of twenty-two.

### 6.2.1 The block, written once

Substitute the slot names from the table in §6.2.2. Attributes are fixed across all schemes —
only the colors vary.

```
=MdText			TEXT
=MdH1			HEAD bold underline
=MdH2			HEAD bold
=MdH3			HEAD bold
=MdH4			HEAD bold
=MdH5			HEAD bold
=MdH6			HEAD bold
=MdBold			STRONG bold
=MdItalic		EMPH italic
=MdBoldItalic		STRONG bold italic
=MdStrike		MUTED dim
=MdCode			CODE
=MdCodeBlock		CODE
=MdCodeFence		MUTED dim
=MdBlockquote		EMPH italic
=MdList			LINK
=MdListEnum		LINKTEXT
=MdRule			MUTED
=MdLinkText		LINKTEXT underline
=MdLinkUrl		LINK underline
=MdImageAlt		LINKTEXT bold
=MdImageUrl		LINK
=MdTableHeader		HEAD bold
=MdTableSeparator	MUTED dim
=MdTableBody
=MdTableAlign		MUTED dim
=MdDelim		MUTED dim
=MdEscape		MUTED
```

`MdTableBody` stays empty on purpose — table cell text inherits body text.

Every scheme with two sections (`.colors 256` and `.colors *`) needs this block **in both**,
with that section's values. Exceptions: `default.jcf` is 16-colour only, `xoria.jcf` is 256 only,
and **`solarized.jcf` needs the block only once per section but with identical text**, because it
defines the same `.set` names in both — write `[violet]`, `[orange]`, … and it resolves correctly
in each.

### 6.2.2 Slot values per scheme

Derived from each scheme's existing class colors so markdown stays internally consistent with the
rest of the theme rather than importing OpenCode's hues wholesale.

| Scheme | Section | TEXT | HEAD | STRONG | EMPH | CODE | LINK | LINKTEXT | MUTED |
|---|---|---|---|---|---|---|---|---|---|
| `default` | 16 | *(empty)* | `magenta` | `yellow` | `yellow` | `cyan` | `magenta` | `cyan` | `dim` |
| `gruvbox` | 256 | `[fg]` | `[light_purple]` | `[light_orange]` | `[light_yellow]` | `[light_green]` | `[light_orange]` | `[light_blue]` | `[light_gray]` |
| `gruvbox` | `*` | `[fg]` | `[light_purple]` | `[light_orange]` | `[light_yellow]` | `[light_green]` | `[light_orange]` | `[light_blue]` | `[light_gray]` |
| `ir_black` | 256 | `255` | `207` | `223` | `229` | `155` | `223` | `146` | `244` |
| `ir_black` | `*` | `$f6f3e8` | `$FF73FD` | `$FFD2A7` | `$FFFFB6` | `$A8FF60` | `$FFD2A7` | `$96CBFE` | `$7C7C7C` |
| `molokai` | 256 | `231` | `141` | `208` | `186` | `148` | `208` | `81` | `239` |
| `molokai` | `*` | `$F8F8F2` | `$AE81FF` | `$ef5939` | `$E6DB74` | `$A6E22E` | `$ef5939` | `$66D9EF` | `$465457` |
| `solarized` | both | `[base0]` | `[violet]` | `[orange]` | `[yellow]` | `[green]` | `[orange]` | `[cyan]` | `[base01]` |
| `wombat` | 256 | `255` | `149` | `203` | `194` | `113` | `203` | `153` | `246` |
| `wombat` | `*` | `$f6f3e8` | `$cae682` | `$e5786d` | `$e7f6da` | `$95e454` | `$e5786d` | `$8ac6f2` | `$99968b` |
| `xoria` | 256 | `252` | `182` | `180` | `229` | `150` | `180` | `110` | `244` |
| `zenburn` | 256 | `253` | `223` | `180` | `187` | `186` | `180` | `116` | `145` |
| `zenburn` | `*` | `$dcdccc` | `$f0dfaf` | `$ffcfaf` | `$dfdfbf` | `$efef8f` | `$ffcfaf` | `$8cd0d3` | `$9f9f9f` |
| `zenburn-hc` | 256 | `253` | `223` | `180` | `187` | `186` | `180` | `116` | `145` |
| `zenburn-hc` | `*` | `$dcdccc` | `$f0dfaf` | `$ffcfaf` | `$dfdfbf` | `$efef8f` | `$ffcfaf` | `$8cd0d3` | `$9f9f9f` |

Notes on the derivations:

- `zenburn` and `zenburn-hc` share slot values; they differ only in background.
- `wombat` and `zenburn` have no purple, so HEAD borrows the scheme's own most prominent accent
  rather than forcing a hue that clashes.
- `gruvbox`'s current per-level rainbow headings (H1 yellow, H2 blue, H3 green, …) are
  **replaced** by a single HEAD colour, matching OpenCode's one-heading-colour model.
- This supersedes the existing `Md*` blocks in `default.jcf` and `gruvbox.jcf`; rewrite them from
  the template rather than patching around them.

### 6.2.3 Optional simplification — verify before relying on it

Reading `parse_color_def` (`src/colors.zig:333`), a definition appears to accept a chain of
`+Ref` references followed by a colour spec — i.e. `=MdCode +String bold` should work, which
would let the whole block be expressed as inheritance from each scheme's existing classes.

**Nothing in the tree exercises that form** (`grep` finds only bare `=X +Y`). Treat it as
unverified: try one line, and if it parses, collapse the block; if not, use the explicit values
above, which are guaranteed to work because they are the form every scheme already uses.

---

## 7. Baseline (already shipped)

Dual edit/view mode, delimiter hide/substitute, ATX headings, emphasis, strike, inline/fenced
code, blockquotes (`>`→`│`), lists/tasks, HR, padded Unicode tables, OSC 8 **emit** on link
text, `viewmode_col_map` / cursor mapping, `tests/viewmode.py` soak.

### 7.0 Provenance — the original C implementations

The baseline was first written in C on this same `markdown` branch, before the Zig port. When the
Zig code looks wrong, the C original is often the fastest way to see what was intended:

| Commit | What |
|---|---|
| `6b623285` | Markdown WYSIWYG view mode, Features 1.1–1.8 (`joe/bw.c`) |
| `e9f2166d` | Unicode box-drawing table borders |
| `620a0568` | Feature 2.2 full table layout engine — padded columns, alignment |
| `7e02b80a` | Viewmode ghost-text fixes; last commit before the Zig port took over |

`git show 620a0568 -- joe/bw.c` is the table engine as first written. Note this is also where the
`hide` → space decision (§4) was originally made — worth reading before changing it.

### 7.1 Where the live code actually is

> **Correction:** `src/render/view.zig:7` says *"Not wired into live `joe` — unit-tested only."*
> **That comment is stale.** `zig_bw_view_line_start` (`src/bw_lgen.zig:697`) binds the C-owned
> tables via `ViewTables.bindScratch` and calls `render.analyzeLineStart`. `view.zig` is live.
> Fix the comment when you next touch the file.

| Area | Path |
|---|---|
| View dispatch, table glue, OSC 8 emit | `src/bw_lgen.zig` |
| ↳ chrome sequencer | `zig_bw_lgen_view` (`src/bw_lgen.zig:958`) |
| ↳ per-line entry (read line, prepare tables, paint, cleanup) | `zig_bw_lgen_view_entry` (`:1581`) |
| ↳ line-start features | `zig_bw_view_line_start` (`:697`) |
| ↳ inline features | `zig_bw_view_inline` (`:751`) |
| ↳ cursor/col_map finish | `zig_bw_view_finish` (`:860`) |
| ↳ viewmode statics (`vm_hide`/`vm_subst`/`vm_urls`/`vm_col_map`) | `:1218-1236` |
| ↳ OSC 8 emit | `out_osc8_link` shape at `:3084-3095` |
| Hide / subst / link_url / col_map analyzers | `src/render/view.zig` |
| Padded tables | `src/render/table.zig` |
| Line paint (`resolveCp` consumer) | `src/render/lgen.zig` |
| Edit-mode DFA | `syntax/md.jsf` |
| Colors | `colors/*.jcf` |
| Toggle | `rc/joerc.in` (`^T A`) |

### 7.2 Known gaps this plan closes

- Conceal pads with spaces instead of collapsing (§4) — **the headline gap**
- `col_map` and painted columns disagree on concealed lines (§4.1)
- Styles ≠ OpenCode hierarchy/colors; 7 of 9 schemes have no markdown tokens (§6.1)
- Link destinations still visible — inline, reference, shortcut, and image (§3.2)
- No JOE-side **mouse open**; OSC 8 alone depends on the terminal
- No self-contained CommonMark-ish **event** layer (ad-hoc line scanners; `applyEmphasis` in
  `src/render/view.zig:301` is ~140 lines of hand-unrolled delimiter cases with no flanking rules)

---

## 8. Architecture

```
 buffer (raw MD)
        │
        ▼
 ┌──────────────────────────┐
 │ md_event (in-tree Zig)   │  ← koino kinds + MD4C-shaped callbacks (ideas only)
 │ enter/leave block/span   │
 └────────────┬─────────────┘
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
 ViewTables  attrs/jcf  link hit map (byte → URL)
 hide/subst  OpenCode    for OSC 8 + mouse
 col_map     tokens
    │         │         │
    └────► lgen / outatr / ttputs OSC 8 ◄──┘
                    │
            mouseup → open URL (viewmode+md)
```

- **Edit:** `md.jsf` → `attr_buf` → `lgen` (no conceal).
- **View:** events/analyzers → existing `ViewTables` + attr overrides → `lgen` / table paint.
- Prefer **line/region + carried block state** (fence/table/quote) before a full-doc AST.
- Comments may cite "follows koino node X / MD4C flag Y"; **no** `build.zig` dependency.

### 8.1 Path A vs Path B

- **Path A (live):** faithful C-ABI port; goal was zero live `joe/*.c` + soak green.
- **Path B (parallel):** idiomatic Zig (`std.posix`, slices, native screen/window).
  Unit-tested; only partially wired. Do not rip out Path A without an explicit soak plan.

---

## 9. Phases

### Phase 0 — Spec freeze ✅ (this document)

- OpenCode style matrix frozen against the reference checkout (§2, §6)
- `Md*` inventory done, including the 7 schemes with no tokens (§6.1)
- Conceal semantics documented (§3); link decision corrected (§3.2)
- Line-grid constraint decided (§5)

### Phase 1 — Zero-width conceal (§4) — **do this first**

The foundation for everything visual. Nothing else looks like OpenCode until this lands.

1. Change `hide` from space-padding to zero width in `src/render/lgen.zig`.
2. Reconcile mark-inverse (linear + square) and horizontal scroll with collapsed columns.
3. Assert `col_map[i]` equals the actual painted column for every visible byte.
4. Rewrite the 62 affected `tests/viewmode.py` assertions; update the soak count in `AGENTS.md`.

Ship this alone. Do not bundle style changes into the same commit — the test churn is already
large enough to hide a regression.

### Phase 2 — Conceal coverage (§3.1) + link destinations (§3.2)

- Inline `[a](u)` and `[a](u "title")` → `a`: conceal brackets, destination, and title.
- Reference `[a][r]`, collapsed `[a][]`, shortcut `[a]` → `a`.
- Image `![alt](u)` → `alt` only (still no image chrome; see roadmap 2.6).
- Autolinks and bare URLs stay visible and styled — do **not** conceal (§3.2).
- HTML entity substitutions (`&nbsp;`, `&lt;`, `&gt;`, `&amp;`, `&quot;`, `&ensp;`, `&emsp;`).
- List markers: normalise `*`/`+`/`-` → `-`; right-align ordered `N.` to the list's widest marker.
- Attach `link_url` / OSC 8 to the surviving **label** cells (the URL cells no longer exist).

### Phase 3 — OpenCode style mapping (§6)

- Retarget six `md.jsf` states per R4; add `MdText`, `MdListEnum`, `MdImageUrl` (no `MdConceal`).
- Expand the §6.2.1 template with the §6.2.2 values into **all 9** `colors/*.jcf`, both sections.
- View attrs: H1 bold+underline; H2–H6 bold; strong bold; emph italic; quote italic; link label
  and URL underlined.
- Degrade truecolor → 256 → 16 → attributes; verify each `Md*` stays legible at 16 colors.
- Edit mode: delimiters and URLs stay visible; soft-align highlight to the same palette.

### Phase 4 — In-tree `md_event` layer

- Add `src/render/md_event.zig` (+ unit tests): MD4C-shaped enter/leave block/span/text callbacks.
- Taxonomy from koino study: Heading, Emph, Strong, Strikethrough, Code, CodeBlock, Link,
  List/Item/Task, BlockQuote, ThematicBreak, Table/*, Text, breaks; **Image = ignore**.
- Migrate `view.zig` scanners (notably `applyEmphasis`) to events where it fixes nesting,
  flanking, and autolink bugs.
- Keep `table.zig` as the layout backend; events mark table structure.
- Nested language highlighting in fences stays deferred (`future-roadmap` 2.5).

### Phase 5 — Clickable links (OSC 8 + mouse)

- Harden OSC 8 emit (C0/C1 strip already present at `src/terminal/screen.zig:1438`).
- Hit-test display cell → buffer byte → URL, using the collapsed `col_map` from Phase 1.
- **Hook point:** `udefmup` (`src/mouse.zig:1246`). A *simple click* is `mouseup` with
  `selecting == 0`; drag sets `selecting = 1` in `udefmdrag` (`:1170`). Do not touch
  `udefm3up`/right-click (paste) or the wheel bindings.
- Spawn: precedent exists (`src/ublock.zig:1323`, `src/gapbuffer/fileio.zig:530`).
  **Use `execlp` with argv directly — never `/bin/sh -c` with the URL interpolated**, or a
  crafted `[x](http://a;rm -rf ~)` in an opened file becomes command execution. Also reject URLs
  whose scheme is not `http`/`https`/`mailto`/`file`.
- macOS `open`, Linux `xdg-open`; fork + `_exit` on failure, never block the editor.
- Optional rc/help note (click + terminal Cmd/Ctrl-click).

### Phase 6 — Scoped CM/GFM gaps

Priority: autolinks/bare URLs → setext headings → table header weight. **Not in scope:**
images, footnotes, raw HTML, math, nested fence HL, block margins, line removal (§5).

### Phase 7 — Docs & gate

- Keep this file + `TODO.md` current; brief `AGENTS.md` blurb.
- Document the deliberate deviations from OpenCode (§5) in `docs/` so they read as choices.
- `./runtests` green at the updated count.

**Ship order:** 1 → 2 → 3 → 5 for user-visible gains; 4 in parallel once conceal is stable;
then 6–7.

---

## 9.1 Resolutions

All six items previously left open are decided below. Nothing in this plan is now "to be
determined."

| # | Item | Resolution | Where |
|---|---|---|---|
| R1 | Fence / indented-code block state | Mirror the table-region cache; skip all analyzers in a fence body. DFA-state alternative rejected with reasons | §4.2.1 |
| R2 | Reference-link definition lookup | Two tiers — no cache. See R2 below | here |
| R3 | Palettes for the 7 unstyled schemes | Eight-slot template + per-scheme value table for all 9 | §6.2 |
| R4 | `md.jsf` rules for the new classes | Six state retargets, three new classes; `MdConceal` dropped | R4 below |
| R5 | Cursor on a concealed byte | Cursor never rests on a concealed byte; rules below | R5 below |
| R6 | Ordered-list right-alignment | **Dropped.** Left-align as authored | R6 below |

### R2 — reference-link destinations: resolve lazily, cache nothing

`[a][r]` conceals correctly per-line; only *resolving* `r` to a URL needs the `[r]: http://…`
definition, which lives on another line. Split by cost:

- **OSC 8 emit (every paint):** inline links only, where the URL is on the line. Reference links
  get no OSC 8. Scanning the buffer per line per repaint is not affordable.
- **Click to open (once, human-initiated):** resolve on demand. Scan the buffer for
  `^[ \t]{0,3}\[<label>\]:[ \t]*<dest>`, case-insensitive on the label per CommonMark. A single
  linear scan on a mouse click is imperceptible; nothing is cached, so nothing can go stale.

This deliberately avoids a definition cache and its invalidation problem. If profiling later
shows the click scan matters on very large buffers, add a cache keyed on the buffer's change
counter — not before.

### R4 — `md.jsf`: three retargets, and one class deleted from the plan

The DFA already has the states; they just point at the wrong classes.

| Change | Line | From | To |
|---|---|---|---|
| Ordered list digits | `syntax/md.jsf:596` | `:ordered_list MdList` | `:ordered_list MdListEnum` |
| Ordered list `.` / `)` | `:601` | `:ordered_mark Idle` | `:ordered_mark MdListEnum` |
| Image destination | `:658` | `:image_url MdLinkUrl` | `:image_url MdImageUrl` |
| Body text | `:79` | `:idle Idle` | `:idle MdText` |
| Line start | `:64` | `:line_start Idle` | `:line_start MdText` |
| List item text | `:589` | `:list_content Idle` | `:list_content MdText` |

Both `:ordered_list` and `:ordered_mark` must change, or the digits and the `.` get different
colours — `recolor=-1` applies the *entering* state's class.

**`MdConceal` is dropped.** It was specified as a shared muted colour for the blockquote bar, the
horizontal rule, and table borders. It is unnecessary:

- blockquote bar → already `MdBlockquote`
- horizontal rule → already `MdRule`
- table grid → use the existing `MdTableSeparator`, which is already the muted/dim class in every
  themed scheme

Concealed bytes emit nothing after Phase 1, so they need no colour at all. Only `MdText`,
`MdListEnum`, and `MdImageUrl` are genuinely new.

### R5 — cursor never rests on a concealed byte

In viewmode, a concealed byte occupies no column, so the cursor cannot be *shown* on one. Rules:

| Motion | Behavior |
|---|---|
| Right, into a concealed run | Skip the whole run; land on the first visible byte after it |
| Left, into a concealed run | Skip the whole run; land on the last visible byte before it |
| Concealed run at end of line | Clamp to the last visible column; do not sit past it |
| Concealed run at start of line | Land on the first visible byte, i.e. column 0 |
| Whole line concealed | Column 0 |
| Up / down onto a concealed byte | Apply the *right* rule, then clamp to the line's last visible column |

`zig_bw_view_finish` (`src/bw_lgen.zig:860`) already implements the forward case via
`skip_hidden`. The backward case does not exist and must be added; the two must agree, or
left-then-right across a concealed span will not round-trip. Add that round-trip as an explicit
test.

Buffer offsets are unaffected — this is display positioning only. Edit mode keeps today's
behavior exactly.

### R6 — ordered-list right-alignment: dropped

OpenCode pads ordered markers to the widest in the list (`9.` / `10.` align on the `.`). That
needs the list's full extent — a third multi-line region, after tables and fences, for a purely
cosmetic gain on lists that cross the 9→10 boundary.

**JOE left-aligns ordered markers as authored.** Unordered normalisation to `-` stays, because it
is a single-line decision needing no region at all. Recorded as deviation 6 in the appendix.

---

## 10. Expected file touch map

| Path | Role |
|---|---|
| `plans/markdown-wysiwyg-feasibility.md` | This plan |
| `plans/TODO.md` | Checkboxes for phases above |
| `src/render/lgen.zig` | **Phase 1** — zero-width conceal in the paint loop |
| `src/render/view.zig` | Conceal analyzers; consume events; fix stale header comment |
| `src/render/md_event.zig` | New event layer (Phase 4) |
| `src/render/table.zig` | Header/style tweaks |
| `src/bw_lgen.zig` | View entry, mark-inverse vs collapsed columns, OSC 8 glue |
| `src/mouse.zig` | `udefmup` → click-to-open URL |
| `syntax/md.jsf` | Six state retargets (R4): `MdText`, `MdListEnum`, `MdImageUrl` |
| `colors/*.jcf` (**all 9**) | OpenCode-like tokens |
| `tests/viewmode.py` | 62 rewritten assertions + conceal/style/click fixtures |
| `AGENTS.md` | Updated soak count |
| `rc/joerc.in` / help | Optional click hint |

---

## 11. Testing

- Buffer integrity: viewmode never changes file bytes (keep existing asserts).
- **Column identity:** for every visible byte, painted column == `col_map[byte]`. This is the
  regression net for Phase 1 and should be a Zig unit test, not only a soak test.
- Conceal fixtures, asserted at collapsed positions:
  - `# H` → `H` at `x=0`
  - `**b**` → `b` at `x=0`
  - `[a](http://x)` → `a` — **screen must not contain `http://x`** (§3.2)
  - `[a](http://x "T")` → `a` — title concealed too
  - `[a][r]` / `[a][]` / `[a]` → `a`
  - `![alt](http://x)` → `alt`
  - `<http://x>` and bare `http://x` → **URL still visible** (the deliberate exception)
- Same fixture in **edit** mode still shows the full URL (the dual-mode contract).
- Cursor across concealed spans; `xcol` stability on up/down through a concealed line.
- Selection: linear and square mark inverse over a concealed line.
- Horizontal scroll on a long concealed line.
- Mouse open: unit-test hit-test and scheme rejection; integration via test hook if practical.
- Gate: `cp -f zig-out/bin/joe joe/joe && ./runtests`.

---

## 12. Risks

| Risk | Mitigation |
|---|---|
| **Zero-width conceal destabilises cursor/selection** | Phase 1 alone, with the column-identity test; no style changes in the same commit |
| **62 test rewrites hide a real regression** | Rewrite mechanically; add the column-identity unit test *first* so it fails loudly |
| Full CommonMark in pure Zig is large | Paint subset + grow against soak; not 671 GFM tests day one |
| Mouse-open vs selection | Click without drag only (`selecting == 0`); skip if mark/drag active |
| **URL → shell injection** | `execlp` with argv, scheme allowlist (Phase 5) |
| Weak italic/truecolor terminals | Existing attr degradation; verify all 9 schemes at 16 colors |
| Event migration regresses soak | Phase 4 behind the same `ViewTables` contract |
| OpenCode reference drifts | §2 pins exact paths; re-verify rather than trusting this doc |

---

## 13. Success criteria

1. Conceal **collapses** — no space padding; painted columns match `col_map`.
2. Viewmode matches OpenCode's visual vocabulary: colors and attrs of §6, conceal rules of §3.1.
3. **All bracketed link destinations are concealed** — `[a](u)` → `a`. No `http://` on screen for
   a labelled link. Autolinks and bare URLs stay visible.
4. Edit mode shows plain source with highlight, byte-faithful — URLs included.
5. Links work via **OSC 8** and **JOE left-click open**, with no shell injection path.
6. All 9 color schemes carry markdown tokens and degrade legibly.
7. No images; no external markdown library in the link.
8. Soak green at the updated count; buffer never mutated by viewmode.
9. Deviations from OpenCode (§3.2 link conceal, §5 line grid) are documented, not accidental.

---

## 14. Hard limits (unchanged)

- No real per-region font sizes or proportional fonts (character grid only).
- No Sixel/Kitty images in this plan.
- Smooth "document" scrolling beyond JOE's line grid is out of scope.
- One buffer line stays one screen row (§5): no block margins, no dropped fence lines,
  no wrapped table cells.

---

## Appendix — historical note

The original v2 write-up correctly chose **dual edit/view** and delimiter hiding, but targeted
deleted `joe/*.c` paths and a C-only constraint. That implementation path is obsolete: the
editor is Zig Path A. Keep old Phase 1–2 checkboxes in `TODO.md` as a completed archive; new
work uses the phases above.

The revision before this one was directionally right but under-specified in two ways that would
have caused rework: it treated `hide` as if it already collapsed (§4), and it costed the soak
gate at "197+" without accounting for the 62 assertions that encode the old layout (§4.3).

Its link-conceal decision (hide destinations) turned out to diverge from OpenCode. That was
reviewed and **kept deliberately** — see §3.2. It is a deviation, not an oversight, and it is the
one place where "match OpenCode" loses to "serve the editor use case."

### Deviations from OpenCode — complete list

| # | Deviation | Why | Section |
|---|---|---|---|
| 1 | Bracketed link destinations concealed (`a`, not `a (u)`) | Editor re-reads the same prose; inline URLs are the main visual noise | §3.2 |
| 2 | No blank-row block margins | Changes row count; breaks JOE's line grid | §5 |
| 3 | Fence lines concealed in place, not removed | Same | §5 |
| 4 | No wrapped table cells | Same | §5 |
| 5 | Task markers → `☐`/`☑`; quote → `│`; HR → `─` | Already shipped; equivalent at 1-column width | §3.1 |
| 6 | Ordered list markers left-aligned, not padded | Needs a third multi-line region for a cosmetic gain | R6 |

Anything not on this list should match OpenCode. If an implementer finds a sixth divergence,
that is a bug or a missing row here — not licence to improvise.
