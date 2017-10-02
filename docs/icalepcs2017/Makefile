# Need to run:
#       module load texlive/2015
#
PATH := /dls_sw/apps/texlive/2015/x86_64-linux/:$(PATH)

LATEX = pdflatex

DOCUMENT = THPHA115

DEPENDS += jacow-2_1.cls
DEPENDS += THPHA115f1.png
DEPENDS += $(wildcard *.tikz)

POSTER_DEPENDS += figures.pdf
POSTER_DEPENDS += diamond_logo.eps diamond-background.png

TARGETS = $(DOCUMENT).pdf $(DOCUMENT)_poster.pdf


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


# There is a rather odd bug in the poster generation code.  If we use the page
# extraction feature of \includegraphics then acroread is unable to load one of
# our images, so instead we use ghostscript to do the extraction.
POSTER_DEPENDS += figures-1.pdf
POSTER_DEPENDS += figures-2.pdf
POSTER_DEPENDS += figures-3.pdf
POSTER_DEPENDS += figures-4.pdf
POSTER_DEPENDS += figures-5.pdf

figures-%.pdf: figures.pdf
	gs -sDEVICE=pdfwrite -dSAFER -o $@ -dFirstPage=$* -dLastPage=$* $<

$(DOCUMENT)_poster.pdf: $(POSTER_DEPENDS)


.PHONY: default clean clean-all
