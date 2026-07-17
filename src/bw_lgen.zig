//! Gated live bridge: JOE `lgen_core` → Zig-native `render.lgenLine`.
//!
//! When `JOE_ZIG_BW_LGEN` / `zig_bw_lgen_enabled` is on, non-viewmode /
//! non-mark / UTF-8 lines paint through the Phase 6 renderer and emit via
//! hybrid `outatr` (works with screen-swap shadow + classic tty path).
//! Default off until soak. Falls back to C `lgen_core` when the gate is off
//! or the line is unsupported.
//!
//! Hybrid `syntax.parse` fills `attr_buf` **per character** (`pgetc`); native
//! `lgenLine` expects **per-byte** attrs — this bridge expands before paint.

const std = @import("std");
const terminal = @import("terminal");
const render = @import("render");

const Attribute = terminal.Attribute;
const TruecolorPalette = terminal.TruecolorPalette;

const COMPOSE = 4;
const NO_MORE_DATA: c_int = -256;
const max_line_bytes: usize = 256 * 1024;

const SCRN = opaque {};
const P = opaque {};
const Charmap = extern struct {
    next: ?*Charmap = null,
    name: ?[*:0]u8 = null,
    /// Non-zero ⇒ UTF-8 (JOE `charmap->type`). Truncated layout; only first fields used.
    @"type": c_int = 0,
};
const HighSyntax = opaque {};

const HighlightState = extern struct {
    stack: ?*anyopaque = null,
    delim_stack: ?*anyopaque = null,
    saved_s: ?*const c_int = null,
    state: isize = 0,
};

pub export var zig_bw_lgen_enabled: c_int = 0;

extern var attr_buf: [*c]c_int;
extern var attr_size: c_int;

extern fn parse(syntax: ?*HighSyntax, line: ?*P, h_state: HighlightState, charmap: ?*Charmap) HighlightState;
extern fn pdup(p: ?*P, tr: [*:0]const u8) ?*P;
extern fn prm(p: ?*P) void;
extern fn pnextl(p: ?*P) ?*P;
extern fn pgetb(p: ?*P) c_int;
extern fn outatr(
    map: ?*Charmap,
    t: ?*SCRN,
    scrn: ?*[COMPOSE]c_int,
    attrf: ?*c_int,
    xx: isize,
    yy: isize,
    c: c_int,
    a: c_int,
) void;
extern fn outatr_complete(t: ?*SCRN) void;
extern fn eraeol(t: ?*SCRN, x: isize, y: isize, atr: c_int) c_int;

/// Apply env gate (called from `ttopnn` alongside screen-swap).
pub export fn zig_bw_lgen_apply_env() void {
    if (std.c.getenv("JOE_ZIG_BW_LGEN")) |v| {
        zig_bw_lgen_enabled = if (v[0] == '1' or v[0] == 'y' or v[0] == 'Y') 1 else 0;
    }
}

/// Returns:
/// - `0`/`1` — same meaning as C `lgen_core` (`updtab` done flag from `eraeol`)
/// - `-1` — caller should fall back to C `lgen_core`
pub export fn zig_bw_lgen(
    t: ?*SCRN,
    y: isize,
    screen: ?[*][COMPOSE]c_int,
    attr_row: ?[*]c_int,
    x0: isize,
    x1: isize,
    p: ?*P,
    scr_offset: i64,
    syntax: ?*HighSyntax,
    st: HighlightState,
    charmap: ?*Charmap,
    tab: c_int,
    defatr: c_int,
    palette: ?[*]c_int,
    palette_len: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (t == null or screen == null or attr_row == null or p == null) return -1;
    if (x1 <= x0) return -1;
    if (charmap == null or charmap.?.@"type" == 0) return -1; // UTF-8 only for spike

    const win_w_isize = x1 - x0;
    if (win_w_isize <= 0 or win_w_isize > 10000) return -1;
    const win_w: u16 = @intCast(win_w_isize);

    const alloc = std.heap.c_allocator;
    var line_buf: std.ArrayList(u8) = .empty;
    defer line_buf.deinit(alloc);

    // Read from caller's `p` as-is (BOL of the target line, or EOF).
    // Do **not** `p_goto_bol`: past-EOF `getto` leaves `p` at EOF on the last
    // line, and C `lgen_core` paints blank from that position. Going to BOL
    // would repaint the last line on every trailing screen row.
    const len_tmp = pdup(p, "zig_bw_lgen_len") orelse return -1;
    defer prm(len_tmp);
    var ll: usize = 0;
    while (true) {
        const ch = pgetb(len_tmp);
        if (ch == NO_MORE_DATA or ch == '\n') break;
        ll += 1;
        if (ll > max_line_bytes) return -1;
    }

    const highlight = (syntax != null and st.state != -1);
    if (highlight) {
        // Separate dup: `parse` consumes through the newline via `pgetc`.
        const parse_tmp = pdup(p, "zig_bw_lgen_parse") orelse return -1;
        defer prm(parse_tmp);
        _ = parse(syntax, parse_tmp, st, charmap);
    }

    const copy_tmp = pdup(p, "zig_bw_lgen_copy") orelse return -1;
    defer prm(copy_tmp);
    while (true) {
        const ch = pgetb(copy_tmp);
        if (ch == NO_MORE_DATA or ch == '\n') break;
        if (line_buf.items.len >= max_line_bytes) break;
        line_buf.append(alloc, @intCast(ch)) catch return -1;
    }
    const line = line_buf.items;

    const pal: ?[]const i32 = if (palette != null and palette_len > 0)
        palette.?[0..@intCast(palette_len)]
    else
        null;

    var attrs_owned: ?[]Attribute = null;
    defer if (attrs_owned) |a| alloc.free(a);
    var native_attrs: ?[]const Attribute = null;

    if (highlight and attr_buf != null and attr_size > 0 and line.len > 0) {
        // Hybrid `parse`/`pgetc` fills one atr per character, not per byte.
        const nchar = @min(utf8CharCount(line), @as(usize, @intCast(attr_size)));
        const char_attrs = alloc.alloc(Attribute, nchar) catch return -1;
        defer alloc.free(char_attrs);
        render.fromHybridRow(char_attrs, attr_buf[0..nchar], pal);

        const byte_attrs = alloc.alloc(Attribute, line.len) catch return -1;
        expandCharAttrsToBytes(line, char_attrs, byte_attrs);
        attrs_owned = byte_attrs;
        native_attrs = byte_attrs;
    }

    const base_attr = terminal.attributeFromHybrid(defatr, pal);

    var scratch = terminal.Screen.init(alloc, win_w, 1) catch return -1;
    defer scratch.deinit();

    const tab_u: u16 = if (tab <= 0) 8 else @intCast(@min(tab, 256));
    const opts: render.Options = .{
        .tab = tab_u,
        .offset = if (scr_offset < 0) 0 else @intCast(scr_offset),
        .attrs = native_attrs,
        .view = null,
    };
    _ = render.lgenLine(&scratch, 0, 0, win_w, line, opts, base_attr);

    var tc_pal: TruecolorPalette = .{};
    if (palette != null and palette_len > 0) {
        var pi: u8 = 1;
        const plen: usize = @intCast(palette_len);
        while (pi < 255 and pi < plen) : (pi += 1) {
            const v = palette.?[pi];
            if (v >= 0) {
                tc_pal.slots[pi] = @intCast(v);
                if (tc_pal.next <= pi) tc_pal.next = pi +% 1;
            }
        }
    }

    var cx: u16 = 0;
    while (cx < win_w) : (cx += 1) {
        const cell = scratch.cells[cx];
        // Wide-continuation cells (cp==0) are filled by `outatr_complete`.
        if (cell.cp == 0) continue;

        const atr: c_int = attributeToHybridOrDef(cell.attr, &tc_pal, defatr);
        const xx: isize = x0 + @as(isize, @intCast(cx));
        outatr(
            charmap,
            t,
            @ptrCast(screen.? + @as(usize, @intCast(xx))),
            @ptrCast(attr_row.? + @as(usize, @intCast(xx))),
            xx,
            y,
            @intCast(cell.cp),
            atr,
        );
        for (cell.combine) |mark| {
            if (mark == 0) break;
            outatr(
                charmap,
                t,
                @ptrCast(screen.? + @as(usize, @intCast(xx))),
                @ptrCast(attr_row.? + @as(usize, @intCast(xx))),
                xx,
                y,
                @intCast(mark),
                atr,
            );
        }
    }
    outatr_complete(t);

    // Advance caller's P to next line (JOE lgen contract).
    _ = pnextl(p);

    const done = eraeol(t, x1, y, defatr);
    return done;
}

fn attributeToHybridOrDef(attr: Attribute, palette: *TruecolorPalette, defatr: c_int) c_int {
    return terminal.attributeToHybrid(attr, palette) catch defatr;
}

/// Expand hybrid per-character `attr_buf` (from `parse`/`pgetc`) into per-byte
/// attrs for UTF-8 `lgenLine` (lead + continuation share the char's atr).
fn expandCharAttrsToBytes(line: []const u8, char_attrs: []const Attribute, out: []Attribute) void {
    @memset(out, .none);
    var bi: usize = 0;
    var ci: usize = 0;
    while (bi < line.len and bi < out.len) {
        const nbytes = utf8SeqLen(line[bi]);
        const a = if (ci < char_attrs.len) char_attrs[ci] else Attribute.none;
        var k: usize = 0;
        while (k < nbytes and bi + k < out.len) : (k += 1) {
            out[bi + k] = a;
        }
        bi += nbytes;
        ci += 1;
    }
}

fn utf8SeqLen(lead: u8) usize {
    if (lead < 0x80) return 1;
    if (lead < 0xC2) return 1; // invalid / continuation → paint as single byte
    if (lead < 0xE0) return 2;
    if (lead < 0xF0) return 3;
    if (lead < 0xF5) return 4;
    return 1;
}

/// Count Unicode characters in a UTF-8 byte slice (invalid leads count as 1).
fn utf8CharCount(line: []const u8) usize {
    var n: usize = 0;
    var i: usize = 0;
    while (i < line.len) {
        i += utf8SeqLen(line[i]);
        n += 1;
    }
    return n;
}

test "gate defaults off" {
    try std.testing.expectEqual(@as(c_int, 0), zig_bw_lgen_enabled);
}

test "expandCharAttrsToBytes maps UTF-8 multi-byte to shared atr" {
    const line = "a\u{00e9}b"; // a, é (2 bytes), b
    var char_attrs = [_]Attribute{
        .{ .bold = true },
        .{ .underline = true },
        .{ .italic = true },
    };
    var out: [4]Attribute = undefined;
    expandCharAttrsToBytes(line, &char_attrs, &out);
    try std.testing.expect(out[0].bold);
    try std.testing.expect(out[1].underline);
    try std.testing.expect(out[2].underline); // continuation of é
    try std.testing.expect(out[3].italic);
}