# Simple LMBF test setup

import time

from driver import SYSTEM, CONTROL, DSP0, DSP1

import setup_pll
import setup_adc
import setup_dac



# Hardware initialisation
def setup_fmc500():
    setup_pll.setup_pll()
    time.sleep(0.1)         # Give the PLL time to lock
    setup_adc.setup_adc()
    setup_dac.setup_dac()


# Configure FIR for passthrough
def setup_fast_fir(group, taps):
    group.COMMAND.WRITE = 1
    group.TAPS = 0x7FFFFFFF
    for i in range(taps - 1):
        group.TAPS = 0

def setup_bunch_control(dsp, bunch_count):
    dsp.BUNCH.CONFIG.BANK = 0

    # Configure unity gain and FIR passthrough for all bunches
    setting = dsp.BUNCH.BANK._fields_wo
    setting.FIR_SELECT = 0
    setting.GAIN = 0x0FFF
    setting.FIR_ENABLE = 1
    setting.NCO0_ENABLE = 1
    setting.NCO1_ENABLE = 0
    for b in range(bunch_count):
        dsp.BUNCH.BANK = setting

def setup_bunch_fir(dsp, taps):
    dsp.FIR.CONFIG.BANK = 0
    dsp.FIR.TAPS = 0x7FFFFFFF
    for t in range(taps-1):
        dsp.FIR.TAPS = 0

def setup_dac_output(dsp):
    dsp.DAC.CONFIG.FIR_ENABLE = 1
    dsp.DAC.CONFIG.FIR_GAIN = 13


def setup_lmbf(bunch_count):
    setup_fmc500()

    # Configure revolution clock
    CONTROL.TRG.CONFIG.TURN.MAX_BUNCH = bunch_count - 1

    for dsp in [DSP0, DSP1]:
        setup_fast_fir(dsp.ADC, SYSTEM.INFO.ADC_TAPS)
        setup_fast_fir(dsp.DAC, SYSTEM.INFO.DAC_TAPS)
        setup_bunch_control(dsp, bunch_count)
        setup_bunch_fir(dsp, SYSTEM.INFO.BUNCH_TAPS)
        setup_dac_output(dsp)

    CONTROL.CONTROL.OUTPUT = 3


if __name__ == '__main__':
    setup_lmbf(936)
