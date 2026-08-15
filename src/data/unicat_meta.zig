//! Auto-generated Unicode input metadata for JOE Zig rewrite.
//! Do not edit by hand; regenerate with: python3 tools/gen_unicat.py
//!
//! Full category tables live in src/unicat.zig (Path A C-ABI port).
//! To regenerate C sources from UnicodeData:
//!   joe/util/uniproc joe/util/unicode-17/Blocks.txt \
//!     joe/util/unicode-17/UnicodeData.txt \
//!     joe/util/unicode-17/CaseFolding.txt \
//!     joe/util/unicode-17/EastAsianWidth.txt > joe/unicat-17.0.0.c
//! Expected future build step: `zig build gen-unicat`.

pub const UNICODE_VERSION: []const u8 = "17.0.0";

pub const InputHash = struct { name: []const u8, sha256: []const u8 };

pub const INPUT_HASHES = [_]InputHash{
    .{ .name = "Blocks.txt", .sha256 = "c0edefaf1a19771e830a82735472716af6bf3c3975f6c2a23ffbe2580fbbcb15" },
    .{ .name = "UnicodeData.txt", .sha256 = "2e1efc1dcb59c575eedf5ccae60f95229f706ee6d031835247d843c11d96470c" },
    .{ .name = "CaseFolding.txt", .sha256 = "ff8d8fefbf123574205085d6714c36149eb946d717a0c585c27f0f4ef58c4183" },
    .{ .name = "EastAsianWidth.txt", .sha256 = "ea7ce50f3444a050333448dffef1cadd9325af55cbb764b4a2280faf52170a33" },
};

/// Manifest of key `pub export` symbols checked by tools/gen_unicat.py.
pub const KEY_EXPORTS = [_][]const u8{
    "uniblocks",
    "unicat",
    "fold_table",
    "fold_repl",
    "width_table",
    "toupper_table",
    "tolower_table",
    "totitle_table",
    "Lu_table",
    "Ll_table",
    "Nd_table",
    "Mn_table",
    "Cc_table",
};

/// Count of all `pub export const` symbols in unicat.zig at generation time.
pub const EXPORT_COUNT: usize = 40;

