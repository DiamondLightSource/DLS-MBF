# Top level makefile for building VHDL project

TOP := $(CURDIR)

BUILD_DIR = /scratch/tmp/LMBF
VIVADO = /dls_sw/FPGA/Xilinx/Vivado/2015.2/settings64.sh

export LM_LICENSE_FILE = 2100@diamcslicserv01.dc.diamond.ac.uk


FPGA_BUILD_DIR = $(BUILD_DIR)/fpga


default: $(FPGA_BUILD_DIR)
	make -C $(FPGA_BUILD_DIR) -f $(TOP)/AMC525/Makefile \
            TOP=$(TOP) VIVADO=$(VIVADO)

$(FPGA_BUILD_DIR):
	mkdir -p $(FPGA_BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default clean
