-- Block ram memory definition for min_max_sum memory.
--
-- Unfortunately Vivado is incapable of synthesising block rams for the kind of
-- memory structure we need.  Instead we have to build it ourself.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.defines.all;

use work.min_max_sum_defs.all;

entity min_max_sum_memory is
    generic (
        READ_DELAY : natural
    );
    port (
        clk_i : in std_logic;

        -- Read interface
        read_addr_i : in unsigned;
        read_data_o : out mms_row_t := mms_reset_value;

        -- Write interface
        write_strobe_i : in std_logic;
        write_addr_i : in unsigned;
        write_data_i : in mms_row_t
    );
end;

architecture arch of min_max_sum_memory is
    constant ADDR_BITS : natural := read_addr_i'LENGTH;

    -- Declare block ram
    subtype bram_row_t is std_logic_vector(MMS_ROW_BITS-1 downto 0);

    signal read_addr : read_addr_i'SUBTYPE;
    signal read_row : bram_row_t;

    signal write_strobe : std_logic;
    signal write_addr : write_addr_i'SUBTYPE;
    signal write_row : bram_row_t;

begin
    -- Delay from read_addr_i to read_data_o
    --  read_addr_i
    --      => read_addr
    --      =(2)=> read_row (block_memory)
    --      => read_data_o
    assert READ_DELAY = 4 severity failure;

    bram : entity work.block_memory generic map (
        ADDR_BITS => ADDR_BITS,
        DATA_BITS => MMS_ROW_BITS,
        READ_DELAY => 2
    ) port map (
        read_clk_i => clk_i,
        read_addr_i => read_addr,
        read_data_o => read_row,
        write_clk_i => clk_i,
        write_strobe_i => write_strobe,
        write_addr_i => write_addr,
        write_data_i => write_row
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            read_addr <= read_addr_i;
            read_data_o <= bits_to_mms_row(read_row);

            write_strobe <= write_strobe_i;
            write_addr <= write_addr_i;
            write_row <= mms_row_to_bits(write_data_i);
        end if;
    end process;
end;
