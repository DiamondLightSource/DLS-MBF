-- Top level controller for output to DRAM1

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity slow_memory_control is
    port (
        dsp_clk_i : in std_logic;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in std_logic_vector(0 to 0);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 0);
        read_strobe_i : in std_logic_vector(0 to 0);
        read_data_o : out reg_data_array_t(0 to 0);
        read_ack_o : out std_logic_vector(0 to 0);

        -- Data out to DRAM1
        dram1_strobe_o : out std_logic;
        dram1_error_i : in std_logic;
        dram1_address_o : out unsigned;
        dram1_data_o : out std_logic_vector
    );
end;

architecture slow_memory_control of slow_memory_control is
    subtype ADDRESS_RANGE is natural range dram1_address_o'RANGE;
    signal hack_register : reg_data_t;
    signal target_count : unsigned(ADDRESS_RANGE);
    signal interval_shift : natural range 0 to 15;
    constant INTERVAL_BITS : natural := 16;

    signal counter : unsigned(ADDRESS_RANGE);
    signal interval_counter : unsigned(INTERVAL_BITS-1 downto 0);
    signal data_counter : unsigned(63 downto 0);
    signal address : unsigned(ADDRESS_RANGE);

begin
    hack_regs_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        register_data_o(0) => hack_register
    );

    read_data_o(0) <= hack_register;
    read_ack_o(0) <= '1';

    target_count <= unsigned(hack_register(ADDRESS_RANGE));
    interval_shift <= to_integer(unsigned(hack_register(31 downto 28)));


    -- Dummy generator
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if write_ack_o(0) = '1' then
                -- Start writing
                counter <= target_count;
                interval_counter <= shift_left(
                    to_unsigned(1, INTERVAL_BITS), interval_shift);
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
                dram1_data_o <= std_logic_vector(data_counter);
                dram1_address_o <= address;
                dram1_strobe_o <= '1';
            end if;
        end if;
    end process;

end;
