# This file contains the appropriate library requires needed for python at DLS.

from pkg_resources import require, VersionConflict, DistributionNotFound

try:
#     require('numpy==1.11.1')
    require('cothread==2.14')
    require('epicsdbbuilder==1.2')

except (VersionConflict, DistributionNotFound) as e:
    # The following extremely dirty code is used to automatically switch to the
    # correct (DLS specific) version of python if any of the requires above
    # fail.
    import sys, os
    if os.path.split(sys.executable)[1] == 'dls-python':
        # Make sure that we don't end up in an endless loop repeatedly trying to
        # run dls-python
        raise e
    else:
        os.execvp('dls-python', ['dls-python'] + sys.argv)
