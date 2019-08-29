#!/bin/env python

import sys
import traceback
import numpy


# Converts a line numbers into a numpy array.
def fromstring(line):
    if line == '\n':
        # Alas, there is a nasty bug in fromstring if the string is empty: we
        # get [-1] returned instead!
        return numpy.empty(0)
    else:
        # This is a bit faster than map(double, line.split()); pity about the
        # empty string bug!
        return numpy.fromstring(line, sep = ' ')


def load_replay(filename, max_n = 0, conj = False):
    s_valid = False
    ts_i = ''
    ts_q = ''

    N = 0
    result = []

    replay = file(filename)
    for line in replay:
        pv, day, time, count, rest = line.split(' ', 4)
        value = fromstring(rest)

        if pv.endswith(':I'):
            value_i = value
            ts_i = time
        elif pv.endswith(':Q'):
            value_q = value
            ts_q = time
        else:
            value_s = value
            if not s_valid:
                s_valid = True

        if ts_i == ts_q == time and s_valid:
            iq = value_i + 1j * value_q
            if conj:
                iq = numpy.conj(iq)
            result.append((value_s, iq))
            N += 1

            if max_n and N >= max_n:
                break

    return result


def load_replay_mat(filename, max_n = 0, conj = False):
    from scipy.io import loadmat
    replay = loadmat(filename, squeeze_me = True)
    s = replay['s']
    iq = replay['iq']
    if conj:
        iq = numpy.conj(iq)
    # Try and figure out which way round iq is.  We want iq.shape[1]==len(s),
    # and we need a two dimensional array (to treat as a list of values).
    if len(iq.shape) == 1:
        iq = iq.reshape(1, -1)
    elif iq.shape[0] == len(s):
        # Probably wrong way round
        iq = iq.T
    if max_n > 0:
        iq = iq[:max_n]
    # Return values as a list
    return [(s, r_iq) for r_iq in iq]


def replay_s_iq(s_iq, fit_tune, keep_traces):
    traces = []
    for s, iq in s_iq:
        try:
            trace = fit_tune(s, iq)
            if keep_traces:
                traces.append(trace)
        except KeyboardInterrupt:
            raise
        except:
            print >>sys.stderr, 'Fit failed'
            traceback.print_exc()
    return traces
