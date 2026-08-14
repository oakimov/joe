#ifndef USEARCH_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define USEARCH_STUBS_H

#include <stddef.h>
#include <stdint.h>

/* Avoid fortified libc wrappers that zig translate-c cannot handle */
int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
int fprintf(void *f, const char *fmt, ...);
char *fgets(char *buf, int n, void *f);
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
#define NO_CODE (-20)
#define NO_MORE_DATA (-256)

#define WIND_BW(x, y) do { \
	if (!((y)->watom->what & (TYPETW | TYPEPW))) \
		return -1; \
	(x) = (BW *)(y)->object; \
	} while(0)

#define joe_snprintf_0(buf,len,fmt) snprintf((buf),(len),(fmt))
#define joe_snprintf_1(buf,len,fmt,a) snprintf((buf),(len),(fmt),(a))
#define joe_snprintf_2(buf,len,fmt,a,b) snprintf((buf),(len),(fmt),(a),(b))

#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)
#define zcmp(a, b) strcmp((a), (b))
#define zlen(s) ((ptrdiff_t)strlen(s))

#define aLen(a) (*((ptrdiff_t *)(a) - 1))
#define aLEN(a) ((a) ? aLen(a) : 0)

#define LINK(type) struct { type *next; type *prev; }

#define joe_isalnum_(map,c) ((map)->is_alnum_((map),(c)))
#define joe_isalpha_(map,c) ((map)->is_alpha_((map),(c)))
#define joe_tolower(map,c) ((map)->to_lower((map),(c)))
#define joe_toupper(map,c) ((map)->to_upper((map),(c)))

#define ttputc(c) do { obuf[obufp++] = (c); if (obufp == obufsiz) ttflsh(); } while (0)

#define NMATCHES 26

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

#define demote(type,member,queue,item) \
	enqueb(type,member,(queue),deque_f(type,member,(item)))

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
struct Cclass;
struct entry; typedef struct entry HENTRY;
struct Hash; typedef struct Hash HASH;
struct search; typedef struct search SRCH;
struct srchrec; typedef struct srchrec SRCHREC;
struct regcomp;
struct stditem; typedef struct stditem STDITEM;

typedef struct regmatch Regmatch_t;
struct regmatch {
	off_t rm_so, rm_eo;
};

struct srchrec {
	LINK(SRCHREC) link;
	int yn;
	int wrap_flag;
	off_t addr;
	B *b;
	off_t last_repl;
};

struct search {
	char *pattern;
	struct regcomp *comp;
	char *replacement;
	int backwards;
	int ignore;
	int regex;
	int repeat;
	int replace;
	int debug;
	int rest;
	Regmatch_t pieces[NMATCHES];
	Regmatch_t entire;
	int flg;
	SRCHREC recs;
	P *markb, *markk;
	P *wrap_p;
	int wrap_flag;
	int allow_wrap;
	int valid;
	off_t addr;
	off_t last_repl;
	int block_restrict;
	int all;
	B *first;
	B *current;
};

/* Minimal regcomp — only fields usearch.c touches */
struct regcomp {
	const char *ptr;
	ptrdiff_t l;
	struct charmap *cmap;
	void *nodes;
	int len;
	int size;
	char *prefix;
	ptrdiff_t prefix_len;
	ptrdiff_t prefix_size;
	int bra_no;
	char _frag_pad[32];
	const char *err;
};

struct entry {
	HENTRY *next;
	const char *name;
	ptrdiff_t hash_val;
	void *val;
};

struct Hash {
	ptrdiff_t len;
	HENTRY **tab;
	ptrdiff_t nentries;
};

struct stditem {
	LINK(STDITEM) link;
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

struct b {
	char _pad0[16];
	P *bof;
	P *eof;
	char *name;
	char _pad1[40];
	int count;
	int changed;
	char _pad2[104];
	OPTIONS o;
	P *oldcur;
	P *oldtop;
	P *err;
	char *current_dir;
	char _pad3[4];
	int rdonly;
	int internal;
	int scratch;
	int er;
	pid_t pid;
	int out;
	char _pad5[4];
	void *vt;
	char _pad6[24];
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

struct query {
	W *parent;
	int (*func)(W *w, int k, void *object, int *notify);
	int (*abrt)(W *w, void *object);
	void *object;
	char *prompt;
	ptrdiff_t promptlen;
	ptrdiff_t org_w;
	ptrdiff_t org_h;
};

/* --- alloc / strings / vs / va --- */
void *joe_malloc(ptrdiff_t size);
void joe_free(void *ptr);
ptrdiff_t slen(const char *s);

char *vsmk(ptrdiff_t len);
char *vsadd(char *s, int c);
char *vstrunc(char *s, ptrdiff_t len);
char *vsncpy(char *s, ptrdiff_t len, const char *blk, ptrdiff_t blklen);
char *vsfill(char *s, ptrdiff_t len, int c, ptrdiff_t amnt);
char *vsdup(char *s);
void vsrm(char *s);

char **vaadd(char **vary, char *element);
char **vasort(char **ary, ptrdiff_t len);
void varm(char **vary);

/* --- hash --- */
HASH *htmk(ptrdiff_t len);
void htrm(HASH *ht);
void *htadd(HASH *ht, const char *name, void *val);
void *htfind(HASH *ht, const char *name);

/* --- queue freelist --- */
void *alitem(void *list, ptrdiff_t itemsize);
void frchn(void *list, void *ch);

/* --- window / bw --- */
int wabort(W *w);
void updall(void);
int get_buffer_in_window(BW *bw, B *b);
void msgnw(W *w, const char *s);
BW *wmkpw(W *w, const char *prompt, B **history,
	int (*func)(W *w, char *s, void *object, int *notify),
	const char *huh,
	int (*abrt)(W *w, void *object),
	int (*tab)(BW *bw, int k),
	void *object, int *notify,
	struct charmap *map, int file_prompt);
int urtn(W *w, int k);
int simple_cmplt(BW *bw, char **list);
int utypebw(BW *bw, int k);
char *mcomplete(MENU *m);
MENU *mkmenu(W *loc, W *targ, char **s,
	int (*func)(MENU *m, ptrdiff_t cursor, void *object, int k),
	int (*abrt)(W *w, ptrdiff_t cursor, void *object),
	int (*backs)(MENU *m, ptrdiff_t cursor, void *object),
	ptrdiff_t cursor, void *object, int *notify);
QW *mkqw(W *w, const char *prompt, ptrdiff_t len,
	int (*func)(W *w, int k, void *object, int *notify),
	int (*abrt)(W *w, void *object),
	void *object, int *notify);
QW *mkqwnsr(W *w, const char *prompt, ptrdiff_t len,
	int (*func)(W *w, int k, void *object, int *notify),
	int (*abrt)(W *w, void *object),
	void *object, int *notify);

/* --- gap buffer / points --- */
P *pdup(P *p, const char *where);
P *pdupown(P *p, P **o, const char *tr);
void prm(P *p);
void pset(P *d, P *s);
P *pgoto(P *p, off_t loc);
void p_goto_bol(P *p);
void p_goto_eol(P *p);
P *p_goto_bof(P *p);
P *p_goto_eof(P *p);
int piseol(P *p);
int piseof(P *p);
off_t piscol(P *p);
int brch(P *p);
int brc(P *p);
int pgetc(P *p);
int prgetc(P *p);
P *pfwrd(P *p, off_t n);
P *pbkwd(P *p, off_t n);
P *pfind(P *p, const char *s, ptrdiff_t len);
P *pifind(P *p, const char *s, ptrdiff_t len);
P *prfind(P *p, const char *s, ptrdiff_t len);
P *prifind(P *p, const char *s, ptrdiff_t len);
char *brvs(P *p, off_t size);
void bdel(P *from, P *to);
void binsb(P *p, B *b);
void binsc(P *p, int c);
void binsm(P *p, const char *blk, ptrdiff_t size);
void binss(P *p, const char *s);
B *bcpy(P *from, P *to);
void brm(B *b);
B *bafter(B *b);
B *beafter(B *b);

/* --- regex --- */
struct regcomp *joe_regcomp(struct charmap *charmap, const char *s, ptrdiff_t len, int icase, int stdfmt, int debug);
void joe_regfree(struct regcomp *r);
int joe_regexec(struct regcomp *r, P *p, int nmatch, struct regmatch *matches, int eflags);
int escape(int utf8, const char **ptr, ptrdiff_t *len, struct Cclass **cat);

/* --- utf8 / charmap helpers --- */
ptrdiff_t utf8_encode(char *buf, int c);
int fwrd_c(struct charmap *map, const char **s, ptrdiff_t *len);

/* --- misc editor APIs used by usearch --- */
int markv(int r);
int yncheck(const char *string, int c);
int modify_logic(BW *bw, B *b);
int uundo(W *w, int k);
void nungetc(int c);
void dofollows(void);
void ttflsh(void);
char **regsub(char **z, ptrdiff_t len, char *s);
const char *my_gettext(const char *s);

int parse_ws(const char **p, int cmt);
int parse_kw(const char **p, const char *kw);
int parse_int(const char **p, int *buf);
ptrdiff_t parse_string(const char **p, char *buf, ptrdiff_t len);
void emit_string(FILE *f, const char *s, ptrdiff_t len);

/* Externs referenced by usearch.c (not defined therein) */
extern P *markb;
extern P *markk;
extern struct charmap *locale_map;
extern int square;
extern const char *yes_key;
extern const char *no_key;
extern int opt_mid;
extern int berror;
extern const char *const msgs[];
extern ptrdiff_t obufp;
extern ptrdiff_t obufsiz;
extern char *obuf;

/* NOTE: wrap, smode, csmode, opt_icase, pico, findhist, replhist,
 * globalsrch, srchstr, replstr, std_regex, rest_key, backup_key,
 * and the option-key strings are DEFINED in usearch.c — do not extern them.
 */

#endif /* USEARCH_STUBS_H */
