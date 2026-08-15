#ifndef MAIN_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define MAIN_STUBS_H

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
char *strstr(const char *h, const char *n);
char *strcpy(char *d, const char *s);

typedef int64_t off_t;
typedef int64_t time_t;
typedef uint64_t ino_t;
typedef unsigned int mode_t;
typedef void FILE;

extern FILE *stdin;
extern FILE *stderr;

int fileno(FILE *f);
int isatty(int fd);
int fclose(FILE *f);
FILE *freopen(const char *path, const char *mode, FILE *stream);
int atexit(void (*func)(void));
time_t time(time_t *t);

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define TO_DIFF_OK(a) ((ptrdiff_t)(a))
#define FALLTHROUGH
#define _(s) (s)
#define joe_gettext(s) my_gettext((s))
#define VERSION "4.8"
#define JOERC ""
#define JOEDATA ""
#define JOE_MSGBUFSIZE 300
#define NO_MORE_DATA (-256)
#define SHELL_TYPE_RAW 2

#define TYPETW		0x0100
#define TYPEPW		0x0200
#define TYPEMENU	0x0800
#define TYPEQW		0x1000

#define BG_COLOR(color)	(color)

#define joe_snprintf_3(buf,len,fmt,a,b,c) snprintf((buf),(unsigned long)(len),(fmt),(a),(b),(c))

#define zcmp(a, b) strcmp((a), (b))
#define zlen(s) ((ptrdiff_t)strlen(s))
#define zstr(a, b) strstr((a), (b))
#define zcpy(a, b) strcpy((a), (b))

#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)
/* sizeof(a)-1 so zig translate-c keeps string-literal length */
#define sc(a) (a), ((ptrdiff_t)(sizeof(a) - 1))

#define logmessage_2(fmt,a,b) (snprintf((i_msg),sizeof(i_msg),(fmt),(a),(b)), internal_msg(i_msg))
#define logerror_0(fmt) (zlcpy((i_msg),sizeof(i_msg),(fmt)), internal_msg(i_msg), setlogerrs())
#define logerror_1(fmt,a) (snprintf((i_msg),sizeof(i_msg),(fmt),(a)), internal_msg(i_msg), setlogerrs())

#define LINK(type) struct { type *next; type *prev; }

/* Darwin/macOS arm64 struct stat (size 144) */
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
#define st_mtime st_mtimespec.tv_sec

int stat(const char *path, struct stat *buf);

struct b; typedef struct b B;
struct p; typedef struct p P;
struct kbd; typedef struct kbd KBD;
struct kmap; typedef struct kmap KMAP;
struct bstack;
struct window; typedef struct window W;
struct screen; typedef struct screen Screen;
struct bw; typedef struct bw BW;
struct macro; typedef struct macro MACRO;
struct cmd; typedef struct cmd CMD;
struct high_syntax;
struct lattr_db;
struct charmap;
struct cap; typedef struct cap CAP;
struct jfile; typedef struct jfile JFILE;
struct vt_context; typedef struct vt_context VT;
struct vfile; typedef struct vfile VFILE;
struct base; typedef struct base BASE;

struct cmd {
	const char *name;
	int flag;
	int (*func)(W *w, int k);
	MACRO *m;
	int arg;
	const char *negarg;
};

struct macro {
	ptrdiff_t what;
	int k;
	int flg;
	const CMD *cmd;
	ptrdiff_t n;
	ptrdiff_t size;
	MACRO **steps;
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

struct scrn {
	char _pad0[8];
	ptrdiff_t li;
	ptrdiff_t co;
	char _pad1[760];
	int *updtab;
	char _pad2[48];
};
typedef struct scrn SCRN;

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

struct base {
	W *parent;
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

struct utf8_sm {
	char buf[8];
	ptrdiff_t ptr;
	int state;
	int accu;
};

enum vt_state {
	vt_idle,
	vt_esc,
	vt_args,
	vt_cmd,
	vt_utf,
	vt_osc,
	vt_osce
};

struct vt_context {
	enum vt_state state;
	char buf[1024];
	ptrdiff_t bufx;
	ptrdiff_t argv[3];
	ptrdiff_t argc;
	P *top;
	ptrdiff_t height;
	ptrdiff_t width;
	ptrdiff_t regn_top;
	ptrdiff_t regn_bot;
	P *vtcur;
	B *b;
	KBD *kbd;
	int attr;
	struct utf8_sm utf8_sm;
};

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
	VT *vt;
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

struct kbd {
	KMAP *curmap;
	KMAP *topmap;
	int seq[16];
	ptrdiff_t x;
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

/* --- callees used by main.c --- */
ptrdiff_t slen(const char *s);
char *zdup(const char *s);
char *zlcpy(char *a, ptrdiff_t siz, const char *b);
long ztoi(const char *s);
off_t ztoo(const char *s);

char *vsncpy(char *s, ptrdiff_t len, const char *blk, ptrdiff_t blklen);
char *vstrunc(char *s, ptrdiff_t len);
void vsrm(char *s);

char *namprt(const char *path);
char *joesep(char *path);
const char *xdg_config_dir(void);

JFILE *jfopen(const char *name, const char *mode);
int procrc(CAP *cap, JFILE *f, char *name);
int validate_rc(void);
void cmd_help(int type);
int glopt(char *s, char *arg, OPTIONS *options, int set);

CAP *my_getcap(char *name, long baud, void (*out)(void *outptr, char c), void *outptr);
SCRN *nopen(CAP *cap);
void nclose(SCRN *t);
int nresize(SCRN *t, ptrdiff_t w, ptrdiff_t h);
void nscroll(SCRN *t, int atr);
int cpos(SCRN *t, ptrdiff_t x, ptrdiff_t y);
void zig_scrn_soft_cursor(SCRN *t, ptrdiff_t x, ptrdiff_t y);

Screen *screate(SCRN *scrn);
void sresize(Screen *t);
W *lastw(Screen *t);
int wnext(Screen *t);
void wshowall(Screen *t);
void wredraw(W *w);
void msgout(W *w);
void msgclr(W *w);
void msgnw(W *w, const char *s);
void msgnwt(W *w, const char *s);

BW *wmktw(Screen *t, B *b);
BW *bwmk(W *window, B *b, int prompt);
void bwrm(BW *bw);
int uduptw(W *w, int k);
off_t get_file_pos(const char *name);
void init_visiblews(void);
void viewmode_cleanup(void);

B *bfind(const char *s);
B *bfind_scratch(const char *s);
B *bcpy(P *from, P *to);
void brmall(void);
int bsavefd(P *p, int fd, off_t size);
void binss(P *p, const char *s);

P *pdup(P *p, const char *where);
void prm(P *p);
P *pline(P *p, off_t line);
void p_goto_bol(P *p);
int piseof(P *p);

void lazy_opts(B *b, OPTIONS *o);
int modify_logic(BW *bw, B *b);
int cstart(BW *bw, const char *name, char **s, void *obj, int *notify, int build, int out_only, const char *first_command, int type);

void setup_history(B **history);
void append_history(B *hist, char *s, ptrdiff_t len);

MACRO *mparse(MACRO *m, const char *buf, ptrdiff_t *sta, int secure);
MACRO *dokey(KBD *kbd, int n);
int exemac(MACRO *m, int k);
void exemac_pasting(int state);
int exmacro(MACRO *m, int u, int k);
void chmac(void);
KBD *mkkbd(KMAP *kmap);
KMAP *kmap_getcontext(const char *name);

int help_on(Screen *t);
void help_display(Screen *t);
int init_colors(void);

void load_state(void);
void save_state(void);

void joe_iswinit(void);
void joe_locale(void);
const char *my_gettext(const char *s);

char *stagen(char *stalin, BW *bw, const char *s, int fill);

int ttflsh(void);
int ttgetch(void);
int ttcheck(void);
void ttgtsz(ptrdiff_t *x, ptrdiff_t *y);

VFILE *vtmp(void);
void vclose(VFILE *v);

int uquote(W *w, int k);
int utype(W *w, int k);
int urtn(W *w, int k);

extern int staupd;
extern int have;
extern unsigned char havec;
extern int leave;
extern int idleout;
extern int notite;
extern int noxon;
extern int Baud;
extern int dopadding;
extern char *joeterm;
extern int env_lines;
extern int env_columns;
extern int bg_text;
extern int orphan;
extern int opt_mid;
extern int berror;
extern B *filehist;
extern char msgbuf[JOE_MSGBUFSIZE];
extern const char *const msgs[];
extern struct charmap *locale_map;
extern const char *locale_msgs;
extern VFILE *vmem;

/* i_msg / internal_msg / setlogerrs are DEFINED in main.c — not stubbed as
 * extern, so translate-c emits `export` rather than an unresolved extern. */

#endif /* MAIN_STUBS_H */
