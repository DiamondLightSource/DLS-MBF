MBF_TOP = ..
include $(MBF_TOP)/Makefile.common

MEX_FILES = mex_mbf_detector_ mex_mbf_memory_


MEX_OPTS += -largeArrayDims
MEX_OPTS += COPTIMFLAGS='-O2 -DNDEBUG'

CFLAGS += -std=gnu99

CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -Werror

CFLAGS += -Wconversion
CFLAGS += -Wsign-compare
CFLAGS += -Wstrict-prototypes

# Suppress a couple of annoying errors
CFLAGS += -Wno-missing-field-initializers
CFLAGS += -Wno-unused-parameter

%.mexa64: mex/%.c mex/socket.c
	$(MEX) $(MEX_OPTS) CFLAGS='$$CFLAGS $(CFLAGS)' LDFLAGS=-lut $^

default: $(MEX_FILES:%=%.mexa64)

clean:
	rm -f *.mexa64

.PHONY: default clean
