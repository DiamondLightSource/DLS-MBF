# Make file for running vsim

ifndef TOP
include ../common/SET_TOP

else
include $(COMMON_DIR)/USE_TOP

VPATH += $(VHDDIR)/nco

vsim: nco_cos_sin_table.vhd
	ln -sf $(SIMDIR)/do/*.do .
	ln -sf $(COMMON_DIR)/modelsim.ini .
	$(RUN_VSIM)

nco_cos_sin_table.vhd: nco_cos_sin_table.py nco_cos_sin_table.vhd.in
	python $^ >$@

endif
