static void cposs(REGISTER SCRN *t, REGISTER ptrdiff_t x, REGISTER ptrdiff_t y)
{
	REGISTER ptrdiff_t bestcost, cost;
	int bestway;
	ptrdiff_t hy;
	ptrdiff_t hl;

	fixupcursor(t);

/* Home y position is usually 0, but it is 'top' if we have scrolling region
 * relative addressing
 */
	if (t->rr) {
		hy = t->top;
		hl = t->bot - 1;
	} else {
		hy = 0;
		hl = t->li - 1;
	}

/* Assume best way is with only using relative cursor positioning */

	bestcost = relcost(t, x, y, t->x, t->y);
	bestway = 0;

/* Now check if combinations of absolute cursor positioning functions are
 * better (or necessary in case one or both cursor positions are unknown)
 */

	if (t->ccm < bestcost) {
		cost = tcost(t->cap, t->cm, 1, y, x, 0, 0);
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 6;
		}
	}
	if (t->ccr < bestcost) {
		cost = relcost(t, x, y, 0, t->y) + t->ccr;
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 1;
		}
	}
	if (t->cho < bestcost) {
		cost = relcost(t, x, y, 0, hy) + t->cho;
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 2;
		}
	}
	if (t->cll < bestcost) {
		cost = relcost(t, x, y, 0, hl) + t->cll;
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 3;
		}
	}
	if (t->cch < bestcost && x != t->x) {
		cost = relcost(t, x, y, x, t->y) + tcost(t->cap, t->ch, 1, x, 0, 0, 0);
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 4;
		}
	}
	if (t->ccv < bestcost && y != t->y) {
		cost = relcost(t, x, y, t->x, y) + tcost(t->cap, t->cv, 1, y, 0, 0, 0);
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 5;
		}
	}
	if (t->ccV < bestcost) {
		cost = relcost(t, x, y, 0, y) + tcost(t->cap, t->cV, 1, y, 0, 0, 0);
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 13;
		}
	}
	if (t->cch + t->ccv < bestcost && x != t->x && y != t->y) {
		cost = tcost(t->cap, t->cv, 1, y - hy, 0, 0, 0) + tcost(t->cap, t->ch, 1, x, 0, 0, 0);
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 7;
		}
	}
	if (t->ccv + t->ccr < bestcost && y != t->y) {
		cost = tcost(t->cap, t->cv, 1, y, 0, 0, 0) + tcost(t->cap, t->cr, 1, 0, 0, 0, 0) + relcost(t, x, y, 0, y);
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 8;
		}
	}
	if (t->cll + t->cch < bestcost) {
		cost = tcost(t->cap, t->ll, 1, 0, 0, 0, 0) + tcost(t->cap, t->ch, 1, x, 0, 0, 0) + relcost(t, x, y, x, hl);
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 9;
		}
	}
	if (t->cll + t->ccv < bestcost) {
		cost = tcost(t->cap, t->ll, 1, 0, 0, 0, 0) + tcost(t->cap, t->cv, 1, y, 0, 0, 0) + relcost(t, x, y, 0, y);
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 10;
		}
	}
	if (t->cho + t->cch < bestcost) {
		cost = tcost(t->cap, t->ho, 1, 0, 0, 0, 0) + tcost(t->cap, t->ch, 1, x, 0, 0, 0) + relcost(t, x, y, x, hy);
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 11;
		}
	}
	if (t->cho + t->ccv < bestcost) {
		cost = tcost(t->cap, t->ho, 1, 0, 0, 0, 0) + tcost(t->cap, t->cv, 1, y, 0, 0, 0) + relcost(t, x, y, 0, y);
		if (cost < bestcost) {
			bestcost = cost;
			bestway = 12;
		}
	}

/* Do absolute cursor positioning if we don't know the cursor position or
 * if it is faster than doing only relative cursor positioning
 */

	switch (bestway) {
	case 1:
		texec(t->cap, t->cr, 1, 0, 0, 0, 0);
		t->x = 0;
		break;
	case 2:
		texec(t->cap, t->ho, 1, 0, 0, 0, 0);
		t->x = 0;
		t->y = hy;
		break;
	case 3:
		texec(t->cap, t->ll, 1, 0, 0, 0, 0);
		t->x = 0;
		t->y = hl;
		break;
	case 9:
		texec(t->cap, t->ll, 1, 0, 0, 0, 0);
		t->x = 0;
		t->y = hl;
		texec(t->cap, t->ch, 1, x, 0, 0, 0);
		t->x = x;
		break;
	case 11:
		texec(t->cap, t->ho, 1, 0, 0, 0, 0);
		t->x = 0;
		t->y = hy;
		texec(t->cap, t->ch, 1, x, 0, 0, 0);
		t->x = x;
		break;
	case 4:
		texec(t->cap, t->ch, 1, x, 0, 0, 0);
		t->x = x;
		break;
	case 10:
		texec(t->cap, t->ll, 1, 0, 0, 0, 0);
		t->x = 0;
		t->y = hl;
		texec(t->cap, t->cv, 1, y, 0, 0, 0);
		t->y = y;
		break;
	case 12:
		texec(t->cap, t->ho, 1, 0, 0, 0, 0);
		t->x = 0;
		t->y = hy;
		texec(t->cap, t->cv, 1, y, 0, 0, 0);
		t->y = y;
		break;
	case 8:
		texec(t->cap, t->cr, 1, 0, 0, 0, 0);
		t->x = 0;
		texec(t->cap, t->cv, 1, y, 0, 0, 0);
		t->y = y;
		break;
	case 5:
		texec(t->cap, t->cv, 1, y, 0, 0, 0);
		t->y = y;
		break;
	case 6:
		texec(t->cap, t->cm, 1, y, x, 0, 0);
		t->y = y;
		t->x = x;
		break;
	case 7:
		texec(t->cap, t->cv, 1, y, 0, 0, 0);
		t->y = y;
		texec(t->cap, t->ch, 1, x, 0, 0, 0);
		t->x = x;
		break;
	case 13:
		texec(t->cap, t->cV, 1, y, 0, 0, 0);
		t->y = y;
		t->x = 0;
		break;
	}

/* Use relative cursor position functions if we're not there yet */

/* First adjust row */
	if (y > t->y) {
		/* Have to go down */
		if (!t->lf || t->cDO < (y - t->y) * t->clf) {
			texec(t->cap, t->DO, 1, y - t->y, 0, 0, 0);
			t->y = y;
		} else
			while (y > t->y) {
				texec(t->cap, t->lf, 1, 0, 0, 0, 0);
				++t->y;
			}
	} else if (y < t->y) {
		/* Have to go up */
		if (!t->up || t->cUP < (t->y - y) * t->cup) {
			texec(t->cap, t->UP, 1, t->y - y, 0, 0, 0);
			t->y = y;
		} else
			while (y < t->y) {
				texec(t->cap, t->up, 1, 0, 0, 0, 0);
				--t->y;
			}
	}

/* Use tabs */
	if (x > t->x && t->ta) {
		ptrdiff_t ntabs = (x - t->x + t->x % t->tw) / t->tw;
		ptrdiff_t cstunder = x % t->tw + t->cta * ntabs;
		ptrdiff_t cstover;

		if (x + t->tw < t->co && t->bs)
			cstover = t->cbs * (t->tw - x % t->tw) + t->cta * (ntabs + 1);
		else
			cstover = 10000;
		if (cstunder < t->cRI && cstunder < x - t->x && cstover > cstunder) {
			if (ntabs) {
				t->x = x - x % t->tw;
				do {
					texec(t->cap, t->ta, 1, 0, 0, 0, 0);
				} while (--ntabs);
			}
		} else if (cstover < t->cRI && cstover < x - t->x) {
			t->x = t->tw + x - x % t->tw;
			++ntabs;
			do {
				texec(t->cap, t->ta, 1, 0, 0, 0, 0);
			} while (--ntabs);
		}
	} else if (x < t->x && t->bt) {
		ptrdiff_t ntabs = ((t->x + t->tw - 1) - (t->x + t->tw - 1) % t->tw - ((x + t->tw - 1) - (x + t->tw - 1) % t->tw)) / t->tw;
		ptrdiff_t cstunder, cstover;

		if (t->bs)
			cstunder = t->cbt * ntabs + t->cbs * (t->tw - x % t->tw);
		else
			cstunder = 10000;
		if (x >= t->tw)
			cstover = t->cbt * (ntabs + 1) + x % t->tw;
		else
			cstover = 10000;
		if (cstunder < t->cLE && (t->bs ? cstunder < (t->x - x) * t->cbs : 1)
		    && cstover > cstunder) {
			if (ntabs) {
				do {
					texec(t->cap, t->bt, 1, 0, 0, 0, 0);
				} while (--ntabs);
				t->x = x + t->tw - x % t->tw;
			}
		} else if (cstover < t->cRI && (t->bs ? cstover < (t->x - x) * t->cbs : 1)) {
			t->x = x - x % t->tw;
			++ntabs;
			do {
				texec(t->cap, t->bt, 1, 0, 0, 0, 0);
			} while (--ntabs);
		}
	}

/* Now adjust column */
	if (x < t->x) {
		/* Have to go left */
		if (!t->bs || t->cLE < (t->x - x) * t->cbs) {
			texec(t->cap, t->LE, 1, t->x - x, 0, 0, 0);
			t->x = x;
		} else
			while (x < t->x) {
				texec(t->cap, t->bs, 1, 0, 0, 0, 0);
				--t->x;
			}
	} else if (x > t->x) {
		/* Have to go right */
		/* Hmm.. this should take into account possible attribute changes */
		if (x-t->x>1 && t->RI) {
			texec(t->cap, t->RI, 1, x - t->x, 0, 0, 0);
			t->x = x;
		} else {
			while(x>t->x) {
				texec(t->cap, t->nd, 1, 0, 0, 0, 0);
				++t->x;
			}
		}

		/* if (t->cRI < x - t->x) { */
/*		} else {
			int *s = t->scrn + t->x + t->y * t->co;
			int *a = t->attr + t->x + t->y * t->co;

			if (t->ins)
				clrins(t);
			while (x > t->x) {
				int atr, c;
				if(*s==-1) c=' ', atr=0;
				else c= *s, atr= *a;

				if (atr != t->attrib)
					set_attr(t, atr);
				utf8_putc(c);
				++s;
				++a;
				++t->x;
			}
		}
*/
	}
}
