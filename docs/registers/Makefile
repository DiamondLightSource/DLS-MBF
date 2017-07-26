TOP = ../..

DEPENDS += $(TOP)/AMC525/vhd/register_defs.in
DEPENDS += register_docs.py

default: registers.pdf

registers.pdf: $(DEPENDS)

%.pdf: %.rst
	rst2pdf -e register_docs.py -o $@ $<

%.html: %.rst
	./rst2html $< >$@

clean:
	rm -f *.html *.pdf *.pyc

.PHONY: default clean
