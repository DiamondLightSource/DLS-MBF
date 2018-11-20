# Miscellanous stuff.  This will probably be renamed to support in a bit.

import re
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


# Reads lines from given file but joins lines ending with \
def read_joined_lines(filename):
    last_line = None
    for line in open(filename):
        # Check for matching continuation pattern, if found delete from line
        continuation = re.match(r'(.*)\\ *\n$', line)
        if continuation:
            line = continuation.groups()[0]

        # If the last line was a continuation then add it to our line
        if last_line:
            line = last_line + line

        # Save line or set aside as continuation
        if continuation:
            last_line = line
        else:
            yield line
            last_line = None
    if last_line:
        yield last_line


def read_config(filename):
    config_lines = read_joined_lines(filename)

    rule_expr = re.compile(r'^(?!#) *([^=]+[^= ]) *= *(.*)\n')
    config = dict([
        m.groups()
        for m in filter(None, map(rule_expr.match, config_lines))])
    return config


class Config:
    MAX_PEAKS = 3
    MINIMUM_WIDTH = 1e-5
    MINIMUM_SPACING = 1e-3
    MINIMUM_HEIGHT = 0.1
    MAXIMUM_FIT_ERROR = 0.2
    WINDOW_START = 0
    WINDOW_LENGTH = 0

    SMOOTHING = 32

    def __init__(self, max_peaks, **kargs):
        self.MAX_PEAKS = max_peaks
        self.__dict__.update(kargs)

    @classmethod
    def _keys(cls):
        return [key for key in cls.__dict__.keys() if key[0] != '_']

    def __repr__(self):
        return 'Config(%s)' % ', '.join([
            '%s=%s' % (key, getattr(self, key))
            for key in self._keys()])


def abs2(z):
    return z.real ** 2 + z.imag ** 2
