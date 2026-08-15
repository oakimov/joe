#!/usr/bin/env python3
"""Phase 8: smoke-verify syntax/*.jsf and colors/*.jcf load lists.

Ensures every file is readable, non-empty, NUL-free, and has basic structure:
  - .jsf: state headers (`:Name …`) and/or transitions / `=` color refs
  - .jcf: color assignments (`=Name …`) and/or `-option` theme lines

Optionally runs `zig build render-test` when quick. Golden attr parity vs C is
deferred to soak / integration tests — this tool is structural smoke only.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SYNTAX_DIR = ROOT / "syntax"
COLORS_DIR = ROOT / "colors"

JSF_STATE = re.compile(r"(?m)^:[A-Za-z_][\w.-]*\b")
JSF_EQ = re.compile(r"(?m)^=\w+")
# Transitions often look like: * 0x20-0x7e noeat call=... or plain " * " lines
JSF_TRANS = re.compile(r"(?m)^[ \t]+\*")

JCF_ASSIGN = re.compile(r"(?m)^=\w+")
JCF_OPTION = re.compile(r"(?m)^-\w+")


def load_list(directory: Path, suffix: str) -> list[Path]:
    if not directory.is_dir():
        raise SystemExit(f"missing directory: {directory}")
    files = sorted(p for p in directory.iterdir() if p.is_file() and p.suffix == suffix)
    return files


def check_jsf(path: Path) -> str:
    raw = path.read_bytes()
    if not raw:
        raise ValueError("empty")
    if b"\x00" in raw:
        raise ValueError("NUL byte")
    text = raw.decode("utf-8", errors="replace")
    states = len(JSF_STATE.findall(text))
    eqs = len(JSF_EQ.findall(text))
    trans = len(JSF_TRANS.findall(text))
    if states == 0 and eqs == 0 and trans == 0:
        # Some include-only stubs may only have .ifdef / comments — require content
        if not any(
            line.strip() and not line.strip().startswith("#")
            for line in text.splitlines()
        ):
            raise ValueError("no non-comment content")
        return "stub/include-only"
    if states == 0 and trans == 0:
        raise ValueError("no :state or transition lines")
    return f"{states} states, {trans} transitions, {eqs} ="


def check_jcf(path: Path) -> str:
    raw = path.read_bytes()
    if not raw:
        raise ValueError("empty")
    if b"\x00" in raw:
        raise ValueError("NUL byte")
    text = raw.decode("utf-8", errors="replace")
    assigns = len(JCF_ASSIGN.findall(text))
    opts = len(JCF_OPTION.findall(text))
    if assigns == 0 and opts == 0:
        raise ValueError("no =color or -option lines")
    return f"{assigns} colors, {opts} options"


def maybe_render_test(timeout: float) -> str:
    try:
        proc = subprocess.run(
            ["zig", "build", "render-test"],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except FileNotFoundError:
        return "zig build render-test: zig not found (skip)"
    except subprocess.TimeoutExpired:
        return f"zig build render-test: TIMEOUT (>{timeout}s)"
    if proc.returncode != 0:
        err = (proc.stderr or proc.stdout or "").strip().splitlines()
        tail = err[-3:] if err else ["exit non-zero"]
        return "zig build render-test: FAIL — " + " | ".join(tail)
    return "zig build render-test: OK"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument(
        "--render-test",
        action="store_true",
        help="also run `zig build render-test` (default: on if under ~60s budget)",
    )
    ap.add_argument(
        "--no-render-test",
        action="store_true",
        help="skip zig build render-test",
    )
    args = ap.parse_args()

    errors: list[str] = []

    jsf_files = load_list(SYNTAX_DIR, ".jsf")
    jcf_files = load_list(COLORS_DIR, ".jcf")

    print(f"syntax: {len(jsf_files)} .jsf under {SYNTAX_DIR.relative_to(ROOT)}")
    for path in jsf_files:
        try:
            detail = check_jsf(path)
            print(f"  OK  {path.relative_to(ROOT)}  ({detail})")
        except Exception as exc:  # noqa: BLE001
            errors.append(f"{path}: {exc}")
            print(f"  FAIL {path.relative_to(ROOT)}: {exc}", file=sys.stderr)

    print(f"colors: {len(jcf_files)} .jcf under {COLORS_DIR.relative_to(ROOT)}")
    for path in jcf_files:
        try:
            detail = check_jcf(path)
            print(f"  OK  {path.relative_to(ROOT)}  ({detail})")
        except Exception as exc:  # noqa: BLE001
            errors.append(f"{path}: {exc}")
            print(f"  FAIL {path.relative_to(ROOT)}: {exc}", file=sys.stderr)

    if not jsf_files:
        errors.append("no .jsf files found")
    if not jcf_files:
        errors.append("no .jcf files found")

    run_rt = args.render_test or not args.no_render_test
    if run_rt:
        note = maybe_render_test(timeout=90.0)
        print(f"  {note}")
        if "FAIL" in note or "TIMEOUT" in note:
            errors.append(note)
    else:
        print("  zig build render-test: skipped")
        print("  note: runtime attr parity vs C is covered by soak tests, not this smoke")

    n_ok = (len(jsf_files) + len(jcf_files)) - len(
        [e for e in errors if ".jsf" in e or ".jcf" in e]
    )
    print(
        f"verify_syntax_colors: {len(jsf_files)} jsf + {len(jcf_files)} jcf checked "
        f"({n_ok} file smokes OK)"
    )
    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
