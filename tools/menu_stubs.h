#ifndef MENU_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define MENU_STUBS_H

#include <stddef.h>
#include <stdint.h>

/* Avoid fortified libc wrappers that zig translate-c cannot handle */
int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
char *getenv(const char *name);
void free(void *p);
void *memcpy(void *d, const void *s, unsigned long n);
void *memset(void *s, int c, unsigned long n);
int strcmp(const char *a, const char *b);
unsigned long strlen(const char *s);

typedef int64_t off_t;

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define BG_COLOR(color) (color)
#define INVERSE 64
#define COMPOSE 4

#define TYPETW		0x0100
#define TYPEPW		0x0200
#define TYPEMENU	0x0800
#define TYPEQW		0x1000

#define LINK(type) struct { type *next; type *prev; }

#define WIND_MENU(x, y) do { \
	if ((y)->watom->what != TYPEMENU) \
		return -1; \
	(x) = (MENU *)(y)->object; \
	} while(0)

#define zcmp(a, b) strcmp((a), (b))
#define zlen(s) ((ptrdiff_t)strlen(s))

#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)

#define aLen(a) (*((ptrdiff_t *)(a) - 1))
#define aLEN(a) ((a) ? aLen(a) : 0)

struct b; typedef struct b B;
struct kbd; typedef struct kbd KBD;
struct kmap; typedef struct kmap KMAP;
struct bstack;
struct window; typedef struct window W;
struct screen; typedef struct screen Screen;
struct menu; typedef struct menu MENU;
struct charmap;

/* SCRN: li@8, co@16, scrn@728, attr@736, updtab@784; sizeof=840 (Darwin LP64) */
struct scrn {
	char _pad0[8];
	ptrdiff_t li;
	ptrdiff_t co;
	char _pad1[704]; /* 24 → 728 */
	int (*scrn)[COMPOSE];
	int *attr;
	char _pad2[40]; /* 744 → 784 */
	int *updtab;
	char _pad3[48]; /* 792 → 840 */
};
typedef struct scrn SCRN;

/* WATOM: sizeof=88; what@80 */
struct watom {
	const char *context;
	void (*disp)(W *w, int flg);
	void (*follow)(W *w);
	int (*abort)(W *w);
	int (*rtn)(W *w);
	int (*type)(W *w, int k);
	void (*resize)(W *w, ptrdiff_t width, ptrdiff_t height);
	void (*move)(W *w, ptrdiff_t x, ptrdiff_t y);
	void (*ins)(W *w, B *b, off_t l, off_t n, int flg);
	void (*del)(W *w, B *b, off_t l, off_t n, int flg);
	int what;
};
typedef struct watom WATOM;

/* Screen: sizeof=48 */
struct screen {
	SCRN *t;
	ptrdiff_t wind;
	W *topwin;
	W *curwin;
	ptrdiff_t w, h;
};

/* Window: sizeof=200 (Darwin LP64) */
struct window {
	LINK(W) link;
	Screen *t;
	ptrdiff_t x, y, w, h;
	ptrdiff_t ny, nh;
	ptrdiff_t reqh;
	ptrdiff_t fixed;
	ptrdiff_t hh;
	W *win;
	W *main;
	W *orgwin;
	ptrdiff_t curx, cury;
	KBD *kbd;
	const WATOM *watom;
	void *object;
	const char *msgt;
	const char *msgb;
	const char *huh;
	int *notify;
	struct bstack *bstack;
};

/* MENU: sizeof=144 (Darwin LP64) */
struct menu {
	W *parent;		/* 0 */
	char **list;		/* 8 */
	ptrdiff_t top;		/* 16 */
	ptrdiff_t cursor;	/* 24 */
	ptrdiff_t width;	/* 32 */
	ptrdiff_t fitline;	/* 40 */
	ptrdiff_t perline;	/* 48 */
	ptrdiff_t lines;	/* 56 */
	ptrdiff_t nitems;	/* 64 */
	Screen *t;		/* 72 */
	ptrdiff_t h, w, x, y;	/* 80,88,96,104 */
	int (*abrt)(W *w, ptrdiff_t cursor, void *object); /* 112 */
	int (*func)(MENU *m, ptrdiff_t cursor, void *object, int k); /* 120 */
	int (*backs)(MENU *m, ptrdiff_t cursor, void *object); /* 128 */
	void *object;		/* 136 */
};

struct charmap {
	void *next;
	const char *name;
	int type;
	char _pad_type[4];
	int (*is_punct)(struct charmap *map, int c);
	int (*is_print)(struct charmap *map, int c);
	int (*is_space)(struct charmap *map, int c);
	int (*is_alpha_)(struct charmap *map, int c);
	int (*is_alnum_)(struct charmap *map, int c);
	char _pad[2692];
};

struct b {
	char _pad[632];
};

struct kbd {
	char _pad[88];
};

struct bstack {
	struct bstack *next;
	B *b;
	void *cursor;
	void *top;
};

void *joe_malloc(ptrdiff_t size);
void joe_free(void *ptr);

ptrdiff_t slen(const char *s);
char *vsncpy(char *s, ptrdiff_t len, const char *blk, ptrdiff_t blklen);
char *vstrunc(char *s, ptrdiff_t len);
void vsrm(char *s);

void genfield(SCRN *t, int (*scrn)[COMPOSE], int *attr, ptrdiff_t x, ptrdiff_t y, ptrdiff_t ofst,
	const char *s, ptrdiff_t len, int atr, ptrdiff_t width, int flg, int *fmt);
void outatr(struct charmap *map, SCRN *t, int (*scrn)[COMPOSE], int *attrf, ptrdiff_t xx, ptrdiff_t yy, int c, int a);
void outatr_complete(SCRN *t);
int eraeol(SCRN *t, ptrdiff_t x, ptrdiff_t y, int atr);
ptrdiff_t txtwidth(const char *s, ptrdiff_t len);

W *wcreate(Screen *t, const WATOM *watom, W *where, W *target, W *after, ptrdiff_t lines, const char *huh, int *notify);
void wfit(Screen *t);

extern struct charmap *locale_map;
extern volatile int dostaupd;

#endif /* MENU_STUBS_H */
