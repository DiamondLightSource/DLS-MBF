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
        TAP_COUNT : natural
    );
    port (
        dsp_clk_i : in std_logic;
        adc_clk_i : in std_logic;

        data_i : in signed;
        data_o : out signed;

        turn_clock_i : in std_logic;
        bunch_config_i : in bunch_config_t;

        -- General register interface
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- Pulse events
        write_start_i : in std_logic        -- For register block writes
    );
end;

architecture arch of bunch_fir_top is
    -- Control values
    signal turn_clock : std_logic;
    signal config_register : reg_data_t;
    signal write_fir : unsigned(FIR_BANK_BITS-1 downto 0);
    signal decimation_limit : unsigned(6 downto 0);
    signal decimation_shift : unsigned(2 downto 0);

    -- Data types
    subtype TAP_RANGE  is natural range TAP_WIDTH-1 downto 0;
    subtype TAPS_RANGE is natural range 0 to TAP_COUNT-1;
    signal taps : signed_array(TAPS_RANGE)(TAP_RANGE);
    signal decimated_data : signed(15 downto 0);
    signal decimated_valid : std_logic;

    -- Data flow and decimation control
    signal data_in : data_i'SUBTYPE;
    signal bunch_index : bunch_count_t;
    signal first_turn : std_logic;
    signal last_turn : std_logic;
    signal filtered_data : data_o'SUBTYPE;
    signal filtered_valid : std_logic;
    signal data_out : data_o'SUBTYPE;

begin
    register_file : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_FIR_CONFIG_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_FIR_CONFIG_REG),
        register_data_o(0) => config_register
    );
    read_data_o(DSP_FIR_CONFIG_REG) <= config_register;
    read_ack_o(DSP_FIR_CONFIG_REG) <= '1';

    write_fir        <= unsigned(config_register(1 downto 0));
    decimation_limit <= unsigned(config_register(8 downto 2));
    decimation_shift <= unsigned(config_register(11 downto 9));


    -- Taps for FIR
    bunch_fir_taps : entity work.bunch_fir_taps port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        write_start_i => write_start_i,
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
        data_i => std_logic_vector(data_i),
        signed(data_o) => data_in
    );


    -- Decimation counter
    counter : entity work.bunch_fir_counter port map (
        clk_i => adc_clk_i,
        decimation_limit_i => decimation_limit,
        turn_clock_i => turn_clock,
        bunch_index_o => bunch_index,
        first_turn_o => first_turn,
        last_turn_o => last_turn
    );


    -- Bunch by bunch data reduction
    decimate : entity work.bunch_fir_decimate port map (
        clk_i => adc_clk_i,

        bunch_index_i => bunch_index,
        decimation_shift_i => decimation_shift,

        first_turn_i => first_turn,
        last_turn_i => last_turn,
        data_i => data_in,
        data_o => decimated_data,
        data_valid_o => decimated_valid
    );

    -- The filter
    bunch_fir : entity work.bunch_fir port map (
        clk_i => adc_clk_i,
        bunch_index_i => bunch_index,
        taps_i => taps,

        data_valid_i => decimated_valid,
        data_i => decimated_data,
        data_valid_o => filtered_valid,
        data_o => filtered_data
    );

    -- Interpolate the reduced data back to full speed
    interpolate : entity work.bunch_fir_interpolate port map (
        clk_i => adc_clk_i,
        bunch_index_i => bunch_index,
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
        data_i => std_logic_vector(data_out),
        signed(data_o) => data_o
    );
end;
