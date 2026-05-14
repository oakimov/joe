# Markdown WYSIWYG Enhancement - Feasibility Analysis (v2)

## Revised Assessment

My original analysis was **too pessimistic**. After deeper investigation into what JOE already supports and what modern terminals can do, the picture is significantly more promising.

---

## What I Got Wrong in v1

1. **I said "font sizes are impossible"** - True at the escape-sequence level, but I failed to consider **visual weight simulation** using the full palette of attributes JOE already has
2. **I said "tables are not feasible"** - Wrong. Unicode box-drawing characters + per-cell background colors + per-line attribute control already give us real table borders and cell-like regions
3. **I undercounted JOE's existing capabilities** - JOE already has truecolor (24-bit RGB), per-line background colors, OSC 8 hyperlinks, and a sophisticated attribute pipeline
4. **I didn't consider the "view mode" approach** - JOE already has shell windows and can toggle between edit and view modes; a rendered-preview mode is architecturally feasible

---

## What JOE Already Has (that I didn't fully appreciate)

### Rendering Pipeline (`scrn.c`, `bw.c`)

| Capability | Implementation | Location |
|---|---|---|
| Truecolor 24-bit RGB | `\e[38;2;R;G;Bm` / `\e[48;2;R;G;Bm` | `scrn.c:225-254` |
| Bold, Italic, Underline, Dim | `set_attr()` emits escape sequences | `scrn.c:166-271` |
| Double underline, Strikethrough | Capability flags `dunderline`, `stricken` | `scrn.c:201-207` |
| Per-line background color | Current line highlighting via `bg_curlin` | `bw.c:465` |
| 256-color palette | Fallback when truecolor unavailable | `scrn.c:232-261` |
| Syntax state machine | DFA interpreter with stack | `syntax.c` |
| Line attribute cache | Per-line syntax state storage | `lattr.c` |

### Key Architecture Insight

The `lgen()` function in `bw.c:434` already applies syntax highlighting **per character cell**. The rendering pipeline is:

```
Syntax DFA → attr_buf[] → lgen() → outatr() → set_attr() → terminal escape sequences
```

Each character cell gets its own attribute value (foreground, background, bold/italic/underline/etc). This is a **per-pixel rendering pipeline** for a character grid. We're not limited to "one color per line" - we have full per-cell control.

---

## Feature-by-Feature Re-Analysis

### 1. "Larger font sizes" for headings → **Simulated via visual weight**

**Can't do:** Actual font size changes (terminal limitation).

**Can do much better than I originally proposed:**

The key insight is that "visual weight" and "visual hierarchy" are what matter, not literal font size. Here's a hierarchy strategy that's genuinely distinguishable:

```
H1:  BOLD + UNDERLINE + truecolor_fg(#FFD700 gold) + background tint
H2:  BOLD + truecolor_fg(#87CEEB sky blue)
H3:  BOLD + truecolor_fg(#98FB98 pale green)
H4:  UNDERLINE + truecolor_fg(#DDA0DD plum)
H5:  ITALIC + truecolor_fg(#F0E68C khaki)
H6:  DIM + truecolor_fg(#C0C0C0 silver)
```

Additionally, we can **hide the `#` prefix characters** by rendering them in the same color as the background (making them invisible), so the user sees only the heading text itself - closer to a WYSIWYG experience.

**Implementation path:** Extend `md.jsf` with six distinct heading states, each mapped to a different color definition. Update color schemes with truecolor definitions.

**Verdict: FEASIBLE and meaningfully better than current state.**

---

### 2. Bold / Italic rendering → **Enhanced, with visual distinction**

**Current problem:** `md.jsf` has one `Bold` state. Both `**text**` and `__text__` look the same. No italic state at all.

**What we can do:**

- **Bold** (`**text**` or `__text__`): BOLD attribute + distinct foreground color
- **Italic** (`*text*` or `_text_`): ITALIC attribute + slightly different foreground
- **Bold+Italic** (`***text***`): BOLD + ITALIC + yet another color
- **Strikethrough** (`~~text~~`): CROSSED_OUT attribute + dim red
- **Hide the delimiters**: Render `**`, `__`, `*`, `_`, `~~` in the background color so they become invisible - the user sees only the *effect*, not the *markup*

The delimiter-hiding trick is the key WYSIWYG innovation. Tools like `glow` and `mdcat` do this - they show rendered output, not raw markdown. JOE's per-cell attribute pipeline makes this possible.

**Verdict: FEASIBLE. Significant UX improvement.**

---

### 3. Better table views → **Meaningfully improvable**

**I was wrong to call this "not feasible."** Here's what we can actually do:

**Per-cell rendering using existing capabilities:**

```
┌──────────┬──────────┬──────────┐  ← Unicode box-drawing
│ Header 1 │ Header 2 │ Header 3 │  ← BOLD + background tint
├──────────┼──────────┼──────────┤  ← Separator row with distinct color
│ data     │ data     │ data     │  ← Normal
│ data     │ data     │ data     │  ← Alternating row background
└──────────┴──────────┴──────────┘
```

The rendering pipeline supports:
- **Background colors per cell** (already works - `BG_COLOR()` in `bw.c:466`)
- **Unicode box-drawing characters** (U+2500-U+257F) - JOE has full UTF-8 support
- **Distinct attribute per cell** - `lgen()` applies attributes per character

**Challenges:**
- The syntax highlighter is line-oriented, not table-oriented
- Need to parse table structure (column positions, alignment)
- Need to modify the rendering path to add borders

**Implementation approach:**
1. Extend `md.jsf` to recognize table lines (`|...|...|`)
2. Add a new rendering pass in `bw.c` that detects table context
3. Replace `|` with box-drawing characters (`│`, `┼`, `┌`, `┐`, etc.)
4. Apply distinct background colors to header vs body cells
5. Use the existing `bg_curlin` mechanism as a model for "table row background"

**Verdict: FEASIBLE with moderate effort. Real visual improvement.**

---

### 4. Code blocks with syntax highlighting → **Architecturally supported**

JOE already supports nested syntax (PHP in HTML, etc.). The `call` mechanism in the syntax DFA allows switching to a different syntax based on context.

**Implementation:**
1. Detect fenced code block language (`` ```python ``)
2. Use `call` to invoke the appropriate syntax subroutine
3. Apply a distinct background color to all code block lines
4. The line attribute cache (`lattr.c`) handles multi-line state

**Verdict: FEASIBLE. JOE's architecture was designed for this.**

---

### 5. Links → **OSC 8 clickable hyperlinks**

Modern terminals (Kitty, iTerm2, WezTerm, GNOME Terminal, Windows Terminal) support OSC 8 hyperlinks:

```
\e]8;;https://example.com\e\\Click here\e]8;;\e\\
```

JOE already has OSC 8 support in `bw.c` (I found the `BEGIN_osc8`/`END_osc8` macros at line 430). This means the infrastructure to emit clickable links is **already built**.

For markdown, we can:
- Render `[link text](url)` as clickable hyperlinks with colored underline
- Hide the URL portion (render in background color)
- Show `link text` with UNDERLINE + distinct foreground color

**Verdict: FEASIBLE. Infrastructure already exists.**

---

## Architecture for the Markdown View Mode

### Core Idea: Dual-Mode Rendering

Rather than trying to make the raw markdown look WYSIWYG (which is fundamentally limited), implement a **toggle between edit mode and view mode**:

**Edit Mode (current behavior):**
- Raw markdown with enhanced syntax highlighting
- Better delimiter coloring, heading hierarchy colors
- Table border highlighting

**View Mode (new):**
- Hide all markdown delimiters (`#`, `*`, `_`, `~~`, `` ` ``, `|`)
- Render headings with visual hierarchy (bold, colors, spacing)
- Render bold/italic with proper attributes
- Render tables with Unicode box-drawing borders
- Render links as OSC 8 clickable hyperlinks
- Render code blocks with background color and language-specific highlighting

### How View Mode Works

The key is that `lgen()` already processes buffer characters and outputs them with attributes. In view mode:

1. The DFA still parses the markdown to identify regions
2. Instead of outputting `#` characters, the renderer skips them
3. Instead of outputting `**`, the renderer skips them but applies BOLD to the enclosed text
4. Instead of outputting `|`, the renderer outputs Unicode box-drawing `│`
5. The buffer is NOT modified - only the rendering changes

This is similar to how syntax highlighting already works: the DFA adds metadata without changing the buffer. We're just adding "skip this character in display" as a new metadata action.

**Existing precedent:** JOE already hides certain characters - for example, in hex edit mode, binary data is rendered differently. The `outatr()` function can output a different character than what's in the buffer.

### Files to Modify

| File | Changes |
|---|---|
| `syntax/md.jsf` | Complete rewrite with proper DFA for all markdown constructs |
| `joe/colors.c` | New markdown-specific color definitions with truecolor |
| `joe/bw.c` | View mode rendering: character substitution, delimiter hiding |
| `joe/lattr.c` | Multi-line construct tracking (tables, code blocks) |
| `joe/scrn.h` | New attribute flags for "hidden" characters |
| `colors/*.jcf` | Updated color schemes with markdown-specific colors |
| `rc/*.rc` | Keybinding for toggling view mode |

### Estimated Effort

| Feature | Effort | Difficulty |
|---|---|---|
| Enhanced heading hierarchy (colors) | 2-3 days | Low (just `md.jsf` + color scheme) |
| Bold/italic with delimiter hiding | 1 week | Medium (rendering changes in `bw.c`) |
| Fenced code block with language sub-syntax | 3-5 days | Medium (uses existing `call` mechanism) |
| Table rendering with box-drawing | 2-3 weeks | High (new rendering logic needed) |
| OSC 8 clickable links | 3-5 days | Low-Medium (infrastructure exists) |
| View mode toggle | 1-2 weeks | Medium (new mode in edit loop) |

**Total: 6-10 weeks for full implementation.**

---

## What Remains Impossible

These are **hard terminal limitations** - no workaround exists:

1. **Actual font size changes** - No terminal supports per-region font sizing
2. **Proportional fonts** - Terminals are character-grid monospace
3. **Inline images** - Would require Kitty/Sixel protocol integration (could be future work but significant scope)
4. **Smooth scrolling of rich content** - Character grid scrolling only
5. **Mouse-based table column resizing** - JOE has mouse support but no table widget

---

## Recommendation

**Implement this in three phases:**

**Phase 1 (Quick wins, 1-2 weeks):**
- Enhanced `md.jsf` with proper heading hierarchy colors
- Bold/italic/strikethrough with distinct attributes
- Code block background colors
- Better table delimiter highlighting

**Phase 2 (WYSIWYG view mode, 3-4 weeks):**
- Delimiter hiding (render `**`, `#`, etc. invisible)
- Character substitution (box-drawing for tables)
- OSC 8 clickable links
- Toggle keybinding between edit and view mode

**Phase 3 (Advanced rendering, 2-4 weeks):**
- Full Unicode box-drawing table borders
- Language-specific syntax highlighting in code blocks
- Alternating row backgrounds for tables
- Smart paragraph spacing in view mode

All three phases work within the existing C/libc-only constraint and use JOE's existing rendering architecture.
