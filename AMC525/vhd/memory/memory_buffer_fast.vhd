-- Fast double registered memory buffer

-- This buffer supports a bubble-free interface between a produced and consumer,
-- and so requires a second data buffer to capture one tick of production data
-- in the case when the consumer becomes unready.
--
-- State transition table:
--
--   state   ir ov iv or state'    action
--  +-------+-----+-----+---------+-----------
--  | EMPTY | 1 0 | 0   : EMPTY
--  |       |     | 1   : HALF      od <= id
--  +-------+-----+-----+---------+-----------
--  | HALF  | 1 1 | 0 0 : HALF
--  |       |     | 0 1 : EMPTY
--  |       |     | 1 0 : FULL      d2 <= id
--  |       |     | 1 1 : HALF      od <= id
--  +-------+-----+-----+---------+-----------
--  | FULL  | 0 1 |   0 : FULL
--  |       |     |   1 : HALF
--  +-------+-----+-----+---------+-----------
--  ir = input_ready_o, ov = output_valid_o, iv = input_valid_i,
--  or = output_read_i, od = output_data_o, id = input_data_i, d2 = full_data

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity memory_buffer_fast is
    port (
        clk_i : in std_logic;

        input_valid_i : in std_logic;
        input_ready_o : out std_logic;
        input_data_i : in std_logic_vector;
        input_addr_i : in unsigned;

        output_valid_o : out std_logic;
        output_ready_i : in std_logic;
        output_data_o : out std_logic_vector;
        output_addr_o : out unsigned
    );
end;

architecture arch of memory_buffer_fast is
    type state_t is (EMPTY, HALF, FULL);
    signal state : state_t := EMPTY;

    signal full_data : input_data_i'SUBTYPE;
    signal full_addr : input_addr_i'SUBTYPE;

    signal input_output_state : std_logic_vector(0 to 1);

begin
    input_output_state <= input_valid_i & output_ready_i;
    process (clk_i) begin
        if rising_edge(clk_i) then
            case state is
                when EMPTY =>
                    if input_valid_i = '1' then
                        state <= HALF;
                        output_data_o <= input_data_i;
                        output_addr_o <= input_addr_i;
                    end if;
                when HALF =>
                    case input_output_state is
                        when "00" =>
                        when "01" =>
                            state <= EMPTY;
                        when "10" =>
                            state <= FULL;
                            full_data <= input_data_i;
                            full_addr <= input_addr_i;
                        when "11" =>
                            output_data_o <= input_data_i;
                            output_addr_o <= input_addr_i;
                        when others =>
                    end case;
                when FULL =>
                    if output_ready_i = '1' then
                        state <= HALF;
                        output_data_o <= full_data;
                        output_addr_o <= full_addr;
                    end if;
            end case;
        end if;
    end process;

    process (state) begin
        case state is
            when EMPTY =>
                input_ready_o  <= '1';
                output_valid_o <= '0';
            when HALF =>
                input_ready_o  <= '1';
                output_valid_o <= '1';
            when FULL =>
                input_ready_o  <= '0';
                output_valid_o <= '1';
        end case;
    end process;
end;
