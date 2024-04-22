#include "include_pp.inc"

program main

  use mo_mkhelper, only: print_mkhelper_hello => print_hello
  use mo_test_submodule, only: &
  &  print_test_submodule_parent => print_hello, &
  &  print_test_submodule_subroutine => print_hello_subroutine, &
  &  print_test_submodule_function => print_hello_function
  use mo_threaded_hello, only: print_threaded_hello => print_hello
  use mo_delayed, only: print_delayed_hello => print_hello
  use mo_cmake_based, only: print_cmake_based_hello => print_hello

#ifdef TEST_INVALID
  use mo_invalid
#endif

#ifdef TEST_MODULE_NATURE
  use mod_test_module_nature_intrinsic
  use mod_test_module_nature_non_intrinsic
#endif

#ifdef INCLUDE_A
  use mod_a
#endif

#ifdef INCLUDE_B
  use mod_b
#endif

#if _OPENMP >= 201511
  use mo_omp45, only: print_omp
#elif _OPENMP >= 201307
  use mo_omp40, only: print_omp
#elif defined(_OPENMP)
  use mo_omp, only: print_omp
#endif

  implicit none
  include "include_fc.inc"

#ifndef NO_NETCDF
  include "netcdf.inc"
  integer ncid
#endif

  integer retval

  character(*), parameter :: string_with_semicolon = &
                            & ";use non_existing_mod"

  print *, included_str

#ifdef INCLUDE_A
  print *, mod_a_str
#endif

#ifdef INCLUDE_A
  print *, mod_b_str
#endif

#ifndef NO_NETCDF
  print *, "Support for NetCDF is enabled."
  print *, "Creating dummy NetCDF file 'dummy.nc'..."
  retval = nf_create("dummy.nc", NF_CLOBBER, ncid)
  if (retval .ne. nf_noerr) stop 2
  retval = nf_close(ncid)
  if (retval .ne. nf_noerr) stop 2

  print *, "The file was successfully created. Deleting it now..."
  open (unit=5, file="dummy.nc", status="old")
  close (unit=5, status="delete")

  print *, "The file was successfully deleted."
#else
  print *, "Support for NetCDF is disabled."
#endif

#ifndef _OPENMP
  print *, "OpenMP is disabled."
#else
  call print_omp()
#endif

  call implicit_external()

  call print_mkhelper_hello()

  call print_test_submodule_parent()
  call print_test_submodule_subroutine()
  retval = print_test_submodule_function()

  print *, "Running threaded bundled library..."
  retval = print_threaded_hello()
  if (retval .ne. 0) stop 2

  call print_delayed_hello()

  call print_cmake_based_hello()

  print *, "Success!"
end program main
