-- Core trigger handling logic

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity trigger_handler is
    port (
        dsp_clk_i : in std_logic;

        trigger_i : in std_logic;       -- External trigger source
        turn_clock_i : in std_logic;    -- Machine revolution clock

        arm_i : in std_logic;
        disarm_i : in std_logic;
        delay_i : in unsigned;

        trigger_o : out std_logic;
        armed_o : out std_logic;

        trigger_seen_o : out std_logic  -- Captured effective trigger pulse
    );
end;

architecture trigger_handler of trigger_handler is
    type trig_state_t is (TRIGGER_IDLE, TRIGGER_ARMED, TRIGGER_TRIGGERED);
    signal trig_state : trig_state_t := TRIGGER_IDLE;

    signal counter : delay_i'SUBTYPE;

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            case trig_state is
                when TRIGGER_IDLE =>
                    if arm_i = '1' then
                        trig_state <= TRIGGER_ARMED;
                    end if;

                when TRIGGER_ARMED =>
                    if trigger_i = '1' then
                        trig_state <= TRIGGER_TRIGGERED;
                        counter <= delay_i;
                    elsif disarm_i = '1' then
                        trig_state <= TRIGGER_IDLE;
                    end if;

                when TRIGGER_TRIGGERED =>
                    if disarm_i = '1' then
                        trig_state <= TRIGGER_IDLE;
                    elsif turn_clock_i = '1' then
                        if counter = 0 then
                            trig_state <= TRIGGER_IDLE;
                        else
                            counter <= counter - 1;
                        end if;
                    end if;
            end case;

            trigger_o <=
                turn_clock_i and
                to_std_logic(trig_state = TRIGGER_TRIGGERED) and
                to_std_logic(counter = 0);
        end if;
    end process;

    -- Report as armed until trigger pulse has actually been generated
    armed_o <= to_std_logic(trig_state /= TRIGGER_IDLE);
    trigger_seen_o <= to_std_logic(trig_state = TRIGGER_ARMED) and trigger_i;
end;
