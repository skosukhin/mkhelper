module mo_omp
  implicit none
  public
contains
  subroutine print_omp()
#ifndef _OPENMP
    choke
#else
    print *, "OpenMP 3.1 or older is enabled."
#endif
  end subroutine print_omp
end module mo_omp
