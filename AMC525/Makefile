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

INTERCONNECT_BD = interconnect/interconnect.bd


# Default targets
default: fpga
fpga: amc525_lmbf.bit
.PHONY: default fpga


$(INTERCONNECT_BD): $(SRCDIR)/bd/interconnect.tcl
	$(RUN_VIVADO) -mode batch -source $(SRCDIR)/create_bd.tcl \
            -tclargs $<

edit_bd: $(INTERCONNECT_BD)
	$(RUN_VIVADO) -source $(SRCDIR)/edit_bd.tcl
.PHONY: edit_bd

# This target reconstructs bd/interconnect.tcl from an existing design
save_bd:
	$(RUN_VIVADO) -mode batch -source $(SRCDIR)/save_bd.tcl \
            -tclargs '$(SRCDIR)/bd/interconnect.tcl'
	touch $(INTERCONNECT_BD)
.PHONY: save_bd


# Run vivado on project
#
runvivado:
	$(RUN_VIVADO) amc525_lmbf/amc525_lmbf.xpr
.PHONY: runvivado


# Target build
#
amc525_lmbf.bit: $(BUILT_FILES) $(INTERCONNECT_BD) $(SOURCES)
	ln -sfn $(SRCDIR)/vhd $(SRCDIR)/constr .
	mkdir -p reports checkpoints
	$(RUN_VIVADO) -mode batch -source $(SRCDIR)/build_top.tcl


built/top_entity.vhd: constr/signals constr/pins constr/used
	mkdir -p built
	cd built  &&  $(TOP)/scripts/make_entity.py $^ top

top_entity: built/top_entity.vhd
.PHONY: top_entity
