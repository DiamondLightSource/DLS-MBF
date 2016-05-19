# Top level makefile for building VHDL project

TOP := $(CURDIR)

BUILD_DIR = $(TOP)/build
VIVADO = /dls_sw/FPGA/Xilinx/Vivado/2016.1/settings64.sh

export LM_LICENSE_FILE = 2100@diamcslicserv01.dc.diamond.ac.uk

-include CONFIG


FPGA_BUILD_DIR = $(BUILD_DIR)/fpga


# The following targets are passed through to the FPGA build
FPGA_TARGETS = fpga fpga_project runvivado edit_bd save_bd top_entity
.PHONY: $(FPGA_TARGETS)

default: fpga


$(FPGA_TARGETS): $(FPGA_BUILD_DIR)
	make -C $(FPGA_BUILD_DIR) -f $(TOP)/AMC525/Makefile \
            TOP=$(TOP) VIVADO=$(VIVADO) $(MAKECMDGOALS)

$(FPGA_BUILD_DIR):
	mkdir -p $(FPGA_BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default clean
