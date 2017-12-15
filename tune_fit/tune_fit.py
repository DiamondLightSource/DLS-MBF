# Tune fitting IOC

from pkg_resources import require
import sys, os
import re

require('cothread==2.14')
require('numpy==1.11.1')
require('epicsdbbuilder==1.2')

# Import the basic framework components.
from softioc import softioc, builder
import cothread
import fit_loop

from softioc import pvlog



# Start by loading the configuration file
config_lines = open(sys.argv[1]).readlines()
rule_expr = re.compile(r'^(?!#)([^= ]+) *= *(.*)\n')
config = dict([
    m.groups()
    for m in filter(None, map(rule_expr.match, config_lines))])

# Read the required configuration parameters
ioc_name = config['ioc_name']
sources = config['sources'].split()


# A couple of identification PVs
builder.SetDeviceName(ioc_name)
builder.stringIn('WHOAMI', VAL = 'Beam Current Lifetime Monitor')
builder.stringIn('HOSTNAME', VAL = os.uname()[1])
builder.UnsetDevice()


# Create the fitters
fitters = [fit_loop.TuneFitLoop(config, source) for source in sources]

# Now get the IOC started
builder.LoadDatabase()
softioc.iocInit()

# Finally run the fitters
for fitter in fitters:
    fitter.start()

softioc.interactive_ioc(globals())
