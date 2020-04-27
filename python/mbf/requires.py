# Imports appropriate Python requirements definitions from SITE directory

import os.path

from mbf import defs_path

requires_file = os.path.join(defs_path.SITE_DIR, 'requires.py')
if os.path.isfile(requires_file):
    # This will define require() which may be used to add further unversioned
    # required.  All versioned requires need to be explictly listed in
    # versions.py
    exec(open(requires_file).read())

else:
    # If no requires.py then create a dummy no-op require() function.
    def require(*requirements):
        pass
