# Need to run:
#       module load texlive/2015
#
PATH := /dls_sw/apps/texlive/2015/x86_64-linux/:$(PATH)

LATEX = pdflatex

PAPER = WECO03

TARGETS += $(PAPER).pdf

default: $(TARGETS)
.PHONY: default


DEPENDS += jacow.cls
DEPENDS += $(wildcard *.png)
DEPENDS += $(wildcard *.tikz)


CITE_GREP = There were undefined references.
REF_GREP = Rerun to get cross-references right.
NOFILE_GREP = ^No file

%.pdf: %.tex
	$(LATEX) </dev/null -halt-on-error $*
	if grep -q '$(CITE_GREP)\|$(REF_GREP)\|$(NOFILE_GREP)' $*.log; then \
            $(LATEX) </dev/null -halt-on-error $*; \
        fi
	rm -f $*.log

clean:
	rm -f *.aux *.log *.nav *.out *.snm *.toc
	rm -f $(filter-out $(TARGETS),$(wildcard *.pdf))

clean-all: clean
	rm -f $(TARGETS)


$(PAPER).pdf: $(DEPENDS)


.PHONY: default clean clean-all
