#ifndef CMD_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define CMD_STUBS_H

#include <stddef.h>
#include <stdint.h>

int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
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
#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)

#define joe_snprintf_0(buf,len,fmt) snprintf((buf),(len),(fmt))
#define joe_snprintf_1(buf,len,fmt,a) snprintf((buf),(len),(fmt),(a))

#define NO_MORE_DATA (-256)
#define TYPETW		0x0100
#define TYPEPW		0x0200
#define TYPEMENU	0x0800
#define TYPEQW		0x1000

#define EMID		  1
#define ECHKXCOL	  2
#define EFIXXCOL	  4
#define EMINOR		  8
#define EPOS		 16
#define EMOVE		 32
#define EKILL		 64
#define EMOD		128
#define EBLOCK		0x4000
#define EMETA		0x10000

struct window;
typedef struct window W;
struct bw;
typedef struct bw BW;
struct b;
typedef struct b B;
struct p;
typedef struct p P;
struct macro;
typedef struct macro MACRO;
struct qw;
typedef struct qw QW;
struct charmap;

struct cmd {
	const char *name;
	int flag;
	int (*func)(W *w, int k);
	MACRO *m;
	int arg;
	const char *negarg;
};
typedef struct cmd CMD;

struct watom {
	char _pad0[80];
	int what;
	char _pad1[4];
};
typedef struct watom WATOM;

struct kbd { char _pad[88]; };
typedef struct kbd KBD;

struct window {
	char _pad0[144];
	const WATOM *watom;
	void *object;
	char _pad1[40];
};
/* W size 200 */

struct options {
	char _pad0[264];
	int hex;
	int viewmode;
	char _pad1[32];
	MACRO *mnew;
	char _pad2[24];
	MACRO *mfirst;
};
typedef struct options OPTIONS;

struct p {
	char _pad0[64];
	off_t col;
	off_t xcol;
	int valcol;
	char _pad1[28];
};

struct b {
	char _pad0[32];
	char *name;
	int locked;
	int ignored_lock;
	int didfirst;
	char _pad1[12];
	time_t check_time;
	int gave_notice;
	char _pad2[8];
	int changed;
	char _pad3[484];
	int rdonly;
	char _pad4[56];
};

struct bw {
	W *parent;
	B *b;
	char _pad0[8];
	P *cursor;
	char _pad1[48];
	OPTIONS o;
	char _pad2[64]; /* 8+8+8+8+48+344=424; +64=488 */
};

struct screen {
	char _pad0[24];
	W *curwin;
	char _pad1[16];
};
typedef struct screen Screen;

struct centry {
	struct centry *next;
	const char *name;
	ptrdiff_t hash_val;
	const void *val;
};
typedef struct centry CHENTRY;

struct CHash {
	ptrdiff_t len;
	CHENTRY **tab;
	ptrdiff_t nentries;
};
typedef struct CHash CHASH;

/* Command function prototypes (from cmds[]) */
int pffirst(W *w, int k);
int pfnext(W *w, int k);
int pqrepl(W *w, int k);
int prfirst(W *w, int k);
int u_goto_bof(W *w, int k);
int u_goto_bol(W *w, int k);
int u_goto_eof(W *w, int k);
int u_goto_eol(W *w, int k);
int u_goto_left(W *w, int k);
int u_goto_next(W *w, int k);
int u_goto_prev(W *w, int k);
int u_goto_right(W *w, int k);
int u_help(W *w, int k);
int u_help_next(W *w, int k);
int u_help_prev(W *w, int k);
int u_word_delete(W *w, int k);
int uabort(W *w, int k);
int uabortbuf(W *w, int k);
int uarg(W *w, int k);
int uask(W *w, int k);
int ubacks(W *w, int k);
int ubackw(W *w, int k);
int ubegin_marking(W *w, int k);
int ubknd(W *w, int k);
int ubkwdc(W *w, int k);
int ublkcpy(W *w, int k);
int ublkdel(W *w, int k);
int ublkmove(W *w, int k);
int ublksave(W *w, int k);
int ubop(W *w, int k);
int ubos(W *w, int k);
int ubrpaste(W *w, int k);
int ubrpaste_done(W *w, int k);
int ubufed(W *w, int k);
int ubuild(W *w, int k);
int ubyte(W *w, int k);
int ucancel(W *w, int k);
int ucenter(W *w, int k);
int ucharset(W *w, int k);
int ucmplt(W *w, int k);
int ucol(W *w, int k);
int ucopy(W *w, int k);
int ucrawll(W *w, int k);
int ucrawlr(W *w, int k);
int uctrl(W *w, int k);
int ucurrent_msg(W *w, int k);
int udebug_joe(W *w, int k);
int udefm2down(W *w, int k);
int udefm2drag(W *w, int k);
int udefm2up(W *w, int k);
int udefm3down(W *w, int k);
int udefm3drag(W *w, int k);
int udefm3up(W *w, int k);
int udefmdown(W *w, int k);
int udefmdrag(W *w, int k);
int udefmiddledown(W *w, int k);
int udefmiddleup(W *w, int k);
int udefmup(W *w, int k);
int udelbl(W *w, int k);
int udelch(W *w, int k);
int udelel(W *w, int k);
int udelln(W *w, int k);
int udnarw(W *w, int k);
int udnslide(W *w, int k);
int udrop(W *w, int k);
int uduptw(W *w, int k);
int uedit(W *w, int k);
int uelse(W *w, int k);
int uelsif(W *w, int k);
int uendif(W *w, int k);
int ueop(W *w, int k);
int uexecmd(W *w, int k);
int uexpld(W *w, int k);
int uexsve(W *w, int k);
int uextmouse(W *w, int k);
int ufilt(W *w, int k);
int ufinish(W *w, int k);
int ufmtblk(W *w, int k);
int uformat(W *w, int k);
int ufwrdc(W *w, int k);
int ugomark(W *w, int k);
int ugparse(W *w, int k);
int ugrep(W *w, int k);
int ugroww(W *w, int k);
int uhome(W *w, int k);
int uif(W *w, int k);
int uinsc(W *w, int k);
int uinsf(W *w, int k);
int uisrch(W *w, int k);
int ujump(W *w, int k);
int ukeymap(W *w, int k);
int ukilljoe(W *w, int k);
int ukillpid(W *w, int k);
int ulanguage(W *w, int k);
int ulindent(W *w, int k);
int uline(W *w, int k);
int ulose(W *w, int k);
int ulower(W *w, int k);
int umacros(W *w, int k);
int umarkb(W *w, int k);
int umarkk(W *w, int k);
int umarkl(W *w, int k);
int umath(W *w, int k);
int umbacks(W *w, int k);
int umbof(W *w, int k);
int umbol(W *w, int k);
int umdnarw(W *w, int k);
int umenu(W *w, int k);
int umeof(W *w, int k);
int umeol(W *w, int k);
int umfit(W *w, int k);
int umltarw(W *w, int k);
int umode(W *w, int k);
int umpgdn(W *w, int k);
int umpgup(W *w, int k);
int umrtarw(W *w, int k);
int umscrdn(W *w, int k);
int umscrup(W *w, int k);
int umsg(W *w, int k);
int umtab(W *w, int k);
int umuparw(W *w, int k);
int umwind(W *w, int k);
int uname_joe(W *w, int k);
int unbuf(W *w, int k);
int unedge(W *w, int k);
int unextpos(W *w, int k);
int unextw(W *w, int k);
int unmark(W *w, int k);
int unotmod(W *w, int k);
int unxterr(W *w, int k);
int uopen(W *w, int k);
int uparserr(W *w, int k);
int upaste(W *w, int k);
int upbuf(W *w, int k);
int upedge(W *w, int k);
int upgdn(W *w, int k);
int upgup(W *w, int k);
int upicokill(W *w, int k);
int uplay(W *w, int k);
int upop(W *w, int k);
int upopabort(W *w, int k);
int uprevpos(W *w, int k);
int uprevw(W *w, int k);
int uprverr(W *w, int k);
int upsh(W *w, int k);
int uquery(W *w, int k);
int uquerysave(W *w, int k);
int uquote(W *w, int k);
int uquote8(W *w, int k);
int urecord(W *w, int k);
int uredo(W *w, int k);
int urelease(W *w, int k);
int ureload(W *w, int k);
int ureload_all(W *w, int k);
int uretyp(W *w, int k);
int urindent(W *w, int k);
int ursrch(W *w, int k);
int urtn(W *w, int k);
int urun(W *w, int k);
int usave(W *w, int k);
int usavenow(W *w, int k);
int uscratch(W *w, int k);
int uscratch_push(W *w, int k);
int uselect(W *w, int k);
int usetcd(W *w, int k);
int usetmark(W *w, int k);
int ushell(W *w, int k);
int ushowlog(W *w, int k);
int ushrnk(W *w, int k);
int usmath(W *w, int k);
int usplitw(W *w, int k);
int ustat(W *w, int k);
int ustop(W *w, int k);
int uswap(W *w, int k);
int uswitch(W *w, int k);
int usys(W *w, int k);
int utag(W *w, int k);
int utagjump(W *w, int k);
int utimer(W *w, int k);
int utoggle_marking(W *w, int k);
int utomarkb(W *w, int k);
int utomarkbk(W *w, int k);
int utomarkk(W *w, int k);
int utomatch(W *w, int k);
int utomouse(W *w, int k);
int utos(W *w, int k);
int utrimlines(W *w, int k);
int utw0(W *w, int k);
int utw1(W *w, int k);
int utxt(W *w, int k);
int utype(W *w, int k);
int uuarg(W *w, int k);
int uundo(W *w, int k);
int uuparw(W *w, int k);
int uupper(W *w, int k);
int uupslide(W *w, int k);
int uvtbknd(W *w, int k);
int uxtmouse(W *w, int k);
int uyank(W *w, int k);
int uyankpop(W *w, int k);
int uyapp(W *w, int k);

void *joe_malloc(ptrdiff_t size);
void joe_free(void *ptr);
char *zdup(const char *s);
ptrdiff_t slen(const char *ary);
void vsrm(char *vary);
void **vaadd(void **vary, void *el);
char *vsncpy(char *vary, ptrdiff_t pos, const char *array, ptrdiff_t len);

MACRO *mkmacro(int k, int flg, ptrdiff_t n, const CMD *cmd);
void rmmacro(MACRO *macro);
int exmacro(MACRO *m, int u, int k);

CHASH *chtmk(ptrdiff_t len);
const void *chtadd(CHASH *ht, const char *name, const void *val);
const void *chtfind(CHASH *ht, const char *name);

P *pfcol(P *p);
#define piscol(p) ((p)->valcol ? (p)->col : (pfcol(p), (p)->col))
void afterpos(void);
void aftermove(W *w, P *p);
void dofollows(void);
int utoggle_marking(W *w, int k);
int plain_file(B *b);
int lock_it(const char *path, char *buf);
void unlock_it(const char *path);
int yncheck(const char *set, int c);

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
int simple_cmplt(BW *bw, char **list);

extern Screen *maint;
extern int leave;
extern int smode;
extern int nowmarking;
extern int justkilled;
extern int opt_mid;
extern struct charmap *utf8_map;
extern int auto_scroll;
void reset_trig_time(void);
void **vaensure(void **vary, ptrdiff_t len);
void vasort(void **ary, ptrdiff_t len);
#define aLEN(a) ((a) ? *((ptrdiff_t *)(a) - 2) : 0)
#define aLen(a) (*((ptrdiff_t *)(a) - 2))


#define CHECK_INTERVAL 15

const CMD *findcmd(const char *s);
MACRO *mparse(MACRO *m, const char *buf, ptrdiff_t *sta, int secure);
int check_mod(B *b);
extern time_t last_time;

extern ptrdiff_t obufp;
extern ptrdiff_t obufsiz;
extern char *obuf;
void ttflsh(void);
#undef ttputc
#define ttputc(c) do { obuf[obufp++] = (c); if (obufp == obufsiz) ttflsh(); } while (0)

#endif /* CMD_STUBS_H */
