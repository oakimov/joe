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
/// Composition buffer size for temporary window messages — JOE `JOE_MSGBUFSIZE`.
pub const msg_buf_size: usize = 300;

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
    /// Temporary top-of-window message (JOE `msgt`); borrowed, cleared by `clearMsgs`.
    msg_top: ?[]const u8 = null,
    /// Temporary bottom-of-window message (JOE `msgb`); borrowed, cleared by `clearMsgs`.
    msg_bot: ?[]const u8 = null,
    huh: ?[]const u8 = null,
    object: ?*anyopaque = null,

    /// Set bottom temporary message — JOE `msgnw`.
    pub fn setMsgBot(self: *Window, s: ?[]const u8) void {
        self.msg_bot = s;
    }

    /// Set top temporary message — JOE `msgnwt`.
    pub fn setMsgTop(self: *Window, s: ?[]const u8) void {
        self.msg_top = s;
    }

    /// Clear temporary messages — JOE `msgclr`.
    pub fn clearMsgs(self: *Window) void {
        self.msg_top = null;
        self.msg_bot = null;
    }

    /// Screen row for bottom message when painted (JOE `msgout` / `msgb`).
    /// `null` when no message, zero height, or off-screen.
    pub fn msgBotRow(self: *const Window) ?i16 {
        if (self.msg_bot == null or self.h == 0 or self.y < 0) return null;
        return self.y + @as(i16, @intCast(self.h)) - 1;
    }

    /// Screen row for top message when painted (JOE `msgout` / `msgt`).
    /// `status_enabled` mirrors JOE `!staen` (default true ⇒ skip status row when possible).
    pub fn msgTopRow(self: *const Window, status_enabled: bool) ?i16 {
        if (self.msg_top == null or self.h == 0 or self.y < 0) return null;
        const skip_status = self.h > 1 and (self.y != 0 or status_enabled);
        return self.y + @as(i16, if (skip_status) 1 else 0);
    }
    pub fn asText(self: *Window) ?*tw.TextWindow {
        if (self.vtable.kind != .text) return null;
        return if (self.object) |obj| @ptrCast(@alignCast(obj)) else null;
    }

    pub fn asPrompt(self: *Window) ?*pw.PromptWindow {
        if (self.vtable.kind != .prompt) return null;
        return if (self.object) |obj| @ptrCast(@alignCast(obj)) else null;
    }

    pub fn asQuery(self: *Window) ?*qw.QueryWindow {
        if (self.vtable.kind != .query) return null;
        return if (self.object) |obj| @ptrCast(@alignCast(obj)) else null;
    }

    pub fn asMenu(self: *Window) ?*menu.MenuWindow {
        if (self.vtable.kind != .menu) return null;
        return if (self.object) |obj| @ptrCast(@alignCast(obj)) else null;
    }

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
    /// Shared composition buffer for temporary messages — JOE `msgbuf`.
    msg_buf: [msg_buf_size]u8 = undefined,

    pub fn init(allocator: Allocator, width: u16, height: u16) !Screen {
        return .{
            .allocator = allocator,
            .width = width,
            .height = height,
            .order = .empty,
            .by_id = .empty,
        };
    }

    /// Format into `msg_buf` and return the written slice (JOE `joe_snprintf(msgbuf, …)`).
    pub fn composeMsg(self: *Screen, comptime fmt: []const u8, args: anytype) []const u8 {
        return std.fmt.bufPrint(&self.msg_buf, fmt, args) catch self.msg_buf[0..0];
    }

    pub fn deinit(self: *Screen) void {
        for (self.order.items) |w| {
            self.destroyAttachedObject(w);
            self.allocator.destroy(w);
        }
        self.order.deinit(self.allocator);
        self.by_id.deinit(self.allocator);
        self.* = undefined;
    }

    /// Free the typed object hanging off `Window.object` (pw/qw/menu/tw).
    fn destroyAttachedObject(self: *Screen, w: *Window) void {
        const obj = w.object orelse return;
        w.object = null;
        switch (w.vtable.kind) {
            .text => {
                const tw_obj: *tw.TextWindow = @ptrCast(@alignCast(obj));
                self.allocator.destroy(tw_obj);
            },
            .prompt => {
                const pw_obj: *pw.PromptWindow = @ptrCast(@alignCast(obj));
                pw_obj.deinit(self.allocator);
                self.allocator.destroy(pw_obj);
            },
            .query => {
                const qw_obj: *qw.QueryWindow = @ptrCast(@alignCast(obj));
                qw_obj.deinit(self.allocator);
                self.allocator.destroy(qw_obj);
            },
            .menu => {
                const menu_obj: *menu.MenuWindow = @ptrCast(@alignCast(obj));
                self.allocator.destroy(menu_obj);
            },
            .base => {},
        }
    }

    /// Undo a partially constructed window (restore org height, no layout/callbacks).
    fn abandonNewWindow(self: *Screen, w: *Window) void {
        const give_back: u16 = if (w.h != 0) w.h else if (w.req_h != 0) w.req_h else self.desiredHeight(w);
        if (w.org) |oid| {
            if (self.get(oid)) |donor| {
                const cur = if (donor.h != 0) donor.h else if (donor.req_h != 0) donor.req_h else self.desiredHeight(donor);
                self.setHeight(donor, cur + give_back);
            }
        }
        if (self.cur_id == w.id) self.cur_id = w.target orelse w.org orelse 0;
        if (self.top_id == w.id) self.top_id = w.target orelse w.org orelse 0;
        if (self.indexOf(w.id)) |idx| {
            _ = self.order.orderedRemove(idx);
        }
        _ = self.by_id.remove(w.id);
        self.destroyAttachedObject(w);
        self.allocator.destroy(w);
        if (self.order.items.len == 0) {
            self.cur_id = 0;
            self.top_id = 0;
        } else {
            if (self.get(self.cur_id) == null) self.cur_id = self.order.items[0].id;
            if (self.get(self.top_id) == null) self.top_id = self.order.items[0].id;
        }
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

    fn minHeightThis(_: *Screen, w: *const Window) u16 {
        if (w.fixed != 0) return w.fixed;
        if (w.target != null) return 1;
        return fit_min;
    }

    /// Minimum height of a whole family — JOE `getminh`.
    fn minHeight(self: *Screen, w: *Window) u16 {
        const topw = self.findTopOfFamily(w);
        var h: u16 = 0;
        const start = self.indexOf(topw.id) orelse return self.minHeightThis(w);
        var i: usize = start;
        while (i < self.order.items.len) : (i += 1) {
            const cur = self.order.items[i];
            if (cur.main != topw.main) break;
            h += self.minHeightThis(cur);
        }
        return h;
    }

    fn byteCols(text: []const u8) usize {
        return text.len;
    }

    /// Height for a new query child — JOE `mkqw` `break_height`.
    fn queryCreateHeight(self: *const Screen, prompt_text: []const u8) u16 {
        const ph = qw.promptHeight(prompt_text, self.width, byteCols);
        const h: u16 = @intCast(@min(ph, std.math.maxInt(u16)));
        return if (h < 1) 1 else h;
    }

    /// Height for a new menu child — JOE `mkmenu` (≤60% of main, ≤ `mlines`).
    fn menuCreateHeight(self: *Screen, main_id: WindowId, items: []const []const u8) u16 {
        const main_w = self.get(main_id) orelse return 1;
        const main_h: u16 = if (main_w.h != 0) main_w.h else self.desiredHeight(main_w);
        var h: u16 = @intCast((@as(u32, main_h) * 60) / 100);
        if (h < 1) h = 1;
        const lines = menu.linesFor(items, self.width, byteCols);
        if (lines > 0 and lines < h) h = @intCast(lines);
        if (h < 1) h = 1;
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
        const w = try self.createWindow(&tw.vtable, after, null, org, height, null);
        errdefer self.abandonNewWindow(w);
        const obj = try self.allocator.create(tw.TextWindow);
        obj.* = tw.TextWindow.init(w);
        w.object = obj;
        return w;
    }

    /// Create a prompt child and attach a `PromptWindow` — JOE `wmkpw` (height usually 1).
    pub fn createPrompt(
        self: *Screen,
        after: WindowId,
        target: WindowId,
        org: WindowId,
        height: u16,
        prompt_text: []const u8,
    ) !*Window {
        const w = try self.createWindow(&pw.vtable, after, target, org, height, null);
        errdefer self.abandonNewWindow(w);
        const obj = try self.allocator.create(pw.PromptWindow);
        errdefer self.allocator.destroy(obj);
        obj.* = try pw.PromptWindow.init(self.allocator, w, prompt_text);
        // Window.h is 0 until layout; seed prompt geometry with the booked height.
        obj.resize(self.width, height);
        w.object = obj;
        return w;
    }

    /// Create a query child and attach a `QueryWindow` — JOE `mkqw` family.
    /// Height comes from prompt wrap at screen width (`break_height`).
    pub fn createQuery(
        self: *Screen,
        after: WindowId,
        target: WindowId,
        org: WindowId,
        prompt_text: []const u8,
        mode: qw.QueryMode,
    ) !*Window {
        const height = self.queryCreateHeight(prompt_text);
        const w = try self.createWindow(&qw.vtable, after, target, org, height, null);
        errdefer self.abandonNewWindow(w);
        const obj = try self.allocator.create(qw.QueryWindow);
        errdefer self.allocator.destroy(obj);
        obj.* = try qw.QueryWindow.init(self.allocator, w, prompt_text, mode);
        obj.org_w = self.width;
        obj.org_h = height;
        // Window.h is 0 until layout; seed query geometry with the booked height.
        obj.resize(self.width, height);
        w.object = obj;
        return w;
    }

    /// Create a menu child and attach a `MenuWindow` — JOE `mkmenu`.
    /// Height is `min(60% of main, mlines)` at create time.
    pub fn createMenu(
        self: *Screen,
        after: WindowId,
        target: WindowId,
        org: WindowId,
        items: []const []const u8,
        cursor: usize,
    ) !*Window {
        const twnd = self.get(target) orelse return error.UnknownWindow;
        const height = self.menuCreateHeight(twnd.main, items);
        const w = try self.createWindow(&menu.vtable, after, target, org, height, null);
        errdefer self.abandonNewWindow(w);
        const obj = try self.allocator.create(menu.MenuWindow);
        obj.* = menu.MenuWindow.init(w, items, cursor);
        // Window.h is 0 until layout; seed menu geometry with the booked height.
        obj.resize(self.width, height);
        w.object = obj;
        return w;
    }

    /// Abort one window (and dependents) during `layout` without relayouting.
    /// Returns reclaimed height — JOE `doabort` used by `wfit` child squeeze.
    fn abortForFit(self: *Screen, id: WindowId) u16 {
        const w = self.get(id) orelse return 0;
        const amnt: u16 = if (w.nh != 0) w.nh else if (w.h != 0) w.h else self.desiredHeight(w);

        var kill_ids: std.ArrayList(WindowId) = .empty;
        defer kill_ids.deinit(self.allocator);
        kill_ids.append(self.allocator, id) catch return 0;

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
                    kill_ids.append(self.allocator, cand.id) catch return amnt;
                    changed = true;
                }
            }
        }

        if (w.org) |oid| {
            if (self.get(oid)) |donor| {
                const cur = if (donor.h != 0) donor.h else if (donor.nh != 0) donor.nh else self.desiredHeight(donor);
                self.setHeight(donor, cur + amnt);
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
                }
            }
        }
        if (self.top_id == id and self.order.items.len > 1) {
            if (self.indexOf(id)) |idx| {
                const nidx = if (idx + 1 < self.order.items.len) idx + 1 else 0;
                self.top_id = self.order.items[nidx].id;
            }
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
            self.destroyAttachedObject(node);
            self.allocator.destroy(node);
        }

        if (self.get(self.cur_id) == null and self.order.items.len > 0) {
            self.cur_id = self.order.items[0].id;
        }
        if (self.get(self.top_id) == null and self.order.items.len > 0) {
            self.top_id = self.order.items[0].id;
        }
        return amnt;
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
                        var nh_i: i16 = @intCast(w.nh);
                        if (adj > 0) nh_i -= adj;
                        // JOE wfit: abort following children until main has space.
                        while (nh_i < 0 or (w.id == self.cur_id and nh_i < 1)) {
                            if (j + 1 >= self.order.items.len) break;
                            const child = self.order.items[j + 1];
                            if (child.main != fam_top.main or child.target == null) break;
                            const got = self.abortForFit(child.id);
                            if (got == 0) break;
                            nh_i += @as(i16, @intCast(got));
                        }
                        w.nh = @intCast(@max(nh_i, @as(i16, 0)));
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

    /// Switch to next window in order. Relayouts if the target is off-screen.
    pub fn nextWindow(self: *Screen) bool {
        if (self.order.items.len <= 1) return false;
        const idx = self.indexOf(self.cur_id) orelse return false;
        const nidx = if (idx + 1 < self.order.items.len) idx + 1 else 0;
        if (nidx == idx) return false;
        const dest = self.order.items[nidx];
        self.cur_id = dest.id;
        if (dest.y < 0) self.layout();
        return true;
    }

    /// Switch to previous window. If off-screen, set `top_id` to its family top then layout.
    pub fn prevWindow(self: *Screen) bool {
        if (self.order.items.len <= 1) return false;
        const idx = self.indexOf(self.cur_id) orelse return false;
        const pidx: usize = if (idx == 0) self.order.items.len - 1 else idx - 1;
        const dest = self.order.items[pidx];
        self.cur_id = dest.id;
        if (dest.y < 0) {
            self.top_id = self.findTopOfFamily(dest).id;
            self.layout();
        }
        return true;
    }

    fn nextVariableAfter(self: *Screen, from_idx: usize) ?*Window {
        var i = if (from_idx + 1 < self.order.items.len) from_idx + 1 else return null;
        while (i < self.order.items.len) : (i += 1) {
            const w = self.order.items[i];
            if (w.fixed == 0) return w;
        }
        return null;
    }

    /// Grow window by 1 row from the next variable-size window (JOE `wgrow`).
    pub const GrowShrinkError = error{ UnknownWindow, CannotGrow, CannotShrink };

    pub fn grow(self: *Screen, id: WindowId) GrowShrinkError!void {
        const w = self.get(id) orelse return error.UnknownWindow;
        const idx = self.indexOf(id) orelse return error.UnknownWindow;

        // Last on-screen window: shrink previous main instead.
        const is_last_on_screen = (idx + 1 >= self.order.items.len) or (self.order.items[idx + 1].y < 0);
        if (is_last_on_screen and w.id != self.top_id) {
            if (idx == 0) return error.CannotGrow;
            const prev_main_id = self.order.items[idx - 1].main;
            return self.shrink(prev_main_id);
        }

        const nextw = self.nextVariableAfter(idx) orelse return error.CannotGrow;
        if (nextw.y < 0 or nextw.h <= fit_height) return error.CannotGrow;

        self.setHeight(w, w.h + 1);
        self.setHeight(nextw, nextw.h - 1);
        self.layout();
    }

    /// Shrink window by 1 row, giving space to the next variable-size window (JOE `wshrink`).
    pub fn shrink(self: *Screen, id: WindowId) GrowShrinkError!void {
        const w = self.get(id) orelse return error.UnknownWindow;
        const idx = self.indexOf(id) orelse return error.UnknownWindow;

        const is_last_on_screen = (idx + 1 >= self.order.items.len) or (self.order.items[idx + 1].y < 0);
        if (is_last_on_screen and w.id != self.top_id) {
            if (idx == 0) return error.CannotShrink;
            const prev_main_id = self.order.items[idx - 1].main;
            return self.grow(prev_main_id);
        }

        if (w.h <= fit_height) return error.CannotShrink;
        const nextw = self.nextVariableAfter(idx) orelse return error.CannotShrink;

        self.setHeight(w, w.h - 1);
        self.setHeight(nextw, nextw.h + 1);
        self.layout();
    }

    /// Equalize main windows across the screen (JOE `wshowall`).
    pub fn showAll(self: *Screen) void {
        var n: usize = 0;
        for (self.order.items) |w| {
            if (w.target == null) n += 1;
        }
        if (n == 0) return;
        var set: u16 = @intCast(self.usableHeight() / n);
        if (set < fit_height) set = fit_height;
        for (self.order.items) |w| {
            if (w.target != null) continue;
            // JOE `getminh`: main + children mins so equalize leaves room for prompts/menus.
            const fam_min = self.minHeight(w);
            if (fam_min >= set) self.setHeight(w, fit_min) else self.setHeight(w, set - (fam_min - fit_min));
            w.org = null;
        }
        self.layout();
    }

    /// Give almost all space to one family (JOE `wshowone`).
    pub fn showOne(self: *Screen, id: WindowId) !void {
        const focus = self.get(id) orelse return error.UnknownWindow;
        const focus_main = focus.main;
        for (self.order.items) |w| {
            if (w.target != null) continue;
            // JOE sets every main to (h-wind)-(getminh-FITMIN); fit then keeps cursor family.
            const fam_extra = self.minHeight(w) -| fit_min;
            self.setHeight(w, self.usableHeight() - fam_extra);
            w.org = null;
        }
        self.cur_id = focus_main;
        self.top_id = self.findTopOfFamily(self.get(focus_main).?).id;
        self.layout();
    }

    /// Split a main text window horizontally, taking half its height for a new sibling.
    pub fn splitText(self: *Screen, id: WindowId) !*Window {
        const w = self.get(id) orelse return error.UnknownWindow;
        if (w.target != null) return error.NotMainWindow;
        if (w.h < fit_height * 2) return error.NotEnoughSpace;
        const half: u16 = w.h / 2;
        const other: u16 = w.h - half;
        self.setHeight(w, other);
        // create after w, new family, no org (force others — but we already resized w)
        const neu = try self.createText(w.id, null, half);
        self.layout();
        return neu;
    }

    /// Reserve help lines at top (JOE `wind`) and relayout.
    pub fn setHelpLines(self: *Screen, lines: u16) void {
        self.wind = lines;
        if (self.usableHeight() < fit_min) {
            self.wind = self.height -| fit_min;
        }
        self.layout();
    }

    /// Abort window and its dependents; return height to `org` when present.
    /// Main-window messages transfer to the new current window when unset (JOE `wabort`).
    pub fn close(self: *Screen, id: WindowId) !void {
        const w = self.get(id) orelse return error.UnknownWindow;

        // Capture main-window messages before destroy (JOE transfers only for `w == w->main`).
        const transfer_msgs = w.target == null;
        const xfer_top = if (transfer_msgs) w.msg_top else null;
        const xfer_bot = if (transfer_msgs) w.msg_bot else null;

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
            self.destroyAttachedObject(node);
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

        // Transfer orphaned main-window messages onto the new current window.
        if (self.current()) |cur| {
            if (xfer_top) |t| {
                if (cur.msg_top == null) cur.msg_top = t;
            }
            if (xfer_bot) |b| {
                if (cur.msg_bot == null) cur.msg_bot = b;
            }
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
    const prompt = try scr.createPrompt(twnd.id, twnd.id, twnd.id, 1, "File: ");
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
    try testing.expect(scr.nextWindow());
    try testing.expectEqual(b.id, scr.cur_id);
    try testing.expect(scr.nextWindow());
    try testing.expectEqual(a.id, scr.cur_id);
    try testing.expect(scr.prevWindow());
    try testing.expectEqual(b.id, scr.cur_id);
}

test "close returns space to org" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const twnd = try scr.createText(null, null, 24);
    scr.layout();
    const prompt = try scr.createPrompt(twnd.id, twnd.id, twnd.id, 2, "Replace with: ");
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

test "grow and shrink transfer one row" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 12);
    const b = try scr.createText(a.id, null, 12);
    scr.layout();
    try scr.grow(a.id);
    try testing.expectEqual(@as(u16, 13), a.h);
    try testing.expectEqual(@as(u16, 11), b.h);
    try scr.shrink(a.id);
    try testing.expectEqual(@as(u16, 12), a.h);
    try testing.expectEqual(@as(u16, 12), b.h);
}

test "splitText halves a main window" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 24);
    scr.layout();
    const b = try scr.splitText(a.id);
    try testing.expectEqual(@as(usize, 2), scr.countMain());
    try testing.expectEqual(@as(u16, 24), a.h + b.h);
    try testing.expect(a.h >= fit_height);
    try testing.expect(b.h >= fit_height);

    // Both sides must own TextWindow objects synced by layout watom hooks.
    const a_tw = a.asText() orelse return error.TestUnexpectedResult;
    const b_tw = b.asText() orelse return error.TestUnexpectedResult;
    try testing.expect(a_tw.status_on);
    try testing.expect(b_tw.status_on);
    try testing.expectEqual(@as(u16, a.h - 1), a_tw.h);
    try testing.expectEqual(@as(u16, b.h - 1), b_tw.h);
    try testing.expectEqual(@as(i16, a.y + 1), a_tw.y);
    try testing.expectEqual(@as(i16, b.y + 1), b_tw.y);
}

test "setHelpLines reserves wind rows" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 24);
    scr.layout();
    scr.setHelpLines(2);
    try testing.expectEqual(@as(u16, 2), scr.wind);
    try testing.expectEqual(@as(i16, 2), a.y);
    try testing.expectEqual(@as(u16, 22), a.h);
}

test "showAll equalizes main windows" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 18);
    const b = try scr.createText(a.id, null, 6);
    scr.layout();
    scr.showAll();
    try testing.expectEqual(a.h, b.h);
    try testing.expectEqual(@as(u16, 24), a.h + b.h);
}

test "set and clear temporary messages" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const w = try scr.createText(null, null, 24);
    scr.layout();
    try testing.expect(w.msgBotRow() == null);
    try testing.expect(w.msgTopRow(true) == null);

    w.setMsgBot("bottom");
    w.setMsgTop("top");
    try testing.expectEqualStrings("bottom", w.msg_bot.?);
    try testing.expectEqualStrings("top", w.msg_top.?);
    try testing.expectEqual(@as(i16, 23), w.msgBotRow().?);
    // Top-most window with status enabled skips status row -> y+1.
    try testing.expectEqual(@as(i16, 1), w.msgTopRow(true).?);
    // With status disabled on y==0, top message paints at y.
    try testing.expectEqual(@as(i16, 0), w.msgTopRow(false).?);

    w.clearMsgs();
    try testing.expect(w.msg_bot == null);
    try testing.expect(w.msg_top == null);
}

test "composeMsg fills screen msg_buf" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const s = scr.composeMsg("file {s} saved", .{"foo.txt"});
    try testing.expectEqualStrings("file foo.txt saved", s);
    try testing.expect(s.ptr == &scr.msg_buf);
}

test "msgTopRow skips status on non-top window" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 12);
    const b = try scr.createText(a.id, null, 12);
    scr.layout();
    b.setMsgTop("hi");
    try testing.expectEqual(@as(i16, 12), b.y);
    try testing.expectEqual(@as(i16, 13), b.msgTopRow(false).?);
    try testing.expectEqual(@as(i16, 13), b.msgTopRow(true).?);
}

test "closing main transfers messages to current" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 12);
    const b = try scr.createText(a.id, null, 12);
    scr.layout();
    a.setMsgBot("from-a");
    a.setMsgTop("top-a");
    scr.cur_id = a.id;
    try scr.close(a.id);
    const cur = scr.current().?;
    try testing.expectEqual(b.id, cur.id);
    try testing.expectEqualStrings("from-a", cur.msg_bot.?);
    try testing.expectEqualStrings("top-a", cur.msg_top.?);
}

test "closing main does not overwrite existing messages" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 12);
    const b = try scr.createText(a.id, null, 12);
    scr.layout();
    a.setMsgBot("from-a");
    b.setMsgBot("keep-b");
    scr.cur_id = a.id;
    try scr.close(a.id);
    const cur = scr.current().?;
    try testing.expectEqual(b.id, cur.id);
    try testing.expectEqualStrings("keep-b", cur.msg_bot.?);
    try testing.expect(cur.msg_top == null);
}

test "closing child does not transfer messages" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const twnd = try scr.createText(null, null, 24);
    scr.layout();
    const prompt = try scr.createPrompt(twnd.id, twnd.id, twnd.id, 1, "File: ");
    scr.layout();
    prompt.setMsgBot("child-msg");
    try scr.close(prompt.id);
    try testing.expect(twnd.msg_bot == null);
}

test "off-screen families when screen is full" {
    var scr = try Screen.init(testing.allocator, 80, 10);
    defer scr.deinit();

    // Three independent families each wanting most of the screen.
    const a = try scr.createText(null, null, 8);
    const b = try scr.createText(a.id, null, 8);
    const c = try scr.createText(b.id, null, 8);
    scr.cur_id = a.id;
    scr.top_id = a.id;
    scr.layout();

    try testing.expect(a.y >= 0);
    try testing.expect(b.y < 0);
    try testing.expect(c.y < 0);
    try testing.expectEqual(@as(u16, 10), a.h);
}

test "nextWindow brings off-screen family into view" {
    var scr = try Screen.init(testing.allocator, 80, 10);
    defer scr.deinit();

    const a = try scr.createText(null, null, 8);
    const b = try scr.createText(a.id, null, 8);
    const c = try scr.createText(b.id, null, 8);
    scr.cur_id = a.id;
    scr.top_id = a.id;
    scr.layout();
    try testing.expect(b.y < 0);

    try testing.expect(scr.nextWindow());
    try testing.expectEqual(b.id, scr.cur_id);
    try testing.expect(b.y >= 0);
    try testing.expect(a.y < 0 or c.y < 0);

    try testing.expect(scr.nextWindow());
    try testing.expectEqual(c.id, scr.cur_id);
    try testing.expect(c.y >= 0);
}

test "prevWindow jumps top to off-screen family" {
    var scr = try Screen.init(testing.allocator, 80, 10);
    defer scr.deinit();

    const a = try scr.createText(null, null, 8);
    const b = try scr.createText(a.id, null, 8);
    const c = try scr.createText(b.id, null, 8);
    scr.cur_id = a.id;
    scr.top_id = a.id;
    scr.layout();

    try testing.expect(scr.prevWindow());
    try testing.expectEqual(c.id, scr.cur_id);
    try testing.expect(c.y >= 0);
    try testing.expectEqual(scr.findTopOfFamily(c).id, scr.top_id);
}

test "layout aborts children to fit main" {
    var scr = try Screen.init(testing.allocator, 80, 8);
    defer scr.deinit();

    const main_w = try scr.createText(null, null, 8);
    scr.layout();
    // Orphan-org children still count in family height and force squeeze.
    _ = try scr.createWindow(&pw.vtable, main_w.id, main_w.id, null, 3, null);
    _ = try scr.createWindow(&pw.vtable, scr.order.items[scr.order.items.len - 1].id, main_w.id, null, 3, null);
    _ = try scr.createWindow(&pw.vtable, scr.order.items[scr.order.items.len - 1].id, main_w.id, null, 3, null);
    scr.cur_id = main_w.id;
    scr.top_id = main_w.id;
    scr.layout();

    // Main must remain visible with at least 1 row; surplus children aborted.
    try testing.expect(main_w.y >= 0);
    try testing.expect(main_w.h >= 1);
    var child_h: u16 = 0;
    var child_n: usize = 0;
    for (scr.order.items) |w| {
        if (w.main == main_w.id and w.id != main_w.id) {
            child_n += 1;
            child_h += w.h;
        }
    }
    try testing.expect(child_n < 3);
    try testing.expectEqual(@as(u16, 8), main_w.h + child_h);
}

test "create helpers attach typed objects" {
    var scr = try Screen.init(testing.allocator, 40, 24);
    defer scr.deinit();

    const twnd = try scr.createText(null, null, 24);
    scr.layout();
    try testing.expect(twnd.asText() != null);
    try testing.expect(twnd.asText().?.parent == twnd);
    const tw_obj = twnd.asText().?;
    try testing.expect(tw_obj.status_on);
    try testing.expectEqual(@as(u16, 23), tw_obj.h);
    try testing.expectEqual(@as(i16, 1), tw_obj.y);

    const prompt = try scr.createPrompt(twnd.id, twnd.id, twnd.id, 1, "File: ");
    scr.layout();
    const pw_obj = prompt.asPrompt() orelse return error.TestUnexpectedResult;
    try testing.expectEqualStrings("File: ", pw_obj.prompt);
    try testing.expectEqual(twnd.id, pw_obj.target);
    try testing.expect(prompt.asMenu() == null);

    const query = try scr.createQuery(prompt.id, twnd.id, twnd.id, "Kill (y,n,^C)?", .capture);
    scr.layout();
    const qw_obj = query.asQuery() orelse return error.TestUnexpectedResult;
    try testing.expectEqualStrings("Kill (y,n,^C)?", qw_obj.prompt);
    try testing.expect(qw_obj.mode == .capture);
    try testing.expectEqual(@as(u16, 1), qw_obj.org_h);
    try testing.expectEqual(@as(u16, 1), query.h);
    try testing.expectEqual(@as(u16, 1), query.fixed);

    const items = [_][]const u8{ "alpha", "beta", "gamma" };
    const menu_w = try scr.createMenu(query.id, twnd.id, twnd.id, &items, 1);
    scr.layout();
    const menu_obj = menu_w.asMenu() orelse return error.TestUnexpectedResult;
    try testing.expectEqual(@as(usize, 1), menu_obj.cursor);
    try testing.expectEqualStrings("beta", menu_obj.selected().?);
    try testing.expectEqual(@as(usize, 3), menu_obj.grid.nitems);
    try testing.expectEqual(@as(u16, 1), menu_w.h); // 3 short labels fit one row

    // Closing must free attached objects without leaking under GPA.
    try scr.close(menu_w.id);
    try scr.close(query.id);
    try scr.close(prompt.id);
}

test "showAll accounts for family child minima" {
    var scr = try Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();

    const a = try scr.createText(null, null, 12);
    const b = try scr.createText(a.id, null, 12);
    scr.layout();
    _ = try scr.createPrompt(a.id, a.id, a.id, 1, "Name: ");
    scr.layout();

    // Family A min = FITMIN(main)+1(prompt)=3; family B min = 2.
    // Equal share set=12 ⇒ A becomes 11, B becomes 12; prompt keeps 1.
    scr.showAll();
    try testing.expectEqual(@as(u16, 11), a.h);
    try testing.expectEqual(@as(u16, 12), b.h);
    try testing.expectEqual(@as(u16, 24), a.h + b.h + 1);
}

test "createQuery wraps prompt height like mkqw" {
    var scr = try Screen.init(testing.allocator, 10, 24);
    defer scr.deinit();

    const twnd = try scr.createText(null, null, 24);
    scr.layout();
    const prompt = "hello world again"; // wraps to 3 lines at width 10
    const query = try scr.createQuery(twnd.id, twnd.id, twnd.id, prompt, .capture);
    try testing.expectEqual(@as(u16, 3), query.h);
    try testing.expectEqual(@as(u16, 3), query.fixed);
    const qw_obj = query.asQuery().?;
    try testing.expectEqual(@as(u16, 3), qw_obj.org_h);
    try testing.expectEqual(@as(u16, 10), qw_obj.org_w);
}

test "createMenu height uses mlines capped at 60 percent" {
    var scr = try Screen.init(testing.allocator, 80, 20);
    defer scr.deinit();

    const twnd = try scr.createText(null, null, 20);
    scr.layout();
    try testing.expectEqual(@as(u16, 20), twnd.h);

    // Wide labels ⇒ one per row ⇒ mlines=40, then capped at 60% of main (12).
    var bufs: [40][64]u8 = undefined;
    var labels: [40][]const u8 = undefined;
    for (0..40) |i| {
        labels[i] = std.fmt.bufPrint(&bufs[i], "item-{d:0>40}", .{i}) catch unreachable;
    }
    const menu_w = try scr.createMenu(twnd.id, twnd.id, twnd.id, labels[0..], 0);
    try testing.expectEqual(@as(u16, 12), menu_w.h); // 60% of 20
    try testing.expectEqual(@as(u16, 12), menu_w.fixed);
    try testing.expectEqual(@as(u16, 12), menu_w.asMenu().?.h);

    const few = [_][]const u8{ "a", "b", "c" };
    const small = try scr.createMenu(menu_w.id, twnd.id, twnd.id, &few, 0);
    try testing.expectEqual(@as(u16, 1), small.h);
}

test "vtable kinds resolve" {
    try testing.expectEqual(WindowKind.text, tw.vtable.kind);
    try testing.expectEqual(WindowKind.prompt, pw.vtable.kind);
    try testing.expectEqual(WindowKind.query, qw.vtable.kind);
    try testing.expectEqual(WindowKind.menu, menu.vtable.kind);
}
