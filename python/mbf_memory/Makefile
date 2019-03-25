PYTHON = python

MBF_TOP := $(shell readlink -f '$(CURDIR)/../..')
include $(MBF_TOP)/Makefile.common

# This is run when we type make
dist: setup.py $(wildcard mbf_memory/*)
	$(PYTHON) setup.py bdist_egg
	touch dist

# Clean the module
clean:
	$(PYTHON) setup.py clean
	-rm -rf build dist *egg-info installed.files
	-find -name '*.pyc' -exec rm {} \;

# Install the built egg
install: dist
	$(PYTHON) setup.py easy_install -m \
            --record=installed.files \
            --install-dir=$(PYMOD_INSTALL_DIR) \
            dist/*.egg
