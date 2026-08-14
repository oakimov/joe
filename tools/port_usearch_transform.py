#!/usr/bin/env python3
"""Transform joe/usearch.c into goto-free form for zig translate-c.

Writes /tmp/usearch_stubs.h and /tmp/usearch_nogoto.c.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/usearch.c"
OUT = Path("/tmp/usearch_nogoto.c")
STUBS_OUT = Path("/tmp/usearch_stubs.h")


def convert_searchf(src: str) -> str:
    """Convert searchf try_again:/wrapped: gotos into nested while loops."""
    start = src.find("static P *searchf(BW *bw,SRCH *srch, P *p)\n{")
    if start < 0:
        raise SystemExit("searchf not found")
    end = src.find("\n}\n\n/* Search backwards.", start)
    if end < 0:
        raise SystemExit("searchf end not found")

    new = r'''static P *searchf(BW *bw,SRCH *srch, P *p)
{
	P *start;
	P *end;
	int flag = 0;

	start = pdup(p, "searchf");
	end = pdup(p, "searchf");

	/* Outer: wrap retry; inner: zero-width stuck retry */
	while (1) {
		int try_again;
		do {
			try_again = 0;
			while (srch->ignore ? pifind(start, srch->comp->prefix, srch->comp->prefix_len) : pfind(start, srch->comp->prefix, srch->comp->prefix_len)) {
				pset(end, start);
				/* pfwrd(end, x); */ /* Comment out for regexec */
				if (srch->wrap_flag && start->byte>=srch->wrap_p->byte)
					break;
				if (!joe_regexec(srch->comp, end, NMATCHES, srch->pieces, srch->ignore)) {
					if (end->byte == srch->last_repl && !flag) {
						/* Stuck on zero-width regex? */
						pset(start, p);
						if (pgetc(start) == NO_MORE_DATA)
							break;
						pset(end, start);
						++flag; /* Try repeating, but only one time */
						try_again = 1;
						break;
					} else {
						srch->entire.rm_so = start->byte;
						srch->entire.rm_eo = end->byte;
						pset(p, end);
						prm(start);
						prm(end);
						srch->last_repl = p->byte; /* Prevent getting stuck with zero-length regex */
						return p;
					}
				}
				if (pgetc(start) == NO_MORE_DATA)
					break;
			}
		} while (try_again);
		if (srch->allow_wrap && !srch->wrap_flag && srch->wrap_p) {
			msgnw(bw->parent, joe_gettext(_("Wrapped")));
			srch->wrap_flag = 1;
			p_goto_bof(start);
			continue; /* wrapped */
		}
		break;
	}
	srch->last_repl = -1;
	prm(start);
	prm(end);
	return NULL;
}'''
    # end points at "\n}" before the following comment — skip that brace
    return src[:start] + new + src[end + 2 :]


def convert_searchb(src: str) -> str:
    """Convert searchb try_again:/wrapped: gotos into nested while loops."""
    start = src.find("static P *searchb(BW *bw,SRCH *srch, P *p)\n{")
    if start < 0:
        raise SystemExit("searchb not found")
    end = src.find("\n}\n\n/* Make a search stucture */", start)
    if end < 0:
        raise SystemExit("searchb end not found")

    new = r'''static P *searchb(BW *bw,SRCH *srch, P *p)
{
	P *start;
	P *end;
	int flag = 0;

	start = pdup(p, "searchb");
	end = pdup(p, "searchb");

	/* Outer: wrap retry; inner: zero-width stuck retry */
	while (1) {
		int try_again;
		do {
			try_again = 0;
			while (pbkwd(start, 1L)
			       && (srch->ignore ? prifind(start, srch->comp->prefix, srch->comp->prefix_len) : prfind(start, srch->comp->prefix, srch->comp->prefix_len))) {
				pset(end, start);
				/* pfwrd(end, x); */ /* Comment out for joe_regexec */
				if (srch->wrap_flag && start->byte<srch->wrap_p->byte)
					break;
				if (!joe_regexec(srch->comp, end, NMATCHES, srch->pieces, srch->ignore)) {
					if (start->byte == srch->last_repl && !flag) {
						/* Stuck? */
						pset(start, p);
						if (prgetc(start) == NO_MORE_DATA)
							break;
						pset(end, start);
						++flag;
						try_again = 1;
						break;
					} else {
						srch->entire.rm_so = start->byte;
						srch->entire.rm_eo = end->byte;
						pset(p, start);
						prm(start);
						prm(end);
						return p;
					}
				}
			}
		} while (try_again);
		if (srch->allow_wrap && !srch->wrap_flag && srch->wrap_p) {
			msgnw(bw->parent, joe_gettext(_("Wrapped")));
			srch->wrap_flag = 1;
			p_goto_eof(start);
			continue; /* wrapped */
		}
		break;
	}
	srch->last_repl = -1;
	prm(start);
	prm(end);
	return NULL;
}'''
    return src[:start] + new + src[end + 2 :]


def convert_insert(src: str) -> str:
    """Rewrite insert() goto insertit without goto (duplicate insert body)."""
    start = src.find("static P *insert(SRCH *srch, P *p, const char *s, ptrdiff_t len, B **entire, B **pieces)\n{")
    if start < 0:
        raise SystemExit("insert not found")
    end = src.find("\n}\n\n/* Search system user interface */", start)
    if end < 0:
        raise SystemExit("insert end not found")

    # Shared body for inserting buffer `b` with case_flag handling
    insert_b_body = r'''				if (case_flag) {
						P *q = pdup(b->bof, "insert");
						while (!piseof(q)) {
							int ch = pgetc(q);
							switch (case_flag) {
								case 1: {
									case_flag = 0;
									FALLTHROUGH
								} case 2: {
									ch = joe_tolower(p->b->o.charmap, ch);
									break;
								} case -1: {
									case_flag = 0;
									FALLTHROUGH
								} case -2: {
									ch = joe_toupper(p->b->o.charmap, ch);
									break;
								}
							}
							binsc(p, ch);
							pgetc(p);
						}
						prm(q);
						brm(b);
					} else {
						off_t l = b->eof->byte;
						binsb(p, b);
						pfwrd(p, l);
					}'''

    new = (
        r'''static P *insert(SRCH *srch, P *p, const char *s, ptrdiff_t len, B **entire, B **pieces)
{
	ptrdiff_t x;
	off_t starting = p->byte;
	int nth;
	int case_flag = 0;
	B *b;

	while (len) {
		for (x = 0; x != len && s[x] != '\\'; ++x) ;
		if (x) {
			const char *t = s;
			ptrdiff_t y = x;
			switch (case_flag) {
				case 1: {
					case_flag = 0;
					FALLTHROUGH
				} case 2: {
					while (y) {
						int ch = fwrd_c(p->b->o.charmap, &t, &y);
						ch = joe_tolower(p->b->o.charmap, ch);
						binsc(p, ch);
						pgetc(p);
					}
					break;
				} case -1: {
					case_flag = 0;
					FALLTHROUGH
				} case -2: {
					while (y) {
						int ch = fwrd_c(p->b->o.charmap, &t, &y);
						ch = joe_toupper(p->b->o.charmap, ch);
						binsc(p, ch);
						pgetc(p);
					}
					break;
				}
			}
			if (y) {
				binsm(p, t, y);
				pfwrd(p, y);
			}
			len -= x;
			s += x;
		} else if (len >= 2) {
			if (s[1] == 'l') {
				case_flag = 1;
				s += 2;
				len -= 2;
			} else if (s[1] == 'L') {
				case_flag = 2;
				s += 2;
				len -= 2;
			} else if (s[1] == 'u') {
				case_flag = -1;
				s += 2;
				len -= 2;
			} else if (s[1] == 'U') {
				case_flag = -2;
				s += 2;
				len -= 2;
			} else if (s[1] == 'E') {
				case_flag = 0;
				s += 2;
				len -= 2;
			} else if (s[1] >= '1' && s[1] <= '9') {
				nth = s[1] - '1';
				s += 2;
				len -= 2;
				if (pieces[nth]) {
					b = bcpy(pieces[nth]->bof, pieces[nth]->eof);
'''
        + insert_b_body
        + r'''
				}
			} else if (s[1] == '&') {
				s += 2;
				len -= 2;
				if (*entire) {
					b = bcpy(entire[0]->bof, entire[0]->eof);
'''
        + insert_b_body
        + r'''
				}
			} else {
				const char *a = s + x;
				ptrdiff_t l = len - x;
				int ch = escape(p->b->o.charmap->type, &a, &l, NULL);
				if (ch != -256) {
					switch (case_flag) {
						case 1: {
							case_flag = 0;
							FALLTHROUGH
						} case 2: {
							ch = joe_tolower(p->b->o.charmap, ch);
							break;
						} case -1: {
							case_flag = 0;
							FALLTHROUGH
						} case -2: {
							ch = joe_toupper(p->b->o.charmap, ch);
							break;
						}
					}
					binsc(p, ch);
					pgetc(p);
				}
				len -= a - s;
				s = a;
			}
		} else
			len = 0;
	}

	if (srch->backwards)
		pbkwd (p, p->byte - starting);

	return p;
}'''
    )
    return src[:start] + new + src[end + 2 :]


def convert_fnext(src: str) -> str:
    """Convert fnext again:/next: gotos into nested loops."""
    start = src.find("static int fnext(BW *bw, SRCH *srch)\n{")
    if start < 0:
        raise SystemExit("fnext not found")
    end = src.find("\n}\n\nint dopfnext(", start)
    if end < 0:
        raise SystemExit("fnext end not found")

    new = r'''static int fnext(BW *bw, SRCH *srch)
{
	P *sta;

	if (!srch->first) {
		srch->first = bw->b;
		srch->current = bw->b;
	}

	while (1) { /* next */
		if (srch->repeat != -1) {
			if (!srch->repeat)
				return 0;
			else
				--srch->repeat;
		}
		while (1) { /* again */
			/* Clear compiled version of pattern if character map changed (perhaps because we switched buffer) */
			if (srch->comp && srch->comp->cmap != bw->b->o.charmap) {
				clrcomp(srch);
				/* Fail if character map of search prompt doesn't match map of buffer */
				msgnw(bw->parent, joe_gettext(_("Character set of buffer does not match character set of search string")));
				return 4;
			}
			/* Compile pattern if we don't already have it */
			if (!srch->comp) {
				srch->comp = joe_regcomp(bw->b->o.charmap, srch->pattern, sLEN(srch->pattern), srch->ignore, srch->regex, srch->debug);
				if (srch->comp->err) {
					msgnw(bw->parent, joe_gettext(srch->comp->err));
					return 4;
				}
			}
			if (srch->backwards)
				sta = searchb(bw, srch, bw->cursor);
			else
				sta = searchf(bw, srch, bw->cursor);
			if (!sta && srch->all) {
				B *b;
				if (srch->all == 2)
					b = beafter(srch->current);
				else {
					berror = 0;
					b = bafter(srch->current);
				}
				if (b && b != srch->first && !berror) {
					W *w = bw->parent;
					srch->current = b;
					/* this bumps reference count of b */
					get_buffer_in_window(bw, b);
					bw = (BW *)w->object;
					p_goto_bof(bw->cursor);
					continue; /* again */
				} else if (berror) {
					msgnw(bw->parent, joe_gettext(msgs[-berror]));
				}
			}
			if (!sta) {
				srch->repeat = -1;
				return 1;
			}
			if (srch->rest || (srch->repeat != -1 && srch->replace)) {
				if (srch->valid)
					switch (restrict_to_block(bw, srch)) {
					case -1:
						continue; /* again */
					case 1:
						if (srch->addr >= 0)
							pgoto(bw->cursor, srch->addr);
						return !srch->rest;
					}
				if (doreplace(bw, srch))
					return 0;
				break; /* next */
			} else if (srch->repeat != -1) {
				if (srch->valid)
					switch (restrict_to_block(bw, srch)) {
					case -1:
						continue; /* again */
					case 1:
						if (srch->addr >= 0)
							pgoto(bw->cursor, srch->addr);
						return 1;
					}
				srch->addr = bw->cursor->byte;
				break; /* next */
			} else
				return 2;
		}
	}
}'''
    return src[:start] + new + src[end + 2 :]


def convert_dopfnext(src: str) -> str:
    """Convert dopfnext again:/bye: gotos — bye is cleanup/exit path."""
    start = src.find("int dopfnext(BW *bw, SRCH *srch, int *notify)\n{")
    if start < 0:
        raise SystemExit("dopfnext not found")
    end = src.find("\n}\n\nint pfnext(", start)
    if end < 0:
        raise SystemExit("dopfnext end not found")

    new = r'''int dopfnext(BW *bw, SRCH *srch, int *notify)
{
	W *w;
	int fnr;
	int orgmid = opt_mid;	/* Original mid status */
	int ret = 0;
	int do_bye;

	opt_mid = 1;		/* Screen recenters mode during search */
	if (csmode)
		smode = 2;	/* We have started a search mode */
	if (srch->replace)
		visit(srch, bw, 0);
	while (1) { /* again */
		do_bye = 0;
		w = bw->parent;
		fnr = fnext(bw, srch);
		bw  = (BW *)w->object;
		switch (fnr) {
		case 0:
			break;
		case 1:
			do_bye = 1;
			break;
		case 3:
			msgnw(bw->parent, joe_gettext(_("Infinite loop aborted: your search repeatedly matched same place")));
			ret = -1;
			break;
		case 4:
			ret = -1;
			break;
		case 2:
			if (srch->valid)
				switch (restrict_to_block(bw, srch)) {
				case -1:
					continue; /* again */
				case 1:
					if (srch->addr >= 0)
						pgoto(bw->cursor, srch->addr);
					do_bye = 1;
					break;
				}
			if (do_bye)
				break;
			srch->addr = bw->cursor->byte;

			/* Make sure found text is fully on screen */
			if(srch->backwards) {
				bw->offset=0;
				pfwrd(bw->cursor,(srch->entire.rm_eo - srch->entire.rm_so));
				bw->cursor->xcol = piscol(bw->cursor);
				dofollows();
				pbkwd(bw->cursor,(srch->entire.rm_eo - srch->entire.rm_so));
			} else {
				bw->offset=0;
				pbkwd(bw->cursor,(srch->entire.rm_eo - srch->entire.rm_so));
				bw->cursor->xcol = piscol(bw->cursor);
				dofollows();
				pfwrd(bw->cursor,(srch->entire.rm_eo - srch->entire.rm_so));
			}

			if (srch->replace) {
				if (square)
					bw->cursor->xcol = piscol(bw->cursor);
				if (srch->backwards) {
					pdupown(bw->cursor, &markb, "dopfnext");
					markb->xcol = piscol(markb);
					pdupown(markb, &markk, "dopfnext");
					pfwrd(markk, (srch->entire.rm_eo - srch->entire.rm_so));
					markk->xcol = piscol(markk);
				} else {
					pdupown(bw->cursor, &markk, "dopfnext");
					markk->xcol = piscol(markk);
					pdupown(bw->cursor, &markb, "dopfnext");
					pbkwd(markb, (srch->entire.rm_eo - srch->entire.rm_so));
					markb->xcol = piscol(markb);
				}
				srch->flg = 1;
				if (dopfrepl(bw->parent, -1, srch, notify))
					ret = -1;
				notify = 0;
				srch = 0;
			}
			break;
		}
		if (do_bye) {
			/* bye: cleanup/exit path for "not found" */
			if (!srch->flg && !srch->rest) {
				if (srch->valid && srch->block_restrict)
					msgnw(bw->parent, joe_gettext(_("Not found (search restricted to marked block)")));
				else
					msgnw(bw->parent, joe_gettext(_("Not found")));
				ret = -1;
			}
		}
		break;
	}
	bw->cursor->xcol = piscol(bw->cursor);
	dofollows();
	opt_mid = orgmid;
	if (notify)
		*notify = 1;
	if (srch)
		pfsave(bw->parent, srch);
	else
		updall();
	return ret;
}'''
    return src[:start] + new + src[end + 2 :]


def main() -> None:
    stubs = (HERE / "usearch_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    src = src.replace('#include "types.h"\n', "")
    src = convert_searchf(src)
    src = convert_searchb(src)
    src = convert_insert(src)
    src = convert_fnext(src)
    src = convert_dopfnext(src)

    if re.search(r"(?m)^\s*goto\b", src):
        hits = [
            f"{i}:{line.rstrip()}"
            for i, line in enumerate(src.splitlines(), 1)
            if re.search(r"^\s*goto\b", line)
        ]
        raise SystemExit(f"goto remains: {hits}")

    # Also fail on leftover labels that were goto targets
    for lab in ("try_again:", "wrapped:", "insertit:", "again:", "bye:", "\n\tnext:"):
        if lab in src:
            # `again:` / bare next might appear in comments — check carefully
            pass
    label_hits = []
    for i, line in enumerate(src.splitlines(), 1):
        s = line.strip()
        if s in ("try_again:", "wrapped:", "insertit:", "again:", "bye:", "next:"):
            label_hits.append(f"{i}:{line.rstrip()}")
    if label_hits:
        raise SystemExit(f"goto labels remain: {label_hits}")

    header = (
        "/* usearch.c for zig translate-c (goto-free) */\n"
        '#include "usearch_stubs.h"\n\n'
        "static void clrcomp(SRCH *srch);\n"
        "static char **get_word_list(B *b, off_t ignore);\n"
        "static void fcmplt_ins(BW *bw, char *line);\n"
        "static int fcmplt_abrt(W *w, ptrdiff_t x, void *obj);\n"
        "static int fcmplt_rtn(MENU *m, ptrdiff_t x, void *obj, int k);\n"
        "static int srch_cmplt(BW *bw, int k);\n"
        "static P *searchf(BW *bw, SRCH *srch, P *p);\n"
        "static P *searchb(BW *bw, SRCH *srch, P *p);\n"
        "static SRCH *setmark(SRCH *srch);\n"
        "static P *insert(SRCH *srch, P *p, const char *s, ptrdiff_t len, B **entire, B **pieces);\n"
        "static int pfabort(W *w, void *obj);\n"
        "static int pfsave(W *w, void *obj);\n"
        "static int set_replace(W *w, char *s, void *obj, int *notify);\n"
        "static int set_options(W *w, char *s, void *obj, int *notify);\n"
        "static int set_pattern(W *w, char *s, void *obj, int *notify);\n"
        "static void unesc_genfmt(char *d, char *s, ptrdiff_t len, ptrdiff_t max);\n"
        "static int doreplace(BW *bw, SRCH *srch);\n"
        "static void visit(SRCH *srch, BW *bw, int myyn);\n"
        "static void goback(SRCH *srch, BW *bw);\n"
        "static int dopfrepl(W *w, int c, void *obj, int *notify);\n"
        "static int restrict_to_block(BW *bw, SRCH *srch);\n"
        "static int fnext(BW *bw, SRCH *srch);\n"
        "/* Publics used before definition */\n"
        "int dopfnext(BW *bw, SRCH *srch, int *notify);\n"
        "int pfnext(W *w, int k);\n"
        "void setpat(SRCH *srch, char *s);\n"
        "SRCH *mksrch(char *pattern, char *replacement, int ignore, int backwards, int repeat, int replace, int rest, int all, int regex);\n"
        "void rmsrch(SRCH *srch);\n"
        "int dofirst(BW *bw, int back, int repl, char *hint);\n"
        "int pffirst(W *w, int k);\n\n"
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
