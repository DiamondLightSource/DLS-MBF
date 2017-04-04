-- SCaling and output of a single detector value

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;

entity detector_output is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        scaling_i : in unsigned;
        overflow_o : out std_logic;
        write_i : in std_logic;
        data_i : in cos_sin_t;

        output_valid_o : out std_logic;
        output_ready_i : in std_logic;
        output_data_o : out std_logic_vector;
        output_underrun_o : out std_logic
    );
end;

architecture arch of detector_output is
begin
end;
