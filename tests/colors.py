import joefx


class ColorSchemeTests(joefx.JoeTestBase):
    """Phase 3: color scheme resolution / fallback (plan §6.2.8)"""

    def test_default_scheme_still_resolves(self):
        """-colors default keeps working via the embedded builtin fallback
        even though colors/default.jcf was deleted (plan §6.2.8 blast-radius
        claim: removal doesn't change out-of-box behavior)."""
        self.workdir.fixtureData("test.md", "# Heading\n")
        self.startup.args = ("-colors", "default", "test.md")
        self.startJoe()
        self.assertTextAt("# Heading", x=0)
        self.exitJoe()
        self.assertExited()

    def test_cursor_dark_scheme_loads(self):
        """The new native scheme parses and applies without error."""
        self.workdir.fixtureData("test.md", "# Heading\n")
        self.startup.args = ("-colors", "cursor-dark", "test.md")
        self.startJoe()
        self.assertTextAt("# Heading", x=0)
        self.exitJoe()
        self.assertExited()

    def test_removed_scheme_name_degrades_gracefully(self):
        """Naming one of the eight removed schemes doesn't crash the editor
        or hide file content -- apply_scheme(null) is a documented no-op."""
        self.workdir.fixtureData("test.md", "# Heading\n")
        self.startup.args = ("-colors", "gruvbox", "test.md")
        self.startJoe()
        self.joe.expect(lambda: False)
        text = "\n".join(
            self.joe.readLine(y, 0, self.joe.size.X) for y in range(self.joe.size.Y)
        )
        self.assertIn("Heading", text)
        self.exitJoe()
        self.assertExited()

    def test_heading_colored_in_viewmode(self):
        """MdH1 (nord_blue bold underline) applies to the heading text.
        Checks bold/underscore only, not fg color value: the pinned test
        dependency (pyte==0.5.2, see tests/requirements.txt) doesn't parse
        extended 256-color/truecolor SGR sequences (38;5;N / 38;2;R;G;B)
        into Char.fg -- confirmed by cross-checking against a newer pyte
        (0.8.2) locally, where the same JOE output does show the real fg
        hex. Bold/underline (simple SGR codes) parse correctly either way,
        and are enough to prove MdH1's styling (vs. plain/Idle) applied."""
        self.workdir.fixtureData("test.md", "# Heading\n")
        self.startup.args = ("-colors", "cursor-dark", "test.md")
        self.startJoe()
        self.mode("viewmode")
        self.joe.expect(lambda: False)
        cell = self.joe.term.buffer[1][1]  # 'e' of Heading, not under cursor
        self.assertEqual(cell.data, "e")
        self.assertTrue(cell.bold)
        self.assertTrue(cell.underscore)
        self.exitJoe()
        self.assertExited()

    def test_heading_colored_in_edit_mode(self):
        """Plan §3.5: edit mode (viewmode off) still applies the same syntax
        colors to the raw, unconcealed source -- the ' ' half of the '# '
        delimiter prefix gets MdH1 styling exactly like the heading text
        does (screen column 0 has its own unrelated rendering convention --
        confirmed by probing a plain non-heading line too -- so this checks
        column 1, the space after '#', rather than '#' itself). See
        test_heading_colored_in_viewmode for why this checks bold/underscore
        rather than fg color value."""
        self.workdir.fixtureData("test.md", "# Heading\n\n")
        self.startup.args = ("-colors", "cursor-dark", "test.md")
        self.startJoe()
        self.writectl("{down}")  # move cursor off row 1 entirely
        self.assertCursor(x=0, y=2)
        delim_cell = self.joe.term.buffer[1][1]  # ' ' of '# '
        self.assertEqual(delim_cell.data, " ")
        self.assertTrue(delim_cell.bold)
        self.assertTrue(delim_cell.underscore)
        text_cell = self.joe.term.buffer[1][2]  # 'H' of Heading
        self.assertEqual(text_cell.data, "H")
        self.assertEqual(text_cell.bold, delim_cell.bold)
        self.assertEqual(text_cell.underscore, delim_cell.underscore)
        self.exitJoe()
        self.assertExited()
