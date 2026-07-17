//! Zig-native menu window (Phase 5 redesign).
//!
//! Parallel to hybrid `src/menu.zig` + `src/mmenu.zig`. Owns grid layout
//! (`mconfig`), cursor/top follow, selection/abort/backs callbacks, common-
//! prefix completion, and rc-menu registry shapes. Not wired into live `joe`
//! yet — unit-tested only.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const screen = @import("screen.zig");

fn onResize(w: *screen.Window, wi: u16, he: u16) void {
    const m = w.asMenu() orelse return;
    m.resize(wi, he);
}

fn onMove(w: *screen.Window, x: u16, y: i16) void {
    const m = w.asMenu() orelse return;
    m.x = x;
    m.y = y;
}

fn onAbort(w: *screen.Window) i32 {
    const m = w.asMenu() orelse return -1;
    return m.abort();
}

pub const vtable: screen.WindowVTable = .{
    .kind = .menu,
    .context = "menu",
    .on_resize = onResize,
    .on_move = onMove,
    .on_abort = onAbort,
};

/// Optional display-width of a label; default treats each byte as width 1.
pub const WidthFn = *const fn (text: []const u8) usize;

fn byteWidth(text: []const u8) usize {
    return text.len;
}

pub const SelectFn = *const fn (menu: *MenuWindow, cursor: usize, object: ?*anyopaque, key: u8) i32;
pub const AbortFn = *const fn (target: screen.WindowId, cursor: usize, object: ?*anyopaque) i32;
pub const BacksFn = *const fn (menu: *MenuWindow, cursor: usize, object: ?*anyopaque) i32;

/// Grid geometry computed by `configure` — JOE `mconfig` / `mlines`.
pub const GridConfig = struct {
    /// Widest item width, clamped to `w - 1`.
    width: usize = 0,
    /// Items that fit per screen row at current width (JOE `fitline`).
    fitline: usize = 1,
    /// Items placed per row (equals `fitline` unless transpose).
    perline: usize = 1,
    /// Total logical rows given `nitems`/`fitline` (JOE `lines`).
    lines: usize = 0,
    nitems: usize = 0,
};

/// Compute menu grid for `items` in a window of width `w` (JOE `mconfig`).
pub fn configureGrid(items: []const []const u8, w: usize, transpose: bool, width_of: WidthFn) GridConfig {
    var cfg: GridConfig = .{};
    cfg.nitems = items.len;
    if (items.len == 0 or w == 0) {
        cfg.fitline = 1;
        cfg.perline = 1;
        return cfg;
    }

    var max_w: usize = 0;
    for (items) |item| {
        const d = width_of(item);
        if (d > max_w) max_w = d;
    }
    if (w > 0 and max_w > w - 1) max_w = w - 1;
    cfg.width = max_w;

    const fit = if (max_w + 1 == 0) 1 else w / (max_w + 1);
    cfg.fitline = if (fit == 0) 1 else fit;
    cfg.lines = (items.len + cfg.fitline - 1) / cfg.fitline;
    if (cfg.lines == 0) cfg.lines = 1;

    if (transpose) {
        cfg.perline = (items.len + cfg.lines - 1) / cfg.lines;
        if (cfg.perline == 0) cfg.perline = 1;
    } else {
        cfg.perline = cfg.fitline;
    }
    return cfg;
}

/// Height needed to show all items (JOE `mlines`).
pub fn linesFor(items: []const []const u8, w: usize, width_of: WidthFn) usize {
    const cfg = configureGrid(items, w, false, width_of);
    return if (cfg.lines == 0) 1 else cfg.lines;
}

/// Longest common prefix of `items` (JOE `find_longest` / `mcomplete` cull).
pub fn commonPrefix(items: []const []const u8) []const u8 {
    if (items.len == 0) return "";
    var prefix = items[0];
    for (items[1..]) |item| {
        var i: usize = 0;
        const lim = @min(prefix.len, item.len);
        while (i < lim and prefix[i] == item[i]) : (i += 1) {}
        prefix = prefix[0..i];
        if (prefix.len == 0) return "";
    }
    return prefix;
}

/// JOE `mcomplete`: empty when no items, or sole item is `"../"`.
pub fn completePrefix(items: []const []const u8) []const u8 {
    if (items.len == 0) return "";
    if (items.len == 1 and std.mem.eql(u8, items[0], "../")) return "";
    return commonPrefix(items);
}


/// Window-relative cursor after paint (JOE `W.curx` / `W.cury`).
pub const CursorPos = struct {
    x: usize = 0,
    y: usize = 0,
};

/// Pad/truncate `text` into `dest` of length `field_w` (byte-width `genfield`).
pub fn paintField(dest: []u8, text: []const u8) void {
    const n = @min(dest.len, text.len);
    @memcpy(dest[0..n], text[0..n]);
    if (n < dest.len) @memset(dest[n..], ' ');
}

/// Tests-only cell grid for one menu viewport (JOE `menudisp` shape).
pub const Paint = struct {
    allocator: Allocator,
    /// Flat `w * h` characters (space-filled).
    chars: []u8,
    /// Inverse attribute per cell (selected field when focused).
    inverse: []bool,
    w: usize,
    h: usize,
    cur: CursorPos = .{},

    pub fn deinit(self: *Paint) void {
        self.allocator.free(self.chars);
        self.allocator.free(self.inverse);
        self.* = undefined;
    }

    pub fn charAt(self: *const Paint, x: usize, y: usize) u8 {
        return self.chars[y * self.w + x];
    }

    pub fn isInverse(self: *const Paint, x: usize, y: usize) bool {
        return self.inverse[y * self.w + x];
    }

    pub fn rowSlice(self: *const Paint, y: usize) []const u8 {
        const start = y * self.w;
        return self.chars[start .. start + self.w];
    }
};

pub const MenuWindow = struct {
    parent: *screen.Window,
    /// Borrowed item labels (caller owns; JOE `list`).
    items: []const []const u8 = &.{},
    cursor: usize = 0,
    /// First visible item index (row-aligned when not transpose).
    top: usize = 0,
    /// Window geometry mirror (JOE MENU `w`/`h`/`x`/`y`).
    w: u16 = 0,
    h: u16 = 0,
    x: u16 = 0,
    y: i16 = 0,
    grid: GridConfig = .{},
    transpose: bool = false,
    on_select: ?SelectFn = null,
    on_abort: ?AbortFn = null,
    on_backs: ?BacksFn = null,
    object: ?*anyopaque = null,
    target: screen.WindowId = 0,
    width_of: WidthFn = byteWidth,

    pub fn init(parent: *screen.Window, items: []const []const u8, cursor: usize) MenuWindow {
        var m: MenuWindow = .{
            .parent = parent,
            .items = items,
            .w = parent.w,
            .h = parent.h,
            .x = parent.x,
            .y = parent.y,
            .target = parent.target orelse parent.main,
        };
        m.load(items, cursor);
        return m;
    }

    /// JOE `ldmenu`.
    pub fn load(self: *MenuWindow, items: []const []const u8, cursor: usize) void {
        self.items = items;
        self.cursor = cursor;
        self.configure();
        if (self.grid.nitems == 0) {
            self.cursor = 0;
        } else if (self.cursor >= self.grid.nitems) {
            self.cursor = self.grid.nitems - 1;
        }
        self.follow();
    }

    /// JOE `mconfig`.
    pub fn configure(self: *MenuWindow) void {
        self.top = 0;
        self.grid = configureGrid(self.items, self.w, self.transpose, self.width_of);
    }

    pub fn resize(self: *MenuWindow, wi: u16, he: u16) void {
        self.w = wi;
        self.h = he;
        self.configure();
        self.follow();
    }

    /// JOE `menufllw` — keep `cursor` in the visible window.
    pub fn follow(self: *MenuWindow) void {
        if (self.grid.nitems == 0 or self.h == 0) return;
        const per = if (self.grid.perline == 0) 1 else self.grid.perline;
        if (self.transpose) {
            const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
            const row = self.cursor % lines;
            if (row < self.top) {
                self.top = row;
            } else if (row >= self.top + self.h) {
                self.top = row - (self.h - 1);
            }
        } else {
            if (self.cursor < self.top) {
                self.top = self.cursor - (self.cursor % per);
            } else if (self.cursor >= self.top + per * self.h) {
                self.top = self.cursor - (self.cursor % per) - per * (self.h - 1);
            }
        }
    }

    /// JOE `menudisp` cursor placement (window-relative).
    pub fn cursorPos(self: *const MenuWindow) CursorPos {
        if (self.grid.nitems == 0 or self.h == 0 or self.w == 0) return .{};
        const field_w = self.grid.width;
        const label = self.items[self.cursor];
        const label_w = self.width_of(label);
        const col_w = if (label_w < field_w) label_w else field_w;
        if (self.transpose) {
            const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
            const y = (self.cursor % lines) -% self.top;
            const x = (self.cursor / lines) * (field_w + 1) + col_w;
            return .{ .x = x, .y = y };
        } else {
            const per = if (self.grid.perline == 0) 1 else self.grid.perline;
            const rel = self.cursor -% self.top;
            const y = rel / per;
            const x = (rel % per) * (field_w + 1) + col_w;
            return .{ .x = x, .y = y };
        }
    }

    /// Build a tests-only paint buffer mirroring JOE `menudisp`.
    /// `focused` matches `m->t->curwin == m->parent` (selection inverse).
    pub fn paint(self: *const MenuWindow, allocator: Allocator, focused: bool) !Paint {
        const wi: usize = self.w;
        const he: usize = self.h;
        var out: Paint = .{
            .allocator = allocator,
            .chars = try allocator.alloc(u8, wi * he),
            .inverse = try allocator.alloc(bool, wi * he),
            .w = wi,
            .h = he,
        };
        errdefer out.deinit();
        @memset(out.chars, ' ');
        @memset(out.inverse, false);
        if (wi == 0 or he == 0 or self.grid.nitems == 0) {
            out.cur = self.cursorPos();
            return out;
        }

        const field_w = self.grid.width;
        const per = if (self.grid.perline == 0) 1 else self.grid.perline;
        const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
        var cut = self.grid.nitems % lines;
        if (cut == 0) cut = lines;

        var y: usize = 0;
        while (y < he) : (y += 1) {
            var col: usize = 0;
            if (self.transpose) {
                if (y < lines) {
                    const row = y + self.top;
                    const x_limit = if (row >= cut) per -| 1 else per;
                    var x: usize = 0;
                    while (x < x_limit) : (x += 1) {
                        const ndx = x * lines + row;
                        if (ndx >= self.grid.nitems) break;
                        if (col >= wi) break;
                        const take = @min(field_w, wi - col);
                        var tmp: [256]u8 = undefined;
                        const use_tmp = take <= tmp.len;
                        const dest = if (use_tmp) tmp[0..take] else try allocator.alloc(u8, take);
                        defer if (!use_tmp) allocator.free(dest);
                        paintField(dest, self.items[ndx]);
                        const inv = focused and ndx == self.cursor;
                        var i: usize = 0;
                        while (i < take) : (i += 1) {
                            out.chars[y * wi + col + i] = dest[i];
                            out.inverse[y * wi + col + i] = inv;
                        }
                        col += take;
                        if (col < wi) {
                            out.chars[y * wi + col] = ' ';
                            col += 1;
                        }
                    }
                }
            } else {
                var x: usize = 0;
                while (x < per and y * per + x + self.top < self.grid.nitems) : (x += 1) {
                    const ndx = x + y * per + self.top;
                    if (col >= wi) break;
                    const take = @min(field_w, wi - col);
                    var tmp: [256]u8 = undefined;
                    const use_tmp = take <= tmp.len;
                    const dest = if (use_tmp) tmp[0..take] else try allocator.alloc(u8, take);
                    defer if (!use_tmp) allocator.free(dest);
                    paintField(dest, self.items[ndx]);
                    const inv = focused and ndx == self.cursor;
                    var i: usize = 0;
                    while (i < take) : (i += 1) {
                        out.chars[y * wi + col + i] = dest[i];
                        out.inverse[y * wi + col + i] = inv;
                    }
                    col += take;
                    if (col < wi) {
                        out.chars[y * wi + col] = ' ';
                        col += 1;
                    }
                }
            }
            // Remainder of row stays spaces (eraeol shape).
        }
        out.cur = self.cursorPos();
        return out;
    }

    pub fn selected(self: *const MenuWindow) ?[]const u8 {
        if (self.cursor >= self.items.len) return null;
        return self.items[self.cursor];
    }

    /// JOE `menujump` — map window-local (x,y) to a cursor index.
    pub fn jump(self: *MenuWindow, x: usize, y: usize) void {
        if (self.grid.nitems == 0) return;
        const cell_w = self.grid.width + 1;
        var pos: usize = self.top;
        if (self.transpose) {
            const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
            pos += y;
            if (cell_w != 0) pos += (x / cell_w) * lines;
        } else {
            const per = if (self.grid.perline == 0) 1 else self.grid.perline;
            pos += y * per;
            if (cell_w != 0) pos += x / cell_w;
        }
        if (pos >= self.grid.nitems) pos = self.grid.nitems - 1;
        self.cursor = pos;
        self.follow();
    }

    pub fn moveHome(self: *MenuWindow) void {
        self.cursor = 0;
        self.follow();
    }

    pub fn moveEnd(self: *MenuWindow) void {
        if (self.grid.nitems == 0) return;
        if (self.transpose and self.grid.nitems % self.grid.lines != 0) {
            const lines = self.grid.lines;
            self.cursor = lines - 1 + (lines * (self.grid.perline - 2));
        } else {
            self.cursor = self.grid.nitems - 1;
        }
        self.follow();
    }

    /// JOE `umbol` — start of current row (or column when transpose).
    pub fn moveBol(self: *MenuWindow) void {
        if (self.grid.nitems == 0) return;
        if (self.transpose) {
            const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
            self.cursor %= lines;
        } else {
            const per = if (self.grid.perline == 0) 1 else self.grid.perline;
            self.cursor -= self.cursor % per;
        }
        self.follow();
    }

    /// JOE `umeol`.
    pub fn moveEol(self: *MenuWindow) void {
        if (self.grid.nitems == 0) return;
        if (self.transpose) {
            const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
            var cut = self.grid.nitems % lines;
            if (cut == 0) cut = lines;
            self.cursor %= lines;
            if (self.cursor >= cut) {
                self.cursor += lines * (self.grid.perline - 2);
            } else {
                self.cursor += lines * (self.grid.perline - 1);
            }
        } else {
            const per = if (self.grid.perline == 0) 1 else self.grid.perline;
            self.cursor -= self.cursor % per;
            if (self.cursor + per - 1 >= self.grid.nitems) {
                self.cursor = self.grid.nitems - 1;
            } else {
                self.cursor += per - 1;
            }
        }
        self.follow();
    }

    /// JOE `umrtarw` (non-transpose: next item). Returns -1 at end.
    pub fn moveRight(self: *MenuWindow) i32 {
        if (self.transpose) {
            if (self.grid.nitems == 0) return -1;
            const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
            var cut = self.grid.nitems % lines;
            if (cut == 0) cut = lines;
            if (self.cursor % lines >= cut) {
                if (self.cursor / lines != self.grid.perline - 2) {
                    self.cursor += lines;
                    self.follow();
                    return 0;
                }
            } else {
                if (self.cursor / lines != self.grid.perline - 1) {
                    self.cursor += lines;
                    self.follow();
                    return 0;
                }
            }
            if ((self.cursor % lines) + 1 < lines) {
                self.cursor = self.cursor % lines + 1;
                self.follow();
                return 0;
            }
            return -1;
        }
        if (self.cursor + 1 < self.grid.nitems) {
            self.cursor += 1;
            self.follow();
            return 0;
        }
        return -1;
    }

    /// JOE `umltarw`.
    pub fn moveLeft(self: *MenuWindow) i32 {
        if (self.transpose) {
            const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
            if (self.cursor >= lines) {
                self.cursor -= lines;
                self.follow();
                return 0;
            } else if (self.cursor > 0) {
                var cut = self.grid.nitems % lines;
                if (cut == 0) cut = lines;
                self.cursor -= 1;
                if (self.cursor >= cut) {
                    self.cursor += (self.grid.perline - 2) * lines;
                } else {
                    self.cursor += (self.grid.perline - 1) * lines;
                }
                self.follow();
                return 0;
            }
            return -1;
        }
        if (self.cursor > 0) {
            self.cursor -= 1;
            self.follow();
            return 0;
        }
        return -1;
    }

    /// JOE `umuparw`.
    pub fn moveUp(self: *MenuWindow) i32 {
        if (self.transpose) {
            const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
            if (self.cursor % lines != 0) {
                self.cursor -= 1;
                self.follow();
                return 0;
            }
            return -1;
        }
        const per = if (self.grid.perline == 0) 1 else self.grid.perline;
        if (self.cursor >= per) {
            self.cursor -= per;
            self.follow();
            return 0;
        }
        return -1;
    }

    /// JOE `umdnarw`.
    pub fn moveDown(self: *MenuWindow) i32 {
        if (self.transpose) {
            const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
            if (self.cursor != self.grid.nitems - 1 and self.cursor % lines != lines - 1) {
                self.cursor += 1;
                self.follow();
                return 0;
            }
            return -1;
        }
        if (self.grid.nitems == 0) return -1;
        const per = if (self.grid.perline == 0) 1 else self.grid.perline;
        const col = self.cursor % per;
        var base = self.cursor - col;
        if (base + per < self.grid.nitems) {
            base += per;
            if (base + col >= self.grid.nitems) {
                self.cursor = self.grid.nitems - 1;
            } else {
                self.cursor = base + col;
            }
            self.follow();
            return 0;
        }
        return -1;
    }

    /// JOE `mscrup` — scroll the menu view up by `amnt` rows (columns if transpose).
    /// Returns 0 on movement, -1 when already at the top edge.
    pub fn scrollUp(self: *MenuWindow, amnt: usize) i32 {
        if (amnt == 0) return -1;
        if (self.transpose) {
            if (self.top >= amnt) {
                self.top -= amnt;
                self.cursor -= amnt;
                return 0;
            } else if (self.top != 0) {
                self.cursor -= self.top;
                self.top = 0;
                return 0;
            } else {
                const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
                const row = self.cursor % lines;
                if (row != 0) {
                    self.cursor -= row;
                    return 0;
                }
                return -1;
            }
        }

        const per = if (self.grid.perline == 0) 1 else self.grid.perline;
        if (self.top >= amnt * per) {
            self.top -= amnt * per;
            self.cursor -= amnt * per;
            return 0;
        } else if (self.top != 0) {
            self.cursor -= self.top;
            self.top = 0;
            return 0;
        } else if (self.cursor >= per) {
            self.cursor = self.cursor % per;
            return 0;
        }
        return -1;
    }

    /// JOE `mscrdn` — scroll the menu view down by `amnt` rows (columns if transpose).
    pub fn scrollDown(self: *MenuWindow, amnt: usize) i32 {
        if (amnt == 0) return -1;
        if (self.h == 0) return -1;

        if (self.transpose) {
            const lines = if (self.grid.lines == 0) 1 else self.grid.lines;
            const per = if (self.grid.perline == 0) 1 else self.grid.perline;
            var col = self.cursor / lines;
            const y = self.cursor % lines;
            const h = lines;
            const t = self.top;
            var cut = if (self.grid.nitems == 0) lines else self.grid.nitems % lines;
            if (cut == 0) cut = lines;
            self.cursor = y;

            if (t + self.h + amnt <= h) {
                self.top += amnt;
                self.cursor += amnt;
                if (self.cursor >= cut and col == per - 1) col -= 1;
                self.cursor += col * lines;
                return 0;
            } else if (t + self.h < h) {
                const move = h - (t + self.h);
                self.top += move;
                self.cursor += move;
                if (self.cursor >= cut and col == per - 1) col -= 1;
                self.cursor += col * lines;
                return 0;
            } else if (y + 1 != h) {
                self.cursor = h - 1;
                if (self.cursor >= cut and col == per - 1) col -= 1;
                self.cursor += col * lines;
                return 0;
            } else {
                self.cursor += col * lines;
                return -1;
            }
        }

        const per = if (self.grid.perline == 0) 1 else self.grid.perline;
        if (self.grid.nitems == 0) return -1;
        const col = self.cursor % per;
        const y = self.cursor / per;
        const total_lines = (self.grid.nitems + per - 1) / per;
        const t = self.top / per;
        self.cursor -= col;

        if (t + self.h + amnt <= total_lines) {
            self.top += amnt * per;
            self.cursor += amnt * per;
            if (self.cursor + col >= self.grid.nitems) {
                self.cursor = self.grid.nitems - 1;
            } else {
                self.cursor += col;
            }
            return 0;
        } else if (t + self.h < total_lines) {
            const move = total_lines - (t + self.h);
            self.top += move * per;
            self.cursor += move * per;
            if (self.cursor + col >= self.grid.nitems) {
                self.cursor = self.grid.nitems - 1;
            } else {
                self.cursor += col;
            }
            return 0;
        } else if (y + 1 != total_lines) {
            self.cursor = (total_lines - 1) * per;
            if (self.cursor + col >= self.grid.nitems) {
                self.cursor = self.grid.nitems - 1;
            } else {
                self.cursor += col;
            }
            return 0;
        } else {
            self.cursor += col;
            return -1;
        }
    }

    /// JOE `umpgup` — scroll up by about half the visible height.
    pub fn pageUp(self: *MenuWindow) i32 {
        const amnt = (@as(usize, self.h) + 1) / 2;
        return self.scrollUp(if (amnt == 0) 1 else amnt);
    }

    /// JOE `umpgdn` — scroll down by about half the visible height.
    pub fn pageDown(self: *MenuWindow) i32 {
        const amnt = (@as(usize, self.h) + 1) / 2;
        return self.scrollDown(if (amnt == 0) 1 else amnt);
    }

    /// JOE `umtab` — wrap to start after last item.
    pub fn moveTab(self: *MenuWindow) void {
        if (self.grid.nitems == 0) return;
        if (self.cursor + 1 >= self.grid.nitems) {
            self.cursor = 0;
        } else {
            self.cursor += 1;
        }
        self.follow();
    }

    /// JOE select path (`func`) — no window teardown.
    pub fn select(self: *MenuWindow, key: u8) i32 {
        const cb = self.on_select orelse return -1;
        return cb(self, self.cursor, self.object, key);
    }

    /// JOE `abrt` callback path.
    pub fn abort(self: *MenuWindow) i32 {
        const cb = self.on_abort orelse return -1;
        return cb(self.target, self.cursor, self.object);
    }

    /// JOE `backs` callback path.
    pub fn backs(self: *MenuWindow) i32 {
        const cb = self.on_backs orelse return -1;
        return cb(self, self.cursor, self.object);
    }

    pub fn complete(self: *const MenuWindow) []const u8 {
        return completePrefix(self.items);
    }
};

/// One rc-menu entry — JOE `rc_menu_entry` without live MACRO.
pub const RcMenuEntry = struct {
    name: []const u8,
    /// Opaque macro/token handle; native layer stores only the pointer.
    macro_ptr: ?*anyopaque = null,
};

/// Named rc menu — JOE `rc_menu`.
pub const RcMenu = struct {
    name: []u8,
    last_position: usize = 0,
    entries: std.ArrayListUnmanaged(RcMenuEntry) = .empty,
    /// Opaque backspace macro (JOE `backs`).
    backs: ?*anyopaque = null,

    pub fn deinit(self: *RcMenu, allocator: Allocator) void {
        allocator.free(self.name);
        for (self.entries.items) |e| {
            allocator.free(e.name);
        }
        self.entries.deinit(allocator);
        self.* = undefined;
    }

    pub fn addEntry(self: *RcMenu, allocator: Allocator, entry_name: []const u8, macro_ptr: ?*anyopaque) !void {
        const copy = try allocator.dupe(u8, entry_name);
        errdefer allocator.free(copy);
        try self.entries.append(allocator, .{ .name = copy, .macro_ptr = macro_ptr });
    }

    pub fn size(self: *const RcMenu) usize {
        return self.entries.items.len;
    }

    /// Build label list for a menu window (caller frees with `freeLabels`).
    pub fn labels(self: *const RcMenu, allocator: Allocator) ![]const []const u8 {
        const out = try allocator.alloc([]const u8, self.entries.items.len);
        for (self.entries.items, 0..) |e, i| {
            out[i] = e.name;
        }
        return out;
    }

    pub fn freeLabels(_: *const RcMenu, allocator: Allocator, labs: []const []const u8) void {
        allocator.free(labs);
    }
};

/// Registry of named rc menus — JOE global `menus` list.
pub const MenuRegistry = struct {
    allocator: Allocator,
    menus: std.ArrayListUnmanaged(*RcMenu) = .empty,

    pub fn init(allocator: Allocator) MenuRegistry {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *MenuRegistry) void {
        for (self.menus.items) |m| {
            m.deinit(self.allocator);
            self.allocator.destroy(m);
        }
        self.menus.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn find(self: *MenuRegistry, name: []const u8) ?*RcMenu {
        for (self.menus.items) |m| {
            if (std.mem.eql(u8, m.name, name)) return m;
        }
        return null;
    }

    /// JOE `create_menu` — returns existing menu if name already registered.
    pub fn create(self: *MenuRegistry, name: []const u8, backs: ?*anyopaque) !*RcMenu {
        if (self.find(name)) |existing| return existing;
        const menu = try self.allocator.create(RcMenu);
        errdefer self.allocator.destroy(menu);
        menu.* = .{
            .name = try self.allocator.dupe(u8, name),
            .backs = backs,
        };
        errdefer menu.deinit(self.allocator);
        try self.menus.append(self.allocator, menu);
        return menu;
    }

    /// Sorted menu names for completion (JOE `getmenus`).
    pub fn names(self: *const MenuRegistry, allocator: Allocator) ![]const []const u8 {
        const out = try allocator.alloc([]const u8, self.menus.items.len);
        for (self.menus.items, 0..) |m, i| {
            out[i] = m.name;
        }
        std.mem.sort([]const u8, out, {}, struct {
            fn less(_: void, a: []const u8, b: []const u8) bool {
                return std.mem.order(u8, a, b) == .lt;
            }
        }.less);
        return out;
    }

    pub fn freeNames(_: *const MenuRegistry, allocator: Allocator, list: []const []const u8) void {
        allocator.free(list);
    }
};

test "configureGrid packs items by width" {
    const items = [_][]const u8{ "aa", "bb", "cccc", "dd", "ee" };
    // width 4 ⇒ clamp; fitline = 10 / (4+1) = 2; lines = ceil(5/2)=3; perline=2
    const cfg = configureGrid(&items, 10, false, byteWidth);
    try testing.expectEqual(@as(usize, 4), cfg.width);
    try testing.expectEqual(@as(usize, 2), cfg.fitline);
    try testing.expectEqual(@as(usize, 2), cfg.perline);
    try testing.expectEqual(@as(usize, 3), cfg.lines);
    try testing.expectEqual(@as(usize, 5), cfg.nitems);

    const tcfg = configureGrid(&items, 10, true, byteWidth);
    try testing.expectEqual(cfg.lines, tcfg.lines);
    // transpose: perline = ceil(nitems/lines)
    try testing.expectEqual(@as(usize, 2), tcfg.perline);
}

test "linesFor matches JOE mlines" {
    const items = [_][]const u8{ "one", "two", "three", "four" };
    // max width "three"=5; w=9 ⇒ fitline = 9/(5+1)=1 ⇒ lines=4
    try testing.expectEqual(@as(usize, 4), linesFor(&items, 9, byteWidth));
    // Short labels: width=3; w=9 ⇒ fitline = 9/(3+1)=2 ⇒ lines=2
    const short = [_][]const u8{ "one", "two", "six", "ten" };
    try testing.expectEqual(@as(usize, 2), linesFor(&short, 9, byteWidth));
    try testing.expectEqual(@as(usize, 1), linesFor(&items, 80, byteWidth));
}

test "commonPrefix and completePrefix" {
    const items = [_][]const u8{ "foobar", "foobaz", "football" };
    try testing.expectEqualStrings("foo", commonPrefix(&items));
    try testing.expectEqualStrings("foo", completePrefix(&items));

    const only_dot = [_][]const u8{"../"};
    try testing.expectEqualStrings("", completePrefix(&only_dot));
    try testing.expectEqualStrings("", completePrefix(&.{}));
}

test "MenuWindow navigation and follow (row-major)" {
    var scr = try screen.Screen.init(testing.allocator, 20, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    // Force a short menu height so follow must scroll.
    win.h = 2;
    win.w = 11; // fitline: items width 1 ⇒ 11/(1+1)=5 perline

    const items = [_][]const u8{ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k" };
    var menu_win = MenuWindow.init(win, &items, 0);
    try testing.expectEqual(@as(usize, 5), menu_win.grid.perline);
    try testing.expectEqual(@as(usize, 3), menu_win.grid.lines);

    try testing.expectEqual(@as(i32, 0), menu_win.moveRight());
    try testing.expectEqual(@as(usize, 1), menu_win.cursor);
    try testing.expectEqual(@as(i32, 0), menu_win.moveDown());
    try testing.expectEqual(@as(usize, 6), menu_win.cursor); // +perline
    menu_win.moveTab();
    try testing.expectEqual(@as(usize, 7), menu_win.cursor);

    menu_win.moveEnd();
    try testing.expectEqual(@as(usize, 10), menu_win.cursor);
    // h=2, perline=5 ⇒ visible 10 items; cursor 10 needs scroll
    try testing.expect(menu_win.top > 0);

    menu_win.moveHome();
    try testing.expectEqual(@as(usize, 0), menu_win.cursor);
    try testing.expectEqual(@as(usize, 0), menu_win.top);

    menu_win.cursor = 3;
    menu_win.moveBol();
    try testing.expectEqual(@as(usize, 0), menu_win.cursor);
    menu_win.cursor = 0;
    menu_win.moveEol();
    try testing.expectEqual(@as(usize, 4), menu_win.cursor);
}

test "MenuWindow scrollUp/scrollDown row-major" {
    var scr = try screen.Screen.init(testing.allocator, 20, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    win.h = 2;
    win.w = 11; // perline=5 for width-1 labels

    const items = [_][]const u8{ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o" };
    var menu_win = MenuWindow.init(win, &items, 0);
    try testing.expectEqual(@as(usize, 5), menu_win.grid.perline);
    try testing.expectEqual(@as(usize, 3), menu_win.grid.lines);

    // Scroll down one row: top advances by perline, cursor follows.
    try testing.expectEqual(@as(i32, 0), menu_win.scrollDown(1));
    try testing.expectEqual(@as(usize, 5), menu_win.top);
    try testing.expectEqual(@as(usize, 5), menu_win.cursor);

    // Already showing the last windowful (rows 1..2 of 0..2); top stays,
    // cursor jumps to the first cell of the final row (JOE mscrdn).
    try testing.expectEqual(@as(i32, 0), menu_win.scrollDown(1));
    try testing.expectEqual(@as(usize, 5), menu_win.top);
    try testing.expectEqual(@as(usize, 10), menu_win.cursor);
    try testing.expectEqual(@as(i32, -1), menu_win.scrollDown(1));

    // Scroll back up to top.
    try testing.expectEqual(@as(i32, 0), menu_win.scrollUp(1));
    try testing.expectEqual(@as(usize, 0), menu_win.top);
    try testing.expectEqual(@as(usize, 5), menu_win.cursor);
    try testing.expectEqual(@as(i32, 0), menu_win.scrollUp(1)); // snap cursor into first row
    try testing.expectEqual(@as(usize, 0), menu_win.top);
    try testing.expectEqual(@as(usize, 0), menu_win.cursor);
    try testing.expectEqual(@as(i32, -1), menu_win.scrollUp(1));
}

test "MenuWindow pageUp/pageDown use half height" {
    var scr = try screen.Screen.init(testing.allocator, 20, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    win.h = 4;
    win.w = 3; // perline=1 for width-1 labels ⇒ 1 column

    var labels: [20][]const u8 = undefined;
    var bufs: [20][4]u8 = undefined;
    for (0..20) |i| {
        labels[i] = std.fmt.bufPrint(&bufs[i], "{d}", .{i}) catch unreachable;
    }
    var menu_win = MenuWindow.init(win, labels[0..], 0);
    try testing.expectEqual(@as(usize, 1), menu_win.grid.perline);

    // pageDown amnt = (4+1)/2 = 2
    try testing.expectEqual(@as(i32, 0), menu_win.pageDown());
    try testing.expectEqual(@as(usize, 2), menu_win.top);
    try testing.expectEqual(@as(usize, 2), menu_win.cursor);

    try testing.expectEqual(@as(i32, 0), menu_win.pageUp());
    try testing.expectEqual(@as(usize, 0), menu_win.top);
    try testing.expectEqual(@as(usize, 0), menu_win.cursor);
}

test "MenuWindow vtable resize/move hooks sync geometry" {
    var scr = try screen.Screen.init(testing.allocator, 80, 20);
    defer scr.deinit();

    const twnd = try scr.createText(null, null, 20);
    scr.layout();
    const items = [_][]const u8{ "alpha", "beta", "gamma", "delta" };
    const menu_w = try scr.createMenu(twnd.id, twnd.id, twnd.id, &items, 0);
    scr.layout();

    const obj = menu_w.asMenu().?;
    try testing.expectEqual(menu_w.w, obj.w);
    try testing.expectEqual(menu_w.h, obj.h);
    try testing.expectEqual(menu_w.x, obj.x);
    try testing.expectEqual(menu_w.y, obj.y);

    // Simulate a later layout resize/move through the watom hooks.
    vtable.on_resize.?(menu_w, 40, 3);
    try testing.expectEqual(@as(u16, 40), obj.w);
    try testing.expectEqual(@as(u16, 3), obj.h);
    // Width 40 with short labels packs multiple per line.
    try testing.expect(obj.grid.perline >= 1);

    vtable.on_move.?(menu_w, 2, 7);
    try testing.expectEqual(@as(u16, 2), obj.x);
    try testing.expectEqual(@as(i16, 7), obj.y);
}

test "MenuWindow jump and callbacks" {

    var scr = try screen.Screen.init(testing.allocator, 20, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    win.h = 4;
    win.w = 11;

    const items = [_][]const u8{ "a", "b", "c", "d", "e", "f" };
    var menu_win = MenuWindow.init(win, &items, 0);
    // perline=5, width=1; jump x into col 1, y=1 ⇒ top + 5 + 1 = 6 → clamped to 5
    menu_win.jump(2, 1);
    try testing.expectEqual(@as(usize, 5), menu_win.cursor);
    try testing.expectEqualStrings("f", menu_win.selected().?);

    var selected_idx: usize = 999;
    var selected_key: u8 = 0;
    var aborted = false;
    var backed = false;
    const Cbs = struct {
        selected_idx: *usize,
        selected_key: *u8,
        aborted: *bool,
        backed: *bool,
        fn onSelect(m: *MenuWindow, cursor: usize, object: ?*anyopaque, key: u8) i32 {
            _ = m;
            const ctx: *@This() = @ptrCast(@alignCast(object.?));
            ctx.selected_idx.* = cursor;
            ctx.selected_key.* = key;
            return 0;
        }
        fn onAbort(target: screen.WindowId, cursor: usize, object: ?*anyopaque) i32 {
            _ = target;
            _ = cursor;
            const ctx: *@This() = @ptrCast(@alignCast(object.?));
            ctx.aborted.* = true;
            return 0;
        }
        fn onBacks(m: *MenuWindow, cursor: usize, object: ?*anyopaque) i32 {
            _ = m;
            _ = cursor;
            const ctx: *@This() = @ptrCast(@alignCast(object.?));
            ctx.backed.* = true;
            return 1;
        }
    };
    var ctx = Cbs{
        .selected_idx = &selected_idx,
        .selected_key = &selected_key,
        .aborted = &aborted,
        .backed = &backed,
    };
    menu_win.object = &ctx;
    menu_win.on_select = Cbs.onSelect;
    menu_win.on_abort = Cbs.onAbort;
    menu_win.on_backs = Cbs.onBacks;

    try testing.expectEqual(@as(i32, 0), menu_win.select('\r'));
    try testing.expectEqual(@as(usize, 5), selected_idx);
    try testing.expectEqual(@as(u8, '\r'), selected_key);
    try testing.expectEqual(@as(i32, 0), menu_win.abort());
    try testing.expect(aborted);
    try testing.expectEqual(@as(i32, 1), menu_win.backs());
    try testing.expect(backed);
    try testing.expectEqualStrings("", menu_win.complete()); // a..f share no prefix
}

test "MenuRegistry create/find/labels" {
    var reg = MenuRegistry.init(testing.allocator);
    defer reg.deinit();

    const opts = try reg.create("options", null);
    try opts.addEntry(testing.allocator, "Wrap", @ptrFromInt(1));
    try opts.addEntry(testing.allocator, "Autoindent", @ptrFromInt(2));
    try testing.expectEqual(@as(usize, 2), opts.size());

    // Same name returns existing.
    const again = try reg.create("options", null);
    try testing.expect(again == opts);

    const search = try reg.create("search", null);
    try search.addEntry(testing.allocator, "Find", null);

    const found = reg.find("search");
    try testing.expect(found != null);
    try testing.expectEqualStrings("search", found.?.name);

    const labs = try opts.labels(testing.allocator);
    defer opts.freeLabels(testing.allocator, labs);
    try testing.expectEqual(@as(usize, 2), labs.len);
    try testing.expectEqualStrings("Wrap", labs[0]);

    const nms = try reg.names(testing.allocator);
    defer reg.freeNames(testing.allocator, nms);
    try testing.expectEqual(@as(usize, 2), nms.len);
    try testing.expectEqualStrings("options", nms[0]);
    try testing.expectEqualStrings("search", nms[1]);

    // Drive a MenuWindow from rc labels.
    var scr = try screen.Screen.init(testing.allocator, 40, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    var menu_win = MenuWindow.init(win, labs, opts.last_position);
    try testing.expectEqualStrings("Wrap", menu_win.selected().?);
    try testing.expectEqual(@as(i32, 0), menu_win.moveRight());
    try testing.expectEqualStrings("Autoindent", menu_win.selected().?);
    opts.last_position = menu_win.cursor;
    try testing.expectEqual(@as(usize, 1), opts.last_position);
}

test "MenuWindow paintField pads and truncates" {
    var buf: [5]u8 = undefined;
    paintField(&buf, "ab");
    try testing.expectEqualStrings("ab   ", &buf);
    paintField(&buf, "abcdef");
    try testing.expectEqualStrings("abcde", &buf);
}

test "MenuWindow paint rows and inverse selection" {
    var scr = try screen.Screen.init(testing.allocator, 20, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    win.w = 11;
    win.h = 2;

    // width=1 ⇒ fitline=5 (11/(1+1)=5), items a..f ⇒ 2 rows visible.
    const items = [_][]const u8{ "a", "b", "c", "d", "e", "f" };
    var menu_win = MenuWindow.init(win, &items, 0);
    try testing.expectEqual(@as(usize, 1), menu_win.grid.width);
    try testing.expectEqual(@as(usize, 5), menu_win.grid.perline);

    var painted = try menu_win.paint(testing.allocator, true);
    defer painted.deinit();
    try testing.expectEqualStrings("a b c d e  ", painted.rowSlice(0));
    try testing.expectEqualStrings("f          ", painted.rowSlice(1));
    try testing.expect(painted.isInverse(0, 0)); // 'a' selected
    try testing.expect(!painted.isInverse(2, 0)); // 'b'
    try testing.expectEqual(@as(usize, 1), painted.cur.x); // end of "a"
    try testing.expectEqual(@as(usize, 0), painted.cur.y);

    _ = menu_win.moveRight();
    var painted2 = try menu_win.paint(testing.allocator, true);
    defer painted2.deinit();
    try testing.expect(!painted2.isInverse(0, 0));
    try testing.expect(painted2.isInverse(2, 0)); // 'b'
    try testing.expectEqual(@as(usize, 3), painted2.cur.x);
    try testing.expectEqual(@as(usize, 0), painted2.cur.y);

    // Unfocused ⇒ no inverse highlight.
    var painted3 = try menu_win.paint(testing.allocator, false);
    defer painted3.deinit();
    try testing.expect(!painted3.isInverse(2, 0));
}

test "MenuWindow cursorPos transpose" {
    var scr = try screen.Screen.init(testing.allocator, 20, 24);
    defer scr.deinit();
    const win = try scr.createText(null, null, 24);
    win.w = 11;
    win.h = 3;

    const items = [_][]const u8{ "a", "b", "c", "d", "e", "f" };
    var menu_win = MenuWindow.init(win, &items, 0);
    menu_win.transpose = true;
    menu_win.configure();
    menu_win.follow();
    // lines = ceil(6/5)=2, perline = ceil(6/2)=3
    try testing.expectEqual(@as(usize, 2), menu_win.grid.lines);
    menu_win.cursor = 2; // column 1, row 0 ⇒ ndx = 1*2+0 = 2 ('c')
    menu_win.follow();
    const cur = menu_win.cursorPos();
    try testing.expectEqual(@as(usize, 0), cur.y);
    try testing.expectEqual(@as(usize, (2 / 2) * (1 + 1) + 1), cur.x);
}

