#!/usr/bin/env python3
"""Transform joe/mmenu.c into goto-free form for zig translate-c."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/mmenu.c"
OUT = Path("/tmp/mmenu_nogoto.c")
STUBS_OUT = Path("/tmp/mmenu_stubs.h")


def main() -> None:
    stubs = (HERE / "mmenu_stubs.h").read_text()
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
        "/* mmenu.c for zig translate-c (goto-free) */\n"
        '#include "mmenu_stubs.h"\n\n'
        "static struct rc_menu *find_menu(char *s);\n"
        "static int backsmenu(MENU *m, ptrdiff_t x, void *obj);\n"
        "static int doabrt(W *w, ptrdiff_t x, void *obj);\n"
        "static int execmenu(MENU *m, ptrdiff_t x, void *obj, int flg);\n"
        "static int display_menu(BW *bw, struct rc_menu *menu, int *notify);\n"
        "static char **getmenus(void);\n"
        "static int menucmplt(BW *bw, int k);\n"
        "static int domenu(W *w, char *s, void *object, int *notify);\n\n"
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
