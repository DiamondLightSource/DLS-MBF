MBF_TOP = ../..

PYTHON = dls-python

DEPENDS += $(MBF_TOP)/AMC525/vhd/register_defs.in
DEPENDS += register_docs.py

default: registers.pdf

registers.pdf: $(DEPENDS)
registers.html: $(DEPENDS)

%.pdf: %.rst
	rst2pdf -e register_docs.py -o $@ $<

%.html: %.rst
	$(PYTHON) ./rst2html $< >$@

clean:
	rm -f *.html *.pdf *.pyc

.PHONY: default clean
