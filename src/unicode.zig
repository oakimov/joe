//! Unicode property queries and character classification.
//!
//! Drop-in replacement for joe/unicode.c.
//! Defines the global character class instances (cclass_upper, etc.)
//! and provides C ABI exports for all character classification,
//! case conversion, width calculation, and digit value queries.
//!
//! During the gradual migration, this Zig module calls C functions
//! for data structure operations (cclass, rmap, hash) via extern references.
//! The data tables (joe/unicat-17.0.0.c) remain as C sources.

const std = @import("std");
const builtin = @import("builtin");

// ══════════════════════════════════════════════════════════════════════
// C-compatible struct layouts
// ══════════════════════════════════════════════════════════════════════

const Interval = extern struct { first: c_int, last: c_int };

const Unicat = extern struct {
    name: [*c]const u8,
    len: c_int,
    intervals: [*c]const Interval,
};

/// Matches `struct Level` in cclass.h
const Level = extern struct {
    alloc: c_int,
    size: c_int,
    table: extern union {
        b: ?*anyopaque,
        c: ?*anyopaque,
        d: ?*anyopaque,
        e: ?*anyopaque,
    },
};

/// Matches `struct Rset` in cclass.h
const Rset = extern struct {
    top: [68]i16,
    second: Level,
    mid: [32]i16,
    third: Level,
};

/// Matches `struct Cclass` in cclass.h
const Cclass = extern struct {
    size: isize,
    len: isize,
    intervals: ?*Interval,
    rset: Rset,
};

/// Matches `struct Rtree` in cclass.h (for rmap_* functions)
const Rtree = extern struct {
    top: [68]i16,
    second: Level,
    mid: [32]i16,
    third: Level,
    leaf: Level,
};

/// Minimal `struct charmap` — only the fields we need
const Charmap = extern struct {
    _next: ?*Charmap,
    _name: ?*const u8,
    type: c_int,
};

/// `struct Hash` from hash.h
const Hash = opaque {};

/// `struct Ztable` — matched from unicat-17.0.0.c:
///     { first, last }
const TableEntry = extern struct { first: c_int, last: c_int };

// ══════════════════════════════════════════════════════════════════════
// C data table references (from joe/unicat-17.0.0.c)
// ══════════════════════════════════════════════════════════════════════
// In C, `const struct unicat unicat[] = {...}` stores ARRAY DATA at the
// symbol address, not a POINTER. We use zero-length extern arrays to get
// the symbol address, then cast to [*c] for indexing.
//
// Zig extern name must match the C symbol name exactly.
// Using `[0]T` gets us the base address without allocating space.

extern const unicat: [0]Unicat;
extern const toupper_table: [0]TableEntry;
extern const toupper_cvt: [0]c_int;
extern const tolower_table: [0]TableEntry;
extern const tolower_cvt: [0]c_int;
extern const fold_table: [0]TableEntry;
extern const fold_repl: [0][3]c_int;
extern const width_table: [0]TableEntry;

fn unicat_entry(sidx: usize) Unicat {
    const base = @as([*c]const Unicat, @ptrCast(@as(*allowzero const [0]Unicat, @ptrCast(&unicat))));
    return base[sidx];
}
fn toupper_entry(idx: usize) TableEntry {
    const base = @as([*c]const TableEntry, @ptrCast(@as(*allowzero const [0]TableEntry, @ptrCast(&toupper_table))));
    return base[idx];
}
fn tup_cvt(idx: usize) c_int {
    const base = @as([*c]const c_int, @ptrCast(@as(*allowzero const [0]c_int, @ptrCast(&toupper_cvt))));
    return base[idx];
}
fn tolower_entry(idx: usize) TableEntry {
    const base = @as([*c]const TableEntry, @ptrCast(@as(*allowzero const [0]TableEntry, @ptrCast(&tolower_table))));
    return base[idx];
}
fn tlo_cvt(idx: usize) c_int {
    const base = @as([*c]const c_int, @ptrCast(@as(*allowzero const [0]c_int, @ptrCast(&tolower_cvt))));
    return base[idx];
}
fn fld_entry(idx: usize) TableEntry {
    const base = @as([*c]const TableEntry, @ptrCast(@as(*allowzero const [0]TableEntry, @ptrCast(&fold_table))));
    return base[idx];
}
fn fld_repl_entry(idx: usize) [3]c_int {
    const base = @as([*c]const [3]c_int, @ptrCast(@as(*allowzero const [0][3]c_int, @ptrCast(&fold_repl))));
    return base[idx];
}
fn wid_entry(idx: usize) TableEntry {
    const base = @as([*c]const TableEntry, @ptrCast(@as(*allowzero const [0]TableEntry, @ptrCast(&width_table))));
    return base[idx];
}

// ══════════════════════════════════════════════════════════════════════
// Extern C functions
// ══════════════════════════════════════════════════════════════════════

extern "c" fn cclass_init(*Cclass) void;
extern "c" fn cclass_union(*Cclass, *Cclass) void;
extern "c" fn cclass_opt(*Cclass) void;
extern "c" fn cclass_add(*Cclass, first: c_int, last: c_int) void;
extern "c" fn cclass_inv(*Cclass) void;
extern "c" fn cclass_lookup(*Cclass, ch: c_int) c_int;

extern "c" fn rmap_init(*Rtree) void;
extern "c" fn rmap_add(*Rtree, first: c_int, last: c_int, val: c_int, flags: c_int) void;
extern "c" fn rmap_opt(*Rtree) void;
extern "c" fn rmap_lookup(*Rtree, ch: c_int, dflt: c_int) c_int;

extern "c" fn cclass_merge(cclass: *Cclass, intervals: [*c]const Interval, len: c_int) void;

extern "c" fn htmk(len: isize) *Hash;
extern "c" fn htfind(ht: *Hash, name: [*c]const u8) ?*anyopaque;
extern "c" fn htadd(ht: *Hash, name: [*c]const u8, val: *anyopaque) *anyopaque;

extern "c" fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
extern "c" fn zdup(s: [*c]const u8) [*c]u8;

extern "c" fn joe_malloc(sz: isize) ?*anyopaque;
extern "c" fn joe_free(ptr: ?*anyopaque) void;

extern "c" fn interval_test(tbl: [*c]const Interval, len: c_int, ch: c_int) isize;

// ══════════════════════════════════════════════════════════════════════
// Constants
// ══════════════════════════════════════════════════════════════════════

const ANSI_BIT: i32 = @bitCast(@as(u32, 0x80000000));
pub const REPLLEN: c_int = 3;
pub const FOLDMAGIC: c_int = 0x4000000;

// ══════════════════════════════════════════════════════════════════════
// Global character class instances (moved from unicode.c)
// ══════════════════════════════════════════════════════════════════════

export var cclass_upper: Cclass = std.mem.zeroes(Cclass);
export var cclass_lower: Cclass = std.mem.zeroes(Cclass);
export var cclass_alpha: Cclass = std.mem.zeroes(Cclass);
export var cclass_alpha_: Cclass = std.mem.zeroes(Cclass);
export var cclass_notalpha_: Cclass = std.mem.zeroes(Cclass);
export var cclass_alnum: Cclass = std.mem.zeroes(Cclass);
export var cclass_alnum_: Cclass = std.mem.zeroes(Cclass);
export var cclass_notalnum_: Cclass = std.mem.zeroes(Cclass);
export var cclass_digit: Cclass = std.mem.zeroes(Cclass);
export var cclass_notdigit: Cclass = std.mem.zeroes(Cclass);
export var cclass_xdigit: Cclass = std.mem.zeroes(Cclass);
export var cclass_punct: Cclass = std.mem.zeroes(Cclass);
export var cclass_space: Cclass = std.mem.zeroes(Cclass);
export var cclass_notspace: Cclass = std.mem.zeroes(Cclass);
export var cclass_blank: Cclass = std.mem.zeroes(Cclass);
export var cclass_ctrl: Cclass = std.mem.zeroes(Cclass);
export var cclass_graph: Cclass = std.mem.zeroes(Cclass);
export var cclass_print: Cclass = std.mem.zeroes(Cclass);
export var cclass_word: Cclass = std.mem.zeroes(Cclass);
export var cclass_notword: Cclass = std.mem.zeroes(Cclass);
export var cclass_combining: Cclass = std.mem.zeroes(Cclass);
export var cclass_double: Cclass = std.mem.zeroes(Cclass);

export var rtree_tolower: Rtree = std.mem.zeroes(Rtree);
export var rtree_toupper: Rtree = std.mem.zeroes(Rtree);
export var rtree_fold: Rtree = std.mem.zeroes(Rtree);

export var unicat_hash: ?*Hash = null;

extern var locale_map: *Charmap;

// ══════════════════════════════════════════════════════════════════════
// joe_iswinit — initialize all character class instances
// ══════════════════════════════════════════════════════════════════════

export fn joe_iswinit() void {
    // Upper
    cclass_init(&cclass_upper);
    cclass_union(&cclass_upper, unicode("Lu") orelse unreachable);
    cclass_opt(&cclass_upper);

    // Lower
    cclass_init(&cclass_lower);
    cclass_union(&cclass_lower, unicode("Ll") orelse unreachable);
    cclass_opt(&cclass_lower);

    // Alpha
    cclass_init(&cclass_alpha);
    cclass_union(&cclass_alpha, unicode("L") orelse unreachable);
    cclass_union(&cclass_alpha, unicode("M") orelse unreachable);
    cclass_opt(&cclass_alpha);

    // Alpha_ (identifier start)
    cclass_init(&cclass_alpha_);
    cclass_union(&cclass_alpha_, unicode("L") orelse unreachable);
    cclass_union(&cclass_alpha_, unicode("Pc") orelse unreachable);
    cclass_union(&cclass_alpha_, unicode("Nl") orelse unreachable);
    cclass_opt(&cclass_alpha_);

    // Not alpha_
    cclass_init(&cclass_notalpha_);
    cclass_union(&cclass_notalpha_, &cclass_alpha_);
    cclass_inv(&cclass_notalpha_);
    cclass_opt(&cclass_notalpha_);

    // Alnum
    cclass_init(&cclass_alnum);
    cclass_union(&cclass_alnum, unicode("L") orelse unreachable);
    cclass_union(&cclass_alnum, unicode("M") orelse unreachable);
    cclass_union(&cclass_alnum, unicode("N") orelse unreachable);
    cclass_opt(&cclass_alnum);

    // Alnum_ (identifier continue)
    cclass_init(&cclass_alnum_);
    cclass_union(&cclass_alnum_, unicode("L") orelse unreachable);
    cclass_union(&cclass_alnum_, unicode("Pc") orelse unreachable);
    cclass_union(&cclass_alpha_, unicode("Nl") orelse unreachable);
    cclass_union(&cclass_alnum_, unicode("Mn") orelse unreachable);
    cclass_union(&cclass_alnum_, unicode("Mc") orelse unreachable);
    cclass_union(&cclass_alnum_, unicode("Nd") orelse unreachable);
    cclass_add(&cclass_alnum_, 0x200c, 0x200d);
    cclass_opt(&cclass_alnum_);

    // Not alnum_
    cclass_init(&cclass_notalnum_);
    cclass_union(&cclass_notalnum_, &cclass_alnum_);
    cclass_inv(&cclass_notalnum_);
    cclass_opt(&cclass_notalnum_);

    // Digit
    cclass_init(&cclass_digit);
    cclass_union(&cclass_digit, unicode("Nd") orelse unreachable);
    cclass_opt(&cclass_digit);

    // Not digit
    cclass_init(&cclass_notdigit);
    cclass_union(&cclass_notdigit, &cclass_digit);
    cclass_inv(&cclass_notdigit);
    cclass_opt(&cclass_notdigit);

    // Hex digit
    cclass_init(&cclass_xdigit);
    cclass_union(&cclass_xdigit, unicode("Nd") orelse unreachable);
    cclass_add(&cclass_xdigit, 'a', 'f');
    cclass_add(&cclass_xdigit, 'A', 'F');
    cclass_opt(&cclass_xdigit);

    // Punctuation
    cclass_init(&cclass_punct);
    cclass_union(&cclass_punct, unicode("P") orelse unreachable);
    cclass_opt(&cclass_punct);

    // Space
    cclass_init(&cclass_space);
    cclass_add(&cclass_space, '\t', '\t');
    cclass_add(&cclass_space, '\r', '\r');
    cclass_add(&cclass_space, '\n', '\n');
    cclass_add(&cclass_space, 0x0c, 0x0c); // form feed
    cclass_union(&cclass_space, unicode("Z") orelse unreachable);
    cclass_opt(&cclass_space);

    // Not space
    cclass_init(&cclass_notspace);
    cclass_union(&cclass_notspace, &cclass_space);
    cclass_inv(&cclass_notspace);
    cclass_opt(&cclass_notspace);

    // Blank
    cclass_init(&cclass_blank);
    cclass_add(&cclass_blank, '\t', '\t');
    cclass_union(&cclass_blank, unicode("Zs") orelse unreachable);
    cclass_opt(&cclass_blank);

    // Control
    cclass_init(&cclass_ctrl);
    cclass_union(&cclass_ctrl, unicode("C") orelse unreachable);
    cclass_union(&cclass_ctrl, unicode("Zl") orelse unreachable);
    cclass_union(&cclass_ctrl, unicode("Zp") orelse unreachable);
    cclass_opt(&cclass_ctrl);

    // Print
    cclass_init(&cclass_print);
    cclass_union(&cclass_print, unicode("L") orelse unreachable);
    cclass_union(&cclass_print, unicode("M") orelse unreachable);
    cclass_union(&cclass_print, unicode("S") orelse unreachable);
    cclass_union(&cclass_print, unicode("N") orelse unreachable);
    cclass_union(&cclass_print, unicode("P") orelse unreachable);
    cclass_union(&cclass_print, unicode("Zs") orelse unreachable);
    cclass_union(&cclass_print, unicode("Co") orelse unreachable);
    cclass_opt(&cclass_print);

    // Graph
    cclass_init(&cclass_graph);
    cclass_union(&cclass_graph, unicode("L") orelse unreachable);
    cclass_union(&cclass_graph, unicode("M") orelse unreachable);
    cclass_union(&cclass_graph, unicode("S") orelse unreachable);
    cclass_union(&cclass_graph, unicode("N") orelse unreachable);
    cclass_union(&cclass_graph, unicode("P") orelse unreachable);
    cclass_union(&cclass_print, unicode("Co") orelse unreachable);
    cclass_opt(&cclass_graph);

    // Not word
    cclass_init(&cclass_notword);
    cclass_union(&cclass_notword, unicode("C") orelse unreachable);
    cclass_union(&cclass_notword, unicode("P") orelse unreachable);
    cclass_union(&cclass_notword, unicode("Z") orelse unreachable);
    cclass_opt(&cclass_notword);

    // Word
    cclass_init(&cclass_word);
    cclass_union(&cclass_word, &cclass_notword);
    cclass_inv(&cclass_word);
    cclass_opt(&cclass_word);

    // Upper case conversion
    rmap_init(&rtree_toupper);
    {
        var xi: usize = 0;
        while (toupper_entry(xi).first != 0) : (xi += 1) {
            const e = toupper_entry(xi);
            rmap_add(&rtree_toupper, e.first, e.last,
                tup_cvt(xi) - e.first, 0);
        }
    }
    rmap_opt(&rtree_toupper);

    // Lower case conversion
    rmap_init(&rtree_tolower);
    {
        var xi: usize = 0;
        while (tolower_entry(xi).first != 0) : (xi += 1) {
            const e = tolower_entry(xi);
            rmap_add(&rtree_tolower, e.first, e.last,
                tlo_cvt(xi) - e.first, 0);
        }
    }
    rmap_opt(&rtree_tolower);

    // Case folding
    rmap_init(&rtree_fold);
    {
        var xi: usize = 0;
        while (fld_entry(xi).first != 0) : (xi += 1) {
            const e = fld_entry(xi);
            if (fld_repl_entry(xi)[1] != 0) {
                rmap_add(&rtree_fold, e.first, e.last,
                    FOLDMAGIC + @as(c_int, @intCast(xi)), 0);
            } else {
                rmap_add(&rtree_fold, e.first, e.last,
                    fld_repl_entry(xi)[0] - e.first, 0);
            }
        }
    }
    rmap_opt(&rtree_fold);

    // Combining
    cclass_init(&cclass_combining);
    cclass_union(&cclass_combining, unicode("Me") orelse unreachable);
    cclass_union(&cclass_combining, unicode("Mn") orelse unreachable);
    cclass_add(&cclass_combining, 0x1160, 0x11FF);
    cclass_opt(&cclass_combining);

    // Double-width
    cclass_init(&cclass_double);
    {
        var xi: usize = 0;
        while (wid_entry(xi).first != 0) : (xi += 1) {
            const e = wid_entry(xi);
            cclass_add(&cclass_double, e.first, e.last);
        }
    }
    cclass_opt(&cclass_double);
}

// ══════════════════════════════════════════════════════════════════════
// Unicode category lookup
// ══════════════════════════════════════════════════════════════════════

/// Get a Cclass containing all characters matching a Unicode category or block.
/// Matches C `unicode()` in joe/unicode.c: for a single-letter category like "L",
/// merge *all* matching two-letter categories (Ll, Lu, Lm, Lt, Lo), not just the first.
export fn unicode(cat: [*c]const u8) ?*Cclass {
    if (unicat_hash == null) {
        unicat_hash = htmk(256);
    }

    // Check cache
    if (htfind(unicat_hash.?, cat)) |cached| {
        return @alignCast(@ptrCast(cached));
    }

    const m = @as(?*Cclass, @alignCast(@ptrCast(joe_malloc(@sizeOf(Cclass)))));
    if (m == null) return null;
    const cc = m.?;
    cclass_init(cc);

    // Search the unicat table and merge every match (exact name or single-letter prefix)
    var xi: usize = 0;
    while (unicat_entry(xi).name != null) : (xi += 1) {
        const name = unicat_entry(xi).name;
        // Match exact category name, or single-letter prefix
        // (e.g. 'L' matches 'Ll', 'Lu', etc.)
        const cat_single = cat[0] != 0 and cat[1] == 0;
        const name_two = name[0] != 0 and name[1] != 0 and name[2] == 0;

        if (strcmp(name, cat) == 0 or (cat_single and cat[0] == name[0] and name_two)) {
            cclass_merge(cc, unicat_entry(xi).intervals, unicat_entry(xi).len);
        }
    }

    if (cc.len == 0) {
        joe_free(cc);
        return null;
    }

    cclass_opt(cc);
    _ = htadd(unicat_hash.?, zdup(cat), @alignCast(@ptrCast(cc)));
    return cc;
}

// ══════════════════════════════════════════════════════════════════════
// Character classification
// ══════════════════════════════════════════════════════════════════════

export fn joe_iswupper(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_upper, ch);
}

export fn joe_iswlower(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_lower, ch);
}

export fn joe_iswalpha(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_alpha, ch);
}

export fn joe_iswalpha_(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_alpha_, ch);
}

export fn joe_iswalnum(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_alnum, ch);
}

export fn joe_iswalnum_(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_alnum_, ch);
}

export fn joe_iswdigit(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_digit, ch);
}

export fn joe_iswxdigit(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_xdigit, ch);
}

export fn joe_iswpunct(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_punct, ch);
}

export fn joe_iswspace(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_space, ch);
}

export fn joe_iswblank(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_blank, ch);
}

export fn joe_iswctrl(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_ctrl, ch);
}

export fn joe_iswgraph(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_graph, ch);
}

export fn joe_iswprint(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return cclass_lookup(&cclass_print, ch);
}

// ══════════════════════════════════════════════════════════════════════
// Case conversion
// ══════════════════════════════════════════════════════════════════════

export fn joe_towlower(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return ch + rmap_lookup(&rtree_tolower, ch, 0);
}

export fn joe_towupper(foo: ?*Charmap, ch: c_int) c_int {
    _ = foo;
    return ch + rmap_lookup(&rtree_toupper, ch, 0);
}

// ══════════════════════════════════════════════════════════════════════
// Case folding (lowerize)
// ══════════════════════════════════════════════════════════════════════

/// Lowercase a Z-string (int array) in place.
/// `d` is the output buffer, `len` is its capacity, `s` is the input string.
export fn lowerize(d: [*c]c_int, len: isize, s: [*c]const c_int) [*c]c_int {
    const org = d;
    if (len == 0) return org;
    var remaining = len - 1;
    var src_idx: isize = 0;
    var dst_idx: isize = 0;

    while (remaining > 0 and s[@as(usize, @intCast(src_idx))] != 0) {
        const si = @as(usize, @intCast(src_idx));
        const idx = rmap_lookup(&rtree_fold, s[si], 0);
        if (idx < FOLDMAGIC) {
            d[@as(usize, @intCast(dst_idx))] = s[si] + idx;
            dst_idx += 1;
            src_idx += 1;
            remaining -= 1;
        } else {
            const repl_idx_i = idx - FOLDMAGIC;
            const ri = @as(usize, @intCast(repl_idx_i));
            src_idx += 1;
            d[@as(usize, @intCast(dst_idx))] = fld_repl_entry(ri)[0];
            dst_idx += 1;
            remaining -= 1;
            if (remaining > 0 and fld_repl_entry(ri)[1] != 0) {
                d[@as(usize, @intCast(dst_idx))] = fld_repl_entry(ri)[1];
                dst_idx += 1;
                remaining -= 1;
                if (remaining > 0 and fld_repl_entry(ri)[2] != 0) {
                    d[@as(usize, @intCast(dst_idx))] = fld_repl_entry(ri)[2];
                    dst_idx += 1;
                    remaining -= 1;
                }
            }
        }
    }
    d[@as(usize, @intCast(dst_idx))] = 0;
    return org;
}

// ══════════════════════════════════════════════════════════════════════
// Character width
// ══════════════════════════════════════════════════════════════════════

export fn joe_wcwidth(wide: c_int, ucs: c_int) c_int {
    // ANSI escape sequences have 0 width
    if (@as(u32, @bitCast(ucs)) & 0x80000000 != 0) return 0;

    // If terminal is not UTF-8 or file is not UTF-8: width is 1
    if (locale_map.type == 0 or wide == 0) return 1;

    var ch = ucs;
    if (ch < 0) ch += 256;

    if (cclass_lookup(&cclass_print, ch) == 0) {
        if (ch < 0x80) return 1;
        if (ch < 0x100) return 4;
        if (ch < 0x1000) return 5;
        if (ch < 0x10000) return 6;
        if (ch < 0x100000) return 7;
        if (ch < 0x1000000) return 8;
        if (ch < 0x10000000) return 9;
        return 10;
    }

    if (cclass_lookup(&cclass_combining, ch) != 0) return 0;
    if (cclass_lookup(&cclass_double, ch) != 0) return 2;
    return 1;
}

export fn joe_wcswidth(map: ?*Charmap, s: [*c]const u8, len: isize) isize {
    if (map) |m| {
        if (m.type == 0) return len;
    } else {
        return len;
    }

    var width: isize = 0;
    var remaining = len;
    var pos = s;

    while (remaining > 0) {
        const c = utf8_decode_fwrd(&pos, &remaining);
        if (c >= 0) {
            width += joe_wcwidth(1, c);
        } else {
            width += 1;
        }
    }
    return width;
}

export fn unictrl(ucs: c_int) c_int {
    return if (cclass_lookup(&cclass_print, ucs) != 0) 0 else 1;
}

export fn digval(ch: c_int) c_int {
    var xi: usize = 0;
    while (unicat_entry(xi).name != null) : (xi += 1) {
        if (strcmp(unicat_entry(xi).name, "Nd") == 0) {
            const idx = interval_test(unicat_entry(xi).intervals, unicat_entry(xi).len, ch);
            if (idx >= 0) {
                return ch - unicat_entry(xi).intervals[@as(usize, @intCast(idx))].first;
            }
            break;
        }
    }
    return -1;
}

// ══════════════════════════════════════════════════════════════════════
// Import utf8_decode_fwrd for joe_wcswidth
// ══════════════════════════════════════════════════════════════════════

extern "c" fn utf8_decode_fwrd(pos: *[*c]const u8, len: ?*isize) c_int;