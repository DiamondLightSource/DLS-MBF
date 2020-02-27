# MBF configuration functions

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
        return self.event.Wait(2)

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
    def __init__(self, mbf):
        self.__mbf = mbf
        self.__pv_set = {}

    def __del__(self):
        for pv in self.__pv_set.values():
            pv.close()

    def __setattr__(self, name, value):
        # Hack to bypass setting of local names
        if name[:7] == '_PV_set':
            self.__dict__[name] = value
        else:
            self.__pv_set[name] = self.__mbf.PV(value)

    def __getattr__(self, name):
        return self.__pv_set[name].get()


class MBF:
    CHANNELS = range(2)

    def __init__(self, name):
        self.mbf = name

        self.adc_taps = self.get_shared('INFO:ADC_TAPS')
        self.dac_taps = self.get_shared('INFO:DAC_TAPS')
        self.bunch_taps = self.get_shared('INFO:BUNCH_TAPS')

        self.axes = [self.get_shared('INFO:AXIS%d' % a) for a in self.CHANNELS]
        self.bunches = self.get_shared('INFO:BUNCHES')

    def pv(self, name, axis = 0):
        if axis is None:
            return '%s:%s' % (self.mbf, name)
        else:
            return '%s:%s:%s' % (self.mbf, self.axes[axis], name)

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


    # Adds given function as an MBF method
    @classmethod
    def method(cls, method):
        setattr(cls, method.__name__, method)
        return method


# Wraps access to DRAM buffer
class DRAM:
    def __init__(self, mbf):
        self.mbf = mbf
        self.wf0 = mbf.PV('MEM:WF0', None)
        self.wf1 = mbf.PV('MEM:WF1', None)

    def get(self, sources, length = None):
        self.mbf.set_shared('MEM:SELECT_S', sources)
        self.mbf.set_shared('MEM:CAPTURE_S.PROC', 0)
        if length is None:
            length = self.mbf.bunches
        a = self.wf0.get()[:length]
        b = self.wf1.get()[:length]
        return a, b

    def get_peaks(self, sources, nco_freq = 0):
        if nco_freq:
            self.mbf.set('NCO1:FREQ_S', nco_freq)
        a, b = self.get(sources)
        peaks = self.mbf.find_one_peak(a), self.mbf.find_one_peak(b)
        if nco_freq:
            self.mbf.set('NCO1:FREQ_S', 0)
        return peaks

    def __del__(self):
        self.wf0.close()
        self.wf1.close()


# ------------------------------------------------------------------------------
# Trigger setup

trigger_inputs = ['SOFT', 'EXT', 'PM', 'ADC0', 'ADC1', 'SEQ0', 'SEQ1']

@MBF.method
def set_trigger_inputs(mbf, target, axis, *sources):
    def pv(input, group):
        return 'TRG:%s:%s:%s_S' % (target, input, group)

    for input in trigger_inputs:
        mbf.set(pv(input, 'EN'),
            'Enable' if input in sources else 'Ignore', axis)
        mbf.set(pv(input, 'BL'), 'All', axis)


# ------------------------------------------------------------------------------
# Bunch Bank setup

sources = ['FIR', 'NCO1', 'NCO2', 'SEQ', 'PLL']

# Configure selected bank for waveform control with given gain, fir and output
# waveform or constant values.
@MBF.method
def bank_wf(mbf, bank, gain, fir, output):
    # A bunch configuration can be either a single value or else an array of the
    # correct length.
    def bunches(value):
        value = numpy.array(value)
        if value.size == 1:
            value = numpy.repeat(value, mbf.bunches)
        assert value.size == mbf.bunches, 'Invalid array length'
        return value

    for source in sources:
        mbf.set('BUN:%d:%s:GAIN_S' % (bank, source), bunches(gain))
    mbf.set('BUN:%d:FIRWF_S' % bank, bunches(fir))
    mbf.set('BUN:%d:OUTWF_S' % bank, bunches(output))



# ------------------------------------------------------------------------------
# Sequencer setup

# Configures bunch bank for quiescent sequencer state
@MBF.method
def state0(mbf, bank = 0):
    mbf.set('SEQ:0:BANK_S', bank)

# Programs a single sequencer state
@MBF.method
def state(mbf, state = 1,
        start = 0, step = 0, dwell = 20, gain = '0dB', enable = True,
        count = 4096, bank = 1, window = True, holdoff = 0, capture = True):
    mbf.set('SEQ:%d:START_FREQ_S' % state, start)
    mbf.set('SEQ:%d:STEP_FREQ_S' % state, step)
    mbf.set('SEQ:%d:DWELL_S' % state, dwell)
    mbf.set('SEQ:%d:COUNT_S' % state, count)
    mbf.set('SEQ:%d:BANK_S' % state, bank)
    mbf.set('SEQ:%d:GAIN_S' % state, gain)
    mbf.set('SEQ:%d:ENABLE_S' % state, enable)
    mbf.set('SEQ:%d:ENWIN_S' % state, window)
    mbf.set('SEQ:%d:HOLDOFF_S' % state, holdoff)
    mbf.set('SEQ:%d:CAPTURE_S' % state, capture)
    mbf.set('SEQ:%d:BLANK_S' % state, 'Off')
