#!/usr/bin/env python3
"""Phase 8: Unicode category metadata / verification for the Zig rewrite.

Reads Unicode 17 inputs from joe/util/unicode-17/ (the four files uniproc
expects: Blocks.txt, UnicodeData.txt, CaseFolding.txt, EastAsianWidth.txt),
verifies that src/unicat.zig still exports the key tables, and writes
src/data/unicat_meta.zig with UNICODE_VERSION plus input-file SHA-256 hashes.

Full table regeneration is huge (~35K lines of Zig). Prefer:
  joe/util/uniproc Blocks.txt UnicodeData.txt CaseFolding.txt EastAsianWidth.txt
    > joe/unicat-17.0.0.c
then port/regenerate Zig separately. A future `zig build gen-unicat` step can
wrap that; this script documents and checksums the sources used by the build.
"""

from __future__ import annotations

import argparse
import hashlib
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UNICODE_DIR = ROOT / "joe" / "util" / "unicode-17"
UNICAT_ZIG = ROOT / "src" / "unicat.zig"
META_OUT = ROOT / "src" / "data" / "unicat_meta.zig"
UNIPROC = ROOT / "joe" / "util" / "uniproc"

UNICODE_VERSION = "17.0.0"

# Order matches uniproc(1) argv: Blocks, UnicodeData, CaseFolding, EastAsianWidth
INPUT_FILES = (
    "Blocks.txt",
    "UnicodeData.txt",
    "CaseFolding.txt",
    "EastAsianWidth.txt",
)

# Key C-ABI exports that Path A unicat.zig must keep (see src/unicat.zig).
REQUIRED_EXPORTS = (
    "uniblocks",
    "unicat",
    "fold_table",
    "fold_repl",
    "width_table",
    "toupper_table",
    "tolower_table",
    "totitle_table",
    "Lu_table",
    "Ll_table",
    "Nd_table",
    "Mn_table",
    "Cc_table",
)


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def verify_inputs() -> dict[str, str]:
    missing = [name for name in INPUT_FILES if not (UNICODE_DIR / name).is_file()]
    if missing:
        raise SystemExit(
            f"missing Unicode inputs under {UNICODE_DIR}: {', '.join(missing)}"
        )
    return {name: sha256_file(UNICODE_DIR / name) for name in INPUT_FILES}


def verify_unicat_exports() -> list[str]:
    if not UNICAT_ZIG.is_file():
        raise SystemExit(f"missing {UNICAT_ZIG}")
    text = UNICAT_ZIG.read_text(encoding="utf-8", errors="replace")
    found = set(re.findall(r"pub\s+export\s+const\s+(\w+)\s*:", text))
    missing = [name for name in REQUIRED_EXPORTS if name not in found]
    if missing:
        raise SystemExit(
            f"{UNICAT_ZIG.name}: missing required exports: {', '.join(missing)}"
        )
    return sorted(found)


def write_meta(hashes: dict[str, str], exports: list[str]) -> None:
    META_OUT.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "//! Auto-generated Unicode input metadata for JOE Zig rewrite.",
        "//! Do not edit by hand; regenerate with: python3 tools/gen_unicat.py",
        "//!",
        "//! Full category tables live in src/unicat.zig (Path A C-ABI port).",
        "//! To regenerate C sources from UnicodeData:",
        "//!   joe/util/uniproc joe/util/unicode-17/Blocks.txt \\",
        "//!     joe/util/unicode-17/UnicodeData.txt \\",
        "//!     joe/util/unicode-17/CaseFolding.txt \\",
        "//!     joe/util/unicode-17/EastAsianWidth.txt > joe/unicat-17.0.0.c",
        "//! Expected future build step: `zig build gen-unicat`.",
        "",
        f'pub const UNICODE_VERSION: []const u8 = "{UNICODE_VERSION}";',
        "",
        "pub const InputHash = struct { name: []const u8, sha256: []const u8 };",
        "",
        "pub const INPUT_HASHES = [_]InputHash{",
    ]
    for name in INPUT_FILES:
        lines.append(f'    .{{ .name = "{name}", .sha256 = "{hashes[name]}" }},')
    lines.append("};")
    lines.append("")
    lines.append("/// Manifest of key `pub export` symbols checked by tools/gen_unicat.py.")
    lines.append("pub const KEY_EXPORTS = [_][]const u8{")
    for name in REQUIRED_EXPORTS:
        lines.append(f'    "{name}",')
    lines.append("};")
    lines.append("")
    lines.append(f"/// Count of all `pub export const` symbols in unicat.zig at generation time.")
    lines.append(f"pub const EXPORT_COUNT: usize = {len(exports)};")
    lines.append("")
    META_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")


def try_run_uniproc(dry_run: bool) -> None:
    """Optionally smoke-run uniproc to stdout count if the binary exists."""
    if not UNIPROC.is_file():
        print(f"note: {UNIPROC} not found; skip uniproc smoke (build via joe/util)")
        return
    if dry_run:
        print(f"note: would invoke {UNIPROC.relative_to(ROOT)} (use without --check)")
        return
    args = [str(UNIPROC)] + [str(UNICODE_DIR / n) for n in INPUT_FILES]
    try:
        proc = subprocess.run(
            args,
            cwd=str(ROOT),
            capture_output=True,
            text=True,
            timeout=120,
            check=False,
        )
    except subprocess.TimeoutExpired:
        raise SystemExit("uniproc timed out after 120s") from None
    if proc.returncode != 0:
        err = (proc.stderr or proc.stdout or "").strip() or f"exit {proc.returncode}"
        raise SystemExit(f"uniproc failed: {err}")
    out_lines = proc.stdout.count("\n")
    print(f"uniproc smoke OK ({out_lines} lines of C generated to stdout; not written)")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument(
        "--check",
        action="store_true",
        help="verify inputs + exports; rewrite meta only if hashes/exports changed",
    )
    ap.add_argument(
        "--run-uniproc",
        action="store_true",
        help="also smoke-run joe/util/uniproc (stdout discarded except line count)",
    )
    args = ap.parse_args()

    hashes = verify_inputs()
    exports = verify_unicat_exports()

    print(f"UNICODE_VERSION = {UNICODE_VERSION}")
    print(f"inputs: {UNICODE_DIR}")
    for name in INPUT_FILES:
        path = UNICODE_DIR / name
        print(f"  {name}: {path.stat().st_size} bytes  sha256={hashes[name][:16]}…")
    print(f"unicat.zig exports: {len(exports)} total; required OK ({len(REQUIRED_EXPORTS)})")

    write_meta(hashes, exports)
    print(f"wrote {META_OUT.relative_to(ROOT)}")

    if args.run_uniproc:
        try_run_uniproc(dry_run=False)
    elif not args.check:
        # Default generation path: mention uniproc availability
        if UNIPROC.is_file():
            print(f"note: {UNIPROC.relative_to(ROOT)} available; pass --run-uniproc to smoke it")
        print("note: full Zig regen not performed (use uniproc → C, then port); see unicat_meta.zig")

    print("gen_unicat: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
