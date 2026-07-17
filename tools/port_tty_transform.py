#!/usr/bin/env python3
"""Transform joe/tty.c into goto-free, platform-narrowed form for zig translate-c.

Keeps the macOS/hybrid active paths (POSIX termios, openpty, login_tty, setitimer).
Writes /tmp/tty_stubs.h and /tmp/tty_nogoto.c.
"""
from __future__ import annotations

import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/tty.c"
OUT = Path("/tmp/tty_nogoto.c")
STUBS_OUT = Path("/tmp/tty_stubs.h")

# MacOS hybrid build truth table (matches joe/autoconf.h + system headers)
DEFINED = {
    "HAVE_UTIL_H",
    "HAVE_OPENPTY",
    "HAVE_LOGIN_TTY",
    "HAVE_POSIX_TERMIOS",
    "HAVE_SETITIMER",
    "HAVE_SYS_WAIT_H",
    "HAVE_SYS_PARAM_H",
    "HAVE_UTMP_H",
    "HAVE_FORK",
    "HAVE_SYS_TIME_H",
    "HAVE_SYS_IOCTL_H",
    "SIGWINCH",
    "SIGTSTP",
    "SIGCHLD",
    "SIG_SETMASK",
    "TIOCGWINSZ",
    "TIOCSWINSZ",
    "B19200",
    "B38400",
    "EXTA",
    "EXTB",
    "O_NDELAY",
    "O_NONBLOCK",
}


def eval_ifdef_tree(src: str) -> str:
    lines = src.splitlines(True)
    out: list[str] = []
    stack: list[tuple[bool, bool, bool]] = []  # parent, active, seen_true

    def keeping() -> bool:
        return all(a for _, a, _ in stack) if stack else True

    def eval_expr(expr: str) -> bool:
        expr = expr.strip()
        if re.fullmatch(r"defined\(\w+\)", expr):
            name = re.findall(r"defined\((\w+)\)", expr)[0]
            return name in DEFINED
        if re.fullmatch(r"!defined\(\w+\)", expr):
            name = re.findall(r"defined\((\w+)\)", expr)[0]
            return name not in DEFINED
        if expr in ("0", "1"):
            return expr == "1"
        if re.fullmatch(r"\w+", expr):
            return expr in DEFINED
        raise SystemExit(f"unhandled preprocessor expr: {expr!r}")

    for line in lines:
        m = re.match(r"#\s*(ifdef|ifndef|if|elif|else|endif)\b(.*)$", line)
        if not m:
            if keeping():
                out.append(line)
            continue
        kind = m.group(1)
        rest = m.group(2).strip()
        if kind == "ifdef":
            name = rest.split()[0]
            val = name in DEFINED
            parent = keeping()
            stack.append((parent, parent and val, val))
        elif kind == "ifndef":
            name = rest.split()[0]
            val = name not in DEFINED
            parent = keeping()
            stack.append((parent, parent and val, val))
        elif kind == "if":
            val = eval_expr(rest)
            parent = keeping()
            stack.append((parent, parent and val, val))
        elif kind == "elif":
            parent, _active, seen = stack.pop()
            val = eval_expr(rest)
            new_active = parent and (not seen) and val
            stack.append((parent, new_active, seen or val))
        elif kind == "else":
            parent, _active, seen = stack.pop()
            stack.append((parent, parent and (not seen), True))
        elif kind == "endif":
            stack.pop()
    if stack:
        raise SystemExit("unbalanced preprocessor conditionals")
    return "".join(out)


def main() -> None:
    stubs = (HERE / "tty_stubs.h").read_text()
    ttgetc_new = (HERE / "tty_ttgetc_new.c").read_text()
    mpx_loop_new = (HERE / "tty_mpx_copy_loop_new.c").read_text()

    STUBS_OUT.write_text(stubs)

    src = SRC.read_text()
    src = src.replace('#include "types.h"\n', "")
    src = eval_ifdef_tree(src)

    # Drop leftover system includes; stubs replace them.
    src = re.sub(r'(?m)^#\s*include\s*[<"].*[>"].*\n', "", src)

    # Replace ttgetc body (goto loop)
    m = re.search(r"char ttgetc\(void\)\s*\{.*?\n\}", src, re.S)
    if not m:
        raise SystemExit("ttgetc not found")
    src = src[: m.start()] + ttgetc_new + src[m.end() :]

    # Replace mpxmk copy-process loop (goto loop near end)
    m = re.search(
        r"/\* We don't really get EOF from a pty.*?\n\t\t\}\n\t\}",
        src,
        re.S,
    )
    if not m:
        raise SystemExit("mpx copy loop not found")
    # Keep the closing `}` of the fork child / outer if — replacement includes inner for-loop
    # Original ends with: loop... } else { _exit } } }  then joe_read(comm...
    # Match from comment through the loop's closing braces carefully.
    m2 = re.search(
        r"\t\t/\* We don't really get EOF from a pty.*?_exit\(0\);\n\t\t\}\n\t\}",
        src,
        re.S,
    )
    if not m2:
        raise SystemExit("mpx copy loop (precise) not found")
    # Replacement should end similarly: for(;;){..._exit...} then close fork-child block
    replacement = mpx_loop_new.rstrip() + "\n\t}"
    src = src[: m2.start()] + replacement + src[m2.end() :]

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
        "/* tty.c for zig translate-c (goto-free, macOS hybrid paths) */\n"
        '#include "tty_stubs.h"\n\n'
    )
    text = header + src
    OUT.write_text(text)
    shutil.copy2(HERE / "tty_stubs.h", "/tmp/tty_stubs.h")
    print("wrote", STUBS_OUT)
    print("wrote", OUT, "lines", text.count("\n"))


if __name__ == "__main__":
    main()
