# Make file for running vsim

ifndef TOP
include ../common/SET_TOP

else
include $(COMMON_DIR)/USE_TOP

VPATH += $(VHDDIR)
VPATH += $(TOP)/AMC525/constr

TCLDIR = $(TOP)/AMC525/tcl


top_entity.vhd: signals pins used
	$(PYTHON) $(PYTHONDIR)/make_entity.py $^ top

version.vhd: $(TOP)/VERSION
	$(TCLDIR)/make_version.sh $@

vsim: register_defs.vhd top_entity.vhd version.vhd
	ln -sf $(SIMDIR)/do/*.do .
	ln -sf $(COMMON_DIR)/modelsim.ini .
	$(RUN_VSIM)

endif
