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

        trigger_i : in std_logic;
        trigger_phase_i : in std_logic;

        capture_enable_o : out std_logic := '0';
        capture_address_i : in std_logic_vector;
        capture_address_o : out std_logic_vector
    );
end;

architecture arch of fast_memory_control is
    signal trigger : std_logic := '0';
    signal capture_phase : std_logic := '0';
    signal capture_address_in : capture_address_i'SUBTYPE;

    signal counter : count_i'SUBTYPE;
    type state_t is (IDLE, RUNNING, RUNOUT);
    signal state : state_t := IDLE;


    -- The phase bit is inserted into the capture address at the right point.
    -- We are capturing 4 bytes per ADC tick, so we need to insert the ADC
    -- phase as bit 2.
    function insert_phase_bit(
        word : std_logic_vector;
        phase : std_logic) return std_logic_vector
    is
        variable result : word'SUBTYPE := word;
    begin
        result(2) := phase;
        return result;
    end;

begin
    capture_address_in <= insert_phase_bit(capture_address_i, capture_phase);

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            trigger <= trigger_i;
            capture_phase <= trigger_phase_i;

            case state is
                when IDLE =>
                    if start_i = '1' then
                        counter <= count_i;
                        if stop_i = '1' then
                            capture_address_o <= (
                                capture_address_o'RANGE => '0');
                            state <= RUNOUT;
                        else
                            state <= RUNNING;
                        end if;
                    end if;
                when RUNNING =>
                    if trigger = '1' then
                        if counter = 0 then
                            state <= IDLE;
                        else
                            capture_address_o <= capture_address_in;
                            state <= RUNOUT;
                        end if;
                    elsif stop_i = '1' then
                        state <= IDLE;
                    end if;
                when RUNOUT =>
                    if counter = 0 then
                        state <= IDLE;
                    elsif stop_i = '1' then
                        state <= IDLE;
                    else
                        counter <= counter - 1;
                    end if;
            end case;

            capture_enable_o <= to_std_logic(state /= IDLE);
        end if;
    end process;
end;
