//! Internal helpers: exported state, queue operations, gap buffer
//! primitives, and header/pointer allocation.
//!
//! Owns the module-level globals that `b.c` defined (`vmem`, `bufs`,
//! `stdbuf`, `force`, …) plus the free-list sentinels.

const types = @import("types.zig");
pub const H = types.H;
pub const P = types.P;
pub const B = types.B;
pub const Link = types.Link;
pub const SEGSIZ = types.SEGSIZ;

// ═══════════════════════════════════════════════════════════════════════
// Exported globals (matching b.c)
// ═══════════════════════════════════════════════════════════════════════

pub export var stdbuf: [31744]u8 = undefined;
pub export var guesscrlf: c_int = 0;
pub export var guessindent: c_int = 0;
pub export var berror: c_int = 0;
pub export var force: c_int = 0;
pub export var nodeadjoe: c_int = 0;
pub export var break_links: c_int = 0;
pub export var break_symlinks: c_int = 0;
pub export var guess_utf16: c_int = 0;

pub export var vmem: ?*anyopaque = null;

pub export var bufs: B = undefined;
var bufs_ok = false;

pub export var msgs: [7][*c]const u8 = .{
    "No error\x00", "New File\x00", "Error reading file\x00",
    "Error seeking file\x00", "Error opening file\x00",
    "Error writing file\x00", "File on disk is newer\x00",
};

// found_space / found_tab (used by guessindent in fileio.zig)
pub var found_space: c_int = 0;
pub var found_tab: c_int = 0;

// ═══════════════════════════════════════════════════════════════════════
// Extern C functions needed by internals
// ═══════════════════════════════════════════════════════════════════════

pub extern fn vlock(vfile: ?*anyopaque, addr: i64) ?*anyopaque;
pub extern fn my_valloc(vfile: ?*anyopaque, size: i64) i64;
pub extern fn vunlock_page(page_data: ?*anyopaque) void;
pub extern fn vchanged_page(page_data: ?*anyopaque) void;
pub extern fn vupcount_page(page_data: ?*anyopaque) void;

pub extern fn joe_malloc(size: isize) ?*anyopaque;
pub extern fn joe_realloc(ptr: ?*anyopaque, size: isize) ?*anyopaque;
pub extern fn joe_free(ptr: ?*anyopaque) void;
pub extern fn mset(dest: ?*anyopaque, c: u8, sz: isize) ?*anyopaque;
pub extern fn mcpy(a: ?*anyopaque, b: ?*const anyopaque, len: isize) ?*anyopaque;
pub extern fn mmove(d: ?*anyopaque, s: ?*const anyopaque, sz: isize) ?*anyopaque;
pub extern fn alitem(list: ?*anyopaque, itemsize: isize) ?*anyopaque;

pub extern fn undomk(b: ?*anyopaque) ?*anyopaque;
pub extern fn undorm(undo: ?*anyopaque) void;
pub extern fn undodel(undo: ?*anyopaque, pos: i64, b: ?*anyopaque) void;
pub extern fn undoins(undo: ?*anyopaque, p: ?*anyopaque, amnt: i64) void;
pub extern fn scrdel(b: ?*anyopaque, line: i64, nlines: i64, purg: c_int) void;
pub extern fn scrins(b: ?*anyopaque, line: i64, nlines: i64, purg: c_int) void;
pub extern fn abrerr(name: ?*anyopaque) void;
pub extern fn inserr(name: ?*anyopaque, line: i64, nlines: i64, purg: c_int) void;
pub extern fn delerr(name: ?*anyopaque, line: i64, nlines: i64) void;
pub extern fn lattr_ins(db: ?*anyopaque, line: i64, nlines: i64) void;
pub extern fn lattr_del(db: ?*anyopaque, line: i64, nlines: i64) void;
pub extern fn rm_all_lattr_db(db: ?*anyopaque) void;

pub extern fn joe_isblank(charmap: ?*anyopaque, c: c_int) c_int;
pub extern fn joe_wcwidth(dummy: c_int, c: c_int) c_int;
pub extern fn utf8_encode(buf: [*c]u8, c: c_int) isize;
pub extern fn zdup(s: ?*const anyopaque) ?*anyopaque;
pub extern fn strlen(s: [*c]const u8) usize;

// `joe_isalnum_` / `joe_tolower` are C macros that call through the charmap
// vtable.  Replicate that here by defining the relevant slice of
// `struct charmap` and invoking the function pointers.

const CharmapFn = ?*const fn (?*anyopaque, c_int) callconv(.c) c_int;

const Charmap = extern struct {
    next: ?*anyopaque,
    name: ?*const anyopaque,
    @"type": c_int,
    _pad: c_int,
    is_punct: CharmapFn,
    is_print: CharmapFn,
    is_space: CharmapFn,
    is_alpha_: CharmapFn,
    is_alnum_: CharmapFn,
    to_lower: CharmapFn,
    to_upper: CharmapFn,
};

pub fn joe_isalnum_v(map: ?*anyopaque, c: c_int) c_int {
    const m = @as(*const Charmap, @alignCast(@ptrCast(map orelse return 0)));
    if (m.is_alnum_) |f| return f(map, c);
    return 0;
}

pub fn joe_tolower_v(map: ?*anyopaque, c: c_int) c_int {
    const m = @as(*const Charmap, @alignCast(@ptrCast(map orelse return c)));
    if (m.to_lower) |f| return f(map, c);
    return c;
}

pub fn joe_toupper_v(map: ?*anyopaque, c: c_int) c_int {
    const m = @as(*const Charmap, @alignCast(@ptrCast(map orelse return c)));
    if (m.to_upper) |f| return f(map, c);
    return c;
}

/// `joe_wcwidth(1, c)` returning i64 for column arithmetic.
pub fn wcw(c: c_int) i64 {
    return @as(i64, @intCast(joe_wcwidth(1, c)));
}
pub extern fn set_file_pos(name: [*c]const u8, line: i64) void;
pub extern fn htmk(size: c_int) ?*anyopaque;
pub extern fn htfind(t: ?*anyopaque, s: [*c]const u8) ?*anyopaque;
pub extern fn htadd(t: ?*anyopaque, s: [*c]const u8, v: ?*anyopaque) void;
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
pub extern fn time(t: ?*i64) i64;
pub extern fn setopt(b: ?*anyopaque, name: [*c]const u8) void;

// ═══════════════════════════════════════════════════════════════════════
// Queue primitives (mirroring queue.h macros)
// ═══════════════════════════════════════════════════════════════════════

pub fn charmapIsUtf8(cm: ?*types.Charmap) bool {
    return if (cm) |m| m.@"type" != 0 else false;
}

pub fn ptrEq(a: anytype, b: anytype) bool { return @intFromPtr(a) == @intFromPtr(b); }

pub fn link2H(l: *Link) *H { return @as(*H, @ptrCast(l)); }
pub fn link2P(l: *Link) *P { return @as(*P, @ptrCast(l)); }
pub fn link2B(l: *Link) *B { return @as(*B, @ptrCast(l)); }
pub fn Hlink(h: *H) *Link { return @ptrCast(h); }
pub fn Plink(p: *P) *Link { return @ptrCast(p); }
pub fn Blink(b: *B) *Link { return @ptrCast(b); }

/// Cast an opaque link next/prev pointer to a typed struct pointer.
/// The link field is always at offset 0, so the cast is sound.
pub fn H_of(p: ?*anyopaque) *H { return @as(*H, @alignCast(@ptrCast(p.?))); }
pub fn P_of(p: ?*anyopaque) *P { return @as(*P, @alignCast(@ptrCast(p.?))); }
pub fn B_of(p: ?*anyopaque) *B { return @as(*B, @alignCast(@ptrCast(p.?))); }

pub fn izque(item: *Link) void { item.next = @ptrCast(item); item.prev = @ptrCast(item); }

pub fn deque_(item: *Link) void {
    const n: *Link = @alignCast(@ptrCast(item.next));
    const p: *Link = @alignCast(@ptrCast(item.prev));
    p.next = item.next;
    n.prev = item.prev;
}

pub fn enquef_(list: *Link, item: *Link) void {
    const n: *Link = @alignCast(@ptrCast(list.next));
    item.next = list.next;
    item.prev = @ptrCast(list);
    n.prev = @ptrCast(item);
    list.next = @ptrCast(item);
}

pub fn enqueb_(list: *Link, item: *Link) void {
    const p: *Link = @alignCast(@ptrCast(list.prev));
    item.next = @ptrCast(list);
    item.prev = list.prev;
    p.next = @ptrCast(item);
    list.prev = @ptrCast(item);
}

pub fn qempty_(list: *Link) bool { return @intFromPtr(list.next) == @intFromPtr(list); }

pub fn splicef_(list: *Link, chain: *Link) void {
    const last: *Link = @alignCast(@ptrCast(chain.prev));
    const n: *Link = @alignCast(@ptrCast(list.next));
    last.next = list.next;
    chain.prev = @ptrCast(list);
    n.prev = @ptrCast(chain);
    list.next = @ptrCast(chain);
}

/// spliceb_f returns the chain head (first element) — matches C macro
pub fn spliceb_f_(list: *Link, chain: *Link) *Link {
    const last: *Link = @alignCast(@ptrCast(chain.prev));
    const p: *Link = @alignCast(@ptrCast(list.prev));
    last.next = @ptrCast(list);
    chain.prev = list.prev;
    p.next = @ptrCast(chain);
    list.prev = @ptrCast(last);
    return chain;
}

pub fn snip_(first: *Link, last: *Link) void {
    const ln: *Link = @alignCast(@ptrCast(last.next));
    const fp: *Link = @alignCast(@ptrCast(first.prev));
    ln.prev = first.prev;
    fp.next = last.next;
    first.prev = @ptrCast(last);
    last.next = @ptrCast(first);
}

pub fn demote_(list: *Link, item: *Link) void { deque_(item); enqueb_(list, item); }

// ═══════════════════════════════════════════════════════════════════════
// Gap buffer primitives (C macros GGAPSZ / GSIZE / GCHAR / gstgap / ginsm / grmem)
// ═══════════════════════════════════════════════════════════════════════

pub fn ggapsz(h: *H) i16 { return @as(i16, h.ehole) - @as(i16, h.hole); }
pub fn gsize_(h: *H) i16 { return @as(i16, @intCast(SEGSIZ)) - ggapsz(h); }

pub fn gchar(p: *P) u8 {
    const ofst = @as(u16, @bitCast(p.ofst));
    const hole = @as(u16, @bitCast(p.hdr.?.hole));
    const ehole = @as(u16, @bitCast(p.hdr.?.ehole));
    const ptr: [*]u8 = @ptrCast(p.ptr.?);
    return if (ofst >= hole) ptr[ofst + (ehole - hole)] else ptr[ofst];
}

pub fn gstgap(hdr: *H, ptr: ?*anyopaque, ofst: i16) void {
    if (ofst > hdr.hole) {
        _ = mmove(@ptrFromInt(@intFromPtr(ptr) + @as(usize, @intCast(hdr.hole))),
                  @ptrFromInt(@intFromPtr(ptr) + @as(usize, @intCast(hdr.ehole))),
                  @as(isize, @intCast(ofst - hdr.hole)));
        vchanged_page(ptr);
    } else if (ofst < hdr.hole) {
        _ = mmove(@ptrFromInt(@intFromPtr(ptr) + @as(usize, @intCast(hdr.ehole - (hdr.hole - ofst)))),
                  @ptrFromInt(@intFromPtr(ptr) + @as(usize, @intCast(ofst))),
                  @as(isize, @intCast(hdr.hole - ofst)));
        vchanged_page(ptr);
    }
    hdr.ehole = ofst + hdr.ehole - hdr.hole;
    hdr.hole = ofst;
}

pub fn ginsm(hdr: *H, ptr: ?*anyopaque, ofst: i16, blk: ?*const anyopaque, size: i16) void {
    if (ofst != hdr.hole) gstgap(hdr, ptr, ofst);
    _ = mmove(@ptrFromInt(@intFromPtr(ptr) + @as(usize, @intCast(hdr.hole))), blk, @as(isize, @intCast(size)));
    hdr.hole += size;
    vchanged_page(ptr);
}

pub fn grmem(hdr: *H, ptr: ?*anyopaque, ofst: i16, blk: ?*anyopaque, size: i16) void {
    if (ofst < hdr.hole) {
        if (size > hdr.hole - ofst) {
            _ = mmove(blk, @ptrFromInt(@intFromPtr(ptr) + @as(usize, @intCast(ofst))), @as(isize, @intCast(hdr.hole - ofst)));
            _ = mmove(@ptrFromInt(@intFromPtr(blk) + @as(usize, @intCast(hdr.hole - ofst))),
                      @ptrFromInt(@intFromPtr(ptr) + @as(usize, @intCast(hdr.ehole))),
                      @as(isize, @intCast(size - (hdr.hole - ofst))));
        } else {
            _ = mmove(blk, @ptrFromInt(@intFromPtr(ptr) + @as(usize, @intCast(ofst))), @as(isize, @intCast(size)));
        }
    } else {
        _ = mmove(blk, @ptrFromInt(@intFromPtr(ptr) + @as(usize, @intCast(ofst + (hdr.ehole - hdr.hole)))), @as(isize, @intCast(size)));
    }
}

pub fn count_nl(blk: ?*const anyopaque, len: isize) isize {
    const b = @as([*]const u8, @ptrCast(blk));
    var cnt: isize = 0;
    var i: usize = 0;
    while (i < @as(usize, @intCast(len))) : (i += 1) {
        if (b[i] == '\n') cnt += 1;
    }
    return cnt;
}

// ═══════════════════════════════════════════════════════════════════════
// Free-list sentinels + lazy initializers
// ═══════════════════════════════════════════════════════════════════════

var nhdrs: H = undefined;          var nhdrs_ok = false;
var ohdrs: H = undefined;          var ohdrs_ok = false;
var frptrs: P = undefined;         var frptrs_ok = false;
pub var frebufs_sentinel: B = undefined; var frebufs_ok = false;

fn blankH() H {
    return .{ .link = .{ .next = undefined, .prev = undefined }, .seg = 0, .hole = 0, .ehole = 0, .nlines = 0, .extra = 0 };
}

pub fn ensureNhdr() void {
    if (!nhdrs_ok) {
        nhdrs = blankH();
        nhdrs.link.next = @ptrCast(&nhdrs);
        nhdrs.link.prev = @ptrCast(&nhdrs);
        nhdrs_ok = true;
    }
}
pub fn ensureOhdr() void {
    if (!ohdrs_ok) {
        ohdrs = blankH();
        ohdrs.link.next = @ptrCast(&ohdrs);
        ohdrs.link.prev = @ptrCast(&ohdrs);
        ohdrs_ok = true;
    }
}
pub fn ensureFrptrs() void {
    if (!frptrs_ok) {
        frptrs = .{ .link = .{ .next = @ptrCast(&frptrs), .prev = @ptrCast(&frptrs) }, .b = null, .ofst = 0, ._pad0 = undefined, .ptr = null, .hdr = null, .byte = 0, .line = 0, .col = 0, .xcol = 0, .valcol = 0, .end = 0, .attr = 0, .valattr = 0, .owner = null, .tracker = null };
        frptrs_ok = true;
    }
}
pub fn ensureFrebufs() void {
    if (!frebufs_ok) {
        frebufs_sentinel = .{ .link = .{ .next = @ptrCast(&frebufs_sentinel), .prev = @ptrCast(&frebufs_sentinel) }, .bof = null, .eof = null, .name = null, .locked = 0, .ignored_lock = 0, .didfirst = 0, ._pad0 = 0, .mod_time = 0, .check_time = 0, .gave_notice = 0, .orphan = 0, .count = 0, .changed = 0, .backup = 0, ._pad1 = 0, .undo = null, .marks = [_]?*P{null} ** 11, .o = undefined, .oldcur = null, .oldtop = null, .err = null, .current_dir = null, .shell_flag = 0, .rdonly = 0, .internal = 0, .scratch = 0, .er = 0, .pid = 0, .out = 0, .vt = null, .raw = 0, ._pad2 = 0, .db = null, .parseone = null };
        frebufs_ok = true;
    }
}
pub fn ensureBufs() *B {
    if (!bufs_ok) {
        bufs = .{ .link = .{ .next = @ptrCast(&bufs), .prev = @ptrCast(&bufs) }, .bof = null, .eof = null, .name = null, .locked = 0, .ignored_lock = 0, .didfirst = 0, ._pad0 = 0, .mod_time = 0, .check_time = 0, .gave_notice = 0, .orphan = 0, .count = 0, .changed = 0, .backup = 0, ._pad1 = 0, .undo = null, .marks = [_]?*P{null} ** 11, .o = undefined, .oldcur = null, .oldtop = null, .err = null, .current_dir = null, .shell_flag = 0, .rdonly = 0, .internal = 0, .scratch = 0, .er = 0, .pid = 0, .out = 0, .vt = null, .raw = 0, ._pad2 = 0, .db = null, .parseone = null };
        bufs_ok = true;
    }
    return &bufs;
}

// ═══════════════════════════════════════════════════════════════════════
// Header / pointer allocation
// ═══════════════════════════════════════════════════════════════════════

pub fn halloc() *H {
    ensureNhdr();
    ensureOhdr();
    if (!qempty_(Hlink(&ohdrs))) {
        const lnk = @as(*Link, @alignCast(@ptrCast(ohdrs.link.next)));
        deque_(lnk);
        const h = link2H(lnk);
        h.hole = 0;
        h.ehole = SEGSIZ;
        h.nlines = 0;
        h.extra = 0;
        izque(Hlink(h));
        return h;
    }
    return hallocFresh();
}

/// Always allocate a brand-new header+segment, bypassing the ohdrs freelist.
pub fn hallocFresh() *H {
    ensureNhdr();
    const ptr = alitem(Hlink(&nhdrs), @sizeOf(H)) orelse unreachable;
    const h = @as(*H, @alignCast(@ptrCast(ptr)));
    h.seg = my_valloc(vmem, SEGSIZ);
    h.hole = 0;
    h.ehole = SEGSIZ;
    h.nlines = 0;
    h.extra = 0;
    izque(Hlink(h));
    return h;
}

pub fn hfree(h: *H) void {
    enquef_(Hlink(&ohdrs), Hlink(h));
}

pub fn hfreechn(h: *H) void {
    splicef_(Hlink(&ohdrs), Hlink(h));
}

pub fn palloc() *P {
    ensureFrptrs();
    return @as(*P, @alignCast(@ptrCast(alitem(Plink(&frptrs), @sizeOf(P)) orelse unreachable)));
}
pub fn pfree(p: *P) void { enquef_(Plink(&frptrs), Plink(p)); }

/// `zlen(s)` = `strlen(s)` as isize (matches the C macro).
pub fn zlen(s: ?*const anyopaque) isize {
    return @as(isize, @intCast(strlen(@ptrCast(s))));
}
