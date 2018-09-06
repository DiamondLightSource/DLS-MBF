# Top level makefile for building VHDL project

MBF_TOP := $(CURDIR)


# We define two sets of targets which can be overridden in the CONFIG file.

# This defines the targets which are built when `make` is run with no target.
# This target is defined for developer convenience.
DEFAULT_TARGETS = epics matlab tune_fit iocs

# These targets are built when `make install` is run, and should define all the
# targets which are expected to be built as part of the system installation.
INSTALL_TARGETS = $(DEFAULT_TARGETS) driver-rpm opi


include Makefile.common

include VERSION


MAKE_LOCAL = \
    $(MAKE) -C $< -f $(MBF_TOP)/$1/Makefile.local MBF_TOP=$(MBF_TOP) $@


default: $(DEFAULT_TARGETS)
.PHONY: default

install: $(INSTALL_TARGETS)
.PHONY: install



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

DRIVER_TARGETS = driver insmod rmmod install-dkms remove-dkms driver-rpm udev
.PHONY: $(DRIVER_TARGETS)

$(DRIVER_TARGETS): $(DRIVER_BUILD_DIR)
	$(call MAKE_LOCAL,driver)

$(DRIVER_BUILD_DIR):
	mkdir -p $@

clean-driver:
	rm -rf $(DRIVER_BUILD_DIR)
.PHONY: clean-driver


# ------------------------------------------------------------------------------
# EPICS build

# The EPICS build is a pain: configure/RELEASE contains core build information
# that must be present before the built begins.  Here we construct it from our
# top level CONFIG file.

epics/configure/RELEASE: CONFIG
	echo '# Automatically generated. DO NOT EDIT THIS FILE!!!' >$@
	echo EPICS_DEVICE = $(EPICS_DEVICE) >>$@
	echo EPICS_BASE = $(EPICS_BASE) >>$@

epics: epics/configure/RELEASE
	make -C $@
.PHONY: epics

clean-epics:
	touch epics/configure/RELEASE
	make -C epics clean uninstall
	rm -f epics/configure/RELEASE
.PHONY: clean-epics


# ------------------------------------------------------------------------------
# Miscellanous other targets

matlab:
	make -C $@
.PHONY: matlab

tune_fit:
	make -C $@
.PHONY: tune_fit

opi:
	make -C $@
.PHONY: opi

iocs:
	make -C $@
.PHONY: iocs


print_version:
	@echo VERSION_EXTRA=$(VERSION_EXTRA)
	@echo VERSION_MAJOR=$(VERSION_MAJOR)
	@echo VERSION_MINOR=$(VERSION_MINOR)
	@echo VERSION_PATCH=$(VERSION_PATCH)
	@echo GIT_VERSION=$(GIT_VERSION)
	@echo MBF_VERSION=$(MBF_VERSION)
.PHONY: print_version


clean: clean-epics
	rm -rf $(BUILD_DIR)
	make -C matlab clean
	make -C tune_fit clean
	make -C opi clean
	make -C iocs clean
.PHONY: clean
