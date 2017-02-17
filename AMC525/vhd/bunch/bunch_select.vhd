-- Bunch counter, turn clock, and detector bunch selection strobes

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.bunch_defs.all;

entity bunch_select is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;
        turn_clock_adc_i : in std_logic;       -- Revolution clock

        -- Bunch configuration SBC interface for writing configuration
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- Bunch configuration readout
        bank_select_i : in unsigned(1 downto 0);       -- Current bunch bank
        bunch_config_lanes_o : out bunch_config_lanes_t;
        bunch_config_o : out bunch_config_t
    );
end;

architecture bunch_select of bunch_select is
    signal write_strobe : write_strobe_i'SUBTYPE;
    signal write_data : write_data_i'SUBTYPE;
    signal write_ack : write_ack_o'SUBTYPE;

    signal config_register : reg_data_t;

    signal write_start : std_logic;
    signal write_bank : unsigned(BUNCH_BANK_BITS-1 downto 0);

    signal bunch_index : bunch_count_t := (others => '0');

    -- Temporary
    signal adc_phase : std_logic;
    signal bunch_config_lanes : bunch_config_lanes_t;

begin
    -- Bring writes over to ADC domain
    register_write_adc : entity work.register_write_adc port map (
        dsp_clk_i => dsp_clk_i,
        adc_clk_i => adc_clk_i,
        adc_phase_i => adc_phase_i,

        dsp_write_strobe_i => write_strobe_i,
        dsp_write_data_i => write_data_i,
        dsp_write_ack_o => write_ack_o,

        adc_write_strobe_o => write_strobe,
        adc_write_data_o => write_data,
        adc_write_ack_i => write_ack
    );

    -- Register management
    register_file_inst : entity work.register_file port map (
        clk_i => adc_clk_i,
        write_strobe_i(0) => write_strobe(DSP_BUNCH_CONFIG_REG),
        write_data_i => write_data,
        write_ack_o(0) => write_ack(DSP_BUNCH_CONFIG_REG),
        register_data_o(0) => config_register
    );

    read_data_o <= (read_data_o'RANGE => (others => '0'));
    read_ack_o <= (read_ack_o'RANGE => '1');

    write_start <= write_strobe(DSP_BUNCH_CONFIG_REG);
    write_bank <= unsigned(config_register(1 downto 0));


    -- Bunch counter
    bunch_counter : entity work.bunch_counter port map (
        clk_i => adc_clk_i,
        turn_clock_i => turn_clock_adc_i,
        bunch_index_o => bunch_index
    );

    -- Bunch bank memory
    bunch_mem : entity work.bunch_store port map (
        clk_i => adc_clk_i,

        write_strobe_i => write_strobe(DSP_BUNCH_BANK_REG_W),
        write_data_i => write_data,
        write_ack_o => write_ack(DSP_BUNCH_BANK_REG_W),
        write_start_i => write_start,
        write_bank_i => write_bank,

        bank_select_i => bank_select_i,
        bunch_index_i => bunch_index,
        config_o => bunch_config_o
    );


    -- For now gather the bunch configuration into lanes
    dly_adc_phase : entity work.dlyreg generic map (
        DLY => 2
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => adc_phase_i,
        data_o(0) => adc_phase
    );
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            bunch_config_lanes(to_integer(adc_phase)) <= bunch_config_o;
        end if;
    end process;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            bunch_config_lanes_o <= bunch_config_lanes;
        end if;
    end process;

end;
