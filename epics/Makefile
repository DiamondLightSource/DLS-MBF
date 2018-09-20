# Makefile at top of application tree
TOP = .

export MBF_TOP := $(CURDIR)/..
include $(MBF_TOP)/Makefile.common

include $(TOP)/configure/CONFIG
DIRS += configure
DIRS += Db
DIRS += src
include $(TOP)/configure/RULES_TOP


# Special local rules.  These are needed to handle site specific setting

install: opi/mbf/overview.edl opi/scripts/site

# Alas these soft links need to be wired up the hard way, as our elderly (RHEL6)
# version of ln doesn't support the -r flag yet.
opi/mbf/overview.edl: ../sites/$(SITE)/edm/overview.edl
	ln -sf ../../$< $@

opi/scripts/site:
	ln -sfn ../../../sites/$(SITE)/scripts $@

clean-extra:
	rm -f opi/mbf/overview.edl
	rm -f opi/scripts/site
.PHONY: clean-extra

clean: clean-extra
