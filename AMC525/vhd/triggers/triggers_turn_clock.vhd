-- Management of turn clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity triggers_turn_clock is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- Control interface
        start_sync_i : in std_logic;    -- Resynchronise request
        start_sample_i : in std_logic;
        max_bunch_i : in bunch_count_t; -- Ring size
        clock_offsets_i : in unsigned_array(CHANNELS)(bunch_count_t'RANGE);

        -- Status readback
        sync_done_o : out std_logic;
        sync_phase_o : out std_logic;
        sync_error_o : out std_logic;
        sample_done_o : out std_logic;
        sample_phase_o : out std_logic;
        sample_count_o : out bunch_count_t;

        -- Input clock
        revolution_clock_i : in std_logic;
        -- Generated turn clocks, one per channel
        turn_clock_o : out std_logic_vector(CHANNELS)
    );
end;

architecture triggers_turn_clock of triggers_turn_clock is
    -- Incoming revolution clock
    signal rev_clock_adc : std_logic;
    signal rev_clock_adc_dsp : std_logic;
    signal rev_clock_dsp : std_logic;
    signal clock_phase_adc : std_logic;
    signal clock_phase_dsp : std_logic;

    signal bunch_counter : bunch_count_t := (others => '0');

    -- Synchronisation and sample state
    signal sync_request : boolean := false;
    signal sync_holdoff : boolean := false;
    signal sync_phase : std_logic;
    signal sync_ok : boolean := true;
    signal sync_error : boolean := false;
    signal sample_request : boolean := false;

begin
    -- -------------------------------------------------------------------------
    -- Revolution clock at ADC clock rate

    -- Convert revolution clock into synchronous rising edge event
    condition_inst : entity work.triggers_condition port map (
        clk_i => adc_clk_i,
        trigger_i => revolution_clock_i,
        trigger_o => rev_clock_adc
    );

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            -- Pick up the turn clock phase
            if rev_clock_adc = '1' then
                clock_phase_adc <= adc_phase_i;
            end if;

            -- Convert event into event on dsp clock
            if rev_clock_adc = '1' then
                rev_clock_adc_dsp <= '1';
            elsif adc_phase_i = '0' then
                rev_clock_adc_dsp <= '0';
            end if;
        end if;
    end process;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Bring trigger and phase over to DSP clock
            clock_phase_dsp <= clock_phase_adc;
            rev_clock_dsp <= rev_clock_adc_dsp;
        end if;
    end process;


    -- -------------------------------------------------------------------------
    -- Normal processing at DSP clock rate

    -- Two signals from revolution clock:
    --  rev_clock_dsp       Revolution clock synchronised to DSP clock
    --  clock_phase_dsp     Phase of revolution clock relative to ADC clock

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Synchronise or else advance base bunch counter
            if rev_clock_dsp = '1' and sync_request then
                bunch_counter <= (others => '0');
                sync_phase <= clock_phase_dsp;
                sync_holdoff <= true;
            elsif bunch_counter = max_bunch_i then
                bunch_counter <= (others => '0');
                sync_holdoff <= false;
            else
                bunch_counter <= bunch_counter + 1;
            end if;

            -- Synchronisation request.
            if start_sync_i = '1' then
                sync_request <= true;
            elsif rev_clock_dsp = '1' then
                sync_request <= false;
            end if;
            sync_done_o <= to_std_logic(not sync_request and not sync_holdoff);


            -- Check synchronisation
            if rev_clock_dsp = '1' then
                sync_ok <=
                    sync_phase = clock_phase_dsp and
                    bunch_counter = max_bunch_i;
            else
                sync_ok <= true;
            end if;
            if sync_request or sync_holdoff then
                sync_error <= false;
            else
                sync_error <= sync_error or not sync_ok;
            end if;


            -- Sample bunch counter
            if rev_clock_dsp = '1' and sample_request then
                sample_count_o <= bunch_counter;
                sample_phase_o <= clock_phase_dsp;
            end if;

            -- Sample request.
            if start_sample_i = '1' then
                sample_request <= true;
            elsif rev_clock_dsp = '1' then
                sample_request <= false;
            end if;


            -- Output of channel specific turn clocks
            for c in CHANNELS loop
                if sync_request or sync_holdoff then
                    turn_clock_o(c) <= '0';
                else
                    turn_clock_o(c) <=
                        to_std_logic(bunch_counter = clock_offsets_i(c));
                end if;
            end loop;
        end if;
    end process;

    sync_error_o <= to_std_logic(sync_error);
    sync_phase_o <= sync_phase;
    sample_done_o <= to_std_logic(not sample_request);
end;
