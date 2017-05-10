# Use register definitions to create API

import os
import sys

# Hacks to pull in the the right definitions
HERE = os.path.dirname(__file__)
TOP = os.path.abspath(os.path.join(HERE, '../..'))
sys.path.append(os.path.join(TOP, 'AMC525/python'))

DEFS = os.path.join(TOP, 'AMC525/vhd/register_defs.in')


from parse import indent
from parse import register_defs
import parse


class Field:
    def __init__(self, field):
        self._name = field.name
        self._range = field.range

    def _read(self, parent):
        offset, length = self._range
        mask = (1 << length) - 1

        reg = parent._read_value()
        return (reg >> offset) & mask

    def _write(self, parent, value):
        offset, length = self._range
        mask = (1 << length) - 1

        value = value & mask
        mask = mask << offset

        reg = parent._read_value()
        parent._write_value((value << offset) | (reg & ~mask))


# Computes a register class from the given register parse and fields
def make_register(register, fields):
    class Register(object):
        _name = register.name
        __offset = register.offset
        __rw = register.rw

        def __init__(self, parent, value = 0):
            self.__parent = parent
            self.__value = value

        def _read_value(self):
            if self.__parent:
                if self.__rw in ['R', 'RW']:
                    self.__value = self.__parent._read_value(self.__offset)
                elif self.__rw == 'WP':
                    self.__value = 0
            return self.__value

        def _write_value(self, value):
            self.__value = value
            if self.__parent:
                assert self.__rw != 'R', 'Read only register'
                self.__parent._write_value(self.__offset, value)

        # _value returns the underlying register value
        _value = property(_read_value, _write_value)

        def __get_fields(self):
            return self.__class__(None, self._value)

        def __set_fields(self, value):
            self._value = value.__value

        # _fields returns an updatable image of the current register settings as
        # a group of settable fields
        _fields = property(__get_fields, __set_fields)

        _field_names = []
        def __repr__(self):
            if self._field_names:
                fields = self._fields
                values = ', '.join(
                    '%s = %d' % (name, getattr(fields, name))
                    for name in self._field_names)
            else:
                values = '%d' % self._value
            return '<Reg %s @%d %s>' % (self._name, self.__offset, values)

    for field in fields:
        setattr(Register, field._name, property(field._read, field._write))
        Register._field_names.append(field._name)

    return Register


class Delegator(object):
    def __init__(self, parent):
        self.__parent = parent

    def _read_value(self, offset):
        return self.__parent._read_value(offset)

    def _write_value(self, offset, value):
        self.__parent._write_value(offset, value)


def make_group(group, fields):
    class Group(Delegator):
        _name = group.name

    for field in fields:
        setattr(Group, field._name, property(field))

    return Group


def make_array(array):
    class RegisterArray(Delegator):
        _name = array.name
        __range = array.range

        def __setitem__(self, index, value):
            base, length = self.__range
            assert 0 <= index < length, 'Index out of range'
            self._write_value(base + index, value)

        def __getitem__(self, index):
            base, length = self.__range
            assert 0 <= index < length, 'Index out of range'
            return self._read_value(base + index)

        def __repr__(self):
            base, length = self.__range
            values = ('%d' % self[i] for i in range(length))
            return '<RegArray %s @%d [%s]>' % (
                self._name, base, ', '.join(values))

    return RegisterArray


class Generate(parse.register_defs.WalkParse):
    def walk_field(self, context, field):
        return Field(field)

    def walk_register_array(self, context, array):
        return make_array(array)

    def walk_register(self, context, register):
        return make_register(register, self.walk_fields(context, register))

    def walk_group(self, context, group):
        return make_group(group, self.walk_subgroups(context, group))

generate = Generate()



# Read the definitions in parsed form
defs = parse.register_defs.parse(parse.indent.parse_file(file(DEFS)))
defs = parse.register_defs.flatten(defs)

groups = {}
for group in defs.groups:
    groups[group.name] = generate.walk_group(None, group)


class BaseAddress(object):
    def __init__(self, base_address):
        self.base_address = base_address

        self.values = {}

    def _read_value(self, offset):
        result = self.values.setdefault(offset, 0)
        print '%04x[%d] => %d' % (self.base_address, offset, result)
        return result

    def _write_value(self, offset, value):
        print '%04x[%d] <= %d' % (self.base_address, offset, value)
        self.values[offset] = value


if __name__ == '__main__':
    sys = groups['SYS'](BaseAddress(0))

    print sys.VERSION
    print sys.STATUS
    print sys.CONTROL
    print sys.ADC_IDELAY
    print sys.FMC_SPI
    print sys.DAC_TEST
    print sys.REV_IDELAY

    dsp0 = groups['DSP'](BaseAddress(0x3000))

    print dsp0.MISC.PULSED
    print dsp0.MISC.STROBE
    print dsp0.MISC.NCO0_FREQ
    dsp0.ADC.CONFIG.THRESHOLD = 1234
    print dsp0.ADC.CONFIG
    print dsp0.ADC.TAPS
    print dsp0.ADC.MMS
    print dsp0.ADC.MMS.COUNT
    print dsp0.ADC.MMS.READOUT

    dsp0.MISC.STROBE.WRITE = 1
    dsp0.MISC.STROBE.RESET_DELTA = 1

    strobe = dsp0.MISC.STROBE._fields
    strobe.WRITE = 1
    strobe.RESET_DELTA = 1
    dsp0.MISC.STROBE._fields = strobe
    print dsp0.MISC.STROBE
    dsp0.MISC.STROBE._fields = strobe

    print
    dsp0.ADC.CONFIG.THRESHOLD = 1234
    print dsp0.ADC.CONFIG
