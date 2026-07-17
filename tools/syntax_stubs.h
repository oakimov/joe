#ifndef SYNTAX_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define SYNTAX_STUBS_H
#include <stddef.h>
#include <stdint.h>

int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
void free(void *p);
void *memcpy(void *d, const void *s, unsigned long n);
void *memset(void *s, int c, unsigned long n);
int strcmp(const char *a, const char *b);
unsigned long strlen(const char *s);

typedef int64_t off_t;
typedef void FILE;

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define _(s) (s)
#define joe_gettext(s) my_gettext(s)
#define joe_snprintf_1(buf,len,fmt,a) snprintf((buf),(unsigned long)(len),(fmt),(a))
#define joe_snprintf_2(buf,len,fmt,a,b) snprintf((buf),(unsigned long)(len),(fmt),(a),(b))
#define joe_snprintf_3(buf,len,fmt,a,b,c) snprintf((buf),(unsigned long)(len),(fmt),(a),(b),(c))
#define joe_snprintf_4(buf,len,fmt,a,b,c,d) snprintf((buf),(unsigned long)(len),(fmt),(a),(b),(c),(d))
#define zcmp(a,b) strcmp((a),(b))
#define zlen(s) ((ptrdiff_t)strlen(s))

#define NO_MORE_DATA (-256)
#define SAVED_SIZE 80
#define COLORSPEC_TYPE_NONE 0
#define CONTEXT_COMMENT 1
#define CONTEXT_STRING 2
#define CONTEXT_MASK (CONTEXT_COMMENT+CONTEXT_STRING)

#define INVERSE           64
#define UNDERLINE        128
#define BOLD             256
#define BLINK            512
#define DIM             1024
#define DOUBLE_UNDERLINE   8
#define CROSSED_OUT       16
#define AT_MASK (INVERSE+UNDERLINE+BOLD+BLINK+DIM+32+DOUBLE_UNDERLINE+CROSSED_OUT)
#define BG_SHIFT 11
#define BG_VALUE (255<<BG_SHIFT)
#define BG_NOT_DEFAULT (256<<BG_SHIFT)
#define BG_TRUECOLOR (512<<BG_SHIFT)
#define BG_MASK (1023<<BG_SHIFT)
#define FG_SHIFT 21
#define FG_VALUE (255<<FG_SHIFT)
#define FG_NOT_DEFAULT (256<<FG_SHIFT)
#define FG_TRUECOLOR (512<<FG_SHIFT)
#define FG_MASK (1023<<FG_SHIFT)

#define invalidate_state(s) (((s)->state = -1), ((s)->saved_s = 0), ((s)->stack = 0), ((s)->delim_stack = 0))

/* high_cmd bitfield flags (ABI-compatible with unsigned bitfields) */
#define CMD_F_NOEAT            (1u<<0)
#define CMD_F_START_BUFFERING  (1u<<1)
#define CMD_F_STOP_BUFFERING   (1u<<2)
#define CMD_F_SAVE_C           (1u<<3)
#define CMD_F_SAVE_S           (1u<<4)
#define CMD_F_PUSH_C           (1u<<5)
#define CMD_F_PUSH_S           (1u<<6)
#define CMD_F_POP_C            (1u<<7)
#define CMD_F_POP_S            (1u<<8)
#define CMD_F_IGNORE           (1u<<9)
#define CMD_F_START_MARK       (1u<<10)
#define CMD_F_STOP_MARK        (1u<<11)
#define CMD_F_RECOLOR_MARK     (1u<<12)
#define CMD_F_RTN              (1u<<13)
#define CMD_F_RESET            (1u<<14)

typedef struct color_set COLORSET;
typedef struct color_scheme SCHEME;
typedef struct Hash HASH;
typedef struct Zhash ZHASH;
typedef struct jfile JFILE;
typedef struct point P;
typedef struct buffer B;
typedef struct bw BW;
typedef struct options OPTIONS;
typedef int attr_data;

struct entry {
	struct entry *next;
	const char *name;
	ptrdiff_t hash_val;
	void *val;
};
typedef struct entry HENTRY;
struct Hash {
	ptrdiff_t len;
	HENTRY **tab;
	ptrdiff_t nentries;
};
struct Zhash { char _pad[24]; };
struct jfile { char _pad[16]; };

struct color_spec {
	int type;
	int atr;
	int mask;
	int gui_fg;
	int gui_bg;
};
struct color_ref {
	const char *name;
	struct color_ref *next;
};
struct color_def {
	const char *name;
	struct color_ref *refs;
	struct color_def *next;
	struct color_spec spec;
	struct color_spec orig;
	int visited;
};
struct color_set {
	COLORSET *next;
	int colors;
	HASH *syntax;
	int *palette;
	struct color_def *alldefs;
	struct color_spec *builtins;
	struct color_spec termcolors[16];
};

struct interval { int first; int last; }; /* size 8 */

struct Rtree { char _pad[248]; };

struct high_cmd {
	unsigned flags;
	ptrdiff_t recolor;
	struct high_state *new_state;
	ZHASH *keywords;
	struct high_cmd *delim;
	struct high_syntax *call;
};

struct high_state {
	ptrdiff_t no;
	int name;
	int color;
	struct color_def *colorp;
	struct Rtree rtree;
	struct high_cmd *dflt;
	struct high_cmd *same_delim;
	struct high_cmd *delim;
};

struct high_param {
	struct high_param *next;
	char *name;
};

struct high_frame {
	struct high_frame *parent;
	struct high_frame *child;
	struct high_frame *sibling;
	struct high_syntax *syntax;
	struct high_state *return_state;
};

struct high_delim_frame {
	struct high_delim_frame *parent;
	struct high_delim_frame *child;
	struct high_delim_frame *sibling;
	const int *saved_s;
};

struct high_syntax {
	struct high_syntax *next;
	char *name;
	char *subr;
	struct high_param *params;
	struct high_state **states;
	HASH *ht_states;
	ptrdiff_t nstates;
	ptrdiff_t szstates;
	struct color_def *color;
	struct high_cmd default_cmd;
	struct high_frame *stack_base;
	struct high_delim_frame *delim_stack_base;
};

struct highlight_state {
	struct high_frame *stack;
	struct high_delim_frame *delim_stack;
	const int *saved_s;
	ptrdiff_t state;
};
typedef struct highlight_state HIGHLIGHT_STATE;

struct state_debug_data {
	int name, recolor;
};

struct charmap {
	struct charmap *next;
	const char *name;
	int type;
	int (*is_punct)(struct charmap*,int);
	int (*is_print)(struct charmap*,int);
	int (*is_space)(struct charmap*,int);
	int (*is_alpha_)(struct charmap*,int);
	int (*is_alnum_)(struct charmap*,int);
	int (*to_lower)(struct charmap*,int);
	int (*to_upper)(struct charmap*,int);
};

struct options_match { char _pad[32]; };

struct macro { char _pad[48]; };
typedef struct macro MACRO;

struct options {
	OPTIONS *next;
	const char *ftype;
	struct options_match *match;
	int overtype;
	off_t lmargin;
	off_t rmargin;
	int autoindent;
	int wordwrap;
	int nobackup;
	off_t tab;
	int indentc;
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

struct point {
	void *link_next;
	void *link_prev;
	B *b;
	char _pad[112 - 24];
};

struct buffer {
	char _pad0[192];
	OPTIONS o;
	char _pad1[632 - 192 - 344];
};

struct bw {
	char _pad0[24];
	P *cursor;
	char _pad1[488 - 32];
};

extern char i_msg[];
extern struct color_set *curschemeset;

const char *my_gettext(const char *s);
void internal_msg(const char *s);
void setlogerrs(void);
void *joe_malloc(ptrdiff_t n);
void *joe_realloc(void *p, ptrdiff_t n);
void *joe_calloc(ptrdiff_t n, ptrdiff_t sz);
void joe_free(void *p);
char *zdup(const char *s);
char *zlcpy(char *a, ptrdiff_t siz, const char *b);
char *zlcat(char *a, ptrdiff_t siz, const char *b);
void vsrm(char *v);

HASH *htmk(ptrdiff_t len);
void *htadd(HASH *ht, const char *name, void *val);
void *htfind(HASH *ht, const char *name);
void htrm(HASH *ht);
const char *atom_add(const char *name);

ZHASH *Zhtmk(ptrdiff_t len);
void *Zhtadd(ZHASH *ht, const int *name, void *val);
void *Zhtfind(ZHASH *ht, const int *name);
const int *Zatom_add(const int *name);
int Zcmp(const int *a, const int *b);
int *Zdup(const int *s);

char *jfgets(char *buf, int len, JFILE *f);
int jfclose(JFILE *f);
char *open_config_file(JFILE **result, const char *prefix, const char *name, const char *suffix);

int parse_ws(const char **p, int cmt);
int parse_ident(const char **p, char *buf, ptrdiff_t len);
int parse_char(const char **p, char c);
int parse_tows(const char **p, char *buf);
int parse_field(const char **p, const char *field);
int parse_diff(const char **p, ptrdiff_t *buf);
ptrdiff_t parse_Zstring(const char **p, int *buf, ptrdiff_t len);
int parse_class(const char **p, struct interval **array, ptrdiff_t *size);
int parse_color_def(const char **p, struct color_def *dest);
void resolve_syntax_colors(COLORSET *cset, struct high_syntax *syntax);

int pgetc(P *p);
P *binss(P *p, const char *s);
P *pnextl(P *p);

int to_uni(struct charmap *cset, int c);
int *lowerize(int *d, ptrdiff_t len, const int *s);

void rtree_init(struct Rtree *r);
void *rtree_lookup(struct Rtree *r, int ch);
void rtree_opt(struct Rtree *r);
void rtree_set(struct Rtree *r, struct interval *array, ptrdiff_t len, void *map);
void rtree_show(struct Rtree *r);

#define logerror_2(fmt,a,b) (snprintf((i_msg),128,(fmt),(a),(b)), internal_msg(i_msg), setlogerrs())
#define logmessage_3(fmt,a,b,c) (snprintf((i_msg),128,(fmt),(a),(b),(c)), internal_msg(i_msg))

#endif
