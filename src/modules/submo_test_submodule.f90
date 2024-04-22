submodule (mo_test_submodule) submo_test_submodule
  implicit none

contains
  module subroutine print_hello_subroutine()
    print *, "Hello from submodule test (submodule subroutine)."
  end subroutine print_hello_subroutine

  module function print_hello_function()
    integer :: print_hello_function
    print_hello_function = 0
    print *, "Hello from submodule test (submodule function)."
  end function print_hello_function
end submodule submo_test_submodule
