//! Zig-native prompt window (Phase 5 redesign).
//!
//! Parallel to hybrid `src/pw.zig`. Owns history + Enter/abort/TAB callback
//! shapes; not wired into the live `joe` binary yet — unit-tested only.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const screen = @import("screen.zig");

fn onResize(w: *screen.Window, wi: u16, he: u16) void {
    const p = w.asPrompt() orelse return;
    p.resize(wi, he);
}

fn onMove(w: *screen.Window, x: u16, y: i16) void {
    const p = w.asPrompt() orelse return;
    p.x = x;
    p.y = y;
}

fn onAbort(w: *screen.Window) i32 {
    const p = w.asPrompt() orelse return -1;
    return p.abort();
}

pub const vtable: screen.WindowVTable = .{
    .kind = .prompt,
    .context = "prompt",
    .on_resize = onResize,
    .on_move = onMove,
    .on_abort = onAbort,
};

/// Mirrors JOE `PWFLAG_*`.
pub const PromptFlags = packed struct(u8) {
    /// Filename prompt ⇒ ~ expansion / `//` restart (JOE `PWFLAG_FILENAME`).
    filename: bool = false,
    /// Update buffer current-dir on submit (JOE `PWFLAG_UPDATE_CD`).
    update_cd: bool = false,
    /// Seed edit line with current directory (JOE `PWFLAG_SEED_CD`).
    seed_cd: bool = false,
    /// Shell-command prompt (JOE `PWFLAG_COMMAND`).
    command: bool = false,
    _pad: u4 = 0,

    pub fn fromBits(bits: u8) PromptFlags {
        return @bitCast(bits);
    }

    pub fn toBits(self: PromptFlags) u8 {
        return @bitCast(self);
    }
};

pub const PromptFn = *const fn (target: screen.WindowId, text: []const u8, object: ?*anyopaque, notify: ?*i32) i32;
pub const AbortFn = *const fn (target: screen.WindowId, object: ?*anyopaque) i32;
pub const TabFn = *const fn (pw: *PromptWindow, key: u8) i32;

/// Line-oriented history (JOE history `B*`, without gap-buffer).
pub const History = struct {
    allocator: Allocator,
    lines: std.ArrayListUnmanaged([]u8) = .empty,

    pub fn init(allocator: Allocator) History {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *History) void {
        for (self.lines.items) |line| {
            self.allocator.free(line);
        }
        self.lines.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn len(self: *const History) usize {
        return self.lines.items.len;
    }

    /// Append a copy of `text` (JOE `append_history`). Empty strings are kept.
    pub fn append(self: *History, text: []const u8) !void {
        const copy = try self.allocator.dupe(u8, text);
        errdefer self.allocator.free(copy);
        try self.lines.append(self.allocator, copy);
    }

    /// Move line at `index` to the end (JOE `promote_history`).
    pub fn promote(self: *History, index: usize) !void {
        if (index >= self.lines.items.len) return error.OutOfBounds;
        if (index + 1 == self.lines.items.len) return;
        const line = self.lines.orderedRemove(index);
        try self.lines.append(self.allocator, line);
    }

    pub fn get(self: *const History, index: usize) ?[]const u8 {
        if (index >= self.lines.items.len) return null;
        return self.lines.items[index];
    }
};


/// Prompt scroll/cursor layout (JOE `disppw` positioning math).
pub const Layout = struct {
    prompt_ofst: usize = 0,
    /// Edit-buffer horizontal offset (JOE `bw->offset`).
    edit_offset: usize = 0,
    curx: usize = 0,
    cury: usize = 0,
    /// Visible prompt columns: `promptLen - prompt_ofst`.
    prompt_visible: usize = 0,
    /// Columns left for the edit line: `w - prompt_visible`.
    edit_width: usize = 0,
};

pub const PromptWindow = struct {
    parent: *screen.Window,
    /// Owned prompt bytes (may include JOE fmt escapes later).
    prompt: []u8,
    prompt_ofst: usize = 0,
    /// Current edit contents (JOE prompt BW single line).
    line: std.ArrayListUnmanaged(u8) = .empty,
    /// When browsing history: index of the loaded line; `null` ⇒ fresh/edited.
    hist_index: ?usize = null,
    /// True when `line` differs from the history entry it was loaded from.
    changed: bool = false,
    history: ?*History = null,
    flags: PromptFlags = .{},
    /// Window geometry mirror for paint/layout hooks (JOE `disppw` reads `W`).
    w: u16 = 0,
    h: u16 = 0,
    x: u16 = 0,
    y: i16 = 0,
    on_submit: ?PromptFn = null,
    on_abort: ?AbortFn = null,
    on_tab: ?TabFn = null,
    object: ?*anyopaque = null,
    /// Target window the prompt operates on (JOE `w->win`).
    target: screen.WindowId = 0,
    huh: ?[]const u8 = null,

    pub fn init(allocator: Allocator, parent: *screen.Window, prompt_text: []const u8) !PromptWindow {
        return .{
            .parent = parent,
            .prompt = try allocator.dupe(u8, prompt_text),
            .w = parent.w,
            .h = if (parent.h != 0) parent.h else 1,
            .x = parent.x,
            .y = parent.y,
            .target = parent.target orelse parent.main,
        };
    }

    pub fn deinit(self: *PromptWindow, allocator: Allocator) void {
        allocator.free(self.prompt);
        self.line.deinit(allocator);
        self.* = undefined;
    }

    /// Keep geometry in sync with the parent window after layout.
    pub fn resize(self: *PromptWindow, wi: u16, he: u16) void {
        self.w = wi;
        self.h = he;
    }

    /// JOE `disppw` prompt/edit scroll math. Updates `prompt_ofst`.
    /// `cursor_col` is the edit-line display column (JOE `piscol`).
    pub fn computeLayout(self: *PromptWindow, cursor_col: usize) Layout {
        const wi: usize = self.w;
        const prompt_len = self.promptLen();
        var prompt_ofst: usize = 0;
        var edit_offset: usize = 0;

        if (wi == 0) {
            self.prompt_ofst = 0;
            return .{};
        }

        if (prompt_len > wi -| 5) {
            prompt_ofst = prompt_len -| (wi / 2);
            const prompt_vis = prompt_len -| prompt_ofst;
            if (cursor_col < wi -| prompt_vis) {
                edit_offset = 0;
            } else {
                edit_offset = cursor_col -| (wi -| prompt_vis -| 1);
            }
        } else {
            if (cursor_col < wi -| prompt_len) {
                prompt_ofst = 0;
                edit_offset = 0;
            } else if (cursor_col >= wi) {
                prompt_ofst = prompt_len;
                edit_offset = cursor_col -| (wi -| 1);
            } else {
                prompt_ofst = prompt_len -| (wi -| cursor_col -| 1);
                const prompt_vis = prompt_len -| prompt_ofst;
                edit_offset = cursor_col -| (wi -| prompt_vis -| 1);
            }
        }

        self.prompt_ofst = prompt_ofst;
        const prompt_visible = prompt_len -| prompt_ofst;
        const edit_width = wi -| prompt_visible;
        const curx = cursor_col -| edit_offset + prompt_visible;
        return .{
            .prompt_ofst = prompt_ofst,
            .edit_offset = edit_offset,
            .curx = curx,
            .cury = 0,
            .prompt_visible = prompt_visible,
            .edit_width = edit_width,
        };
    }

    /// Prompt bytes starting at `prompt_ofst` (JOE `genfmt` ofst).
    pub fn visiblePrompt(self: *const PromptWindow) []const u8 {
        const ofst = @min(self.prompt_ofst, self.prompt.len);
        return self.prompt[ofst..];
    }

    pub fn setLine(self: *PromptWindow, allocator: Allocator, text: []const u8) !void {
        self.line.clearRetainingCapacity();
        try self.line.appendSlice(allocator, text);
        self.changed = true;
        self.hist_index = null;
    }

    /// Load history line `index` into the edit buffer (browse).
    pub fn loadHistory(self: *PromptWindow, allocator: Allocator, index: usize) !void {
        const hist = self.history orelse return error.NoHistory;
        const text = hist.get(index) orelse return error.OutOfBounds;
        self.line.clearRetainingCapacity();
        try self.line.appendSlice(allocator, text);
        self.hist_index = index;
        self.changed = false;
    }

    pub fn replaceLine(self: *PromptWindow, allocator: Allocator, text: []const u8) !void {
        self.line.clearRetainingCapacity();
        try self.line.appendSlice(allocator, text);
        self.changed = true;
    }

    /// Display columns occupied by the prompt (byte length for now).
    pub fn promptLen(self: *const PromptWindow) usize {
        return self.prompt.len;
    }

    /// JOE `rtnpw` history side-effect + submit callback (no window abort/layout).
    /// Returns callback result, or `-1` when no callback.
    pub fn submit(self: *PromptWindow, notify: ?*i32) !i32 {
        const text = self.line.items;
        if (self.history) |hist| {
            if (self.changed or self.hist_index == null) {
                try hist.append(text);
            } else if (self.hist_index) |idx| {
                try hist.promote(idx);
            }
        }
        const cb = self.on_submit orelse return -1;
        return cb(self.target, text, self.object, notify);
    }

    /// JOE `abortpw` callback path (no window teardown).
    pub fn abort(self: *PromptWindow) i32 {
        const cb = self.on_abort orelse return -1;
        return cb(self.target, self.object);
    }

    /// JOE `ucmplt` → `pw->tab`.
    pub fn complete(self: *PromptWindow, key: u8) i32 {
        const cb = self.on_tab orelse return -1;
        return cb(self, key);
    }
};

test "PromptFlags bit layout matches JOE PWFLAG_*" {
    try testing.expectEqual(@as(u8, 1), (PromptFlags{ .filename = true }).toBits());
    try testing.expectEqual(@as(u8, 2), (PromptFlags{ .update_cd = true }).toBits());
    try testing.expectEqual(@as(u8, 4), (PromptFlags{ .seed_cd = true }).toBits());
    try testing.expectEqual(@as(u8, 8), (PromptFlags{ .command = true }).toBits());
    try testing.expectEqual(PromptFlags{ .filename = true, .update_cd = true }, PromptFlags.fromBits(3));
}

test "History append and promote" {
    var hist = History.init(testing.allocator);
    defer hist.deinit();

    try hist.append("one");
    try hist.append("two");
    try hist.append("three");
    try testing.expectEqual(@as(usize, 3), hist.len());
    try hist.promote(0);
    try testing.expectEqualStrings("two", hist.get(0).?);
    try testing.expectEqualStrings("three", hist.get(1).?);
    try testing.expectEqualStrings("one", hist.get(2).?);
    try hist.promote(2); // already last — no-op move
    try testing.expectEqualStrings("one", hist.get(2).?);
}

test "PromptWindow submit appends when changed" {
    var hist = History.init(testing.allocator);
    defer hist.deinit();
    try hist.append("old");

    var scr = try screen.Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);

    var pw_win = try PromptWindow.init(testing.allocator, win, "File: ");
    defer pw_win.deinit(testing.allocator);
    pw_win.history = &hist;
    try pw_win.setLine(testing.allocator, "newfile.txt");

    var got_text: ?[]const u8 = null;
    var got_target: screen.WindowId = 0;
    const SubmitCtx = struct {
        text: *?[]const u8,
        target: *screen.WindowId,
        fn onSubmit(target: screen.WindowId, text: []const u8, object: ?*anyopaque, notify: ?*i32) i32 {
            _ = notify;
            const ctx: *@This() = @ptrCast(@alignCast(object.?));
            ctx.text.* = text;
            ctx.target.* = target;
            return 7;
        }
    };
    var ctx = SubmitCtx{ .text = &got_text, .target = &got_target };
    pw_win.object = &ctx;
    pw_win.on_submit = SubmitCtx.onSubmit;

    try testing.expectEqual(@as(i32, 7), try pw_win.submit(null));
    try testing.expectEqual(win.id, got_target);
    try testing.expectEqualStrings("newfile.txt", got_text.?);
    try testing.expectEqual(@as(usize, 2), hist.len());
    try testing.expectEqualStrings("newfile.txt", hist.get(1).?);
}

test "PromptWindow submit promotes unchanged history line" {
    var hist = History.init(testing.allocator);
    defer hist.deinit();
    try hist.append("alpha");
    try hist.append("beta");
    try hist.append("gamma");

    var scr = try screen.Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);

    var pw_win = try PromptWindow.init(testing.allocator, win, "Command: ");
    defer pw_win.deinit(testing.allocator);
    pw_win.history = &hist;
    try pw_win.loadHistory(testing.allocator, 0);
    try testing.expectEqual(@as(i32, -1), try pw_win.submit(null));
    try testing.expectEqualStrings("beta", hist.get(0).?);
    try testing.expectEqualStrings("gamma", hist.get(1).?);
    try testing.expectEqualStrings("alpha", hist.get(2).?);
}

test "PromptWindow abort and tab callbacks" {
    var scr = try screen.Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);

    var pw_win = try PromptWindow.init(testing.allocator, win, "Find: ");
    defer pw_win.deinit(testing.allocator);

    var aborted = false;
    var tab_key: u8 = 0;
    const Cbs = struct {
        aborted: *bool,
        tab_key: *u8,
        fn onAbort(target: screen.WindowId, object: ?*anyopaque) i32 {
            _ = target;
            const ctx: *@This() = @ptrCast(@alignCast(object.?));
            ctx.aborted.* = true;
            return 0;
        }
        fn onTab(pw: *PromptWindow, key: u8) i32 {
            const ctx: *@This() = @ptrCast(@alignCast(pw.object.?));
            ctx.tab_key.* = key;
            return 1;
        }
    };
    var ctx = Cbs{ .aborted = &aborted, .tab_key = &tab_key };
    pw_win.object = &ctx;
    pw_win.on_abort = Cbs.onAbort;
    pw_win.on_tab = Cbs.onTab;

    try testing.expectEqual(@as(i32, 0), pw_win.abort());
    try testing.expect(aborted);
    try testing.expectEqual(@as(i32, 1), pw_win.complete('\t'));
    try testing.expectEqual(@as(u8, '\t'), tab_key);
}

test "PromptWindow vtable resize/move/abort hooks" {
    var scr = try screen.Screen.init(testing.allocator, 80, 24);
    defer scr.deinit();
    const twnd = try scr.createText(null, null, 24);
    scr.layout();
    const prompt = try scr.createPrompt(twnd.id, twnd.id, twnd.id, 1, "File: ");
    scr.layout();

    const obj = prompt.asPrompt().?;
    try testing.expectEqual(prompt.w, obj.w);
    try testing.expectEqual(prompt.h, obj.h);
    try testing.expectEqual(prompt.x, obj.x);
    try testing.expectEqual(prompt.y, obj.y);

    vtable.on_resize.?(prompt, 60, 1);
    try testing.expectEqual(@as(u16, 60), obj.w);
    try testing.expectEqual(@as(u16, 1), obj.h);

    vtable.on_move.?(prompt, 4, 9);
    try testing.expectEqual(@as(u16, 4), obj.x);
    try testing.expectEqual(@as(i16, 9), obj.y);

    var aborted = false;
    const Cbs = struct {
        aborted: *bool,
        fn onAbort(target: screen.WindowId, object: ?*anyopaque) i32 {
            _ = target;
            const ctx: *@This() = @ptrCast(@alignCast(object.?));
            ctx.aborted.* = true;
            return 4;
        }
    };
    var ctx = Cbs{ .aborted = &aborted };
    obj.object = &ctx;
    obj.on_abort = Cbs.onAbort;
    try testing.expectEqual(@as(i32, 4), vtable.on_abort.?(prompt));
    try testing.expect(aborted);
}

test "PromptWindow computeLayout keeps short prompt fixed" {
    var scr = try screen.Screen.init(testing.allocator, 40, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    win.w = 40;

    var pw_win = try PromptWindow.init(testing.allocator, win, "File: ");
    defer pw_win.deinit(testing.allocator);
    try pw_win.setLine(testing.allocator, "hello.txt");

    const lay = pw_win.computeLayout(5);
    try testing.expectEqual(@as(usize, 0), lay.prompt_ofst);
    try testing.expectEqual(@as(usize, 0), lay.edit_offset);
    try testing.expectEqual(@as(usize, 0), lay.cury);
    try testing.expectEqual(@as(usize, 6 + 5), lay.curx); // "File: " + col 5
    try testing.expectEqualStrings("File: ", pw_win.visiblePrompt());
}

test "PromptWindow computeLayout scrolls long prompt" {
    var scr = try screen.Screen.init(testing.allocator, 20, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    win.w = 20;

    // prompt_len=30 > w-5=15 ⇒ first branch; ofst = 30 - 10 = 20
    var pw_win = try PromptWindow.init(testing.allocator, win, "ABCDEFGHIJ0123456789PROMPT!!");
    defer pw_win.deinit(testing.allocator);
    try testing.expectEqual(@as(usize, 28), pw_win.promptLen());

    const lay = pw_win.computeLayout(0);
    try testing.expectEqual(@as(usize, 28 - 10), lay.prompt_ofst);
    try testing.expectEqual(@as(usize, 0), lay.edit_offset);
    try testing.expectEqual(lay.prompt_ofst, pw_win.prompt_ofst);
    try testing.expectEqualStrings("89PROMPT!!", pw_win.visiblePrompt());
    try testing.expectEqual(lay.prompt_visible, lay.curx);
}

