//! Line attribute cache — replaces `joe/lattr.c`.
//!
//! Gap buffer of per-line `HIGHLIGHT_STATE` values for syntax highlighting.
//! Lazily recomputes an invalid window after inserts/deletes, then scans
//! forward until a cached state matches (so the rest can stay trusted).

const types = @import("gapbuffer/types.zig");

const B = types.B;
const P = types.P;

// ═══════════════════════════════════════════════════════════════════════
// External C / Zig symbols
// ═══════════════════════════════════════════════════════════════════════

extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn joe_realloc(ptr: ?*anyopaque, size: isize) ?*anyopaque;
extern fn free(ptr: ?*anyopaque) void;
extern fn mmove(d: ?*anyopaque, s: ?*const anyopaque, sz: isize) ?*anyopaque;

extern fn pdup(p: ?*P, tr: [*c]const u8) ?*P;
extern fn prm(p: ?*P) void;
extern fn pline(p: ?*P, line: i64) ?*P;

extern fn parse(syntax: ?*anyopaque, line: ?*P, state: HIGHLIGHT_STATE, charmap: ?*anyopaque) HIGHLIGHT_STATE;

// ═══════════════════════════════════════════════════════════════════════
// Struct layouts (must match joe/types.h + joe/lattr.h)
// ═══════════════════════════════════════════════════════════════════════

const HIGHLIGHT_STATE = extern struct {
    stack: ?*anyopaque, // high_frame *
    delim_stack: ?*anyopaque, // high_delim_frame *
    saved_s: ?*const c_int,
    state: isize,
};

comptime {
    if (@sizeOf(HIGHLIGHT_STATE) != 32) @compileError("HIGHLIGHT_STATE size mismatch");
}

const LattrDb = extern struct {
    next: ?*LattrDb,
    syn: ?*anyopaque, // high_syntax *
    b: ?*B,
    buffer: ?[*]HIGHLIGHT_STATE,
    hole: isize,
    ehole: isize,
    end: isize,
    first_invalid: isize,
    invalid_window: isize,
};

comptime {
    if (@sizeOf(LattrDb) != 72) @compileError("lattr_db size mismatch");
}

// ═══════════════════════════════════════════════════════════════════════
// Helpers (C macros / statics)
// ═══════════════════════════════════════════════════════════════════════

fn clearState(s: *HIGHLIGHT_STATE) void {
    s.saved_s = null;
    s.state = 0;
    s.stack = null;
    s.delim_stack = null;
}

fn eqState(x: *const HIGHLIGHT_STATE, y: *const HIGHLIGHT_STATE) bool {
    return x.state == y.state and x.stack == y.stack and x.delim_stack == y.delim_stack and x.saved_s == y.saved_s;
}

fn lattrSize(db: *const LattrDb) isize {
    return db.end - (db.ehole - db.hole);
}

fn lattrLvalue(db: *const LattrDb, line: isize) HIGHLIGHT_STATE {
    const buf = db.buffer.?;
    if (line >= db.hole) {
        return buf[@intCast(line - db.hole + db.ehole)];
    } else {
        return buf[@intCast(line)];
    }
}

fn lattrGt(db: *LattrDb, line: isize) *HIGHLIGHT_STATE {
    const buf = db.buffer.?;
    if (line >= db.hole) {
        return &buf[@intCast(line - db.hole + db.ehole)];
    } else {
        return &buf[@intCast(line)];
    }
}

fn lattrSt(db: *LattrDb, line: isize, state: *const HIGHLIGHT_STATE) void {
    lattrGt(db, line).* = state.*;
}

// ═══════════════════════════════════════════════════════════════════════
// Exported C ABI
// ═══════════════════════════════════════════════════════════════════════

export fn mk_lattr_db(new_b: ?*B, new_syn: ?*anyopaque) ?*LattrDb {
    const db: *LattrDb = @ptrCast(@alignCast(joe_malloc(@sizeOf(LattrDb)) orelse return null));
    db.next = null;
    db.syn = new_syn;
    db.b = new_b;
    db.end = 512;
    db.hole = 1;
    db.ehole = db.end;
    db.buffer = @ptrCast(@alignCast(joe_malloc(db.end * @sizeOf(HIGHLIGHT_STATE)) orelse {
        free(db);
        return null;
    }));
    db.first_invalid = 1;
    db.invalid_window = -1;
    // State of first line is idle
    clearState(&db.buffer.?[0]);
    return db;
}

export fn rm_lattr_db(db: ?*LattrDb) void {
    const d = db orelse return;
    free(@ptrCast(d.buffer));
    free(d);
}

export fn rm_all_lattr_db(db: ?*LattrDb) void {
    var cur = db;
    while (cur) |d| {
        const n = d.next;
        d.next = null;
        rm_lattr_db(d);
        cur = n;
    }
}

export fn reset_all_lattr_db(db: ?*LattrDb) void {
    var n = db;
    while (n) |d| {
        d.hole = 1;
        d.ehole = d.end;
        d.first_invalid = 1;
        d.invalid_window = -1;
        clearState(&d.buffer.?[0]);
        n = d.next;
    }
}

export fn lattr_hole(db: ?*LattrDb, pos: isize) void {
    const d = db orelse return;
    const buf = d.buffer.?;
    if (pos > d.hole) {
        _ = mmove(
            @ptrCast(buf + @as(usize, @intCast(d.hole))),
            @ptrCast(buf + @as(usize, @intCast(d.ehole))),
            (pos - d.hole) * @sizeOf(HIGHLIGHT_STATE),
        );
    } else if (pos < d.hole) {
        _ = mmove(
            @ptrCast(buf + @as(usize, @intCast(d.ehole - (d.hole - pos)))),
            @ptrCast(buf + @as(usize, @intCast(pos))),
            (d.hole - pos) * @sizeOf(HIGHLIGHT_STATE),
        );
    }
    d.ehole = pos + d.ehole - d.hole;
    d.hole = pos;
}

export fn lattr_check(db: ?*LattrDb, amnt_in: isize) void {
    const d = db orelse return;
    var amnt = amnt_in;
    if (amnt > d.ehole - d.hole) {
        // Not enough space — amount of additional space needed
        amnt = amnt - (d.ehole - d.hole) + 16;
        d.buffer = @ptrCast(@alignCast(joe_realloc(
            @ptrCast(d.buffer),
            (d.end + amnt) * @sizeOf(HIGHLIGHT_STATE),
        ) orelse return));
        const buf = d.buffer.?;
        _ = mmove(
            @ptrCast(buf + @as(usize, @intCast(d.ehole + amnt))),
            @ptrCast(buf + @as(usize, @intCast(d.ehole))),
            (d.end - d.ehole) * @sizeOf(HIGHLIGHT_STATE),
        );
        d.ehole += amnt;
        d.end += amnt;
    }
}

export fn find_lattr_db(b: ?*B, y: ?*anyopaque) ?*LattrDb {
    const buf = b orelse return null;
    var db: ?*LattrDb = @ptrCast(@alignCast(buf.db));
    while (db) |d| {
        if (d.syn == y) return d;
        db = d.next;
    }
    const created = mk_lattr_db(buf, y) orelse return null;
    created.next = @ptrCast(@alignCast(buf.db));
    buf.db = created;
    return created;
}

/// Drop a database, but only if no BWs refer to it.
/// Body is `#ifdef junk` in the C source — exported no-op for ABI.
export fn drop_lattr_db(b: ?*B, db: ?*LattrDb) void {
    _ = b;
    _ = db;
}

export fn lattr_ins(db: ?*LattrDb, line_in: isize, size: isize) void {
    const d = db orelse return;
    const line = line_in + 1; // First invalid line is the one following the insert

    if (line < lattrSize(d)) {
        if (size != 0) {
            lattr_hole(d, line);
            lattr_check(d, size);
            d.ehole -= size;
        }
        if (d.invalid_window == -1) {
            d.first_invalid = line;
            d.invalid_window = size;
        } else if (line >= d.first_invalid + d.invalid_window) {
            d.invalid_window = line + size - d.first_invalid;
        } else if (line >= d.first_invalid) {
            d.invalid_window += size;
        } else {
            d.invalid_window += d.first_invalid - line + size;
            d.first_invalid = line;
        }
    }
}

export fn lattr_del(db: ?*LattrDb, line_in: isize, size_in: isize) void {
    const d = db orelse return;
    const line = line_in + 1; // First invalid line is the one following the delete
    var size = size_in;

    if (line < lattrSize(d)) {
        if (size != 0) {
            lattr_hole(d, line);
            if (size > d.end - d.ehole)
                size = d.end - d.ehole;
            d.ehole += size;
        }

        if (d.invalid_window == -1) {
            d.first_invalid = line;
            d.invalid_window = 0;
        } else if (line < d.first_invalid) {
            if (line + size <= d.first_invalid) {
                d.invalid_window = d.first_invalid + d.invalid_window - line - size;
                d.first_invalid = line;
            } else if (line + size <= d.first_invalid + d.invalid_window) {
                d.invalid_window -= line + size - d.first_invalid;
                d.first_invalid = line;
            } else {
                d.invalid_window = 0;
                d.first_invalid = line;
            }
        } else if (line < d.first_invalid + d.invalid_window) {
            if (line + size < d.first_invalid + d.invalid_window) {
                d.invalid_window -= size;
            } else {
                d.invalid_window = line - d.first_invalid;
            }
        } else {
            d.invalid_window = line - d.first_invalid;
        }
    }
}

export fn lattr_get(db: ?*LattrDb, y: ?*anyopaque, p: ?*P, line: isize) HIGHLIGHT_STATE {
    const d = db orelse {
        var x: HIGHLIGHT_STATE = undefined;
        clearState(&x);
        return x;
    };
    const pt = p orelse {
        var x: HIGHLIGHT_STATE = undefined;
        clearState(&x);
        return x;
    };

    // Past end of file?
    if (line > pt.b.?.eof.?.line) {
        var x: HIGHLIGHT_STATE = undefined;
        clearState(&x);
        return x;
    }

    // Check if we need to expand
    if (line >= lattrSize(d)) {
        const amnt = line - lattrSize(d) + 1;
        lattr_hole(d, lattrSize(d));
        lattr_check(d, amnt);
        d.ehole -= amnt;
        if (d.invalid_window == -1) {
            d.first_invalid = lattrSize(d) - amnt;
            d.invalid_window = amnt;
        } else {
            d.invalid_window = lattrSize(d) - d.first_invalid;
        }
    }

    // Check if we are pointing to a valid record
    if (line >= d.first_invalid) {
        var ln = d.first_invalid;
        const tmp = pdup(pt, "lattr_get");
        var state = lattrLvalue(d, ln - 1);
        _ = pline(tmp, ln - 1);

        // Recompute everything in invalid window
        while (ln < d.first_invalid + d.invalid_window) {
            state = parse(y, tmp, state, pt.b.?.o.charmap);
            lattrSt(d, ln, &state);
            ln += 1;
        }

        // Update invalid window: hopefully we did the whole window
        d.invalid_window -= ln - d.first_invalid;
        d.first_invalid = ln;

        // Recompute until match found. If match is found, rest is valid.
        while (ln < lattrSize(d)) {
            state = parse(y, tmp, state, pt.b.?.o.charmap);
            const prev = lattrGt(d, ln);
            if (!eqState(prev, &state)) {
                lattrSt(d, ln, &state);
            } else {
                d.first_invalid = lattrSize(d);
                d.invalid_window = -1;
                ln += 1;
                break;
            }
            ln += 1;
        }

        // Update invalid pointer
        if (ln > d.first_invalid) {
            d.first_invalid = ln;
            d.invalid_window = 0;
        }
        if (ln == lattrSize(d)) {
            d.first_invalid = ln;
            d.invalid_window = -1;
        }
        prm(tmp);
    }

    return lattrLvalue(d, line);
}
