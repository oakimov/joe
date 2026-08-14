#!/usr/bin/env python3
"""Prepare joe/main.c for zig translate-c (goto-free, Unix-only).

Writes /tmp/main_stubs.h and /tmp/main_nogoto.c.

Pipeline:
  python3 tools/port_main_transform.py
  zig translate-c /tmp/main_nogoto.c -I /tmp -lc > /tmp/main_raw.zig
  python3 tools/clean_translate_c.py /tmp/main_raw.zig src/main.zig \\
    --title 'Editor startup and edit loop — replaces `joe/main.c`.' \\
    --blurb 'Faithful C-ABI Path A port of JOE main (maint/edupd/edloop/… + entry).'
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent
SRC = ROOT / "joe/main.c"
OUT = Path("/tmp/main_nogoto.c")
STUBS_OUT = Path("/tmp/main_stubs.h")

EDLOOP_OLD = r'''int edloop(int flg)
{
	int term = 0;
	int ret = 0;

	if (flg) {
		if (maint->curwin->watom->what == TYPETW)
			return 0;
		else
			maint->curwin->notify = &term;
	}
	while (!leave && (!flg || !term)) {
		W *w;
		MACRO *m;
		BW *bw;
		int c;
		int auto_off = 0;
		int word_off = 0;
		int spaces_off = 0;

		if (exmsg && !flg) {
			vsrm(exmsg);
			exmsg = NULL;
		}
		edupd(1);
		if (!ahead && !have)
			ahead = 1;
		if (ungot) {
			c = ungotc;
			ungot = 0;
		} else
			c = ttgetch();

		/* Clear temporary messages */
		w = maint->curwin;
		do {
			if (w->y != -1) {
				msgclr(w);
			}
			w = (W *) (w->link.next);
		} while (w != maint->curwin);

		more_no_auto:

		if (maint->curwin->watom->what & (TYPETW | TYPEPW))
			bw = (BW *)maint->curwin->object;
		else
			bw = 0;

		/* Insert CR not LF when pasting to get a newline and not deleol */
		if (c == 10 && (!ahead || (bw && bw->pasting)))
			c = 13;

		/* Use special kbd if we're handing data to a shell window */
		if (shell_kbd && (maint->curwin->watom->what & TYPETW) && bw->b->pid && !bw->b->vt && !bw->b->raw && piseof(bw->cursor))
			m = dokey(shell_kbd, c);
		else if ((maint->curwin->watom->what & TYPETW) && bw->b->pid && bw->b->vt && bw->cursor->byte == bw->b->vt->vtcur->byte)
			m = dokey(bw->b->vt->kbd, c);
		else
			m = dokey(maint->curwin->kbd, c);

		/* leading part of backtick hack... */
		/* should only do this if backtick is uquote, but you're not likely to get quick typeahead with ESC ' as uquote */
		if (pastehack && m && m->cmd && m->cmd->func == uquote && ttcheck()) {
			m = type_backtick;
		}

		/* disable autoindent if it looks like a mouse paste... */
		if (pastehack && m && m->cmd && (m->cmd->func == utype || m->cmd->func == urtn) && (maint->curwin->watom->what & TYPETW) &&
		    (bw->o.autoindent || bw->o.wordwrap || bw->o.spaces) && ttcheck()) {
			auto_off = bw->o.autoindent;
			bw->o.autoindent = 0;
			word_off = bw->o.wordwrap;
			bw->o.wordwrap = 0;
			spaces_off = bw->o.spaces;
			bw->o.spaces = 0;
		}

		/* FIXME: if we don't receive input in a reasonably short time,
		 * assume that the pasting's done and call ubrpaste_done.
		 * Also need to do that on switching buffer? Other times? */
		if (bw && bw->pasting) exemac_pasting(1); /* we're in paste mode */

		if (maint->curwin->main && maint->curwin->main != maint->curwin) {
			ptrdiff_t x = maint->curwin->kbd->x;

			maint->curwin->main->kbd->x = x;
			if (x)
				maint->curwin->main->kbd->seq[x - 1] = maint->curwin->kbd->seq[x - 1];
		}
		if (!m) {
			m = timer_play();
			c = NO_MORE_DATA;
		}
		if (m)
			ret = exemac(m, c);

		/* trailing part of backtick hack... */
		/* for case where ` is very last character of pasted block */
		while (pastehack && !leave && (!flg || !term) && m && (m == type_backtick || (m->cmd && (m->cmd->func == utype || m->cmd->func == urtn))) && ttcheck() && havec == '`') {
			ttgetch();
			ret = exemac(type_backtick, NO_MORE_DATA);
		}

		/* exemac could have invalidated bw, but hopefully not from paste */
		if (!leave && maint->curwin->watom->what & (TYPETW | TYPEPW))
			bw = (BW *)maint->curwin->object;
		else
			bw = 0;
		if (bw && !bw->pasting) exemac_pasting(0); /* okay, done for now */

		/* trailing part of disabled autoindent */
		if (pastehack && !leave && (!flg || !term) && m && (m == type_backtick || (m->cmd && (m->cmd->func == utype || m->cmd->func == urtn))) && ttcheck()) {
			if (ungot) {
				c = ungotc;
				ungot = 0;
			} else
				c = ttgetch();
			goto more_no_auto;
		}

		/* Restore modes */
		if (!leave && maint->curwin->watom->what & TYPETW) {
			bw = (BW *)maint->curwin->object;

			if (auto_off) {
				auto_off = 0;
				bw->o.autoindent = 1;
			}

			if (word_off) {
				word_off = 0;
				bw->o.wordwrap = 1;
			}

			if (spaces_off) {
				spaces_off = 0;
				bw->o.spaces = 1;
			}
		}

	}

	if (term == -1)
		return -1;
	else
		return ret;
}'''

EDLOOP_NEW = r'''int edloop(int flg)
{
	int term = 0;
	int ret = 0;

	if (flg) {
		if (maint->curwin->watom->what == TYPETW)
			return 0;
		else
			maint->curwin->notify = &term;
	}
	while (!leave && (!flg || !term)) {
		W *w;
		MACRO *m;
		BW *bw;
		int c;
		int auto_off = 0;
		int word_off = 0;
		int spaces_off = 0;

		if (exmsg && !flg) {
			vsrm(exmsg);
			exmsg = NULL;
		}
		edupd(1);
		if (!ahead && !have)
			ahead = 1;
		if (ungot) {
			c = ungotc;
			ungot = 0;
		} else
			c = ttgetch();

		/* Clear temporary messages */
		w = maint->curwin;
		do {
			if (w->y != -1) {
				msgclr(w);
			}
			w = (W *) (w->link.next);
		} while (w != maint->curwin);

		/* was: more_no_auto: / goto more_no_auto */
		while (1) {
			if (maint->curwin->watom->what & (TYPETW | TYPEPW))
				bw = (BW *)maint->curwin->object;
			else
				bw = 0;

			/* Insert CR not LF when pasting to get a newline and not deleol */
			if (c == 10 && (!ahead || (bw && bw->pasting)))
				c = 13;

			/* Use special kbd if we're handing data to a shell window */
			if (shell_kbd && (maint->curwin->watom->what & TYPETW) && bw->b->pid && !bw->b->vt && !bw->b->raw && piseof(bw->cursor))
				m = dokey(shell_kbd, c);
			else if ((maint->curwin->watom->what & TYPETW) && bw->b->pid && bw->b->vt && bw->cursor->byte == bw->b->vt->vtcur->byte)
				m = dokey(bw->b->vt->kbd, c);
			else
				m = dokey(maint->curwin->kbd, c);

			/* leading part of backtick hack... */
			/* should only do this if backtick is uquote, but you're not likely to get quick typeahead with ESC ' as uquote */
			if (pastehack && m && m->cmd && m->cmd->func == uquote && ttcheck()) {
				m = type_backtick;
			}

			/* disable autoindent if it looks like a mouse paste... */
			if (pastehack && m && m->cmd && (m->cmd->func == utype || m->cmd->func == urtn) && (maint->curwin->watom->what & TYPETW) &&
			    (bw->o.autoindent || bw->o.wordwrap || bw->o.spaces) && ttcheck()) {
				auto_off = bw->o.autoindent;
				bw->o.autoindent = 0;
				word_off = bw->o.wordwrap;
				bw->o.wordwrap = 0;
				spaces_off = bw->o.spaces;
				bw->o.spaces = 0;
			}

			/* FIXME: if we don't receive input in a reasonably short time,
			 * assume that the pasting's done and call ubrpaste_done.
			 * Also need to do that on switching buffer? Other times? */
			if (bw && bw->pasting) exemac_pasting(1); /* we're in paste mode */

			if (maint->curwin->main && maint->curwin->main != maint->curwin) {
				ptrdiff_t x = maint->curwin->kbd->x;

				maint->curwin->main->kbd->x = x;
				if (x)
					maint->curwin->main->kbd->seq[x - 1] = maint->curwin->kbd->seq[x - 1];
			}
			if (!m) {
				m = timer_play();
				c = NO_MORE_DATA;
			}
			if (m)
				ret = exemac(m, c);

			/* trailing part of backtick hack... */
			/* for case where ` is very last character of pasted block */
			while (pastehack && !leave && (!flg || !term) && m && (m == type_backtick || (m->cmd && (m->cmd->func == utype || m->cmd->func == urtn))) && ttcheck() && havec == '`') {
				ttgetch();
				ret = exemac(type_backtick, NO_MORE_DATA);
			}

			/* exemac could have invalidated bw, but hopefully not from paste */
			if (!leave && maint->curwin->watom->what & (TYPETW | TYPEPW))
				bw = (BW *)maint->curwin->object;
			else
				bw = 0;
			if (bw && !bw->pasting) exemac_pasting(0); /* okay, done for now */

			/* trailing part of disabled autoindent */
			if (pastehack && !leave && (!flg || !term) && m && (m == type_backtick || (m->cmd && (m->cmd->func == utype || m->cmd->func == urtn))) && ttcheck()) {
				if (ungot) {
					c = ungotc;
					ungot = 0;
				} else
					c = ttgetch();
				continue; /* more_no_auto */
			}

			/* Restore modes */
			if (!leave && maint->curwin->watom->what & TYPETW) {
				bw = (BW *)maint->curwin->object;

				if (auto_off) {
					auto_off = 0;
					bw->o.autoindent = 1;
				}

				if (word_off) {
					word_off = 0;
					bw->o.wordwrap = 1;
				}

				if (spaces_off) {
					spaces_off = 0;
					bw->o.spaces = 1;
				}
			}
			break;
		}

	}

	if (term == -1)
		return -1;
	else
		return ret;
}'''


def strip_platform(src: str) -> str:
    src = src.replace("#ifdef MOUSE_GPM\n", "#if 0 /* MOUSE_GPM */\n")
    src = src.replace("#ifdef __MSDOS__\n", "#if 0 /* __MSDOS__ */\n")
    src = src.replace("#ifndef __MSDOS__\n", "#if 1 /* !__MSDOS__ */\n")
    return src


def convert_nope(src: str) -> str:
    """Rewrite locale joerc lookup `goto nope` into structured if/else."""
    old = r'''	if (!stat(t,&sbuf))
		time_rc = sbuf.st_mtime;
	else {
		/* Try generic language: like joerc.de */
		if (locale_msgs[0] && locale_msgs[1] && locale_msgs[2]=='_') {
			vsrm(t);
			t = vsncpy(NULL, 0, sc(JOERC));
			t = vsncpy(sv(t), sv(run));
			t = vsncpy(sv(t), sc("rc."));
			t = vsncpy(sv(t), locale_msgs, 2);
			if (!stat(t,&sbuf))
				time_rc = sbuf.st_mtime;
			else
				goto nope;
		} else {
			nope:
			vsrm(t);
			/* Try non-localized */
			t = vsncpy(NULL, 0, sc(JOERC));
			t = vsncpy(sv(t), sv(run));
			t = vsncpy(sv(t), sc("rc"));
			if (!stat(t,&sbuf))
				time_rc = sbuf.st_mtime;
			else {
				time_rc = 0;
				vsrm(t);
				t = 0;
			}
		}
	}'''
    new = r'''	if (!stat(t,&sbuf))
		time_rc = sbuf.st_mtime;
	else {
		int need_nope = 0;
		/* Try generic language: like joerc.de */
		if (locale_msgs[0] && locale_msgs[1] && locale_msgs[2]=='_') {
			vsrm(t);
			t = vsncpy(NULL, 0, sc(JOERC));
			t = vsncpy(sv(t), sv(run));
			t = vsncpy(sv(t), sc("rc."));
			t = vsncpy(sv(t), locale_msgs, 2);
			if (!stat(t,&sbuf))
				time_rc = sbuf.st_mtime;
			else
				need_nope = 1;
		} else {
			need_nope = 1;
		}
		if (need_nope) {
			/* was: nope: */
			vsrm(t);
			/* Try non-localized */
			t = vsncpy(NULL, 0, sc(JOERC));
			t = vsncpy(sv(t), sv(run));
			t = vsncpy(sv(t), sc("rc"));
			if (!stat(t,&sbuf))
				time_rc = sbuf.st_mtime;
			else {
				time_rc = 0;
				vsrm(t);
				t = 0;
			}
		}
	}'''
    if old not in src:
        raise SystemExit("nope block not found")
    return src.replace(old, new)


def convert_main_gotos(src: str) -> str:
    """Replace exit_errors/donerc gotos with helper + rc_done flag."""
    # Insert helper before main
    helper = r'''
static int exit_with_errors(void)
{
	/* Write out error log to console if we are exiting with errors. */
	if (startup_log && startup_log->eof->byte)
		bsavefd(startup_log->bof, 2, startup_log->eof->byte);

	return 1;
}

'''
    marker = "int main(int argc, char **real_argv, const char * const *envv)\n"
    idx = src.find(marker)
    if idx < 0:
        raise SystemExit("main() not found")
    src = src[:idx] + helper + src[idx:]

    src = src.replace("\t\tgoto exit_errors;\n", "\t\treturn exit_with_errors();\n")
    src = src.replace("\tgoto exit_errors;\n", "\treturn exit_with_errors();\n")

    start = src.find("\t/* Load rc file */\n")
    if start < 0:
        raise SystemExit("Load rc file marker not found")
    donerc = src.find("\tdonerc:\n", start)
    if donerc < 0:
        raise SystemExit("donerc label not found")

    exit_lab = src.find("\nexit_errors:\n")
    if exit_lab < 0:
        raise SystemExit("exit_errors label not found")

    # Successful path after rc (through return 0). Main's closing brace lives
    # after the exit_errors body in the original — append it ourselves.
    after_donerc = src[donerc + len("\tdonerc:\n") : exit_lab]

    rc_region = src[start:donerc]
    # Braced so `break` is tied to the if that guarded `goto donerc`
    rc_region = rc_region.replace("goto donerc;", "{ rc_done = 1; break; }")

    # Declare rc_done with other locals — splice near filesonly
    decl_anchor = "\tint filesonly;\n"
    if decl_anchor not in src[:start]:
        raise SystemExit("filesonly decl not found")
    src = src.replace(decl_anchor, decl_anchor + "\tint rc_done;\n", 1)

    # Re-find start after splice (offset +1 line)
    start = src.find("\t/* Load rc file */\n")
    donerc = src.find("\tdonerc:\n", start)
    exit_lab = src.find("\nexit_errors:\n")
    after_donerc = src[donerc + len("\tdonerc:\n") : exit_lab]
    rc_region = src[start:donerc].replace("goto donerc;", "{ rc_done = 1; break; }")

    new_rc = (
        "\trc_done = 0;\n"
        "\tdo {\n"
        + rc_region
        + "\t} while (0);\n"
        "\tif (!rc_done)\n"
        "\t\treturn exit_with_errors();\n"
    )

    # Drop unreachable return-before-while close if present
    new_rc = new_rc.replace(
        "\treturn exit_with_errors();\n"
        "\t} while (0);\n",
        "\t} while (0);\n",
    )

    src = src[:start] + new_rc + after_donerc
    # Drop exit_errors label/body; restore main's closing brace
    exit_lab = src.find("\nexit_errors:\n")
    if exit_lab >= 0:
        src = src[:exit_lab]
    src = src.rstrip() + "\n}\n"
    return src


def main() -> None:
    stubs = (HERE / "main_stubs.h").read_text()
    STUBS_OUT.write_text(stubs)

    src = SRC.read_text(encoding="latin-1")
    if "REMOVED from the live link" in src:
        raise SystemExit("joe/main.c is already a tombstone; restore C body from git to re-run")
    src = src.replace('#include "types.h"\n', "")
    src = strip_platform(src)

    if EDLOOP_OLD not in src:
        raise SystemExit("edloop body not found (whitespace drift?)")
    src = src.replace(EDLOOP_OLD, EDLOOP_NEW)

    src = convert_nope(src)
    src = convert_main_gotos(src)

    real_gotos = [
        f"{i}:{line.rstrip()}"
        for i, line in enumerate(src.splitlines(), 1)
        if re.search(r"(?m)^\s*goto\b", line)
    ]
    if real_gotos:
        raise SystemExit(f"goto remains: {real_gotos}")

    header = (
        "/* main.c for zig translate-c (goto-free, Unix-only) */\n"
        '#include "main_stubs.h"\n\n'
    )
    OUT.write_text(header + src)
    print("wrote", OUT, "lines", (header + src).count("\n"))


if __name__ == "__main__":
    main()
