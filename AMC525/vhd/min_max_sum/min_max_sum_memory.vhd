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
        ADDR_BITS : natural
    );
    port (
        clk_i : in std_logic;

        -- Read interface
        read_addr_i : in unsigned(ADDR_BITS-1 downto 0);
        read_data_o : out mms_row_channels_t;

        -- Write interface
        write_strobe_i : in std_logic;
        write_addr_i : in unsigned(ADDR_BITS-1 downto 0);
        write_data_i : in mms_row_channels_t
    );
end;

architecture min_max_sum_memory of min_max_sum_memory is
    -- Declare block ram
    constant ROW_BITS : natural := 64;
    constant CHANNEL_ROW_BITS : natural := CHANNEL_COUNT * ROW_BITS;
    subtype bram_row_t is std_logic_vector(CHANNEL_ROW_BITS-1 downto 0);
    type bram_mem_t is array(0 to 2**ADDR_BITS-1) of bram_row_t;
    signal memory : bram_mem_t;
    attribute ram_style : string;
    attribute ram_style of memory : signal is "BLOCK";

    signal read_row : bram_row_t;
    signal write_row : bram_row_t;

    function row_to_bits(data : mms_row_t) return std_logic_vector is
        variable result : std_logic_vector(ROW_BITS-1 downto 0);
    begin
        result(15 downto  0) := std_logic_vector(data.min);
        result(31 downto 16) := std_logic_vector(data.max);
        result(63 downto 32) := std_logic_vector(data.sum);
        return result;
    end;

    function bits_to_row(data : std_logic_vector) return mms_row_t is
        variable result : mms_row_t;
    begin
        result.min := signed(data(15 downto  0));
        result.max := signed(data(31 downto 16));
        result.sum := signed(data(63 downto 32));
        return result;
    end;

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            read_row <= memory(to_integer(read_addr_i));
            if write_strobe_i = '1' then
                memory(to_integer(write_addr_i)) <= write_row;
            end if;
        end if;
    end process;

    convert_gen : for c in CHANNELS generate
        read_data_o(c) <= bits_to_row(read_field_ix(read_row, ROW_BITS, c));
        write_row((c+1)*ROW_BITS-1 downto c*ROW_BITS)
            <= row_to_bits(write_data_i(c));
    end generate;
end;
