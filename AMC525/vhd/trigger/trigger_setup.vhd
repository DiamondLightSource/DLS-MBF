-- Prepare triggers and gather into a single trigger source.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.trigger_defs.all;

entity trigger_setup is
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- External trigger sources, all asynchronous
        revolution_clock_i : in std_ulogic;
        event_trigger_i : in std_ulogic;
        postmortem_trigger_i : in std_ulogic;
        blanking_trigger_i : in std_ulogic;

        -- Internal trigger sources, all on DSP clock
        soft_trigger_i : in std_ulogic;
        adc_trigger_i : in std_ulogic_vector(CHANNELS);
        seq_trigger_i : in std_ulogic_vector(CHANNELS);

        -- Results
        revolution_clock_o : out std_ulogic;     -- On ADC clock
        blanking_trigger_o : out std_ulogic;
        trigger_set_o : out trigger_set_t
    );
end;

architecture arch of trigger_setup is
    -- Input signals converted to synchronous rising edge pulse
    signal event_trigger : std_ulogic;
    signal postmortem_trigger : std_ulogic;

    -- Delayed soft trigger
    signal soft_trigger_delay : std_ulogic;

    -- Pipelined internal triggers
    signal adc_trigger_in : adc_trigger_i'SUBTYPE;
    signal seq_trigger_in : seq_trigger_i'SUBTYPE;

begin
    -- Note the revolution clock is synchronised to the ADC clock
    revolution_condition_inst : entity work.trigger_condition port map (
        clk_i => adc_clk_i,
        trigger_i => revolution_clock_i,
        trigger_o => revolution_clock_o
    );

    event_condition_inst : entity work.trigger_condition port map (
        clk_i => dsp_clk_i,
        trigger_i => event_trigger_i,
        trigger_o => event_trigger
    );

    postmortem_condition_inst : entity work.trigger_condition port map (
        clk_i => dsp_clk_i,
        trigger_i => postmortem_trigger_i,
        trigger_o => postmortem_trigger
    );

    -- The blanking input is level not edge sensitive, so we just pull the input
    -- over to the DSP clock.
    blanking_condition_inst : entity work.sync_bit port map (
        clk_i => dsp_clk_i,
        bit_i => blanking_trigger_i,
        bit_o => blanking_trigger_o
    );

    -- Delay the soft trigger so we can strobe arm and trigger together
    soft_delay_inst : entity work.dlyline port map (
        clk_i => dsp_clk_i,
        data_i(0) => soft_trigger_i,
        data_o(0) => soft_trigger_delay
    );

    -- Pipeline the internally generated triggers.  These are all DSP clock.
    adc_delay : entity work.dlyreg generic map (
        DLY => 4,
        DW => CHANNEL_COUNT
    ) port map (
        clk_i => dsp_clk_i,
        data_i => adc_trigger_i,
        data_o => adc_trigger_in
    );

    seq_delay : entity work.dlyreg generic map (
        DLY => 4,
        DW => CHANNEL_COUNT
    ) port map (
        clk_i => dsp_clk_i,
        data_i => seq_trigger_i,
        data_o => seq_trigger_in
    );

    -- Gather all the triggers into a single trigger source set
    trigger_set_o <= (
        TRIGGERS_IN_SOFT_BIT => soft_trigger_delay,
        TRIGGERS_IN_EXT_BIT => event_trigger,
        TRIGGERS_IN_PM_BIT => postmortem_trigger,
        TRIGGERS_IN_ADC0_BIT => adc_trigger_in(0),
        TRIGGERS_IN_ADC1_BIT => adc_trigger_in(1),
        TRIGGERS_IN_SEQ0_BIT => seq_trigger_in(0),
        TRIGGERS_IN_SEQ1_BIT => seq_trigger_in(1)
    );
end;
