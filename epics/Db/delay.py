# PVs for fine delay

from common import *

def make_fine_delay(target):
    fine_delay = longOut('FINE_DELAY', 0, 23,
        DESC = '%s clock fine delay' % target)
    fine_delay.FLNK = records.calc('FINE_DELAY_PS',
        EGU  = 'ps', CALC = 'A*B',   INPA = fine_delay,  INPB = 25)

with name_prefix('DLY'):
    with name_prefix('DAC'):
        make_fine_delay('DAC')
    with name_prefix('ADC'):
        make_fine_delay('ADC')
