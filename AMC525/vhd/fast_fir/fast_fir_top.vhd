-- ADC input compensation FIR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity fast_fir_top is
    generic (
        TAP_COUNT : natural;
        PIPELINE_IN : natural := 4;
        PIPELINE_OUT : natural := 4
    );
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- Taps write interface
        write_start_i : in std_ulogic;
        write_strobe_i : in std_ulogic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic;

        -- data stream
        data_i : in signed;                 -- on ADC clock
        data_o : out signed;                -- on ADC clock
        overflow_o : out std_ulogic          -- on DSP clock
    );
end;

architecture arch of fast_fir_top is
    signal data_in : data_i'SUBTYPE;
    signal data_out : data_o'SUBTYPE;
    signal taps_in : reg_data_array_t(0 to TAP_COUNT-1);
    signal taps : reg_data_array_t(0 to TAP_COUNT-1);
    signal fir_overflow : std_ulogic;

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
            clk_i => dsp_clk_i,
            write_i => '1',
            data_i => taps_in(i),
            data_o => taps(i)
        );
    end generate;


    -- Pipeline the input data
    delay_input : entity work.dlyreg generic map (
        DLY => PIPELINE_IN,
        DW => data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(data_i),
        signed(data_o) => data_in
    );


    -- The compensation filter itself
    fast_fir : entity work.fast_fir generic map (
        TAP_COUNT => TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        taps_i => taps,
        data_i => data_in,
        data_o => data_out,
        overflow_o => fir_overflow
    );


    -- Pipeline the output data
    delay_output : entity work.dlyreg generic map (
        DLY => PIPELINE_OUT,
        DW => data_o'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(data_out),
        signed(data_o) => data_o
    );

    -- Bring any overflow pulse to the DSP clock domain
    pulse_adc_to_dsp : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        pulse_i => fir_overflow,
        pulse_o => overflow_o
    );
end;
