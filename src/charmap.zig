//! Character maps — replaces `joe/charmap.c`.
//!
//! Locale/encoding maps, Unicode↔byte conversion, charset guessing,
//! and `my_iconv` conversion between maps. Builtin tables live in
//! `charmap_data.zig` (generated from the original C tables).

const data = @import("charmap_data.zig");
const types = @import("gapbuffer/types.zig");

// ═══════════════════════════════════════════════════════════════════════
// External symbols
// ═══════════════════════════════════════════════════════════════════════

extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn jsort(base: ?*anyopaque, num: isize, size: isize, compar: ?*const anyopaque) void;
extern fn zdup(bf: [*c]const u8) [*c]u8;
extern fn zicmp(a: [*c]const u8, b: [*c]const u8) c_int;
extern fn zhtoi(s: [*c]const u8) c_int;
extern fn zlcpy(a: [*c]u8, len: isize, b: [*c]const u8) [*c]u8;
extern fn Ztoutf8(a: [*c]u8, len: isize, b: [*c]const c_int) [*c]u8;
extern fn parse_ws(pp: [*c][*c]const u8, cmt: c_int) c_int;
extern fn parse_tows(pp: [*c][*c]const u8, buf: [*c]u8) c_int;
extern fn vsrm(vary: [*c]u8) void;
extern fn vsncpy(vary: [*c]u8, pos: isize, array: [*c]const u8, len: isize) [*c]u8;
extern fn vaadd(vary: ?*anyopaque, el: ?*anyopaque) ?*anyopaque;
extern fn utf8_encode(buf: [*c]u8, c: c_int) isize;
extern fn utf8_decode_string(s: [*c]const u8) c_int;
extern fn utf8_decode_fwrd(s: [*c][*c]const u8, len: ?*isize) c_int;

extern fn joe_iswpunct(map: ?*Charmap, c: c_int) c_int;
extern fn joe_iswprint(map: ?*Charmap, c: c_int) c_int;
extern fn joe_iswspace(map: ?*Charmap, c: c_int) c_int;
extern fn joe_iswalpha_(map: ?*Charmap, c: c_int) c_int;
extern fn joe_iswalnum_(map: ?*Charmap, c: c_int) c_int;
extern fn joe_iswalpha(map: ?*Charmap, c: c_int) c_int;
extern fn joe_towlower(map: ?*Charmap, c: c_int) c_int;
extern fn joe_towupper(map: ?*Charmap, c: c_int) c_int;

extern fn jfgets(buf: [*c]u8, len: c_int, f: ?*anyopaque) ?*anyopaque;
extern fn jfclose(f: ?*anyopaque) c_int;
extern fn open_config_file(result: [*c]?*anyopaque, prefix: [*c]const u8, name: [*c]const u8, suffix: [*c]const u8) [*c]u8;
extern fn find_configs(encodings: ?*anyopaque, dir: [*c]const u8, suffix: ?*const anyopaque) ?*anyopaque;
extern fn init_gettext(s: [*c]const u8) void;

extern var fdefault: types.OPTIONS;
extern var pdefault: types.OPTIONS;

extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
extern fn strrchr(s: [*c]const u8, c: c_int) [*c]u8;
extern fn getenv(name: [*c]const u8) [*c]u8;
extern fn setlocale(category: c_int, locale: [*c]const u8) [*c]u8;
extern fn nl_langinfo(item: c_int) [*c]u8;

const LC_ALL: c_int = 0;
const CODESET: c_int = 0;

// ═══════════════════════════════════════════════════════════════════════
// Struct layouts (must match joe/charmap.h)
// ═══════════════════════════════════════════════════════════════════════

const Pair = extern struct {
    first: c_int,
    last: c_int,
};

comptime {
    if (@sizeOf(Pair) != 8) @compileError("pair size mismatch");
}

const PredFn = *const fn (?*Charmap, c_int) callconv(.c) c_int;

const Charmap = extern struct {
    next: ?*Charmap,
    name: ?[*:0]const u8,
    @"type": c_int, // 0=byte, 1=UTF-8
    is_punct: ?PredFn,
    is_print: ?PredFn,
    is_space: ?PredFn,
    is_alpha_: ?PredFn,
    is_alnum_: ?PredFn,
    to_lower: ?PredFn,
    to_upper: ?PredFn,
    to_map: ?[*]const c_int,
    lower_map: [256]u8,
    upper_map: [256]u8,
    from_map: [256]Pair,
    from_size: isize,
    print_map: [32]u8,
    alpha__map: [32]u8,
    alnum__map: [32]u8,
};

comptime {
    if (@sizeOf(Charmap) != 2752) @compileError("charmap size mismatch");
}

const BuiltinCharmap = extern struct {
    name: ?[*:0]const u8,
    to_uni: [256]c_int,
};

// ═══════════════════════════════════════════════════════════════════════
// Globals (C ABI)
// ═══════════════════════════════════════════════════════════════════════

var charmaps: ?*Charmap = null;

export var utf8_map: ?*Charmap = null;
export var utf16_map: ?*Charmap = null;
export var utf16r_map: ?*Charmap = null;
export var ascii_map: ?*Charmap = null;
export var locale_map: ?*Charmap = null;
export var locale_map_non_utf8: ?*Charmap = null;

export var locale_lang: ?[*:0]const u8 = null;
export var locale_msgs: ?[*:0]const u8 = null;

export var codeset: ?[*:0]const u8 = null;
export var non_utf8_codeset: ?[*:0]const u8 = null;

export var guess_non_utf8: c_int = 0;
export var guess_utf8: c_int = 0;

// ═══════════════════════════════════════════════════════════════════════
// Conversion helpers
// ═══════════════════════════════════════════════════════════════════════

export fn to_uni(cset: ?*Charmap, c_in: c_int) c_int {
    const map = cset orelse return -1;
    var c = c_in;
    if (c < 0) c += 256;
    const to_map = map.to_map orelse return -1;
    return to_map[@intCast(c)];
}

export fn to_utf8(map: ?*Charmap, s: [*c]u8, c: c_int) void {
    const d = to_uni(map, c);
    if (d == -1) {
        _ = utf8_encode(s, '?');
    } else {
        _ = utf8_encode(s, d);
    }
}

export fn from_uni(cset: ?*Charmap, c_in: c_int) c_int {
    const map = cset orelse return -1;
    var c = c_in;
    if (c < 0) c += 256;

    var x: isize = 0;
    var y: isize = map.from_size;
    var z: isize = -1;
    while (z != @divTrunc(x + y, 2)) {
        z = @divTrunc(x + y, 2);
        if (c > map.from_map[@intCast(z)].first) {
            x = z;
        } else if (c < map.from_map[@intCast(z)].first) {
            y = z;
        } else {
            return map.from_map[@intCast(z)].last;
        }
    }
    return -1;
}

export fn from_utf8(map: ?*Charmap, s: [*c]const u8) c_int {
    const d = utf8_decode_string(s);
    const c = from_uni(map, d);
    if (c == -1) return '?';
    return c;
}

// ═══════════════════════════════════════════════════════════════════════
// Byte-map predicates / converters
// ═══════════════════════════════════════════════════════════════════════

fn pairCmp(a: ?*const anyopaque, b: ?*const anyopaque) callconv(.c) c_int {
    const pa = @as(*const Pair, @alignCast(@ptrCast(a.?)));
    const pb = @as(*const Pair, @alignCast(@ptrCast(b.?)));
    if (pa.first > pb.first) return 1;
    if (pa.first < pb.first) return -1;
    return 0;
}

fn byteIspunct(map: ?*Charmap, c_in: c_int) callconv(.c) c_int {
    const m = map orelse return 0;
    var c = c_in;
    if (c < 0) c += 256;
    if (c < 0 or c > 255) return 0;
    const ofst: usize = @intCast(c >> 3);
    const bitn: u8 = @as(u8, 1) << @intCast(c & 7);
    if ((m.print_map[ofst] & bitn) != 0 and (m.alnum__map[ofst] & bitn) == 0) return 1;
    return 0;
}

fn byteIsprint(map: ?*Charmap, c_in: c_int) callconv(.c) c_int {
    const m = map orelse return 0;
    var c = c_in;
    if (c < 0) c += 256;
    if (c < 0 or c > 255) return 0;
    const ofst: usize = @intCast(c >> 3);
    const bitn: u8 = @as(u8, 1) << @intCast(c & 7);
    if ((m.print_map[ofst] & bitn) != 0) return 1;
    return 0;
}

fn byteIsspace(map: ?*Charmap, c: c_int) callconv(.c) c_int {
    _ = map;
    if (c == 32 or (c >= 9 and c <= 13)) return 1;
    return 0;
}

fn byteIsalpha_(map: ?*Charmap, c_in: c_int) callconv(.c) c_int {
    const m = map orelse return 0;
    var c = c_in;
    if (c < 0) c += 256;
    if (c < 0 or c > 255) return 0;
    const ofst: usize = @intCast(c >> 3);
    const bitn: u8 = @as(u8, 1) << @intCast(c & 7);
    if ((m.alpha__map[ofst] & bitn) != 0) return 1;
    return 0;
}

fn byteIsalnum_(map: ?*Charmap, c_in: c_int) callconv(.c) c_int {
    const m = map orelse return 0;
    var c = c_in;
    if (c < 0) c += 256;
    if (c < 0 or c > 255) return 0;
    const ofst: usize = @intCast(c >> 3);
    const bitn: u8 = @as(u8, 1) << @intCast(c & 7);
    if ((m.alnum__map[ofst] & bitn) != 0) return 1;
    return 0;
}

fn byteTolower(map: ?*Charmap, c_in: c_int) callconv(.c) c_int {
    const m = map orelse return c_in;
    var c = c_in;
    if (c < 0 and c >= -128) c += 256;
    if (c < 0 or c > 255) return c;
    return m.lower_map[@intCast(c)];
}

fn byteToupper(map: ?*Charmap, c_in: c_int) callconv(.c) c_int {
    const m = map orelse return c_in;
    var c = c_in;
    if (c < 0 and c >= -128) c += 256;
    if (c < 0 or c > 255) return c;
    return m.upper_map[@intCast(c)];
}

fn setBit(map: *[32]u8, n: c_int) void {
    map[@intCast(n >> 3)] |= @as(u8, 1) << @intCast(n & 7);
}

fn processBuiltinNamed(name: [*:0]const u8, to_table: *const [256]c_int) ?*Charmap {
    const map = @as(*Charmap, @alignCast(@ptrCast(joe_malloc(@sizeOf(Charmap)) orelse return null)));
    @memset(@as([*]u8, @ptrCast(map))[0..@sizeOf(Charmap)], 0);

    map.name = @ptrCast(zdup(name));
    map.@"type" = 0;
    map.is_punct = byteIspunct;
    map.is_print = byteIsprint;
    map.is_space = byteIsspace;
    map.is_alpha_ = byteIsalpha_;
    map.is_alnum_ = byteIsalnum_;
    map.to_lower = byteTolower;
    map.to_upper = byteToupper;
    map.from_size = 0;
    map.to_map = to_table;

    var x: c_int = 0;
    while (x != 256) : (x += 1) {
        if (map.to_map.?[@intCast(x)] != -1) {
            map.from_map[@intCast(map.from_size)].first = map.to_map.?[@intCast(x)];
            map.from_map[@intCast(map.from_size)].last = x;
            map.from_size += 1;
        }
    }

    jsort(@ptrCast(&map.from_map), map.from_size, @sizeOf(Pair), @ptrCast(&pairCmp));

    @memset(&map.print_map, 0);
    @memset(&map.alpha__map, 0);
    @memset(&map.alnum__map, 0);

    x = 0;
    while (x != 256) : (x += 1) {
        const u = map.to_map.?[@intCast(x)];
        if (u != -1) {
            if (joe_iswprint(null, u) != 0) setBit(&map.print_map, x);
            if (joe_iswalpha(null, u) != 0) {
                setBit(&map.alpha__map, x);
                setBit(&map.alnum__map, x);
            }
        }
    }

    const us = from_uni(map, 0x5F);
    if (us != -1) {
        setBit(&map.alpha__map, us);
        setBit(&map.alnum__map, us);
    }

    x = 0x30;
    while (x != 0x3A) : (x += 1) {
        const y = from_uni(map, x);
        if (y != -1) setBit(&map.alnum__map, y);
    }

    x = 0;
    while (x != 256) : (x += 1) {
        map.lower_map[@intCast(x)] = @intCast(x);
        if (map.to_map.?[@intCast(x)] != -1) {
            const y = joe_towlower(null, map.to_map.?[@intCast(x)]);
            const z = from_uni(map, y);
            if (z != -1) map.lower_map[@intCast(x)] = @intCast(z);
        }
    }

    x = 0;
    while (x != 256) : (x += 1) {
        map.upper_map[@intCast(x)] = @intCast(x);
        if (map.to_map.?[@intCast(x)] != -1) {
            const y = joe_towupper(null, map.to_map.?[@intCast(x)]);
            const z = from_uni(map, y);
            if (z != -1) map.upper_map[@intCast(x)] = @intCast(z);
        }
    }

    map.next = charmaps;
    charmaps = map;
    return map;
}

fn processBuiltin(builtin: *const BuiltinCharmap) ?*Charmap {
    return processBuiltinNamed(builtin.name.?, &builtin.to_uni);
}

fn processBuiltinData(builtin: *const data.BuiltinCharmap) ?*Charmap {
    return processBuiltinNamed(builtin.name.ptr, &builtin.to_uni);
}

fn loadBuiltins() void {
    {
        const map = @as(*Charmap, @alignCast(@ptrCast(joe_malloc(@sizeOf(Charmap)) orelse return)));
        @memset(@as([*]u8, @ptrCast(map))[0..@sizeOf(Charmap)], 0);
        map.name = "utf-8";
        map.@"type" = 1;
        map.is_punct = joe_iswpunct;
        map.is_print = joe_iswprint;
        map.is_space = joe_iswspace;
        map.is_alpha_ = joe_iswalpha_;
        map.is_alnum_ = joe_iswalnum_;
        map.to_lower = joe_towlower;
        map.to_upper = joe_towupper;
        map.next = charmaps;
        charmaps = map;
        utf8_map = map;
    }
    {
        const map = @as(*Charmap, @alignCast(@ptrCast(joe_malloc(@sizeOf(Charmap)) orelse return)));
        @memset(@as([*]u8, @ptrCast(map))[0..@sizeOf(Charmap)], 0);
        map.name = "utf-16";
        map.@"type" = 1;
        map.is_punct = joe_iswpunct;
        map.is_print = joe_iswprint;
        map.is_space = joe_iswspace;
        map.is_alpha_ = joe_iswalpha_;
        map.is_alnum_ = joe_iswalnum_;
        map.to_lower = joe_towlower;
        map.to_upper = joe_towupper;
        map.next = charmaps;
        charmaps = map;
        utf16_map = map;
    }
    {
        const map = @as(*Charmap, @alignCast(@ptrCast(joe_malloc(@sizeOf(Charmap)) orelse return)));
        @memset(@as([*]u8, @ptrCast(map))[0..@sizeOf(Charmap)], 0);
        map.name = "utf-16r";
        map.@"type" = 1;
        map.is_punct = joe_iswpunct;
        map.is_print = joe_iswprint;
        map.is_space = joe_iswspace;
        map.is_alpha_ = joe_iswalpha_;
        map.is_alnum_ = joe_iswalnum_;
        map.to_lower = joe_towlower;
        map.to_upper = joe_towupper;
        map.next = charmaps;
        charmaps = map;
        utf16r_map = map;
    }
}

fn parseCharmap(name: [*c]const u8, f: ?*anyopaque) ?*BuiltinCharmap {
    if (f == null) return null;

    const b = @as(*BuiltinCharmap, @alignCast(@ptrCast(joe_malloc(@sizeOf(BuiltinCharmap)) orelse return null)));
    b.name = @ptrCast(zdup(name));
    var x: usize = 0;
    while (x != 256) : (x += 1) b.to_uni[x] = -1;

    var buf: [1024]u8 = undefined;
    var bf1: [1024]u8 = undefined;
    var comment_char: c_int = '#';
    var in_map: c_int = 0;

    while (jfgets(&buf, @sizeOf(@TypeOf(buf)), f) != null) {
        var p: [*c]const u8 = &buf;
        _ = parse_ws(&p, comment_char);
        _ = parse_tows(&p, &bf1);
        if (strcmp(&bf1, "<comment_char>") == 0) {
            _ = parse_ws(&p, comment_char);
            _ = parse_tows(&p, &bf1);
            comment_char = bf1[0];
        } else if (strcmp(&bf1, "<escape_char>") == 0) {
            _ = parse_ws(&p, comment_char);
            _ = parse_tows(&p, &bf1);
        } else if (strcmp(&bf1, "CHARMAP") == 0) {
            in_map = 1;
        } else if (strcmp(&bf1, "END") == 0) {
            in_map = 0;
        } else if (in_map != 0 and bf1[0] == '<' and bf1[1] == 'U') {
            const uni = zhtoi(@ptrCast(bf1[2..].ptr));
            _ = parse_ws(&p, comment_char);
            _ = parse_tows(&p, &bf1);
            const byt = zhtoi(@ptrCast(bf1[2..].ptr));
            if (byt >= 0 and byt < 256) b.to_uni[@intCast(byt)] = uni;
        }
    }

    _ = jfclose(f);
    return b;
}

fn mapUp(c: u8) u8 {
    if (c >= 'a' and c <= 'z') return c - 32;
    return c;
}

fn mapNameCmp(a_in: [*c]const u8, b_in: [*c]const u8) c_int {
    var a = a_in;
    var b = b_in;
    while (a[0] == '-') a += 1;
    while (b[0] == '-') b += 1;
    while (a[0] != 0 and b[0] != 0 and mapUp(a[0]) == mapUp(b[0])) {
        a += 1;
        b += 1;
        while (a[0] == '-') a += 1;
        while (b[0] == '-') b += 1;
    }
    if (a[0] == 0 and (b[0] == '.' or b[0] == 0)) return 0;
    return 1;
}

export fn find_charmap(name_in: ?[*:0]const u8) ?*Charmap {
    const name0 = name_in orelse return null;
    if (name0[0] == 0) return null;

    var name: [*c]const u8 = name0;

    if (charmaps == null) loadBuiltins();

    for (data.alias_table) |alias| {
        if (mapNameCmp(alias.alias.ptr, name) == 0) {
            name = alias.builtin.ptr;
            break;
        }
    }

    var m = charmaps;
    while (m) |cur| : (m = cur.next) {
        if (mapNameCmp(cur.name.?, name) == 0) return cur;
    }

    var f: ?*anyopaque = null;
    const fullpath = open_config_file(&f, "charmaps/", name, "");
    vsrm(fullpath);

    if (f) |ff| {
        if (parseCharmap(name, ff)) |b| {
            return processBuiltin(b);
        }
    }

    for (&data.builtin_charmaps) |*builtin| {
        if (mapNameCmp(builtin.name.ptr, name) == 0) {
            return processBuiltinData(builtin);
        }
    }

    return null;
}

export fn get_encodings() ?*anyopaque {
    var encodings: ?*anyopaque = null;

    const add = struct {
        fn go(list: ?*anyopaque, s: [:0]const u8) ?*anyopaque {
            const r = vsncpy(null, 0, s.ptr, @intCast(s.len));
            return vaadd(list, r);
        }
    }.go;

    encodings = add(encodings, "utf-8");
    encodings = add(encodings, "utf-16");
    encodings = add(encodings, "utf-16r");

    for (data.builtin_charmaps) |builtin| {
        encodings = add(encodings, builtin.name);
    }
    for (data.alias_table) |alias| {
        encodings = add(encodings, alias.alias);
    }

    return find_configs(encodings, "charmaps", null);
}

export fn joe_isblank(map: ?*Charmap, c: c_int) c_int {
    _ = map;
    if (c == 32 or c == 9) return 1;
    return 0;
}

export fn joe_isspace_eos(map: ?*Charmap, c: c_int) c_int {
    _ = map;
    if (c == 0 or c == 32 or (c >= 9 and c <= 13)) return 1;
    return 0;
}

export fn joe_locale() void {
    var sc: [*c]u8 = getenv("LC_ALL");
    if (sc == null or sc[0] == 0) {
        sc = getenv("LC_MESSAGES");
        if (sc == null or sc[0] == 0) {
            sc = getenv("LANG");
        }
    }
    if (sc == null) sc = @constCast(@as([*:0]const u8, "C"));

    var s = zdup(sc);
    if (strrchr(s, '.')) |t| t[0] = 0;

    if (zicmp(s, "C") == 0 or zicmp(s, "POSIX") == 0) {
        locale_msgs = "en_US";
    } else {
        locale_msgs = @ptrCast(s);
    }

    sc = getenv("LC_ALL");
    if (sc == null or sc[0] == 0) {
        sc = getenv("LC_CTYPE");
        if (sc == null or sc[0] == 0) {
            sc = getenv("LANG");
        }
    }
    if (sc == null) sc = @constCast(@as([*:0]const u8, "C"));

    s = zdup(sc);

    const lang = zdup(s);
    if (strrchr(lang, '.')) |t| t[0] = 0;
    locale_lang = @ptrCast(lang);

    _ = setlocale(LC_ALL, lang);
    non_utf8_codeset = @ptrCast(zdup(nl_langinfo(CODESET)));

    _ = setlocale(LC_ALL, "");
    codeset = @ptrCast(zdup(nl_langinfo(CODESET)));

    ascii_map = find_charmap("ascii");
    locale_map = find_charmap(codeset);
    if (locale_map == null) locale_map = ascii_map;

    locale_map_non_utf8 = find_charmap(non_utf8_codeset);
    if (locale_map_non_utf8 == null) locale_map_non_utf8 = ascii_map;

    fdefault.charmap = @ptrCast(locale_map);
    pdefault.charmap = @ptrCast(locale_map);

    init_gettext(@ptrCast(locale_msgs));
}

fn toCharOk(d: c_int) u8 {
    return @truncate(@as(u32, @bitCast(d)));
}

export fn my_iconv(dest_in: [*c]u8, destsiz_in: isize, dest_map: ?*Charmap, src_in: [*c]const u8, src_map: ?*Charmap) void {
    const dm = dest_map orelse return;
    const sm = src_map orelse return;
    var dest = dest_in;
    var destsiz = destsiz_in;
    var src = src_in;

    if (dm == sm) {
        _ = zlcpy(dest, destsiz, src);
        return;
    }

    if (sm.@"type" != 0) {
        if (dm.@"type" != 0) {
            _ = zlcpy(dest, destsiz, src);
        } else {
            destsiz -= 1;
            while (src[0] != 0 and destsiz != 0) {
                var len: isize = -1;
                const c = utf8_decode_fwrd(&src, &len);
                if (c >= 0) {
                    const d = from_uni(dm, c);
                    dest[0] = if (d >= 0) toCharOk(d) else '?';
                    dest += 1;
                } else {
                    dest[0] = 'X';
                    dest += 1;
                }
                destsiz -= 1;
            }
            dest[0] = 0;
        }
    } else {
        if (dm.@"type" == 0) {
            destsiz -= 1;
            while (src[0] != 0 and destsiz != 0) {
                const c = to_uni(sm, src[0]);
                src += 1;
                if (c >= 0) {
                    const d = from_uni(dm, c);
                    dest[0] = if (d >= 0) toCharOk(d) else '?';
                } else {
                    dest[0] = '?';
                }
                dest += 1;
                destsiz -= 1;
            }
            dest[0] = 0;
        } else {
            destsiz -= 1;
            while (src[0] != 0 and destsiz >= 6) {
                const c = to_uni(sm, src[0]);
                src += 1;
                if (c >= 0) {
                    const l = utf8_encode(dest, c);
                    destsiz -= l;
                    dest += @intCast(l);
                } else {
                    dest[0] = '?';
                    dest += 1;
                    destsiz -= 1;
                }
            }
            dest[0] = 0;
        }
    }
}

export fn my_iconv1(dest_in: [*c]u8, destsiz_in: isize, dest_map: ?*Charmap, src: [*c]const c_int) void {
    const dm = dest_map orelse return;
    var dest = dest_in;
    var destsiz = destsiz_in;
    var p = src;

    if (dm.@"type" != 0) {
        _ = Ztoutf8(dest, destsiz, p);
    } else {
        destsiz -= 1;
        while (p[0] != 0 and destsiz != 0) {
            const d = from_uni(dm, p[0]);
            p += 1;
            dest[0] = if (d >= 0) toCharOk(d) else '?';
            dest += 1;
            destsiz -= 1;
        }
        dest[0] = 0;
    }
}

export fn guess_map(buf: [*c]const u8, len: isize) ?*Charmap {
    if (len == 0 or (guess_non_utf8 == 0 and guess_utf8 == 0))
        return locale_map;

    var p: [*c]const u8 = buf;
    var plen = len;
    var c: c_int = 0;
    var flag: c_int = 0;

    while (plen != 0) {
        if (plen < 7) break;
        if (@as(i8, @bitCast(p[0])) < 0) flag = 1;
        c = utf8_decode_fwrd(&p, &plen);
        if (c < 0) break;
    }

    if (flag != 0 and c >= 0) {
        const lm = locale_map orelse return utf8_map;
        if (lm.@"type" != 0 or guess_utf8 == 0) return locale_map;
        return utf8_map;
    }

    if (flag == 0 or guess_non_utf8 == 0) {
        return locale_map;
    } else {
        return locale_map_non_utf8;
    }
}