-- Variable length memory buffer

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity memory_buffer is
    generic (
        LENGTH : natural := 1;
        DOUBLE_BUFFER : boolean := false
    );
    port (
        clk_i : in std_ulogic;

        input_valid_i : in std_ulogic;
        input_ready_o : out std_ulogic;
        input_data_i : in std_ulogic_vector;
        input_addr_i : in unsigned;

        output_valid_o : out std_ulogic;
        output_ready_i : in std_ulogic;
        output_data_o : out std_ulogic_vector;
        output_addr_o : out unsigned
    );
end;

architecture arch of memory_buffer is
    signal valid : std_ulogic_vector(0 to LENGTH);
    signal ready : std_ulogic_vector(0 to LENGTH);
    signal data : vector_array(0 to LENGTH)(input_data_i'RANGE);
    signal addr : unsigned_array(0 to LENGTH)(input_addr_i'RANGE);

begin
    gen_buffer : for n in 0 to LENGTH-1 generate
        gen : if DOUBLE_BUFFER generate
            fast : entity work.memory_buffer_fast port map (
                clk_i => clk_i,
                input_valid_i => valid(n),
                input_ready_o => ready(n),
                input_data_i => data(n),
                input_addr_i => addr(n),
                output_valid_o => valid(n + 1),
                output_ready_i => ready(n + 1),
                output_data_o => data(n + 1),
                output_addr_o => addr(n + 1)
            );
        else generate
            simple : entity work.memory_buffer_simple port map (
                clk_i => clk_i,
                input_valid_i => valid(n),
                input_ready_o => ready(n),
                input_data_i => data(n),
                input_addr_i => addr(n),
                output_valid_o => valid(n + 1),
                output_ready_i => ready(n + 1),
                output_data_o => data(n + 1),
                output_addr_o => addr(n + 1)
            );
        end generate;
    end generate;

    valid(0) <= input_valid_i;
    input_ready_o <= ready(0);
    data(0) <= input_data_i;
    addr(0) <= input_addr_i;

    output_valid_o <= valid(LENGTH);
    ready(LENGTH) <= output_ready_i;
    output_data_o <= data(LENGTH);
    output_addr_o <= addr(LENGTH);
end;
