#include <lslstddef.h>

#define component(f)   ((string)(f))
#define components(v)  llSay(0, component(v.x) + component(v.y) + component(v.z))


default
{
	event touch_start(int t)
	{
		vector one = ZERO_VECTOR;
		vector two = <0.5, 0.5, 2.2>;
		vector composed = one + two;

		components(composed);
	}
}
