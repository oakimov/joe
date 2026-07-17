//! Bytecode fragment construction — replaces `joe/frag.c`.
//!
//! A `Frag` is a growable byte buffer used to assemble macro bytecode
//! with alignment padding.  Multi-byte emits align before and after.

const std = @import("std");

extern fn joe_malloc(size: isize) ?*anyopaque;
extern fn joe_realloc(ptr: ?*anyopaque, size: isize) ?*anyopaque;
extern fn joe_free(ptr: ?*anyopaque) void;
extern fn mcpy(a: ?*anyopaque, b: ?*const anyopaque, len: isize) ?*anyopaque;

const Frag = extern struct {
    start: ?[*]u8,
    len: isize,
    size: isize,
    align_: isize,
};

/// align_o(p, size) = ((size-1) & -(ptrdiff_t)p)
fn align_o(p: isize, size: isize) isize {
    return (size - 1) & (-p);
}

fn fragByte(f: *Frag, ofst: isize) *u8 {
    return &f.start.?[ @as(usize, @intCast(ofst)) ];
}
fn fragShort(f: *Frag, ofst: isize) *c_short {
    return @alignCast(@ptrCast(&f.start.?[ @as(usize, @intCast(ofst)) ]));
}
fn fragInt(f: *Frag, ofst: isize) *c_int {
    return @alignCast(@ptrCast(&f.start.?[ @as(usize, @intCast(ofst)) ]));
}
fn fragDouble(f: *Frag, ofst: isize) *f64 {
    return @alignCast(@ptrCast(&f.start.?[ @as(usize, @intCast(ofst)) ]));
}
fn fragPtr(f: *Frag, ofst: isize) *?*anyopaque {
    return @alignCast(@ptrCast(&f.start.?[ @as(usize, @intCast(ofst)) ]));
}

export fn iz_frag(f: *Frag, alignment: isize) void {
    f.size = 1024;
    f.start = @ptrCast(joe_malloc(f.size) orelse return);
    f.len = 0;
    f.align_ = alignment;
}

export fn fin_code(f: *Frag) void {
    f.start = @ptrCast(joe_realloc(@ptrCast(f.start), f.len) orelse return);
    f.size = f.len;
}

export fn clr_frag(f: *Frag) void {
    joe_free(@ptrCast(f.start));
}

fn expand_frag(frag: *Frag, size: isize) void {
    if ((frag.size >> 1) > size) {
        frag.size = frag.size + (frag.size >> 1);
    } else {
        frag.size += frag.size + (frag.size >> 1);
    }
    frag.start = @ptrCast(joe_realloc(@ptrCast(frag.start), frag.size) orelse return);
}

export fn emitb_noalign(f: *Frag, c: u8) isize {
    if (f.len + 1 > f.size) expand_frag(f, 1);
    const start = f.len;
    f.start.?[ @as(usize, @intCast(f.len)) ] = c;
    f.len += 1;
    return start;
}

export fn align_frag(f: *Frag, alignment: isize) void {
    const add = align_o(f.len, alignment);
    var x: isize = 0;
    while (x != add) : (x += 1) _ = emitb_noalign(f, '-');
}

export fn emitb(f: *Frag, c: u8) isize {
    const ofst = emitb_noalign(f, c);
    if ((f.len & (f.align_ - 1)) != 0) align_frag(f, f.align_);
    return ofst;
}

export fn emith(f: *Frag, c: c_short) isize {
    if ((f.len & (@sizeOf(c_short) - 1)) != 0) align_frag(f, @sizeOf(c_short));
    if (f.len + @sizeOf(c_short) > f.size) expand_frag(f, @sizeOf(c_short));
    const start = f.len;
    fragShort(f, f.len).* = c;
    f.len += @sizeOf(c_short);
    if ((f.len & (f.align_ - 1)) != 0) align_frag(f, f.align_);
    return start;
}

export fn emiti(f: *Frag, c: c_int) isize {
    if ((f.len & (@sizeOf(c_int) - 1)) != 0) align_frag(f, @sizeOf(c_int));
    if (f.len + @sizeOf(c_int) > f.size) expand_frag(f, @sizeOf(c_int));
    const start = f.len;
    fragInt(f, f.len).* = c;
    f.len += @sizeOf(c_int);
    if ((f.len & (f.align_ - 1)) != 0) align_frag(f, f.align_);
    return start;
}

export fn emitd(f: *Frag, d: f64) isize {
    if ((f.len & (@sizeOf(f64) - 1)) != 0) align_frag(f, @sizeOf(f64));
    if (f.len + @sizeOf(f64) > f.size) expand_frag(f, @sizeOf(f64));
    const start = f.len;
    fragDouble(f, f.len).* = d;
    f.len += @sizeOf(f64);
    if ((f.len & (f.align_ - 1)) != 0) align_frag(f, f.align_);
    return start;
}

export fn emitp(f: *Frag, p: ?*anyopaque) isize {
    if ((f.len & (@sizeOf(?*anyopaque) - 1)) != 0) align_frag(f, @sizeOf(?*anyopaque));
    if (f.len + @sizeOf(?*anyopaque) > f.size) expand_frag(f, @sizeOf(?*anyopaque));
    const start = f.len;
    fragPtr(f, f.len).* = p;
    f.len += @sizeOf(?*anyopaque);
    if ((f.len & (f.align_ - 1)) != 0) align_frag(f, f.align_);
    return start;
}

export fn emits(f: *Frag, s: ?[*]const u8, len: c_int) isize {
    const start = emiti(f, len);
    if (f.len + @as(isize, @intCast(len)) + 1 > f.size) expand_frag(f, @as(isize, @intCast(len)) + 1);
    if (len != 0) _ = mcpy(@ptrCast(&f.start.?[ @as(usize, @intCast(f.len)) ]), @ptrCast(s), @intCast(len));
    f.start.?[ @as(usize, @intCast(f.len + @as(isize, @intCast(len)))) ] = 0;
    f.len += @as(isize, @intCast(len)) + 1;
    if ((f.len & (f.align_ - 1)) != 0) align_frag(f, f.align_);
    return start;
}

export fn emit_branch(f: *Frag, target: isize) isize {
    const ofst = emiti(f, 0);
    fragInt(f, ofst).* = @intCast(target - ofst);
    return ofst;
}

export fn fixup_branch(f: *Frag, pos: isize) void {
    align_frag(f, @sizeOf(c_int));
    fragInt(f, pos).* = @intCast(f.len - pos);
}

export fn frag_link(f: *Frag, chain_in: isize) void {
    var chain = chain_in;
    align_frag(f, @sizeOf(c_int));
    const ket = f.len;
    while (chain != 0) {
        const next = fragInt(f, chain).*;
        fragInt(f, chain).* = @intCast(ket - chain);
        chain = next;
    }
}

export fn fetchh(f: *Frag, pcp: *isize) c_short {
    var pc = pcp.*;
    pc += align_o(pc, @sizeOf(c_short));
    const i = fragShort(f, pc).*;
    pc += @sizeOf(c_short);
    if ((pc & (f.align_ - 1)) != 0) pc += align_o(pc, f.align_);
    pcp.* = pc;
    return i;
}

export fn fetchi(f: *Frag, pcp: *isize) c_int {
    var pc = pcp.*;
    pc += align_o(pc, @sizeOf(c_int));
    const i = fragInt(f, pc).*;
    pc += @sizeOf(c_int);
    if ((pc & (f.align_ - 1)) != 0) pc += align_o(pc, f.align_);
    pcp.* = pc;
    return i;
}

export fn fetchp(f: *Frag, pcp: *isize) ?*anyopaque {
    var pc = pcp.*;
    pc += align_o(pc, @sizeOf(?*anyopaque));
    const p = fragPtr(f, pc).*;
    pc += @sizeOf(?*anyopaque);
    if ((pc & (f.align_ - 1)) != 0) pc += align_o(pc, f.align_);
    pcp.* = pc;
    return p;
}
