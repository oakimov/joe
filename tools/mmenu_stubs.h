#ifndef MMENU_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define MMENU_STUBS_H

#include <stddef.h>
#include <stdint.h>

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
#define _(s) (s)
#define joe_gettext(s) my_gettext((s))

#define TYPETW		0x0100
#define TYPEPW		0x0200
#define TYPEMENU	0x0800
#define TYPEQW		0x1000

#define LINK(type) struct { type *next; type *prev; }

#define WIND_BW(x, y) do { \
	if (!((y)->watom->what & (TYPETW | TYPEPW))) \
		return -1; \
	(x) = (BW *)(y)->object; \
	} while(0)

#define zcmp(a, b) strcmp((a), (b))
#define zlen(s) ((ptrdiff_t)strlen(s))

#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)

#define aLen(a) (*((ptrdiff_t *)(a) - 1))
#define aLEN(a) ((a) ? aLen(a) : 0)

typedef char *aELEMENT;

struct b; typedef struct b B;
struct p; typedef struct p P;
struct kbd; typedef struct kbd KBD;
struct kmap; typedef struct kmap KMAP;
struct bstack;
struct window; typedef struct window W;
struct screen; typedef struct screen Screen;
struct bw; typedef struct bw BW;
struct menu; typedef struct menu MENU;
struct macro; typedef struct macro MACRO;
struct charmap;
struct options; typedef struct options OPTIONS;

struct scrn {
	char _pad0[8];
	ptrdiff_t li;
	ptrdiff_t co;
	char _pad1[760];
	int *updtab;
	char _pad2[48];
};
typedef struct scrn SCRN;

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

struct screen {
	SCRN *t;
	ptrdiff_t wind;
	W *topwin;
	W *curwin;
	ptrdiff_t w, h;
};

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

/* OPTIONS: readonly@136; sizeof=344 */
struct options {
	char _pad0[136];
	int readonly;
	char _pad1[204];
};

/* B: o@192, rdonly@572; sizeof=632 */
struct b {
	char _pad0[192];
	OPTIONS o;
	char _pad1[36]; /* 536 → 572 */
	int rdonly;
	char _pad2[56]; /* 576 → 632 */
};

/* BW: parent@0, b@8, o@80; sizeof=488 */
struct bw {
	W *parent;
	B *b;
	char _pad0[64]; /* 16 → 80 */
	OPTIONS o;
	char _pad1[64]; /* 424 → 488 */
};

struct menu {
	W *parent;
	char **list;
	ptrdiff_t top;
	ptrdiff_t cursor;
	ptrdiff_t width;
	ptrdiff_t fitline;
	ptrdiff_t perline;
	ptrdiff_t lines;
	ptrdiff_t nitems;
	Screen *t;
	ptrdiff_t h, w, x, y;
	int (*abrt)(W *w, ptrdiff_t cursor, void *object);
	int (*func)(MENU *m, ptrdiff_t cursor, void *object, int k);
	int (*backs)(MENU *m, ptrdiff_t cursor, void *object);
	void *object;
};

struct macro {
	char _pad[64];
};

struct charmap {
	void *next;
	const char *name;
	int type;
	char _pad_type[4];
	char _pad[2732];
};

struct kbd { char _pad[88]; };
struct bstack {
	struct bstack *next;
	B *b;
	void *cursor;
	void *top;
};

/* rc menus */
struct rc_menu_entry {
	MACRO *m;
	char *name;
};

struct rc_menu {
	struct rc_menu *next;
	char *name;
	ptrdiff_t last_position;
	ptrdiff_t size;
	struct rc_menu_entry **entries;
	MACRO *backs;
};

struct menu_instance {
	struct rc_menu *menu;
	char **s;
};

void *joe_malloc(ptrdiff_t size);
void *joe_realloc(void *ptr, ptrdiff_t size);
void joe_free(void *ptr);
char *zdup(const char *s);

ptrdiff_t slen(const char *s);
char *vsncpy(char *s, ptrdiff_t len, const char *blk, ptrdiff_t blklen);
void vsrm(char *s);

aELEMENT *vaensure(aELEMENT *vary, ptrdiff_t len);
aELEMENT *vaadd(aELEMENT *vary, aELEMENT element);
aELEMENT *vasort(aELEMENT *ary, ptrdiff_t len);

char *stagen(char *stalin, BW *bw, const char *s, char fill);
int exmacro(MACRO *m, int u, int k);
void msgnw(W *w, const char *s);
const char *my_gettext(const char *s);

int wabort(W *w);
MENU *mkmenu(W *loc, W *targ, char **s,
	int (*func)(MENU *m, ptrdiff_t cursor, void *object, int k),
	int (*abrt)(W *w, ptrdiff_t cursor, void *object),
	int (*backs)(MENU *m, ptrdiff_t cursor, void *object),
	ptrdiff_t cursor, void *object, int *notify);
BW *wmkpw(W *w, const char *prompt, B **history,
	int (*func)(W *w, char *s, void *object, int *notify),
	const char *huh,
	int (*abrt)(W *w, void *object),
	int (*tab)(BW *bw, int k),
	void *object, int *notify, struct charmap *map, int file_prompt);
int simple_cmplt(BW *bw, char **list);

extern struct charmap *locale_map;

#endif /* MMENU_STUBS_H */
