#!/usr/bin/env python

import sys
import parse


head_template = '''\
--
-- DO NOT EDIT THIS FILE !!!
--
-- This file has been automatically generated.
-- To change this file edit the source file and rebuild.
--

-- Register definitions

package %s is
'''
tail_template = 'end;'

reg_template   = '    constant %(reg_name)s : natural := %(index)d;'

subtype_template = '    subtype %%(reg_name)s is natural range %s;'
range_templates = {
    'to'     : subtype_template % '%(low)d to %(high)d',
    'downto' : subtype_template % '%(high)d downto %(low)d',
}


def prefix_name(prefix, name, suffix):
    return '%s%s_%s' % ('_'.join(prefix + ['']), name, suffix)

# Emits a range of register values
def emit_range(prefix, name, range, suffix, direction):
    low, count = range
    high = low + count - 1
    reg_name = prefix_name(prefix, name, suffix)
    template = range_templates[direction]
    print template % locals()

def emit_constant(prefix, name, index, suffix):
    reg_name = prefix_name(prefix, name, suffix)
    print reg_template % locals()


class Generate(parse.register_defs.WalkParse):
    def walk_register_array(self, prefix, array):
        emit_range(prefix, array.name, array.range, 'REGS', 'to')

    def walk_field(self, prefix, field):
        if field.is_bit:
            emit_constant(prefix, field.name, field.range[0], 'BIT')
        else:
            emit_range(prefix, field.name, field.range, 'BITS', 'downto')

    def walk_register(self, prefix, register):
        suffix = 'REG'
        if register.overlaid:
            suffix += '_' + register.rw[:1]
        emit_constant(prefix, register.name, register.offset, suffix)
        self.walk_fields(prefix + [register.name], register)

    def walk_group(self, prefix, group):
        suffix = 'REGS' if prefix else 'REGS_RANGE'
        emit_range(prefix, group.name, group.range, suffix, 'to')
        self.walk_subgroups(prefix + [group.name], group)


def generate_list(walk, values):
    for value in values:
        print '    -- Definitions for %s' % value.name
        walk([], value)
        print

# Generates complete package definition
def generate_package(package, parse):
    generate = Generate()
    print head_template % package
    generate_list(generate.walk_register, parse.register_defs)
    generate_list(generate.walk_group, parse.group_defs)
    generate_list(generate.walk_group, parse.groups)
    print tail_template


if __name__ == '__main__':
    package = sys.argv[2] if len(sys.argv) > 2 else 'register_defs'
    indent = parse.indent.parse_file(file(sys.argv[1]))
    parse = parse.register_defs.parse(indent)
    generate_package(package, parse)
