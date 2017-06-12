# Parses register definition file into an abstract syntax.

# Syntax of register_defs.in as parsed by parse_register_defs.py
#
#   register_defs = { register_def_entry }*
#   register_def_entry = group_def | shared_def
#   shared_def = shared_reg_def | shared_group_def
#
#   group_def = "!"name { group_entry }*
#   group_entry = group_def | reg_def | reg_pair | reg_array | shared_name
#
#   reg_def = name rw { field_def | field_skip }*
#   field_def = "."name [ width ] [ "@"offset ] [ rw ]
#   field_skip = "-" [ width ]
#
#   reg_pair = "*RW" { reg_def }2
#   reg_array = name count rw
#
#   shared_reg_def = ":"reg_def
#   shared_group_def = ":"group_def
#
#   shared_name = ":"saved_name new_name
#
#   rw = "R" | "W" | "RW" | "WP"
#
#   name and new_name are any valid VHDL identifier
#   saved_name is a previously defined shared_reg_def or shared_group_def name
#   count, offset, width are all integers
#
# The syntax {...}* denotes a list of parses at the indented level, {...}2
# specifies precisely two sub-parses, {...}+ denotes one or more sub-parses.
#
# This concrete syntax is flattened somewhat to generate register groups,
# registers, and field.  Note: we could record the two lists of sub-values as
# separate lists, but then we'd lose the ordering, in particular keeping the
# ordering of fields and bits is important for documentation.
#
#   group = (name, range, [group | register | register_array], definition, doc)
#   register = (name, offset, rw, [field], definition, doc)
#   field = (name, range, is_bit, rw, doc)
#   register_array = (name, range, rw, doc)

import sys
from collections import namedtuple, OrderedDict
import re

import indent


# ------------------------------------------------------------------------------
# The following structures are used to return the results of a parse.

Group = namedtuple('Group',
    ['name', 'range', 'content', 'definition', 'doc'])
Register = namedtuple('Register',
    ['name', 'offset', 'rw', 'fields', 'definition', 'doc'])
RegisterArray = namedtuple('RegisterArray',
    ['name', 'range', 'rw', 'doc'])
Field = namedtuple('Field',
    ['name', 'range', 'is_bit', 'rw', 'doc'])
Overlay = namedtuple('Overlay', ['registers'])

Parse = namedtuple('Parse', ['group_defs', 'register_defs', 'groups'])


# ------------------------------------------------------------------------------
# Helper functions for walking the parse.

class WalkParse:
    '''This class should be subclassed and the following methods need to be
    defined, then .walk_parse(), .walk_subgroups() and walk_fields() can be
    called to walk the parse:

        def walk_register_array(self, context, array):
        def walk_field(self, context, field):
        def walk_group(self, context, group):
        def walk_register(self, context, reg):
        def walk_overlay(self, context, overlay):

    '''

    def walk_subgroup(self, context, entry):
        if isinstance(entry, Group):
            return self.walk_group(context, entry)
        elif isinstance(entry, Register):
            return self.walk_register(context, entry)
        elif isinstance(entry, RegisterArray):
            return self.walk_register_array(context, entry)
        elif isinstance(entry, Overlay):
            return self.walk_overlay(context, entry)
        else:
            assert False

    def walk_subgroups(self, context, group):
        return [
            self.walk_subgroup(context, entry)
            for entry in group.content]

    def walk_fields(self, context, register):
        return [
            self.walk_field(context, field)
            for field in register.fields]


# ------------------------------------------------------------------------------
# Debug function for printing result of parse

class PrintMethods(WalkParse):
    def __init__(self, name_prefix = ''):
        self.__name_prefix = name_prefix

    def __print_prefix(self, n, prefix):
        sys.stdout.write(n * '    ')
        print prefix,

    def __print_doc(self, n, doc):
        for d in doc:
            self.__print_prefix(n, '#')
            print d

    def __do_print(self, n, prefix, value, *fields):
        self.__print_doc(n, value.doc)
        self.__print_prefix(n, prefix)
        print '%s%s' % (self.__name_prefix, value.name),
        for field in fields:
            print field,


    # WalkParse interface methods

    def walk_register_array(self, n, array):
        self.__do_print(n, 'A', array, array.range, array.rw)
        print

    def walk_field(self, n, field):
        self.__do_print(n, 'F', field, field.range, field.is_bit, field.rw)
        print

    def walk_group(self, n, group):
        self.__do_print(n, 'G', group, group.range)
        if group.definition:
            print ':', group.definition.name,
        print
        self.walk_subgroups(n + 1, group)

    def walk_register(self, n, reg):
        self.__do_print(n, 'R', reg, reg.offset, reg.rw)
        if reg.definition:
            print ':', reg.definition.name,
        print
        self.walk_fields(n + 1, reg)

    def walk_overlay(self, n, overlay):
        self.__print_prefix(n, 'O')
        print
        for reg in overlay.registers:
            self.walk_register(n + 1, reg)


def print_parse(parse):
    methods = PrintMethods(':')
    for g in parse.group_defs:
        methods.walk_group(0, g)
    for r in parse.register_defs:
        methods.walk_register(0, r)

    methods = PrintMethods()
    for g in parse.groups:
        methods.walk_group(0, g)


# ------------------------------------------------------------------------------
# Parse implementation


def fail_parse(message, line_no):
    print >>sys.stderr, 'Parse error: %s at line %d' % (message, line_no)
    sys.exit(1)

def parse_int(value, line_no):
    try:
        return int(value, 0)
    except:
        fail_parse('Expected integer', line_no)

def check_args(args, min_length, max_length, line_no):
    if len(args) < min_length:
        fail_parse('Expected more arguments', line_no)
    if len(args) > max_length:
        fail_parse('Unexpected extra arguments', line_no)

name_pattern = re.compile(r'[A-Z][A-Z0-9_]*$', re.I)
def check_name(name, line_no):
    if not name_pattern.match(name):
        fail_parse('Invalid name "%s"' % name, line_no)

def check_body(parse):
    if parse.body:
        fail_parse('No sub-definitions allowed here', parse.line_no)

def is_int(value):
    return value and value[0] in '0123456789'

def check_rw(rw, line_no):
    if rw not in ['R', 'W', 'RW', 'WP']:
        fail_parse('Invalid R/W specification', line_no)


def is_field_skip(parse):
    return parse.line.split()[0] == '-'


# field_def = "."name [ width ] [ "@"offset ] [ rw ]
def parse_field_def(offset, parse):
    line, _, doc, line_no = parse
    line = line.split()
    name = line[0]
    args = line[1:]

    check_body(parse)
    if name[0] != '.':
        fail_parse('Expected field definition', line_no)
    name = name[1:]

    if args and is_int(args[0]):
        is_bit = False
        count = parse_int(args[0], line_no)
        del args[0]
    else:
        is_bit = True
        count = 1

    if args and args[0][0] == '@':
        offset = parse_int(args[0][1:], line_no)
        del args[0]

    check_args(args, 0, 1, line_no)
    if args:
        rw = args[0]
        check_rw(rw, line_no)
    else:
        rw = ''

    return (Field(name, (offset, count), is_bit, rw, doc), offset + count)


# field_skip = "-" [ width ]
def parse_field_skip(parse):
    line, body, _, line_no = parse
    line = line.split()
    check_args(line, 1, 2, line_no)

    if len(line) > 1:
        return parse_int(line[1], line_no)
    else:
        return 1


def parse_field_defs(field_list):
    fields = []
    offset = 0
    for parse in field_list:
        if is_field_skip(parse):
            offset += parse_field_skip(parse)
        else:
            field, offset = parse_field_def(offset, parse)
            fields.append(field)
    return fields


# reg_def = name rw { field_def | field_skip }*
def parse_reg_def(offset, parse, expect = []):
    line, body, doc, line_no = parse
    line = line.split()
    check_args(line, 2, 2, line_no)
    name = line[0]
    check_name(name, line_no)
    rw = line[1]
    check_rw(rw, line_no)
    if expect and rw not in expect:
        fail_parse('Expected %s field' % expect, line_no)

    fields = parse_field_defs(body)
    return Register(name, offset, rw, fields, None, doc)


def is_reg_array(parse):
    line = parse[0].split()
    return len(line) > 1 and is_int(line[1])


# reg_array = name count rw
def parse_reg_array(offset, parse):
    line, _, doc, line_no = parse
    line = line.split()
    check_args(line, 3, 3, line_no)
    name = line[0]
    check_name(name, line_no)
    count = parse_int(line[1], line_no)
    rw = line[2]
    check_rw(rw, line_no)
    check_body(parse)
    return (RegisterArray(name, (offset, count), rw, doc), count)


# reg_pair = "*RW" { reg_def }2
def parse_reg_pair(offset, parse):
    line, body, _, line_no = parse
    if line != '*RW':
        fail_parse('Expected *RW here', line_no)
    if len(body) != 2:
        fail_parse('Must have two registers', line_no)
    return (Overlay([
        parse_reg_def(offset, body[0], expect = ['R']),
        parse_reg_def(offset, body[1], expect = ['W', 'WP'])]), 1)


# shared_name = ":"saved_name new_name
def parse_shared_name(offset, parse, defines):
    line, body, doc, line_no = parse
    line = line.split()
    key = line[0]
    name = line[1] if len(line) > 1 else key
    check_name(name, line_no)
    if key not in defines:
        fail_parse('Unknown shared name %s' % key, line_no)
    define = defines[key]
    if isinstance(define, Group):
        check_body(parse)
        length = define.range[1]
        result = Group(name, (offset, length), [], define, doc)
    elif isinstance(define, Register):
        fields = parse_field_defs(body)
        length = 1
        result = Register(name, offset, define.rw, fields, define, doc)
    else:
        assert False
    return (result, length)


# Returns a list of results together with the number of registers spanned by the
# returned result.
#
# group_entry = group_def | reg_def | reg_pair | reg_array | shared_name
def parse_group_entry(offset, parse, defines):
    line, body, _, line_no = parse
    if line[0] in '.-':
        fail_parse('Field definition not allowed here', line_no)

    # Dispatch the parse
    if line[0] == ':':
        # shared_name = ":"...
        return parse_shared_name(
            offset, parse._replace(line = line[1:]), defines)
    elif line[0] == '*':
        return parse_reg_pair(offset, parse)
    elif line[0] == '!':
        # Not a register definition, must be a group
        return parse_group_def(offset, parse, defines)
    elif is_reg_array(parse):
        return parse_reg_array(offset, parse)
    else:
        return (parse_reg_def(offset, parse), 1)


# Parses a group definition, returns the resulting parse together with the
# number of registers in the parsed group
#
# group_def = "!"name { group_entry }*
def parse_group_def(offset, parse, defines):
    line, body, doc, line_no = parse

    line = line.split()
    name = line[0]
    assert name[0] == '!'
    name = name[1:]
    check_name(name, line_no)

    check_args(line, 1, 1, line_no)

    content = []
    count = 0
    for entry in body:
        result, entry_count = \
            parse_group_entry(offset + count, entry, defines)
        count += entry_count
        content.append(result)

    return (Group(name, (offset, count), content, None, doc), count)


# shared_def = shared_reg_def | shared_group_def
def parse_shared_def(parse, defines):
    # Parsing one of shared_reg_def or shared_group_def.
    line = parse.line[1:]
    parse = parse._replace(line = line)
    if line[0] == '!':
        result, _ = parse_group_def(0, parse, {})
    else:
        result = parse_reg_def(0, parse)
    defines[result.name] = result


# Parse for a top level entry -- either a reusable name definition, if prefixed
# with :, or a top level group definition.
#
# register_def_entry = group_def | shared_def
def parse_register_def_entry(parse, defines):
    if parse.line[0] == ':':
        parse_shared_def(parse, defines)
        return []
    elif parse.line[0] == '!':
        group, count = parse_group_def(0, parse, defines)
        return [group]
    else:
        fail_parse(
            'Ungrouped register definition not expected here', parse.line_no)


# Pull the defines apart into register and group definitions.
def separate_defines(defines):
    group_defs = []
    register_defs = []
    for d in defines.values():
        if isinstance(d, Group):
            group_defs.append(d)
        elif isinstance(d, Register):
            register_defs.append(d)
        else:
            assert False
    return group_defs, register_defs


# Converts a list of indented parses into a list of Group definitions
def parse(parse):
    defines = OrderedDict()
    groups = []

    # The incoming parse is a list of (line, [parse], doc, line_no) parses
    for entry in parse:
        groups.extend(parse_register_def_entry(entry, defines))

    group_defs, register_defs = separate_defines(defines)
    return Parse(group_defs, register_defs, groups)


# ------------------------------------------------------------------------------
# Flattening

class FlattenMethods(WalkParse):
    def walk_field(self, offset, field):
        return field

    def walk_register_array(self, offset, array):
        base, length = array.range
        return array._replace(range = (base + offset, length))

    def walk_group(self, offset, group):
        base, length = group.range
        group_def = group.definition
        if group_def:
            content = self.walk_subgroups(offset + base, group_def)
        else:
            content = self.walk_subgroups(offset, group)
        return group._replace(
            range = (base + offset, length), content = content)

    def walk_register(self, offset, reg):
        reg_def = reg.definition
        if reg_def:
            return reg._replace(
                name = reg.name, offset = reg.offset,
                fields = reg_def.fields + reg.fields)
        else:
            return reg._replace(offset = reg.offset + offset)

    def walk_overlay(self, offset, overlay):
        registers = [
            self.walk_register(offset, reg)
            for reg in overlay.registers]
        return overlay._replace(registers = registers)


# Eliminates definitions from a parse by replacing all group and register
# entries by their corresponding definitions
def flatten(parse):
    flatten = FlattenMethods()
    groups = [flatten.walk_group(0, group) for group in parse.groups]
    return parse._replace(groups = groups)


# ------------------------------------------------------------------------------

if __name__ == '__main__':
    import sys
    indent_parse = indent.parse_file(file(sys.argv[1]))
    parse = parse(indent_parse)
    print_parse(parse)
    print
    print_parse(flatten(parse))
