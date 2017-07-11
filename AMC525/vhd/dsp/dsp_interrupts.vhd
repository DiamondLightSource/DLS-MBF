-- Top level controller for DSP units.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;

entity dsp_interrupts is
    port (
        dsp_clk_i : in std_logic;

        -- Interrupt sources
        dram0_capture_enable_i : in std_logic;
        dram0_trigger_i : in std_logic;
        seq_start_i : in std_logic_vector(CHANNELS);

        interrupts_o : out std_logic_vector
    );
end;

architecture arch of dsp_interrupts is
    signal dram0_trigger : std_logic;
    signal seq_start : std_logic_vector(CHANNELS);
    signal interrupts : interrupts_o'SUBTYPE;

    constant INTERRUPT_PIPELINE : natural := 4;

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
        0 => dram0_capture_enable_i,
        1 => not dram0_capture_enable_i,
        2 => dram0_trigger,
        3 => seq_start(0),
        4 => seq_start(1),
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
