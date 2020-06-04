module mo_mkhelper
  implicit none
  public
  contains
    subroutine print_hello()
      print *, "Hello from mkhelper library."
    end subroutine print_hello
end module mo_mkhelper
