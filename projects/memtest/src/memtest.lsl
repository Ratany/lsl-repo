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


#define WITH_DEFINE_FLOAT 0
#define WITH_DEFINE_INT   0


#if WITH_DEFINE_FLOAT
#define ftest 1.0
#else
float ftest = 1.0;
#endif

#if WITH_DEFINE_INT
#define itest 1
#else
int itest = 1;
#endif



default
{
	event touch_start(int t)
	{
		apf("---");
		apf("the float is", ftest, "and the int is", itest, " with ", llGetFreeMemory(), " bytes free");
		apf("the float is", ftest, "and the int is", itest, " with ", llGetFreeMemory(), " bytes free");
		apf("the float is", ftest, "and the int is", itest, " with ", llGetFreeMemory(), " bytes free");
		apf("the float is", ftest, "and the int is", itest, " with ", llGetFreeMemory(), " bytes free");
		apf("the float is", ftest, "and the int is", itest, " with ", llGetFreeMemory(), " bytes free");
		apf("the float is", ftest, "and the int is", itest, " with ", llGetFreeMemory(), " bytes free");
		apf("the float is", ftest, "and the int is", itest, " with ", llGetFreeMemory(), " bytes free");
		apf("the float is", ftest, "and the int is", itest, " with ", llGetFreeMemory(), " bytes free");
		apf("the float is", ftest, "and the int is", itest, " with ", llGetFreeMemory(), " bytes free");
		apf("the float is", ftest, "and the int is", itest, " with ", llGetFreeMemory(), " bytes free");
		apf("---");
	}
}
