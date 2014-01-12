// This program is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see
// <http://www.gnu.org/licenses/>.


#include <lslstddef.h>

#define Memsay(...)                llOwnerSay(fprintl(llGetFreeMemory(), "bytes free", __VA_ARGS__))

#define LIST                       numbers
#define iGetNumber(_n)             llList2Integer(LIST, (_n))

#define foreach(_l, _n, _do)       int _n = Len(_l); LoopDown(_n, _do);

#define iMany                      10

#define INLINE_FUNCTIONS           1


list LIST;

#if INLINE_FUNCTIONS

#define multiply_two(n)							\
	{								\
		Memsay("multiply_two start");				\
		foreach(LIST, two, opf(iGetNumber(n), "times", iGetNumber(two), "makes", iGetNumber(n) * iGetNumber(two))); \
		Memsay("multiply_two end");				\
	}


#define multiply_one()					\
	{						\
		Memsay("multiply_one start");		\
		foreach(LIST, one, multiply_two(one));	\
		Memsay("multiply_one end");		\
	}


#define handle_touch()							\
	{								\
		LIST = [];						\
		int n = iMany;						\
		LoopDown(n, Enlist(LIST, (int)llFrand(2000.0)));	\
		multiply_one();						\
	}

#else

void multiply_two(const int n)
{
	Memsay("multiply_two start");
	foreach(LIST, two, opf(iGetNumber(n), "times", iGetNumber(two), "makes", iGetNumber(n) * iGetNumber(two)));
	Memsay("multiply_two end");
}


void multiply_one()
{
	Memsay("multiply_one start");
	foreach(LIST, one, multiply_two(one));
	Memsay("multiply_one end");
}


void handle_touch()
{
	LIST = [];
	int n = iMany;
	LoopDown(n, Enlist(LIST, (int)llFrand(2000.0)));
	multiply_one();
}

#endif


default
{
	event touch_start(const int t)
	{
		Memsay("before multiplying");
		handle_touch();
		Memsay("after multiplying");
		LIST = [];
		Memsay("list emptied");
	}

	event state_entry()
	{
		Memsay("state entry");
	}
}
