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

default: $(SCRIPTS) $(RESSOURCES) install-py mbfstartioc-res macroserver-res
.PHONY: default

$(RESSOURCES): %.res: ../epics/db/tmbf.db
	tools/epics_to_tango.py ../epics/db/tmbf.db $(subst e2t_,,$*) > $(RESSOURCE_DIR)/$*.res

%.py: $(SCRIPT_DIR)/%.py
	ln -sf ../../sites/$(SITE)/scripts/tango/$@ macros/$@

mbfstartioc-res:
	make -C servers/MBFStartIOC
.PHONY: mbfstartioc-res

mbfstartioc-res-clean:
	make -C servers/MBFStartIOC clean
.PHONY: mbfstartioc-res-clean

macroserver-res:
	make -C servers/MacroServer
.PHONY: macroserver-res

macroserver-res-clean:
	make -C servers/MacroServer clean
.PHONY: macroserver-res-clean

install-py:
	install -d $(INSTALL_DIR)
	install -T servers/MBFStartIOC/MBFStartIOC.py $(INSTALL_DIR)/MBFStartIOC

clean: mbfstartioc-res-clean macroserver-res-clean
	rm -f macros/*.py
	rm -f tools/*.pyc
	rm -f $(RESSOURCE_DIR)/*.res
	rm -f $(INSTALL_DIR)/MBFStartIOC
.PHONY: clean
