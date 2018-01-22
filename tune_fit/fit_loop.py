# Top level fitter loop for IOC

import traceback
import numpy

import cothread
from cothread.catools import *

import tune_fit
import pvs


LENGTH = 4096


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


def get_mux_config(config, prefix):
    # The multiplexor config is recorded as a sequence of keys of the form
    # 'prefix %d'.
    result = []
    for n in range(16):
        key = '%s %d' % (prefix, n)
        if key in config:
            result.append(config[key].rsplit(None, 2))
        else:
            break
    if result:
        return zip(*result)
    else:
        return ((), (), ())


# Manages list of possible sources for the tune and phase measurement and
# updates the associated final tune and phase PVs accordingly.  Interacts with
# pvs.publish_mux as follows:
#   .mux_options
#       Initialised here as a list of available source names and indices
#   .update_selection
#       Called by the generated selection PV when the chosen selection changes
#   .tune_pv, .phase_pv
#       PVs created by publish_mux to receive the current selected values.
class PvMux:
    def __init__(self, config, source):
        options, tune_pvs, phase_pvs = get_mux_config(config, source + '_m')
        self.mux_options = [
            (name, n) for n, name in enumerate(('Peak Fit',) + options)]
        self.selection = 0
        self.values = numpy.zeros((len(self.mux_options), 2))

        camonitor(tune_pvs, self.__update_tune_pv)
        camonitor(phase_pvs, self.__update_phase_pv)


    def update_selection(self, value):
        if value != self.selection:
            self.selection = value
            self.__update_pvs()

    def update_tune(self, tune):
        self.values[0] = (tune.tune, tune.phase)
        if self.selection == 0:
            self.__update_pvs()

    def __update_tune_pv(self, tune, index):
        index += 1
        self.values[index, 0] = tune
        if self.selection == index:
            self.tune_pv.set(tune)

    def __update_phase_pv(self, phase, index):
        index += 1
        self.values[index, 1] = phase
        if self.selection == index:
            self.phase_pv.set(phase)

    def __update_pvs(self):
        tune, phase = self.values[self.selection]
        self.tune_pv.set(tune)
        self.phase_pv.set(phase)


class TuneFitLoop:
    def __init__(self, persist, config, source):
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

        self.mux = PvMux(config, source)
        self.pvs = pvs.publish_pvs(persist, target, self.mux, LENGTH)

    def update(self, timestamp, values):
        iq = numpy.complex128(values['I'] + 1j * values['Q'])
        s = numpy.float64(values['S'])
        self.event.Signal((timestamp, s, iq))

    def fit_one_sweep(self):
        t, s, iq = self.event.Wait()
        config = self.pvs.get_config()
        trace = tune_fit.fit_tune(config, s, iq)
        self.pvs.update(t, trace)
        self.mux.update_tune(trace.tune.tune)

    def fit_thread(self):
        while True:
            try:
                self.fit_one_sweep()
            except:
                print 'Fitter raised exception'
                traceback.print_exc()

    def start(self):
        cothread.Spawn(self.fit_thread)
