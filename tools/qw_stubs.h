#ifndef QW_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define QW_STUBS_H

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

#define TYPETW		0x0100
#define TYPEPW		0x0200
#define TYPEMENU	0x0800
#define TYPEQW		0x1000
#define COMPOSE		4

#define LINK(type) struct { type *next; type *prev; }

struct b; typedef struct b B;
struct kbd; typedef struct kbd KBD;
struct kmap; typedef struct kmap KMAP;
struct bstack;
struct window; typedef struct window W;
struct screen; typedef struct screen Screen;
struct qw; typedef struct qw QW;
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

/* Window: sizeof=200; watom@144, object@152, notify@184 (Darwin LP64) */
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

/* QW / query: sizeof=64 (Darwin LP64) */
struct qw {
	W *parent;
	int (*func)(W *w, int k, void *object, int *notify);
	int (*abrt)(W *w, void *object);
	void *object;
	char *prompt;
	ptrdiff_t promptlen;
	ptrdiff_t org_w;
	ptrdiff_t org_h;
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

char *vsncpy(char *s, ptrdiff_t len, const char *blk, ptrdiff_t blklen);
void vsrm(char *s);

ptrdiff_t joe_wcswidth(struct charmap *map, const char *s, ptrdiff_t len);
void genfield(SCRN *t, int (*scrn)[COMPOSE], int *attr, ptrdiff_t x, ptrdiff_t y, ptrdiff_t ofst,
	const char *s, ptrdiff_t len, int atr, ptrdiff_t width, int flg, int *fmt);

W *wcreate(Screen *t, const WATOM *watom, W *where, W *target, W *after, ptrdiff_t lines, const char *huh, int *notify);
int wabort(W *w);
void wfit(Screen *t);

extern struct charmap *locale_map;
extern int bg_prompt;

#endif /* QW_STUBS_H */
