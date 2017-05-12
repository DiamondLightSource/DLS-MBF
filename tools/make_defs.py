# Script to compute C definitions from register_defs

# Python path hacking, need to fix
import os
import sys

HERE = os.path.dirname(__file__)
TOP = os.path.abspath(os.path.join(HERE, '..'))
sys.path.append(os.path.join(TOP, 'AMC525/python'))
DEFS = os.path.join(TOP, 'AMC525/vhd/register_defs.in')

from parse import indent
from parse import register_defs
import parse


def make_name(context, name):
    return '_'.join(context + [name]).lower()


def make_field(indent, base, field):
    offset, length = field.range
    assert offset >= base, 'Overlapping or disordered fields'
    if offset > base:
        print indent + '    uint32_t : %d;' % (offset - base)
    print indent + '    uint32_t %s : %d;' % (field.name.lower(), length)
    return offset + length


def make_register_struct(indent, struct_name, fields, reg_name = '', rw = ''):
    print indent + 'struct %s {' % struct_name
    base = 0
    for field in fields:
        base = make_field(indent, base, field)
    if reg_name:
        print indent + '} %s;    // %s' % (reg_name, rw)
    else:
        print indent + '};'


class GenerateMethods(parse.register_defs.WalkParse):
    def walk_register_array(self, context, array):
        name = make_name(context, array.name)
        print '    uint32_t %s[%d];' % (name, array.range[1])

    def walk_register(self, context, register, indent = '    '):
        name = make_name(context, register.name)
        if register.definition:
            print indent + 'struct %s %s;    // %s' % (
                register.definition.name.lower(), name, register.rw)
        elif register.fields:
            struct_name = make_name([self.top_name] + context, register.name)
            make_register_struct(
                indent, struct_name, register.fields, name, register.rw)
        else:
            print indent + 'uint32_t %s;    // %s' % (name, register.rw)

    def walk_overlay(self, context, overlay):
        print '    union {'
        for register in overlay.registers:
            self.walk_register(context, register, indent = '        ')
        print '    };'

    def walk_group(self, context, group):
        if group.definition:
            name = make_name(context, group.name)
            print '    struct %s %s;' % (
                group.definition.name.lower(), name)
        else:
            self.walk_subgroups(context + [group.name], group)

    def walk_top(self, group):
        self.top_name = group.name.lower()
        print 'struct %s {' % group.name.lower()
        self.walk_subgroups([], group)
        print '};'


def print_doc(indent, doc):
    if doc:
        prefix = '/*'
        for line in doc:
            print indent + prefix + line
            prefix = ' *'
        print indent + ' */'


generate = GenerateMethods()
defs = parse.register_defs.parse(parse.indent.parse_file(file(DEFS)))

print '''\
/* DO NOT EDIT THIS FILE !!!
 *
 * This file has been automatically generated.
 * To change this file edit the source file and rebuild.
 */
'''

print '/* Shared structure definitions. */'
print
for group in defs.group_defs:
    print_doc('', group.doc)
    generate.walk_top(group)
    print

for register in defs.register_defs:
    print_doc('', register.doc)
    make_register_struct('', register.name.lower(), register.fields)
    print

print

for group in defs.groups:
    print_doc('', group.doc)
    generate.walk_top(group)
    print