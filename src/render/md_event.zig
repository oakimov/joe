//! In-tree markdown "event" primitives (plan §8 / Phase 4).
//!
//! Ideas borrowed from koino's node taxonomy and MD4C's enter/leave
//! callback shape and flanking-delimiter-run classification — no vendored
//! code, no `build.zig` dependency on either. JOE parses line-by-line with
//! carried block state (fence/table/quote), not a full-document AST, so
//! this is deliberately small: a documented node taxonomy for reference,
//! and a delimiter-run flanking classifier that's actually wired into
//! `view.zig`'s `applyEmphasis` to fix real bugs (see below), not a
//! parser replacement.
//!
//! **Bug this fixes**: `applyEmphasis`'s previous delimiter scan had no
//! flanking-rule concept at all — it hid the *first* `*`/`_`/`~~` it found
//! and the *next* matching one, unconditionally. Two concrete, confirmed
//! wrong results from that: `x * a * y` (space-surrounded stars) got
//! treated as emphasis (CommonMark §6.2: a delimiter run followed by
//! whitespace isn't left-flanking, so it can't open), and
//! `snake_case_word` got treated as emphasis (CommonMark's intraword `_`
//! restriction: `_` can't open/close in the middle of a word the way `*`
//! can). `classifyRun` below implements the actual CommonMark §6.2 rule
//! (ASCII whitespace/punctuation only — adequate for the common case;
//! full Unicode categories are out of scope).

const std = @import("std");
const testing = std.testing;

/// koino-inspired node taxonomy (plan §Phase 4 "taxonomy from koino
/// study"). Documents the shape a future full event layer would use;
/// `view.zig`'s line-scanners already detect all of these constructs
/// today, just not through this enum. `Image` is deliberately absent —
/// out of scope per plan roadmap 2.6.
pub const NodeKind = enum {
    document,
    heading,
    paragraph,
    block_quote,
    list,
    item,
    task_item,
    code_block,
    thematic_break,
    table,
    table_row,
    table_cell,
    text,
    soft_break,
    line_break,
    emph,
    strong,
    strikethrough,
    code_span,
    link,
    escape,
};

pub const DelimChar = enum(u8) {
    star = '*',
    underscore = '_',

    fn byte(self: DelimChar) u8 {
        return @intFromEnum(self);
    }
};

/// Whether a delimiter run (a maximal sequence of the same delimiter
/// character) can open and/or close emphasis, per CommonMark §6.2.
pub const RunFlank = struct {
    can_open: bool,
    can_close: bool,
};

fn isAsciiAny(c: u8, comptime table: []const u8) bool {
    for (table) |t| {
        if (c == t) return true;
    }
    return false;
}

/// ASCII punctuation per CommonMark's definition (the 32 ASCII punctuation
/// characters listed in the spec, i.e. `string.punctuation` in Python).
fn isAsciiPunct(c: u8) bool {
    return switch (c) {
        '!', '"', '#', '$', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '.', '/' => true,
        ':', ';', '<', '=', '>', '?', '@' => true,
        '[', '\\', ']', '^', '_', '`' => true,
        '{', '|', '}', '~' => true,
        else => false,
    };
}

fn isSpaceByte(c: u8) bool {
    return isAsciiAny(c, &.{ ' ', '\t', '\n', '\r', 0x0B, 0x0C });
}

/// Classify a delimiter run spanning `line[start..end]` (all the same
/// `ch`). Boundary (`start == 0` / `end == line.len`) counts as
/// whitespace, matching CommonMark treating line edges as whitespace for
/// flanking purposes.
pub fn classifyRun(line: []const u8, start: usize, end: usize, ch: DelimChar) RunFlank {
    std.debug.assert(start < end and end <= line.len);
    const before: u8 = if (start == 0) ' ' else line[start - 1];
    const after: u8 = if (end >= line.len) ' ' else line[end];

    const before_ws = isSpaceByte(before);
    const after_ws = isSpaceByte(after);
    const before_punct = isAsciiPunct(before);
    const after_punct = isAsciiPunct(after);

    // left-flanking: not followed by whitespace, and either not followed
    // by punctuation, or preceded by whitespace/punctuation/line-start.
    const left_flanking = !after_ws and (!after_punct or before_ws or before_punct);
    // right-flanking: not preceded by whitespace, and either not preceded
    // by punctuation, or followed by whitespace/punctuation/line-end.
    const right_flanking = !before_ws and (!before_punct or after_ws or after_punct);

    if (ch == .underscore) {
        // Intraword restriction: `_` can open only if left-flanking and
        // (not also right-flanking, or preceded by punctuation) — and
        // symmetrically to close. `*` has no such restriction.
        return .{
            .can_open = left_flanking and (!right_flanking or before_punct),
            .can_close = right_flanking and (!left_flanking or after_punct),
        };
    }
    return .{ .can_open = left_flanking, .can_close = right_flanking };
}

/// Convenience for a single-position (length-1) run — the common case for
/// `view.zig`'s scanner, which decides open/close one delimiter at a time
/// rather than pre-scanning whole runs. `run_start`/`run_end` describe the
/// *whole* maximal run this position sits inside (needed for correct
/// before/after lookaround), which the caller determines by scanning
/// outward from `pos` while `line[i] == ch.byte()`.
pub fn classifyAt(line: []const u8, pos: usize, ch: DelimChar) RunFlank {
    var start = pos;
    while (start > 0 and line[start - 1] == ch.byte()) : (start -= 1) {}
    var end = pos + 1;
    while (end < line.len and line[end] == ch.byte()) : (end += 1) {}
    return classifyRun(line, start, end, ch);
}

test "classifyRun: spaced stars are neither opener nor closer" {
    // "x * a * y" — both '*' runs are surrounded by spaces on the side
    // that would need to be non-whitespace to flank.
    const line = "x * a * y";
    const open = classifyRun(line, 2, 3, .star); // first '*'
    try testing.expect(!open.can_open); // followed by ' ' -> not left-flanking
    try testing.expect(!open.can_close); // preceded by ' ' -> not right-flanking
    const close = classifyRun(line, 6, 7, .star); // second '*'
    try testing.expect(!close.can_open);
    try testing.expect(!close.can_close);
}

test "classifyRun: adjacent-to-word stars flank normally" {
    // "a*b*c" — both runs touch word characters on both sides.
    const line = "a*b*c";
    const open = classifyRun(line, 1, 2, .star);
    try testing.expect(open.can_open);
    try testing.expect(open.can_close); // also right-flanking (star has no intraword restriction)
    const close = classifyRun(line, 3, 4, .star);
    try testing.expect(close.can_open);
    try testing.expect(close.can_close);
}

test "classifyRun: underscore intraword restriction" {
    // "snake_case_word" — both '_' are mid-word: left AND right flanking
    // simultaneously, which disqualifies both ends under the intraword
    // rule (neither preceded nor followed by punctuation).
    const line = "snake_case_word";
    const first = classifyRun(line, 5, 6, .underscore);
    try testing.expect(!first.can_open);
    try testing.expect(!first.can_close);
    const second = classifyRun(line, 10, 11, .underscore);
    try testing.expect(!second.can_open);
    try testing.expect(!second.can_close);
}

test "classifyRun: underscore at word boundary still flanks" {
    // "foo _bar_ baz" — each '_' touches a word on only one side, so the
    // intraword restriction doesn't apply; this is legitimate emphasis.
    const line = "foo _bar_ baz";
    const open = classifyRun(line, 4, 5, .underscore);
    try testing.expect(open.can_open);
    try testing.expect(!open.can_close); // preceded by space, so not right-flanking
    const close = classifyRun(line, 8, 9, .underscore);
    try testing.expect(!close.can_open); // followed by space, so not left-flanking
    try testing.expect(close.can_close);
}

test "classifyRun: punctuation-adjacent underscore can flank one side" {
    // "(_foo_)" — parens are punctuation. Opening '_' is preceded by '('
    // (punctuation, counts as whitespace-like for the *outer* flanking
    // check) and followed by 'f' (word char): left-flanking and NOT
    // right-flanking (since 'f' isn't punctuation/whitespace) -> can_open.
    const line = "(_foo_)";
    const open = classifyRun(line, 1, 2, .underscore);
    try testing.expect(open.can_open);
    const close = classifyRun(line, 5, 6, .underscore);
    try testing.expect(close.can_close);
}

test "classifyAt matches classifyRun for a scanned run" {
    const line = "a**b";
    const a = classifyAt(line, 1, .star);
    const b = classifyRun(line, 1, 3, .star);
    try testing.expectEqual(b.can_open, a.can_open);
    try testing.expectEqual(b.can_close, a.can_close);
}

/// Plan §5: only these schemes are ever spawned for click-to-open. Rejects
/// anything else — in particular a crafted `[x](javascript:...)` or
/// `[x](http://a;rm -rf ~)` destination never reaches the spawn call in
/// `src/bw_lgen.zig` at all, since this check runs first. Pulled out here
/// (rather than living directly in `bw_lgen.zig`) specifically so it's
/// unit-testable — `bw_lgen.zig` isn't part of the `zig build test`/
/// `render-test` target (AGENTS.md), but this module is.
pub fn isSafeUrlScheme(url: []const u8) bool {
    const schemes = [_][]const u8{ "http://", "https://", "mailto:", "file://" };
    for (schemes) |s| {
        if (std.mem.startsWith(u8, url, s)) return true;
    }
    return false;
}

test "isSafeUrlScheme accepts the allowed schemes" {
    try testing.expect(isSafeUrlScheme("http://example.com"));
    try testing.expect(isSafeUrlScheme("https://example.com/path?q=1"));
    try testing.expect(isSafeUrlScheme("mailto:a@b.com"));
    try testing.expect(isSafeUrlScheme("file:///etc/hosts"));
}

test "isSafeUrlScheme rejects everything else, including injection attempts" {
    try testing.expect(!isSafeUrlScheme("javascript:alert(1)"));
    try testing.expect(!isSafeUrlScheme("ftp://example.com"));
    try testing.expect(!isSafeUrlScheme("data:text/html,<script>1</script>"));
    try testing.expect(!isSafeUrlScheme(""));
    try testing.expect(!isSafeUrlScheme("HTTP://example.com")); // case-sensitive, deliberately strict
}

/// Plan §5.2b: parses one line as a reference-link definition
/// `[label]: dest` (optionally indented up to 3 spaces, matching
/// CommonMark's definition rules; an optional ` "title"`/similar trailer
/// is dropped — dest ends at the first following whitespace). `label`
/// matches case-insensitively. Returns `null` if the line doesn't match
/// this shape. Used by `src/bw_lgen.zig`'s click-time reference resolver
/// (never on paint — reference URLs aren't pre-scanned/cached).
pub fn parseReferenceDef(line: []const u8, label: []const u8) ?[]const u8 {
    var i: usize = 0;
    while (i < line.len and i < 3 and (line[i] == ' ' or line[i] == '\t')) : (i += 1) {}
    if (i >= line.len or line[i] != '[') return null;
    i += 1;
    const label_start = i;
    while (i < line.len and line[i] != ']') : (i += 1) {}
    if (i >= line.len) return null;
    if (!std.ascii.eqlIgnoreCase(line[label_start..i], label)) return null;
    i += 1;
    if (i >= line.len or line[i] != ':') return null;
    i += 1;
    while (i < line.len and (line[i] == ' ' or line[i] == '\t')) : (i += 1) {}
    var dest_end = i;
    while (dest_end < line.len and line[dest_end] != ' ' and line[dest_end] != '\t' and
        line[dest_end] != '\r' and line[dest_end] != '\n') : (dest_end += 1)
    {}
    if (dest_end <= i) return null;
    return line[i..dest_end];
}

test "parseReferenceDef: basic match" {
    try testing.expectEqualStrings("http://example.com", parseReferenceDef("[ref]: http://example.com", "ref").?);
}

test "parseReferenceDef: case-insensitive label match" {
    try testing.expectEqualStrings("http://example.com", parseReferenceDef("[Ref]: http://example.com", "ref").?);
    try testing.expectEqualStrings("http://example.com", parseReferenceDef("[REF]: http://example.com", "Ref").?);
}

test "parseReferenceDef: trailing title dropped" {
    try testing.expectEqualStrings("http://example.com", parseReferenceDef("[ref]: http://example.com \"Title\"", "ref").?);
}

test "parseReferenceDef: up to 3 leading spaces allowed" {
    try testing.expectEqualStrings("http://x", parseReferenceDef("   [ref]: http://x", "ref").?);
}

test "parseReferenceDef: 4+ leading spaces rejected (indented code)" {
    try testing.expect(parseReferenceDef("    [ref]: http://x", "ref") == null);
}

test "parseReferenceDef: label mismatch rejected" {
    try testing.expect(parseReferenceDef("[other]: http://x", "ref") == null);
}

test "parseReferenceDef: non-definition lines rejected" {
    try testing.expect(parseReferenceDef("just some text", "ref") == null);
    try testing.expect(parseReferenceDef("[ref](http://x)", "ref") == null); // inline link, not a definition
    try testing.expect(parseReferenceDef("[ref]:", "ref") == null); // no destination
}

test "isSafeUrlScheme: shell metacharacters in an allowed-scheme URL are still 'safe' by this check" {
    // The security property this function provides is "only these
    // schemes get spawned" -- NOT "no shell metacharacters". A URL like
    // this passes the scheme check (correctly), and stays safe only
    // because the caller (src/bw_lgen.zig's spawnOpenUrl) passes it to
    // execlp as a single argv element, never through a shell.
    try testing.expect(isSafeUrlScheme("http://a;rm -rf ~"));
}
