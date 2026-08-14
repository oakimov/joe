#ifndef HELP_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define HELP_STUBS_H

#include <stddef.h>
#include <stdint.h>

int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
char *getenv(const char *name);
void free(void *p);
void *malloc(unsigned long n);
void *memcpy(void *d, const void *s, unsigned long n);
void *memset(void *s, int c, unsigned long n);
int strcmp(const char *a, const char *b);
unsigned long strlen(const char *s);
char *strchr(const char *s, int c);

typedef int64_t off_t;

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define TO_DIFF_OK(a) ((ptrdiff_t)(a))
#define FALLTHROUGH
#define _(s) (s)
#define joe_gettext(s) my_gettext((s))
#define logerror_1(fmt, a) ((void)printf((fmt), (a)))

#define FITMIN 2
#define COMPOSE 4

#define DOUBLE_UNDERLINE   8
#define CROSSED_OUT       16
#define ITALIC		  32
#define INVERSE		  64
#define UNDERLINE	 128
#define BOLD		 256
#define BLINK		 512
#define DIM		1024

#define BG_SHIFT	11
#define BG_MASK		(1023<<BG_SHIFT)
#define FG_SHIFT	21
#define FG_MASK		(1023<<FG_SHIFT)
#define BG_COLOR(color)	(color)

#define zcmp(a, b) strcmp((a), (b))
#define zlen(s) ((ptrdiff_t)strlen(s))
#define zchr(s, c) strchr((s), (c))

#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)
/* sizeof(a)-1 so zig translate-c keeps string-literal length */
#define sc(a) (a), ((ptrdiff_t)(sizeof(a) - 1))

struct hentry { int a; int b; int c; int d; };

struct cap;
typedef struct cap CAP;

struct scrn {
	CAP *cap;
	ptrdiff_t li;
	ptrdiff_t co;
	const char *ti, *cl, *cd, *te, *brp, *bre;
	int haz, os, eo, ul, am, xn;
	const char *so, *se, *us, *ue, *uc;
	int ms; int _pad_ms;
	const char *mb, *md, *mh, *mr, *stricken, *dunderline, *me;
	const char *ZH, *ZR, *Sb, *Sf;
	int Co, Tc, ut, da, db; int _pad_db;
	const char *al, *dl, *AL, *DL, *cs;
	int rr; int _pad_rr;
	const char *sf, *SF, *sr, *SR;
	const char *dm, *dc, *DC, *ed;
	const char *im, *ic, *IC, *ip, *ei;
	int mi; int _pad_mi;
	const char *bs; ptrdiff_t cbs;
	const char *lf; ptrdiff_t clf;
	const char *up; ptrdiff_t cup;
	const char *nd;
	const char *ta; ptrdiff_t cta;
	const char *bt; ptrdiff_t cbt;
	ptrdiff_t tw;
	const char *ho; ptrdiff_t cho;
	const char *ll; ptrdiff_t cll;
	const char *cr; ptrdiff_t ccr;
	const char *RI; ptrdiff_t cRI;
	const char *LE; ptrdiff_t cLE;
	const char *UP; ptrdiff_t cUP;
	const char *DO; ptrdiff_t cDO;
	const char *ch; ptrdiff_t cch;
	const char *cv; ptrdiff_t ccv;
	const char *cV; ptrdiff_t ccV;
	const char *cm; ptrdiff_t ccm;
	const char *ce; ptrdiff_t cce;
	int assume_256, truecolor;
	int *palette;
	int scroll, insdel;
	int (*scrn)[COMPOSE];
	int *attr;
	ptrdiff_t x, y;
	ptrdiff_t top, bot;
	int attrib, ins;
	int *updtab;
	int avattr; int _pad_avattr;
	ptrdiff_t *sary;
	int *compose;
	ptrdiff_t *ofst;
	struct hentry *htab;
	struct hentry *ary;
};
typedef struct scrn SCRN;

struct window;
typedef struct window W;

struct screen {
	SCRN *t;
	ptrdiff_t wind;
	W *topwin;
	W *curwin;
	ptrdiff_t w;
	ptrdiff_t h;
};
typedef struct screen Screen;

struct window {
	struct { W *next; W *prev; } link;
	Screen *t;
	ptrdiff_t x, y, w, h, ny, nh, reqh, fixed, hh;
	W *win, *main, *orgwin;
	ptrdiff_t curx, cury;
	void *kbd;
	void *watom;
	void *object;
	const char *msgt;
	const char *msgb;
	const char *huh;
	int *notify;
	void *bstack;
};

struct charmap {
	struct charmap *next;
	const char *name;
	int type;
	char _pad[2720];
};

typedef void JFILE;

void *joe_malloc(ptrdiff_t size);
void *joe_realloc(void *ptr, ptrdiff_t size);
void joe_free(void *ptr);
void *mcpy(void *d, const void *s, ptrdiff_t n);
void *msetI(void *d, int c, ptrdiff_t n);

ptrdiff_t slen(const char *s);
char *vsncpy(char *d, ptrdiff_t dlen, const char *s, ptrdiff_t sl);
char *jfgets(char *buf, int len, JFILE *f);
const char *my_gettext(const char *s);

int utf8_decode_fwrd(const char **p, ptrdiff_t *len);
int joe_wcwidth(int wide, int c);

void outatr(struct charmap *map, SCRN *t, int *scrn, int *attrf, ptrdiff_t xx, ptrdiff_t yy, int c, int a);
void outatr_complete(SCRN *t);
int eraeol(SCRN *t, ptrdiff_t x, ptrdiff_t y, int atr);
void wfit(Screen *t);

extern int skiptop;
extern int bg_stalin;
extern int bg_menu;
extern struct charmap *locale_map;
extern struct charmap *utf8_map;

#endif /* HELP_STUBS_H */
