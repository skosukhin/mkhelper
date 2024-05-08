module mo_test_submodule_indirect
  implicit none
  public

  contains
    subroutine print_hello()
      print *, "Hello from submodule test (indirect module)."
    end subroutine print_hello
end module mo_test_submodule_indirect
