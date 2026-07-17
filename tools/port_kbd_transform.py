#!/usr/bin/env python3
"""Prepare joe/kbd.c for zig translate-c (already goto-free; strip MSDOS).

Writes /tmp/kbd_stubs.h and /tmp/kbd_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/kbd.c"
OUT = Path("/tmp/kbd_nogoto.c")
STUBS_OUT = Path("/tmp/kbd_stubs.h")


def strip_msdos(src: str) -> str:
    """Keep the non-MSDOS branch of `#ifdef __MSDOS__` ... `#else` ... `#endif`."""
    m = re.search(
        r"#ifdef __MSDOS__\n.*?#else\n(.*?)#endif\n",
        src,
        re.S,
    )
    if not m:
        if "#ifdef __MSDOS__" in src:
            raise SystemExit("MSDOS block shape unexpected")
        return src
    return src[: m.start()] + m.group(1) + src[m.end() :]


def main() -> None:
    stubs = (HERE / "kbd_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text()
    src = src.replace('#include "types.h"\n', "")
    src = strip_msdos(src)
    assert "goto " not in src, "goto remains"
    assert "__MSDOS__" not in src, "MSDOS residue"

    header = '/* kbd.c for zig translate-c (non-MSDOS path) */\n#include "kbd_stubs.h"\n\n'
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
