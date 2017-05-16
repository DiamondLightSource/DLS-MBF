# Generates C file using generated definitions

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

class GenerateMethods(parse.register_defs.WalkParse):
    def check_offset(self, field_name, offset):
        print
        print '    offset = offsetof(struct %s, %s);' % (
            self.top_name, field_name)
        print '    printf("offsetof(%s, %s) = %%d   ", offset);' % (
            self.top_name, field_name)
        print '    test_ok = offset == %d;' % (4 * offset)
        print '    printf("expected %d : %%s\\n", test_ok ? "OK" : "FAIL!");' \
            % (4 * offset)
        print '    if (!test_ok) failed += 1;'


    def walk_register_array(self, context, array):
        name = make_name(context, array.name)
        self.check_offset(name, array.range[0])

    def walk_register(self, context, register):
        name = make_name(context, register.name)
        self.check_offset(name, register.offset)

    def walk_overlay(self, context, overlay):
        for register in overlay.registers:
            self.walk_register(context, register)

    def walk_group(self, context, group):
        if group.definition:
            name = make_name(context, group.name)
            self.check_offset(name, group.range[0])
        else:
            self.walk_subgroups(context + [group.name], group)

    def walk_top(self, group):
        self.top_name = group.name.lower()
        self.walk_subgroups([], group)


generate = GenerateMethods()
defs = parse.register_defs.parse(parse.indent.parse_file(file(DEFS)))

print '''\
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>

#include "bitfield.h"

int main(int argc, char *argv[])
{
    size_t offset;
    bool test_ok;
    int failed = 0;
''',

for group in defs.group_defs:
    generate.walk_top(group)

for group in defs.groups:
    generate.walk_top(group)

print '''
    if (failed)
        printf("%d tests FAILED!\\n", failed);
    else
        printf("All tests OK\\n");
    return failed ? 1 : 0;
}'''
