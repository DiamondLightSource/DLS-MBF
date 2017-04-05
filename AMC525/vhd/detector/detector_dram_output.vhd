-- Output to DRAM controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.detector_defs.all;

entity detector_dram_output is
    port (
        clk_i : in std_logic;

        output_reset_i : in std_logic;
        output_enables_i : in std_logic_vector(DETECTOR_RANGE);

        input_valid_i : in std_logic_vector(DETECTOR_RANGE);
        input_ready_o : out std_logic_vector(DETECTOR_RANGE);
        input_data_i : vector_array(DETECTOR_RANGE)(open);

        output_valid_o : out std_logic;
        output_ready_i : in std_logic;
        output_addr_o : out unsigned;
        output_data_o : out std_logic_vector
    );
end;

architecture arch of detector_dram_output is
begin
    -- quick and dirty!
    output_valid_o <= input_valid_i(0);
    input_ready_o <= (0 => output_ready_i, others => '0');
    output_data_o <= input_data_i(0);
    output_addr_o <= (output_addr_o'RANGE => '0');
end;
