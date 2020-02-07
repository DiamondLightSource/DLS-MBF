-- Definitions for bunch selection

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;

package bunch_defs is
    -- Bunch configuration
    -- This needs to match the register definition for DSP.BUNCH.BANK
    type bunch_config_t is record
        -- Selects FIR filter
        fir_select : unsigned(FIR_BANK_BITS-1 downto 0);
        -- Output enables
        fir_enable : std_ulogic;
        nco_0_enable : std_ulogic;
        nco_1_enable : std_ulogic;
        nco_2_enable : std_ulogic;
        nco_3_enable : std_ulogic;
        -- Final output gain, scaled as signed 6.12 number
        gain : signed(17 downto 0);
    end record;

    constant BUNCH_CONFIG_BITS : natural := FIR_BANK_BITS + 5 + 18;
    subtype bunch_config_bits_t is
        std_ulogic_vector(BUNCH_CONFIG_BITS-1 downto 0);

    function to_bunch_config_t(bits : std_ulogic_vector) return bunch_config_t;
    function from_bunch_config_t(config : bunch_config_t)
        return bunch_config_bits_t;
end;

package body bunch_defs is
    function to_bunch_config_t(bits : std_ulogic_vector)
        return bunch_config_t is
    begin
        return (
            fir_select => unsigned(bits(DSP_BUNCH_BANK_FIR_SELECT_BITS)),
            gain => signed(bits(DSP_BUNCH_BANK_GAIN_BITS)),
            fir_enable => bits(DSP_BUNCH_BANK_FIR_ENABLE_BIT),
            nco_0_enable => bits(DSP_BUNCH_BANK_NCO0_ENABLE_BIT),
            nco_1_enable => bits(DSP_BUNCH_BANK_NCO1_ENABLE_BIT),
            nco_2_enable => bits(DSP_BUNCH_BANK_NCO2_ENABLE_BIT),
            nco_3_enable => bits(DSP_BUNCH_BANK_NCO3_ENABLE_BIT));
    end;

    function from_bunch_config_t(config : bunch_config_t)
        return bunch_config_bits_t is
    begin
        return (
            DSP_BUNCH_BANK_FIR_SELECT_BITS =>
                std_ulogic_vector(config.fir_select),
            DSP_BUNCH_BANK_GAIN_BITS => std_ulogic_vector(config.gain),
            DSP_BUNCH_BANK_FIR_ENABLE_BIT => config.fir_enable,
            DSP_BUNCH_BANK_NCO0_ENABLE_BIT => config.nco_0_enable,
            DSP_BUNCH_BANK_NCO1_ENABLE_BIT => config.nco_1_enable,
            DSP_BUNCH_BANK_NCO2_ENABLE_BIT => config.nco_2_enable,
            DSP_BUNCH_BANK_NCO3_ENABLE_BIT => config.nco_3_enable);
    end;
end;
