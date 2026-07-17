char ttgetc(void)
{
	MACRO *m;
	ptrdiff_t mystat;
	time_t new_time;
	int flg;

	tickon();

	for (;;) {
		flg = 0;
		/* Status line clock */
		new_time = time(NULL);
		if (new_time != last_time) {
			last_time = new_time;
			dostaupd = 1;
			ticked = 1;
		}
		/* Autoscroller */
		if (auto_scroll && mnow() >= auto_trig_time) {
			do_auto_scroll();
			ticked = 1;
			flg = 1;
		}
		ttflsh();
		m = timer_play();
		if (m) {
			exemac(m, NO_MORE_DATA);
			edupd(1);
			ttflsh();
		}
		while (winched) {
			winched = 0;
			dostaupd = 1;
			edupd(1);
			ttflsh();
		}
		if (ticked) {
			edupd(flg);
			ttflsh();
			tickon();
		}
		if (ackkbd != -1) {
			if (!have) {	/* Wait for input */
				mystat = read(mpxfd, &pack, pack.data - (char *)&pack);

				if (pack.size && mystat > 0) {
					if (pack.size < 0 || pack.size > sizeof(pack.data))
						pack.size = sizeof(pack.data);
					joe_read(mpxfd, pack.data, pack.size);
				} else if (mystat < 1) {
					if (winched || ticked)
						continue;
					else
						ttsig(0);
				}
				acceptch = pack.ch;
			}
			have = 0;
			if (pack.who) {	/* Got bknd input */
				if (acceptch != NO_MORE_DATA) {
					if (pack.who->func) {
						pack.who->func(pack.who->object, pack.data, pack.size);
						edupd(1);
					}
				} else
					mpxdied(pack.who);
				continue;
			} else {
				if (acceptch != NO_MORE_DATA) {
					tickoff();
					return TO_CHAR_OK(acceptch);
				} else {
					tickoff();
					ttsig(0);
					return 0;
				}
			}
		}
		if (have) {
			have = 0;
		} else {
			if (read(fileno(termin), &havec, 1) < 1) {
				if (winched || ticked)
					continue;
				else
					ttsig(0);
			}
		}
		tickoff();
		return havec;
	}
}
