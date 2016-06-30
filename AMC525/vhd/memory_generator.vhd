-- Simple memory pattern generator for testing

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.support.all;

entity memory_generator is
    generic (
        DATA_WIDTH : natural := 64
    );
    port (
        clk_i : in std_logic;

        -- Internal register interface
        read_strobe_i : in std_logic;
        read_address_i : in reg_addr_t;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;
        --
        write_strobe_i : in std_logic;
        write_address_i : in reg_addr_t;
        write_data_i : in reg_data_t;

        -- Interface to streaming AXI master
        capture_enable_o : out std_logic;
        data_ready_i : in std_logic;
        data_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_valid_o : out std_logic;
        -- Error bits
        data_error_i : in std_logic;
        addr_error_i : in std_logic;
        brsp_error_i : in std_logic
    );
end entity;

architecture memory_generator of memory_generator is
    constant COUNT_WIDTH : natural := 28;
    signal write_counter : unsigned(COUNT_WIDTH-1 downto 0)
        := (others => '0');
    signal data_pattern : std_logic_vector(DATA_WIDTH-1 downto 0)
        := x"0000_0002_0000_0001";
    signal data_increment : std_logic_vector(DATA_WIDTH-1 downto 0)
        := X"0000_0002_0000_0002";

    signal writing : boolean := false;

    signal data_error_count : unsigned(REG_DATA_WIDTH-1 downto 0)
        := (others => '0');
    signal addr_error_count : unsigned(REG_DATA_WIDTH-1 downto 0)
        := (others => '0');
    signal brsp_error_count : unsigned(REG_DATA_WIDTH-1 downto 0)
        := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if writing and data_ready_i = '1' then
                -- Ensure we emit the selected number of writes
                if write_counter = 0 then
                    writing <= false;
                else
                    write_counter <= write_counter - 1;
                end if;

                data_pattern <= std_logic_vector(
                    unsigned(data_pattern) + unsigned(data_increment));

            elsif write_strobe_i = '1' then
                case to_integer(write_address_i) is
                    when 0 =>
                        data_pattern(31 downto 0) <= write_data_i;
                    when 1 =>
                        data_pattern(63 downto 32) <= write_data_i;
                    when 2 =>
                        data_increment(31 downto 0) <= write_data_i;
                    when 3 =>
                        data_increment(63 downto 32) <= write_data_i;
                    when 4 =>
                        write_counter <=
                            unsigned(write_data_i(COUNT_WIDTH-1 downto 0));
                        writing <= true;
                    when others =>
                end case;
            end if;
        end if;
    end process;

    data_o <= data_pattern;
    data_valid_o <= '1';
    capture_enable_o <= to_std_logic(writing);


    -- Readback of internal registers
    process (clk_i) begin
        if rising_edge(clk_i) then
            case to_integer(read_address_i) is
                when 0 =>
                    read_data_o <= data_pattern(31 downto 0);
                when 1 =>
                    read_data_o <= data_pattern(63 downto 32);
                when 2 =>
                    read_data_o <= data_increment(31 downto 0);
                when 3 =>
                    read_data_o <= data_increment(63 downto 32);
                when 4 =>
                    read_data_o <= std_logic_vector(data_error_count);
                when 5 =>
                    read_data_o <= std_logic_vector(addr_error_count);
                when 6 =>
                    read_data_o <= std_logic_vector(brsp_error_count);
                when 7 =>
                    read_data_o <= (0 => to_std_logic(writing), others => '0');
                when others =>
                    read_data_o <= (others => '0');
            end case;
        end if;
    end process;
    read_ack_o <= '1';


    -- Error counters
    process (clk_i) begin
        if rising_edge(clk_i) then
            if data_error_i = '1' then
                data_error_count <= data_error_count + 1;
            end if;
            if addr_error_i = '1' then
                addr_error_count <= addr_error_count + 1;
            end if;
            if brsp_error_i = '1' then
                brsp_error_count <= brsp_error_count + 1;
            end if;
        end if;
    end process;
end;
