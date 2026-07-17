static void dodnscrl(SCRN *t, ptrdiff_t top, ptrdiff_t bot, ptrdiff_t amnt, int atr)
{
	ptrdiff_t a = amnt;
	int did = 0;

	if (!amnt)
		return;
	set_attr(t, atr);
	if (top == 0 && bot == t->li && (t->sr || t->SR)) {
		setregn(t, 0, t->li);
		cpos(t, 0, 0);
		if ((amnt == 1 && t->sr) || !t->SR)
			while (a--)
				texec(t->cap, t->sr, 1, 0, 0, 0, 0);
		else
			texec(t->cap, t->SR, a, a, 0, 0, 0);
		did = 1;
	} else if (bot == t->li && (t->al || t->AL)) {
		setregn(t, 0, t->li);
		cpos(t, 0, top);
		if ((amnt == 1 && t->al) || !t->AL)
			while (a--)
				texec(t->cap, t->al, 1, top, 0, 0, 0);
		else
			texec(t->cap, t->AL, a, a, 0, 0, 0);
		did = 1;
	} else if (t->cs && (t->sr || t->SR)) {
		setregn(t, top, bot);
		cpos(t, 0, top);
		if ((amnt == 1 && t->sr) || !t->SR)
			while (a--)
				texec(t->cap, t->sr, 1, top, 0, 0, 0);
		else
			texec(t->cap, t->SR, a, a, 0, 0, 0);
		did = 1;
	} else if ((t->dl || t->DL) && (t->al || t->AL)) {
		cpos(t, 0, bot - amnt);
		if ((amnt == 1 && t->dl) || !t->DL)
			while (a--)
				texec(t->cap, t->dl, 1, bot - amnt, 0, 0, 0);
		else
			texec(t->cap, t->DL, a, a, 0, 0, 0);
		a = amnt;
		cpos(t, 0, top);
		if ((amnt == 1 && t->al) || !t->AL)
			while (a--)
				texec(t->cap, t->al, 1, top, 0, 0, 0);
		else
			texec(t->cap, t->AL, a, a, 0, 0, 0);
		did = 1;
	}
	if (!did) {
		msetI(t->updtab + top, 1, bot - top);
		return;
	}
	mmove(t->scrn + (top + amnt) * t->co, t->scrn + top * t->co, (bot - top - amnt) * t->co * SIZEOF(int [COMPOSE]));
	mmove(t->attr + (top + amnt) * t->co, t->attr + top * t->co, (bot - top - amnt) * t->co * SIZEOF(int));

	if (!top && t->da) {
		mfill(t->scrn, -1, amnt * t->co);
		msetI(t->attr, 0, amnt * t->co);
		msetI(t->updtab, 1, amnt);
	} else {
		mfill(t->scrn + t->co * top, ' ', amnt * t->co);
		msetI(t->attr + t->co * top, 0, amnt * t->co);
	}
}
