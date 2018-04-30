# All the programming here is derived from the documentation for the LMK04828
# clock controller from Texas Instruments.  The documentation reference is
# SNAS605 and the datasheet is avaliable at http://www.ti.com/lit/pdf/snas605
# Revision SNAS605AR dated December 2015 was used for this script.

from config_pll import SettingsBase
import time


# PLL ratios for different frequencies.  These are designed to be passed through
# to Settings.setup_pll_ratios().
#
#   N1/R1   This should be the ceiling of f_RF / 40 MHz
#   VCO     Choose between VCO 0 and VCO 1
#   D       Divisor for VCO output
#   P2      VCO PLL2 prescaler, in range 2..7
#   N2      Feedback factor from output
#   R2      Feedback factor from VCXO
#
# Note that
#   D * f_RF = f_VCO
#   R2 * f_VCO = P2 * N2 * 200 MHz
#
# Use tools/find_freq to find a list of candidate values.
PLL_ratios = {
    # name        N1/R1 VCO D   P2  N2      R2
    '499_682' : ( 13,   0,  5,  2,  381,    61 ),   # DLS (post DDBA)
    '352_202' : ( 9,    0,  7,  2,  339,    55 ),   # ESRF (pre upgrade)
    '352_372' : ( 9,    0,  7,  2,  37,     6 ),    # ESRF-EBS (post upgrade)
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


def divided_output(output):
    output.CLK_PD = 0           # Enable output
    output.DCLK_MUX = 0         # Divider only

def sysref_output(output):
    output.CLK_PD = 0
    output.SDCLK_MUX = 1        # Output SYSREF
    output.SDCLK_PD = 0

def passthrough_output(output):
    output.CLK_PD = 0           # Enable output group
    output.DCLK_MUX = 2         # Bypass all divide and delay

def delayed_output(output):
    output.CLK_PD = 0           # Enable output
    output.DCLK_MUX = 3         # Allow analogue delay

    output.DCLK_ADLY_PD = 0     # Enable analogue delay and
    output.DCLK_ADLYg_PD = 0    # glitchless control
    output.DCLK_ADLY = 0        # Start with 0ps (extra) delay
    output.DCLK_ADLY_MUX = 1    # Enable duty cycle correction in divide


# The following clock connections are configured and used:
#
#   SDCLKout3   => FPGA => DIO #5 (optionally, for SCLK debugging)
#   DCLKout4    => DAC CLK
#   DCLKout8    => (internal clock feedback for PLL)
#   DCLKout10   => CLK OUT front panel connector
#   SDCLKout13  => ADC CLK
#
# The following clock connections are wired but are left unused:
#
#   SDCLKout1   => ADC SYNC (not used)
#   DCLKout2    => FPGA (not used)
#   DCLKout6    => DAC REFCLK (not used)
#
# The following clock connections go to the AMC525 clocking network and are not
# used:
#
#   DCLKout0    => CLK1_M2C
#   DCLKout12   => CLK0_M2C
#
class Settings(SettingsBase):
    SettingsBase.create_outputs(locals())

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Output configuration

    # Put SYSREF on SDCLKout3.  This is routed through to DIO #5 when control
    # bit SYS.CONTROL.DIO_SEL_SDCLK = 1, used for SYSREF debugging
    sysref_output(out2_3)

    # DAC clock on DCLKout4 with fully controllable output delay
    delayed_output(out4_5)

    # PLL internal feedback on DCLKout8
    divided_output(out8_9)

    # Front panel connector on DCLKout10
    delayed_output(out10_11)

    # ADC clock on SDCLKout13.  Unusually this output uses the SDCLK output pin,
    # but is otherwise a normal data clock.
    divided_output(out12_13)
    out12_13.SDCLK_MUX = 0      # Device clock on SD clock


    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # PLL setup.  This must be completed by calling setup_pll_ratios at end.

    # PLL1 R (reference) input
    CLKin0_EN = 0
    CLKin1_EN = 1
    CLKin0_OUT_MUX = 3
    CLKin1_OUT_MUX = 2      # 500 MHz on CLKin1 routed to PLL1
    CLKin_SEL_MODE = 1      # Use CLKin1 as PLL1 reference

    # PLL1 N (feedback) input from DCLKout8 for Nested 0-delay
    # For Nested 0-delay Dual Loop Mode we take the PLL1 feedback from the
    # DCLKout8 output.  This will ensure that our output phase has a fixed
    # relationship to our input clock.
    FB_MUX_EN = 1           # Enable feedback mux and
    FB_MUX = 1              # select DCLKout8 as feedback source
    PLL1_NCLK_MUX = 1       # Use feedback mux for PLL1 feedback

    # PLL1 control.
    PLL1_PD = 0             # Ensure PLL1 is operating
    OSCin_PD = 0            # Enable OSCin from external VCXO
    PLL1_CP_GAIN = 15       # 1.55 mA charge pump current (from CD Tool)

    # For PLL2 we have less choice once f1 has been determined, the only real
    # choice is between VCO0 running at 2.5GHz or VCO1 running at 3GHz.
    OSCin_FREQ = 1          # OSCin running at 100 MHz (63 to 127 MHz)
    PLL2_PD = 0             # Ensure PLL2 and
    PLL2_PRE_PD = 0         #  prescaler are enabled
    PLL2_REF_2X_EN = 1      # Enable frequency doubling on VCXO
    PLL2_NCLK_MUX = 0       # Use direct output feedback


    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Remaining state

    CLKin_OVERRIDE = 1      # Force use of selected clock input


    # This sets up the given PLL ratios.  The basic parameters are:
    #
    #   n1r1    N1 = D1, inputs to VCXO phase detector
    #   vco     VCO mux selector
    #   d       VCO output divider
    #   p2      VCO output frequency prescale divider
    #   n2      VCO feedback divider
    #   r2      VCO reference divider
    #
    # This must be called before writing the PLL configuration as otherwise the
    # appropriate dividers will not be configured.
    def setup_pll_ratios(self, n1r1, vco, d, p2, n2, r2):
        self.CLKin1_R = n1r1
        self.PLL1_N = n1r1

        self.VCO_MUX = vco
        self.PLL2_R = r2
        self.PLL2_P = p2
        self.PLL2_N = n2
        self.PLL2_N_CAL = n2

        self.out4_5.DCLK_DIV = d    # DAC CLK
        self.out8_9.DCLK_DIV = d    # Feedback clock
        self.out10_11.DCLK_DIV = d  # CLK OUT (front panel)
        self.out12_13.DCLK_DIV = d  # ADC CLK


# Simpler configuration where the input clock is passed unmodified to the four
# configured outputs.
class Passthrough(SettingsBase):
    SettingsBase.create_outputs(locals())

    # Pass CLKin1 straight through to internal clock distribution path
    CLKin1_OUT_MUX = 0      # Route to Fin path
    VCO_MUX = 2             # Route output from CLKin1
    CLKin_OVERRIDE = 1      # Force use of selected clock input

    delayed_output(out4_5)  # DAC
    out4_5.DCLK_DIV = 1

    passthrough_output(out10_11)    # Front panel

    passthrough_output(out12_13)    # ADC
    out12_13.SDCLK_MUX = 0  # Device clock on SD clock

    # Power down all the oscillator functions to reduce noise
    PLL1_PD = 1
    VCO_LDO_PD = 1
    VCO_PD = 1
    OSCin_PD = 1
    SYSREF_GBL_PD = 1
    SYSREF_PD = 1
    SYSREF_DDLY_PD = 1
    SYDREF_PLSR_PD = 1


# The mode string is allowed to be either a name or a list of numbers separated
# by spaces, corresponding to the arguments to setup_pll_ratios above.
def decode_mode(mode):
    array = mode.split()
    if len(array) == 1:
        return PLL_ratios[mode]
    else:
        return map(int, array)


def setup_pll(regs, mode):
    print 'Setting clock mode', mode
    if mode == 'Passthrough':
        s = Passthrough(regs.PLL_SPI)
    else:
        s = Settings(regs.PLL_SPI)
        s.setup_pll_ratios(*decode_mode(mode))

    s.write_config()
    time.sleep(0.01)        # Give the PLL time to lock
    return s
