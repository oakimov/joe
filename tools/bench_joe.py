#!/usr/bin/env python3
"""Phase 8: lightweight startup benchmark — Zig joe vs optional MacPorts C joe.

Metrics (wall time, median of N runs, with timeouts):
  - cold `joe -help` / `--help` startup
  - binary size (stat)

Interactive open+quit is awkward without a PTY and can hang; this v1 sticks to
help/version probes plus size notes. Results go to stdout and tools/bench_results.txt.
"""

from __future__ import annotations

import argparse
import os
import statistics
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ZIG_JOE = ROOT / "zig-out" / "bin" / "joe"
C_JOE = Path("/opt/local/bin/joe")
RESULTS = ROOT / "tools" / "bench_results.txt"

HELP_ARGS = ("-help", "--help")


def timed_run(cmd: list[str], timeout: float) -> tuple[float | None, str]:
    """Return (seconds, status). seconds is None on failure/timeout."""
    env = {**os.environ, "TERM": os.environ.get("TERM", "xterm")}
    t0 = time.perf_counter()
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
            env=env,
        )
    except subprocess.TimeoutExpired:
        return None, f"TIMEOUT>{timeout}s"
    except FileNotFoundError:
        return None, "not found"
    elapsed = time.perf_counter() - t0
    out = (proc.stdout or "") + (proc.stderr or "")
    if "Joe's Own Editor" not in out and "Usage:" not in out and proc.returncode != 0:
        return None, f"exit {proc.returncode}"
    return elapsed, "ok"


def median_help(binary: Path, n: int, timeout: float) -> tuple[float | None, str, str]:
    """Try -help then --help; return (median_s, flag_used, status)."""
    if not binary.is_file():
        return None, "", "absent"

    best_flag = ""
    samples: list[float] = []
    last_status = "no samples"

    for flag in HELP_ARGS:
        samples = []
        for _ in range(n):
            sec, status = timed_run([str(binary), flag], timeout=timeout)
            if sec is None:
                last_status = status
                samples = []
                break
            samples.append(sec)
        if samples:
            best_flag = flag
            last_status = "ok"
            break

    if not samples:
        return None, best_flag, last_status
    return statistics.median(samples), best_flag, last_status


def fmt_ms(sec: float | None) -> str:
    if sec is None:
        return "n/a"
    return f"{sec * 1000:.2f} ms"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("-n", type=int, default=7, help="runs per binary (default 7)")
    ap.add_argument("--timeout", type=float, default=5.0, help="per-run timeout seconds")
    ap.add_argument(
        "--c-joe",
        type=Path,
        default=C_JOE,
        help="optional C joe path (skipped if missing)",
    )
    args = ap.parse_args()

    lines: list[str] = []
    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    lines.append(f"# JOE Phase 8 bench  {stamp}")
    lines.append(f"# N={args.n}  timeout={args.timeout}s  help flags tried: {HELP_ARGS}")
    lines.append("")

    targets = [("zig", ZIG_JOE), ("c", args.c_joe)]
    any_ok = False
    zig_failed = False

    for label, path in targets:
        size = path.stat().st_size if path.is_file() else None
        med, flag, status = median_help(path, args.n, args.timeout)
        size_s = f"{size} bytes" if size is not None else "n/a"
        if status == "absent":
            row = f"{label:4}  {path}  ABSENT (skip)"
        elif med is None:
            row = f"{label:4}  {path}  size={size_s}  help={status}"
            if label == "zig":
                zig_failed = True
        else:
            row = (
                f"{label:4}  {path}  size={size_s}  "
                f"median({args.n}× `{flag}`)={fmt_ms(med)}  [{status}]"
            )
            any_ok = True
        lines.append(row)
        print(row)

    lines.append("")
    lines.append(
        "note: interactive open+quit omitted (PTY risk of hang); "
        "soak covers editor runtime. Compare help cold-start only."
    )

    text = "\n".join(lines) + "\n"
    RESULTS.write_text(text, encoding="utf-8")
    print(f"wrote {RESULTS.relative_to(ROOT)}")

    if zig_failed or not ZIG_JOE.is_file():
        print("bench_joe: FAIL (zig joe missing or help probe failed)", file=sys.stderr)
        return 1
    if not any_ok:
        print("bench_joe: FAIL (no successful samples)", file=sys.stderr)
        return 1
    print("bench_joe: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
