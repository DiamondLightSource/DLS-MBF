-- Controller for fast memory

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity fast_memory_control is
    port (
        dsp_clk_i : in std_logic;

        start_i : in std_logic;
        stop_i : in std_logic;
        count_i : in unsigned;

        capture_enable_o : out std_logic;
        capture_address_i : in std_logic_vector;
        capture_address_o : out std_logic_vector
    );
end;

architecture fast_memory_control of fast_memory_control is
    signal counter : count_i'SUBTYPE;
    type state_t is (IDLE, RUNNING, RUNOUT);
    signal state : state_t := IDLE;

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            case state is
                when IDLE =>
                    if start_i = '1' then
                        counter <= count_i;
                        if stop_i = '1' then
                            capture_address_o <=
                                (capture_address_o'RANGE => '0');
                            state <= RUNOUT;
                        else
                            state <= RUNNING;
                        end if;
                    end if;
                when RUNNING =>
                    if stop_i = '1' then
                        if counter = 0 then
                            state <= IDLE;
                        else
                            capture_address_o <= capture_address_i;
                            state <= RUNOUT;
                        end if;
                    end if;
                when RUNOUT =>
                    if counter = 0 then
                        state <= IDLE;
                    else
                        counter <= counter - 1;
                    end if;
            end case;

            capture_enable_o <= to_std_logic(state /= IDLE);
        end if;
    end process;
end;
