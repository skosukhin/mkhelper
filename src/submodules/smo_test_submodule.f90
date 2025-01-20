submodule(mo_test_submodule) smo_test_submodule
  implicit none

  integer, parameter :: res = 0

contains
  module subroutine print_hello_subroutine()
    print *, "Hello from submodule test (parentless submodule)."
  end subroutine print_hello_subroutine
end submodule smo_test_submodule
