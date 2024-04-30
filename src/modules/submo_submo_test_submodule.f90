submodule (mo_test_submodule:submo_test_submodule) submo_submo_test_submodule
  implicit none
contains
  module function print_hello_function()
    integer :: print_hello_function
    print_hello_function = res
    print *, "Hello from submodule test (submodule function)."
  end function print_hello_function
end submodule submo_submo_test_submodule
