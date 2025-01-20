submodule(mo_test_submodule) smo_test_submodule2
  use mo_test_submodule_indirect, only: &
  & print_hello_indirect => print_hello
  implicit none
contains
  integer module function print_hello_function2()
    print_hello_function2 = 0
    print *, "Hello from submodule test (parentless submodule 2)."
    call print_hello_indirect
  end function print_hello_function2
end submodule smo_test_submodule2
