#!/bin/env python

import sys
import traceback
import numpy


class Config:
    sel = 0
    fit_threshold = 0.2
    max_error = 0.6
    max_error = 10
    min_width = 1e-6
    max_width = 5e-3


class Result:
    def __init__(self, N):
        self.__N = N
        self.__ix = 0
        self._groups = []
        self._arrays = None

    def __getattr__(self, name):
        if name.startswith('__'):
            raise AttributeError(
                '\'Result\' object has no attribute \'%s\'' % name)

        self._groups.append(name)
        result = Result(self.__N)
        setattr(self, name, result)
        return result

    def set_timestamp(self, t):
        pass

    def create_arrays(self, kargs):
        for key, value in kargs.items():
            a = numpy.empty((self.__N,) + value.shape)
            a[:] = numpy.nan
            setattr(self, key, a)
        self._arrays = kargs.keys()

    def output(self, **kargs):
        if self._arrays is None:
            self.create_arrays(kargs)
        for key, value in kargs.items():
            getattr(self, key)[self.__ix] = value
        self.__ix += 1

    def print_summary(self, indent = ''):
        for k in self._arrays:
            a = getattr(self, k)
            print '%s%s: %s %s' % (indent, k, a.shape, a.dtype)
        for k in self._groups:
            print '%s%s:' % (indent, k)
            getattr(self, k).print_summary(indent + '    ')

    config = Config


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


def replay_file(filename, fit_tune, max_n = 0, subset = []):
    print 'replay_file', filename, max_n, subset
    s_iq = load_replay(filename, max_n)

    if subset:
        s_iq = [s_iq[ix] for ix in subset]

    N = len(s_iq)
    print 'Replaying', N, 'trials'

    result = Result(N)
    for n, (s, iq) in enumerate(s_iq):
        try:
            fit_tune(result, 0, s, iq)
        except:
            print >>sys.stderr, 'Fit', n, 'failed'
            traceback.print_exc()

    return result


def replay_s_iq(s_iq, fit_tune):
    for s, iq in s_iq:
        try:
            fit_tune(s, iq)
        except:
            print >>sys.stderr, 'Fit failed'
            traceback.print_exc()
