//! Gap buffer — replaces `joe/b.c`
//!
//! Collector module.  All C‑ABI exports and exported globals live in the
//! submodules under `gapbuffer/`; this file just imports them so they are
//! compiled and linked.  Layout:
//!
//!   types.zig   — C‑compatible struct definitions + constants
//!   intern.zig  — exported globals, queue primitives, gap primitives, alloc
//!   ansi.zig    — interned ANSI escape sequence cache
//!   pointer.zig — P creation / movement / predicates / read access
//!   search.zig  — Boyer‑Moore find (forward/backward, case‑[in]sensitive)
//!   buffer.zig  — B creation / destruction / copy / delete / insert
//!   fileio.zig  — bload / bread / bsave / bfind / ttsig / locks

const std = @import("std");

comptime {
    _ = @import("gapbuffer/types.zig");
    _ = @import("gapbuffer/intern.zig");
    _ = @import("gapbuffer/ansi.zig");
    _ = @import("gapbuffer/pointer.zig");
    _ = @import("gapbuffer/search.zig");
    _ = @import("gapbuffer/buffer.zig");
    _ = @import("gapbuffer/fileio.zig");
}
