#!/usr/bin/env python3
"""Prepare joe/mouse.c for zig translate-c (no gotos).

Writes /tmp/mouse_stubs.h and /tmp/mouse_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/mouse.c"
OUT = Path("/tmp/mouse_nogoto.c")
STUBS_OUT = Path("/tmp/mouse_stubs.h")


def main() -> None:
    stubs = (HERE / "mouse_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")
    # Drop system timeval include — stubs provide Darwin layout
    src = re.sub(
        r"#ifdef HAVE_SYS_TIME_H\n#include <sys/time.h>\n#endif\n",
        "",
        src,
    )

    # Forward decls for functions called before definition
    forward = """
void mousedn(ptrdiff_t x, ptrdiff_t y, int middle);
void mouseup(ptrdiff_t x, ptrdiff_t y);
void mousedrag(ptrdiff_t x, ptrdiff_t y);
int utomouse(W *xx, int k);
long mnow(void);
void reset_trig_time(void);
static int tomousestay(void);
static void select_done(struct charmap *map);
static void fake_key(int c);
static void ttputs64(char *pp, ptrdiff_t length);
static void ttputs64_flush(void);

"""
    marker = "int auto_scroll = 0;		/* Set for autoscroll */\n"
    idx = src.find(marker)
    if idx < 0:
        raise SystemExit("auto_scroll marker not found")
    src = src[:idx] + forward + src[idx:]

    header = (
        "/* mouse.c for zig translate-c */\n"
        '#include "mouse_stubs.h"\n\n'
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
