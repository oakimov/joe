/*
 *	Edit buffer window generation
 *	Copyright
 *		(C) 1992 Joseph H. Allen
 *
 *	This file is part of JOE (Joe's Own Editor)
 */
#include "types.h"
#include <limits.h>

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

/* get_highlight_state: owned by Zig `zig_c_bw_get_highlight_state` */

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

/* static lgen/lgen_core/lgen_view/gennum + zig_c_bw_{lgen,gennum}:
 * owned by Zig `zig_c_bw_lgen` / `zig_c_bw_gennum` (bwLgenCore/View). */

/* Path A owns viewmode tables in Zig (`zig_bw_vm_*`). */

off_t viewmode_display_col(off_t buf_line, off_t buf_offset)
{
	return zig_bw_vm_display_col(buf_line, buf_offset);
}

void viewmode_cleanup(void)
{
	zig_bw_vm_cleanup();
}


void bwgenh(BW *w)
{
	if (zig_bw_bwgenh_entry(w) >= 0)
		return;
	fprintf(stderr, "Path A: zig_bw_bwgenh_entry returned -1\n");
	abort();
}


/* C helpers for Zig Path A `zig_bw_bwgen` / `zig_bw_bwgenh` / follow.
 * Typed BW/W/P field accessors + resize owned by Zig. */









/* zig_c_bw_lgen / zig_c_bw_gennum: owned by Zig. */


/* zig_c_bw_alloc / zig_c_bw_mk_init: owned by Zig `bwMkInit` */

/* zig_c_bw_orphit_impl / is_sole_errbuf / rm_*: owned by Zig `bwOrphit`/`bwrm` */

/* Typed BW/W/P field accessors + resize: owned by Zig (see src/bw_lgen.zig). */

/* Path A field helpers for Zig-owned bwgen/bwgenh mark setup. */






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

/* zig_c_bw_file_pos_all: owned by Zig `zig_bw_set_file_pos_all` */

/* zig_c_bw_vtmaster_impl: owned by Zig `zig_bw_vtmaster` */

/* zig_c_bw_ustat_impl / zig_c_bw_wind_bw: owned by Zig `bwUstat`/`windBw` */




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