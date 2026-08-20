# AMX_CUDA_INIT()
# -----------------------------------------------------------------------------
# Extends ACX_PROG_CUDACXX with Automake-specific checks and substitute
# variable definitions. Must be expanded after AM_INIT_AUTOMAKE.
#
# The macro does NOT provide Automake support for CUDA language, which can be
# achieved only by introducing changes to the automake script, but allows to
# specify dependency generation rules for CUDA source files in the Makefile.am
# as follows:
#
# @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cuda_src_1.Po@am__quote@ # am--include-marker
# @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cuda_src_2.Po@am__quote@ # am--include-marker
# ...
# @AMDEP_TRUE@@am__include@ @am__quote@./$(DEPDIR)/cuda_src_N.Po@am__quote@ # am--include-marker
#
# am__extra_depfiles_remade = \
#   ./$(DEPDIR)/cuda_src_1.Po \
#   ./$(DEPDIR)/cuda_src_2.Po \
# ...
#   ./$(DEPDIR)/cuda_src_N.Po
#
# $(am__extra_depfiles_remade):
# 	@$(MKDIR_P) $(@D)
# 	@echo '# dummy' >$@-t && $(am__mv) $@-t $@
#
# am--depfiles: $(am__depfiles_remade) $(am__extra_depfiles_remade)
#
# CUDACOMPILE = $(CUDACXX) $(AM_CUDAFLAGS) $(CUDAFLAGS)
# AM_V_CUDACXX = $(am__v_CUDACXX_@AM_V@)
# am__v_CUDACXX_ = $(am__v_CUDACXX_@AM_DEFAULT_V@)
# am__v_CUDACXX_0 = @echo "  CUDACXX " $@;
# am__v_CUDACXX_1 =
#
# .cu.o:
# @am__fastdepCUDACXX_TRUE@	$(AM_V_CUDACXX)$(CUDACOMPILE) -MT $@ -MD -MP -MF $(DEPDIR)/$*.Tpo -c -o $@ $<
# @am__fastdepCUDACXX_TRUE@	$(AM_V_at)$(am__mv) $(DEPDIR)/$*.Tpo $(DEPDIR)/$*.Po
# @AMDEP_TRUE@@am__fastdepCUDACXX_FALSE@	$(AM_V_CUDACXX)source='$<' object='$@' libtool=no @AMDEPBACKSLASH@
# @AMDEP_TRUE@@am__fastdepCUDACXX_FALSE@	DEPDIR=$(DEPDIR) $(CUDACXXDEPMODE) $(depcomp) @AMDEPBACKSLASH@
# @am__fastdepCUDACXX_FALSE@	$(AM_V_CUDACXX@am__nodep@)$(CUDACOMPILE) -c -o $@ $<
#
AC_DEFUN([AMX_CUDA_INIT],
  [AC_PROVIDE_IFELSE([AM_INIT_AUTOMAKE], [],
     [m4_fatal([$0 must be called after AM_INIT_AUTOMAKE])])dnl
   AC_PROVIDE_IFELSE([ACX_PROG_CUDACXX],
     [_AM_DEPENDENCIES([CUDACXX])],
     [m4_define([ACX_PROG_CUDACXX],
        m4_defn([ACX_PROG_CUDACXX])[_AM_DEPENDENCIES([CUDACXX])])])])
