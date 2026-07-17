//! Syntax attribute helpers for Phase 6 `lgen` (JOE `attr_buf` shaped).
//!
//! `attr_buf` is **per-byte** from BOL. UTF-8 multi-byte glyphs use the lead
//! byte's attribute (JOE `lgen_core` rewinds idx on incomplete UTF-8 so the
//! completed character paints with the lead atr). Context bits are stripped
//! when converting from hybrid packed ints.
//!
//! Full JSF DFA stays in hybrid `src/syntax.zig`; this module only applies an
//! already-populated attribute row to the native renderer.

const std = @import("std");
const testing = std.testing;
const terminal = @import("terminal");

pub const Attribute = terminal.Attribute;
pub const Color = terminal.Color;
pub const Hybrid = terminal.Hybrid;
pub const attributeFromHybrid = terminal.attributeFromHybrid;

/// Merge highlighter atr onto the line's default/base atr (JOE `defatr` fill).
/// Missing FG/BG in `syn` (`.default`) inherit from `base`. Style flags come
/// from `syn` (highlighter owns them); callers may OR extra flags afterward.
pub fn mergeHighlight(base: Attribute, syn: Attribute) Attribute {
    var out = syn;
    if (Color.eql(out.fg, .default)) out.fg = base.fg;
    if (Color.eql(out.bg, .default)) out.bg = base.bg;
    return out;
}

/// Look up per-byte attr at `byte_idx`, merge with `base`. Out-of-range → base.
pub fn attrAt(base: Attribute, attrs: ?[]const Attribute, byte_idx: usize) Attribute {
    const row = attrs orelse return base;
    if (byte_idx >= row.len) return base;
    return mergeHighlight(base, row[byte_idx]);
}

/// Convert a JOE `attr_buf` row (`attr_data` / packed `int`) into native Attributes.
/// Strips `CONTEXT_*` bits like `lgen_core` (`atr & ~CONTEXT_MASK`).
pub fn fromHybridRow(dst: []Attribute, src: []const i32, palette: ?[]const i32) void {
    const n = @min(dst.len, src.len);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const atr = src[i] & ~Hybrid.CONTEXT_MASK;
        dst[i] = attributeFromHybrid(atr, palette);
    }
    while (i < dst.len) : (i += 1) {
        dst[i] = .none;
    }
}

/// Allocate + convert a hybrid attr row (caller frees with `allocator.free`).
pub fn allocFromHybridRow(allocator: std.mem.Allocator, src: []const i32, palette: ?[]const i32) ![]Attribute {
    const out = try allocator.alloc(Attribute, src.len);
    fromHybridRow(out, src, palette);
    return out;
}

test "mergeHighlight fills default colors from base" {
    const base = Attribute{
        .fg = .{ .indexed = 7 },
        .bg = .{ .indexed = 0 },
        .bold = false,
    };
    const syn = Attribute{
        .fg = .default,
        .bg = .default,
        .bold = true,
    };
    const m = mergeHighlight(base, syn);
    try testing.expect(m.bold);
    try testing.expect(Color.eql(m.fg, .{ .indexed = 7 }));
    try testing.expect(Color.eql(m.bg, .{ .indexed = 0 }));
}

test "fromHybridRow strips context and maps bold/underline" {
    var dst: [3]Attribute = undefined;
    const src = [_]i32{
        Hybrid.BOLD | Hybrid.CONTEXT_COMMENT,
        Hybrid.UNDERLINE | (Hybrid.FG_NOT_DEFAULT | (2 << Hybrid.FG_SHIFT)),
        0,
    };
    fromHybridRow(&dst, &src, null);
    try testing.expect(dst[0].bold);
    try testing.expect(!dst[0].underline);
    try testing.expect(Color.eql(dst[0].fg, .default));
    try testing.expect(dst[1].underline);
    try testing.expect(Color.eql(dst[1].fg, .{ .indexed = 2 }));
    try testing.expect(Attribute.eql(dst[2], .none));
}
