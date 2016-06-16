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

        -- Generated data stream
        data_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_strobe_o : out std_logic;
        capture_enable_o : out std_logic
    );
end entity;

architecture memory_generator of memory_generator is
    constant COUNT_WIDTH : natural := 28;
    signal write_counter : unsigned(COUNT_WIDTH-1 downto 0)
        := (others => '0');
    signal data_pattern : std_logic_vector(DATA_WIDTH-1 downto 0)
        := X"0102_0304_0506_0708";
    signal data_increment : std_logic_vector(DATA_WIDTH-1 downto 0)
        := X"0001_0001_0001_0001";

    signal writing : std_logic := '0';

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if writing = '1' then
                -- Ensure we emit the selected number of writes
                if write_counter = 0 then
                    writing <= '0';
                else
                    write_counter <= write_counter - 1;
                end if;
                data_o <= data_pattern;

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
                        writing <= '1';
                    when others =>
                end case;
            end if;
        end if;
    end process;

    data_strobe_o <= '1';
    capture_enable_o <= writing;


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
                when others =>
                    read_data_o <= (others => '0');
            end case;
        end if;
    end process;
    read_ack_o <= '1';
end;
