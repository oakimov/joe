#ifndef TTY_STUBS_H
#undef _FORTIFY_SOURCE
#define _FORTIFY_SOURCE 0
#define TTY_STUBS_H

#include <stddef.h>
#include <stdint.h>

/* Avoid fortified libc wrappers that zig translate-c cannot handle */
int printf(const char *fmt, ...);
int snprintf(char *buf, unsigned long n, const char *fmt, ...);
int fprintf(void *stream, const char *fmt, ...);
int fputs(const char *s, void *stream);
char *getenv(const char *name);
void free(void *p);
void *memcpy(void *d, const void *s, unsigned long n);
void *memset(void *s, int c, unsigned long n);
int strcmp(const char *a, const char *b);
unsigned long strlen(const char *s);
void exit(int status);
void _exit(int status);
int fflush(void *stream);
void *fopen(const char *path, const char *mode);
int fclose(void *stream);
int fileno(void *stream);
ptrdiff_t read(int fd, void *buf, unsigned long n);
ptrdiff_t write(int fd, const void *buf, unsigned long n);
int close(int fd);
int open(const char *path, int flags, ...);
int pipe(int fds[2]);
int fork(void);
int kill(int pid, int sig);
int wait(int *status);
int execl(const char *path, const char *arg0, ...);
int execve(const char *path, char *const argv[], char *const envp[]);
int dup2(int oldfd, int newfd);
int fcntl(int fd, int cmd, ...);
int openpty(int *amaster, int *aslave, char *name, void *termp, void *winp);
int login_tty(int fd);
int tcgetattr(int fd, void *termios_p);
int tcsetattr(int fd, int optional_actions, const void *termios_p);
unsigned long cfgetospeed(const void *termios_p);
int setitimer(int which, const void *new_value, void *old_value);
int alarm(unsigned seconds);
long time(long *t);
int sigemptyset(void *set);
int sigaddset(void *set, int signo);
int sigprocmask(int how, const void *set, void *oset);
int sigsuspend(const void *set);
int sleep(unsigned seconds);

typedef void FILE;
typedef int64_t time_t;
typedef int pid_t;
typedef unsigned long speed_t;
typedef long suseconds_t;
typedef void *sigset_t;
typedef void (*sighandler_t)(int);

typedef unsigned long tcflag_t;
typedef unsigned char cc_t;

struct termios {
	tcflag_t c_iflag;
	tcflag_t c_oflag;
	tcflag_t c_cflag;
	tcflag_t c_lflag;
	cc_t c_cc[20];
	char _pad_cc[4];
	speed_t c_ispeed;
	speed_t c_ospeed;
};
struct timeval {
	time_t tv_sec;
	suseconds_t tv_usec;
};
struct itimerval {
	struct timeval it_interval;
	struct timeval it_value;
};
struct winsize {
	unsigned short ws_row;
	unsigned short ws_col;
	unsigned short ws_xpixel;
	unsigned short ws_ypixel;
};

struct mpx {
	int ackfd;
	int kpid;
	int pid;
	void (*func)(void *object, char *data, ptrdiff_t len);
	void *object;
	void (*die)(void *object);
	void *dieobj;
};
typedef struct mpx MPX;

struct utf8_sm {
	char buf[8];
	ptrdiff_t ptr;
	int state;
	int accu;
};

struct charmap {
	struct charmap *next;
	const char *name;
	int type;
	char _pad[2752 - 8 - 8 - 4];
};

struct macro {
	char _pad[48];
};
typedef struct macro MACRO;

struct scrn {
	char _pad[840];
};
typedef struct scrn SCRN;

struct screen {
	SCRN *t;
	char _pad[40];
};
typedef struct screen Screen;

struct cap {
	char _pad[88];
};
typedef struct cap CAP;

#define SIZEOF(a) ((ptrdiff_t)sizeof(a))
#define TO_CHAR_OK(a) ((char)(a))
#define _(s) (s)
#define joe_gettext(s) (s)
#define joe_snprintf_1(buf,len,fmt,a) snprintf((buf),(unsigned long)(len),(fmt),(a))
#define zlen(s) ((ptrdiff_t)strlen(s))
#define REINSTALL_SIGHANDLER(sig, handler) do {} while (0)

#define NO_MORE_DATA (-256)
#define NPROC 8
#define TIMES 3
#define DIVIDEND 10000000

/* termios / signal / fcntl constants (macOS) */
#define O_RDWR 0x0002
#define O_NONBLOCK 0x00000004
#define O_NDELAY O_NONBLOCK
#define F_SETFL 4
#define EINTR 4

#define SIGHUP 1
#define SIGINT 2
#define SIGABRT 6
#define SIGPIPE 13
#define SIGALRM 14
#define SIGTERM 15
#define SIGTSTP 18
#define SIGCHLD 20
#define SIGWINCH 28
#define SIG_DFL ((sighandler_t)0)
#define SIG_IGN ((sighandler_t)1)
#define SIG_SETMASK 3

#define ITIMER_REAL 0
#define TCSADRAIN 1
#define ICRNL 0x00000100
#define IGNCR 0x00000080
#define INLCR 0x00000040
#define IXON 0x00000200
#define IXOFF 0x00000400
#define VMIN 16
#define VTIME 17

#define B50 50
#define B75 75
#define B110 110
#define B134 134
#define B150 150
#define B200 200
#define B300 300
#define B600 600
#define B1200 1200
#define B1800 1800
#define B2400 2400
#define B4800 4800
#define B9600 9600
#define B19200 19200
#define B38400 38400
#define EXTA 19200
#define EXTB 38400

/* TIOCGWINSZ / TIOCSWINSZ — values not needed as numeric if we keep calls opaque;
 * provide placeholders so translate-c accepts joe_ioctl(..., TIOCGWINSZ, ...) */
#define TIOCGWINSZ 0x40087468
#define TIOCSWINSZ 0x80087467

extern FILE *stdin;
extern FILE *stdout;
extern FILE *stderr;
extern int errno;

void *joe_malloc(ptrdiff_t size);
void *joe_realloc(void *ptr, ptrdiff_t size);
void joe_free(void *ptr);
ptrdiff_t joe_read(int fd, void *buf, ptrdiff_t size);
ptrdiff_t joe_write(int fd, const void *buf, ptrdiff_t size);
int joe_ioctl(int fd, unsigned long req, void *arg);
int joe_set_signal(int signum, sighandler_t handler);

int utf8_decode(struct utf8_sm *sm, char c);
int to_uni(struct charmap *map, int c);
int set_attr(SCRN *t, int c);
void do_auto_scroll(void);
long mnow(void);
void edupd(int flg);
MACRO *timer_play(void);
int exemac(MACRO *m, int k);
void ttsig(int sig);

extern struct charmap *locale_map;
extern Screen *maint;
extern volatile int dostaupd;
extern int auto_scroll;
extern long auto_trig_time;
extern const char *const *mainenv;
extern int nodeadjoe;

/* Exported ABI (forward decls used inside tty.c) */
void sigjoe(void);
void signrm(void);
void ttopen(void);
void ttclose(void);
void ttopnn(void);
void ttclsn(void);
void tickoff(void);
void tickon(void);
int ttcheck(void);
int ttflsh(void);
char ttgetc(void);
int ttgetch(void);
void ttputs(const char *s);
void ttgtsz(ptrdiff_t *x, ptrdiff_t *y);
void ttstsz(int fd, ptrdiff_t w, ptrdiff_t h);
int ttshell(char *cmd);
void ttsusp(void);
MPX *mpxmk(int *ptyfd, const char *cmd, char **args,
	void (*func)(void *object, char *data, ptrdiff_t len), void *object,
	void (*die)(void *object), void *dieobj, int copy_in,
	ptrdiff_t w, ptrdiff_t h, int use_pipe);
void mpxdied(MPX *m);

extern int idleout;
extern int noxon;
extern int Baud;
extern char *obuf;
extern ptrdiff_t obufp;
extern ptrdiff_t obufsiz;
extern long tty_baud;
extern long upc;
extern int have;
extern char havec;
extern int leave;
extern int ticked;
extern time_t last_time;

#endif /* TTY_STUBS_H */