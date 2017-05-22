# Simple soft IOC for testing *ONLY*!

from pkg_resources import require
require('cothread==2.13')
require('numpy==1.11.1')
require('epicsdbbuilder==1.1')

import sys, os

from softioc import softioc, builder
import cothread
import numpy

from driver import SYSTEM, CONTROL, DSP0, DSP1
import setup_lmbf

ADC_TAPS   = SYSTEM.INFO.ADC_TAPS
BUNCH_TAPS = SYSTEM.INFO.BUNCH_TAPS
DAC_TAPS   = SYSTEM.INFO.DAC_TAPS

BUNCH_COUNT = 936
BUNCH_COUNT = 468


builder.SetDeviceName('TS-DI-LMBF-02')
builder.stringIn('HOSTNAME', VAL = os.uname()[1])


def set_bunch_fir(value):
    value = numpy.clip(2**31 * value, -2**31, 2**31-1)
    print value
    value = numpy.require(value, dtype = numpy.int32)
    print value
    value = numpy.pad(value, (0, BUNCH_TAPS - len(value)), 'constant')
    print value

    DSP0.FIR.CONFIG.BANK = 0
    for v in value:
        DSP0.FIR.TAPS = v


class MMS:
    def pv_name(self, suffix):
        return '%s:MMS:%s' % (self.name, suffix)

    def waveform(self, name):
        return builder.Waveform(
            self.pv_name(name),
            length = BUNCH_COUNT, datatype = numpy.double)

    def overflow(self, name):
        return builder.boolIn(
            self.pv_name(name + '_OVFL'),
            'Ok', 'Overflow', OSV = 'MAJOR')

    def __init__(self, name, mms):
        self.name = name
        self.mms = mms

        self.turns = builder.longIn(self.pv_name('TURNS'))
        self.sum_ovfl = self.overflow('SUM')
        self.sum2_ovfl = self.overflow('SUM2')
        self.min = self.waveform('MIN')
        self.max = self.waveform('MAX')
        self.delta = self.waveform('DELTA')
        self.mean = self.waveform('MEAN')
        self.std = self.waveform('STD')
        builder.Action(
            self.pv_name('SCAN'), on_update = self.scan,
            SCAN = '.1 second')

    def scan(self, value):
        count = self.mms.COUNT._fields
        turns = count.TURNS + 1

        minv  = numpy.empty(BUNCH_COUNT, dtype = numpy.int16)
        maxv  = numpy.empty(BUNCH_COUNT, dtype = numpy.int16)
        sumv  = numpy.empty(BUNCH_COUNT, dtype = numpy.int32)
        sum2v = numpy.empty(BUNCH_COUNT, dtype = numpy.int64)

        for i in range(BUNCH_COUNT):
            min_max = self.mms.READOUT._value
            sum = self.mms.READOUT._value
            sum2_low = self.mms.READOUT._value
            sum2_high = self.mms.READOUT._value

            minv[i] = min_max
            maxv[i] = min_max >> 16
            sumv[i] = sum
            sum2v[i] = sum2_low + (sum2_high << 32)

        scaling = 2.**-15
        self.turns.set(turns)
        self.min.set(minv * scaling)
        self.max.set(maxv * scaling)
        self.delta.set((numpy.double(maxv) - minv) * scaling)

        mean = numpy.double(sumv) / turns
        self.mean.set(mean * scaling)
        var = numpy.double(sum2v) / turns - mean * mean
        self.std.set(var * scaling)
        self.sum_ovfl.set(count.SUM_OVFL)
        self.sum2_ovfl.set(count.SUM2_OVFL)


builder.WaveformOut('FIR0', numpy.zeros(BUNCH_TAPS),
    on_update = set_bunch_fir)

mms_adc = MMS('ADC', DSP0.ADC.MMS)
mms_dac = MMS('DAC', DSP0.DAC.MMS)


builder.LoadDatabase()
softioc.iocInit()

setup_lmbf.setup_lmbf(BUNCH_COUNT)

softioc.interactive_ioc(globals())
