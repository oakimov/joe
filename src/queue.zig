//! Doubly-linked list primitives — replaces `joe/queue.c`
//!
//! Implements `alitem()` and `frchn()` used by all list-based subsystems.
//! Also exports the `QUEUE`, `ITEM`, `LAST` globals referenced by `queue.h` macros.

const std = @import("std");

extern fn joe_malloc(size: isize) ?*anyopaque;

export var QUEUE: ?*anyopaque = null;
export var ITEM: ?*anyopaque = null;
export var LAST: ?*anyopaque = null;

/// LINK(struct stditem) — 2 pointers
const Link = extern struct { next: ?*anyopaque, prev: ?*anyopaque };

/// STDITEM — item with just a link
const STDITEM = extern struct { link: Link };

fn ptrEq(a: anytype, b: anytype) bool { return @intFromPtr(a) == @intFromPtr(b); }

fn qempty(list: *Link) bool { return ptrEq(list.next, list); }

fn enquef(list: *Link, item: *Link) void {
    const n = @as(*Link, @alignCast(@ptrCast(list.next)));
    item.next = list.next;
    item.prev = @ptrCast(list);
    n.prev = @ptrCast(item);
    list.next = @ptrCast(item);
}

fn deque_(item: *Link) void {
    const n = @as(*Link, @alignCast(@ptrCast(item.next)));
    const p = @as(*Link, @alignCast(@ptrCast(item.prev)));
    p.next = item.next;
    n.prev = item.prev;
}

fn splicef(list: *Link, chain_last: *Link) void {
    const chain_first = @as(*Link, @alignCast(@ptrCast(chain_last.prev)));
    const n = @as(*Link, @alignCast(@ptrCast(list.next)));
    chain_first.next = list.next;
    chain_last.prev = @ptrCast(list);
    n.prev = @ptrCast(chain_last);
    list.next = @ptrCast(chain_first);
}

export fn alitem(list: ?*anyopaque, itemsize: isize) ?*anyopaque {
    const freelist = @as(*STDITEM, @alignCast(@ptrCast(list.?)));
    if (qempty(@ptrCast(freelist))) {
        const i = @as([*]u8, @ptrCast(joe_malloc(itemsize * 16) orelse return null));
        const z = i + @as(usize, @intCast(itemsize * 16));
        var cur = i;
        while (cur != z) : (cur = cur + @as(usize, @intCast(itemsize))) {
            enquef(@ptrCast(freelist), @alignCast(@ptrCast(cur)));
        }
    }
    const last = @as(*STDITEM, @alignCast(@ptrCast(freelist.link.prev)));
    deque_(@ptrCast(last));
    return @ptrCast(last);
}

export fn frchn(list: ?*anyopaque, ch: ?*anyopaque) void {
    const freelist = @as(*STDITEM, @alignCast(@ptrCast(list.?)));
    const chn = @as(*STDITEM, @alignCast(@ptrCast(ch.?)));
    const i = @as(*STDITEM, @alignCast(@ptrCast(chn.link.prev)));
    if (!ptrEq(i, chn)) {
        deque_(@ptrCast(chn));
        splicef(@ptrCast(freelist), @ptrCast(i));
    }
}
