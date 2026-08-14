#!/usr/bin/env python3
"""Prepare joe/help.c for zig translate-c (no gotos).

Writes /tmp/help_stubs.h and /tmp/help_nogoto.c.
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/help.c"
OUT = Path("/tmp/help_nogoto.c")
STUBS_OUT = Path("/tmp/help_stubs.h")


def main() -> None:
    stubs = (HERE / "help_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")

    # Forward decl for statics
    forward = """
static struct help *find_context_help(const char *name);
static void help_off(Screen *t);

"""
    marker = "int bg_help;	/* Background color for help */\n"
    idx = src.find(marker)
    if idx < 0:
        raise SystemExit("bg_help marker not found")
    insert_at = idx + len(marker)
    src = src[:insert_at] + forward + src[insert_at:]

    header = (
        "/* help.c for zig translate-c */\n"
        '#include "help_stubs.h"\n\n'
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
