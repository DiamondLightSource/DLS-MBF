# Makefile for building kernel driver and associated RPM

ifndef TOP
$(error Do not call this file directly)
endif

kernelver = $(shell uname -r)
KERNEL_DIR = /lib/modules/$(kernelver)/build

include $(TOP)/Makefile.common

SRCDIR = $(TOP)/driver
KBUILD_DIR = $(CURDIR)/kbuild-$(kernelver)

DRIVER_NAME = amc525_lmbf


# Default target is to build the driver
default: driver
.PHONY: driver


# ------------------------------------------------------------------------------
# Build the kernel driver

DRIVER_KO = $(KBUILD_DIR)/$(DRIVER_NAME).ko
DRIVER_FILES = $(wildcard $(SRCDIR)/*)

driver: $(DRIVER_KO)
.PHONY: driver

# The usual dance for building kernel modules out of tree
DRIVER_BUILD_FILES := $(DRIVER_FILES:$(SRCDIR)/%=$(KBUILD_DIR)/%)
$(DRIVER_BUILD_FILES): $(KBUILD_DIR)/%: $(SRCDIR)/%
	mkdir -p $(KBUILD_DIR)
	ln -s $$(readlink -e $<) $@

$(DRIVER_KO): $(DRIVER_BUILD_FILES)
	$(MAKE) -C $(KERNEL_DIR) M=$(KBUILD_DIR) modules
	touch $@


# ------------------------------------------------------------------------------
# Standalone testing

# We need to go via /tmp before invoking insmod at DLS due to our configuration.
insmod: $(DRIVER_KO)
	cp $^ /tmp
	sudo insmod /tmp/$(DRIVER_NAME).ko

rmmod:
	sudo rmmod $(DRIVER_NAME)

.PHONY: insmod rmmod



