#ifndef PATH_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define PATH_STUBS_H

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

#define HAVE_MKSTEMP 1
#define HAVE_GETCWD 1
#define HAVE_PWD_H 1
#define HAVE_DIRENT_H 1
#define PATH_MAX 4096
#define _PATH_TMP "/tmp/"

#define JOERC ""
#define JOEDATA ""

#define O_RDONLY 0
#define O_RDWR 2
#define O_CREAT 0x0200
#define O_EXCL 0x0800
#define X_OK 1

#define S_IFMT  0170000
#define S_IFREG 0100000
#define S_IFDIR 0040000
#define S_ISREG(m) (((m) & S_IFMT) == S_IFREG)
#define S_ISDIR(m) (((m) & S_IFMT) == S_IFDIR)

#define joe_snprintf_1(buf,len,fmt,a) snprintf((buf),(unsigned long)(len),(fmt),(a))
#define joe_snprintf_3(buf,len,fmt,a,b,c) snprintf((buf),(unsigned long)(len),(fmt),(a),(b),(c))

#define zcmp(a, b) strcmp((a), (b))
#define zlen(s) ((ptrdiff_t)strlen(s))

#define sLen(a) (*((ptrdiff_t *)(a) - 1))
#define sLEN(a) ((a) ? sLen(a) : 0)
#define sSiz(a) (*((ptrdiff_t *)(a) - 2))
#define sv(a) (a), sLEN(a)
#define sz(a) (a), slen(a)
/* Prefer sizeof(a)-1 so zig translate-c keeps string-literal length
 * (sizeof(a)/sizeof(*(a))-1 collapses to 0 under translate-c). */
#define sc(a) (a), ((ptrdiff_t)(sizeof(a) - 1))

#define aLen(a) (*((ptrdiff_t *)(a) - 1))
#define aLEN(a) ((a) ? aLen(a) : 0)

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

int stat(const char *path, struct stat *buf);
int access(const char *path, int mode);
int chdir(const char *path);
char *getcwd(char *buf, unsigned long size);
int mkdir(const char *path, mode_t mode);
int mkstemp(char *tmpl);
int fchmod(int fd, mode_t mode);
int close(int fd);
int open(const char *path, int flags, ...);

/* Darwin dirent: size 1048, d_name @ 21 */
typedef struct DIR DIR;
struct dirent {
	char _pad0[21];
	char d_name[1027];
};
DIR *opendir(const char *name);
struct dirent *readdir(DIR *dirp);
int closedir(DIR *dirp);
#define NAMLEN(dirent) zlen((dirent)->d_name)

/* Minimal passwd — only pw_name used */
struct passwd {
	char *pw_name;
};
struct passwd *getpwent(void);
void endpwent(void);

/* JOE variable strings / arrays */
ptrdiff_t slen(const char *s);
char *vsmk(ptrdiff_t len);
void vsrm(char *s);
char *vsensure(char *s, ptrdiff_t len);
char *vsadd(char *s, char c);
char *vsncpy(char *d, ptrdiff_t dlen, const char *s, ptrdiff_t sl);
char *zdup(const char *s);
char *zlcpy(char *d, ptrdiff_t dlen, const char *s);
ptrdiff_t zncmp(const char *a, const char *b, ptrdiff_t n);
void joe_free(void *p);
char **vaadd(char **a, char *s);
void varm(char **a);
char **vawords(char **a, const char *s, ptrdiff_t sl, const char *sep, ptrdiff_t sepl);

/* Opaque JOE file + path helpers from other modules */
typedef void JFILE;
void *jfopen(const char *name, const char *mode);
char *canonical(char *s, int flags);

#endif /* PATH_STUBS_H */
