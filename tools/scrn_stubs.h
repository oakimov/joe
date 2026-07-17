#ifndef SCRN_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define SCRN_STUBS_H

#include <stddef.h>
#include <stdint.h>

/* Avoid fortified libc wrappers that zig translate-c cannot handle */
int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
int fprintf(void *stream, const char *fmt, ...);
int fputs(const char *s, void *stream);
int fflush(void *stream);
char *getenv(const char *name);
void free(void *p);
void *memcpy(void *d, const void *s, unsigned long n);
void *memset(void *s, int c, unsigned long n);
int strcmp(const char *a, const char *b);
unsigned long strlen(const char *s);

typedef int64_t off_t;
typedef void FILE;

extern FILE *stdin;
extern FILE *stdout;
extern FILE *stderr;

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define FALLTHROUGH
#define REGISTER
#define _(s) (s)
#define joe_gettext(s) (s)
#define ifhave have

#define COMPOSE 4

/* Attribute bits (non-MSDOS path from scrn.h) */
#define CONTEXT_COMMENT 1
#define CONTEXT_STRING 2
#define CONTEXT_MASK (CONTEXT_COMMENT+CONTEXT_STRING)

#define DOUBLE_UNDERLINE 8
#define CROSSED_OUT 16
#define ITALIC 32
#define INVERSE 64
#define UNDERLINE 128
#define BOLD 256
#define BLINK 512
#define DIM 1024
#define AT_MASK (INVERSE+UNDERLINE+BOLD+BLINK+DIM+ITALIC+DOUBLE_UNDERLINE+CROSSED_OUT)

#define BG_SHIFT 11
#define BG_VALUE (255<<BG_SHIFT)
#define BG_NOT_DEFAULT (256<<BG_SHIFT)
#define BG_TRUECOLOR (512<<BG_SHIFT)
#define BG_MASK (1023<<BG_SHIFT)
#define BG_DEFAULT (0<<BG_SHIFT)
#define BG_COLOR(color) (color)

#define FG_SHIFT 21
#define FG_VALUE (255<<FG_SHIFT)
#define FG_NOT_DEFAULT (256<<FG_SHIFT)
#define FG_TRUECOLOR (512<<FG_SHIFT)
#define FG_MASK (1023<<FG_SHIFT)
#define FG_DEFAULT (0<<FG_SHIFT)

#define BG_BLACK	(BG_NOT_DEFAULT|(0<<BG_SHIFT))
#define BG_RED		(BG_NOT_DEFAULT|(1<<BG_SHIFT))
#define BG_GREEN	(BG_NOT_DEFAULT|(2<<BG_SHIFT))
#define BG_YELLOW	(BG_NOT_DEFAULT|(3<<BG_SHIFT))
#define BG_BLUE		(BG_NOT_DEFAULT|(4<<BG_SHIFT))
#define BG_MAGENTA	(BG_NOT_DEFAULT|(5<<BG_SHIFT))
#define BG_CYAN		(BG_NOT_DEFAULT|(6<<BG_SHIFT))
#define BG_WHITE	(BG_NOT_DEFAULT|(7<<BG_SHIFT))
#define BG_BBLACK	(BG_NOT_DEFAULT|(8<<BG_SHIFT))
#define BG_BRED		(BG_NOT_DEFAULT|(9<<BG_SHIFT))
#define BG_BGREEN	(BG_NOT_DEFAULT|(10<<BG_SHIFT))
#define BG_BYELLOW	(BG_NOT_DEFAULT|(11<<BG_SHIFT))
#define BG_BBLUE	(BG_NOT_DEFAULT|(12<<BG_SHIFT))
#define BG_BMAGENTA	(BG_NOT_DEFAULT|(13<<BG_SHIFT))
#define BG_BCYAN	(BG_NOT_DEFAULT|(14<<BG_SHIFT))
#define BG_BWHITE	(BG_NOT_DEFAULT|(15<<BG_SHIFT))

#define FG_BWHITE	(FG_NOT_DEFAULT|(15<<FG_SHIFT))
#define FG_BCYAN	(FG_NOT_DEFAULT|(14<<FG_SHIFT))
#define FG_BMAGENTA	(FG_NOT_DEFAULT|(13<<FG_SHIFT))
#define FG_BBLUE	(FG_NOT_DEFAULT|(12<<FG_SHIFT))
#define FG_BYELLOW	(FG_NOT_DEFAULT|(11<<FG_SHIFT))
#define FG_BGREEN	(FG_NOT_DEFAULT|(10<<FG_SHIFT))
#define FG_BRED		(FG_NOT_DEFAULT|(9<<FG_SHIFT))
#define FG_BBLACK	(FG_NOT_DEFAULT|(8<<FG_SHIFT))
#define FG_WHITE	(FG_NOT_DEFAULT|(7<<FG_SHIFT))
#define FG_CYAN		(FG_NOT_DEFAULT|(6<<FG_SHIFT))
#define FG_MAGENTA	(FG_NOT_DEFAULT|(5<<FG_SHIFT))
#define FG_BLUE		(FG_NOT_DEFAULT|(4<<FG_SHIFT))
#define FG_YELLOW	(FG_NOT_DEFAULT|(3<<FG_SHIFT))
#define FG_GREEN	(FG_NOT_DEFAULT|(2<<FG_SHIFT))
#define FG_RED		(FG_NOT_DEFAULT|(1<<FG_SHIFT))
#define FG_BLACK	(FG_NOT_DEFAULT|(0<<FG_SHIFT))


struct hentry {
	ptrdiff_t next;
	ptrdiff_t loc;
};

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

/* Full SCRN layout — Darwin LP64 total 840 (matches sizeof(SCRN)) */
struct scrn {
	CAP *cap;

	ptrdiff_t li;
	ptrdiff_t co;

	const char *ti;
	const char *cl;
	const char *cd;
	const char *te;
	const char *brp;
	const char *bre;

	int haz;
	int os;
	int eo;
	int ul;
	int am;
	int xn;

	const char *so;
	const char *se;

	const char *us;
	const char *ue;
	const char *uc;

	int ms;
	int _pad_ms;

	const char *mb;
	const char *md;
	const char *mh;
	const char *mr;
	const char *stricken;
	const char *dunderline;
	const char *me;

	const char *ZH;
	const char *ZR;

	const char *Sb;
	const char *Sf;
	int Co;
	int Tc;
	int ut;

	int da, db;
	int _pad_db;

	const char *al, *dl, *AL, *DL;
	const char *cs;
	int rr;
	int _pad_rr;
	const char *sf, *SF, *sr, *SR;

	const char *dm, *dc, *DC, *ed;
	const char *im, *ic, *IC, *ip, *ei;
	int mi;
	int _pad_mi;

	const char *bs;
	ptrdiff_t cbs;
	const char *lf;
	ptrdiff_t clf;
	const char *up;
	ptrdiff_t cup;
	const char *nd;

	const char *ta;
	ptrdiff_t cta;
	const char *bt;
	ptrdiff_t cbt;
	ptrdiff_t tw;

	const char *ho;
	ptrdiff_t cho;
	const char *ll;
	ptrdiff_t cll;
	const char *cr;
	ptrdiff_t ccr;
	const char *RI;
	ptrdiff_t cRI;
	const char *LE;
	ptrdiff_t cLE;
	const char *UP;
	ptrdiff_t cUP;
	const char *DO;
	ptrdiff_t cDO;
	const char *ch;
	ptrdiff_t cch;
	const char *cv;
	ptrdiff_t ccv;
	const char *cV;
	ptrdiff_t ccV;
	const char *cm;
	ptrdiff_t ccm;

	const char *ce;
	ptrdiff_t cce;

	int assume_256;
	int truecolor;
	int *palette;

	int scroll;
	int insdel;

	int (*scrn)[COMPOSE];
	int *attr;
	ptrdiff_t x, y;
	ptrdiff_t top, bot;
	int attrib;
	int ins;

	int *updtab;
	int avattr;
	int _pad_avattr;
	ptrdiff_t *sary;

	int *compose;
	ptrdiff_t *ofst;
	struct hentry *htab;
	struct hentry *ary;
};
typedef struct scrn SCRN;

struct charmap {
	struct charmap *next;
	const char *name;
	int type;
	int (*is_punct)(struct charmap *map, int c);
	int (*is_print)(struct charmap *map, int c);
	char _pad[2752 - 40];
};

#define joe_isprint(map,c) ((map)->is_print((map),(c)))

void *joe_malloc(ptrdiff_t size);
void *joe_calloc(ptrdiff_t nmemb, ptrdiff_t size);
void *joe_realloc(void *ptr, ptrdiff_t size);
void joe_free(void *ptr);
void *mmove(void *d, const void *s, ptrdiff_t sz);
void *msetI(void *d, int c, ptrdiff_t sz);
void *msetD(void *d, ptrdiff_t c, ptrdiff_t sz);

CAP *setcap(CAP *cap, long baud, void (*out)(void *, char), void *outptr);
const char *jgetstr(CAP *cap, const char *name);
int getflag(CAP *cap, const char *name);
int getnum(CAP *cap, const char *name);
void rmcap(CAP *cap);
void texec(CAP *cap, const char *s, ptrdiff_t l, ptrdiff_t a0, ptrdiff_t a1, ptrdiff_t a2, ptrdiff_t a3);
ptrdiff_t tcost(CAP *cap, const char *s, ptrdiff_t l, ptrdiff_t a0, ptrdiff_t a1, ptrdiff_t a2, ptrdiff_t a3);

void ttopen(void);
void ttclose(void);
void ttflsh(void);
void ttputs(const char *s);
void ttgtsz(ptrdiff_t *x, ptrdiff_t *y);
void signrm(void);
void mouseopen(void);
void mouseclose(void);

extern long tty_baud;
extern ptrdiff_t obufp;
extern ptrdiff_t obufsiz;
extern char *obuf;
extern int have;
extern int leave;

#define ttputc(c) do { obuf[obufp++] = (c); if (obufp == obufsiz) ttflsh(); } while (0)

extern struct charmap *locale_map;
extern int dspasis;
extern int opt_mid;
extern int opt_left;
extern int opt_right;
extern int dostaupd;

int sprintf(char *buf, const char *fmt, ...);
#define joe_snprintf_1(buf,len,fmt,a) snprintf((buf),(unsigned long)(len),(fmt),(a))
#define joe_snprintf_3(buf,len,fmt,a,b,c) snprintf((buf),(unsigned long)(len),(fmt),(a),(b),(c))

#define zcmp(a, b) strcmp((a), (b))
int zicmp(const char *a, const char *b);
int ztoi(const char *s);
int unictrl(int c);
void utf8_putc(int c);

struct utf8_sm {
	char buf[8];
	ptrdiff_t ptr;
	int state;
	int accu;
};
void utf8_init(struct utf8_sm *sm);
int utf8_decode(struct utf8_sm *sm, char c);

ptrdiff_t utf8_encode(char *buf, int c);
int to_uni(struct charmap *cset, int c);
int from_uni(struct charmap *cset, int c);
int joe_wcwidth(int wide, int c);

int cclass_lookup(const void *table, int c);
struct Cclass_stub { char _pad[512]; };
extern struct Cclass_stub cclass_combining[1];

/* Forward decls for intra-translation-unit calls */
int clrins(SCRN *t);
int cpos(SCRN *t, ptrdiff_t x, ptrdiff_t y);
int nresize(SCRN *t, ptrdiff_t w, ptrdiff_t h);
void nredraw(SCRN *t);

#endif /* SCRN_STUBS_H */