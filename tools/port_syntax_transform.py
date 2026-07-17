#!/usr/bin/env python3
"""Transform joe/syntax.c into goto-free / bitfield-free form for zig translate-c."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
src = (ROOT / "joe/syntax.c").read_text()
src = src.replace('#include "types.h"\n', "")

BITS = [
    ("noeat", "CMD_F_NOEAT"),
    ("start_buffering", "CMD_F_START_BUFFERING"),
    ("stop_buffering", "CMD_F_STOP_BUFFERING"),
    ("save_c", "CMD_F_SAVE_C"),
    ("save_s", "CMD_F_SAVE_S"),
    ("push_c", "CMD_F_PUSH_C"),
    ("push_s", "CMD_F_PUSH_S"),
    ("pop_c", "CMD_F_POP_C"),
    ("pop_s", "CMD_F_POP_S"),
    ("ignore", "CMD_F_IGNORE"),
    ("start_mark", "CMD_F_START_MARK"),
    ("stop_mark", "CMD_F_STOP_MARK"),
    ("recolor_mark", "CMD_F_RECOLOR_MARK"),
    ("rtn", "CMD_F_RTN"),
    ("reset", "CMD_F_RESET"),
]

iz_old = """static void iz_cmd(struct high_cmd *cmd)
{
	cmd->noeat = 0;
	cmd->recolor = 0;
	cmd->start_buffering = 0;
	cmd->stop_buffering = 0;
	cmd->save_c = 0;
	cmd->save_s = 0;
	cmd->push_c = 0;
	cmd->push_s = 0;
	cmd->pop_c = 0;
	cmd->pop_s = 0;
	cmd->new_state = 0;
	cmd->keywords = 0;
	cmd->delim = 0;
	cmd->ignore = 0;
	cmd->start_mark = 0;
	cmd->stop_mark = 0;
	cmd->recolor_mark = 0;
	cmd->rtn = 0;
	cmd->reset = 0;
	cmd->call = 0;
}"""

iz_new = """static void iz_cmd(struct high_cmd *cmd)
{
	cmd->flags = 0;
	cmd->recolor = 0;
	cmd->new_state = 0;
	cmd->keywords = 0;
	cmd->delim = 0;
	cmd->call = 0;
}"""
assert iz_old in src, "iz_cmd not found"
src = src.replace(iz_old, iz_new)

recv = "(?:cmd|kw_cmd)"
for field, flag in BITS:
    pat1 = "(" + recv + ")->" + field + r"\s*=\s*1\b"
    pat0 = "(" + recv + ")->" + field + r"\s*=\s*0\b"
    src = re.sub(pat1, r"\1->flags |= " + flag, src)
    src = re.sub(pat0, r"\1->flags &= ~" + flag, src)

for field, flag in BITS:
    leftover = re.findall(recv + "->" + field + r"\s*=", src)
    if leftover:
        raise SystemExit(f"leftover assign {field}: {leftover}")

for field, flag in BITS:
    pat = "(" + recv + ")->" + field + r"\b"
    src = re.sub(pat, r"(\1->flags & " + flag + ")", src)

helper = """
static HIGHLIGHT_STATE syntax_error_invalidate(HIGHLIGHT_STATE h_state, attr_data *attr, attr_data *attr_end, struct state_debug_data *syndebug)
{
	invalidate_state(&h_state);
	/* remainder of these two buffers has unknown content - clear it */
	memset(attr, 0, (size_t)(attr_end - attr) * sizeof(*attr));
	if (syndebug)
		memset(syndebug, 255, (size_t)(attr_end - attr) * sizeof(*syndebug)); /* set to -1 */
	return h_state;
}

"""
anchor = "static HIGHLIGHT_STATE ansi_parse("
assert anchor in src
src = src.replace(anchor, helper + anchor, 1)

old_block = """			if (iters++ > state_count) {
			      error_invalidate_return:
				invalidate_state(&h_state);
				/* remainder of these two buffers has unknown content - clear it */
				memset(attr, 0, (size_t)(attr_end - attr) * sizeof(*attr));
				if (syndebug)
					memset(syndebug, 255, (size_t)(attr_end - attr) * sizeof(*syndebug)); /* set to -1 */
				return h_state;
			}"""
new_block = """			if (iters++ > state_count) {
				return syntax_error_invalidate(h_state, attr, attr_end, syndebug);
			}"""
assert old_block in src, "error block missing"
src = src.replace(old_block, new_block)

old_goto = """				/* Guard against missing jump targets */
				if (!h)
					goto error_invalidate_return;"""
new_goto = """				/* Guard against missing jump targets */
				if (!h)
					return syntax_error_invalidate(h_state, attr, attr_end, syndebug);"""
assert old_goto in src
src = src.replace(old_goto, new_goto)

start = src.index('} else if(!zcmp(bf,"call"))')
end = src.index('} else if(!zcmp(bf,"return"))', start)
new_call = r"""		} else if(!zcmp(bf,"call")) {
			parse_ws(&p,'#');
			if(!parse_char(&p,'=')) {
				parse_ws(&p,'#');
				if (!parse_char(&p,'.')) {
					zlcpy(bf, SIZEOF(bf), syntax->name);
					if (parse_ident(&p,bf1,SIZEOF(bf1)))
						logerror_2(joe_gettext(_("%s %d: Missing subroutine name\n")),name,line);
					else
						cmd->call = load_syntax_subr(bf,bf1,parse_params(syntax->params,&p,name,line));
				} else if (parse_ident(&p,bf,SIZEOF(bf)))
					logerror_2(joe_gettext(_("%s %d: Missing value for option\n")),name,line);
				else {
					if (!parse_char(&p,'.')) {
						if (parse_ident(&p,bf1,SIZEOF(bf1)))
							logerror_2(joe_gettext(_("%s %d: Missing subroutine name\n")),name,line);
						else
							cmd->call = load_syntax_subr(bf,bf1,parse_params(syntax->params,&p,name,line));
					} else
						cmd->call = load_syntax_subr(bf,0,parse_params(syntax->params,&p,name,line));
				}
			} else
				logerror_2(joe_gettext(_("%s %d: Missing value for option\n")),name,line);
"""
src = src[:start] + new_call + src[end:]

src = src.replace("syntax->default_cmd.reset = 1;", "syntax->default_cmd.flags |= CMD_F_RESET;")

assert "goto " not in src, "goto remains"
assert re.search(r"^\s*subr:", src, re.M) is None

header = '/* syntax.c for zig translate-c */\n#include "syntax_stubs.h"\n\n'
out = Path("/tmp/syntax_nogoto.c")
out.write_text(header + src)
print("wrote", out, "lines", (header + src).count("\n"))
print(
    "bitfield residue:",
    re.findall(r"(?:cmd|kw_cmd)->(?:noeat|ignore|rtn|reset|start_buffering)\b", src),
)
