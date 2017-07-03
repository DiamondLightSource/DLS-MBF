TOP = ..
include $(TOP)/configure/CONFIG

#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

include $(EPICS_DEVICE)/src/Makefile.extra


# # Pick up configuration symbols and pass them through to the IOC build
# include $(TOP)/install_d/CONFIG
LMBF_VERSION = testing testing
BUNCHES_PER_TURN = 936

USR_CFLAGS += -DLMBF_VERSION='"$(LMBF_VERSION)"'
USR_CFLAGS += -DBUNCHES_PER_TURN=$(BUNCHES_PER_TURN)

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
# lmbf_SRCS += config_file.c      # Parse configuration file

lmbf_SRCS += hardware.c         # Interface to FPGA

# LMBF components
lmbf_SRCS += system.c           # System level components
lmbf_SRCS += mms.c              # Min/max/sum common implementation
lmbf_SRCS += adc.c              # ADC interface and control
lmbf_SRCS += dac.c              # DAC interface and control
lmbf_SRCS += bunch_fir.c        # Bunch buunch FIR filter control
lmbf_SRCS += bunch_select.c     # Bunch selection control
# lmbf_SRCS += sequencer.c        # State sequencer control
# lmbf_SRCS += triggers.c         # Trigger control and selection
# lmbf_SRCS += detector.c         # I/Q detector
# lmbf_SRCS += tune.c             # Tune measurement and high level control
# lmbf_SRCS += tune_support.c     # Support library for tune measurement
# lmbf_SRCS += tune_peaks.c       # High level tune peak detection
# lmbf_SRCS += sensors.c          # Miscellaneous system health sensors
# lmbf_SRCS += tune_follow.c      # Support for tune following

lmbf_LIBS += epics_device
lmbf_LIBS += $(EPICS_BASE_IOC_LIBS)


hardware.o: register_defs.h


#===========================


PROD += test_defs

test_defs_SRCS += test_defs.c



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
