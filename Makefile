# Top level makefile for building VHDL project

TOP := $(CURDIR)

include Makefile.common


# Get our version from git.  The name of the most recent parent tag is
# optionally followed by a commit count and a git code.
GIT_VERSION := $(shell git describe --abbrev=7 --dirty --always --tags)

MAKE_LOCAL = \
    $(MAKE) -C $< -f $(TOP)/$1/Makefile.local \
        TOP=$(TOP) GIT_VERSION=$(GIT_VERSION) $(MAKECMDGOALS)


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
	$(call MAKE_LOCAL,AMC525)

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
	$(call MAKE_LOCAL,driver)

$(DRIVER_BUILD_DIR):
	mkdir -p $@

clean-driver:
	rm -rf $(DRIVER_BUILD_DIR)
.PHONY: clean-driver


# ------------------------------------------------------------------------------

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default clean
