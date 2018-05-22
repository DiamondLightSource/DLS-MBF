# Make file for running vsim

ifndef MBF_TOP
include ../common/SET_TOP

else
include $(COMMON_DIR)/USE_TOP

VPATH += $(VHDDIR)/nco

vsim: nco_cos_sin_table.vhd
	ln -sf $(SIMDIR)/do/*.do .
	ln -sf $(COMMON_DIR)/modelsim.ini .
	$(RUN_VSIM)

endif
