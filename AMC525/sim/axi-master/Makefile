# Make file for running vsim

ifndef TOP
# ------------------------------------------------------------------------------
# The following is concerned with setting up the build directory and moving the
# rest of the make process over to the build directory.

TOP := $(shell cd ../../..; pwd)


BUILD_DIR = /scratch/tmp/LMBF/sim/axi-master

default $(filter-out clean,$(MAKECMDGOALS)): $(BUILD_DIR)
	VPATH=$(CURDIR) $(MAKE) -f $(CURDIR)/Makefile -C $< \
            SIMDIR=$(CURDIR) TOP=$(TOP) $@

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default clean


else
# ------------------------------------------------------------------------------
# The rest of this Makefile is called in the target build directory.


LM_LICENSE_FILE_LIST = \
    2100@diamcslicserv01.dc.diamond.ac.uk \
    1717@diamrd2208.dc.diamond.ac.uk

SPACE := $(subst ,, )
export LM_LICENSE_FILE := $(subst $(SPACE),:,$(LM_LICENSE_FILE_LIST))

VIVADO = /dls_sw/FPGA/Xilinx/Vivado/2015.1/settings64.sh
RUN_VSIM = /dls_sw/FPGA/Questa/10.4/questasim/bin/vsim
RUN_VIVADO = source $(VIVADO) && vivado

VHDDIR = $(TOP)/AMC525/vhd

# Directory where block design simulation is built, needs to be working
# directory for running vsim.
BEHAV = interconnect/interconnect.sim/sim_1/behav

default: vsim

$(BEHAV)/msim: $(SIMDIR)/bench/interconnect.tcl
	$(RUN_VIVADO) -mode batch -source $(SIMDIR)/do/create_bd.tcl \
            -tclargs interconnect -tclargs $<
	cd $(BEHAV)  && \
        $(RUN_VSIM) -c -do interconnect_wrapper_compile.do -do quit

vsim: $(BEHAV)/msim
	ln -sfn $(BEHAV) .
	ln -sf $(SIMDIR)/do/compile.do behav
	ln -sf $(SIMDIR)/do/modelsim.ini behav
	cd behav  &&  \
        VHD_DIR=$(VHDDIR) BENCH_DIR=$(SIMDIR)/bench $(RUN_VSIM)

interconnect: $(BEHAV)/msim


.PHONY: default interconnect

endif
