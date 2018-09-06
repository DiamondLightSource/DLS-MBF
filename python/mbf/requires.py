# Imports appropriate Python requirements definitions from SITE directory

import os.path

from mbf import defs_path

requires_file = os.path.join(defs_path.SITE_DIR, 'requires.py')
if os.path.isfile(requires_file):
    execfile(requires_file)
