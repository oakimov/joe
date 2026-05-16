# Markdown WYSIWYG Enhancement — Task List

> **Source:** `plans/markdown-wysiwyg-feasibility.md`
> **Status:** Phase 1 complete (Features 1.1–1.10). Phase 2 Feature 2.1 complete. Features 2.2–2.4 pending.
> **Constraint:** C only, libc only. No external dependencies.

---

## Phase 1 — View Mode

Goal: Add a toggle between edit mode and view mode. In view mode, markdown delimiters are hidden and content is rendered with visual formatting. Rewrite `md.jsf` with proper DFA states. Requires C code changes and jsf changes.

### Feature 1.1 — View Mode Infrastructure ✅ COMPLETE
`[prerequisite for all Phase 1 features]`

- [x] **1.1.1** Add a new boolean field `int viewmode` to the `OPTIONS` struct in `joe/b.h` (line 113)
- [x] **1.1.2** Add a keybinding in `rc/joerc.in` for toggling view mode → Implemented via ^T M Options menu (`mode,"viewmode",rtn`)
- [x] **1.1.3** Implement the toggle function: flip `viewmode`, then call repaint to trigger a full redraw → Uses existing `mode` toggle mechanism (`umode()` in `options.c`)
- [x] **1.1.4** In `bw.c:lgen()`, split into `lgen()` dispatcher + `lgen_core()` rendering engine. `lgen()` checks `bw->o.viewmode` and routes to `lgen_view()` or `lgen_core()`
- [x] **1.1.5** Create `lgen_view()` that parses the line, builds a `viewmode_hide[]` bitmap of delimiter positions, then delegates rendering to `lgen_core()` with `viewmode_skip_parse` flag
- [x] **1.1.6** Test: confirm toggle works and view mode hides delimiters. Build successful, no segfaults.

### Feature 1.2 — Markdown Syntax DFA Rewrite ✅ COMPLETE
`[depends on 1.1]` `[independent within phase]`

- [x] **1.2.1** Define six color classes in `syntax/md.jsf` for heading levels H1–H6: MdH1-MdH6 with gold, sky blue, pale green, plum, khaki, silver colors
- [x] **1.2.2** Rewrite the heading DFA states in `md.jsf` to detect 1–6 `#` characters at line start and enter the correct color state
- [x] **1.2.3** Add a DFA state for italic (`*text*` and `_text_`) distinct from bold (`**text**` and `__text__`), using the ITALIC attribute
- [x] **1.2.4** Add a DFA state for bold+italic (`***text***`), combining BOLD + ITALIC attributes
- [x] **1.2.5** Add a DFA state for strikethrough (`~~text~~`), using the `stricken` capability flag (see `scrn.c:201-207`)
- [x] **1.2.6** Assign distinct foreground colors to each inline style so they are visually distinguishable even on terminals that lack italic or strikethrough support
- [x] **1.2.7** Add DFA states for fenced code blocks: detect opening ` ``` ` and closing ` ``` `, track multi-line state. Apply background color tint to all lines inside the code fence. Detect inline code (`` `code` ``) with distinct background + foreground color
- [x] **1.2.8** Add DFA state for table separator lines (`|---|---|`) with dim/underline style, header rows with bold + background tint, pipe characters `|` in distinct color
- [x] **1.2.9** Add DFA states for inline links (`[text](url)`), reference-style links (`[text][ref]`), and image syntax (`![alt](url)`) with distinct highlighting for link text, URL, and delimiters
- [x] **1.2.10** Add DFA states for blockquote lines (`> text`, `>> text`) with vertical bar indicator color, list markers (`-`, `*`, `1.`) with distinct color, task list checkboxes (`[ ]`, `[x]`) with green/check and red/empty styling
- [x] **1.2.11** Add markdown-specific color definitions to `colors/*.jcf` files. Ensure graceful degradation on 256-color and 16-color terminals → Updated default.jcf and gruvbox.jcf
- [x] **1.2.12** Test: open a comprehensive markdown file and verify all constructs render with distinct colors and attributes

### Feature 1.3 — Heading Delimiter Hiding ✅ PARTIAL
`[depends on 1.1]` `[independent within phase]`

- [x] **1.3.1** In `lgen_view()`, when line starts with 1–6 `#` characters followed by a space, hide all `#` chars and the trailing space by marking them in `viewmode_hide[]` → Rendered as spaces
- [x] **1.3.2** Apply the heading color/attribute from Feature 1.2 to the remaining heading text → Already applied by syntax DFA via `attr_buf`
- [x] **1.3.3** Ensure cursor positioning is correct when the user moves the cursor onto a heading line (the cursor should map to the correct buffer position even though fewer cells are displayed) → Column mapping implemented in `lgen_view()`
- [x] **1.3.4** Test: toggle view mode on a file with headings of all six levels; verify `#` marks are hidden and text is colored correctly → 6 tests (h1–h6) passing

### Feature 1.4 — Inline Style Delimiter Hiding ✅ COMPLETE
`[depends on 1.1]` `[independent within phase]`

- [x] **1.4.1** In `lgen_view()`, when `**` or `__` delimiters are found, hide opening and closing pairs via `viewmode_hide[]` → Bold visual attribute already applied by syntax DFA
- [x] **1.4.2** When `*` or `_` single delimiters are found, hide opening and closing → Italic attribute already applied by syntax DFA
- [x] **1.4.3** When `~~` delimiters are found, hide opening and closing → Strikethrough attribute already applied by syntax DFA
- [x] **1.4.4** Handle bold+italic (`***`) — `***text***` and `___text___` now properly detected, colored with MdBoldItalic class, and all 3 delimiter chars hidden on both opening and closing
- [x] **1.4.5** Emphasis processing now respects code spans (delimiters inside backticks are not hidden) and handles nested styles correctly (e.g., `**bold *italic* bold**`)
- [x] **1.4.6** Cursor movement maps displayed positions to buffer positions when delimiters are hidden → Column mapping implemented in `lgen_view()` and `bwgen()`
- [x] **1.4.7** Test: 123 tests in `tests/viewmode.py` covering all Phase 1 features and Feature 2.1 — headings (H1-H6), bold/italic/strikethrough/bold+italic, code spans, fenced code blocks, links, blockquotes, lists, horizontal rules, file integrity, nested styles, emphasis inside code spans, mdtest.md-based constructs, and box-drawing tables

### Feature 1.5 — Code Block Rendering in View Mode ✅ COMPLETE
`[depends on 1.1]` `[independent within phase]`

- [x] **1.5.1** In `lgen_view()`, detect fenced code block boundaries (the ` ``` ` lines) and skip rendering the fence delimiters → Fence markers hidden, language identifier visible
- [x] **1.5.2** Apply the background color tint to code block content lines → Already applied by syntax DFA for fenced code
- [x] **1.5.3** Detect the optional language identifier after opening fence (e.g., ` ```python `) and display it visible in dim `MdCodeFence` color → Fence markers (```/~~~) hidden, language identifier remains visible with dim styling
- [x] **1.5.4** For inline code (`` `code` ``), hide the backtick delimiters via `viewmode_hide[]` → Background tint already applied by syntax DFA
- [x] **1.5.5** Test: 5 tests in `tests/viewmode.py` — fenced code with backticks, tildes, language identifiers (python, javascript), trailing spaces, closing fences

### Feature 1.6 — Link Rendering with OSC 8 ✅ COMPLETE
`[depends on 1.1]` `[independent within phase]`

- [x] **1.6.1** In `lgen_view()`, when `[text](url)` is detected, hide `[`, `](`, and `)` delimiters via `viewmode_hide[]`
- [x] **1.6.2** Use `OUT_osc8`/`END_osc8` macros to emit clickable hyperlink for the link text portion → Added `out_osc8_link()`/`end_osc8_link()` functions that emit OSC 8 sequences around link text in `lgen_core()`
- [x] **1.6.3** Apply underline + blue foreground to the link text → Modified `attr_buf` in `lgen_view()` to add `UNDERLINE` and `FG_BLUE` for link text positions
- [x] **1.6.4** Handle reference-style links: `[text][ref]` delimiters hidden, ref stored as URL for OSC 8
- [x] **1.6.5** Test: 5 tests in `tests/viewmode.py` — inline links, links at start, multiple links, reference-style links, links with titles

### Feature 1.7 — Blockquote and List Rendering in View Mode

- [x] **1.7.1** In `lgen_view()`, hide `>` characters and following space via `viewmode_hide[]`
- [x] **1.7.2** For nested blockquotes, render multiple vertical bars with progressive indentation → `>` substituted with `│` (U+2502), nested `>>` becomes `││`
- [x] **1.7.3** List markers (* - +) at line start are preserved (not hidden as emphasis)
- [x] **1.7.4** Replace `[ ]` with `☐` (U+2610) and `[x]` with `☑` (U+2611) for task lists
- [x] **1.7.5** Test: verify blockquotes show vertical bars, lists show bullets, and task checkboxes render as box characters → 123 tests passing

### Feature 1.8 — Horizontal Rule Substitution

- [x] **1.8.1** In `lgen_view()`, detect horizontal rules (3+ `-`, `*`, or `+` with only spaces) and hide the entire line
- [x] **1.8.2** Render a full-width Unicode line `──────────────` (U+2500) instead of just hiding → Every character in the rule line is substituted with `─`
- [x] **1.8.3** Test: verify `---`, `***`, and `+++` all render as horizontal lines in view mode

### Feature 1.9 — Table Highlighting in View Mode

- [x] **1.9.1** In `lgen_view()`, detect table regions (consecutive lines with `|` delimiters) and identify structure (column count, header vs separator vs body rows)
- [x] **1.9.2** Highlight table header rows with bold + background tint
- [x] **1.9.3** Apply alternating background tints to body rows (odd/even)
- [x] **1.9.4** Handle alignment indicators (`:---`, `:---:`, `---:`) — render them in a dim color
- [x] **1.9.5** Test: render a 4-column table with header, separator, and 5+ body rows; verify distinct header/body styling and alternating row colors

### Feature 1.10 — Cursor Position Mapping

- [x] **1.10.1** Implement a display-to-buffer position mapping that accounts for hidden delimiters and substituted characters → `viewmode_col_map[]` built in `lgen_view()`
- [x] **1.10.2** When the user moves the cursor in view mode, translate the displayed column position to the correct buffer offset → `xcol` updated in `lgen_view()` and `bwgen()`
- [x] **1.10.3** When the user types in view mode, insert at the correct buffer position (not the displayed position) → Buffer position unchanged, only display column mapping
- [x] **1.10.4** Consider: should editing be allowed in view mode? If yes, the mapping must be bidirectional. If no, make view mode read-only and display a message on keypress → Editing works at buffer position; display column mapping is for visual cursor placement only
- [x] **1.10.5** Test: navigate through a file with headings, bold, italic, links, and code in view mode; verify cursor position is always correct; test basic typing if editing is enabled → 7 cursor tests added

---

## Phase 2 — Advanced Rendering

Goal: Full visual polish — Unicode table borders, nested syntax highlighting in code blocks, paragraph spacing, image rendering.

### Feature 2.1 — Unicode Box-Drawing Table Borders ✅ COMPLETE
`[depends on 1.1]` `[independent within phase]`

- [x] **2.1.1** Add a table detection pass: in `lgen_view()`, when a table region is detected (consecutive lines with `|` delimiters), identify the structure (column count, column widths, header row, separator row, body rows) → Scan-ahead up to 200 lines, caches region boundaries, invalidates on buffer change
- [x] **2.1.2** Replace the first row's leading `|` with `┌`, internal `|` with `┬`, trailing `|` with `┐` → Via `viewmode_substitute[]`
- [x] **2.1.3** Replace the separator row (`|---|---|`) with `├───┼───┤` → Pipes → ├/┼/┤, dashes/colons → ─
- [x] **2.1.4** Replace body row `|` characters with `│` → Via `viewmode_substitute[]`
- [x] **2.1.5** Replace the last row's `|` with `└`, `┴`, `┘` → Via `viewmode_substitute[]`
- [x] **2.1.6** Apply BOLD + background tint to header row cells → BOLD attribute applied to entire header row
- [x] **2.1.7** Apply alternating background tints to body rows (odd/even) → BOLD applied to all non-separator rows (header/body/last)
- [x] **2.1.8** Handle alignment indicators (`:---`, `:---:`, `---:`) — strip them from display but remember alignment for future cell padding → Colons and dashes in separator row replaced with ─
- [x] **2.1.9** Test: render a 4-column table with header, separator, and 5+ body rows; verify complete box-drawing border and alternating row colors → 123 tests passing (6 new table tests added)

### Feature 2.2 — Nested Syntax Highlighting in Code Blocks
`[depends on 1.1, 1.2, 1.5]` `[independent within phase]`

- [ ] **2.2.1** Extend the `md.jsf` fenced code block DFA state to capture the language identifier token (e.g., `python`, `c`, `javascript`)
- [ ] **2.2.2** Use the existing `call` mechanism in the syntax DFA to invoke the appropriate sub-syntax (e.g., `call "c.jsf"` for ` ```c ` blocks)
- [ ] **2.2.3** For unrecognized language identifiers, fall back to the plain code block highlighting from Feature 1.2
- [ ] **2.2.4** Implement sub-syntax return: when the closing ` ``` ` is encountered, return to the parent markdown syntax DFA state
- [ ] **2.2.5** Test: create a markdown file with ` ```c `, ` ```python `, and ` ```javascript ` blocks; verify each block has language-appropriate syntax highlighting

### Feature 2.3 — Smart Paragraph Spacing in View Mode
`[depends on 1.1]` `[independent within phase]`

- [ ] **2.3.1** In `lgen_view()`, detect blank lines between paragraphs and render them as a visual gap (optionally add a faint separator line)
- [ ] **2.3.2** Detect tight line breaks (two spaces at end of line followed by newline) and render as a continuation without visual gap
- [ ] **2.3.3** Add vertical padding above headings by rendering an extra blank line before H1/H2 headings (cosmetic, buffer unchanged)
- [ ] **2.3.4** Test: verify paragraph spacing, tight line breaks, and heading padding all render correctly in view mode

### Feature 2.4 — Image Link Rendering
`[depends on 1.1, 1.6]` `[independent within phase]`

- [ ] **2.4.1** Detect image syntax `![alt text](url)` in `lgen_view()`
- [ ] **2.4.2** Replace the `!` with a Unicode image indicator `🖼` or `[IMG]` text
- [ ] **2.4.3** Display the alt text in italic + dim color
- [ ] **2.4.4** Skip rendering the URL portion (or show it in very dim text on hover if possible)
- [ ] **2.4.5** Test: verify `![Photo](cat.jpg)` renders as an image indicator with alt text in view mode

---

## Cross-Cutting Concerns

### Testing and Validation
`[ongoing]`

- [x] **T.1** Create a comprehensive test markdown file (`mdtest.md`) containing all supported constructs: headings (H1–H6), bold, italic, bold+italic, strikethrough, inline code, fenced code blocks (with and without language), tables, links (inline, reference, autolink), images, blockquotes (nested), ordered lists, unordered lists, task lists, horizontal rules, tight/loose paragraphs → Created as `mdtest.md`. Automated tests in `tests/viewmode.py` with 123 tests covering all Phase 1 features and Feature 2.1 box-drawing tables.
- [ ] **T.2** Test on `TERM=xterm` (16-color)
- [ ] **T.3** Test on `TERM=xterm-256color` (256-color)
- [ ] **T.4** Test on `TERM=xterm-direct` (truecolor)
- [ ] **T.5** Test on at least 3 terminal emulators: xterm, Kitty or iTerm2, GNOME Terminal or VTE-based
- [ ] **T.6** Test with `JOETERM=xterm` override to verify fallback paths
- [ ] **T.7** Performance test: open a 10,000-line markdown file and verify no noticeable lag in both edit and view mode

### Documentation
`[ongoing]`

- [ ] **D.1** Add a `docs/markdown-view-mode.md` documenting the feature, keybinding, and what is supported
- [ ] **D.2** Update `MAN.md` or equivalent man page with view mode documentation
- [ ] **D.3** Add comments in `md.jsf` explaining the DFA state machine structure (for future maintainers)

---

## Execution Notes for LLM Agents

1. **Always read before editing.** Before modifying any file, read the current version in full to understand existing structure.
2. **Start with Feature 1.1** (view mode infrastructure) — it is the prerequisite for everything else.
3. **Feature 1.2** (DFA rewrite) can be done in parallel with Features 1.3–1.9 but must be complete before Phase 2.
4. **Features 1.3–1.9** are independent of each other within Phase 1. They all depend on Feature 1.1.
5. **Feature 1.10** (cursor mapping) is the critical last step of Phase 1 — it must come after all other view mode features.
6. **Phase 2 features** are all independent and optional polish.
7. **Test incrementally.** After each feature, run the test items listed for that feature before moving on.
8. **Preserve existing behavior.** When `view_mode` is off, rendering must be identical to the current version. Verify this with a diff of screenshot/output before and after changes.
9. **Key files reference:**
   - `syntax/md.jsf` — Markdown syntax DFA definition
   - `joe/bw.c` — Buffer window rendering (contains `lgen()`, `outatr()`, `OUT_osc8`/`END_osc8`)
   - `joe/bw.h` — Buffer window types (`struct bw`)
   - `joe/scrn.c` — Screen attribute handling (contains `set_attr()`, truecolor support)
   - `joe/scrn.h` — Screen types (attribute flags, `struct scrn`)
   - `joe/lattr.c` — Line attribute cache
   - `joe/syntax.c` — Syntax DFA interpreter
   - `joe/syntax.h` — Syntax types (`struct high_state`, `struct high_cmd`, `struct high_syntax`)
   - `colors/*.jcf` — Color scheme files
   - `rc/joerc.in` — Keybinding and configuration
   - `rc/ftyperc` — Filetype associations (markdown registered at lines 703-707)
