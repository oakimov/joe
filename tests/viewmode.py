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

    # --- Feature 1.3: Heading delimiter hiding ---

    def test_viewmode_h1_heading(self):
        """H1: '# ' hidden as spaces"""
        self.workdir.fixtureData("test.md", "# Heading One\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("  ", x=0)
        self.assertTextAt("Heading One", x=2)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_h2_heading(self):
        """H2: '## ' hidden as spaces"""
        self.workdir.fixtureData("test.md", "## Heading Two\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Heading Two", x=3)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_h3_heading(self):
        """H3: '### ' hidden as spaces"""
        self.workdir.fixtureData("test.md", "### Heading Three\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Heading Three", x=4)
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

    # --- Feature 1.4: Bold/italic/strikethrough delimiter hiding ---

    def test_viewmode_bold(self):
        """Bold **text** delimiters hidden"""
        self.workdir.fixtureData("test.md", "Some **bold** text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Some   bold  ", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_italic(self):
        """Italic *text* delimiters hidden"""
        self.workdir.fixtureData("test.md", "Some *italic* text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Some  italic  text", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_bold_underscore(self):
        """Bold __text__ delimiters hidden"""
        self.workdir.fixtureData("test.md", "Some __bold__ text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Some   bold  ", x=0)
        self.exitJoe()
        self.assertExited()

    def test_viewmode_strikethrough(self):
        """Strikethrough ~~text~~ delimiters hidden"""
        self.workdir.fixtureData("test.md", "Some ~~deleted~~ text\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Some   deleted", x=0)
        self.exitJoe()
        self.assertExited()

    # --- Feature 1.5: Inline code backtick hiding ---

    def test_viewmode_inline_code(self):
        """Inline code `code` backticks hidden"""
        self.workdir.fixtureData("test.md", "Some `code` here\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.mode("viewmode")
        self.assertTextAt("Some  code  here", x=0)
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
        self.assertTextAt("Hello", x=2)
        self.exitJoe()
        self.assertExited()
        self.assertFileContents("test.md", content)


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

    # --- Horizontal rules ---

    def test_horizontal_rule(self):
        self.workdir.fixtureData("test.md", "----\n")
        self.startup.args = ("test.md",)
        self.startJoe()
        self.assertTextAt("----", x=0, y=1)
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
