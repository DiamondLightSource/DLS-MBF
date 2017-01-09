# Top level makefile for building VHDL project

TOP := $(CURDIR)

include Makefile.common



default: fpga


# ------------------------------------------------------------------------------
# FPGA build

# The following targets are passed through to the FPGA build
FPGA_TARGETS = fpga fpga_project runvivado edit_bd save_bd load_fpga
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

# The usual dance for building kernel modules out of tree
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
ifdef DMA_BUF_SHIFT
	sudo insmod /tmp/$(DRIVER_NAME).ko dma_block_shift=$(DMA_BUF_SHIFT)
else
	sudo insmod /tmp/$(DRIVER_NAME).ko
endif
	sudo chgrp dcs /dev/amc525_lmbf.*
	sudo chmod g+rw /dev/amc525_lmbf.*

rmmod:
	sudo rmmod $(DRIVER_NAME)

modperm:
	sudo chgrp dcs /dev/amc525_lmbf.*
	sudo chmod g+rw /dev/amc525_lmbf.*

.PHONY: insmod rmmod modperm


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
