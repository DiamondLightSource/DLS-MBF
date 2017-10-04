# Sphinx extension for generating register documentation

import os

from docutils import nodes, statemachine
from docutils.parsers import rst

import lmbf


def trim_text(text):
    return [s[1:] for s in text]

def format_name(entity, prefix = ''):
    if prefix:
        name = '.'.join(prefix + [entity.name])
    else:
        name = entity.name
    return ['``%s``' % name]

def format_range(range, bits = False):
    start, length = range
    if length > 1:
        if bits:
            return '%d:%d' % (start + length - 1, start)
        else:
            return '%d-%d' % (start, start + length - 1)
    else:
        return '%d' % start


class GenerateMethods(lmbf.parse.register_defs.WalkParse):
    def __init__(self, table):
        self.table = table

    def walk_field(self, context, field):
        self.table.add_row(
            [[format_range(field.range, True)],
             format_name(field), trim_text(field.doc)])

    def walk_register_array(self, context, array):
        self.table.add_row(
            [[format_range(array.range)],
             [array.rw], format_name(array, context)],
            more_cols = [0, 0, 2], more_rows = [1, 1, 0])
        self.table.add_row([trim_text(array.doc)], more_cols = [2])

    def walk_register(self, context, register, overlay = False):
        row_count = len(register.fields)
        if register.doc:
            row_count += 1

        if overlay:
            self.table.add_row(
                [[], ['%d' % register.offset], format_name(register)],
                more_cols = [0, 0, 2],
                more_rows = [row_count, row_count, 0])
        else:
            self.table.add_row(
                [['%d' % register.offset],
                 [register.rw], format_name(register, context)],
                more_cols = [0, 0, 2],
                more_rows = [row_count, row_count, 0])
        if register.doc:
            self.table.add_row(
                [trim_text(register.doc)], more_cols = [2])
        self.walk_fields(context, register)

    def walk_group(self, context, group):
        if group.doc and context:
            self.table.add_row(
                [[format_range(group.range)],
                 trim_text(group.doc)],
                more_cols = [0, 3])
        self.walk_subgroups(context + [group.name], group)

    def walk_rw_pair(self, context, rw_pair):
        for register in rw_pair.registers:
            self.walk_register(context, register)

    def walk_overlay(self, context, overlay):
        self.table.add_row(
            [['%d' % overlay.offset], [overlay.rw],
             format_name(overlay, context)],
            more_cols = [0, 0, 2],
            more_rows = [1, 1, 0])
        self.table.add_row([trim_text(overlay.doc)], more_cols = [2])
        for register in overlay.registers:
            self.walk_register(context, register, overlay = True)

    def walk_union(self, context, union):
        if union.doc:
            start, length = union.range
            self.table.add_row(
                [[format_range(union.range)],
                 trim_text(union.doc)],
                more_cols = [0, 3])
        self.walk_subgroups(context, union)



# Helper class for building a table
#
#   A table node has the following structure:
#       table
#       +-- tgroup
#           +-- colspec             *(number of columns)
#           +-- thead
#           |   +-- row             *(number of header rows)
#           |       +-- entry       *(number of active columns)
#           |           +-- text
#           +-- tbody
#               +-- row             *(number of table rows)
#                   ...
# Note that the number of active columns is affected by morecols and morerows.
class Table:
    def __init__(self, parent, col_widths):
        self.parent = parent
        self.table = nodes.table()

        # Specify the columns
        tgroup = nodes.tgroup(cols = len(col_widths))
        self.table += tgroup
        for width in col_widths:
            tgroup += nodes.colspec(colwidth = width)

        # Create header and body
        self.thead = nodes.thead()
        tgroup += self.thead
        self.tbody = nodes.tbody()
        tgroup += self.tbody


    def add_header(self, data, **kargs):
        self.thead += self.__make_table_row(data, **kargs)

    def add_row(self, data, **kargs):
        self.tbody += self.__make_table_row(data, **kargs)


    def __make_table_row(self, data, more_cols = None, more_rows = None):
        if more_cols is None:
            more_cols = [0 for x in data]
        if more_rows is None:
            more_rows = [0 for x in data]

        row = nodes.row()
        for text, more_col, more_row in zip(data, more_cols, more_rows):
            entry = nodes.entry()
            if more_col:
                entry["morecols"] = more_col
            if more_row:
                entry["morerows"] = more_row
            row += entry
            entry += self.parent.parse_text(text)
        return row



# This directive loads the given register definitions file into memory.
class register_docs_file(rst.Directive):
    option_spec = {
        'file' : str,
    }

    def run(self):
        filename = self.options['file']

        global register_groups, group_defs, register_defs
        register_groups, group_defs, register_defs = \
            self.load_groups(filename)

        return []

    def list_to_dict(self, list):
        result = {}
        for l in list:
            result[l.name] = l
        return result

    def load_groups(self, filename):
        full_filename = os.path.join(lmbf.TOP, filename)
        defs = lmbf.parse.register_defs.parse(
            lmbf.parse.indent.parse_file(file(full_filename)))
        defs = lmbf.parse.register_defs.flatten(defs)
        groups = self.list_to_dict(defs.groups)
        group_defs = self.list_to_dict(defs.group_defs)
        register_defs = self.list_to_dict(defs.register_defs)
        return groups, group_defs, register_defs

register_groups = {}


class register_docs(rst.Directive):
    option_spec = {
        'section' : str,
        'group' : str,
        'register' : str,
    }


    def lookup_option(self):
        if 'section' in self.options:
            return (register_groups[self.options['section']], True)
        elif 'group' in self.options:
            return (group_defs[self.options['group']], True)
        elif 'register' in self.options:
            return (register_defs[self.options['register']], False)

    def run(self):
        definition, is_group = self.lookup_option()

        header = self.doc_text(definition)

        table = Table(self, [11, 9, 11, 25, 80])
        table.add_header(
            [['Reg'], [], ['Field'], ['Name'], ['Description']])
        methods = GenerateMethods(table)
        if is_group:
            methods.walk_group([], definition)
        else:
            methods.walk_register([], definition)

        return header + [table.table]

    def doc_text(self, entity):
        text = [s[1:] for s in entity.doc]
        return self.parse_text(text)

    # This dance appears to be how we parse arbitrary RST text.  Note that the
    # Element is just a placeholder for doing the parse, and in fact we return
    # the list of children from the parse.
    def parse_text(self, text):
        text = statemachine.ViewList(initlist = text)
        node = nodes.Element()
        self.state.nested_parse(text, self.content_offset, node)
        return node.children

    def create_table(self):
        col_widths = [1, 2, 3, 4]
        table = Table(self, col_widths)

        table.add_header(test_line)

        table.add_row(test_line)
        table.add_row(test_line[:2])
        table.add_row(
            [['short'], paragraph_text, long_text],
            more_rows = [0, 1, 0], more_cols = [0, 1, 0])
        table.add_row([['one'], ['two']])
        table.add_row(
            test_line[1:], more_cols = [1, 0, 0])
        table.add_row(
            test_line[0:2] + [compound_table, paragraph_text])
        return table.table


rst.directives.register_directive('register_docs_file', register_docs_file)
rst.directives.register_directive('register_docs', register_docs)
