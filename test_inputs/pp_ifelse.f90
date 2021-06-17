! args: --pp-enable --pp-eval-expr --fc-enable -i pp_ifelse.f90
! expected output:
! pp_ifelse.o: pp_ifelse.f90
! pp_ifelse.o: keep4.mod keep5.mod keep6.mod keep1.mod keep2.mod keep3.mod
! end of expected output

#if 0
use ignore1
#endif

#if 1
use keep1
#endif

#ifdef SOME_MACRO
use ignore2
#endif

#define SOME_MACRO
#ifdef SOME_MACRO
use keep2
#endif

#undef SOME_MACRO
#ifdef SOME_MACRO
use ignore3
#endif

#if 0
use ignore4
#elif defined(SOME_MACRO)
use ignore5
 #elif 5 > 4
use keep3
#endif

	#if 1
use keep4
#endif

#if 1
use keep5
   #endif
use keep6
