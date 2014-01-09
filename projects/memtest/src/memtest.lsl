

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
