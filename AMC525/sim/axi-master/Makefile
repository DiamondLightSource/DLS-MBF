# Make file for running vsim

ifndef TOP
include ../common/SET_TOP

else
include $(COMMON_DIR)/USE_TOP

# Directory where block design simulation is built, needs to be working
# directory for running vsim.
BEHAV = interconnect/interconnect.sim/sim_1/behav

$(BEHAV)/msim: $(SIMDIR)/bench/interconnect.tcl
	$(RUN_VIVADO) -mode batch -source $(SIMDIR)/do/create_bd.tcl \
            -tclargs interconnect -tclargs $<
	cd $(BEHAV)  && \
        $(RUN_VSIM) -c -do interconnect_wrapper_compile.do -do quit

vsim: $(BEHAV)/msim
	ln -sfn $(BEHAV) .
	ln -sf $(SIMDIR)/do/compile.do behav
	ln -sf $(COMMON_DIR)/modelsim.ini behav
	cd behav  &&  $(RUN_VSIM)

interconnect: $(BEHAV)/msim


.PHONY: interconnect

endif
