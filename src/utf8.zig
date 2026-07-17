//! UTF-8 and UTF-16 encode/decode utilities
//!
//! Drop-in replacement for joe/utf8.c.
//! All functions exported with C ABI for seamless interop with
//! C code that hasn't been ported yet.
//!
//! Note: `export` implies C calling convention in Zig.

const std = @import("std");
const builtin = @import("builtin");

// ── C ABI constants matching utf8.h ──────────────────────────────────

pub const UTF8_ACCEPTED: c_int = -257;
pub const UTF8_INCOMPLETE: c_int = -258;
pub const UTF8_BAD: c_int = -259;

pub const UTF16_ACCEPTED: c_int = -257;
pub const UTF16_INCOMPLETE: c_int = -258;
pub const UTF16_BAD: c_int = -259;

// ── Struct layouts matching C ABI ────────────────────────────────────

/// UTF-8 decoder state machine — 24 bytes on arm64/x64.
/// Must match `struct utf8_sm` in joe/utf8.h exactly.
const Utf8Sm = extern struct {
    buf: [8]u8,
    ptr: isize,
    state: c_int,
    accu: c_int,
};

/// UTF-16 decoder state machine.
/// Must match `struct utf16_sm` in joe/utf8.h exactly.
const Utf16Sm = extern struct {
    state: c_int,
};

// ── UTF-8 encoder ────────────────────────────────────────────────────

/// Encode a Unicode code point into a NUL-terminated UTF-8 buffer.
/// `buf` must have space for at least 7 bytes.
/// Returns the number of bytes written (excluding NUL terminator).
export fn utf8_encode(buf: [*]u8, c: c_int) isize {
    const cp = @as(u21, @intCast(c));

    if (cp < 0x80) {
        buf[0] = @truncate(cp);
        buf[1] = 0;
        return 1;
    }
    if (cp < 0x800) {
        buf[0] = 0xC0 | @as(u8, @truncate(cp >> 6));
        buf[1] = 0x80 | @as(u8, @truncate(cp & 0x3F));
        buf[2] = 0;
        return 2;
    }
    if (cp < 0x10000) {
        buf[0] = 0xE0 | @as(u8, @truncate(cp >> 12));
        buf[1] = 0x80 | @as(u8, @truncate((cp >> 6) & 0x3F));
        buf[2] = 0x80 | @as(u8, @truncate(cp & 0x3F));
        buf[3] = 0;
        return 3;
    }
    if (cp < 0x200000) {
        buf[0] = 0xF0 | @as(u8, @truncate(cp >> 18));
        buf[1] = 0x80 | @as(u8, @truncate((cp >> 12) & 0x3F));
        buf[2] = 0x80 | @as(u8, @truncate((cp >> 6) & 0x3F));
        buf[3] = 0x80 | @as(u8, @truncate(cp & 0x3F));
        buf[4] = 0;
        return 4;
    }
    if (cp < 0x4000000) {
        buf[0] = 0xF8 | @as(u8, @truncate(cp >> 24));
        buf[1] = 0x80 | @as(u8, @truncate((cp >> 18) & 0x3F));
        buf[2] = 0x80 | @as(u8, @truncate((cp >> 12) & 0x3F));
        buf[3] = 0x80 | @as(u8, @truncate((cp >> 6) & 0x3F));
        buf[4] = 0x80 | @as(u8, @truncate(cp & 0x3F));
        buf[5] = 0;
        return 5;
    }
    // 6-byte sequences (RFC 2279 legacy, for completeness)
    buf[0] = 0xFC | @as(u8, @truncate(cp >> 30));
    buf[1] = 0x80 | @as(u8, @truncate((cp >> 24) & 0x3F));
    buf[2] = 0x80 | @as(u8, @truncate((cp >> 18) & 0x3F));
    buf[3] = 0x80 | @as(u8, @truncate((cp >> 12) & 0x3F));
    buf[4] = 0x80 | @as(u8, @truncate((cp >> 6) & 0x3F));
    buf[5] = 0x80 | @as(u8, @truncate(cp & 0x3F));
    buf[6] = 0;
    return 6;
}

// ── UTF-8 decoder ────────────────────────────────────────────────────

/// Decode one byte in a UTF-8 sequence via state machine.
///
/// Returns:
///   0x00000000 - 0x7FFFFFFF  decoded character (sequence complete)
///   UTF8_ACCEPTED            byte consumed, waiting for more
///   UTF8_INCOMPLETE          bad continuation byte found
///   UTF8_BAD                 invalid start byte (128-191, 254, 255)
export fn utf8_decode(sm: *Utf8Sm, char_byte: u8) c_int {
    if (sm.state != 0) {
        // Continuation byte expected
        if (char_byte & 0xC0 == 0x80) {
            sm.buf[@as(usize, @intCast(sm.ptr))] = char_byte;
            sm.ptr += 1;
            sm.state -= 1;
            sm.accu = (sm.accu << 6) | @as(c_int, char_byte & 0x3F);
            if (sm.state == 0) return sm.accu;
        } else {
            sm.state = 0;
            return UTF8_INCOMPLETE;
        }
    } else if (char_byte & 0x80 == 0x00) {
        // 1-byte: 0x00 - 0x7F
        sm.buf[0] = char_byte;
        sm.ptr = 1;
        sm.state = 0;
        return char_byte;
    } else if (char_byte & 0xE0 == 0xC0) {
        // 2-byte: 0xC0 - 0xDF
        sm.buf[0] = char_byte;
        sm.ptr = 1;
        sm.state = 1;
        sm.accu = char_byte & 0x1F;
    } else if (char_byte & 0xF0 == 0xE0) {
        // 3-byte: 0xE0 - 0xEF
        sm.buf[0] = char_byte;
        sm.ptr = 1;
        sm.state = 2;
        sm.accu = char_byte & 0x0F;
    } else if (char_byte & 0xF8 == 0xF0) {
        // 4-byte: 0xF0 - 0xF7
        sm.buf[0] = char_byte;
        sm.ptr = 1;
        sm.state = 3;
        sm.accu = char_byte & 0x07;
    } else if (char_byte & 0xFC == 0xF8) {
        // 5-byte: 0xF8 - 0xFB
        sm.buf[0] = char_byte;
        sm.ptr = 1;
        sm.state = 4;
        sm.accu = char_byte & 0x03;
    } else if (char_byte & 0xFE == 0xFC) {
        // 6-byte: 0xFC - 0xFD
        sm.buf[0] = char_byte;
        sm.ptr = 1;
        sm.state = 5;
        sm.accu = char_byte & 0x01;
    } else {
        // 0x80-0xBF (continuation byte without start) or 0xFE-0xFF
        sm.ptr = 0;
        sm.state = 0;
        return UTF8_BAD;
    }
    return UTF8_ACCEPTED;
}

/// Initialize UTF-8 decoder state machine.
export fn utf8_init(sm: *Utf8Sm) void {
    sm.ptr = 0;
    sm.state = 0;
}

/// Decode the first complete UTF-8 sequence from a NUL-terminated string.
/// Returns the decoded character, or a negative error code.
export fn utf8_decode_string(s: [*:0]const u8) c_int {
    var sm: Utf8Sm = undefined;
    utf8_init(&sm);
    var p: usize = 0;
    while (s[p] != 0) : (p += 1) {
        const result = utf8_decode(&sm, s[p]);
        if (result >= 0) return result;
        if (result == UTF8_INCOMPLETE or result == UTF8_BAD) return result;
        // UTF8_ACCEPTED: continue
    }
    // End of string with no complete character
    return UTF8_INCOMPLETE;
}

/// Decode one UTF-8 character from a byte buffer and advance position.
///
/// Returns:
///   0x00000000 - 0x7FFFFFFF  decoded character
///   UTF8_INCOMPLETE          incomplete sequence (call again with rest)
///   UTF8_BAD                 invalid start byte
///
/// On return, *pos and *len are advanced so repeated calls don't hang.
/// Pass null for `len` to use a NUL-terminated string.
export fn utf8_decode_fwrd(pos: *[*c]const u8, len: ?*isize) c_int {
    var sm: Utf8Sm = undefined;
    utf8_init(&sm);

    const s = pos.*;
    var offset: usize = 0;
    var remaining: isize = if (len) |l| l.* else -1;

    const result: c_int = while (true) {
        const byte: u8 = if (remaining >= 0)
            if (remaining > 0) s[offset] else break UTF8_INCOMPLETE
        else
            if (s[offset] != 0) s[offset] else break UTF8_INCOMPLETE;

        const c = utf8_decode(&sm, byte);
        if (c >= 0) {
            // Complete character decoded
            offset += 1;
            if (remaining >= 0) remaining -= 1;
            break c;
        } else if (c == UTF8_BAD) {
            // Bad start byte — advance past it to avoid infinite loops
            offset += 1;
            if (remaining >= 0) remaining -= 1;
            break UTF8_BAD;
        } else if (c == UTF8_INCOMPLETE) {
            // Invalid continuation byte — don't advance
            break UTF8_INCOMPLETE;
        } else {
            // UTF8_ACCEPTED — continuation byte consumed
            offset += 1;
            if (remaining >= 0) remaining -= 1;
        }
    };

    pos.* = s + offset;
    if (len) |l| l.* = remaining;
    return result;
}

// ── UTF-16 decode ────────────────────────────────────────────────────

/// Initialize UTF-16 decoder state machine.
export fn utf16_init(sm: *Utf16Sm) void {
    sm.state = 0;
}

/// Decode one 16-bit word in a UTF-16 sequence.
///
/// Returns:
///   0x00000 - 0x10FFFF  decoded character
///   UTF16_ACCEPTED       low surrogate saved, waiting for high
///   UTF16_INCOMPLETE     expected continuation but didn't get one
///   UTF16_BAD            unexpected low surrogate
export fn utf16_decode(sm: *Utf16Sm, c: u16) c_int {
    if (sm.state != 0) {
        if (c >= 0xDC00 and c <= 0xDFFF) {
            const rtn = ((@as(c_int, sm.state) - 0xD800) << 10) + (@as(c_int, c) - 0xDC00) + 0x10000;
            sm.state = 0;
            return rtn;
        } else if (c >= 0xD800 and c <= 0xDBFF) {
            sm.state = @as(c_int, c);
            return UTF16_ACCEPTED;
        } else {
            return @as(c_int, c);
        }
    } else {
        if (c >= 0xD800 and c <= 0xDBFF) {
            sm.state = @as(c_int, c);
            return UTF16_ACCEPTED;
        } else if (c >= 0xDC00 and c <= 0xDFFF) {
            return UTF16_BAD;
        } else {
            return @as(c_int, c);
        }
    }
}

/// Decode UTF-16 with reversed byte order.
export fn utf16r_decode(sm: *Utf16Sm, c: u16) c_int {
    const reversed = @as(u16, @intCast((c >> 8) | (c << 8)));
    return utf16_decode(sm, reversed);
}

// ── UTF-16 encode ────────────────────────────────────────────────────

/// Encode a Unicode code point to UTF-16 (native byte order).
/// `buf` must have space for at least 4 bytes.
/// Returns number of bytes written (2 or 4), or UTF16_BAD on error.
export fn utf16_encode(buf: [*]u8, c: c_int) isize {
    const cp = @as(u21, @intCast(c));
    if ((cp < 0xD800) or (cp >= 0xE000 and cp < 0x10000)) {
        @as(*u16, @ptrCast(@alignCast(buf))).* = @as(u16, @truncate(cp));
        return 2;
    } else if (cp >= 0x10000 and cp < 0x110000) {
        const adjusted = cp - 0x10000;
        const high = 0xD800 + @as(u16, @truncate(adjusted >> 10));
        const low = 0xDC00 + @as(u16, @truncate(adjusted & 0x3FF));
        @as(*u16, @ptrCast(@alignCast(buf))).* = high;
        @as(*u16, @ptrCast(@alignCast(buf + 2))).* = low;
        return 4;
    } else {
        return UTF16_BAD;
    }
}

/// Encode a Unicode code point to UTF-16R (reversed byte order).
export fn utf16r_encode(buf: [*]u8, c: c_int) isize {
    const cp = @as(u21, @intCast(c));
    if ((cp < 0xD800) or (cp >= 0xE000 and cp < 0x10000)) {
        var d: u16 = @as(u16, @truncate(cp));
        d = @as(u16, @intCast((d >> 8) | (d << 8)));
        @as(*u16, @ptrCast(@alignCast(buf))).* = d;
        return 2;
    } else if (cp >= 0x10000 and cp < 0x110000) {
        const adjusted = cp - 0x10000;
        var high: u16 = 0xD800 + @as(u16, @truncate(adjusted >> 10));
        var low: u16 = 0xDC00 + @as(u16, @truncate(adjusted & 0x3FF));
        high = @as(u16, @intCast((high >> 8) | (high << 8)));
        low = @as(u16, @intCast((low >> 8) | (low << 8)));
        @as(*u16, @ptrCast(@alignCast(buf))).* = high;
        @as(*u16, @ptrCast(@alignCast(buf + 2))).* = low;
        return 4;
    } else {
        return UTF16_BAD;
    }
}

// ── Locale-aware character advance ───────────────────────────────────

/// Minimal compat definition for `struct charmap` from joe/charmap.h.
/// Only the fields needed by fwrd_c are declared.
const Charmap = extern struct {
    type: c_int,
    // (remaining fields not needed here)
};

/// Get next character from string and advance it, locale dependent.
/// Delegates to utf8_decode_fwrd for Unicode charmaps, or simple
/// byte advance for single-byte charmaps.
export fn fwrd_c(map: *Charmap, s: *[*c]const u8, len: ?*isize) c_int {
    if (map.type != 0) {
        return utf8_decode_fwrd(s, len);
    } else {
        const c = @as(c_int, s.*[0]);
        s.* = s.* + 1;
        if (len) |l| l.* -= 1;
        return c;
    }
}

// ── Tests ────────────────────────────────────────────────────────────

const testing = std.testing;

test "utf8_encode basic" {
    var buf: [7]u8 = undefined;
    try testing.expectEqual(@as(isize, 1), utf8_encode(&buf, 0x41));
    try testing.expectEqual(@as(u8, 'A'), buf[0]);

    try testing.expectEqual(@as(isize, 2), utf8_encode(&buf, 0xA9));
    try testing.expectEqual(@as(u8, 0xC2), buf[0]);
    try testing.expectEqual(@as(u8, 0xA9), buf[1]);

    try testing.expectEqual(@as(isize, 3), utf8_encode(&buf, 0x2603));
    try testing.expectEqual(@as(u8, 0xE2), buf[0]);
    try testing.expectEqual(@as(u8, 0x98), buf[1]);
    try testing.expectEqual(@as(u8, 0x83), buf[2]);

    try testing.expectEqual(@as(isize, 4), utf8_encode(&buf, 0x1F600));
    try testing.expectEqual(@as(u8, 0xF0), buf[0]);
    try testing.expectEqual(@as(u8, 0x9F), buf[1]);
    try testing.expectEqual(@as(u8, 0x98), buf[2]);
    try testing.expectEqual(@as(u8, 0x80), buf[3]);
}

test "utf8_decode roundtrip" {
    var sm: Utf8Sm = undefined;
    var buf: [7]u8 = undefined;
    const codepoints = [_]u21{ 0x41, 0xA9, 0x2603, 0x1F600, 0x7F, 0x80, 0x7FF, 0x800, 0xFFFF, 0x10000, 0x10FFFF };
    inline for (codepoints) |cp| {
        const len = utf8_encode(&buf, @as(c_int, cp));
        utf8_init(&sm);
        var decoded: c_int = 0;
        for (0..@as(usize, @intCast(len))) |i| {
            decoded = utf8_decode(&sm, buf[i]);
        }
        try testing.expectEqual(@as(c_int, cp), decoded);
    }
}

test "utf16_encode basic" {
    var buf: [4]u8 = undefined;
    try testing.expectEqual(@as(isize, 2), utf16_encode(&buf, 0x20AC));
    try testing.expectEqual(@as(isize, 4), utf16_encode(&buf, 0x1F600));
}

test "utf16_decode" {
    var sm: Utf16Sm = undefined;
    utf16_init(&sm);
    const c1 = utf16_decode(&sm, 0xD83D);
    try testing.expectEqual(UTF16_ACCEPTED, c1);
    const c2 = utf16_decode(&sm, 0xDE00);
    try testing.expectEqual(@as(c_int, 0x1F600), c2);
}
