#!/usr/bin/env python3
"""Prepare joe/tab.c for zig translate-c (no gotos).

Writes /tmp/tab_stubs.h and /tmp/tab_nogoto.c.
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/tab.c"
OUT = Path("/tmp/tab_nogoto.c")
STUBS_OUT = Path("/tmp/tab_stubs.h")


def main() -> None:
    stubs = (HERE / "tab_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")

    # Forward decls for statics referenced before definition
    forward = """
static int get_entries(TAB *tab, ino_t prv);
static void insnam(BW *bw, char *path, char *nam, int dir, P *path_loc, int quote);
static char **treload(TAB *tab, MENU *m, BW *bw, int flg, int *defer);
static void rmtab(TAB *tab);
static int tabrtn(MENU *m, ptrdiff_t cursor, void *object, int op);
static int tabrtn1(MENU *m, int cursor, TAB *tab);
static int tabbacks(MENU *m, ptrdiff_t cursor, void *object);
static int tababrt(W *w, ptrdiff_t cursor, void *object);
static int p_goto_start_of_path(P *p, int flags);
static int cmplt(BW *bw, int k, int flags_in);

"""
    # Insert after typedef/globals — after `extern WATOM watommenu;`
    marker = "extern WATOM watommenu;\n"
    idx = src.find(marker)
    if idx < 0:
        raise SystemExit("watommenu extern not found")
    insert_at = idx + len(marker)
    # TAB typedef is `typedef struct tab TAB;` before struct — keep as-is;
    # forward decls use TAB which needs the typedef first.
    # Move insert to after struct tab closing `};`
    struct_end = src.find("#define F_DIR")
    if struct_end < 0:
        raise SystemExit("F_DIR not found")
    insert_at = struct_end
    src = src[:insert_at] + forward + src[insert_at:]

    header = (
        "/* tab.c for zig translate-c */\n"
        '#include "tab_stubs.h"\n\n'
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
