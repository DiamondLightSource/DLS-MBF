PYTHON = python

MBF_TOP := $(shell readlink -f '$(CURDIR)/../..')

MUST_DEFINE += PYMOD_INSTALL_DIR
include $(MBF_TOP)/Makefile.common

include $(MBF_TOP)/VERSION


default: mbf_memory/__init__.py
.PHONY: default

mbf_memory/__init__.py: mbf_memory/__init__.py.in $(MBF_TOP)/VERSION
	sed 's/@@VERSION@@/$(MBF_VERSION)/' $< >$@

# This is run when we type make
dist: setup.py mbf_memory/__init__.py $(wildcard mbf_memory/*.py)
	$(PYTHON) setup.py bdist_egg
	touch dist

# Clean the module
clean:
	$(PYTHON) setup.py clean
	-rm -rf build dist *egg-info installed.files
	-find -name '*.pyc' -exec rm {} \;
	rm -f mbf_memory/__init__.py
.PHONY: clean

# Install the built egg
install: dist
	$(PYTHON) setup.py easy_install -m \
            --record=installed.files \
            --install-dir=$(PYMOD_INSTALL_DIR) \
            dist/*.egg
.PHONY: install
