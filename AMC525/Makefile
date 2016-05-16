# This makefile is designed to be called after setting the working directory to
# the target build directory.
ifndef TOP
$(error Do not call this file directly)
endif


SRCDIR = $(TOP)/AMC525

VPATH = $(SRCDIR)


RUN_VIVADO = source $(VIVADO) && vivado


BUILT_FILES += built/top_entity.vhd

SOURCES += $(wildcard $(SRCDIR)/vhd/*.vhd)
SOURCES += $(wildcard $(SRCDIR)/constr/*)

BD_DIR = $(CURDIR)/bd


# Default targets
default: fpga
fpga: amc525_lmbf.bit
.PHONY: default fpga


# Target to edit the block design
#
edit_bd: $(BD_DIR)
	$(RUN_VIVADO) -source $(SRCDIR)/edit_bd.tcl
.PHONY: edit_bd

$(BD_DIR):
	mkdir -p bd
	ln -sfn $(SRCDIR)/bd/* bd


# Run vivado on project
#
vivado:
	$(RUN_VIVADO) amc525_lmbf/amc525_lmbf.xpr
.PHONY: vivado


# Target build
#
amc525_lmbf.bit: $(BUILT_FILES) $(BD_DIR) $(SOURCES)
	ln -sfn $(SRCDIR)/vhd .
	mkdir -p reports checkpoints
	$(RUN_VIVADO) -mode batch -source $(SRCDIR)/build_top.tcl


built/top_entity.vhd: constr/signals constr/pins constr/used
	mkdir -p built
	cd built  &&  $(TOP)/scripts/make_entity.py $^ top

