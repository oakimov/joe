//! Path A live port of JOE SELinux helpers (`joe/selinux.c`).
//!
//! `WITH_SELINUX` is unset in this hybrid build, so these are no-ops matching C.
//! `joe/selinux.c` is a tombstone; `joe/selinux.h` remains the declaration surface.

export fn copy_security_context(from_file: [*c]const u8, to_file: [*c]const u8) c_int {
    _ = from_file;
    _ = to_file;
    return 0;
}

export fn match_default_security_context(from_file: [*c]const u8) c_int {
    _ = from_file;
    return 0;
}

export fn reset_default_security_context() c_int {
    return 0;
}

export fn output_security_context(from_file: [*c]const u8) c_int {
    _ = from_file;
    return 0;
}
