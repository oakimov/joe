//! Zig-native window Screen + layout (Phase 5 redesign).
//!
//! Parallel to hybrid `src/w.zig`. Not wired into the live `joe` binary yet.
//! Ordering uses `ArrayList` + unique IDs instead of JOE's circular `LINK(W)`.
//! `layout` is a simplified `wfit`: geometry only (no terminal scroll magic).

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const tw = @import("tw.zig");
const pw = @import("pw.zig");
const qw = @import("qw.zig");
const menu = @import("menu.zig");

/// Minimum height for a main (non-child) window — JOE `FITMIN`.
pub const fit_min: u16 = 2;
/// Minimum free lines needed to place another text family — JOE `FITHEIGHT`.
pub const fit_height: u16 = 4;

pub const WindowId = u32;

pub const WindowKind = enum {
    text,
    prompt,
    query,
    menu,
    base,
};

pub const WindowVTable = struct {
    kind: WindowKind,
    context: ?[]const u8 = null,
    on_move: ?*const fn (*Window, u16, i16) void = null,
    on_resize: ?*const fn (*Window, u16, u16) void = null,
    on_abort: ?*const fn (*Window) i32 = null,
};

pub const Window = struct {
    id: WindowId,
    screen: *Screen,
    x: u16 = 0,
    /// `-1` means off-screen (JOE `y == -1`).
    y: i16 = -1,
    w: u16,
    h: u16 = 0,
    ny: i16 = 0,
    nh: u16 = 0,
    /// Requested height for next `layout`; `0` means use `fixed` / `hh`.
    req_h: u16 = 0,
    /// Non-zero ⇒ fixed-height child (prompt/query/menu).
    fixed: u16 = 0,
    /// Proportional height on a 1000-line usable screen (JOE `hh`).
    hh: u16 = 0,
    /// Window this one operates on (JOE `win`); null ⇒ main/parent.
    target: ?WindowId = null,
    /// Family main window id (JOE `main`).
    main: WindowId,
    /// Space donor; closed height returns here (JOE `orgwin`).
    org: ?WindowId = null,
    vtable: *const WindowVTable,
    msg_top: ?[]const u8 = null,
    msg_bot: ?[]const u8 = null,
    huh: ?[]const u8 = null,
    object: ?*anyopaque = null,
};

pub const Screen = struct {
    allocator: Allocator,
    width: u16,
    height: u16,
    /// Help-line rows reserved at top (JOE `wind`).
    wind: u16 = 0,
    /// Top→bottom on-screen order (may include off-screen windows with `y < 0`).
    order: std.ArrayList(*Window),
    by_id: std.AutoHashMapUnmanaged(WindowId, *Window),
    cur_id: WindowId = 0,
    /// First window considered by layout (JOE `topwin`).
    top_id: WindowId = 0,
    next_id: WindowId = 1,

    pub fn init(allocator: Allocator, width: u16, height: u16) !Screen {
        return .{
            .allocator = allocator,
            .width = width,
            .height = height,
            .order = .empty,
            .by_id = .empty,
        };
    }

    pub fn deinit(self: *Screen) void {
        for (self.order.items) |w| {
            self.allocator.destroy(w);
        }
        self.order.deinit(self.allocator);
        self.by_id.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn usableHeight(self: *const Screen) u16 {
        return self.height -| self.wind;
    }

    pub fn get(self: *Screen, id: WindowId) ?*Window {
        return self.by_id.get(id);
    }

    pub fn current(self: *Screen) ?*Window {
        return self.get(self.cur_id);
    }

    pub fn top(self: *Screen) ?*Window {
        return self.get(self.top_id);
    }

    fn indexOf(self: *Screen, id: WindowId) ?usize {
        for (self.order.items, 0..) |w, i| {
            if (w.id == id) return i;
        }
        return null;
    }

    fn findTopOfFamily(self: *Screen, w: *Window) *Window {
        const idx = self.indexOf(w.id) orelse return w;
        var i: usize = idx;
        while (i > 0 and self.order.items[i - 1].main == w.main) : (i -= 1) {}
        return self.order.items[i];
    }

    fn findBotOfFamily(self: *Screen, w: *Window) *Window {
        const idx = self.indexOf(w.id) orelse return w;
        var i: usize = idx;
        while (i + 1 < self.order.items.len and self.order.items[i + 1].main == w.main) : (i += 1) {}
        return self.order.items[i];
    }

    fn desiredHeight(self: *const Screen, w: *const Window) u16 {
        if (w.req_h != 0) {
            if (w.target != null) return @max(w.req_h, 1);
            return @max(w.req_h, fit_min);
        }
        if (w.fixed != 0) return w.fixed;
        const usable = self.usableHeight();
        if (usable == 0) return fit_min;
        const scaled: u16 = @intCast((@as(u32, usable) * w.hh) / 1000);
        return @max(scaled, fit_min);
    }

    fn setHeight(self: *const Screen, w: *Window, h: u16) void {
        w.req_h = h;
        const usable = self.usableHeight();
        if (usable == 0) {
            w.hh = 1000;
            return;
        }
        const tmp: u32 = 1000 * @as(u32, h);
        w.hh = @intCast(tmp / usable + @as(u32, @intFromBool(tmp % usable != 0)));
    }

    fn familyHeight(self: *Screen, w: *Window) u16 {
        const topw = self.findTopOfFamily(w);
        var h: u16 = 0;
        const start = self.indexOf(topw.id) orelse return 0;
        var i: usize = start;
        while (i < self.order.items.len) : (i += 1) {
            const cur = self.order.items[i];
            if (cur.main != topw.main) break;
            h += self.desiredHeight(cur);
        }
        return h;
    }

    /// Create a window after `after` (or at end if null). `target == null` starts a family.
    /// `org` donates `height` rows when non-null.
    pub fn createWindow(
        self: *Screen,
        vtable: *const WindowVTable,
        after: ?WindowId,
        target: ?WindowId,
        org: ?WindowId,
        height: u16,
        huh: ?[]const u8,
    ) !*Window {
        if (height < 1) return error.InvalidHeight;

        if (org) |oid| {
            const donor = self.get(oid) orelse return error.UnknownWindow;
            if (donor.h != 0) {
                if (donor.h < height) return error.NotEnoughSpace;
                self.setHeight(donor, donor.h - height);
            } else if (donor.req_h != 0) {
                if (donor.req_h < height) return error.NotEnoughSpace;
                self.setHeight(donor, donor.req_h - height);
            } else {
                const want = self.desiredHeight(donor);
                if (want < height) return error.NotEnoughSpace;
                self.setHeight(donor, want - height);
            }
        }

        const w = try self.allocator.create(Window);
        errdefer self.allocator.destroy(w);

        const id = self.next_id;
        self.next_id += 1;

        const main_id: WindowId = if (target) |t| blk: {
            const twnd = self.get(t) orelse return error.UnknownWindow;
            break :blk twnd.main;
        } else id;

        w.* = .{
            .id = id,
            .screen = self,
            .w = self.width,
            .vtable = vtable,
            .huh = huh,
            .target = target,
            .main = main_id,
            .org = org,
            .fixed = if (target != null) height else 0,
        };
        self.setHeight(w, height);
        w.h = w.req_h;

        const insert_at: usize = if (after) |aid| blk: {
            const idx = self.indexOf(aid) orelse return error.UnknownWindow;
            break :blk idx + 1;
        } else self.order.items.len;

        try self.order.insert(self.allocator, insert_at, w);
        errdefer {
            _ = self.order.orderedRemove(insert_at);
        }
        try self.by_id.put(self.allocator, id, w);

        if (self.order.items.len == 1) {
            self.cur_id = id;
            self.top_id = id;
        }
        return w;
    }

    pub fn createText(self: *Screen, after: ?WindowId, org: ?WindowId, height: u16) !*Window {
        return self.createWindow(&tw.vtable, after, null, org, height, null);
    }

    pub fn createPrompt(self: *Screen, after: WindowId, target: WindowId, org: WindowId, height: u16) !*Window {
        return self.createWindow(&pw.vtable, after, target, org, height, null);
    }

    pub fn createQuery(self: *Screen, after: WindowId, target: WindowId, org: WindowId, height: u16) !*Window {
        return self.createWindow(&qw.vtable, after, target, org, height, null);
    }

    pub fn createMenu(self: *Screen, after: WindowId, target: WindowId, org: WindowId, height: u16) !*Window {
        return self.createWindow(&menu.vtable, after, target, org, height, null);
    }

    /// Fit windows onto the screen — simplified JOE `wfit` (geometry only).
    pub fn layout(self: *Screen) void {
        if (self.order.items.len == 0) return;

        var guard: usize = 0;
        while (guard < self.order.items.len + 2) : (guard += 1) {
            const top_idx = self.indexOf(self.top_id) orelse {
                self.top_id = self.order.items[0].id;
                continue;
            };

            for (self.order.items) |w| {
                w.ny = -1;
                w.nh = self.desiredHeight(w);
            }

            var y: i16 = @intCast(self.wind);
            var left: i16 = @intCast(self.usableHeight());
            var prev_main: ?*Window = null;
            var cursor_placed = false;

            // Circular family walk starting at top_idx.
            var fam_start = top_idx;
            var families_done: usize = 0;
            const max_families = self.order.items.len;
            while (families_done < max_families and left >= 0) : (families_done += 1) {
                if (families_done > 0 and left < fit_height) break;

                const fam_top = self.order.items[fam_start];
                if (fam_top.ny >= 0) break;

                const req: i16 = @intCast(self.familyHeight(fam_top));
                const adj: i16 = if (req > left) req - left else 0;

                var j = fam_start;
                while (j < self.order.items.len) {
                    const w = self.order.items[j];
                    if (w.main != fam_top.main) break;
                    w.ny = y;
                    if (w.target == null) {
                        prev_main = w;
                        if (adj > 0) {
                            const nh_i: i16 = @intCast(w.nh);
                            w.nh = @intCast(@max(nh_i - adj, @as(i16, 0)));
                        }
                    }
                    if (w.id == self.cur_id) cursor_placed = true;
                    y += @intCast(w.nh);
                    left -= @intCast(w.nh);
                    j += 1;
                }

                const bot = self.findBotOfFamily(fam_top);
                const bidx = self.indexOf(bot.id) orelse fam_start;
                const next = if (bidx + 1 < self.order.items.len) bidx + 1 else 0;
                if (next == top_idx) break;
                fam_start = next;
            }

            if (prev_main) |pm| {
                pm.nh = @intCast(@as(i16, @intCast(pm.nh)) + left);
                const pidx = self.indexOf(pm.id) orelse 0;
                var k = pidx + 1;
                while (k < self.order.items.len and self.order.items[k].main == pm.main) : (k += 1) {
                    if (self.order.items[k].ny >= 0) {
                        self.order.items[k].ny += left;
                    }
                }
            }

            if (!cursor_placed) {
                if (self.top()) |t| {
                    const bot = self.findBotOfFamily(t);
                    const bidx = self.indexOf(bot.id) orelse 0;
                    const nidx = if (bidx + 1 < self.order.items.len) bidx + 1 else 0;
                    self.top_id = self.order.items[nidx].id;
                }
                continue;
            }

            for (self.order.items) |w| {
                if (w.ny >= 0) {
                    w.y = w.ny;
                } else {
                    w.y = -1;
                }
                w.h = w.nh;
                w.req_h = 0;
                w.w = self.width;
                if (w.y >= 0) {
                    if (w.vtable.on_move) |m| m(w, w.x, w.y);
                    if (w.vtable.on_resize) |r| r(w, w.w, w.h);
                }
            }
            return;
        }
    }

    pub fn nextWindow(self: *Screen) void {
        if (self.order.items.len == 0) return;
        const idx = self.indexOf(self.cur_id) orelse 0;
        var i = if (idx + 1 < self.order.items.len) idx + 1 else 0;
        var tries: usize = 0;
        while (tries < self.order.items.len) : (tries += 1) {
            if (self.order.items[i].y >= 0) {
                self.cur_id = self.order.items[i].id;
                return;
            }
            i = if (i + 1 < self.order.items.len) i + 1 else 0;
        }
        self.cur_id = self.order.items[i].id;
    }

    pub fn prevWindow(self: *Screen) void {
        if (self.order.items.len == 0) return;
        const idx = self.indexOf(self.cur_id) orelse 0;
        var i: usize = if (idx == 0) self.order.items.len - 1 else idx - 1;
        var tries: usize = 0;
        while (tries < self.order.items.len) : (tries += 1) {
            if (self.order.items[i].y >= 0) {
                self.cur_id = self.order.items[i].id;
                return;
            }
            i = if (i == 0) self.order.items.len - 1 else i - 1;
        }
        self.cur_id = self.order.items[i].id;
    }

    /// Abort window and its dependents; return height to `org` when present.
    pub fn close(self: *Screen, id: WindowId) !void {
        const w = self.get(id) orelse return error.UnknownWindow;

        var kill_ids: std.ArrayList(WindowId) = .empty;
        defer kill_ids.deinit(self.allocator);
        try kill_ids.append(self.allocator, id);

        var changed = true;
        while (changed) {
            changed = false;
            for (self.order.items) |cand| {
                if (cand.id == id) continue;
                const depends = (cand.target == id) or (cand.main == id and cand.id != id) or (cand.org == id);
                if (!depends) continue;
                var already = false;
                for (kill_ids.items) |kid| {
                    if (kid == cand.id) {
                        already = true;
                        break;
                    }
                }
                if (!already) {
                    try kill_ids.append(self.allocator, cand.id);
                    changed = true;
                }
            }
        }

        const give_back = if (w.h != 0) w.h else self.desiredHeight(w);
        if (w.org) |oid| {
            if (self.get(oid)) |donor| {
                const cur = if (donor.h != 0) donor.h else self.desiredHeight(donor);
                self.setHeight(donor, cur + give_back);
            }
        }

        if (self.cur_id == id) {
            if (w.target) |t| {
                self.cur_id = t;
            } else if (w.org) |o| {
                self.cur_id = o;
            } else if (self.indexOf(id)) |idx| {
                if (self.order.items.len > 1) {
                    const nidx = if (idx + 1 < self.order.items.len) idx + 1 else idx -| 1;
                    self.cur_id = self.order.items[nidx].id;
                } else self.cur_id = 0;
            }
        }
        if (self.top_id == id and self.order.items.len > 1) {
            const idx = self.indexOf(id).?;
            const nidx = if (idx + 1 < self.order.items.len) idx + 1 else 0;
            self.top_id = self.order.items[nidx].id;
        }

        var ki = kill_ids.items.len;
        while (ki > 0) {
            ki -= 1;
            const kid = kill_ids.items[ki];
            const node = self.get(kid) orelse continue;
            if (node.vtable.on_abort) |ab| _ = ab(node);
            if (self.indexOf(kid)) |idx| {
                _ = self.order.orderedRemove(idx);
            }
            _ = self.by_id.remove(kid);
            self.allocator.destroy(node);
        }

        if (self.order.items.len == 0) {
            self.cur_id = 0;
            self.top_id = 0;
        } else if (self.get(self.cur_id) == null) {
            self.cur_id = self.order.items[0].id;
        }
        if (self.get(self.top_id) == null and self.order.items.len > 0) {
            self.top_id = self.order.items[0].id;
        }

        self.layout();
    }

    pub fn resize(self: *Screen, width: u16, height: u16) void {
        self.width = width;
        self.height = height;
        if (self.usableHeight() < fit_min) {
            self.wind = self.height -| fit_min;
        }
        for (self.order.items) |win| {
            win.w = width;
        }
        self.layout();
    }

    pub fn windowAt(self: *Screen, x: u16, y: i16) ?*Window {
        _ = x;
        for (self.order.items) |w| {
            if (w.y < 0) continue;
            if (y >= w.y and y < w.y + @as(i16, @intCast(w.h))) return w;
        }
        return null;
    }

    pub fn countMain(self: *Screen) usize {
        if (self.order.items.len == 0) return 0;
        var n: usize = 0;
        var last_main: ?WindowId = null;
        for (self.order.items) |w| {
            if (w.target != null) continue;
            if (last_main != w.main) {
                n += 1;
                last_main = w.main;
            }
        }
        return n;
    }
};

test "create single text window fills usable height" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const w = try scr.createText(null, null, 24);
    scr.layout();
    try testing.expectEqual(@as(i16, 0), w.y);
    try testing.expectEqual(@as(u16, 24), w.h);
    try testing.expectEqual(w.id, scr.cur_id);
}

test "two text windows share screen" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 12);
    const b = try scr.createText(a.id, null, 12);
    scr.layout();
    try testing.expectEqual(@as(i16, 0), a.y);
    try testing.expectEqual(@as(u16, 12), a.h);
    try testing.expectEqual(@as(i16, 12), b.y);
    try testing.expectEqual(@as(u16, 12), b.h);
    try testing.expectEqual(@as(usize, 2), scr.countMain());
}

test "prompt child takes height from parent" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const twnd = try scr.createText(null, null, 24);
    scr.layout();
    const prompt = try scr.createPrompt(twnd.id, twnd.id, twnd.id, 1);
    scr.layout();
    try testing.expect(prompt.target == twnd.id);
    try testing.expectEqual(twnd.id, prompt.main);
    try testing.expectEqual(@as(u16, 1), prompt.h);
    try testing.expectEqual(@as(u16, 23), twnd.h);
    try testing.expectEqual(twnd.y + @as(i16, @intCast(twnd.h)), prompt.y);
}

test "next and prev cycle on-screen windows" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 12);
    const b = try scr.createText(a.id, null, 12);
    scr.layout();
    scr.cur_id = a.id;
    scr.nextWindow();
    try testing.expectEqual(b.id, scr.cur_id);
    scr.nextWindow();
    try testing.expectEqual(a.id, scr.cur_id);
    scr.prevWindow();
    try testing.expectEqual(b.id, scr.cur_id);
}

test "close returns space to org" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const twnd = try scr.createText(null, null, 24);
    scr.layout();
    const prompt = try scr.createPrompt(twnd.id, twnd.id, twnd.id, 2);
    scr.layout();
    try testing.expectEqual(@as(u16, 22), twnd.h);
    try scr.close(prompt.id);
    try testing.expectEqual(@as(usize, 1), scr.order.items.len);
    try testing.expectEqual(@as(u16, 24), twnd.h);
}

test "resize keeps proportional split" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 12);
    const b = try scr.createText(a.id, null, 12);
    scr.layout();
    scr.resize(80, 40);
    try testing.expectEqual(@as(u16, 20), a.h);
    try testing.expectEqual(@as(u16, 20), b.h);
    try testing.expectEqual(@as(i16, 20), b.y);
}

test "windowAt hits correct window" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 12);
    const b = try scr.createText(a.id, null, 12);
    scr.layout();
    try testing.expect(scr.windowAt(0, 0) == a);
    try testing.expect(scr.windowAt(0, 12) == b);
    try testing.expect(scr.windowAt(0, 23) == b);
}

test "vtable kinds resolve" {
    try testing.expectEqual(WindowKind.text, tw.vtable.kind);
    try testing.expectEqual(WindowKind.prompt, pw.vtable.kind);
    try testing.expectEqual(WindowKind.query, qw.vtable.kind);
    try testing.expectEqual(WindowKind.menu, menu.vtable.kind);
}
