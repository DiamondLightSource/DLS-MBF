-- Definitions for bunch selection

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;

package bunch_defs is
    -- Bunch configuration
    type bunch_config_t is record
        -- Selects FIR filter
        fir_select : unsigned(FIR_BANK_BITS-1 downto 0);
        -- Output enables
        fir_enable : std_logic;
        nco_0_enable : std_logic;
        nco_1_enable : std_logic;
        -- Final output gain
        gain : signed(12 downto 0);
    end record;
    constant BUNCH_CONFIG_BITS : natural := FIR_BANK_BITS + 3 + 13;

    constant default_bunch_config_t : bunch_config_t := (
        fir_select => (others => '0'),
        gain => (others => '0'),
        others => '0');


    -- Packed conversion between bunch configuration and std_logic_vector
    function bunch_config_to_bits(data : bunch_config_t)
        return std_logic_vector;
    function bits_to_bunch_config(data : std_logic_vector)
        return bunch_config_t;

end;

package body bunch_defs is

    function bunch_config_to_bits(data : bunch_config_t)
        return std_logic_vector
    is
        variable result : std_logic_vector(BUNCH_CONFIG_BITS-1 downto 0);
    begin
        result(DSP_BUNCH_BANK_FIR_SELECT_BITS) :=
            std_logic_vector(data.fir_select);
        result(DSP_BUNCH_BANK_GAIN_BITS) := std_logic_vector(data.gain);
        result(DSP_BUNCH_BANK_FIR_ENABLE_BIT) := data.fir_enable;
        result(DSP_BUNCH_BANK_NCO0_ENABLE_BIT) := data.nco_0_enable;
        result(DSP_BUNCH_BANK_NCO1_ENABLE_BIT) := data.nco_1_enable;
        return result;
    end;

    function bits_to_bunch_config(data : std_logic_vector)
        return bunch_config_t
    is
        variable result : bunch_config_t;
    begin
        result.fir_select := unsigned(data(DSP_BUNCH_BANK_FIR_SELECT_BITS));
        result.gain       := signed(data(DSP_BUNCH_BANK_GAIN_BITS));
        result.fir_enable   := data(DSP_BUNCH_BANK_FIR_ENABLE_BIT);
        result.nco_0_enable := data(DSP_BUNCH_BANK_NCO0_ENABLE_BIT);
        result.nco_1_enable := data(DSP_BUNCH_BANK_NCO1_ENABLE_BIT);
        return result;
    end;

end;
