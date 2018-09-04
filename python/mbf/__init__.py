from defs_path import MBF_TOP, DEFS

import parse

def parsed_defs(warn = False, flatten = False):
    defs = parse.register_defs.parse_defs(
        parse.indent.parse_file(file(DEFS), warn))
    if flatten:
        defs = parse.register_defs.flatten(defs)
    return defs
