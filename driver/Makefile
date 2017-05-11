# Makefile for building kernel driver and associated RPM

ifndef TOP
$(error Do not call this file directly)
endif

include $(TOP)/Makefile.common

SRCDIR = $(TOP)/driver


DRIVER_NAME = amc525_lmbf
DRIVER_KO = $(DRIVER_NAME).ko

DRIVER_FILES = $(wildcard $(SRCDIR)/*)

driver: $(DRIVER_KO)
.PHONY: driver

# The usual dance for building kernel modules out of tree
DRIVER_BUILD_FILES := $(DRIVER_FILES:$(SRCDIR)/%=%)
$(DRIVER_BUILD_FILES): %: $(SRCDIR)/%
	ln -s $$(readlink -e $<) $@

$(DRIVER_KO): $(DRIVER_BUILD_FILES)
	$(MAKE) -C $(KERNEL_DIR) M=$(CURDIR) modules
	touch $@



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
