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
import delay
import tune_pll
import nco

system.create_aggregate_pvs()

WriteRecords(sys.argv[1], Disclaimer(__file__))
