#!/usr/bin/env python3
"""Transform joe/w.c into goto-free form for zig translate-c.

Writes /tmp/w_stubs.h and /tmp/w_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/w.c"
OUT = Path("/tmp/w_nogoto.c")
STUBS_OUT = Path("/tmp/w_stubs.h")




def fix_comma_for_loops(src: str) -> str:
    """Rewrite for-loops with comma operators that zig translate-c mishandles."""
    src = src.replace(
        """\tfor (w = x, h = geth(w); w->link.next != x && w->link.next->main == x->main; w = w->link.next, h += geth(w)) ;""",
        """\tw = x;\n\th = geth(w);\n\twhile (w->link.next != x && w->link.next->main == x->main) {\n\t\tw = w->link.next;\n\t\th += geth(w);\n\t}""",
    )
    src = src.replace(
        """\tfor (w = x, h = getminhthis(w);\n\t     w->link.next != x && w->link.next->main == x->main;\n\t     w = w->link.next, h += getminhthis(w)) ;""",
        """\tw = x;\n\th = getminhthis(w);\n\twhile (w->link.next != x && w->link.next->main == x->main) {\n\t\tw = w->link.next;\n\t\th += getminhthis(w);\n\t}""",
    )
    return src

def main() -> None:
    stubs = (HERE / "w_stubs.h").read_text()
    wfit_new = (HERE / "w_wfit_new.c").read_text()
    doabort_new = (HERE / "w_doabort_new.c").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")

    m = re.search(
        r"void wfit\(Screen \*t\)\n\{.*?\n\}\n\n/\* Goto next window \*/",
        src,
        re.S,
    )
    if not m:
        raise SystemExit("wfit not found")
    src = src[: m.start()] + wfit_new.rstrip() + "\n\n/* Goto next window */" + src[m.end() :]

    m = re.search(
        r"static ptrdiff_t doabort\(W \*w, int \*ret\)\n\{.*?\n\}\n\n/\* Abort a window and its children \*/",
        src,
        re.S,
    )
    if not m:
        raise SystemExit("doabort not found")
    src = src[: m.start()] + doabort_new.rstrip() + "\n\n/* Abort a window and its children */" + src[m.end() :]

    src = fix_comma_for_loops(src)

    if re.search(r"(?m)^\s*goto\b", src):
        hits = [
            f"{i}:{line.rstrip()}"
            for i, line in enumerate(src.splitlines(), 1)
            if re.search(r"^\s*goto\b", line)
        ]
        raise SystemExit(f"goto remains: {hits}")

    forwards = (
        "/* w.c for zig translate-c (goto-free) */\n"
        '#include "w_stubs.h"\n\n'
        "void wfit(Screen *t);\n"
        "void updall(void);\n"
        "int wshrink(W *w);\n"
        "int wgrow(W *w);\n"
        "static ptrdiff_t geth(W *w);\n"
        "static void seth(W *w, ptrdiff_t h);\n"
        "static ptrdiff_t getminh(W *w);\n"
        "static void wspread(Screen *t);\n\n"
    )
    OUT.write_text(forwards + src)
    print("wrote", OUT, "lines", (forwards + src).count("\n"))


if __name__ == "__main__":
    main()
