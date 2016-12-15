-- Priority multiplexer

-- Selects one out of a set of ready inputs

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity slow_memory_priority is
    port (
        clk_i : in std_logic;

        input_valid_i : in std_logic_vector;
        input_ready_o : out std_logic_vector;
        data_i : in vector_array;

        output_ready_i : in std_logic;
        output_valid_o : out std_logic;
        data_o : out std_logic_vector
    );
end;

architecture slow_memory_priority of slow_memory_priority is
    constant INPUT_COUNT : natural := input_ready_o'LENGTH;

    function priority_select(input : std_logic_vector) return natural is
    begin
        for n in input'RANGE loop
            if input(n) = '1' then
                return n;
            end if;
        end loop;
        return 0;       -- Doesn't matter, won't be used
    end;

    signal input_ready : std_logic_vector(input_ready_o'RANGE)
        := (others => '0');
    signal selection : natural;

    type out_state_t is (IDLE, BUSY);
    signal out_state : out_state_t := IDLE;

begin
    selection <= priority_select(input_valid_i);

    process (clk_i) begin
        if rising_edge(clk_i) then
            case out_state is
                when IDLE =>
                    if vector_or(input_valid_i) then
                        data_o <= data_i(selection);
                        input_ready <= compute_strobe(selection, INPUT_COUNT);
                        out_state <= BUSY;
                    end if;
                when BUSY =>
                    input_ready <= (others => '0');
                    if output_ready_i = '1' then
                        out_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;

    input_ready_o <= input_ready;
    output_valid_o <= to_std_logic(out_state = BUSY);
end;
