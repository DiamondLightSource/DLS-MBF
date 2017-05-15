# Top level makefile for building VHDL project

TOP := $(CURDIR)

include Makefile.common



default:
	echo Need to specify a build target
	false
.PHONY: default



# ------------------------------------------------------------------------------
# FPGA build

# The following targets are passed through to the FPGA build
FPGA_TARGETS = \
    fpga fpga_project runvivado edit_bd save_bd create_bd load_fpga fpga_built
.PHONY: $(FPGA_TARGETS)

$(FPGA_TARGETS): $(FPGA_BUILD_DIR)
	make -C $< -f $(TOP)/AMC525/Makefile.local TOP=$(TOP) $(MAKECMDGOALS)

$(FPGA_BUILD_DIR):
	mkdir -p $@

clean-fpga:
	rm -rf $(FPGA_BUILD_DIR)
.PHONY: clean-fpga


# ------------------------------------------------------------------------------
# Driver build

DRIVER_TARGETS = driver insmod rmmod install-dkms driver-rpm udev
.PHONY: $(DRIVER_TARGETS)

$(DRIVER_TARGETS): $(DRIVER_BUILD_DIR)
	make -C $< -f $(TOP)/driver/Makefile.local TOP=$(TOP) $(MAKECMDGOALS)

$(DRIVER_BUILD_DIR):
	mkdir -p $@

clean-driver:
	rm -rf $(DRIVER_BUILD_DIR)
.PHONY: clean-driver


# ------------------------------------------------------------------------------
# Tools build

TOOLS_TARGETS = tools
.PHONY: $(TOOLS_TARGETS)

$(TOOLS_TARGETS): $(TOOLS_BUILD_DIR)
	$(MAKE) -C $< -f $(TOP)/tools/Makefile.local TOP=$(TOP) $(MAKECMDGOALS)

$(TOOLS_BUILD_DIR):
	mkdir -p $@

clean-tools:
	rm -rf $(TOOLS_BUILD_DIR)
.PHONY: clean-tools



# ------------------------------------------------------------------------------

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default clean
