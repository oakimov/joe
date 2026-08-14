#!/usr/bin/env python3
"""Transform joe/umath.c into goto-free form for zig translate-c.

Writes /tmp/umath_stubs.h and /tmp/umath_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/umath.c"
OUT = Path("/tmp/umath_nogoto.c")
STUBS_OUT = Path("/tmp/umath_stubs.h")


def convert_expr_gotos(src: str) -> str:
    """Convert expr()'s loop:/goto loop into while(1)/continue/break."""
    marker = "\n      loop:\n"
    idx = src.find(marker)
    if idx < 0:
        raise SystemExit("expr loop: label not found")

    # Find matching end: "*rtv = v;\n\treturn x;\n}" after the label body
    end_marker = "\n\t*rtv = v;\n\treturn x;\n}"
    end = src.find(end_marker, idx)
    if end < 0:
        raise SystemExit("expr loop end not found")

    body = src[idx + len(marker) : end]
    # Replace goto loop; with continue;
    body = body.replace("goto loop;", "continue;")
    # Wrap in while(1) { ... break; }
    wrapped = (
        "\n\twhile (1) {\n"
        + body
        + "\t\tbreak;\n"
        + "\t}"
        + end_marker
    )
    return src[:idx] + wrapped + src[end + len(end_marker) :]


def main() -> None:
    stubs = (HERE / "umath_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")
    src = convert_expr_gotos(src)

    if re.search(r"(?m)^\s*goto\b", src):
        hits = [
            f"{i}:{line.rstrip()}"
            for i, line in enumerate(src.splitlines(), 1)
            if re.search(r"^\s*goto\b", line)
        ]
        raise SystemExit(f"goto remains: {hits}")

    header = (
        "/* umath.c for zig translate-c (goto-free) */\n"
        '#include "umath_stubs.h"\n\n'
        "static int doumath(W *w, char *s, void *object, int *notify);\n"
        "static int dosmath(W *w, char *s, void *object, int *notify);\n"
        "static int domath(W *w, char *s, void *object, int *notify, int secure);\n"
        "static void setup_vars(BW *tbw);\n"
        "static void format_result(char *out, double result, int base, int commas);\n"
        "static void get_math_list(void);\n\n"
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
