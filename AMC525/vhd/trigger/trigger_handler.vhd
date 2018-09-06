-- Core trigger handling logic

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity trigger_handler is
    port (
        dsp_clk_i : in std_ulogic;

        trigger_i : in std_ulogic;       -- External trigger source
        turn_clock_i : in std_ulogic;    -- Machine revolution clock

        arm_i : in std_ulogic;
        fire_i : in std_ulogic;
        disarm_i : in std_ulogic;
        delay_i : in unsigned;

        trigger_o : out std_ulogic := '0';
        armed_o : out std_ulogic;

        trigger_seen_o : out std_ulogic  -- Captured effective trigger pulse
    );
end;

architecture arch of trigger_handler is
    type trig_state_t is (TRIGGER_IDLE, TRIGGER_ARMED, TRIGGER_TRIGGERED);
    signal trig_state : trig_state_t := TRIGGER_IDLE;

    signal counter : delay_i'SUBTYPE := (others => '0');

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            case trig_state is
                when TRIGGER_IDLE =>
                    if fire_i = '1' then
                        trig_state <= TRIGGER_TRIGGERED;
                        counter <= delay_i;
                    elsif arm_i = '1' then
                        trig_state <= TRIGGER_ARMED;
                    end if;

                when TRIGGER_ARMED =>
                    if trigger_i = '1' or fire_i = '1' then
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
                to_std_ulogic(trig_state = TRIGGER_TRIGGERED) and
                to_std_ulogic(counter = 0);
        end if;
    end process;

    -- Report as armed until trigger pulse has actually been generated
    armed_o <= to_std_ulogic(trig_state /= TRIGGER_IDLE);
    trigger_seen_o <= to_std_ulogic(trig_state = TRIGGER_ARMED) and trigger_i;
end;
