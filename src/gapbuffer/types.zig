//! C-compatible type definitions for the JOE gap buffer subsystem.
//! Mirrors `joe/b.h`, `joe/queue.h`, etc.

const std = @import("std");

// ═══════════════════════════════════════════════════════════════════════
// Constants
// ═══════════════════════════════════════════════════════════════════════

pub const stdsiz: isize = 31744;
pub const SEGSIZ: c_int = 4096;
pub const ANSI_BIT: c_int = @bitCast(@as(u32, 0x80000000));
pub const ANSIMAX: c_int = 64;
pub const NO_MORE_DATA: c_int = -256;

// ═══════════════════════════════════════════════════════════════════════
// External C functions called by the gap buffer code
// ═══════════════════════════════════════════════════════════════════════

extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn joe_realloc(ptr: ?*anyopaque, size: isize) ?*anyopaque;
extern fn joe_free(ptr: ?*anyopaque) void;
extern fn joe_read(fd: c_int, buf: ?*anyopaque, siz: isize) isize;
extern fn joe_write(fd: c_int, buf: ?*const anyopaque, siz: isize) isize;

pub extern fn mset(dest: ?*anyopaque, c: u8, sz: isize) ?*anyopaque;
pub extern fn mcpy(a: ?*anyopaque, b: ?*const anyopaque, len: isize) ?*anyopaque;
pub extern fn mmove(d: ?*anyopaque, s: ?*const anyopaque, sz: isize) ?*anyopaque;

extern fn ttsig(sig: c_int) void;
pub extern fn open(path: [*c]const u8, flags: c_int, ...) c_int;
pub extern fn close(fd: c_int) c_int;
extern fn lseek(fd: c_int, offset: i64, whence: c_int) i64;
extern fn unlink(path: [*c]const u8) c_int;
extern fn read(fd: c_int, buf: ?*anyopaque, count: usize) isize;
extern fn write(fd: c_int, buf: ?*const anyopaque, count: usize) isize;
extern fn exit(status: c_int) noreturn;
extern fn time(t: ?*i64) i64;

// VFILE functions
pub extern fn vlock(vfile: ?*anyopaque, addr: i64) ?*anyopaque;
pub extern fn vtmp() ?*anyopaque;
pub extern fn my_valloc(vfile: ?*anyopaque, size: i64) i64;

// VFILE globals used by C macros
pub extern var vbase: ?*anyopaque;
pub extern var vheaders: ?*anyopaque;

// Queue helpers (defined in queue.c)
extern fn alitem(list: ?*anyopaque, itemsize: isize) ?*anyopaque;

// Undo
extern fn undomk(b: ?*anyopaque) ?*anyopaque;
extern fn undorm(undo: ?*anyopaque) void;
extern fn undodel(undo: ?*anyopaque, pos: i64, b: ?*anyopaque) void;
extern fn undoins(undo: ?*anyopaque, p: ?*anyopaque, amnt: i64) void;

// Screen update / error reporting
extern fn scrdel(b: ?*anyopaque, line: i64, nlines: i64, purg: c_int) void;
extern fn scrins(b: ?*anyopaque, line: i64, nlines: i64, purg: c_int) void;
extern fn abrerr(name: ?*anyopaque) void;
extern fn inserr(name: ?*anyopaque, line: i64, nlines: i64, purg: c_int) void;
extern fn delerr(name: ?*anyopaque, line: i64, nlines: i64, purg: c_int) void;

// Line attribute DB
extern fn reset_all_lattr_db(db: ?*anyopaque) void;
extern fn rm_all_lattr_db(db: ?*anyopaque) void;
extern fn lattr_ins(db: ?*anyopaque, line: i64, nlines: i64) void;
extern fn lattr_del(db: ?*anyopaque, line: i64, nlines: i64) void;

// Path helpers
extern fn set_file_pos(name: [*c]const u8, line: i64) void;

// Hash table (for ansi_code/ansi_string)
extern fn htmk(size: c_int) ?*anyopaque;
extern fn htfind(t: ?*anyopaque, s: [*c]const u8) ?*anyopaque;
extern fn htadd(t: ?*anyopaque, s: [*c]const u8, v: ?*anyopaque) void;

// Unicode (still C for now)

// libc
pub extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;

// ═══════════════════════════════════════════════════════════════════════
// C-compatible structs
// ═══════════════════════════════════════════════════════════════════════

/// Doubly-linked list link (LINK macro)
pub const Link = extern struct {
    next: ?*anyopaque,
    prev: ?*anyopaque,
};

/// Gap buffer header — C `struct header`
pub const H = extern struct {
    link: Link,     // 16
    seg: i64,       // 8
    hole: c_short,  // 2
    ehole: c_short, // 2
    nlines: c_short, // 2
    extra: c_short, // 2
};

comptime {
    assert(@sizeOf(H) == 32);
}

/// Partial charmap header matching C `struct charmap` prefix.
/// Full struct lives in C; Zig only needs next/name/type for UTF-8 branching.
pub const Charmap = extern struct {
    next: ?*Charmap,
    name: ?[*:0]const u8,
    @"type": c_int, // 0=byte, 1=UTF-8
};

/// Options — C `struct options`
pub const OPTIONS = extern struct {
    next: ?*OPTIONS,
    ftype: ?*anyopaque,
    match: ?*anyopaque,
    overtype: c_int,
    _pad0: c_int,
    lmargin: i64,
    rmargin: i64,
    autoindent: c_int,
    wordwrap: c_int,
    nobackup: c_int,
    _pad1: c_int,
    tab: i64,
    indentc: c_int,
    _pad2: c_int,
    istep: i64,
    context: ?*anyopaque,
    lmsg: ?*anyopaque,
    rmsg: ?*anyopaque,
    smsg: ?*anyopaque,
    zmsg: ?*anyopaque,
    linums: c_int,
    hiline: c_int,
    readonly: c_int,
    french: c_int,
    flowed: c_int,
    spaces: c_int,
    crlf: c_int,
    highlight: c_int,
    visiblews: c_int,
    syntax_debug: c_int,
    syntax_name: ?*anyopaque,
    syntax: ?*anyopaque,
    map_name: ?*anyopaque,
    charmap: ?*Charmap,
    language: ?*anyopaque,
    smarthome: c_int,
    indentfirst: c_int,
    smartbacks: c_int,
    purify: c_int,
    picture: c_int,
    highlighter_context: c_int,
    single_quoted: c_int,
    no_double_quoted: c_int,
    c_comment: c_int,
    cpp_comment: c_int,
    hash_comment: c_int,
    vhdl_comment: c_int,
    semi_comment: c_int,
    tex_comment: c_int,
    hex: c_int,
    viewmode: c_int,
    ansi: c_int,
    title: c_int,
    text_delimiters: ?*anyopaque,
    cpara: ?*anyopaque,
    cnotpara: ?*anyopaque,
    mnew: ?*anyopaque,
    mold: ?*anyopaque,
    msnew: ?*anyopaque,
    msold: ?*anyopaque,
    mfirst: ?*anyopaque,
};

comptime {
    assert(@sizeOf(OPTIONS) == 344);
}

/// Pointer into a buffer — C `struct point`
pub const P = extern struct {
    link: Link,
    b: ?*B,
    ofst: c_short,
    _pad0: [6]u8,
    ptr: ?*anyopaque,
    hdr: ?*H,
    byte: i64,
    line: i64,
    col: i64,
    xcol: i64,
    valcol: c_int,
    end: c_int,
    attr: c_int,
    valattr: c_int,
    owner: ?*?*P,
    tracker: ?*const anyopaque,
};

comptime {
    assert(@sizeOf(P) == 112);
}

/// Buffer — C `struct buffer`
pub const B = extern struct {
    link: Link,
    bof: ?*P,
    eof: ?*P,
    name: ?*anyopaque,
    locked: c_int,
    ignored_lock: c_int,
    didfirst: c_int,
    _pad0: c_int,
    mod_time: i64,
    check_time: i64,
    gave_notice: c_int,
    orphan: c_int,
    count: c_int,
    changed: c_int,
    backup: c_int,
    _pad1: c_int,
    undo: ?*anyopaque,
    marks: [11]?*P,
    o: OPTIONS,
    oldcur: ?*P,
    oldtop: ?*P,
    err: ?*P,
    current_dir: ?*anyopaque,
    shell_flag: c_int,
    rdonly: c_int,
    internal: c_int,
    scratch: c_int,
    er: c_int,
    pid: c_int,
    out: c_int,
    vt: ?*anyopaque,
    raw: c_int,
    _pad2: c_int,
    db: ?*anyopaque,
    parseone: ?*anyopaque,
};

comptime {
    assert(@sizeOf(B) == 632);
}

fn assert(v: bool) void {
    if (!v) @compileError("struct size mismatch");
}