-- Management of turn clock

-- All the controls and readbacks are on the DSP clock, while the revolution
-- clock and generated turn clock are on the ADC clock.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.trigger_defs.all;

entity trigger_turn_clock is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        -- Control and readback
        setup_i : in turn_clock_setup_t;
        readback_o : out turn_clock_readback_t;

        -- Input clock
        revolution_clock_i : in std_logic;
        -- Generated turn clocks
        turn_clock_o : out std_logic
    );
end;

architecture arch of trigger_turn_clock is
    signal start_sync : std_logic;
    signal read_sync : std_logic;
    signal zero_detect : boolean;
    signal bunch_counter : bunch_count_t := (others => '0');
    signal revolution_clock : std_logic := '0';
    signal sync_request : boolean := false;
    signal bunch_counter_delay : bunch_count_t := (others => '0');
    signal zero_detect_delay : boolean := false;
    signal revolution_clock_delay : boolean := false;
    signal turn_clock : std_logic := '0';

    signal turn_counter : readback_o.turn_counter'SUBTYPE := (others => '0');
    signal turn_counter_out : readback_o.turn_counter'SUBTYPE;
    signal error_counter : readback_o.error_counter'SUBTYPE := (others => '0');
    signal error_counter_out : readback_o.error_counter'SUBTYPE;

begin

    -- Convert the sync and read requests on DSP clock to ADC clock
    convert_sync : entity work.pulse_dsp_to_adc port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        pulse_i => setup_i.start_sync,
        pulse_o => start_sync
    );

    convert_read : entity work.pulse_dsp_to_adc port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        pulse_i => setup_i.read_sync,
        pulse_o => read_sync
    );

    zero_detect <= bunch_counter = 0;

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            revolution_clock <= revolution_clock_i;

            -- Sync request state machine
            if start_sync then
                sync_request <= true;
            elsif revolution_clock then
                sync_request <= false;
            end if;

            -- Bunch counter
            if zero_detect or (revolution_clock = '1') then
                bunch_counter <= setup_i.max_bunch;
            else
                bunch_counter <= bunch_counter - 1;
            end if;
            bunch_counter_delay <= bunch_counter;

            -- Clock phase check
            zero_detect_delay <= zero_detect;
            revolution_clock_delay <= revolution_clock = '1';

            -- Output of turn clock
            turn_clock <= to_std_logic(
                bunch_counter_delay = setup_i.clock_offset);

            -- Now count some turn statistics
            if read_sync then
                turn_counter_out <= turn_counter;
                error_counter_out <= error_counter;
                turn_counter <= (others => '0');
                error_counter <= (others => '0');
            elsif zero_detect_delay then
                turn_counter <= turn_counter + 1;
                if revolution_clock_delay /= zero_detect_delay then
                    error_counter <= error_counter + 1;
                end if;
            end if;

            -- Only check for an error when a revolution clock pulse occurs
            if revolution_clock_delay then
                if revolution_clock_delay /= zero_detect_delay then
                    error_counter <= error_counter + 1;
                end if;
            end if;
        end if;
    end process;


    -- Bring register readbacks onto DSP clock
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            readback_o.sync_busy <= to_std_logic(false);
            readback_o.turn_counter <= turn_counter_out;
            readback_o.error_counter <= error_counter_out;
        end if;
    end process;


    -- Delay line for the turn clock to help with timing
    turn_clock_delay : entity work.dlyreg generic map (
        DLY => 4
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => turn_clock,
        data_o(0) => turn_clock_o
    );
end;
