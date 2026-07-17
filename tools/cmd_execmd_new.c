int execmd(const CMD *cmd, int k)
{
	BW *bw = (BW *) maint->curwin->object;
	int ret = -1;
	int do_skip = 0;

	/* Warning: bw is a BW * only if maint->curwin->watom->what &
	    (TYPETW|TYPEPW) */

	if (cmd->m)
		return exmacro(cmd->m, 0, k);

	/* We don't execute if we have to fix the column position first
	 * (i.e., left arrow when cursor is in middle of nowhere) */
	if (cmd->flag & ECHKXCOL) {
		if (bw->o.hex)
			bw->cursor->xcol = piscol(bw->cursor);
		else if (!bw->o.viewmode && bw->cursor->xcol != piscol(bw->cursor))
			do_skip = 1;
	}

	/* Don't execute command if we're in wrong type of window */
	if (!do_skip && !(cmd->flag & maint->curwin->watom->what))
		do_skip = 1;

	if (!do_skip) {
		/* Complete selection for block commands */
		if ((cmd->flag & EBLOCK) && nowmarking)
			utoggle_marking(maint->curwin, 0);

		/* We are about to modify the file */
		if ((maint->curwin->watom->what & TYPETW) && (cmd->flag & EMOD)) {
			if (!modify_logic(bw,bw->b))
				do_skip = 1;
		}
	}

	if (!do_skip) {
		/* Execute command */
		ret = cmd->func(maint->curwin, k);

		if (smode)
			--smode;

		/* Don't update anything if we're going to leave */
		if (leave)
			return 0;

		/* cmd->func could have changed bw on us */
		/* This is bad: maint->curwin might not be the same window */
		/* Safer would be to attach a pointer to curwin- if curwin
		   gets clobbered, so does pointer. */
		bw = (BW *) maint->curwin->object;

		/* Maintain position history */
		/* If command was not a positioning command */
		if (!(cmd->flag & EPOS)
		    && (maint->curwin->watom->what & (TYPETW | TYPEPW)))
			afterpos();

		/* If command was not a movement */
		if (!(cmd->flag & (EMOVE | EPOS)) && (maint->curwin->watom->what & (TYPETW | TYPEPW)))
			aftermove(maint->curwin, bw->cursor);

		if (cmd->flag & EKILL)
			justkilled = 1;
		else
			justkilled = 0;
	}

	/* Make displayed cursor column equal the actual cursor column
	 * for commands which arn't simple vertical movements */
	if ((cmd->flag & EFIXXCOL) && (maint->curwin->watom->what & (TYPETW | TYPEPW)))
		if (!bw->o.viewmode)
			bw->cursor->xcol = piscol(bw->cursor);

	/* Recenter cursor to middle of screen */
	if (cmd->flag & EMID) {
		int omid = opt_mid;

		opt_mid = 1;
		dofollows();
		opt_mid = omid;
	}

	if (joe_beep && ret)
		ttputc(7);
	return ret;
}
