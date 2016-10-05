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
        dsp_clk_ok_i : in std_logic;    -- Needed to sync ADC and DSP clocks

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
    constant COMMAND_REG : natural := 0;
    subtype REG_FILE_RANGE is natural range 0 to 4;
    subtype UNUSED_REG is natural range 5 to REG_ADDR_COUNT-1;

    signal register_file : reg_data_array_t(REG_FILE_RANGE);
    signal command_register : reg_data_t;

    signal reset_dummy_adc : std_logic;
    signal reset_dummy_adc_dsp : std_logic;
    signal dummy_adc : adc_inp_t;
    signal dummy_adc_pl : adc_inp_t;
    signal dummy_dsp : adc_inp_channels;
    signal dummy_dsp_out : ddr0_data_channels;
    signal dsp_data_in : adc_inp_channels;
    signal dsp_data_out : ddr0_data_channels;

    signal output_mux_select : std_logic;

begin
    -- Register file
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(REG_FILE_RANGE),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(REG_FILE_RANGE),
        read_strobe_i => read_strobe_i(REG_FILE_RANGE),
        read_data_o => read_data_o(REG_FILE_RANGE),
        read_ack_o => read_ack_o(REG_FILE_RANGE),
        register_data_o => register_file
    );

    command_register <= register_file(COMMAND_REG);
    output_mux_select <= command_register(0);

    reset_dummy_inst : entity work.dlyline generic map (
        DLY => 2
    ) port map (
        clk_i => dsp_clk_i,
        data_i(0) => dsp_control_i.dummy,
        data_o(0) => reset_dummy_adc_dsp
    );
    reset_dummy_adc_inst : entity work.dlyline generic map (
        DLY => 2
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => reset_dummy_adc_dsp,
        data_o(0) => reset_dummy_adc
    );


    -- Unused registers
    write_ack_o(UNUSED_REG) <= (others => '1');
    read_data_o(UNUSED_REG) <= (others => (others => '0'));
    read_ack_o(UNUSED_REG) <= (others => '1');


    -- Dummy ADC data for testing
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            if reset_dummy_adc = '1' then
                dummy_adc <= (others => '0');
            else
                dummy_adc <= dummy_adc + 1;
            end if;
            dummy_adc_pl <= dummy_adc;
        end if;
    end process;

    dummy_to_dsp_inst : entity work.adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        dsp_clk_ok_i => dsp_clk_ok_i,

        adc_data_i => dummy_adc_pl,
        dsp_data_o => dummy_dsp
    );

    -- For the moment all we do is output our data stream
    adc_to_dsp_inst : entity work.adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        dsp_clk_ok_i => dsp_clk_ok_i,

        adc_data_i => adc_data_i,
        dsp_data_o => dsp_data_in
    );

    resize_gen : for c in CHANNELS generate
        dummy_dsp_out(c) <= std_logic_vector(resize(dummy_dsp(c), 16));
        dsp_data_out(c) <= std_logic_vector(resize(dsp_data_in(c), 16));
    end generate;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            case output_mux_select is
                when '0' => ddr0_data_o <= dummy_dsp_out;
                when '1' => ddr0_data_o <= dsp_data_out;
            end case;
        end if;
    end process;

    adc_to_dac_inst : entity work.dlyreg generic map (
        DLY => 3,
        DW => 16
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(adc_data_i) & "00",
        signed(data_o) => dac_data_o
    );

end;
