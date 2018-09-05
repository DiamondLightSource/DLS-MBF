-- Top level controller for DSP units.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;

entity dsp_interrupts is
    port (
        dsp_clk_i : in std_ulogic;

        -- Interrupt sources
        dram0_capture_enable_i : in std_ulogic;
        dram0_trigger_i : in std_ulogic;
        seq_start_i : in std_ulogic_vector(CHANNELS);
        seq_busy_i : in std_ulogic_vector(CHANNELS);

        interrupts_o : out std_ulogic_vector
    );
end;

architecture arch of dsp_interrupts is
    signal dram0_trigger : std_ulogic;
    signal seq_start : std_ulogic_vector(CHANNELS);
    signal interrupts : interrupts_o'SUBTYPE;

    constant INTERRUPT_PIPELINE : natural := 8;

begin
    -- Stretch each interrupt pulse so it's not missed by the interrupt
    -- receiver.
    stretch_dram0 : entity work.stretch_pulse port map (
        clk_i => dsp_clk_i,
        pulse_i(0) => dram0_trigger_i,
        pulse_o(0) => dram0_trigger
    );

    strech_seq_start : entity work.stretch_pulse generic map (
        WIDTH => CHANNEL_COUNT
    ) port map (
        clk_i => dsp_clk_i,
        pulse_i => seq_start_i,
        pulse_o => seq_start
    );

    -- Assemble interrupt events mask
    interrupts <= (
        INTERRUPTS_DRAM_BUSY_BIT => dram0_capture_enable_i,
        INTERRUPTS_DRAM_DONE_BIT => not dram0_capture_enable_i,
        INTERRUPTS_DRAM_TRIGGER_BIT => dram0_trigger,
        INTERRUPTS_SEQ_TRIGGER_BITS => reverse(seq_start),
        INTERRUPTS_SEQ_BUSY_BITS => reverse(seq_busy_i),
        INTERRUPTS_SEQ_DONE_BITS => reverse(not seq_busy_i),
        others => '0'
    );

    -- Interrupt assignment and pipeline to help with placement.
    interrupt_delay : entity work.dlyreg generic map (
        DLY => INTERRUPT_PIPELINE,
        DW => interrupts'LENGTH
    ) port map (
        clk_i => dsp_clk_i,
        data_i => interrupts,
        data_o => interrupts_o
    );
end;
