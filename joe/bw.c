/*
 *	Edit buffer window generation
 *	Copyright
 *		(C) 1992 Joseph H. Allen
 *
 *	This file is part of JOE (Joe's Own Editor)
 */
#include "types.h"
#include <limits.h>

/* Path A: gated Zig-native lgen_core body paint (default off).
 * Env: JOE_ZIG_BW_LGEN=1. Falls back to C when unsupported. */
extern int zig_bw_lgen_enabled;
extern int zig_bw_lgen(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr,
	ptrdiff_t x0, ptrdiff_t x1, P *p, off_t scr, struct high_syntax *syntax,
	HIGHLIGHT_STATE st, struct charmap *charmap, int tab, int defatr,
	int *palette, int palette_len, off_t from, off_t to, off_t line_byte,
	int viewmode, char *vm_hide, int vm_hide_len, int *vm_subst, int vm_subst_len,
	char **vm_urls, int vm_urls_len, int visiblews, int square, int ansi);
/* Path A Feature 2.2: gated Zig padded table row (widths/aligns from C). */
extern int zig_bw_table_row(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr,
	ptrdiff_t x0, ptrdiff_t x1, const unsigned char *line, int line_len,
	int ncols, const int *widths, const int *aligns, int row_type,
	struct charmap *charmap, int defatr, int *palette, int palette_len,
	off_t *col_map, int col_map_size);
/* Path A: gated Zig gennum line-number gutter (same JOE_ZIG_BW_LGEN gate). */
extern int zig_bw_gennum(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr,
	int *compose, int lincols, int have_number, off_t line_1based, int atr,
	struct charmap *charmap);
/* Path A: gated Zig bwgen paint loops (mark setup stays in C). */
extern int zig_bw_bwgen(BW *w, SCRN *t, int (*scrn)[COMPOSE], int *attr_base,
	int *updtab, int *compose, ptrdiff_t scr_w,
	ptrdiff_t win_x, ptrdiff_t win_y, ptrdiff_t win_w, ptrdiff_t win_h,
	ptrdiff_t mid_y, P *top, P *cursor, off_t top_line, off_t offset,
	int linums, int linchg, int dosquare,
	off_t from, off_t to, off_t fromline, off_t toline);
/* Path A: gated Zig bwgenh hex dump paint (mark setup stays in C). */
extern int zig_bw_bwgenh(SCRN *t, int (*scrn)[COMPOSE], int *attr_base,
	ptrdiff_t scr_w, ptrdiff_t win_y, ptrdiff_t win_h, ptrdiff_t win_w,
	off_t offset, P *top, off_t cursor_byte, int hiline,
	off_t from, off_t to, int bg_text_atr, int bg_linum_atr,
	int bg_curlinum_atr, int bg_cursor_atr);
/* Path A Feature 2.1/2.2: gated Zig table region detect (widths/aligns). */
extern int zig_bw_table_detect(P *anchor, off_t buf_line,
	off_t *out_start, off_t *out_end, off_t *out_sep, int *out_ncols,
	int *out_widths, int *out_aligns, int out_cap);
/* Path A: gated Zig cursor follow (text + hex). */
extern int zig_bw_bwfllwt(P *top, P *cursor, SCRN *t, int *updtab,
	ptrdiff_t y, ptrdiff_t h, ptrdiff_t w,
	off_t *offset, off_t *curlin, int hiline);
extern int zig_bw_bwfllwh(P *top, P *cursor, SCRN *t, int *updtab,
	ptrdiff_t y, ptrdiff_t h, ptrdiff_t w, off_t *offset);
/* Path A: gated Zig post-edit window scroll. */
extern int zig_bw_bwins(SCRN *t, int *updtab, ptrdiff_t *sary, ptrdiff_t li,
	ptrdiff_t y, ptrdiff_t h, off_t top_line, off_t eof_line,
	off_t l, off_t n, int flg, int do_highlight);
extern int zig_bw_bwdel(SCRN *t, int *updtab,
	ptrdiff_t y, ptrdiff_t h, off_t top_line, off_t eof_line,
	off_t l, off_t n, int flg, int do_highlight);
/* Path A: gated Zig Feature 1.9 table dim/bold fallback. */
extern int zig_bw_view_table_hl(const unsigned char *line, int line_len,
	int *atr, int atr_len, int in_table_region);
/* Path A: gated Zig lgen_view line-start Feature 1.3/1.5/1.7/1.8. */
extern int zig_bw_view_line_start(const unsigned char *line, int line_len,
	char *hide, int hide_len, int *subst, int subst_len,
	off_t *col_map, int col_map_len, int tab);
/* Path A: gated Zig lgen_view inline Feature 1.4/1.5/1.6 + col_map. */
extern int zig_bw_view_inline(const unsigned char *line, int line_len,
	char *hide, int hide_len, int *subst, int subst_len,
	char **urls, int urls_len, off_t *col_map, int col_map_len,
	int *atr, int atr_len, int tab);
/* Path A: gated Zig Feature 1.10 col_map ensure + cursor xcol. */
extern int zig_bw_view_finish(const unsigned char *line, int line_len,
	char *vm_hide, int vm_hide_len, int *vm_subst, int vm_subst_len,
	off_t *vm_col_map, int vm_col_map_len, off_t *vm_col_map_line,
	off_t buf_line, int tab, P *cursor, int skip_hidden);
/* Path A: gated thin lgen_view chrome dispatcher (Feature 1.x/2.x sequence). */
extern int zig_bw_lgen_view(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr,
	ptrdiff_t x0, ptrdiff_t x1, P *p, const unsigned char *line, int line_len,
	char *vm_hide, int vm_hide_len, int *vm_subst, int vm_subst_len,
	char **urls, int urls_len, off_t *vm_col_map, int vm_col_map_len,
	off_t *vm_col_map_line, int *atr, int atr_len, int tab, off_t buf_line,
	P *cursor, off_t *table_region_start, off_t *table_region_end,
	off_t *table_separator_line, off_t *table_cached_for_line,
	off_t *table_no_region_line, int *table_col_count,
	int *table_col_width, int *table_col_align, int table_cap,
	struct charmap *charmap, int defatr, int *palette, int palette_len, int utf8);
/* Path A Feature 2.1: gated Zig simple pipe substitute into vm_subst[]. */
extern int zig_bw_table_simple(const unsigned char *line, int line_len, int row_type,
	int *vm_subst, int vm_subst_len);

/* Attributes for line numbers, and current line */
int bg_linum = 0;
int bg_curlinum = 0;
int bg_curlin = 0;
int curlinmask = -1;

/* Display modes */
int dspasis = 0;
int marking = 0;

/* Selected text format */
int selectatr = INVERSE;
int selectmask = ~INVERSE;

/* Visible whitespace text format */
int vwsatr = DIM;
int vwsmask = ~(DIM | FG_MASK);

/* Characters used for visible whitespace (Zig bw_lgen reads these). */
int vspace = 0;
int vtab = 0;
int vrtn = 0;

static P *getto(P *p, P *cur, P *top, off_t line)
{

	if (p == NULL) {
		P *best = cur;
		off_t dist = MAXOFF;
		off_t d;

		d = (line >= cur->line ? line - cur->line : cur->line - line);
		if (d < dist) {
			dist = d;
			best = cur;
		}
		d = (line >= top->line ? line - top->line : top->line - line);
		if (d < dist) {
			dist = d;
			best = top;
		}
		p = pdup(best, "getto");
		p_goto_bol(p);
	}
	while (line > p->line)
		if (!pnextl(p))
			break;
	if (line < p->line) {
		while (line < p->line)
			pprevl(p);
		p_goto_bol(p);
	}
	return p;
}

/* Recenter cursor on vertical scroll if true */
int opt_mid = 0;

/* Amount to horizontally scroll when cursor goes past edge */
/* -1 means 1/4 width of screen */
int opt_left = 8;
int opt_right = 8;

/* For hex */

void bwfllwh(W *thew)
{
	BW *w = (BW *)thew->object;
	/* Path A: Zig-native hex follow (JOE_ZIG_BW_LGEN). */
	if (zig_bw_lgen_enabled) {
		if (zig_bw_bwfllwh(w->top, w->cursor, w->t->t, w->t->t->updtab,
			w->y, w->h, w->w, &w->offset) >= 0)
			return;
	}
	/* Top must be a multiple of 16 bytes */
	if (w->top->byte%16) {
		pbkwd(w->top,w->top->byte%16);
	}

	/* Move backward */
	if (w->cursor->byte < w->top->byte) {
		off_t new_top = w->cursor->byte/16;
		if (opt_mid) {
			if (new_top >= w->h / 2)
				new_top -= w->h / 2;
			else
				new_top = 0;
		}
		if (w->top->byte/16 - new_top < w->h)
			nscrldn(w->t->t, w->y, w->y + w->h, (int) (w->top->byte/16 - new_top));
		else
			msetI(w->t->t->updtab + w->y, 1, w->h);
		pgoto(w->top,new_top*16);
	}

	/* Move forward */
	if (w->cursor->byte >= w->top->byte+(w->h*16)) {
		off_t new_top;
		if (opt_mid) {
			new_top = w->cursor->byte/16 - w->h / 2;
		} else {
			new_top = w->cursor->byte/16 - (w->h - 1);
		}
		if (new_top - w->top->byte/16 < w->h)
			nscrlup(w->t->t, w->y, w->y + w->h, (int) (new_top - w->top->byte/16));
		else {
			msetI(w->t->t->updtab + w->y, 1, w->h);
		}
		pgoto(w->top, new_top*16);
	}

	/* Adjust scroll offset */
	if (w->cursor->byte%16+60 < w->offset) {
		w->offset = w->cursor->byte%16+60;
		msetI(w->t->t->updtab + w->y, 1, w->h);
	} else if (w->cursor->byte%16+60 >= w->offset + w->w) {
		w->offset = w->cursor->byte%16+60 - (w->w - 1);
		msetI(w->t->t->updtab + w->y, 1, w->h);
	}
}

/* For text */

void bwfllwt(W *thew)
{
	BW *w = (BW *)thew->object;
	P *newtop;

	/* Path A: Zig-native text follow (JOE_ZIG_BW_LGEN). */
	if (zig_bw_lgen_enabled) {
		if (zig_bw_bwfllwt(w->top, w->cursor, w->t->t, w->t->t->updtab,
			w->y, w->h, w->w, &w->offset, &w->curlin, w->o.hiline) >= 0)
			return;
	}

	if (!pisbol(w->top)) {
		p_goto_bol(w->top);
	}

	if (w->cursor->line < w->top->line) {
		newtop = pdup(w->cursor, "bwfllwt");
		p_goto_bol(newtop);
		if (opt_mid) {
			if (newtop->line >= w->h / 2)
				pline(newtop, newtop->line - w->h / 2);
			else
				pset(newtop, newtop->b->bof);
		}
		if (w->top->line - newtop->line < w->h)
			nscrldn(w->t->t, w->y, w->y + w->h, (int) (w->top->line - newtop->line));
		else {
			msetI(w->t->t->updtab + w->y, 1, w->h);
		}
		pset(w->top, newtop);
		prm(newtop);
	} else if (w->cursor->line >= w->top->line + w->h) {
		/* newtop = pdup(w->top); */
		/* getto() creates newtop */
		if (opt_mid)
			newtop = getto(NULL, w->cursor, w->top, w->cursor->line - w->h / 2);
		else
			newtop = getto(NULL, w->cursor, w->top, w->cursor->line - (w->h - 1));
		if (newtop->line - w->top->line < w->h)
			nscrlup(w->t->t, w->y, w->y + w->h, (int) (newtop->line - w->top->line));
		else {
			msetI(w->t->t->updtab + w->y, 1, w->h);
		}
		pset(w->top, newtop);
		prm(newtop);
	}

/* Adjust column */
	if (w->cursor->xcol < w->offset) {
		/* Need to scroll left */
		off_t target = w->cursor->xcol;
		ptrdiff_t amnt;

		if (opt_left < 0) {
			amnt = w->w / (-opt_left);
		} else {
			amnt = opt_left - 1;
		}

		if (amnt >= w->w)
			amnt = w->w - 1;

		if (amnt < 0)
			amnt = 0;

		if (target < amnt) {
			target = 0;
		} else {
			target -= amnt;
		}
		w->offset = target;
		msetI(w->t->t->updtab + w->y, 1, w->h);
	}
	if (w->cursor->xcol >= w->offset + w->w) {
		/* Need to scroll right */
		ptrdiff_t amnt;
		if (opt_right < 0) {
			amnt = w->w - w->w/(-opt_right);
		} else {
			amnt = w->w - opt_right;
		}
		if (amnt >= w->w)
			amnt = w->w - 1;
		if (amnt < 0)
			amnt = 0;

		w->offset = w->cursor->xcol - amnt;

		msetI(w->t->t->updtab + w->y, 1, w->h);
	}

	if (w->o.hiline) {
		if (w->curlin != w->cursor->line) {
			/* Update old and new cursor lines */
			if (w->curlin >= w->top->line && w->curlin < (w->top->line + w->h))
				w->t->t->updtab[w->y + w->curlin - w->top->line] = 1;
			w->curlin = w->cursor->line;
			w->t->t->updtab[w->y + w->curlin - w->top->line] = 1;
		}
	} else {
		w->curlin = w->cursor->line;
	}
}

/* For either */

void bwfllw(W *w)
{
	BW *bw = (BW *)w->object;
	if (bw->o.hex)
		bwfllwh(w);
	else
		bwfllwt(w);
}

/* Determine highlighting state of a particular line on the window.
   If the state is not known, it is computed and the state for all
   of the remaining lines of the window are also recalculated. */

static HIGHLIGHT_STATE get_highlight_state(BW *w, P *p, off_t line)
{
	HIGHLIGHT_STATE state;

	if(!w->o.highlight || !w->o.syntax) {
		invalidate_state(&state);
		return state;
	}

	return lattr_get(w->db, w->o.syntax, p, line); /* FIXME: lattr database should be a in vfile */
}

/* Scroll a buffer window after an insert occurred.  'flg' is set to 1 if
 * the first line was split
 */

void bwins(BW *w, off_t l, off_t n, int flg)
{
	/* Path A: Zig-native post-insert scroll (JOE_ZIG_BW_LGEN). */
	if (zig_bw_lgen_enabled) {
		int z = zig_bw_bwins(w->t->t, w->t->t->updtab, w->t->t->sary, w->t->t->li,
			w->y, w->h, w->top->line, w->b->eof->line,
			l, n, flg, (w->o.highlight && w->o.syntax) ? 1 : 0);
		if (z >= 0)
			return;
	}
	/* If highlighting is enabled... */
	if (w->o.highlight && w->o.syntax) {
		/* Invalidate cache */
		/* lattr_cut(w->db, l + 1); */
		/* Force updates */
		if (l < w->top->line) {
			msetI(w->t->t->updtab + w->y, 1, w->h);
		} else if ((l + 1) < w->top->line + w->h) {
			ptrdiff_t start = TO_DIFF_OK(l + 1 - w->top->line);
			ptrdiff_t size = w->h - start;
			msetI(w->t->t->updtab + w->y + start, 1, size);
		}
	}

	/* Scroll */
	if (l + flg + n < w->top->line + w->h && l + flg >= w->top->line && l + flg <= w->b->eof->line) {
		if (flg)
			w->t->t->sary[w->y + l - w->top->line] = w->t->t->li;
		nscrldn(w->t->t, (int) (w->y + l + flg - w->top->line), w->y + w->h, (int) n);
	}

	/* Force update of lines in opened hole */
	if (l < w->top->line + w->h && l >= w->top->line) {
		if (n >= w->h - (l - w->top->line)) {
			msetI(w->t->t->updtab + w->y + l - w->top->line, 1, w->h - (int) (l - w->top->line));
		} else {
			msetI(w->t->t->updtab + w->y + l - w->top->line, 1, (int) n + 1);
		}
	}
}

/* Scroll current windows after a delete */

void bwdel(BW *w, off_t l, off_t n, int flg)
{
	/* Path A: Zig-native post-delete scroll (JOE_ZIG_BW_LGEN). */
	if (zig_bw_lgen_enabled) {
		int z = zig_bw_bwdel(w->t->t, w->t->t->updtab,
			w->y, w->h, w->top->line, w->b->eof->line,
			l, n, flg, (w->o.highlight && w->o.syntax) ? 1 : 0);
		if (z >= 0)
			return;
	}
	/* If highlighting is enabled... */
	if (w->o.highlight && w->o.syntax) {
		/* lattr_cut(w->db, l + 1); */
		if (l < w->top->line) {
			msetI(w->t->t->updtab + w->y, 1, w->h);
		} else if ((l + 1) < w->top->line + w->h) {
			ptrdiff_t start = TO_DIFF_OK(l + 1 - w->top->line);
			ptrdiff_t size = w->h - start;
			msetI(w->t->t->updtab + w->y + start, 1, size);
		}
	}

	/* Update the line where the delete began */
	if (l < w->top->line + w->h && l >= w->top->line)
		w->t->t->updtab[w->y + l - w->top->line] = 1;

	/* Update the line where the delete ended */
	if (l + n < w->top->line + w->h && l + n >= w->top->line)
		w->t->t->updtab[w->y + l + n - w->top->line] = 1;

	if (l < w->top->line + w->h && (l + n >= w->top->line + w->h || (l + n == w->b->eof->line && w->b->eof->line >= w->top->line + w->h))) {
		if (l >= w->top->line)
			/* Update window from l to end */
			msetI(w->t->t->updtab + w->y + l - w->top->line, 1, w->h - (int) (l - w->top->line));
		else
			/* Update entire window */
			msetI(w->t->t->updtab + w->y, 1, w->h);
	} else if (l < w->top->line + w->h && l + n == w->b->eof->line && w->b->eof->line < w->top->line + w->h) {
		if (l >= w->top->line)
			/* Update window from l to end of file */
			msetI(w->t->t->updtab + w->y + l - w->top->line, 1, (int) n);
		else
			/* Update from beginning of window to end of file */
			msetI(w->t->t->updtab + w->y, 1, (int) (w->b->eof->line - w->top->line));
	} else if (l + n < w->top->line + w->h && l + n > w->top->line && l + n < w->b->eof->line) {
		if (l + flg >= w->top->line)
			nscrlup(w->t->t, (int) (w->y + l + flg - w->top->line), w->y + w->h, (int) n);
		else
			nscrlup(w->t->t, w->y, w->y + w->h, (int) (l + n - w->top->line));
	}
}

struct ansi_sm
{
	int state;
};

static int ansi_decode(struct ansi_sm *sm, int bc)
{
	if (sm->state) {
		if ((bc >= 'a' && bc <= 'z') || (bc >= 'A' && bc <= 'Z'))
			sm->state = 0;
		return -1;
	} else if (bc == '\033') {
		sm->state = 1;
		return -1;
	} else
		return bc;
}

static void ansi_init(struct ansi_sm *sm)
{
	sm->state = 0;
}

#define SELECT_IF(c)	{ if (c) { ca = selectatr; cm = selectmask; } else { ca = 0; cm = -1; } }

/* Sanitize a string for terminal output: replace control characters
 * (0x00-0x1F, 0x7F) with '?'.  Returns a static buffer that is reused. */
static const char *sanitize_for_terminal(const char *s)
{
	static char buf[256];
	if (!s) return "(null)";
	size_t len = strlen(s);
	if (len >= sizeof(buf)) len = sizeof(buf) - 1;
	size_t i;
	for (i = 0; i < len; i++) {
		unsigned char c = (unsigned char)s[i];
		buf[i] = (c <= 0x1F || c == 0x7F) ? '?' : (char)c;
	}
	buf[len] = '\0';
	return buf;
}

static struct state_debug_data out_osc8(const struct state_debug_data *oldstate, const struct state_debug_data *newstate, int opt)
{
	static const struct state_debug_data empty = {};

	opt &= 3;

	if (!oldstate) oldstate = &empty;
	if (!newstate) newstate = &empty;

	switch (opt) {
		case 1:
			if (oldstate->name == newstate->name)
				return *oldstate;

			if (oldstate->name >= 0)
				ttputs("\x1B]8;;\x1B\\");

			if (newstate && newstate->name >= 0) {
				ttputs("\x1B]8;id=");
				ttputs(sanitize_for_terminal(state_names[newstate->name]));
				ttputs(";");
				ttputs(sanitize_for_terminal(state_names[newstate->name]));
				ttputs("\x1B\\");
			}
			break;
		case 2:
			if (oldstate->recolor == newstate->recolor)
				return *oldstate;

			if (oldstate->recolor)
				ttputs("\x1B]8;;\x1B\\");

			if (newstate && newstate->name >= 0) {
				ttputs("\x1B]8;id=");
				ttputs(newstate->recolor ? sanitize_for_terminal(state_names[newstate->recolor]) : "(idle)");
				ttputs(";");
				ttputs(newstate->recolor ? sanitize_for_terminal(state_names[newstate->recolor]) : "(idle)");
				ttputs("\x1B\\");
			}
			break;
		case 3:
			if (oldstate->name == newstate->name && oldstate->recolor == newstate->recolor)
				return *oldstate;

			if (oldstate->name >= 0 || oldstate->recolor >= 0)
				ttputs("\x1B]8;;\x1B\\");

			if (newstate && newstate->name >= 0) {
				ttputs("\x1B]8;id=");
				ttputs(sanitize_for_terminal(state_names[newstate->name]));
				ttputs(";");
				ttputs(sanitize_for_terminal(state_names[newstate->name]));
				if (newstate->recolor && newstate->recolor != newstate->name) {
					/* ugh, only ASCII for OSC-8 pop-up text */
					ttputs("->");
					ttputs(sanitize_for_terminal(state_names[newstate->recolor]));
				}
				ttputs("\x1B\\");
			}
	}

	return newstate ? *newstate : empty;
}

static void end_osc8(const struct state_debug_data *oldstate, int opt)
{
	if ((opt & 1 && oldstate->name >= 0) || (opt & 2 && oldstate->recolor >= 0))
		ttputs("\x1B]8;;\x1B\\");
}
#define OUT_osc8(bw,os,ns) ((bw)->b->o.syntax_debug ? out_osc8(&(os), &(ns), (bw)->b->o.syntax_debug) : (os))
#define END_osc8(bw,old) end_osc8(&(old), (bw)->b->o.syntax_debug)

static void end_osc8_link(const char *old_url)
{
	if (old_url)
		ttputs("\x1B]8;;\x1B\\");
}

static const char *out_osc8_link(const char *old_url, const char *new_url)
{
	if (old_url == new_url)
		return old_url;

	if (old_url)
		ttputs("\x1B]8;;\x1B\\");

	if (new_url) {
		ttputs("\x1B]8;;");
		/* Sanitize URL: strip all control characters to prevent terminal injection */
		const char *p;
		for (p = new_url; *p; p++) {
			unsigned char ch = (unsigned char)*p;
			if (ch < 0x20 || ch == 0x7F || (ch >= 0x80 && ch <= 0x9F))
				continue;
			ttputc(*p);
		}
		ttputs("\x1B\\");
	}

	return new_url;
}

/* Update a single line */

static int lgen_core(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr, ptrdiff_t x, ptrdiff_t w, P *p, off_t scr, off_t from, off_t to,HIGHLIGHT_STATE st,BW *bw);
static int lgen_view(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr, ptrdiff_t x, ptrdiff_t w, P *p, off_t scr, off_t from, off_t to,HIGHLIGHT_STATE st,BW *bw);

/* When set, lgen_core skips re-parsing and uses the already-populated attr_buf.
 * This allows lgen_view to parse, modify attr_buf, then delegate rendering. */
static int viewmode_skip_parse = 0;

/*
 * View mode operates by building per-line side tables indexed by buffer byte
 * offset (hide/substitute/link-url/column-map). Without a hard cap, a single
 * gigantic line can force multi-hundred-megabyte allocations and OOM.
 *
 * The cap only limits viewmode transformations; the underlying buffer and core
 * renderer can still handle longer lines (delimiters beyond the cap remain
 * visible / untransformed).
 */
#define VIEWMODE_MAX_LINE_BYTES (1024 * 1024)

/* Table scanning does not need full-line fidelity; keep it small to avoid OOM. */
#define VIEWMODE_TABLE_SCAN_MAX_BYTES (16 * 1024)

/* Bitmap for view mode: when viewmode_skip_parse is set, characters with
 * a set bit in viewmode_hide[] are rendered as spaces (hidden delimiters).
 */
static char *viewmode_hide = NULL;
static int viewmode_hide_size = 0;

/* Unicode substitution map for view mode: when viewmode_skip_parse is set,
 * characters with a non-zero entry in viewmode_substitute[] are rendered
 * as that Unicode code point instead of the buffer character.
 */
static int *viewmode_substitute = NULL;
static int viewmode_substitute_size = 0;

/* Link URL map for view mode: when viewmode_skip_parse is set,
 * characters with a non-NULL entry in viewmode_link_url[] are link text
 * and should be wrapped in OSC 8 hyperlink sequences. */
static char **viewmode_link_url = NULL;
static int viewmode_link_url_size = 0;

/* Column mapping for view mode: maps buffer byte offset (relative to BOL)
 * to display column. This is used to correctly position the cursor when
 * delimiters are hidden or characters are substituted. */
static off_t *viewmode_col_map = NULL;
static int viewmode_col_map_size = 0;
static off_t viewmode_col_map_line = -1;	/* Buffer line number for which the map is valid */

/* Feature 2.1: Table region tracking for box-drawing borders */
typedef enum {
	TABLE_ROW_NONE = 0,
	TABLE_ROW_HEADER,
	TABLE_ROW_SEPARATOR,
	TABLE_ROW_BODY,
	TABLE_ROW_LAST
} table_row_type_t;

static off_t table_region_start = -1;	/* First line of detected table region */
static off_t table_region_end = -1;	/* Last line of detected table region (exclusive) */
static off_t table_separator_line = -1;	/* Line number of the separator row */
static off_t table_cached_for_line = -1;/* Which line triggered the cache (staleness check) */
static off_t table_no_region_line = -1;/* Line where no table was found (negative cache) */
static int table_col_count = 0;		/* Number of columns in the table */
static unsigned char *viewmode_scan_buf = NULL;	/* Persistent buffer for table scan */
static ptrdiff_t viewmode_scan_buf_size = 0;

/* Feature 2.2: Table layout engine — per-column widths and alignment */
#define MAX_TABLE_COLS 64
static int table_col_width[MAX_TABLE_COLS];	/* Max display width per column */
static int table_col_align[MAX_TABLE_COLS];	/* 0=left, 1=center, 2=right */

/* When non-zero, lgen_view rendered the table row to screen directly. */
static int viewmode_table_rendered = 0;

/* Track which BW last rendered viewmode state — invalidate caches on window change */
static BW *viewmode_last_bw = NULL;

/* Feature 1.10: Get display column for a buffer position in view mode.
 * Returns -1 if not in view mode or map not available. */
off_t viewmode_display_col(off_t buf_line, off_t buf_offset)
{
	if (viewmode_col_map && viewmode_col_map_line == buf_line &&
	    buf_offset >= 0 && buf_offset < viewmode_col_map_size) {
		return viewmode_col_map[buf_offset];
	}
	return -1;
}

/* Free all URL strings in viewmode_link_url with deduplication.
 * Multiple slots may point to the same allocation; we only free each
 * unique pointer once.  Slots are NULLed out after freeing. */
static void viewmode_free_link_urls(void)
{
	if (!viewmode_link_url)
		return;
	/* In-place dedup: walk the array, free each unique pointer on first
	 * encounter, then NULL all slots pointing to the same allocation. */
	int m;
	for (m = 0; m < viewmode_link_url_size; m++) {
		void *p = viewmode_link_url[m];
		if (p) {
			joe_free(p);
			/* NULL all subsequent slots pointing to the same allocation */
			int i;
			for (i = m + 1; i < viewmode_link_url_size; i++) {
				if (viewmode_link_url[i] == p)
					viewmode_link_url[i] = NULL;
			}
		}
		viewmode_link_url[m] = NULL;
	}
}

/* Cleanup view mode static globals on exit */
void viewmode_cleanup(void)
{
	if (viewmode_hide) {
		joe_free(viewmode_hide);
		viewmode_hide = NULL;
	}
	viewmode_hide_size = 0;
	if (viewmode_substitute) {
		joe_free(viewmode_substitute);
		viewmode_substitute = NULL;
	}
	viewmode_substitute_size = 0;
	if (viewmode_col_map) {
		joe_free(viewmode_col_map);
		viewmode_col_map = NULL;
	}
	viewmode_col_map_size = 0;
	viewmode_col_map_line = -1;
	if (viewmode_link_url) {
		viewmode_free_link_urls();
		joe_free(viewmode_link_url);
		viewmode_link_url = NULL;
		viewmode_link_url_size = 0;
	}
	table_region_start = -1;
	table_region_end = -1;
	table_separator_line = -1;
	table_cached_for_line = -1;
	table_no_region_line = -1;
	table_col_count = 0;
	viewmode_table_rendered = 0;
	{
		int _vi;
		for (_vi = 0; _vi < MAX_TABLE_COLS; _vi++) {
			table_col_width[_vi] = 0;
			table_col_align[_vi] = 0;
		}
	}
	if (viewmode_scan_buf) {
		joe_free(viewmode_scan_buf);
		viewmode_scan_buf = NULL;
		viewmode_scan_buf_size = 0;
	}
	viewmode_last_bw = NULL;
}

static int lgen(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr, ptrdiff_t x, ptrdiff_t w, P *p, off_t scr, off_t from, off_t to,HIGHLIGHT_STATE st,BW *bw)
{
	/* Markdown view mode transformations are only valid for Markdown syntax. */
	if (bw->o.viewmode && bw->o.syntax && !zcmp(bw->o.syntax->name, "md"))
		return lgen_view(t, y, screen, attr, x, w, p, scr, from, to, st, bw);
	else
		return lgen_core(t, y, screen, attr, x, w, p, scr, from, to, st, bw);
}

static int lgen_core(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr, ptrdiff_t x, ptrdiff_t w, P *p, off_t scr, off_t from, off_t to,HIGHLIGHT_STATE st,BW *bw)


            			/* Screen line address */
      				/* Window */
     				/* Buffer pointer */
         			/* Starting column to display */
              			/* Range for marked block */
{
	/* Path A: Zig-native paint for UTF-8 and byte charmaps (+ linear/square
	 * marks + viewmode tables + visiblews + ansi ESC hide). Feature 2.2 padded
	 * table rows skip lgen_core (painted via zig_bw_table_row / C fallback in
	 * lgen_view). dspasis lives in outatr. */
	if (zig_bw_lgen_enabled
	    && p && p->b && p->b->o.charmap) {
		int defatr = (bw->o.hiline && bw->cursor->line == y - bw->y + bw->top->line)
			? (bg_text & curlinmask) | bg_curlin
			: bg_text;
		int z = zig_bw_lgen(t, y, screen, attr, x, w, p, scr,
			bw->o.syntax, st, p->b->o.charmap, p->b->o.tab, BG_COLOR(defatr),
			t->palette, t->palette ? 256 : 0, from, to, p->byte,
			viewmode_skip_parse,
			viewmode_skip_parse ? viewmode_hide : NULL, viewmode_hide_size,
			viewmode_skip_parse ? viewmode_substitute : NULL, viewmode_substitute_size,
			viewmode_skip_parse ? viewmode_link_url : NULL, viewmode_link_url_size,
			bw->o.visiblews, square, bw->o.ansi);
		if (z >= 0)
			return z;
	}

	int ansi = bw->o.ansi;
	ptrdiff_t ox = x;
	int tach;
	int done = 1;
	off_t col = 0;
	off_t byte = p->byte;
	char *bp;	/* Buffer pointer, 0 if not set */
	ptrdiff_t amnt;		/* Amount left in this segment of the buffer */
	int c;
	off_t ta;
	char bc;
	int ungetit = NO_MORE_DATA;
	int sub_c = 0;		/* Unicode substitution for view mode */

	struct utf8_sm utf8_sm;
	struct ansi_sm ansi_sm;

	const attr_data *syn = NULL;
	const struct state_debug_data *syndebug = NULL;
	struct state_debug_data atr_state = {};
	struct state_debug_data old_atr_state = {};
        P *tmp;
        int idx=0;
	int highlight = (st.state != -1);
        int defatr = (bw->o.hiline && bw->cursor->line == y - bw->y + bw->top->line) ? (bg_text & curlinmask) | bg_curlin : bg_text;
        int atr = BG_COLOR(defatr);
        int ca = 0;		/* Additional attributes for current character */
        int cm = -1;		/* Attribute mask for current character */
        const char *current_link_url = NULL;	/* OSC 8 link tracking for view mode */

	utf8_init(&utf8_sm);
	ansi_init(&ansi_sm);

	if (highlight) {
		if (!viewmode_skip_parse) {
			/* Avoid unbounded per-line allocations in the highlighter:
			 * a single huge line can otherwise OOM via attr_buf growth. */
			P *lp = pdup(p, "lgen_len");
			p_goto_bol(lp);
			int ll = 0;
			int ch;
			while ((ch = pgetb(lp)) != NO_MORE_DATA && ch != '\n') {
				if (++ll > VIEWMODE_MAX_LINE_BYTES) {
					highlight = 0;
					break;
				}
			}
			prm(lp);
			if (!highlight)
				goto no_parse;
			tmp=pdup(p, "lgen");
			p_goto_bol(tmp);
			parse(bw->o.syntax,tmp,st,p->b->o.charmap);
			prm(tmp);
		}
no_parse:
		syn = attr_buf;
		syndebug = syndebug_buf;
	}

/* Initialize bp and amnt from p */
	if (p->ofst >= p->hdr->hole) {
		bp = p->ptr + p->hdr->ehole + p->ofst - p->hdr->hole;
		amnt = SEGSIZ - p->hdr->ehole - (p->ofst - p->hdr->hole);
	} else {
		bp = p->ptr + p->ofst;
		amnt = p->hdr->hole - p->ofst;
	}

	if (col == scr)
		goto loop;
      lp:			/* Display next character */
	if (amnt)
		do {
			if (ungetit == NO_MORE_DATA)
				bc = *bp++;
			else {
				bc = TO_CHAR_OK(ungetit);
				ungetit = NO_MORE_DATA;
			}
			sub_c = 0;
			if (highlight) {
				atr = syn[idx] & ~CONTEXT_MASK;
				if (syndebug)
					atr_state = syndebug[idx];
				++idx;
				if (viewmode_skip_parse && viewmode_hide && idx <= viewmode_hide_size && viewmode_hide[idx - 1])
					bc = ' ';
				if (viewmode_skip_parse && viewmode_substitute && idx <= viewmode_substitute_size && viewmode_substitute[idx - 1])
					sub_c = viewmode_substitute[idx - 1];
				if (viewmode_skip_parse && viewmode_link_url && idx <= viewmode_link_url_size && viewmode_link_url[idx - 1])
					current_link_url = out_osc8_link(current_link_url, viewmode_link_url[idx - 1]);
				else if (viewmode_skip_parse && current_link_url)
					current_link_url = out_osc8_link(current_link_url, NULL);
				if (!(atr & BG_MASK))
					atr |= defatr & BG_MASK;
				if (!(atr & FG_MASK))
					atr |= defatr & FG_MASK;
			}
			if (p->b->o.crlf && bc == '\r') {
				++byte;
				if (!--amnt) {
				      pppl:
					if (bp == p->ptr + SEGSIZ) {
						if (pnext(p)) {
							bp = p->ptr;
							amnt = p->hdr->hole;
						} else
							goto nnnl;
					} else {
						bp = p->ptr + p->hdr->ehole;
						amnt = SEGSIZ - p->hdr->ehole;
						if (!amnt)
							goto pppl;
					}
				}
				if (*bp == '\n') {
					++bp;
					++byte;
					++amnt;
					goto eobl;
				}
			      nnnl:
				--byte;
				++amnt;
			}
			if (square)
				if (bc == '\t') {
					off_t tcol = col + p->b->o.tab - col % p->b->o.tab;

					SELECT_IF(tcol > from && tcol <= to);
				} else {
					SELECT_IF(col >= from && col < to);
				}
			else
				SELECT_IF(byte >= from && byte < to);
			++byte;
			if (bc == '\t') {
				ta = p->b->o.tab - col % p->b->o.tab;
				if (ta + col > scr) {
					ta -= scr - col;
					tach = ' ';
					goto dota;
				}
				if ((col += ta) == scr) {
					--amnt;
					goto loop;
				}
			} else if (bc == '\n')
				goto eobl;
			else {
				int wid = 1;
				if (p->b->o.charmap->type) {
					c = utf8_decode(&utf8_sm,bc);

					if (c>=0) { /* Normal decoded character */
						if (sub_c > 0)
							c = sub_c;
						if (ansi) {
							c = ansi_decode(&ansi_sm, c);
							if (c >= 0) /* Not ansi */
								wid = joe_wcwidth(1, c);
							else { /* Skip ANSI character */
								wid = 0;
								++idx;
							}
						} else
							wid = joe_wcwidth(1,c);
					} else if(c == UTF8_ACCEPTED) /* Character taken */
						wid = -1;
					else if(c == UTF8_INCOMPLETE) { /* Incomplete sequence (FIXME: do something better here) */
						wid = 1;
						ungetit = c;
						++amnt;
						--byte;
					}
					else if(c == UTF8_BAD) /* Control character 128-191, 254, 255 */
						wid = 1;
				} else {
					if (ansi) {
						c = ansi_decode(&ansi_sm, bc);
						if (c>=0) { /* Not ANSI */
							if (sub_c > 0)
								c = sub_c;
							wid = 1;
						} else {
							wid = 0;
							++idx;
						}
					} else {
						if (sub_c > 0)
							c = sub_c;
						wid = 1;
					}
				}

				if(wid>0) {
					col += wid;
					if (col == scr) {
						--amnt;
						goto loop;
					} else if (col > scr) {
						ta = col - scr;
						tach = '<';
						goto dota;
					}
				} else
					--idx;	/* Get highlighting character again.. */
			}
		} while (--amnt);
	if (bp == p->ptr + SEGSIZ) {
		if (pnext(p)) {
			bp = p->ptr;
			amnt = p->hdr->hole;
			goto lp;
		}
	} else {
		bp = p->ptr + p->hdr->ehole;
		amnt = SEGSIZ - p->hdr->ehole;
		goto lp;
	}
	goto eof;

      loop:			/* Display next character */
	if (amnt)
		do {
			if (ungetit == NO_MORE_DATA)
				bc = *bp++;
			else {
				bc = TO_CHAR_OK(ungetit);
				ungetit = NO_MORE_DATA;
			}
			sub_c = 0;
			if (highlight) {
				atr = syn[idx] & ~CONTEXT_MASK;
				if (syndebug)
					atr_state = syndebug[idx];
				++idx;
				if (viewmode_skip_parse && viewmode_hide && idx <= viewmode_hide_size && viewmode_hide[idx - 1])
					bc = ' ';
				if (viewmode_skip_parse && viewmode_substitute && idx <= viewmode_substitute_size && viewmode_substitute[idx - 1])
					sub_c = viewmode_substitute[idx - 1];
				if (viewmode_skip_parse && viewmode_link_url && idx <= viewmode_link_url_size && viewmode_link_url[idx - 1])
					current_link_url = out_osc8_link(current_link_url, viewmode_link_url[idx - 1]);
				else if (viewmode_skip_parse && current_link_url)
					current_link_url = out_osc8_link(current_link_url, NULL);
				if (!(atr & BG_MASK))
					atr |= defatr & BG_MASK;
				if (!(atr & FG_MASK))
					atr |= defatr & FG_MASK;
			}
			if (p->b->o.crlf && bc == '\r') {
				++byte;
				if (!--amnt) {
				      ppl:
					if (bp == p->ptr + SEGSIZ) {
						if (pnext(p)) {
							bp = p->ptr;
							amnt = p->hdr->hole;
						} else
							goto nnl;
					} else {
						bp = p->ptr + p->hdr->ehole;
						amnt = SEGSIZ - p->hdr->ehole;
						if (!amnt)
							goto ppl;
					}
				}
				if (*bp == '\n') {
					if (bw->o.visiblews && x < w) {
						outatr(utf8_map, t, screen + x, attr + x, x, y, vrtn, (((atr & vwsmask) | (vwsatr & ~vwsmask)) & cm) | ca);
						old_atr_state = OUT_osc8(bw, old_atr_state, atr_state);
						++x;
					}

					++bp;
					++byte;
					++amnt;
					goto eobl;
				}
			      nnl:
				--byte;
				++amnt;
			}
			if (square) {
				if (bc == '\t') {
					off_t tcol = scr + x - ox + p->b->o.tab - (scr + x - ox) % p->b->o.tab;
					SELECT_IF(tcol > from && tcol <= to);
				} else {
					SELECT_IF(scr + x - ox >= from && scr + x - ox < to);
				}
			} else {
				SELECT_IF(byte >= from && byte < to);
			}
			++byte;
			if (bc == '\t') {
				ta = p->b->o.tab - (x - ox + scr) % p->b->o.tab;
				tach = ' ';
				if (ta > 0 && x < w && bw->o.visiblews) {
					outatr(utf8_map, t, screen + x, attr + x, x, y, vtab, (((atr & vwsmask) | (vwsatr & ~vwsmask)) & cm) | ca);
					old_atr_state = OUT_osc8(bw, old_atr_state, atr_state);
					++x;
					--ta;
				}
			      dota:
			      	while (x < w && ta--) {
					outatr(bw->b->o.charmap, t, screen + x, attr + x, x, y, tach, (atr & cm) | ca);
					old_atr_state = OUT_osc8(bw, old_atr_state, atr_state);
					++x;
				}
				if (ifhave)
					goto bye;
				if (x > w)
					goto eosl;
			} else if (bc == '\n') {
				if (bw->o.visiblews && x < w) {
					outatr(utf8_map, t, screen + x, attr + x, x, y, vrtn, (((atr & vwsmask) | (vwsatr & ~vwsmask)) & cm) | ca);
					old_atr_state = OUT_osc8(bw, old_atr_state, atr_state);
					++x;
				}
				goto eobl;
			} else if (bc == ' ' && bw->o.visiblews && x < w) {
				outatr(utf8_map, t, screen + x, attr + x, x, y, vspace, (((atr & vwsmask) | (vwsatr & ~vwsmask)) & cm) | ca);
				old_atr_state = OUT_osc8(bw, old_atr_state, atr_state);
				++x;
			} else {
				int wid = -1;
				int utf8_char;
				if (p->b->o.charmap->type) { /* UTF-8 */

					utf8_char = utf8_decode(&utf8_sm,bc);

					if (utf8_char >= 0) { /* Normal decoded character */
						if (sub_c > 0)
							utf8_char = sub_c;
						if (ansi) {
							utf8_char = ansi_decode(&ansi_sm, utf8_char);
							if (utf8_char >= 0) {
								wid = joe_wcwidth(1, utf8_char);
							} else {
								wid = -1;
								++idx;
							}
						} else
							wid = joe_wcwidth(1,utf8_char);
					} else if(utf8_char == UTF8_ACCEPTED) { /* Character taken */
						wid = -1;
					} else if(utf8_char == UTF8_INCOMPLETE) { /* Incomplete sequence (FIXME: do something better here) */
						ungetit = bc;
						++amnt;
						--byte;
						utf8_char = 'X';
						wid = 1;
					} else if(utf8_char == UTF8_BAD) { /* Invalid UTF-8 start character 128-191, 254, 255 */
						/* Show as control character */
						wid = 1;
						utf8_char = 'X';
					}
				} else { /* Regular */
					if (ansi) {
						utf8_char = ansi_decode(&ansi_sm, bc);
						if (utf8_char >= 0) { /* Not ANSI */
							if (sub_c > 0)
								utf8_char = sub_c;
							wid = 1;
						} else {
							wid = -1;
							++idx;
						}
					} else {
						utf8_char = (unsigned char)bc;
						if (sub_c > 0)
							utf8_char = sub_c;
						wid = 1;
					}
				}

				if(wid >= 0) {
					if (x + wid > w) {
						/* If character hits right most column, don't display it */
						while (x < w) {
							outatr(bw->b->o.charmap, t, screen + x, attr + x, x, y, '>', (atr & cm) | ca);
							old_atr_state = OUT_osc8(bw, old_atr_state, atr_state);
							x++;
						}
						goto eosl;
					} else {
						outatr(bw->b->o.charmap, t, screen + x, attr + x, x, y, utf8_char, (atr & cm) | ca);
						old_atr_state = OUT_osc8(bw, old_atr_state, atr_state);
						x += wid;
					}
				} else
					--idx;

				if (ifhave)
					goto bye;
				if (x > w)
					goto eosl;
			}
		} while (--amnt);
	if (bp == p->ptr + SEGSIZ) {
		if (pnext(p)) {
			bp = p->ptr;
			amnt = p->hdr->hole;
			goto loop;
		}
	} else {
		bp = p->ptr + p->hdr->ehole;
		amnt = SEGSIZ - p->hdr->ehole;
		goto loop;
	}
	goto eof;

       eobl:			/* End of buffer line found.  Erase to end of screen line */
	++p->line;
       eof:
	outatr_complete(t);
	END_osc8(bw, old_atr_state);
	end_osc8_link(current_link_url);
	if (x < w)
		done = eraeol(t, x, y, BG_COLOR(defatr));
	else
		done = 0;

/* Set p to bp/amnt */
       bye:
	outatr_complete(t);
	END_osc8(bw, old_atr_state);
	end_osc8_link(current_link_url);
	if (bp - p->ptr <= p->hdr->hole)
		p->ofst = (short)(bp - p->ptr);
	else
		p->ofst = (short)(bp - p->ptr - (p->hdr->ehole - p->hdr->hole));
	p->byte = byte;
	return done;

       eosl:
	outatr_complete(t);
	END_osc8(bw, old_atr_state);
	end_osc8_link(current_link_url);
	if (bp - p->ptr <= p->hdr->hole)
		p->ofst = (short)(bp - p->ptr);
	else
		p->ofst = (short)(bp - p->ptr - (p->hdr->ehole - p->hdr->hole));
	p->byte = byte;
	pnextl(p);
	return 0;
}

/* Feature 2.2: Render a table row with padded columns, alignment, and
 * box-drawing borders.  Writes directly to the screen buffer because the
 * padded output is wider than the original buffer line.  After this
 * returns, caller should advance p past the line and skip lgen_core.
 * Also builds viewmode_col_map for cursor positioning. */
static void render_padded_table_row(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr, ptrdiff_t x, ptrdiff_t w, BW *bw, const unsigned char *line, int line_len, table_row_type_t row_type)
{
	int pipe_pos[MAX_TABLE_COLS];
	int pipe_count = 0;
	int ti;
	for (ti = 0; ti < line_len && pipe_count < MAX_TABLE_COLS; ti++) {
		if (line[ti] == '|')
			pipe_pos[pipe_count++] = ti;
	}
	if (pipe_count == 0) return;
	int ncols = pipe_count - 1;
	if (ncols > MAX_TABLE_COLS) ncols = MAX_TABLE_COLS;
	int defatr = (bw->o.hiline && bw->cursor->line == y - bw->y + bw->top->line) ? (bg_text & curlinmask) | bg_curlin : bg_text;
	int base_atr = BG_COLOR(defatr);
	if (row_type == TABLE_ROW_HEADER) base_atr |= BOLD;
	/* Parse each cell: trimmed byte range and display width */
	int ci;
	struct { int start; int end; int width; } cells[MAX_TABLE_COLS];
	for (ci = 0; ci < ncols; ci++) {
		int cs = pipe_pos[ci] + 1;
		int ce = (ci + 1 < pipe_count) ? pipe_pos[ci + 1] : line_len;
		int ts = cs;
		while (ts < ce && (line[ts] == ' ' || line[ts] == '\t')) ++ts;
		int te = ce - 1;
		while (te >= ts && (line[te] == ' ' || line[te] == '\t')) --te;
		te++;
		cells[ci].start = ts;
		cells[ci].end = te;
		int width = 0;
		if (ts < te) {
			const char *cp = (const char *)(line + ts);
			ptrdiff_t rem = (ptrdiff_t)(te - ts);
			while (rem > 0) {
				int c = utf8_decode_fwrd(&cp, &rem);
				if (c >= 0) {
					int cw = joe_wcwidth(1, c);
					if (cw > 0) width += cw;
				}
			}
		}
		cells[ci].width = width;
	}
	int col;



	/* Compute total rendered width */
	int total_width = 0;
	for (col = 0; col < ncols && col < MAX_TABLE_COLS; col++)
		total_width += 3 + (col < MAX_TABLE_COLS ? table_col_width[col] : 0);
	total_width += 1; /* closing border */
	/* Clip to available width */
	ptrdiff_t max_col = w - x;
	if (total_width > max_col)
		total_width = (int)max_col;
	if (total_width <= 0) return;

	/* Feature 2.2: Separator rows — box-drawing joints with dashes matching column widths */
	if (row_type == TABLE_ROW_SEPARATOR) {
		ptrdiff_t oc = x;
		for (col = 0; col < ncols && oc < x + total_width; col++) {
			int cw = (col < MAX_TABLE_COLS) ? table_col_width[col] : 0;
			int seg_w = cw + 2;
			if (oc + 1 + seg_w > x + total_width) break;
			int joint = (col == 0) ? 0x251C : 0x253C;
			outatr(bw->b->o.charmap, t, screen + oc, attr + oc, oc, y, joint, base_atr);
			oc++;
			int di;
			for (di = 0; di < seg_w && oc < x + total_width; di++) {
				outatr(bw->b->o.charmap, t, screen + oc, attr + oc, oc, y, 0x2500, base_atr);
				oc++;
			}
		}
		if (oc < x + total_width)
			outatr(bw->b->o.charmap, t, screen + oc, attr + oc, oc, y, 0x2524, base_atr);
		outatr_complete(t);
		oc++;
		if (oc < w)
			eraeol(t, oc, y, base_atr);
		return;
	}

	/* Render */
	ptrdiff_t oc = x;
	for (col = 0; col < ncols && oc < x + total_width; col++) {
		int cw = (col < MAX_TABLE_COLS) ? table_col_width[col] : 0;
		if (cw < cells[col].width) cw = cells[col].width; /* clamp to at least content width */
		/* Ensure there's room for border + left_pad + content + right_pad */
		if (oc + 1 + 1 + cw + 1 > x + total_width) break;
		/* Border │ */
		outatr(bw->b->o.charmap, t, screen + oc, attr + oc, oc, y, 0x2502, base_atr);
		oc++;
		/* Left padding */
		outatr(bw->b->o.charmap, t, screen + oc, attr + oc, oc, y, ' ', base_atr);
		oc++;
		/* Padded content */
		int align = (col < MAX_TABLE_COLS) ? table_col_align[col] : 0;
		int avail = cw;
		int cwidth = cells[col].width;
		if (cwidth > avail) cwidth = avail;
		int pad_total = avail - cwidth;
		int pad_left = 0, pad_right = pad_total;
		if (align == 1) {
			pad_left = pad_total / 2;
			pad_right = pad_total - pad_left;
		} else if (align == 2) {
			pad_left = pad_total;
			pad_right = 0;
		}
		/* Alignment pad (left) */
		int pi;
		for (pi = 0; pi < pad_left && oc < x + total_width; pi++) {
			outatr(bw->b->o.charmap, t, screen + oc, attr + oc, oc, y, ' ', base_atr);
			oc++;
		}
		/* Cell content */
		if (cells[col].start < cells[col].end) {
			const char *cp = (const char *)(line + cells[col].start);
			ptrdiff_t rem = (ptrdiff_t)(cells[col].end - cells[col].start);
			while (rem > 0 && oc < x + total_width) {
				int c = utf8_decode_fwrd(&cp, &rem);
				if (c >= 0) {
					int cww = joe_wcwidth(1, c);
					if (cww > 0) {
						if (oc + cww <= x + total_width) {
							outatr(bw->b->o.charmap, t, screen + oc, attr + oc, oc, y, c, base_atr);
							oc += cww;
						} else break;
					}
				}
			}
		}
		/* Alignment pad (right) */
		for (pi = 0; pi < pad_right && oc < x + total_width; pi++) {
			outatr(bw->b->o.charmap, t, screen + oc, attr + oc, oc, y, ' ', base_atr);
			oc++;
		}
		/* Right padding (always 1 space) */
		if (oc < x + total_width) {
			outatr(bw->b->o.charmap, t, screen + oc, attr + oc, oc, y, ' ', base_atr);
			oc++;
		}
	}
	/* Closing border */
	if (oc < x + total_width)
		outatr(bw->b->o.charmap, t, screen + oc, attr + oc, oc, y, 0x2502, base_atr);
	outatr_complete(t);
	oc++;
	if (oc < w)
		eraeol(t, oc, y, base_atr);

	/* Build viewmode_col_map for cursor positioning */
	if (viewmode_col_map && viewmode_col_map_size >= (line_len > 0 ? line_len : 1)) {
		int bi;
		for (bi = 0; bi < line_len; bi++)
			viewmode_col_map[bi] = 0;
		/* Compute display start column for each cell's content area */
		ptrdiff_t content_display_start[MAX_TABLE_COLS];
		ptrdiff_t col_start_disp = x;
		int cj;
		for (cj = 0; cj < ncols; cj++) {
			content_display_start[cj] = col_start_disp;
			int cw_ = (cj < MAX_TABLE_COLS) ? table_col_width[cj] : 0;
			if (cw_ < cells[cj].width) cw_ = cells[cj].width;
			col_start_disp += 3 + cw_;
		}
		for (cj = 0; cj < ncols; cj++) {
			ptrdiff_t base = content_display_start[cj];
			int cw_ = (cj < MAX_TABLE_COLS) ? table_col_width[cj] : 0;
			if (cw_ < cells[cj].width) cw_ = cells[cj].width;
			int pad_t = cw_ - cells[cj].width;
			if (pad_t < 0) pad_t = 0;
			int pl = 0;
			int al_ = (cj < MAX_TABLE_COLS) ? table_col_align[cj] : 0;
			if (al_ == 1) { pl = pad_t / 2; }
			else if (al_ == 2) { pl = pad_t; }
			/* Pipe position maps to border */
			if (cj < pipe_count)
				viewmode_col_map[pipe_pos[cj]] = base;
			/* Content area: border(1) + left_pad(1) + pad_left */
			ptrdiff_t content_col = base + 1 + 1 + pl;
			/* Walk content bytes and map each to display column */
			int buf_i = cells[cj].start;
			const char *cp_ = (const char *)(line + cells[cj].start);
			ptrdiff_t rem_ = (ptrdiff_t)(cells[cj].end - cells[cj].start);
			while (rem_ > 0 && buf_i < cells[cj].end) {
				int ch_ = utf8_decode_fwrd(&cp_, &rem_);
				if (ch_ >= 0) {
					int cww_ = joe_wcwidth(1, ch_);
					if (cww_ > 0) {
						while (buf_i < cells[cj].end && (const char *)(line + buf_i) < cp_) {
							if (buf_i < line_len)
								viewmode_col_map[buf_i] = content_col;
							buf_i++;
						}
						content_col += cww_;
					} else {
						while (buf_i < cells[cj].end && (const char *)(line + buf_i) < cp_) {
							if (buf_i < line_len)
								viewmode_col_map[buf_i] = content_col;
							buf_i++;
						}
					}
				}
			}
			/* Remaining bytes before next pipe map to end of content area */
			ptrdiff_t content_end_col = base + 1 + 1 + cw_ + 1; /* after right_pad space */
			int next_pipe = (cj + 1 < pipe_count) ? pipe_pos[cj + 1] : line_len;
			while (buf_i < next_pipe && buf_i < line_len) {
				viewmode_col_map[buf_i] = content_end_col;
				buf_i++;
			}
		}
		viewmode_col_map_line = bw->top->line + y - bw->y;
	}
}

/* Markdown view mode rendering */
/* Features 1.3-1.8: Hide/transform markdown delimiters in view mode */
static int lgen_view(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr, ptrdiff_t x, ptrdiff_t w, P *p, off_t scr, off_t from, off_t to,HIGHLIGHT_STATE st,BW *bw)
{
	/* Only process when syntax highlighting is active and syntax is Markdown. */
	if (st.state == -1 || !bw->o.syntax || zcmp(bw->o.syntax->name, "md"))
		return lgen_core(t, y, screen, attr, x, w, p, scr, from, to, st, bw);

	/* Invalidate caches when rendering a different window (split-screen safety). */
	if (viewmode_last_bw != bw) {
		table_region_start = -1;
		table_region_end = -1;
		table_separator_line = -1;
		table_cached_for_line = -1;
		table_no_region_line = -1;
		table_col_count = 0;
		viewmode_col_map_line = -1;
		viewmode_last_bw = bw;
	}

	/* Avoid unbounded allocations in view mode on pathological lines. */
	{
		P *lp = pdup(p, "lgen_view_len");
		p_goto_bol(lp);
		int ll = 0;
		int ch;
		while ((ch = pgetb(lp)) != NO_MORE_DATA && ch != '\n') {
			if (++ll > VIEWMODE_MAX_LINE_BYTES) {
				prm(lp);
				return lgen_core(t, y, screen, attr, x, w, p, scr, from, to, st, bw);
			}
		}
		prm(lp);
	}

	/* Parse the line to populate attr_buf */
	P *tmp = pdup(p, "lgen_view");
	p_goto_bol(tmp);
	(void)parse(bw->o.syntax, tmp, st, p->b->o.charmap);
	prm(tmp);

	/* Read line bytes into a local buffer */
	tmp = pdup(p, "lgen_view2");
	p_goto_bol(tmp);

	int line_len = 0;
	ptrdiff_t line_cap = 1024;
	int line_truncated = 0;
	unsigned char *line = (unsigned char *)joe_malloc(line_cap);
	if (!line) {
		prm(tmp);
		return lgen_core(t, y, screen, attr, x, w, p, scr, from, to, st, bw);
	}
	int c;
	while ((c = pgetb(tmp)) != NO_MORE_DATA && c != '\n') {
		if (line_len >= INT_MAX - 1)
			break;
		if (line_len >= VIEWMODE_MAX_LINE_BYTES) {
			/* Stop buffering: avoid allocating per-line state for gigantic lines. */
			line_truncated = 1;
			break;
		}
		if (line_len >= line_cap) {
			ptrdiff_t new_cap = line_cap * 2;
			if (new_cap <= line_cap) {
				/* Overflow protection: cap at max safe size */
				new_cap = line_cap + (ptrdiff_t)1024 * 1024;
			}
			if (new_cap > VIEWMODE_MAX_LINE_BYTES)
				new_cap = VIEWMODE_MAX_LINE_BYTES;
			unsigned char *new_line = (unsigned char *)joe_realloc(line, new_cap);
			line = new_line;
			line_cap = new_cap;
		}
		line[line_len++] = (unsigned char)c;
	}
	prm(tmp);

	/* Ensure viewmode_hide is the right size */
	if (!viewmode_hide || viewmode_hide_size < (line_len > 0 ? line_len : 1)) {
		int need = line_len > 0 ? line_len : 1;
		if (need > VIEWMODE_MAX_LINE_BYTES)
			need = VIEWMODE_MAX_LINE_BYTES;
		if (viewmode_hide)
			joe_free(viewmode_hide);
		viewmode_hide_size = need;
		viewmode_hide = (char *)joe_malloc((ptrdiff_t)viewmode_hide_size);
	}
	memset(viewmode_hide, 0, (size_t)(line_len > 0 ? line_len : 1));

	/* Ensure viewmode_substitute is the right size */
	if (!viewmode_substitute || viewmode_substitute_size < (line_len > 0 ? line_len : 1)) {
		int need = line_len > 0 ? line_len : 1;
		if (need > VIEWMODE_MAX_LINE_BYTES)
			need = VIEWMODE_MAX_LINE_BYTES;
		if (viewmode_substitute)
			joe_free(viewmode_substitute);
		viewmode_substitute_size = need;
		viewmode_substitute = (int *)joe_malloc((ptrdiff_t)viewmode_substitute_size * (ptrdiff_t)sizeof(int));
	}
	memset(viewmode_substitute, 0, (size_t)(line_len > 0 ? line_len : 1) * sizeof(int));

	/* If we couldn't buffer the full line, avoid building additional per-line state. */
	if (line_truncated) {
		joe_free(line);
		/* Prevent stale URL mappings from previous lines from leaking into this render. */
		viewmode_free_link_urls();
		viewmode_skip_parse = 1;
		int result = lgen_core(t, y, screen, attr, x, w, p, scr, from, to, st, bw);
		viewmode_skip_parse = 0;
		return result;
	}

	/* --- Detect line type and hide delimiters --- */

	/* Path A: thin Zig lgen_view chrome dispatcher (Feature 1.x/2.x sequence).
	 * C keeps parse / line buffer / side-table alloc and post paint cleanup.
	 * On success, Zig already ran Feature 1.10 finish — jump to paint_and_cleanup.
	 * On failure (-1), fall through to piecemeal Path A + C chrome. */
	if (zig_bw_lgen_enabled && attr_buf && attr_size > 0) {
		int need = line_len > 0 ? line_len : 1;
		int ready = 1;
		if (!viewmode_col_map || viewmode_col_map_size < need) {
			off_t *nm = (off_t *)joe_realloc(viewmode_col_map, (ptrdiff_t)need * (ptrdiff_t)sizeof(off_t));
			if (!nm) {
				if (viewmode_col_map) joe_free(viewmode_col_map);
				viewmode_col_map = NULL;
				viewmode_col_map_size = 0;
				viewmode_col_map_line = -1;
				ready = 0;
			} else {
				viewmode_col_map = nm;
				viewmode_col_map_size = need;
			}
		}
		if (!viewmode_link_url || viewmode_link_url_size < need) {
			viewmode_free_link_urls();
			char **nl = (char **)joe_realloc(viewmode_link_url, (ptrdiff_t)need * (ptrdiff_t)sizeof(char *));
			if (!nl) {
				ready = 0;
			} else {
				viewmode_link_url = nl;
				if (viewmode_link_url_size < need) {
					memset(viewmode_link_url + viewmode_link_url_size, 0,
					       (size_t)(need - viewmode_link_url_size) * sizeof(char *));
				}
				viewmode_link_url_size = need;
			}
		} else {
			viewmode_free_link_urls();
			memset(viewmode_link_url, 0, (size_t)need * sizeof(char *));
		}
		if (ready
		    && viewmode_hide && viewmode_hide_size >= need
		    && viewmode_substitute && viewmode_substitute_size >= need
		    && viewmode_col_map && viewmode_col_map_size >= need
		    && viewmode_link_url && viewmode_link_url_size >= need
		    && bw->b && bw->b->o.charmap) {
			int tab = bw->o.tab;
			if (tab <= 0) tab = 8;
			off_t buf_line = bw->top->line + y - bw->y;
			int defatr = (bw->o.hiline && bw->cursor->line == buf_line)
				? (bg_text & curlinmask) | bg_curlin
				: bg_text;
			int utf8 = bw->b->o.charmap->type ? 1 : 0;
			int z = zig_bw_lgen_view(t, y, screen, attr, x, w, p, line, line_len,
				viewmode_hide, viewmode_hide_size,
				viewmode_substitute, viewmode_substitute_size,
				viewmode_link_url, viewmode_link_url_size,
				viewmode_col_map, viewmode_col_map_size,
				&viewmode_col_map_line, attr_buf, attr_size, tab, buf_line,
				bw->cursor, &table_region_start, &table_region_end,
				&table_separator_line, &table_cached_for_line,
				&table_no_region_line, &table_col_count,
				table_col_width, table_col_align, MAX_TABLE_COLS,
				bw->b->o.charmap, BG_COLOR(defatr),
				t->palette, t->palette ? 256 : 0, utf8);
			if (z == 1) {
				viewmode_table_rendered = 1;
				goto paint_and_cleanup;
			}
			if (z == 0)
				goto paint_and_cleanup;
		}
	}

	/* Path A: Zig line-start view chrome (heading/fence/blockquote/HR/task). */
	int zig_line_start_done = 0;
	if (zig_bw_lgen_enabled) {
		int need = line_len > 0 ? line_len : 1;
		if (!viewmode_col_map || viewmode_col_map_size < need) {
			off_t *nm = (off_t *)joe_realloc(viewmode_col_map, (ptrdiff_t)need * (ptrdiff_t)sizeof(off_t));
			if (nm) {
				viewmode_col_map = nm;
				viewmode_col_map_size = need;
			}
		}
		if (viewmode_col_map && viewmode_col_map_size >= need
		    && viewmode_hide && viewmode_hide_size >= need
		    && viewmode_substitute && viewmode_substitute_size >= need) {
			int tab = bw->o.tab;
			if (tab <= 0) tab = 8;
			int z = zig_bw_view_line_start(line, line_len,
				viewmode_hide, viewmode_hide_size,
				viewmode_substitute, viewmode_substitute_size,
				viewmode_col_map, viewmode_col_map_size, tab);
			if (z == 1) {
				viewmode_col_map_line = bw->top->line + y - bw->y;
				goto done;
			}
			if (z == 0)
				zig_line_start_done = 1;
		}
	}

	if (!zig_line_start_done) {
	/* Feature 1.3: Heading — hide # run and trailing space */
	{
		int i = 0;
		while (i < line_len && line[i] == '#')
			++i;
		if (i > 0 && i <= 6) {
			if (i < line_len && (line[i] == ' ' || line[i] == '\t')) {
				int j;
				for (j = 0; j <= i; j++)
					viewmode_hide[j] = 1;
			} else if (i == line_len) {
				int j;
				for (j = 0; j < i; j++)
					viewmode_hide[j] = 1;
			}
			goto done;
		}
	}

	/* Feature 1.5: Fenced code block fence — hide ``` or ~~~ lines
	 * Feature 1.5.3: Keep language identifier visible in dim color
	 */
	{
		int i = 0;
		while (i < line_len && (line[i] == ' ' || line[i] == '\t'))
			++i;
		if (i + 2 < line_len && line[i] == '`' && line[i+1] == '`' && line[i+2] == '`') {
			/* Count all consecutive backtick characters */
			int fence_end = i + 3;
			while (fence_end < line_len && line[fence_end] == '`')
				++fence_end;
			/* Hide leading whitespace and all fence markers */
			int j;
			for (j = 0; j < fence_end; j++)
				viewmode_hide[j] = 1;
			/* Language identifier (if any) remains visible with MdCodeFence color */
			goto done;
		}
		if (i + 2 < line_len && line[i] == '~' && line[i+1] == '~' && line[i+2] == '~') {
			/* Count all consecutive tilde characters */
			int fence_end = i + 3;
			while (fence_end < line_len && line[fence_end] == '~')
				++fence_end;
			/* Hide leading whitespace and all fence markers */
			int j;
			for (j = 0; j < fence_end; j++)
				viewmode_hide[j] = 1;
			/* Language identifier (if any) remains visible with MdCodeFence color */
			goto done;
		}
	}

	/* Feature 1.7: Blockquote — render nested blockquotes with vertical bars
	 * Single > becomes │, nested >> becomes │ │, etc.
	 */
	{
		int i = 0;
		int nesting = 0;
		while (i < line_len && line[i] == '>') {
			++nesting;
			/* Replace > with │ (U+2502) */
			viewmode_substitute[i] = 0x2502;
			++i;
			if (i < line_len && line[i] == ' ') {
				/* Keep the space after > for indentation */
				++i;
			}
		}
		if (nesting > 0)
			goto done;
	}

	/* Feature 1.7.3: List markers (* - +) at line start are preserved (not hidden as emphasis)
	 * Feature 1.7.4: Task list checkbox substitution [ ] → ☐, [x] → ☑
	 */
	{
		int i = 0;
		/* Skip leading whitespace */
		while (i < line_len && (line[i] == ' ' || line[i] == '\t'))
			++i;
		/* Check for list marker: * - + followed by space */
		if (i < line_len && (line[i] == '*' || line[i] == '-' || line[i] == '+') &&
		    i + 1 < line_len && (line[i+1] == ' ' || line[i+1] == '\t')) {
			/* Check for task list checkbox: [ ] or [x] after the list marker */
			int after_marker = i + 2;
			/* Skip whitespace after list marker */
			while (after_marker < line_len && (line[after_marker] == ' ' || line[after_marker] == '\t'))
				++after_marker;
			/* Check for [ ] or [x] */
			if (after_marker + 2 < line_len && line[after_marker] == '[' &&
			    (line[after_marker+1] == ' ' || line[after_marker+1] == 'x' || line[after_marker+1] == 'X') &&
			    line[after_marker+2] == ']') {
				/* Substitute [ with checkbox character, hide ] and space/x */
				int is_checked = (line[after_marker+1] == 'x' || line[after_marker+1] == 'X');
				viewmode_substitute[after_marker] = is_checked ? 0x2611 : 0x2610; /* ☑ or ☐ */
				viewmode_hide[after_marker+1] = 1; /* hide space/x */
				viewmode_hide[after_marker+2] = 1; /* hide ] */
				/* Also hide trailing space after ] if present */
				if (after_marker + 3 < line_len && line[after_marker+3] == ' ')
					viewmode_hide[after_marker+3] = 1;
			}
		}
	}

	/* Feature 1.8: Horizontal rule - render full-width Unicode line ─ (U+2500) */
	{
		int i = 0;
		while (i < line_len && (line[i] == ' ' || line[i] == '\t'))
			++i;
		if (i < line_len && (line[i] == '-' || line[i] == '*' || line[i] == '+')) {
			unsigned char rule_char = line[i];
			int count = 0;
			int j = i;
			int is_rule = 1;
			while (j < line_len) {
				if (line[j] == rule_char)
					++count;
				else if (line[j] != ' ' && line[j] != '\t') {
					is_rule = 0;
					break;
				}
				++j;
			}
			if (is_rule && count >= 3) {
				/* Substitute every character with ─ (U+2500) for full-width line */
				for (j = 0; j < line_len; j++)
					viewmode_substitute[j] = 0x2500;
				goto done;
			}
		}
	}

	} /* !zig_line_start_done */

	/* Feature 2.1: Unicode Box-Drawing Table Borders
	 * Detect table regions by scanning ahead, then apply box-drawing substitutions:
	 * - First row:    | → ┌ (first), | → ┬ (middle), | → ┐ (last)
	 * - Separator:    | → ├ (first), | → ┼ (middle), | → ┤ (last), dashes → ─
	 * - Body rows:    | → │
	 * - Last row:     | → └ (first), | → ┴ (middle), | → ┘ (last)
	 * Also strips alignment indicators (:---, :---:, ---:) from display.
	 */
	{
		off_t buf_line = bw->top->line + y - bw->y;
		table_row_type_t row_type = TABLE_ROW_NONE;

		/* Check if our cached table region is still valid */
		if (table_cached_for_line != buf_line) {
			/* Cache is stale — check if we're still in the cached region */
			if (buf_line >= table_region_start && buf_line < table_region_end) {
				/* Still in region — cache is valid for this line */
				table_cached_for_line = buf_line;
			} else {
				/* Outside cached region — invalidate and scan ahead */
				table_region_start = -1;
				table_region_end = -1;
				table_separator_line = -1;
				table_col_count = 0;
				{
					int _vi;
					for (_vi = 0; _vi < MAX_TABLE_COLS; _vi++) {
						table_col_width[_vi] = 0;
						table_col_align[_vi] = 0;
					}
				}

				/* Negative cache: if we recently scanned nearby and found
					 * no table region, skip the expensive forward/backward scan.
					 * But only skip if this line has no pipe chars — a line with
					 * | might be the start of a new table. */
					int has_pipe = 0;
					{
						int _pi;
						for (_pi = 0; _pi < line_len; _pi++) {
							if (line[_pi] == '|') { has_pipe = 1; break; }
						}
					}
					if (!has_pipe &&
					    table_no_region_line != -1 &&
					    buf_line >= table_no_region_line - 10 &&
					    buf_line <= table_no_region_line + 10) {
						table_cached_for_line = buf_line;
						goto skip_table_scan;
					}

					/* Path A: Zig-native table region detect (JOE_ZIG_BW_LGEN). */
					if (zig_bw_lgen_enabled) {
						int zdet = zig_bw_table_detect(p, buf_line,
							&table_region_start, &table_region_end,
							&table_separator_line, &table_col_count,
							table_col_width, table_col_align, MAX_TABLE_COLS);
						if (zdet >= 0) {
							if (table_region_start == -1)
								table_no_region_line = buf_line;
							table_cached_for_line = buf_line;
							goto skip_table_scan;
						}
					}

					/* Try to find the table start by scanning backward from current line */
				off_t backward_first = -1;
				{
					P *back = pdup(p, "back_scan");
					p_goto_bol(back);
					int bc0;
					while ((bc0 = pgetb(back)) != NO_MORE_DATA && (bc0 == ' ' || bc0 == '\t'));
					if (bc0 == '|') {
						backward_first = buf_line;
						off_t bl = buf_line - 1;
						while (bl >= 0 && buf_line - bl <= 50) {
							pline(back, bl);
							p_goto_bol(back);
							int bc1;
							while ((bc1 = pgetb(back)) != NO_MORE_DATA && (bc1 == ' ' || bc1 == '\t'));
							if (bc1 == '|') {
								backward_first = bl;
								bl--;
							} else {
								break;
							}
						}
					}
					prm(back);
				}

				/* Scan ahead from current line to find a table region */
				P *scan = pdup(p, "table_scan");
				if (backward_first != -1) {
					pline(scan, backward_first);
				}
				p_goto_bol(scan);
				off_t scan_line = (backward_first != -1) ? backward_first : buf_line;
				off_t first_table_line = -1;
				off_t sep_line = -1;
				int consecutive = 0;
				int col_cnt = 0;

				/* Scan up to 200 lines ahead to find table region */
				while (consecutive < 200) {
					/* Read this line into persistent scan buffer */
					int ll = 0;
					int too_long = 0;
					{
						ptrdiff_t need = 512;
						if (need > VIEWMODE_TABLE_SCAN_MAX_BYTES)
							need = VIEWMODE_TABLE_SCAN_MAX_BYTES;
						if (!viewmode_scan_buf || viewmode_scan_buf_size < need) {
							if (viewmode_scan_buf) joe_free(viewmode_scan_buf);
							viewmode_scan_buf = (unsigned char *)joe_malloc(need);
							if (!viewmode_scan_buf) { viewmode_scan_buf_size = 0; break; }
							viewmode_scan_buf_size = need;
						}
					}
					unsigned char *lb = viewmode_scan_buf;
					ptrdiff_t lc = viewmode_scan_buf_size;
					P *rl = pdup(scan, "table_read");
					p_goto_bol(rl);
					int ch;
						while ((ch = pgetb(rl)) != NO_MORE_DATA && ch != '\n') {
							if (ll >= INT_MAX - 1)
								break;
							if (ll >= VIEWMODE_TABLE_SCAN_MAX_BYTES) {
								too_long = 1;
								break;
							}
							if (ll >= lc) {
								ptrdiff_t nc = lc * 2;
								if (nc <= lc) nc = lc + 256;
								if (nc > VIEWMODE_TABLE_SCAN_MAX_BYTES)
									nc = VIEWMODE_TABLE_SCAN_MAX_BYTES;
							unsigned char *nb = (unsigned char *)joe_realloc(viewmode_scan_buf, nc);
							viewmode_scan_buf = nb;
							viewmode_scan_buf_size = nc;
							lb = nb;
							lc = nc;
						}
						lb[ll++] = (unsigned char)ch;
					}
					prm(rl);

					/* Check if this line has a pipe */
					int line_has_pipe = 0;
					int si = 0;
					while (si < ll && (lb[si] == ' ' || lb[si] == '\t')) ++si;
					if (si < ll && lb[si] == '|') line_has_pipe = 1;
					if (too_long)
						line_has_pipe = 0; /* Avoid classifying huge lines as tables. */

					if (line_has_pipe) {
					if (first_table_line == -1)
						first_table_line = scan_line;

					/* Check if this is a separator row */
					int is_sep = 1, has_dash = 0, di;
					for (di = 0; di < ll; di++) {
						if (lb[di] == '|' || lb[di] == '-' || lb[di] == ':' ||
						    lb[di] == ' ' || lb[di] == '\t') {
							if (lb[di] == '-') has_dash = 1;
						} else {
							is_sep = 0;
							break;
						}
					}
					if (is_sep && has_dash) {
						sep_line = scan_line;
						/* Count columns */
						int pipes = 0, ci;
						for (ci = 0; ci < ll; ci++)
							if (lb[ci] == '|') pipes++;
						col_cnt = pipes > 0 ? pipes - 1 : 1;
						/* Extract column alignment from separator row */
						{
							int pipe_pos[MAX_TABLE_COLS];
							int np = 0;
							for (ci = 0; ci < ll && np < MAX_TABLE_COLS; ci++)
								if (lb[ci] == '|') pipe_pos[np++] = ci;
							int max_col = np > 0 ? np - 1 : 0;
							if (max_col > MAX_TABLE_COLS) max_col = MAX_TABLE_COLS;
							int k;
							for (k = 0; k < max_col; k++) {
								int cs = pipe_pos[k] + 1;
								int ce = (k + 1 < np) ? pipe_pos[k + 1] : ll;
								if (cs >= ce) continue;
								int has_left = (lb[cs] == ':') ? 1 : 0;
								int has_right = (lb[ce - 1] == ':') ? 1 : 0;
								if (has_left && has_right)
									table_col_align[k] = 1; /* center */
								else if (has_right)
									table_col_align[k] = 2; /* right */
							}
						}
					} else {
						/* Feature 2.2: Track per-column display widths */
						int pipe_pos[MAX_TABLE_COLS];
						int np = 0;
						int ci2;
						for (ci2 = 0; ci2 < ll && np < MAX_TABLE_COLS; ci2++)
							if (lb[ci2] == '|') pipe_pos[np++] = ci2;
						int max_col = np > 0 ? np - 1 : 0;
						if (max_col > MAX_TABLE_COLS) max_col = MAX_TABLE_COLS;
						int k;
						for (k = 0; k < max_col; k++) {
							int cs = pipe_pos[k] + 1;
							int ce = (k + 1 < np) ? pipe_pos[k + 1] : ll;
							/* Trim leading/trailing whitespace */
							int ts = cs;
							while (ts < ce && (lb[ts] == ' ' || lb[ts] == '\t')) ++ts;
							int te = ce - 1;
							while (te >= ts && (lb[te] == ' ' || lb[te] == '\t')) --te;
							te++;
							int width = 0;
							if (ts < te) {
								const char *cp = (const char *)(lb + ts);
								ptrdiff_t rem = (ptrdiff_t)(te - ts);
								while (rem > 0) {
									int ucw = utf8_decode_fwrd(&cp, &rem);
									if (ucw >= 0) {
										int cw = joe_wcwidth(1, ucw);
										if (cw > 0) width += cw;
									}
								}
							}
							if (width > table_col_width[k])
								table_col_width[k] = width;
						}
					}

						consecutive++;
					} else {
					/* Non-table line — if we found at least 2 table lines, we have a region */
					if (first_table_line != -1 && consecutive >= 2) {
						table_region_start = first_table_line;
						table_region_end = scan_line;
						table_separator_line = sep_line;
						table_col_count = col_cnt;
					}
						break;
					}
						pnextl(scan);
						scan_line++;
					}

				/* If we reached EOF with a valid table region */
				if (first_table_line != -1 && consecutive >= 2 && table_region_start == -1) {
					table_region_start = first_table_line;
					table_region_end = scan_line;
					table_separator_line = sep_line;
					table_col_count = col_cnt;
				}

				prm(scan);
					/* If no table region was found, record in negative cache */
					if (table_region_start == -1)
						table_no_region_line = buf_line;
				table_cached_for_line = buf_line;
			}
		}

		skip_table_scan:
			/* Determine what kind of row we are */
		if (buf_line >= table_region_start && buf_line < table_region_end) {
			if (buf_line == table_separator_line) {
				row_type = TABLE_ROW_SEPARATOR;
			} else if (buf_line == table_region_start) {
				row_type = TABLE_ROW_HEADER;
			} else if (buf_line == table_region_end - 1 && table_region_end - 1 > table_separator_line) {
				row_type = TABLE_ROW_LAST;
			} else if (buf_line > table_separator_line) {
				row_type = TABLE_ROW_BODY;
			} else {
				/* Between header and separator — treat as header */
				row_type = TABLE_ROW_HEADER;
			}
		}

		if (row_type != TABLE_ROW_NONE) {
			if (table_col_count > 0) {
				/* Feature 2.2: Full table layout engine.
				 * Path A: Zig region detect fills widths/aligns; Zig padded row
				 * when gate+UTF-8; C fallback retained. */
				{
					int need = line_len > 0 ? line_len : 1;
					if (!viewmode_col_map || viewmode_col_map_size < need) {
						off_t *nm = (off_t *)joe_realloc(viewmode_col_map, (ptrdiff_t)need * (ptrdiff_t)sizeof(off_t));
						if (!nm) {
							if (viewmode_col_map) joe_free(viewmode_col_map);
							viewmode_col_map = NULL;
							viewmode_col_map_size = 0;
							viewmode_col_map_line = -1;
						} else {
							viewmode_col_map = nm;
							viewmode_col_map_size = need;
						}
					}
				}
				{
					int used_zig = 0;
					if (zig_bw_lgen_enabled
					    && bw->b && bw->b->o.charmap && bw->b->o.charmap->type) {
						int defatr = (bw->o.hiline && bw->cursor->line == y - bw->y + bw->top->line)
							? (bg_text & curlinmask) | bg_curlin
							: bg_text;
						int ncols = table_col_count;
						if (ncols > MAX_TABLE_COLS) ncols = MAX_TABLE_COLS;
						int z = zig_bw_table_row(t, y, screen, attr, x, w, line, line_len,
							ncols, table_col_width, table_col_align, (int)row_type,
							bw->b->o.charmap, BG_COLOR(defatr),
							t->palette, t->palette ? 256 : 0,
							viewmode_col_map, viewmode_col_map_size);
						if (z >= 0) {
							used_zig = 1;
							/* Match C render_padded_table_row: set map line after
							 * non-separator fill (separator returns before col_map). */
							if (row_type != TABLE_ROW_SEPARATOR
							    && viewmode_col_map
							    && viewmode_col_map_size >= (line_len > 0 ? line_len : 1))
								viewmode_col_map_line = bw->top->line + y - bw->y;
						}
					}
					if (!used_zig)
						render_padded_table_row(t, y, screen, attr, x, w, bw, line, line_len, row_type);
				}
				viewmode_table_rendered = 1;
				/* Skip rest of lgen_view — we rendered to screen directly */
				goto table_rendered;
			} else {
				/* Feature 2.1 residual: no column widths — simple pipe substitute.
				 * Path A: Zig applySimpleBorders; C fallback for separator-only. */
				int zok = 0;
				if (zig_bw_lgen_enabled && bw->b && bw->b->o.charmap && bw->b->o.charmap->type
				    && viewmode_substitute && viewmode_substitute_size >= line_len) {
					if (zig_bw_table_simple(line, line_len, (int)row_type,
						viewmode_substitute, viewmode_substitute_size) >= 0)
						zok = 1;
				}
				if (!zok) {
					/* Find pipe positions in this line */
					int pipe_positions[32];
					int pipe_count = 0;
					int ti;
					for (ti = 0; ti < line_len && pipe_count < 32; ti++) {
						if (line[ti] == '|')
							pipe_positions[pipe_count++] = ti;
					}

					if (pipe_count > 0) {
						switch (row_type) {
					case TABLE_ROW_SEPARATOR:
						/* Separator row: ├───┼───┤ */
						if (pipe_count == 1) {
							viewmode_substitute[pipe_positions[0]] = 0x251C; /* ├ */
						} else {
							viewmode_substitute[pipe_positions[0]] = 0x251C; /* ├ first */
							int pi;
							for (pi = 1; pi < pipe_count - 1; pi++)
								viewmode_substitute[pipe_positions[pi]] = 0x253C; /* ┼ middle */
							viewmode_substitute[pipe_positions[pipe_count - 1]] = 0x2524; /* ┤ last */
						}
						/* Replace dashes and colons (alignment indicators) with ─ */
						{
							int si;
							for (si = 0; si < line_len; si++) {
								if (line[si] == '-' || line[si] == ':') {
									viewmode_substitute[si] = 0x2500; /* ─ */
								}
							}
						}
						break;

						case TABLE_ROW_HEADER:
						case TABLE_ROW_BODY:
						case TABLE_ROW_LAST:
						default:
						case TABLE_ROW_NONE:
							break;
						}
					}
				}
			}
		}
	}

	/* Feature 1.9 fallback: Table highlighting (dim/bold) — only if box-drawing didn't apply */
	{
		off_t buf_line = bw->top->line + y - bw->y;
		int in_region = (buf_line >= table_region_start && buf_line < table_region_end);
		if (zig_bw_lgen_enabled &&
		    zig_bw_view_table_hl(line, line_len, attr_buf, attr_size, in_region) >= 0) {
			/* Zig Path A handled Feature 1.9 */
		} else if (!in_region) {
			/* Not in a detected table region — check if this single line looks like a table */
			int i = 0;
			while (i < line_len && (line[i] == ' ' || line[i] == '\t'))
				++i;
			int has_pipe = (i < line_len && line[i] == '|');
			if (has_pipe) {
				/* Check if this is a separator row */
				int is_separator = 1, has_dash = 0, j;
				for (j = 0; j < line_len; j++) {
					if (line[j] == '|' || line[j] == '-' || line[j] == ':' ||
					    line[j] == ' ' || line[j] == '\t') {
						if (line[j] == '-') has_dash = 1;
					} else {
						is_separator = 0;
						break;
					}
				}
				if (is_separator && has_dash) {
					for (j = 0; j < line_len && j < attr_size; j++)
						attr_buf[j] |= DIM;
				} else {
					int k;
					for (k = 0; k < line_len && k < attr_size; k++)
						attr_buf[k] |= BOLD;
				}
			}
		}
	}

	/* Path A: Zig inline view chrome (emphasis / code / links / col_map). */
	if (zig_bw_lgen_enabled) {
		int need = line_len > 0 ? line_len : 1;
		/* Ensure link URL array is sized */
		if (!viewmode_link_url || viewmode_link_url_size < need) {
			viewmode_free_link_urls();
			char **nl = (char **)joe_realloc(viewmode_link_url, (ptrdiff_t)need * (ptrdiff_t)sizeof(char *));
			if (!nl) {
				/* OOM — fall back to C */
			} else {
				viewmode_link_url = nl;
				if (viewmode_link_url_size < need) {
					memset(viewmode_link_url + viewmode_link_url_size, 0,
					       (size_t)(need - viewmode_link_url_size) * sizeof(char *));
				}
				viewmode_link_url_size = need;
			}
		} else {
			viewmode_free_link_urls();
			memset(viewmode_link_url, 0, (size_t)need * sizeof(char *));
		}
		/* Ensure column map is sized */
		if (!viewmode_col_map || viewmode_col_map_size < need) {
			off_t *nm = (off_t *)joe_realloc(viewmode_col_map, (ptrdiff_t)need * (ptrdiff_t)sizeof(off_t));
			if (nm) {
				viewmode_col_map = nm;
				viewmode_col_map_size = need;
			}
		}
		if (viewmode_link_url && viewmode_link_url_size >= need
		    && viewmode_col_map && viewmode_col_map_size >= need
		    && viewmode_hide && viewmode_hide_size >= need
		    && viewmode_substitute && viewmode_substitute_size >= need) {
			int tab = bw->o.tab;
			if (tab <= 0) tab = 8;
			if (zig_bw_view_inline(line, line_len,
				viewmode_hide, viewmode_hide_size,
				viewmode_substitute, viewmode_substitute_size,
				viewmode_link_url, viewmode_link_url_size,
				viewmode_col_map, viewmode_col_map_size,
				attr_buf, attr_size, tab) >= 0) {
				viewmode_col_map_line = bw->top->line + y - bw->y;
				goto done;
			}
		}
	}

	/* Feature 1.4: Bold/italic/strikethrough delimiters
	 * Uses DFA attribute info to identify delimiters vs content.
	 * Process code spans first so we skip emphasis inside them.
	 * Handles nested styles: **bold *italic* bold**
	 */

	char *in_code = NULL;
	/* Pass 1: Mark code span regions so we skip emphasis inside them */
	{
		in_code = (char *)joe_malloc(line_len > 0 ? line_len : 1);
		if (!in_code) {
			/* OOM — skip emphasis processing, delimiters remain visible */
			goto skip_emphasis;
		}
		if (line_len > 0)
			memset(in_code, 0, (size_t)line_len);
		int i = 0;
		while (i < line_len) {
			if (line[i] == '`') {
				int start = i;
				int bcnt = 0;
				while (i < line_len && line[i] == '`') {
					++bcnt;
					++i;
				}
				/* Find matching closing run of same backtick count */
				int found_close = 0;
				while (i <= line_len - bcnt) {
					if (line[i] == '`') {
						int k;
						for (k = 0; k < bcnt && i + k < line_len && line[i + k] == '`'; k++)
							;
						if (k == bcnt) {
							int j;
							for (j = start + bcnt; j < i; j++)
								in_code[j] = 1;
							i += bcnt;
							found_close = 1;
							break;
						}
					}
					++i;
				}
				if (!found_close)
					i = start + bcnt;
			} else {
				++i;
			}
		}

		/* Pass 2: Process emphasis, skipping code span content */
		{
			int j = 0;

			/* Skip over leading whitespace */
			while (j < line_len && (line[j] == ' ' || line[j] == '\t'))
				++j;
			/* Check for list marker: * - + followed by space */
			if (j < line_len &&
			    (line[j] == '*' || line[j] == '-' || line[j] == '+') &&
			    j + 1 < line_len && (line[j+1] == ' ' || line[j+1] == '\t')) {
				/* List marker — skip inline emphasis processing */
				goto skip_emphasis;
			}

			/* Process inline delimiters */
			while (j < line_len) {
				/* Skip code span content */
				if (in_code[j]) {
					++j;
					continue;
				}

				if (line[j] == '*' && j + 2 < line_len && line[j+1] == '*' && line[j+2] == '*') {
					/* *** bold+italic */
					viewmode_hide[j] = 1;
					viewmode_hide[j+1] = 1;
					viewmode_hide[j+2] = 1;
					j += 3;
					while (j < line_len) {
						if (in_code[j]) { ++j; continue; }
						if (line[j] == '*' && j + 2 < line_len && line[j+1] == '*' && line[j+2] == '*') {
							viewmode_hide[j] = 1;
							viewmode_hide[j+1] = 1;
							viewmode_hide[j+2] = 1;
							j += 3;
							break;
						}
						++j;
					}
				} else if (line[j] == '*' && j + 1 < line_len && line[j+1] == '*') {
					/* ** bold */
					viewmode_hide[j] = 1;
					viewmode_hide[j+1] = 1;
					j += 2;
					while (j < line_len) {
						if (in_code[j]) { ++j; continue; }
						if (line[j] == '*' && j + 1 < line_len && line[j+1] == '*') {
							viewmode_hide[j] = 1;
							viewmode_hide[j+1] = 1;
							j += 2;
							break;
						}
						++j;
					}
				} else if (line[j] == '_' && j + 2 < line_len && line[j+1] == '_' && line[j+2] == '_') {
					/* ___ bold+italic */
					viewmode_hide[j] = 1;
					viewmode_hide[j+1] = 1;
					viewmode_hide[j+2] = 1;
					j += 3;
					while (j < line_len) {
						if (in_code[j]) { ++j; continue; }
						if (line[j] == '_' && j + 2 < line_len && line[j+1] == '_' && line[j+2] == '_') {
							viewmode_hide[j] = 1;
							viewmode_hide[j+1] = 1;
							viewmode_hide[j+2] = 1;
							j += 3;
							break;
						}
						++j;
					}
				} else if (line[j] == '_' && j + 1 < line_len && line[j+1] == '_') {
					/* __ bold */
					viewmode_hide[j] = 1;
					viewmode_hide[j+1] = 1;
					j += 2;
					while (j < line_len) {
						if (in_code[j]) { ++j; continue; }
						if (line[j] == '_' && j + 1 < line_len && line[j+1] == '_') {
							viewmode_hide[j] = 1;
							viewmode_hide[j+1] = 1;
							j += 2;
							break;
						}
						++j;
					}
				} else if (line[j] == '~' && j + 1 < line_len && line[j+1] == '~') {
					/* ~~ strikethrough */
					viewmode_hide[j] = 1;
					viewmode_hide[j+1] = 1;
					j += 2;
					while (j < line_len) {
						if (in_code[j]) { ++j; continue; }
						if (line[j] == '~' && j + 1 < line_len && line[j+1] == '~') {
							viewmode_hide[j] = 1;
							viewmode_hide[j+1] = 1;
							j += 2;
							break;
						}
						++j;
					}
			} else if (line[j] == '*' || line[j] == '_') {
				char delim = (char)line[j];
				/* Skip if part of a longer run (handled by bold/bold+italic arms) */
				if (j + 1 < line_len && line[j + 1] == delim) {
					++j;
					continue;
				}
				/* Single * or _ for italic */
				viewmode_hide[j] = 1;
				++j;
				while (j < line_len) {
					if (in_code[j]) { ++j; continue; }
					if (line[j] == delim) {
						/* If closing delimiter is part of a longer run
						 * (e.g. part of star-star), break so the outer
						 * loop processes remaining delimiter chars */
						if (j + 1 < line_len && line[j + 1] == delim)
							break;
						viewmode_hide[j] = 1;
						++j;
						break;
					}
					++j;
				}
				} else {
					++j;
				}
			}
		}
	}
skip_emphasis:
	if (in_code)
		joe_free(in_code);

	/* Feature 1.5: Inline code backticks — hide matching runs */
	{
		int i = 0;
		while (i < line_len) {
			if (line[i] == '`') {
				int start = i;
				int bcnt = 0;
				while (i < line_len && line[i] == '`') {
					++bcnt;
					++i;
				}
				/* Find matching closing run of same backtick count */
				int found_close = 0;
				while (i <= line_len - bcnt) {
					if (line[i] == '`') {
						int k;
						for (k = 0; k < bcnt && i + k < line_len && line[i + k] == '`'; k++)
							;
						if (k == bcnt) {
							int j;
							for (j = start; j < start + bcnt; j++)
								viewmode_hide[j] = 1;
							for (j = i; j < i + bcnt; j++)
								viewmode_hide[j] = 1;
							i += bcnt;
							found_close = 1;
							break;
						}
					}
					++i;
				}
				if (!found_close)
					i = start + bcnt;
			} else {
				++i;
			}
		}
	}

	/* Feature 1.6: Link delimiters [text](url) — hide brackets and parens
	 * 1.6.2: Store URL for OSC 8 hyperlinks
	 * 1.6.3: Apply underline + blue to link text via attr_buf modification
	 */
	{
		int i = 0;
		while (i < line_len) {
			if (line[i] == '[') {
				int j = i + 1;
				while (j < line_len && line[j] != ']') ++j;
				if (j < line_len && j + 1 < line_len && line[j+1] == '(') {
					int k = j + 2;
					while (k < line_len && line[k] != ')') ++k;
					if (k < line_len) {
						viewmode_hide[i] = 1;    /* [ */
						viewmode_hide[j] = 1;   /* ] */
						viewmode_hide[j+1] = 1; /* ( */
						viewmode_hide[k] = 1;   /* ) */

						/* Extract URL for OSC 8 */
						int url_len = k - (j + 2);
						if (url_len > 0) {
							char *url = (char *)joe_malloc(url_len + 1);
							if (!url) {
								i = k + 1;
								continue;
							}
							memcpy(url, line + j + 2, (size_t)url_len);
							url[url_len] = '\0';

							/* Ensure link URL array is sized */
							if (!viewmode_link_url || viewmode_link_url_size < line_len) {
								viewmode_free_link_urls();
								char **nl = (char **)joe_realloc(viewmode_link_url, (ptrdiff_t)line_len * (ptrdiff_t)sizeof(char *));
								viewmode_link_url = nl;
								/* Ensure newly grown region is NULLed. */
								if (viewmode_link_url_size < line_len) {
									memset(viewmode_link_url + viewmode_link_url_size, 0,
									       (size_t)(line_len - viewmode_link_url_size) * sizeof(char *));
								}
								viewmode_link_url_size = line_len;
							}

							/* Store URL for each link text character */
							int lp2;
							for (lp2 = i + 1; lp2 < j; lp2++)
								viewmode_link_url[lp2] = url;

							/* 1.6.3: Add underline + blue to link text in attr_buf */
							int lp;
							for (lp = i + 1; lp < j && lp < line_len && lp < attr_size; lp++) {
								attr_buf[lp] |= UNDERLINE;
								/* Set blue foreground if no fg color set */
								if (!(attr_buf[lp] & FG_MASK))
									attr_buf[lp] |= FG_BLUE;
							}
						}

						i = k + 1;
						continue;
					}
				}
				/* Reference-style link: [text][ref] */
				if (j < line_len && j + 1 < line_len && line[j+1] == '[') {
					int k = j + 2;
					while (k < line_len && line[k] != ']') ++k;
					if (k < line_len) {
						viewmode_hide[i] = 1;    /* [ */
						viewmode_hide[j] = 1;   /* ] */
						viewmode_hide[j+1] = 1; /* [ */
						viewmode_hide[k] = 1;   /* ] */

						/* Ensure link URL array is sized */
						if (!viewmode_link_url || viewmode_link_url_size < line_len) {
							viewmode_free_link_urls();
							char **nl = (char **)joe_realloc(viewmode_link_url, (ptrdiff_t)line_len * (ptrdiff_t)sizeof(char *));
							viewmode_link_url = nl;
							if (viewmode_link_url_size < line_len) {
								memset(viewmode_link_url + viewmode_link_url_size, 0,
								       (size_t)(line_len - viewmode_link_url_size) * sizeof(char *));
							}
							viewmode_link_url_size = line_len;
						}

						/* Store ref as URL for OSC 8 (will be resolved later) */
						int ref_len = k - (j + 2);
						if (ref_len > 0) {
							char *ref = (char *)joe_malloc(ref_len + 1);
							if (ref) {
								memcpy(ref, line + j + 2, (size_t)ref_len);
								ref[ref_len] = '\0';
								int lp2;
								for (lp2 = i + 1; lp2 < j; lp2++)
									viewmode_link_url[lp2] = ref;
							}
						}

						/* 1.6.3: Add underline + blue to link text in attr_buf */
						int lp;
						for (lp = i + 1; lp < j && lp < line_len && lp < attr_size; lp++) {
							attr_buf[lp] |= UNDERLINE;
							if (!(attr_buf[lp] & FG_MASK))
								attr_buf[lp] |= FG_BLUE;
						}

						i = k + 1;
						continue;
					}
				}
			}
			++i;
		}
	}

		/* Feature 1.10: Build column mapping for cursor position
		 * Maps buffer byte offset (relative to BOL) to display column.
		 * Accounts for hidden delimiters and Unicode substitutions. */
		{
		/* Ensure column map is the right size */
			if (!viewmode_col_map || viewmode_col_map_size < (line_len > 0 ? line_len : 1)) {
				int need = line_len > 0 ? line_len : 1;
				off_t *nm = (off_t *)joe_realloc(viewmode_col_map, (ptrdiff_t)need * (ptrdiff_t)sizeof(off_t));
				viewmode_col_map = nm;
				viewmode_col_map_size = need;
			}

		/* Build the mapping: for each buffer byte, compute display column */
		off_t display_col = 0;
		int i;
		for (i = 0; i < line_len; i++) {
			viewmode_col_map[i] = display_col;
			if (viewmode_hide && i < viewmode_hide_size && viewmode_hide[i]) {
				/* Hidden character — don't advance display column */
				continue;
			}
			if (viewmode_substitute && i < viewmode_substitute_size && viewmode_substitute[i]) {
				/* Substituted character — use substituted character's width */
				int sub = viewmode_substitute[i];
				{ int cw = joe_wcwidth(1, sub); display_col += (cw > 0) ? cw : 0; }
			} else {
				/* Normal character — use original character's width */
				if (line[i] == '\t')
					display_col += bw->b->o.tab - display_col % bw->b->o.tab;
				else
					{ int cw = joe_wcwidth(1, line[i]); display_col += (cw > 0) ? cw : 0; }
			}
		}
		/* Record which buffer line this map is for */
		viewmode_col_map_line = bw->top->line + y - bw->y;
	}

done:
table_rendered:
	/* Feature 1.10: ensure col_map + update cursor xcol (shared done/table paths). */
	{
		off_t buf_line = bw->top->line + y - bw->y;
		int zig_ok = 0;
		if (zig_bw_lgen_enabled) {
			int need = line_len > 0 ? line_len : 1;
			if (!viewmode_col_map || viewmode_col_map_size < need) {
				off_t *nm = (off_t *)joe_realloc(viewmode_col_map, (ptrdiff_t)need * (ptrdiff_t)sizeof(off_t));
				if (!nm) {
					if (viewmode_col_map) joe_free(viewmode_col_map);
					viewmode_col_map = NULL;
					viewmode_col_map_size = 0;
					viewmode_col_map_line = -1;
				} else {
					viewmode_col_map = nm;
					viewmode_col_map_size = need;
				}
			}
			if (viewmode_col_map && viewmode_col_map_size >= need
			    && viewmode_hide && viewmode_hide_size >= need
			    && viewmode_substitute && viewmode_substitute_size >= need) {
				int tab = bw->o.tab;
				if (tab <= 0) tab = 8;
				int skip_hidden = viewmode_table_rendered ? 0 : 1;
				if (zig_bw_view_finish(line, line_len,
					viewmode_hide, viewmode_hide_size,
					viewmode_substitute, viewmode_substitute_size,
					viewmode_col_map, viewmode_col_map_size,
					&viewmode_col_map_line, buf_line, tab,
					bw->cursor, skip_hidden) >= 0)
					zig_ok = 1;
			}
		}
		if (!zig_ok) {
			/* Ensure we always have a valid map for this line. */
			if (viewmode_col_map_line != buf_line) {
				if (!viewmode_col_map || viewmode_col_map_size < (line_len > 0 ? line_len : 1)) {
					int need = line_len > 0 ? line_len : 1;
					off_t *nm = (off_t *)joe_realloc(viewmode_col_map, (ptrdiff_t)need * (ptrdiff_t)sizeof(off_t));
					if (!nm) {
						if (viewmode_col_map) joe_free(viewmode_col_map);
						viewmode_col_map = NULL;
						viewmode_col_map_size = 0;
						viewmode_col_map_line = -1;
					} else {
						viewmode_col_map = nm;
						viewmode_col_map_size = need;
					}
				}
				if (viewmode_col_map && viewmode_col_map_size >= (line_len > 0 ? line_len : 1)) {
					off_t display_col = 0;
					int i;
					for (i = 0; i < line_len; i++) {
						viewmode_col_map[i] = display_col;
						if (viewmode_hide && i < viewmode_hide_size && viewmode_hide[i])
							continue;
						if (viewmode_substitute && i < viewmode_substitute_size && viewmode_substitute[i]) {
							int sub = viewmode_substitute[i];
							{ int cw = joe_wcwidth(1, sub); display_col += (cw > 0) ? cw : 0; }
						} else {
							if (line[i] == '\t')
								display_col += bw->b->o.tab - display_col % bw->b->o.tab;
							else
								{ int cw = joe_wcwidth(1, line[i]); display_col += (cw > 0) ? cw : 0; }
						}
					}
					viewmode_col_map_line = buf_line;
				}
			}

			/* Feature 1.10/2.2.7: Update cursor position for view mode. */
			if (bw->cursor->line == buf_line && viewmode_col_map &&
			    viewmode_col_map_size > 0 && viewmode_col_map_line == buf_line) {
				P *cur_tmp = pdup(bw->cursor, "viewmode_cursor");
				p_goto_bol(cur_tmp);
				off_t cursor_offset = bw->cursor->byte - cur_tmp->byte;
				prm(cur_tmp);
				if (!viewmode_table_rendered) {
					if (cursor_offset >= 0 && cursor_offset < viewmode_hide_size &&
					    viewmode_hide && viewmode_hide[cursor_offset]) {
						off_t next_visible = cursor_offset + 1;
						while (next_visible < viewmode_hide_size && viewmode_hide[next_visible])
							++next_visible;
						if (next_visible < viewmode_hide_size) {
							P *move_tmp = pdup(bw->cursor, "viewmode_skip_hidden");
							p_goto_bol(move_tmp);
							off_t target_byte = move_tmp->byte + next_visible;
							pgoto(bw->cursor, target_byte);
							cursor_offset = next_visible;
							prm(move_tmp);
						}
					}
				}
				if (cursor_offset >= 0 && cursor_offset < viewmode_col_map_size) {
					off_t new_xcol = viewmode_col_map[cursor_offset];
					bw->cursor->xcol = new_xcol;
					bw->cursor->valcol = 1;
				}
			}
		}
	}
paint_and_cleanup:
	joe_free(line);

	int result = 0;
	if (viewmode_table_rendered) {
		pnextl(p);
	} else {
		viewmode_skip_parse = 1;
		result = lgen_core(t, y, screen, attr, x, w, p, scr, from, to, st, bw);
		viewmode_skip_parse = 0;
	}

	/* Clear hide map for next line */
	if (viewmode_hide)
		memset(viewmode_hide, 0, (size_t)(line_len > 0 ? line_len : 1));

	/* Clear substitution map for next line */
	if (viewmode_substitute)
		memset(viewmode_substitute, 0, (size_t)(line_len > 0 ? line_len : 1) * sizeof(int));

	/* Free link URL strings for next line (keep array allocated) */
	viewmode_free_link_urls();

	viewmode_table_rendered = 0;
	return result;
}
static void gennum(BW *w, int (*screen)[COMPOSE], int *attr, SCRN *t, ptrdiff_t y, int *comp)
{
	char buf[24];
	ptrdiff_t z, x;
	off_t lin = w->top->line + y - w->y;
	int atr = (w->o.hiline && lin == w->cursor->line) ? bg_curlinum : bg_linum;

	/* Path A: Zig-native line-number gutter (JOE_ZIG_BW_LGEN). */
	if (zig_bw_lgen_enabled && w->lincols > 0) {
		int have_number = (lin <= w->b->eof->line);
		off_t line_1based = have_number ? (lin + 1) : 0;
		int zret = zig_bw_gennum(t, y, screen, attr, comp, w->lincols,
			have_number, line_1based, BG_COLOR(atr),
			w->b && w->b->o.charmap ? w->b->o.charmap : NULL);
		if (zret >= 0)
			return;
	}

	if (lin <= w->b->eof->line)
#ifdef HAVE_LONG_LONG
		joe_snprintf_1(buf, SIZEOF(buf), " %21lld ", (long long)(w->top->line + y - w->y + 1));
#else
		joe_snprintf_1(buf, SIZEOF(buf), " %21ld ", (long)(w->top->line + y - w->y + 1));
#endif
	else {
		for (x = 0; x != SIZEOF(buf) - 1; ++x)
			buf[x] = ' ';
		buf[x] = 0;
	}
	for (z = SIZEOF(buf) - w->lincols - 1, x = 0; buf[z]; ++z, ++x) {
		outatr(w->b->o.charmap, t, screen + x, attr + x, x, y, buf[z], BG_COLOR(atr));
		comp[x] = buf[z];
	}
	outatr_complete(t);
}

void bwgenh(BW *w)
{
	int (*screen)[COMPOSE];
	int *attr;
	P *q = pdup(w->top, "bwgenh");
	ptrdiff_t bot = w->h + w->y;
	ptrdiff_t y;
	SCRN *t = w->t->t;
	int flg = 0;
	off_t from;
	off_t to;
	int dosquare = 0;

	from = to = 0;

	if (markv(0) && markk->b == w->b)
		if (square) {
			from = markb->xcol;
			to = markk->xcol;
			dosquare = 1;
		} else {
			from = markb->byte;
			to = markk->byte;
		}
	else if (marking && w == (BW *)maint->curwin->object && markb && markb->b == w->b && w->cursor->byte != markb->byte && !from) {
		if (square) {
			from = off_min(w->cursor->xcol, markb->xcol);
			to = off_max(w->cursor->xcol, markb->xcol);
			dosquare = 1;
		} else {
			from = off_min(w->cursor->byte, markb->byte);
			to = off_max(w->cursor->byte, markb->byte);
		}
	}

	if (marking && w == (BW *)maint->curwin->object)
		msetI(t->updtab + w->y, 1, w->h);

	if (dosquare) {
		from = 0;
		to = 0;
	}

	/* Path A: Zig-native hex dump paint (JOE_ZIG_BW_LGEN). */
	if (zig_bw_lgen_enabled) {
		int zret = zig_bw_bwgenh(t, t->scrn, t->attr, w->t->w, w->y, w->h, w->w,
			w->offset, w->top, w->cursor->byte, w->o.hiline,
			from, to, BG_COLOR(bg_text), BG_COLOR(bg_linum),
			BG_COLOR(bg_curlinum), BG_COLOR(bg_cursor));
		if (zret >= 0) {
			prm(q);
			return;
		}
	}

	y=w->y;
	attr = t->attr + y*w->t->w;
	for (screen = t->scrn + y * w->t->w; y != bot; ++y, (screen += w->t->w), (attr += w->t->w)) {
		char txt[80];
		int fmt[80];
		char bf[16];
		int x;
		memset(txt,' ',76);
		msetI(fmt,BG_COLOR(bg_text),76);
		txt[76]=0;
		if (w->o.hiline && (q->byte & ~15) == (w->cursor->byte & ~15)) {
			msetI(fmt,BG_COLOR(bg_curlinum),9);
		} else {
			msetI(fmt,BG_COLOR(bg_linum),9);
		}
		if (!flg) {
#if HAVE_LONG_LONG
			snprintf(bf,sizeof(bf),"%8llx ",(unsigned long long)q->byte);
#else
			snprintf(bf,sizeof(bf),"%8lx ",(unsigned long)q->byte);
#endif
			memcpy(txt,bf,9);
			for (x=0; x!=8; ++x) {
				int c;
				if (q->byte==w->cursor->byte && !flg) {
					fmt[10+x*3] = BG_COLOR(bg_cursor);
					fmt[10+x*3+1] = BG_COLOR(bg_cursor);
				}
				if (q->byte>=from && q->byte<to && !flg) {
					fmt[10+x*3] |= UNDERLINE;
					fmt[10+x*3+1] |= UNDERLINE;
					fmt[60+x] |= INVERSE;
				}
				c = pgetb(q);
				if (c != NO_MORE_DATA) {
					snprintf(bf,sizeof(bf),"%2.2x",c);
					txt[10+x*3] = bf[0];
					txt[10+x*3+1] = bf[1];
					if (c >= 0x20 && c <= 0x7E)
						txt[60+x] = TO_CHAR_OK(c);
					else
						txt[60+x] = '.';
				} else
					flg = 1;
			}
			for (x=8; x!=16; ++x) {
				int c;
				if (q->byte==w->cursor->byte && !flg) {
					fmt[11+x*3] = BG_COLOR(bg_cursor);
					fmt[11+x*3+1] = BG_COLOR(bg_cursor);
				}
				if (q->byte>=from && q->byte<to && !flg) {
					fmt[11+x*3] |= UNDERLINE;
					fmt[11+x*3+1] |= UNDERLINE;
					fmt[60+x] |= INVERSE;
				}
				c = pgetb(q);
				if (c != NO_MORE_DATA) {
					snprintf(bf,sizeof(bf),"%2.2x",c);
					txt[11+x*3] = bf[0];
					txt[11+x*3+1] = bf[1];
					if (c >= 0x20 && c <= 0x7E)
						txt[60+x] = TO_CHAR_OK(c);
					else
						txt[60+x] = '.';
				} else
					flg = 1;
			}
		}
		genfield(t, screen, attr, 0, y, TO_DIFF_OK(w->offset), txt, 76, BG_COLOR(bg_text), w->w, 1, fmt);
	}
	prm(q);
}

/* C helpers for Zig Path A `zig_bw_bwgen` / `zig_bw_bwgenh` / follow. */
off_t zig_c_bw_pbyte(P *p)
{
	return p ? p->byte : 0;
}

off_t zig_c_bw_pline_no(P *p)
{
	return p ? p->line : -1;
}

off_t zig_c_bw_pxcol(P *p)
{
	return p ? p->xcol : 0;
}

void zig_c_bw_set_xcol(P *p, off_t xcol)
{
	if (!p) return;
	p->xcol = xcol;
	p->valcol = 1;
}

P *zig_c_bw_bof(P *p)
{
	return (p && p->b) ? p->b->bof : NULL;
}

int zig_c_bw_pisbol(P *p)
{
	return p ? pisbol(p) : 1;
}

void zig_c_bw_p_goto_bol(P *p)
{
	if (p)
		p_goto_bol(p);
}

void zig_c_bw_pset(P *d, P *s)
{
	if (d && s)
		pset(d, s);
}

void zig_c_bw_pline(P *p, off_t line)
{
	if (p)
		pline(p, line);
}

void zig_c_bw_pgoto(P *p, off_t loc)
{
	if (p)
		pgoto(p, loc);
}

void zig_c_bw_pbkwd(P *p, off_t n)
{
	if (p)
		pbkwd(p, n);
}

void zig_c_bw_nscrldn(SCRN *t, ptrdiff_t top, ptrdiff_t bot, ptrdiff_t amnt)
{
	nscrldn(t, top, bot, amnt);
}

void zig_c_bw_nscrlup(SCRN *t, ptrdiff_t top, ptrdiff_t bot, ptrdiff_t amnt)
{
	nscrlup(t, top, bot, amnt);
}

void zig_c_bw_msetI(int *dest, int c, ptrdiff_t sz)
{
	msetI(dest, c, sz);
}

off_t zig_c_bw_eof_line(P *p)
{
	return (p && p->b && p->b->eof) ? p->b->eof->line : -1;
}

/* Read line `line` (no newline) into buf. Returns len, -2 if too long, -1 on error. */
int zig_c_bw_read_line(P *anchor, off_t line, unsigned char *buf, int buf_cap)
{
	P *tmp;
	int ll = 0;
	int ch;

	if (!anchor || !anchor->b || !buf || buf_cap <= 0 || line < 0)
		return -1;
	if (!anchor->b->eof || line > anchor->b->eof->line)
		return -1;

	tmp = pdup(anchor, "zig_c_bw_read_line");
	if (!tmp)
		return -1;
	pline(tmp, line);
	p_goto_bol(tmp);
	while ((ch = pgetb(tmp)) != NO_MORE_DATA && ch != '\n') {
		if (ll >= VIEWMODE_TABLE_SCAN_MAX_BYTES || ll >= buf_cap) {
			prm(tmp);
			return -2;
		}
		buf[ll++] = (unsigned char)ch;
	}
	prm(tmp);
	return ll;
}

P *zig_c_bw_getto(P *p, P *cur, P *top, off_t line)
{
	return getto(p, cur, top, line);
}

int zig_c_bw_lgen(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr,
	ptrdiff_t x, ptrdiff_t w, P *p, off_t scr, off_t from, off_t to,
	HIGHLIGHT_STATE st, BW *bw)
{
	return lgen(t, y, screen, attr, x, w, p, scr, from, to, st, bw);
}

void zig_c_bw_gennum(BW *w, int (*screen)[COMPOSE], int *attr, SCRN *t,
	ptrdiff_t y, int *comp)
{
	gennum(w, screen, attr, t, y, comp);
}

HIGHLIGHT_STATE zig_c_bw_get_highlight_state(BW *w, P *p, off_t line)
{
	return get_highlight_state(w, p, line);
}

void bwgen(BW *w, int linums, int linchg)
{
	int (*screen)[COMPOSE];
	int *attr;
	P *p = NULL;
	P *q;
	ptrdiff_t bot = w->h + w->y;
	ptrdiff_t y;
	int dosquare = 0;
	off_t from, to;
	off_t fromline, toline;
	SCRN *t = w->t->t;

	/* Set w.db to correct value */
	if (w->o.highlight && w->o.syntax && (!w->db || w->db->syn != w->o.syntax))
		w->db = find_lattr_db(w->b, w->o.syntax);

	/* Feature 1.1/1.4: Invalidate screen buffer when viewmode toggles.
	 * Hidden delimiters shift content left, so the new render can land on
	 * positions where the old buffer already has the same character.
	 * Without invalidation, outatr() skips those writes, leaving ghost text.
	 * scrn_invalidate() only touches memory — no terminal I/O, safe during popups. */
	if (w->o.viewmode != w->last_viewmode) {
		scrn_invalidate(w->t->t);
		w->last_viewmode = w->o.viewmode;
	}

	fromline = toline = from = to = 0;

	if (w->b == errbuf && w->b->err) {
		P *tmp = pdup(w->b->err, "bwgen");
		p_goto_bol(tmp);
		from = tmp->byte;
		pnextl(tmp);
		to = tmp->byte;
		prm(tmp);
	} else if (markv(0) && markk->b == w->b)
		if (square) {
			from = markb->xcol;
			to = markk->xcol;
			dosquare = 1;
			fromline = markb->line;
			toline = markk->line;
		} else {
			from = markb->byte;
			to = markk->byte;
		}
	else if (marking && w == (BW *)maint->curwin->object && markb && markb->b == w->b && w->cursor->byte != markb->byte && !from) {
		if (square) {
			from = off_min(w->cursor->xcol, markb->xcol);
			to = off_max(w->cursor->xcol, markb->xcol);
			fromline = off_min(w->cursor->line, markb->line);
			toline = off_max(w->cursor->line, markb->line);
			dosquare = 1;
		} else {
			from = off_min(w->cursor->byte, markb->byte);
			to = off_max(w->cursor->byte, markb->byte);
		}
	}

	if (marking && w == (BW *)maint->curwin->object)
		msetI(t->updtab + w->y, 1, w->h);

	/* Path A: Zig-native bwgen paint loops (JOE_ZIG_BW_LGEN). */
	if (zig_bw_lgen_enabled) {
		ptrdiff_t mid = TO_DIFF_OK(w->cursor->line - w->top->line) + w->y;
		int zret = zig_bw_bwgen(w, t, t->scrn, t->attr, t->updtab, t->compose,
			w->t->w, w->x, w->y, w->w, w->h, mid,
			w->top, w->cursor, w->top->line, w->offset,
			linums, linchg, dosquare, from, to, fromline, toline);
		if (zret >= 0)
			goto bwgen_viewmode_cursor;
	}

	q = pdup(w->cursor, "bwgen");

	y = TO_DIFF_OK(w->cursor->line - w->top->line) + w->y;
	attr = t->attr + y*w->t->w;
	for (screen = t->scrn + y * w->t->w; y != bot; ++y, (screen += w->t->w), (attr += w->t->w)) {
		if (ifhave)
			break;
		if (linums)
			gennum(w, screen, attr, t, y, t->compose);
		if (linchg || t->updtab[y]) {
			p = getto(p, w->cursor, w->top, w->top->line + y - w->y);
/*			if (t->insdel && !w->x) {
				pset(q, p);
				if (dosquare)
					if (w->top->line + y - w->y >= fromline && w->top->line + y - w->y <= toline)
						lgena(t, y, t->compose, w->x, w->x + w->w, q, w->offset, from, to);
					else
						lgena(t, y, t->compose, w->x, w->x + w->w, q, w->offset, 0L, 0L);
				else
					lgena(t, y, t->compose, w->x, w->x + w->w, q, w->offset, from, to);
				magic(t, y, screen, attr, t->compose, (int) (w->cursor->xcol - w->offset + w->x));
			} */
			if (dosquare)
				if (w->top->line + y - w->y >= fromline && w->top->line + y - w->y <= toline)
					t->updtab[y] = lgen(t, y, screen, attr, w->x, w->x + w->w, p, w->offset, from, to, get_highlight_state(w,p,w->top->line+y-w->y),w);
				else
					t->updtab[y] = lgen(t, y, screen, attr, w->x, w->x + w->w, p, w->offset, 0L, 0L, get_highlight_state(w,p,w->top->line+y-w->y),w);
			else
				t->updtab[y] = lgen(t, y, screen, attr, w->x, w->x + w->w, p, w->offset, from, to, get_highlight_state(w,p,w->top->line+y-w->y),w);
		}
	}

	y = w->y;
	attr = t->attr + w->y * w->t->w;
	for (screen = t->scrn + w->y * w->t->w; y != w->y + w->cursor->line - w->top->line; ++y, (screen += w->t->w), (attr += w->t->w)) {
		if (ifhave)
			break;
		if (linums)
			gennum(w, screen, attr, t, y, t->compose);
		if (linchg || t->updtab[y]) {
			p = getto(p, w->cursor, w->top, w->top->line + y - w->y);
/*			if (t->insdel && !w->x) {
				pset(q, p);
				if (dosquare)
					if (w->top->line + y - w->y >= fromline && w->top->line + y - w->y <= toline)
						lgena(t, y, t->compose, w->x, w->x + w->w, q, w->offset, from, to);
					else
						lgena(t, y, t->compose, w->x, w->x + w->w, q, w->offset, 0L, 0L);
				else
					lgena(t, y, t->compose, w->x, w->x + w->w, q, w->offset, from, to);
				magic(t, y, screen, attr, t->compose, (int) (w->cursor->xcol - w->offset + w->x));
			} */
			if (dosquare)
				if (w->top->line + y - w->y >= fromline && w->top->line + y - w->y <= toline)
					t->updtab[y] = lgen(t, y, screen, attr, w->x, w->x + w->w, p, w->offset, from, to, get_highlight_state(w,p,w->top->line+y-w->y),w);
				else
					t->updtab[y] = lgen(t, y, screen, attr, w->x, w->x + w->w, p, w->offset, 0L, 0L, get_highlight_state(w,p,w->top->line+y-w->y),w);
			else
				t->updtab[y] = lgen(t, y, screen, attr, w->x, w->x + w->w, p, w->offset, from, to, get_highlight_state(w,p,w->top->line+y-w->y),w);
		}
	}
	prm(q);
	if (p)
		prm(p);

bwgen_viewmode_cursor:
	/* Feature 1.10: Update cursor position for view mode after rendering */
	if (w->o.viewmode && viewmode_col_map && viewmode_col_map_size > 0) {
		off_t buf_line = w->cursor->line;
		if (viewmode_col_map_line == buf_line) {
			/* Compute buffer byte offset relative to BOL */
			P *cur_tmp = pdup(w->cursor, "bwgen_cursor");
			p_goto_bol(cur_tmp);
			off_t cursor_offset = w->cursor->byte - cur_tmp->byte;
			prm(cur_tmp);

			/* Look up display column from map */
			if (cursor_offset >= 0 && cursor_offset < viewmode_col_map_size) {
				w->cursor->xcol = viewmode_col_map[cursor_offset];
				w->cursor->valcol = 1;
			}
		}
	}
}

void bwmove(BW *w, ptrdiff_t x, ptrdiff_t y)
{
	w->x = x;
	w->y = y;
}

void bwresz(BW *w, ptrdiff_t wi, ptrdiff_t he)
{
	if (he > w->h && w->y != -1) {
		msetI(w->t->t->updtab + w->y + w->h, 1, he - w->h);
	}
	w->w = wi;
	w->h = he;
	if (w->b->vt && w->b->pid && w == vtmaster(w->parent->t, w->b)) {
		vt_resize(w->b->vt, w->top, he, wi);
		ttstsz(w->b->out, wi, he);
	}
}

BW *bwmk(W *window, B *b, int prompt)
{
	BW *w = (BW *) joe_malloc(SIZEOF(BW));

	w->parent = window;
	w->b = b;
	if (prompt || (!window->y && staen) || window->h < 2) {
		w->y = window->y;
		w->h = window->h;
	} else {
		w->y = window->y + 1;
		w->h = window->h - 1;
	}
	if (b->oldcur) {
		w->top = b->oldtop;
		b->oldtop = NULL;
		w->top->owner = NULL;
		w->cursor = b->oldcur;
		b->oldcur = NULL;
		w->cursor->owner = NULL;
	} else {
		w->top = pdup(b->bof, "bwmk");
		w->cursor = pdup(b->bof, "bwmk");
	}
	w->t = window->t;
	w->object = NULL;
	w->offset = 0;
	w->o = w->b->o;
	w->lincols = 0;
	w->curlin = 0;
	w->x = window->x;
	w->w = window->w;
	if (window == window->main) {
		rmkbd(window->kbd);
		window->kbd = mkkbd(kmap_getcontext(w->o.context));
	}
	w->top->xcol = 0;
	w->cursor->xcol = 0;
	w->top_changed = 1;
	w->db = 0;
	w->shell_flag = 0;
	w->pasting = 0;
	w->last_viewmode = 0;
	return w;
}

/* Database of last file positions */

#define MAX_FILE_POS 20 /* Maximum number of file positions we track */

static struct file_pos {
	LINK(struct file_pos) link;
	char *name;
	off_t line;
} file_pos = { { &file_pos, &file_pos }, NULL, 0 };

static int file_pos_count;

static struct file_pos *find_file_pos(const char *name)
{
	struct file_pos *p;
	for (p = file_pos.link.next; p != &file_pos; p = p->link.next)
		if (!zcmp(p->name, name)) {
			promote(struct file_pos,link,&file_pos,p);
			return p;
		}
	p = (struct file_pos *)malloc(SIZEOF(struct file_pos));
	p->name = zdup(name);
	p->line = 0;
	enquef(struct file_pos,link,&file_pos,p);
	if (++file_pos_count == MAX_FILE_POS) {
		free(deque_f(struct file_pos,link,file_pos.link.prev));
		--file_pos_count;
	}
	return p;
}

int restore_file_pos;

off_t get_file_pos(const char *name)
{
	if (name && restore_file_pos) {
		struct file_pos *p = find_file_pos(name);
		return p->line;
	} else {
		return 0;
	}
}

void set_file_pos(const char *name, off_t pos)
{
	if (name) {
		struct file_pos *p = find_file_pos(name);
		p->line = pos;
	}
}

void save_file_pos(FILE *f)
{
	struct file_pos *p;
	for (p = file_pos.link.prev; p != &file_pos; p = p->link.prev) {
#ifdef HAVE_LONG_LONG
		fprintf(f,"	%lld ",(long long)p->line);
#else
		fprintf(f,"	%ld ",(long)p->line);
#endif
		emit_string(f,p->name,zlen(p->name));
		fprintf(f,"\n");
	}
	fprintf(f,"done\n");
}

void load_file_pos(FILE *f)
{
	char buf[1024];
	while (fgets(buf,SIZEOF(buf)-1,f) && zcmp(buf,"done\n")) {
		const char *p = buf;
		off_t pos;
		char name[1024];
		parse_ws(&p,'#');
		if (!parse_off_t(&p, &pos)) {
			parse_ws(&p, '#');
			if (parse_string(&p, name, SIZEOF(name)) > 0) {
				set_file_pos(name, pos);
			}
		}
	}
}

/* Save file position for all windows */

void set_file_pos_all(Screen *t)
{
	/* Step through all windows */
	W *w = t->topwin;
	do {
		if (w->watom == &watomtw) {
			BW *bw = (BW *)w->object;
			set_file_pos(bw->b->name, bw->cursor->line);
		}
		w = w->link.next;
	} while(w != t->topwin);
	/* Set through orphaned buffers */
	set_file_pos_orphaned();
}

/* Return master BW for a B.  It's the last window on the screen with the B.  If the B has a VT, then
 * it's the last window on the screen with the B and where the cursor matches the VT cursor. */

BW *vtmaster(Screen *t, B *b)
{
	W *w = t->topwin;
	BW *m = 0;
	do {
		if (w->watom == &watomtw) {
			BW *bw = (BW *)w->object;
			if (bw && w->y != -1 && bw->b == b && (!b->vt || b->vt->vtcur->byte == bw->cursor->byte))
				m = bw;
		}
		w = w->link.next;
	} while (w != t->topwin);
	return m;
}

void bwrm(BW *w)
{
	if (w->b == errbuf && w->b->count == 1) {
		/* Do not lose message buffer */
		orphit(w);
	}
	set_file_pos(w->b->name,w->cursor->line);
	prm(w->top);
	prm(w->cursor);
	brm(w->b);
	joe_free(w);
}

char *ustat_line;

int ustat(W *w, int k)
{
	(void)k;
	BW *bw;
	int c;
	const char *msg;
	WIND_BW(bw, w);
	c = brch(bw->cursor);

	if (c == NO_MORE_DATA) {
		if (bw->o.zmsg) msg = bw->o.zmsg;
		else msg = "** Line %r Col %c Offset %o(0x%O) **";
	} else {
		if (bw->o.smsg) msg = bw->o.smsg;
		else msg = "** Line %r Col %c Offset %o(0x%O) %e %a(0x%A) Width %w **";
	}

	ustat_line = stagen(ustat_line, bw, msg, (char)(zlen(msg) ? msg[zlen(msg) - 1] : ' '));
	msgnw(bw->parent, ustat_line);

	return 0;
}

int ucrawlr(W *w, int k)
{
	(void)k;
	BW *bw;
	ptrdiff_t amnt;
	WIND_BW(bw, w);

	if (opt_right < 0)
		amnt = bw->w / (-opt_right);
	else
		amnt = opt_right;

	if (amnt > bw->w)
		amnt = bw->w;
	if (amnt <= 0)
		amnt = 1;

	/* amnt = bw->w / 2; */

	pcol(bw->cursor, bw->cursor->xcol + amnt);
	bw->cursor->xcol += amnt;
	bw->offset += amnt;
	updall();
	return 0;
}

int ucrawll(W *w, int k)
{
	(void)k;
	BW *bw;
	off_t amnt;
	WIND_BW(bw, w);
	int rtn = -1;

	if (opt_left < 0)
		amnt = bw->w / (-opt_left);
	else
		amnt = opt_left;

	if (amnt > bw->w)
		amnt = bw->w;

	if (amnt < 1)
		amnt = 1;

	if (amnt > bw->cursor->xcol) {
		if (bw->cursor->xcol)
			rtn = 0;
		bw->cursor->xcol = 0;
	} else {
		bw->cursor->xcol -= amnt;
		rtn = 0;
	}

	if (amnt > bw->offset) {
		if (bw->offset)
			rtn = 0;
		bw->offset = 0;
	} else {
		bw->offset -= amnt;
		rtn = 0;
	}

	if (rtn)
		return rtn;
	pcol(bw->cursor, bw->cursor->xcol);
	updall();
	return rtn;
}

/* If we are about to call bwrm, and b->count is 1, and orphan mode
 * is set, call this. */

void orphit(BW *bw)
{
	++bw->b->count; /* Assumes bwrm() is about to be called */
	bw->b->orphan = 1;
	pdupown(bw->cursor, &bw->b->oldcur, "orphit");
	pdupown(bw->top, &bw->b->oldtop, "orphit");
}

/* Calculate the width of the line number gutter for the Window */

int calclincols(BW *bw)
{
	int width = 0;
	off_t lines = bw->b->eof->line + 1;

	if (!bw->o.linums) {
		return 0;
	}

	if (lines < 10) {
		width = 1;
	} else if (lines < 100) {
		width = 2;
	} else if (lines < 1000) {
		width = 3;
	} else if (lines < 10000) {
		width = 4;
	} else {
		off_t l;
		for (l = 10000, width = 4; lines >= l; l *= 10, width++) {}
	}

	return width + 2;
}

/* Determine characters to use for visible whitespace */

void init_visiblews(void)
{
	int spaces[] = { 0xb7, 0x2291, '.', 0 };
	int tabs[] = { 0x2192, 0x203a, 0xbb, 0x25ba, '>', 0 };
	int rtns[] = { 0x21b5, 0x21b2, '$', 0 };
	int i;

	vspace = vtab = vrtn = 0;

	/* If we're Unicode, just take the best */
	if (locale_map->type) {
		vspace = spaces[0];
		vtab = tabs[0];
		vrtn = rtns[0];
		return;
	}

	/* Otherwise, we need to find bytes matching the desired code points */
	for (i = 0; spaces[i]; i++) {
		/* Check for unicode character in locale so we can display it */
		if (from_uni(locale_map, spaces[i]) > 0) {
			vspace = spaces[i];
			break;
		}
	}

	for (i = 0; tabs[i]; i++) {
		/* Same */
		if (from_uni(locale_map, tabs[i]) > 0) {
			vtab = tabs[i];
			break;
		}
	}

	for (i = 0; rtns[i]; i++) {
		/* Same */
		if (from_uni(locale_map, rtns[i]) > 0) {
			vrtn = rtns[i];
			break;
		}
	}
}
