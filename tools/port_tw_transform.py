#!/usr/bin/env python3
"""Transform joe/tw.c into goto-free form for zig translate-c.

Writes /tmp/tw_stubs.h and /tmp/tw_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/tw.c"
OUT = Path("/tmp/tw_nogoto.c")
STUBS_OUT = Path("/tmp/tw_stubs.h")


def strip_if0(src: str) -> str:
    return re.sub(r"#if 0\n.*?#endif\n", "", src, flags=re.S)


def force_long_long(src: str) -> str:
    """Keep HAVE_LONG_LONG branches; drop #else/#endif pairs for those ifdefs."""
    # Pattern: #ifdef HAVE_LONG_LONG\n <then> #else\n <else> #endif
    def repl(m: re.Match[str]) -> str:
        return m.group(1)

    return re.sub(
        r"#ifdef HAVE_LONG_LONG\n(.*?)#else\n.*?#endif\n",
        repl,
        src,
        flags=re.S,
    )


def fix_comma_inits(src: str) -> str:
    """Rewrite for-loops with comma operators in initializer."""
    src = src.replace(
        "\t\tfor (i=0,j=0,spc=0; src[i] && i < SAVED_SIZE-1; i++) {",
        "\t\ti = 0;\n\t\tj = 0;\n\t\tspc = 0;\n\t\tfor (; src[i] && i < SAVED_SIZE-1; i++) {",
    )
    return src


def main() -> None:
    stubs = (HERE / "tw_stubs.h").read_text()
    utw1_new = (HERE / "tw_utw1_new.c").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")
    src = strip_if0(src)
    src = force_long_long(src)
    src = fix_comma_inits(src)

    m = re.search(
        r"int utw1\(W \*w, int k\)\n\{.*?\n\}\n\nvoid setline",
        src,
        re.S,
    )
    if not m:
        raise SystemExit("utw1 not found")
    src = src[: m.start()] + utw1_new.rstrip() + "\n\nvoid setline" + src[m.end() :]

    if re.search(r"(?m)^\s*goto\b", src):
        hits = [
            f"{i}:{line.rstrip()}"
            for i, line in enumerate(src.splitlines(), 1)
            if re.search(r"^\s*goto\b", line)
        ]
        raise SystemExit(f"goto remains: {hits}")

    header = (
        "/* tw.c for zig translate-c (goto-free) */\n"
        '#include "tw_stubs.h"\n\n'
        "static void movetw(W *w, ptrdiff_t x, ptrdiff_t y);\n"
        "static void resizetw(W *w, ptrdiff_t wi, ptrdiff_t he);\n"
        "static void disptw(W *w, int flg);\n"
        "static void iztw(TW *tw, ptrdiff_t y);\n"
        "static void instw(W *w, B *b, off_t l, off_t n, int flg);\n"
        "static void deltw(W *w, B *b, off_t l, off_t n, int flg);\n"
        "static int naborttw(W *w, int k, void *object, int *notify);\n"
        "static int naborttw1(W *w, int k, void *object, int *notify);\n"
        "static B *wpop(BW *bw);\n"
        "static const int *get_context(BW *bw);\n\n"
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
