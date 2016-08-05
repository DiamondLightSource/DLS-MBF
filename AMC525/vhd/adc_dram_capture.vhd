-- Entity for data capture from DDR ADC data to DRAM

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.support.all;

entity adc_dram_capture is
    generic (
        DATA_WIDTH : natural := 64
    );
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        -- Register control interface
        read_strobe_i : in std_logic;
        read_address_i : in reg_addr_t;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;
        --
        write_strobe_i : in std_logic;
        write_address_i : in reg_addr_t;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;

        -- ADC data in
        adc_data_a_i : in std_logic_vector(13 downto 0);
        adc_data_b_i : in std_logic_vector(13 downto 0);

        -- Interface to streaming AXI master
        capture_enable_o : out std_logic;
        data_ready_i : in std_logic;
        data_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_valid_o : out std_logic;
        capture_address_i : in std_logic_vector(30 downto 0);
        -- Error bits
        data_error_i : in std_logic;
        addr_error_i : in std_logic;
        brsp_error_i : in std_logic
    );
end;

architecture adc_dram_capture of adc_dram_capture is
    signal adc_phase : std_logic := '0';
    signal adc_data_a : std_logic_vector(13 downto 0);
    signal adc_data_b : std_logic_vector(13 downto 0);
    signal adc_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal adc_data_pl : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal select_adc_data : std_logic := '0';

    -- -------------------------------------------------------------------------
    -- Memory generator variables

    signal write_counter : unsigned(REG_DATA_WIDTH-1 downto 0)
        := (others => '0');
    signal data_pattern : std_logic_vector(DATA_WIDTH-1 downto 0)
        := x"0000_0002_0000_0001";
    signal data_increment : std_logic_vector(DATA_WIDTH-1 downto 0)
        := X"0000_0002_0000_0002";

    signal writing : std_logic := '0';

    signal data_error_count : unsigned(REG_DATA_WIDTH-1 downto 0)
        := (others => '0');
    signal addr_error_count : unsigned(REG_DATA_WIDTH-1 downto 0)
        := (others => '0');
    signal brsp_error_count : unsigned(REG_DATA_WIDTH-1 downto 0)
        := (others => '0');

begin
    -- Gather ADC data for DDR capture
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            adc_phase <= not adc_phase;
            adc_data_a <= adc_data_a_i;
            adc_data_b <= adc_data_b_i;
            case adc_phase is
                when '0' =>
                    adc_data(15 downto 0)  <= sign_extend(adc_data_a, 16);
                    adc_data(31 downto 16) <= sign_extend(adc_data_b, 16);
                when '1' =>
                    adc_data(47 downto 32) <= sign_extend(adc_data_a, 16);
                    adc_data(63 downto 48) <= sign_extend(adc_data_b, 16);
            end case;
        end if;
    end process;


    -- -------------------------------------------------------------------------
    -- Code stolen from memory_generator

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if writing = '1' and data_ready_i = '1' then
                -- Ensure we emit the selected number of writes
                if write_counter = 0 then
                    writing <= '0';
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
                        write_counter <= unsigned(write_data_i);
                        writing <= '1';
                    when 5 =>
                        select_adc_data <= write_data_i(0);
                    when others =>
                end case;
            end if;

            -- Output selected data
            adc_data_pl <= adc_data;
            case select_adc_data is
                when '0' => data_o <= data_pattern;
                when '1' => data_o <= adc_data_pl;
            end case;
        end if;
    end process;

    write_ack_o <= '1';
    data_valid_o <= '1';
    capture_enable_o <= writing;


    -- Readback of internal registers
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
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
                    read_data_o(0) <= writing;
                    read_data_o(1) <= select_adc_data;
                    read_data_o(31 downto 2) <= (others => '0');
                when 8 =>
                    read_data_o <= "0" & capture_address_i;
                when others =>
                    read_data_o <= (others => '0');
            end case;
        end if;
    end process;
    read_ack_o <= '1';


    -- Error counters
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
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
