DOCUMENT = DEELS2019


default: $(DOCUMENT).pdf

FIGURES += $(wildcard *.png)
FIGURES += $(wildcard *.tikz)



$(DOCUMENT).pdf: $(FIGURES)

CITE_GREP = There were undefined references.
REF_GREP = Rerun to get cross-references right.
NOFILE_GREP = ^No file

LATEX = pdflatex

# Need to run:
#       module load texlive/2015
#
PATH := /dls_sw/apps/texlive/2015/x86_64-linux/:$(PATH)

%.pdf: %.tex
	$(LATEX) </dev/null -halt-on-error $*
	if grep -q '$(CITE_GREP)\|$(REF_GREP)\|$(NOFILE_GREP)' $*.log; then \
            $(LATEX) </dev/null -halt-on-error $*; \
        fi
	rm -f $*.log

%.pdf: %.eps
	epstopdf -o $@ $<


# An insane collection of auxilliary files generated by LaTeX
CLEAN += *.dvi *.aux *.log *.out *.snm *.toc *.vrb *.nav

clean:
	rm -f $(CLEAN)

clean-all: clean
	rm -f $(DOCUMENT).pdf *.ps


.PHONY: default clean clean-all
