from common import *

import system
import adc
import dac
import bunch_fir
import bunch_select
import sequencer
import detector
import memory
import triggers

system.create_aggregate_pvs()

WriteRecords(sys.argv[1], Disclaimer(__file__))