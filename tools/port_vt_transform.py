#!/usr/bin/env python3
"""Prepare joe/vt.c for zig translate-c (goto-free).

Writes /tmp/vt_stubs.h and /tmp/vt_nogoto.c.

Pipeline (from a revision that still has the C body):
  python3 tools/port_vt_transform.py
  zig translate-c /tmp/vt_nogoto.c -I /tmp -lc > /tmp/vt_raw.zig
  python3 tools/clean_translate_c.py /tmp/vt_raw.zig src/vt.zig \\
    --title 'Terminal emulator — replaces `joe/vt.c`.' \\
    --blurb 'Faithful C-ABI Path A port of JOE vt (mkvt/vtrm/vt_data/vt_resize).'
  # Then: inject BOLD/FG_SHIFT/… consts; Zig 0.16 array-field index via
  # @as([*]T, @ptrCast(&vt.*.buf|argv))[i]; comptime sizeof/offset checks.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/vt.c"
OUT = Path("/tmp/vt_nogoto.c")
STUBS_OUT = Path("/tmp/vt_stubs.h")


def main() -> None:
    stubs = (HERE / "vt_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    if "REMOVED from the live link" in src:
        raise SystemExit("joe/vt.c is already a tombstone; restore C body from git to re-run")
    src = src.replace('#include "types.h"\n', "")

    # No real gotos in vt.c — only comments / p_goto_* names.
    # Reject bare `goto` statements; allow "goto" inside comments/strings.
    real_gotos = [
        f"{i}:{line.rstrip()}"
        for i, line in enumerate(src.splitlines(), 1)
        if re.search(r"(?m)^\s*goto\b", line)
    ]
    if real_gotos:
        raise SystemExit(f"goto remains: {real_gotos}")

    header = (
        "/* vt.c for zig translate-c (goto-free) */\n"
        '#include "vt_stubs.h"\n\n'
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
