static char *lfind(char *s, ptrdiff_t pos, FILE *fd, const char *name)
{
	int c;
	ptrdiff_t x;

	if (!s)
		s = vsmk(1024);
	while (1) {
		int cont = 0;

		while (c = getc(fd), c == ' ' || c == '\t' || c == '#')
			do {
				c = getc(fd);
			} while (!(c == -1 || c == '\n'));
		if (c == -1)
			return s = vstrunc(s, pos);
		ungetc(c, fd);
		s = vstrunc(s, x = pos);
		while (1) {
			c = getc(fd);
			if (c == -1 || c == '\n')
				if (x != pos && s[x - 1] == '\\') {
					--x;
					if (!match(s + pos, name)) {
						cont = 1;
						break;
					} else
						break;
				} else if (!match(s + pos, name)) {
					cont = 1;
					break;
				} else
					return vstrunc(s, x);
			else if (c == '\r')
				/* do nothing */;
			else {
				s = vsset(s, x, TO_CHAR_OK(c));
				++x;
			}
		}
		if (cont)
			continue;
		while (c = getc(fd), c != -1)
			if (c == '\n')
				if (s[x - 1] == '\\')
					--x;
				else
					break;
			else if (c == '\r')
				/* do nothing */;
			else {
				s = vsset(s, x, TO_CHAR_OK(c));
				++x;
			}
		s = vstrunc(s, x);
		return s;
	}
}