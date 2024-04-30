module mo_test_submodule
  implicit none
  public

  interface
    module subroutine print_hello_subroutine()
    end subroutine print_hello_subroutine

    module function print_hello_function()
      integer :: print_hello_function
    end function print_hello_function

    module function print_hello_function2()
      integer :: print_hello_function2
    end function print_hello_function2
  end interface

  contains
    subroutine print_hello()
      print *, "Hello from submodule test (ancestor module)."
    end subroutine print_hello
end module mo_test_submodule
