#!/usr/bin/env python3
"""Transform joe/pw.c into goto-free form for zig translate-c.

Writes /tmp/pw_stubs.h and /tmp/pw_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/pw.c"
OUT = Path("/tmp/pw_nogoto.c")
STUBS_OUT = Path("/tmp/pw_stubs.h")


def main() -> None:
    stubs = (HERE / "pw_stubs.h").read_text()
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
        "/* pw.c for zig translate-c (goto-free) */\n"
        '#include "pw_stubs.h"\n\n'
        "static void disppw(W *w, int flg);\n"
        "static int rtnpw(W *w);\n"
        "static void inspw(W *w, B *b, off_t l, off_t n, int flg);\n"
        "static void delpw(W *w, B *b, off_t l, off_t n, int flg);\n"
        "static int abortpw(W *w);\n"
        "static void p_goto_bow(P *ptr);\n"
        "static void p_goto_eow(P *ptr);\n"
        "static void word_ins(BW *bw, char *line);\n"
        "static int word_rtn(MENU *m, ptrdiff_t x, void *object, int k);\n\n"
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
