# Top level makefile for building VHDL project

TOP := $(CURDIR)

BUILD_DIR = $(TOP)/build
VIVADO = /dls_sw/FPGA/Xilinx/Vivado/2016.1/settings64.sh
KERNEL_DIR = /lib/modules/$(shell uname -r)/build

FPGA_BUILD_DIR = $(BUILD_DIR)/fpga
DRIVER_BUILD_DIR = $(BUILD_DIR)/driver
TOOLS_BUILD_DIR = $(BUILD_DIR)/tools

export LM_LICENSE_FILE = 2100@diamcslicserv01.dc.diamond.ac.uk

-include CONFIG



default: fpga


# ------------------------------------------------------------------------------
# FPGA build

# The following targets are passed through to the FPGA build
FPGA_TARGETS = \
    fpga fpga_project runvivado edit_bd save_bd top_entity load_fpga
.PHONY: $(FPGA_TARGETS)


$(FPGA_TARGETS): $(FPGA_BUILD_DIR)
	make -C $(FPGA_BUILD_DIR) -f $(TOP)/AMC525/Makefile \
            TOP=$(TOP) VIVADO=$(VIVADO) $(MAKECMDGOALS)

$(FPGA_BUILD_DIR):
	mkdir -p $@

clean_fpga:
	rm -rf $(FPGA_BUILD_DIR)
.PHONY: clean_fpga


# ------------------------------------------------------------------------------
# Driver build

DRIVER_NAME = amc525_lmbf
DRIVER_KO = $(DRIVER_BUILD_DIR)/$(DRIVER_NAME).ko

DRIVER_FILES = $(wildcard driver/*)

driver: $(DRIVER_KO)
.PHONY: driver

# The usual dance for building kernel mouldes out of tree
DRIVER_BUILD_FILES := $(DRIVER_FILES:driver/%=$(DRIVER_BUILD_DIR)/%)
$(DRIVER_BUILD_FILES): $(DRIVER_BUILD_DIR)/%: driver/%
	ln -s $$(readlink -e $<) $@

$(DRIVER_KO): $(DRIVER_BUILD_DIR) $(DRIVER_BUILD_FILES)
	$(MAKE) -C $(KERNEL_DIR) M=$< modules
	touch $@

$(DRIVER_BUILD_DIR):
	mkdir -p $@


insmod: $(DRIVER_KO)
	cp $^ /tmp
	sudo insmod /tmp/$(DRIVER_NAME).ko
	sudo chgrp dcs /dev/amc525_lmbf.*
	sudo chmod g+rw /dev/amc525_lmbf.*
.PHONY: insmod

rmmod:
	sudo rmmod $(DRIVER_NAME)


# ------------------------------------------------------------------------------
# Tools build

tools: $(TOOLS_BUILD_DIR)
	$(MAKE) -C $(TOOLS_BUILD_DIR) -f $(TOP)/tools/Makefile \
            VPATH=$(TOP)/tools TOP=$(TOP)

$(TOOLS_BUILD_DIR):
	mkdir -p $@

.PHONY: tools


# ------------------------------------------------------------------------------

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default clean
