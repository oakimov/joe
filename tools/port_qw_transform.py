#!/usr/bin/env python3
"""Transform joe/qw.c into goto-free form for zig translate-c.

Writes /tmp/qw_stubs.h and /tmp/qw_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/qw.c"
OUT = Path("/tmp/qw_nogoto.c")
STUBS_OUT = Path("/tmp/qw_stubs.h")


def main() -> None:
    stubs = (HERE / "qw_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")

    if re.search(r"(?m)^\s*goto\b", src):
        hits = [
            f"{i}:{line.rstrip()}"
            for i, line in enumerate(src.splitlines(), 1)
            if re.search(r"^\s*goto\b", line)
        ]
        raise SystemExit(f"goto remains: {hits}")

    header = (
        "/* qw.c for zig translate-c (goto-free) */\n"
        '#include "qw_stubs.h"\n\n'
        "static ptrdiff_t break_height(struct charmap *map, const char **src, "
        "ptrdiff_t *src_len, ptrdiff_t wid, ptrdiff_t n);\n"
        "static void dispqw(W *w, int flg);\n"
        "static void dispqwn(W *w, int flg);\n"
        "static int utypeqw(W *w, int c);\n"
        "static int abortqw(W *w);\n\n"
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
