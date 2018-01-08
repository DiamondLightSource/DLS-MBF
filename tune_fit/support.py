# Miscellanous stuff.  This will probably be renamed to support in a bit.

import numpy


class Struct:
    def __init__(self, **kargs):
        self.__dict__.update(kargs)


def abs2(z):
    return z.real ** 2 + z.imag ** 2


# Computes model for a single fit
def eval_one_peak(fit, s):
    a, b = fit
    return a / (s - b)


# Evaluates model from a list of fits
def eval_model(scale, fits, offset = 0):
    result = numpy.zeros(scale.shape, dtype = numpy.complex)
    for fit in fits:
        result += eval_one_peak(fit, scale)
    return result + offset


