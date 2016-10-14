-- Top level DSP.  Takes ADC data in, generates DAC data out.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity dsp_top is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- External data in and out
        adc_data_i : in adc_inp_t;
        dac_data_o : out dac_out_t;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in reg_strobe_t;
        write_data_i : in reg_data_t;
        write_ack_o : out reg_strobe_t;
        read_strobe_i : in reg_strobe_t;
        read_data_o : out reg_data_array_t;
        read_ack_o : out reg_strobe_t;

        -- Data out to DDR0 (two channels of 16-bit numbers)
        ddr0_data_o : out ddr0_data_channels;

        -- Data out to DDR1
        ddr1_data_o : out ddr1_data_t;
        ddr1_data_strobe_o : out std_logic;

        -- External control (not yet defined)
        dsp_control_i : in dsp_control_t;
        dsp_status_o : out dsp_status_t
    );
end;

architecture dsp_top of dsp_top is
    constant STROBE_REG : natural := 0;
    constant ADC_TAPS_REG : natural := 1;
    constant PULSED_REG : natural := 2;
    subtype UNUSED_REG is natural range 3 to REG_ADDR_COUNT-1;

    signal strobed_bits : reg_data_t;
    signal write_reset : std_logic;
    signal pulsed_bits : reg_data_t;

    signal adc_data_delay : adc_inp_t;
    signal adc_data_fir : signed(15 downto 0);
    signal adc_fir_overflow : std_logic;

    signal dsp_data_in : dac_out_channels;

begin
    -- Strobed bits for single clock control
    strobed_bits_inst : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(STROBE_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(STROBE_REG),
        strobed_bits_o => strobed_bits
    );
    read_data_o(STROBE_REG) <= (others => '0');
    read_ack_o(STROBE_REG) <= '1';

    write_reset <= strobed_bits(0);

    -- Capture of single clock events
    pulsed_bits_inst : entity work.pulsed_bits port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(PULSED_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(PULSED_REG),
        read_strobe_i => read_strobe_i(PULSED_REG),
        read_data_o => read_data_o(PULSED_REG),
        read_ack_o => read_ack_o(PULSED_REG),

        pulsed_bits_i => pulsed_bits
    );

    pulsed_bits <= (
        0 => adc_fir_overflow,
        others => '0'
    );

    -- Unused registers
    write_ack_o(UNUSED_REG) <= (others => '1');
    read_data_o(UNUSED_REG) <= (others => (others => '0'));
    read_ack_o(UNUSED_REG) <= (others => '1');


    -- Pipeline input data to help with timing
    dlyreg_inst : entity work.dlyreg generic map (
        DLY => 2,
        DW => ADC_INP_WIDTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(adc_data_i),
        signed(data_o) => adc_data_delay
    );

    -- ADC compensation fir
    adc_fir_inst : entity work.adc_fir port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        write_strobe_i => write_strobe_i(ADC_TAPS_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(ADC_TAPS_REG),
        write_reset_i => write_reset,

        data_i => adc_data_delay,
        data_o => adc_data_fir,
        overflow_o => adc_fir_overflow
    );
    read_data_o(ADC_TAPS_REG) <= (others => '0');
    read_ack_o(ADC_TAPS_REG) <= '1';


    -- Convert from ADC rate data to DSP rate by doubling up the stream into
    -- concurrent channels.
    adc_to_dsp_inst : entity work.adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        adc_data_i => adc_data_fir,
        dsp_data_o => dsp_data_in
    );

    -- Generate the DDR0 data stream
    convert_inst : for c in CHANNELS generate
        ddr0_data_o(c) <= std_logic_vector(dsp_data_in(c));
    end generate;

    -- Generate DSP data stream
    dsp_to_adc_inst : entity work.dsp_to_adc port map (
        adc_clk_i => adc_clk_i,
        adc_phase_i => adc_phase_i,

        dsp_data_i => dsp_data_in,
        adc_data_o => dac_data_o
    );

end;
