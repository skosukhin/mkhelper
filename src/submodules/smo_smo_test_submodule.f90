submodule(mo_test_submodule:smo_test_submodule) smo_smo_test_submodule
implicit none
contains
module function print_hello_function()
  integer :: print_hello_function
  print_hello_function = res
  print *, "Hello from submodule test (submodule of submodule)."
end function print_hello_function
end submodule smo_smo_test_submodule
