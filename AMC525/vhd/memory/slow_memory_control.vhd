-- Top level controller for output to DRAM1
-- Currently this is a dummy controller which generates a test sequence.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity slow_memory_control is
    port (
        dsp_clk_i : in std_logic;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        read_strobe_i : in std_logic;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;

        -- Data out to DRAM1
        dram1_strobe_o : out std_logic;
        dram1_error_i : in std_logic;
        dram1_address_o : out unsigned;
        dram1_data_o : out std_logic_vector
    );
end;

architecture slow_memory_control of slow_memory_control is
    subtype ADDRESS_RANGE is natural range dram1_address_o'RANGE;
    signal target_count : unsigned(ADDRESS_RANGE);
    signal interval_shift_in : natural range 0 to 15;
    signal interval_shift : natural range 0 to 15;
    constant INTERVAL_BITS : natural := 16;

    signal counter : unsigned(ADDRESS_RANGE) := (others => '0');
    signal interval_counter : unsigned(INTERVAL_BITS-1 downto 0)
        := (others => '0');
    signal data_counter : unsigned(63 downto 0) := (others => '0');
    signal address : unsigned(ADDRESS_RANGE) := (others => '0');

begin
    write_ack_o <= '1';
    read_data_o <= (
        ADDRESS_RANGE => std_logic_vector(address), others => '0');
    read_ack_o <= '1';

    target_count <= unsigned(write_data_i(ADDRESS_RANGE));
    interval_shift_in <= to_integer(unsigned(write_data_i(31 downto 28)));


    -- Dummy generator
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if write_strobe_i = '1' then
                -- Start writing
                counter <= target_count;
                interval_counter <= shift_left(
                    to_unsigned(1, INTERVAL_BITS), interval_shift_in);
                interval_shift <= interval_shift_in;

                data_counter <= (others => '0');
                address <= (others => '0');
                dram1_strobe_o <= '0';
            elsif interval_counter > 0 then
                interval_counter <= interval_counter - 1;
                dram1_strobe_o <= '0';
            elsif counter > 0 then
                counter <= counter - 1;
                data_counter <= data_counter + 1;
                address <= address + 1;
                interval_counter <= shift_left(
                    to_unsigned(1, INTERVAL_BITS), interval_shift);

                dram1_data_o <= std_logic_vector(data_counter);
                dram1_address_o <= address;
                dram1_strobe_o <= '1';
            end if;
        end if;
    end process;

end;
