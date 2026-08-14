#ifndef MOUSE_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define MOUSE_STUBS_H

#include <stddef.h>
#include <stdint.h>

/* Avoid fortified libc wrappers that zig translate-c cannot handle */
int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
char *getenv(const char *name);
void free(void *p);
void *malloc(unsigned long n);
void *memcpy(void *d, const void *s, unsigned long n);
void *memset(void *s, int c, unsigned long n);
int strcmp(const char *a, const char *b);
unsigned long strlen(const char *s);

typedef int64_t off_t;
typedef int64_t time_t;
typedef int32_t suseconds_t;

/* Darwin timeval: 16 bytes, tv_sec@0, tv_usec@8 */
struct timeval {
	time_t tv_sec;
	suseconds_t tv_usec;
	int32_t _pad;
};

int gettimeofday(struct timeval *tv, void *tz);

#define MOUSE_XTERM 1
#define HAVE_SYS_TIME_H 1
#define MOUSE_MULTI_THRESH 300

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define TO_DIFF_OK(a) ((ptrdiff_t)(a))
#define FALLTHROUGH
#define _(s) (s)
#define joe_gettext(s) my_gettext((s))

#define TYPETW		0x0100
#define TYPEPW		0x0200
#define TYPEMENU	0x0800
#define TYPEQW		0x1000

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

#define WIND_BW(x, y) do { \
	if (!((y)->watom->what & (TYPETW | TYPEPW))) \
		return -1; \
	(x) = (BW *)(y)->object; \
	} while(0)

/* sizeof(a)-1 so zig translate-c keeps string-literal length */
#define sc(a) (a), ((ptrdiff_t)(sizeof(a) - 1))
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)
#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)

#define LINK(type) struct { type *next; type *prev; }

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
struct lattr_db;
struct high_syntax;
struct charmap;
struct macro; typedef struct macro MACRO;

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
	void *t;
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

/* Layout mirrors gapbuffer/types.zig B (size 632) */
struct b {
	LINK(B) link;
	P *bof;
	P *eof;
	char *name;
	char _pad1[36];
	int orphan;
	int count;
	int changed;
	int backup;
	char _pad_backup[4];
	void *undo;
	char _pad_marks[88];
	OPTIONS o;
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

struct kbd {
	KMAP *curmap;
	KMAP *topmap;
	int seq[16];
	ptrdiff_t x;
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

struct macro {
	char _pad[64];
};

/* --- callees used by mouse.c --- */
MACRO *dokey(KBD *kbd, int n);
int exemac(MACRO *m, int k);

int ttgetc(void);
int ttgetch(void);
void ttputs(const char *s);
void ttputc(char c);
int ttflsh(void);

ptrdiff_t utf8_encode(char *buf, int c);
int from_uni(struct charmap *map, int c);
int to_uni(struct charmap *map, int c);

W *watpos(Screen *t, ptrdiff_t x, ptrdiff_t y);
void menujump(MENU *m, ptrdiff_t x, ptrdiff_t y);
int wgrowup(W *w);
int wgrowdown(W *w);

P *pdup(P *p, const char *where);
void prm(P *p);
void pset(P *d, P *s);
P *pgoto(P *p, off_t loc);
P *pline(P *p, off_t line);
P *pcol(P *p, off_t goalcol);
off_t piscol(P *p);
int pgetc(P *p);
void p_goto_bol(P *p);
P *pnextl(P *p);
int pisbol(P *p);
int piseol(P *p);

int markv(int r);
int umarkb(W *w, int k);
int umarkk(W *w, int k);
int ublkcpy(W *w, int k);
int u_goto_prev(W *w, int k);
int u_goto_next(W *w, int k);

ptrdiff_t slen(const char *s);
const char *my_gettext(const char *s);

extern Screen *maint;
extern int usexmouse;
extern int square;
extern P *markb;
extern P *markk;
extern struct charmap *locale_map;

#endif /* MOUSE_STUBS_H */
