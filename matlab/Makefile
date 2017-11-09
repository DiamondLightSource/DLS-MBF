TOP = ..
include $(TOP)/Makefile.common
# MEX = /dls_sw/prod/tools/RHEL6-x86_64/matlab/R2014a/prefix/bin/mex

MEX_OPTS += -largeArrayDims
MEX_OPTS += COPTIMFLAGS='-O2 -DNDEBUG'

CFLAGS += -std=gnu99

CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -Werror

# Suppress a couple of annoying errors
CFLAGS += -Wno-missing-field-initializers
CFLAGS += -Wno-unused-parameter

%.mexa64: %.c
	$(MEX) $(MEX_OPTS) CFLAGS='$$CFLAGS $(CFLAGS)' $<

default: lmbf_memory_mex.mexa64

clean:
	rm -f *.mexa64
