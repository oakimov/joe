//! Zig-native gap buffer + Point (Phase 6 redesign).
//!
//! Parallel to hybrid `src/gapbuffer` (C-ABI B/P/H), but allocator-owned and
//! unit-testable from `render-test` without vfile/joe_malloc. Enough for
//! `lgen` to walk live buffer text the way JOE's `lgen_core` walks `P`.
//! Not wired into live `joe`.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

/// Contiguous gap buffer. Logical text is `bytes[0..gap_start] ++ bytes[gap_end..]`.
pub const GapBuffer = struct {
    allocator: Allocator,
    bytes: []u8,
    gap_start: usize,
    gap_end: usize,

    pub fn init(allocator: Allocator) !GapBuffer {
        return initCapacity(allocator, 64);
    }

    pub fn initCapacity(allocator: Allocator, capacity: usize) !GapBuffer {
        const cap = @max(capacity, 1);
        const bytes = try allocator.alloc(u8, cap);
        return .{
            .allocator = allocator,
            .bytes = bytes,
            .gap_start = 0,
            .gap_end = cap,
        };
    }

    pub fn deinit(self: *GapBuffer) void {
        self.allocator.free(self.bytes);
        self.* = undefined;
    }

    pub fn len(self: *const GapBuffer) usize {
        return self.bytes.len - (self.gap_end - self.gap_start);
    }

    pub fn gapSize(self: *const GapBuffer) usize {
        return self.gap_end - self.gap_start;
    }

    /// JOE-shaped line count: `n_newlines + 1` (empty buffer ⇒ 1 empty line).
    pub fn lineCount(self: *const GapBuffer) u64 {
        var lines: u64 = 1;
        var i: usize = 0;
        const n = self.len();
        while (i < n) : (i += 1) {
            if (self.byteAt(i).? == '\n') lines += 1;
        }
        return lines;
    }

    pub fn byteAt(self: *const GapBuffer, pos: usize) ?u8 {
        if (pos >= self.len()) return null;
        if (pos < self.gap_start) return self.bytes[pos];
        return self.bytes[self.gap_end + (pos - self.gap_start)];
    }

    pub fn moveGap(self: *GapBuffer, pos: usize) void {
        const n = self.len();
        const p = @min(pos, n);
        if (p == self.gap_start) return;
        if (p < self.gap_start) {
            const count = self.gap_start - p;
            const dest = self.gap_end - count;
            @memcpy(self.bytes[dest..][0..count], self.bytes[p..self.gap_start]);
            self.gap_end = dest;
            self.gap_start = p;
        } else {
            const count = p - self.gap_start;
            @memcpy(self.bytes[self.gap_start..][0..count], self.bytes[self.gap_end..][0..count]);
            self.gap_start = p;
            self.gap_end += count;
        }
    }

    fn ensureGap(self: *GapBuffer, need: usize) !void {
        if (self.gapSize() >= need) return;
        const logical = self.len();
        var new_cap = self.bytes.len;
        while (new_cap - logical < need) {
            new_cap = @max(new_cap * 2, logical + need);
        }
        const new_bytes = try self.allocator.alloc(u8, new_cap);
        @memcpy(new_bytes[0..self.gap_start], self.bytes[0..self.gap_start]);
        const suffix_len = self.bytes.len - self.gap_end;
        const new_gap_end = new_cap - suffix_len;
        @memcpy(new_bytes[new_gap_end..][0..suffix_len], self.bytes[self.gap_end..]);
        self.allocator.free(self.bytes);
        self.bytes = new_bytes;
        self.gap_end = new_gap_end;
    }

    pub fn insert(self: *GapBuffer, pos: usize, text: []const u8) !void {
        if (text.len == 0) return;
        self.moveGap(pos);
        try self.ensureGap(text.len);
        @memcpy(self.bytes[self.gap_start..][0..text.len], text);
        self.gap_start += text.len;
    }

    pub fn append(self: *GapBuffer, text: []const u8) !void {
        try self.insert(self.len(), text);
    }

    pub fn delete(self: *GapBuffer, pos: usize, count: usize) void {
        const n = self.len();
        if (pos >= n or count == 0) return;
        const take = @min(count, n - pos);
        self.moveGap(pos);
        self.gap_end += take;
    }

    /// Copy bytes of 0-based `line` into `out` (no trailing newline). Returns length.
    pub fn copyLine(self: *const GapBuffer, line: u64, out: []u8) usize {
        var p = Point.bof(@constCast(self));
        p.gotoLine(line);
        var n: usize = 0;
        while (p.peekb()) |b| {
            if (b == '\n' or b == '\r') break;
            if (n >= out.len) break;
            out[n] = b;
            n += 1;
            p.byte += 1;
        }
        return n;
    }

        /// Copy logical contents into a new slice (caller frees).
    pub fn snapshot(self: *const GapBuffer, allocator: Allocator) ![]u8 {
        const out = try allocator.alloc(u8, self.len());
        var i: usize = 0;
        while (i < out.len) : (i += 1) {
            out[i] = self.byteAt(i).?;
        }
        return out;
    }
};

/// Cursor into a `GapBuffer` — JOE `P`-shaped for native lgen walks.
pub const Point = struct {
    buf: *GapBuffer,
    byte: usize = 0,
    line: u64 = 0,

    pub fn bof(buf: *GapBuffer) Point {
        return .{ .buf = buf, .byte = 0, .line = 0 };
    }

    pub fn isEof(self: *const Point) bool {
        return self.byte >= self.buf.len();
    }

    pub fn isEol(self: *const Point) bool {
        if (self.isEof()) return true;
        return self.buf.byteAt(self.byte).? == '\n';
    }

    pub fn isBol(self: *const Point) bool {
        if (self.byte == 0) return true;
        return self.buf.byteAt(self.byte - 1).? == '\n';
    }

    /// Absolute byte → point. Line is recomputed from BOF (fine for small buffers).
    pub fn gotoByte(self: *Point, pos: usize) void {
        const p = @min(pos, self.buf.len());
        self.byte = 0;
        self.line = 0;
        while (self.byte < p) {
            const b = self.buf.byteAt(self.byte).?;
            self.byte += 1;
            if (b == '\n') self.line += 1;
        }
    }

    pub fn gotoBol(self: *Point) void {
        while (self.byte > 0 and self.buf.byteAt(self.byte - 1).? != '\n') {
            self.byte -= 1;
        }
    }

    pub fn gotoEol(self: *Point) void {
        const n = self.buf.len();
        while (self.byte < n and self.buf.byteAt(self.byte).? != '\n') {
            self.byte += 1;
        }
    }

    /// Move to the start of 0-based `line`. Clamps to last line.
    pub fn gotoLine(self: *Point, line: u64) void {
        self.byte = 0;
        self.line = 0;
        const target = @min(line, self.buf.lineCount() -| 1);
        while (self.line < target) {
            if (!self.nextl()) break;
        }
    }

    /// Advance to the start of the next line. Returns false at EOF.
    pub fn nextl(self: *Point) bool {
        if (self.isEof()) return false;
        self.gotoEol();
        if (self.isEof()) return false;
        // Consume '\n'.
        self.byte += 1;
        self.line += 1;
        return true;
    }

    /// Peek next raw byte without advancing. `null` at EOF.
    pub fn peekb(self: *const Point) ?u8 {
        return self.buf.byteAt(self.byte);
    }

    /// Alias for `nextUnit` — shared `lgen` iterator surface.
    pub fn next(self: *Point) ?Unit {
        return self.nextUnit();
    }

    /// Consume one UTF-8 codepoint (or invalid-byte sentinel).
    /// Returns `null` at EOF. Does not cross `\n`/`\r` — returns `.eol` instead.
    pub fn nextUnit(self: *Point) ?Unit {
        if (self.isEof()) return null;
        const b = self.buf.byteAt(self.byte).?;
        if (b == '\n' or b == '\r') return .eol;

        const seq_len = std.unicode.utf8ByteSequenceLength(b) catch {
            self.byte += 1;
            return .{ .invalid = {} };
        };
        if (self.byte + seq_len > self.buf.len()) {
            self.byte += 1;
            return .{ .invalid = {} };
        }
        var tmp: [4]u8 = undefined;
        var i: usize = 0;
        while (i < seq_len) : (i += 1) {
            tmp[i] = self.buf.byteAt(self.byte + i).?;
        }
        const cp = std.unicode.utf8Decode(tmp[0..seq_len]) catch {
            self.byte += 1;
            return .{ .invalid = {} };
        };
        self.byte += seq_len;
        return .{ .cp = cp };
    }
};

pub const Unit = union(enum) {
    cp: u21,
    invalid,
    eol,
};

test "GapBuffer insert/delete across the gap" {
    var buf = try GapBuffer.init(testing.allocator);
    defer buf.deinit();
    try buf.append("hello");
    try testing.expectEqual(@as(usize, 5), buf.len());
    try buf.insert(5, " world");
    const snap1 = try buf.snapshot(testing.allocator);
    defer testing.allocator.free(snap1);
    try testing.expectEqualStrings("hello world", snap1);

    buf.delete(5, 6);
    const snap2 = try buf.snapshot(testing.allocator);
    defer testing.allocator.free(snap2);
    try testing.expectEqualStrings("hello", snap2);

    try buf.insert(2, "XY");
    const snap3 = try buf.snapshot(testing.allocator);
    defer testing.allocator.free(snap3);
    try testing.expectEqualStrings("heXYllo", snap3);
}

test "GapBuffer lineCount and Point.gotoLine/nextl" {
    var buf = try GapBuffer.init(testing.allocator);
    defer buf.deinit();
    try testing.expectEqual(@as(u64, 1), buf.lineCount());

    try buf.append("alpha\nbravo\ncharlie");
    try testing.expectEqual(@as(u64, 3), buf.lineCount());

    var p = Point.bof(&buf);
    p.gotoLine(1);
    try testing.expectEqual(@as(u64, 1), p.line);
    try testing.expectEqual(@as(u8, 'b'), p.peekb().?);

    try testing.expect(p.nextl());
    try testing.expectEqual(@as(u64, 2), p.line);
    try testing.expectEqual(@as(u8, 'c'), p.peekb().?);
    try testing.expect(!p.nextl());
}

test "Point.nextUnit decodes UTF-8 and stops at EOL" {
    var buf = try GapBuffer.init(testing.allocator);
    defer buf.deinit();
    try buf.append("a\u{00e9}\nZ");

    var p = Point.bof(&buf);
    try testing.expectEqual(@as(u21, 'a'), p.nextUnit().?.cp);
    try testing.expectEqual(@as(u21, 0xe9), p.nextUnit().?.cp);
    try testing.expect(p.nextUnit().? == .eol);
}
