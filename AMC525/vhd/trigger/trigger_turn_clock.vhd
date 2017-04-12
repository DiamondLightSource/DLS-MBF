-- Management of turn clock

-- All the controls and readbacks are on the DSP clock, while the revolution
-- clock and generated turn clock are on the ADC clock.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity trigger_turn_clock is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        -- Control interface
        start_sync_i : in std_logic;    -- Resynchronise request
        start_sample_i : in std_logic;
        max_bunch_i : in bunch_count_t; -- Ring size
        clock_offsets_i : in unsigned_array(CHANNELS)(bunch_count_t'RANGE);

        -- Status readbacks
        sync_busy_o : out std_logic;
        sync_phase_o : out std_logic;
        sync_error_o : out std_logic;
        sample_busy_o : out std_logic;
        sample_phase_o : out std_logic;
        sample_count_o : out bunch_count_t;

        -- Input clock
        revolution_clock_i : in std_logic;
        -- Generated turn clocks, one per channel
        turn_clock_o : out std_logic_vector(CHANNELS)
    );
end;

architecture arch of trigger_turn_clock is
    signal adc_phase : std_logic;

    signal max_bunch : bunch_count_t := (others => '0');
    signal clock_offsets : clock_offsets_i'SUBTYPE;
    signal bunch_counter : bunch_count_t := (others => '0');

    -- Synchronisation and sample state
    signal sync_request : boolean := false;
    signal sync_holdoff : boolean := false;
    signal sync_phase : std_logic;
    signal sync_ok : boolean := true;
    signal sync_error : boolean := false;
    signal sample_request : boolean := false;
    signal sample_phase : std_logic;
    signal sample_count : bunch_count_t;

    signal turn_clock : std_logic_vector(CHANNELS) := (others => '0');

begin
    -- -------------------------------------------------------------------------
    -- Revolution clock at ADC clock rate

    phase : entity work.adc_dsp_phase port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_o => adc_phase
    );

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            -- Transfer control counters to ADC clock
            max_bunch <= max_bunch_i;
            clock_offsets <= clock_offsets_i;

            -- Synchronise or else advance base bunch counter
            if revolution_clock_i = '1' and sync_request then
                bunch_counter <= max_bunch;
                sync_phase <= adc_phase;
                sync_holdoff <= true;
            elsif bunch_counter = 0 then
                bunch_counter <= max_bunch;
                sync_holdoff <= false;
            else
                bunch_counter <= bunch_counter - 1;
            end if;
            -- Synchronisation request.
            if start_sync_i = '1' and adc_phase = '1' then
                sync_request <= true;
            elsif revolution_clock_i = '1' then
                sync_request <= false;
            end if;


            -- Check synchronisation
            if revolution_clock_i = '1' then
                sync_ok <= bunch_counter = 0;
            else
                sync_ok <= true;
            end if;
            if sync_request or sync_holdoff then
                sync_error <= false;
            else
                sync_error <= sync_error or not sync_ok;
            end if;


            -- Sample request.
            if revolution_clock_i = '1' and sample_request then
                sample_count <= bunch_counter;
                sample_phase <= adc_phase;
            end if;
            if start_sample_i = '1' and adc_phase = '1' then
                sample_request <= true;
            elsif revolution_clock_i = '1' then
                sample_request <= false;
            end if;


            -- Output of channel specific turn clocks
            for c in CHANNELS loop
                if sync_request or sync_holdoff then
                    turn_clock(c) <= '0';
                else
                    turn_clock(c) <=
                        to_std_logic(bunch_counter = clock_offsets(c));
                end if;
            end loop;
        end if;
    end process;

    -- Delay line for the ADC turn clock
    turn_clock_delay : entity work.dlyreg generic map (
        DLY => 2,
        DW => CHANNEL_COUNT
    ) port map (
        clk_i => adc_clk_i,
        data_i => turn_clock,
        data_o => turn_clock_o
    );


    -- Pull all our DSP output across to the DSP clock
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            sync_busy_o <= to_std_logic(sync_request or sync_holdoff);
            sync_phase_o <= sync_phase;
            sync_error_o <= to_std_logic(sync_error);
            sample_busy_o <= to_std_logic(sample_request);
            sample_phase_o <= sample_phase;
            sample_count_o <= sample_count;
        end if;
    end process;
end;
