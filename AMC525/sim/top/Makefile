# Make file for running vsim

ifndef TOP
include ../common/SET_TOP

else
include $(COMMON_DIR)/USE_TOP

VPATH += $(VHDDIR)
VPATH += $(TOP)/AMC525/constr


top_entity.vhd: signals pins used
	$(PYTHONDIR)/make_entity.py $^ top

vsim: register_defs.vhd top_entity.vhd
	ln -sf $(SIMDIR)/do/*.do .
	ln -sf $(COMMON_DIR)/modelsim.ini .
	$(RUN_VSIM)

endif
