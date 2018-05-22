# Build executable script

MBF_TOP = ..
include $(MBF_TOP)/Makefile.common

default: runioc
.PHONY: default


runioc: runioc.in
	sed 's:@@PYTHON_IOC@@:$(PYTHON_IOC):' $< >$@
	chmod +x $@


clean:
	rm -f runioc
.PHONY: clean
