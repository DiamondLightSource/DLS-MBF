-- Manage the signal length and alignment for the resets, start of
-- frequency sweep, and NCO phase reset.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity swept_nco_seq_signals is
    port (
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;

        state_end_i : in std_ulogic;         -- Next turn is start of state

        reset_sweep_i : in std_ulogic;
        reset_turn_o : out std_ulogic;

        reset_phase_i : in std_ulogic;
        nco_reset_o : out std_ulogic;

        repeat_start_i : in std_ulogic;
        repeat_start_reset_i : in std_ulogic;
        repeat_start_turn_o : out std_ulogic
    );
end;

architecture arch of swept_nco_seq_signals is
    signal reset_armed : std_ulogic := '0';
    signal repeat_start_armed : std_ulogic := '0';
    signal reset_phase_armed : std_ulogic := '0';
    -- phase reset requested at the start of frequency sweep repetitions.
    signal reset_phase_at_start : std_ulogic := '0';
    -- phase reset signal has to be delayed by 1 turn to wait for the correct
    -- state end signal.
    signal reset_phase_at_start_d1 : std_ulogic := '0';

begin
    -- Reset processing.  The reset_sweep_i pulse comes in as a one clock
    -- pulse, here we synchronise it to the turn clock and generate a
    -- one turn long reset output pulse.
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if turn_clock_i = '1' then
                reset_turn_o <= reset_armed;
                reset_armed <= '0';

                repeat_start_turn_o <= repeat_start_armed;
                repeat_start_armed <= '0';
                reset_phase_at_start <= '0';
                reset_phase_at_start_d1 <= reset_phase_at_start;
            end if;

            if reset_sweep_i = '1' then
                reset_armed <= '1';
            end if;

            if repeat_start_i = '1' then
                repeat_start_armed <= '1';
                reset_phase_at_start <= repeat_start_reset_i;
            end if;
        end if;
    end process;


    -- Manage NCO phase reset signal.
    --
    -- Phase reset is either asked by the user (reset_phase_i) or performed
    -- at the begining of a frequency sweep train if the RESET_PHASE bit is
    -- asserted simultaneously with the START bit (reset_phase_at_start_d1).
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- phase reset requested
            if reset_phase_i or reset_phase_at_start_d1 then
                reset_phase_armed <= '1';
            end if;

            -- a phase reset occurs now
            if nco_reset_o = '1' then
                reset_phase_armed <= '0';
            end if;

            -- The reset signal pulse has to be aligned precisely with respect
            -- to the turn clock and sequencer state.  See sequencer_counter
            -- as reference.
            nco_reset_o <= reset_phase_armed and turn_clock_i and state_end_i;
        end if;
    end process;
end;
