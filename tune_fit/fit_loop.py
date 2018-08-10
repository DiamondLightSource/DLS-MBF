# Top level fitter loop for IOC

import traceback
import numpy

import cothread
from cothread.catools import *

import tune_fit
import pvs


LENGTH = 4096


# It normally doesn't help when we're warned about NaN and the like, we'll check
# for them at the appropriate points in the code.
numpy.seterr(all = 'ignore')


class Gather:
    def __init__(self, updates, pv_i, pv_q, pv_s):
        self.event = cothread.Event()
        self.timestamps = {}
        self.values = {}

        self.updates = updates
        self.monitor('I', pv_i)
        self.monitor('Q', pv_q)
        self.monitor('S', pv_s)

    def monitor(self, key, pv):
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

    def emit(self, timestamp, values):
        iq = numpy.complex128(values['I'] + 1j * values['Q'])
        s = numpy.float64(values['S'])
        if len(iq) > 0:
            self.event.Signal((timestamp, s, iq))

    def wait(self):
        return self.event.Wait()


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


class TuneFitLoop:
    def __init__(self, persist, config, source):
        pv_i    = config[source + '_i']
        pv_q    = config[source + '_q']
        pv_s    = config[source + '_s']
        target  = config[source + '_t']
        updates = config[source + '_u']
        tune_aliases = config.get(source + '_a', '')

        self.gather = Gather(updates.split(), pv_i, pv_q, pv_s)
        self.pvs = pvs.publish_pvs(
            persist, target, tune_aliases.split(), LENGTH)

    def fit_one_sweep(self):
        timestamp, s, iq = self.gather.wait()
        config = self.pvs.get_config()
        trace = tune_fit.fit_tune(config, s, iq)
        self.pvs.update(timestamp, trace)

    def fit_thread(self):
        while True:
            try:
                self.fit_one_sweep()
            except:
                print 'Fitter raised exception'
                traceback.print_exc()

    def start(self):
        cothread.Spawn(self.fit_thread)
