# Miscellanous stuff.  This will probably be renamed to support in a bit.

import numpy


class Trace:
    def __init__(self, **kargs):
        self.__dict__.update(kargs)

    def _print(self, indent = ''):
        for k, v in self.__dict__.items():
            if isinstance(v, Trace):
                print '%s%s:' % (indent, k)
                v._print(indent + '    ')
            else:
                print '%s%s: %s' % (indent, k, v)


def abs2(z):
    return z.real ** 2 + z.imag ** 2
