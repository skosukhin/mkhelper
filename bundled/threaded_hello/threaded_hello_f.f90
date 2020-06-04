module mo_threaded_hello

  use iso_c_binding

  implicit none

  public

  interface
    function print_hello() result(err) bind(c)
      import c_int
      integer(c_int) :: err
    end function print_hello
  end interface

end module mo_threaded_hello
