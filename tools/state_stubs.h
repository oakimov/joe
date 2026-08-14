#ifndef STATE_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define STATE_STUBS_H

#include <stddef.h>
#include <stdint.h>

int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
int fprintf(void *f, const char *fmt, ...);
char *fgets(char *s, int n, void *f);
void *fopen(const char *path, const char *mode);
int fclose(void *f);
char *getenv(const char *name);
int strcmp(const char *a, const char *b);
unsigned long strlen(const char *s);
unsigned int umask(unsigned int mask);

typedef int64_t off_t;
typedef unsigned int mode_t;
typedef void FILE;

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_DIFF_OK(a) ((ptrdiff_t)(a))
#define zcmp(a, b) strcmp((a), (b))
#define zlen(s) ((ptrdiff_t)strlen(s))
#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)
#define sc(a) (a), ((ptrdiff_t)(sizeof(a) - 1))

#define LINK(type) struct { type *next; type *prev; }

struct b; typedef struct b B;
struct p; typedef struct p P;

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

struct b {
	LINK(B) link;
	P *bof;
	P *eof;
	char _pad[600];
};

ptrdiff_t slen(const char *s);
char *vsncpy(char *d, ptrdiff_t dlen, const char *s, ptrdiff_t sl);
void vsrm(char *s);
P *pdup(P *p, const char *tr);
P *pset(P *n, P *p);
void prm(P *p);
P *pline(P *p, off_t line);
int piseof(P *p);
P *pnextl(P *p);
void brmem(P *p, char *buf, ptrdiff_t size);
P *binsm(P *p, const char *blk, ptrdiff_t size);
B *bmk(B *prop);
int parse_ws(const char **p, int cmt);
ptrdiff_t parse_string(const char **p, char *buf, ptrdiff_t len);
void emit_string(FILE *f, const char *s, ptrdiff_t len);
const char *xdg_state_dir(void);
int mkpath(const char *path);
void save_srch(FILE *f);
void load_srch(FILE *f);
void save_macros(FILE *f);
void load_macros(FILE *f);
void save_yank(FILE *f);
void load_yank(FILE *f);
void save_file_pos(FILE *f);
void load_file_pos(FILE *f);
void save_colors_state(FILE *f);
void load_colors_state(FILE *f);

extern B *filehist;
extern B *findhist;
extern B *replhist;
extern B *runhist;
extern B *buildhist;
extern B *grephist;
extern B *filthist;
extern B *cmdhist;
extern B *mathhist;

#endif
