# Make file for building CSS screens

MBF_TOP = ..

EDM_DIRS += $(MBF_TOP)/epics/opi
EDM_DIRS += $(MBF_TOP)/epics/opi/mbf
EDM_DIRS += $(MBF_TOP)/tune_fit/opi
EDM_DIRS += $(MBF_TOP)/tune_fit/opi/tune_fit

VPATH = $(EDM_DIRS)


EDM_FILES = $(wildcard $(EDM_DIRS:=/*.edl))
CSS_FILES = $(patsubst %,css/%,$(notdir $(EDM_FILES:.edl=.opi)))


default: $(CSS_FILES)
.PHONY: default

clean:
	rm -rf css
.PHONY: clean

$(CSS_FILES): css

css:
	mkdir -p $@
# 	# Install dummy project file to avoid strange CSS behaviour
# 	cp css.project $@/.project

css/%.opi: %.edl
	./edm-to-css $< $@
