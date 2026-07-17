MACRO *mparse(MACRO *m, const char *buf, ptrdiff_t *sta, int secure)
{
	const char *org = buf;
	int bf[1024];
	char bf1[1024];
	int x;

	for (;;) {
		/* Skip whitespace */
		parse_ws(&buf, 0);

		/* If the buffer is only whitespace then treat as unknown command */
		if (!*buf) {
			*sta = -1;
			return NULL;
		}

		/* Do we have a string? */
		if (parse_Zstring(&buf, bf, SIZEOF(bf)/SIZEOF(bf[0])) >= 0) {
			for (x = 0; bf[x]; ++x) {
				if (m) {
					if (!m->steps) {
						MACRO *macro = m;

						m = mkmacro(NO_MORE_DATA, 0, 0, NULL);
						addmacro(m, macro);
					}
				} else
					m = mkmacro(NO_MORE_DATA, 0, 0, NULL);
				addmacro(m, mkmacro(bf[x], 0, 0, secure ? findcmd("secure_type") : findcmd("type")));
			}
		} else { /* Do we have a command? */
			x = 0;
			while (*buf && *buf != '#' && *buf != '!' && *buf != '~' && *buf !='-' && *buf != ',' &&
			       *buf != ' ' && *buf != '\t' && *buf != '\n' && *buf != '\r') {
				if (x != SIZEOF(bf1) - 1)
					bf1[x++] = *buf;
				++buf;
			}
			bf1[x] = 0;
			if (x) {
				const CMD *cmd;
				int flg = 0;

				if (!secure || !zncmp(bf1, "shell_", 6))
					cmd = findcmd(bf1);
				else
					cmd = 0;

				/* Parse flags */
				while (*buf == '-' || *buf == '!' || *buf == '#' || *buf == '~') {
					if (*buf == '-') flg |= 1;
					if (*buf == '!') flg |= 2;
					if (*buf == '#') flg |= 4;
					if (*buf == '~') flg |= 8;
					++buf;
				}

				if (!cmd) {
					*sta = -1;
					return NULL;
				} else if (m) {
					if (!m->steps) {
						MACRO *macro = m;

						m = mkmacro(NO_MORE_DATA, 0, 0, NULL);
						addmacro(m, macro);
					}
					addmacro(m, mkmacro(NO_MORE_DATA, flg, 0, cmd));
				} else
					m = mkmacro(NO_MORE_DATA, flg, 0, cmd);
			} else { /* not a valid command */
				*sta = -1;
				return NULL;
			}
		}

		/* Skip whitespace */
		parse_ws(&buf, 0);

		/* Do we have a comma? */
		if (*buf == ',') {
			++buf;
			parse_ws(&buf, 0);
			if (*buf && *buf != '\r' && *buf != '\n')
				continue;
			*sta = -2;
			return m;
		}

		/* Done */
		*sta = buf - org;
		return m;
	}
}
