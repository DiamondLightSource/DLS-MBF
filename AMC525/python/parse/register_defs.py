# Parses register definition file into an abstract syntax.

# Syntax of register_defs.in as parsed by parse_register_defs.py
#
#   register_defs = { register_def_entry }*
#   register_def_entry = group_def | shared_def
#   shared_def = shared_reg_def | shared_group_def
#
#   group_def = name { group_entry }+
#   group_entry = group_def | reg_def | reg_pair | reg_array | shared_name
#
#   reg_def = name [ rw ] { field_def | field_skip }*
#   field_def = "."name [ width ] [ "@"offset ] [ rw ]
#   field_skip = "-" [ width ]
#
#   reg_pair = "*RW" { reg_def }2
#   reg_array = name count [ rw ]
#
#   shared_reg_def = ":"reg_def
#   shared_group_def = ":"group_def
#
#   shared_name = ":"saved_name new_name
#
#   rw = "R" | "W" | "RW"
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
#   register = (name, offset, rw, overlaid, [field | bit], definition, doc)
#   field = (name, range, rw, doc)
#   bit = (name, offset, rw, doc)
#   register_array = (name, range, rw, doc)

import sys
from collections import namedtuple, OrderedDict

import indent


# ------------------------------------------------------------------------------
# The following structures are used to return the results of a parse.

Group = namedtuple('Group',
    ['name', 'range', 'content', 'definition', 'doc'])
Register = namedtuple('Register',
    ['name', 'offset', 'rw', 'overlaid', 'content', 'definition', 'doc'])
RegisterArray = namedtuple('RegisterArray',
    ['name', 'range', 'rw', 'doc'])
Field = namedtuple('Field',
    ['name', 'range', 'rw', 'doc'])
Bit = namedtuple('Bit',
    ['name', 'offset', 'rw', 'doc'])

Parse = namedtuple('Parse', ['group_defs', 'register_defs', 'groups'])


# ------------------------------------------------------------------------------
# Helper functions for walking the parse.

class WalkParse:
    '''This class should be subclassed and the following methods need to be
    defined, then .walk_parse(), .walk_subgroups() and walk_fields() can be
    called to walk the parse:

        def walk_register_array(self, context, array):
        def walk_field(self, context, field):
        def walk_bit(self, context, bit):
        def walk_group(self, context, group):
        def walk_register(self, context, reg):

    '''

    def walk_subgroup(self, context, entry):
        if isinstance(entry, Group):
            return self.walk_group(context, entry)
        elif isinstance(entry, Register):
            return self.walk_register(context, entry)
        elif isinstance(entry, RegisterArray):
            return self.walk_register_array(context, entry)
        else:
            assert False

    def walk_subgroups(self, context, group):
        return [
            self.walk_subgroup(context, entry)
            for entry in group.content]

    def walk_field_def(self, context, field):
        if isinstance(field, Field):
            return self.walk_field(context, field)
        elif isinstance(field, Bit):
            return self.walk_bit(context, field)
        else:
            assert False

    def walk_fields(self, context, register):
        return [
            self.walk_field_def(context, field)
            for field in register.content]


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
        self.__do_print(n, 'F', field, field.range, field.rw)
        print

    def walk_bit(self, n, bit):
        self.__do_print(n, 'B', bit, bit.offset, bit.rw)
        print

    def walk_group(self, n, group):
        self.__do_print(n, 'G', group, group.range)
        if group.definition:
            print ':', group.definition.name,
        print
        self.walk_subgroups(n + 1, group)

    def walk_register(self, n, reg):
        self.__do_print(n, 'R', reg, reg.offset, reg.rw, reg.overlaid)
        if reg.definition:
            print ':', reg.definition.name,
        print
        self.walk_fields(n + 1, reg)


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
        return int(value)
    except:
        fail_parse('Expected integer', line_no)

def check_args(args, max_length, line_no):
    if len(args) > max_length:
        fail_parse('Unexpected extra arguments', line_no)

def is_int(value):
    return value and value[0] in '0123456789'

def check_rw(rw, line_no):
    if rw not in ['R', 'W', 'RW', '']:
        fail_parse('Invalid R/W specification', line_no)


# Determines whether this is a register or group definition by looking more
# closely at the parse.
def is_register_def(parse):
    line, body, doc, line_no = parse

    # Three separate cases identify a register definition
    if not body:
        # A group definition must be non empty
        return True
    elif len(line.split()) > 1:
        # A group definition can only be a single word
        return True
    else:
        body_line, _, _, _ = body[0]
        if body_line[0] in '.-':
            # A group definition cannot be followed by fields
            return True
    return False


def is_field_skip(parse):
    line, body, doc, line_no = parse
    return line.split()[0] == '-'


def parse_field_def(offset, parse):
    line, body, doc, line_no = parse
    line = line.split()
    name = line[0]
    args = line[1:]

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

    rw = args[0] if args else ''
    check_args(args, 1, line_no)

    if is_bit:
        result = Bit(name, offset, rw, doc)
    else:
        result = Field(name, (offset, count), rw, doc)
    return (result, offset + count)


def parse_field_skip(parse):
    line, body, doc, line_no = parse
    line = line.split()
    check_args(line, 2, line_no)

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


# reg_def = name [ rw ] { field_def }*
def parse_reg_def(offset, parse, expect = None):
    line, body, doc, line_no = parse
    line = line.split()
    rw = line[1] if len(line) > 1 else ''
    check_rw(rw, line_no)
    check_args(line, 2, line_no)
    if expect and rw != expect:
        fail_parse('Expected %s field' % expect, line_no)
    overlaid = bool(expect)

    fields = parse_field_defs(body)
    return Register(line[0], offset, rw, overlaid, fields, None, doc)


def is_reg_array(parse):
    line = parse[0].split()
    return len(line) > 1 and is_int(line[1])


def parse_reg_array(offset, parse):
    line, body, doc, line_no = parse
    line = line.split()
    if len(line) < 2:
        fail_parse('Expected register count', line_no)
    count = parse_int(line[1], line_no)
    rw = line[2] if len(line) > 2 else ''
    check_args(line, 3, line_no)
    if body:
        fail_parse('Unexpected field definitions', line_no)
    return (RegisterArray(line[0], (offset, count), rw, doc), count)



def parse_reg_pair(offset, parse):
    line, body, doc, line_no = parse
    if len(body) != 2:
        fail_parse('Must have two registers', line_no)
    reg1 = parse_reg_def(offset, body[0], expect = 'R')
    reg2 = parse_reg_def(offset, body[1], expect = 'W')
    return [reg2, reg1]
    return [reg1, reg2]


def parse_shared_name(offset, line, defines):
    line = line.split()
    name = line[1] if len(line) > 1 else line[0]
    define = defines[line[0]]
    if isinstance(define, Group):
        length = define.range[1]
        return (
            define._replace(
                name = name, range = (offset, length),
                content = [], definition = define),
            length)
    elif isinstance(define, Register):
        return (
            define._replace(
                name = name, offset = offset,
                content = [], definition = define),
            1)
    else:
        assert False


# Returns a list of results together with the number of registers spanned by the
# returned result.
def parse_group_entry(offset, parse, defines):
    line, body, doc, line_no = parse
    if line[0] in '.-':
        parse_fail('Field definition not allowed here', line_no)

    # Dispatch the parse
    if line[0] == ':':
        # shared_name = ":"...
        return parse_shared_name(offset, line[1:], defines)
    elif not is_register_def(parse):
        # Not a register definition, must be a group
        return parse_group_def(offset, parse, defines)
    elif is_reg_array(parse):
        return parse_reg_array(offset, parse)
    else:
        return (parse_reg_def(offset, parse), 1)


# Parses a group definition, returns the resulting parse together with the
# number of registers in the parsed group
def parse_group_def(offset, parse, defines):
    line, body, doc, line_no = parse
    check_args(line.split(), 1, line_no)

    content = []
    count = 0
    for entry in body:
        # Need to handle register pairs specially at this level as they return a
        # pair of registers
        if entry.line == '*RW':
            result = parse_reg_pair(offset + count, entry)
            count += 1
            content.extend(result)
        else:
            result, entry_count = \
                parse_group_entry(offset + count, entry, defines)
            count += entry_count
            content.append(result)

    return (Group(line, (offset, count), content, None, doc), count)


def parse_shared_def(parse, defines):
    line, body, doc, line_no = parse
    # Parsing one of shared_reg_def or shared_group_def.  Use the rest of
    # the line as the name.
    line = parse.line[1:]
    name = line.split()[0]
    parse = parse._replace(line = line)
    if is_register_def(parse):
        result = parse_reg_def(0, parse)
    else:
        result, _ = parse_group_def(0, parse, {})
    defines[name] = result


# Parse for a top level entry -- either a reusable name definition, if prefixed
# with :, or a top level group definition.
def parse_register_def_entry(parse, defines):
    if parse.line[0] == ':':
        parse_shared_def(parse, defines)
        return []
    else:
        group, count = parse_group_def(0, parse, defines)
        return [group]


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



if __name__ == '__main__':
    import sys
    indent_parse = indent.parse_file(file(sys.argv[1]))
    parse = parse(indent_parse)
    print_parse(parse)
