TOP = ..
include $(TOP)/configure/CONFIG

#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

include $(EPICS_DEVICE)/src/Makefile.extra

USR_CFLAGS += -Werror


# Compute the version information
include $(TOP)/../VERSION
LMBF_VERSION = \
    $(VERSION_EXTRA)$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
GIT_VERSION := $(shell git describe --abbrev=7 --dirty --always --tags)


USR_CFLAGS += -DLMBF_VERSION='"$(LMBF_VERSION)"'
USR_CFLAGS += -DGIT_VERSION='"$(GIT_VERSION)"'

# Compute a sensible format of build date
USR_CFLAGS += -DBUILD_DATE_TIME='"$(shell date '+%Y-%m-%d %H:%M')"'


ifdef DEBUG_TRACEBACK
# Allow panic_error() backtrace to show a backtrace with useful information.
USR_CFLAGS += -O0
USR_CFLAGS += -g
USR_LDFLAGS += -rdynamic
endif

STATIC_BUILD = YES


#=============================


USR_INCLUDES += -I$(LMBF_TOP)/driver


PROD_IOC = lmbf

DBD += lmbf.dbd
# lmbf.dbd will be made up from these files:
lmbf_DBD += base.dbd
lmbf_DBD += epics_device.dbd

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
lmbf_SRCS += lmbf_registerRecordDeviceDriver.c
lmbf_SRCS += main.c             # Entry point and initialisation

lmbf_SRCS += common.c           # Miscellaneous shared helper functions
lmbf_SRCS += parse.c            # Low level common parsing functions
lmbf_SRCS += config_file.c      # Parse configuration file
lmbf_SRCS += configs.c          # Load configurations
lmbf_SRCS += events.c           # Load configurations

lmbf_SRCS += hardware.c         # Interface to FPGA

# LMBF components
lmbf_SRCS += system.c           # System level components
lmbf_SRCS += mms.c              # Min/max/sum common implementation
lmbf_SRCS += adc.c              # ADC interface and control
lmbf_SRCS += dac.c              # DAC interface and control
lmbf_SRCS += bunch_fir.c        # Bunch buunch FIR filter control
lmbf_SRCS += bunch_select.c     # Bunch selection control
lmbf_SRCS += sequencer.c        # State sequencer control
lmbf_SRCS += memory.c           # Fast memory readout
lmbf_SRCS += trigger_target.c   # Trigger target specific control
lmbf_SRCS += triggers.c         # Trigger control and selection
lmbf_SRCS += detector.c         # I/Q detector

lmbf_SRCS += buffered_file.c    # Helper for buffered file access
lmbf_SRCS += socket_command.c   # Command implementation for high speed data
lmbf_SRCS += socket_server.c    # Socket connection for high speed data


lmbf_LIBS += epics_device
lmbf_LIBS += $(EPICS_BASE_IOC_LIBS)


hardware.o: register_defs.h


#===========================


PROD += test_defs

test_defs_SRCS += test_defs.c

test_defs.o: register_defs.h



#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

# Force lmbfMain to be rebuilt every time so that the build date and time is
# current.
main.o: EMPTY
EMPTY:

# Build register_defs.h
register_defs.h: ../make_c_defs $(LMBF_TOP)/AMC525/vhd/register_defs.in
	PYTHONPATH=$(LMBF_TOP)/python $(PYTHON) $< >$@

test_defs.c: ../make_c_defs_test $(LMBF_TOP)/AMC525/vhd/register_defs.in
	PYTHONPATH=$(LMBF_TOP)/python $(PYTHON) $< >$@
