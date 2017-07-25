-- Implements detector bunch selection and output scaling

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;
use work.detector_defs.all;

entity detector_body is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;

        -- Bunch selection control on DSP clock
        start_write_i : in std_logic;
        bunch_write_i : in std_logic;
        write_data_i : in reg_data_t;

        -- Data in, all on ADC clock
        data_i : in signed(24 downto 0);
        iq_i : in cos_sin_18_t;
        start_i : in std_logic;
        write_i : in std_logic;

        -- Error events, all on DSP clock
        detector_overflow_o : out std_logic;
        output_underrun_o : out std_logic;

        -- Output scaling control on DSP clock
        output_scaling_i : in unsigned(1 downto 0);

        -- Detector data out, all on ADC clock, with AXI style handshake
        valid_o : out std_logic;
        ready_i : in std_logic;
        data_o : out std_logic_vector(63 downto 0)
    );
end;

architecture arch of detector_body is
    signal bunch_enable : std_logic;

    signal detector_overflow : std_logic;
    signal det_write : std_logic;
    signal det_iq : cos_sin_96_t;
    signal iq_shift : cos_sin_96_t;
    signal iq_out : cos_sin_32_t;

    signal shift : integer;
    signal base_mask : unsigned(95 downto 0) := (others => '1');
    signal overflow_mask : signed(95 downto 0);
    signal preload : signed(95 downto 0);

    signal det_write_dsp : std_logic;
    signal det_write_out : std_logic;

begin
    -- Bunch selection
    bunch_select : entity work.detector_bunch_select port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,

        start_write_i => start_write_i,
        write_strobe_i => bunch_write_i,
        write_data_i => write_data_i,

        bunch_enable_o => bunch_enable
    );


    -- Compute preload and overflow detection mask for output shift.
    shift <= 8 * to_integer(output_scaling_i) + 24;
    preload <= shift_left(96X"0_0000_0000_0000_0000_0000_0001", shift - 1);
    -- The overflow mask determines which bits will be used for overflow
    -- detection: we need to include all discarded bits plus our generated sign
    -- bit, hence the base shift of 65 = 96 - 32 - 1.
    overflow_mask <= signed(shift_right(base_mask, 65 - shift));


    -- IQ Detector
    detector : entity work.detector_core port map (
        clk_i => adc_clk_i,

        data_i => data_i,
        iq_i => iq_i,
        bunch_enable_i => bunch_enable,
        detector_overflow_o => detector_overflow,

        overflow_mask_i => overflow_mask,
        preload_i => preload,

        start_i => start_i,
        write_i => write_i,
        write_o => det_write,
        iq_o => det_iq
    );

    write_to_dsp : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        pulse_i => det_write,
        pulse_o => det_write_dsp
    );

    -- Shift of detector output
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            iq_shift <= det_iq;
            if det_write_dsp = '1' then
                iq_out.cos <= shift_right(iq_shift.cos, shift)(31 downto 0);
                iq_out.sin <= shift_right(iq_shift.sin, shift)(31 downto 0);
            end if;
            det_write_out <= det_write_dsp;
        end if;
    end process;


    -- Bring overflows over to DSP clock
    detector_to_dsp : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        pulse_i => detector_overflow,
        pulse_o => detector_overflow_o
    );


    -- Make output available to DRAM
    output : entity work.detector_output port map (
        dsp_clk_i => dsp_clk_i,

        write_i => det_write_out,
        data_i => iq_out,

        output_valid_o => valid_o,
        output_ready_i => ready_i,
        output_data_o => data_o,
        output_underrun_o => output_underrun_o
    );
end;
