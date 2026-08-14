#ifndef UFILE_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define UFILE_STUBS_H

#include <stddef.h>
#include <stdint.h>

/* Avoid fortified libc wrappers that zig translate-c cannot handle */
int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
int fprintf(void *f, const char *fmt, ...);
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
typedef void FILE;
typedef int mode_t;
typedef unsigned int uid_t;
typedef unsigned int gid_t;

/* POSIX bits used by backup/cp — avoid system headers */
#define O_RDONLY 0
#define S_ISUID 04000
#define S_ISGID 02000
#define HAVE_UTIME 1

struct stat {
	mode_t st_mode;
	char _pad0[4];
	time_t st_atime;
	time_t st_mtime;
	char _pad1[64];
};

struct utimbuf {
	time_t actime;
	time_t modtime;
};

int open(const char *path, int flags, ...);
int close(int fd);
int creat(const char *path, mode_t mode);
ptrdiff_t read(int fd, void *buf, unsigned long n);
ptrdiff_t joe_write(int fd, const void *buf, ptrdiff_t siz);
int unlink(const char *path);
int fstat(int fd, struct stat *buf);
int utime(const char *path, const struct utimbuf *times);

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

#define YES_CODE (-10)
#define NO_CODE (-20)
#define NO_MORE_DATA (-256)
#define CANFLAG_NORESTART 1
#define JOE_MSGBUFSIZE 300

#define PWFLAG_FILENAME 1
#define PWFLAG_UPDATE_CD 2
#define PWFLAG_SEED_CD 4
#define PWFLAG_COMMAND 8

#define WIND_BW(x, y) do { \
	if (!((y)->watom->what & (TYPETW | TYPEPW))) \
		return -1; \
	(x) = (BW *)(y)->object; \
	} while(0)

#define joe_snprintf_0(buf,len,fmt) snprintf((buf),(len),(fmt))
#define joe_snprintf_1(buf,len,fmt,a) snprintf((buf),(len),(fmt),(a))
#define joe_snprintf_2(buf,len,fmt,a,b) snprintf((buf),(len),(fmt),(a),(b))
#define joe_snprintf_3(buf,len,fmt,a,b,c) snprintf((buf),(len),(fmt),(a),(b),(c))

#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)
#define sc(a) (a), ((ptrdiff_t)(sizeof(a)/sizeof(char) - 1))

#define aLen(a) (*((ptrdiff_t *)(a) - 1))
#define aLEN(a) ((a) ? aLen(a) : 0)
#define av(a) (a), aLEN(a)

#define zcmp(a, b) strcmp((a), (b))
#define zlen(s) ((ptrdiff_t)strlen(s))
#define zcpy(a, b) strcpy((a), (b))

#define LINK(type) struct { type *next; type *prev; }

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
struct cmd; typedef struct cmd CMD;
struct undorec; typedef struct undorec UNDOREC;
struct undo; typedef struct undo UNDO;

struct undorec {
	LINK(UNDOREC) link;
	UNDOREC *unit;
	int min;
	int changed;
	off_t where;
	off_t len;
	int del;
	char _pad_del[4];
	B *big;
	char *small;
};

struct undo {
	LINK(UNDO) link;
	B *b;
	ptrdiff_t nrecs;
	UNDOREC recs;
	UNDOREC *ptr;
	UNDOREC *first;
	UNDOREC *last;
};

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

/* Layout mirrors gapbuffer/types.zig B (size 632); expose backup + undo */
struct b {
	LINK(B) link;               /* 0 */
	P *bof;                     /* 16 */
	P *eof;                     /* 24 */
	char *name;                 /* 32 */
	char _pad1[36];             /* locked..gave_notice (36) → 72 */
	int orphan;                 /* 76 */
	int count;                  /* 80 */
	int changed;                /* 84 */
	int backup;                 /* 88 */
	char _pad_backup[4];        /* 92 */
	UNDO *undo;                 /* 96 */
	char _pad_marks[88];        /* marks[11] → 192 */
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

struct bstack {
	struct bstack *next;
	B *b;
	P *cursor;
	P *top;
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

/* --- alloc / strings / vs / va --- */
void *joe_malloc(ptrdiff_t size);
void joe_free(void *ptr);
ptrdiff_t slen(const char *s);
char *zdup(const char *s);
char *zlcpy(char *a, ptrdiff_t siz, const char *b);

char *vsmk(ptrdiff_t len);
char *vsadd(char *s, int c);
char *vstrunc(char *s, ptrdiff_t len);
char *vsncpy(char *s, ptrdiff_t len, const char *blk, ptrdiff_t blklen);
char *vsdup(char *s);
void vsrm(char *s);

char **vaadd(char **vary, char *element);
char **vasort(char **ary, ptrdiff_t len);
void varm(char **vary);

/* --- window / bw / prompts --- */
void msgnw(W *w, const char *s);
void msgnwt(W *w, const char *s);
void wredraw(W *w);
int wabort(W *w);
BW *wmkpw(W *w, const char *prompt, B **history,
	int (*func)(W *w, char *s, void *object, int *notify),
	const char *huh,
	int (*abrt)(W *w, void *object),
	int (*tab)(BW *bw, int k),
	void *object, int *notify,
	struct charmap *map, int file_prompt);
int simple_cmplt(BW *bw, char **list);
QW *mkqw(W *w, const char *prompt, ptrdiff_t len,
	int (*func)(W *w, int k, void *object, int *notify),
	int (*abrt)(W *w, void *object),
	void *object, int *notify);
MENU *mkmenu(W *loc, W *targ, char **s,
	int (*func)(MENU *m, ptrdiff_t cursor, void *object, int k),
	int (*abrt)(W *w, ptrdiff_t cursor, void *object),
	int (*backs)(MENU *m, ptrdiff_t cursor, void *object),
	ptrdiff_t cursor, void *object, int *notify);

BW *bwmk(W *window, B *b, int prompt);
void bwrm(BW *bw);
void orphit(BW *bw);
void bw_unlock(BW *bw);
void set_current_dir(BW *bw, char *s, int simp);
off_t get_file_pos(const char *name);
void set_file_pos_all(Screen *t);

int uduptw(W *w, int k);
int upopabort(W *w, int k);
int uabort(W *w, int k);
int uabort1(W *w, int k);
int abortit(W *w, int k);
int ukillpid(W *w, int k);
int unmark(W *w, int k);

/* --- gap buffer / points --- */
P *pdup(P *p, const char *where);
P *pdupown(P *p, P **o, const char *tr);
void prm(P *p);
void pset(P *d, P *s);
int pline(P *p, off_t line);
off_t piscol(P *p);
void binss(P *p, const char *s);
void brm(B *b);
int bsave(P *p, const char *s, off_t size, int flag);
B *bload(const char *s);
B *bfind(const char *s);
B *bfind_reload(const char *s);
B *bfind_scratch(const char *s);
B *bcheck_loaded(const char *s);
B *bnext(void);
B *bprev(void);
B *borphan(void);
void breplace(B *b, B *n);
char **getbufs(void);
int plain_file(B *b);
int check_mod(B *b);
char *dequote(const char *s);
char *dequotevs(char *s);
char *canonical(char *s, int flags);
char *namepart(char *tmp, ptrdiff_t tmpsiz, const char *path);
char *joesep(char *path);
int mkpath(const char *path);
B *pextrect(P *org, off_t height, off_t right);
int markv(int r);
int doinsf(W *w, char *s, void *object, int *notify);

/* --- tty / screen --- */
void nescape(SCRN *t);
void nreturn(SCRN *t);
void nredraw(SCRN *t);
int ttshell(char *cmd);
void ttsusp(void);
void dofollows(void);

/* --- path / utf8 / charmap --- */
char *duplicate_backslashes(const char *s, ptrdiff_t len);
int utf8_decode_fwrd(const char **p, ptrdiff_t *plen);
int from_uni(struct charmap *cset, int c);
const char *my_gettext(const char *s);

/* --- macros / cmds / tab complete --- */
int exmacro(MACRO *m, int u, int k);
const CMD *findcmd(const char *s);
int execmd(const CMD *cmd, int k);
int cmplt_file(BW *bw, int k);
int cmplt_file_in(BW *bw, int k);
int cmplt_file_out(BW *bw, int k);

/* --- error list --- */
void saverr(const char *name);

/* Externs referenced by ufile.c (not defined therein) */
extern P *markb;
extern P *markk;
extern Screen *maint;
extern char msgbuf[JOE_MSGBUFSIZE];
extern int berror;
extern int opt_mid;
extern int square;
extern int lightoff;
extern int leave;
extern char *exmsg;
extern int noexmsg;
extern const char *const msgs[];
extern char stdbuf[];
extern B bufs;
extern struct charmap *locale_map;

/* NOTE: orphan, backpath, backup_file_suffix, filehist, nobackups, exask,
 * yes_key, no_key, bufhist, sbufs, and the ufile.h command entry points
 * (incl. doswitch/get_buffer_in_window/yncheck/genexmsg) are DEFINED in
 * ufile.c — do not extern them.
 */

#endif /* UFILE_STUBS_H */
