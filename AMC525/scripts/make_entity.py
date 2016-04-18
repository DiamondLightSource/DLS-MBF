#!/bin/env dls-python

import sys
import os
import types

# Inputs are a list of signals, a list of pin assignments, and a list of signals
# actually used.
signal_file = sys.argv[1]
pins_file = sys.argv[2]
used_file = sys.argv[3]

# We generate two files: a top level entity and a pin constrains file.
entity_name = sys.argv[4]

entity_file = '%s_entity.vhd' % entity_name
xdc_file = '%s_pins.xdc' % entity_name


# Template string for entity.
entity_template_head = '''\
-- Skeleton top level VHDL

library ieee;
use ieee.std_logic_1164.all;

entity %(entity_name)s is
port (
'''

entity_template_declaration = '''\
%(sep)s    %(name)s : %(direction)s %(type)s\
'''

entity_template_tail = '''\

);
end;
'''

xdc_template_line = '''\
set_property PACKAGE_PIN %(location)s [get_ports {%(name)s%(index)s}]
'''



def uncomment_file(file_name, comment):
    for line in file(file_name):
        line = line.split(comment, 1)[0].rstrip()
        if line:
            yield line


# Expands strings of the form a{b,c} into ab ac.  Can't cope with nested
# brackets, but can cope with sequences.
def expand_string(string):
    if '{' in string:
        start, tail = string.split('{', 1)
        repeats, tail = tail.split('}', 1)
        for repeat in repeats.split(','):
            for string in expand_string(start + repeat + tail):
                yield string
    else:
        yield string


# Extracts the range part from the name, parses string of form
#
#   name [ "[" range "]" ]
#
# into its two components.  Leaves the range part unprocessed for parsing below.
def parse_basic_name(name):
    if '[' in name:
        name, range = name.split('[', 1)
        assert range[-1] == ']', 'Malformed range'
        range = range[:-1]
        assert range, 'Unexpected empty range'
        return name, range
    else:
        return (name, None)


# Parses name of form
#
#   name-range = name [ "[" start ".." end "]" ]
#
def parse_name_range(name):
    name, range = parse_basic_name(name)
    if range:
        range = range.split('..', 1)
        range = (int(range[0]), int(range[1]))
    return (name, range)


# Parses name of form
#
#   name-index = name [ "[" index "]" ]
#
def parse_name_index(name):
    name, index = parse_basic_name(name)
    if index:
        index = int(index)
    return (name, index)


# Checks validity of direction field.
def check_direction(direction):
    assert direction in ['in', 'out', 'inout'], \
        'Invalid direction %s' % direction

# Checks that a direction refinement is valid
def check_signal_direction(signal_direction, direction):
    assert signal_direction == direction or signal_direction == 'inout', \
        'Can only refine direction of inout signal'

# Checks that the given range is valid for the signal and is the same direction
def check_signal_range(signal_range, range):
    # A bit complicated: range can be None, a single number, or a tuple.
    if range is None:
        assert signal_range is None, 'Must explitly specify range'
    elif isinstance(range, types.TupleType):
        s_start, s_end = signal_range
        i_start, i_end = range
        if s_start <= s_end:
            assert s_start <= i_start <= i_end <= s_end
        else:
            assert s_start >= i_start >= i_end >= s_end
    else:
        s_start, s_end = signal_range
        if s_start <= s_end:
            assert s_start <= range <= s_end
        else:
            assert s_start >= range >= s_end




# Each line is simply a name followed by pin direction.
#
#   signals = signal-line*
#   direction = "in" | "out" | "inout"
#   signal-line = name-range direction
#
def load_signals(signal_file):
    signals = {}

    for line in uncomment_file(signal_file, '--'):
        names_range, direction = line.split()
        check_direction(direction)
        names, range = parse_name_range(names_range)
        for name in expand_string(names):
            assert name not in signals, 'Repeated signal name'
            signals[name] = (range, direction)

    return signals


# Each line is a fully qualified signal name followed by a location identifier
#
#   locations = location-line*
#   location-line = name-index location
#
def load_locations(pins_file):
    pins = {}
    for line in uncomment_file(pins_file, '#'):
        name, pin = line.split()
        name, index = parse_name_index(name)
        pins[(name, index)] = pin
    return pins


# The list of used pins is similar in syntax to the list of signals, but an
# alias can be specified.
#
#   used-pins = used-pins-line*
#   used-pins-line = name-range direction [ name-range | name-index ]
#
# The name-index form is permitted if the original name is a single name.
def load_used_pins(signals, used_file):
    used_pins = []

    for line in uncomment_file(used_file, '--'):
        fields = line.split()
        out_name_range, direction = fields[:2]
        check_direction(direction)
        out_names, out_range = parse_name_range(out_name_range)
        if fields[2:]:
            in_name_range, = fields[2:]
            if out_range is None:
                in_names, in_range = parse_name_index(in_name_range)
            else:
                in_names, in_range = parse_name_range(in_name_range)
        else:
            in_names, in_range = out_names, out_range

        in_out_names = zip(expand_string(in_names), expand_string(out_names))
        for in_name, out_name in in_out_names:
            signal_range, signal_direction = signals[in_name]
            check_signal_direction(signal_direction, direction)
            check_signal_range(signal_range, in_range)
            used_pins.append(
                (in_name, in_range, out_name, out_range, direction))

    return used_pins


# Returns the appropriate type for the given range
def range_type(range):
    if range is None:
        return 'std_logic'
    else:
        low, high = range
        updown = 'to' if low <= high else 'downto'
        return 'std_logic_vector(%d %s %d)' % (low, updown, high)


def map_pin_range(mapping):
    in_name, in_range, out_name, out_range, direction = mapping
    type = range_type(out_range)
    return out_name, direction, type


# The entity maps all the used pins.
def write_entity(used_pins, entity_name, entity_file):
    with open(entity_file, 'w') as file:
        file.write(entity_template_head % locals())
        sep = ''
        for mapping in used_pins:
            name, direction, type = map_pin_range(mapping)
            file.write(entity_template_declaration % locals())
            sep = ';\n'
        file.write(entity_template_tail % locals())


def map_range(start, end):
    if start <= end:
        return range(start, end + 1)
    else:
        return range(start, end - 1, -1)

def map_used_pins(locations, mapping):
    in_name, in_range, out_name, out_range, direction = mapping

    if out_range is None:
        yield out_name, '', locations[(in_name, in_range)]
    else:
        for in_ix, out_ix in zip(map_range(*in_range), map_range(*out_range)):
            yield out_name, '[%d]' % out_ix, locations[(in_name, in_ix)]


# Maps each used pin to the appropriate physical location.
def write_xdc(locations, used_pins, xdc_file):
    with open(xdc_file, 'w') as file:
        for mapping in used_pins:
            mapped = map_used_pins(locations, mapping)
            for name, index, location in mapped:
                file.write(xdc_template_line % locals())


signals = load_signals(signal_file)
locations = load_locations(pins_file)
used = load_used_pins(signals, used_file)

write_entity(used, entity_name, entity_file)
write_xdc(locations, used, xdc_file)
