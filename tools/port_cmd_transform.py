#!/usr/bin/env python3
"""Transform joe/cmd.c into goto-free form for zig translate-c."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/cmd.c"
OUT = Path("/tmp/cmd_nogoto.c")
STUBS_OUT = Path("/tmp/cmd_stubs.h")


def strip_ifdef_junk(src: str) -> str:
    """Remove `#ifdef junk` ... `#endif` blocks (including nested-safe simple form)."""
    return re.sub(r"#ifdef junk\n.*?#endif\n", "", src, flags=re.S)


def main() -> None:
    stubs = (HERE / "cmd_stubs.h").read_text()
    execmd_new = (HERE / "cmd_execmd_new.c").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")
    src = strip_ifdef_junk(src)

    m = re.search(
        r"int execmd\(const CMD \*cmd, int k\)\n\{.*?\n\}\n\nvoid do_auto_scroll",
        src,
        re.S,
    )
    if not m:
        raise SystemExit("execmd not found")
    src = src[: m.start()] + execmd_new.rstrip() + "\n\nvoid do_auto_scroll" + src[m.end() :]

    assert "goto " not in src, "goto remains"
    assert "#ifdef junk" not in src, "junk ifdef remains"

    header = '/* cmd.c for zig translate-c (goto-free) */\n#include "cmd_stubs.h"\n\n'
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
