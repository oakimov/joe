int utw1(W *w, int k)
{
	W *starting = w;
	W *mainw = starting->main;
	Screen *t = mainw->t;
	int myyn;

	do {
		myyn = 0;
		for (;;) {
			do {
				wnext(t);
			} while (t->curwin->main == mainw && t->curwin != starting);
			if (t->curwin->main != mainw) {
				utw0(t->curwin->main, 0);
				myyn = 1;
				continue;
			}
			break;
		}
	} while (myyn);
	return 0;
}
