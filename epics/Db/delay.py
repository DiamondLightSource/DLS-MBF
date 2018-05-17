# PVs for fine delay

from common import *

COARSE_LIMIT = 7


with name_prefix('DLY'):
    step_size = aIn('STEP_SIZE', PINI = 'YES', EGU = 'ps')

    with name_prefix('DAC'):
        # Fine delay control with readback
        fine_delay = longOut('FINE_DELAY', 0, 23,
            DESC = 'DAC clock fine delay')

        # Half step control
        half_step = boolOut('HALF_STEP', '0', '-0.5')

        # Simlarly coarse delay control with readback
        coarse_delay = longOut('COARSE_DELAY',
            DESC = 'DAC clock coarse delay')
        Action('STEP', FLNK = coarse_delay,
            DESC = 'Advance coarse delay')
        Action('RESET', FLNK = coarse_delay,
            DESC = 'Reset coarse delay')

        # Compute the overall delay
        delay_ps = records.calc('DELAY_PS',
            EGU  = 'ps', CALC = '(A-0.5*B)*C+D*E',
            INPA = coarse_delay,
            INPB = half_step,
            INPC = step_size,
            INPD = fine_delay,
            INPE = 25)
        coarse_delay.FLNK = delay_ps
        half_step.FLNK = delay_ps
        fine_delay.FLNK = delay_ps

        # Monitor of DAC FIFO
        longIn('FIFO', SCAN = '.2 second')
