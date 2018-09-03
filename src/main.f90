#include "include_pp.inc"
program main
#ifdef USE_MOD_A
  use mod_a
#endif
#ifdef USE_MOD_B
  use mod_b
#endif
  include "include_fc.inc"
  write(*, *) included_str
#ifdef USE_MOD_A
  write(*, *) mod_a_str
#endif
#ifdef USE_MOD_B
  write(*, *) mod_b_str
#endif
end program main
