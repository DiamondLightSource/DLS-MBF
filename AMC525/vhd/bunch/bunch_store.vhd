-- Access to both lanes of bunch configuration memory and update interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.bunch_defs.all;

entity bunch_store is
    generic (
        -- Processing delay bank_select_i => config_o for validation
        BUNCH_STORE_DELAY : natural
    );
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- Write interface
        write_strobe_i : in std_ulogic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic;
        write_start_i : in std_ulogic;   -- Reset write address
        write_bank_i : in unsigned;     -- Selects which bank to write

        -- Bunch readout
        bank_select_i : in unsigned;
        bunch_index_i : in unsigned;
        config_o : out std_ulogic_vector
    );
end;

architecture arch of bunch_store is
    -- Assemble address from bank_select_i and bunch_index_i
    constant ADDR_BITS : natural := bank_select_i'LENGTH + bunch_index_i'LENGTH;
    signal bank_select_in : bank_select_i'SUBTYPE := (others => '0');
    signal read_addr : unsigned(ADDR_BITS-1 downto 0) := (others => '0');
    signal write_addr : unsigned(ADDR_BITS-1 downto 0) := (others => '0');

    signal write_word0 : std_ulogic_vector(31 downto 0);
    signal write_word1 : std_ulogic_vector(31 downto 0);
    signal write_word2 : std_ulogic_vector(28 downto 0);

    type write_phase_t is (WORD0, WORD1, WORD2);
    signal write_phase : write_phase_t;
    signal write_bunch : bunch_index_i'SUBTYPE;
    signal write_strobe : std_ulogic := '0';

    -- Block memory read delay
    constant READ_DELAY : natural := 2;

begin
    -- bank_select_i
    --  => bank_select_in
    --  => read_addr
    --  =(READ_DELAY)=> config_o
    assert BUNCH_STORE_DELAY = READ_DELAY + 2 severity failure;

    -- Bunch memory for each line
    memory_inst : entity work.block_memory generic map (
        ADDR_BITS => ADDR_BITS,
        DATA_BITS => BUNCH_CONFIG_BITS,
        READ_DELAY => READ_DELAY
    ) port map (
        read_clk_i => adc_clk_i,
        read_addr_i => read_addr,
        read_data_o => config_o,
        write_clk_i => dsp_clk_i,
        write_strobe_i => write_strobe,
        write_addr_i => write_addr,
        write_data_i => write_word2 & write_word1 & write_word0
    );

    -- Bring result to ADC clock
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            -- Assemble addresses from selected bank and target bunch
            bank_select_in <= bank_select_i;
            read_addr <= bank_select_in & bunch_index_i;
        end if;
    end process;


    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if write_start_i = '1' then
                -- Reset write back to start
                write_bunch <= (others => '0');
                write_phase <= WORD0;
            elsif write_strobe_i = '1' then
                -- Assemble three words into a single write
                case write_phase is
                    when WORD0 =>
                        write_word0 <= write_data_i;
                        write_phase <= WORD1;
                    when WORD1 =>
                        write_word1 <= write_data_i;
                        write_phase <= WORD2;
                    when WORD2 =>
                        write_word2 <= write_data_i(28 downto 0);
                        write_phase <= WORD0;
                end case;

                if write_phase = WORD2 then
                    -- Write this word and advance to next entry
                    write_addr <= write_bank_i & write_bunch;
                    write_bunch <= write_bunch + 1;
                end if;
            end if;

            write_strobe <=
                write_strobe_i and to_std_ulogic(write_phase = WORD2);
        end if;
    end process;

    write_ack_o <= '1';
end;
