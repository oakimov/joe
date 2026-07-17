CAP *my_getcap(char *name, long baud, void (*out) (void *, char), void *outptr)
{
	CAP *cap;
	FILE *f, *f1;
	off_t idx;
	int c;
	ptrdiff_t ti;
	ptrdiff_t x, y, z;
	char *tp, *pp, *qq, *namebuf, **npbuf, *idxname;
	int sortsiz;
	int from_env;

	if (!name && !(name = joeterm) && !(name = getenv("TERM")))
		return NULL;
	cap = (CAP *) joe_malloc(SIZEOF(CAP));
	cap->tbuf = vsmk(4096);
	cap->abuf = NULL;
	cap->sort = NULL;

	name = vsncpy(NULL, 0, sz(name));
	cap->sort = (struct sortentry *) joe_malloc(SIZEOF(struct sortentry) * (sortsiz = 64));

	cap->sortlen = 0;

	tp = getenv("TERMCAP");

	if (tp && tp[0] == '/')
		namebuf = vsncpy(NULL, 0, sz(tp));
	else {
		if (tp)
			cap->tbuf = vsncpy(sv(cap->tbuf), sz(tp));
		if ((tp = getenv("TERMPATH")))
			namebuf = vsncpy(NULL, 0, sz(tp));
		else {
			if ((tp = getenv("HOME"))) {
				namebuf = vsncpy(NULL, 0, sz(tp));
				namebuf = vsadd(namebuf, '/');
			} else
				namebuf = NULL;
			namebuf = vsncpy(sv(namebuf), sc(".termcap "));
			namebuf = vsncpy(sv(namebuf), sc(JOERC));
			namebuf = vsncpy(sv(namebuf), sc("termcap /etc/termcap"));
		}
	}

	npbuf = vawords(NULL, sv(namebuf), sc("\t :"));
	vsrm(namebuf);

	y = 0;
	ti = 0;

	from_env = match(cap->tbuf, name);
	if (!from_env)
		cap->tbuf = vstrunc(cap->tbuf, 0);

	/* nextfile / checktc cycle */
	while (1) {
		if (!from_env) {
			if (!npbuf[y]) {
				logmessage_0(joe_gettext(_("Couldn't load termcap entry.  Using ansi default\n")));
				ti = 0;
				cap->tbuf = vsncpy(cap->tbuf, 0, sc(defentry));
			} else {
				idx = 0;
				idxname = vsncpy(NULL, 0, sz(npbuf[y]));
				idxname = vsncpy(idxname, sLEN(idxname), sc(".idx"));
				f1 = fopen((npbuf[y]), "r");
				++y;
				if (!f1)
					continue;
				f = fopen(idxname, "r");
				if (f) {
					struct stat buf, buf1;

					fstat(fileno(f), &buf);
					fstat(fileno(f1), &buf1);
					if (buf.st_mtime > buf1.st_mtime)
						idx = findidx(f, name);
					else
						logmessage_1(joe_gettext(_("termcap: %s is out of date\n")), idxname);
					fclose(f);
				}
				vsrm(idxname);
#ifdef HAVE_FSEEKO
				fseeko(f1, idx, 0);
#else
				fseek(f1, idx, 0);
#endif
				cap->tbuf = lfind(cap->tbuf, ti, f1, name);
				fclose(f1);
				if (sLEN(cap->tbuf) == ti)
					continue;
			}
		}
		from_env = 0;

		/* checktc */
		x = sLEN(cap->tbuf);
		do {
			cap->tbuf[x] = 0;
			while (x && cap->tbuf[--x] != ':')
				/* do nothing */;
		} while (x && (!cap->tbuf[x + 1] || cap->tbuf[x + 1] == ':'));

		if (cap->tbuf[x + 1] == 't' && cap->tbuf[x + 2] == 'c' && cap->tbuf[x + 3] == '=') {
			name = vsncpy(NULL, 0, sz(cap->tbuf + x + 4));
			cap->tbuf[x] = 0;
			cap->tbuf[x + 1] = 0;
			ti = x + 1;
			sLen(cap->tbuf) = x + 1;
			if (y)
				--y;
			continue;
		}

		/* doline: process each null-separated segment */
		while (1) {
			pp = cap->tbuf + ti;

			/* loop: walk colon-separated capabilities */
			while (*pp) {
				while (*pp && *pp != ':')
					++pp;
				if (!*pp)
					break;
				*pp++ = 0;

				/* loop1: parse entries until next colon search needed */
				while (1) {
					int q;
					int found_existing;

					if (pp[0] == ' ' || pp[0] == '\t')
						break; /* resume colon walk */

					for (q = 0; pp[q] && pp[q] != '#' && pp[q] != '=' && pp[q] != '@' && pp[q] != ':'; ++q) ;
					qq = pp;
					c = pp[q];
					pp[q] = 0;
					if (c)
						pp += q + 1;
					else
						pp += q;

					x = 0;
					y = cap->sortlen;
					z = -1;
					found_existing = 0;
					if (y) {
						while (z != (x + y) / 2) {
							int found;

							z = (x + y) / 2;
							found = zcmp(qq, cap->sort[z].name);
							if (found > 0) {
								x = z;
							} else if (found < 0) {
								y = z;
							} else {
								found_existing = 1;
								if (c == '@')
									mmove(cap->sort + z, cap->sort + z + 1, (cap->sortlen-- - (z + 1)) * SIZEOF(struct sortentry));

								else if (c && c != ':')
									cap->sort[z].value = qq + q + 1;
								else
									cap->sort[z].value = NULL;
								break;
							}
						}
					}
					if (!found_existing) {
						/* in: insert new capability */
						if (cap->sortlen == sortsiz)
							cap->sort = (struct sortentry *) joe_realloc(cap->sort, (sortsiz += 32) * SIZEOF(struct sortentry));
						mmove(cap->sort + y + 1, cap->sort + y, (cap->sortlen++ - y) * SIZEOF(struct sortentry));

						cap->sort[y].name = qq;
						if (c && c != ':')
							cap->sort[y].value = qq + q + 1;
						else
							cap->sort[y].value = NULL;
					}
					if (c == ':')
						continue; /* next entry */
					else
						break; /* resume colon walk */
				}
			}

			if (ti) {
				for (--ti; ti; --ti)
					if (!cap->tbuf[ti - 1])
						break;
				continue; /* next segment */
			}
			break;
		}
		break;
	}

	varm(npbuf);
	vsrm(name);

	cap->pad = jgetstr(cap, "pc");
	if (dopadding)
		cap->dopadding = 1;
	else
		cap->dopadding = 0;

	return setcap(cap, baud, out, outptr);
}
