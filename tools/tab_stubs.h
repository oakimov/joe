#ifndef TAB_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define TAB_STUBS_H

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
char *strcpy(char *d, const char *s);

typedef int64_t off_t;
typedef int64_t time_t;
typedef uint64_t ino_t;
typedef unsigned int mode_t;

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define TO_DIFF_OK(a) ((ptrdiff_t)(a))
#define FALLTHROUGH
#define _(s) (s)
#define joe_gettext(s) my_gettext((s))
#define NO_MORE_DATA (-256)

#define TYPETW		0x0100
#define TYPEPW		0x0200
#define TYPEMENU	0x0800
#define TYPEQW		0x1000

/* Darwin/macOS arm64 struct stat (size 144) — needs st_ino + st_mode */
struct timespec_joe {
	time_t tv_sec;
	long tv_nsec;
};
struct stat {
	unsigned int st_dev;		/* 0 */
	unsigned short st_mode;		/* 4 */
	unsigned short st_nlink;	/* 6 */
	ino_t st_ino;			/* 8 */
	unsigned int st_uid;		/* 16 */
	unsigned int st_gid;		/* 20 */
	unsigned int st_rdev;		/* 24 */
	unsigned int _pad_rdev;		/* 28 */
	struct timespec_joe st_atimespec; /* 32 */
	struct timespec_joe st_mtimespec; /* 48 */
	struct timespec_joe st_ctimespec; /* 64 */
	struct timespec_joe st_birthtimespec; /* 80 */
	int64_t st_size;		/* 96 */
	int64_t st_blocks;		/* 104 */
	int st_blksize;			/* 112 */
	unsigned int st_flags;		/* 116 */
	unsigned int st_gen;		/* 120 */
	int st_lspare;			/* 124 */
	int64_t st_qspare[2];		/* 128 */
};

#define S_IFMT  0170000
#define S_IFDIR 0040000

int stat(const char *path, struct stat *buf);

#define LINK(type) struct { type *next; type *prev; }

#define zcmp(a, b) strcmp((a), (b))
#define zlen(s) ((ptrdiff_t)strlen(s))

#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sSiz(a) (*((ptrdiff_t *)(a) - 2))
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)
#define sc(a) (a), ((ptrdiff_t)(sizeof(a)/sizeof(*(a)) - 1))

#define aLen(a) (*((ptrdiff_t *)(a) - 1))
#define aLEN(a) ((a) ? aLen(a) : 0)

struct b; typedef struct b B;
struct p; typedef struct p P;
struct undo; typedef struct undo UNDO;
struct undorec; typedef struct undorec UNDOREC;
struct kbd; typedef struct kbd KBD;
struct kmap; typedef struct kmap KMAP;
struct bstack;
struct window; typedef struct window W;
struct screen; typedef struct screen Screen;
struct menu; typedef struct menu MENU;
struct bw; typedef struct bw BW;
struct charmap;
struct options; typedef struct options OPTIONS;
struct high_syntax;
struct macro; typedef struct macro MACRO;
struct pw; typedef struct pw PW;

/* Minimal P used by tab (byte/xcol/cursor ops) — size matches gapbuffer P=112 */
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

/* OPTIONS size 344 @ B.o offset 192; B size 632 */
struct options {
	char _pad[344];
};

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
	UNDO *undo;
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
	int pid;
	int out;
	void *vt;
	int raw;
	char _pad_raw[4];
	void *db;
	void (*parseone)(struct charmap *map, const char *s, char **rtn_name, off_t *rtn_line);
};

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

struct bw {
	W *parent;
	B *b;
	P *top;
	P *cursor;
	char _pad[456]; /* sizeof(BW)=488 on Darwin */
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
	char _pad[2692];
};

void *joe_malloc(ptrdiff_t size);
void joe_free(void *ptr);
void *mset(void *d, unsigned char c, ptrdiff_t sz);

ptrdiff_t slen(const char *s);
char *vsncpy(char *s, ptrdiff_t len, const char *blk, ptrdiff_t blklen);
char *vsadd(char *s, char ch);
void vsrm(char *s);
char **vatrunc(char **a, ptrdiff_t len);
char **vaset(char **a, ptrdiff_t idx, char *s);
void varm(char **a);
void vasort(char **a, ptrdiff_t len);
void vauniq(char **a);

P *pdup(P *p, const char *tr);
P *pset(P *d, P *s);
void prm(P *p);
void p_goto_eol(P *p);
void p_goto_bol(P *p);
void pgoto(P *p, off_t loc);
int pgetc(P *p);
int prgetc(P *p);
int brch(P *p);
off_t piscol(P *p);
char *brvs(P *p, off_t amnt);
void bdel(P *from, P *to);
P *binsm(P *p, const char *blk, ptrdiff_t amnt);
P *binsmq(P *p, const char *blk, ptrdiff_t amnt);

char *pwd(void);
int chpwd(const char *path);
char **rexpnd(const char *word);
char **rexpnd_users(const char *word);
char **rexpnd_cmd_cd(const char *word);
char **rexpnd_cmd_path(const char *word);
char *namprt(const char *path);
char *dirprt(const char *path);
char *begprt(const char *path);
char *endprt(const char *path);
int isreg(const char *s);
char *canonical(char *s, int flags);
char *dequotevs(char *s);

MENU *mkmenu(W *loc, W *targ, char **s,
	int (*func)(MENU *m, ptrdiff_t cursor, void *object, int k),
	int (*abrt)(W *w, ptrdiff_t cursor, void *object),
	int (*backs)(MENU *m, ptrdiff_t cursor, void *object),
	ptrdiff_t cursor, void *object, int *notify);
void ldmenu(MENU *m, char **s, ptrdiff_t cursor);
char *mcomplete(MENU *m);
int wabort(W *w);
void msgnw(W *w, const char *s);
void ttputc(int c);

const char *my_gettext(const char *s);

extern WATOM watommenu;
extern int menu_above;
extern int smode;

/* DEFINED in tab.c — do not extern:
 * menu_explorer, menu_jump, cmplt_file, cmplt_file_in, cmplt_file_out, cmplt_command
 */

#endif /* TAB_STUBS_H */
