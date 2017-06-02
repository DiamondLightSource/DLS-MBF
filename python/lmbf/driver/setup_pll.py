# All the programming here is derived from the documentation for the LMK04828
# clock controller from Texas Instruments.  The documentation reference is
# SNAS605 and the datasheet is avaliable at http://www.ti.com/lit/pdf/snas605
# Revision SNAS605AR dated December 2015 was used for this script.

from config_pll import SettingsBase

from driver import PLL_SPI as PLL


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# Simple setup with input clock directly exported as system clock
class SysclkSetup(SettingsBase):
    SettingsBase.create_outputs(locals())

    # Configure SDCLKout3 with a copy of SYSREF
    out2_3.CLK_PD = 0           # Enable clock group
    out2_3.SDCLK_PD = 0         # and enable SDCLK
    out2_3.SDCLK_MUX = 1        # Output SYSREF to SDCLK

    # Route 100MHz input from CLKin0 to SYSREF clocking chain
    CLKin0_OUT_MUX = 0          # CLIin0 to SYSREF mux
    SYSREF_CLKin0_MUX = 1       # CLKin0 (100MHz) input
    SYSREF_PD = 0               # Enable sysref
    SYNC_EN = 1                 # Enable SYNC (needed for SYSREF)
    SYSREF_CLR = 0              # Take SYSREF out of reset

# SysclkSetup().write_config(PLL)
# sys.exit()



# The following clock connections are configured and used:
#
#   DCLKout4    => DAC CLK
#   DCLKout8    => (internal clock feedback for PLL)
#   DCLKout10   => Front panel connector
#   SDCLKout13  => ADC CLK
#
# The following clock connections are wired but are left unused:
#
#   SDCLKout1   => ADC SYNC (not used)
#   DCLKout2    => FPGA (not used)
#   SDCLKout3   => FPGA (not used)
#   DCLKout6    => DAC REFCLK (not used?)
#
class Settings(SettingsBase):
    SettingsBase.create_outputs(locals())

    # DAC clock
    out4_5.CLK_PD = 0
    out4_5.DCLK_DIV = 5
    out4_5.DCLK_MUX = 0

    out6_7.CLK_PD = 0
    out6_7.DCLK_DIV = 10
    out6_7.DCLK_MUX = 0

    # Internal feedback for PLLs on DCLKout8
    out8_9.CLK_PD = 0
    out8_9.DCLK_DIV = 5         # Reduce VCO = 2.5G to 500 MHz output
    out8_9.DCLK_MUX = 3         # Allow analogue delay
    out8_9.DCLK_ADLY_PD = 0     # Enable analogue delay and
    out8_9.DCLK_ADLYg_PD = 0    # glitchless control
    out8_9.DCLK_ADLY = 0        # Start with 0ps (extra) delay

    # Front panel connector on DCLKout10
    out10_11.CLK_PD = 0
    out10_11.DCLK_DIV = 5
    out10_11.DCLK_MUX = 0
#     out10_11.DCLK_MUX = 3       # Allow analogue delay
#     out10_11.DCLK_ADLY_PD = 0   # Enable analogue delay and
#     out10_11.DCLK_ADLYg_PD = 0  # glitchless control
#     out10_11.DCLK_ADLY = 0      # Start with 0ps (extra) delay
#     # Enable dynamic digital delay on this output
#     out10_11.DCLK_DDLY_PD = 0
#     out10_11.DCLK_DDLY_CNTH = 3 # Settings for one step delay
#     out10_11.DCLK_DDLY_CNTL = 3
#     DDLYd10_EN = 1

    # ADC clock on SDCLKout13
    out12_13.CLK_PD = 0
    out12_13.DCLK_DIV = 5
    out12_13.DCLK_MUX = 0
    out12_13.SDCLK_MUX = 0


    SYSREF_CLR = 0              # Take SYSREF out of reset
    SYNC_EN = 0


    # We run the clock controller in Nested 0-delay Dual Loop mode: this means
    # that the regenerated RF output clock is used as feedback to the input:
    #
    #   f_RF -- /R1 --|
    #                 | PD1 >-- VCXO -- /R2 --|
    #       +-- /N1 --|                       | PD2 >-- VCO --+-- /D --+-- f_RF
    #       |                       +-- /N2 --|               |        |
    #       |                       +-------------------------+        |
    #       +----------------------------------------------------------+
    #
    # The governing equations of the system above (put f_in = f_RF, f_out =
    # regenerated f_RF, f1 = VCXO frequency, f2 = VCO frequency, d1 = first
    # Phase Detector frequency, d2 = second Phase Detector frequency) are:
    #
    #   (1)     d1 = f_in / R1 = f_out / N1
    #   (2)     d2 = f1 / R2 = f2 / N2
    #   (3)     f_out = f2 / D
    #
    # Our operating constraints are quite tight:
    #
    #   (4)     f_in = f_out = 499.655 to 499.681 MHz
    #   (5)     f1 = 100 MHz +-10 kHz
    #   (6)     f2 = 2.4 to 2.6 GHz or 2.9 to 3.1 GHz (VCO0 or VCO1)
    #   (7)     d1 < 40 MHz, d2 < 155 MHz but otherwise as large as possible.
    #
    # From (1, 4) we get R1 = N1 and from (7) we get N1, R1 >= 13.  From (3, 6)
    # we have D = 5 or 6 (depending on choice of VCO), and from the remaining
    # constraints and equations we have
    #
    #       N2 / R2 = D * f_in / 100 MHz ~= 24.983 or 29.979
    #
    # We want R2 to be as small as possible, as this determines d2 = f1/R2, and
    # there is also the constraint that N2 must be divisible by a small prime
    # (2, 3, 5, or 7).  Examining the candidates we find:
    #
    #   N2 = 1524, R2 = 61 => f2 = 2498 MHz => f_out = 499.672 MHz
    #
    # This gives us an accessible range 499.622 to 499.722 MHz.  Our nominal
    # operating points are 499.656 (pre DDBA) and 499.681 (post DBA).

    # PLL1 R (reference) input, RF clock at 499.97 MHz
    CLKin0_EN = 0
    CLKin1_EN = 1
    CLKin0_OUT_MUX = 3
    CLKin1_OUT_MUX = 2      # 500 MHz on CLKin1 routed to PLL1
    CLKin_SEL_MODE = 1      # Use CLKin1 as PLL1 reference
    CLKin1_R = 30           # PDF1 = 500 / 15 = 33 +1/3 MHz

    # PLL1 N (feedback) input from DCLKout8 for Nested 0-delay
    # For Nested 0-delay Dual Loop Mode we take the PLL1 feedback from the
    # DCLKout8 output.  This will ensure that our output phase has a fixed
    # relationship to our input clock.
    FB_MUX_EN = 1           # Enable feedback mux and
    FB_MUX = 1              # select DCLKout8 as feedback source
    PLL1_NCLK_MUX = 1       # Use feedback mux for PLL1 feedback
    PLL1_N = 30             # PDF1 = 500 / 15 = 33 +1/3 MHz

    # PLL1 control.
    PLL1_PD = 0                 # Ensure PLL1 is operating
    OSCin_PD = 0                # Enable OSCin from external VCXO
    PLL1_CP_GAIN = 15           # 1.55 mA charge pump current (from CD Tool)


    # For PLL2 we have less choice once f1 has been determined, the only real
    # choice is between VCO0 running at 2.5GHz or VCO1 running at 3GHz.
    VCO_MUX = 0                 # Use VCO0 running at 2.5GHz
    OSCin_FREQ = 1              # OSCin running at 100 MHz (63 to 127 MHz)
    PLL2_PD = 0                 # Ensure PLL2 and
    PLL2_PRE_PD = 0             #  prescaler are enabled

    # PLL2 reference R
    PLL2_REF_2X_EN = 0          # No frequency doubling on f1
    PLL2_R = 61                 # PDF2 = f1
    PLL2_R = 59
    PLL2_R = 2*59

    # PLL2 feedback N
    PLL2_NCLK_MUX = 0           # Use direct output feedback
    PLL2_P = 4                  # Feedback N with prescale is 30 for PDF2
    PLL2_N = 381                # equal to to f1
    PLL2_N_CAL = 381

    PLL2_P = 2
    PLL2_P = 4
    PLL2_N = 737
    PLL2_N_CAL = 737


    # Publish lock state of the two PLLs on the Status_LD{1,2} pins
    PLL1_LD_MUX = 1             # PLL1 DLD (Digital lock detect)
    PLL2_LD_MUX = 2             # PLL2 DLD (Digital lock detect)

    HOLDOVER_EN = 0
    CLKin_OVERRIDE = 1          # Force use of selected clock input

    PLL2_LF_R4 = 4
    PLL2_LF_R3 = 4
    PLL2_LF_C4 = 13
    PLL2_LF_C3 = 13
    PLL2_LF_R4 = 2
    PLL2_LF_R3 = 2
    PLL2_LF_C4 = 6
    PLL2_LF_C3 = 6




# To bypass all the above and pass CLKin1 straight through to clock path:
#     CLKin1_OUT_MUX = 0          # Fin internal path
#     VCO_MUX = 2                 # Use CLKin1 as output
#     out4_5.DCLK_MUX = 2
#     out4_5.DCLK_DIV = 1
#     out10_11.DCLK_MUX = 2
#     out10_11.DCLK_DIV = 1
#     out12_13.DCLK_MUX = 2
#     out12_13.DCLK_DIV = 1


def setup_pll():
    s = Settings(PLL)
    s.write_config()


if __name__ == '__main__':
    setup_pll()