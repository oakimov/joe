include $(top_srcdir)/Makevars

AUTOMAKE_OPTIONS = foreign

SUBDIRS = util

EXTRA_DIST = TODO

noinst_HEADERS = b.h blocks.h bw.h cmd.h config.h hash.h help.h kbd.h \
	macro.h main.h menu.h path.h poshist.h pw.h queue.h qw.h rc.h regex.h \
	scrn.h tab.h termcapj.h tty.h tw.h types.h ublock.h uedit.h uerror.h \
	ufile.h uformat.h uisrch.h umath.h undo.h usearch.h ushell.h utag.h \
	utils.h va.h vfile.h vs.h w.h utf8.h syntax.h charmap.h mouse.h \
	lattr.h gettext.h builtin.h vt.h mmenu.h state.h options.h selinux.h \
	unicode.h cclass.h frag.h colors.h

bin_PROGRAMS = joe
AM_CPPFLAGS = -DJOERC="\"$(sysconf_joedir)/\"" -DJOEDATA="\"$(data_joedir)/\""

# joe_LDADD = -lm

joe_SOURCES = b.c blocks.c bw.c cmd.c hash.c help.c kbd.c macro.c main.c menu.c \
	path.c poshist.c pw.c queue.c qw.c rc.c regex.c scrn.c tab.c termcap.c \
	tty.c tw.c ublock.c uedit.c uerror.c ufile.c uformat.c uisrch.c umath.c \
	undo.c usearch.c ushell.c utag.c va.c vfile.c vs.c w.c utils.c syntax.c \
	utf8.c selinux.c charmap.c mouse.c lattr.c gettext.c builtin.c \
	builtins.c vt.c mmenu.c state.c options.c unicode.c \
	cclass.c frag.c colors.c unicat-@UNICODE_VERSION@.c

# Files that get embedded into builtins.c by stringify
# Note: rc/joerc is generated from rc/joerc.in by configure; ../rc/joerc is
# relative to joe/ where make runs from.
# Extra files to embed (can be overridden via configure --enable-extra-builtins
# or make EXTRA_BUILTINS="..." for ad-hoc additions)
EXTRA_BUILTINS = @EXTRA_BUILTINS@

BUILTINS_INPUTS = \
	../rc/joerc \
	../rc/ftyperc \
	../syntax/c.jsf \
	../colors/default.jcf \
	../syntax/comment_todo.jsf \
	../syntax/filename.jsf \
	../syntax/context.jsf \
	../syntax/md.jsf \
	$(EXTRA_BUILTINS)

# Regenerate builtins.c from source files
builtins.c: $(BUILTINS_INPUTS) util/stringify$(EXEEXT)
	$(AM_V_GEN)util/stringify$(EXEEXT) $(BUILTINS_INPUTS) > builtins.c.tmp && mv builtins.c.tmp builtins.c

distclean-local:
	rm -f *~

.PHONY: termcap
