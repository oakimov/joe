#!/usr/bin/env python3
"""Phase 8: smoke-verify JOE personality rc files under rc/.

Checks that each personality config is non-empty and contains typical JOE rc
constructs (:include, menu/, mode/, binding-style `=` keymap lines, :defmenu,
or :window sections). Optionally probes zig-out/bin/joe -help if present.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RC_DIR = ROOT / "rc"
ZIG_JOE = ROOT / "zig-out" / "bin" / "joe"

# Personality bases; resolve .in when the processed file is absent.
PERSONALITIES = (
    "joerc",
    "jmacsrc",
    "jstarrc",
    "rjoerc",
    "jpicorc",
    "joerc.zh_TW",
    "jicerc.ru",
)

# Lines that indicate a real JOE rc (not an empty stub).
RC_MARKERS = re.compile(
    r"^(?:"
    r":include\b|"
    r":defmenu\b|"
    r":window\b|"
    r":main\b|"
    r":prompt\b|"
    r":query\w*\b|"
    r":shell\b|"
    r"menu,|"
    r"mode,"
    r")|"
    r"^[ \t]*\S+.*=\s",  # keybinding-ish assignment lines
    re.MULTILINE,
)


def resolve_rc(name: str) -> Path:
    """Prefer processed rc/<name>, else rc/<name>.in."""
    processed = RC_DIR / name
    if processed.is_file():
        return processed
    source = RC_DIR / f"{name}.in"
    if source.is_file():
        return source
    raise FileNotFoundError(f"neither {processed} nor {source} found")


def smoke_parse(path: Path) -> tuple[int, int]:
    """Return (line_count, marker_hits). Raise on failure."""
    raw = path.read_bytes()
    if not raw:
        raise ValueError("empty file")
    if b"\x00" in raw:
        raise ValueError("contains NUL bytes")
    text = raw.decode("utf-8", errors="replace")
    lines = text.splitlines()
    if not lines:
        raise ValueError("no lines")
    hits = len(RC_MARKERS.findall(text))
    if hits == 0:
        raise ValueError("no JOE rc markers (:include / menu / mode / bindings)")
    return len(lines), hits


def maybe_probe_joe() -> str:
    if not ZIG_JOE.is_file():
        return "zig-out/bin/joe: absent (skip help probe)"
    try:
        proc = subprocess.run(
            [str(ZIG_JOE), "-help"],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
            env={**os.environ, "TERM": os.environ.get("TERM", "xterm")},
        )
    except subprocess.TimeoutExpired:
        return "zig-out/bin/joe -help: TIMEOUT"
    out = (proc.stdout or "") + (proc.stderr or "")
    if proc.returncode != 0 and "Joe's Own Editor" not in out:
        return f"zig-out/bin/joe -help: exit {proc.returncode}"
    if "Joe's Own Editor" not in out and "Usage:" not in out:
        return "zig-out/bin/joe -help: unexpected output"
    return "zig-out/bin/joe -help: OK"


def make_personality_symlinks(tmpdir: Path) -> list[str]:
    """Create temporary ~/.joe-style names pointing at resolved rcs (optional aid)."""
    created = []
    for name in PERSONALITIES:
        src = resolve_rc(name)
        link = tmpdir / f".{name}"
        link.symlink_to(src)
        created.append(str(link))
    return created


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument(
        "--symlinks",
        action="store_true",
        help="create temporary personality symlinks (smoke only)",
    )
    args = ap.parse_args()

    ok = 0
    errors: list[str] = []

    for name in PERSONALITIES:
        try:
            path = resolve_rc(name)
            nlines, hits = smoke_parse(path)
            rel = path.relative_to(ROOT)
            print(f"  OK  {rel}  ({nlines} lines, {hits} markers)")
            ok += 1
        except Exception as exc:  # noqa: BLE001 — summarize all personalities
            errors.append(f"{name}: {exc}")
            print(f"  FAIL {name}: {exc}", file=sys.stderr)

    if args.symlinks:
        with tempfile.TemporaryDirectory(prefix="joe-rc-") as td:
            links = make_personality_symlinks(Path(td))
            print(f"  symlink smoke: {len(links)} links under {td}")

    joe_note = maybe_probe_joe()
    print(f"  {joe_note}")
    if "TIMEOUT" in joe_note:
        errors.append(joe_note)

    print(f"verify_rc: {ok}/{len(PERSONALITIES)} personalities OK")
    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
