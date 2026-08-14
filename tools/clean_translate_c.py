#!/usr/bin/env python3
"""Clean zig translate-c output into a hybrid src/*.zig module."""
from __future__ import annotations

import argparse
import re
from pathlib import Path


def clean_translate(raw: str, header: str) -> str:
    raw = raw.replace("callconv(.C)", "callconv(.c)")
    raw = raw.replace("__helpers.signedRemainder", "@rem")
    raw = re.sub(
        r"@import\(\"std\"\)\.mem\.zeroes",
        "std.mem.zeroes",
        raw,
    )

    # Drop nested __root method aliases inside type decls (incl. @"name")
    raw = re.sub(
        r"\n\s*pub const (?:\w+|@\"\w+\") = __root\.\w+;",
        "",
        raw,
    )

    lines = raw.splitlines()
    # Find start: first stub-ish typedef after libc junk — prefer `pub const off_t = i64;`
    start = None
    for i, line in enumerate(lines):
        if line.strip() == "pub const off_t = i64;":
            # include a few preceding extern fn decls from stubs
            j = i
            while j > 0 and (
                lines[j - 1].startswith("pub extern fn ")
                or lines[j - 1].startswith("pub extern var ")
                or lines[j - 1].startswith("pub const ")
                or lines[j - 1].strip() == ""
            ):
                j -= 1
            # Better: find first `pub extern fn printf` 
            start = j
            break
    for i, line in enumerate(lines):
        if line.startswith("pub extern fn printf"):
            start = i
            break
    if start is None:
        raise SystemExit("could not find stubs start")

    # Find end: first compiler builtin define dump
    end = len(lines)
    for i in range(start, len(lines)):
        if lines[i].startswith("pub const __VERSION__"):
            end = i
            break
        if lines[i].startswith("pub const __STDC__"):
            end = i
            break

    body = "\n".join(lines[start:end]).rstrip() + "\n"

    # Prepend std/ptrdiff and file header; skip duplicate ptrdiff if present early
    preamble = header.rstrip() + "\n\nconst std = @import(\"std\");\nconst ptrdiff_t = c_long;\n\n"
    # If body already begins with printf externs, good.
    return preamble + body


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("raw")
    ap.add_argument("out")
    ap.add_argument("--title", required=True)
    ap.add_argument("--blurb", required=True)
    args = ap.parse_args()
    header = f"//! {args.title}\n//!\n//! {args.blurb}"
    raw = Path(args.raw).read_text()
    out = clean_translate(raw, header)
    Path(args.out).write_text(out)
    print("wrote", args.out, "lines", out.count("\n"))


if __name__ == "__main__":
    main()
