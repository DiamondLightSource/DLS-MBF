# Makefile for MacroServer resource files

MBF_TOP = ../../..
include $(MBF_TOP)/Makefile.common

DSERVER_NAME = $(notdir $(shell pwd))

CONFIG_DIR = $(MBF_TOP)/sites/$(SITE)/iocs
CONFIGS = $(wildcard $(CONFIG_DIR)/*.config)
IOCS_RES = $(subst .config,.res,$(notdir $(CONFIGS)))

ressource_iocs: $(IOCS_RES)
.PHONY: ressource_iocs

%.res: $(CONFIG_DIR)/%.config
	make_res $(CONFIG_DIR)/$*.config >$@
	# Copy in resource dir only if generated file is not empty
	if [ -s $@ ] ; then mv $@ ../resources/$(DSERVER_NAME)_$@ ; fi

clean:
	rm -f $(IOCS_RES)
.PHONY: clean
