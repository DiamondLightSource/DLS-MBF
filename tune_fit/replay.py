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


def load_replay(filename, max_n = 0):
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
            result.append((value_s, value_i + 1j * value_q))
            N += 1

            if max_n and N >= max_n:
                break

    return result


def load_replay_mat(filename, max_n = 0):
    from scipy.io import loadmat
    replay = loadmat(filename, squeeze_me = True)
    iq = replay['iq'].T
    s = replay['s']
    if max_n > 0:
        iq = iq[:max_n]
    # Return values as a list
    return [(s, r_iq) for r_iq in iq]


def replay_s_iq(s_iq, fit_tune):
    for s, iq in s_iq:
        try:
            fit_tune(s, iq)
        except KeyboardInterrupt:
            raise
        except:
            print >>sys.stderr, 'Fit failed'
            traceback.print_exc()
