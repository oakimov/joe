/* GPM/xterm mouse functions
   Copyright (C) 1999 Tara McGrew

This file is part of JOE (Joe's Own Editor)

JOE is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; either version 1, or (at your option) any later version.

JOE is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You should have received a copy of the GNU General Public License along with
JOE; see the file COPYING.  If not, write to the Free Software Foundation,
675 Mass Ave, Cambridge, MA 02139, USA.

	REMOVED from the live link (see build.zig).
	Path A JOE `mouse.h` ABI now lives in `src/mouse.zig`
	(Zig exports mouseopen/mouseclose/mousedn/mouseup/mousedrag/
	uxtmouse/uextmouse/utomouse/udefm*/mnow/reset_trig_time +
	floatmouse/rtbutton/joexterm/auto_scroll/auto_trig_time/auto_rate).
	`joe/mouse.h` remains the C declaration surface for remaining C callers.
 */
