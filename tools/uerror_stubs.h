#ifndef UERROR_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define UERROR_STUBS_H

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
char *strstr(const char *haystack, const char *needle);
char *strchr(const char *s, int c);
int strncmp(const char *a, const char *b, unsigned long n);

typedef int64_t off_t;
typedef int64_t time_t;
typedef void FILE;

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define TO_DIFF_OK(a) ((ptrdiff_t)(a))
#define FALLTHROUGH
#define _(s) (s)
#define joe_gettext(s) my_gettext((s))
#define VERSION "4.8"
#define HAVE_LONG_LONG 1
#define SAVED_SIZE 80
#define stdsiz 8192

#define TYPETW		0x0100
#define TYPEPW		0x0200
#define TYPEMENU	0x0800
#define TYPEQW		0x1000

#define NO_MORE_DATA (-256)
#define CANFLAG_NORESTART 1
#define JOE_MSGBUFSIZE 300

#define WIND_BW(x, y) do { \
	if (!((y)->watom->what & (TYPETW | TYPEPW))) \
		return -1; \
	(x) = (BW *)(y)->object; \
	} while(0)

#define joe_snprintf_0(buf,len,fmt) snprintf((buf),(len),(fmt))
#define joe_snprintf_1(buf,len,fmt,a) snprintf((buf),(len),(fmt),(a))

#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)
#define sc(a) (a), (sizeof(a)/sizeof(char) - 1)

#define zcmp(a, b) strcmp((a), (b))
#define zstr(a, b) strstr((a), (b))
#define zlen(s) ((ptrdiff_t)strlen(s))

#define LINK(type) struct { type *next; type *prev; }

#define joe_isalnum_(map,c) ((map)->is_alnum_((map),(c)))

/* Queue macros (from joe/queue.h) — need ITEM/QUEUE/LAST */
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

struct b; typedef struct b B;
struct p; typedef struct p P;
struct kbd; typedef struct kbd KBD;
struct kmap; typedef struct kmap KMAP;
struct bstack;
struct window; typedef struct window W;
struct screen; typedef struct screen Screen;
struct bw; typedef struct bw BW;
struct tw; typedef struct tw TW;
struct pw; typedef struct pw PW;
struct menu; typedef struct menu MENU;
struct qw; typedef struct qw QW;
struct lattr_db;
struct high_syntax;
struct charmap;
struct macro; typedef struct macro MACRO;

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
	int indentc;
	char _pad_istep[4];
	off_t istep;
	const char *context;
	const char *lmsg;
	const char *rmsg;
	const char *smsg;
	const char *zmsg;
	int linums;
	int hiline;
	int readonly;
	int french;
	int flowed;
	int spaces;
	int crlf;
	int highlight;
	int visiblews;
	int syntax_debug;
	const char *syntax_name;
	struct high_syntax *syntax;
	const char *map_name;
	struct charmap *charmap;
	const char *language;
	int smarthome;
	int indentfirst;
	int smartbacks;
	int purify;
	int picture;
	int highlighter_context;
	int single_quoted;
	int no_double_quoted;
	int c_comment;
	int cpp_comment;
	int hash_comment;
	int vhdl_comment;
	int semi_comment;
	int tex_comment;
	int hex;
	int viewmode;
	int ansi;
	int title;
	const char *text_delimiters;
	const char *cpara;
	const char *cnotpara;
	MACRO *mnew;
	MACRO *mold;
	MACRO *msnew;
	MACRO *msold;
	MACRO *mfirst;
};
typedef struct options OPTIONS;

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

typedef int pid_t;

/* Layout mirrors gapbuffer/types.zig B (size 632): expose orphan + parseone */
struct b {
	char _pad0[16];             /* link */
	P *bof;                     /* 16 */
	P *eof;                     /* 24 */
	char *name;                 /* 32 */
	char _pad1[36];             /* locked..gave_notice */
	int orphan;                 /* 76 */
	int count;                  /* 80 */
	int changed;                /* 84 */
	char _pad2[104];            /* backup..marks */
	OPTIONS o;                  /* 192 */
	P *oldcur;
	P *oldtop;
	P *err;
	char *current_dir;
	int shell_flag;
	int rdonly;
	int internal;
	int scratch;
	int er;
	pid_t pid;
	int out;
	void *vt;
	int raw;
	char _pad_raw[4];
	void *db;
	void (*parseone)(struct charmap *map, const char *s, char **rtn_name, off_t *rtn_line);
};

struct bw {
	W *parent;
	B *b;
	P *top;
	P *cursor;
	off_t offset;
	Screen *t;
	ptrdiff_t h, w, x, y;
	OPTIONS o;
	void *object;
	int lincols;
	off_t curlin;
	int top_changed;
	struct lattr_db *db;
	int shell_flag;
	int pasting;
	int last_viewmode;
	struct { int ww, ai, sp; } saved;
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
	int (*to_lower)(struct charmap *map, int c);
	int (*to_upper)(struct charmap *map, int c);
	char _pad[2684];
};

/* --- alloc / strings / vs --- */
void *joe_malloc(ptrdiff_t size);
void joe_free(void *ptr);
ptrdiff_t slen(const char *s);
int zncmp(const char *a, const char *b, ptrdiff_t len);
off_t ztoo(const char *s);

char *vsmk(ptrdiff_t len);
char *vsadd(char *s, int c);
char *vstrunc(char *s, ptrdiff_t len);
char *vsncpy(char *s, ptrdiff_t len, const char *blk, ptrdiff_t blklen);
char *vsdup(char *s);
void vsrm(char *s);

/* --- queue freelist --- */
void *alitem(void *list, ptrdiff_t itemsize);

/* --- window / bw --- */
void updall(void);
void msgnw(W *w, const char *s);
int unmark(W *w, int k);
int uprevw(W *w, int k);
int doswitch(W *w, char *s, void *obj, int *notify);
void setline(B *b, off_t line);
char *get_cd(W *w);
char *duplicate_backslashes(const char *s, ptrdiff_t len);
void dofollows(void);

/* --- gap buffer / points --- */
P *pdup(P *p, const char *where);
void prm(P *p);
void pset(P *d, P *s);
void p_goto_bol(P *p);
void p_goto_eol(P *p);
int pgetc(P *p);
int pline(P *p, off_t line);
off_t piscol(P *p);
char *brvs(P *p, off_t size);
B *bfind(const char *s);
char *canonical(char *s, int flags);
int hack_check(const char *name);

/* --- utf8 / charmap helpers --- */
ptrdiff_t utf8_encode(char *buf, int c);
int fwrd_c(struct charmap *map, const char **s, ptrdiff_t *len);

/* --- misc --- */
int markv(int r);
const char *my_gettext(const char *s);

/* Externs referenced by uerror.c (not defined therein) */
extern P *markb;
extern P *markk;
extern Screen *maint;
extern char msgbuf[JOE_MSGBUFSIZE];
extern int berror;
extern int opt_mid;

/* NOTE: errbuf, parserr_homeonly, beafter, inserr, delerr, abrerr, saverr,
 * parseone_grep, and the u* command entry points are DEFINED in uerror.c.
 */

#endif /* UERROR_STUBS_H */
