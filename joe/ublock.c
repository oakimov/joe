/*
 * 	Highlighted block functions
 *	Copyright
 *		(C) 1992 Joseph H. Allen
 *
 *	This file is part of JOE (Joe's Own Editor)
 */
#include "types.h"

#ifdef HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

/* Path A: mark globals/stack/set/goto + rectangle helpers +
 * `ublkdel`/`upicokill`/`ublkmove`/`ublkcpy` live in `src/ublock.zig`.
 */

/* Set highlighted block on a program block */

void setindent(BW *bw)
{
	P *p, *q;
	off_t indent;

	if (pisblank(bw->cursor))
		return;

	p = pdup(bw->cursor, "setindent");
	q = pdup(p, "setindent");
	indent = pisindent(p);

	do {
		if (!pprevl(p))
			goto done;
		else
			p_goto_bol(p);
	} while (pisindent(p) >= indent || pisblank(p));
	pnextl(p);
	/* Maybe skip blank lines at beginning */
      done:
	p_goto_bol(p);
	p->xcol = piscol(p);
	if (markb)
		prm(markb);
	markb = p;
	p->owner = &markb;

	do {
		if (!pnextl(q))
			break;
	} while (pisindent(q) >= indent || pisblank(q));
	/* Maybe skip blank lines at end */
	if (markk)
		prm(markk);
	q->xcol = piscol(q);
	markk = q;
	q->owner = &markk;

	updall();
}

#if 0
/* Purity check entire block */
/* Verifies that at least n indentation characters (for non-blank lines) match c */
/* If n is 0 (for urindent), this fails if c is space but indentation begins with tab */

static int purity_check(int c, off_t n)
{
	P *p = pdup(markb, "purity_check");
	while (p->byte < markk->byte) {
		off_t x;
		p_goto_bol(p);
		if (!n && c==' ' && brc(p)=='\t') {
			prm(p);
			return 0;
		} else if (!piseol(p))
			for (x=0; x!=n; ++x)
				if (pgetc(p)!=c) {
					prm(p);
					return 0;
				}
		pnextl(p);
	}
	prm(p);
	return 1;
}
#endif

/* Calculate the common indent across the selection */
/* Assumes that the indent is spaces and/or tabs */
/* Returned value is in columns */

static off_t get_common_indent_width(void)
{
	P *p = pdup(markb, "get_common_indent_width");
	off_t maxwidth = 0x7FFFFFFF; /* that'd be one very wide indent */

	p_goto_bol(p);
	while (p->byte < markk->byte) {
		off_t width = 0;
		int c;
		while ((c = pgetc(p)), c == ' ' || c == '\t')
			width = p->col;
		if (width < maxwidth)
			maxwidth = width;
		pnextl(p);
	}
	prm(p);

	if (markb->b->o.indentc == '\t')
		return maxwidth - maxwidth % (markb->b->o.tab * markb->b->o.istep);
	else
		return maxwidth - maxwidth % markb->b->o.istep;
}

/* Purity check single line */
/* Verifies that at least n columns' worth of indentation characters match c */

static int is_pure(P *p, int c, off_t n)
{
	off_t col = piscol(p) + n;
	while (piscol(p) < col) {
		if (pgetc(p)!=c) {
			return 0;
		}
	}
	return 1;
}

/* Eat pre-tab spaces */
/* Goes back to nearest tab stop and replaces following spaces with tabs */
/* If chr after spaces is not a tab or EOF is reached, go back to nearest tab stop before replacing */
/* Do not go beyond the given column limit */

static void eat_pretab_spaces(P *p, off_t limit)
{
	off_t col = piscol(p);
	off_t del;
	P *q = pdup(p, "eat_pretab_spaces");
	const off_t tab = p->b->o.tab;
	int c;

	col -= col % tab;
	pcol(q, col);

	while ((c = brc(q)), c == ' ' && q->col < limit)
		c = pgetc(q);
	if (piscol(q) >= limit) {
		pcol(q, limit);
		c = '\t'; /* lie */
	}
	del = piscol(q) - col; /* number of spaces being deleted */
	if (del) {
		if (c != '\t') {
			/* not at a tab: leave last few, if any, beyond tab stop */
			del -= del % tab;
			pcol(q, col + del);
		}
		if (del) {
			bdel(p,q);
			pfill(q, col + del - (del % tab), '\t');
		}
	}
	prm(q);
}

/* Left indent check */
/* Verify that there is enough whitespace to do the left shift */

static int lindent_check(int c, off_t n)
{
	P *p = pdup(markb, "lindent_check");
	P *q = pdup(markb, "lindent_check");
	off_t indwid;
	if (c=='\t')
		indwid = n * p->b->o.tab;
	else
		indwid = n;
	if (c == ' ' || c == '\t') {
		/* Normal whitespace, measure indentation */
		/* Ignore blank lines */
		while (p->byte < markk->byte) {
			p_goto_bol(p);
			if (!piseol(p) && pisindent(p)<indwid) {
				prm(q);
				prm(p);
				return 0;
			}
			pnextl(p);
		}
	} else {
		/* Some other indentation character, require prefix to have that character */
		/* Ignore blank lines */
		while (p->byte < markk->byte) {
			off_t x;
			p_goto_bol(p);
			if (!piseol(p)) {
				pset(q, p);
				for (x = 0; x < indwid && pgetc(q) == c; ++x);
				if (x < indwid) {
					prm(q);
					prm(p);
					return 0;
				}
			}
			pnextl(p);
		}
	}
	prm(q);
	prm(p);
	return 1;
}

/* Indent more */

int urindent(W *w, int k)
{
	BW *bw;
	WIND_BW(bw, w);
	if (square) {
		if (markb && markk && markb->b == markk->b && markb->byte <= markk->byte && markb->xcol <= markk->xcol) {
			P *p = pdup(markb, "urindent");

			do {
				pcol(p, markb->xcol);
				pfill(p, markb->xcol + bw->o.istep, bw->o.indentc);
			} while (pnextl(p) && p->line <= markk->line);
			prm(p);
		}
	} else {
		if (!markb || !markk || markb->b != markk->b || bw->cursor->byte < markb->byte || bw->cursor->byte > markk->byte || markb->byte == markk->byte) {
			setindent(bw);
		} else {
			P *p = pdup(markb, "urindent");
			P *q = pdup(markb, "urindent");
			const off_t common_width = get_common_indent_width();
			off_t indwid;

			if (bw->o.indentc=='\t')
				indwid = bw->o.tab * bw->o.istep;
			else
				indwid = bw->o.istep;

			while (p->byte < markk->byte) {
				p_goto_bol(p);
				if (!piseol(p)) /* FIXME: we don't indent empty lines.. probably this should be optional */
				{
					off_t col;
					pset(q, p);
					if (bw->o.indentc == ' ' && brc(p) == '\t') {
						/* Don't insert spaces before tabs */
						/* Rewrite the whitespace instead */
						p_goto_indent(q, bw->o.indentc);
						col = piscol(q);
						bdel(p,q);
						pfill(p,col+indwid,bw->o.indentc);
					} else {
						/* Simple insert */
						/* ... with some clean-up if inserting tabs */
						/* FIXME: cleanup should be optional */
						if (bw->o.indentc == '\t') {
							for (col = 0; col < common_width; col += bw->o.tab) {
								pcol(q, col);
								eat_pretab_spaces(q, common_width);
							}
						}
						while (piscol(p) < bw->o.istep) {
							binsc(p, bw->o.indentc);
							pgetc(p);
						}
					}
				}
				pnextl(p);
			}
			prm(p);
			prm(q);
		}

#if 0
		} else if ( 1 /* bw->o.purify */) {
			P *p = pdup(markb, "urindent");
			P *q = pdup(markb, "urindent");
			off_t indwid;

			if (bw->o.indentc=='\t')
				indwid = bw->o.tab * bw->o.istep;
			else
				indwid = bw->o.istep;

			while (p->byte < markk->byte) {
				p_goto_bol(p);
				if (!piseol(p)) {
					off_t col;
					pset(q, p);
					p_goto_indent(q, bw->o.indentc);
					col = piscol(q);
					bdel(p,q);
					pfill(p,col+indwid,bw->o.indentc);
				}
				pnextl(p);
			}
		} else if (purity_check(bw->o.indentc,0)) {
			P *p = pdup(markb, "urindent");

			while (p->byte < markk->byte) {
				p_goto_bol(p);
				if (!piseol(p))
					while (piscol(p) < bw->o.istep) {
						binsc(p, bw->o.indentc);
						pgetc(p);
					}
				pnextl(p);
			}
			prm(p);
		} else {
			/* Purity failure */
			msgnw(bw->parent,joe_gettext(_("Selected lines not properly indented")));
			return 1;
		}
#endif
	}
	return 0;
}

/* Indent less */

int ulindent(W *w, int k)
{
	BW *bw;
	WIND_BW(bw, w);
	if (square) {
		if (markb && markk && markb->b == markk->b && markb->byte <= markk->byte && markb->xcol <= markk->xcol) {
			P *p = pdup(markb, "ulindent");
			P *q = pdup(p, "ulindent");

			do {
				pcol(p, markb->xcol);
				while (piscol(p) < markb->xcol + bw->o.istep) {
					int c = pgetc(p);

					if (c != ' ' && c != '\t' && c != bw->o.indentc) {
						prm(p);
						prm(q);
						return -1;
					}
				}
			} while (pnextl(p) && p->line <= markk->line);
			pset(p, markb);
			do {
				pcol(p, markb->xcol);
				pset(q, p);
				pcol(q, markb->xcol + bw->o.istep);
				bdel(p, q);
			} while (pnextl(p) && p->line <= markk->line);
			prm(p);
			prm(q);
		}
	} else {
		if (!markb || !markk || markb->b != markk->b || bw->cursor->byte < markb->byte || bw->cursor->byte > markk->byte || markb->byte == markk->byte) {
			setindent(bw);
		} else if (lindent_check(bw->o.indentc,bw->o.istep)) {
			/* All lines have enough whitespace for the left-shift */
			P *p = pdup(markb, "ulindent");
			P *q = pdup(markb, "ulindent");
			const off_t common_width = get_common_indent_width();
			off_t indwid;

			if (bw->o.indentc=='\t')
				indwid = bw->o.tab * bw->o.istep;
			else
				indwid = bw->o.istep;

			while (p->byte < markk->byte) {
				p_goto_bol(p);
				if (!piseol(p)) {
					pset(q, p);
					/* FIXME: what to do with blank/whitespace lines? For now, just outdent anyway */
					/* FIXME: cleanup should be optional */
					/* character count is common_width, not indent step */
					if (is_pure(q,bw->o.indentc,common_width)) {
						/* Simple deletion */
						pset(q, p);
						while (piscol(q) < bw->o.istep)
							pgetc(q);
						bdel(p, q);
					} else if (bw->o.indentc == '\t') {
						/* Rewrite white space, but only up to the common indent width */
						pcol(q, common_width);
						bdel(p,q);
						if (common_width > bw->o.tab) {
							pfill(p, common_width - bw->o.tab, '\t');
						}
					} else {
						/* Rewrite whitespace */
						off_t col;
						pset(q, p);
						p_goto_indent(q, bw->o.indentc);
						col = piscol(q);
						bdel(p,q);
						pfill(p,col-indwid,bw->o.indentc);
					}
				}
				pnextl(p);
			}
			prm(p);
			prm(q);
#if 0
		} else if (1 /* bw->o.purify */ && lindent_check(bw->o.indentc,bw->o.istep)) {
			P *p = pdup(markb, "ulindent");
			P *q = pdup(markb, "ulindent");
			off_t indwid;

			if (bw->o.indentc=='\t')
				indwid = bw->o.tab * bw->o.istep;
			else
				indwid = bw->o.istep;

			while (p->byte < markk->byte) {
				p_goto_bol(p);
				if (!piseol(p)) {
					off_t col;
					pset(q, p);
					p_goto_indent(q, bw->o.indentc);
					col = piscol(q);
					bdel(p,q);
					pfill(p,col-indwid,bw->o.indentc);
				}
				pnextl(p);
			}
			prm(p);
			prm(q);
		} else if (purity_check(bw->o.indentc,bw->o.istep)) {
			P *p = pdup(markb, "ulindent");
			P *q = pdup(p, "ulindent");

			p_goto_bol(p);
			while (p->byte < markk->byte) {
				if (!piseol(p)) {
					pset(q, p);
					while (piscol(q) < bw->o.istep)
						pgetc(q);
					bdel(p, q);
				}
				pnextl(p);
			}
			prm(p);
			prm(q);
#endif
		} else {
			/* Purity failure */
			msgnw(bw->parent,joe_gettext(_("Selected lines not properly indented")));
			return 1;
		}
	}
	return 0;
}

/* Insert a file */

int doinsf(W *w, char *s, void *object, int *notify)
{
	BW *bw;
	WIND_BW(bw, w);
	if (notify)
		*notify = 1;
	if (square)
		if (markv(2)) {
			B *tmp;
			off_t width = markk->xcol - markb->xcol;
			off_t height;
			int usetabs = ptabrect(markb,
					       markk->line - markb->line + 1,
					       markk->xcol);

			tmp = bload(s);
			if (berror) {
				msgnw(bw->parent, joe_gettext(msgs[-berror]));
				brm(tmp);
				return -1;
			}
			if (piscol(tmp->eof))
				height = tmp->eof->line + 1;
			else
				height = tmp->eof->line;
			if (bw->o.overtype) {
				pclrrect(markb, off_max(markk->line - markb->line + 1, height), markk->xcol, usetabs);
				pdelrect(markb, height, width + markb->xcol);
			}
			pinsrect(markb, tmp, width, usetabs);
			pdupown(markb, &markk, "doinsf");
			markk->xcol = markb->xcol;
			if (height) {
				pline(markk, markk->line + height - 1);
				pcol(markk, markb->xcol + width);
				markk->xcol = markb->xcol + width;
			}
			brm(tmp);
			updall();
			return 0;
		} else {
			msgnw(bw->parent, joe_gettext(_("No block")));
			return -1;
	} else {
		int ret = 0;
		B *tmp = bload(s);

		if (berror) {
			msgnw(bw->parent, joe_gettext(msgs[-berror])), brm(tmp);
			ret = -1;
		} else
			binsb(bw->cursor, tmp);
		vsrm(s);
		bw->cursor->xcol = piscol(bw->cursor);
		return ret;
	}
}


/* Filter highlighted block through a UNIX command */

static int filtflg = 0;

static int dofilt(W *w, char *s, void *object, int *notify)
{
	int fr[2];
	int fw[2];
	int flg = 0;
	BW *bw;
	WIND_BW(bw, w);

	if (notify)
		*notify = 1;
	if (markb && markk && !square && markb->b == bw->b && markk->b == bw->b && markb->byte == markk->byte) {
		flg = 1;
		goto ok;
	} if (!markv(1)) {
		msgnw(bw->parent, joe_gettext(_("No block")));
		return -1;
	}
      ok:
	if (markb->b!=bw->b && !modify_logic(bw,markb->b))
		return -1;

	if (-1 == pipe(fr)) {
		msgnw(bw->parent, joe_gettext(_("Couldn't create pipe")));
		return -1;
	}
	if (-1 == pipe(fw)) {
		msgnw(bw->parent, joe_gettext(_("Couldn't create pipe")));
		return -1;
	}
	/* npartial is less jarring... */
	/* npartial(bw->parent->t->t); */
	/* But we must use nescape if we are using the ti te sequences, otherwise
	   JOE doesn't return from alternate screen if aspell is used */
	nescape(bw->parent->t->t);
	ttclsn();
#ifdef HAVE_FORK
	if (!fork()) {
#else
	if (!vfork()) { /* For AMIGA only */
#endif
#ifdef HAVE_PUTENV
		char *fname;
		const char *name;
		ptrdiff_t len;
#endif
		signrm();
		close(0);
		close(1);
		close(2);
		if (-1 == dup(fw[0])) _exit(1);
		if (-1 == dup(fr[1])) _exit(1);
		if (-1 == dup(fr[1])) _exit(1);
		close(fw[0]);
		close(fr[1]);
		close(fw[1]);
		close(fr[0]);
#ifdef HAVE_PUTENV
		fname = vsncpy(NULL, 0, sc("JOE_FILENAME="));
		name = bw->b->name ? bw->b->name : "Unnamed";
		if((len = slen(name)) >= 512)	/* limit filename length */
			len = 512;
		fname = vsncpy(sv(fname), name, len);
		putenv(fname);
		vsrm(fname);
#endif
		execl("/bin/sh", "/bin/sh", "-c", s, NULL);
		_exit(0);
	}
	close(fr[1]);
	close(fw[0]);
#ifdef HAVE_FORK
	if (fork()) {
#else
	if (vfork()) { /* For AMIGA only */
#endif
		close(fw[1]);
		if (square) {
			B *tmp;
			off_t width = markk->xcol - markb->xcol;
			off_t height;
			int usetabs = ptabrect(markb,
					       markk->line - markb->line + 1,
					       markk->xcol);

			tmp = bread(fr[0], MAXOFF, 0);
			if (piscol(tmp->eof))
				height = tmp->eof->line + 1;
			else
				height = tmp->eof->line;
			if (bw->o.overtype) {
				pclrrect(markb, markk->line - markb->line + 1, markk->xcol, usetabs);
				pdelrect(markb, off_max(height, markk->line - markb->line + 1), width + markb->xcol);
			} else
				pdelrect(markb, markk->line - markb->line + 1, markk->xcol);
			pinsrect(markb, tmp, width, usetabs);
			pdupown(markb, &markk, "dofilt");
			markk->xcol = markb->xcol;
			if (height) {
				pline(markk, markk->line + height - 1);
				pcol(markk, markb->xcol + width);
				markk->xcol = markb->xcol + width;
			}
			if (lightoff)
				unmark(bw->parent, 0);
			brm(tmp);
			updall();
		} else {
			P *p = pdup(markk, "dofilt");
			if (!flg)
				prgetc(p);
			bdel(markb, p);
			binsb(p, bread(fr[0], MAXOFF, 0));
			if (!flg) {
				pset(p,markk);
				prgetc(p);
				bdel(p,markk);
			}
			prm(p);
			if (lightoff)
				unmark(bw->parent, 0);
		}
		close(fr[0]);
		wait(NULL);
		wait(NULL);
	} else {
		if (square) {
			B *tmp = pextrect(markb,
					  markk->line - markb->line + 1,
					  markk->xcol);

			bsavefd(tmp->bof, fw[1], tmp->eof->byte);
		} else
			bsavefd(markb, fw[1], markk->byte - markb->byte);
		close(fw[1]);
		_exit(0);
	}
	vsrm(s);
	ttopnn();
	/* Use nreturn because we now use nescape */
	nreturn(bw->parent->t->t);
	if (filtflg)
		unmark(bw->parent, 0);
	bw->cursor->xcol = piscol(bw->cursor);
	return 0;
}

B *filthist = NULL;

static void markall(BW *bw)
{
	pdupown(bw->cursor->b->bof, &markb, "markall");
	markb->xcol = 0;
	pdupown(bw->cursor->b->eof, &markk, "markall");
	markk->xcol = piscol(markk);
	updall();
}

static int checkmark(BW *bw)
{
	if (!markv(1))
		if (square)
			return 2;
		else {
			markall(bw);
			filtflg = 1;
			return 1;
	} else {
		filtflg = 0;
		return 0;
	}
}

int ufilt(W *w, int k)
{
	BW *bw;
	WIND_BW(bw, w);
#ifdef __MSDOS__
	msgnw(bw->parent, joe_gettext(_("Sorry, no sub-processes in DOS (yet)")));
	return -1;
#else
	switch (checkmark(bw)) {
	case 0:
		if (wmkpw(bw->parent, joe_gettext(_("Command to filter block through (%{abort} to abort): ")), &filthist, dofilt, NULL, NULL, cmplt_command, NULL, NULL, locale_map, PWFLAG_COMMAND))
			return 0;
		else
			return -1;
	case 1:
		if (wmkpw(bw->parent, joe_gettext(_("Command to filter file through (%{abort} to abort): ")), &filthist, dofilt, NULL, NULL, cmplt_command, NULL, NULL, locale_map, PWFLAG_COMMAND))
			return 0;
		else
			return -1;
	case 2:
	default:
		msgnw(bw->parent, joe_gettext(_("No block")));
		return -1;
	}
#endif
}

/* Force region to lower case */

int ulower(W *w, int k)
{
	BW *bw;
	WIND_BW(bw, w);
	if (markv(1)) {
		P *q;
	        P *p;
	        int c;
		B *b = bcpy(markb,markk);
		/* Leave one character in buffer to keep pointers set properly... */
		q = pdup(markk, "ulower");
		prgetc(q);
		bdel(markb,q);
		b->o.charmap = markb->b->o.charmap;
		p=pdup(b->bof, "ulower");
		while ((c=pgetc(p))!=NO_MORE_DATA) {
			c = joe_tolower(b->o.charmap,c);
			binsc(q,c);
			pgetc(q);
		}
		prm(p);
		bdel(q,markk);
		prm(q);
		brm(b);
		bw->cursor->xcol = piscol(bw->cursor);
		return 0;
	} else
		return -1;
}

/* Force region to upper case */

int uupper(W *w, int k)
{
	BW *bw;
	WIND_BW(bw, w);
	if (markv(1)) {
		P *q;
	        P *p;
	        int c;
		B *b = bcpy(markb,markk);
		q = pdup(markk, "uupper");
		prgetc(q);
		bdel(markb,q);
		b->o.charmap = markb->b->o.charmap;
		p=pdup(b->bof, "uupper");
		while ((c=pgetc(p))!=NO_MORE_DATA) {
			c = joe_toupper(b->o.charmap,c);
			binsc(q,c);
			pgetc(q);
		}
		prm(p);
		bdel(q,markk);
		prm(q);
		brm(b);
		bw->cursor->xcol = piscol(bw->cursor);
		return 0;
	} else
		return -1;
}

/* Get sum, sum of squares, and return count of
 * a block of numbers. */

int blksum(BW *bw, double *sum, double *sumsq)
{
	char buf[80];
	if (checkmark(bw) != 2) {
		P *q = pdup(markb, "blksum");
		int x;
		int c;
		double accu = 0.0;
		double accusq = 0.0;
		double v;
		int count = 0;
		off_t left = markb->xcol;
		off_t right = markk->xcol;
		while (q->byte < markk->byte) {
			/* Skip until we're within columns */
			while (q->byte < markk->byte && square && (piscol(q) < left || piscol(q) >= right))
				pgetc(q);

			/* Skip to first number */
			while (q->byte < markk->byte && (!square || (piscol(q) >= left && piscol(q) < right))) {
				c=pgetc(q);
				if ((c >= '0' && c <= '9') || c == '.' || c == '-') {
					/* Copy number into buffer */
					buf[0] = TO_CHAR_OK(c); x=1;
					while (q->byte < markk->byte && (!square || (piscol(q) >= left && piscol(q) < right))) {
						c=pgetc(q);
						if ((c >= '0' && c <= '9') || c == 'e' || c == 'E' ||
						    c == 'p' || c == 'P' || c == 'x' || c == 'X' ||
						    c == '.' || c == '-' || c == '+' || c == 'o' || c == 'O' ||
						    (c >= 'a' && c <= 'f') || (c >= 'A' && c<='F') || (c == '_')) {
							if(x != 79)
								buf[x++]= TO_CHAR_OK(c);
						} else
							break;
					}
					/* Convert number to floating point, add it to total */
					buf[x] = 0;
					v = joe_strtod(buf,NULL);
					++count;
					accu += v;
					accusq += v*v;
					break;
				}
			}
		}
		prm(q);
		*sum = accu;
		*sumsq = accusq;
		if (filtflg)
			unmark(bw->parent, 0);
		return count;
	} else
		return -1;
}

int blklr(BW *bw, double *xsum, double *xsumsq, double *ysum, double *ysumsq, double *xy, int logx, int logy)
{
	char buf[80];
	if (checkmark(bw) != 2) {
		P *q = pdup(markb, "blklr");
		int x;
		int c;
		double accux = 0.0;
		double accuxsq = 0.0;
		double accuy = 0.0;
		double accuysq = 0.0;
		double accuxy = 0.0;
		double prevx = 0.0;
		double v;
		int state = 0; /* 0 = x, 1 = y */
		int count = 0;
		off_t left = markb->xcol;
		off_t right = markk->xcol;
		while (q->byte < markk->byte) {
			/* Skip until we're within columns */
			while (q->byte < markk->byte && square && (piscol(q) < left || piscol(q) >= right))
				pgetc(q);

			/* Skip to first number */
			while (q->byte < markk->byte && (!square || (piscol(q) >= left && piscol(q) < right))) {
				c=pgetc(q);
				if ((c >= '0' && c <= '9') || c == '.' || c == '-') {
					/* Copy number into buffer */
					buf[0] = TO_CHAR_OK(c); x=1;
					while (q->byte < markk->byte && (!square || (piscol(q) >= left && piscol(q) < right))) {
						c=pgetc(q);
						if ((c >= '0' && c <= '9') || c == 'e' || c == 'E' ||
						    c == 'p' || c == 'P' || c == 'x' || c == 'X' ||
						    c == '.' || c == '-' || c == '+' || c == 'o' || c == 'O' ||
						    (c >= 'a' && c <= 'f') || (c >= 'A' && c<='F') || (c == '_')) {
							if(x != 79)
								buf[x++]= TO_CHAR_OK(c);
						} else
							break;
					}
					/* Convert number to floating point, add it to total */
					buf[x] = 0;
					v = joe_strtod(buf,NULL);
					if (!state) {
						if (logx)
							v = log(v);
						prevx = v;
						accux += v;
						accuxsq += v*v;
						state = 1;
					} else {
						if (logy)
							v = log(v);
						accuy += v;
						accuysq += v*v;
						accuxy += prevx*v;
						state = 0;
						++count;
					}
					break;
				}
			}
		}
		prm(q);
		*xsum = accux;
		*xsumsq = accuxsq;
		*ysum = accuy;
		*ysumsq = accuysq;
		*xy = accuxy;
		if (filtflg)
			unmark(bw->parent, 0);
		if (state)
			return -1;
		else
			return count;
	} else
		return -1;
}

/* Get a (possibly square) block into a buffer
 * Block is converted to UTF-8
 */

char *blkget(BW *bw)
{
	if (checkmark(bw) != 2) {
		P *q;
		ptrdiff_t buf_size = markk->byte - markb->byte + 1; /* Risky... */
		ptrdiff_t buf_x = 0;
		char *buf = (char *)joe_malloc(buf_size);
		off_t left = markb->xcol;
		off_t right = markk->xcol;
		q = pdup(markb, "blkget");
		while (q->byte < markk->byte) {
			/* Skip until we're within columns */
			while (q->byte < markk->byte && square && (piscol(q) < left || piscol(q) >= right))
				pgetc(q);

			/* Copy text into buffer */
			while (q->byte < markk->byte && (!square || (piscol(q) >= left && piscol(q) < right))) {
				int ch = pgetc(q);
				char bf[8];
				ptrdiff_t len, x;
				if (!q->b->o.charmap->type)
					ch = to_uni(q->b->o.charmap, ch);
				len = utf8_encode(bf, ch);
				for (x = 0; x != len; ++x) {
					if (buf_x == buf_size - 1) {
						buf_size *= 2;
						buf = (char *)joe_realloc(buf, buf_size);
					}
					buf[buf_x++] = bf[x];
				}
			}
			/* Add a new line if we went past right edge of column */
			if (square && q->byte<markk->byte && piscol(q) >= right) {
				if (buf_x == buf_size - 1) {
					buf_size *= 2;
					buf = (char *)joe_realloc(buf, buf_size);
				}
				buf[buf_x++] = '\n';
			}
		}
		prm(q);
		buf[buf_x] = 0;
		if (filtflg)
			unmark(bw->parent, 0);
		return buf;
	} else
		return 0;
}
