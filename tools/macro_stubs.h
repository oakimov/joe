#ifndef MACRO_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define MACRO_STUBS_H

#include <stddef.h>
#include <stdint.h>

/* Avoid fortified libc wrappers that zig translate-c cannot handle */
int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
int fprintf(void *stream, const char *fmt, ...);
char *fgets(char *s, int n, void *stream);
char *getenv(const char *name);
void free(void *p);
void *memcpy(void *d, const void *s, unsigned long n);
void *memset(void *s, int c, unsigned long n);
int strcmp(const char *a, const char *b);
unsigned long strlen(const char *s);

typedef int64_t off_t;
typedef int64_t time_t;
typedef void FILE;

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define FALLTHROUGH
#define _(s) (s)
#define joe_gettext(s) my_gettext((s))

#define zcmp(a, b) strcmp((a), (b))
#define zlen(s) ((ptrdiff_t)strlen(s))
#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)

#define joe_snprintf_0(buf,len,fmt) snprintf((buf),(len),(fmt))
#define joe_snprintf_1(buf,len,fmt,a) snprintf((buf),(len),(fmt),(a))
#define joe_snprintf_2(buf,len,fmt,a,b) snprintf((buf),(len),(fmt),(a),(b))

#define NO_MORE_DATA (-256)
#define JOE_MSGBUFSIZE 300

#define TYPETW		0x0100
#define TYPEPW		0x0200
#define TYPEMENU	0x0800
#define TYPEQW		0x1000

#define EMINOR		  8
#define EMETA		0x10000

#define WIND_BW(x, y) do { \
  if (!((y)->watom->what & (TYPETW | TYPEPW))) \
    return -1; \
  (x) = (BW *)(y)->object; \
  } while(0)

/* Opaque-ish structs with needed fields/offsets (Darwin LP64) */
struct charmap;
struct window;
struct p;
typedef struct p P;
struct b;
typedef struct b B;

struct cmd {
	const char *name;
	int flag;
	int (*func)(struct window *w, int k);
	struct macro *m;
	int arg;
	const char *negarg;
};
typedef struct cmd CMD;

struct macro {
	ptrdiff_t what;
	int k;
	int flg;
	const CMD *cmd;
	ptrdiff_t n;
	ptrdiff_t size;
	struct macro **steps;
};
typedef struct macro MACRO;

struct recmac {
	struct recmac *next;
	int n;
	MACRO *m;
};

struct watom {
	char _pad0[80];
	int what;
	char _pad1[4];
};
typedef struct watom WATOM;

struct kbd {
	char _pad[88];
};
typedef struct kbd KBD;

/* W: watom@144 object@152; total 200 */
struct window {
	char _pad0[144];
	const WATOM *watom;
	void *object;
	char _pad1[40];
};
typedef struct window W;

/* BW: parent@0 cursor@24; total 488 */
struct bw {
	W *parent;
	char _pad0[16];
	P *cursor;
	char _pad1[456];
};
typedef struct bw BW;

struct screen {
	char _pad0[24];
	W *curwin;
	char _pad1[16];
};
typedef struct screen Screen;

struct qw;
typedef struct qw QW;

/* Alloc / string helpers */
void *joe_malloc(ptrdiff_t size);
void *joe_realloc(void *ptr, ptrdiff_t size);
void joe_free(void *ptr);
char *zdup(const char *s);
int zncmp(const char *a, const char *b, ptrdiff_t len);
ptrdiff_t slen(const char *ary);
void vsrm(char *vary);

int parse_ws(const char **p, int cmt);
int parse_int(const char **p, int *buf);
ptrdiff_t parse_string(const char **p, char *buf, ptrdiff_t len);
ptrdiff_t parse_Zstring(const char **p, int *buf, ptrdiff_t len);
void emit_string(FILE *f, const char *s, ptrdiff_t len);

const CMD *findcmd(const char *s);
int execmd(const CMD *cmd, int k);

void umclear(void);
void undomark(void);
void nungetc(int c);

P *binsc(P *p, int c);
P *binss(P *p, const char *s);
int pgetc(P *p);
P *p_goto_eol(P *p);

void ttputc(unsigned char c); /* may be unused; keep for safety */
void msgnw(W *w, const char *s);
const char *my_gettext(const char *s);

BW *wmkpw(W *w, const char *prompt, B **history,
	int (*func)(W *w, char *s, void *object, int *notify),
	const char *huh, int (*abrt)(W *w, void *object),
	int (*tab)(BW *bw, int k),
	void *object, int *notify, struct charmap *map, int file_prompt);
QW *mkqw(W *w, const char *prompt, ptrdiff_t len,
	int (*func)(W *w, int k, void *object, int *notify),
	int (*abrt)(W *w, void *object), void *object, int *notify);
QW *mkqwna(W *w, const char *prompt, ptrdiff_t len,
	int (*func)(W *w, int k, void *object, int *notify),
	int (*abrt)(W *w, void *object), void *object, int *notify);

double calc(BW *bw, char *s, int secure);
int math_cmplt(BW *bw, int k);

extern Screen *maint;
extern int leave;
extern int nstack;
extern struct charmap *locale_map;
extern struct charmap *utf8_map;
extern const char *merr;
extern time_t timer_macro_delay;
extern MACRO *timer_macro;
extern char msgbuf[];


int utf8_encode(char *buf, int c);
int edloop(int flg);
int upop(BW *bw, int k);
extern int dostaupd;

#endif /* MACRO_STUBS_H */
