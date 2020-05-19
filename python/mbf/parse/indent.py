# This file exports this function:
#   parse_indented_file(file_name) -> list of parsed indented sections
#
# The data structure returned can be described as a list of Parse values, where
# a Parse is a pair consisting of a parsed line, a list of sub-parses,
# documentation lines, and finally the input line number for reporting:
#
#   type FileParse = [Parse]
#   type Parse = Parse(Line, [Parse], [Line], LineNo)
#
# For example, a file containing the following lines:
#
#   a
#       # doc
#       b
#           c
#       d
#
# will return the following parse:
#
#   [
#       Parse(line = 'a', body = [
#           Parse(line = 'b', body = [
#               Parse(line = 'c', body = [], doc = [], line_no = 4),
#           ], doc = [' doc'], line_no = 3),
#           Parse(line = 'd', body = [], doc = [], line_no = 5),
#       ], doc = [], line_no = 1)
#   ]

from __future__ import print_function

import sys
from collections import namedtuple


Parse = namedtuple('Parse', ['line', 'body', 'doc', 'line_no'])


class read_lines:
    # Line classification
    EOF = 0         # End of file
    BLANK = 1       # Blank line, used for comment separation
    COMMENT = 2     # Documentation line
    LINE = 3        # Body line

    def __init__(self, input, warn):
        self.__input = input
        self.__undo = False
        self.__result = ()
        self.__warn = warn
        self.line_no = 0


    def fail(self, message):
        print('Error: %s on line %d' % (message, self.line_no),
            file = sys.stderr)
        sys.exit(1)

    def warn(self, message):
        if self.__warn:
            print('Warning: %s on line %d' % (message, self.line_no),
                file = sys.stderr)


    def __read_line(self):
        line = self.__input.readline()
        self.line_no += 1
        if line:
            if line[-1] != '\n':
                self.fail('Missing newline at end of file')
            content = line.lstrip(' ')
            if content == '\n':
                return (self.BLANK, 0, '')
            else:
                indent = len(line) - len(content)
                if content.startswith('##'):
                    return None
                elif content.startswith('#'):
                    return (self.COMMENT, indent, content[1:-1])
                else:
                    return (self.LINE, indent, content[:-1])
        else:
            return (self.EOF, 0, '')

    def __fill(self, undo):
        if not self.__undo:
            while True:
                self.__result = self.__read_line()
                if self.__result:
                    break
        self.__undo = undo
        return self.__result

    def read_line(self):
        return self.__fill(False)

    def lookahead(self):
        return self.__fill(True)

    def undo(self):
        self.__undo = True


# First gather together any comments with the correct indent as a documentation
# block.  We allow a blank line to discard comments so we can also have true
# comments.
def parse_comments(input, indent):
    comments = []
    while True:
        token, new_indent, line = input.read_line()

        if token == input.BLANK:
            if comments:
                input.warn('Discarding inline comments')
            comments = []
        elif token == input.COMMENT:
            if indent != new_indent:
                input.fail('Bad comment indentation')
            if line and line[0] == '#':
                # Discard all lines with ## comment prefix; these act as true
                # comments rather than documentation lines.
                pass
            else:
                comments.append(line)
        else:
            input.undo()
            return comments


def parse_line(input, indent):
    comments = parse_comments(input, indent)
    token, new_indent, line = input.read_line()
    line_no = input.line_no

    if token == input.EOF:
        if comments:
            input.warn('Discarding comments at end of file')
        return None
    else:
        assert token == input.LINE
        if new_indent != indent:
            input.fail('Invalid identation')

        sub_lines = parse_sub_lines(input, indent)
        return Parse(line, sub_lines, comments, line_no)


def find_new_indent(input):
    while True:
        token, indent, _ = input.read_line()
        if token == input.EOF:
            return 0
        elif token != input.BLANK:
            input.undo()
            return indent


def parse_sub_lines(input, indent):
    lines = []
    new_indent = find_new_indent(input)
    if new_indent > indent:
        indent = new_indent
        while True:
            line = parse_line(input, indent)
            if line:
                lines.append(line)
            else:
                break
            _, new_indent, _ = input.lookahead()
            if new_indent > indent:
                input.fail('Invalid indentation')
            elif new_indent < indent:
                break
    return lines


def parse_file(input, warn = True):
    return parse_sub_lines(read_lines(input, warn), -1)


def print_parse(prefix, parse):
    for line, body, doc, line_no in parse:
        for c in doc:
            print('     %s#%s' % (prefix, c))
        print('% 4d %s%s' % (line_no, prefix, line))
        print_parse(prefix + '    ', body)


if __name__ == '__main__':
    input = file(sys.argv[1])
    parse = parse_file(input)
    print_parse('', parse)
