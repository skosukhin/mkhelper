module mo_omp40
  implicit none
  public
contains
  subroutine print_omp()
#if _OPENMP < 201307
    choke
#else
    print *, "OpenMP 4.0 is enabled."
#endif
  end subroutine print_omp
end module mo_omp40
