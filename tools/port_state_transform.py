#!/usr/bin/env python3
"""Prepare joe/state.c for zig translate-c."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/state.c"
OUT = Path("/tmp/state_nogoto.c")
STUBS_OUT = Path("/tmp/state_stubs.h")


def main() -> None:
    stubs = (HERE / "state_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)
    src = SRC.read_text(encoding="latin-1").replace('#include "types.h"\n', "")
    forward = """
static void save_hist(FILE *f, B *b);
static void load_hist(FILE *f, B **bp);

"""
    marker = "int joe_state;\n"
    idx = src.find(marker)
    if idx < 0:
        raise SystemExit("joe_state not found")
    src = src[: idx + len(marker)] + forward + src[idx + len(marker) :]
    OUT.write_text('/* state.c for zig translate-c */\n#include "state_stubs.h"\n\n' + src)
    print("wrote", OUT)


if __name__ == "__main__":
    main()
