#ifndef CCLASS_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define CCLASS_STUBS_H

#include <stddef.h>
#include <stdint.h>

/* Avoid fortified libc wrappers that zig translate-c cannot handle */
int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
int fprintf(void *f, const char *fmt, ...);
int sprintf(char *buf, const char *fmt, ...);
void free(void *p);
void *malloc(unsigned long n);
void *memcpy(void *d, const void *s, unsigned long n);
void *memset(void *s, int c, unsigned long n);
int memcmp(const void *a, const void *b, unsigned long n);
void exit(int status);

typedef int64_t off_t;
typedef void FILE;

extern FILE *__stderrp;
#define stderr __stderrp

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define TO_DIFF_OK(a) ((ptrdiff_t)(a))
#define FALLTHROUGH
#define _(s) (s)

/* Prefer sizeof(a)-1 so zig translate-c keeps string-literal length
 * (sizeof(a)/sizeof(*(a))-1 collapses to 0 under translate-c). */
#define sc(a) (a), ((ptrdiff_t)(sizeof(a) - 1))

#define logmessage_0(fmt) ((void)printf((fmt)))
#define logmessage_1(fmt, a) ((void)printf((fmt), (a)))
#define logmessage_2(fmt, a, b) ((void)printf((fmt), (a), (b)))
#define logmessage_3(fmt, a, b, c) ((void)printf((fmt), (a), (b), (c)))
#define logmessage_4(fmt, a, b, c, d) ((void)printf((fmt), (a), (b), (c), (d)))

/* From cclass.h — radix tree / character class layouts */
#define LEAFSIZE 16
#define LEAFMASK 0xF
#define LEAFSHIFT 0

#define THIRDSIZE 32
#define THIRDMASK 0x1f
#define THIRDSHIFT 4

#define SECONDSIZE 32
#define SECONDMASK 0x1f
#define SECONDSHIFT 9

#define TOPSIZE 68
#define TOPMASK 0x7f
#define TOPSHIFT 14

struct interval {
	int first;
	int last;
};

struct interval_list {
	struct interval_list *next;
	struct interval interval;
	void *map;
};

struct First {
	short entry[TOPSIZE];
};

struct Mid {
	short entry[SECONDSIZE];
};

struct Leaf {
	void *entry[LEAFSIZE];
	int refcount;
};

struct Ileaf {
	int entry[LEAFSIZE];
	int refcount;
};

struct Level {
	int alloc;
	int size;
	union {
		struct Mid *b;
		struct Mid *c;
		struct Leaf *d;
		struct Ileaf *e;
	} table;
};

struct Rset {
	struct First top;
	struct Level second;
	struct Mid mid;
	struct Level third;
};

struct Rtree {
	struct First top;
	struct Level second;
	struct Mid mid;
	struct Level third;
	struct Level leaf;
};

struct Cclass {
	ptrdiff_t size;
	ptrdiff_t len;
	struct interval *intervals;
	struct Rset rset[1];
};

/* Minimal charmap — cclass_remap only reads type + calls from_uni */
struct charmap {
	struct charmap *next;
	const char *name;
	int type;
};

void *joe_malloc(ptrdiff_t size);
void *joe_calloc(ptrdiff_t nmemb, ptrdiff_t size);
void *joe_realloc(void *ptr, ptrdiff_t size);
void joe_free(void *ptr);
void *mcpy(void *a, const void *b, ptrdiff_t len);
void *mmove(void *d, const void *s, ptrdiff_t sz);
void jsort(void *base, ptrdiff_t num, ptrdiff_t size, int (*compar)(const void *a, const void *b));
void ttsig(int sig);
int from_uni(struct charmap *cset, int c);

#endif
