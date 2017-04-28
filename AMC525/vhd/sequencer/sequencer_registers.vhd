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
        write_strobe_i : in std_logic_vector(DSP_SEQ_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(DSP_SEQ_REGS);
        read_strobe_i : in std_logic_vector(DSP_SEQ_REGS);
        read_data_o : out reg_data_array_t(DSP_SEQ_REGS);
        read_ack_o : out std_logic_vector(DSP_SEQ_REGS);

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
    signal mem_write_strobe : mem_write_strobe_o'SUBTYPE := (others => '0');
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
                mem_write_strobe, to_integer(write_target), write_strobe);
            if write_strobe = '1' then
                mem_write_addr_o <= write_address;
                mem_write_data_o <= write_data_i;
            end if;
        end if;
    end process;
    write_ack_o(DSP_SEQ_WRITE_REG) <= '1';

    read_data_o(DSP_SEQ_WRITE_REG) <= (others => '0');
    read_ack_o(DSP_SEQ_WRITE_REG) <= '1';

    mem_write_strobe_o <= mem_write_strobe;


    -- -------------------------------------------------------------------------
    -- Register mapping

    seq_abort_o <= strobed_bits(DSP_SEQ_COMMAND_ABORT_BIT);
    start_write <= strobed_bits(DSP_SEQ_COMMAND_WRITE_BIT);

    readback_register <= (
        DSP_SEQ_STATUS_PC_BITS    => std_logic_vector(seq_pc_i),
        DSP_SEQ_STATUS_BUSY_BIT   => seq_busy_i,
        DSP_SEQ_STATUS_SUPER_BITS => std_logic_vector(super_count_i),
        others => '0'
    );

    target_seq_pc_o <=
        seq_pc_t(register_file(DSP_SEQ_CONFIG_PC_BITS));
    trigger_state_o <=
        seq_pc_t(register_file(DSP_SEQ_CONFIG_TRIGGER_BITS));
    target_super_count_o <=
        super_count_t(register_file(DSP_SEQ_CONFIG_SUPER_COUNT_BITS));
    write_target <=
        unsigned(register_file(DSP_SEQ_CONFIG_TARGET_BITS));
end;
