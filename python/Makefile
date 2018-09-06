# Makefile for building python dependent stuff

MBF_TOP := $(shell readlink -f '$(CURDIR)/..')
include $(MBF_TOP)/Makefile.common

default: mbf/defs_path.py
.PHONY: default

mbf/defs_path.py: ../CONFIG
	echo 'HERE = "$(CURDIR)/mbf"' >$@
	echo 'MBF_TOP = "$(MBF_TOP)"' >>$@
	echo 'DEFS = "$(MBF_TOP)/AMC525/vhd/register_defs.in"' >>$@
	echo 'SITE = "$(SITE)"' >>$@
	echo 'SITE_DIR = "$(MBF_TOP)/sites/$(SITE)"' >>$@

clean:
	rm -f mbf/defs_path.py
.PHONY: clean
