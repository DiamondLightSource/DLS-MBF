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
        dsp_clk_i : in std_logic;

        turn_clock_i : in std_logic;           -- Revolution clock

        -- Bunch configuration SBC interface for writing configuration
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- Bunch configuration readout
        bank_select_i : in unsigned(1 downto 0);       -- Current bunch bank
        bunch_config_o : out bunch_config_lanes_t
    );
end;

architecture bunch_select of bunch_select is
    signal config_register : reg_data_t;

    signal write_start : std_logic;
    signal write_bank : unsigned(BUNCH_BANK_BITS-1 downto 0);

    signal bunch_index : bunch_count_t := (others => '0');

begin
    -- Register management
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_BUNCH_CONFIG_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_BUNCH_CONFIG_REG),
        register_data_o(0) => config_register
    );

    read_data_o <= (read_data_o'RANGE => (others => '0'));
    read_ack_o <= (read_ack_o'RANGE => '1');

    write_start <= write_strobe_i(DSP_BUNCH_CONFIG_REG);
    write_bank <= unsigned(config_register(1 downto 0));


    -- Bunch counter
    bunch_counter : entity work.bunch_counter port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,
        bunch_index_o => bunch_index
    );

    -- Bunch bank memory
    bunch_mem : entity work.bunch_store port map (
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(DSP_BUNCH_BANK_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_BUNCH_BANK_REG_W),
        write_start_i => write_start,
        write_bank_i => write_bank,

        bank_select_i => bank_select_i,
        bunch_index_i => bunch_index,
        config_o => bunch_config_o
    );
end;
