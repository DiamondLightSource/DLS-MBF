-- Memory mapped into Block RAM.  We double buffer the read data to ensure that
-- the BRAM is fully registered.
--
-- The delay from read_addr_i to read_data_o is 2 clock ticks:
--
-- clk_i            /       /       /       /       /
-- read_addr_i    --X  A    X----------------------------
-- read_data      ----------X M[A]  X--------------------
-- read_data_o    ------------------X M[A]  X------------
--
-- The relationship with data written into the same location is shown by the
-- figure below:
--
-- clk_i            /       /       /       /       /
-- write_strobe_i __/^^^^^^^\____________________________
-- write_addr_i   --X  A    X----------------------------
-- write_data_i   --X  D    X----------------------------
-- memory[A]      ----------X  D
-- read_addr_i    ----------X  A    X--------------------
-- read_data      ------------------X  D    X------------
-- read_data_o    --------------------------X  D    X----
--
-- This shows that the written data at any address must be read one tick later.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity block_memory is
    generic (
        ADDR_BITS : natural;
        DATA_BITS : natural;
        READ_DELAY : natural := 2   -- Validation parameter only
    );
    port (
        -- Read interface
        read_clk_i : in std_logic;
        read_addr_i : in unsigned(ADDR_BITS-1 downto 0);
        read_data_o : out std_logic_vector(DATA_BITS-1 downto 0)
            := (others => '0');

        -- Write interface
        write_clk_i : in std_logic;
        write_strobe_i : in std_logic;
        write_addr_i : in unsigned(ADDR_BITS-1 downto 0);
        write_data_i : in std_logic_vector(DATA_BITS-1 downto 0)
    );
end;

architecture arch of block_memory is
    -- Block RAM
    subtype data_t is std_logic_vector(DATA_BITS-1 downto 0);
    type memory_t is array(0 to 2**ADDR_BITS-1) of data_t;
    signal memory : memory_t := (others => (others => '0'));
    attribute ram_style : string;
    attribute ram_style of memory : signal is "BLOCK";

    signal read_data : std_logic_vector(DATA_BITS-1 downto 0)
        := (others => '0');

begin
    -- For callers to verify if required:
    --  read_addr_i
    --      => read_data
    --      => read_data_o
    assert READ_DELAY = 2 severity failure;

    process (write_clk_i) begin
        if rising_edge(write_clk_i) then
            if write_strobe_i = '1' then
                memory(to_integer(write_addr_i)) <= write_data_i;
            end if;
        end if;
    end process;

    process (read_clk_i) begin
        if rising_edge(read_clk_i) then
            read_data <= memory(to_integer(read_addr_i));
            read_data_o <= read_data;
        end if;
    end process;
end;
