#!/usr/bin/env python3
"""Transform joe/termcap.c into goto-free form for zig translate-c.

Writes /tmp/termcap_stubs.h and /tmp/termcap_nogoto.c.
Replacement snippets live beside this script in tools/.
"""
from __future__ import annotations

import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/termcap.c"
OUT = Path("/tmp/termcap_nogoto.c")
STUBS_OUT = Path("/tmp/termcap_stubs.h")


def strip_ifdef_blocks(src: str, macro: str) -> str:
    lines = src.splitlines(True)
    out: list[str] = []
    depth = 0
    skipping = False
    skip_depth = 0
    ifdef_re = re.compile(rf"#\s*ifn?def\s+{macro}\b")
    if_re = re.compile(r"#\s*if(n?def)?\b")
    else_re = re.compile(r"#\s*el(se|if)\b")
    endif_re = re.compile(r"#\s*endif\b")

    for line in lines:
        if not skipping and ifdef_re.match(line):
            skipping = True
            skip_depth = depth
            depth += 1
            continue
        if if_re.match(line):
            depth += 1
            if skipping:
                continue
            out.append(line)
            continue
        if endif_re.match(line):
            if skipping:
                depth -= 1
                if depth == skip_depth:
                    skipping = False
                continue
            depth -= 1
            out.append(line)
            continue
        if skipping:
            if depth == skip_depth + 1 and else_re.match(line):
                continue
            continue
        out.append(line)
    return "".join(out)


def main() -> None:
    stubs = (HERE / "termcap_stubs.h").read_text()
    lfind_new = (HERE / "termcap_lfind_new.c").read_text()
    my_getcap_new = (HERE / "termcap_my_getcap_new.c").read_text()
    texec_new = (HERE / "termcap_texec_digit_new.c").read_text()

    STUBS_OUT.write_text(stubs)

    src = SRC.read_text()
    src = src.replace('#include "types.h"\n', "")
    src = strip_ifdef_blocks(src, "TERMINFO")

    m = re.search(r"static char \*lfind\(.*?\n\}", src, re.S)
    if not m:
        raise SystemExit("lfind not found")
    src = src[: m.start()] + lfind_new + src[m.end() :]

    start = src.index(
        "CAP *my_getcap(char *name, long baud, void (*out) (void *, char), void *outptr)"
    )
    end = src.index("static struct sortentry *findcap(CAP *cap, const char *name)")
    src = src[:start] + my_getcap_new + "\n" + src[end:]

    m = re.search(r"\t\t\tcase 'd':\n.*?goto one;.*?break;", src, re.S)
    if not m:
        raise SystemExit("texec digit block not found")
    src = src[: m.start()] + texec_new + src[m.end() :]

    src = strip_ifdef_blocks(src, "junk")

    if re.search(r"(?m)^\s*goto\b", src):
        hits = [
            (i + 1, line)
            for i, line in enumerate(src.splitlines())
            if re.search(r"^\s*goto\b", line)
        ]
        raise SystemExit(f"goto remains: {hits}")

    bad_labels = []
    for i, line in enumerate(src.splitlines(), 1):
        mlab = re.match(r"^\s*([A-Za-z_][A-Za-z0-9_]*):", line)
        if mlab and mlab.group(1) != "default":
            bad_labels.append((i, line.rstrip()))
    if bad_labels:
        raise SystemExit(f"labels remain: {bad_labels}")

    header = (
        "/* termcap.c for zig translate-c (goto-free, no TERMINFO) */\n"
        '#include "termcap_stubs.h"\n\n'
    )
    text = header + src
    OUT.write_text(text)
    shutil.copy2(Path(__file__), "/tmp/termcap_transform.py")
    print("wrote", STUBS_OUT)
    print("wrote", OUT, "lines", text.count("\n"))


if __name__ == "__main__":
    main()
