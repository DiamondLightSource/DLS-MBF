from defs_path import TOP, DEFS

import parse

def parsed_defs(warn = False, flatten = False):
    defs = parse.register_defs.parse(
        parse.indent.parse_file(file(DEFS), warn))
    if flatten:
        defs = parse.register_defs.flatten(defs)
    return defs
