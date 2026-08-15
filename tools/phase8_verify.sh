#!/usr/bin/env bash
# Phase 8: run verification / generation smoke tools for the Zig rewrite.
# Exits non-zero if any step fails.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== phase8_verify: $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="

fail=0

run() {
  local title="$1"
  shift
  echo
  echo "--- $title ---"
  if "$@"; then
    echo "PASS: $title"
  else
    echo "FAIL: $title" >&2
    fail=1
  fi
}

run "verify_rc.py" python3 tools/verify_rc.py
run "verify_syntax_colors.py" python3 tools/verify_syntax_colors.py
run "gen_unicat.py --check" python3 tools/gen_unicat.py --check
run "bench_joe.py" python3 tools/bench_joe.py

echo
if [[ "$fail" -ne 0 ]]; then
  echo "phase8_verify: FAILED" >&2
  exit 1
fi
echo "phase8_verify: ALL OK"
exit 0
