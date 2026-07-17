#!/usr/bin/env python3
"""Transform joe/scrn.c into goto-free form for zig translate-c.

Writes /tmp/scrn_stubs.h and /tmp/scrn_nogoto.c.
Replacement snippets live beside this script in tools/.
"""
from __future__ import annotations

import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/scrn.c"
OUT = Path("/tmp/scrn_nogoto.c")
STUBS_OUT = Path("/tmp/scrn_stubs.h")


def strip_ifdef_blocks(src: str, macro: str) -> str:
    """Remove entire #ifdef/#ifndef MACRO ... #endif (both branches)."""
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


def assume_undefined(src: str, macro: str) -> str:
    """Treat MACRO as undefined: drop #ifdef body, keep #else; keep #ifndef body, drop its #else."""
    lines = src.splitlines(True)
    out: list[str] = []
    stack: list[tuple[str, bool]] = []

    ifdef_re = re.compile(rf"#\s*ifdef\s+{macro}\b")
    ifndef_re = re.compile(rf"#\s*ifndef\s+{macro}\b")
    if_re = re.compile(r"#\s*if(n?def)?\b")
    else_re = re.compile(r"#\s*else\b")
    elif_re = re.compile(r"#\s*elif\b")
    endif_re = re.compile(r"#\s*endif\b")

    def dropping() -> bool:
        return any(state == "drop" for state, _ in stack)

    for line in lines:
        if ifdef_re.match(line):
            stack.append(("drop", True))
            continue
        if ifndef_re.match(line):
            stack.append(("keep", True))
            continue
        if if_re.match(line):
            stack.append(("drop" if dropping() else "keep", False))
            if not dropping():
                out.append(line)
            continue
        if endif_re.match(line):
            if not stack:
                out.append(line)
                continue
            _, ours = stack.pop()
            if ours:
                continue
            if not dropping():
                out.append(line)
            continue
        if else_re.match(line) or elif_re.match(line):
            if stack and stack[-1][1]:
                state, _ = stack[-1]
                stack[-1] = ("keep" if state == "drop" else "drop", True)
                continue
            if not dropping():
                out.append(line)
            continue
        if not dropping():
            out.append(line)
    return "".join(out)


def strip_if0_blocks(src: str) -> str:
    """Remove #if 0 ... #endif blocks (including nested preprocessor)."""
    lines = src.splitlines(True)
    out: list[str] = []
    depth = 0
    skipping = False
    skip_depth = 0
    if0_re = re.compile(r"#\s*if\s+0\b")
    if_re = re.compile(r"#\s*if(n?def)?\b")
    endif_re = re.compile(r"#\s*endif\b")
    else_re = re.compile(r"#\s*el(se|if)\b")

    for line in lines:
        if not skipping and if0_re.match(line):
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
                # #else of #if 0: keep the else branch
                skipping = False
                # stay at same depth until endif — convert to keep mode by
                # treating remaining as normal but still need to consume endif
                # Simpler: don't support #else of #if 0 (none in scrn.c)
                continue
            continue
        out.append(line)
    return "".join(out)


def strip_includes(src: str) -> str:
    out: list[str] = []
    for line in src.splitlines(True):
        if re.match(r'#\s*include\s*[<"]', line):
            continue
        out.append(line)
    return "".join(out)


def rewrite_nopen_gotos(src: str) -> str:
    """Rewrite oops/ok gotos inside nopen."""
    # oops: skip attr probing when me is missing
    old_oops = (
        "\tif (!(t->me = jgetstr(t->cap,\"me\")))\n"
        "\t\tgoto oops;\n"
        "\tif ((t->mb = jgetstr(t->cap,\"mb\")))\n"
        "\t\tt->avattr |= BLINK;\n"
        "\tif ((t->md = jgetstr(t->cap,\"md\")))\n"
        "\t\tt->avattr |= BOLD;\n"
        "\tif ((t->mh = jgetstr(t->cap,\"mh\")))\n"
        "\t\tt->avattr |= DIM;\n"
        "\tif ((t->mr = jgetstr(t->cap,\"mr\")))\n"
        "\t\tt->avattr |= INVERSE;\n"
        "      oops:\n"
    )
    new_oops = (
        "\tt->me = jgetstr(t->cap,\"me\");\n"
        "\tif (t->me) {\n"
        "\t\tif ((t->mb = jgetstr(t->cap,\"mb\")))\n"
        "\t\t\tt->avattr |= BLINK;\n"
        "\t\tif ((t->md = jgetstr(t->cap,\"md\")))\n"
        "\t\t\tt->avattr |= BOLD;\n"
        "\t\tif ((t->mh = jgetstr(t->cap,\"mh\")))\n"
        "\t\t\tt->avattr |= DIM;\n"
        "\t\tif ((t->mr = jgetstr(t->cap,\"mr\")))\n"
        "\t\t\tt->avattr |= INVERSE;\n"
        "\t}\n"
    )
    if old_oops not in src:
        raise SystemExit("nopen oops block not found")
    src = src.replace(old_oops, new_oops, 1)

    old_ok = (
        "/* Make sure terminal can do absolute positioning */\n"
        "\tif (t->cm)\n"
        "\t\tgoto ok;\n"
        "\tif (t->ch && t->cv)\n"
        "\t\tgoto ok;\n"
        "\tif (t->ho && (t->lf || t->DO || t->cv))\n"
        "\t\tgoto ok;\n"
        "\tif (t->ll && (t->up || t->UP || t->cv))\n"
        "\t\tgoto ok;\n"
        "\tif (t->cr && t->cv)\n"
        "\t\tgoto ok;\n"
        "\tleave = 1;\n"
        "\tttclose();\n"
        "\tsignrm();\n"
        "        fprintf(stderr,\"cm=%p ch=%p cv=%p ho=%p lf=%p DO=%p ll=%p up=%p UP=%p cr=%p\\n\",\n"
        "                       t->cm, t->ch, t->cv, t->ho, t->lf, t->DO, t->ll, t->up, t->UP, t->cr);\n"
        "\tfputs(joe_gettext(_(\"Sorry, your terminal can't do absolute cursor positioning.\\nIt's broken\\n\")), stderr);\n"
        "\treturn NULL;\n"
        "      ok:\n"
    )
    new_ok = (
        "/* Make sure terminal can do absolute positioning */\n"
        "\tif (!(t->cm || (t->ch && t->cv) || (t->ho && (t->lf || t->DO || t->cv)) || (t->ll && (t->up || t->UP || t->cv)) || (t->cr && t->cv))) {\n"
        "\t\tleave = 1;\n"
        "\t\tttclose();\n"
        "\t\tsignrm();\n"
        "\t\tfprintf(stderr,\"cm=%p ch=%p cv=%p ho=%p lf=%p DO=%p ll=%p up=%p UP=%p cr=%p\\n\",\n"
        "\t\t               t->cm, t->ch, t->cv, t->ho, t->lf, t->DO, t->ll, t->up, t->UP, t->cr);\n"
        "\t\tfputs(joe_gettext(_(\"Sorry, your terminal can't do absolute cursor positioning.\\nIt's broken\\n\")), stderr);\n"
        "\t\treturn NULL;\n"
        "\t}\n"
    )
    if old_ok not in src:
        raise SystemExit("nopen ok block not found")
    src = src.replace(old_ok, new_ok, 1)
    return src


def rewrite_genfmt_emitch(src: str) -> str:
    old = (
        "\t\t\tcase '@':\n"
        "\t\t\t\tc = 0;\n"
        "\t\t\t\tgoto emitch;\n"
        "\t\t\tdefault: {\n"
        "emitch:\n"
        "\t\t\t\tif (col++ >= ofst) {\n"
        "\t\t\t\t\toutatr(locale_map, t, scrn, attr, x, y, (c&0x7F), atr);\n"
        "\t\t\t\t\t++scrn;\n"
        "\t\t\t\t\t++attr;\n"
        "\t\t\t\t\t++x;\n"
        "\t\t\t\t\t}\n"
        "\t\t\t\tbreak;\n"
        "\t\t\t\t}\n"
    )
    new = (
        "\t\t\tcase '@':\n"
        "\t\t\t\tc = 0;\n"
        "\t\t\t\tif (col++ >= ofst) {\n"
        "\t\t\t\t\toutatr(locale_map, t, scrn, attr, x, y, (c&0x7F), atr);\n"
        "\t\t\t\t\t++scrn;\n"
        "\t\t\t\t\t++attr;\n"
        "\t\t\t\t\t++x;\n"
        "\t\t\t\t}\n"
        "\t\t\t\tbreak;\n"
        "\t\t\tdefault: {\n"
        "\t\t\t\tif (col++ >= ofst) {\n"
        "\t\t\t\t\toutatr(locale_map, t, scrn, attr, x, y, (c&0x7F), atr);\n"
        "\t\t\t\t\t++scrn;\n"
        "\t\t\t\t\t++attr;\n"
        "\t\t\t\t\t++x;\n"
        "\t\t\t\t}\n"
        "\t\t\t\tbreak;\n"
        "\t\t\t\t}\n"
    )
    if old not in src:
        raise SystemExit("genfmt emitch block not found")
    return src.replace(old, new, 1)


def replace_func(src: str, start_re: str, new_body: str) -> str:
    m = re.search(start_re, src, re.M)
    if not m:
        raise SystemExit(f"function start not found: {start_re}")
    start = m.start()
    # find matching closing brace at column 0
    i = m.end() - 1
    # move to opening brace of function
    brace = src.find("{", start)
    depth = 0
    j = brace
    while j < len(src):
        c = src[j]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                end = j + 1
                if end < len(src) and src[end] == "\n":
                    end += 1
                return src[:start] + new_body.rstrip() + "\n\n" + src[end:]
        j += 1
    raise SystemExit("failed to find function end")


def main() -> None:
    stubs = (HERE / "scrn_stubs.h").read_text()
    cposs_new = (HERE / "scrn_cposs_new.c").read_text()
    doupscrl_new = (HERE / "scrn_doupscrl_new.c").read_text()
    dodnscrl_new = (HERE / "scrn_dodnscrl_new.c").read_text()

    STUBS_OUT.write_text(stubs)

    src = SRC.read_text()
    src = src.replace('#include "types.h"\n', "")
    src = strip_ifdef_blocks(src, "junk")
    src = assume_undefined(src, "TERMINFO")
    src = strip_if0_blocks(src)
    src = strip_includes(src)

    src = rewrite_nopen_gotos(src)
    src = rewrite_genfmt_emitch(src)

    src = replace_func(
        src,
        r"^static void cposs\(REGISTER SCRN \*t, REGISTER ptrdiff_t x, REGISTER ptrdiff_t y\)\n",
        cposs_new,
    )
    src = replace_func(
        src,
        r"^static void doupscrl\(SCRN \*t, ptrdiff_t top, ptrdiff_t bot, ptrdiff_t amnt, int atr\)\n",
        doupscrl_new,
    )
    src = replace_func(
        src,
        r"^static void dodnscrl\(SCRN \*t, ptrdiff_t top, ptrdiff_t bot, ptrdiff_t amnt, int atr\)\n",
        dodnscrl_new,
    )

    if re.search(r"(?m)^\s*goto\b", src):
        hits = [
            (i + 1, line)
            for i, line in enumerate(src.splitlines())
            if re.search(r"^\s*goto\b", line)
        ]
        raise SystemExit(f"goto remains: {hits}")

    bad_labels = []
    for i, line in enumerate(src.splitlines(), 1):
        mlab = re.match(r"^([A-Za-z_][A-Za-z0-9_]*):", line)
        if mlab and mlab.group(1) != "default":
            bad_labels.append((i, line.rstrip()))
    if bad_labels:
        raise SystemExit(f"labels remain: {bad_labels}")

    header = (
        "/* scrn.c for zig translate-c (goto-free, non-TERMINFO path) */\n"
        '#include "scrn_stubs.h"\n\n'
    )
    text = header + src
    OUT.write_text(text)
    shutil.copy2(Path(__file__), "/tmp/scrn_transform.py")
    print("wrote", STUBS_OUT)
    print("wrote", OUT, "lines", text.count("\n"))


if __name__ == "__main__":
    main()
