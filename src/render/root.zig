//! Zig-native rendering pipeline (Phase 6).
//!
//! Parallel to hybrid/C `joe/bw.c` (`lgen` / `bwgen`). Grows behind unit tests;
//! not wired into live `joe` yet. Window paint may call into this module for
//! text-body cells.

pub const lgen = @import("lgen.zig");

pub const Options = lgen.Options;
pub const lgenLine = lgen.lgenLine;

test {
    _ = lgen;
}
