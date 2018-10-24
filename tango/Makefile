# Makefile for Tango server and resource files

MBF_TOP = ..
include $(MBF_TOP)/Makefile.common

SCRIPT_DIR := $(MBF_TOP)/sites/$(SITE)/scripts/tango
RESSOURCE_DIR := servers/resources

SCRIPTS := $(wildcard $(SCRIPT_DIR)/*)
SCRIPTS := $(notdir $(SCRIPTS))

RESSOURCES =
RESSOURCES += e2t_global.res
RESSOURCES += e2t_horizontal.res
RESSOURCES += e2t_vertical.res

default: $(SCRIPTS) $(RESSOURCES) install-py mbfstartioc-res macroserver-res mbfcontrol-res
.PHONY: default

$(RESSOURCES): %.res: ../epics/db/tmbf.db
	tools/epics_to_tango.py ../epics/db/tmbf.db $(subst e2t_,,$*) > $(RESSOURCE_DIR)/$*.res

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
