#!/usr/bin/env python3
"""Transform joe/macro.c into goto-free form for zig translate-c.

Writes /tmp/macro_stubs.h and /tmp/macro_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/macro.c"
OUT = Path("/tmp/macro_nogoto.c")
STUBS_OUT = Path("/tmp/macro_stubs.h")


def main() -> None:
    stubs = (HERE / "macro_stubs.h").read_text()
    mparse_new = (HERE / "macro_mparse_new.c").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding='latin-1')
    src = src.replace('#include "types.h"\n', "")

    m = re.search(r"MACRO \*mparse\(MACRO \*m, const char \*buf, ptrdiff_t \*sta, int secure\)\n\{.*?\n\}\n\n/\* Convert macro to text \*/", src, re.S)
    if not m:
        raise SystemExit("mparse not found")
    src = src[: m.start()] + mparse_new.rstrip() + "\n\n/* Convert macro to text */" + src[m.end() :]

    assert "goto " not in src, "goto remains"

    header = '/* macro.c for zig translate-c (goto-free) */\n#include "macro_stubs.h"\n\n'
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
