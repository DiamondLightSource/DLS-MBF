-- Definitions for bunch selection

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

package bunch_defs is
    -- This determines the maximum number of bunches in a machine turn, equal to
    -- LANE_COUNT * 2**BUNCH_NUM_BITS.  At DLS with our 936 bunches and 2 lanes
    -- in the FPGA design a value of 9 is sufficient.
    constant BUNCH_NUM_BITS : natural := 9;
    subtype bunch_count_t is unsigned(BUNCH_NUM_BITS-1 downto 0);

    -- Number of bunch banks
    constant BUNCH_BANK_BITS : natural := 2;

    -- Bunch configuration
    type bunch_config_t is record
        fir_select : unsigned(1 downto 0);
        out_mux_select : unsigned(2 downto 0);
        gain : signed(12 downto 0);
    end record;
    constant BUNCH_CONFIG_BITS : natural := 18;

    type bunch_config_lanes_t is array(LANES) of bunch_config_t;

    -- Packed conversion between bunch configuration and std_logic_vector
    function bunch_config_to_bits(data : bunch_config_t)
        return std_logic_vector;
    function bits_to_bunch_config(data : std_logic_vector)
        return bunch_config_t;

end package;

package body bunch_defs is

    function bunch_config_to_bits(data : bunch_config_t)
        return std_logic_vector
    is
        variable result : std_logic_vector(BUNCH_CONFIG_BITS-1 downto 0);
    begin
        result(1 downto 0)  := std_logic_vector(data.fir_select);
        result(4 downto 2)  := std_logic_vector(data.out_mux_select);
        result(17 downto 5) := std_logic_vector(data.gain);
        return result;
    end;

    function bits_to_bunch_config(data : std_logic_vector)
        return bunch_config_t
    is
        variable result : bunch_config_t;
    begin
        result.fir_select     := unsigned(data(1 downto 0));
        result.out_mux_select := unsigned(data(4 downto 2));
        result.gain           := signed  (data(17 downto 5));
        return result;
    end;

end package body;
