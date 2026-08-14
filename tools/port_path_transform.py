#!/usr/bin/env python3
"""Prepare joe/path.c for zig translate-c (goto-free, no MSDOS).

Writes /tmp/path_stubs.h and /tmp/path_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/path.c"
OUT = Path("/tmp/path_nogoto.c")
STUBS_OUT = Path("/tmp/path_stubs.h")


def strip_ifdef_blocks(src: str, macro: str) -> str:
    """Remove #ifdef MACRO ... #else/#endif nested-ish blocks (non-nested enough for path.c)."""
    # Handle #ifdef MACRO ... #else ... #endif and #ifdef MACRO ... #endif
    pattern = re.compile(
        rf"#ifdef\s+{macro}\b.*?(?:#else.*? )??#endif\b",
        re.DOTALL,
    )
    # Simpler iterative scan
    out = []
    i = 0
    lines = src.splitlines(keepends=True)
    while i < len(lines):
        line = lines[i]
        if re.match(rf"#ifdef\s+{macro}\b", line) or re.match(rf"#\s*ifdef\s+{macro}\b", line):
            depth = 1
            i += 1
            in_else = False
            else_buf: list[str] = []
            while i < len(lines) and depth > 0:
                l = lines[i]
                if re.match(r"#\s*if(n?def)?\b", l):
                    depth += 1
                    if in_else and depth > 1:
                        else_buf.append(l)
                elif re.match(r"#\s*endif\b", l):
                    depth -= 1
                    if depth == 0:
                        break
                    if in_else:
                        else_buf.append(l)
                elif depth == 1 and re.match(r"#\s*else\b", l):
                    in_else = True
                elif in_else:
                    else_buf.append(l)
                i += 1
            out.extend(else_buf)
            i += 1  # skip endif
            continue
        out.append(line)
        i += 1
    return "".join(out)


def convert_mkpath(src: str) -> str:
    start = src.find("int mkpath(const char *path_in)\n{")
    if start < 0:
        raise SystemExit("mkpath not found")
    end = src.find("\n}\n/********************************************************************/\n/* Create a temporary file */", start)
    if end < 0:
        raise SystemExit("mkpath end not found")

    new = r'''int mkpath(const char *path_in)
{
	char *path_cpy = zdup(path_in);
	char *path = path_cpy;
	int err = 0;
	char *org = pwd();
	char *s;

	if (path[0] == '/') {
		/* Start at root */
		if (chpwd("/")) {
			err = -1;
		} else {
			s = path;
			while (*s == '/')
				++s;
			path = s;
			while (!err && path[0]) {
				char c;
				for (s = path; (*s) && (*s != '/'); s++) ;
				c = *s;
				*s = 0;
				if (chpwd(path)) {
					if (mkdir(path, 0700)) {
						err = -1;
					} else if (chpwd(path)) {
						err = -1;
					}
				}
				*s = c;
				while (*s == '/')
					++s;
				path = s;
			}
		}
	} else {
		while (!err && path[0]) {
			char c;
			for (s = path; (*s) && (*s != '/'); s++) ;
			c = *s;
			*s = 0;
			if (chpwd(path)) {
				if (mkdir(path, 0700)) {
					err = -1;
				} else if (chpwd(path)) {
					err = -1;
				}
			}
			*s = c;
			while (*s == '/')
				++s;
			path = s;
		}
	}
	chpwd(org);
	joe_free(path_cpy);
	return err;
}'''
    return src[:start] + new + src[end + 2 :]


def convert_mktmp(src: str) -> str:
    """Keep only the HAVE_MKSTEMP implementation (no goto loop)."""
    start = src.find("char *mktmp(const char *where)\n{")
    if start < 0:
        raise SystemExit("mktmp not found")
    end = src.find("\n}\n/********************************************************************/\nint rmatch(", start)
    if end < 0:
        raise SystemExit("mktmp end not found")

    new = r'''char *mktmp(const char *where)
{
	char *name;
	int fd;
	ptrdiff_t namesize;

	if (!where)
		where = getenv("TEMP");
	if (!where)
		where = _PATH_TMP;

	namesize = zlen(where) + 16;
	name = vsmk(namesize);
	joe_snprintf_1(name, (size_t)namesize, "%s/joe.tmp.XXXXXX", where);
	if((fd = mkstemp(name)) == -1)
		return NULL;

	fchmod(fd, 0600);
	close(fd);
	return name;
}'''
    return src[:start] + new + src[end + 2 :]


def main() -> None:
    stubs = (HERE / "path_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")

    # Drop all system/feature includes — stubs provide decls
    src = re.sub(r'#ifdef HAVE_PWD_H\n#include <pwd\.h>\n#endif\n', "", src)
    src = re.sub(r'#ifdef HAVE_PATHS_H\n#  include <paths\.h>.*?\n#endif\n', "", src, flags=re.DOTALL)
    src = re.sub(r'#ifdef HAVE_LIMITS_H\n#include <limits\.h>\n#endif\n', "", src)

    # Strip huge dirent include tree — stubs define DIR/dirent/NAMLEN
    dirent_start = src.find("#ifdef HAVE_DIRENT_H\n")
    if dirent_start >= 0:
        dirent_end = src.find("#endif\n\n#ifdef __MSDOS__", dirent_start)
        if dirent_end < 0:
            dirent_end = src.find("#endif\n\n#ifdef __MSDOS__", dirent_start)
        # Find the closing of the whole nested block before MSDOS drive macros
        marker = "#ifdef __MSDOS__\t/* paths in MS-DOS"
        marker_idx = src.find(marker)
        if marker_idx < 0:
            marker = "#ifdef __MSDOS__\t/* paths in MS-DOS can include"
            marker_idx = src.find(marker)
        if dirent_start >= 0 and marker_idx > dirent_start:
            src = src[:dirent_start] + src[marker_idx:]

    # Strip MSDOS drive-letter macros: keep else (no-op) branch behavior via defines
    src = re.sub(
        r"#ifdef __MSDOS__\t/\* paths in MS-DOS.*?#else\n#define do_if_drive_letter\(path, command\)\tdo \{ \} while\(0\)\n#endif\n#define skip_drive_letter\(path\)\tdo_if_drive_letter\(\(path\), \(path\) \+= 2\)\n",
        "#define do_if_drive_letter(path, command)\tdo { } while(0)\n"
        "#define skip_drive_letter(path)\tdo_if_drive_letter((path), (path) += 2)\n",
        src,
        flags=re.DOTALL,
    )

    # Drop _PATH_TMP / PATH_MAX ifndefs — stubs provide them
    src = re.sub(r"#ifndef\s+_PATH_TMP\n.*?#endif\n", "", src, flags=re.DOTALL)
    src = re.sub(r"#ifndef PATH_MAX\n.*?#endif\n", "", src, flags=re.DOTALL)

    # Strip MSDOS joesep body / chpwd / mktmp already handled / readdir MSDOS block
    src = strip_ifdef_blocks(src, "__MSDOS__")

    # Force Unix chpwd (strip leftover ifdefs around chpwd if any remain)
    src = convert_mkpath(src)
    src = convert_mktmp(src)

    # pwd: keep HAVE_GETCWD path only
    src = re.sub(
        r"#ifdef HAVE_GETCWD\n\tret = getcwd\(buf, PATH_MAX - 1\);\n#else\n\tret = getwd\(buf\);\n#endif\n",
        "\tret = getcwd(buf, PATH_MAX - 1);\n",
        src,
    )

    # Drop #if 0 block in open_configrc_file
    src = re.sub(r"#if 0\n.*?\#endif\n", "", src, flags=re.DOTALL)

    # Drop #ifdef junk in simplify_prefix
    src = re.sub(r"#ifdef junk\n.*?#endif\n", "", src, flags=re.DOTALL)

    if re.search(r"(?m)^\s*goto\b", src):
        hits = [
            f"{i}:{line.rstrip()}"
            for i, line in enumerate(src.splitlines(), 1)
            if re.search(r"^\s*goto\b", line)
        ]
        raise SystemExit(f"goto remains: {hits}")

    # Forward decls (mkpath calls pwd/chpwd before their definitions)
    forwards = """
char *pwd(void);
int chpwd(const char *path);
static char *open_configrc_file(JFILE **result, const char *sys, const char *prefix, const char *name, const char *suffix);

"""
    insert_at = src.find("/********************************************************************/\nchar *joesep(")
    if insert_at < 0:
        raise SystemExit("joesep marker not found")
    src = src[:insert_at] + forwards + src[insert_at:]

    header = (
        "/* path.c for zig translate-c (goto-free) */\n"
        '#include "path_stubs.h"\n\n'
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))
    if "goto " in src:
        raise SystemExit("goto string remains")


if __name__ == "__main__":
    main()
