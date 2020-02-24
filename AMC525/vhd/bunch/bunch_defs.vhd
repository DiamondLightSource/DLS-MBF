-- Definitions for bunch selection

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;

package bunch_defs is
    -- All bunch gains are scaled as 4.14 values
    constant BUNCH_GAIN_BITS : natural := 18;
    subtype bunch_gain_t is signed(BUNCH_GAIN_BITS-1 downto 0);

    -- Bunch configuration
    -- This needs to match the register definition for DSP.BUNCH.BANK
    type bunch_config_t is record
        -- Selects FIR filter
        fir_select : unsigned(FIR_BANK_BITS-1 downto 0);
        -- Output enables
        fir_enable : std_ulogic;
        fir_gain : bunch_gain_t;
        nco0_gain : bunch_gain_t;
        nco1_gain : bunch_gain_t;
        nco2_gain : bunch_gain_t;
        nco3_gain : bunch_gain_t;
    end record;

    constant BUNCH_CONFIG_BITS : natural :=
        FIR_BANK_BITS + 5 * BUNCH_GAIN_BITS + 1;
    subtype bunch_config_bits_t is
        std_ulogic_vector(BUNCH_CONFIG_BITS-1 downto 0);

    function to_bunch_config_t(bits : std_ulogic_vector) return bunch_config_t;
    function from_bunch_config_t(config : bunch_config_t)
        return bunch_config_bits_t;
end;

package body bunch_defs is
    function to_bunch_config_t(bits : std_ulogic_vector) return bunch_config_t
    is
        variable word0 : std_ulogic_vector(31 downto 0);
        variable word1 : std_ulogic_vector(31 downto 0);
        variable word2 : std_ulogic_vector(28 downto 0);

    begin
        word0 := bits(31 downto 0);
        word1 := bits(63 downto 32);
        word2 := bits(92 downto 64);
        return (
            fir_select => unsigned(word2(DSP_BUNCH_BANK_EXTRA_FIR_SELECT_BITS)),
            fir_enable => word2(DSP_BUNCH_BANK_EXTRA_FIR_ENABLE_BIT),
            fir_gain => signed(word2(DSP_BUNCH_BANK_EXTRA_FIR_GAIN_BITS)),
            nco0_gain =>
                signed(word0(DSP_BUNCH_BANK_NCO01_NCO0_HIGH_BITS)) &
                signed(word2(DSP_BUNCH_BANK_EXTRA_NCO0_LOW_BITS)),
            nco1_gain =>
                signed(word0(DSP_BUNCH_BANK_NCO01_NCO1_HIGH_BITS)) &
                signed(word2(DSP_BUNCH_BANK_EXTRA_NCO1_LOW_BITS)),
            nco2_gain =>
                signed(word1(DSP_BUNCH_BANK_NCO23_NCO2_HIGH_BITS)) &
                signed(word2(DSP_BUNCH_BANK_EXTRA_NCO2_LOW_BITS)),
            nco3_gain =>
                signed(word1(DSP_BUNCH_BANK_NCO23_NCO3_HIGH_BITS)) &
                signed(word2(DSP_BUNCH_BANK_EXTRA_NCO3_LOW_BITS)));
    end;

    function from_bunch_config_t(config : bunch_config_t)
        return bunch_config_bits_t
    is
        variable word0 : std_ulogic_vector(31 downto 0);
        variable word1 : std_ulogic_vector(31 downto 0);
        variable word2 : std_ulogic_vector(28 downto 0);

    begin
        word0 := (
            DSP_BUNCH_BANK_NCO01_NCO0_HIGH_BITS =>
                std_ulogic_vector(config.nco0_gain(17 downto 2)),
            DSP_BUNCH_BANK_NCO01_NCO1_HIGH_BITS =>
                std_ulogic_vector(config.nco1_gain(17 downto 2)));
        word1 := (
            DSP_BUNCH_BANK_NCO23_NCO2_HIGH_BITS =>
                std_ulogic_vector(config.nco2_gain(17 downto 2)),
            DSP_BUNCH_BANK_NCO23_NCO3_HIGH_BITS =>
                std_ulogic_vector(config.nco3_gain(17 downto 2)));
        word2 := (
            DSP_BUNCH_BANK_EXTRA_FIR_SELECT_BITS =>
                std_ulogic_vector(config.fir_select),
            DSP_BUNCH_BANK_EXTRA_FIR_GAIN_BITS =>
                std_ulogic_vector(config.fir_gain),
            DSP_BUNCH_BANK_EXTRA_FIR_ENABLE_BIT => config.fir_enable,
            DSP_BUNCH_BANK_EXTRA_NCO0_LOW_BITS =>
                std_ulogic_vector(config.nco0_gain(1 downto 0)),
            DSP_BUNCH_BANK_EXTRA_NCO1_LOW_BITS =>
                std_ulogic_vector(config.nco1_gain(1 downto 0)),
            DSP_BUNCH_BANK_EXTRA_NCO2_LOW_BITS =>
                std_ulogic_vector(config.nco2_gain(1 downto 0)),
            DSP_BUNCH_BANK_EXTRA_NCO3_LOW_BITS =>
                std_ulogic_vector(config.nco3_gain(1 downto 0)));
        return word2 & word1 & word0;
    end;
end;
