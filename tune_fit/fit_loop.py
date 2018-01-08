# Top level fitter loop for IOC

import traceback
import numpy

import cothread
from cothread.catools import *

import tune_fit
import pvs


LENGTH = 4096
MAX_PEAKS = 5


class Gather:
    def __init__(self, updates):
        self.updates = updates
        self.timestamps = {}
        self.values = {}

    def monitor(self, emit, key, pv):
        self.emit = emit
        self.timestamps[key] = 0
        self.values[key] = 0
        camonitor(pv, lambda v: self.update(key, v), format = FORMAT_TIME)

    def update(self, key, value):
        timestamp = value.timestamp
        self.timestamps[key] = timestamp
        self.values[key] = +value
        if any(t == 0 for t in self.timestamps.values()):
            return
        if all(self.timestamps[u] == timestamp for u in self.updates):
            self.emit(timestamp, self.values)


class TuneFitLoop:
    def __init__(self, config, source):
        self.event = cothread.Event()

        pv_i    = config[source + '_i']
        pv_q    = config[source + '_q']
        pv_s    = config[source + '_s']
        target  = config[source + '_t']
        updates = config[source + '_u']

        gather = Gather(updates.split())
        gather.monitor(self.update, 'I', pv_i)
        gather.monitor(self.update, 'Q', pv_q)
        gather.monitor(self.update, 'S', pv_s)

        self.pvs = pvs.publish_pvs(target, LENGTH, MAX_PEAKS)

    def update(self, timestamp, values):
        iq = numpy.complex128(values['I'] + 1j * values['Q'])
        s = numpy.float64(values['S'])
        self.event.Signal((timestamp, s, iq))

    def fit_one_sweep(self):
        config = self.pvs.config
        t, s, iq = self.event.Wait()
        trace = tune_fit.fit_tune(config, s, iq)
        tune_fit.update_pvs(config, trace, self.pvs)

    def fit_thread(self):
        while True:
            try:
                self.fit_one_sweep()
            except:
                print 'Fitter raised exception'
                traceback.print_exc()

    def start(self):
        print 'started'
        cothread.Spawn(self.fit_thread)
