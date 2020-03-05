# This file contains the appropriate library requires needed for python at DLS.

from pkg_resources import require, VersionConflict, DistributionNotFound

require('numpy>=1.11.1')
require('cothread>=2.14')
#require('epicsdbbuilder>=0.0')
