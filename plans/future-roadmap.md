# Future Roadmap

Deferred relative to `plans/markdown-wysiwyg-feasibility.md` (OpenCode-style
rich viewmode). Implement on the **Zig** paint path when scheduled — not C `bw.c`.

---

## Feature 2.7 — Row-count-changing layout (blocked on a line↔row map)

OpenCode renders markdown as flexbox blocks, so it can insert and remove screen
rows freely. JOE's paint assumes **one buffer line = one screen row**
(`buf_line = top_line + y - win_y`, `src/bw_lgen.zig:1487`), and cursor mapping,
scrolling, and every `col_map` consumer rely on it. See plan §5.

These three OpenCode behaviors are therefore deferred, not dropped. Any of them
requires a real line↔row mapping layer first — that is the actual unit of work.

- [ ] **2.7.1** Line↔row mapping layer (prerequisite for all of the below)
- [ ] **2.7.2** Inter-block margin: one blank row between separately-rendered
      blocks (OpenTUI `marginBottom: 1`; was old task 2.3)
- [ ] **2.7.3** Drop fence and info-string lines entirely (OpenTUI
      `conceal_lines ""`); today JOE conceals the markers in place
- [ ] **2.7.4** Wrapped table cells / word wrap (was old task 2.2.6)

Until 2.7.1 exists, the plan's §5 decision holds: match OpenCode's **visual
vocabulary** at line-grid fidelity, and document the difference.

---

## Feature 2.5 — Nested Syntax Highlighting in Code Blocks

Fenced bodies should use the language’s JOE syntax when known. DFA `call` into
`c.jsf` / `python.jsf` / … is unsafe (those DFAs don’t know markdown fence closes).
Do it in Zig view paint instead: detect fence body → `load_syntax(lang)` →
re-`parse` body lines → clear on closing fence; fall back to plain code tint.

- [ ] **2.5.1** Track nested syntax state in the Zig view/bw_lgen path
- [ ] **2.5.2** Detect fenced body lines (DFA state and/or raw fence patterns)
- [ ] **2.5.3** Map language id → syntax name; re-parse body lines; carry highlight state
- [ ] **2.5.4** Unknown language → keep markdown code-block colors
- [ ] **2.5.5** Closing fence clears nested state
- [ ] **2.5.6** Cleanup when viewmode toggles off
- [ ] **2.5.7** Soak: ` ```c `, ` ```python `, ` ```javascript `, ` ```unknown `, ` ~~~c `

---

## Feature 2.6 — Image chrome (not inline bitmaps)

Out of scope for the current OpenCode-style plan (no images). When revisited:

- [ ] **2.6.1** Detect `![alt](url)` in view analysis / `md_event` (Image = dedicated node)
- [ ] **2.6.2** Show a small text/Unicode indicator + alt (no Sixel/Kitty required)
- [ ] **2.6.3** Optional click-open later. Destination concealment itself is
      already Phase 2 work (task 2.5): JOE conceals `!`, `[`, `]`, `(`, the
      destination and `)`, leaving only `alt` — same as links (plan §3.2). This
      item is only the *chrome* on top of that.
- [ ] **2.6.4** Soak for alt visibility and buffer integrity
