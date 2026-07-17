#ifndef TERMCAP_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define TERMCAP_STUBS_H

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

struct stat {
	long st_mtime;
	char _pad[128];
};

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define FALLTHROUGH
#define _(s) (s)
#define joe_gettext(s) (s)
#define JOERC ""

#define zcmp(a, b) strcmp((a), (b))
#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), ((ptrdiff_t)strlen(a))
#define sc(a) (a), ((ptrdiff_t)(sizeof(a) / sizeof(char) - 1))

#define logmessage_0(fmt) ((void)(fmt))
#define logmessage_1(fmt, a) ((void)(fmt), (void)(a))

struct sortentry {
	char *name;
	char *value;
};

struct cap {
	char *tbuf;
	struct sortentry *sort;
	ptrdiff_t sortlen;
	char *abuf;
	char *abufp;
	long div;
	long baud;
	const char *pad;
	void (*out)(void *, char);
	void *outptr;
	int dopadding;
};
typedef struct cap CAP;

void *joe_malloc(ptrdiff_t size);
void *joe_realloc(void *ptr, ptrdiff_t size);
void joe_free(void *ptr);
void *mmove(void *d, const void *s, ptrdiff_t sz);

int ztoi(const char *s);
int zhtoi(const char *s);
ptrdiff_t slen(const char *ary);

char *vsmk(ptrdiff_t len);
void vsrm(char *vary);
char *vstrunc(char *vary, ptrdiff_t len);
char *vsncpy(char *vary, ptrdiff_t pos, const char *array, ptrdiff_t len);
char *vsset(char *vary, ptrdiff_t pos, char el);
char *vsadd(char *vary, char el);
char **vawords(char **a, const char *s, ptrdiff_t len, const char *sep, ptrdiff_t seplen);
void varm(char **vary);

FILE *fopen(const char *path, const char *mode);
int fclose(FILE *stream);
char *fgets(char *s, int n, FILE *stream);
int getc(FILE *stream);
int ungetc(int c, FILE *stream);
int fseek(FILE *stream, long offset, int whence);
int fseeko(FILE *stream, off_t offset, int whence);
int fstat(int fd, struct stat *buf);
int fileno(FILE *stream);
int stat(const char *path, struct stat *buf);

/* Exported ABI (also needed as forward decls for my_getcap) */
extern int dopadding;
extern char *joeterm;
CAP *my_getcap(char *name, long baud, void (*out)(void *, char), void *outptr);
CAP *setcap(CAP *cap, long baud, void (*out)(void *, char), void *outptr);
const char *jgetstr(CAP *cap, const char *name);
int getflag(CAP *cap, const char *name);
int getnum(CAP *cap, const char *name);
void rmcap(CAP *cap);
void texec(CAP *cap, const char *s, ptrdiff_t l, ptrdiff_t a0, ptrdiff_t a1, ptrdiff_t a2, ptrdiff_t a3);
ptrdiff_t tcost(CAP *cap, const char *s, ptrdiff_t l, ptrdiff_t a0, ptrdiff_t a1, ptrdiff_t a2, ptrdiff_t a3);
char *tcompile(CAP *cap, const char *s, ptrdiff_t a0, ptrdiff_t a1, ptrdiff_t a2, ptrdiff_t a3);

#endif /* TERMCAP_STUBS_H */
