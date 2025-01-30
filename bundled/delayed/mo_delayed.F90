#ifdef MANGLE
#  define MODULE_NAME mo_delayed_mangled
#else
#  define MODULE_NAME mo_delayed
#endif

module MODULE_NAME
  implicit none
  public

contains
  subroutine print_hello()
#ifdef MANGLE
    print *, "Hello from the make-time-configured library (mangled)."
#else
    print *, "Hello from the make-time-configured library (original)."
#endif
  end subroutine print_hello

end module MODULE_NAME
