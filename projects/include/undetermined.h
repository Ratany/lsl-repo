
#ifndef _UNDETERMINED
#define _UNDETERMINED


// sometimes stuff is undetermined
//
#define fUNDETERMINED              (-1.0)
#define iUNDETERMINED              (-1)
#define vUNDETERMINED              (<fUNDETERMINED, fUNDETERMINED, fUNDETERMINED>)

#define fIsUndetermined(_f)        (fUNDETERMINED == _f)
#define iIsUndetermined(_i)        (!~(_i))
#define vIsUndetermined(_v)        (vUNDETERMINED == _v)


#endif
