-- Controller for fast memory interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.dsp_defs.all;

entity fast_memory_top is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- Control register interface
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- Input data stream
        dsp_to_control_i : in dsp_to_control_array_t;
        -- Capture control
        memory_trigger_i : in std_logic;

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
    signal config_registers : reg_data_array_t(CTRL_MEM_CONFIG_REGS);
    signal config_untimed : reg_data_array_t(CTRL_MEM_CONFIG_REGS);
    signal command_bits : reg_data_t;
    signal status_register : reg_data_t;

    -- Configuration
    constant COUNT_BITS : natural := 28;
    signal mux_select : std_logic_vector(3 downto 0);
    signal fir_gain : unsigned(3 downto 0);
    signal enable_select : std_logic_vector(CHANNELS);
    signal count : unsigned(COUNT_BITS-1 downto 0);

    -- Command
    signal start : std_logic;
    signal stop : std_logic;
    signal reset_errors : std_logic;

    signal capture_address : capture_address_i'SUBTYPE;

    signal data_valid : std_logic;
    signal extra_data : std_logic_vector(63 downto 0);

    signal data_out : data_o'SUBTYPE;

    -- We don't expect the error bits to ever be seen
    signal data_error : std_logic := '0';
    signal addr_error : std_logic := '0';
    signal brsp_error : std_logic := '0';

begin
    -- -------------------------------------------------------------------------
    -- Register control

    -- Configuration registers with readback
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(CTRL_MEM_CONFIG_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CTRL_MEM_CONFIG_REGS),
        register_data_o => config_registers
    );
    read_data_o(CTRL_MEM_CONFIG_REGS) <= config_registers;
    read_ack_o(CTRL_MEM_CONFIG_REGS) <= (others => '1');

    untimed_inst : entity work.untimed_reg generic map (
        WIDTH => 64
    ) port map (
        clk_i => dsp_clk_i,
        write_i => '1',
        data_i(31 downto  0) => config_registers(CTRL_MEM_CONFIG_REG),
        data_i(63 downto 32) => config_registers(CTRL_MEM_COUNT_REG),
        data_o(31 downto  0) => config_untimed(CTRL_MEM_CONFIG_REG),
        data_o(63 downto 32) => config_untimed(CTRL_MEM_COUNT_REG)
    );


    -- Pulsed command events
    strobed_bits_inst : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(CTRL_MEM_COMMAND_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CTRL_MEM_COMMAND_REG_W),
        strobed_bits_o => command_bits
    );
    -- Address register readback
    read_data_o(CTRL_MEM_ADDRESS_REG_R) <= "0" & capture_address;
    read_ack_o(CTRL_MEM_ADDRESS_REG_R) <= '1';

    -- Status register
    write_ack_o(CTRL_MEM_STATUS_REG) <= '1';
    read_data_o(CTRL_MEM_STATUS_REG) <= status_register;
    read_ack_o(CTRL_MEM_STATUS_REG) <= '1';


    -- -------------------------------------------------------------------------
    -- Register mapping

    -- Configuration fields extracted from config registers
    mux_select <= config_untimed(CTRL_MEM_CONFIG_REG)(3 downto 0);
    fir_gain <= unsigned(config_untimed(CTRL_MEM_CONFIG_REG)(7 downto 4));
    enable_select <= config_untimed(CTRL_MEM_CONFIG_REG)(9 downto 8);
    count <= unsigned(
        config_untimed(CTRL_MEM_COUNT_REG)(COUNT_BITS-1 downto 0));

    -- Control events
    start <= command_bits(0);
    stop  <= command_bits(1);
    reset_errors <= command_bits(2);

    -- Active status
    status_register <= (
        0 => data_error or addr_error or brsp_error,
        1 => data_error,
        2 => addr_error,
        3 => brsp_error,
        4 => capture_enable_o,
        others => '0'
    );


    -- -------------------------------------------------------------------------
    -- Implementation

    -- Simple capture control
    control_inst : entity work.fast_memory_control port map (
        dsp_clk_i => dsp_clk_i,
        start_i => start,
        stop_i => stop or memory_trigger_i,
        count_i => count,
        capture_enable_o => capture_enable_o,
        capture_address_i => capture_address_i,
        capture_address_o => capture_address
    );

    -- Enable data according to input channel selection.
    data_valid <=
        (dsp_to_control_i(0).dram0_enable and enable_select(0)) or
        (dsp_to_control_i(1).dram0_enable and enable_select(1)) or
        (not enable_select(0) and not enable_select(1));

    -- Select data to be written
    mux_inst : entity work.fast_memory_mux port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        mux_select_i => mux_select,
        fir_gain_i => fir_gain,

        data_valid_i => data_valid,
        dsp_to_control_i => dsp_to_control_i,
        extra_i => extra_data,

        data_valid_o => data_valid_o,
        data_o => data_out
    );

    -- Pipeline data out to relax timing
    dlyreg_inst : entity work.dlyreg generic map (
        DLY => 10,
        DW => data_o'LENGTH
    ) port map (
        clk_i => dsp_clk_i,
        data_i => data_out,
        data_o => data_o
    );

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

    -- Currently this is just a placeholder.
    extra_data <= (others => '0');

end;
