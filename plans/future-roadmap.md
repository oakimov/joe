# Future Roadmap

Deferred relative to `plans/markdown-wysiwyg-feasibility.md` (OpenCode-style
rich viewmode). Implement on the **Zig** paint path when scheduled — not C `bw.c`.
Features 2.5 and 2.6 have since landed (below); 2.7 remains blocked on its own
prerequisite (a line↔row mapping layer that doesn't exist yet).

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

## Feature 2.5 — Nested Syntax Highlighting in Code Blocks — done (single-line state)

Implemented as originally sketched: detect fence body → `load_syntax(lang)` →
re-`parse` body lines → fall back to plain code tint. `load_syntax` already
resolves colors against the current scheme itself (`resolve_syntax_colors`
inside `load_syntax_subr`, `src/syntax.zig`) and caches by name (`syntax_list`
linked-list scan), so repeated calls per repaint are cheap after the first.

- [x] **2.5.1** `applyFenceSyntaxHighlight` (`src/bw_lgen.zig`) hooks into the
      existing `in_fence_body` branch of `zig_bw_lgen_view` (Phase 1.0's fence
      region cache) — no new state-tracking struct needed, reuses
      `fence_region_start`/`fence_region_end` already threaded through.
- [x] **2.5.2** Reused Phase 1.0's fence-body detection as-is (`in_fence_body`,
      driven by `zig_bw_fence_detect`'s forward-simulated region scan) —
      already exactly "detect fenced body lines."
- [x] **2.5.3** `fenceInfoLang` extracts the language tag from the fence's
      opening line's info string; `fenceSyntaxAlias` maps common tags that
      don't match a `syntax/<name>.jsf` filename 1:1 (`js`/`javascript` → `js`,
      `py` → `python`, `ts`/`typescript` → `typescript`, `rb`/`ruby` → `ruby`,
      `rs`/`rust` → `rust`, `sh`/`bash`/`shell`/`zsh` → `sh`, `cs`/`csharp` →
      `csharp`); anything else is tried as-is (covers `c`, `go`, `java`, `sql`,
      `html`, `css`, `json`, `yaml`, `php`, `perl`, `swift`, `lua`, ... every
      tag that already equals a `.jsf` base name). **Highlight state is NOT
      carried across body lines** — each line re-parses from a fresh initial
      state (`state = 0`, matching `lattr.zig`'s `clearState`), not threaded
      from the previous line's end state. A real cross-line thread would need
      its own `find_lattr_db`/`lattr_get`-backed cache seeded fresh at each
      fence's first body line (to stop its backward-walk from crossing the
      fence boundary into unrelated markdown text) — judged too much
      correctness-critical surface for this pass; single-line-restart is
      correct for the overwhelming majority of real code (one token/construct
      per line) and only mis-highlights mid-construct for a comment or string
      that spans multiple lines within the fence. Documented limitation, not
      an oversight.
- [x] **2.5.4** Unknown language (or any tag with no matching `.jsf` file):
      `load_syntax` returns null, `applyFenceSyntaxHighlight` no-ops, the
      `md.jsf` plain code-block tint from the earlier outer `parse()` call
      (already in `attr_buf` before this function runs) is left untouched.
- [x] **2.5.5** N/A as scoped — nothing to clear. Body lines are re-detected
      per repaint (Phase 1.0's existing per-row cache-or-rescan, not a
      standing nested-state object this feature would need to tear down).
- [x] **2.5.6** N/A as scoped, same reason as 2.5.5 — no persistent state
      outside a single repaint call to clean up.
- [x] **2.5.7** `tests/viewmode.py`: ` ```python `, ` ```javascript `, ` ```c `,
      ` ~~~c `, ` ```unknown ` (fallback). Verified via a bold-attribute check
      on the first highlighted keyword — text-only assertions would pass
      identically with or without this feature, since fence-body text already
      rendered literally before Feature 2.5 (Phase 1.0). The attribute check
      must poll (`self.joe.expect(...)`) rather than read `term.buffer`
      directly: text and its SGR attribute bytes can arrive in separate
      reads, so an unpolled read raced the paint and was flaky under the full
      suite despite passing standalone — the rest of this codebase's soak
      tests avoid that whole class of flake by only asserting on text.
      Soak 223 → 228.

---

## Feature 2.6 — Image chrome (not inline bitmaps) — done

- [x] **2.6.1** `![alt](url)`/`![alt][ref]` detection already existed (Phase 2
      task 2.5, `applyLinks` in `src/render/view.zig`, the `bang` branch) —
      no dedicated `md_event` node needed; the existing link-shaped detection
      already distinguishes it via the leading `!`.
- [x] **2.6.2** Chrome glyph: `⬚` (U+2B1A DOTTED SQUARE) now substitutes for
      the `!` instead of hiding it at zero width, so a concealed image is
      visually distinguishable from a concealed plain link (previously both
      rendered as identical colored text — `md.jsf`'s `MdImageAlt` vs.
      `MdLinkText` color difference was the *only* signal). Text-only, no
      Sixel/Kitty. Originally `▣` (U+25A3) — replaced after a real
      terminal-overlap report: U+25A3 has Unicode East Asian Width
      **Ambiguous** (some terminals render it 2 columns wide; JOE's own
      width table treats it as 1, so the next character got painted over
      what the terminal thought was still the glyph). `☐`/`☑`
      (U+2610/U+2611) are EAW **Neutral** — unambiguously narrow, which is
      why they never had this problem — U+2B1A shares that property.
      Even after the EAW-Neutral swap, a real terminal-rendering report
      persisted (⬚ still looked like it touched/overlapped the following
      character) — traced both of JOE's own width tables (`joe_wcwidth`,
      `src/unicode.zig`, used by edit-mode/core painting; `displayWidth`,
      `terminal/screen.zig`, used by viewmode) and confirmed neither
      classifies U+2B1A or U+25A3 as double-width, and cursor-movement
      column tracking is correct too — so this is a font-metrics quirk
      (symbol/dingbat blocks are inconsistently spaced in many monospace
      fonts, unlike Box Drawing, which terminal fonts always get right)
      outside anything JOE's logic controls, not a bug in this codebase.
      Per user request, worked around rather than chasing a third glyph:
      the byte right after the glyph (`[`, which would otherwise conceal
      to zero width) now substitutes to a literal space instead, so any
      font overhang has a real, harmless cell to land in rather than
      overlapping the alt text's first letter.
- [x] **2.6.3** Turned out to be free: `link_url` was already populated for
      the alt-text span in the `bang` branch (same as link text), and Phase
      5's click-to-open (OSC 8 + mouse) reads `link_url` generically with no
      link/image distinction — so clicking an image's alt text already opens
      its destination, unchanged by this feature. Confirmed with a new soak
      test rather than by inspection alone.
- [x] **2.6.4** `tests/viewmode.py`: `test_viewmode_image_alt_text_only`
      updated for the chrome glyph; new `test_click_image_alt_does_not_crash`
      exercises 2.6.3. `src/render/view.zig`'s image unit test updated
      (`view image shows chrome glyph + alt, hides brackets/destination`).
      Soak 222 → 223.
