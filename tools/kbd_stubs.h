#ifndef KBD_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define KBD_STUBS_H

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

#define zcmp(a, b) strcmp((a), (b))
#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)

/* Mouse / special keycodes — Plane 16 Private Use (types.h) */
#define KEY_MDOWN	0x100000
#define KEY_MUP		0x100001
#define KEY_MDRAG	0x100002
#define KEY_M2DOWN	0x100003
#define KEY_M2UP	0x100004
#define KEY_M2DRAG	0x100005
#define KEY_M3DOWN	0x100006
#define KEY_M3UP	0x100007
#define KEY_M3DRAG	0x100008
#define KEY_MWUP	0x100009
#define KEY_MWDOWN	0x10000A
#define KEY_MIDDLEUP	0x10000B
#define KEY_MIDDLEDOWN	0x10000C

/* Forward types */
struct Rtree {
	char _pad[248];
};
struct interval {
	int first;
	int last;
};
struct interval_list {
	struct interval_list *next;
	struct interval interval;
	void *map;
};

struct macro;
typedef struct macro MACRO;

struct cmd;
typedef struct cmd CMD;

struct cap {
	char _pad[88];
};
typedef struct cap CAP;

struct kmap {
	ptrdiff_t what;
	struct Rtree rtree;
	struct interval_list *src;
	void *dflt;
	int rtree_version;
	int src_version;
};
typedef struct kmap KMAP;

struct kbd {
	KMAP *curmap;
	KMAP *topmap;
	int seq[16];
	ptrdiff_t x;
};
typedef struct kbd KBD;

struct context {
	struct context *next;
	char *name;
	KMAP *kmap;
};

struct charmap;
struct b;
typedef struct b B;
struct bw;
typedef struct bw BW;

/* W: kbd must be at offset 136; total size 200 (Darwin LP64) */
struct window {
	char _pad0[136];
	KBD *kbd;
	char _pad1[56];
};
typedef struct window W;

/* Alloc / string helpers (Zig/C hybrid) */
void *joe_malloc(ptrdiff_t size);
void *joe_calloc(ptrdiff_t nmemb, ptrdiff_t size);
void joe_free(void *ptr);
char *zdup(const char *s);
int zhtoi(const char *s);
ptrdiff_t slen(const char *ary);
char *vsncpy(char *vary, ptrdiff_t pos, const char *array, ptrdiff_t len);
void vsrm(char *vary);
void **vaadd(void **vary, void *el);

int utf8_decode_string(const char *s);
const char *jgetstr(CAP *cap, const char *name);
char *tcompile(CAP *cap, const char *s, ptrdiff_t a0, ptrdiff_t a1, ptrdiff_t a2, ptrdiff_t a3);

void rtree_init(struct Rtree *r);
void rtree_clr(struct Rtree *r);
void *rtree_lookup(struct Rtree *r, int ch);
void rtree_opt(struct Rtree *r);
void rtree_build(struct Rtree *r, struct interval_list *l);

struct interval_list *interval_add(struct interval_list *list, int first, int last, void *map);
void *interval_lookup(struct interval_list *list, void *dflt, int ch);

extern ptrdiff_t obufp;
extern ptrdiff_t obufsiz;
extern char *obuf;
void ttflsh(void);
#define ttputc(c) do { obuf[obufp++] = (c); if (obufp == obufsiz) ttflsh(); } while (0)
void msgnw(W *w, const char *s);
const char *my_gettext(const char *s);
BW *wmkpw(W *w, const char *prompt, B **history,
	int (*func)(W *w, char *s, void *object, int *notify),
	const char *huh, int (*abrt)(W *w, void *object),
	int (*tab)(BW *bw, int k),
	void *object, int *notify, struct charmap *map, int file_prompt);
int simple_cmplt(BW *bw, char **list);

extern struct charmap *locale_map;

#endif /* KBD_STUBS_H */
