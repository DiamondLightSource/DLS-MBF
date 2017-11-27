# LMBF configuration functions

import numpy
import time

import cothread
from cothread.catools import *


class PV:
    def __init__(self, name):
        self.monitor = camonitor(name, self.__on_update, format = FORMAT_TIME)
        self.event = cothread.Event()
        self.value = None

        # Always wait for and discard value on connection.
        self.get()

    def close(self):
        self.monitor.close()

    def __on_update(self, value):
        assert value.ok, 'Error connecting to %s' % value.name
        self.value = value
        self.event.Signal(value)

    # Waits for a reasonably fresh value to arrive.  No guarantees, but it will
    # be fresher than the last value!
    def get(self):
        return self.event.Wait(1)

    # Waits for a value at least as old as the given age to arrive.
    def get_new(self, age = 0, now = None):
        if now is None:
            now = time.time()
        now = now + age
        while True:
            value = self.get()
            if value.timestamp >= now:
                return value


class PV_set(object):
    def __init__(self, lmbf):
        self.__lmbf = lmbf
        self.__pv_set = {}

    def __del__(self):
        for pv in self.__pv_set.values():
            pv.close()

    def __setattr__(self, name, value):
        # Hack to bypass setting of local names
        if name[:7] == '_PV_set':
            self.__dict__[name] = value
        else:
            self.__pv_set[name] = self.__lmbf.PV(value)

    def __getattr__(self, name):
        return self.__pv_set[name].get()


class LMBF:
    CHANNELS = range(2)

    def __init__(self, name):
        self.lmbf = name

        self.adc_taps = self.get_shared('ADC_TAPS')
        self.dac_taps = self.get_shared('DAC_TAPS')
        self.bunch_taps = self.get_shared('BUNCH_TAPS')

        self.axes = [self.get_shared('AXIS%d' % a) for a in self.CHANNELS]
        self.bunches = self.get_shared('BUNCHES')

    def pv(self, name, axis = 0):
        if axis is None:
            return '%s:%s' % (self.lmbf, name)
        else:
            return '%s:%s:%s' % (self.lmbf, self.axes[axis], name)

    def PV(self, name, axis = 0):
        return PV(self.pv(name, axis))


    def get(self, name, axis = 0):
        return caget(self.pv(name, axis), format = FORMAT_TIME, timeout = 1)

    def get_shared(self, name):
        return self.get(name, None)

    def get_channels(self, name):
        return [self.get(name, c) for c in self.CHANNELS]

    def set(self, name, value, axis = 0):
        return caput(self.pv(name, axis), value, timeout = 1)

    def set_shared(self, name, value):
        return self.set(name, value, None)

    def set_channels(self, name, value):
        return [self.set(name, value, c) for c in self.CHANNELS]


    # Adds given function as an LMBF method
    @classmethod
    def method(cls, method):
        setattr(cls, method.__name__, method)
        return method


# Wraps access to DRAM buffer
class DRAM:
    def __init__(self, lmbf):
        self.lmbf = lmbf
        self.wf0 = lmbf.PV('MEM:WF0', None)
        self.wf1 = lmbf.PV('MEM:WF1', None)

    def get(self, sources, length = None):
        self.lmbf.set_shared('MEM:SELECT_S', sources)
        self.lmbf.set_shared('MEM:CAPTURE_S.PROC', 0)
        if length is None:
            length = self.lmbf.bunches
        a = self.wf0.get()[:length]
        b = self.wf1.get()[:length]
        return a, b

    def get_peaks(self, sources):
        a, b = self.get(sources)
        return self.lmbf.find_one_peak(a), self.lmbf.find_one_peak(b)

    def __del__(self):
        self.wf0.close()
        self.wf1.close()


# ------------------------------------------------------------------------------
# Trigger setup

trigger_inputs = ['SOFT', 'EXT', 'PM', 'ADC0', 'ADC1', 'SEQ0', 'SEQ1']

@LMBF.method
def set_trigger_inputs(lmbf, target, axis, *sources):
    def pv(input, group):
        return 'TRG:%s:%s:%s_S' % (target, input, group)

    for input in trigger_inputs:
        lmbf.set(pv(input, 'EN'),
            'Enable' if input in sources else 'Ignore', axis)
        lmbf.set(pv(input, 'BL'), 'All', axis)


# ------------------------------------------------------------------------------
# Bunch Bank setup

# Configure selected bank for waveform control with given gain, fir and output
# waveform or constant values.
@LMBF.method
def bank_wf(lmbf, bank, gain, fir, output):
    # A bunch configuration can be either a single value or else an array of the
    # correct length.
    def bunches(value):
        value = numpy.array(value)
        if value.size == 1:
            value = numpy.repeat(value, lmbf.bunches)
        assert value.size == lmbf.bunches, 'Invalid array length'
        return value

    lmbf.set('BUN:%d:GAINWF_S' % bank, bunches(gain))
    lmbf.set('BUN:%d:FIRWF_S' % bank, bunches(fir))
    lmbf.set('BUN:%d:OUTWF_S' % bank, bunches(output))



# ------------------------------------------------------------------------------
# Sequencer setup

# Configures bunch bank for quiescent sequencer state
@LMBF.method
def state0(lmbf, bank = 0):
    lmbf.set('SEQ:0:BANK_S', bank)

# Programs a single sequencer state
@LMBF.method
def state(lmbf, state = 1,
        start = 0, step = 0, dwell = 20, gain = '0dB', enable = True,
        count = 4096, bank = 1, window = True, holdoff = 0, capture = True):
    lmbf.set('SEQ:%d:START_FREQ_S' % state, start)
    lmbf.set('SEQ:%d:STEP_FREQ_S' % state, step)
    lmbf.set('SEQ:%d:DWELL_S' % state, dwell)
    lmbf.set('SEQ:%d:COUNT_S' % state, count)
    lmbf.set('SEQ:%d:BANK_S' % state, bank)
    lmbf.set('SEQ:%d:GAIN_S' % state, gain)
    lmbf.set('SEQ:%d:ENABLE_S' % state, enable)
    lmbf.set('SEQ:%d:ENWIN_S' % state, window)
    lmbf.set('SEQ:%d:HOLDOFF_S' % state, holdoff)
    lmbf.set('SEQ:%d:CAPTURE_S' % state, capture)
    lmbf.set('SEQ:%d:BLANK_S' % state, 'Off')
