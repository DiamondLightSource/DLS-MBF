# Miscellanous stuff.  This will probably be renamed to support in a bit.

import numpy


class Trace:
    def __init__(self, **kargs):
        self.__dict__.update(kargs)

    def _get(self, name):
        value = self
        for n in name.split('.'):
            value = getattr(value, n)
        return value

    def _print(self, indent = ''):
        for k, v in self.__dict__.items():
            if isinstance(v, Trace):
                print '%s%s:' % (indent, k)
                v._print(indent + '    ')
            else:
                print '%s%s: %s' % (indent, k, v)


class Config:
    MINIMUM_WIDTH = 1e-5
    MINIMUM_SPACING = 1
    MAXIMUM_ANGLE = 100
    MINIMUM_HEIGHT = 0.1

    SMOOTHING = 32

    def __init__(self, max_peaks):
        self.MAX_PEAKS = max_peaks


def abs2(z):
    return z.real ** 2 + z.imag ** 2
