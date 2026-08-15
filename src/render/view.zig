//! Zig-native markdown viewmode side tables (JOE `lgen_view` shaped).
//!
//! Builds per-line hide / substitute / link-url / column-map tables from raw
//! buffer bytes, matching JOE `joe/bw.c` Feature 1.x. Table box-drawing lives
//! in `table.zig` (Feature 2.1/2.2) and paints padded rows directly.
//! `lgen` conceals hidden bytes at zero width and applies substitute→codepoint
//! when `Options.view` is set (plan §4). Wired into live `joe` via
//! `zig_bw_view_line_start` (`src/bw_lgen.zig`), which binds these tables onto
//! the C-owned side-table storage through `bindScratch`.

const std = @import("std");
const testing = std.testing;
const terminal = @import("terminal");

pub const Attribute = terminal.Attribute;
pub const Color = terminal.Color;
pub const displayWidth = terminal.displayWidth;

/// JOE `FG_BLUE` — ANSI indexed blue for link text.
pub const link_fg: Color = .{ .indexed = 4 };

/// Per-line viewmode tables indexed by buffer byte offset from BOL.
pub const ViewTables = struct {
    allocator: std.mem.Allocator,
    /// Non-zero ⇒ paint as space (JOE `viewmode_hide`).
    hide: []u8 = &.{},
    /// Non-zero ⇒ paint this codepoint instead (JOE `viewmode_substitute`).
    substitute: []u21 = &.{},
    /// Borrowed URL slices into the analyzed line (JOE `viewmode_link_url`).
    /// Valid only while that line buffer lives.
    link_url: []?[]const u8 = &.{},
    /// Display column for cursor mapping; hidden bytes contribute 0 width
    /// (JOE `viewmode_col_map`). Visual paint still emits spaces for hide.
    col_map: []u64 = &.{},
    len: usize = 0,
    /// When false, slices are borrowed (bindScratch) — deinit does not free.
    owns_memory: bool = true,

    pub fn init(allocator: std.mem.Allocator) ViewTables {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *ViewTables) void {
        if (self.owns_memory) {
            self.allocator.free(self.hide);
            self.allocator.free(self.substitute);
            self.allocator.free(self.link_url);
            self.allocator.free(self.col_map);
        }
        self.* = .{ .allocator = self.allocator };
    }

    /// Ensure capacity for `need` bytes (clears to zero / null).
    pub fn prepare(self: *ViewTables, need: usize) !void {
        std.debug.assert(self.owns_memory);
        const n = if (need == 0) @as(usize, 1) else need;
        if (self.hide.len < n) {
            self.hide = try self.allocator.realloc(self.hide, n);
        }
        if (self.substitute.len < n) {
            self.substitute = try self.allocator.realloc(self.substitute, n);
        }
        if (self.link_url.len < n) {
            self.link_url = try self.allocator.realloc(self.link_url, n);
        }
        if (self.col_map.len < n) {
            self.col_map = try self.allocator.realloc(self.col_map, n);
        }
        const clear_n = if (need == 0) @as(usize, 1) else need;
        @memset(self.hide[0..clear_n], 0);
        @memset(self.substitute[0..clear_n], 0);
        @memset(self.link_url[0..clear_n], null);
        @memset(self.col_map[0..clear_n], 0);
        self.len = need;
    }

    /// Bind to caller-owned scratch slices (no allocation). `need` must fit.
    pub fn bindScratch(
        self: *ViewTables,
        hide: []u8,
        substitute: []u21,
        link_url: []?[]const u8,
        col_map: []u64,
        need: usize,
    ) void {
        const clear_n = if (need == 0) @as(usize, 1) else need;
        std.debug.assert(hide.len >= clear_n);
        std.debug.assert(substitute.len >= clear_n);
        std.debug.assert(link_url.len >= clear_n);
        std.debug.assert(col_map.len >= clear_n);
        self.owns_memory = false;
        self.hide = hide;
        self.substitute = substitute;
        self.link_url = link_url;
        self.col_map = col_map;
        @memset(self.hide[0..clear_n], 0);
        @memset(self.substitute[0..clear_n], 0);
        @memset(self.link_url[0..clear_n], null);
        @memset(self.col_map[0..clear_n], 0);
        self.len = need;
    }

    pub fn isHidden(self: *const ViewTables, byte_idx: usize) bool {
        return byte_idx < self.len and self.hide[byte_idx] != 0;
    }

    pub fn subAt(self: *const ViewTables, byte_idx: usize) u21 {
        if (byte_idx >= self.len) return 0;
        return self.substitute[byte_idx];
    }

    pub fn linkAt(self: *const ViewTables, byte_idx: usize) ?[]const u8 {
        if (byte_idx >= self.len) return null;
        return self.link_url[byte_idx];
    }
};

/// Analyze one markdown line into `tables` (JOE `lgen_view` Feature 1.x).
/// Optional `attrs` (same length as `line`) receives link underline+blue.
/// When `tables` is scratch-bound (`owns_memory == false`), capacity must already
/// cover `line.len` (see `bindScratch`); this only re-clears and sets `len`.
pub fn analyzeLine(tables: *ViewTables, line: []const u8, attrs: ?[]Attribute) !void {
    if (tables.owns_memory) {
        try tables.prepare(line.len);
    } else {
        const clear_n = if (line.len == 0) @as(usize, 1) else line.len;
        std.debug.assert(tables.hide.len >= clear_n);
        std.debug.assert(tables.substitute.len >= clear_n);
        std.debug.assert(tables.link_url.len >= clear_n);
        std.debug.assert(tables.col_map.len >= clear_n);
        @memset(tables.hide[0..clear_n], 0);
        @memset(tables.substitute[0..clear_n], 0);
        @memset(tables.link_url[0..clear_n], null);
        @memset(tables.col_map[0..clear_n], 0);
        tables.len = line.len;
    }

    if (analyzeLineStart(tables, line, 8)) return;

    // Feature 1.4: Bold/italic/strikethrough — hide delimiters (skip list markers + code spans)
    applyEmphasis(tables, line);

    // Feature 1.5: Inline code backticks — hide matching runs
    applyInlineCode(tables, line);

    // Feature 1.6: Links — hide delimiters, store URL, style link text
    applyLinks(tables, line, attrs);

    buildColMap(tables, line, 8);
}

/// Line-start Feature 1.3/1.5/1.7/1.8 (+ task 1.7.4). Returns true when the
/// line is fully handled (JOE `goto done`); false to continue with tables/inline.
pub fn analyzeLineStart(tables: *ViewTables, line: []const u8, tab: u16) bool {
    const tab_u: u16 = if (tab == 0) 8 else tab;
    // Feature 1.3: Heading — hide # run and trailing space
    {
        var i: usize = 0;
        while (i < line.len and line[i] == '#') : (i += 1) {}
        if (i > 0 and i <= 6) {
            if (i < line.len and (line[i] == ' ' or line[i] == '\t')) {
                var j: usize = 0;
                while (j <= i) : (j += 1) tables.hide[j] = 1;
            } else if (i == line.len) {
                var j: usize = 0;
                while (j < i) : (j += 1) tables.hide[j] = 1;
            }
            buildColMap(tables, line, tab_u);
            return true;
        }
    }

    // Feature 1.5: Fenced code block fence — hide ``` / ~~~ (+ leading ws)
    {
        var i: usize = 0;
        while (i < line.len and (line[i] == ' ' or line[i] == '\t')) : (i += 1) {}
        if (i + 2 < line.len and line[i] == '`' and line[i + 1] == '`' and line[i + 2] == '`') {
            var fence_end = i + 3;
            while (fence_end < line.len and line[fence_end] == '`') : (fence_end += 1) {}
            var j: usize = 0;
            while (j < fence_end) : (j += 1) tables.hide[j] = 1;
            buildColMap(tables, line, tab_u);
            return true;
        }
        if (i + 2 < line.len and line[i] == '~' and line[i + 1] == '~' and line[i + 2] == '~') {
            var fence_end = i + 3;
            while (fence_end < line.len and line[fence_end] == '~') : (fence_end += 1) {}
            var j: usize = 0;
            while (j < fence_end) : (j += 1) tables.hide[j] = 1;
            buildColMap(tables, line, tab_u);
            return true;
        }
    }

    // Feature 1.7: Blockquote — `>` → │ (U+2502); nested `>>` → ││
    {
        var i: usize = 0;
        var nesting: usize = 0;
        while (i < line.len and line[i] == '>') {
            nesting += 1;
            tables.substitute[i] = 0x2502;
            i += 1;
            if (i < line.len and line[i] == ' ') i += 1;
        }
        if (nesting > 0) {
            buildColMap(tables, line, tab_u);
            return true;
        }
    }

    // Feature 1.7.4: Task list checkbox `[ ]` / `[x]` → ☐ / ☑
    {
        var i: usize = 0;
        while (i < line.len and (line[i] == ' ' or line[i] == '\t')) : (i += 1) {}
        if (i < line.len and (line[i] == '*' or line[i] == '-' or line[i] == '+') and
            i + 1 < line.len and (line[i + 1] == ' ' or line[i + 1] == '\t'))
        {
            var after = i + 2;
            while (after < line.len and (line[after] == ' ' or line[after] == '\t')) : (after += 1) {}
            if (after + 2 < line.len and line[after] == '[' and
                (line[after + 1] == ' ' or line[after + 1] == 'x' or line[after + 1] == 'X') and
                line[after + 2] == ']')
            {
                const checked = line[after + 1] == 'x' or line[after + 1] == 'X';
                tables.substitute[after] = if (checked) @as(u21, 0x2611) else @as(u21, 0x2610);
                tables.hide[after + 1] = 1;
                tables.hide[after + 2] = 1;
                if (after + 3 < line.len and line[after + 3] == ' ')
                    tables.hide[after + 3] = 1;
            }
        }
    }

    // Feature 1.8: Horizontal rule — 3+ matching -/*/+ (spaces ok) → ─
    {
        var i: usize = 0;
        while (i < line.len and (line[i] == ' ' or line[i] == '\t')) : (i += 1) {}
        if (i < line.len and (line[i] == '-' or line[i] == '*' or line[i] == '+')) {
            const rule_char = line[i];
            var count: usize = 0;
            var j = i;
            var is_rule = true;
            while (j < line.len) : (j += 1) {
                if (line[j] == rule_char) {
                    count += 1;
                } else if (line[j] != ' ' and line[j] != '\t') {
                    is_rule = false;
                    break;
                }
            }
            if (is_rule and count >= 3) {
                var k: usize = 0;
                while (k < line.len) : (k += 1) tables.substitute[k] = 0x2500;
                buildColMap(tables, line, tab_u);
                return true;
            }
        }
    }

    // Feature 4.2.1(d): Indented code block — 4+ display columns of leading
    // whitespace, not otherwise recognized above (headings/fences/quotes/
    // tasks/HR already returned). No block-context (blank-line-before)
    // tracking; single line-start test only, unlike fenced regions which
    // need `zig_bw_fence_detect`. Skip a plain bullet marker so a deeply
    // nested list item's content isn't misread as code.
    {
        var i: usize = 0;
        var col: u16 = 0;
        while (i < line.len and (line[i] == ' ' or line[i] == '\t')) : (i += 1) {
            col += if (line[i] == '\t') tab_u - (col % tab_u) else 1;
        }
        if (col >= 4 and i < line.len) {
            const c = line[i];
            const next_is_ws = i + 1 < line.len and (line[i + 1] == ' ' or line[i + 1] == '\t');
            const looks_like_bullet = (c == '*' or c == '-' or c == '+') and next_is_ws;
            if (!looks_like_bullet) {
                buildColMap(tables, line, tab_u);
                return true;
            }
        }
    }

    return false;
}

/// Feature 1.4/1.5/1.6 + col_map only (JOE post-table inline chrome).
/// Assumes line-start features (heading/fence/blockquote/HR/task) and tables
/// were already handled by the caller when relevant.
pub fn analyzeLineInline(tables: *ViewTables, line: []const u8, attrs: ?[]Attribute, tab: u16) void {
    applyEmphasis(tables, line);
    applyInlineCode(tables, line);
    applyLinks(tables, line, attrs);
    buildColMap(tables, line, if (tab == 0) 8 else tab);
}

fn markCodeSpans(in_code: []u8, line: []const u8) void {
    @memset(in_code, 0);
    var i: usize = 0;
    while (i < line.len) {
        if (line[i] == '`') {
            const start = i;
            var bcnt: usize = 0;
            while (i < line.len and line[i] == '`') : (i += 1) bcnt += 1;
            var found = false;
            while (i + bcnt <= line.len) {
                if (line[i] == '`') {
                    var k: usize = 0;
                    while (k < bcnt and i + k < line.len and line[i + k] == '`') : (k += 1) {}
                    if (k == bcnt) {
                        var j = start + bcnt;
                        while (j < i) : (j += 1) in_code[j] = 1;
                        i += bcnt;
                        found = true;
                        break;
                    }
                }
                i += 1;
            }
            if (!found) i = start + bcnt;
        } else {
            i += 1;
        }
    }
}

fn applyEmphasis(tables: *ViewTables, line: []const u8) void {
    if (line.len == 0) return;
    var in_code_buf: [4096]u8 = undefined;
    var heap_code: ?[]u8 = null;
    defer if (heap_code) |h| tables.allocator.free(h);
    const in_code: []u8 = blk: {
        if (line.len <= in_code_buf.len) break :blk in_code_buf[0..line.len];
        const h = tables.allocator.alloc(u8, line.len) catch return;
        heap_code = h;
        break :blk h;
    };
    markCodeSpans(in_code, line);

    var j: usize = 0;
    while (j < line.len and (line[j] == ' ' or line[j] == '\t')) : (j += 1) {}
    if (j < line.len and (line[j] == '*' or line[j] == '-' or line[j] == '+') and
        j + 1 < line.len and (line[j + 1] == ' ' or line[j + 1] == '\t'))
    {
        return; // list marker — skip inline emphasis
    }

    while (j < line.len) {
        if (in_code[j] != 0) {
            j += 1;
            continue;
        }

        if (line[j] == '*' and j + 2 < line.len and line[j + 1] == '*' and line[j + 2] == '*') {
            tables.hide[j] = 1;
            tables.hide[j + 1] = 1;
            tables.hide[j + 2] = 1;
            j += 3;
            while (j < line.len) {
                if (in_code[j] != 0) {
                    j += 1;
                    continue;
                }
                if (line[j] == '*' and j + 2 < line.len and line[j + 1] == '*' and line[j + 2] == '*') {
                    tables.hide[j] = 1;
                    tables.hide[j + 1] = 1;
                    tables.hide[j + 2] = 1;
                    j += 3;
                    break;
                }
                j += 1;
            }
        } else if (line[j] == '*' and j + 1 < line.len and line[j + 1] == '*') {
            tables.hide[j] = 1;
            tables.hide[j + 1] = 1;
            j += 2;
            while (j < line.len) {
                if (in_code[j] != 0) {
                    j += 1;
                    continue;
                }
                if (line[j] == '*' and j + 1 < line.len and line[j + 1] == '*') {
                    tables.hide[j] = 1;
                    tables.hide[j + 1] = 1;
                    j += 2;
                    break;
                }
                j += 1;
            }
        } else if (line[j] == '_' and j + 2 < line.len and line[j + 1] == '_' and line[j + 2] == '_') {
            tables.hide[j] = 1;
            tables.hide[j + 1] = 1;
            tables.hide[j + 2] = 1;
            j += 3;
            while (j < line.len) {
                if (in_code[j] != 0) {
                    j += 1;
                    continue;
                }
                if (line[j] == '_' and j + 2 < line.len and line[j + 1] == '_' and line[j + 2] == '_') {
                    tables.hide[j] = 1;
                    tables.hide[j + 1] = 1;
                    tables.hide[j + 2] = 1;
                    j += 3;
                    break;
                }
                j += 1;
            }
        } else if (line[j] == '_' and j + 1 < line.len and line[j + 1] == '_') {
            tables.hide[j] = 1;
            tables.hide[j + 1] = 1;
            j += 2;
            while (j < line.len) {
                if (in_code[j] != 0) {
                    j += 1;
                    continue;
                }
                if (line[j] == '_' and j + 1 < line.len and line[j + 1] == '_') {
                    tables.hide[j] = 1;
                    tables.hide[j + 1] = 1;
                    j += 2;
                    break;
                }
                j += 1;
            }
        } else if (line[j] == '~' and j + 1 < line.len and line[j + 1] == '~') {
            tables.hide[j] = 1;
            tables.hide[j + 1] = 1;
            j += 2;
            while (j < line.len) {
                if (in_code[j] != 0) {
                    j += 1;
                    continue;
                }
                if (line[j] == '~' and j + 1 < line.len and line[j + 1] == '~') {
                    tables.hide[j] = 1;
                    tables.hide[j + 1] = 1;
                    j += 2;
                    break;
                }
                j += 1;
            }
        } else if (line[j] == '*' or line[j] == '_') {
            const delim = line[j];
            if (j + 1 < line.len and line[j + 1] == delim) {
                j += 1;
                continue;
            }
            tables.hide[j] = 1;
            j += 1;
            while (j < line.len) {
                if (in_code[j] != 0) {
                    j += 1;
                    continue;
                }
                if (line[j] == delim) {
                    if (j + 1 < line.len and line[j + 1] == delim) break;
                    tables.hide[j] = 1;
                    j += 1;
                    break;
                }
                j += 1;
            }
        } else {
            j += 1;
        }
    }
}

fn applyInlineCode(tables: *ViewTables, line: []const u8) void {
    var i: usize = 0;
    while (i < line.len) {
        if (line[i] == '`') {
            const start = i;
            var bcnt: usize = 0;
            while (i < line.len and line[i] == '`') : (i += 1) bcnt += 1;
            var found = false;
            while (i + bcnt <= line.len) {
                if (line[i] == '`') {
                    var k: usize = 0;
                    while (k < bcnt and i + k < line.len and line[i + k] == '`') : (k += 1) {}
                    if (k == bcnt) {
                        var j = start;
                        while (j < start + bcnt) : (j += 1) tables.hide[j] = 1;
                        j = i;
                        while (j < i + bcnt) : (j += 1) tables.hide[j] = 1;
                        i += bcnt;
                        found = true;
                        break;
                    }
                }
                i += 1;
            }
            if (!found) i = start + bcnt;
        } else {
            i += 1;
        }
    }
}

fn hideSpan(tables: *ViewTables, start: usize, end: usize) void {
    var p = start;
    while (p < end) : (p += 1) tables.hide[p] = 1;
}

/// Feature 2.1-2.5: `[a](u)`, `[a](u "title")`, `[a][r]`, `[a][]`, `[a]`,
/// `![alt](u)` → label/alt text only. §3.2 deliberately deviates from
/// OpenCode here: the destination (and title) are concealed, not just the
/// bracket syntax, so the label survives as the sole visible content.
/// Autolinks (`<u>`) and bare URLs have no label to fall back on, so they
/// are handled elsewhere (styled, never concealed) and never reach here.
fn applyLinks(tables: *ViewTables, line: []const u8, attrs: ?[]Attribute) void {
    var i: usize = 0;
    while (i < line.len) {
        const bang = line[i] == '!' and i + 1 < line.len and line[i + 1] == '[';
        if (line[i] != '[' and !bang) {
            i += 1;
            continue;
        }
        const bracket_start = if (bang) i + 1 else i;
        var j = bracket_start + 1;
        while (j < line.len and line[j] != ']') : (j += 1) {}
        if (j >= line.len) {
            i += 1;
            continue;
        }

        // Inline: [a](u) / [a](u "title") / image ![a](u)
        if (j + 1 < line.len and line[j + 1] == '(') {
            var k = j + 2;
            while (k < line.len and line[k] != ')') : (k += 1) {}
            if (k < line.len) {
                if (bang) tables.hide[i] = 1;
                tables.hide[bracket_start] = 1;
                tables.hide[j] = 1;
                tables.hide[j + 1] = 1;
                hideSpan(tables, j + 2, k);
                tables.hide[k] = 1;
                const url = line[j + 2 .. k];
                if (url.len > 0) {
                    var lp = bracket_start + 1;
                    while (lp < j) : (lp += 1) tables.link_url[lp] = url;
                }
                if (!bang) styleLinkText(attrs, bracket_start + 1, j);
                i = k + 1;
                continue;
            }
        }

        // Reference-style: [a][r], collapsed [a][]
        if (j + 1 < line.len and line[j + 1] == '[') {
            var k = j + 2;
            while (k < line.len and line[k] != ']') : (k += 1) {}
            if (k < line.len) {
                if (bang) tables.hide[i] = 1;
                tables.hide[bracket_start] = 1;
                tables.hide[j] = 1;
                tables.hide[j + 1] = 1;
                hideSpan(tables, j + 2, k);
                tables.hide[k] = 1;
                const ref = line[j + 2 .. k];
                const link_name = if (ref.len > 0) ref else line[bracket_start + 1 .. j];
                var lp = bracket_start + 1;
                while (lp < j) : (lp += 1) tables.link_url[lp] = link_name;
                if (!bang) styleLinkText(attrs, bracket_start + 1, j);
                i = k + 1;
                continue;
            }
        }

        // Shortcut reference: [a] — images need an explicit destination,
        // so `![a]` alone (no `(...)`/`[...]` following) is left untouched.
        if (!bang) {
            const label = line[bracket_start + 1 .. j];
            if (label.len > 0) {
                tables.hide[bracket_start] = 1;
                tables.hide[j] = 1;
                var lp = bracket_start + 1;
                while (lp < j) : (lp += 1) tables.link_url[lp] = label;
                styleLinkText(attrs, bracket_start + 1, j);
            }
        }
        i = j + 1;
    }
}

fn styleLinkText(attrs: ?[]Attribute, start: usize, end: usize) void {
    const row = attrs orelse return;
    var lp = start;
    while (lp < end and lp < row.len) : (lp += 1) {
        row[lp].underline = true;
        if (Color.eql(row[lp].fg, .default)) row[lp].fg = link_fg;
    }
}

pub fn buildColMap(tables: *ViewTables, line: []const u8, tab: u16) void {
    const t: u64 = if (tab == 0) 1 else tab;
    var display_col: u64 = 0;
    var i: usize = 0;
    while (i < line.len) : (i += 1) {
        tables.col_map[i] = display_col;
        if (tables.hide[i] != 0) continue;
        if (tables.substitute[i] != 0) {
            const cw = displayWidth(tables.substitute[i]);
            display_col += if (cw > 0) cw else 0;
            continue;
        }
        if (line[i] == '\t') {
            display_col += t - (display_col % t);
        } else if ((line[i] & 0x80) == 0) {
            const cw = displayWidth(line[i]);
            display_col += if (cw > 0) cw else 0;
        } else if ((line[i] & 0xc0) != 0x80) {
            // UTF-8 lead — decode for width
            const seq_len = std.unicode.utf8ByteSequenceLength(line[i]) catch 1;
            if (i + seq_len <= line.len) {
                const cp = std.unicode.utf8Decode(line[i..][0..seq_len]) catch {
                    display_col += 1;
                    continue;
                };
                const cw = displayWidth(cp);
                display_col += if (cw > 0) cw else 0;
            } else {
                display_col += 1;
            }
        }
        // UTF-8 continuation bytes: already counted with lead
    }
}

/// Resolve the painted codepoint for a **visible** lead byte (substitute
/// wins over the raw codepoint). Callers must not invoke this for a byte
/// where `isHidden(byte_idx)` and `subAt(byte_idx) == 0` both hold — that
/// byte paints at zero width (plan §4) and is skipped by the caller before
/// reaching this function, not routed through it as a space.
pub fn resolveCp(tables: *const ViewTables, byte_idx: usize, cp: u21) u21 {
    const sub = tables.subAt(byte_idx);
    if (sub != 0) return sub;
    return cp;
}

// ── Tests ────────────────────────────────────────────────────────────

fn expectRendered(allocator: std.mem.Allocator, line: []const u8, expected: []const u8) !void {
    var tables = ViewTables.init(allocator);
    defer tables.deinit();
    try analyzeLine(&tables, line, null);

    var out: std.ArrayList(u8) = .empty;
    defer out.deinit(allocator);

    var i: usize = 0;
    while (i < line.len) {
        const b = line[i];
        if (b == '\n' or b == '\r') break;
        if (tables.substitute[i] != 0) {
            var buf: [4]u8 = undefined;
            const n = try std.unicode.utf8Encode(tables.substitute[i], &buf);
            try out.appendSlice(allocator, buf[0..n]);
            i += 1;
            continue;
        }
        if (tables.hide[i] != 0) {
            try out.append(allocator, ' ');
            i += 1;
            continue;
        }
        if ((b & 0x80) == 0) {
            try out.append(allocator, b);
            i += 1;
        } else {
            const seq_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
            const take = @min(seq_len, line.len - i);
            try out.appendSlice(allocator, line[i .. i + take]);
            i += take;
        }
    }
    try testing.expectEqualStrings(expected, out.items);
}

test "view heading hides hash run as spaces" {
    try expectRendered(testing.allocator, "# Heading One", "  Heading One");
    try expectRendered(testing.allocator, "## Heading Two", "   Heading Two");
    try expectRendered(testing.allocator, "####### Not a heading", "####### Not a heading");
}

test "view fence hides backtick/tilde markers" {
    try expectRendered(testing.allocator, "```", "   ");
    try expectRendered(testing.allocator, "```python", "   python");
    try expectRendered(testing.allocator, "~~~javascript", "   javascript");
}

test "view blockquote substitutes vertical bars" {
    try expectRendered(testing.allocator, "> Quoted text", "\u{2502} Quoted text");
    try expectRendered(testing.allocator, ">> Nested quote", "\u{2502}\u{2502} Nested quote");
}

test "view task list checkbox substitution" {
    try expectRendered(testing.allocator, "- [ ] Unchecked task", "- \u{2610}   Unchecked task");
    try expectRendered(testing.allocator, "- [x] Checked task", "- \u{2611}   Checked task");
    try expectRendered(testing.allocator, "- [X] Checked task", "- \u{2611}   Checked task");
}

test "view horizontal rule becomes box-drawing dashes" {
    try expectRendered(testing.allocator, "---", "\u{2500}\u{2500}\u{2500}");
    try expectRendered(testing.allocator, "***", "\u{2500}\u{2500}\u{2500}");
    try expectRendered(testing.allocator, "- - -", "\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}");
    try expectRendered(testing.allocator, "-- not a rule", "-- not a rule");
}

test "view indented code block leaves markdown-looking content verbatim" {
    try expectRendered(testing.allocator, "    **not bold**", "    **not bold**");
    try expectRendered(testing.allocator, "    # not a heading", "    # not a heading");
    try expectRendered(testing.allocator, "    [not](a link)", "    [not](a link)");
}

test "view indented code block requires 4+ display columns" {
    // 3 spaces: below CommonMark's indented-code threshold; still emphasis.
    try expectRendered(testing.allocator, "   **bold**", "     bold  ");
}

test "view indented code block does not swallow a nested bullet" {
    try expectRendered(testing.allocator, "    - nested item", "    - nested item");
}

test "view emphasis hides delimiters as spaces" {
    try expectRendered(testing.allocator, "Some **bold** text", "Some   bold   text");
    try expectRendered(testing.allocator, "Some *italic* text", "Some  italic  text");
    try expectRendered(testing.allocator, "***bold italic***", "   bold italic   ");
    try expectRendered(testing.allocator, "Some ~~deleted~~ x", "Some   deleted   x");
}

test "view list marker not treated as emphasis" {
    try expectRendered(testing.allocator, "* List item", "* List item");
    try expectRendered(testing.allocator, "- List item", "- List item");
}

test "view inline code hides backticks; emphasis inside stays" {
    try expectRendered(testing.allocator, "Some `code` here", "Some  code  here");
    try expectRendered(testing.allocator, "Use `**not bold**` here", "Use  **not bold**  here");
}

test "view links hide delimiters and style attrs" {
    var tables = ViewTables.init(testing.allocator);
    defer tables.deinit();
    const line = "Click [here](http://example.com)";
    var attrs: [64]Attribute = .{Attribute.none} ** 64;
    try analyzeLine(&tables, line, attrs[0..line.len]);
    try expectRendered(testing.allocator, line, "Click  here                     ");
    // 'h' of here is at byte 7
    try testing.expect(attrs[7].underline);
    try testing.expect(Color.eql(attrs[7].fg, link_fg));
    try testing.expectEqualStrings("http://example.com", tables.linkAt(7).?);
}

test "view reference link hides brackets and label" {
    try expectRendered(testing.allocator, "See [docs][reference] here", "See  docs             here");
}

test "view collapsed reference link hides brackets" {
    try expectRendered(testing.allocator, "See [docs][] here", "See  docs    here");
}

test "view shortcut reference link hides brackets" {
    var tables = ViewTables.init(testing.allocator);
    defer tables.deinit();
    const line = "See [docs] here";
    try analyzeLine(&tables, line, null);
    try expectRendered(testing.allocator, line, "See  docs  here");
    try testing.expectEqualStrings("docs", tables.linkAt(5).?);
}

test "view inline link with title hides destination and title" {
    try expectRendered(
        testing.allocator,
        "[a](http://x \"T\") end",
        " a                end",
    );
}

test "view image hides bang/brackets/destination, leaves alt visible" {
    var tables = ViewTables.init(testing.allocator);
    defer tables.deinit();
    const line = "![alt](http://x.png) end";
    try analyzeLine(&tables, line, null);
    try expectRendered(testing.allocator, line, "  alt                end");
    // Images aren't styled as clickable link text (no underline/color).
    try testing.expectEqualStrings("http://x.png", tables.linkAt(2).?);
}

test "view autolink and bare URL stay visible (no label to conceal to)" {
    try expectRendered(testing.allocator, "See <http://x> here", "See <http://x> here");
    try expectRendered(testing.allocator, "See http://x here", "See http://x here");
}

test "view col_map treats hide as zero width" {
    var tables = ViewTables.init(testing.allocator);
    defer tables.deinit();
    try analyzeLine(&tables, "# Hi", null);
    // '#' and ' ' hidden → col 0; 'H' also at compressed col 0
    try testing.expectEqual(@as(u64, 0), tables.col_map[0]);
    try testing.expectEqual(@as(u64, 0), tables.col_map[1]);
    try testing.expectEqual(@as(u64, 0), tables.col_map[2]); // H
    try testing.expectEqual(@as(u64, 1), tables.col_map[3]); // i
}
