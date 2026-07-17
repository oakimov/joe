//! Shared JOE `genfmt` attribute-escape helpers.
//!
//! Used by status/`fmtLen`/`fmtPos` and by the paint bridge (`writeFmt`,
//! help springs). Keeps the escape set in one place.

const std = @import("std");
const testing = std.testing;

const terminal = @import("terminal");
pub const Attribute = terminal.Attribute;

pub const StyleKind = enum {
    underline,
    inverse,
    bold,
    italic,
    dim,
    blink,
    crossed_out,
    double_underline,
};

/// Map a JOE `\[…]` escape letter to a style toggle, if it is an attribute escape.
pub fn styleKind(esc: u8) ?StyleKind {
    return switch (esc) {
        'u', 'U' => .underline,
        'i', 'I' => .inverse,
        'b', 'B' => .bold,
        'l', 'L' => .italic,
        'd', 'D' => .dim,
        'f', 'F' => .blink,
        's', 'S' => .crossed_out,
        'z', 'Z' => .double_underline,
        else => null,
    };
}

pub fn isAttrEsc(esc: u8) bool {
    return styleKind(esc) != null;
}

pub fn toggleStyle(attr: Attribute, kind: StyleKind) Attribute {
    var out = attr;
    switch (kind) {
        .underline => out.underline = !out.underline,
        .inverse => out.inverse = !out.inverse,
        .bold => out.bold = !out.bold,
        .italic => out.italic = !out.italic,
        .dim => out.dim = !out.dim,
        .blink => out.blink = !out.blink,
        .crossed_out => out.crossed_out = !out.crossed_out,
        .double_underline => out.double_underline = !out.double_underline,
    }
    return out;
}

/// Apply a style escape in-place. Returns `true` when `esc` was an attribute toggle.
pub fn applyStyleEsc(attr: *Attribute, esc: u8) bool {
    const kind = styleKind(esc) orelse return false;
    attr.* = toggleStyle(attr.*, kind);
    return true;
}

test "styleKind covers genfmt attribute letters" {
    try testing.expect(isAttrEsc('i'));
    try testing.expect(isAttrEsc('L'));
    try testing.expect(isAttrEsc('z'));
    try testing.expect(!isAttrEsc('|'));
    try testing.expect(!isAttrEsc('@'));
    try testing.expect(!isAttrEsc('n'));
}

test "applyStyleEsc toggles inverse" {
    var attr: Attribute = .none;
    try testing.expect(applyStyleEsc(&attr, 'i'));
    try testing.expect(attr.inverse);
    try testing.expect(applyStyleEsc(&attr, 'I'));
    try testing.expect(!attr.inverse);
}
