//! Zig-native rendering pipeline (Phase 6).
//!
//! Parallel to hybrid/C `joe/bw.c` (`lgen` / `bwgen`). Grows behind unit tests;
//! not wired into live `joe` yet. Window paint may call into this module for
//! text-body cells. Includes Zig-native `lattr` highlight-state cache.

pub const lgen = @import("lgen.zig");
pub const gap = @import("gap.zig");
pub const attr = @import("attr.zig");
pub const syntax = @import("syntax.zig");
pub const view = @import("view.zig");
pub const table = @import("table.zig");
pub const lattr = @import("lattr.zig");

pub const Options = lgen.Options;
pub const VisibleWs = lgen.VisibleWs;
pub const mergeVisibleWsAttr = lgen.mergeVisibleWsAttr;
pub const lgenLine = lgen.lgenLine;
pub const lgenPoint = lgen.lgenPoint;
pub const lgenBuffer = lgen.lgenBuffer;
pub const GapBuffer = gap.GapBuffer;
pub const Point = gap.Point;
pub const mergeHighlight = attr.mergeHighlight;
pub const attrAt = attr.attrAt;
pub const fromHybridRow = attr.fromHybridRow;
pub const allocFromHybridRow = attr.allocFromHybridRow;
pub const Syntax = syntax.Syntax;
pub const HighlightState = syntax.HighlightState;
pub const loadSyntax = syntax.load;
pub const ViewTables = view.ViewTables;
pub const analyzeLine = view.analyzeLine;
pub const analyzeLineInline = view.analyzeLineInline;
pub const tryPaintTable = table.tryPaintFromLines;
pub const tableLayoutAt = table.layoutAt;
pub const LineAttrCache = lattr.LineAttrCache;

test {
    _ = lgen;
    _ = gap;
    _ = attr;
    _ = syntax;
    _ = view;
    _ = table;
    _ = lattr;
}
