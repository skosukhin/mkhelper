submodule (mo_test_submodule) submo_test_submodule
  implicit none

  integer, parameter :: res = 0

contains
  module subroutine print_hello_subroutine()
    print *, "Hello from submodule test (submodule subroutine)."
  end subroutine print_hello_subroutine
end submodule submo_test_submodule
