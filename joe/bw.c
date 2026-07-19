/*
 *	Edit buffer window generation
 *	Copyright
 *		(C) 1992 Joseph H. Allen
 *
 *	This file is part of JOE (Joe's Own Editor)
 */
#include "types.h"
#include <limits.h>

/* Path A: Zig-native lgen_core body paint (always on; abort on -1). */
extern int zig_bw_lgen(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr,
	ptrdiff_t x0, ptrdiff_t x1, P *p, off_t scr, struct high_syntax *syntax,
	HIGHLIGHT_STATE st, struct charmap *charmap, int tab, int defatr,
	int *palette, int palette_len, off_t from, off_t to, off_t line_byte,
	int viewmode, char *vm_hide, int vm_hide_len, int *vm_subst, int vm_subst_len,
	char **vm_urls, int vm_urls_len, int visiblews, int square, int ansi);
/* Path A: Zig gennum line-number gutter. */
extern int zig_bw_gennum(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr,
	int *compose, int lincols, int have_number, off_t line_1based, int atr,
	struct charmap *charmap);
/* Path A: Zig bwgen paint loops. */
extern int zig_bw_bwgen(BW *w, SCRN *t, int (*scrn)[COMPOSE], int *attr_base,
	int *updtab, int *compose, ptrdiff_t scr_w,
	ptrdiff_t win_x, ptrdiff_t win_y, ptrdiff_t win_w, ptrdiff_t win_h,
	ptrdiff_t mid_y, P *top, P *cursor, off_t top_line, off_t offset,
	int linums, int linchg, int dosquare,
	off_t from, off_t to, off_t fromline, off_t toline);
/* Path A: thin bwgen entry (lattr/viewmode/mark setup + loops + cursor). */
extern int zig_bw_bwgen_entry(BW *w, int linums, int linchg);
/* Path A: Zig bwgenh hex dump paint. */
extern int zig_bw_bwgenh(SCRN *t, int (*scrn)[COMPOSE], int *attr_base,
	ptrdiff_t scr_w, ptrdiff_t win_y, ptrdiff_t win_h, ptrdiff_t win_w,
	off_t offset, P *top, off_t cursor_byte, int hiline,
	off_t from, off_t to, int bg_text_atr, int bg_linum_atr,
	int bg_curlinum_atr, int bg_cursor_atr);
/* Path A: thin bwgenh entry (mark setup + hex paint). */
extern int zig_bw_bwgenh_entry(BW *w);
/* Path A: Zig cursor follow (text + hex). */
extern int zig_bw_bwfllwt(P *top, P *cursor, SCRN *t, int *updtab,
	ptrdiff_t y, ptrdiff_t h, ptrdiff_t w,
	off_t *offset, off_t *curlin, int hiline);
extern int zig_bw_bwfllwh(P *top, P *cursor, SCRN *t, int *updtab,
	ptrdiff_t y, ptrdiff_t h, ptrdiff_t w, off_t *offset);
/* Path A: Zig post-edit window scroll. */
extern int zig_bw_bwins(SCRN *t, int *updtab, ptrdiff_t *sary, ptrdiff_t li,
	ptrdiff_t y, ptrdiff_t h, off_t top_line, off_t eof_line,
	off_t l, off_t n, int flg, int do_highlight);
extern int zig_bw_bwdel(SCRN *t, int *updtab,
	ptrdiff_t y, ptrdiff_t h, off_t top_line, off_t eof_line,
	off_t l, off_t n, int flg, int do_highlight);
/* Path A: thin lgen_view entry (prelude + dispatcher + paint cleanup). */
extern int zig_bw_lgen_view_entry(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr,
	ptrdiff_t x, ptrdiff_t w, P *p, off_t scr, off_t from, off_t to,
	HIGHLIGHT_STATE st, BW *bw);
/* Path A: Zig-owned viewmode statics for Path A. */
extern off_t zig_bw_vm_display_col(off_t buf_line, off_t buf_offset);
extern void zig_bw_vm_cleanup(void);
/* Path A: lifecycle helpers. */
extern int zig_bw_bwmove(BW *w, ptrdiff_t x, ptrdiff_t y);
extern int zig_bw_bwresz(BW *w, ptrdiff_t wi, ptrdiff_t he);
extern int zig_bw_bwmk(W *window, B *b, int prompt, BW **out_bw);
extern int zig_bw_bwrm(BW *w);
extern int zig_bw_orphit(BW *bw);
extern int zig_bw_calclincols(BW *bw);
/* Path A: non-paint helpers. */
extern int zig_bw_get_file_pos(const char *name, off_t *out);
extern int zig_bw_set_file_pos(const char *name, off_t pos);
extern int zig_bw_save_file_pos(FILE *f);
extern int zig_bw_load_file_pos(FILE *f);
extern int zig_bw_set_file_pos_all(Screen *t);
extern int zig_bw_vtmaster(Screen *t, B *b, BW **out);
extern int zig_bw_ustat(W *w, int k, int *out_rc);
extern int zig_bw_ucrawlr(W *w, int k, int *out_rc);
extern int zig_bw_ucrawll(W *w, int k, int *out_rc);
extern int zig_bw_init_visiblews(void);
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

/* getto: owned by Zig `bwGetto` in src/bw_lgen.zig */

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
	if (zig_bw_bwfllwh(w->top, w->cursor, w->t->t, w->t->t->updtab,
		w->y, w->h, w->w, &w->offset) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_bwfllwh -1\n");
	abort();
}


/* For text */

void bwfllwt(W *thew)
{
	BW *w = (BW *)thew->object;
	if (zig_bw_bwfllwt(w->top, w->cursor, w->t->t, w->t->t->updtab,
		w->y, w->h, w->w, &w->offset, &w->curlin, w->o.hiline) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_bwfllwt -1\n");
	abort();
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
	if (zig_bw_bwins(w->t->t, w->t->t->updtab, w->t->t->sary, w->t->t->li,
		w->y, w->h, w->top->line, w->b->eof->line,
		l, n, flg, (w->o.highlight && w->o.syntax) ? 1 : 0) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_bwins -1\n");
	abort();
}


/* Scroll current windows after a delete */

void bwdel(BW *w, off_t l, off_t n, int flg)
{
	if (zig_bw_bwdel(w->t->t, w->t->t->updtab,
		w->y, w->h, w->top->line, w->b->eof->line,
		l, n, flg, (w->o.highlight && w->o.syntax) ? 1 : 0) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_bwdel -1\n");
	abort();
}



/* Update a single line */

static int lgen_core(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr, ptrdiff_t x, ptrdiff_t w, P *p, off_t scr, off_t from, off_t to,HIGHLIGHT_STATE st,BW *bw);
static int lgen_view(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr, ptrdiff_t x, ptrdiff_t w, P *p, off_t scr, off_t from, off_t to,HIGHLIGHT_STATE st,BW *bw);

/* Path A owns viewmode tables in Zig (`zig_bw_vm_*`). */

/* Caps used by `zig_c_bw_read_line` to avoid OOM on huge lines. */
#define VIEWMODE_MAX_LINE_BYTES (1024 * 1024)
#define VIEWMODE_TABLE_SCAN_MAX_BYTES (16 * 1024)

off_t viewmode_display_col(off_t buf_line, off_t buf_offset)
{
	return zig_bw_vm_display_col(buf_line, buf_offset);
}

void viewmode_cleanup(void)
{
	zig_bw_vm_cleanup();
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
{
	/* Path A always-on: Zig-native body paint. */
	if (p && p->b && p->b->o.charmap) {
		int defatr = (bw->o.hiline && bw->cursor->line == y - bw->y + bw->top->line)
			? (bg_text & curlinmask) | bg_curlin
			: bg_text;
		int z = zig_bw_lgen(t, y, screen, attr, x, w, p, scr,
			bw->o.syntax, st, p->b->o.charmap, p->b->o.tab, BG_COLOR(defatr),
			t->palette, t->palette ? 256 : 0, from, to, p->byte,
			0, NULL, 0, NULL, 0, NULL, 0,
			bw->o.visiblews, square, bw->o.ansi);
		if (z >= 0)
			return z;
	}
	fprintf(stderr, "Path A: zig_bw_lgen -1\n");
	abort();
}


/* Markdown view mode rendering */
/* Features 1.3-1.8: Hide/transform markdown delimiters in view mode */
static int lgen_view(SCRN *t, ptrdiff_t y, int (*screen)[COMPOSE], int *attr, ptrdiff_t x, ptrdiff_t w, P *p, off_t scr, off_t from, off_t to,HIGHLIGHT_STATE st,BW *bw)
{
	if (st.state == -1 || !bw->o.syntax || zcmp(bw->o.syntax->name, "md"))
		return lgen_core(t, y, screen, attr, x, w, p, scr, from, to, st, bw);

	/* Path A always-on: Zig owns prelude + chrome + paint. */
	int z = zig_bw_lgen_view_entry(t, y, screen, attr, x, w, p, scr, from, to, st, bw);
	if (z >= 0)
		return z;
	fprintf(stderr, "Path A: zig_bw_lgen_view_entry returned %d\n", z);
	abort();
}

static void gennum(BW *w, int (*screen)[COMPOSE], int *attr, SCRN *t, ptrdiff_t y, int *comp)
{
	off_t lin = w->top->line + y - w->y;
	int atr = (w->o.hiline && lin == w->cursor->line) ? bg_curlinum : bg_linum;

	/* Path A always-on: Zig-native line-number gutter. */
	if (w->lincols > 0) {
		int have_number = (lin <= w->b->eof->line);
		off_t line_1based = have_number ? (lin + 1) : 0;
		int zret = zig_bw_gennum(t, y, screen, attr, comp, w->lincols,
			have_number, line_1based, BG_COLOR(atr),
			w->b && w->b->o.charmap ? w->b->o.charmap : NULL);
		if (zret >= 0)
			return;
	}
	fprintf(stderr, "Path A: zig_bw_gennum -1\n");
	abort();
}

int zig_c_bw_get_hiline(BW *w)
{
	return (w && w->o.hiline) ? 1 : 0;
}

void bwgenh(BW *w)
{
	if (zig_bw_bwgenh_entry(w) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_bwgenh_entry returned -1\n");
	abort();
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

/* Path A helpers for zig_bw_lgen_view_entry / bwgen entry.
 * Zig owns viewmode tables (`zig_bw_vm_*`). `lgen_core` is Zig-entry-only. */

P *zig_c_bw_get_top(BW *bw)
{
	return bw ? bw->top : NULL;
}

P *zig_c_bw_get_cursor(BW *bw)
{
	return bw ? bw->cursor : NULL;
}

ptrdiff_t zig_c_bw_get_y(BW *bw)
{
	return bw ? bw->y : 0;
}

off_t zig_c_bw_get_top_line(BW *bw)
{
	return (bw && bw->top) ? bw->top->line : 0;
}

int zig_c_bw_get_tab(BW *bw)
{
	int tab = bw ? bw->o.tab : 8;
	return tab <= 0 ? 8 : tab;
}

struct high_syntax *zig_c_bw_get_syntax(BW *bw)
{
	return bw ? bw->o.syntax : NULL;
}

struct charmap *zig_c_bw_get_charmap(BW *bw)
{
	return (bw && bw->b) ? bw->b->o.charmap : NULL;
}


int *zig_c_bw_get_palette(SCRN *t, int *out_len)
{
	if (out_len) *out_len = 0;
	if (!t || !t->palette) return NULL;
	if (out_len) *out_len = 256;
	return t->palette;
}

/* Path A helpers for lifecycle exports. */
void zig_c_bw_set_pos(BW *w, ptrdiff_t x, ptrdiff_t y)
{
	if (!w) return;
	w->x = x;
	w->y = y;
}

ptrdiff_t zig_c_bw_get_h(BW *w)
{
	return w ? w->h : 0;
}

void zig_c_bw_set_size(BW *w, ptrdiff_t wi, ptrdiff_t he)
{
	if (!w) return;
	w->w = wi;
	w->h = he;
}

void zig_c_bw_dirty_grown_rows(BW *w, ptrdiff_t old_h, ptrdiff_t new_h)
{
	if (!w || !w->t || !w->t->t || w->y == -1) return;
	if (new_h > old_h)
		msetI(w->t->t->updtab + w->y + old_h, 1, new_h - old_h);
}

void zig_c_bw_resz_vt_if_master(BW *w, ptrdiff_t wi, ptrdiff_t he)
{
	if (!w || !w->b || !w->parent) return;
	if (w->b->vt && w->b->pid && w == vtmaster(w->parent->t, w->b)) {
		vt_resize(w->b->vt, w->top, he, wi);
		ttstsz(w->b->out, wi, he);
	}
}

int zig_c_bw_get_linums(BW *w)
{
	return (w && w->o.linums) ? 1 : 0;
}

off_t zig_c_bw_b_eof_line(BW *w)
{
	return (w && w->b && w->b->eof) ? w->b->eof->line : 0;
}

BW *zig_c_bw_alloc(void)
{
	return (BW *)joe_malloc(SIZEOF(BW));
}

int zig_c_bw_mk_init(BW *w, W *window, B *b, int prompt)
{
	if (!w || !window || !b) return -1;

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
		if (!w->top || !w->cursor) return -1;
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
	return 0;
}

void zig_c_bw_orphit_impl(BW *bw)
{
	if (!bw || !bw->b) return;
	++bw->b->count;
	bw->b->orphan = 1;
	pdupown(bw->cursor, &bw->b->oldcur, "orphit");
	pdupown(bw->top, &bw->b->oldtop, "orphit");
}

int zig_c_bw_is_sole_errbuf(BW *w)
{
	return (w && w->b == errbuf && w->b->count == 1) ? 1 : 0;
}

void zig_c_bw_rm_save_pos(BW *w)
{
	if (w && w->b && w->cursor)
		set_file_pos(w->b->name, w->cursor->line);
}

void zig_c_bw_rm_release(BW *w)
{
	if (!w) return;
	if (w->top) prm(w->top);
	if (w->cursor) prm(w->cursor);
	if (w->b) brm(w->b);
	joe_free(w);
}

/* Path A field helpers for Zig-owned bwgen/bwgenh mark setup. */
void zig_c_bw_ensure_lattr_db(BW *w)
{
	if (!w)
		return;
	if (w->o.highlight && w->o.syntax && (!w->db || w->db->syn != w->o.syntax))
		w->db = find_lattr_db(w->b, w->o.syntax);
}

void zig_c_bw_sync_viewmode(BW *w)
{
	if (!w || !w->t || !w->t->t)
		return;
	if (w->o.viewmode != w->last_viewmode) {
		scrn_invalidate(w->t->t);
		w->last_viewmode = w->o.viewmode;
	}
}

P *zig_c_bw_get_err(BW *w)
{
	return (w && w->b == errbuf && w->b->err) ? w->b->err : NULL;
}

int zig_c_bw_same_buf(BW *w, P *p)
{
	return (w && p && p->b == w->b) ? 1 : 0;
}

int zig_c_bw_is_maint_cur(BW *w)
{
	return (w && maint && maint->curwin && w == (BW *)maint->curwin->object) ? 1 : 0;
}

SCRN *zig_c_bw_get_scrn(BW *w)
{
	return (w && w->t) ? w->t->t : NULL;
}

ptrdiff_t zig_c_bw_get_x(BW *w)
{
	return w ? w->x : 0;
}

ptrdiff_t zig_c_bw_scr_w(BW *w)
{
	return (w && w->t) ? w->t->w : 0;
}

int (*zig_c_bw_scrn_cells(SCRN *t))[COMPOSE]
{
	return t ? t->scrn : NULL;
}

int *zig_c_bw_scrn_attr(SCRN *t)
{
	return t ? t->attr : NULL;
}

int *zig_c_bw_scrn_updtab(SCRN *t)
{
	return t ? t->updtab : NULL;
}

int *zig_c_bw_scrn_compose(SCRN *t)
{
	return t ? t->compose : NULL;
}

int zig_c_bw_get_viewmode(BW *w)
{
	return (w && w->o.viewmode) ? 1 : 0;
}

int zig_c_bw_get_visiblews(BW *w)
{
	return (w && w->o.visiblews) ? 1 : 0;
}

int zig_c_bw_get_ansi(BW *w)
{
	return (w && w->o.ansi) ? 1 : 0;
}

void bwgen(BW *w, int linums, int linchg)
{
	if (zig_bw_bwgen_entry(w, linums, linchg) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_bwgen_entry returned -1\n");
	abort();
}


void bwmove(BW *w, ptrdiff_t x, ptrdiff_t y)
{
	if (zig_bw_bwmove(w, x, y) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_bwmove -1\n");
	abort();
}


void bwresz(BW *w, ptrdiff_t wi, ptrdiff_t he)
{
	if (zig_bw_bwresz(w, wi, he) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_bwresz -1\n");
	abort();
}


BW *bwmk(W *window, B *b, int prompt)
{
	BW *zw = NULL;
	if (zig_bw_bwmk(window, b, prompt, &zw) >= 0)
		return zw;
	fprintf(stderr, "Path A: zig_bw_bwmk -1\n");
	abort();
}


/* restore_file_pos: Zig file_pos DB reads this global. */
int restore_file_pos;

char *ustat_line;

/* Path A: window walk for Zig-owned file_pos DB (+ orphaned buffers). */
void zig_c_bw_file_pos_all(Screen *t)
{
	W *w;
	if (!t || !t->topwin)
		return;
	w = t->topwin;
	do {
		if (w->watom == &watomtw) {
			BW *bw = (BW *)w->object;
			if (bw && bw->b && bw->cursor)
				zig_bw_set_file_pos(bw->b->name, bw->cursor->line);
		}
		w = w->link.next;
	} while (w != t->topwin);
	set_file_pos_orphaned();
}

BW *zig_c_bw_vtmaster_impl(Screen *t, B *b)
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

int zig_c_bw_ustat_impl(W *w)
{
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

int zig_c_bw_wind_bw(W *w, BW **out)
{
	if (!w || !out) return -1;
	if (!(w->watom->what & (TYPETW | TYPEPW)))
		return -1;
	*out = (BW *)w->object;
	return 0;
}

ptrdiff_t zig_c_bw_get_w(BW *w) { return w ? w->w : 0; }
off_t zig_c_bw_get_offset(BW *w) { return w ? w->offset : 0; }
void zig_c_bw_set_offset(BW *w, off_t off) { if (w) w->offset = off; }
off_t zig_c_bw_get_cursor_xcol(BW *w) { return (w && w->cursor) ? w->cursor->xcol : 0; }
void zig_c_bw_set_cursor_xcol(BW *w, off_t xcol)
{
	if (w && w->cursor) {
		w->cursor->xcol = xcol;
		w->cursor->valcol = 1;
	}
}
void zig_c_bw_pcol(BW *w, off_t xcol)
{
	if (w && w->cursor)
		pcol(w->cursor, xcol);
}
void zig_c_bw_updall(void) { updall(); }

int zig_c_bw_locale_utf8(void)
{
	return (locale_map && locale_map->type) ? 1 : 0;
}

int zig_c_bw_from_uni(int cp)
{
	return locale_map ? from_uni(locale_map, cp) : -1;
}

off_t get_file_pos(const char *name)
{
	off_t zpos = 0;
	if (zig_bw_get_file_pos(name, &zpos) >= 0)
		return zpos;
	fprintf(stderr, "Path A: zig_bw_get_file_pos -1\n");
	abort();
}


void set_file_pos(const char *name, off_t pos)
{
	if (zig_bw_set_file_pos(name, pos) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_set_file_pos -1\n");
	abort();
}


void save_file_pos(FILE *f)
{
	if (zig_bw_save_file_pos(f) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_save_file_pos -1\n");
	abort();
}


void load_file_pos(FILE *f)
{
	if (zig_bw_load_file_pos(f) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_load_file_pos -1\n");
	abort();
}


/* Save file position for all windows */

void set_file_pos_all(Screen *t)
{
	if (zig_bw_set_file_pos_all(t) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_set_file_pos_all -1\n");
	abort();
}


/* Return master BW for a B.  It's the last window on the screen with the B.  If the B has a VT, then
 * it's the last window on the screen with the B and where the cursor matches the VT cursor. */

BW *vtmaster(Screen *t, B *b)
{
	BW *zm = NULL;
	if (zig_bw_vtmaster(t, b, &zm) >= 0)
		return zm;
	fprintf(stderr, "Path A: zig_bw_vtmaster -1\n");
	abort();
}


void bwrm(BW *w)
{
	if (zig_bw_bwrm(w) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_bwrm -1\n");
	abort();
}


int ustat(W *w, int k)
{
	int zrc = 0;
	if (zig_bw_ustat(w, k, &zrc) >= 0)
		return zrc;
	fprintf(stderr, "Path A: zig_bw_ustat -1\n");
	abort();
}


int ucrawlr(W *w, int k)
{
	int zrc = 0;
	if (zig_bw_ucrawlr(w, k, &zrc) >= 0)
		return zrc;
	fprintf(stderr, "Path A: zig_bw_ucrawlr -1\n");
	abort();
}


int ucrawll(W *w, int k)
{
	int zrc = 0;
	if (zig_bw_ucrawll(w, k, &zrc) >= 0)
		return zrc;
	fprintf(stderr, "Path A: zig_bw_ucrawll -1\n");
	abort();
}


/* If we are about to call bwrm, and b->count is 1, and orphan mode
 * is set, call this. */

void orphit(BW *bw)
{
	if (zig_bw_orphit(bw) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_orphit -1\n");
	abort();
}


/* Calculate the width of the line number gutter for the Window */

int calclincols(BW *bw)
{
	int z = zig_bw_calclincols(bw);
	if (z >= 0)
		return z;
	fprintf(stderr, "Path A: zig_bw_calclincols -1\n");
	abort();
}


/* Determine characters to use for visible whitespace */

void init_visiblews(void)
{
	if (zig_bw_init_visiblews() >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_init_visiblews -1\n");
	abort();
}