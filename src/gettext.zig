//! Path A live port of JOE gettext (`joe/gettext.c`).
//!
//! JOE `gettext.h` ABI lives here (`my_gettext`, `init_gettext`).
//! JOE uses **`.po` text catalogs** under `lang/` (installed from `po/`),
//! not GNU binary `.mo` files — see `po/HOWTO`. Phase 8 i18n = `.po` parity.

extern fn htmk(len: isize) ?*anyopaque;
extern fn htadd(ht: ?*anyopaque, name: ?*anyopaque, val: ?*anyopaque) ?*anyopaque;
extern fn htfind(ht: ?*anyopaque, name: [*c]const u8) ?*anyopaque;
extern fn atom_add(name: [*c]const u8) [*c]const u8;
extern fn parse_ws(pp: [*c][*c]const u8, cmt: c_int) c_int;
extern fn parse_field(pp: [*c][*c]const u8, kw: [*c]const u8) c_int;
extern fn parse_string(pp: [*c][*c]const u8, buf: [*c]u8, len: isize) isize;
extern fn my_iconv(dest: [*c]u8, destsiz: isize, dest_map: ?*anyopaque, src: [*c]const u8, src_map: ?*anyopaque) void;
extern fn find_charmap(name: [*c]const u8) ?*anyopaque;
extern fn open_config_file(result: [*c]?*anyopaque, prefix: [*c]const u8, name: [*c]const u8, suffix: [*c]const u8) [*c]u8;
extern fn jfgets(buf: [*c]u8, len: c_int, f: ?*anyopaque) ?*anyopaque;
extern fn jfclose(f: ?*anyopaque) c_int;
extern fn vsrm(s: [*c]u8) void;
extern fn zdup(s: [*c]const u8) [*c]u8;
extern fn strlen(s: [*c]const u8) c_ulong;
extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
extern fn strcpy(d: [*c]u8, s: [*c]const u8) [*c]u8;
extern fn strstr(a: [*c]const u8, b: [*c]const u8) [*c]u8;
extern fn strrchr(s: [*c]const u8, c: c_int) [*c]u8;

extern var locale_map: ?*anyopaque;
extern var aborthint: [*c]const u8;
extern var helphint: [*c]const u8;

var gettext_ht: ?*anyopaque = null;

fn ignore_prefix(set: [*c]const u8) [*c]const u8 {
    const s = strrchr(set, '|');
    if (s != null) return s + 1;
    return set;
}

fn zlen(s: [*c]const u8) isize {
    return @intCast(strlen(s));
}

export fn my_gettext(s_in: [*c]const u8) [*c]const u8 {
    var s = s_in;
    if (gettext_ht != null) {
        const r = htfind(gettext_ht, s);
        if (r != null) s = @ptrCast(r);
    }
    if (s[0] == '|') s = ignore_prefix(s);
    if (strstr(s, "%{") != null) {
        var buf: [128]u8 = undefined;
        var name: [80]u8 = undefined;
        var i: usize = 0;
        while (s[0] != 0) {
            if (s[0] == '%' and s[1] == '{') {
                var j: usize = 0;
                s += 2;
                while (s[0] != 0 and s[0] != '}') {
                    name[j] = s[0];
                    j += 1;
                    s += 1;
                }
                name[j] = 0;
                if (s[0] == '}') s += 1;
                if (strcmp(@ptrCast(&name), "abort") == 0) {
                    _ = strcpy(@ptrCast(&buf[i]), aborthint);
                    i = @intCast(zlen(@ptrCast(&buf)));
                } else if (strcmp(@ptrCast(&name), "help") == 0) {
                    _ = strcpy(@ptrCast(&buf[i]), helphint);
                    i = @intCast(zlen(@ptrCast(&buf)));
                }
            } else {
                buf[i] = s[0];
                i += 1;
                s += 1;
            }
        }
        buf[i] = 0;
        s = atom_add(@ptrCast(&buf));
    }
    return s;
}

fn load_po(f: ?*anyopaque) c_int {
    var buf: [1024]u8 = undefined;
    var msgid: [1024]u8 = undefined;
    var msgstr: [1024]u8 = undefined;
    var bf: [8192]u8 = undefined;
    var po_map: ?*anyopaque = locale_map;
    var preload_flag: bool = false;
    msgid[0] = 0;
    msgstr[0] = 0;

    outer: while (true) {
        if (!preload_flag) {
            if (jfgets(@ptrCast(&buf), @as(c_int, @intCast(buf.len - 1)), f) == null) break;
        }
        preload_flag = false;
        var p: [*c]const u8 = @ptrCast(&buf);
        _ = parse_ws(@ptrCast(&p), '#');
        if (parse_field(@ptrCast(&p), "msgid") == 0) {
            var ofst: isize = 0;
            msgid[0] = 0;
            _ = parse_ws(@ptrCast(&p), '#');
            while (true) {
                const len = parse_string(@ptrCast(&p), @ptrCast(&msgid[@as(usize, @intCast(ofst))]), @as(isize, @intCast(msgid.len)) - ofst);
                if (len < 0) break;
                preload_flag = false;
                ofst += len;
                _ = parse_ws(@ptrCast(&p), '#');
                if (p[0] == 0) {
                    if (jfgets(@ptrCast(&buf), @as(c_int, @intCast(buf.len - 1)), f) != null) {
                        p = @ptrCast(&buf);
                        preload_flag = true;
                        _ = parse_ws(@ptrCast(&p), '#');
                    } else {
                        break :outer;
                    }
                }
            }
        } else if (parse_field(@ptrCast(&p), "msgstr") == 0) {
            var ofst: isize = 0;
            msgstr[0] = 0;
            _ = parse_ws(@ptrCast(&p), '#');
            while (true) {
                const len = parse_string(@ptrCast(&p), @ptrCast(&msgstr[@as(usize, @intCast(ofst))]), @as(isize, @intCast(msgstr.len)) - ofst);
                if (len < 0) break;
                preload_flag = false;
                ofst += len;
                _ = parse_ws(@ptrCast(&p), '#');
                if (p[0] == 0) {
                    if (jfgets(@ptrCast(&buf), @as(c_int, @intCast(buf.len - 1)), f) != null) {
                        p = @ptrCast(&buf);
                        preload_flag = true;
                        _ = parse_ws(@ptrCast(&p), '#');
                    } else {
                        break;
                    }
                }
            }
            if (msgid[0] != 0 and msgstr[0] != 0) {
                my_iconv(@ptrCast(&bf), @as(isize, @intCast(bf.len)), locale_map, @ptrCast(&msgstr), po_map);
                _ = htadd(gettext_ht, zdup(@ptrCast(&msgid)), zdup(@ptrCast(&bf)));
            } else if (msgid[0] == 0 and msgstr[0] != 0) {
                const tp0 = strstr(@ptrCast(&msgstr), "charset=");
                if (tp0 != null) {
                    var tp: [*c]const u8 = tp0 + "charset=".len;
                    while (tp[0] == ' ' or tp[0] == '\t') tp += 1;
                    var x: usize = 0;
                    while (tp[x] != 0 and tp[x] != '\n' and tp[x] != '\r' and tp[x] != ' ' and
                        tp[x] != '\t' and tp[x] != ';' and tp[x] != ',') : (x += 1)
                    {
                        msgid[x] = tp[x];
                    }
                    msgid[x] = 0;
                    po_map = find_charmap(@ptrCast(&msgid));
                    if (po_map == null) po_map = locale_map;
                }
            }
        }
    }

    _ = jfclose(f);
    return 0;
}

export fn init_gettext(s: [*c]const u8) void {
    var f: ?*anyopaque = null;
    var fullpath = open_config_file(@ptrCast(&f), "lang/", s, ".po");
    if (fullpath == null and s[0] != 0 and s[1] != 0) {
        var lang: [3]u8 = .{ s[0], s[1], 0 };
        fullpath = open_config_file(@ptrCast(&f), "lang/", @ptrCast(&lang), ".po");
    }
    if (fullpath != null) {
        gettext_ht = htmk(256);
        _ = load_po(f);
        vsrm(fullpath);
    }
}
