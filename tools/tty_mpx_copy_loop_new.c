		/* We don't really get EOF from a pty- it would just wait forever
		   until someone else writes to the tty.  So: when the shell
		   dies, the child died signal handler death() puts pty in non-block
		   mode.  This allows us to read any remaining data- then
		   read returns 0 and we know we're done. */

		for (;;) {
			pack.who = m;
			pack.ch = 0;

			/* Read data from process */
			pack.size = joe_read(*ptyfd, pack.data, SIZEOF(pack.data));

			/* On SUNOS 5.8, the very first read from the pty returns 0 for some reason */
			if (!pack.size)
				pack.size = joe_read(*ptyfd, pack.data, SIZEOF(pack.data));

			if (pack.size > 0) {
				/* Send data to JOE, wait for ack */
				joe_write(mpxsfd, &pack, pack.data - (char *)&pack + pack.size);

				joe_read(fds[0], &pack, 1);
				continue;
			} else {
				/* Shell died: return */
				pack.ch = NO_MORE_DATA;
				pack.size = 0;
				joe_write(mpxsfd, &pack, pack.data - (char *)&pack);

				_exit(0);
			}
		}
