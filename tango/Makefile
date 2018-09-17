# Place-holder for building Tango

MBF_TOP = ..
include $(MBF_TOP)/Makefile.common

#Display a warning if not called from above (because we need .db files)

SCRIPT_DIR := $(MBF_TOP)/sites/$(SITE)/scripts/tango
RESSOURCE_DIR := servers/resources

SCRIPTS := $(wildcard $(SCRIPT_DIR)/*)
SCRIPTS := $(notdir $(SCRIPTS))

RESSOURCES =
RESSOURCES += e2t_global.res
RESSOURCES += e2t_horizontal.res
RESSOURCES += e2t_vertical.res

default: $(SCRIPTS) $(RESSOURCES) install
.PHONY: default

$(RESSOURCES): %.res:
	tools/epics_to_tango.py ../epics/db/tmbf.db $(subst e2t_,,$*) > $(RESSOURCE_DIR)/$*.res

%.py: $(SCRIPT_DIR)/%.py
	ln -sf ../../sites/$(SITE)/scripts/tango/$@ macros/$@

install:
	install -d $(INSTALL_DIR)
	install -T servers/MBFStartIOC/MBFStartIOC.py $(INSTALL_DIR)/MBFStartIOC

clean:
	rm -f macros/*.py
	rm -f tools/*.pyc
	rm -f $(RESSOURCE_DIR)/e2t_*
	rm -f $(INSTALL_DIR)/MBFStartIOC
.PHONY: clean
