module mo_omp45
  implicit none
  public
contains
  subroutine print_omp()
#if _OPENMP < 201511
    choke
#else
    print *, "OpenMP 4.5 is enabled."
#endif
  end subroutine print_omp
end module mo_omp45
