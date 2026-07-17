static ptrdiff_t doabort(W *w, int *ret)
{
	ptrdiff_t amnt = geth(w);
	W *z;
	int again;

	w->y = -2;
	if (w->t->topwin == w)
		w->t->topwin = w->link.next;
	do {
		again = 0;
		z = w->t->topwin;
		do {
			if (z->orgwin == w)
				z->orgwin = NULL;
			if ((z->win == w || z->main == w) && z->y != -2) {
				amnt += doabort(z, ret);
				again = 1;
				break;
			}
		} while (z = z->link.next, z != w->t->topwin);
	} while (again);
	if (w->orgwin)
		seth(w->orgwin, geth(w->orgwin) + geth(w));
	if (w->t->curwin == w) {
		if (w->t->curwin->win)
			w->t->curwin = w->t->curwin->win;
		else if (w->orgwin)
			w->t->curwin = w->orgwin;
		else
			w->t->curwin = w->link.next;
	}
	if (qempty(W, link, w)) {
		leave = 1;
		amnt = 0;
	}
	deque(W, link, w);
	if (w->watom->abort && w->object) {
		*ret = w->watom->abort(w);
		if (w->notify)
			*w->notify = -1;
	} else {
		*ret = -1;
		if (w->notify)
			*w->notify = 1;
	}
	rmkbd(w->kbd);
	windie(w);
	joe_free(w);
	return amnt;
}
