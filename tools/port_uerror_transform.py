#!/usr/bin/env python3
"""Transform joe/uerror.c into goto-free form for zig translate-c.

Writes /tmp/uerror_stubs.h and /tmp/uerror_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/uerror.c"
OUT = Path("/tmp/uerror_nogoto.c")
STUBS_OUT = Path("/tmp/uerror_stubs.h")


def convert_parseone(src: str) -> str:
    """Remove goto bye in parseone via if/else restructuring."""
    start = src.find(
        "static void parseone(struct charmap *map,const char *s,char **rtn_name,off_t *rtn_line)\n{"
    )
    if start < 0:
        raise SystemExit("parseone not found")
    end = src.find(
        "\n}\n\n/* Parser for file name lists from grep, find and ls.",
        start,
    )
    if end < 0:
        raise SystemExit("parseone end not found")

    new = r'''static void parseone(struct charmap *map,const char *s,char **rtn_name,off_t *rtn_line)
{
	int flg;
	int c;
	char *name = NULL;
	off_t line = -1;
	const char *u, *v, *t;

	v = s;
	flg = 0;

	/* JOE: prefix → skip parsing; flg stays 0 so line becomes -1 */
	if (!(s[0] == 'J' && s[1] == 'O' && s[2] == 'E' && s[3] == ':')) {
		do {

			/* Skip to first word */
			for (u = v; *u && !((t = u), (c = fwrd_c(map, &t, NULL)), ((c >= 0 && joe_isalnum_(map, c)) || c == '.' || c == '/' || c == '~')); u = t) ;

			/* Skip to end of first word */
			for (v = u; (t = v), (c = fwrd_c(map, &t, NULL)), ((c >= 0 && joe_isalnum_(map, c)) || c == '.' || c == '/' || c == '-' || c == '~'); v = t)
				if (c == '.')
					flg = 1;
		} while (!flg && u != v);

		/* Save file name */
		if (u != v)
			name = vsncpy(NULL, 0, u, v - u);

		/* Skip to first number */
		for (u = v; *u && (*u < '0' || *u > '9'); ++u) ;

		/* Skip to end of first number */
		for (v = u; *v >= '0' && *v <= '9'; ++v) ;

		/* Save line number */
		if (u != v) {
			line = ztoo(u);
		}
		if (line != -1)
			--line;

		/* Look for ':' */
		flg = 0;
		while (*v) {
		/* Allow : anywhere on line: works for MIPS C compiler */
/*
	for (y = 0; s[y];)
*/
			if (*v == ':') {
				flg = 1;
				break;
			}
			++v;
		}
	}

	if (!flg)
		line = -1;

	*rtn_name = name;
	*rtn_line = line;
}'''
    return src[:start] + new + src[end + 2 :]


def convert_parseone_grep(src: str) -> str:
    """Remove goto bye in parseone_grep via if/else restructuring."""
    start = src.find(
        "void parseone_grep(struct charmap *map,const char *s,char **rtn_name,off_t *rtn_line)\n{"
    )
    if start < 0:
        raise SystemExit("parseone_grep not found")
    end = src.find(
        "\n}\n\nstatic int parseit(struct charmap *map,const char *s, off_t row,",
        start,
    )
    if end < 0:
        raise SystemExit("parseone_grep end not found")

    new = r'''void parseone_grep(struct charmap *map,const char *s,char **rtn_name,off_t *rtn_line)
{
	int y;
	char *name = NULL;
	off_t line = -1;

	/* JOE: prefix → leave name=NULL, line=-1 */
	if (!(s[0] == 'J' && s[1] == 'O' && s[2] == 'E' && s[3] == ':')) {
		/* Skip to first : or end of line */
		for (y = 0;s[y] && s[y] != ':';++y);
		if (y) {
			/* This should be the file name */
			name = vsncpy(NULL,0,s,y);
			line = 0;
			if (s[y] == ':') {
				/* Maybe there's a line number */
				++y;
				while (s[y] >= '0' && s[y] <= '9')
					line = line * 10 + (s[y++] - '0');
				--line;
				if (line < 0 || s[y] != ':') {
					/* Line number is only valid if there's a second : */
					line = 0;
				}
			}
		}
	}

	*rtn_name = name;
	*rtn_line = line;
}'''
    return src[:start] + new + src[end + 2 :]


def main() -> None:
    stubs = (HERE / "uerror_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")
    src = convert_parseone(src)
    src = convert_parseone_grep(src)

    if re.search(r"(?m)^\s*goto\b", src):
        hits = [
            f"{i}:{line.rstrip()}"
            for i, line in enumerate(src.splitlines(), 1)
            if re.search(r"^\s*goto\b", line)
        ]
        raise SystemExit(f"goto remains: {hits}")
    if re.search(r"(?m)^\s*\w+:\s*$", src):
        # bare labels (e.g. leftover bye:) should not remain
        hits = [
            f"{i}:{line.rstrip()}"
            for i, line in enumerate(src.splitlines(), 1)
            if re.search(r"^\s*\w+:\s*$", line)
            and not line.strip().startswith("/*")
        ]
        # Allow nothing — fail if any leftover labels
        if hits:
            raise SystemExit(f"labels remain: {hits}")

    # Forward decls after ERROR typedef / sentinel definitions
    marker = "ERROR errnodes = { {&errnodes, &errnodes} };\n"
    idx = src.find(marker)
    if idx < 0:
        raise SystemExit("errnodes sentinel not found")
    insert_at = idx + len(marker)
    forward = """
static void freeerr(ERROR *n);
static int freeall(void);
static void parsedir(struct charmap *map, const char *s, char **rtn_dir);
static void parseone(struct charmap *map, const char *s, char **rtn_name, off_t *rtn_line);
static int parseit(struct charmap *map, const char *s, off_t row,
  void (*parseline)(struct charmap *map, const char *s, char **rtn_name, off_t *rtn_line), char *current_dir);
static off_t parserr(B *b);
static BW *find_a_good_bw(B *b);
static int jump_to_file_line(BW *bw, char *file, off_t line, char *msg);
static ERROR *srcherr(BW *bw, char *file, off_t line);
void kill_ansi(char *s);

"""
    src = src[:insert_at] + forward + src[insert_at:]

    header = (
        "/* uerror.c for zig translate-c (goto-free) */\n"
        '#include "uerror_stubs.h"\n\n'
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
