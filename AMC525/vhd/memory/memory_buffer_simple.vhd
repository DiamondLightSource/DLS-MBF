-- Simple single registered memory buffer

-- This buffer alternates between consuming and producing, and so introduces a
-- data bubble on every transation: maximum throughput is every other tick.
--
-- State transition table:
--
--   state   ir ov iv or state'    action
--  +-------+-----+-----+---------+-----------
--  | EMPTY | 1 0 | 0   : EMPTY
--  |       |     | 1   : FULL      od <= id
--  +-------+-----+-----+---------+-----------
--  | FULL  | 0 1 |   0 : FULL
--  |       |     |   1 : EMPTY
--  +-------+-----+-----+---------+-----------
--  ir = input_ready_o, ov = output_valid_o, iv = input_valid_i,
--  or = output_read_i, od = output_data_o, id = input_data_i

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity memory_buffer_simple is
    port (
        clk_i : in std_logic;

        input_valid_i : in std_logic;
        input_ready_o : out std_logic;
        input_data_i : in std_logic_vector;
        input_addr_i : in unsigned;

        output_valid_o : out std_logic;
        output_ready_i : in std_logic;
        output_data_o : out std_logic_vector;
        output_addr_o : in unsigned
    );
end;

architecture arch of memory_buffer_simple is
    type state_t is (EMPTY, FULL);
    signal state : state_t := EMPTY;

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            case state is
                when EMPTY =>
                    if input_valid_i = '1' then
                        state <= FULL;
                        output_data_o <= input_data_i;
                        output_addr_o <= input_addr_i;
                    end if;
                when FULL =>
                    if output_ready_i = '1' then
                        state <= EMPTY;
                    end if;
            end case;
        end if;
    end process;

    input_ready_o  <= to_std_logic(state = EMPTY);
    output_valid_o <= to_std_logic(state = FULL);
end;
