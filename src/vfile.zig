//! Software virtual memory system for JOE editor
//!
//! Port of `joe/vfile.c` to Zig.
//!
//! Provides a page-cache-based virtual file system: fixed-size pages
//! (PGSIZE = 4096) are allocated on demand, backed by temporary files
//! when memory pressure requires eviction.  The interface is used by
//! the gap buffer (b.c) and main.c.

const std = @import("std");

// ═══════════════════════════════════════════════════════════════════════
// Constants
// ═══════════════════════════════════════════════════════════════════════

const LPGSIZE: c_int = 12;
const PGSIZE: c_int = 1 << LPGSIZE; // 4096
const NPAGES: c_int = 8192;
const ILIMIT: c_int = PGSIZE * NPAGES; // 33,554,432
const HTSIZE: c_int = NPAGES * 2; // 16384
const INC: c_int = 16;

/// C's ((unsigned long long)-1L)/2 - 1 (= MAXLONGLONG).
const MAXOFF: i64 = std.math.maxInt(u64) / 2 - 1;

/// O_RDWR from <fcntl.h> on POSIX.
const O_RDWR: c_int = 2;

// ═══════════════════════════════════════════════════════════════════════
// External C functions
// ═══════════════════════════════════════════════════════════════════════

extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn joe_realloc(ptr: ?*anyopaque, size: isize) ?*anyopaque;
extern fn joe_free(ptr: ?*anyopaque) void;
extern fn joe_read(fd: c_int, buf: ?*anyopaque, siz: isize) isize;
extern fn joe_write(fd: c_int, buf: ?*const anyopaque, siz: isize) isize;
extern fn mset(dest: ?*anyopaque, c: u8, sz: isize) ?*anyopaque;
extern fn mcpy(a: ?*anyopaque, b: ?*const anyopaque, len: isize) ?*anyopaque;
extern fn mmove(d: ?*anyopaque, s: ?*const anyopaque, sz: isize) ?*anyopaque;
extern fn ttsig(sig: c_int) void;
extern fn mktmp(where_opt: ?*anyopaque) ?*anyopaque;
extern fn open(path: [*c]const u8, flags: c_int, ...) c_int;
extern fn lseek(fd: c_int, offset: i64, whence: c_int) i64;
extern fn close(fd: c_int) c_int;
extern fn unlink(path: [*c]const u8) c_int;
extern fn random() c_long;
extern fn exit(status: c_int) noreturn;

// ═══════════════════════════════════════════════════════════════════════
// C-compatible struct layouts
// ═══════════════════════════════════════════════════════════════════════

/// Doubly linked list link — mirrors C `LINK(VFILE)`.
const Link = extern struct {
    next: ?*VFILE,
    prev: ?*VFILE,
};

/// Virtual memory page header — mirrors C `struct vpage`.
const VPAGE = extern struct {
    next: ?*VPAGE,
    vfile: ?*VFILE,
    addr: i64, // off_t
    count: c_int,
    dirty: c_int,
    data: ?*anyopaque,
};

/// Virtual file descriptor — mirrors C `struct vfile`.
const VFILE = extern struct {
    link: Link,
    size: i64,
    alloc: i64,
    fd: c_int,
    writeable: c_int,
    name: ?*anyopaque,
    flags: c_int,
    // 4-byte padding follows on LP64 (vpage1 must be 8-byte aligned)
    vpage1: ?*anyopaque,
    addr: i64,
    bufp: ?*anyopaque,
    vpage: ?*anyopaque,
    left: isize, // ptrdiff_t
    lv: isize, // ptrdiff_t
};

// ═══════════════════════════════════════════════════════════════════════
// Module-level state
// ═══════════════════════════════════════════════════════════════════════

/// Sentinel node for the VFILE doubly-linked list (circular).
var vfile_sentinel: VFILE linksection("__DATA,__joe_vfsent") = undefined;
var vfile_sentinel_ready: bool = false;

/// Free page list.
var freepages: ?*VPAGE = null;

/// Hash table of active page headers.
var htab: [@as(usize, HTSIZE)]?*VPAGE = [_]?*VPAGE{null} ** @as(usize, HTSIZE);

/// Total physical memory allocated for page data.
var curvalloc: c_long = 0;
/// Upper bound on `curvalloc`.
var maxvalloc: c_long = ILIMIT;

/// Base address of the lowest allocated page — used by the C `vheader()` macro.
export var vbase: ?*anyopaque = null;
/// Array mapping physical-page offsets to `VPAGE*` — used by `vheader()`.
export var vheaders: ?*anyopaque = null;
/// Number of slots currently allocated in `vheaders`.
var vheadsz: isize = 0;

// ═══════════════════════════════════════════════════════════════════════
// Internal helpers
// ═══════════════════════════════════════════════════════════════════════

/// Ensure the VFILE sentinel is initialised.
fn ensureSentinel() void {
    if (!vfile_sentinel_ready) {
        vfile_sentinel = VFILE{
            .link = .{
                .next = &vfile_sentinel,
                .prev = &vfile_sentinel,
            },
            .size = 0,
            .alloc = 0,
            .fd = 0,
            .writeable = 0,
            .name = null,
            .flags = 0,
            .vpage1 = null,
            .addr = 0,
            .bufp = null,
            .vpage = null,
            .left = 0,
            .lv = 0,
        };
        vfile_sentinel_ready = true;
    }
}

/// Insert `vf` at the tail of the global VFILE list.
fn listAdd(vf: *VFILE) void {
    ensureSentinel();
    const list = &vfile_sentinel;
    vf.link.next = list;
    vf.link.prev = list.link.prev;
    list.link.prev.?.link.next = vf;
    list.link.prev = vf;
}

/// Remove `vf` from whichever list it belongs to.
fn listRemove(vf: *VFILE) void {
    vf.link.prev.?.link.next = vf.link.next;
    vf.link.next.?.link.prev = vf.link.prev;
}

/// Compute the effective size of a VFILE — mirrors C `vsize(vfile)`.
fn vsize(vf: *const VFILE) i64 {
    if (vf.left < vf.lv) {
        return vf.alloc + @as(i64, @intCast(vf.lv)) - @as(i64, @intCast(vf.left));
    }
    return vf.alloc;
}

/// Aligned allocation: allocate `align + size` bytes, return a pointer
/// whose address is a multiple of `align`.  Mirrors C `mema()`.
fn memAlign(alignment: isize, size: isize) ?*anyopaque {
    const z = @as([*]u8, @ptrCast(joe_malloc(alignment + size) orelse return null));
    const addr = @intFromPtr(z);
    const misalign = addr % @as(usize, @intCast(alignment));
    const aligned = if (misalign == 0) addr + @as(usize, @intCast(alignment)) else addr + @as(usize, @intCast(alignment)) - misalign;
    return @ptrFromInt(aligned);
}

/// Try to evict one clean, unreferenced page from the hash table.
/// Starts at a random bucket and probes linearly.
fn evictOne() ?*VPAGE {
    const start = @as(usize, @intCast(random() & @as(c_long, @intCast(HTSIZE - 1))));
    var bucket = start;
    var remain: usize = HTSIZE;
    while (remain > 0) : ({
        bucket = (bucket + 1) & @as(usize, HTSIZE - 1);
        remain -= 1;
    }) {
        var prev: ?*VPAGE = null;
        var vp = htab[bucket];
        while (vp) |page| {
            const nxt = page.next;
            if (page.count == 0 and page.dirty == 0) {
                // Unlink from chain.
                if (prev) |p| {
                    p.next = nxt;
                } else {
                    htab[bucket] = nxt;
                }
                return page;
            }
            prev = page;
            vp = nxt;
        }
    }
    return null;
}

// ═══════════════════════════════════════════════════════════════════════
// Exported API
// ═══════════════════════════════════════════════════════════════════════

/// Flush all dirty pages for every open VFILE to disk.
export fn vflsh() void {
    ensureSentinel();
    var vf = vfile_sentinel.link.next;
    while (vf != &vfile_sentinel) : (vf = vf.?.link.next) {
        const file = vf orelse continue;

        var last: i64 = -1;
        while (true) {
            var best_addr: i64 = MAXOFF;
            var best: ?*VPAGE = null;

            for (&htab) |maybe_bucket| {
                var vp = maybe_bucket;
                while (vp) |page| : (vp = page.next) {
                    if (page.addr < best_addr and
                        page.addr > last and
                        page.vfile == file and
                        (page.addr >= file.size or (page.dirty != 0 and page.count == 0)))
                    {
                        best_addr = page.addr;
                        best = page;
                    }
                }
            }

            const page = best orelse break;

            // Ensure a backing file exists.
            if (file.name == null) {
                file.name = mktmp(null);
            }
            if (file.fd == 0) {
                file.fd = open(@as([*c]const u8, @ptrCast(file.name.?)), O_RDWR);
            }
            if (file.fd < 0) {
                ttsig(-2);
            }

            _ = lseek(file.fd, page.addr, 0);

            const pgsz: i64 = PGSIZE;
            if (page.addr + pgsz > vsize(file)) {
                const partial = vsize(file) - page.addr;
                if (joe_write(file.fd, page.data, @as(isize, @intCast(partial))) < 0) {
                    ttsig(-2);
                }
                file.size = vsize(file);
            } else {
                if (joe_write(file.fd, page.data, PGSIZE) < 0) {
                    ttsig(-2);
                }
                if (page.addr + pgsz > file.size) {
                    file.size = page.addr + pgsz;
                }
            }
            page.dirty = 0;
            last = page.addr;
        }
    }
}

/// Flush all dirty pages belonging to a specific VFILE.
export fn vflshf(vfile: ?*VFILE) void {
    const file = vfile orelse return;

    while (true) {
        var best_addr: i64 = MAXOFF;
        var best: ?*VPAGE = null;

        for (&htab) |maybe_bucket| {
            var vp = maybe_bucket;
            while (vp) |page| : (vp = page.next) {
                if (page.addr < best_addr and
                    page.dirty != 0 and
                    page.vfile == file and
                    page.count == 0)
                {
                    best_addr = page.addr;
                    best = page;
                }
            }
        }

        const page = best orelse break;

        if (file.name == null) {
            file.name = mktmp(null);
        }
        if (file.fd == 0) {
            file.fd = open(@as([*c]const u8, @ptrCast(file.name.?)), O_RDWR);
        }
        if (file.fd < 0) {
            ttsig(-2);
        }

        _ = lseek(file.fd, page.addr, 0);

        const pgsz: i64 = PGSIZE;
        if (page.addr + pgsz > vsize(file)) {
            const partial = vsize(file) - page.addr;
            if (joe_write(file.fd, page.data, @as(isize, @intCast(partial))) < 0) {
                ttsig(-2);
            }
            file.size = vsize(file);
        } else {
            if (joe_write(file.fd, page.data, PGSIZE) < 0) {
                ttsig(-2);
            }
            if (page.addr + pgsz > file.size) {
                file.size = page.addr + pgsz;
            }
        }
        page.dirty = 0;
    }
}

/// Lock the page containing virtual address `addr`, returning a pointer
/// to the data at `addr` within that page.  The page stays resident until
/// `vunlock` is called.
export fn vlock(vfile: ?*VFILE, addr: i64) ?*anyopaque {
    const file = vfile orelse return null;

    const ofst = addr & (PGSIZE - 1);
    const pg_addr = addr - ofst;

    // Hash index: (shifted_addr + pointer_as_int) modulo HTSIZE.
    const ptr_bits: i64 = @bitCast(@intFromPtr(file));
    const raw_hash = (pg_addr >> LPGSIZE) + ptr_bits;
    const hash = @as(usize, @intCast(@as(u64, @bitCast(raw_hash)) & @as(u64, HTSIZE - 1)));

    // ── 1. Already in hash table? ───────────────────────────────────
    {
        var vp = htab[hash];
        while (vp) |page| : (vp = page.next) {
            if (page.vfile == file and page.addr == pg_addr) {
                page.count += 1;
                return @ptrFromInt(@intFromPtr(page.data) + @as(usize, @intCast(ofst)));
            }
        }
    }

    var vp: ?*VPAGE = null;

    // ── 2. Grab a page from the free list. ──────────────────────────
    if (freepages) |fp| {
        freepages = fp.next;
        vp = fp;
    }

    // ── 3. Allocate a fresh batch of pages. ─────────────────────────
    if (vp == null and curvalloc + @as(c_long, PGSIZE) <= maxvalloc) {
        const pages = @as(?*VPAGE, @alignCast(@ptrCast(joe_malloc(@sizeOf(VPAGE) * INC))));
        if (pages) |pgs| {
            // Allocate page-aligned data for all INC pages at once.
            const data = memAlign(PGSIZE, PGSIZE * INC);
            if (data) |pg_data| {
                curvalloc += @as(c_long, PGSIZE * INC);

                const d_addr = @intFromPtr(pg_data);
                const b_addr = @intFromPtr(vbase);
                const vh_ptr = vheaders;

                if (vh_ptr == null) {
                    // First allocation — initialise vheaders array.
                    const arr = joe_malloc(@sizeOf(?*VPAGE) * INC) orelse {
                        joe_free(pgs);
                        joe_free(pg_data);
                        return null;
                    };
                    vheaders = arr;
                    vheadsz = INC;
                    vbase = pg_data;
                } else if (d_addr < b_addr) {
                    // New page lies BELOW the current base —
                    // prepend entries to vheaders.
                    const extra: isize = @intCast((b_addr - d_addr) >> LPGSIZE);
                    const new_sz = extra + vheadsz;
                    const new_vh = joe_malloc(@sizeOf(?*VPAGE) * new_sz) orelse {
                        joe_free(pgs);
                        joe_free(pg_data);
                        return null;
                    };
                    // Zero the new lower slots.
                    @memset(
                        @as([*]u8, @ptrCast(new_vh))[0..@as(usize, @intCast(extra * @sizeOf(?*VPAGE)))],
                        0,
                    );
                    // Move existing entries up.
                    _ = mmove(
                        @ptrFromInt(@intFromPtr(new_vh) + @as(usize, @intCast(extra * @sizeOf(?*VPAGE)))),
                        vh_ptr.?,
                        @sizeOf(?*VPAGE) * vheadsz,
                    );
                    vheadsz = new_sz;
                    vbase = pg_data;
                    joe_free(vh_ptr.?);
                    vheaders = new_vh;
                } else if (((d_addr + PGSIZE * INC - b_addr) >> LPGSIZE) > @as(usize, @intCast(vheadsz))) {
                    // New page extends above existing coverage — grow vheaders.
                    const needed: isize = @intCast((d_addr + PGSIZE * INC - b_addr) >> LPGSIZE);
                    const new_vh = joe_realloc(vh_ptr.?, @sizeOf(?*VPAGE) * needed) orelse {
                        joe_free(pgs);
                        joe_free(pg_data);
                        return null;
                    };
                    vheadsz = needed;
                    vheaders = new_vh;
                }

                // Link pages[1..INC-1] into the free list.
                const vh_arr: [*c]?*VPAGE = @alignCast(@ptrCast(vheaders));
                const b_addr_final = @intFromPtr(vbase);
                const pg_arr: [*]VPAGE = @ptrCast(pgs);

                var q: usize = 1;
                while (q < INC) : (q += 1) {
                    pg_arr[q].next = freepages;
                    freepages = &pg_arr[q];
                    pg_arr[q].data = @ptrFromInt(d_addr + q * PGSIZE);
                    pg_arr[q].count = 0;
                    pg_arr[q].dirty = 0;
                    pg_arr[q].addr = 0;
                    pg_arr[q].vfile = null;
                    vh_arr[(d_addr + q * PGSIZE - b_addr_final) >> LPGSIZE] = &pg_arr[q];
                }
                // Page 0 is the one we will use.
                pg_arr[0].data = pg_data;
                pg_arr[0].count = 0;
                pg_arr[0].dirty = 0;
                pg_arr[0].addr = 0;
                pg_arr[0].vfile = null;
                vh_arr[(d_addr - b_addr_final) >> LPGSIZE] = &pg_arr[0];

                vp = pgs;
            } else {
                joe_free(pgs);
            }
        }
    }

    // ── 4. Evict a clean unreferenced page. ─────────────────────────
    if (vp == null) {
        vp = evictOne();
    }

    // ── 5. Flush everything, then try eviction again. ───────────────
    if (vp == null) {
        vflsh();
        vp = evictOne();
    }

    // ── 6. Out of memory — fatal. ──────────────────────────────────
    const page = vp orelse {
        const msg = "vfile: out of memory\n";
        if (joe_write(2, @ptrCast(@as(*const anyopaque, @ptrCast(msg))), @as(isize, @intCast(msg.len))) == -1) {
            exit(2);
        } else {
            exit(1);
        }
    };

    // ── gotit — set up the page header. ─────────────────────────────
    page.addr = pg_addr;
    page.vfile = file;
    page.dirty = 0;
    page.count = 1;
    page.next = htab[hash];
    htab[hash] = page;

    // ── Read data from backing file, or zero-fill. ──────────────────
    if (pg_addr < file.size) {
        if (file.fd == 0) {
            file.fd = open(@as([*c]const u8, @ptrCast(file.name.?)), O_RDWR);
        }
        if (file.fd < 0) {
            ttsig(-2);
        }
        _ = lseek(file.fd, pg_addr, 0);

        const pgsz: i64 = PGSIZE;
        if (pg_addr + pgsz > file.size) {
            const remain = file.size - pg_addr;
            _ = joe_read(file.fd, page.data, @as(isize, @intCast(remain)));
            _ = mset(
                @ptrFromInt(@intFromPtr(page.data) + @as(usize, @intCast(remain))),
                0,
                PGSIZE - @as(isize, @intCast(remain)),
            );
        } else {
            _ = joe_read(file.fd, page.data, PGSIZE);
        }
    } else {
        _ = mset(page.data, 0, PGSIZE);
    }

    return @ptrFromInt(@intFromPtr(page.data) + @as(usize, @intCast(ofst)));
}

/// Create a new temporary virtual file.  The file is backed by a
/// temporary name on disk only when pages must be evicted.
export fn vtmp() ?*VFILE {
    const vh = joe_malloc(@sizeOf(VFILE)) orelse return null;
    const newf = @as(*VFILE, @alignCast(@ptrCast(vh)));
    newf.* = VFILE{
        .link = .{ .next = undefined, .prev = undefined },
        .size = 0,
        .alloc = 0,
        .fd = 0,
        .writeable = 0,
        .name = null,
        .flags = 1,
        .vpage1 = null,
        .addr = -1,
        .bufp = null,
        .vpage = null,
        .left = 0,
        .lv = 0,
    };
    listAdd(newf);
    return newf;
}

/// Close a virtual file: flush, unlink the backing file, free headers,
/// and return all its pages to the free list.
export fn vclose(vfile: ?*VFILE) void {
    const file = vfile orelse return;

    if (file.vpage) |vp| {
        // vunlock via the C macro: decrement count on the page header.
        const vh_arr: [*c]?*VPAGE = @alignCast(@ptrCast(vheaders));
        if (vh_arr != null) {
            const idx = (@intFromPtr(vp) - @intFromPtr(vbase)) >> LPGSIZE;
            if (vh_arr[idx]) |hdr| {
                hdr.count -= 1;
            }
        }
    }
    if (file.vpage1) |vp1| {
        const vh_arr: [*c]?*VPAGE = @alignCast(@ptrCast(vheaders));
        if (vh_arr != null) {
            const idx = (@intFromPtr(vp1) - @intFromPtr(vbase)) >> LPGSIZE;
            if (vh_arr[idx]) |hdr| {
                hdr.count -= 1;
            }
        }
    }

    if (file.name) |nm| {
        if (file.flags != 0) {
            if (file.fd != 0) {
                _ = close(file.fd);
                file.fd = 0;
            }
            _ = unlink(@as([*c]const u8, @ptrCast(nm)));
        } else {
            vflshf(file);
        }
        // vsrm(nm) — free the name string.
        joe_free(@as(?*anyopaque, @ptrCast(nm)));
    }
    if (file.fd != 0) {
        _ = close(file.fd);
    }

    listRemove(file);
    joe_free(@as(?*anyopaque, @ptrCast(file)));

    // Move all pages belonging to this file to the free list.
    for (&htab) |*bucket| {
        var prev: ?*VPAGE = null;
        var vp = bucket.*;
        while (vp) |page| {
            const nxt = page.next;
            if (page.vfile == file) {
                // Unlink from chain.
                if (prev) |p| {
                    p.next = nxt;
                } else {
                    bucket.* = nxt;
                }
                // Add to free list.
                page.next = freepages;
                freepages = page;
                // Clear vfile so the page isn't mistaken later.
                page.vfile = null;
                vp = nxt;
            } else {
                prev = page;
                vp = nxt;
            }
        }
    }
}

/// Allocate `size` bytes at the end of `vfile`, returning the starting
/// offset.  Only the gap buffer (b.c) calls this.
export fn my_valloc(vfile: ?*VFILE, size: i64) i64 {
    const file = vfile orelse return 0;
    const start = vsize(file);
    file.alloc = start + size;
    if (file.lv != 0) {
        const vh_arr: [*c]?*VPAGE = @alignCast(@ptrCast(vheaders));
        const idx = (@intFromPtr(file.vpage) - @intFromPtr(vbase)) >> LPGSIZE;
        const hdr = vh_arr[idx] orelse return start;
        if (hdr.addr + PGSIZE > file.alloc) {
            file.lv = PGSIZE - (file.alloc - hdr.addr);
        } else {
            file.lv = 0;
        }
    }
    return start;
}

// ═══════════════════════════════════════════════════════════════════════
// Page‑header helpers (needed by gapbuffer.zig — implement C macros)
// ═══════════════════════════════════════════════════════════════════════

const LPGSIZE_VAL: c_int = 12;

/// Return a pointer to the VPAGE header for a page‑data pointer.
/// Corresponds to the C `vheader()` macro.
fn vheaderLookup(page_data: ?*anyopaque) ?*VPAGE {
    const vh = vheaders orelse return null;
    const base = vbase orelse return null;
    const idx = (@intFromPtr(page_data) - @intFromPtr(base)) >> @as(u64, @intCast(LPGSIZE_VAL));
    const arr: [*c]?*VPAGE = @alignCast(@ptrCast(vh));
    return arr[idx];
}

/// Decrement the reference count on a page.
/// Corresponds to the C `vunlock()` macro.
export fn vunlock_page(page_data: ?*anyopaque) void {
    const hdr = vheaderLookup(page_data) orelse return;
    hdr.*.count -= 1;
}

/// Mark a page as dirty.
/// Corresponds to the C `vchanged()` macro.
export fn vchanged_page(page_data: ?*anyopaque) void {
    const hdr = vheaderLookup(page_data) orelse return;
    hdr.*.dirty = 1;
}

/// Increment the reference count on a page.
/// Corresponds to the C `vupcount()` macro.
export fn vupcount_page(page_data: ?*anyopaque) void {
    const hdr = vheaderLookup(page_data) orelse return;
    hdr.*.count += 1;
}
