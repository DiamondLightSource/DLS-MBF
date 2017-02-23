-- Definitions for bunch selection

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

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
        result(1 downto 0)  := std_logic_vector(data.fir_select);
        result(14 downto 2) := std_logic_vector(data.gain);
        result(15) := data.fir_enable;
        result(16) := data.nco_0_enable;
        result(17) := data.nco_1_enable;
        return result;
    end;

    function bits_to_bunch_config(data : std_logic_vector)
        return bunch_config_t
    is
        variable result : bunch_config_t;
    begin
        result.fir_select := unsigned(data(1 downto 0));
        result.gain       := signed(data(14 downto 2));
        result.fir_enable   := data(15);
        result.nco_0_enable := data(16);
        result.nco_1_enable := data(17);
        return result;
    end;

end;
