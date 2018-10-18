-- Top level control for bunch by bunch FIR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.bunch_defs.all;

entity bunch_fir_top is
    generic (
        TAP_WIDTH : natural := 25;
        TAP_COUNT : natural;
        HEADROOM_OFFSET : natural
    );
    port (
        dsp_clk_i : in std_ulogic;
        adc_clk_i : in std_ulogic;

        data_i : in signed;
        data_o : out signed;

        turn_clock_i : in std_ulogic;
        bunch_config_i : in bunch_config_t;

        -- General register interface
        write_strobe_i : in std_ulogic_vector(DSP_FIR_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_FIR_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_FIR_REGS);
        read_data_o : out reg_data_array_t(DSP_FIR_REGS);
        read_ack_o : out std_ulogic_vector(DSP_FIR_REGS)
    );
end;

architecture arch of bunch_fir_top is
    -- Control values
    signal turn_clock : std_ulogic;
    signal config_register : reg_data_t;
    signal write_fir : unsigned(FIR_BANK_BITS-1 downto 0);
    signal decimation_limit : unsigned(6 downto 0);
    signal decimation_shift : unsigned(2 downto 0);
    signal write_start : std_ulogic;

    -- Overflow detection
    signal pulsed_bits : reg_data_t;
    signal overflow : std_ulogic;

    -- Data types
    subtype TAP_RANGE  is natural range TAP_WIDTH-1 downto 0;
    subtype TAPS_RANGE is natural range 0 to TAP_COUNT-1;
    signal taps : signed_array(TAPS_RANGE)(TAP_RANGE);
    signal decimated_data : signed(15 downto 0);
    signal decimated_valid : std_ulogic;

    -- Data flow and decimation control
    signal data_in : data_i'SUBTYPE;
    signal filtered_data : data_o'SUBTYPE;
    signal filtered_valid : std_ulogic;
    signal data_out : data_o'SUBTYPE;

begin
    register_file : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_FIR_CONFIG_REG_W),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_FIR_CONFIG_REG_W),
        register_data_o(0) => config_register
    );

    all_pulsed_bits : entity work.all_pulsed_bits port map (
        clk_i => dsp_clk_i,
        read_strobe_i => read_strobe_i(DSP_FIR_EVENTS_REG_R),
        read_data_o => read_data_o(DSP_FIR_EVENTS_REG_R),
        read_ack_o => read_ack_o(DSP_FIR_EVENTS_REG_R),
        pulsed_bits_i => pulsed_bits
    );

    -- Use write to config register to trigger start of taps write
    write_start <= write_strobe_i(DSP_FIR_CONFIG_REG_W);

    write_fir        <= unsigned(config_register(DSP_FIR_CONFIG_BANK_BITS));
    decimation_limit <= unsigned(config_register(DSP_FIR_CONFIG_LIMIT_BITS));
    decimation_shift <= unsigned(config_register(DSP_FIR_CONFIG_SHIFT_BITS));

    pulsed_bits <= (
        DSP_FIR_EVENTS_OVERFLOW_BIT => overflow,
        others => '0'
    );


    -- Taps for FIR
    bunch_fir_taps : entity work.bunch_fir_taps port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        write_start_i => write_start,
        write_fir_i => write_fir,

        write_strobe_i => write_strobe_i(DSP_FIR_TAPS_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_FIR_TAPS_REG),

        fir_select_i => bunch_config_i.fir_select,
        taps_o => taps
    );
    read_data_o(DSP_FIR_TAPS_REG) <= (others => '0');
    read_ack_o(DSP_FIR_TAPS_REG) <= '1';


    turn_clock_delay : entity work.dlyreg generic map (
        DLY => 4
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => turn_clock_i,
        data_o(0) => turn_clock
    );

    data_delay : entity work.dlyreg generic map (
        DLY => 6,
        DW => data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(data_i),
        signed(data_o) => data_in
    );


    -- Bunch by bunch data reduction
    decimate : entity work.bunch_fir_decimate port map (
        clk_i => adc_clk_i,

        turn_clock_i => turn_clock,
        decimation_shift_i => decimation_shift,
        decimation_limit_i => decimation_limit,

        data_i => data_in,
        data_o => decimated_data,
        data_valid_o => decimated_valid
    );

    -- The filter
    bunch_fir : entity work.bunch_fir generic map (
        HEADROOM_OFFSET => HEADROOM_OFFSET
    ) port map (
        clk_i => adc_clk_i,
        turn_clock_i => turn_clock,
        taps_i => taps,

        data_valid_i => decimated_valid,
        data_i => decimated_data,
        data_valid_o => filtered_valid,
        data_o => filtered_data,
        overflow_o => overflow
    );

    -- Interpolate the reduced data back to full speed
    interpolate : entity work.bunch_fir_interpolate port map (
        clk_i => adc_clk_i,
        turn_clock_i => turn_clock,
        data_valid_i => filtered_valid,
        data_i => filtered_data,
        data_o => data_out
    );

    -- need data_o pipeline here
    filtered_delay : entity work.dlyreg generic map (
        DLY => 4,
        DW => data_o'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(data_out),
        signed(data_o) => data_o
    );
end;
