-- Controller for fast memory interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.dsp_defs.all;

entity fast_memory_top is
    port (
        dsp_clk_i : in std_logic;

        -- Control register interface
        write_strobe_i : in std_logic_vector(0 to 1);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 1);
        read_strobe_i : in std_logic_vector(0 to 1);
        read_data_o : out reg_data_array_t(0 to 1);
        read_ack_o : out std_logic_vector(0 to 1);

        -- Input data stream
        dsp0_to_control_i : in dsp_to_control_t;
        dsp1_to_control_i : in dsp_to_control_t;

        -- DRAM0 capture control: connected directly to AXI burst master
        capture_enable_o : out std_logic;
        data_ready_i : in std_logic;
        capture_address_i : in std_logic_vector;
        data_valid_o : out std_logic;
        data_o : out std_logic_vector;
        data_error_i : in std_logic;
        addr_error_i : in std_logic;
        brsp_error_i : in std_logic
    );
end;

architecture fast_memory_top of fast_memory_top is
    constant COUNT_BITS : natural := 28;

    signal control : reg_data_array_t(0 to 1);
    signal mux_select : std_logic_vector(3 downto 0);
    signal fir_gain : unsigned(3 downto 0);
    signal count : unsigned(COUNT_BITS-1 downto 0);

    signal strobed_bits : reg_data_t;
    signal start : std_logic;
    signal stop : std_logic;
    signal reset_errors : std_logic;
    signal capture_address : std_logic_vector(capture_address_i'RANGE);

    signal data_valid : std_logic;
    signal extra_data : std_logic_vector(63 downto 0);

    -- We don't expect the error bits to ever be seen
    signal data_error : std_logic := '0';
    signal addr_error : std_logic := '0';
    signal brsp_error : std_logic := '0';

begin
    -- Control registers
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        register_data_o => control
    );
    read_data_o(0) <= "0" & capture_address;
    read_ack_o(0) <= '1';
    read_data_o(1) <= (
        0 => data_error or addr_error or brsp_error,
        1 => data_error,
        2 => addr_error,
        3 => brsp_error,
        others => '0'
    );
    read_ack_o(1) <= '1';


    -- Also generate strobed bits from the control register
    strobed_bits_inst : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(0),
        write_data_i => write_data_i,
        write_ack_o => open,
        strobed_bits_o => strobed_bits
    );

    -- Control fields
    mux_select <= control(0)(3 downto 0);
    fir_gain <= unsigned(control(0)(7 downto 4));
    count <= unsigned(control(1)(27 downto 0));


    -- Simple capture control
    control_inst : entity work.fast_memory_control port map (
        dsp_clk_i => dsp_clk_i,
        start_i => start,
        stop_i => stop,
        count_i => count,
        capture_enable_o => capture_enable_o,
        capture_address_i => capture_address_i,
        capture_address_o => capture_address
    );


    -- Select data to be written
    mux_inst : entity work.fast_memory_mux port map (
        dsp_clk_i => dsp_clk_i,

        mux_select_i => mux_select,
        fir_gain_i => fir_gain,

        data_valid_i => data_valid,
        dsp0_to_control_i => dsp0_to_control_i,
        dsp1_to_control_i => dsp1_to_control_i,
        extra_i => extra_data,

        data_valid_o => data_valid_o,
        data_o => data_o
    );
    extra_data <= (others => '0');


    -- Gather error bits together
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if reset_errors = '1' then
                data_error <= '0';
                addr_error <= '0';
                brsp_error <= '0';
            else
                data_error <= data_error or data_error_i;
                addr_error <= addr_error or addr_error_i;
                brsp_error <= brsp_error or brsp_error_i;
            end if;
        end if;
    end process;


    -- Currently this is mostly just a placeholder.
    data_valid <= '1';

    -- Control events (for now)
    start <= strobed_bits(16);
    stop  <= strobed_bits(17);
    reset_errors <= strobed_bits(0);
end;
