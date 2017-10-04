# Use register definitions to create API

import os
import sys
import numpy

import lmbf


# Reads and writes a bit-field in a register
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


# Dummy storage for register without hardware.
class DummyBase:
    def __init__(self, value):
        self.value = value

    def _read_value(self, offset, rw):
        return self.value

    def _write_value(self, offset, rw, value):
        self.value = value


# Computes a register class from the given register parse and fields
def make_register(register, fields):
    class Register(object):
        _name = register.name
        __offset = register.offset
        __rw = register.rw

        def __init__(self, parent):
            self.__parent = parent


        def _read_value(self):
            return self.__parent._read_value(self.__offset, self.__rw)

        def _write_value(self, value):
            self.__parent._write_value(self.__offset, self.__rw, value)

        # _value returns the underlying register value
        _value = property(_read_value, _write_value)


        def _get_fields(self, read = True):
            value = self._value if read else 0
            return self.__class__(DummyBase(value))

        def __set_fields(self, value):
            self._value = value._value

        # _fields returns an updatable image of the current register settings as
        # a group of settable fields
        _fields = property(_get_fields, __set_fields)

        @property
        def _fields_wo(self):
            return self._get_fields(False)


        # Single action update of a group of fields
        def __write_fields(self, do_read, fields):
            update = self._get_fields(do_read)
            for field, value in fields.items():
                setattr(update, field, value)
            self.__set_fields(update)

        def _write_fields_wo(self, **fields):
            self.__write_fields(False, fields)

        def _write_fields_rw(self, **fields):
            self.__write_fields(True, fields)

        @classmethod
        def _writer(cls, parent, value):
            register = cls(parent)
            if isinstance(value, (int, numpy.integer)):
                register._write_value(value)
            elif isinstance(value, Register):
                register.__set_fields(value)
            else:
                assert False


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

    def _read_value(self, offset, rw):
        return self.__parent._read_value(offset, rw)

    def _write_value(self, offset, rw, value):
        self.__parent._write_value(offset, rw, value)


def make_array(array):
    class RegisterArray(Delegator):
        _name = array.name
        __range = array.range
        __rw = array.rw

        def __setitem__(self, index, value):
            base, length = self.__range
            assert 0 <= index < length, 'Index out of range'
            self._write_value(base + index, self.__rw, value)

        def __getitem__(self, index):
            base, length = self.__range
            assert 0 <= index < length, 'Index out of range'
            return self._read_value(base + index, self.__rw)

        def __repr__(self):
            base, length = self.__range
            values = ('%d' % self[i] for i in range(length))
            return '<RegArray %s @%d [%s]>' % (
                self._name, base, ', '.join(values))

    return RegisterArray


def add_attributes(target, attributes):
    for attribute in attributes:
        if isinstance(attribute, list):
            # When we parsed an overlay we were returned a list of attributes
            add_attributes(target, attribute)
        else:
            setattr(target, attribute._name,
                property(attribute, getattr(attribute, '_writer', None)))


# An ordinary group just delegates its attributes
def make_group(group, attributes):
    class Group(Delegator):
        _name = group.name

    add_attributes(Group, attributes)

    return Group


def make_top(group, attributes):
    class Top:
        _name = group.name

        def __init__(self, hardware):
            self.__hardware = hardware
            # Cached values for write only registers
            self.__values = {}

        def _read_value(self, offset, rw):
            if rw == 'W':
                # Write only register, return cached value
                return self.__values.get(offset, 0)
            elif rw == 'WP':
                # Pulse register, only ever reads as zero
                return 0
            else:
                return self.__hardware._read_value(offset)

        def _write_value(self, offset, rw, value):
            assert rw != 'R', 'Writing to read only register'
            if rw == 'W':
                # Cache value written to write-only register
                self.__values[offset] = value
            self.__hardware._write_value(offset, value)

    add_attributes(Top, attributes)

    return Top


class GenerateMethods(lmbf.parse.register_defs.WalkParse):
    def walk_field(self, context, field):
        return Field(field)

    def walk_register_array(self, context, array):
        return make_array(array)

    def walk_register(self, context, register):
        return make_register(register, self.walk_fields(context, register))

    def walk_group(self, context, group):
        return make_group(group, self.walk_subgroups(context, group))

    def walk_rw_pair(self, context, rw_pair):
        return [
            self.walk_register(context, register)
            for register in rw_pair.registers]

    def walk_overlay(self, context, overlay):
        # Overlay registers are a bit tricky: the register number is the overlay
        # index, not the register offset, so fix this as we walk each register
        registers = [
            self.walk_register(
                context, register._replace(offset = overlay.offset))
            for register in overlay.registers]
        return make_group(overlay, registers)

    def walk_union(self, context, union):
        return self.walk_subgroups(context, union)

    def walk_top(self, group):
        return make_top(group, self.walk_subgroups(None, group))


generate = GenerateMethods()



# Read the definitions in parsed form
defs = lmbf.parsed_defs(flatten = True)

register_groups = {}
for group in defs.groups:
    register_groups[group.name] = generate.walk_top(group)


class BaseAddress:
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
    sys = register_groups['SYS'](BaseAddress(0))

    print sys.VERSION
    print sys.STATUS
    print sys.CONTROL
    print sys.ADC_IDELAY
    print sys.FMC_SPI
    print sys.DAC_TEST
    print sys.REV_IDELAY

    dsp0 = register_groups['DSP'](BaseAddress(0x3000))

    print dsp0.MISC.PULSED
    print dsp0.MISC.STROBE
    print dsp0.MISC.NCO0_FREQ
    dsp0.ADC.CONFIG.THRESHOLD = 1234
    print dsp0.ADC.CONFIG
    print dsp0.ADC.TAPS
    print dsp0.ADC.MMS
    print dsp0.ADC.MMS.COUNT
    print dsp0.ADC.MMS.READOUT

    print
    dsp0.MISC.STROBE.WRITE = 1
    dsp0.MISC.STROBE.RESET_DELTA = 1

    strobe = dsp0.MISC.STROBE._fields
    strobe.WRITE = 1
    strobe.RESET_DELTA = 1
    dsp0.MISC.STROBE._fields = strobe
    print dsp0.MISC.STROBE
    dsp0.MISC.STROBE._fields = strobe
    dsp0.MISC.STROBE._write_fields_wo(WRITE = 1, RESET_DELTA = 1)

    print
    dsp0.ADC.CONFIG.THRESHOLD = 1234
    print dsp0.ADC.CONFIG

    print
    dsp0.ADC.TAPS = 1234
    dsp0.MISC.STROBE = strobe
