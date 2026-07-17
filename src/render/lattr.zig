//! Zig-native per-line highlight-state cache (JOE `lattr` shape).
//!
//! Stores `HighlightState` at the **start** of each line. Invalid ranges are
//! tracked with `first_invalid` + `invalid_window` the way JOE's `lattr_db`
//! does, so inserts/deletes only reparse what they must. Used by window paint
//! to avoid O(n²) `syntaxStateAtLine` walks. Not wired into live `joe`.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;
const syntax = @import("syntax.zig");

pub const HighlightState = syntax.HighlightState;
pub const Syntax = syntax.Syntax;
pub const Attribute = syntax.Attribute;

/// Callback that returns borrowed text for buffer line `line` (no newline).
pub const LineFn = *const fn (ctx: *anyopaque, line: u64) ?[]const u8;

pub const LineAttrCache = struct {
    allocator: Allocator,
    /// `states[i]` = highlight state at the start of line `i`.
    states: std.ArrayList(HighlightState) = .empty,
    /// First line whose start-state may be stale (JOE `first_invalid`).
    first_invalid: usize = 1,
    /// Known-invalid span after `first_invalid`; `-1` ⇒ all cached states valid.
    invalid_window: isize = -1,

    pub fn init(allocator: Allocator) !LineAttrCache {
        var self: LineAttrCache = .{ .allocator = allocator };
        try self.states.append(allocator, HighlightState.initial);
        return self;
    }

    pub fn deinit(self: *LineAttrCache) void {
        self.states.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn len(self: *const LineAttrCache) usize {
        return self.states.items.len;
    }

    /// Expand so `states[0..=min_line]` exist. New slots are invalid.
    pub fn ensureSize(self: *LineAttrCache, min_line: usize) !void {
        const need = min_line + 1;
        if (self.len() >= need) return;
        const old = self.len();
        try self.states.resize(self.allocator, need);
        var i = old;
        while (i < need) : (i += 1) self.states.items[i] = HighlightState.initial;
        self.states.items[0] = HighlightState.initial;

        if (self.invalid_window == -1) {
            self.first_invalid = old;
            if (self.first_invalid == 0) self.first_invalid = 1;
            self.invalid_window = @intCast(need - self.first_invalid);
        } else {
            self.invalid_window = @intCast(need - self.first_invalid);
        }
        if (self.first_invalid >= need) {
            self.first_invalid = need;
            self.invalid_window = -1;
        }
    }

    /// Invalidate from `line` through end (JOE-style expand of invalid window).
    pub fn invalidateFrom(self: *LineAttrCache, line: u64) !void {
        const ln: usize = if (line == 0) 1 else @intCast(line);
        try self.ensureSize(ln);
        if (self.invalid_window == -1) {
            self.first_invalid = ln;
            self.invalid_window = @intCast(self.len() - ln);
        } else if (ln < self.first_invalid) {
            self.invalid_window += @intCast(self.first_invalid - ln);
            self.first_invalid = ln;
        } else {
            const win: usize = @intCast(@max(self.invalid_window, 0));
            if (ln >= self.first_invalid + win) {
                self.invalid_window = @intCast(self.len() - self.first_invalid);
            }
        }
        if (self.first_invalid >= self.len()) {
            self.first_invalid = self.len();
            self.invalid_window = -1;
        }
    }

    /// Insert `count` blank cached lines at `first_affected`.
    pub fn insertLines(self: *LineAttrCache, first_affected: u64, count: u64) !void {
        if (count == 0) return;
        const at: usize = @intCast(first_affected);
        const n: usize = @intCast(count);
        try self.ensureSize(at);
        const insert_at = @min(at, self.len());
        try self.states.resize(self.allocator, self.len() + n);
        var i = self.len();
        while (i > insert_at + n) {
            i -= 1;
            self.states.items[i] = self.states.items[i - n];
        }
        var j: usize = 0;
        while (j < n) : (j += 1) self.states.items[insert_at + j] = HighlightState.initial;
        self.states.items[0] = HighlightState.initial;

        if (self.invalid_window == -1) {
            self.first_invalid = if (insert_at == 0) 1 else insert_at;
            self.invalid_window = if (insert_at == 0 and n == 1) 0 else @intCast(if (insert_at == 0) n - 1 else n);
        } else if (insert_at >= self.first_invalid + @as(usize, @intCast(@max(self.invalid_window, 0)))) {
            self.invalid_window = @intCast(insert_at + n - self.first_invalid);
        } else if (insert_at >= self.first_invalid) {
            self.invalid_window += @intCast(n);
        } else {
            self.invalid_window += @intCast(self.first_invalid - insert_at + n);
            self.first_invalid = if (insert_at == 0) 1 else insert_at;
        }
        if (self.first_invalid >= self.len()) {
            self.first_invalid = self.len();
            self.invalid_window = -1;
        }
    }

    /// Delete `count` cached lines starting at `first_affected`.
    pub fn deleteLines(self: *LineAttrCache, first_affected: u64, count: u64) !void {
        if (count == 0) return;
        const line: usize = @intCast(first_affected);
        const n: usize = @intCast(count);
        if (line >= self.len()) return;
        const take = @min(n, self.len() - line);
        const remain = self.len() - line - take;
        var i: usize = 0;
        while (i < remain) : (i += 1) {
            self.states.items[line + i] = self.states.items[line + take + i];
        }
        try self.states.resize(self.allocator, self.len() - take);
        if (self.len() == 0) {
            try self.states.append(self.allocator, HighlightState.initial);
            self.first_invalid = 1;
            self.invalid_window = -1;
            return;
        }
        self.states.items[0] = HighlightState.initial;

        const win: usize = if (self.invalid_window < 0) 0 else @intCast(self.invalid_window);
        if (self.invalid_window == -1) {
            self.first_invalid = if (line == 0) 1 else line;
            self.invalid_window = 0;
        } else if (line < self.first_invalid) {
            if (line + take <= self.first_invalid) {
                self.invalid_window = @intCast(self.first_invalid + win - line - take);
                self.first_invalid = if (line == 0) 1 else line;
            } else if (line + take <= self.first_invalid + win) {
                self.invalid_window = @intCast(self.first_invalid + win - line - take);
                self.first_invalid = if (line == 0) 1 else line;
            } else {
                self.invalid_window = 0;
                self.first_invalid = if (line == 0) 1 else line;
            }
        } else if (line < self.first_invalid + win) {
            if (line + take < self.first_invalid + win) {
                self.invalid_window -= @intCast(take);
            } else {
                self.invalid_window = @intCast(line - self.first_invalid);
            }
        } else {
            self.invalid_window = @intCast(line - self.first_invalid);
        }
        if (self.first_invalid >= self.len()) {
            self.first_invalid = self.len();
            self.invalid_window = -1;
        }
    }

    /// Return highlight state at the start of `line`, computing/caching as needed.
    pub fn get(
        self: *LineAttrCache,
        syn: *const Syntax,
        ctx: *anyopaque,
        lineFn: LineFn,
        line: u64,
        line_count: u64,
    ) !HighlightState {
        if (line_count == 0 or line > line_count) return HighlightState.initial;
        const want: usize = @intCast(line);
        try self.ensureSize(want);
        if (want < self.first_invalid) return self.states.items[want];

        var ln = self.first_invalid;
        if (ln == 0) ln = 1;
        var state = self.states.items[ln - 1];
        var attrs: [8192]Attribute = undefined;

        const win_end: usize = if (self.invalid_window < 0)
            self.len()
        else
            @min(self.len(), self.first_invalid + @as(usize, @intCast(self.invalid_window)));

        // Always cover the requested line.
        const target_end = @max(want + 1, win_end);

        while (ln < target_end) {
            const src = lineFn(ctx, @intCast(ln - 1)) orelse "";
            state = parseOne(syn, src, state, &attrs);
            try self.ensureSize(ln);
            self.states.items[ln] = state;
            ln += 1;
        }

        // JOE: keep going until a recomputed state matches (rest still valid).
        while (ln < self.len()) {
            const src = lineFn(ctx, @intCast(ln - 1)) orelse "";
            state = parseOne(syn, src, state, &attrs);
            if (self.states.items[ln].eql(state)) {
                self.first_invalid = self.len();
                self.invalid_window = -1;
                return self.states.items[want];
            }
            self.states.items[ln] = state;
            ln += 1;
        }

        self.first_invalid = self.len();
        self.invalid_window = -1;
        return self.states.items[want];
    }
};

fn parseOne(syn: *const Syntax, line: []const u8, start: HighlightState, attrs: *[8192]Attribute) HighlightState {
    if (line.len > attrs.len) {
        return syn.parseLine(line[0..attrs.len], start, attrs[0..attrs.len]);
    }
    return syn.parseLine(line, start, attrs[0..line.len]);
}

test "LineAttrCache get walks and caches start states" {
    const src =
        \\=Idle
        \\=Comment
        \\:idle Idle
        \\  *    idle
        \\  "#"    comment    recolor=-1
        \\:comment Comment comment
        \\  *    comment
        \\  "\n"    idle
    ;
    var syn = try syntax.load(testing.allocator, "c", src);
    defer syn.deinit();

    const Lines = struct {
        lines: []const []const u8,
        fn get(ctx: *anyopaque, line: u64) ?[]const u8 {
            const self: *const @This() = @ptrCast(@alignCast(ctx));
            if (line >= self.lines.len) return null;
            return self.lines[@intCast(line)];
        }
    };
    var body = Lines{ .lines = &[_][]const u8{ "#a", "b", "c" } };
    var cache = try LineAttrCache.init(testing.allocator);
    defer cache.deinit();

    const st0 = try cache.get(&syn, &body, Lines.get, 0, 3);
    try testing.expectEqual(@as(i32, 0), st0.state);

    const st1 = try cache.get(&syn, &body, Lines.get, 1, 3);
    try testing.expectEqual(@as(i32, 0), st1.state);

    const st1b = try cache.get(&syn, &body, Lines.get, 1, 3);
    try testing.expect(st1.eql(st1b));
    try testing.expect(cache.invalid_window == -1);
}

test "LineAttrCache invalidateFrom forces reparse" {
    const src =
        \\=Idle
        \\=Comment
        \\:idle Idle
        \\  *    idle
        \\  "#"    comment    recolor=-1
        \\:comment Comment comment
        \\  *    comment
        \\  "\n"    comment
    ;
    var syn = try syntax.load(testing.allocator, "c", src);
    defer syn.deinit();

    const Lines = struct {
        lines: []const []const u8,
        fn get(ctx: *anyopaque, line: u64) ?[]const u8 {
            const self: *const @This() = @ptrCast(@alignCast(ctx));
            if (line >= self.lines.len) return null;
            return self.lines[@intCast(line)];
        }
    };
    var body = Lines{ .lines = &[_][]const u8{ "x", "#y", "z" } };
    var cache = try LineAttrCache.init(testing.allocator);
    defer cache.deinit();

    const before = try cache.get(&syn, &body, Lines.get, 2, 3);
    try testing.expectEqual(@as(i32, 1), before.state);

    body.lines = &[_][]const u8{ "x", "y", "z" };
    try cache.invalidateFrom(1);
    const after = try cache.get(&syn, &body, Lines.get, 2, 3);
    try testing.expectEqual(@as(i32, 0), after.state);
}

test "LineAttrCache insertLines shifts and invalidates" {
    var cache = try LineAttrCache.init(testing.allocator);
    defer cache.deinit();
    try cache.ensureSize(3);
    cache.states.items[1] = .{ .state = 7 };
    cache.states.items[2] = .{ .state = 8 };
    cache.states.items[3] = .{ .state = 9 };
    cache.first_invalid = 4;
    cache.invalid_window = -1;

    try cache.insertLines(2, 1);
    try testing.expectEqual(@as(usize, 5), cache.len());
    try testing.expectEqual(@as(i32, 7), cache.states.items[1].state);
    try testing.expectEqual(@as(i32, 9), cache.states.items[4].state);
    try testing.expect(cache.first_invalid <= 2);
}
