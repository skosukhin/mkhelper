module mo_delayed
  implicit none
  public

contains
  subroutine print_hello()
    print *, "Hello from the make-time-configured library."
  end subroutine print_hello

end module mo_delayed
