//! Gated live bridge: JOE `lgen_core` → Zig-native `render.lgenLine`.
//!
//! When `JOE_ZIG_BW_LGEN` / `zig_bw_lgen_enabled` is on, plain UTF-8 lines
//! (including linear/square mark inverse + viewmode hide/substitute/link tables +
//! `-visiblews` glyphs + `-ansi` ESC hiding) paint through the Phase 6 renderer
//! and emit via hybrid `outatr` (works with screen-swap shadow + classic tty
//! path). Default off until soak. Falls back to C `lgen_core` when the gate is
//! off or the line is unsupported (non-UTF-8). Table padded rows stay in C
//! (`viewmode_table_rendered` skips `lgen_core`).
//!
//! Hybrid `syntax.parse` fills `attr_buf` **per character** (`pgetc`); native
//! `lgenLine` expects **per-byte** attrs — this bridge expands before paint.
//! `ansi_parse` temporarily clears `o.ansi`, so ESC bytes stay as normal chars
//! in `attr_buf`; Path A strips JOE `ansi_decode` spans (ESC…letter) after
//! attr/mark apply so colors stay aligned. When `viewmode!=0`, C `lgen_view`
//! already parsed+mutated `attr_buf` — do **not** re-parse. Linear marks use
//! raw byte offsets (before strip); square marks use post-strip display
//! columns. Default `selectatr=INVERSE`. Visible whitespace uses C
//! `vspace`/`vtab`/`vrtn` + `vwsatr`.

const std = @import("std");
const terminal = @import("terminal");
const render = @import("render");

const Attribute = terminal.Attribute;
const TruecolorPalette = terminal.TruecolorPalette;
const ViewTables = render.ViewTables;
const VisibleWs = render.VisibleWs;

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
extern var vwsatr: c_int;
extern var vspace: c_int;
extern var vtab: c_int;
extern var vrtn: c_int;

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
extern fn ttputs(s: [*c]const u8) void;

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
    from: i64,
    to: i64,
    line_byte: i64,
    viewmode: c_int,
    vm_hide: ?[*]u8,
    vm_hide_len: c_int,
    vm_subst: ?[*]c_int,
    vm_subst_len: c_int,
    vm_urls: ?[*]?[*:0]u8,
    vm_urls_len: c_int,
    visiblews: c_int,
    square: c_int,
    ansi: c_int,
) c_int {
    if (zig_bw_lgen_enabled == 0) return -1;
    if (t == null or screen == null or attr_row == null or p == null) return -1;
    if (x1 <= x0) return -1;
    if (charmap == null or charmap.?.@"type" == 0) return -1; // UTF-8 only for spike

    const win_w_isize = x1 - x0;
    if (win_w_isize <= 0 or win_w_isize > 10000) return -1;
    const win_w: u16 = @intCast(win_w_isize);
    const preparsed = viewmode != 0;

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
    // Viewmode: `lgen_view` already ran `parse` and mutated `attr_buf` (links etc).
    if (highlight and !preparsed) {
        const parse_tmp = pdup(p, "zig_bw_lgen_parse") orelse return -1;
        defer prm(parse_tmp);
        _ = parse(syntax, parse_tmp, st, charmap);
    }

    const copy_tmp = pdup(p, "zig_bw_lgen_copy") orelse return -1;
    defer prm(copy_tmp);
    var saw_eol = false;
    while (true) {
        const ch = pgetb(copy_tmp);
        if (ch == NO_MORE_DATA) break;
        if (ch == '\n') {
            saw_eol = true;
            break;
        }
        if (line_buf.items.len >= max_line_bytes) break;
        line_buf.append(alloc, @intCast(ch)) catch return -1;
    }
    // Include trailing `\n` so native paint emits `vrtn` (EOF-without-NL omits it).
    if (saw_eol and visiblews != 0) {
        line_buf.append(alloc, '\n') catch return -1;
    }
    const line = line_buf.items;
    // Attr/mark/view tables are per content byte — exclude synthetic `\n`.
    const content = if (saw_eol and visiblews != 0 and line.len > 0 and line[line.len - 1] == '\n')
        line[0 .. line.len - 1]
    else
        line;

    const pal: ?[]const i32 = if (palette != null and palette_len > 0)
        palette.?[0..@intCast(palette_len)]
    else
        null;

    var attrs_owned: ?[]Attribute = null;
    defer if (attrs_owned) |a| alloc.free(a);
    var native_attrs: ?[]const Attribute = null;

    const use_attr_buf = (highlight or preparsed) and attr_buf != null and attr_size > 0 and content.len > 0;
    if (use_attr_buf) {
        // Hybrid `parse`/`pgetc` fills one atr per character, not per byte.
        // Viewmode ASCII-mostly lines: char index ≡ byte index after C mutations.
        const nchar = @min(utf8CharCount(content), @as(usize, @intCast(attr_size)));
        const char_attrs = alloc.alloc(Attribute, nchar) catch return -1;
        defer alloc.free(char_attrs);
        render.fromHybridRow(char_attrs, attr_buf[0..nchar], pal);

        const byte_attrs = alloc.alloc(Attribute, content.len) catch return -1;
        expandCharAttrsToBytes(content, char_attrs, byte_attrs);
        attrs_owned = byte_attrs;
        native_attrs = byte_attrs;
    }

    // Linear mark inverse on raw bytes (ESC bytes count in buffer offsets).
    // Square marks wait until after ansi strip (display columns skip ESC).
    // `bwgen` already scopes square to mark lines (passes from=to=0 off-line).
    if (from != to and content.len > 0 and square == 0) {
        if (attrs_owned == null) {
            const byte_attrs = alloc.alloc(Attribute, content.len) catch return -1;
            @memset(byte_attrs, .none);
            attrs_owned = byte_attrs;
        }
        applyLinearMarkInverse(attrs_owned.?, line_byte, from, to);
        native_attrs = attrs_owned;
    }

    // Borrow C `lgen_view` side tables. `col_map` is cursor-only (stays in C).
    var hide_owned: ?[]u8 = null;
    defer if (hide_owned) |h| alloc.free(h);
    var subst_owned: ?[]u21 = null;
    defer if (subst_owned) |s| alloc.free(s);
    var links_owned: ?[]?[]const u8 = null;
    defer if (links_owned) |l| alloc.free(l);

    var view_tables: ViewTables = undefined;
    var view_ptr: ?*const ViewTables = null;

    if (preparsed and content.len > 0) {
        const n = content.len;

        const hide_slice: []u8 = blk: {
            if (vm_hide != null and vm_hide_len > 0) {
                const hn = @min(n, @as(usize, @intCast(vm_hide_len)));
                if (hn == n) break :blk vm_hide.?[0..hn];
                const padded = alloc.alloc(u8, n) catch return -1;
                @memset(padded, 0);
                @memcpy(padded[0..hn], vm_hide.?[0..hn]);
                hide_owned = padded;
                break :blk padded;
            }
            const zeros = alloc.alloc(u8, n) catch return -1;
            @memset(zeros, 0);
            hide_owned = zeros;
            break :blk zeros;
        };

        const subst = alloc.alloc(u21, n) catch return -1;
        @memset(subst, 0);
        if (vm_subst != null and vm_subst_len > 0) {
            const sn = @min(n, @as(usize, @intCast(vm_subst_len)));
            var i: usize = 0;
            while (i < sn) : (i += 1) {
                const v = vm_subst.?[i];
                if (v > 0) subst[i] = @intCast(v);
            }
        }
        subst_owned = subst;

        const links = alloc.alloc(?[]const u8, n) catch return -1;
        @memset(links, null);
        if (vm_urls != null and vm_urls_len > 0) {
            const un = @min(n, @as(usize, @intCast(vm_urls_len)));
            var i: usize = 0;
            while (i < un) : (i += 1) {
                if (vm_urls.?[i]) |up| links[i] = std.mem.span(up);
            }
        }
        links_owned = links;

        view_tables = .{
            .allocator = alloc,
            .owns_memory = false,
            .hide = hide_slice,
            .substitute = subst,
            .link_url = links,
            .col_map = &.{},
            .len = n,
        };
        view_ptr = &view_tables;
    }

    // `-ansi`: strip JOE `ansi_decode` spans (ESC…letter) for paint. Attrs from
    // `ansi_parse` stay aligned because parse walked the same raw characters.
    var ansi_text_owned: ?[]u8 = null;
    defer if (ansi_text_owned) |bytes| alloc.free(bytes);
    var ansi_attrs_owned: ?[]Attribute = null;
    defer if (ansi_attrs_owned) |a| alloc.free(a);
    var ansi_hide_owned: ?[]u8 = null;
    defer if (ansi_hide_owned) |h| alloc.free(h);
    var ansi_subst_owned: ?[]u21 = null;
    defer if (ansi_subst_owned) |s| alloc.free(s);
    var ansi_links_owned: ?[]?[]const u8 = null;
    defer if (ansi_links_owned) |l| alloc.free(l);

    var paint_content: []const u8 = content;
    if (ansi != 0 and content.len > 0) {
        const stripped = stripAnsiEscapes(
            alloc,
            content,
            if (attrs_owned) |a| a else null,
            if (view_ptr) |vt| vt.hide else null,
            if (view_ptr) |vt| vt.substitute else null,
            if (view_ptr) |vt| vt.link_url else null,
        ) catch return -1;
        ansi_text_owned = stripped.text;
        paint_content = stripped.text;
        if (stripped.attrs) |a| {
            ansi_attrs_owned = a;
            native_attrs = a;
        }
        if (view_ptr != null) {
            if (stripped.hide) |h| ansi_hide_owned = h;
            if (stripped.subst) |s| ansi_subst_owned = s;
            if (stripped.links) |l| ansi_links_owned = l;
            view_tables = .{
                .allocator = alloc,
                .owns_memory = false,
                .hide = ansi_hide_owned orelse &.{},
                .substitute = ansi_subst_owned orelse &.{},
                .link_url = ansi_links_owned orelse &.{},
                .col_map = &.{},
                .len = paint_content.len,
            };
            view_ptr = &view_tables;
        }
    }

    // Square mark inverse on display columns (post-ansi-strip).
    if (from != to and paint_content.len > 0 and square != 0) {
        const mutable: []Attribute = blk: {
            if (ansi_attrs_owned) |a| break :blk a;
            if (attrs_owned) |a| break :blk a;
            const byte_attrs = alloc.alloc(Attribute, paint_content.len) catch return -1;
            @memset(byte_attrs, .none);
            attrs_owned = byte_attrs;
            break :blk byte_attrs;
        };
        if (mutable.len != paint_content.len) return -1;
        const tab_u16: u16 = if (tab <= 0) 1 else @intCast(tab);
        applySquareMarkInverse(mutable, paint_content, tab_u16, from, to);
        native_attrs = mutable;
    }

    // Paint text: content (+ trailing \n for visiblews rtn).
    var paint_line_buf: std.ArrayList(u8) = .empty;
    defer paint_line_buf.deinit(alloc);
    var paint_line: []const u8 = paint_content;
    if (saw_eol and visiblews != 0) {
        paint_line_buf.appendSlice(alloc, paint_content) catch return -1;
        paint_line_buf.append(alloc, '\n') catch return -1;
        paint_line = paint_line_buf.items;
    } else if (ansi != 0) {
        paint_line = paint_content;
    } else {
        paint_line = line;
    }

    const base_attr = terminal.attributeFromHybrid(defatr, pal);

    var vws_storage: VisibleWs = undefined;
    var vws_ptr: ?*const VisibleWs = null;
    if (visiblews != 0) {
        const style = terminal.attributeFromHybrid(vwsatr, pal);
        vws_storage = .{
            .space = if (vspace > 0) @intCast(vspace) else 0xb7,
            .tab = if (vtab > 0) @intCast(vtab) else 0x2192,
            .rtn = if (vrtn > 0) @intCast(vrtn) else 0x21b5,
            .style = .{ .dim = style.dim, .fg = style.fg },
            .clear_fg = true,
        };
        vws_ptr = &vws_storage;
    }

    var scratch = terminal.Screen.init(alloc, win_w, 1) catch return -1;
    defer scratch.deinit();

    const tab_u: u16 = if (tab <= 0) 8 else @intCast(@min(tab, 256));
    const opts: render.Options = .{
        .tab = tab_u,
        .offset = if (scr_offset < 0) 0 else @intCast(scr_offset),
        .attrs = native_attrs,
        .view = view_ptr,
        .visible_ws = vws_ptr,
    };
    _ = render.lgenLine(&scratch, 0, 0, win_w, paint_line, opts, base_attr);

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

    var current_url: ?[]const u8 = null;
    var cx: u16 = 0;
    while (cx < win_w) : (cx += 1) {
        const cell = scratch.cells[cx];
        // Wide-continuation cells (cp==0) are filled by `outatr_complete`.
        if (cell.cp == 0) continue;

        if (preparsed) current_url = emitOsc8Link(current_url, cell.url);

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
    if (preparsed) _ = emitOsc8Link(current_url, null);
    outatr_complete(t);

    // Advance caller's P to next line (JOE lgen contract).
    _ = pnextl(p);

    const done = eraeol(t, x1, y, defatr);
    return done;
}

fn attributeToHybridOrDef(attr: Attribute, palette: *TruecolorPalette, defatr: c_int) c_int {
    return terminal.attributeToHybrid(attr, palette) catch defatr;
}

/// JOE `out_osc8_link` shaped — content equality (C uses pointer equality on shared URLs).
fn emitOsc8Link(old: ?[]const u8, new_url: ?[]const u8) ?[]const u8 {
    const same = blk: {
        if (old == null and new_url == null) break :blk true;
        if (old == null or new_url == null) break :blk false;
        break :blk std.mem.eql(u8, old.?, new_url.?);
    };
    if (same) return old;

    if (old != null) ttputs("\x1b]8;;\x1b\\");
    if (new_url) |url| {
        ttputs("\x1b]8;;");
        var buf: [256]u8 = undefined;
        var n: usize = 0;
        for (url) |ch| {
            if (ch < 0x20 or ch == 0x7F or (ch >= 0x80 and ch <= 0x9F)) continue;
            if (n + 1 >= buf.len) {
                buf[n] = 0;
                ttputs(@ptrCast(&buf));
                n = 0;
            }
            buf[n] = ch;
            n += 1;
        }
        if (n > 0) {
            buf[n] = 0;
            ttputs(@ptrCast(&buf));
        }
        ttputs("\x1b\\");
    }
    return new_url;
}

const AnsiStripResult = struct {
    text: []u8,
    attrs: ?[]Attribute,
    hide: ?[]u8,
    subst: ?[]u21,
    links: ?[]?[]const u8,
};

/// Remove JOE `ansi_decode` hidden spans (from ESC through terminating ASCII letter).
/// Compacts optional parallel slices in lockstep (must be null or `src.len`).
fn stripAnsiEscapes(
    alloc: std.mem.Allocator,
    src: []const u8,
    attrs: ?[]const Attribute,
    hide: ?[]const u8,
    subst: ?[]const u21,
    links: ?[]const ?[]const u8,
) !AnsiStripResult {
    if (attrs) |a| std.debug.assert(a.len == src.len);
    if (hide) |h| std.debug.assert(h.len == src.len);
    if (subst) |s| std.debug.assert(s.len == src.len);
    if (links) |l| std.debug.assert(l.len == src.len);

    var text: std.ArrayList(u8) = .empty;
    errdefer text.deinit(alloc);
    var out_attrs: std.ArrayList(Attribute) = .empty;
    errdefer out_attrs.deinit(alloc);
    var out_hide: std.ArrayList(u8) = .empty;
    errdefer out_hide.deinit(alloc);
    var out_subst: std.ArrayList(u21) = .empty;
    errdefer out_subst.deinit(alloc);
    var out_links: std.ArrayList(?[]const u8) = .empty;
    errdefer out_links.deinit(alloc);

    var in_esc = false;
    var i: usize = 0;
    while (i < src.len) {
        const b = src[i];
        var nbytes: usize = 1;
        var cp: u21 = b;
        if (b >= 0x80) {
            nbytes = utf8SeqLen(b);
            if (i + nbytes <= src.len) {
                if (std.unicode.utf8Decode(src[i..][0..nbytes])) |decoded| {
                    cp = decoded;
                } else |_| {
                    nbytes = 1;
                    cp = b;
                }
            } else {
                nbytes = 1;
                cp = b;
            }
        }
        const end = i + nbytes;

        var hidden = false;
        if (in_esc) {
            hidden = true;
            if ((cp >= 'a' and cp <= 'z') or (cp >= 'A' and cp <= 'Z')) in_esc = false;
        } else if (cp == 0x1b) {
            hidden = true;
            in_esc = true;
        }

        if (!hidden) {
            try text.appendSlice(alloc, src[i..end]);
            if (attrs) |aa| {
                var k = i;
                while (k < end) : (k += 1) try out_attrs.append(alloc, aa[k]);
            }
            if (hide) |hh| {
                var k = i;
                while (k < end) : (k += 1) try out_hide.append(alloc, hh[k]);
            }
            if (subst) |ss| {
                var k = i;
                while (k < end) : (k += 1) try out_subst.append(alloc, ss[k]);
            }
            if (links) |ll| {
                var k = i;
                while (k < end) : (k += 1) try out_links.append(alloc, ll[k]);
            }
        }
        i = end;
    }

    return .{
        .text = try text.toOwnedSlice(alloc),
        .attrs = if (attrs != null) try out_attrs.toOwnedSlice(alloc) else null,
        .hide = if (hide != null) try out_hide.toOwnedSlice(alloc) else null,
        .subst = if (subst != null) try out_subst.toOwnedSlice(alloc) else null,
        .links = if (links != null) try out_links.toOwnedSlice(alloc) else null,
    };
}

/// Force inverse on bytes whose absolute buffer offset is in `[from, to)`.
fn applyLinearMarkInverse(attrs: []Attribute, line_byte: i64, from: i64, to: i64) void {
    if (from == to) return;
    for (attrs, 0..) |*a, i| {
        const b = line_byte + @as(i64, @intCast(i));
        if (b >= from and b < to) a.inverse = true;
    }
}

/// Display width matching `lgen` / JOE C0→caret (width 1) + `displayWidth`.
fn squareUnitWidth(cp: u21) u8 {
    if (cp < 32 or cp == 127) return 1;
    return terminal.displayWidth(cp);
}

/// Force inverse for square marks: `from`/`to` are display columns (`xcol`).
/// JOE `SELECT_IF`: tab uses end-col `tcol > from && tcol <= to` (whole run);
/// other units use start-col `col >= from && col < to`.
fn applySquareMarkInverse(attrs: []Attribute, line: []const u8, tab: u16, from: i64, to: i64) void {
    if (from == to) return;
    const t: i64 = if (tab == 0) 1 else tab;
    var col: i64 = 0;
    var i: usize = 0;
    while (i < line.len and i < attrs.len) {
        const b = line[i];
        if (b == '\n' or b == '\r') break;
        if (b == '\t') {
            const tcol = col + t - @rem(col, t);
            if (tcol > from and tcol <= to) attrs[i].inverse = true;
            col = tcol;
            i += 1;
            continue;
        }
        const seq_len = utf8SeqLen(b);
        const end = @min(i + seq_len, @min(line.len, attrs.len));
        var wid: u8 = 1;
        if (seq_len >= 1 and i + seq_len <= line.len) {
            if (std.unicode.utf8Decode(line[i..][0..seq_len])) |cp| {
                wid = squareUnitWidth(cp);
            } else |_| {
                wid = 1;
            }
        }
        if (col >= from and col < to) {
            var k = i;
            while (k < end) : (k += 1) attrs[k].inverse = true;
        }
        col += wid;
        i = if (i + seq_len > line.len) line.len else i + seq_len;
    }
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

test "applyLinearMarkInverse marks ASCII byte range" {
    var attrs = [_]Attribute{ .{ .bold = true }, .{ .bold = true }, .{ .bold = true }, .{ .bold = true }, .{ .bold = true } };
    applyLinearMarkInverse(&attrs, 10, 11, 14);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(attrs[1].inverse);
    try std.testing.expect(attrs[2].inverse);
    try std.testing.expect(attrs[3].inverse);
    try std.testing.expect(!attrs[4].inverse);
    try std.testing.expect(attrs[1].bold);
}

test "applyLinearMarkInverse covers UTF-8 continuation bytes" {
    var attrs = [_]Attribute{.{}} ** 4;
    applyLinearMarkInverse(&attrs, 100, 101, 103);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(attrs[1].inverse);
    try std.testing.expect(attrs[2].inverse);
    try std.testing.expect(!attrs[3].inverse);
}

test "applyLinearMarkInverse no-op when from==to" {
    var attrs = [_]Attribute{.{ .underline = true }} ** 3;
    applyLinearMarkInverse(&attrs, 0, 5, 5);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(!attrs[1].inverse);
    try std.testing.expect(!attrs[2].inverse);
}

test "applySquareMarkInverse tab uses end-col inclusive" {
    var attrs = [_]Attribute{.{}} ** 4;
    // "ab\tc" tab=4 → a@0 b@1 tab→4 c@4; from=1 to=4 selects b + tab
    applySquareMarkInverse(&attrs, "ab\tc", 4, 1, 4);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(attrs[1].inverse);
    try std.testing.expect(attrs[2].inverse);
    try std.testing.expect(!attrs[3].inverse);
}

test "applySquareMarkInverse tab excluded when end past to" {
    var attrs = [_]Attribute{.{}} ** 3;
    // "\tX" tab=8, from=2 to=5: tcol=8 not in (2,5] → unselected
    applySquareMarkInverse(&attrs, "\tX", 8, 2, 5);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(!attrs[1].inverse);
}

test "applySquareMarkInverse covers UTF-8 start column" {
    const line = "a\u{00e9}b";
    var attrs = [_]Attribute{.{}} ** 4;
    applySquareMarkInverse(&attrs, line, 8, 1, 2);
    try std.testing.expect(!attrs[0].inverse);
    try std.testing.expect(attrs[1].inverse);
    try std.testing.expect(attrs[2].inverse);
    try std.testing.expect(!attrs[3].inverse);
}

test "stripAnsiEscapes removes CSI color sequences" {
    const src = "a\x1b[31mB\x1b[0mC";
    const stripped = try stripAnsiEscapes(std.testing.allocator, src, null, null, null, null);
    defer std.testing.allocator.free(stripped.text);
    try std.testing.expectEqualStrings("aBC", stripped.text);
}

test "stripAnsiEscapes compacts attrs with escapes" {
    const src = "a\x1b[1mB";
    var attrs = [_]Attribute{ .{ .bold = true }, .{}, .{}, .{}, .{ .underline = true }, .{ .italic = true } };
    try std.testing.expectEqual(src.len, attrs.len);
    const stripped = try stripAnsiEscapes(std.testing.allocator, src, &attrs, null, null, null);
    defer std.testing.allocator.free(stripped.text);
    defer std.testing.allocator.free(stripped.attrs.?);
    try std.testing.expectEqualStrings("aB", stripped.text);
    try std.testing.expect(stripped.attrs.?[0].bold);
    try std.testing.expect(stripped.attrs.?[1].italic);
}

test "emitOsc8Link no-op when unchanged" {
    const u = "http://example.com";
    try std.testing.expectEqual(@as(?[]const u8, u), emitOsc8Link(u, u));
}
