-- ADC input compensation FIR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity adc_fir is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- Taps write interface
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        -- Write reset
        write_reset_i : in std_logic;

        -- ADC data stream
        data_i : in adc_inp_t;
        data_o : out signed(15 downto 0);
        overflow_o : out std_logic
    );
end;

architecture adc_fir of adc_fir is
    constant TAP_COUNT : natural := 8;
    signal taps    : reg_data_array_t(0 to TAP_COUNT-1);
    signal fir_overflow : std_logic;

begin
    -- Single register writes to array of taps
    taps_inst : entity work.untimed_register_block generic map (
        COUNT => TAP_COUNT
    ) port map (
        clk_in_i => dsp_clk_i,
        clk_out_i => adc_clk_i,

        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,

        write_reset_i => write_reset_i,

        registers_o => taps
    );

    fast_fir_inst : entity work.fast_fir generic map (
        TAP_WIDTH => 18,
        TAP_COUNT => TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        taps_i => taps,
        data_i => data_i,
        data_o => data_o,
        overflow_o => fir_overflow
    );

    pulse_adc_to_dsp_inst : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        pulse_i => fir_overflow,
        pulse_o => overflow_o
    );

end;
