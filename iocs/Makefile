# Manages links to IOC definition files

MBF_TOP = ..
include $(MBF_TOP)/Makefile.common

CONFIG_DIR = $(MBF_TOP)/sites/$(SITE)/iocs

CONFIGS = $(wildcard $(CONFIG_DIR)/*.config)
IOCS = $(subst .config,,$(notdir $(CONFIGS)))

iocs: $(IOCS)
.PHONY: iocs

%: $(CONFIG_DIR)/%.config
	ln -sf ../tools/start-ioc $@

clean:
	rm -f $(filter-out Makefile,$(wildcard *))
.PHONY: clean
