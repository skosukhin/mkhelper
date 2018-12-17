! Non-intrinsic module with a name of an intrinsic one
module iso_c_binding
end module iso_c_binding

module mod_test_module_nature_intrinsic
  use, intrinsic :: iso_c_binding ! ignore explicitly intrinsic module
end module mod_test_module_nature_intrinsic

module mod_test_module_nature_non_intrinsic
  use, non_intrinsic :: iso_c_binding ! ignore provided module
  use iso_c_binding ! ignore implicitly intrinsic module
end module mod_test_module_nature_non_intrinsic
