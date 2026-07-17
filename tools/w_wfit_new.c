void wfit(Screen *t)
{
	ptrdiff_t y;		/* Where next window goes */
	ptrdiff_t left;		/* Lines left on screen */
	W *w;			/* Current window we're fitting */
	W *pw;			/* Main window of previous family */
	ptrdiff_t req;		/* Amount this family needs */
	ptrdiff_t adj;		/* Amount family needs to be adjusted */
	int flg;		/* Set if cursor window was placed on screen */
	int ret;

	dostaupd = 1;

	for (;;) {
		flg = 0;
		y = t->wind;
		left = t->h - y;
		pw = NULL;

		w = t->topwin;
		do {
			w->ny = -1;
			w->nh = geth(w);
			w = w->link.next;
		} while (w != t->topwin);

		/* Fit a group of windows on the screen */
		w = t->topwin;
		do {
			req = getgrouph(w);
			if (req > left)	/* If group is taller than lines left */
				adj = req - left;	/* then family gets shorter */
			else
				adj = 0;

			/* Fit a family of windows on the screen */
			do {
				w->ny = y;	/* Set window's y position */
				if (!w->win) {
					pw = w;
					w->nh -= adj;	/* Adjust main window of the group */
				}
				/* Delete child windows to make sure parent has space
				 * 0 lines is acceptable unless cursor is in window, then we
				 * must have 1 line
				 */
				if (!w->win && (w->nh < 0 || (w == t->curwin && w->nh < 1)))
					while ((w->nh < 0 || (w == t->curwin && w->nh < 1)) && w->link.next->win)
						w->nh += doabort(w->link.next, &ret);
				if (w == t->curwin)
					flg = 1;	/* Set if we got window with cursor */
				y += w->nh;
				left -= w->nh;	/* Increment y value by height of window */
				w = w->link.next;	/* Next window */
			} while (w != t->topwin && w->main == w->link.prev->main);
		} while (w != t->topwin && left >= FITHEIGHT);

		/* We can't use extra space to fit a new family on, so give space to parent of
		 * previous family */
		pw->nh += left;

		/* Adjust that family's children which are below the parent */
		while ((pw = pw->link.next) != w)
			pw->ny += left;

		/* Make sure the cursor window got on the screen */
		if (!flg) {
			t->topwin = findbotw(t->topwin)->link.next;
			continue;
		}
		break;
	}

	/* All of the windows are now on the screen.  Scroll the screen to reflect what
	 * happened
	 */
	w = t->topwin;
	do {
		if (w->y >= 0 && w->ny >= 0)
			if (w->ny > w->y) {
				W *l = pw = w;

				while (pw->link.next != t->topwin && (pw->link.next->y < 0 || pw->link.next->ny < 0 || pw->link.next->ny > pw->link.next->y)) {
					pw = pw->link.next;
					if (pw->ny >= 0 && pw->y >= 0)
						l = pw;
				}
				/* Scroll windows between l and w */
				for (;;) {
					if (l->ny >= 0 && l->y >= 0)
						nscrldn(t->t, l->y, l->ny + diff_min(l->h, l->nh), l->ny - l->y);
					if (w == l)
						break;
					l = l->link.prev;
				}
				w = pw->link.next;
			} else if (w->ny < w->y) {
				W *l = pw = w;

				while (pw->link.next != t->topwin && (pw->link.next->y < 0 || pw->link.next->ny < 0 || pw->link.next->ny < pw->link.next->y)) {
					pw = pw->link.next;
					if (pw->ny >= 0 && pw->y >= 0)
						l = pw;
				}
				/* Scroll windows between l and w */
				for (;;) {
					if (w->ny >= 0 && w->y >= 0)
						nscrlup(t->t, w->ny, w->y + diff_min(w->h, w->nh), w->y - w->ny);
					if (w == l)
						break;
					w = w->link.next;
				}
				w = pw->link.next;
			} else
				w = w->link.next;
		else
			w = w->link.next;
	} while (w != t->topwin);

	/* Update current height and position values */
	w = t->topwin;
	do {
		if (w->ny >= 0) {
			if (w->y == -1) {
				msetI(t->t->updtab + w->ny, 1, w->nh);
			}
			w->y = w->ny;
		} else
			w->y = -1;
		w->h = w->nh;
		w->reqh = 0;
		w = w->link.next;
	} while (w != t->topwin);

	/* Call move and resize in a second pass so that they see valid positions for all windows */
	w = t->topwin;
	do {
		if (w->y >= 0) {
			if (w->object) {
				if (w->watom->move)
					w->watom->move(w, w->x, w->y);
				if (w->watom->resize)
					w->watom->resize(w, w->w, w->h);
			}
		}
		w = w->link.next;
	} while (w != t->topwin);
}
