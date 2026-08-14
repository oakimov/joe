#!/usr/bin/env python3
"""Prepare joe/cclass.c for zig translate-c (goto-free).

Writes /tmp/cclass_stubs.h and /tmp/cclass_nogoto.c.

Pipeline (from a revision that still has the C body):
  python3 tools/port_cclass_transform.py
  zig translate-c /tmp/cclass_nogoto.c -I /tmp -lc > /tmp/cclass_raw.zig
  python3 tools/clean_translate_c.py /tmp/cclass_raw.zig src/cclass.zig \\
    --title 'Character classes and radix maps — replaces `joe/cclass.c`.' \\
    --blurb 'Faithful C-ABI Path A port of JOE cclass/rmap/rtree/rset/interval helpers.'
  # Then: inject LEAFSIZE..UNICODE_LAST consts; replace return undefined with
  # unreachable; Darwin stderr → __stderrp; Zig 0.16 array-field index via
  # @as([*]T, @ptrCast(&x.entry))[i] (value[i] on [N]T fields is broken).
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/cclass.c"
OUT = Path("/tmp/cclass_nogoto.c")
STUBS_OUT = Path("/tmp/cclass_stubs.h")


def convert_interval_test(src: str) -> str:
    """Rewrite interval_test without goto no_match."""
    start = src.find("ptrdiff_t interval_test(const struct interval *array, ptrdiff_t size, int ch)\n{")
    if start < 0:
        raise SystemExit("interval_test not found")
    end = src.find("\n}\n\nstruct interval_list *mkinterval(", start)
    if end < 0:
        raise SystemExit("interval_test end not found")

    new = r'''ptrdiff_t interval_test(const struct interval *array, ptrdiff_t size, int ch)
{
	if (size) {
		ptrdiff_t min = 0;
		ptrdiff_t mid;
		ptrdiff_t max = size - 1;
		if (ch >= array[min].first && ch <= array[max].last) {
			while (max >= min) {
				mid = (min + max) / 2;
				if (ch > array[mid].last)
					min = mid + 1;
				else if (ch < array[mid].first)
					max = mid - 1;
				else
					return mid;
			}
		}
	}
	return -1;
}'''
    return src[:start] + new + src[end + 2 :]


def main() -> None:
    stubs = (HERE / "cclass_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    if "REMOVED from the live link" in src:
        raise SystemExit("joe/cclass.c is already a tombstone; restore C body from git to re-run")
    src = src.replace('#include "types.h"\n', "")
    src = convert_interval_test(src)

    if re.search(r"(?m)^\s*goto\b", src):
        hits = [
            f"{i}:{line.rstrip()}"
            for i, line in enumerate(src.splitlines(), 1)
            if re.search(r"^\s*goto\b", line)
        ]
        raise SystemExit(f"goto remains: {hits}")

    header = (
        "/* cclass.c for zig translate-c (goto-free) */\n"
        '#include "cclass_stubs.h"\n\n'
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))
    if "goto " in src:
        raise SystemExit("goto string remains")


if __name__ == "__main__":
    main()
