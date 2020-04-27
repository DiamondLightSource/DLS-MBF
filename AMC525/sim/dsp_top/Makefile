# Make file for running vsim

ifndef MBF_TOP
include ../common/SET_TOP

else
include $(COMMON_DIR)/USE_TOP

VPATH += $(VHDDIR)
VPATH += $(VHDDIR)/nco
VPATH += $(VHDDIR)/tune_pll

VSIM_DEPENDS = nco_cos_sin_table.vhd cordic_table.vhd register_defs.vhd

vsim: $(VSIM_DEPENDS)
	ln -sf $(SIMDIR)/do/*.do .
	ln -sf $(COMMON_DIR)/modelsim.ini .
	$(RUN_VSIM)

depends: $(VSIM_DEPENDS)
.PHONY: depends

endif
