#ifndef VT_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define VT_STUBS_H

#include <stddef.h>
#include <stdint.h>

/* Avoid fortified libc wrappers that zig translate-c cannot handle */
int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
int fprintf(void *f, const char *fmt, ...);
void free(void *p);
void *malloc(unsigned long n);
void *memcpy(void *d, const void *s, unsigned long n);
void *memset(void *s, int c, unsigned long n);
unsigned long strlen(const char *s);

typedef int64_t off_t;
typedef void FILE;

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define TO_DIFF_OK(a) ((ptrdiff_t)(a))
#define FALLTHROUGH
#define _(s) (s)

/* Prefer sizeof(a)-1 so zig translate-c keeps string-literal length */
#define sc(a) (a), ((ptrdiff_t)(sizeof(a) - 1))
#define zlen(s) ((ptrdiff_t)strlen(s))

#define joe_snprintf_1(buf,len,fmt,a) snprintf((buf),(len),(fmt),(a))

#define LINK(type) struct { type *next; type *prev; }

/* Attribute bits (non-MSDOS path from joe/scrn.h) */
#define DOUBLE_UNDERLINE   8
#define CROSSED_OUT       16
#define ITALIC		  32
#define INVERSE		  64
#define UNDERLINE	 128
#define BOLD		 256
#define BLINK		 512
#define DIM		1024
#define AT_MASK		(INVERSE+UNDERLINE+BOLD+BLINK+DIM+ITALIC+DOUBLE_UNDERLINE+CROSSED_OUT)

#define BG_SHIFT	11
#define BG_VALUE	(255<<BG_SHIFT)
#define BG_NOT_DEFAULT	(256<<BG_SHIFT)
#define BG_MASK		(1023<<BG_SHIFT)

#define FG_SHIFT	21
#define FG_VALUE	(255<<FG_SHIFT)
#define FG_NOT_DEFAULT	(256<<FG_SHIFT)
#define FG_MASK		(1023<<FG_SHIFT)

#define UTF8_ACCEPTED -257

#define MAXARGS 2

struct b; typedef struct b B;
struct p; typedef struct p P;
struct kbd; typedef struct kbd KBD;
struct kmap; typedef struct kmap KMAP;
struct macro; typedef struct macro MACRO;
struct charmap;

struct utf8_sm {
	char buf[8];
	ptrdiff_t ptr;
	int state;
	int accu;
};

enum vt_state {
	vt_idle,
	vt_esc,
	vt_args,
	vt_cmd,
	vt_utf,
	vt_osc,
	vt_osce
};

struct vt_context {
	enum vt_state state;
	char buf[1024];
	ptrdiff_t bufx;
	ptrdiff_t argv[MAXARGS + 1];
	ptrdiff_t argc;
	P *top;
	ptrdiff_t height;
	ptrdiff_t width;
	ptrdiff_t regn_top;
	ptrdiff_t regn_bot;
	P *vtcur;
	B *b;
	KBD *kbd;
	int attr;
	struct utf8_sm utf8_sm;
};
typedef struct vt_context VT;

struct macro {
	ptrdiff_t what;
	int k;
	int flg;
	void *cmd;
	ptrdiff_t n;
	ptrdiff_t size;
	MACRO **steps;
};

struct kbd {
	KMAP *curmap;
	KMAP *topmap;
	int seq[16];
	ptrdiff_t x;
};

/* OPTIONS: tab at offset 64; total size 344 (matches joe/b.h) */
struct options {
	struct options *next;
	const char *ftype;
	void *match;
	int overtype;
	off_t lmargin;
	off_t rmargin;
	int autoindent;
	int wordwrap;
	int nobackup;
	char _pad_tab[4];
	off_t tab;
	char _pad_rest[272]; /* 344 - 72 */
};
typedef struct options OPTIONS;

/* P size 112 — matches gapbuffer */
struct p {
	LINK(P) link;
	B *b;
	char _pad0[24];
	off_t byte;
	off_t line;
	off_t col;
	off_t xcol;
	int valcol;
	int end;
	int attr;
	int valattr;
	P **owner;
	const char *tracker;
};

/* B size 632 — eof@24, o@192 */
struct b {
	LINK(B) link;
	P *bof;
	P *eof;
	char _pad1[160];
	OPTIONS o;
	char _pad2[96]; /* 632 - 192 - 344 */
};

struct charmap {
	struct charmap *next;
	const char *name;
	int type;
};

void *joe_malloc(ptrdiff_t size);
void joe_free(void *ptr);

P *pdup(P *p, const char *tr);
void prm(P *p);
P *pset(P *n, P *p);
P *pline(P *p, off_t line);
P *pnextl(P *p);
P *p_goto_bol(P *p);
P *p_goto_eol(P *p);
P *p_goto_eof(P *p);
off_t piscol(P *p);
int piseol(P *p);
int pgetc(P *p);
int pgetb(P *p);
P *pfwrd(P *p, off_t n);
P *pcol(P *p, off_t goalcol);
void pfill(P *p, off_t to, int usetabs);
P *binsc(P *p, int c);
P *binss(P *p, const char *s);
void bdel(P *from, P *to);

KBD *mkkbd(KMAP *kmap);
void rmkbd(KBD *k);
KMAP *kmap_getcontext(const char *name);

void utf8_init(struct utf8_sm *utf8_sm);
int utf8_decode(struct utf8_sm *utf8_sm, char c);

void ttputc(int c);
void vt_scrdn(void);

MACRO *mparse(MACRO *m, const char *buf, ptrdiff_t *sta, int secure);
void rmmacro(MACRO *macro);

extern struct charmap *locale_map;

#endif
