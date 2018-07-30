include $(MBF_TOP)/Makefile.common

TOP = ..
include $(TOP)/configure/CONFIG

#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

include $(EPICS_DEVICE)/src/Makefile.extra

# Pick up extra C flags from the top level config file
USR_CFLAGS += $(CFLAGS_EXTRA)

# Our processor has AVX support.
USR_CFLAGS += -mavx


# Compute the version information
include $(TOP)/../VERSION
MBF_VERSION = \
    $(VERSION_EXTRA)$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
GIT_VERSION := $(shell git describe --abbrev=7 --dirty --always --tags)


USR_CFLAGS += -DMBF_VERSION='"$(MBF_VERSION)"'
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


USR_INCLUDES += -I$(MBF_TOP)/driver


PROD_IOC = mbf

DBD += mbf.dbd
# mbf.dbd will be made up from these files:
mbf_DBD += base.dbd
mbf_DBD += epics_device.dbd

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
mbf_SRCS += mbf_registerRecordDeviceDriver.c
mbf_SRCS += main.c              # Entry point and initialisation

mbf_SRCS += common.c            # Miscellaneous shared helper functions
mbf_SRCS += parse.c             # Low level common parsing functions
mbf_SRCS += config_file.c       # Parse configuration file
mbf_SRCS += configs.c           # Load configurations
mbf_SRCS += events.c            # Load configurations

mbf_SRCS += hardware.c          # Interface to FPGA

# MBF components
mbf_SRCS += system.c            # System level components
mbf_SRCS += mms.c               # Min/max/sum common implementation
mbf_SRCS += adc.c               # ADC interface and control
mbf_SRCS += dac.c               # DAC interface and control
mbf_SRCS += bunch_fir.c         # Bunch buunch FIR filter control
mbf_SRCS += bunch_select.c      # Bunch selection control
mbf_SRCS += sequencer.c         # State sequencer control
mbf_SRCS += memory.c            # Fast memory readout
mbf_SRCS += trigger_target.c    # Trigger target specific control
mbf_SRCS += triggers.c          # Trigger control and selection
mbf_SRCS += detector.c          # I/Q detector
mbf_SRCS += delay.c             # Fine control over clocking delays

mbf_SRCS += buffered_file.c     # Helper for buffered file access
mbf_SRCS += socket_command.c    # Command implementation for high speed data
mbf_SRCS += socket_server.c     # Socket connection for high speed data


mbf_LIBS += epics_device
mbf_LIBS += $(EPICS_BASE_IOC_LIBS)


hardware.o: register_defs.h


#===========================


PROD += test_defs

test_defs_SRCS += test_defs.c

test_defs.o: register_defs.h



#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

# Force main to be rebuilt every time so that the build date and time is
# current.
main.o: EMPTY
EMPTY:

# Build register_defs.h
register_defs.h: ../make_c_defs $(MBF_TOP)/AMC525/vhd/register_defs.in
	PYTHONPATH=$(MBF_TOP)/python $(PYTHON) $< >$@

test_defs.c: ../make_c_defs_test $(MBF_TOP)/AMC525/vhd/register_defs.in
	PYTHONPATH=$(MBF_TOP)/python $(PYTHON) $< >$@


check_vars:
	../check_global_vars ../global_vars .
.PHONY: check_vars

build: check_vars
