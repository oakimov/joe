#!/usr/bin/env python3
"""Transform joe/menu.c into goto-free form for zig translate-c.

Writes /tmp/menu_stubs.h and /tmp/menu_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/menu.c"
OUT = Path("/tmp/menu_nogoto.c")
STUBS_OUT = Path("/tmp/menu_stubs.h")


def main() -> None:
    stubs = (HERE / "menu_stubs.h").read_text()
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
        "/* menu.c for zig translate-c (goto-free) */\n"
        '#include "menu_stubs.h"\n\n'
        "static void menufllw(W *w);\n"
        "static void menudisp(W *w, int flg);\n"
        "static void menumove(W *w, ptrdiff_t x, ptrdiff_t y);\n"
        "static ptrdiff_t mlines(char **s, ptrdiff_t w);\n"
        "static void mconfig(MENU *m);\n"
        "static void menuresz(W *w, ptrdiff_t wi, ptrdiff_t he);\n"
        "static int mscrup(MENU *m, ptrdiff_t amnt);\n"
        "static int mscrdn(MENU *m, ptrdiff_t amnt);\n"
        "static int umrtn(W *w);\n"
        "static int menufold(int c);\n"
        "static int umkey(W *w, int c);\n"
        "static int menuabort(W *w);\n"
        "static char *cull(char *a, char *b);\n\n"
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
