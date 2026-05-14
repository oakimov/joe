# Markdown WYSIWYG Enhancement — Task List

> **Source:** `plans/markdown-wysiwyg-feasibility.md`
> **Status:** Phase 1 Features 1.1–1.8 infrastructure complete (viewmode toggle, DFA rewrite, delimiter hiding for headings/bold/italic/code/fences/blockquotes/rules/links). Features 1.9 (tables) and 1.10 (cursor mapping) pending. Phase 2 not started.
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
- [ ] **1.3.3** Ensure cursor positioning is correct when the user moves the cursor onto a heading line (the cursor should map to the correct buffer position even though fewer cells are displayed) → Currently cursor still sees spaces where delimiters were
- [ ] **1.3.4** Test: toggle view mode on a file with headings of all six levels; verify `#` marks are hidden and text is colored correctly

### Feature 1.4 — Inline Style Delimiter Hiding ✅ PARTIAL
`[depends on 1.1]` `[independent within phase]`

- [x] **1.4.1** In `lgen_view()`, when `**` or `__` delimiters are found, hide opening and closing pairs via `viewmode_hide[]` → Bold visual attribute already applied by syntax DFA
- [x] **1.4.2** When `*` or `_` single delimiters are found, hide opening and closing → Italic attribute already applied by syntax DFA
- [x] **1.4.3** When `~~` delimiters are found, hide opening and closing → Strikethrough attribute already applied by syntax DFA
- [ ] **1.4.4** Handle bold+italic (`***`) — currently `**` pair hides first two `*`, third `*` hides as single italic. Not fully correct for `***text***` pattern
- [ ] **1.4.5** Ensure cursor movement correctly maps displayed positions to buffer positions when delimiters are hidden → Currently cursor sees spaces
- [ ] **1.4.6** Test: toggle view mode on a file with various inline styles; verify delimiters vanish and text attributes appear; verify cursor navigation works correctly

### Feature 1.5 — Code Block Rendering in View Mode ✅ PARTIAL
`[depends on 1.1]` `[independent within phase]`

- [x] **1.5.1** In `lgen_view()`, detect fenced code block boundaries (the ` ``` ` lines) and skip rendering the fence delimiters → Fence lines fully hidden in viewmode
- [x] **1.5.2** Apply the background color tint to code block content lines → Already applied by syntax DFA for fenced code
- [ ] **1.5.3** Detect the optional language identifier after opening fence (e.g., ` ```python `) and display it as a small label in a dim color at the start of the block
- [x] **1.5.4** For inline code (`` `code` ``), hide the backtick delimiters via `viewmode_hide[]` → Background tint already applied by syntax DFA
- [ ] **1.5.5** Test: toggle view mode on a file with fenced and inline code; verify fences are hidden, code has background tint, language labels appear

### Feature 1.6 — Link Rendering with OSC 8
`[depends on 1.1]` `[independent within phase]`

- [x] **1.6.1** In `lgen_view()`, when `[text](url)` is detected, hide `[`, `](`, and `)` delimiters via `viewmode_hide[]`
- [ ] **1.6.2** Use `OUT_osc8`/`END_osc8` macros to emit clickable hyperlink for the link text portion
- [ ] **1.6.3** Apply underline + blue foreground to the link text (currently uses DFA colors)
- [ ] **1.6.4** Handle reference-style links: resolve `[text][ref]` by looking up the reference definition elsewhere in the buffer
- [ ] **1.6.5** Test: in a terminal that supports OSC 8, open a markdown file, toggle view mode, and click a link

### Feature 1.7 — Blockquote and List Rendering in View Mode
`[depends on 1.1]` `[independent within phase]`

- [x] **1.7.1** In `lgen_view()`, hide `>` characters and following space via `viewmode_hide[]`
- [ ] **1.7.2** For nested blockquotes, render multiple vertical bars with progressive indentation → Currently just hides all > chars
- [x] **1.7.3** List markers (* - +) at line start are preserved (not hidden as emphasis)
- [ ] **1.7.4** Replace `[ ]` with `☐` (U+2610) and `[x]` with `☑` (U+2611) for task lists
- [ ] **1.7.5** Test: verify blockquotes show vertical bars, lists show bullets, and task checkboxes render as box characters

### Feature 1.8 — Horizontal Rule Substitution
`[depends on 1.1]` `[independent within phase]`

- [x] **1.8.1** In `lgen_view()`, detect horizontal rules (3+ `-`, `*`, or `+` with only spaces) and hide the entire line
- [ ] **1.8.2** Render a full-width Unicode line `──────────────` (U+2500) instead of just hiding → Currently just hides the rule characters
- [ ] **1.8.3** Test: verify `---`, `***`, and `+++` all render as horizontal lines in view mode

### Feature 1.9 — Table Highlighting in View Mode
`[depends on 1.1]` `[independent within phase]`

- [ ] **1.9.1** In `lgen_view()`, detect table regions (consecutive lines with `|` delimiters) and identify structure (column count, header vs separator vs body rows)
- [ ] **1.9.2** Highlight table header rows with bold + background tint
- [ ] **1.9.3** Apply alternating background tints to body rows (odd/even)
- [ ] **1.9.4** Handle alignment indicators (`:---`, `:---:`, `---:`) — render them in a dim color
- [ ] **1.9.5** Test: render a 4-column table with header, separator, and 5+ body rows; verify distinct header/body styling and alternating row colors

### Feature 1.10 — Cursor Position Mapping
`[depends on 1.3–1.9]` `[critical]`

- [ ] **1.10.1** Implement a display-to-buffer position mapping that accounts for hidden delimiters and substituted characters
- [ ] **1.10.2** When the user moves the cursor in view mode, translate the displayed column position to the correct buffer offset
- [ ] **1.10.3** When the user types in view mode, insert at the correct buffer position (not the displayed position)
- [ ] **1.10.4** Consider: should editing be allowed in view mode? If yes, the mapping must be bidirectional. If no, make view mode read-only and display a message on keypress
- [ ] **1.10.5** Test: navigate through a file with headings, bold, italic, links, and code in view mode; verify cursor position is always correct; test basic typing if editing is enabled

---

## Phase 2 — Advanced Rendering

Goal: Full visual polish — Unicode table borders, nested syntax highlighting in code blocks, paragraph spacing, image rendering.

### Feature 2.1 — Unicode Box-Drawing Table Borders
`[depends on 1.1]` `[independent within phase]`

- [ ] **2.1.1** Add a table detection pass: in `lgen_view()`, when a table region is detected (consecutive lines with `|` delimiters), identify the structure (column count, column widths, header row, separator row, body rows)
- [ ] **2.1.2** Replace the first row's leading `|` with `┌`, internal `|` with `┬`, trailing `|` with `┐`
- [ ] **2.1.3** Replace the separator row (`|---|---|`) with `├───┼───┤`
- [ ] **2.1.4** Replace body row `|` characters with `│`
- [ ] **2.1.5** Replace the last row's `|` with `└`, `┴`, `┘`
- [ ] **2.1.6** Apply BOLD + background tint to header row cells
- [ ] **2.1.7** Apply alternating background tints to body rows (odd/even)
- [ ] **2.1.8** Handle alignment indicators (`:---`, `:---:`, `---:`) — strip them from display but remember alignment for future cell padding
- [ ] **2.1.9** Test: render a 4-column table with header, separator, and 5+ body rows; verify complete box-drawing border and alternating row colors

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

- [x] **T.1** Create a comprehensive test markdown file (`mdtest.md`) containing all supported constructs: headings (H1–H6), bold, italic, bold+italic, strikethrough, inline code, fenced code blocks (with and without language), tables, links (inline, reference, autolink), images, blockquotes (nested), ordered lists, unordered lists, task lists, horizontal rules, tight/loose paragraphs → Created as `mdtest.md` (copied from `tests/TEST.md`). Automated tests in `tests/viewmode.py` with 103 total tests passing.
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
