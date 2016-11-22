-- Top level controller for DSP units.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.dsp_defs.all;

entity control_top is
    port (
        -- Clocking
        dsp_clk_i : in std_logic;

        -- Control register interface
        write_strobe_i : in reg_strobe_t;
        write_data_i : in reg_data_t;
        write_ack_o : out reg_strobe_t;
        read_strobe_i : in reg_strobe_t;
        read_data_o : out reg_data_array_t;
        read_ack_o : out reg_strobe_t;

        -- DSP controls
        control_to_dsp0_o : out control_to_dsp_t;
        dsp0_to_control_i : in dsp_to_control_t;
        control_to_dsp1_o : out control_to_dsp_t;
        dsp1_to_control_i : in dsp_to_control_t;

        -- DDR0 DRAM capture control
        ddr0_capture_enable_o : out std_logic;
        ddr0_data_ready_i : in std_logic;
        ddr0_capture_address_i : in ddr0_addr_t;
        ddr0_data_valid_o : out std_logic;
        ddr0_data_error_i : in std_logic;
        ddr0_addr_error_i : in std_logic;
        ddr0_brsp_error_i : in std_logic
    );
end;

architecture control_top of control_top is
    constant PULSED_REG : natural := 0;
    constant CONTROL_REG : natural := 1;
    constant MEM_GEN_REG : natural := 2;
    subtype UNUSED_REG is natural range 3 to REG_ADDR_COUNT-1;

    signal pulsed_bits : reg_data_t;
    signal control : reg_data_t;

    signal adc_mux : std_logic;
    signal nco_0_mux : std_logic;
    signal nco_1_mux : std_logic;

    -- Counter for simulated memory generator
    signal write_counter : unsigned(DDR0_ADDR_RANGE);

begin
    -- Capture of pulsed bits.
    pulsed_bits_inst : entity work.pulsed_bits port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(PULSED_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(PULSED_REG),
        read_strobe_i => read_strobe_i(PULSED_REG),
        read_data_o => read_data_o(PULSED_REG),
        read_ack_o => read_ack_o(PULSED_REG),

        pulsed_bits_i => pulsed_bits
    );

    -- General control register
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(CONTROL_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(CONTROL_REG),
        register_data_o(0) => control
    );
    read_data_o(CONTROL_REG) <= control;
    read_ack_o(CONTROL_REG) <= '1';


    -- Memory generator.
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if write_strobe_i(MEM_GEN_REG) = '1' then
                ddr0_capture_enable_o <= '1';
                write_counter <= unsigned(write_data_i(DDR0_ADDR_RANGE));
            elsif write_counter > 0 then
                write_counter <= write_counter - 1;
            else
                ddr0_capture_enable_o <= '0';
            end if;
        end if;
    end process;
    write_ack_o(MEM_GEN_REG) <= '1';
    ddr0_data_valid_o <= '1';

    pulsed_bits <= (
        0 => ddr0_data_error_i,
        1 => ddr0_addr_error_i,
        2 => ddr0_brsp_error_i,
        others => '0'
    );

    read_data_o(MEM_GEN_REG) <= "0" & ddr0_capture_address_i;
    read_ack_o(MEM_GEN_REG) <= '1';


    -- Data multiplexing control
    adc_mux <= control(0);
    nco_0_mux <= control(1);
    nco_1_mux <= control(2);
    dsp_control_mux_inst : entity work.dsp_control_mux port map (
        dsp_clk_i => dsp_clk_i,

        adc_mux_i => adc_mux,
        nco_0_mux_i => nco_0_mux,
        nco_1_mux_i => nco_1_mux,

        control_to_dsp0_o => control_to_dsp0_o,
        dsp0_to_control_i => dsp0_to_control_i,
        control_to_dsp1_o => control_to_dsp1_o,
        dsp1_to_control_i => dsp1_to_control_i
    );


    -- Unused registers
    write_ack_o(UNUSED_REG) <= (others => '1');
    read_data_o(UNUSED_REG) <= (others => (others => '0'));
    read_ack_o(UNUSED_REG) <= (others => '1');

end;
