# Simple soft IOC for testing *ONLY*!

from pkg_resources import require
require('cothread==2.13')
require('numpy==1.11.1')
require('epicsdbbuilder==1.1')

import sys, os

from softioc import softioc, builder
import cothread
import numpy

from lmbf.driver.driver import SYSTEM, CONTROL, DSP0, DSP1
from lmbf.driver import setup_lmbf

ADC_TAPS   = SYSTEM.INFO.ADC_TAPS
BUNCH_TAPS = SYSTEM.INFO.BUNCH_TAPS
DAC_TAPS   = SYSTEM.INFO.DAC_TAPS

BUNCH_COUNT = 936


builder.SetDeviceName('TS-DI-LMBF-02')
builder.stringIn('HOSTNAME', VAL = os.uname()[1])


class BunchFIR:
    def __init__(self, fir):
        self.fir = fir
        self.filter = builder.WaveformOut('FIR%d' % fir,
            numpy.zeros(BUNCH_TAPS), on_update = self.set_bunch_fir)

    def set_bunch_fir(self, value):
        value = numpy.clip(2**31 * value, -2**31, 2**31-1)
        value = numpy.require(value, dtype = numpy.int32)
        value = numpy.pad(value, (0, BUNCH_TAPS - len(value)), 'constant')

        DSP0.FIR.CONFIG.BANK = self.fir
        for v in value:
            DSP0.FIR.TAPS = v

    def startup(self):
        self.filter.set(1)


class Bank:
    def pv_name(self, suffix):
        return 'BANK%d:%s' % (self.bank, suffix)

    def waveform(self, name, dtype, value):
        return builder.WaveformOut(
            self.pv_name(name),
            value * numpy.ones(BUNCH_COUNT, dtype = dtype),
            on_update = self.on_update)

    def __init__(self, bank):
        self.bank = bank
        self.fir = self.waveform('FIR', numpy.uint8, 0)
        self.gain = self.waveform('GAIN', numpy.float, 1)
        self.enables = self.waveform('ENABLES', numpy.uint8, 7)

    def on_update(self, _):
        DSP0.BUNCH.CONFIG = self.bank
        fir = self.fir.get()
        gain = self.gain.get()
        enables = self.enables.get()
        for f, g, e in zip(fir, gain, enables):
            g = numpy.clip(2**12 * g, -2**12, 2**12-1)
            g = int(g)
            DSP0.BUNCH.BANK._write_fields_wo(
                FIR_SELECT = f, GAIN = g,
                FIR_ENABLE = e & 1,
                NCO0_ENABLE = (e >> 1) & 1,
                NCO1_ENABLE = (e >> 2) & 1)

    def startup(self):
        self.on_update(None)
        pass


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
        self.std.set(numpy.sqrt(var) * scaling)
        self.sum_ovfl.set(count.SUM_OVFL)
        self.sum2_ovfl.set(count.SUM2_OVFL)



mms_adc = MMS('ADC', DSP0.ADC.MMS)
mms_dac = MMS('DAC', DSP0.DAC.MMS)

firs = map(BunchFIR, range(4))
banks = map(Bank, range(4))


builder.LoadDatabase()
softioc.iocInit()

setup_lmbf.setup_lmbf(BUNCH_COUNT)
for fir in firs:
    fir.startup()
for bank in banks:
    bank.startup()

softioc.interactive_ioc(globals())
