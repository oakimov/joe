//! Zig-native JSF subset DFA → per-byte `attr_buf` fill (Phase 6).
//!
//! Loads enough of JOE `.jsf` for `conf.jsf` plus C-like keyword/call/mark paths:
//! color classes (`=Name [+Parent…]`), states (`:name Color [context]`),
//! transitions (`*` / `"chars"` / `&` / `%` → target with `noeat` / `recolor=-N`),
//! `buffer` + `strings`/`istrings` keyword tables (including `"&"` delim),
//! `save_c`/`save_s`/`push_c`/`push_s`/`pop_c`/`pop_s` delimiter match buffer+stack,
//! local `.subr`/`.end` and external `call=file.subr()` / `call=file()` / `call=.name()`,
//! `.ifdef` params, `return`, `reset`, `mark`/`markend`/`recolormark`, `hold`, and `\i`/`\c`.
//!
//! External calls resolve through in-memory `SyntaxLibrary` (`loadWithLibrary`).
//! `.ifdef` / `.else` / `.endif` honor `call=…(params)` (including `-param`).
//! Pair with `render/lattr.zig` for per-line state cache. Fills per-byte attrs for `lgen`.
//! Not wired into live `joe`.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;
const terminal = @import("terminal");

pub const Attribute = terminal.Attribute;
pub const Color = terminal.Color;

const max_call_depth = 8;
const max_delim_depth = 8;
const max_buf_chars = 23; // JOE buffers leading 23 characters
const max_saved_chars = 24; // save_c uses 2; save_s copies keyword buffer
const max_codepoint_starts = 4096;

const DelimBuf = struct {
    len: u8 = 0,
    data: [max_saved_chars]u8 = [_]u8{0} ** max_saved_chars,

    fn slice(self: *const DelimBuf) []const u8 {
        return self.data[0..self.len];
    }

    fn setBytes(self: *DelimBuf, bytes: []const u8) void {
        const n: u8 = @intCast(@min(bytes.len, max_saved_chars));
        if (n > 0) @memcpy(self.data[0..n], bytes[0..n]);
        self.len = n;
    }

    fn setSaveC(self: *DelimBuf, cp: u21) void {
        // JOE: saved_s = [pair_close(c), c, 0]
        const open: u8 = if (cp <= 0x7f) @intCast(cp) else '?';
        const close: u8 = switch (open) {
            '<' => '>',
            '(' => ')',
            '[' => ']',
            '{' => '}',
            '`' => '\'',
            else => open,
        };
        self.data[0] = close;
        self.data[1] = open;
        self.len = 2;
    }

    fn eql(self: *const DelimBuf, bytes: []const u8) bool {
        return std.mem.eql(u8, self.slice(), bytes);
    }

    fn eqlIgnoreCase(self: *const DelimBuf, bytes: []const u8) bool {
        return std.ascii.eqlIgnoreCase(self.slice(), bytes);
    }
};

const ParamDelta = struct {
    name: []const u8,
    remove: bool = false,
};

const CallSpec = struct {
    /// Syntax file name without `.jsf` (local calls use the current file name).
    file: []const u8,
    /// Subroutine name, or null to call the whole file (`call=file()`).
    subr: ?[]const u8 = null,
    /// Parameter adds/removes from `call=…(a -b c)` relative to the caller.
    deltas: []const ParamDelta = &.{},
};

/// In-memory `.jsf` sources available for external `call=file…`.
pub const SyntaxLibrary = struct {
    pub const File = struct {
        name: []const u8,
        source: []const u8,
    };
    files: []const File = &.{},

    fn find(self: SyntaxLibrary, name: []const u8) ?[]const u8 {
        for (self.files) |f| {
            if (std.mem.eql(u8, f.name, name)) return f.source;
        }
        return null;
    }
};

pub const HighlightState = struct {
    /// Index into the active syntax piece's `states`, or `-1` when disabled.
    state: i32 = 0,
    /// 0 = root syntax; 1.. = `root.subrs[syn_id-1]`.
    syn_id: u8 = 0,
    stack_depth: u8 = 0,
    frames: [max_call_depth]CallFrame = .{CallFrame{}} ** max_call_depth,
    /// Current delimiter match buffer (JOE `saved_s`).
    saved: DelimBuf = .{},
    /// Delimiter stack depth (JOE `delim_stack`).
    delim_depth: u8 = 0,
    delim_stack: [max_delim_depth]DelimBuf = .{DelimBuf{}} ** max_delim_depth,

    pub const initial: HighlightState = .{};
    pub const disabled: HighlightState = .{ .state = -1 };

    pub fn isDisabled(self: HighlightState) bool {
        return self.state < 0;
    }

    /// JOE `eq_state` shape: compare DFA/call/delim identity (not buffer contents beyond `saved`).
    pub fn eql(self: HighlightState, other: HighlightState) bool {
        if (self.state != other.state) return false;
        if (self.syn_id != other.syn_id) return false;
        if (self.stack_depth != other.stack_depth) return false;
        if (self.delim_depth != other.delim_depth) return false;
        if (!self.saved.eql(other.saved.slice())) return false;
        var i: u8 = 0;
        while (i < self.stack_depth) : (i += 1) {
            if (self.frames[i].ret_state != other.frames[i].ret_state) return false;
            if (self.frames[i].ret_syn != other.frames[i].ret_syn) return false;
        }
        i = 0;
        while (i < self.delim_depth) : (i += 1) {
            if (!self.delim_stack[i].eql(other.delim_stack[i].slice())) return false;
        }
        return true;
    }
};

const CallFrame = struct {
    ret_state: u16 = 0,
    ret_syn: u8 = 0,
};

const Context = enum { none, comment, string };

const Keyword = struct {
    word: []const u8,
    cmd: Command,
};

const Command = struct {
    new_state: usize = 0,
    noeat: bool = false,
    recolor: i32 = 0,
    buffer: bool = false,
    hold: bool = false, // stop_buffering
    rtn: bool = false,
    reset: bool = false,
    start_mark: bool = false, // mark
    stop_mark: bool = false, // markend
    recolor_mark: bool = false, // recolormark
    save_c: bool = false,
    save_s: bool = false,
    push_c: bool = false,
    push_s: bool = false,
    pop: bool = false, // pop_c or pop_s (identical)
    /// Subroutine to invoke (local or external; owned by root `Syntax.subrs`).
    call: ?*const Syntax = null,
    /// Set during load for `call=`; resolved to `call` after pieces load.
    call_spec: ?CallSpec = null,
    keywords: []const Keyword = &.{},
    /// `strings`/`istrings` entry `"&"` — match buffer against delimiter `saved`.
    strings_delim: ?*Command = null,
    icase: bool = false,
};

const Transition = struct {
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
    dflt: ?Command = null,
    /// `&` — opposite/matching delimiter (`saved[0]` from `save_c`).
    delim: ?Command = null,
    /// `%` — same delimiter (`saved[1]` from `save_c`).
    same_delim: ?Command = null,
    transitions: []Transition,
};

const SubrSlot = struct {
    name: []const u8,
    syn: *Syntax,
};

pub const Syntax = struct {
    allocator: Allocator,
    name: []const u8,
    /// Subroutine name when this piece was loaded via `.subr`; empty for root.
    subr: []const u8 = "",
    /// Active `.ifdef` parameter set for this loaded instance (sorted).
    params: []const []const u8 = &.{},
    states: []State,
    /// Local subroutines loaded from the same source (root only).
    subrs: []SubrSlot = &.{},
    /// Owned backing storage for names / ranges / transition arrays / child Syntax.
    arena_ptr: *std.heap.ArenaAllocator,
    /// True when this Syntax owns `arena_ptr` (root). Subr pieces borrow root arena.
    owns_arena: bool = true,

    pub fn deinit(self: *Syntax) void {
        if (!self.owns_arena) {
            self.* = undefined;
            return;
        }
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

    fn piece(self: *const Syntax, syn_id: u8) *const Syntax {
        if (syn_id == 0) return self;
        const idx = syn_id - 1;
        std.debug.assert(idx < self.subrs.len);
        return self.subrs[idx].syn;
    }

    fn synIdOf(self: *const Syntax, target: *const Syntax) ?u8 {
        if (target == self) return 0;
        for (self.subrs, 0..) |slot, i| {
            if (slot.syn == target) return @intCast(i + 1);
        }
        return null;
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

        var hs = start;
        var active = self.piece(hs.syn_id);
        if (hs.state < 0 or hs.state >= active.states.len) return .disabled;

        var buf: [max_buf_chars + 1]u8 = undefined;
        var buf_len: usize = 0;
        var buffering = false;
        // Codepoints eaten after `hold` (JOE `ofst`) — keyword recolor shifts by this.
        var ofst: usize = 0;
        // JOE mark offsets (codepoints back from current); line-local only.
        var mark1: usize = 0;
        var mark2: usize = 0;
        var mark_en = false;

        var i: usize = 0;
        var cp_byte_start: [max_codepoint_starts]usize = undefined;
        var cp_count: usize = 0;

        while (i < line.len) {
            const b = line[i];
            if (b == '\n' or b == '\r') break;

            const seq_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
            const take = if (i + seq_len <= line.len) seq_len else 1;
            const cp: u21 = if (take > 1)
                (std.unicode.utf8Decode(line[i..][0..take]) catch @as(u21, b))
            else
                @as(u21, b);

            if (cp_count < cp_byte_start.len) {
                cp_byte_start[cp_count] = i;
                cp_count += 1;
            }

            var iters: usize = 0;
            const max_iters = active.states.len * 8 + 8;
            var ate = false;
            while (!ate) : (iters += 1) {
                if (iters > max_iters) return .disabled;

                active = self.piece(hs.syn_id);
                if (hs.state < 0 or hs.state >= active.states.len) return .disabled;
                const st_idx: usize = @intCast(hs.state);
                const state = &active.states[st_idx];
                paintBytes(attrs, i, take, state.color);

                var cmd = findCmd(state, cp, &hs.saved) orelse Command{ .new_state = st_idx };

                // Keyword / strings / strings-"&" lookup against current buffer (before adding `cp`).
                var recolor_keyword = false;
                if (matchStringsOrDelim(&cmd, buf[0..buf_len], &hs.saved)) {
                    recolor_keyword = true;
                    // Matched string always implies noeat (JOE).
                    cmd.noeat = true;
                    if (cmd.recolor == 0) cmd.recolor = -1;
                }

                // Call / return / reset / plain goto.
                if (cmd.call) |callee| {
                    const ret_syn = hs.syn_id;
                    const ret_state: u16 = @intCast(cmd.new_state);
                    if (hs.stack_depth >= max_call_depth) return .disabled;
                    hs.frames[hs.stack_depth] = .{ .ret_state = ret_state, .ret_syn = ret_syn };
                    hs.stack_depth += 1;
                    const sid = self.synIdOf(callee) orelse return .disabled;
                    hs.syn_id = sid;
                    hs.state = 0;
                    active = callee;
                } else if (cmd.rtn) {
                    if (hs.stack_depth > 0) {
                        hs.stack_depth -= 1;
                        const fr = hs.frames[hs.stack_depth];
                        hs.syn_id = fr.ret_syn;
                        hs.state = fr.ret_state;
                        active = self.piece(hs.syn_id);
                    } else {
                        hs.state = @intCast(cmd.new_state);
                        active = self.piece(hs.syn_id);
                    }
                } else if (cmd.reset) {
                    // JOE reset: return to root idle; call stack cleared; delimiter kept.
                    hs.syn_id = 0;
                    hs.stack_depth = 0;
                    hs.state = 0;
                    active = self;
                } else {
                    if (cmd.new_state >= active.states.len) return .disabled;
                    hs.state = @intCast(cmd.new_state);
                }

                if (hs.state < 0 or hs.state >= active.states.len) return .disabled;
                const new_color = active.states[@intCast(hs.state)].color;

                if (recolor_keyword and buf_len > 0 and cp_count > 0) {
                    // JOE: attr[x-ofst] for x in [-(buf_idx+1), -1) — skip held trailing cps.
                    const cur = cp_count - 1;
                    const end_excl = cur -| ofst; // first codepoint after keyword
                    const from_cp = end_excl -| buf_len;
                    if (from_cp < end_excl) {
                        const byte_from = cp_byte_start[from_cp];
                        const byte_to = if (end_excl < cp_count) cp_byte_start[end_excl] else i;
                        var j = byte_from;
                        while (j < byte_to and j < attrs.len) : (j += 1) {
                            attrs[j] = new_color;
                        }
                    }
                }

                if (cmd.recolor < 0) {
                    const n: usize = @intCast(-cmd.recolor);
                    recolorPast(attrs, line, cp_byte_start[0..cp_count], cp_count, n, new_color);
                }

                if (cmd.recolor_mark and mark1 > mark2 and cp_count > 0) {
                    // JOE: for x=-mark1; x<-mark2; ++x → codepoints [cp_count-mark1, cp_count-mark2).
                    const from_cp = if (mark1 >= cp_count) 0 else cp_count - mark1;
                    const to_cp = if (mark2 >= cp_count) cp_count else cp_count - mark2;
                    if (from_cp < to_cp) {
                        const byte_from = cp_byte_start[from_cp];
                        const byte_to = if (to_cp < cp_count) cp_byte_start[to_cp] else i + take;
                        var j = byte_from;
                        while (j < byte_to and j < attrs.len) : (j += 1) {
                            attrs[j] = new_color;
                        }
                    }
                }

                // Delimiter push/save/pop (JOE order: push, save_s, save_c, pop).
                applyDelimOps(&hs, cmd, buf[0..buf_len], cp);

                if (cmd.buffer) {
                    buffering = true;
                    buf_len = 0;
                    ofst = 0;
                }
                if (cmd.hold) {
                    buffering = false;
                }

                if (cmd.start_mark) {
                    mark1 = 1;
                    mark2 = 1;
                    mark_en = true;
                }
                if (cmd.stop_mark) {
                    mark_en = false;
                    mark2 = 1;
                }

                if (cmd.noeat) {
                    continue;
                }
                ate = true;
            }

            // Save character into buffer after eat (JOE: codepoint as... we store UTF-8 bytes
            // for ASCII keywords; multi-byte keywords are rare in .jsf string tables).
            if (buffering) {
                if (take == 1 and buf_len < max_buf_chars) {
                    buf[buf_len] = @intCast(cp);
                    buf_len += 1;
                } else if (take > 1) {
                    // Non-ASCII: stop buffering; .jsf keyword tables are ASCII.
                    buffering = false;
                }
            } else {
                ofst += 1;
            }

            // Update mark pointers after eating this codepoint.
            mark1 += 1;
            if (!mark_en) mark2 += 1;

            i += take;
        }

        // Implicit `\n` feed: updates state and may recolor/markend (JOE parses through newline).
        // Does not paint a new attr slot — line attrs exclude the newline byte.
        {
            const cp: u21 = '\n';
            var iters: usize = 0;
            var ate = false;
            while (!ate) : (iters += 1) {
                if (iters > 64) return .disabled;
                active = self.piece(hs.syn_id);
                if (hs.state < 0 or hs.state >= active.states.len) return .disabled;
                const st_idx: usize = @intCast(hs.state);
                const state = &active.states[st_idx];
                var cmd = findCmd(state, cp, &hs.saved) orelse Command{ .new_state = st_idx };

                var recolor_keyword = false;
                if (matchStringsOrDelim(&cmd, buf[0..buf_len], &hs.saved)) {
                    recolor_keyword = true;
                    cmd.noeat = true;
                    if (cmd.recolor == 0) cmd.recolor = -1;
                }

                if (cmd.call) |callee| {
                    if (hs.stack_depth >= max_call_depth) return .disabled;
                    hs.frames[hs.stack_depth] = .{ .ret_state = @intCast(cmd.new_state), .ret_syn = hs.syn_id };
                    hs.stack_depth += 1;
                    hs.syn_id = self.synIdOf(callee) orelse return .disabled;
                    hs.state = 0;
                    active = callee;
                } else if (cmd.rtn) {
                    if (hs.stack_depth > 0) {
                        hs.stack_depth -= 1;
                        const fr = hs.frames[hs.stack_depth];
                        hs.syn_id = fr.ret_syn;
                        hs.state = fr.ret_state;
                        active = self.piece(hs.syn_id);
                    } else {
                        hs.state = @intCast(cmd.new_state);
                    }
                } else if (cmd.reset) {
                    // Keep delimiter buffer/stack across reset (JOE).
                    hs.syn_id = 0;
                    hs.stack_depth = 0;
                    hs.state = 0;
                    active = self;
                } else {
                    if (cmd.new_state >= active.states.len) return .disabled;
                    hs.state = @intCast(cmd.new_state);
                }

                if (hs.state < 0 or hs.state >= active.states.len) return .disabled;
                const new_color = active.states[@intCast(hs.state)].color;

                if (recolor_keyword and buf_len > 0 and cp_count > 0) {
                    const end_excl = cp_count -| ofst;
                    const from_cp = end_excl -| buf_len;
                    if (from_cp < end_excl) {
                        const byte_from = cp_byte_start[from_cp];
                        const byte_to = if (end_excl < cp_count) cp_byte_start[end_excl] else line.len;
                        var j = byte_from;
                        while (j < byte_to and j < attrs.len) : (j += 1) attrs[j] = new_color;
                    }
                }

                if (cmd.recolor < 0 and cp_count > 0) {
                    const n: usize = @intCast(-cmd.recolor);
                    // recolorPast includes the last codepoint; for newline feed, last is final line cp.
                    recolorPast(attrs, line, cp_byte_start[0..cp_count], cp_count, n, new_color);
                }

                if (cmd.recolor_mark and mark1 > mark2 and cp_count > 0) {
                    // No current char slot: treat mark2 relative to one-past-last.
                    // After all chars eaten, mark1/mark2 already advanced. Recolor [cp_count-mark1, cp_count-mark2).
                    const from_cp = if (mark1 >= cp_count) 0 else cp_count - mark1;
                    const to_cp = if (mark2 >= cp_count) cp_count else cp_count - mark2;
                    if (from_cp < to_cp) {
                        const byte_from = cp_byte_start[from_cp];
                        const byte_to = if (to_cp < cp_count) cp_byte_start[to_cp] else line.len;
                        var j = byte_from;
                        while (j < byte_to and j < attrs.len) : (j += 1) attrs[j] = new_color;
                    }
                }

                applyDelimOps(&hs, cmd, buf[0..buf_len], cp);

                if (cmd.buffer) {
                    buffering = true;
                    buf_len = 0;
                    ofst = 0;
                }
                if (cmd.hold) {
                    buffering = false;
                }

                if (cmd.start_mark) {
                    mark1 = 1;
                    mark2 = 1;
                    mark_en = true;
                }
                if (cmd.stop_mark) {
                    mark_en = false;
                    mark2 = 1;
                }

                if (cmd.noeat) continue;
                ate = true;
            }
        }

        return hs;
    }

    /// Advance highlight state across many lines (attrs discarded).
    pub fn stateAfterLines(self: *const Syntax, lines: []const []const u8, start: HighlightState) HighlightState {
        var st = start;
        var tmp: [8192]Attribute = undefined;
        for (lines) |line| {
            if (line.len > tmp.len) {
                st = self.parseLine(line[0..tmp.len], st, tmp[0..tmp.len]);
            } else {
                st = self.parseLine(line, st, tmp[0..line.len]);
            }
            if (st.isDisabled()) return st;
        }
        return st;
    }
};

fn lookupKeyword(kws: []const Keyword, word: []const u8, icase: bool) ?Keyword {
    for (kws) |kw| {
        if (icase) {
            if (std.ascii.eqlIgnoreCase(kw.word, word)) return kw;
        } else if (std.mem.eql(u8, kw.word, word)) {
            return kw;
        }
    }
    return null;
}


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
    const byte_to = blk: {
        const last_start = cp_byte_start[cp_count - 1];
        const b = line[last_start];
        const seq = std.unicode.utf8ByteSequenceLength(b) catch 1;
        break :blk @min(last_start + seq, attrs.len);
    };
    var j = byte_from;
    while (j < byte_to) : (j += 1) {
        attrs[j] = color;
    }
}

fn findCmd(state: *const State, cp: u21, saved: *const DelimBuf) ?Command {
    // JOE: & matches saved_s[0] when saved is a 2-slot save_c buffer.
    if (state.delim) |d| {
        if (saved.len == 2 and cp == saved.data[0]) return d;
    }
    // JOE: % matches saved_s[1] (the original open char).
    if (state.same_delim) |d| {
        if (saved.len == 2 and saved.data[0] != 0 and cp == saved.data[1]) return d;
    }
    for (state.transitions) |tr| {
        for (tr.ranges) |r| {
            if (r.contains(cp)) return tr.cmd;
        }
    }
    return state.dflt;
}

fn matchStringsOrDelim(cmd: *Command, buf: []const u8, saved: *const DelimBuf) bool {
    // strings `"&"` — buffer equals delimiter match buffer.
    if (cmd.strings_delim) |dptr| {
        const hit = saved.len > 0 and if (cmd.icase) saved.eqlIgnoreCase(buf) else saved.eql(buf);
        if (hit) {
            cmd.* = dptr.*;
            return true;
        }
    }
    if (cmd.keywords.len > 0) {
        if (lookupKeyword(cmd.keywords, buf, cmd.icase)) |kw| {
            cmd.* = kw.cmd;
            return true;
        }
    }
    return false;
}

fn applyDelimOps(hs: *HighlightState, cmd: Command, buf: []const u8, cp: u21) void {
    // Push current saved BEFORE save (JOE order).
    if (cmd.push_c or cmd.push_s) {
        if (hs.delim_depth < max_delim_depth) {
            hs.delim_stack[hs.delim_depth] = hs.saved;
            hs.delim_depth += 1;
        }
    }
    if (cmd.save_s or cmd.push_s) {
        hs.saved.setBytes(buf);
    }
    if (cmd.save_c or cmd.push_c) {
        hs.saved.setSaveC(cp);
    }
    if (cmd.pop) {
        if (hs.delim_depth > 0) {
            hs.delim_depth -= 1;
            hs.saved = hs.delim_stack[hs.delim_depth];
        }
    }
}

fn defaultClassColor(name: []const u8) Attribute {
    if (std.mem.eql(u8, name, "Idle") or std.mem.eql(u8, name, "Ident")) return .none;
    if (std.mem.eql(u8, name, "Comment")) return .{ .fg = .{ .indexed = 2 }, .dim = true };
    if (std.mem.eql(u8, name, "TODO")) return .{ .fg = .{ .indexed = 3 }, .bold = true };
    if (std.mem.eql(u8, name, "String") or std.mem.eql(u8, name, "Constant") or std.mem.eql(u8, name, "Character"))
        return .{ .fg = .{ .indexed = 3 } };
    if (std.mem.eql(u8, name, "Escape") or std.mem.eql(u8, name, "StringEscape") or std.mem.eql(u8, name, "CharacterEscape"))
        return .{ .fg = .{ .indexed = 5 } };
    if (std.mem.eql(u8, name, "Backtick")) return .{ .fg = .{ .indexed = 5 } };
    if (std.mem.eql(u8, name, "Number")) return .{ .fg = .{ .indexed = 5 } };
    if (std.mem.eql(u8, name, "Keyword") or std.mem.eql(u8, name, "CppKeyword") or std.mem.eql(u8, name, "Statement") or
        std.mem.eql(u8, name, "Loop") or std.mem.eql(u8, name, "Conditional") or std.mem.eql(u8, name, "Label"))
        return .{ .fg = .{ .indexed = 6 }, .bold = true };
    if (std.mem.eql(u8, name, "Type") or std.mem.eql(u8, name, "StorageClass") or std.mem.eql(u8, name, "Structure"))
        return .{ .fg = .{ .indexed = 4 }, .bold = true };
    if (std.mem.eql(u8, name, "Preproc") or std.mem.eql(u8, name, "Precond") or std.mem.eql(u8, name, "Define") or
        std.mem.eql(u8, name, "IncLocal") or std.mem.eql(u8, name, "IncSystem"))
        return .{ .fg = .{ .indexed = 5 }, .bold = true };
    if (std.mem.eql(u8, name, "Bad")) return .{ .fg = .{ .indexed = 1 }, .bold = true };
    if (std.mem.eql(u8, name, "Brace") or std.mem.eql(u8, name, "Control") or std.mem.eql(u8, name, "Operator"))
        return .{ .fg = .{ .indexed = 4 } };
    if (std.mem.eql(u8, name, "IfZero")) return .{ .fg = .{ .indexed = 2 }, .dim = true };
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

fn appendInterval(al: *std.ArrayList(Interval), arena: Allocator, first: u21, last: u21) !void {
    try al.append(arena, .{ .first = @min(first, last), .last = @max(first, last) });
}

fn appendAsciiClass(al: *std.ArrayList(Interval), arena: Allocator, class: u8) !void {
    switch (class) {
        'i' => { // identifier start: letters + _
            try appendInterval(al, arena, 'A', 'Z');
            try appendInterval(al, arena, 'a', 'z');
            try appendInterval(al, arena, '_', '_');
        },
        'c' => { // identifier continue: alnum + _
            try appendInterval(al, arena, 'A', 'Z');
            try appendInterval(al, arena, 'a', 'z');
            try appendInterval(al, arena, '0', '9');
            try appendInterval(al, arena, '_', '_');
        },
        'd' => try appendInterval(al, arena, '0', '9'),
        'w' => { // word ≈ alnum + _
            try appendInterval(al, arena, 'A', 'Z');
            try appendInterval(al, arena, 'a', 'z');
            try appendInterval(al, arena, '0', '9');
            try appendInterval(al, arena, '_', '_');
        },
        's' => {
            try appendInterval(al, arena, ' ', ' ');
            try appendInterval(al, arena, '\t', '\t');
            try appendInterval(al, arena, '\n', '\n');
            try appendInterval(al, arena, '\r', '\r');
            try appendInterval(al, arena, 12, 12); // formfeed
        },
        else => try appendInterval(al, arena, class, class),
    }
}

fn parseCharList(arena: Allocator, s: []const u8, from: usize) !struct { ranges: []Interval, next: usize } {
    var i = skipWs(s, from);
    if (i >= s.len or s[i] != '"') return error.BadCharList;
    i += 1;
    var ranges_al: std.ArrayList(Interval) = .empty;

    while (i < s.len and s[i] != '"') {
        if (s[i] == '\\') {
            i += 1;
            if (i >= s.len) return error.BadEscape;
            const esc = s[i];
            i += 1;
            switch (esc) {
                'n' => try appendInterval(&ranges_al, arena, '\n', '\n'),
                't' => try appendInterval(&ranges_al, arena, '\t', '\t'),
                'r' => try appendInterval(&ranges_al, arena, '\r', '\r'),
                'b' => try appendInterval(&ranges_al, arena, 8, 8),
                'f' => try appendInterval(&ranges_al, arena, 12, 12),
                'a' => try appendInterval(&ranges_al, arena, 7, 7),
                '\\', '"', '\'' => try appendInterval(&ranges_al, arena, esc, esc),
                '`' => try appendInterval(&ranges_al, arena, '`', '`'),
                'x', 'X' => {
                    if (i + 1 >= s.len) return error.BadEscape;
                    const hi = std.fmt.parseInt(u8, s[i .. i + 2], 16) catch return error.BadEscape;
                    try appendInterval(&ranges_al, arena, hi, hi);
                    i += 2;
                },
                'i', 'c', 'd', 'w', 's' => try appendAsciiClass(&ranges_al, arena, esc),
                // Complements / others: treat as literal for now.
                else => try appendInterval(&ranges_al, arena, esc, esc),
            }
            continue;
        }

        const c: u21 = s[i];
        i += 1;
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
            try appendInterval(&ranges_al, arena, c, c2);
        } else {
            try appendInterval(&ranges_al, arena, c, c);
        }
    }
    if (i >= s.len or s[i] != '"') return error.BadCharList;
    i += 1;
    return .{ .ranges = try ranges_al.toOwnedSlice(arena), .next = i };
}

fn parseQuotedString(s: []const u8, from: usize) !struct { str: []const u8, next: usize } {
    var i = skipWs(s, from);
    if (i >= s.len or s[i] != '"') return error.BadSyntax;
    i += 1;
    const start = i;
    while (i < s.len and s[i] != '"') {
        if (s[i] == '\\') {
            i += 1;
            if (i >= s.len) return error.BadEscape;
        }
        i += 1;
    }
    if (i >= s.len) return error.BadSyntax;
    const str = s[start..i];
    i += 1;
    return .{ .str = str, .next = i };
}

fn parseCallParamDeltas(arena: Allocator, s: []const u8, from: usize) LoadError!struct {
    deltas: []const ParamDelta,
    next: usize,
} {
    var i = skipWs(s, from);
    if (i >= s.len or s[i] != '(') return .{ .deltas = &.{}, .next = i };
    i += 1;
    var deltas: std.ArrayList(ParamDelta) = .empty;
    while (true) {
        i = skipWs(s, i);
        if (i >= s.len) return error.BadSyntax;
        if (s[i] == ')') {
            i += 1;
            break;
        }
        var remove = false;
        if (s[i] == '-') {
            remove = true;
            i += 1;
        }
        const id = parseIdent(s, i) orelse return error.BadSyntax;
        i = id.next;
        try deltas.append(arena, .{
            .name = try arena.dupe(u8, id.name),
            .remove = remove,
        });
    }
    return .{ .deltas = try deltas.toOwnedSlice(arena), .next = i };
}

fn paramIndex(params: []const []const u8, name: []const u8) ?usize {
    for (params, 0..) |p, idx| {
        if (std.mem.eql(u8, p, name)) return idx;
    }
    return null;
}

fn applyParamDeltas(
    arena: Allocator,
    base: []const []const u8,
    deltas: []const ParamDelta,
) LoadError![]const []const u8 {
    var list: std.ArrayList([]const u8) = .empty;
    try list.appendSlice(arena, base);
    for (deltas) |d| {
        if (d.remove) {
            if (paramIndex(list.items, d.name)) |idx| {
                _ = list.orderedRemove(idx);
            }
        } else if (paramIndex(list.items, d.name) == null) {
            // Keep sorted like JOE.
            var insert_at: usize = 0;
            while (insert_at < list.items.len and std.mem.order(u8, list.items[insert_at], d.name) == .lt) : (insert_at += 1) {}
            try list.insert(arena, insert_at, try arena.dupe(u8, d.name));
        }
    }
    return try list.toOwnedSlice(arena);
}

const IfFrame = struct {
    ignore: bool,
    skip: bool,
    else_seen: bool = false,
};

fn ifdefIgnoring(stack: *const std.ArrayList(IfFrame)) bool {
    return stack.items.len > 0 and stack.items[stack.items.len - 1].ignore;
}

fn ifdefPush(stack: *std.ArrayList(IfFrame), allocator: Allocator, params: []const []const u8, name: []const u8) !void {
    const parent_ignore = ifdefIgnoring(stack);
    var frame = IfFrame{ .ignore = true, .skip = true };
    if (!parent_ignore) {
        frame.ignore = paramIndex(params, name) == null;
        frame.skip = false;
    }
    try stack.append(allocator, frame);
}

fn ifdefElse(stack: *std.ArrayList(IfFrame)) void {
    if (stack.items.len == 0) return;
    const frame = &stack.items[stack.items.len - 1];
    if (frame.else_seen) return;
    frame.else_seen = true;
    if (!frame.skip) frame.ignore = !frame.ignore;
}

fn ifdefPop(stack: *std.ArrayList(IfFrame)) void {
    if (stack.items.len > 0) _ = stack.pop();
}

fn parseTransitionOptions(
    arena: Allocator,
    s: []const u8,
    from: usize,
    cmd: *Command,
    current_file: []const u8,
) LoadError!usize {
    var i = from;
    while (true) {
        i = skipWs(s, i);
        if (i >= s.len or s[i] == '#' or s[i] == '\n' or s[i] == '\r') break;

        if (std.mem.startsWith(u8, s[i..], "noeat")) {
            cmd.noeat = true;
            if (cmd.recolor == 0) cmd.recolor = -1;
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
        if (std.mem.startsWith(u8, s[i..], "buffer")) {
            cmd.buffer = true;
            i += "buffer".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "hold")) {
            cmd.hold = true;
            i += "hold".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "return")) {
            cmd.rtn = true;
            i += "return".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "reset")) {
            cmd.reset = true;
            i += "reset".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "recolormark")) {
            cmd.recolor_mark = true;
            i += "recolormark".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "markend")) {
            cmd.stop_mark = true;
            i += "markend".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "mark")) {
            cmd.start_mark = true;
            i += "mark".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "istrings")) {
            cmd.icase = true;
            i += "istrings".len;
            // Caller consumes keyword list lines.
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "strings")) {
            i += "strings".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "call=")) {
            i += "call=".len;
            // call=.name() | call=file.subr() | call=file()
            if (i < s.len and s[i] == '.') {
                i += 1;
                const id = parseIdent(s, i) orelse return error.BadSyntax;
                i = id.next;
                const pd = try parseCallParamDeltas(arena, s, i);
                i = pd.next;
                cmd.call_spec = .{
                    .file = try arena.dupe(u8, current_file),
                    .subr = try arena.dupe(u8, id.name),
                    .deltas = pd.deltas,
                };
            } else {
                const file_id = parseIdent(s, i) orelse return error.BadSyntax;
                i = file_id.next;
                var subr: ?[]const u8 = null;
                if (i < s.len and s[i] == '.') {
                    i += 1;
                    const sid = parseIdent(s, i) orelse return error.BadSyntax;
                    i = sid.next;
                    subr = try arena.dupe(u8, sid.name);
                }
                const pd = try parseCallParamDeltas(arena, s, i);
                i = pd.next;
                cmd.call_spec = .{
                    .file = try arena.dupe(u8, file_id.name),
                    .subr = subr,
                    .deltas = pd.deltas,
                };
            }
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "save_c")) {
            cmd.save_c = true;
            i += "save_c".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "save_s")) {
            cmd.save_s = true;
            i += "save_s".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "push_c")) {
            cmd.push_c = true;
            i += "push_c".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "push_s")) {
            cmd.push_s = true;
            i += "push_s".len;
            continue;
        }
        if (std.mem.startsWith(u8, s[i..], "pop_c") or std.mem.startsWith(u8, s[i..], "pop_s")) {
            cmd.pop = true;
            i += 5; // pop_c / pop_s
            continue;
        }
        // Skip unknown option token.
        while (i < s.len and s[i] != ' ' and s[i] != '\t' and s[i] != '#' and s[i] != '\n' and s[i] != '\r') : (i += 1) {}
    }
    return i;
}

fn lineHasStringsOption(s: []const u8) bool {
    // Rough token scan.
    var i: usize = 0;
    while (i < s.len) {
        i = skipWs(s, i);
        if (i >= s.len or s[i] == '#') break;
        if (std.mem.startsWith(u8, s[i..], "strings") or std.mem.startsWith(u8, s[i..], "istrings"))
            return true;
        while (i < s.len and s[i] != ' ' and s[i] != '\t') : (i += 1) {}
    }
    return false;
}

pub const LoadError = error{
    BadCharList,
    BadEscape,
    BadSyntax,
    MissingDefault,
    UnknownState,
    UnknownSyntax,
    UnknownSubr,
    OutOfMemory,
};

const LoadCtx = struct {
    allocator: Allocator,
    arena: Allocator,
    arena_ptr: *std.heap.ArenaAllocator,
    /// Stable root identity (not swapped while loading externals).
    root_name: []const u8,
    root_source: []const u8,
    /// Current file being parsed by `loadPiece`.
    name: []const u8,
    source: []const u8,
    /// Active parameter set while `loadPiece` runs.
    params: []const []const u8 = &.{},
    class_attr: std.StringHashMap(Attribute),
    library: SyntaxLibrary,
    /// Cache key = `file\x00subr\x00params…` → loaded piece.
    syntax_cache: std.StringHashMap(*Syntax),
    /// All callable pieces registered on the root (local + external).
    all_slots: std.ArrayList(SubrSlot),
};

fn ensureNullState(
    state_names: *std.ArrayList([]const u8),
    state_color_names: *std.ArrayList([]const u8),
    state_contexts: *std.ArrayList(Context),
    name_to_idx: *std.StringHashMap(usize),
    allocator: Allocator,
    arena: Allocator,
) !void {
    if (name_to_idx.contains("NULL")) return;
    const n = try arena.dupe(u8, "NULL");
    try name_to_idx.put(n, state_names.items.len);
    try state_names.append(allocator, n);
    try state_color_names.append(allocator, try arena.dupe(u8, "Idle"));
    try state_contexts.append(allocator, .none);
}

fn loadPiece(ctx: *LoadCtx, want_subr: ?[]const u8) LoadError!*Syntax {
    const allocator = ctx.allocator;
    const arena = ctx.arena;

    var state_names: std.ArrayList([]const u8) = .empty;
    defer state_names.deinit(allocator);
    var state_color_names: std.ArrayList([]const u8) = .empty;
    defer state_color_names.deinit(allocator);
    var state_contexts: std.ArrayList(Context) = .empty;
    defer state_contexts.deinit(allocator);

    var inside_subr = false;
    var this_one = want_subr == null;
    var if_stack: std.ArrayList(IfFrame) = .empty;
    defer if_stack.deinit(allocator);

    // Pass 1: collect :state headers in the selected region.
    var line_start: usize = 0;
    while (line_start < ctx.source.len) {
        var line_end = line_start;
        while (line_end < ctx.source.len and ctx.source[line_end] != '\n') : (line_end += 1) {}
        const raw = ctx.source[line_start..line_end];
        line_start = if (line_end < ctx.source.len) line_end + 1 else line_end;

        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0 or line[0] == '#') continue;

        if (line[0] == '.') {
            const rest = std.mem.trim(u8, line[1..], " \t");
            if (std.mem.startsWith(u8, rest, "ifdef")) {
                const id = parseIdent(rest, "ifdef".len) orelse return error.BadSyntax;
                try ifdefPush(&if_stack, allocator, ctx.params, id.name);
                continue;
            }
            if (std.mem.startsWith(u8, rest, "else") and (rest.len == 4 or !isIdentCont(rest[4]))) {
                ifdefElse(&if_stack);
                continue;
            }
            if (std.mem.startsWith(u8, rest, "endif") and (rest.len == 5 or !isIdentCont(rest[5]))) {
                ifdefPop(&if_stack);
                continue;
            }
            if (ifdefIgnoring(&if_stack)) continue;
            if (std.mem.startsWith(u8, rest, "subr")) {
                const id = parseIdent(rest, "subr".len) orelse continue;
                inside_subr = true;
                this_one = if (want_subr) |w| std.mem.eql(u8, w, id.name) else false;
                continue;
            }
            if (std.mem.startsWith(u8, rest, "end") and (rest.len == 3 or !isIdentCont(rest[3]))) {
                inside_subr = false;
                this_one = want_subr == null;
                continue;
            }
            continue;
        }

        if (ifdefIgnoring(&if_stack)) continue;
        // Main file skips subr bodies; subr load skips outside.
        if (want_subr == null and inside_subr) continue;
        if (want_subr != null and !this_one) continue;

        if (line[0] == '=') continue; // colors already in ctx

        if (line[0] == ':') {
            var i: usize = 1;
            const sn = parseIdent(line, i) orelse return error.BadSyntax;
            i = sn.next;
            const cn = parseIdent(line, i) orelse return error.BadSyntax;
            i = cn.next;
            var cctx: Context = .none;
            i = skipWs(line, i);
            if (parseIdent(line, i)) |cx| {
                if (std.mem.eql(u8, cx.name, "comment")) cctx = .comment;
                if (std.mem.eql(u8, cx.name, "string")) cctx = .string;
            }
            try state_names.append(allocator, try arena.dupe(u8, sn.name));
            try state_color_names.append(allocator, try arena.dupe(u8, cn.name));
            try state_contexts.append(allocator, cctx);
            continue;
        }
    }

    var name_to_idx = std.StringHashMap(usize).init(allocator);
    defer name_to_idx.deinit();
    for (state_names.items, 0..) |sn, idx| {
        try name_to_idx.put(sn, idx);
    }
    try ensureNullState(&state_names, &state_color_names, &state_contexts, &name_to_idx, allocator, arena);

    if (state_names.items.len == 0) return error.BadSyntax;

    var states = try arena.alloc(State, state_names.items.len);
    for (states, 0..) |*st, idx| {
        const cname = state_color_names.items[idx];
        const color = ctx.class_attr.get(cname) orelse defaultClassColor(cname);
        st.* = .{
            .name = state_names.items[idx],
            .color = color,
            .context = state_contexts.items[idx],
            .dflt = null,
            .transitions = &.{},
        };
    }

    var per_state_trans = try arena.alloc(std.ArrayList(Transition), states.len);
    for (per_state_trans) |*al| al.* = .empty;

    // Pass 2: transitions.
    inside_subr = false;
    this_one = want_subr == null;
    if_stack.clearRetainingCapacity();
    var cur_state: ?usize = null;

    line_start = 0;
    while (line_start < ctx.source.len) {
        var line_end = line_start;
        while (line_end < ctx.source.len and ctx.source[line_end] != '\n') : (line_end += 1) {}
        const raw = ctx.source[line_start..line_end];
        line_start = if (line_end < ctx.source.len) line_end + 1 else line_end;

        const line = std.mem.trimEnd(u8, raw, "\r");
        const trimmed = std.mem.trimStart(u8, line, " \t");
        if (trimmed.len == 0 or trimmed[0] == '#') continue;

        if (trimmed[0] == '.') {
            const rest = std.mem.trim(u8, trimmed[1..], " \t");
            if (std.mem.startsWith(u8, rest, "ifdef")) {
                const id = parseIdent(rest, "ifdef".len) orelse return error.BadSyntax;
                try ifdefPush(&if_stack, allocator, ctx.params, id.name);
                continue;
            }
            if (std.mem.startsWith(u8, rest, "else") and (rest.len == 4 or !isIdentCont(rest[4]))) {
                ifdefElse(&if_stack);
                continue;
            }
            if (std.mem.startsWith(u8, rest, "endif") and (rest.len == 5 or !isIdentCont(rest[5]))) {
                ifdefPop(&if_stack);
                continue;
            }
            if (ifdefIgnoring(&if_stack)) continue;
            if (std.mem.startsWith(u8, rest, "subr")) {
                const id = parseIdent(rest, "subr".len) orelse continue;
                inside_subr = true;
                this_one = if (want_subr) |w| std.mem.eql(u8, w, id.name) else false;
                cur_state = null;
                continue;
            }
            if (std.mem.startsWith(u8, rest, "end") and (rest.len == 3 or !isIdentCont(rest[3]))) {
                inside_subr = false;
                this_one = want_subr == null;
                cur_state = null;
                continue;
            }
            continue;
        }

        if (ifdefIgnoring(&if_stack)) continue;
        if (want_subr == null and inside_subr) continue;
        if (want_subr != null and !this_one) continue;
        if (trimmed[0] == '=') continue;

        if (trimmed[0] == ':') {
            const sn = parseIdent(trimmed, 1) orelse return error.BadSyntax;
            cur_state = name_to_idx.get(sn.name) orelse return error.UnknownState;
            continue;
        }

        const st_idx = cur_state orelse return error.BadSyntax;
        var i: usize = 0;
        const tline = trimmed;

        var ranges: []Interval = &.{};
        var is_default = false;
        var is_delim = false;
        var is_same_delim = false;
        i = skipWs(tline, i);
        if (i < tline.len and tline[i] == '*') {
            is_default = true;
            i += 1;
        } else if (i < tline.len and tline[i] == '&') {
            // Bare `&` — opposite/matching delimiter (saved[0] from save_c).
            is_delim = true;
            i += 1;
        } else if (i < tline.len and tline[i] == '%') {
            // Bare `%` — same delimiter (saved[1] from save_c).
            is_same_delim = true;
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
        // Create missing forward states? JOE find_state creates them. We only have
        // collected :headers — unknown target is an error unless NULL (ensured).
        const target_idx = name_to_idx.get(target.name) orelse return error.UnknownState;

        var cmd: Command = .{ .new_state = target_idx };
        _ = try parseTransitionOptions(arena, tline, i, &cmd, ctx.name);

        // Consume strings list if present.
        if (lineHasStringsOption(tline)) {
            var kws: std.ArrayList(Keyword) = .empty;
            while (line_start < ctx.source.len) {
                var le = line_start;
                while (le < ctx.source.len and ctx.source[le] != '\n') : (le += 1) {}
                const raw2 = ctx.source[line_start..le];
                line_start = if (le < ctx.source.len) le + 1 else le;
                const tr2 = std.mem.trim(u8, raw2, " \t\r");
                if (tr2.len == 0 or tr2[0] == '#') continue;
                if (std.mem.eql(u8, tr2, "done")) break;
                // Keyword line: "word" target [options]; `"&"` matches delimiter buffer.
                const qs = parseQuotedString(tr2, 0) catch return error.BadSyntax;
                const tgt = parseIdent(tr2, qs.next) orelse return error.BadSyntax;
                const tidx = name_to_idx.get(tgt.name) orelse return error.UnknownState;
                var kcmd: Command = .{ .new_state = tidx };
                _ = try parseTransitionOptions(arena, tr2, tgt.next, &kcmd, ctx.name);
                // String match implies noeat.
                kcmd.noeat = true;
                if (kcmd.recolor == 0) kcmd.recolor = -1;
                if (std.mem.eql(u8, qs.str, "&")) {
                    const dptr = try arena.create(Command);
                    dptr.* = kcmd;
                    cmd.strings_delim = dptr;
                } else {
                    try kws.append(arena, .{
                        .word = try arena.dupe(u8, qs.str),
                        .cmd = kcmd,
                    });
                }
            }
            cmd.keywords = try kws.toOwnedSlice(arena);
        }

        if (is_default) {
            states[st_idx].dflt = cmd;
        } else if (is_delim) {
            states[st_idx].delim = cmd;
        } else if (is_same_delim) {
            states[st_idx].same_delim = cmd;
        } else {
            try per_state_trans[st_idx].append(arena, .{ .ranges = ranges, .cmd = cmd });
        }
    }

    for (states, 0..) |*st, idx| {
        st.transitions = try per_state_trans[idx].toOwnedSlice(arena);
        if (st.dflt == null) {
            st.dflt = .{ .new_state = idx };
        }
    }

    const syn_ptr = try arena.create(Syntax);
    syn_ptr.* = .{
        .allocator = allocator,
        .name = try arena.dupe(u8, ctx.name),
        .subr = if (want_subr) |w| try arena.dupe(u8, w) else "",
        .params = try dupeParams(arena, ctx.params),
        .states = states,
        .subrs = &.{},
        .arena_ptr = ctx.arena_ptr,
        .owns_arena = false,
    };
    return syn_ptr;
}

fn dupeParams(arena: Allocator, params: []const []const u8) ![]const []const u8 {
    if (params.len == 0) return &.{};
    const out = try arena.alloc([]const u8, params.len);
    for (params, 0..) |p, i| out[i] = try arena.dupe(u8, p);
    return out;
}

fn collectLocalSubrNames(allocator: Allocator, source: []const u8) ![][]const u8 {
    var names: std.ArrayList([]const u8) = .empty;
    errdefer {
        for (names.items) |n| allocator.free(n);
        names.deinit(allocator);
    }
    var line_start: usize = 0;
    while (line_start < source.len) {
        var line_end = line_start;
        while (line_end < source.len and source[line_end] != '\n') : (line_end += 1) {}
        const raw = source[line_start..line_end];
        line_start = if (line_end < source.len) line_end + 1 else line_end;
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0 or line[0] != '.') continue;
        const rest = std.mem.trim(u8, line[1..], " \t");
        if (!std.mem.startsWith(u8, rest, "subr")) continue;
        const id = parseIdent(rest, "subr".len) orelse continue;
        // Dedupe
        var found = false;
        for (names.items) |n| {
            if (std.mem.eql(u8, n, id.name)) {
                found = true;
                break;
            }
        }
        if (!found) try names.append(allocator, try allocator.dupe(u8, id.name));
    }
    return try names.toOwnedSlice(allocator);
}

fn loadColorsInto(
    class_attr: *std.StringHashMap(Attribute),
    arena: Allocator,
    allocator: Allocator,
    source: []const u8,
) !void {
    var class_parents = std.StringHashMap([]const []const u8).init(allocator);
    defer class_parents.deinit();

    var line_start: usize = 0;
    while (line_start < source.len) {
        var line_end = line_start;
        while (line_end < source.len and source[line_end] != '\n') : (line_end += 1) {}
        const raw = source[line_start..line_end];
        line_start = if (line_end < source.len) line_end + 1 else line_end;

        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0 or line[0] == '#' or line[0] != '=') continue;

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
    }

    var pending = std.ArrayList([]const u8).empty;
    defer pending.deinit(allocator);
    var it = class_parents.keyIterator();
    while (it.next()) |k| {
        try pending.append(allocator, k.*);
    }
    for (pending.items) |cname| {
        _ = resolveClass(class_attr, &class_parents, cname, 0);
    }
}


fn cacheKey(arena: Allocator, file: []const u8, subr: ?[]const u8, params: []const []const u8) ![]const u8 {
    var out: std.ArrayList(u8) = .empty;
    try out.appendSlice(arena, file);
    try out.append(arena, 0);
    if (subr) |s| try out.appendSlice(arena, s);
    try out.append(arena, 0);
    for (params) |p| {
        try out.appendSlice(arena, p);
        try out.append(arena, 0);
    }
    return try out.toOwnedSlice(arena);
}

fn resolveSource(ctx: *LoadCtx, file: []const u8) LoadError![]const u8 {
    if (std.mem.eql(u8, file, ctx.root_name)) return ctx.root_source;
    return ctx.library.find(file) orelse error.UnknownSyntax;
}

fn ensureLoaded(
    ctx: *LoadCtx,
    file: []const u8,
    subr: ?[]const u8,
    params: []const []const u8,
) LoadError!*Syntax {
    const key = try cacheKey(ctx.arena, file, subr, params);
    if (ctx.syntax_cache.get(key)) |s| return s;

    const source = try resolveSource(ctx, file);
    var colors = std.StringHashMap(Attribute).init(ctx.allocator);
    errdefer colors.deinit();
    try loadColorsInto(&colors, ctx.arena, ctx.allocator, source);

    const saved_attr = ctx.class_attr;
    const saved_source = ctx.source;
    const saved_name = ctx.name;
    const saved_params = ctx.params;
    ctx.class_attr = colors;
    ctx.source = source;
    ctx.name = file;
    ctx.params = params;

    const syn = loadPiece(ctx, subr) catch |err| {
        ctx.class_attr = saved_attr;
        ctx.source = saved_source;
        ctx.name = saved_name;
        ctx.params = saved_params;
        colors.deinit();
        return err;
    };

    ctx.class_attr = saved_attr;
    ctx.source = saved_source;
    ctx.name = saved_name;
    ctx.params = saved_params;
    colors.deinit();

    // Cache before bind so recursive calls can reuse this instance.
    try ctx.syntax_cache.put(key, syn);
    const slot_name = if (subr) |s|
        try std.fmt.allocPrint(ctx.arena, "{s}.{s}", .{ file, s })
    else
        try ctx.arena.dupe(u8, file);
    try ctx.all_slots.append(ctx.arena, .{ .name = slot_name, .syn = syn });
    try bindCalls(ctx, syn);
    return syn;
}

/// Load a `.jsf` source (subset). `name` is a display label (copied).
pub fn load(allocator: Allocator, name: []const u8, source: []const u8) LoadError!Syntax {
    return loadWithLibrary(allocator, name, source, .{});
}

/// Load a `.jsf` source with an in-memory library for external `call=file…`.
pub fn loadWithLibrary(
    allocator: Allocator,
    name: []const u8,
    source: []const u8,
    library: SyntaxLibrary,
) LoadError!Syntax {
    const arena_ptr = try allocator.create(std.heap.ArenaAllocator);
    errdefer allocator.destroy(arena_ptr);
    arena_ptr.* = std.heap.ArenaAllocator.init(allocator);
    errdefer arena_ptr.deinit();
    const arena = arena_ptr.allocator();

    var ctx = LoadCtx{
        .allocator = allocator,
        .arena = arena,
        .arena_ptr = arena_ptr,
        .root_name = name,
        .root_source = source,
        .name = name,
        .source = source,
        .params = &.{},
        .class_attr = std.StringHashMap(Attribute).init(allocator),
        .library = library,
        .syntax_cache = std.StringHashMap(*Syntax).init(allocator),
        .all_slots = .empty,
    };
    defer ctx.class_attr.deinit();
    defer ctx.syntax_cache.deinit();

    try loadColorsInto(&ctx.class_attr, arena, allocator, source);

    const main_ptr = try loadPiece(&ctx, null);
    const main_key = try cacheKey(arena, name, null, &.{});
    try ctx.syntax_cache.put(main_key, main_ptr);
    try bindCalls(&ctx, main_ptr);

    main_ptr.subrs = try ctx.all_slots.toOwnedSlice(arena);
    var result = main_ptr.*;
    result.owns_arena = true;
    main_ptr.owns_arena = false;
    return result;
}

fn bindCalls(ctx: *LoadCtx, syn: *Syntax) LoadError!void {
    for (syn.states) |*st| {
        if (st.dflt) |*d| try bindCmd(ctx, d, syn.params);
        if (st.delim) |*d| try bindCmd(ctx, d, syn.params);
        if (st.same_delim) |*d| try bindCmd(ctx, d, syn.params);
        for (st.transitions) |*tr| {
            try bindCmd(ctx, &tr.cmd, syn.params);
            for (tr.cmd.keywords) |*kw| {
                try bindCmd(ctx, @constCast(&kw.cmd), syn.params);
            }
            if (tr.cmd.strings_delim) |dptr| try bindCmd(ctx, dptr, syn.params);
        }
        if (st.dflt) |*d| {
            if (d.strings_delim) |dptr| try bindCmd(ctx, dptr, syn.params);
        }
    }
}

fn bindCmd(ctx: *LoadCtx, cmd: *Command, caller_params: []const []const u8) LoadError!void {
    if (cmd.call_spec) |spec| {
        const resolved = try applyParamDeltas(ctx.arena, caller_params, spec.deltas);
        cmd.call = try ensureLoaded(ctx, spec.file, spec.subr, resolved);
    }
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
    try testing.expect(Color.eql(attrs[1].fg, .{ .indexed = 2 }) or attrs[1].dim);
    try testing.expect(attrs[2].dim or Color.eql(attrs[2].fg, .{ .indexed = 2 }));

    const line2 = "\"xy\"";
    st = syn.parseLine(line2, .initial, attrs[0..line2.len]);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 3 }));
    try testing.expect(Color.eql(attrs[1].fg, .{ .indexed = 3 }));
    try testing.expect(Color.eql(attrs[3].fg, .{ .indexed = 3 }));
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
\\:single String string
\\  *    single
\\  "'"    idle
\\  "\\"    single_escape  recolor=-1
\\
\\:single_escape StringEscape string
\\  *    single
\\  "\n"    single    recolor=-2
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
\\:string_in_bt String string
\\  *    string_in_bt
\\  "\""    backtick
\\  "\\"    string_escape_b  recolor=-1
\\
\\:string_escape_b StringEscape string
\\  *    string_in_bt
\\  "\n"    string_in_bt  recolor=-2
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
    const lines = [_][]const u8{ "#a", "b" };
    const st = syn.stateAfterLines(&lines, .initial);
    try testing.expectEqual(@as(i32, 0), st.state);
}

test "buffer+strings highlights C-like keywords" {
    const src =
        \\=Idle
        \\=Ident
        \\=Type
        \\:idle Idle
        \\  *    idle
        \\  "\i"    ident    recolor=-1 buffer
        \\:ident Ident
        \\  *    idle    noeat strings
        \\  "int"    type
        \\  "if"    type
        \\done
        \\  "\c"    ident
        \\:type Type
        \\  *    idle    noeat
    ;
    var syn = try load(testing.allocator, "kw", src);
    defer syn.deinit();

    var attrs: [32]Attribute = undefined;
    const line = "int x";
    _ = syn.parseLine(line, .initial, attrs[0..line.len]);
    // "int" should be Type-colored (bold indexed 4)
    try testing.expect(attrs[0].bold);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 4 }));
    try testing.expect(Color.eql(attrs[1].fg, .{ .indexed = 4 }));
    try testing.expect(Color.eql(attrs[2].fg, .{ .indexed = 4 }));
    // space / ident fall back toward idle/ident
    try testing.expect(Attribute.eql(attrs[3], .none) or Color.eql(attrs[3].fg, .default));
}

test "hold stops buffering for delayed strings lookup" {
    // Fortran/c.jsf shape: buffer ident, hold on space, strings on next char.
    const src =
        \\=Idle
        \\=Ident
        \\=Keyword
        \\:idle Idle
        \\  *    idle
        \\  "\i"    ident    recolor=-1 buffer
        \\:ident Ident
        \\  *    ident
        \\  "\c"    ident
        \\  " \t"    ws_ident    hold
        \\:ws_ident Idle
        \\  *    idle    noeat strings
        \\  "write"    keyword
        \\done
        \\  "("    idle
        \\:keyword Keyword
        \\  *    idle    noeat
    ;
    var syn = try load(testing.allocator, "hold", src);
    defer syn.deinit();

    var attrs: [32]Attribute = undefined;
    const line = "write 7";
    _ = syn.parseLine(line, .initial, attrs[0..line.len]);
    // "write" recolored as Keyword despite the held space before '7'.
    try testing.expect(attrs[0].bold);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 6 }));
    try testing.expect(Color.eql(attrs[4].fg, .{ .indexed = 6 }));
    // Space and '7' are not part of the keyword recolor.
    try testing.expect(!attrs[5].bold);
    try testing.expect(!attrs[6].bold);
}

test "hold+noeat strings on terminator matches go.jsf shape" {
    // Same role as go.jsf `noeat hold strings` on a non-ident terminator.
    // (Full hex-range char classes are a separate TODO.)
    const src =
        \\=Idle
        \\=Ident
        \\=Keyword
        \\:idle Idle
        \\  *    idle
        \\  "\i"    ident    recolor=-1 buffer
        \\:ident Ident
        \\  *    ident
        \\  "\c"    ident
        \\  " \t()[]{}"    idle    noeat hold strings
        \\  "func"    keyword
        \\  "package"    keyword
        \\done
        \\:keyword Keyword
        \\  *    idle    noeat
    ;
    var syn = try load(testing.allocator, "gohold", src);
    defer syn.deinit();

    var attrs: [32]Attribute = undefined;
    const line = "func ";
    _ = syn.parseLine(line, .initial, attrs[0..line.len]);
    try testing.expect(attrs[0].bold);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 6 }));
    try testing.expect(Color.eql(attrs[3].fg, .{ .indexed = 6 }));
    try testing.expect(!attrs[4].bold);
}

test "local call=.slash() and return color line comments" {
    const src =
        \\=Idle
        \\=Comment
        \\:idle Idle
        \\  *    idle
        \\  "/"    idle    call=.slash()
        \\.subr slash
        \\:slash Comment comment
        \\  *    NULL    noeat recolor=-2 return
        \\  "/"    line_comment    recolor=-2
        \\:line_comment Comment comment
        \\  *    line_comment
        \\  "\n"    NULL    noeat return
        \\.end
    ;
    var syn = try load(testing.allocator, "slash", src);
    defer syn.deinit();
    try testing.expect(syn.subrs.len == 1);

    var attrs: [32]Attribute = undefined;
    const line = "// hi";
    const st = syn.parseLine(line, .initial, attrs[0..line.len]);
    try testing.expect(attrs[0].dim or Color.eql(attrs[0].fg, .{ .indexed = 2 }));
    try testing.expect(attrs[1].dim or Color.eql(attrs[1].fg, .{ .indexed = 2 }));
    try testing.expect(attrs[3].dim or Color.eql(attrs[3].fg, .{ .indexed = 2 }));
    // Returned to idle for next line.
    try testing.expectEqual(@as(i32, 0), st.state);
    try testing.expectEqual(@as(u8, 0), st.syn_id);
    try testing.expectEqual(@as(u8, 0), st.stack_depth);
}

test "block comment call/rtn persists across lines" {
    const src =
        \\=Idle
        \\=Comment
        \\:idle Idle
        \\  *    idle
        \\  "/"    idle    call=.slash()
        \\.subr slash
        \\:slash Comment comment
        \\  *    NULL    noeat recolor=-2 return
        \\  "*"    comment    recolor=-2
        \\:comment Comment comment
        \\  *    comment
        \\  "*"    maybe_end
        \\:maybe_end Comment comment
        \\  *    comment
        \\  "/"    NULL    return
        \\.end
    ;
    var syn = try load(testing.allocator, "block", src);
    defer syn.deinit();

    var attrs: [32]Attribute = undefined;
    var st = syn.parseLine("/* a", .initial, attrs[0..4]);
    try testing.expect(st.stack_depth == 1);
    try testing.expect(attrs[0].dim or Color.eql(attrs[0].fg, .{ .indexed = 2 }));

    st = syn.parseLine("b */", st, attrs[0..4]);
    try testing.expectEqual(@as(u8, 0), st.stack_depth);
    try testing.expectEqual(@as(i32, 0), st.state);
}

test "c.jsf-shaped slice: keywords plus local slash subr" {
    const src =
        \\=Idle
        \\=Ident
        \\=Comment
        \\=Type
        \\=Statement
        \\=Keyword
        \\:idle Idle
        \\  *    idle
        \\  "/"    idle    call=.slash()
        \\  "\i"    ident    recolor=-1 buffer
        \\.subr slash
        \\:slash Comment comment
        \\  *    NULL    noeat recolor=-2 return
        \\  "/"    line_comment    recolor=-2
        \\:line_comment Comment comment
        \\  *    line_comment
        \\  "\n"    NULL    noeat return
        \\.end
        \\:ident Ident
        \\  *    idle    noeat strings
        \\  "int"    type
        \\  "return"    stmt
        \\done
        \\  "\c"    ident
        \\:type Type
        \\  *    idle    noeat
        \\:stmt Statement
        \\  *    idle    noeat
    ;
    var syn = try load(testing.allocator, "cslice", src);
    defer syn.deinit();

    var attrs: [64]Attribute = undefined;
    const line = "return x; // done";
    _ = syn.parseLine(line, .initial, attrs[0..line.len]);
    // "return" is Statement (Keyword family → bold indexed 6)
    try testing.expect(attrs[0].bold);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 6 }));
    // "//" comment tail — find first '/'
    const slash = std.mem.indexOfScalar(u8, line, '/') orelse return error.TestUnexpectedResult;
    try testing.expect(attrs[slash].dim or Color.eql(attrs[slash].fg, .{ .indexed = 2 }));
    try testing.expect(attrs[slash + 1].dim or Color.eql(attrs[slash + 1].fg, .{ .indexed = 2 }));
}

test "mark+recolormark colors preprocessor directive" {
    // Mirrors c.jsf :first/# → :pre → :preident + strings path (no call/ifdef).
    const src =
        \\=Idle
        \\=Preproc
        \\=Define
        \\=Precond
        \\:reset Idle
        \\  *    first    noeat
        \\  " \t"    reset
        \\:first Idle
        \\  *    idle    noeat
        \\  "#"    pre    mark
        \\:pre Preproc
        \\  *    preproc    noeat
        \\  " \t"    pre
        \\  "a-z"    preident    recolor=-1 buffer
        \\:preident Preproc
        \\  *    preproc    noeat markend recolormark strings
        \\  "define"    predef    markend recolormark
        \\  "ifdef"    precond    markend recolormark
        \\done
        \\  "a-z"    preident
        \\:predef Define
        \\  *    predef
        \\  "\n"    reset
        \\:precond Precond
        \\  *    preproc    noeat
        \\:preproc Preproc
        \\  *    preproc
        \\  "\n"    reset
        \\:idle Idle
        \\  *    idle
        \\  "\n"    reset
    ;
    var syn = try load(testing.allocator, "pre", src);
    defer syn.deinit();

    var attrs: [64]Attribute = undefined;
    const line = "#define FOO";
    _ = syn.parseLine(line, .initial, attrs[0..line.len]);
    // Entire "#define" should be Define/Preproc colored (bold indexed 5).
    try testing.expect(attrs[0].bold);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 5 }));
    try testing.expect(Color.eql(attrs[6].fg, .{ .indexed = 5 })); // 'e' of define
}

test "markend without keyword still recolormarks unknown directive" {
    const src =
        \\=Idle
        \\=Preproc
        \\:first Idle
        \\  *    idle    noeat
        \\  "#"    pre    mark
        \\:pre Preproc
        \\  *    preproc    noeat
        \\  "a-z"    preident    recolor=-1 buffer
        \\:preident Preproc
        \\  *    preproc    noeat markend recolormark strings
        \\  "define"    predef    markend recolormark
        \\done
        \\  "a-z"    preident
        \\:predef Preproc
        \\  *    preproc    noeat
        \\:preproc Preproc
        \\  *    preproc
        \\  "\n"    idle
        \\:idle Idle
        \\  *    idle
    ;
    var syn = try load(testing.allocator, "pre2", src);
    defer syn.deinit();

    var attrs: [32]Attribute = undefined;
    const line = "#pragma";
    _ = syn.parseLine(line, .initial, attrs[0..line.len]);
    // Unknown directive: mark region recolored with Preproc on default strings miss.
    try testing.expect(attrs[0].bold);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 5 }));
    try testing.expect(Color.eql(attrs[2].fg, .{ .indexed = 5 }));
}


test "save_c and & close matching quote" {
    // Python-like: open quote push_c/save_c; & closes with pop.
    const src =
        \\=Idle
        \\=String
        \\:idle Idle
        \\  *    idle
        \\  "'\""    string    recolor=-1 push_c
        \\:string String string
        \\  *    string
        \\  &    idle    pop_c
    ;
    var syn = try load(testing.allocator, "quot", src);
    defer syn.deinit();

    var attrs: [32]Attribute = undefined;
    const line = "'hi'";
    const st = syn.parseLine(line, .initial, attrs[0..line.len]);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 3 }));
    try testing.expect(Color.eql(attrs[1].fg, .{ .indexed = 3 }));
    try testing.expect(Color.eql(attrs[2].fg, .{ .indexed = 3 }));
    try testing.expect(Color.eql(attrs[3].fg, .{ .indexed = 3 }));
    try testing.expectEqual(@as(i32, 0), st.state);
    try testing.expectEqual(@as(u8, 0), st.delim_depth);
}

test "save_c and % match same delimiter" {
    // Angled brackets so & and % differ: save_c '<' → saved=['>', '<'].
    // '<' matches % (same); '>' matches & (opposite).
    const src =
        \\=Idle
        \\=Regex
        \\:idle Idle
        \\  *    idle
        \\  "<"    inmatch    save_c recolor=-1
        \\:inmatch Regex
        \\  *    inmatch
        \\  %    still
        \\  &    idle
        \\:still Regex
        \\  *    still
        \\  &    idle
    ;
    var syn = try load(testing.allocator, "re2", src);
    defer syn.deinit();
    try testing.expect(syn.states[1].same_delim != null);
    try testing.expect(syn.states[1].delim != null);

    var attrs: [32]Attribute = undefined;
    // Stop after second '<' — must be in `still` (index 2) via %.
    var st = syn.parseLine("<a<", .initial, attrs[0..3]);
    try testing.expectEqual(@as(i32, 2), st.state);
    st = syn.parseLine("<a<a>", .initial, attrs[0..5]);
    try testing.expectEqual(@as(i32, 0), st.state);
}

test "push_c and pop_c nest delimiter buffers" {
    const src =
        \\=Idle
        \\=String
        \\:idle Idle
        \\  *    idle
        \\  "'\""    string    recolor=-1 push_c
        \\:string String string
        \\  *    string
        \\  &    idle    pop_c
    ;
    var syn = try load(testing.allocator, "nest", src);
    defer syn.deinit();

    var attrs: [32]Attribute = undefined;
    // Nested different quotes: "a'b'c"
    const line = "\"a'b'c\"";
    const st = syn.parseLine(line, .initial, attrs[0..line.len]);
    try testing.expectEqual(@as(i32, 0), st.state);
    // Outer " ... " should all be String; inner quotes also String (nested push).
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 3 }));
    try testing.expect(Color.eql(attrs[2].fg, .{ .indexed = 3 }));
    try testing.expect(Color.eql(attrs[4].fg, .{ .indexed = 3 }));
    try testing.expect(Color.eql(attrs[6].fg, .{ .indexed = 3 }));
    try testing.expectEqual(@as(u8, 0), st.delim_depth);
}

test "save_s and strings & match delimiter buffer" {
    // Line1 buffers a word and save_s it; line2 buffers again and strings `"&"` hits.
    const src =
        \\=Idle
        \\=Type
        \\:idle Idle
        \\  *    idle
        \\  "\i"    word    recolor=-1 buffer
        \\:word Idle
        \\  *    idle    noeat save_s strings
        \\  "&"    type
        \\done
        \\  "\c"    word
        \\:type Type
        \\  *    idle    noeat
    ;
    var syn = try load(testing.allocator, "save_s", src);
    defer syn.deinit();
    try testing.expect(syn.states[1].dflt != null);
    try testing.expect(syn.states[1].dflt.?.strings_delim != null);

    var attrs: [32]Attribute = undefined;
    var st = syn.parseLine("ab", .initial, attrs[0..2]);
    try testing.expect(st.saved.eql("ab"));
    // Second line: buffer "ab" again; on terminator, strings `"&"` matches saved.
    st = syn.parseLine("ab", st, attrs[0..2]);
    try testing.expect(attrs[0].bold);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 4 }));
    try testing.expectEqual(@as(i32, 0), st.state);
}

test "external call=file.subr() highlights TODO" {
    const lib_src =
        \\=Comment
        \\=TODO
        \\.subr comment_todo
        \\:comment_todo_init Comment comment
        \\  *    comment_todo_guess    buffer
        \\:comment_todo_guess Comment comment
        \\  *    comment_todo_unknown    noeat strings
        \\  "TODO"    comment_todo
        \\  "FIXME"    comment_todo
        \\done
        \\  "A-Z"    comment_todo_guess
        \\:comment_todo_unknown Comment comment
        \\  *    NULL    noeat return
        \\:comment_todo TODO comment
        \\  *    NULL    noeat return
        \\.end
    ;
    const src =
        \\=Idle
        \\=Comment
        \\:idle Idle
        \\  *    idle
        \\  "/"    idle    call=.slash()
        \\.subr slash
        \\:slash Comment comment
        \\  *    NULL    noeat recolor=-2 return
        \\  "/"    line_comment    recolor=-2
        \\:line_comment Comment comment
        \\  *    line_comment
        \\  "BFHNTX"    line_comment    noeat call=todo_lib.comment_todo()
        \\  "\n"    NULL    noeat return
        \\.end
    ;
    var syn = try loadWithLibrary(testing.allocator, "host", src, .{
        .files = &.{
            .{ .name = "todo_lib", .source = lib_src },
        },
    });
    defer syn.deinit();

    var attrs: [64]Attribute = undefined;
    const line = "// TODO x";
    const st = syn.parseLine(line, .initial, attrs[0..line.len]);
    // "//" comment-colored
    try testing.expect(attrs[0].dim or Color.eql(attrs[0].fg, .{ .indexed = 2 }));
    // "TODO" should be TODO class (bold indexed 3)
    const t = std.mem.indexOf(u8, line, "TODO") orelse return error.TestUnexpectedResult;
    try testing.expect(attrs[t].bold);
    try testing.expect(Color.eql(attrs[t].fg, .{ .indexed = 3 }));
    try testing.expectEqual(@as(u8, 0), st.stack_depth);
    try testing.expectEqual(@as(i32, 0), st.state);
}

test "external call=file() invokes whole-file syntax" {
    const lib_src =
        \\=Idle
        \\=String
        \\:idle Idle
        \\  *    idle
        \\  "\""    string    recolor=-1
        \\:string String string
        \\  *    string
        \\  "\""    NULL    return
    ;
    const src =
        \\=Idle
        \\:idle Idle
        \\  *    idle
        \\  "\""    idle    noeat call=strlib()
    ;
    var syn = try loadWithLibrary(testing.allocator, "host", src, .{
        .files = &.{
            .{ .name = "strlib", .source = lib_src },
        },
    });
    defer syn.deinit();

    var attrs: [32]Attribute = undefined;
    const line = "\"hi\"";
    const st = syn.parseLine(line, .initial, attrs[0..line.len]);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 3 }));
    try testing.expect(Color.eql(attrs[1].fg, .{ .indexed = 3 }));
    try testing.expect(Color.eql(attrs[2].fg, .{ .indexed = 3 }));
    try testing.expectEqual(@as(i32, 0), st.state);
    try testing.expectEqual(@as(u8, 0), st.stack_depth);
}

test "external call unknown file returns UnknownSyntax" {
    const src =
        \\=Idle
        \\:idle Idle
        \\  *    idle
        \\  "x"    idle    call=missing.subr()
    ;
    try testing.expectError(error.UnknownSyntax, loadWithLibrary(testing.allocator, "host", src, .{}));
}


test "ifdef params select then/else branches" {
    const src =
        \\=Idle
        \\=Comment
        \\=String
        \\:idle Idle
        \\  *    idle
        \\  "a"    idle    noeat call=.piece(long)
        \\  "b"    idle    noeat call=.piece()
        \\.subr piece
        \\.ifdef long
        \\:body String string
        \\  *    NULL    noeat return
        \\.else
        \\:body Comment comment
        \\  *    NULL    noeat return
        \\.endif
        \\.end
    ;
    var syn = try load(testing.allocator, "host", src);
    defer syn.deinit();

    // Two param instantiations of the same subr.
    try testing.expect(syn.subrs.len >= 2);

    var attrs: [8]Attribute = undefined;
    _ = syn.parseLine("a", .initial, attrs[0..1]);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 3 })); // String

    _ = syn.parseLine("b", .initial, attrs[0..1]);
    try testing.expect(attrs[0].dim or Color.eql(attrs[0].fg, .{ .indexed = 2 })); // Comment
}

test "ifdef nested and -param removal" {
    const src =
        \\=Idle
        \\=Comment
        \\=String
        \\=Type
        \\:idle Idle
        \\  *    idle
        \\  "x"    idle    noeat call=.piece(outer inner)
        \\  "y"    idle    noeat call=.piece(outer)
        \\  "z"    idle    noeat call=.piece(outer -inner)
        \\.subr piece
        \\.ifdef outer
        \\.ifdef inner
        \\:body Type
        \\  *    NULL    noeat return
        \\.else
        \\:body String string
        \\  *    NULL    noeat return
        \\.endif
        \\.else
        \\:body Comment comment
        \\  *    NULL    noeat return
        \\.endif
        \\.end
    ;
    var syn = try load(testing.allocator, "host", src);
    defer syn.deinit();

    var attrs: [8]Attribute = undefined;
    _ = syn.parseLine("x", .initial, attrs[0..1]);
    try testing.expect(attrs[0].bold); // Type
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 4 }));

    _ = syn.parseLine("y", .initial, attrs[0..1]);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 3 })); // String (outer, not inner)

    // z: start from outer then -inner → same as outer only → String
    _ = syn.parseLine("z", .initial, attrs[0..1]);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 3 }));
}

test "ifdef params propagate through external call" {
    const lib_src =
        \\=Comment
        \\=String
        \\.subr piece
        \\.ifdef fancy
        \\:body String string
        \\  *    NULL    noeat return
        \\.else
        \\:body Comment comment
        \\  *    NULL    noeat return
        \\.endif
        \\.end
    ;
    const src =
        \\=Idle
        \\:idle Idle
        \\  *    idle
        \\  "a"    idle    noeat call=lib.piece(fancy)
        \\  "b"    idle    noeat call=lib.piece()
    ;
    var syn = try loadWithLibrary(testing.allocator, "host", src, .{
        .files = &.{.{ .name = "lib", .source = lib_src }},
    });
    defer syn.deinit();

    var attrs: [8]Attribute = undefined;
    _ = syn.parseLine("a", .initial, attrs[0..1]);
    try testing.expect(Color.eql(attrs[0].fg, .{ .indexed = 3 }));
    _ = syn.parseLine("b", .initial, attrs[0..1]);
    try testing.expect(attrs[0].dim or Color.eql(attrs[0].fg, .{ .indexed = 2 }));
}
