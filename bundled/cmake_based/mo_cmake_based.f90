module mo_cmake_based
  implicit none
  public

contains
  subroutine print_hello()
    print *, "Hello from the cmake-based library."
  end subroutine print_hello

end module mo_cmake_based
