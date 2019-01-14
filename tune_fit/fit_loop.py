# Top level fitter loop for IOC

import traceback
import numpy

import cothread
from cothread.catools import *

import tune_fit
import pvs
import support


LENGTH = 4096


# It normally doesn't help when we're warned about NaN and the like, we'll check
# for them at the appropriate points in the code.
numpy.seterr(all = 'ignore')


class Gather:
    # At present we expect all three waveforms to always update before we send a
    # gathered updated on for processing.
    updates = ['I', 'Q', 'S']

    def __init__(self, pv_i, pv_q, pv_s):
        self.event = cothread.Event()
        self.monitor('I', pv_i)
        self.monitor('Q', pv_q)
        self.monitor('S', pv_s)

    def monitor(self, key, pv):
        camonitor(pv, lambda v: self.update(key, v), format = FORMAT_TIME)

    def update(self, key, value):
        setattr(self, key, value)

        try:
            timestamp = self.I.timestamp
            do_emit = \
                self.Q.timestamp == timestamp and timestamp >= self.S.timestamp
        except AttributeError:
            # Until we've seen all values we'll get an attribute error
            pass
        else:
            if do_emit:
                iq = numpy.complex128(self.I + 1j * self.Q)
                if len(iq) > 0:
                    self.event.Signal((timestamp, self.S, iq))

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
        tune_aliases = config.get(source + '_a', '')

        self.gather = Gather(pv_i, pv_q, pv_s)
        self.pvs = pvs.publish_pvs(persist, target, LENGTH)
        self.mux = pvs.TuneMux(target, tune_aliases.split())

    def fit_one_sweep(self):
        timestamp, s, iq = self.gather.wait()
        config = self.pvs.get_config()
        try:
            trace = tune_fit.fit_tune(config, s, iq)
        except:
            trace = support.Trace(last_error = 'Fitter raised exception')
            print 'Fitter exception'
            traceback.print_exc(1)
        self.pvs.update(timestamp, trace)
        self.mux.update(timestamp, trace)

    def fit_thread(self):
        while True:
            try:
                self.fit_one_sweep()
            except:
                # If we have an exception here we've got a bit of a problem, but
                # let's not actually die right now.
                print 'Fitter raised unexpected exception'
                traceback.print_exc()

    def start(self):
        cothread.Spawn(self.fit_thread)
