-- Sequencer register mapping

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.sequencer_defs.all;

entity sequencer_registers is
    port (
        dsp_clk_i : in std_logic;

        -- Register interface
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- Sequencer configuration settings
        seq_abort_o : out std_logic;
        target_seq_pc_o : out seq_pc_t;
        target_super_count_o : out super_count_t;
        trigger_state_o : out seq_pc_t;

        -- State readbacks
        seq_pc_i : in seq_pc_t;
        super_count_i : in super_count_t;
        seq_busy_i : in std_logic;

        -- Burst memory write interface
        mem_write_strobe_o : out std_logic_vector;
        mem_write_addr_o : out unsigned;
        mem_write_data_o : out reg_data_t
    );
end;

architecture arch of sequencer_registers is
    signal strobed_bits : reg_data_t;
    signal readback_register : reg_data_t;
    signal register_file : reg_data_t;

    constant WRITE_LENGTH : natural := mem_write_strobe_o'LENGTH;
    signal start_write : std_logic;
    signal write_target : unsigned(bits(WRITE_LENGTH)-1 downto 0);
    signal write_address : mem_write_addr_o'SUBTYPE;
    signal write_strobe : std_logic;

begin
    -- -------------------------------------------------------------------------
    -- Core register interface

    strobed_bits_inst : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(DSP_SEQ_COMMAND_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_SEQ_COMMAND_REG_W),

        strobed_bits_o => strobed_bits
    );

    read_data_o(DSP_SEQ_STATUS_REG_R) <= readback_register;
    read_ack_o(DSP_SEQ_STATUS_REG_R) <= '1';

    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,

        write_strobe_i(0) => write_strobe_i(DSP_SEQ_CONFIG_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_SEQ_CONFIG_REG),

        register_data_o(0) => register_file
    );

    read_data_o(DSP_SEQ_CONFIG_REG) <= register_file;
    read_ack_o(DSP_SEQ_CONFIG_REG) <= '1';


    -- Block write support
    write_strobe <= write_strobe_i(DSP_SEQ_WRITE_REG);
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if start_write = '1' then
                write_address <= (others => '0');
            elsif write_strobe = '1' then
                write_address <= write_address + 1;
            end if;

            compute_strobe(
                mem_write_strobe_o, to_integer(write_target), write_strobe);
            if write_strobe = '1' then
                mem_write_addr_o <= write_address;
                mem_write_data_o <= write_data_i;
            end if;
        end if;
    end process;
    write_ack_o(DSP_SEQ_WRITE_REG) <= '1';

    read_data_o(DSP_SEQ_WRITE_REG) <= (others => '0');
    read_ack_o(DSP_SEQ_WRITE_REG) <= '1';


    -- -------------------------------------------------------------------------
    -- Register mapping

    seq_abort_o <= strobed_bits(0);
    start_write <= strobed_bits(1);

    readback_register <= (
        2 downto 0 => std_logic_vector(seq_pc_i),
        4 => seq_busy_i,
        17 downto 8 => std_logic_vector(super_count_i),
        others => '0'
    );

    target_seq_pc_o <= seq_pc_t(register_file(2 downto 0));
    trigger_state_o <= seq_pc_t(register_file(6 downto 4));
    target_super_count_o <= super_count_t(register_file(17 downto 8));
    write_target <= unsigned(register_file(29 downto 28));
end;
