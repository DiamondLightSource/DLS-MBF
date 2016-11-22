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

%.vhd: %.py %.vhd.in
	python $^ >$@

endif
