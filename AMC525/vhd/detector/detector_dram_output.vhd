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

        output_valid_o : out std_logic_vector(DETECTOR_RANGE);
        output_ready_i : in std_logic_vector(DETECTOR_RANGE);
        output_addr_o : out unsigned;
        output_data_o : out std_logic_vector;
    );
end;

architecture arch of detector_dram_output is
begin
end;
