-- Sequencer program counter and reset
--
-- Note that state_end_i must be valid for several clocks before turn_clock_i to
-- allow time for the next state to be loaded, and is sampled immediately after
-- turn_clock_i.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.sequencer_defs.all;

entity sequencer_pc is
    port (
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;

        trigger_i : in std_logic;       -- Sequencer trigger

        reset_i : in std_logic;         -- Program reset request
        seq_pc_i : in seq_pc_t;         -- PC for newly started program
        super_count_i : in super_count_t;   -- Number of sequencer meta states
        state_end_i : in std_logic;     -- Signal to advance PC and update state

        trigger_state_i : in seq_pc_t;  -- State to generate trigger
        state_trigger_o : out std_logic;    -- Sequencer about to start state

        start_load_o : out std_logic;   -- Triggers loading of next state
        seq_pc_o : out seq_pc_t;        -- Current PC
        super_count_o : out super_count_t;  -- Current sequencer meta state
        busy_o : out std_logic;         -- Set from trigger until program done
        reset_o : out std_logic         -- Program reset command, aborts dwell
    );
end;

architecture sequencer_pc of sequencer_pc is
    -- Reset processing.  The reset_i pulse comes in as a one clock asynchronous
    -- pulse, here we synchronise it to the turn clock and generate a one turn
    -- long reset output pulse.
    signal reset_in : std_logic := '0';
    signal reset_out : std_logic := '0';

    -- Arming and trigger.  Capture trigger, disallow retriggering until current
    -- program has completed.  The trigger flag remains set until a fresh load
    -- event occurs.
    signal trigger : std_logic := '0';
    signal trigger_in : std_logic := '0';

    -- When we see last_turn_i we should advance the program counter and then
    -- pulse start_load_o to trigger loading of configuration for the new state.
    signal loading : std_logic := '0';
    signal super_count : super_count_t := (others => '0');
    signal seq_pc : seq_pc_t := "000";
    signal start_load : std_logic := '0';

    -- Generate trigger output on entry to selected state
    signal last_trigger : std_logic := '0';
    signal trigger_now : std_logic;

begin
    -- Trigger source selection.
    trigger_in <= trigger_i or trigger;

    -- Output trigger
    trigger_now <= to_std_logic(seq_pc = trigger_state_i);

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then

            -- Reset processing
            if reset_i = '1' then
                reset_in <= '1';
            elsif reset_out = '1' then
                reset_in <= '0';
            end if;

            if turn_clock_i = '1' then
                reset_out <= reset_in;
            end if;

            -- Trigger capture
            if trigger_i = '1' then
                trigger <= '1';
            elsif start_load = '1' then
                trigger <= '0';
            end if;

            -- Ensure we report as busy from sight of incoming trigger until PC
            -- goes zero at end of the following turn clock.  It's quite
            -- important that busy_o be set as soon as an incoming trigger is
            -- seen to avoid a glitch between trigger armed and sequencer busy.
            if trigger_in = '1' then
                busy_o <= '1';
            elsif turn_clock_i = '1' and seq_pc = 0 then
                busy_o <= '0';
            end if;

            -- Program counter and control
            if loading = '1' then
                start_load <= '0';
                if turn_clock_i = '1' then
                    loading <= '0';
                end if;
            elsif state_end_i = '1' or reset_out = '1' then
                -- Advance PC to the appropriate next state and trigger loading
                -- event for sequencer state.
                if reset_out = '1' then
                    seq_pc    <= (others => '0');
                    super_count <= (others => '0');
                else
                    case to_integer(seq_pc) is
                        when 0 => -- Idle state, sequencer waiting for trigger
                            if trigger_in = '1' then
                                seq_pc <= seq_pc_i;
                                super_count <= super_count_i;
                            end if;
                        when 1 => -- Last sequencer state, enter idle or restart
                            if super_count = 0 then
                                seq_pc <= (others => '0');
                            else
                                seq_pc <= seq_pc_i;
                                super_count <= super_count - 1;
                            end if;
                        when others =>    -- Step sequencer state down
                            seq_pc <= seq_pc - 1;
                    end case;
                end if;

                start_load <= '1';
                loading <= '1';
            end if;

            -- Edge capture for state trigger
            last_trigger <= trigger_now;

        end if;
    end process;

    reset_o <= reset_out;
    start_load_o <= start_load;
    seq_pc_o <= seq_pc;
    super_count_o <= super_count;
    state_trigger_o <= trigger_now and not last_trigger;
end;
