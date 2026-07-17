#!/usr/bin/env python3
"""Regenerate src/charmap_data.zig from joe/charmap.c builtin tables."""
import re
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
src = (ROOT / "joe" / "charmap.c").read_text()

alias_m = re.search(r"alias_table\[\] = \{(.*?)\};", src, re.S)
aliases = re.findall(r'\{\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\}', alias_m.group(1))

bm = re.search(r"builtin_charmaps\[\]=\s*\{(.*)\n\};", src, re.S)
body = bm.group(1)
entries = []
for m in re.finditer(r'\{\s*"([^"]+)"\s*,\s*\{([^{}]+)\}\s*\}', body):
    name = m.group(1)
    nums = [x.strip() for x in m.group(2).split(",") if x.strip()]
    if len(nums) != 256:
        raise SystemExit(f"{name}: expected 256 entries, got {len(nums)}")
    entries.append((name, nums))

out = []
out.append("//! Auto-generated from joe/charmap.c — builtin encoding tables.")
out.append("//! Do not edit by hand; regenerate with tools/gen_charmap_data.py if needed.")
out.append("")
out.append("pub const Alias = struct { alias: [:0]const u8, builtin: [:0]const u8 };")
out.append("")
out.append("pub const alias_table = [_]Alias{")
for a, b in aliases:
    out.append(f'    .{{ .alias = "{a}", .builtin = "{b}" }},')
out.append("};")
out.append("")
out.append("pub const BuiltinCharmap = struct { name: [:0]const u8, to_uni: [256]c_int };")
out.append("")
out.append("pub const builtin_charmaps = [_]BuiltinCharmap{")
for name, nums in entries:
    out.append("    .{")
    out.append(f'        .name = "{name}",')
    out.append("        .to_uni = .{")
    for i in range(0, 256, 8):
        out.append(f"            {', '.join(nums[i:i+8])},")
    out.append("        },")
    out.append("    },")
out.append("};")
out.append("")

path = ROOT / "src" / "charmap_data.zig"
path.write_text("\n".join(out) + "\n")
print(f"wrote {path} ({path.stat().st_size} bytes, {len(entries)} maps, {len(aliases)} aliases)")
