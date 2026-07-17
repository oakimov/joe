//! Simple hash tables — replaces `joe/hash.c`
//!
//! Provides three hash table variants:
//! - HASH:  string → void*        (htadd / htfind / htmk / htrm)
//! - CHASH: string → const void*  (chtadd / chtfind / chtmk / chtrm)
//! - ZHASH: int[] → void*         (Zhtadd / Zhtfind / Zhtmk / Zhtrm)
//! Plus interned‑string (atom) tables for both character and integer strings.

const std = @import("std");

// ═══════════════════════════════════════════════════════════════════════
// Extern C functions
// ═══════════════════════════════════════════════════════════════════════

extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn joe_calloc(cnt: isize, size: isize) ?*anyopaque;
extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;

extern fn Zcmp(a: [*c]const c_int, b: [*c]const c_int) c_int;
extern fn zdup(s: [*c]const u8) [*c]u8;
extern fn Zdup(s: [*c]const c_int) [*c]c_int;

// ═══════════════════════════════════════════════════════════════════════
// C‑compatible structs
// ═══════════════════════════════════════════════════════════════════════

/// HASH entry — C `struct entry`
const HENTRY = extern struct {
    next: ?*HENTRY,
    name: ?*anyopaque,
    hash_val: isize,
    val: ?*anyopaque,
};

/// HASH table — C `struct Hash`
const HASH = extern struct {
    len: isize,
    tab: [*]?*HENTRY,
    nentries: isize,
};

/// CHASH entry — C `struct centry`
const CHENTRY = extern struct {
    next: ?*CHENTRY,
    name: ?*anyopaque,
    hash_val: isize,
    val: ?*const anyopaque,
};

/// CHASH table — C `struct CHash`
const CHASH = extern struct {
    len: isize,
    tab: [*]?*CHENTRY,
    nentries: isize,
};

/// ZHASH entry — C `struct Zentry`
const ZHENTRY = extern struct {
    next: ?*ZHENTRY,
    name: ?*anyopaque,
    hash_val: isize,
    val: ?*anyopaque,
};

/// ZHASH table — C `struct Zhash`
const ZHASH = extern struct {
    len: isize,
    tab: [*]?*ZHENTRY,
    nentries: isize,
};

// ═══════════════════════════════════════════════════════════════════════
// Constants
// ═══════════════════════════════════════════════════════════════════════

const HINIT: isize = 5381;
fn hnext(accu: isize, c: u8) isize {
    return ((accu << 5) +% accu) ^ @as(isize, @intCast(c));
}

// ═══════════════════════════════════════════════════════════════════════
// Module‑level free lists
// ═══════════════════════════════════════════════════════════════════════

var freentry: ?*HENTRY = null;
var cfreentry: ?*CHENTRY = null;
var zfreentry: ?*ZHENTRY = null;

// ═══════════════════════════════════════════════════════════════════════
// HASH (string → void*)
// ═══════════════════════════════════════════════════════════════════════

export fn hash(s: [*c]const u8) isize {
    var accu: isize = HINIT;
    var i: usize = 0;
    while (s[i] != 0) : (i += 1) {
        accu = hnext(accu, s[i]);
    }
    return accu;
}

export fn htmk(len: isize) ?*anyopaque {
    const t = @as(*HASH, @alignCast(@ptrCast(joe_malloc(@sizeOf(HASH)) orelse return null)));
    t.len = len;
    t.nentries = 0;
    t.tab = @alignCast(@ptrCast(joe_calloc(len, @sizeOf(?*HENTRY))));
    return @alignCast(@ptrCast(t));
}

export fn htrm(ht: ?*anyopaque) void {
    const h = @as(*HASH, @alignCast(@ptrCast(ht)));
    for (0..@as(usize, @intCast(h.len))) |x| {
        var p = h.tab[x];
        while (p) |entry| {
            const nxt = entry.next;
            entry.next = freentry;
            freentry = entry;
            p = nxt;
        }
    }
    joe_free(@as(?*anyopaque, @ptrCast(h.tab)));
    joe_free(h);
}

fn htexpand(h: *HASH) void {
    const new_size = h.len * 2;
    const new_table = @as([*]?*HENTRY, @alignCast(@ptrCast(joe_calloc(new_size, @sizeOf(?*HENTRY)) orelse return)));
    for (0..@as(usize, @intCast(h.len))) |x| {
        while (h.tab[x]) |e| {
            h.tab[x] = e.next;
            e.next = new_table[@as(usize, @intCast(e.hash_val & (new_size - 1)))];
            new_table[@as(usize, @intCast(e.hash_val & (new_size - 1)))] = e;
        }
    }
    joe_free(@as(?*anyopaque, @ptrCast(h.tab)));
    h.tab = @alignCast(@ptrCast(new_table));
    h.len = new_size;
}

export fn htadd(ht: ?*anyopaque, name: ?*anyopaque, val: ?*anyopaque) ?*anyopaque {
    const h = @as(*HASH, @alignCast(@ptrCast(ht)));
    const namestr = @as([*c]const u8, @ptrCast(name));
    const hval = hash(namestr);
    const idx = @as(usize, @intCast(hval & (h.len - 1)));
    var entry: *HENTRY = undefined;
    if (freentry) |fe| {
        entry = fe;
        freentry = fe.next;
    } else {
        const block = @as([*]HENTRY, @alignCast(@ptrCast(joe_malloc(@sizeOf(HENTRY) * 64) orelse return null)));
        for (1..64) |x| {
            block[x - 1].next = &block[x];
        }
        block[63].next = freentry;
        freentry = &block[1];
        entry = &block[0];
    }
    entry.next = h.tab[idx];
    h.tab[idx] = entry;
    entry.name = name;
    entry.hash_val = hval;
    entry.val = val;
    h.nentries += 1;
    if (h.nentries == (h.len >> 1) + (h.len >> 2)) htexpand(h);
    return val;
}

export fn htfind(ht: ?*anyopaque, name: [*c]const u8) ?*anyopaque {
    const h = @as(*HASH, @alignCast(@ptrCast(ht)));
    const hval = hash(name);
    const idx = @as(usize, @intCast(hval & (h.len - 1)));
    var e = h.tab[idx];
    while (e) |entry| {
        if (strcmp(@ptrCast(entry.name), name) == 0) return entry.val;
        e = entry.next;
    }
    return null;
}

// ═══════════════════════════════════════════════════════════════════════
// CHASH (string → const void*)
// ═══════════════════════════════════════════════════════════════════════

export fn chtmk(len: isize) ?*anyopaque {
    const t = @as(*CHASH, @alignCast(@ptrCast(joe_malloc(@sizeOf(CHASH)) orelse return null)));
    t.len = len;
    t.nentries = 0;
    t.tab = @alignCast(@ptrCast(joe_calloc(len, @sizeOf(?*CHENTRY))));
    return @alignCast(@ptrCast(t));
}

export fn chtrm(ht: ?*anyopaque) void {
    const h = @as(*CHASH, @alignCast(@ptrCast(ht)));
    for (0..@as(usize, @intCast(h.len))) |x| {
        var p = h.tab[x];
        while (p) |entry| {
            const nxt = entry.next;
            entry.next = cfreentry;
            cfreentry = entry;
            p = nxt;
        }
    }
    joe_free(@as(?*anyopaque, @ptrCast(h.tab)));
    joe_free(h);
}

fn chtexpand(h: *CHASH) void {
    const new_size = h.len * 2;
    const new_table = @as([*]?*CHENTRY, @alignCast(@ptrCast(joe_calloc(new_size, @sizeOf(?*CHENTRY)) orelse return)));
    for (0..@as(usize, @intCast(h.len))) |x| {
        while (h.tab[x]) |e| {
            h.tab[x] = e.next;
            e.next = new_table[@as(usize, @intCast(e.hash_val & (new_size - 1)))];
            new_table[@as(usize, @intCast(e.hash_val & (new_size - 1)))] = e;
        }
    }
    joe_free(@as(?*anyopaque, @ptrCast(h.tab)));
    h.tab = @alignCast(@ptrCast(new_table));
    h.len = new_size;
}

export fn chtadd(ht: ?*anyopaque, name: ?*anyopaque, val: ?*const anyopaque) ?*const anyopaque {
    const h = @as(*CHASH, @alignCast(@ptrCast(ht)));
    const namestr = @as([*c]const u8, @ptrCast(name));
    const hval = hash(namestr);
    const idx = @as(usize, @intCast(hval & (h.len - 1)));
    var entry: *CHENTRY = undefined;
    if (cfreentry) |fe| {
        entry = fe;
        cfreentry = fe.next;
    } else {
        const block = @as([*]CHENTRY, @alignCast(@ptrCast(joe_malloc(@sizeOf(CHENTRY) * 64) orelse return null)));
        for (1..64) |x| {
            block[x - 1].next = &block[x];
        }
        block[63].next = cfreentry;
        cfreentry = &block[1];
        entry = &block[0];
    }
    entry.next = h.tab[idx];
    h.tab[idx] = entry;
    entry.name = name;
    entry.hash_val = hval;
    entry.val = val;
    h.nentries += 1;
    if (h.nentries == (h.len >> 1) + (h.len >> 2)) chtexpand(h);
    return val;
}

export fn chtfind(ht: ?*anyopaque, name: [*c]const u8) ?*const anyopaque {
    const h = @as(*CHASH, @alignCast(@ptrCast(ht)));
    const hval = hash(name);
    const idx = @as(usize, @intCast(hval & (h.len - 1)));
    var e = h.tab[idx];
    while (e) |entry| {
        if (strcmp(@ptrCast(entry.name), name) == 0) return entry.val;
        e = entry.next;
    }
    return null;
}

// ═══════════════════════════════════════════════════════════════════════
// Atom (interned string) tables — character strings
// ═══════════════════════════════════════════════════════════════════════

var atom_table: ?*anyopaque = null;

export fn atom_add(name: [*c]const u8) [*c]const u8 {
    if (atom_table == null) atom_table = htmk(256);
    var s = @as([*c]u8, @ptrCast(htfind(atom_table, name)));
    if (s == null) {
        s = zdup(name);
        _ = htadd(atom_table, @ptrCast(s), @ptrCast(s));
    }
    return s;
}

export fn atom_noadd(name: [*c]const u8) [*c]const u8 {
    if (atom_table == null) atom_table = htmk(256);
    return @as([*c]const u8, @ptrCast(htfind(atom_table, name)));
}

// ═══════════════════════════════════════════════════════════════════════
// ZHASH (int[] → void*)
// ═══════════════════════════════════════════════════════════════════════

fn zhash(s: [*c]const c_int) isize {
    var accu: isize = HINIT;
    var i: usize = 0;
    while (s[i] != 0) : (i += 1) {
        accu = ((accu << 5) +% accu) ^ @as(isize, @intCast(s[i]));
    }
    return accu;
}

export fn Zhtmk(len: isize) ?*anyopaque {
    const t = @as(*ZHASH, @alignCast(@ptrCast(joe_malloc(@sizeOf(ZHASH)) orelse return null)));
    t.len = len;
    t.nentries = 0;
    t.tab = @alignCast(@ptrCast(joe_calloc(len, @sizeOf(?*ZHENTRY))));
    return @alignCast(@ptrCast(t));
}

export fn Zhtrm(ht: ?*anyopaque) void {
    const h = @as(*ZHASH, @alignCast(@ptrCast(ht)));
    for (0..@as(usize, @intCast(h.len))) |x| {
        var p = h.tab[x];
        while (p) |entry| {
            const nxt = entry.next;
            entry.next = zfreentry;
            zfreentry = entry;
            p = nxt;
        }
    }
    joe_free(@as(?*anyopaque, @ptrCast(h.tab)));
    joe_free(h);
}

fn Zhtexpand(h: *ZHASH) void {
    const new_size = h.len * 2;
    const new_table = @as([*]?*ZHENTRY, @alignCast(@ptrCast(joe_calloc(new_size, @sizeOf(?*ZHENTRY)) orelse return)));
    for (0..@as(usize, @intCast(h.len))) |x| {
        while (h.tab[x]) |e| {
            h.tab[x] = e.next;
            e.next = new_table[@as(usize, @intCast(e.hash_val & (new_size - 1)))];
            new_table[@as(usize, @intCast(e.hash_val & (new_size - 1)))] = e;
        }
    }
    joe_free(@as(?*anyopaque, @ptrCast(h.tab)));
    h.tab = @alignCast(@ptrCast(new_table));
    h.len = new_size;
}

export fn Zhtadd(ht: ?*anyopaque, name: ?*anyopaque, val: ?*anyopaque) ?*anyopaque {
    const h = @as(*ZHASH, @alignCast(@ptrCast(ht)));
    const namestr = @as([*c]const c_int, @alignCast(@ptrCast(name)));
    const hval = zhash(namestr);
    const idx = @as(usize, @intCast(hval & (h.len - 1)));
    var entry: *ZHENTRY = undefined;
    if (zfreentry) |fe| {
        entry = fe;
        zfreentry = fe.next;
    } else {
        const block = @as([*]ZHENTRY, @alignCast(@ptrCast(joe_malloc(@sizeOf(ZHENTRY) * 64) orelse return null)));
        for (1..64) |x| {
            block[x - 1].next = &block[x];
        }
        block[63].next = zfreentry;
        zfreentry = &block[1];
        entry = &block[0];
    }
    entry.next = h.tab[idx];
    h.tab[idx] = entry;
    entry.name = name;
    entry.hash_val = hval;
    entry.val = val;
    h.nentries += 1;
    if (h.nentries == (h.len >> 1) + (h.len >> 2)) Zhtexpand(h);
    return val;
}

export fn Zhtfind(ht: ?*anyopaque, name: [*c]const c_int) ?*anyopaque {
    const h = @as(*ZHASH, @alignCast(@ptrCast(ht)));
    const hval = zhash(name);
    const idx = @as(usize, @intCast(hval & (h.len - 1)));
    var e = h.tab[idx];
    while (e) |entry| {
        if (Zcmp(@alignCast(@ptrCast(entry.name)), name) == 0) return entry.val;
        e = entry.next;
    }
    return null;
}

// ═══════════════════════════════════════════════════════════════════════
// Zatom tables — interned integer‑string tables
// ═══════════════════════════════════════════════════════════════════════

var Zatom_table: ?*anyopaque = null;

export fn Zatom_add(name: [*c]const c_int) [*c]const c_int {
    if (Zatom_table == null) Zatom_table = Zhtmk(256);
    var s = @as([*c]c_int, @alignCast(@ptrCast(Zhtfind(Zatom_table, name))));
    if (s == null) {
        s = Zdup(name);
        _ = Zhtadd(Zatom_table, @ptrCast(s), @ptrCast(s));
    }
    return s;
}

export fn Zatom_noadd(name: [*c]const c_int) [*c]const c_int {
    if (Zatom_table == null) Zatom_table = Zhtmk(256);
    return @as([*c]const c_int, @alignCast(@ptrCast(Zhtfind(Zatom_table, name))));
}

// ═══════════════════════════════════════════════════════════════════════
// Compile‑time verifications
// ═══════════════════════════════════════════════════════════════════════

comptime {
    std.debug.assert(@sizeOf(HENTRY) == 32);
    std.debug.assert(@sizeOf(HASH) == 24);
    std.debug.assert(@sizeOf(CHENTRY) == 32);
    std.debug.assert(@sizeOf(CHASH) == 24);
    std.debug.assert(@sizeOf(ZHENTRY) == 32);
    std.debug.assert(@sizeOf(ZHASH) == 24);
}
