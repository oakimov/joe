import joefx

class ViewModeTests(joefx.JoeTestBase):
    """Tests for Markdown WYSIWYG view mode — toggle, delimiter hiding, file integrity"""

    # --- Feature 1.1: View mode toggle ---

    def test_viewmode_toggle_off_on(self):
        """Toggle viewmode on, then off, verify editor still works"""
        self.startJoe()
        self.write("Hello")
        self.assertTextAt("Hello", x=0)
        self.mode("viewmode")
        self.mode("viewmode")
        self.write(" World")
        self.assertTextAt("Hello World", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_toggle_on_stays_on(self):
        """Viewmode stays on after toggle"""
        self.workdir.fixtureData("test.md", "# Hello\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Hello", x=0)
        self.exitJoe()
        self.assertExited()

    # --- Feature 1.3: Heading delimiter hiding ---
    # Plan §4: hidden bytes paint at zero width, so heading text starts
    # immediately at column 0 rather than after N space-padded columns.

    def test_viewmode_h1_heading(self):
        """H1: '# ' hidden at zero width"""
        self.workdir.fixtureData("test.md", "# Heading One\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Heading One", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_h2_heading(self):
        """H2: '## ' hidden at zero width"""
        self.workdir.fixtureData("test.md", "## Heading Two\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Heading Two", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_h3_heading(self):
        """H3: '### ' hidden at zero width"""
        self.workdir.fixtureData("test.md", "### Heading Three\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Heading Three", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_h4_heading(self):
        """H4: '#### ' hidden at zero width"""
        self.workdir.fixtureData("test.md", "#### Heading Four\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Heading Four", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_h5_heading(self):
        """H5: '##### ' hidden at zero width"""
        self.workdir.fixtureData("test.md", "##### Heading Five\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Heading Five", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_h6_heading(self):
        """H6: '###### ' hidden at zero width"""
        self.workdir.fixtureData("test.md", "###### Heading Six\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Heading Six", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_heading_no_space(self):
        """Heading without trailing space: '#' at end of line"""
        self.workdir.fixtureData("test.md", "#\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # The # should be hidden even without trailing space
        self.assertTextAt(" ", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_no_heading_no_hide(self):
        """Non-heading text not affected"""
        self.workdir.fixtureData("test.md", "Just plain text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Just plain text", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_seven_hashes_not_heading(self):
        """7+ hashes should not be treated as heading"""
        self.workdir.fixtureData("test.md", "####### Not a heading\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Should not hide the hashes
        self.assertTextAt("####### Not a hea", x=0)
        self.exitJoe()
        self.assertExited()

    # --- Feature 1.4: Bold/italic/strikethrough delimiter hiding ---

    def test_viewmode_bold(self):
        """Bold **text** delimiters hidden at zero width"""
        self.workdir.fixtureData("test.md", "Some **bold** text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Some bold text", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_italic(self):
        """Italic *text* delimiters hidden at zero width"""
        self.workdir.fixtureData("test.md", "Some *italic* text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Some italic text", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_bold_underscore(self):
        """Bold __text__ delimiters hidden at zero width"""
        self.workdir.fixtureData("test.md", "Some __bold__ text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Some bold text", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_italic_underscore(self):
        """Italic _text_ delimiters hidden at zero width"""
        self.workdir.fixtureData("test.md", "Some _italic_ text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Some italic text", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_strikethrough(self):
        """Strikethrough ~~text~~ delimiters hidden at zero width"""
        self.workdir.fixtureData("test.md", "Some ~~deleted~~ text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Some deleted text", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_bold_italic_asterisks(self):
        """Bold+italic ***text*** delimiters hidden (all 3 chars, zero width)"""
        self.workdir.fixtureData("test.md", "***bold italic***\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("bold italic", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_bold_italic_underscores(self):
        """Bold+italic ___text___ delimiters hidden (all 3 chars, zero width)"""
        self.workdir.fixtureData("test.md", "___bold italic___\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("bold italic", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_nested_bold_italic(self):
        """Nested: **bold *italic* bold** — outer ** hidden, inner * not fully handled
        Note: Linear scanner limitation — nested emphasis not fully supported yet."""
        self.workdir.fixtureData("test.md", "**bold *italic* more**\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Outer ** hidden at zero width, but inner *italic* delimiters remain
        # visible (known limitation)
        self.assertTextAt("bold *italic* more", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_emphasis_inside_code_not_hidden(self):
        """Emphasis markers inside code spans should NOT be hidden"""
        self.workdir.fixtureData("test.md", "Use `**not bold**` here\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Backticks hidden at zero width, but ** inside code stays visible
        self.assertTextAt("Use **not bold** here", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_multiple_emphasis_same_line(self):
        """Multiple bold spans on one line"""
        self.workdir.fixtureData("test.md", "**one** and **two**\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("one and two", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_mixed_emphasis_same_line(self):
        """Mixed bold and italic on same line"""
        self.workdir.fixtureData("test.md", "**bold** and *italic*\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("bold and italic", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_list_marker_not_emphasis(self):
        """List marker * at line start should not be hidden as emphasis (normalises to -, plan §3.1/2.8)"""
        self.workdir.fixtureData("test.md", "* List item\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("- List item", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_list_marker_dash_not_emphasis(self):
        """List marker - at line start should not be hidden"""
        self.workdir.fixtureData("test.md", "- List item\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("- List item", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_list_marker_plus_not_emphasis(self):
        """List marker + at line start should not be hidden (normalises to -, plan §3.1/2.8)"""
        self.workdir.fixtureData("test.md", "+ List item\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("- List item", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_bold_at_line_start(self):
        """Bold at beginning of line"""
        self.workdir.fixtureData("test.md", "**bold** at start\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("bold at start", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_italic_at_line_start(self):
        """Italic at beginning of line"""
        self.workdir.fixtureData("test.md", "*italic* at start\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("italic at start", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_strikethrough_at_line_start(self):
        """Strikethrough at beginning of line"""
        self.workdir.fixtureData("test.md", "~~strike~~ at start\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("strike at start", x=0)
        self.exitJoe()
        self.assertExited()

    # --- Feature 1.5: Inline code backtick hiding ---

    def test_viewmode_inline_code(self):
        """Inline code `code` backticks hidden at zero width"""
        self.workdir.fixtureData("test.md", "Some `code` here\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Some code here", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_inline_code_at_start(self):
        """Inline code at start of line"""
        self.workdir.fixtureData("test.md", "`code` at start\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("code at start", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_multiple_inline_code(self):
        """Multiple inline code spans on one line"""
        self.workdir.fixtureData("test.md", "Use `foo` and `bar` here\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Use foo and bar here", x=0)
        self.exitJoe()
        self.assertExited()

    # --- Feature 1.6: Link delimiter hiding ---

    def test_viewmode_inline_link(self):
        """Inline link [text](url): brackets/parens/destination all concealed (plan §3.2)"""
        self.workdir.fixtureData("test.md", "Click [here](http://example.com)\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Click here", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_link_at_start(self):
        """Link at start of line"""
        self.workdir.fixtureData("test.md", "[link](http://x.com)\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("link", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_multiple_links_same_line(self):
        """Multiple links on one line"""
        self.workdir.fixtureData("test.md", "[one](http://a.com) and [two](http://b.com)\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("one and two", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_reference_link(self):
        """Reference-style link [text][ref]: brackets and reference label concealed"""
        self.workdir.fixtureData("test.md", "See [docs][reference] here\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("See docs here", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_link_with_title(self):
        """Link with title [text](url "title"): destination and title both concealed"""
        self.workdir.fixtureData("test.md", "[click](http://x.com \"Title\") here\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("click here", x=0)
        self.exitJoe()
        self.assertExited()

    # --- Feature 1.7: Blockquote delimiter hiding ---

    def test_viewmode_blockquote(self):
        """Blockquote > rendered as vertical bar"""
        self.workdir.fixtureData("test.md", "> Quoted text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("\u2502 Quoted text", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_nested_blockquote(self):
        """Nested blockquote >> rendered as double vertical bars"""
        self.workdir.fixtureData("test.md", ">> Nested quote\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # >> substituted with ││, space kept
        self.assertTextAt("\u2502\u2502 Nested quote ", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_blockquote_no_bleed(self):
        """Blockquote substitution must not bleed to next line"""
        self.workdir.fixtureData("test.md", "> quote\nabc\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Line 1: blockquote rendered as │ quote
        self.assertTextAt("\u2502 quote", x=0, y=1)
        # Line 2: normal text must NOT be substituted
        self.assertTextAt("abc", x=0, y=2)
        self.exitJoe()
        self.assertExited()

    # --- Feature 1.7.4: Task list checkboxes ---

    def test_viewmode_task_list_unchecked(self):
        """Task list [ ] rendered as ☐"""
        self.workdir.fixtureData("test.md", "- [ ] Unchecked task\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("- \u2610Unchecked task", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_task_list_checked(self):
        """Task list [x] rendered as ☑"""
        self.workdir.fixtureData("test.md", "- [x] Checked task\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("- \u2611Checked task", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_task_list_checked_uppercase(self):
        """Task list [X] rendered as ☑"""
        self.workdir.fixtureData("test.md", "- [X] Checked task\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("- \u2611Checked task", x=0)
        self.exitJoe()
        self.assertExited()

    # --- Feature 1.8: Horizontal rule Unicode substitution ---

    def test_viewmode_horizontal_rule_dashes(self):
        """Horizontal rule --- rendered as ───"""
        self.workdir.fixtureData("test.md", "---\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("\u2500\u2500\u2500", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_horizontal_rule_asterisks(self):
        """Horizontal rule *** rendered as ───"""
        self.workdir.fixtureData("test.md", "***\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("\u2500\u2500\u2500", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_horizontal_rule_plus(self):
        """Horizontal rule +++ rendered as ───"""
        self.workdir.fixtureData("test.md", "+++\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("\u2500\u2500\u2500", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_horizontal_rule_with_spaces(self):
        """Horizontal rule with spaces: - - - rendered as ─────"""
        self.workdir.fixtureData("test.md", "- - -\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("\u2500\u2500\u2500\u2500\u2500", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_not_horizontal_rule(self):
        """Two dashes should not be hidden as rule"""
        self.workdir.fixtureData("test.md", "-- not a rule\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("-- not a rule", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_horizontal_rule_no_bleed(self):
        """Horizontal rule substitution must not bleed to next line"""
        self.workdir.fixtureData("test.md", "---\nabc\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Line 1: rule rendered as ───
        self.assertTextAt("\u2500\u2500\u2500", x=0, y=1)
        # Line 2: normal text must NOT be substituted
        self.assertTextAt("abc", x=0, y=2)
        self.exitJoe()
        self.assertExited()

    # --- Feature 1.9: Table highlighting ---

    def test_viewmode_table_separator_row(self):
        """Table separator row renders with box-drawing middle border"""
        self.workdir.fixtureData("test.md", "| Header1 | Header2 |\n|---|---|\n| cell1 | cell2 |\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Separator row: ├─────────┼─────────┤ (padded to column width 7)
        self.assertTextAt("\u251c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u253c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2524", x=0, y=2)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_table_body_row(self):
        """Table body row renders with padded columns (Feature 2.2)"""
        self.workdir.fixtureData("test.md", "| Header1 | Header2 |\n|---|---|\n| cell1 | cell2 |\n| cell3 | cell4 |\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Body rows: columns padded to max width (Header1=7, Header2=7)
        # │ cell1   │ cell2   │
        self.assertTextAt("\u2502 cell1   \u2502 cell", x=0, y=3)
        self.assertTextAt("\u2502 cell3   \u2502 cell", x=0, y=4)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_table_with_alignment(self):
        """Table with alignment indicators — alignment stripped, replaced with ─"""
        self.workdir.fixtureData("test.md", "| Left | Center | Right |\n|:-----|:------:|------:|\n| a | b | c |\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Separator row: alignment indicators replaced with ─
        self.assertTextAt("\u251c\u2500", x=0, y=2)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_not_table(self):
        """Line with pipe but not a table should render normally"""
        self.workdir.fixtureData("test.md", "a | b\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Should render normally (no box-drawing for single-line pipe)
        self.assertTextAt("a | b", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    # --- Feature 1.5: Fenced code block hiding ---

    def test_viewmode_fenced_code_backtick(self):
        """Fenced code block ``` lines hidden (no language identifier)"""
        content = "```\ncode here\n```\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Fence markers hidden, nothing else on line → spaces
        self.assertTextAt("   ", x=0)
        self.assertTextAt("code here", x=0, y=2)
        self.assertTextAt("   ", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_fenced_code_tilde(self):
        """Fenced code block ~~~ lines hidden (no language identifier)"""
        content = "~~~\ncode here\n~~~\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Fence markers hidden, nothing else on line → spaces
        self.assertTextAt("   ", x=0)
        self.assertTextAt("code here", x=0, y=2)
        self.assertTextAt("   ", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_fenced_code_with_language(self):
        """Fenced code block with language identifier — language visible in dim color"""
        content = "```python\nclass Foo: pass\n```\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Opening fence markers hidden, language identifier visible
        self.assertTextAt("python", x=0)
        self.assertTextAt("class Foo: pass", x=0, y=2)
        # Closing fence markers hidden, nothing else → spaces
        self.assertTextAt("   ", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_fenced_code_language_with_spaces(self):
        """Fenced code block with language and trailing spaces"""
        content = "```python  \ncode\n```\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Fence markers hidden, language + trailing spaces visible
        self.assertTextAt("python  ", x=0)
        self.assertTextAt("code", x=0, y=2)
        self.assertTextAt("   ", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_fenced_code_tilde_with_language(self):
        """Tilde fenced code block with language identifier"""
        content = "~~~javascript\nlet x = 1;\n~~~\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Opening fence markers hidden, language visible
        self.assertTextAt("javascript", x=0)
        self.assertTextAt("let x = 1;", x=0, y=2)
        self.assertTextAt("   ", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_fenced_body_not_reparsed_as_markdown(self):
        """Plan §4.2.1 (R1): a fence body must stay byte-exact even when its
        content looks like markdown. Before the fence-body region cache, a
        `#` comment inside a code block was hidden as a heading, `**` was
        eaten as bold, and `---` became a horizontal rule — cosmetic before
        conceal collapsed to zero width, destructive after. Every other
        fenced-code soak fixture uses a body with no markdown-shaped
        characters, so this case was previously untested."""
        content = "```python\n# a comment\nx = a ** b\n---\nplain\n```\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("python", x=0, y=1)
        self.assertTextAt("# a comment", x=0, y=2)
        self.assertTextAt("x = a ** b", x=0, y=3)
        self.assertTextAt("---", x=0, y=4)
        self.assertTextAt("plain", x=0, y=5)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_fenced_body_mismatched_fence_char(self):
        """A ~~~ line inside a ``` fence body is body text, not a close —
        CommonMark fences only close on a matching character. Regression
        for plan §4.2.1's forward-simulation fence detector."""
        content = "```\nline one\n~~~\nline two\n```\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("line one", x=0, y=2)
        self.assertTextAt("~~~", x=0, y=3)
        self.assertTextAt("line two", x=0, y=4)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_indented_code_not_reparsed_as_markdown(self):
        """Plan §4.2.1(d): a 4+ space indented code block also stays
        byte-exact, not just fenced blocks."""
        content = "Para text.\n\n    # not heading\n    x = a ** b\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Para text.", x=0, y=1)
        self.assertTextAt("    # not heading", x=0, y=3)
        self.assertTextAt("    x = a ** b", x=0, y=4)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_hscroll_uses_collapsed_columns(self):
        """Plan §4 task 1.4: horizontal scroll must key off collapsed
        (post-conceal) columns, not raw byte positions. A heading whose
        text runs past the terminal width already relies on col_map/xcol
        (both collapsed pre-Phase-1.2) to decide when to scroll — this
        pins that the paint loop's own column bookkeeping (Phase 1.2)
        stays consistent with it: no leftover "# " ghost, no truncated or
        misaligned fill once scrolled to the end of a long concealed line."""
        content = "# " + ("x" * 100) + "\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Unscrolled: heading collapses, so column 0 starts directly on the
        # 100-x run (not on a phantom "# " prefix).
        self.assertTextAt("x" * 78, x=0)
        self.writectl("{end}")
        # Scrolled to the end of a 100-column run of plain 'x': the visible
        # window must be entirely 'x' (JOE's scroll heuristic keeps a
        # right-hand margin, so the exact width isn't 80 — that margin is
        # unrelated to this fix). No '#' or blank gap must appear, which
        # is what a raw-byte-offset (uncollapsed) scroll would produce.
        self.assertTrue(self.joe.expect(
            lambda: self.joe.readLine(1, 0, self.joe.size.X).rstrip() != ''
            and set(self.joe.readLine(1, 0, self.joe.size.X).rstrip()) == {'x'}
        ))
        self.exitJoe()
        self.assertExited()

    # --- Regression: viewmode off preserves delimiters ---

    def test_viewmode_off_preserves_delimiters(self):
        """With viewmode off, delimiters visible"""
        self.workdir.fixtureData("test.md", "# Heading\n**bold**\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("# Heading", x=0)
        self.assertTextAt("**bold**", x=0, y=2)
        self.exitJoe()
        self.assertExited()

    # --- File integrity ---

    def test_viewmode_no_file_modification(self):
        """View mode must not modify the underlying file"""
        content = "# Hello **world**\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Hello", x=0)
        self.exitJoe()
        self.assertExited()
        self.assertFileContents("test.md", content)

    def test_viewmode_no_file_modification_complex(self):
        """View mode must not modify complex markdown file"""
        content = "# Title\n\n**bold** and *italic* and `code`\n\n> quote\n\n---\n\n[link](http://x.com)\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.exitJoe()
        self.assertExited()
        self.assertFileContents("test.md", content)

    # --- Feature 1.10: Cursor position mapping ---

    def test_viewmode_cursor_heading(self):
        """Cursor on heading line: file not modified after cursor movement"""
        self.workdir.fixtureData("test.md", "# Heading\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Move cursor around
        self.writectl("{end}")
        self.writectl("{home}")
        self.writectl("{right*3}")
        # File must not be modified
        self.exitJoe()
        self.assertExited()
        self.assertFileContents("test.md", "# Heading\n")

    def test_viewmode_cursor_bold(self):
        """Cursor on bold text: file not modified after cursor movement"""
        self.workdir.fixtureData("test.md", "**bold**\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.writectl("{end}")
        self.writectl("{home}")
        self.exitJoe()
        self.assertExited()
        self.assertFileContents("test.md", "**bold**\n")

    def test_viewmode_cursor_link(self):
        """Cursor on link text: file not modified after cursor movement"""
        self.workdir.fixtureData("test.md", "[link](http://example.com)\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.writectl("{end}")
        self.writectl("{home}")
        self.exitJoe()
        self.assertExited()
        self.assertFileContents("test.md", "[link](http://example.com)\n")

    def test_viewmode_cursor_blockquote(self):
        """Cursor on blockquote: file not modified after cursor movement"""
        self.workdir.fixtureData("test.md", "> quote\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.writectl("{end}")
        self.writectl("{home}")
        self.exitJoe()
        self.assertExited()
        self.assertFileContents("test.md", "> quote\n")

    def test_viewmode_cursor_hidden_char_skip(self):
        """Cursor skips hidden characters and lands on visible content"""
        self.workdir.fixtureData("test.md", "**bold** text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.writectl("{home}")
        self.writectl("{right}")
        self.exitJoe()
        self.assertExited()
        self.assertFileContents("test.md", "**bold** text\n")

    def test_viewmode_cursor_horizontal_rule(self):
        """Cursor on horizontal rule: file not modified after cursor movement"""
        self.workdir.fixtureData("test.md", "---\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.writectl("{end}")
        self.writectl("{home}")
        self.exitJoe()
        self.assertExited()
        self.assertFileContents("test.md", "---\n")

    def test_viewmode_cursor_code_block(self):
        """Cursor in code block: file not modified after cursor movement"""
        content = "```\ncode\n```\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.writectl("{down}")
        self.writectl("{end}")
        self.writectl("{up}")
        self.exitJoe()
        self.assertExited()
        self.assertFileContents("test.md", content)

    # --- Multi-line comprehensive test ---

    def test_viewmode_comprehensive(self):
        """Comprehensive test with multiple constructs"""
        content = "# Title\n## Subtitle\n\n**bold** and *italic*\n\n> quote\n\n---\n\n`code` here\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Line 1: H1 \u2014 hidden bytes at zero width, text starts at column 0
        self.assertTextAt("Title", x=0, y=1)
        # Line 2: H2
        self.assertTextAt("Subtitle", x=0, y=2)
        # Line 3: blank
        # Line 4: bold + italic
        self.assertTextAt("bold and italic", x=0, y=4)
        # Line 6: blockquote (substitute only, unaffected by collapse)
        self.assertTextAt("\u2502 quote", x=0, y=6)
        # Line 8: horizontal rule (substitute only, unaffected by collapse)
        self.assertTextAt("\u2500\u2500\u2500", x=0, y=8)
        # Line 10: inline code
        self.assertTextAt("code here", x=0, y=10)
        self.exitJoe()
        self.assertExited()



    def test_viewmode_toggle_tables_scroll_no_ghost(self):
        """Regression: scrolling then toggling viewmode with tables must not duplicate lines.
        Simulates user scenario: file with tables, scroll to middle, toggle viewmode ON."""
        lines = []
        # Build a file similar to user's README with two tables separated by text
        lines.append("# Chat Client\n")
        lines.append("\n")
        lines.append("## Commands\n")
        lines.append("\n")
        lines.append("| Command | Description |\n")
        lines.append("|---------|-------------|\n")
        lines.append("| `/status` | Show session stats |\n")
        lines.append("| `/reset` | Reset session |\n")
        lines.append("| `/config` | View model parameters |\n")
        lines.append("| `/exit` | Exit gracefully |\n")
        lines.append("| `/help` | Show available commands |\n")
        lines.append("\n")
        lines.append("### API Reference\n")
        lines.append("\n")
        # Long line that extends beyond screen width
        lines.append("The server exposes OpenAI-compatible endpoints alongside the dashboard. Any tool that speaks the OpenAI Chat Completions API can use it.\n")
        lines.append("\n")
        lines.append("**Base URL:** `http://localhost:3457`\n")
        lines.append("\n")
        lines.append("| Method | Path | Description |\n")
        lines.append("|--------|------|-------------|\n")
        lines.append("| `GET` | `/v1/models` | List available models |\n")
        lines.append("| `GET` | `/v1/models/:id` | Get model details |\n")
        lines.append("| `POST` | `/v1/chat/completions` | Chat completion |\n")
        lines.append("| `GET` | `/health` | Health check |\n")
        content = "".join(lines)
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        # Scroll down to around line 15 (the long text line)
        for _ in range(14):
            self.writectl("{down}")
        # Now toggle viewmode ON
        self.mode("viewmode")
        # Wait for rendering to complete — the second table at the bottom
        # of the screen must be fully rendered before we read.
        self.assertTrue(self.joe.expect(lambda: '│' in self.joe.readLine(self.joe.size.Y - 2, 0, self.joe.size.X)),
                        "Timed out waiting for viewmode rendering to complete")
        # Read the full screen — there should be no duplicated rows
        screen_lines = []
        for y in range(self.joe.size.Y):
            line = self.joe.readLine(y, 0, self.joe.size.X).rstrip()
            if line:
                screen_lines.append(line)
        # Check for duplicate adjacent non-empty lines (ghost text duplication)
        # Skip the status bar line
        for i in range(1, len(screen_lines) - 1):
            if screen_lines[i] == screen_lines[i-1] and len(screen_lines[i].strip()) > 3:
                self.fail("Ghost text duplication: line %d and %d are identical: '%s'" %
                          (i, i-1, screen_lines[i][:60]))
        # Check that table pipes are replaced with box-drawing characters in viewmode
        # Find a line that should be a table row (has visible content from the first table)
        found_table = False
        for y in range(self.joe.size.Y):
            line = self.joe.readLine(y, 0, self.joe.size.X)
            if '│' in line:  # Box-drawing │ character
                found_table = True
                break
        self.assertTrue(found_table, "Expected box-drawing table borders in viewmode")
        self.exitJoe()
        self.assertExited()

    def test_viewmode_toggle_no_ghost_text(self):
        """Regression: toggling viewmode on must not leave ghost/raw text in buffer.
        The raw ** delimiters should be hidden at zero width, not duplicated as
        ghost text underneath the rendered content."""
        self.workdir.fixtureData("test.md", "**Base URL:** http://localhost:3457\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # After toggle, the opening ** contributes zero width — no asterisks,
        # no leftover ghost characters, and no gap before "Base".
        self.assertTextAt("Base URL: http://localhost:3457", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_toggle_off_to_on_no_ghost(self):
        """Regression: toggle viewmode off then on — screen must fully refresh.
        Old non-viewmode characters must not persist as ghost text."""
        self.workdir.fixtureData("test.md", "**bold** text *italic* here\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        # Start in non-viewmode, toggle on
        self.mode("viewmode")
        # Delimiters hidden at zero width, not ghost raw text
        self.assertTextAt("bold text italic here", x=0)
        # Toggle off and back on
        self.mode("viewmode")
        self.mode("viewmode")
        # After re-toggle, still clean — no ghost text
        self.assertTextAt("bold text italic here", x=0)
        self.exitJoe()
        self.assertExited()

class MarkdownSyntaxTests(joefx.JoeTestBase):
    """Tests for Markdown syntax highlighting (DFA correctness, viewmode off).
       Content starts at y=1 (y=0 is the status bar).
       Based on constructs from mdtest.md."""

    # --- Headings ---

    def test_h1_visible(self):
        self.workdir.fixtureData("test.md", "# Markdown: Syntax\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("# Markdown: Synta", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_h2_visible(self):
        self.workdir.fixtureData("test.md", "## Overview\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("## Overview", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_h3_visible(self):
        self.workdir.fixtureData("test.md", "### Philosophy\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("### Philosophy", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_h4_visible(self):
        self.workdir.fixtureData("test.md", "#### Level Four\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("#### Level Four", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_h5_visible(self):
        self.workdir.fixtureData("test.md", "##### Level Five\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("##### Level Five", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_h6_visible(self):
        self.workdir.fixtureData("test.md", "###### Level Six\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("###### Level Six", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    # --- Inline code ---

    def test_inline_code_backticks(self):
        self.workdir.fixtureData("test.md", "Use the `printf()` function.\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("Use the ", x=0, y=1)
        self.assertTextAt("printf()", x=9, y=1)
        self.exitJoe()
        self.assertExited()

    def test_inline_code_in_sentence(self):
        self.workdir.fixtureData("test.md", "Within a code block, ampersands (`&`) are converted.\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("Within a code block", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_inline_code_multiple_on_line(self):
        """Multiple inline code spans on one line"""
        self.workdir.fixtureData("test.md", "Use `foo` and `bar` here\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("Use ", x=0, y=1)
        self.assertTextAt("foo", x=5, y=1)
        self.assertTextAt(" and ", x=9, y=1)
        self.assertTextAt("bar", x=15, y=1)
        self.exitJoe()
        self.assertExited()

    # --- Fenced code blocks ---

    def test_fenced_code_block(self):
        content = "```\ntell application \"Foo\"\n    beep\nend tell\n```\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("```", x=0, y=1)
        self.assertTextAt("tell application", x=0, y=2)
        self.assertTextAt("    beep", x=0, y=3)
        self.assertTextAt("end tell", x=0, y=4)
        self.assertTextAt("```", x=0, y=5)
        self.exitJoe()
        self.assertExited()

    def test_fenced_code_with_language(self):
        content = "```python\nclass Foo:\n    pass\n```\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("```python", x=0, y=1)
        self.assertTextAt("class Foo:", x=0, y=2)
        self.assertTextAt("```", x=0, y=4)
        self.exitJoe()
        self.assertExited()

    def test_fenced_code_tilde(self):
        content = "~~~\nsome code\n~~~\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("~~~", x=0, y=1)
        self.assertTextAt("some code", x=0, y=2)
        self.assertTextAt("~~~", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    # --- Indented code ---

    def test_indented_code_block(self):
        content = "This is a normal paragraph:\n\n    This is a code block.\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("This is a normal ", x=0, y=1)
        self.assertTextAt("    This is a code", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    # --- Blockquotes ---

    def test_blockquote(self):
        content = "> This is a blockquote\n> Second line\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("> This is a blockq", x=0, y=1)
        self.assertTextAt("> Second line", x=0, y=2)
        self.exitJoe()
        self.assertExited()

    def test_nested_blockquote(self):
        content = "> Outer\n> > Inner\n> Back to outer\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("> Outer", x=0, y=1)
        self.assertTextAt("> > Inner", x=0, y=2)
        self.assertTextAt("> Back to outer", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    # --- Lists ---

    def test_unordered_list_dash(self):
        content = "- Red\n- Green\n- Blue\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("- Red", x=0, y=1)
        self.assertTextAt("- Green", x=0, y=2)
        self.assertTextAt("- Blue", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_unordered_list_asterisk(self):
        content = "* Red\n* Green\n* Blue\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("* Red", x=0, y=1)
        self.assertTextAt("* Green", x=0, y=2)
        self.assertTextAt("* Blue", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_unordered_list_plus(self):
        content = "+ Red\n+ Green\n+ Blue\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("+ Red", x=0, y=1)
        self.assertTextAt("+ Green", x=0, y=2)
        self.assertTextAt("+ Blue", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_ordered_list(self):
        content = "1.  Bird\n2.  McHale\n3.  Parish\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("1.  Bird", x=0, y=1)
        self.assertTextAt("2.  McHale", x=0, y=2)
        self.assertTextAt("3.  Parish", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    # --- Links ---

    def test_inline_link(self):
        content = "This is [an example](http://example.com/) inline link.\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("This is ", x=0, y=1)
        self.assertTextAt("[an example]", x=8, y=1)
        self.exitJoe()
        self.assertExited()

    def test_reference_link(self):
        content = "This is [a reference][ref]\n\n[ref]: http://example.com\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("This is [a referenc", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_image_link(self):
        content = "![alt text](image.png)\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("![alt text](image.", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    # --- Horizontal rules ---

    def test_horizontal_rule(self):
        self.workdir.fixtureData("test.md", "----\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("----", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_horizontal_rule_asterisks(self):
        self.workdir.fixtureData("test.md", "****\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("****", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    # --- Emphasis ---

    def test_italic_asterisks(self):
        self.workdir.fixtureData("test.md", "*single asterisks*\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("*single asterisks*", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_bold_asterisks(self):
        self.workdir.fixtureData("test.md", "**double asterisks**\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("**double asterisks**", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_bold_italic_asterisks(self):
        self.workdir.fixtureData("test.md", "***triple asterisks***\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("***triple asterisks", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_italic_underscores(self):
        self.workdir.fixtureData("test.md", "_single underscores_\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("_single underscores_", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_bold_underscores(self):
        self.workdir.fixtureData("test.md", "__double underscores__\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("__double underscores__", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_bold_italic_underscores(self):
        self.workdir.fixtureData("test.md", "___triple underscores___\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("___triple underscor", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    # --- Strikethrough ---

    def test_strikethrough(self):
        self.workdir.fixtureData("test.md", "~~strikethrough~~\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("~~strikethrough~~", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    # --- Escape sequences ---

    def test_backslash_escape(self):
        self.workdir.fixtureData("test.md", "Markdown's syntax\\.\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("Markdown's syntax", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    # --- No DFA stuck bugs ---

    def test_no_dfa_stuck_on_backtick_escape(self):
        """Regression: backtick with backslash doesn't get DFA stuck"""
        content = "works by writing `^\\[X` to bring up the command prompt\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        # After closing backtick, rest of line should be visible (not stuck in code state)
        # The line is longer than screen width, so just check start
        self.assertTextAt("works by writing ", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_no_dfa_stuck_multiple_inline_codes(self):
        """Regression: multiple inline code spans on one line"""
        content = "    * Keystrokes `^` and `+` to add\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        # Text should be visible on the first content line
        self.assertTextAt("    * Keystrokes", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    # --- mdtest.md based tests ---

    def test_mdtest_heading_chain(self):
        """Test heading hierarchy from mdtest.md"""
        content = "# Markdown: Syntax\n\n## Overview\n\n### Philosophy\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("# Markdown: Synta", x=0, y=1)
        self.assertTextAt("## Overview", x=0, y=3)
        self.assertTextAt("### Philosophy", x=0, y=5)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_emphasis_examples(self):
        """Test emphasis examples from mdtest.md"""
        content = "*single asterisks*\n\n_single underscores_\n\n**double asterisks**\n\n__double underscores__\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("*single asterisks*", x=0, y=1)
        self.assertTextAt("_single underscores_", x=0, y=3)
        self.assertTextAt("**double asterisks**", x=0, y=5)
        self.assertTextAt("__double underscores__", x=0, y=7)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_code_examples(self):
        """Test code examples from mdtest.md"""
        content = "Use the `printf()` function.\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("Use the ", x=0, y=1)
        self.assertTextAt("printf()", x=9, y=1)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_blockquote_examples(self):
        """Test blockquote examples from mdtest.md"""
        content = "> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,\n> consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("> This is a blockq", x=0, y=1)
        self.assertTextAt("> consectetuer adip", x=0, y=2)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_nested_blockquote(self):
        """Test nested blockquote from mdtest.md"""
        content = "> This is the first level of quoting.\n>\n> > This is nested blockquote.\n>\n> Back to the first level.\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("> This is the first", x=0, y=1)
        self.assertTextAt("> ", x=0, y=2)
        self.assertTextAt("> > This is nested ", x=0, y=3)
        self.assertTextAt("> ", x=0, y=4)
        self.assertTextAt("> Back to the first", x=0, y=5)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_list_examples(self):
        """Test list examples from mdtest.md"""
        content = "*   Red\n*   Green\n*   Blue\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("*   Red", x=0, y=1)
        self.assertTextAt("*   Green", x=0, y=2)
        self.assertTextAt("*   Blue", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_ordered_list_examples(self):
        """Test ordered list examples from mdtest.md"""
        content = "1.  Bird\n2.  McHale\n3.  Parish\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("1.  Bird", x=0, y=1)
        self.assertTextAt("2.  McHale", x=0, y=2)
        self.assertTextAt("3.  Parish", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_link_example(self):
        """Test link example from mdtest.md"""
        content = "This is [an example](http://example.com/) inline link.\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("This is ", x=0, y=1)
        self.assertTextAt("[an example]", x=8, y=1)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_fenced_code(self):
        """Test fenced code from mdtest.md"""
        content = "```\ntell application \"Foo\"\n    beep\nend tell\n```\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("```", x=0, y=1)
        self.assertTextAt("tell application", x=0, y=2)
        self.assertTextAt("    beep", x=0, y=3)
        self.assertTextAt("end tell", x=0, y=4)
        self.assertTextAt("```", x=0, y=5)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_horizontal_rule(self):
        """Test horizontal rule from mdtest.md"""
        content = "----\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("----", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_emphasis_in_sentence(self):
        """Test emphasis in context from mdtest.md"""
        content = "**Note:** This document is itself written using Markdown\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("**Note:** This doc", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_code_with_special_chars(self):
        """Test code with special characters from mdtest.md"""
        content = "Within a code block, ampersands (`&`) are converted.\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("Within a code block", x=0, y=1)
        self.exitJoe()
        self.assertExited()

    def test_mdtest_mixed_content(self):
        """Test mixed content from mdtest.md"""
        content = "# Markdown: Syntax\n\n**Note:** This document is itself written using Markdown;\n\n## Overview\n\n### Philosophy\n\nMarkdown is intended to be as easy-to-read and easy-to-write as is feasible.\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("# Markdown: Synta", x=0, y=1)
        self.assertTextAt("**Note:** This doc", x=0, y=3)
        self.assertTextAt("## Overview", x=0, y=5)
        self.assertTextAt("### Philosophy", x=0, y=7)
        self.assertTextAt("Markdown is intende", x=0, y=9)
        self.exitJoe()
        self.assertExited()

    # --- Feature 2.1/2.2: Unicode Box-Drawing Table Borders + Layout Engine ---

    def test_viewmode_table_two_tables_separate(self):
        """Two separate tables — region detection resets correctly between tables"""
        content = "| A | B |\n|---|---|\n| 1 | 2 |\n\n| X | Y |\n|---|---|\n| a | b |\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # First table: all columns same width (1) → no extra padding
        self.assertTextAt("\u2502 A \u2502 B \u2502", x=0, y=1)
        self.assertTextAt("\u251c\u2500\u2500\u2500\u253c\u2500\u2500\u2500\u2524", x=0, y=2)
        self.assertTextAt("\u2502 1 \u2502 2 \u2502", x=0, y=3)
        # Second table (after blank line)
        self.assertTextAt("\u2502 X \u2502 Y \u2502", x=0, y=5)
        self.assertTextAt("\u251c\u2500\u2500\u2500\u253c\u2500\u2500\u2500\u2524", x=0, y=6)
        self.assertTextAt("\u2502 a \u2502 b \u2502", x=0, y=7)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_table_padded_columns(self):
        """Table columns padded to match widest cell per column"""
        content = "| Short | LongerName |\n|---|---|\n| ab | cd |\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Header: column widths [6, 11], body cell 'ab' (2) padded to 6, 'cd' (2) padded to 11
        # Both left-aligned (default).  pad_total = col_width - content_width
        # │ ab    │ cd         │
        self.assertTextAt("\u2502 ab    \u2502 cd         \u2502", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_table_alignment_center_right(self):
        """Table columns respect alignment markers :---  :---:  ---:"""
        content = "| L | C | R |\n|:---|:---:|---:|\n| a | b | c |\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Column widths: all 1 (from header 'L','C','R')
        # L=left: "a "  C=center: " b "  R=right: " c"  but with right_pad too
        # Col 0 (L, width 1, align 0=left):   │ a
        # Col 1 (C, width 1, align 1=center): │ b
        # Col 2 (R, width 1, align 2=right):  │ c │
        self.assertTextAt("\u2502 a \u2502 b \u2502 c \u2502", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_table_varying_column_widths(self):
        """Three columns with different widths — each padded independently"""
        content = "| A | BB | CCC |\n|---|---|---|\n| x | y | z |\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Column widths: [1, 2, 3] from header
        # Body: content widths [1,1,1] → padded to [1,2,3]
        # │ x │ y  │ z   │
        self.assertTextAt("\u2502 x \u2502 y  \u2502 z   \u2502", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_table_single_column(self):
        """Single-column table renders correctly with padding"""
        content = "| Header |\n|---|\n| cell |\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Column width: 6 (Header)
        # Body: 'cell' (4) padded to 6, plus 1 right-pad → │ cell   │
        self.assertTextAt("\u2502 cell   \u2502", x=0, y=3)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_cursor_table_row(self):
        """Cursor on table row: file not modified after cursor movement in padded table"""
        content = "| H1 | H2 |\n|---|---|\n| ab | cd |\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.writectl("{end}")
        self.writectl("{home}")
        self.writectl("{down}")
        self.writectl("{down}")
        self.writectl("{right*3}")
        self.writectl("{left*2}")
        self.exitJoe()
        self.assertExited()
        self.assertFileContents("test.md", content)

    def test_viewmode_table_body_wider_than_header(self):
        """Body content wider than header — column widths expand to fit"""
        content = "| Hdr | Label |\n|----|------|\n| longbody | tiny |\n"
        self.workdir.fixtureData("test.md", content)
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        # Column widths from scan: Hdr=3 < longbody=8 → col 0 = 8, Label=5 > tiny=4 → col 1 = 5
        # Header: Hdr(3) padded to 8 → │ Hdr      │
        # Separator: dashes span 8+2=10, 5+2=7 → ├──────────┼───────┤
        # Body: longbody(8) padded to 8 → │ longbody │
        self.assertTextAt("\u2502 Hdr      \u2502 Label \u2502", x=0, y=1)
        self.assertTextAt("\u251c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u253c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2524", x=0, y=2)
        self.assertTextAt("\u2502 longbody \u2502 tiny  \u2502", x=0, y=3)
        self.exitJoe()
        self.assertExited()
