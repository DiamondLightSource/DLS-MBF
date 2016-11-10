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
    -- Overall register map:
    --
    --  0       W   Strobed bits
    --  0       R   General status bits
    --  1       RW  Latched pulsed events
    --  2-3     RW  ADC registers
    constant STROBE_REG_W : natural := 0;
    constant STATUS_REG_R : natural := 0;
    constant PULSED_REG : natural := 1;
    subtype ADC_REGS is natural range 2 to 3;
    subtype UNUSED_REGS is natural range 4 to write_strobe_i'HIGH;

    -- Number of taps in ADC compensation filter
    constant ADC_FIR_TAP_COUNT : natural := 8;

    signal strobed_bits : reg_data_t;
    signal status_bits : reg_data_t := (others => '0');

    -- Strobed control signals
    signal write_start : std_logic;
    signal delta_reset : std_logic;

    -- Captured pulsed events
    signal pulsed_bits : reg_data_t;
    signal adc_input_overflow : std_logic;
    signal adc_fir_overflow : std_logic;
    signal adc_mms_overflow : std_logic;
    signal adc_delta_event : std_logic;

    -- Data from ADC to FIR
    signal adc_data_in : signed(13 downto 0);
    signal adc_to_fir_data : signed_array(CHANNELS)(15 downto 0);
    signal dac_data_out : signed(15 downto 0);

    -- Quick and dirty bunch counter
    signal bunch_reset : std_logic;
    signal bunch_counter : unsigned(7 downto 0) := (others => '0');

begin
    -- -------------------------------------------------------------------------
    -- General register handling

    -- Strobed bits for single clock control
    strobed_bits_inst : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(STROBE_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(STROBE_REG_W),
        strobed_bits_o => strobed_bits
    );

    write_start <= strobed_bits(0);
    delta_reset <= strobed_bits(1);


    -- Miscellaneous status bits etc
    read_data_o(STATUS_REG_R) <= status_bits;
    read_ack_o(STATUS_REG_R) <= '1';

    status_bits <= (
        others => '0'
    );


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
        0 => adc_input_overflow,    -- ADC out of limit
        1 => adc_fir_overflow,      -- Compensation filter overflow
        2 => adc_mms_overflow,      -- MMS accumulator overflow
        3 => adc_delta_event,       -- Bunch by bunch motion over threshold
        others => '0'
    );


    -- Unused registers
    write_ack_o(UNUSED_REGS) <= (others => '1');
    read_data_o(UNUSED_REGS) <= (others => (others => '0'));
    read_ack_o(UNUSED_REGS) <= (others => '1');


    -- -------------------------------------------------------------------------
    -- Signal processing chain

    -- ADC input processing
    adc_delay : entity work.dlyreg generic map (
        DLY => 2,
        DW => adc_data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(adc_data_i),
        signed(data_o) => adc_data_in
    );

    adc_top_inst : entity work.adc_top generic map (
        TAP_COUNT => ADC_FIR_TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,
        bunch_reset_i => bunch_reset,

        data_i => adc_data_in,
        data_o => adc_to_fir_data,

        write_strobe_i => write_strobe_i(ADC_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(ADC_REGS),
        read_strobe_i => read_strobe_i(ADC_REGS),
        read_data_o => read_data_o(ADC_REGS),
        read_ack_o => read_ack_o(ADC_REGS),

        write_start_i => write_start,
        delta_reset_i => delta_reset,

        input_overflow_o => adc_input_overflow,
        fir_overflow_o => adc_fir_overflow,
        mms_overflow_o => adc_mms_overflow,
        delta_event_o => adc_delta_event
    );



    -- -------------------------------------------------------------------------
    -- Work in progress hacks below


    -- Quick and dirty bunch counter
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            bunch_counter <= bunch_counter + 1;
            bunch_reset <= to_std_logic(bunch_counter = 0);
        end if;
    end process;


    -- Generate the DDR0 data stream
    convert_inst : for c in CHANNELS generate
        ddr0_data_o(c) <= std_logic_vector(adc_to_fir_data(c));
    end generate;

    -- Generate DSP data stream
    dsp_to_adc_inst : entity work.dsp_to_adc port map (
        adc_clk_i => adc_clk_i,
        adc_phase_i => adc_phase_i,

        dsp_data_i => adc_to_fir_data,
        adc_data_o => dac_data_out
    );

    dac_delay : entity work.dlyreg generic map (
        DLY => 2,
        DW => dac_data_o'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(dac_data_out),
        signed(data_o) => dac_data_o
    );

end;
