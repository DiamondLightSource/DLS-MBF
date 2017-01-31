-- Bunch counter, turn clock, and detector bunch selection strobes

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.bunch_defs.all;

entity bunch_select is
    port (
        dsp_clk_i : in std_logic;

        turn_clock_i : in std_logic;           -- Revolution clock

        -- Bunch configuration SBC interface for writing configuration
        -- We use two registers
        write_strobe_i : in std_logic_vector(0 to 1);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 1);
        read_strobe_i : in std_logic_vector(0 to 1);
        read_data_o : out reg_data_array_t(0 to 1);
        read_ack_o : out std_logic_vector(0 to 1);

        write_start_i : in std_logic;           -- Reset write address

        -- Bunch configuration readout
        bank_select_i : in unsigned(1 downto 0);       -- Current bunch bank
        bunch_config_o : out bunch_config_lanes_t
    );
end;

architecture bunch_select of bunch_select is
    -- Our registers are used as follows:
    --
    --  0   RW  8:0     Number of bunches in ring, determines turn_clock_o freq
    --  0   RW  20:12   Bunch to select for bunch zero
    --  0   RW  25:24   Bank currently being written
    --  1   R           (unused)
    --  1   W           Configure selected bank
    constant CONFIG_REG : natural := 0;
    constant BANK_REG_W : natural := 1;
    constant UNUSED_REG_R : natural := 1;
    signal config_register : reg_data_t;

    signal write_bank : unsigned(BUNCH_BANK_BITS-1 downto 0);

    signal bunch_index : bunch_count_t := (others => '0');

begin
    -- Register management
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(CONFIG_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(CONFIG_REG),
        register_data_o(0) => config_register
    );

    -- Readback and unused registers
    read_data_o(CONFIG_REG) <= config_register;
    read_ack_o(CONFIG_REG) <= '1';
    read_data_o(UNUSED_REG_R) <= (others => '0');
    read_ack_o(UNUSED_REG_R) <= '1';

    write_bank <= unsigned(read_field(config_register, BUNCH_BANK_BITS, 24));


    -- Bunch counter
    bunch_counter : entity work.bunch_counter port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,
        bunch_index_o => bunch_index
    );

    -- Bunch bank memory
    bunch_mem : entity work.bunch_store port map (
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(BANK_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(BANK_REG_W),
        write_start_i => write_start_i,
        write_bank_i => write_bank,

        bank_select_i => bank_select_i,
        bunch_index_i => bunch_index,
        config_o => bunch_config_o
    );
end;
