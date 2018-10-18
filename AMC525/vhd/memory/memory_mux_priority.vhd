-- Priority multiplexer

-- Selects one out of a set of ready inputs

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity memory_mux_priority is
    port (
        clk_i : in std_ulogic;

        input_valid_i : in std_ulogic_vector;
        input_ready_o : out std_ulogic_vector;
        data_i : in vector_array;
        addr_i : in unsigned_array;

        output_valid_o : out std_ulogic;
        output_ready_i : in std_ulogic;
        data_o : out std_ulogic_vector;
        addr_o : out unsigned
    );
end;

architecture arch of memory_mux_priority is
    function priority_select(input : std_ulogic_vector) return natural is
    begin
        for n in input'RANGE loop
            if input(n) = '1' then
                return n;
            end if;
        end loop;
        return 0;       -- Doesn't matter, won't be used
    end;

    signal input_ready : input_ready_o'SUBTYPE := (others => '0');
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
                        addr_o <= addr_i(selection);
                        compute_strobe(input_ready, selection);
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
    output_valid_o <= to_std_ulogic(out_state = BUSY);
end;
