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

css/%.opi: %.edl
	mkdir -p css
	./edm-to-css $< $@
