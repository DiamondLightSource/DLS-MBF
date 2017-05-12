# This Makefile is invoked by makefile after setting the working directory
ifndef TOP
$(error Do not call this make file directly)
endif

include $(TOP)/Makefile.common

SRCDIR = $(TOP)/tools

VPATH = $(SRCDIR)


TOOLS = testmem read_debug


# (not) git version
BUILD_DATE_TIME = $(shell date +'%Y-%m-%d %H:%M:%S')


tools: $(TOOLS)
.PHONY: tools


CFLAGS += -std=gnu99
CFLAGS += -O3
CFLAGS += -g
CPPFLAGS += -D_GNU_SOURCE

CFLAGS += -Werror
CFLAGS += -Wall
CFLAGS += -Wextra

CFLAGS += -Wundef
CFLAGS += -Wshadow
CFLAGS += -Wcast-align
CFLAGS += -Wwrite-strings
CFLAGS += -Wredundant-decls
CFLAGS += -Wmissing-prototypes
CFLAGS += -Wmissing-declarations
CFLAGS += -Wstrict-prototypes
CFLAGS += -Wcast-qual
CFLAGS += -Woverflow
CFLAGS += -Wconversion

CFLAGS += -fstrict-overflow
CFLAGS += -Wsign-compare

CFLAGS += -Wstrict-overflow=5

CFLAGS += -Wno-switch-enum
CFLAGS += -Wno-variadic-macros
CFLAGS += -Wno-padded
CFLAGS += -Wno-format-nonliteral
CFLAGS += -Wno-vla
CFLAGS += -Wno-c++-compat
CFLAGS += -Wno-pointer-arith
CFLAGS += -Wno-unused-parameter
CFLAGS += -Wno-missing-field-initializers


# Pick up kernel driver header file
CPPFLAGS += -I$(TOP)/driver

LDLIBS += -lpthread
LDLIBS += -lrt
LDLIBS += -lm


# Allow access to function names in assert fail tracebacks
LDFLAGS += -rdynamic

# Debug override option
ifdef DEBUG
CFLAGS += -O0
endif


testmem_SRCS += error.c
testmem_SRCS += testmem.c

read_debug_SRCS += error.c
read_debug_SRCS += read_debug.c



testmem: $(testmem_SRCS:.c=.o)
read_debug: $(read_debug_SRCS:.c=.o)


%.d: %.c
	set -o pipefail && $(CC) -M $(CPPFLAGS) $(CFLAGS) $< | \
            sed '1s/:/ $@:/' >$@
include $(SRCS:.c=.d)

# Target for assembler build for code generation inspection.
%.s: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -S $<
