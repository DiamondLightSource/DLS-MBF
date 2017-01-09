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

-- Some details of the implementation of this block ram are required to ensure
-- correct high speed operation, in particular the rather bogus write_data_o
-- port (and its rather complex behaviour) is required to ensure that we don't
-- generate a READ_FIRST port which then slows down the device.  The coding
-- tricks used here are taken from pages 110 to 113 of UG901 (v2016.1).
--
-- Note also that this file must be synthesised as VHDL 93, as VHDL 2008
-- generates a rather cryptic complaint that "shared variables must be of
-- protected type".

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity block_memory is
    generic (
        ADDR_BITS : natural;
        DATA_BITS : natural
    );
    port (
        clk_i : in std_logic;

        -- Read interface
        read_addr_i : in unsigned(ADDR_BITS-1 downto 0);
        read_data_o : out std_logic_vector(DATA_BITS-1 downto 0)
            := (others => '0');

        -- Write interface
        write_strobe_i : in std_logic;
        write_addr_i : in unsigned(ADDR_BITS-1 downto 0);
        write_data_i : in std_logic_vector(DATA_BITS-1 downto 0);
        write_data_o : out std_logic_vector(DATA_BITS-1 downto 0) -- leave open
    );
end;

architecture block_memory of block_memory is
    -- Block RAM
    subtype data_t is std_logic_vector(DATA_BITS-1 downto 0);
    type memory_t is array(0 to 2**ADDR_BITS-1) of data_t;
    -- Shared variable used to get correct synthesis and correct modelling
    -- behaviour; note that when this is used we also need two process blocks!
    shared variable memory : memory_t := (others => (others => '0'));
    attribute ram_style : string;
    attribute ram_style of memory : variable is "BLOCK";

    signal read_data : std_logic_vector(DATA_BITS-1 downto 0)
        := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Slightly odd write semantics, required for correct synthesis.
            if write_strobe_i = '1' then
                memory(to_integer(write_addr_i)) := write_data_i;
                write_data_o <= write_data_i;
            else
                write_data_o <= memory(to_integer(write_addr_i));
            end if;
        end if;
    end process;

    -- Note: if this is merged with block above we don't get block RAM!
    process (clk_i) begin
        if rising_edge(clk_i) then
            read_data <= memory(to_integer(read_addr_i));
            read_data_o <= read_data;
        end if;
    end process;
end;
