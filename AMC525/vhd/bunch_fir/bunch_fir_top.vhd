-- Top level control for bunch by bunch FIR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.bunch_defs.all;

entity bunch_fir_top is
    generic (
        TAP_WIDTH : natural := 25;
        TAP_COUNT : natural
    );
    port (
        dsp_clk_i : in std_logic;

        data_i : in signed_array;
        data_o : out signed_array;

        turn_clock_i : in std_logic;
        bunch_index_i : in bunch_count_t;
        bunch_config_i : in bunch_config_lanes_t;

        -- General register interface
        write_strobe_i : in std_logic_vector(0 to 1);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 1);
        read_strobe_i : in std_logic_vector(0 to 1);
        read_data_o : out reg_data_array_t(0 to 1);
        read_ack_o : out std_logic_vector(0 to 1);

        -- Pulse events
        write_start_i : in std_logic        -- For register block writes
    );
end;

architecture bunch_fir_top of bunch_fir_top is
    -- Register map
    constant CONFIG_REG : natural := 0;
    constant TAPS_REG : natural := 1;

    -- Control values
    signal config_register : reg_data_t;
    signal write_fir : unsigned(FIR_BANK_BITS-1 downto 0);
    signal decimation_limit : unsigned(6 downto 0);
    signal decimation_shift : unsigned(2 downto 0);

    -- Data types
    subtype TAP_RANGE  is natural range TAP_WIDTH-1 downto 0;
    subtype TAPS_RANGE is natural range TAP_COUNT-1 downto 0;
    signal taps : signed_array_array(LANES)(TAPS_RANGE)(TAP_RANGE);
    signal decimated_data : signed_array(LANES)(15 downto 0);
    signal decimated_valid : std_logic_vector(LANES);

    -- Data flow and decimation control
    signal first_turn : std_logic;
    signal last_turn : std_logic;
    signal filtered_data : signed_array(LANES)(15 downto 0);
    signal filtered_valid : std_logic_vector(LANES);

begin
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(CONFIG_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(CONFIG_REG),
        register_data_o(0) => config_register
    );
    read_data_o(CONFIG_REG) <= config_register;
    read_ack_o(CONFIG_REG) <= '1';

    write_fir <= unsigned(config_register(1 downto 0));
    decimation_limit <= unsigned(config_register(8 downto 2));
    decimation_shift <= unsigned(config_register(11 downto 9));


    -- Taps for FIR
    bunch_fir_taps_inst : entity work.bunch_fir_taps port map (
        dsp_clk_i => dsp_clk_i,

        write_start_i => write_start_i,
        write_fir_i => write_fir,

        write_strobe_i => write_strobe_i(TAPS_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(TAPS_REG),

        bunch_config_i => bunch_config_i,
        taps_o => taps
    );
    read_data_o(TAPS_REG) <= (others => '0');
    read_ack_o(TAPS_REG) <= '1';


    -- Decimation counter
    bunch_fir_counter_inst : entity work.bunch_fir_counter port map (
        dsp_clk_i => dsp_clk_i,
        decimation_limit_i => decimation_limit,
        turn_clock_i => turn_clock_i,
        first_turn_o => first_turn,
        last_turn_o => last_turn
    );

    lanes_gen : for l in LANES generate
        -- Bunch by bunch data reduction
        decimate_inst : entity work.bunch_fir_decimate port map (
            dsp_clk_i => dsp_clk_i,

            bunch_index_i => bunch_index_i,
            decimation_shift_i => decimation_shift,

            first_turn_i => first_turn,
            last_turn_i => last_turn,
            data_i => data_i(l),
            data_o => decimated_data(l),
            data_valid_o => decimated_valid(l)
        );

        -- The filter
        fir_inst : entity work.bunch_fir port map (
            dsp_clk_i => dsp_clk_i,
            bunch_index_i => bunch_index_i,
            taps_i => taps(l),

            data_valid_i => decimated_valid(l),
            data_i => decimated_data(l),
            data_valid_o => filtered_valid(l),
            data_o => filtered_data(l)
        );

        -- Interpolate the reduced data back to full speed
        interpolate_inst : entity work.bunch_fir_interpolate port map (
            dsp_clk_i => dsp_clk_i,
            bunch_index_i => bunch_index_i,
            data_valid_i => filtered_valid(l),
            data_i => filtered_data(l),
            data_o => data_o(l)
        );
    end generate;
end;
