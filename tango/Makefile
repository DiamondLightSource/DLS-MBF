# Makefile for Tango server and resource files

MBF_TOP = ..
include $(MBF_TOP)/Makefile.common

SCRIPT_DIR := $(MBF_TOP)/sites/$(SITE)/scripts/tango
RESSOURCE_DIR := servers/resources

SCRIPTS := $(wildcard $(SCRIPT_DIR)/*)
SCRIPTS := $(notdir $(SCRIPTS))

TMBF_RES =
TMBF_RES += e2t_tmbf_global.res
TMBF_RES += e2t_tmbf_horizontal.res
TMBF_RES += e2t_tmbf_vertical.res

TFIT_RES =
TFIT_RES += e2t_tfit_horizontal.res
TFIT_RES += e2t_tfit_vertical.res

default: $(SCRIPTS) $(TMBF_RES) $(TFIT_RES) install-py mbfstartioc-res macroserver-res mbfcontrol-res
.PHONY: default

$(TMBF_RES): %.res: ../epics/db/tmbf.db
	tools/T2E_make_res.py tmbf ../epics/db/tmbf.db $(subst e2t_tmbf_,,$*) > $(RESSOURCE_DIR)/$*.res

$(TFIT_RES): %.res: tools/tune_fit.db
	tools/T2E_make_res.py tfit tools/tune_fit.db $(subst e2t_tfit_,,$*) > $(RESSOURCE_DIR)/$*.res

%.py: $(SCRIPT_DIR)/%.py
	ln -sf ../../sites/$(SITE)/scripts/tango/$@ macros/$@

mbfstartioc-res:
	make -C servers/MBFStartIOC -f Makefile-res
.PHONY: mbfstartioc-res

mbfstartioc-res-clean:
	make -C servers/MBFStartIOC -f Makefile-res clean
.PHONY: mbfstartioc-res-clean

macroserver-res:
	make -C servers/MacroServer -f Makefile-res
.PHONY: macroserver-res

macroserver-res-clean:
	make -C servers/MacroServer -f Makefile-res clean
.PHONY: macroserver-res-clean

mbfcontrol-res:
	make -C servers/MBFControl -f Makefile-res
.PHONY: mbfcontrol-res

mbfcontrol-res-clean:
	make -C servers/MBFControl -f Makefile-res clean
.PHONY: mbfcontrol-res-clean

install-py:
	install -d $(INSTALL_DIR)
	install -T servers/MBFStartIOC/MBFStartIOC.py $(INSTALL_DIR)/MBFStartIOC

clean: mbfstartioc-res-clean macroserver-res-clean mbfcontrol-res-clean
	rm -f macros/*.py
	rm -f tools/*.pyc
	rm -f $(RESSOURCE_DIR)/*.res
	rm -f $(INSTALL_DIR)/MBFStartIOC
.PHONY: clean
