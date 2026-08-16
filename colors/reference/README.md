# Colour scheme reference

`cursor-dark-color-theme.json` — the upstream source for `colors/cursor-dark.jcf`.

Extracted from `cursor-official-themes-0.0.5.vsix` (a zip archive):

    unzip -j cursor-official-themes-0.0.5.vsix \
      'extension/themes/cursor-dark-color-theme.json' -d colors/reference/

Theme label "Cursor Dark", `uiTheme: vs-dark`, 225 token rules.
The scope → JOE class mapping, palette, and alpha-flattening maths live in
`plans/markdown-wysiwyg-feasibility.md` §6.2.

Kept so the translation can be re-derived or re-checked when the theme changes.

## Licence research (plan §6.2.8 / TODO 3.2e)

No definitive, authoritative license text for the specific
`cursor-official-themes` package was found (Cursor/Anysphere's official
theme distribution channel). However:

- The exact "Cursor Dark" / "Anysphere" palette is independently
  re-published by multiple unrelated third parties under permissive
  licenses, with no apparent objection or takedown from Cursor/Anysphere:
  `hasokeric/cursor-anysphere-theme` (MIT), `CedricVerlinden/cursor-dark`
  (MIT), `BioHazard786/cursor-theme-vscode` (MIT), and at least one GPL-3.0
  derivative (`GustavoPrietoP/anysphere-modern`).
- `colors/cursor-dark.jcf` is a **derived translation of color values**
  (hex codes mapped onto JOE's own class names, in JOE's own `.jcf`
  format) — not a copy of Cursor's theme JSON, code, or any other
  copyrightable expression from the original package. Raw color values
  and simple scope-to-color mappings are generally understood to carry
  thin-to-no copyright protection on their own; what would be protected
  is the original creative expression (the JSON structure, comments,
  naming, etc.), none of which is reproduced here.

On that basis this was judged reasonable to ship without further
clearance. This is not a legal opinion — if you have reason to believe
otherwise, please open an issue.
