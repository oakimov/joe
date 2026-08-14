#!/usr/bin/env python3
"""Transform joe/ufile.c into goto-free form for zig translate-c.

Writes /tmp/ufile_stubs.h and /tmp/ufile_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/ufile.c"
OUT = Path("/tmp/ufile_nogoto.c")
STUBS_OUT = Path("/tmp/ufile_stubs.h")


def convert_doquerysave(src: str) -> str:
    """Convert the single `goto next;` in doquerysave into a while loop."""
    start = src.find("static int doquerysave(W *w,int c,void *obj,int *notify)\n{")
    if start < 0:
        raise SystemExit("doquerysave not found")
    end = src.find("\n}\n\nstatic int query_next(BW *bw, struct savereq *req,int flg,int *notify)", start)
    if end < 0:
        raise SystemExit("doquerysave end not found")

    new = r'''static int doquerysave(W *w,int c,void *obj,int *notify)
{
	BW *bw;
	struct savereq *req = (struct savereq *)obj;
	WIND_BW(bw, w);
	if (c == YES_CODE || yncheck(yes_key, c)) {
		if (bw->b->name && bw->b->name[0])
			return dosave1(bw->parent, vsncpy(NULL,0,sz(bw->b->name)), req, notify);
		else {
			BW *pbw;
			pbw = wmkpw(bw->parent, joe_gettext(_("Name of file to save (%{help} for help): ")), &filehist, dosave1, "Names", NULL, cmplt_file_out, req, notify, locale_map, (PWFLAG_FILENAME | PWFLAG_SEED_CD | PWFLAG_UPDATE_CD));

			if (pbw) {
				return 0;
			} else {
				joe_free(req);
				return -1;
			}
		}
	} else if (c == NO_CODE || yncheck(no_key, c)) {
		/* Find next buffer to save */
		if (bw->b->changed)
			req->not_saved = 1;
		/* was: next: / goto next; — loop until modified non-scratch buffer */
		while (1) {
			if (unbuf(bw->parent, 0)) {
				if (notify)
					*notify = 1;
				genexmsgmulti(bw,1,req->not_saved);
				rmsavereq(req);
				return 0;
			}
			bw = (BW *)w->object;
			if (bw->b==req->first) {
				if (notify)
					*notify = 1;
				genexmsgmulti(bw,1,req->not_saved);
				rmsavereq(req);
				return 0;
			}
			if (!bw->b->changed || bw->b->scratch)
				continue;

			return doquerysave(bw->parent,0,req,notify);
		}
	} else {
		char buf[1024];
		joe_snprintf_1(buf,1024,joe_gettext(_("File %s has been modified.  Save it (y,n,%{abort})? ")),bw->b->name ? bw->b->name : "(Unnamed)" );
		if (mkqw(bw->parent, sz(buf), doquerysave, NULL, req, notify)) {
			return 0;
			} else {
			/* Should be in abort function */
			rmsavereq(req);
			return -1;
		}
	}
}'''
    return src[:start] + new + src[end + 2 :]


def strip_ifdef_blocks(src: str) -> str:
    """Drop platform/feature ifdefs that pull system headers or dead junk."""
    # Remove utime.h includes (we declare utimbuf ourselves)
    src = re.sub(
        r"#ifdef HAVE_UTIME_H\n#include <utime\.h>\n#else\n#ifdef HAVE_SYS_UTIME_H\n#include <sys/utime\.h>\n#endif\n#endif\n",
        "",
        src,
    )
    # Force non-NeXT utimbuf path inside HAVE_UTIME
    src = src.replace("#ifdef NeXT\n", "#if 0 /* NeXT */\n")
    # Drop SELinux / MSDOS branches
    src = src.replace("#ifdef WITH_SELINUX\n", "#if 0 /* WITH_SELINUX */\n")
    src = src.replace("#ifdef __MSDOS__\n", "#if 0 /* __MSDOS__ */\n")
    # Drop #ifdef junk buffer-list menu
    src = src.replace("#ifdef junk\n", "#if 0 /* junk */\n")
    return src


def main() -> None:
    stubs = (HERE / "ufile_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")
    src = strip_ifdef_blocks(src)
    src = convert_doquerysave(src)

    if re.search(r"(?m)^\s*goto\b", src):
        hits = [
            f"{i}:{line.rstrip()}"
            for i, line in enumerate(src.splitlines(), 1)
            if re.search(r"^\s*goto\b", line)
        ]
        raise SystemExit(f"goto remains: {hits}")
    # bare labels (e.g. leftover next:) should not remain
    hits = [
        f"{i}:{line.rstrip()}"
        for i, line in enumerate(src.splitlines(), 1)
        if re.search(r"^\s*\w+:\s*$", line) and not line.strip().startswith("/*")
    ]
    if hits:
        raise SystemExit(f"labels remain: {hits}")

    # Forward decls after globals
    marker = "extern int noexmsg;\n"
    idx = src.find(marker)
    if idx < 0:
        raise SystemExit("noexmsg extern not found")
    insert_at = idx + len(marker)
    forward = """
struct savereq;
static void genexmsgmulti(BW *bw, int saved, int skipped);
static int dosys(W *w, char *s, void *object, int *notify);
static int cp(char *from, char *to);
static int backup(BW *bw);
static struct savereq *mksavereq(int (*callback)(BW *bw, struct savereq *req, int flg, int *notify), char *name, B *first, int myrename, int block_save);
static void rmsavereq(struct savereq *req);
static int saver(W *w, int c, void *object, int *notify);
static int dosave(BW *bw, struct savereq *req, int *notify);
static int dosave2(W *w, int c, void *object, int *notify);
static int dosave1(W *w, char *s, void *object, int *notify);
static int doedit1(W *w, int c, void *obj, int *notify);
static int doedit(W *w, char *s, void *obj, int *notify);
static int dosetcd(W *w, char *s, void *obj, int *notify);
static void wpush(BW *bw);
static int doscratch(W *w, char *s, void *obj, int *notify);
static int doscratchpush(W *w, char *s, void *obj, int *notify);
static int bufedcmplt(BW *bw, int k);
static int dorepl(W *w, char *s, void *obj, int *notify);
static int exdone(BW *bw, struct savereq *req, int flg, int *notify);
static int nask(W *w, int c, void *object, int *notify);
static int dolose(W *w, int c, void *object, int *notify);
static int dobufed(W *w, char *s, void *object, int *notify);
static int doquerysave(W *w, int c, void *obj, int *notify);
static int query_next(BW *bw, struct savereq *req, int flg, int *notify);
static int doreload(W *w, int c, void *object, int *notify);

"""
    src = src[:insert_at] + forward + src[insert_at:]

    header = (
        "/* ufile.c for zig translate-c (goto-free) */\n"
        '#include "ufile_stubs.h"\n\n'
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
