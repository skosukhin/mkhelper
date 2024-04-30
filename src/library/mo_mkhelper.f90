module mo_mkhelper
  implicit none
  public
  interface
    module subroutine print_hello()
    end subroutine print_hello
  end interface
end module mo_mkhelper

submodule (mo_mkhelper) smo_mkhelper
  contains
    module subroutine print_hello()
      print *, "Hello from mkhelper library."
    end subroutine print_hello
end submodule smo_mkhelper
