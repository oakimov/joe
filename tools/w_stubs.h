#ifndef W_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define W_STUBS_H

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
typedef void FILE;

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define FALLTHROUGH
#define _(s) (s)
#define joe_gettext(s) my_gettext((s))

#define FITMIN		2
#define FITHEIGHT	4
#define JOE_MSGBUFSIZE	300

#define TYPETW		0x0100
#define TYPEPW		0x0200
#define TYPEMENU	0x0800
#define TYPEQW		0x1000

#define BG_COLOR(color) (color)

#define LINK(type) struct { type *next; type *prev; }

/* queue.h macros — rely on ITEM/QUEUE/LAST globals from queue.zig */
extern void *ITEM;
extern void *QUEUE;
extern void *LAST;

#define izque(type,member,item) do { \
	QUEUE = (void *)(item); \
	((type *)QUEUE)->member.prev = (type *)QUEUE; \
	((type *)QUEUE)->member.next = (type *)QUEUE; \
	} while(0)

#define deque(type,member,item) do { \
	ITEM = (void *)(item); \
	((type *)ITEM)->member.prev->member.next = ((type *)ITEM)->member.next; \
	((type *)ITEM)->member.next->member.prev = ((type *)ITEM)->member.prev; \
	} while(0)

#define deque_f(type,member,item) \
	( \
	ITEM=(void *)(item), \
	((type *)ITEM)->member.prev->member.next=((type *)ITEM)->member.next, \
	((type *)ITEM)->member.next->member.prev=((type *)ITEM)->member.prev, \
	(type *)ITEM \
	)

#define qempty(type,member,item) \
	( \
	QUEUE=(void *)(item), \
	(type *)QUEUE==((type *)QUEUE)->member.next \
	)

#define enquef(type,member,queue,item) do { \
	ITEM = (void *)(item); \
	QUEUE = (void *)(queue); \
	((type *)ITEM)->member.next = ((type *)QUEUE)->member.next; \
	((type *)ITEM)->member.prev = (type *)QUEUE; \
	((type *)QUEUE)->member.next->member.prev = (type *)ITEM; \
	((type *)QUEUE)->member.next = (type *)ITEM; \
	} while(0)

#define enqueb(type,member,queue,item) do { \
	ITEM = (void *)(item); \
	QUEUE = (void *)(queue); \
	((type *)ITEM)->member.next = (type *)QUEUE; \
	((type *)ITEM)->member.prev = ((type *)QUEUE)->member.prev; \
	((type *)QUEUE)->member.prev->member.next = (type *)ITEM; \
	((type *)QUEUE)->member.prev = (type *)ITEM; \
	} while(0)

#define demote(type,member,queue,item) \
	enqueb(type,member,(queue),deque_f(type,member,(item)))

/* Forward types */
struct b;
typedef struct b B;
struct kbd;
typedef struct kbd KBD;
struct kmap;
typedef struct kmap KMAP;
struct bstack;
struct window;
typedef struct window W;
struct screen;
typedef struct screen Screen;
struct bw;
typedef struct bw BW;

/* SCRN: li@8, co@16, updtab@784; sizeof=840 (Darwin LP64) */
struct scrn {
	char _pad0[8];
	ptrdiff_t li;
	ptrdiff_t co;
	char _pad1[760];
	int *updtab;
	char _pad2[48];
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

/* Window: sizeof=200; kbd@136, watom@144, object@152 (Darwin LP64) */
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

/* BW: b@8; sizeof=488 */
struct bw {
	W *parent;
	B *b;
	char _pad[472];
};

/* KBD opaque-ish (sizeof 88) — only passed through */
struct kbd {
	char _pad[88];
};

#define WIND_BW(x, y) do { \
	if (!((y)->watom->what & (TYPETW | TYPEPW))) \
		return -1; \
	(x) = (BW *)(y)->object; \
	} while(0)

void *joe_malloc(ptrdiff_t size);
void joe_free(void *ptr);
void *msetI(void *d, int c, ptrdiff_t sz);
ptrdiff_t diff_min(ptrdiff_t a, ptrdiff_t b);

void nscrldn(SCRN *t, ptrdiff_t top, ptrdiff_t bot, ptrdiff_t amnt);
void nscrlup(SCRN *t, ptrdiff_t top, ptrdiff_t bot, ptrdiff_t amnt);
void nredraw(SCRN *t);
ptrdiff_t fmtlen(const char *s);
void genfmt(SCRN *t, ptrdiff_t x, ptrdiff_t y, ptrdiff_t ofst, const char *s, int flg, int trunc, int atr);

KBD *mkkbd(KMAP *kmap);
void rmkbd(KBD *k);
KMAP *kmap_getcontext(const char *name);

void windie(W *w);
int usplitw(W *w, int k);
int get_buffer_in_window(BW *bw, B *b);
B *bfind(const char *s);
const char *my_gettext(const char *s);

extern int skiptop;
extern volatile int dostaupd;
extern int leave;
extern Screen *maint;
extern int staen;
extern WATOM watomtw;
extern B *errbuf;

#endif /* W_STUBS_H */
