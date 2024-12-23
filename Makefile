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


# The following file is a prerequisite for both the EPICS and FPGA builds.
DEFS_PATH = python/mbf/defs_path.py


# ------------------------------------------------------------------------------
# FPGA build

# The following targets are passed through to the FPGA build
FPGA_TARGETS = \
    fpga fpga_project runvivado edit_bd save_bd create_bd load_fpga fpga_built \
    reseed
.PHONY: $(FPGA_TARGETS)

$(FPGA_TARGETS): $(FPGA_BUILD_DIR) $(DEFS_PATH)
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
# Miscellanous self contained targets

# All the targets below are implemented by simple recursive calls to make.
DIR_TARGETS = epics matlab tune_fit opi iocs python

$(DIR_TARGETS):
	make -C $@
.PHONY: $(DIR_TARGETS)


$(DEFS_PATH):
	make -C python mbf/defs_path.py

epics: $(DEFS_PATH)
tune_fit: $(DEFS_PATH)


# This is a bit excessive, as the whole epics build isn't a real dependency, but
# it's more manageable this way.
opi: epics



# Note that because we use pattern matching for our subdirectory clean targets,
# we can't mark these targets as .PHONY, because it seems that .PHONY targets
# don't participate in pattern matching.
clean-%:
	make -C $* clean

clean: $(DIR_TARGETS:%=clean-%)
	rm -rf $(BUILD_DIR)
.PHONY: clean


print_version:
	@echo VERSION_EXTRA=$(VERSION_EXTRA)
	@echo VERSION_MAJOR=$(VERSION_MAJOR)
	@echo VERSION_MINOR=$(VERSION_MINOR)
	@echo VERSION_PATCH=$(VERSION_PATCH)
	@echo GIT_VERSION=$(GIT_VERSION)
	@echo MBF_VERSION=$(MBF_VERSION)
.PHONY: print_version
