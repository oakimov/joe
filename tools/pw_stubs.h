#ifndef PW_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define PW_STUBS_H

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
unsigned long strspn(const char *s, const char *accept);

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

#define FITHEIGHT	4

#define TYPETW		0x0100
#define TYPEPW		0x0200
#define TYPEMENU	0x0800
#define TYPEQW		0x1000

#define BG_COLOR(color) (color)
#define YES_CODE (-10)
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

#define LINK(type) struct { type *next; type *prev; }

#define clear_state(s) (((s)->saved_s = 0), ((s)->state = 0), ((s)->stack = 0), ((s)->delim_stack = 0))

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
	char _pad1[24];
};

typedef int pid_t;

struct b {
	char _pad0[16];
	P *bof;                 /* 16 */
	P *eof;                 /* 24 */
	char *name;             /* 32 */
	char _pad1[40];         /* 40 */
	int count;              /* 80 */
	int changed;            /* 84 */
	char _pad2[104];        /* 88 */
	OPTIONS o;              /* 192 */
	P *oldcur;              /* 536 */
	P *oldtop;              /* 544 */
	P *err;                 /* 552 */
	char *current_dir;      /* 560 */
	char _pad3[4];          /* 568 → 572 */
	int rdonly;             /* 572 */
	int internal;           /* 576 */
	int scratch;            /* 580 */
	int er;                 /* 584 */
	pid_t pid;              /* 588 */
	int out;                /* 592 */
	char _pad5[4];          /* 596 → 600 */
	void *vt;               /* 600 */
	char _pad6[24];         /* 608 → 632 */
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


struct bstack {
	struct bstack *next;
	B *b;
	P *cursor;
	P *top;
};
struct tw {
	char *stalin;
	char *staright;
	int staon;
	char _pad_staon[4];
	off_t prevline;
	int changed;
	char _pad_changed[4];
	B *prev_b;
};

struct kbd {
	KMAP *curmap;
	KMAP *topmap;
	int seq[16];
	ptrdiff_t x;
};

struct highlight_state {
	void *stack;
	void *delim_stack;
	const int *saved_s;
	int state;
	char _pad[4];
};
typedef struct highlight_state HIGHLIGHT_STATE;

struct high_syntax {
	void *next;
	const char *name;
	char _pad[120];
};

struct charmap {
	void *next;                 /* 0 */
	const char *name;           /* 8 */
	int type;                   /* 16 */
	char _pad_type[4];          /* 20 → 24 */
	int (*is_punct)(struct charmap *map, int c);   /* 24 */
	int (*is_print)(struct charmap *map, int c);   /* 32 */
	int (*is_space)(struct charmap *map, int c);   /* 40 */
	int (*is_alpha_)(struct charmap *map, int c);  /* 48 */
	int (*is_alnum_)(struct charmap *map, int c);  /* 56 */
	char _pad[2692];            /* keep rough size; only is_alnum_ needed */
};

struct recmac {
	struct recmac *next;
	int n;
	char _pad[12];
};

struct tm {
	int tm_sec;
	int tm_min;
	int tm_hour;
	int tm_mday;
	int tm_mon;
	int tm_year;
	int tm_wday;
	int tm_yday;
	int tm_isdst;
	char _pad[20];
};


struct pw {
	int (*pfunc)(W *w, char *s, void *object, int *notify);
	int (*abrt)(W *w, void *object);
	int (*tab)(BW *bw, int k);
	char *prompt;
	ptrdiff_t promptlen;
	ptrdiff_t promptofst;
	B *hist;
	void *object;
	int file_prompt;
	char _pad_file_prompt[4];
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

void *joe_malloc(ptrdiff_t size);
void joe_free(void *ptr);
ptrdiff_t slen(const char *s);

char *vsmk(ptrdiff_t len);
char *vsadd(char *s, int c);
char *vstrunc(char *s, ptrdiff_t len);
char *vsncpy(char *s, ptrdiff_t len, const char *blk, ptrdiff_t blklen);
char *vsfill(char *s, ptrdiff_t len, int c, ptrdiff_t amnt);
void vsrm(char *s);

void nscrldn(SCRN *t, ptrdiff_t top, ptrdiff_t bot, ptrdiff_t amnt);
void nscrlup(SCRN *t, ptrdiff_t top, ptrdiff_t bot, ptrdiff_t amnt);
ptrdiff_t fmtlen(const char *s);
ptrdiff_t fmtpos(const char *s, ptrdiff_t goal);
void genfmt(SCRN *t, ptrdiff_t x, ptrdiff_t y, ptrdiff_t ofst, const char *s, int flg, int trunc, int atr);

W *wcreate(Screen *t, const WATOM *watom, W *where, W *target, W *after, ptrdiff_t lines, const char *huh, int *notify);
int wabort(W *w);
void wfit(Screen *t);
void wnext(Screen *t);
void wredraw(W *w);
void updall(void);
ptrdiff_t getgrouph(W *w);
W *findbotw(W *w);
int demotegroup(W *w);
int countmain(Screen *t);

BW *bwmk(W *window, B *b, int prompt);
void bwmove(BW *w, ptrdiff_t x, ptrdiff_t y);
void bwresz(BW *w, ptrdiff_t wi, ptrdiff_t he);
void bwrm(BW *w);
void bwins(BW *w, off_t l, off_t n, int flg);
void bwdel(BW *w, off_t l, off_t n, int flg);
void bwgen(BW *w, int linums, int linchg);
void bwgenh(BW *w);
void bwfllw(W *w);
void orphit(BW *bw);
int calclincols(BW *bw);
int get_buffer_in_window(BW *bw, B *b);

P *pdup(P *p, const char *where);
void prm(P *p);
void pset(P *d, P *s);
void p_goto_bol(P *p);
int pline(P *p, off_t line);
off_t piscol(P *p);
int piseof(P *p);
int brch(P *p);

B *borphan(void);
struct high_syntax *load_syntax(const char *name);
struct lattr_db *find_lattr_db(B *b, struct high_syntax *y);
HIGHLIGHT_STATE lattr_get(struct lattr_db *db, struct high_syntax *y, P *p, ptrdiff_t line);
HIGHLIGHT_STATE parse(struct high_syntax *syntax, P *line, HIGHLIGHT_STATE state, struct charmap *charmap);

void my_iconv1(char *dest, ptrdiff_t destsiz, struct charmap *dest_map, const char *s);
char *simplify_prefix(const char *path);
const char *get_status(BW *bw, char *s);
int markv(int r);
void genexmsg(BW *bw, int saved, char *name);
int okrepl(BW *bw);
int yncheck(const char *string, int c);
int joe_wcwidth(int wide, int c);
int ukillpid(W *w, int k);
const char *my_gettext(const char *s);

QW *mkqw(W *w, const char *prompt, ptrdiff_t len,
	int (*func)(W *w, int k, void *object, int *notify),
	int (*abrt)(W *w, void *object),
	void *object, int *notify);

time_t time(time_t *t);
struct tm *localtime(const time_t *t);
char *ctime(const time_t *t);

extern int skiptop;
extern volatile int dostaupd;
extern int leave;
extern Screen *maint;
extern B *errbuf;
extern char stdbuf[stdsiz];
extern struct charmap *locale_map;
extern struct recmac *recmac;
extern P *markb;
extern P *markk;
extern char *exmsg;
extern int have;

extern int square;
extern const char *yes_key;
extern WATOM watomtw;
int rtntw(W *w);
int utypew(W *w, int k);
int *msetI(int *dest, int c, ptrdiff_t sz);

#define ifhave have

#define PWFLAG_FILENAME 1
#define PWFLAG_UPDATE_CD 2
#define PWFLAG_SEED_CD 4
#define PWFLAG_COMMAND 8
#define CANFLAG_NORESTART 1
#define NO_MORE_DATA (-256)

#define aLen(a) (*((ptrdiff_t *)(a) - 1))
#define aLEN(a) ((a) ? aLen(a) : 0)

#define joe_isalnum_(map,c) ((map)->is_alnum_((map),(c)))

#define ttputc(c) do { obuf[obufp++] = (c); if (obufp == obufsiz) ttflsh(); } while (0)


char *zdup(const char *s);
char *dirprt(const char *path);
char *canonical(char *s, int flags);
char *brvs(P *p, off_t size);
int brc(P *p);
int pgetc(P *p);
int prgetc(P *p);
void p_goto_eol(P *p);
void p_goto_eof(P *p);
int pnextl(P *p);
B *bmk(B *prop);
B *bcpy(P *from, P *to);
void bdel(P *from, P *to);
void binsb(P *p, B *b);
void binsc(P *p, int c);
void binsm(P *p, const char *blk, ptrdiff_t size);
void binsmq(P *p, const char *blk, ptrdiff_t size);

char **vaadd(char **vary, char *element);
void varm(char **vary);
int rmatch(const char *pattern, const char *s);
int isreg(const char *s);
int cmplt_file(BW *bw, int k);
MENU *mkmenu(W *loc, W *targ, char **s,
	int (*func)(MENU *m, ptrdiff_t cursor, void *object, int k),
	int (*abrt)(W *w, ptrdiff_t cursor, void *object),
	int (*backs)(MENU *m, ptrdiff_t cursor, void *object),
	ptrdiff_t cursor, void *object, int *notify);
char *mcomplete(MENU *m);
void bwfllwt(W *w);
void ttflsh(void);

extern ptrdiff_t obufp;
extern ptrdiff_t obufsiz;
extern char *obuf;
extern int smode;
extern int menu_above;
extern int menu_jump;
extern WATOM watommenu;


#endif /* PW_STUBS_H */
