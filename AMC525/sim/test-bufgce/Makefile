# Make file for running vsim

ifndef TOP
include ../common/SET_TOP

else
include $(COMMON_DIR)/USE_TOP

vsim:
	ln -sf $(SIMDIR)/do/*.do .
	ln -sf $(COMMON_DIR)/modelsim.ini .
	$(RUN_VSIM)

endif
