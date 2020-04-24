# Pull in the local modules, we'll want them.

from . import indent
from . import register_defs

from .. import defs_path

def parsed_defs(warn = False, flatten = False):
    defs = register_defs.parse_defs(
        indent.parse_file(open(defs_path.DEFS), warn))
    if flatten:
        defs = register_defs.flatten(defs)
    return defs
