# Top level makefile for building VHDL project

TOP := $(CURDIR)

BUILD_DIR = /scratch/tmp/LMBF/build
VIVADO = /dls_sw/FPGA/Xilinx/Vivado/2015.2/settings64.sh

export LM_LICENSE_FILE = 2100@diamcslicserv01.dc.diamond.ac.uk



default: $(BUILD_DIR)
	make -C $(BUILD_DIR) -f $(TOP)/vhd/Makefile \
            TOP=$(TOP) VIVADO=$(VIVADO)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default clean
