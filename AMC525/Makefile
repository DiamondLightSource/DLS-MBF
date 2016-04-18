# This makefile is designed to be called after setting the working directory to
# the target build directory.
ifndef TOP
$(error Do not call this file directly)
endif

SRCDIR = $(TOP)/AMC525

VPATH = $(SRCDIR)


RUN_VIVADO = source $(VIVADO) && vivado


default: top.bit

top.bit: top_entity.vhd $(wildcard $(SRCDIR)/vhd/*.vhd)
	ln -sfn $(SRCDIR)/vhd vhd
	mkdir -p output
	$(RUN_VIVADO) -mode batch -source $(SRCDIR)/build_fpga.tcl


top_entity.vhd: constr/signals constr/pins vhd/used
	$(TOP)/scripts/make_entity.py $^ top

.PHONY: default
