			case 'd':
			case '2':
			case '3':
				{
					int fmt = c;
					int digs;

					if (fmt == 'd')
						digs = (x < 10) ? 1 : (x < 100) ? 2 : 3;
					else if (fmt == '2')
						digs = (x < 100) ? 2 : 3;
					else
						digs = 3;
					if (digs >= 3) {
						c = '0';
						while (x >= 100) {
							++c;
							x -= 100;
						}
						cap->out(cap->outptr, (char)c);
					}
					if (digs >= 2) {
						c = '0';
						while (x >= 10) {
							++c;
							x -= 10;
						}
						cap->out(cap->outptr, (char)c);
					}
					cap->out(cap->outptr, (char)('0' + x));
					++a;
					break;
				}