//! Path A live port of JOE SELinux helpers (`joe/selinux.c`).
//!
//! Default / non-Linux / `-Dselinux=false`: no-op exports (return 0).
//! Linux + `-Dselinux=true`: real libselinux wrappers matching historical C.
//! `joe/selinux.c` is a tombstone; `joe/selinux.h` remains the declaration surface.

const builtin = @import("builtin");
const build_options = @import("build_options");

const with_selinux = builtin.os.tag == .linux and build_options.selinux;

const Impl = if (with_selinux) struct {
    const security_context_t = [*c]u8;

    extern fn is_selinux_enabled() c_int;
    extern fn getfilecon(path: [*c]const u8, con: *security_context_t) c_int;
    extern fn setfilecon(path: [*c]const u8, con: security_context_t) c_int;
    extern fn setfscreatecon(con: security_context_t) c_int;
    extern fn freecon(con: security_context_t) void;
    extern fn __errno_location() [*c]c_int;
    extern fn strcmp(a: [*c]const u8, b: [*c]const u8) c_int;
    extern fn strerror(errnum: c_int) [*c]u8;
    extern fn dprintf(fd: c_int, fmt: [*:0]const u8, ...) c_int;

    var selinux_enabled: c_int = -1;

    fn errnoVal() c_int {
        return __errno_location().*;
    }

    // Linux EOPNOTSUPP — match C errno handling for xattr-incapable filesystems.
    const EOPNOTSUPP: c_int = 95;

    fn enabled() bool {
        if (selinux_enabled == -1) {
            selinux_enabled = if (is_selinux_enabled() > 0) 1 else 0;
        }
        return selinux_enabled != 0;
    }

    pub fn copy(from_file: [*c]const u8, to_file: [*c]const u8) c_int {
        var status: c_int = 0;
        if (!enabled()) return 0;

        var from_context: security_context_t = undefined;
        var to_context: security_context_t = undefined;

        if (getfilecon(from_file, &from_context) < 0) {
            if (errnoVal() == EOPNOTSUPP) return 0;
            _ = dprintf(2, "Could not get security context for %s: %s\n", from_file, strerror(errnoVal()));
            return 1;
        }

        if (getfilecon(to_file, &to_context) < 0) {
            _ = dprintf(2, "Could not get security context for %s: %s\n", to_file, strerror(errnoVal()));
            freecon(from_context);
            return 1;
        }

        if (strcmp(from_context, to_context) != 0) {
            if (setfilecon(to_file, from_context) < 0) {
                _ = dprintf(2, "Could not set security context for %s: %s\n", to_file, strerror(errnoVal()));
                status = 1;
            }
        }

        freecon(to_context);
        freecon(from_context);
        return status;
    }

    pub fn matchDefault(from_file: [*c]const u8) c_int {
        if (!enabled()) return 0;

        var scontext: security_context_t = undefined;
        if (getfilecon(from_file, &scontext) < 0) {
            if (errnoVal() == EOPNOTSUPP) return 0;
            _ = dprintf(2, "Could not get security context for %s: %s\n", from_file, strerror(errnoVal()));
            return 1;
        }

        if (setfscreatecon(scontext) < 0) {
            _ = dprintf(2, "Could not set default security context for %s: %s\n", from_file, strerror(errnoVal()));
            freecon(scontext);
            return 1;
        }
        freecon(scontext);
        return 0;
    }

    pub fn resetDefault() c_int {
        if (!enabled()) return 0;
        if (setfscreatecon(null) < 0) {
            _ = dprintf(2, "Could not reset default security context: %s\n", strerror(errnoVal()));
            return 1;
        }
        return 0;
    }

    pub fn output(from_file: [*c]const u8) c_int {
        if (!enabled()) return 0;

        var scontext: security_context_t = undefined;
        if (getfilecon(from_file, &scontext) < 0) {
            if (errnoVal() == EOPNOTSUPP) return 0;
            _ = dprintf(2, "Could not get security context for %s: %s\n", from_file, strerror(errnoVal()));
            return 1;
        }

        _ = dprintf(2, "%s Security Context %s\n", from_file, scontext);
        freecon(scontext);
        return 0;
    }
} else struct {
    pub fn copy(from_file: [*c]const u8, to_file: [*c]const u8) c_int {
        _ = from_file;
        _ = to_file;
        return 0;
    }
    pub fn matchDefault(from_file: [*c]const u8) c_int {
        _ = from_file;
        return 0;
    }
    pub fn resetDefault() c_int {
        return 0;
    }
    pub fn output(from_file: [*c]const u8) c_int {
        _ = from_file;
        return 0;
    }
};

export fn copy_security_context(from_file: [*c]const u8, to_file: [*c]const u8) c_int {
    return Impl.copy(from_file, to_file);
}

export fn match_default_security_context(from_file: [*c]const u8) c_int {
    return Impl.matchDefault(from_file);
}

export fn reset_default_security_context() c_int {
    return Impl.resetDefault();
}

export fn output_security_context(from_file: [*c]const u8) c_int {
    return Impl.output(from_file);
}
