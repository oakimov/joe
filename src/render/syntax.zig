//! Zig-native JSF subset DFA → per-byte `attr_buf` fill (Phase 6).
//!
//! Loads enough of JOE `.jsf` to run syntaxes like `syntax/conf.jsf`:
//! color classes (`=Name [+Parent…]`), states (`:name Color [context]`),
//! transitions (`*` / `"chars"` → target with `noeat` / `recolor=-N`).
//!
//! Not a full port of hybrid `src/syntax.zig` (no keywords/buffer/call/mark/
//! delimiter stack/`%`/`&`/classes yet). Fills per-byte attrs for `lgen`
//! (codepoint atr expanded across UTF-8 bytes). Not wired into live `joe`.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;
const terminal = @import("terminal");

pub const Attribute = terminal.Attribute;
pub const Color = terminal.Color;

pub const HighlightState = struct {
    /// Index into `Syntax.states`, or `-1` when highlighting is disabled.
    state: i32 = 0,

    pub const initial: HighlightState = .{ .state = 0 };
    pub const disabled: HighlightState = .{ .state = -1 };

    pub fn isDisabled(self: HighlightState) bool {
        return self.state < 0;
    }
};

const Context = enum { none, comment, string };

const Command = struct {
    new_state: usize,
    noeat: bool = false,
    recolor: i32 = 0, // JOE: negative ⇒ recolor past -N chars with target color
};

const Transition = struct {
    /// Inclusive ranges of codepoints this transition matches.
    ranges: []Interval,
    cmd: Command,
};

const Interval = struct {
    first: u21,
    last: u21,

    fn contains(self: Interval, c: u21) bool {
        return c >= self.first and c <= self.last;
    }
};

const State = struct {
    name: []const u8,
    color: Attribute,
    context: Context = .none,
    /// Default (`*`) transition; required for a well-formed state.
    dflt: ?Command = null,
    transitions: []Transition,
};

pub const Syntax = struct {
    allocator: Allocator,
    name: []const u8,
    states: []State,
    /// Owned backing storage for names / ranges / transition arrays.
    arena_ptr: *std.heap.ArenaAllocator,

    pub fn deinit(self: *Syntax) void {
        const allocator = self.allocator;
        const arena_ptr = self.arena_ptr;
        arena_ptr.deinit();
        allocator.destroy(arena_ptr);
        self.* = undefined;
    }

    pub fn initialState(self: *const Syntax) HighlightState {
        _ = self;
        return .initial;
    }

    /// Parse one line (bytes up to but not including `\n`/`\r`).
    /// Writes per-byte attributes into `attrs` (length must be `>= line.len`).
    /// Returns the highlight state for the following line.
    pub fn parseLine(
        self: *const Syntax,
        line: []const u8,
        start: HighlightState,
        attrs: []Attribute,
    ) HighlightState {
        std.debug.assert(attrs.len >= line.len);
        @memset(attrs[0..line.len], .none);

        if (start.isDisabled() or self.states.len == 0) {
            return .disabled;
        }
        if (start.state >= self.states.len) return .disabled;

        var st: usize = @intCast(start.state);
        var i: usize = 0;
        // Codepoint index for recolor (JOE recolors by character, not byte).
        // Map codepoint index → starting byte for recolor expansion.
        var cp_byte_start: [4096]usize = undefined;
        var cp_count: usize = 0;

        while (i < line.len) {
            const b = line[i];
            if (b == '\n' or b == '\r') break;

            const seq_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
            const take = if (i + seq_len <= line.len) seq_len else 1;
            const cp: u21 = if (take > 1)
                (std.unicode.utf8Decode(line[i..][0..take]) catch @as(u21, b))
            else if (b < 0x80)
                @as(u21, b)
            else
                @as(u21, b); // invalid lead — treat as byte

            if (cp_count < cp_byte_start.len) {
                cp_byte_start[cp_count] = i;
                cp_count += 1;
            }

            // Guard against infinite noeat cycles.
            var iters: usize = 0;
            const max_iters = self.states.len * 8 + 8;
            var ate = false;
            while (!ate) : (iters += 1) {
                if (iters > max_iters) return .disabled;

                const state = &self.states[st];
                // Color current character bytes with this state's color.
                paintBytes(attrs, i, take, state.color);

                const cmd = findCmd(state, cp) orelse {
                    // No default — stay, eat (degenerate).
                    ate = true;
                    continue;
                };

                if (cmd.recolor < 0) {
                    const n: usize = @intCast(-cmd.recolor);
                    const target_color = self.states[cmd.new_state].color;
                    recolorPast(attrs, line, &cp_byte_start, cp_count, n, target_color);
                }

                st = cmd.new_state;
                if (cmd.noeat) {
                    // Recolor=-1 is implied by JOE for noeat; already handled if present.
                    continue;
                }
                ate = true;
            }

            i += take;
                    }

        // Consuming a newline transitions via `"\n"` if the line slice included it;
        // our API excludes newline, so apply an implicit `\n` feed for state only.
        st = feedNewline(self, st);

        return .{ .state = @intCast(st) };
    }

    /// Advance highlight state across many lines (attrs discarded).
    pub fn stateAfterLines(self: *const Syntax, lines: []const []const u8, start: HighlightState) HighlightState {
        var st = start;
        var tmp: [8192]Attribute = undefined;
        for (lines) |line| {
            if (line.len > tmp.len) {
                // Truncate paint for state walk; still feed parsed prefix + newline.
                st = self.parseLine(line[0..tmp.len], st, tmp[0..tmp.len]);
            } else {
                st = self.parseLine(line, st, tmp[0..line.len]);
            }
            if (st.isDisabled()) return st;
        }
        return st;
    }
};

fn paintBytes(attrs: []Attribute, start: usize, len: usize, color: Attribute) void {
    var j = start;
    const end = @min(start + len, attrs.len);
    while (j < end) : (j += 1) {
        attrs[j] = color;
    }
}

fn recolorPast(
    attrs: []Attribute,
    line: []const u8,
    cp_byte_start: []const usize,
    cp_count: usize,
    n: usize,
    color: Attribute,
) void {
    if (n == 0 or cp_count == 0) return;
    const from_cp = if (n >= cp_count) 0 else cp_count - n;
    const byte_from = cp_byte_start[from_cp];
    // End = current codepoint end ≈ next start or line len handled by caller paint;
    // recolor through the last started codepoint's bytes (up to current fill).
    const byte_to = if (cp_count < cp_byte_start.len)
        // current cp start + its length is already painted; include from byte_from
        // through end of last cp — use line len capped by attrs already written.
        blk: {
            const last_start = cp_byte_start[cp_count - 1];
            const b = line[last_start];
            const seq = std.unicode.utf8ByteSequenceLength(b) catch 1;
            break :blk @min(last_start + seq, attrs.len);
        }
    else
        attrs.len;
    var j = byte_from;
    while (j < byte_to) : (j += 1) {
        attrs[j] = color;
    }
}

fn findCmd(state: *const State, cp: u21) ?Command {
    for (state.transitions) |tr| {
        for (tr.ranges) |r| {
            if (r.contains(cp)) return tr.cmd;
        }
    }
    return state.dflt;
}

fn feedNewline(self: *const Syntax, st0: usize) usize {
    if (st0 >= self.states.len) return st0;
    // Simulate eating `\n` with possible noeat loops (state only; no attrs).
    var st = st0;
    var iters: usize = 0;
    const max_iters = self.states.len * 8 + 8;
    var ate = false;
    while (!ate) : (iters += 1) {
        if (iters > max_iters) return st0;
        const s = &self.states[st];
        const c = findCmd(s, '\n') orelse s.dflt orelse return st;
        st = c.new_state;
        if (c.noeat) continue;
        ate = true;
    }
    return st;
}

fn defaultClassColor(name: []const u8) Attribute {
    // Sensible fallbacks when no .jcf is loaded (tests / early Phase 6).
    if (std.mem.eql(u8, name, "Idle") or std.mem.eql(u8, name, "Text")) return .none;
    if (std.mem.eql(u8, name, "Comment")) return .{ .fg = .{ .indexed = 2 }, .dim = true }; // green+dim-ish
    if (std.mem.eql(u8, name, "String") or std.mem.eql(u8, name, "Constant"))
        return .{ .fg = .{ .indexed = 3 } };
    if (std.mem.eql(u8, name, "Escape") or std.mem.eql(u8, name, "StringEscape"))
        return .{ .fg = .{ .indexed = 5 }, .bold = true };
    if (std.mem.eql(u8, name, "Character") or std.mem.eql(u8, name, "Backtick"))
        return .{ .fg = .{ .indexed = 6 } };
    if (std.mem.eql(u8, name, "Keyword")) return .{ .fg = .{ .indexed = 5 }, .bold = true };
    if (std.mem.eql(u8, name, "Operator")) return .{ .fg = .{ .indexed = 4 } };
    if (std.mem.eql(u8, name, "Type")) return .{ .fg = .{ .indexed = 4 }, .bold = true };
    return .{ .fg = .{ .indexed = 7 } };
}

fn resolveClass(
    classes: *std.StringHashMap(Attribute),
    parents: *std.StringHashMap([]const []const u8),
    name: []const u8,
    depth: usize,
) Attribute {
    if (classes.get(name)) |a| return a;
    if (depth > 32) return defaultClassColor(name);
    var acc = defaultClassColor(name);
    if (parents.get(name)) |plist| {
        // Apply parents left-to-right; later refs override.
        for (plist) |p| {
            acc = resolveClass(classes, parents, p, depth + 1);
        }
    }
    classes.put(name, acc) catch {};
    return acc;
}

fn skipWs(s: []const u8, from: usize) usize {
    var i = from;
    while (i < s.len and (s[i] == ' ' or s[i] == '\t')) : (i += 1) {}
    return i;
}

fn isIdentStart(c: u8) bool {
    return std.ascii.isAlphabetic(c) or c == '_';
}
fn isIdentCont(c: u8) bool {
    return isIdentStart(c) or std.ascii.isDigit(c);
}

fn parseIdent(s: []const u8, from: usize) ?struct { name: []const u8, next: usize } {
    var i = skipWs(s, from);
    if (i >= s.len or !isIdentStart(s[i])) return null;
    const start = i;
    i += 1;
    while (i < s.len and isIdentCont(s[i])) : (i += 1) {}
    return .{ .name = s[start..i], .next = i };
}

fn parseCharList(arena: Allocator, s: []const u8, from: usize) !struct { ranges: []Interval, next: usize } {
    var i = skipWs(s, from);
    if (i >= s.len or s[i] != '"') return error.BadCharList;
    i += 1;
    var list: std.ArrayList(Interval) = .empty;
    defer list.deinit(arena); // we'll toOwnedSlice into arena below carefully
    // Actually use arena for the ArrayList allocator
    var ranges_al: std.ArrayList(Interval) = .empty;

    while (i < s.len and s[i] != '"') {
        var c: u21 = undefined;
        if (s[i] == '\\') {
            i += 1;
            if (i >= s.len) return error.BadEscape;
            switch (s[i]) {
                'n' => c = '\n',
                't' => c = '\t',
                'r' => c = '\r',
                'b' => c = 8,
                'f' => c = 12,
                'a' => c = 7,
                '\\', '"', '\'' => c = s[i],
                'x', 'X' => {
                    i += 1;
                    if (i + 1 >= s.len) return error.BadEscape;
                    const hi = std.fmt.parseInt(u8, s[i .. i + 2], 16) catch return error.BadEscape;
                    c = hi;
                    i += 1; // loop +1 → total +2
                },
                '`' => c = '`',
                else => c = s[i],
            }
            i += 1;
        } else {
            c = s[i];
            i += 1;
        }

        // Range: a-z where next is '-' and another char (not closing quote)
        if (i + 1 < s.len and s[i] == '-' and s[i + 1] != '"') {
            i += 1;
            var c2: u21 = undefined;
            if (s[i] == '\\') {
                i += 1;
                if (i >= s.len) return error.BadEscape;
                c2 = switch (s[i]) {
                    'n' => '\n',
                    't' => '\t',
                    else => s[i],
                };
                i += 1;
            } else {
                c2 = s[i];
                i += 1;
            }
            try ranges_al.append(arena, .{ .first = @min(c, c2), .last = @max(c, c2) });
        } else {
            try ranges_al.append(arena, .{ .first = c, .last = c });
        }
    }
    if (i >= s.len or s[i] != '"') return error.BadCharList;
    i += 1;
    return .{ .ranges = try ranges_al.toOwnedSlice(arena), .next = i };
}

fn parseTransitionOptions(s: []const u8, from: usize, cmd: *Command) usize {
    var i = from;
    while (true) {
        i = skipWs(s, i);
        if (i >= s.len or s[i] == '#' or s[i] == '\n' or s[i] == '\r') break;
        if (std.mem.startsWith(u8, s[i..], "noeat")) {
            cmd.noeat = true;
            if (cmd.recolor == 0) cmd.recolor = -1; // JOE: noeat implies recolor=-1
            i += "noeat".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "recolor=")) {
            i += "recolor=".len;
            const start = i;
            if (i < s.len and (s[i] == '-' or s[i] == '+')) i += 1;
            while (i < s.len and std.ascii.isDigit(s[i])) : (i += 1) {}
            cmd.recolor = std.fmt.parseInt(i32, s[start..i], 10) catch 0;
            continue;
        }
        // Skip unknown option token.
        while (i < s.len and s[i] != ' ' and s[i] != '\t' and s[i] != '#' and s[i] != '\n' and s[i] != '\r') : (i += 1) {}
    }
    return i;
}

pub const LoadError = error{
    BadCharList,
    BadEscape,
    BadSyntax,
    MissingDefault,
    UnknownState,
    OutOfMemory,
};

/// Load a `.jsf` source (subset). `name` is a display label (copied).
pub fn load(allocator: Allocator, name: []const u8, source: []const u8) LoadError!Syntax {
    const arena_ptr = try allocator.create(std.heap.ArenaAllocator);
    errdefer allocator.destroy(arena_ptr);
    arena_ptr.* = std.heap.ArenaAllocator.init(allocator);
    errdefer arena_ptr.deinit();
    const arena = arena_ptr.allocator();

    var class_attr = std.StringHashMap(Attribute).init(allocator);
    defer class_attr.deinit();
    var class_parents = std.StringHashMap([]const []const u8).init(allocator);
    defer class_parents.deinit();

    // First pass: collect =Color and :State headers so forward refs work.
    var state_names: std.ArrayList([]const u8) = .empty;
    defer state_names.deinit(allocator);
    var state_color_names: std.ArrayList([]const u8) = .empty;
    defer state_color_names.deinit(allocator);
    var state_contexts: std.ArrayList(Context) = .empty;
    defer state_contexts.deinit(allocator);

    var line_start: usize = 0;
    while (line_start < source.len) {
        var line_end = line_start;
        while (line_end < source.len and source[line_end] != '\n') : (line_end += 1) {}
        const raw = source[line_start..line_end];
        line_start = if (line_end < source.len) line_end + 1 else line_end;

        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0 or line[0] == '#') continue;

        if (line[0] == '=') {
            var i: usize = 1;
            const id = parseIdent(line, i) orelse continue;
            i = id.next;
            var parents_al: std.ArrayList([]const u8) = .empty;
            while (true) {
                i = skipWs(line, i);
                if (i >= line.len or line[i] == '#') break;
                if (line[i] == '+') {
                    i += 1;
                    const p = parseIdent(line, i) orelse break;
                    try parents_al.append(arena, try arena.dupe(u8, p.name));
                    i = p.next;
                    continue;
                }
                break;
            }
            const ncopy = try arena.dupe(u8, id.name);
            if (parents_al.items.len > 0) {
                try class_parents.put(ncopy, try parents_al.toOwnedSlice(arena));
            } else {
                try class_attr.put(ncopy, defaultClassColor(id.name));
            }
            continue;
        }

        if (line[0] == ':') {
            var i: usize = 1;
            const sn = parseIdent(line, i) orelse return error.BadSyntax;
            i = sn.next;
            const cn = parseIdent(line, i) orelse return error.BadSyntax;
            i = cn.next;
            var ctx: Context = .none;
            i = skipWs(line, i);
            if (parseIdent(line, i)) |cx| {
                if (std.mem.eql(u8, cx.name, "comment")) ctx = .comment;
                if (std.mem.eql(u8, cx.name, "string")) ctx = .string;
            }
            try state_names.append(allocator, try arena.dupe(u8, sn.name));
            try state_color_names.append(allocator, try arena.dupe(u8, cn.name));
            try state_contexts.append(allocator, ctx);
            continue;
        }
    }

    // Resolve color classes with parents.
    var pending = std.ArrayList([]const u8).empty;
    defer pending.deinit(allocator);
    var it = class_parents.keyIterator();
    while (it.next()) |k| {
        try pending.append(allocator, k.*);
    }
    for (pending.items) |cname| {
        _ = resolveClass(&class_attr, &class_parents, cname, 0);
    }

    if (state_names.items.len == 0) return error.BadSyntax;

    var name_to_idx = std.StringHashMap(usize).init(allocator);
    defer name_to_idx.deinit();
    for (state_names.items, 0..) |sn, idx| {
        try name_to_idx.put(sn, idx);
    }

    var states = try arena.alloc(State, state_names.items.len);
    for (states, 0..) |*st, idx| {
        const cname = state_color_names.items[idx];
        const color = class_attr.get(cname) orelse defaultClassColor(cname);
        st.* = .{
            .name = state_names.items[idx],
            .color = color,
            .context = state_contexts.items[idx],
            .dflt = null,
            .transitions = &.{},
        };
    }

    // Second pass: transitions belong to the most recent :state.
    var cur_state: ?usize = null;
    // Per-state transition lists finalized at end of pass.
    var per_state_trans = try arena.alloc(std.ArrayList(Transition), states.len);
    for (per_state_trans) |*al| al.* = .empty;

    line_start = 0;
    while (line_start < source.len) {
        var line_end = line_start;
        while (line_end < source.len and source[line_end] != '\n') : (line_end += 1) {}
        const raw = source[line_start..line_end];
        line_start = if (line_end < source.len) line_end + 1 else line_end;

        const line = std.mem.trimEnd(u8, raw, "\r");
        // Keep leading tab/space significance lightly — trim left for commands.
        const trimmed = std.mem.trimStart(u8, line, " \t");
        if (trimmed.len == 0 or trimmed[0] == '#') continue;

        if (trimmed[0] == '=' ) continue;

        if (trimmed[0] == ':') {
            const sn = parseIdent(trimmed, 1) orelse return error.BadSyntax;
            cur_state = name_to_idx.get(sn.name) orelse return error.UnknownState;
            continue;
        }

        const st_idx = cur_state orelse return error.BadSyntax;
        var i: usize = 0;
        const tline = trimmed;

        // `*` default or `"..."` char list
        var ranges: []Interval = &.{};
        var is_default = false;
        i = skipWs(tline, i);
        if (i < tline.len and tline[i] == '*') {
            is_default = true;
            i += 1;
        } else if (i < tline.len and tline[i] == '"') {
            const cl = try parseCharList(arena, tline, i);
            ranges = cl.ranges;
            i = cl.next;
        } else {
            return error.BadSyntax;
        }

        const target = parseIdent(tline, i) orelse return error.BadSyntax;
        i = target.next;
        const target_idx = name_to_idx.get(target.name) orelse return error.UnknownState;

        var cmd: Command = .{ .new_state = target_idx };
        _ = parseTransitionOptions(tline, i, &cmd);

        if (is_default) {
            states[st_idx].dflt = cmd;
        } else {
            try per_state_trans[st_idx].append(arena, .{ .ranges = ranges, .cmd = cmd });
        }
    }

    for (states, 0..) |*st, idx| {
        st.transitions = try per_state_trans[idx].toOwnedSlice(arena);
        if (st.dflt == null) {
            // Allow missing default only if transitions exist; JOE requires `*`.
            // Provide self-loop eat default to avoid hard fail on partial files.
            st.dflt = .{ .new_state = idx };
        }
    }

    const name_copy = try arena.dupe(u8, name);
    return .{
        .allocator = allocator,
        .name = name_copy,
        .states = states,
        .arena_ptr = arena_ptr,
    };
}

test "load mini jsf and highlight comment/string" {
    const src =
        \\=Idle
        \\=Comment
        \\=String
        \\
        \\:idle Idle
        \\  *    idle
        \\  "#"    comment    recolor=-1
        \\  "\""    string    recolor=-1
        \\
        \\:comment Comment comment
        \\  *    comment
        \\  "\n"    idle
        \\
        \\:string String string
        \\  *    string
        \\  "\""    idle
    ;
    var syn = try load(testing.allocator, "mini", src);
    defer syn.deinit();

    var attrs: [64]Attribute = undefined;
    const line1 = "a# hi";
    var st = syn.parseLine(line1, .initial, attrs[0..line1.len]);
    try testing.expect(Color.eql(attrs[0].fg, .default) or Attribute.eql(attrs[0], .none));
    try testing.expect(Color.eql(attrs[1].fg, .{ .indexed = 2 }) or attrs[1].dim); // '#' comment
    try testing.expect(attrs[2].dim or Color.eql(attrs[2].fg, .{ .indexed = 2 }));

    const line2 = "\"xy\"";
    st = syn.parseLine(line2, .initial, attrs[0..line2.len]);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 3 })); // opening quote
    try testing.expect(Color.eql(attrs[1].fg, .{ .indexed = 3 }));
    try testing.expect(Color.eql(attrs[3].fg, .{ .indexed = 3 }));
    // After closing quote, state returns to idle for next line.
    try testing.expectEqual(@as(i32, 0), st.state);
}

test "load syntax/conf.jsf and color a conf line" {
    const src =
\\# JOE syntax highlight file for typical UNIX configuration files
\\
\\=Idle
\\=Comment
\\=String    +Constant
\\=Escape
\\=StringEscape  +Escape
\\=Backtick  +Character +Constant +String
\\
\\:idle Idle
\\  *    idle
\\  "#"    comment    recolor=-1
\\  "\""    string    recolor=-1
\\  "'"    single    recolor=-1
\\  "\`"    backtick  recolor=-1
\\  "\\"    escape    recolor=-1
\\
\\:escape Escape
\\  *    idle
\\
\\:comment Comment comment
\\  *    comment
\\  "\n"    idle
\\
\\
\\:string String string
\\  *    string
\\  "\""    idle
\\  "\`"    backtick_in_str  recolor=-1
\\  "\\"    string_escape  recolor=-1
\\
\\:string_escape StringEscape string
\\  *    string
\\  "\n"    string    recolor=-2
\\
\\:backtick_in_str Backtick
\\  *    backtick_in_str
\\  "\`"    string
\\  "\\"    bt_escape_2  recolor=-1
\\
\\:bt_escape_2 Escape
\\  *    backtick_in_str
\\  "\n"    backtick_in_str  recolor=-2
\\
\\
\\:single String string
\\  *    single
\\  "'"    idle
\\  "\\"    single_escape  recolor=-1
\\
\\:single_escape StringEscape string
\\  *    single
\\  "\n"    single    recolor=-2
\\
\\
\\:backtick Backtick
\\  *    backtick
\\  "\`"    idle
\\  "\""    string_in_bt  recolor=-1
\\  "'"    single_in_bt  recolor=-1
\\  "\\"    bt_escape  recolor=-1
\\
\\:bt_escape Escape
\\  *    backtick
\\  "\n"    backtick  recolor=-2
\\
\\
\\:string_in_bt String string
\\  *    string_in_bt
\\  "\""    backtick
\\  "\\"    string_escape_b  recolor=-1
\\
\\:string_escape_b StringEscape string
\\  *    string_in_bt
\\  "\n"    string_in_bt  recolor=-2
\\
\\
\\:single_in_bt String string
\\  *    single_in_bt
\\  "'"    backtick
\\  "\\"    single_escape_b  recolor=-1
\\
\\:single_escape_b StringEscape string
\\  *    single_in_bt
\\  "\n"    single_in_bt  recolor=-2
\\
    ;
    var syn = try load(testing.allocator, "conf", src);
    defer syn.deinit();

    const line = "# comment";
    var attrs: [32]Attribute = undefined;
    _ = syn.parseLine(line, .initial, attrs[0..line.len]);
    // Entire line should be comment-colored (recolor=-1 on '#').
    try testing.expect(attrs[0].dim or Color.eql(attrs[0].fg, .{ .indexed = 2 }));
    try testing.expect(attrs[2].dim or Color.eql(attrs[2].fg, .{ .indexed = 2 }));
}

test "stateAfterLines carries comment across lines" {
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
    var syn = try load(testing.allocator, "c", src);
    defer syn.deinit();
    // Single-line comments reset on newline feed inside parseLine.
    const lines = [_][]const u8{ "#a", "b" };
    const st = syn.stateAfterLines(&lines, .initial);
    try testing.expectEqual(@as(i32, 0), st.state);
}
