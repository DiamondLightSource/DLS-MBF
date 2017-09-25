# Need to run:
#       module load texlive/2015
#
PATH := /dls_sw/apps/texlive/2015/x86_64-linux/:$(PATH)

LATEX = pdflatex

DOCUMENT = THPHA115

DEPENDS += jacow-2_1.cls
DEPENDS += $(wildcard *.png)
DEPENDS += $(wildcard *.tikz)

POSTER_DEPENDS += figures.pdf
POSTER_DEPENDS += diamond_logo.eps diamond-background.png

TARGETS = $(DOCUMENT).pdf # $(DOCUMENT)_poster.pdf


default: $(TARGETS)

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
	rm -f *.aux *.log
	rm -f $(filter-out $(TARGETS),$(wildcard *.pdf))

clean-all: clean
	rm -f $(TARGETS)


$(DOCUMENT).pdf: $(DEPENDS)

figures.pdf: $(DEPENDS)

$(DOCUMENT)_poster.pdf: $(POSTER_DEPENDS)


.PHONY: default clean clean-all
