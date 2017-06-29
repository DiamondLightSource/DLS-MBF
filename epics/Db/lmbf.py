import sys

from common import *

import adc


# Version string from build
stringIn('VERSION', PINI = 'YES', DESC = 'LMBF version')
stringIn('FPGA_VERSION', PINI = 'YES', DESC = 'LMBF version')
stringIn('HOSTNAME', PINI = 'YES', DESC = 'Host name of LMBF IOC')

# Path to fast DRAM device for direct access (if on same machine)
Waveform('DRAM_NAME', 256,
    PINI = 'YES', FTVL = 'CHAR', DESC = 'Name of fast memory device')

WriteRecords(sys.argv[1], Disclaimer(__file__))
