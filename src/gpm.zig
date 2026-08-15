//! Linux console GPM mouse — Path A helpers for `joe/mouse.h` (`MOUSE_GPM`).
//!
//! Always exports `gpmopen` / `gpmclose` (stubs return 0 / no-op) so the ABI
//! exists when `MOUSE_GPM` is set. Real libgpm only when Linux + `-Dgpm=true`.

const builtin = @import("builtin");
const build_options = @import("build_options");

const with_gpm = builtin.os.tag == .linux and build_options.gpm;

const Impl = if (with_gpm) struct {
    const Gpm_Connect = extern struct {
        eventMask: c_ushort = 0,
        defaultMask: c_ushort = 0,
        minMod: c_ushort = 0,
        maxMod: c_ushort = 0,
    };

    // GPM_HARD from gpm.h — exclude hard-handled events from default mask.
    const GPM_HARD: c_ushort = 128;

    extern fn Gpm_Open(conn: *Gpm_Connect, flag: c_int) c_int;
    extern fn Gpm_Close() void;

    var opened: bool = false;

    pub fn open() c_int {
        var conn = Gpm_Connect{
            .eventMask = 0xffff,
            .defaultMask = ~GPM_HARD,
            .minMod = 0,
            .maxMod = 0xffff,
        };
        // Gpm_Open returns fd (>=0) on success, -1 on failure.
        if (Gpm_Open(&conn, 0) < 0) return 0;
        opened = true;
        return 1;
    }

    pub fn close() void {
        if (!opened) return;
        Gpm_Close();
        opened = false;
    }
} else struct {
    pub fn open() c_int {
        return 0;
    }
    pub fn close() void {}
};

/// Initialize GPM. Returns 0 on failure, non-zero on success (matches `mouse.h`).
export fn gpmopen() c_int {
    return Impl.open();
}

export fn gpmclose() void {
    Impl.close();
}
