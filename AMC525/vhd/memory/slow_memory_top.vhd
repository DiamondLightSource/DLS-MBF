-- Slow memory multiplexer.
--
-- Provides two separate buffered channels to slow memory.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity slow_memory_top is
    port (
        dsp_clk_i : in std_logic;

        -- Inputs from DSP
        dsp_strobe_i : in std_logic_vector;
        dsp_ready_o : out std_logic_vector;
        dsp_address_i : in unsigned_array;
        dsp_data_i : in vector_array;

        -- Output to AXI control
        dram1_address_o : out unsigned;
        dram1_data_o : out std_logic_vector;
        dram1_data_valid_o : out std_logic;
        dram1_data_ready_i : in std_logic
    );
end;

architecture slow_memory_top of slow_memory_top is
begin
    dsp_ready_o <= (dsp_ready_o'RANGE => '0');
    dram1_data_valid_o <= '0';
    dram1_data_o <= (dram1_data_o'RANGE => '0');
    dram1_address_o <= (dram1_address_o'RANGE => '0');
end;
