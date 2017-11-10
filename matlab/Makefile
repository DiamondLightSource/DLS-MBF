TOP = ..
include $(TOP)/Makefile.common

MEX_FILES = lmbf_detector_mex lmbf_memory_mex


MEX_OPTS += -largeArrayDims
MEX_OPTS += COPTIMFLAGS='-O2 -DNDEBUG'

CFLAGS += -std=gnu99

CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -Werror

# Suppress a couple of annoying errors
CFLAGS += -Wno-missing-field-initializers
CFLAGS += -Wno-unused-parameter

%.mexa64: mex/%.c mex/socket.c
	$(MEX) $(MEX_OPTS) CFLAGS='$$CFLAGS $(CFLAGS)' $^

default: $(MEX_FILES:%=%.mexa64)

clean:
	rm -f *.mexa64

.PHONY: default clean
