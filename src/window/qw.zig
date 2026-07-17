//! Zig-native query window (Phase 5 redesign).
//!
//! Parallel to hybrid `src/qw.zig`. Owns prompt wrap (`breakHeight`) +
//! single-key accept/abort callback shapes; not wired into live `joe` yet.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const screen = @import("screen.zig");

pub const vtable: screen.WindowVTable = .{
    .kind = .query,
    .context = "query",
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

pub const QueryWindow = struct {
    parent: *screen.Window,
    /// Owned prompt bytes.
    prompt: []u8,
    mode: QueryMode = .capture,
    /// Width used when the query was created (JOE `org_w`).
    org_w: u16 = 0,
    /// Height booked at create time (JOE `org_h`).
    org_h: u16 = 0,
    on_key: ?QueryFn = null,
    on_abort: ?AbortFn = null,
    object: ?*anyopaque = null,
    target: screen.WindowId = 0,

    pub fn init(allocator: Allocator, parent: *screen.Window, prompt_text: []const u8, mode: QueryMode) !QueryWindow {
        const prompt = try allocator.dupe(u8, prompt_text);
        errdefer allocator.free(prompt);
        const h = promptHeight(prompt_text, parent.w, byteWidth);
        return .{
            .parent = parent,
            .prompt = prompt,
            .mode = mode,
            .org_w = parent.w,
            .org_h = @intCast(@min(h, std.math.maxInt(u16))),
            .target = parent.target orelse parent.main,
        };
    }

    pub fn deinit(self: *QueryWindow, allocator: Allocator) void {
        allocator.free(self.prompt);
        self.* = undefined;
    }

    pub fn promptLen(self: *const QueryWindow) usize {
        return self.prompt.len;
    }

    pub fn heightForWidth(self: *const QueryWindow, width: usize) usize {
        return promptHeight(self.prompt, width, byteWidth);
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