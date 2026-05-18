# Future Roadmap

Features deferred to a later phase. These are fully designed but not scheduled for current work.

---

## Feature 2.5 — Nested Syntax Highlighting in Code Blocks
`[depends on 1.1, 1.2, 1.5]` `[independent within phase]`

**Approach:** Cannot use DFA `call` mechanism — existing sub-syntaxes (c.jsf, python.jsf, etc.) have no awareness of markdown closing fences (```) and cannot `rtn`. Instead, handle sub-syntax entirely in C code within `lgen_view()`:
- After markdown `parse()`, detect fenced code body lines by DFA state (`fence_*_body`)
- Extract language from the opening fence line (scan backward)
- Load sub-syntax via `load_syntax(lang)` and re-`parse()` each body line
- Detect closing fence by raw line content (``` or ~~~ at start)
- Fall back to plain `MdCodeBlock` when language is unknown or sub-syntax fails to load

- [ ] **2.5.1** Add static variables in `bw.c` to track nested syntax state (`nested_syntax`, `nested_st`, `nested_active`, `nested_syntax_lang`)
- [ ] **2.5.2** In `lgen_view()`, detect fenced code body lines by checking the incoming `HIGHLIGHT_STATE.state` against the `fence_bt_body` / `fence_tl_body` state indices, or by checking fence-opening/closing patterns in the raw line buffer
- [ ] **2.5.3** Extract language identifier from the opening fence line; load sub-syntax via `load_syntax(lang)` with a language-to-syntax-name mapping table; call `parse(sub_syntax, ...)` to re-color body lines; save the `HIGHLIGHT_STATE` return for cross-line state continuation
- [ ] **2.5.4** For unrecognized language identifiers, fall back to the plain code block highlighting from Feature 1.2 (don't re-parse, leave `attr_buf[]` with markdown colors)
- [ ] **2.5.5** Detect closing fence when line starts with ``` or ~~~ after optional whitespace; clear nested state and don't re-parse with sub-syntax
- [ ] **2.5.6** Add `viewmode_cleanup()` cleanup for nested syntax state when view mode is toggled off
- [ ] **2.5.7** Test: create a markdown file with ` ```c `, ` ```python `, ` ```javascript `, ` ```unknown `, and ` ~~~c ` blocks; verify each block has language-appropriate (or fallback) syntax highlighting

---

## Feature 2.6 — Image Link Rendering
`[depends on 1.1, 1.6]` `[independent within phase]`

- [ ] **2.6.1** Detect image syntax `![alt text](url)` in `lgen_view()`
- [ ] **2.6.2** Replace the `!` with a Unicode image indicator `🖼` or `[IMG]` text
- [ ] **2.6.3** Display the alt text in italic + dim color
- [ ] **2.6.4** Skip rendering the URL portion (or show it in very dim text on hover if possible)
- [ ] **2.6.5** Test: verify `![Photo](cat.jpg)` renders as an image indicator with alt text in view mode
