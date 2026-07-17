//! Zig-native query window (Phase 5 redesign).
//!
//! Parallel to hybrid `src/qw.zig`. Owns prompt wrap (`breakHeight`) +
//! single-key accept/abort callback shapes; not wired into live `joe` yet.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const screen = @import("screen.zig");

fn onResize(w: *screen.Window, wi: u16, he: u16) void {
    const q = w.asQuery() orelse return;
    q.resize(wi, he);
}

fn onMove(w: *screen.Window, x: u16, y: i16) void {
    const q = w.asQuery() orelse return;
    q.x = x;
    q.y = y;
}

fn onAbort(w: *screen.Window) i32 {
    const q = w.asQuery() orelse return -1;
    return q.abort();
}

pub const vtable: screen.WindowVTable = .{
    .kind = .query,
    .context = "query",
    .on_resize = onResize,
    .on_move = onMove,
    .on_abort = onAbort,
};

/// Creation / focus variants — JOE `mkqw` / `mkqwna` / `mkqwnsr`.
pub const QueryMode = enum {
    /// Focus moves to the query window (`watomqw`).
    capture,
    /// Cursor stays in original window (`watqwn`).
    leave_cursor,
    /// Search/replace overlay (`watqwsr`).
    search_replace,

    pub fn contextName(self: QueryMode) []const u8 {
        return switch (self) {
            .capture => "query",
            .leave_cursor => "querya",
            .search_replace => "querysr",
        };
    }
};

pub const QueryFn = *const fn (target: screen.WindowId, key: u8, object: ?*anyopaque, notify: ?*i32) i32;
pub const AbortFn = *const fn (target: screen.WindowId, object: ?*anyopaque) i32;

/// Optional column-width of a byte slice; default treats each byte as width 1.
pub const WidthFn = *const fn (text: []const u8) usize;

fn byteWidth(text: []const u8) usize {
    return text.len;
}

/// Result of `breakHeight` when selecting a wrapped line (`n >= 0`).
pub const BreakLine = struct {
    /// Total wrapped height of the prompt at `width`.
    height: usize,
    /// Slice of `prompt` for wrapped line `n` (empty when `n` past end).
    line: []const u8,
};

/// JOE `break_height`: word-wrap prompt to `width` columns.
///
/// When `n == null`, only the height is meaningful (`line` is the last line).
/// When `n` is set, `line` is the `n`th wrapped line (0-based).
pub fn breakHeight(prompt: []const u8, width: usize, n: ?usize, width_of: WidthFn) BreakLine {
    const wfn = width_of;
    if (width == 0) {
        return .{ .height = 1, .line = prompt[0..0] };
    }

    var h: usize = 1;
    var col: usize = 0;
    var x: usize = 0;
    var start_of_line: usize = 0;
    var end_of_line: usize = 0;
    const want = n;

    while (x < prompt.len) {
        const start = x;
        var space: usize = 0;
        while (x < prompt.len and prompt[x] == ' ') {
            space += 1;
            x += 1;
        }
        const start_word = x;
        while (x < prompt.len and prompt[x] != ' ') {
            x += 1;
        }
        const word = wfn(prompt[start_word..x]);

        if (col + space + word < width or col == 0) {
            col += space + word;
            end_of_line = x;
        } else {
            if (want) |line_n| {
                if (line_n + 1 == h) {
                    return .{
                        .height = h, // provisional; caller wanting only the line can ignore
                        .line = prompt[start_of_line..start],
                    };
                }
            }
            h += 1;
            col = word;
            start_of_line = start_word;
            end_of_line = x;
        }
    }

    if (want) |line_n| {
        if (line_n + 1 == h) {
            return .{ .height = h, .line = prompt[start_of_line..end_of_line] };
        }
        // Past last line — return empty slice at end, still report full height.
        return .{ .height = h, .line = prompt[prompt.len..prompt.len] };
    }
    return .{ .height = h, .line = prompt[start_of_line..end_of_line] };
}

/// Convenience: height only (JOE `break_height(..., -1)`).
pub fn promptHeight(prompt: []const u8, width: usize, width_of: WidthFn) usize {
    return breakHeight(prompt, width, null, width_of).height;
}


/// Window-relative cursor after paint (JOE `W.curx` / `W.cury`).
pub const CursorPos = struct {
    x: usize = 0,
    y: usize = 0,
};

/// Tests-only paint rows for a query prompt (JOE `dispqw` shape).
pub const Paint = struct {
    allocator: Allocator,
    /// One owned, space-padded row per visible line (`h` rows of width `w`).
    rows: [][]u8,
    w: usize,
    cur: CursorPos = .{},

    pub fn deinit(self: *Paint) void {
        for (self.rows) |row| self.allocator.free(row);
        self.allocator.free(self.rows);
        self.* = undefined;
    }
};

pub const QueryWindow = struct {
    parent: *screen.Window,
    /// Owned prompt bytes.
    prompt: []u8,
    mode: QueryMode = .capture,
    /// Width used when the query was created (JOE `org_w`).
    org_w: u16 = 0,
    /// Height booked at create time (JOE `org_h`).
    org_h: u16 = 0,
    /// Window geometry mirror for paint/layout hooks (JOE reads `W` directly).
    w: u16 = 0,
    h: u16 = 0,
    x: u16 = 0,
    y: i16 = 0,
    on_key: ?QueryFn = null,
    on_abort: ?AbortFn = null,
    object: ?*anyopaque = null,
    target: screen.WindowId = 0,

    pub fn init(allocator: Allocator, parent: *screen.Window, prompt_text: []const u8, mode: QueryMode) !QueryWindow {
        const prompt = try allocator.dupe(u8, prompt_text);
        errdefer allocator.free(prompt);
        const h = promptHeight(prompt_text, parent.w, byteWidth);
        const booked: u16 = @intCast(@min(h, std.math.maxInt(u16)));
        return .{
            .parent = parent,
            .prompt = prompt,
            .mode = mode,
            .org_w = parent.w,
            .org_h = booked,
            .w = parent.w,
            .h = if (parent.h != 0) parent.h else booked,
            .x = parent.x,
            .y = parent.y,
            .target = parent.target orelse parent.main,
        };
    }

    pub fn deinit(self: *QueryWindow, allocator: Allocator) void {
        allocator.free(self.prompt);
        self.* = undefined;
    }

    /// Keep geometry in sync with the parent window after layout.
    pub fn resize(self: *QueryWindow, wi: u16, he: u16) void {
        self.w = wi;
        self.h = he;
    }

    pub fn promptLen(self: *const QueryWindow) usize {
        return self.prompt.len;
    }

    pub fn heightForWidth(self: *const QueryWindow, width: usize) usize {
        return promptHeight(self.prompt, width, byteWidth);
    }

    /// Build wrapped prompt rows for the current geometry (JOE `dispqw`).
    /// Uses `org_w` for wrapping (JOE `break_height(..., qw->org_w, y)`).
    pub fn paint(self: *const QueryWindow, allocator: Allocator) !Paint {
        const wi: usize = self.w;
        const he: usize = self.h;
        var rows = try allocator.alloc([]u8, he);
        errdefer {
            for (rows) |row| allocator.free(row);
            allocator.free(rows);
        }
        var cur: CursorPos = .{};
        var y: usize = 0;
        while (y < he) : (y += 1) {
            const br = breakHeight(self.prompt, self.org_w, y, byteWidth);
            const row = try allocator.alloc(u8, wi);
            errdefer allocator.free(row);
            @memset(row, ' ');
            const n = @min(wi, br.line.len);
            if (n > 0) @memcpy(row[0..n], br.line[0..n]);
            rows[y] = row;
            // Capture-mode cursor tracks the last painted line end (relative).
            cur.y = y;
            cur.x = @min(wi, byteWidth(br.line));
        }
        return .{
            .allocator = allocator,
            .rows = rows,
            .w = wi,
            .cur = cur,
        };
    }

    /// JOE `utypeqw` — invoke key callback (no window teardown).
    pub fn acceptKey(self: *QueryWindow, key: u8, notify: ?*i32) i32 {
        const cb = self.on_key orelse return -1;
        return cb(self.target, key, self.object, notify);
    }

    /// JOE `abortqw`.
    pub fn abort(self: *QueryWindow) i32 {
        const cb = self.on_abort orelse return -1;
        return cb(self.target, self.object);
    }
};

test "QueryMode context names match JOE watoms" {
    try testing.expectEqualStrings("query", QueryMode.capture.contextName());
    try testing.expectEqualStrings("querya", QueryMode.leave_cursor.contextName());
    try testing.expectEqualStrings("querysr", QueryMode.search_replace.contextName());
}

test "breakHeight wraps on word boundaries" {
    const prompt = "Replace with (S to skip) [foo]";
    // Width 10: "Replace" (7) fits; " with" needs wrap, etc.
    const h = promptHeight(prompt, 10, byteWidth);
    try testing.expect(h >= 3);

    const line0 = breakHeight(prompt, 10, 0, byteWidth);
    try testing.expectEqualStrings("Replace", line0.line);

    const line1 = breakHeight(prompt, 10, 1, byteWidth);
    // New line starts at the word that did not fit (JOE `start_of_line = start_word`).
    try testing.expectEqualStrings("with (S", line1.line);

    const all = breakHeight(prompt, 80, null, byteWidth);
    try testing.expectEqual(@as(usize, 1), all.height);
    try testing.expectEqualStrings(prompt, all.line);
}

test "breakHeight long word still advances" {
    // Word longer than width: JOE keeps it on the current line when col==0.
    const prompt = "ABCDEFGHIJ";
    const r = breakHeight(prompt, 4, null, byteWidth);
    try testing.expectEqual(@as(usize, 1), r.height);
    try testing.expectEqualStrings(prompt, r.line);
}

test "QueryWindow acceptKey and abort callbacks" {
    var scr = try screen.Screen.init(testing.allocator, 40, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);

    var qw_win = try QueryWindow.init(testing.allocator, win, "Kill this block (y,n,^C)?", .capture);
    defer qw_win.deinit(testing.allocator);
    try testing.expectEqual(@as(u16, 40), qw_win.org_w);
    try testing.expect(qw_win.org_h >= 1);

    var seen_key: u8 = 0;
    var aborted = false;
    const Cbs = struct {
        key: *u8,
        aborted: *bool,
        fn onKey(target: screen.WindowId, key: u8, object: ?*anyopaque, notify: ?*i32) i32 {
            _ = target;
            _ = notify;
            const ctx: *@This() = @ptrCast(@alignCast(object.?));
            ctx.key.* = key;
            return 3;
        }
        fn onAbort(target: screen.WindowId, object: ?*anyopaque) i32 {
            _ = target;
            const ctx: *@This() = @ptrCast(@alignCast(object.?));
            ctx.aborted.* = true;
            return 0;
        }
    };
    var ctx = Cbs{ .key = &seen_key, .aborted = &aborted };
    qw_win.object = &ctx;
    qw_win.on_key = Cbs.onKey;
    qw_win.on_abort = Cbs.onAbort;

    try testing.expectEqual(@as(i32, 3), qw_win.acceptKey('y', null));
    try testing.expectEqual(@as(u8, 'y'), seen_key);
    try testing.expectEqual(@as(i32, 0), qw_win.abort());
    try testing.expect(aborted);
}

test "QueryWindow leave_cursor mode height for multi-line prompt" {
    var scr = try screen.Screen.init(testing.allocator, 12, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);

    const prompt = "Really delete this file forever? (yes or no)";
    var qw_win = try QueryWindow.init(testing.allocator, win, prompt, .leave_cursor);
    defer qw_win.deinit(testing.allocator);
    try testing.expect(qw_win.org_h > 1);
    try testing.expectEqual(qw_win.org_h, @as(u16, @intCast(qw_win.heightForWidth(12))));
    try testing.expectEqualStrings("querya", qw_win.mode.contextName());
}

test "QueryWindow vtable resize/move/abort hooks" {
    var scr = try screen.Screen.init(testing.allocator, 40, 24);
    defer scr.deinit();
    const twnd = try scr.createText(null, null, 24);
    scr.layout();
    const query = try scr.createQuery(twnd.id, twnd.id, twnd.id, "Kill (y,n,^C)?", .capture);
    scr.layout();

    const obj = query.asQuery().?;
    try testing.expectEqual(query.w, obj.w);
    try testing.expectEqual(query.h, obj.h);
    try testing.expectEqual(query.x, obj.x);
    try testing.expectEqual(query.y, obj.y);

    vtable.on_resize.?(query, 20, 2);
    try testing.expectEqual(@as(u16, 20), obj.w);
    try testing.expectEqual(@as(u16, 2), obj.h);

    vtable.on_move.?(query, 3, 5);
    try testing.expectEqual(@as(u16, 3), obj.x);
    try testing.expectEqual(@as(i16, 5), obj.y);

    var aborted = false;
    const Cbs = struct {
        aborted: *bool,
        fn onAbort(target: screen.WindowId, object: ?*anyopaque) i32 {
            _ = target;
            const ctx: *@This() = @ptrCast(@alignCast(object.?));
            ctx.aborted.* = true;
            return 9;
        }
    };
    var ctx = Cbs{ .aborted = &aborted };
    obj.object = &ctx;
    obj.on_abort = Cbs.onAbort;
    try testing.expectEqual(@as(i32, 9), vtable.on_abort.?(query));
    try testing.expect(aborted);
}

test "QueryWindow paint wraps prompt lines and sets cursor" {
    var scr = try screen.Screen.init(testing.allocator, 10, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    win.w = 10;

    const prompt = "Replace with (S to skip)";
    var qw_win = try QueryWindow.init(testing.allocator, win, prompt, .capture);
    defer qw_win.deinit(testing.allocator);
    // Force a 3-line viewport at org_w=10.
    qw_win.h = 3;
    qw_win.w = 10;
    qw_win.org_w = 10;

    const line0 = breakHeight(prompt, 10, 0, byteWidth);
    const line1 = breakHeight(prompt, 10, 1, byteWidth);
    const line2 = breakHeight(prompt, 10, 2, byteWidth);

    var painted = try qw_win.paint(testing.allocator);
    defer painted.deinit();
    try testing.expectEqual(@as(usize, 3), painted.rows.len);

    var expect0: [10]u8 = undefined;
    @memset(&expect0, ' ');
    @memcpy(expect0[0..line0.line.len], line0.line);
    try testing.expectEqualStrings(&expect0, painted.rows[0]);

    var expect1: [10]u8 = undefined;
    @memset(&expect1, ' ');
    const n1 = @min(10, line1.line.len);
    if (n1 > 0) @memcpy(expect1[0..n1], line1.line[0..n1]);
    try testing.expectEqualStrings(&expect1, painted.rows[1]);

    try testing.expectEqualStrings("Replace", line0.line);
    try testing.expectEqual(@as(usize, 2), painted.cur.y);
    try testing.expectEqual(@min(@as(usize, 10), byteWidth(line2.line)), painted.cur.x);
}

