# All the programming here is derived from the documentation for the LMK04828
# clock controller from Texas Instruments.  The documentation reference is
# SNAS605 and the datasheet is avaliable at http://www.ti.com/lit/pdf/snas605
# Revision SNAS605AR dated December 2015 was used for this script.

from config_pll import SettingsBase, Const
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
    output.SDCLK_PD = 0         # Enable sysref clock

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

    output.DCLK_DDLY_PD = 0     # Enable dynamic digital delay


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
def setup_reclocked(pll):
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Configure outputs for FMC 500.

    # Output level definitions taken from Malibu Fmc_500_Mb.cpp, function
    # Fmc500_Pll::OnInit().
    pll.out0_1.SDCLK_FMT = Const.FMT_HSDS8      # S1  ADC SYNC
    pll.out2_3.DCLK_FMT  = Const.FMT_LVDS       # D2  FMC HB[9] (unused)
    pll.out2_3.SDCLK_FMT = Const.FMT_LVDS       # S3  FMC LA[19] (unused)
    pll.out4_5.DCLK_FMT  = Const.FMT_LVDS       # D4  DAC DACCLK
    pll.out6_7.DCLK_FMT  = Const.FMT_LVDS       # D6  DAC REFCLK
    pll.out10_11.DCLK_FMT = Const.FMT_HSDS8     # D10 J12 front panel
    pll.out12_13.SDCLK_FMT = Const.FMT_HSDS8    # S13 ADC CLK


    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Output configuration

    # Enable full delay control (fine delay, half step, digital delay) on all
    # our signals.

    # Put SYSREF on SDCLKout3.  This is routed through to DIO #5 when control
    # bit SYS.CONTROL.DIO_SEL_SDCLK = 1, used for SYSREF debugging
    sysref_output(pll.out2_3)

    # DAC clock on DCLKout4 with fully controllable output delay.  It seems that
    # the DAC analogue output is agile enough to cope with steps on this clock.
    delayed_output(pll.out4_5)

    # PLL internal feedback on DCLKout8.  Although the inner VCO loop cannot
    # unlock, the VCXO can if we move this too much, so we leave it alone.
    divided_output(pll.out8_9)

    # CLK OUT front panel connector on DCLKout10, fully controlled delay for
    # debug only.
    delayed_output(pll.out10_11)

    # ADC clock on SDCLKout13.  Unusually this output uses the SDCLK output pin,
    # but is otherwise a normal data clock.
    #    Note that any kind of dynamic delay on this clock output is unsafe, as
    # phase steps (even fine adjustments) can cause the FPGA PLL to unlock and
    # drop clock pulses.
    divided_output(pll.out12_13)
    pll.out12_13.SDCLK_MUX = 0      # Device clock on SD clock


    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # PLL setup.  This must be completed by calling setup_pll_ratios at end.  We
    # are configured to run in Nested 0-delay Dual Loop Mode (section 9.4.2,
    # figure 14, p.36 of SNAS703, figure 19, p.48 of SNAS605AR):
    #
    #   f_RF -- /R1 --|
    #                 | PD1 >-- VCXO -- /R2 --|
    #       +-- /N1 --|                       | PD2 >-- VCO --+-- /D --+-- f_RF
    #       |                       +-- /N2 --|               |        |
    #       |                       +-------------------------+        |
    #       +----------------------------------------------------------+
    #
    # See tools/find_freq for annotation of this figure.

    # PLL1 R (reference) input
    pll.CLKin0_EN = 0
    pll.CLKin1_EN = 1
    pll.CLKin0_OUT_MUX = 3      # Disable CLKin0 input
    pll.CLKin1_OUT_MUX = 2      # 500 MHz on CLKin1 routed to PLL1
    pll.CLKin_SEL_MODE = 1      # Use CLKin1 as PLL1 reference

    # PLL1 N (feedback) input from DCLKout8 for Nested 0-delay
    # For Nested 0-delay Dual Loop Mode we take the PLL1 feedback from the
    # DCLKout8 output.  This will ensure that our output phase has a fixed
    # relationship to our input clock.
    pll.FB_MUX_EN = 1           # Enable feedback mux and
    pll.FB_MUX = 1              # select DCLKout8 as feedback source
    pll.PLL1_NCLK_MUX = 1       # Use feedback mux for PLL1 feedback

    # PLL1 control.
    pll.PLL1_PD = 0             # Ensure PLL1 is operating
    pll.OSCin_PD = 0            # Enable OSCin from external VCXO
    pll.PLL1_CP_GAIN = 15       # 1.55 mA charge pump current (from CD Tool)

    # For PLL2 we have less choice once f1 has been determined, the only real
    # choice is between VCO0 running at 2.5GHz or VCO1 running at 3GHz.
    pll.OSCin_FREQ = 1          # OSCin running at 100 MHz (63 to 127 MHz)
    pll.PLL2_PD = 0             # Ensure PLL2 and
    pll.PLL2_PRE_PD = 0         #  prescaler are enabled
    pll.PLL2_REF_2X_EN = 1      # Enable frequency doubling on VCXO
    pll.PLL2_NCLK_MUX = 0       # Use direct output feedback

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # Set up for manual sync

    pll.SYNC_POL = 0
    pll.SYNC_MODE = 1
    pll.SYSREF_MUX = 0


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
def setup_pll_ratios(pll, n1r1, vco, d, p2, n2, r2):
    pll.CLKin1_R = n1r1
    pll.PLL1_N = n1r1

    pll.VCO_MUX = vco
    pll.PLL2_R = r2
    pll.PLL2_P = p2
    pll.PLL2_N = n2
    pll.PLL2_N_CAL = n2

    pll.out4_5.DCLK_DIV = d     # DAC CLK
    pll.out8_9.DCLK_DIV = d     # Feedback clock
    pll.out10_11.DCLK_DIV = d   # CLK OUT (front panel)
    pll.out12_13.DCLK_DIV = d   # ADC CLK

    # Set up dividers for phase advance for DAC, only.
    cntl = (d + 1) / 2
    cnth = d + 1 - cntl
    pll.out4_5.DCLK_DDLY_CNTL = cntl
    pll.out4_5.DCLK_DDLYd_CNTL = cntl
    pll.out4_5.DCLK_DDLY_CNTH = cnth
    pll.out4_5.DCLK_DDLYd_CNTH = cnth


# Simpler configuration where the input clock is passed unmodified to the four
# configured outputs.
def setup_passthrough(pll):
    # Pass CLKin1 straight through to internal clock distribution path
    pll.CLKin1_OUT_MUX = 0      # Route to Fin path
    pll.VCO_MUX = 2             # Route output from CLKin1
    pll.CLKin_OVERRIDE = 1      # Force use of selected clock input

    delayed_output(pll.out4_5)          # DAC
    pll.out4_5.DCLK_DIV = 1

    passthrough_output(pll.out10_11)    # Front panel

    passthrough_output(pll.out12_13)    # ADC
    pll.out12_13.SDCLK_MUX = 0  # Device clock on SD clock

    # Power down all the oscillator functions to reduce noise
    pll.PLL1_PD = 1
    pll.VCO_LDO_PD = 1
    pll.VCO_PD = 1
    pll.OSCin_PD = 1
    pll.SYSREF_GBL_PD = 1
    pll.SYSREF_PD = 1
    pll.SYSREF_DDLY_PD = 1
    pll.SYSREF_PLSR_PD = 1


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
    pll = SettingsBase(regs.PLL_SPI)
    if mode == 'Passthrough':
        setup_passthrough(pll)
    else:
        setup_reclocked(pll)
        setup_pll_ratios(pll, *decode_mode(mode))

    pll.write_config()
    time.sleep(0.01)        # Give the PLL time to lock
    return pll
