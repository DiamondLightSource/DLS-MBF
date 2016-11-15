-- ADC input compensation FIR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity fast_fir_top is
    generic (
        TAP_COUNT : natural
    );
    port (
        adc_clk_i : in std_logic;

        -- DSP clocking needed to transport overflow to DSP clock
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- Taps write interface
        write_start_i : in std_logic;
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;

        -- data stream
        data_i : in signed;                 -- on ADC clock
        data_o : out signed;                -- on ADC clock
        overflow_o : out std_logic          -- on DSP clock
    );
end;

architecture fast_fir_top of fast_fir_top is
    signal taps_in : reg_data_array_t(0 to TAP_COUNT-1);
    signal taps : reg_data_array_t(0 to TAP_COUNT-1);
    signal fir_overflow : std_logic;

begin
    -- Single register writes to array of taps
    taps_inst : entity work.register_block port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        write_start_i => write_start_i,

        registers_o => taps_in
    );

    -- Decouple the taps, written on DSP clock, from the FIR on ADC clock
    untimed_taps_gen : for i in 0 to TAP_COUNT-1 generate
        untimed_inst : entity work.untimed_reg generic map (
            WIDTH => REG_DATA_WIDTH
        ) port map (
            clk_in_i => dsp_clk_i,
            clk_out_i => adc_clk_i,
            write_i => '1',
            data_i => taps_in(i),
            data_o => taps(i)
        );
    end generate;

    -- The compensation filter itself
    fast_fir_inst : entity work.fast_fir generic map (
        TAP_COUNT => TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        taps_i => taps,
        data_i => data_i,
        data_o => data_o,
        overflow_o => fir_overflow
    );

    -- Bring any overflow pulse to the DSP clock domain
    pulse_adc_to_dsp_inst : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        pulse_i => fir_overflow,
        pulse_o => overflow_o
    );
end;
