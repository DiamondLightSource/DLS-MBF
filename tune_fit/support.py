# Miscellanous stuff.  This will probably be renamed to support in a bit.

import numpy


class Struct:
    def __init__(self, **kargs):
        self._extend(**kargs)

    def _extend(self, **kargs):
        self.__dict__.update(kargs)


def abs2(z):
    return z.real ** 2 + z.imag ** 2
