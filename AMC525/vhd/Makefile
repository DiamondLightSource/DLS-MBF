# This makefile is designed to be called after setting the working directory to
# the target build directory.
ifndef TOP
$(error Do not call this file directly)
endif

VPATH = $(TOP)


RUN_VIVADO = source $(VIVADO) && vivado


default: top.bit

top.bit: top_entity.vhd $(wildcard $(TOP)/vhd/*.vhd)
	ln -sfn $(TOP)/vhd vhd
	mkdir -p output
	$(RUN_VIVADO) -mode batch -source $(TOP)/scripts/build_fpga.tcl


top_entity.vhd: constr/signals constr/pins vhd/used
	$(TOP)/scripts/make_entity.py $^ top

.PHONY: default
