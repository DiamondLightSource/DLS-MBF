library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.dsp_defs.all;

use work.sim_support.all;

entity testbench is
end testbench;


architecture testbench of testbench is
    signal adc_clk : std_logic;
    signal dsp_clk : std_logic;
    signal adc_phase : std_logic;

    signal adc_data : signed(ADC_INP_WIDTH-1 downto 0) := (others => '0');
    signal dac_data : signed(DAC_OUT_WIDTH-1 downto 0);

    signal write_strobe : reg_strobe_t := (others => '0');
    signal write_data : reg_data_t := (others => '0');
    signal write_ack : reg_strobe_t;
    signal read_strobe : reg_strobe_t := (others => '0');
    signal read_data : reg_data_array_t(REG_ADDR_RANGE);
    signal read_ack : reg_strobe_t;

    signal dram1_strobe : std_logic;
    signal dram1_error : std_logic;
    signal dram1_address : unsigned(22 downto 0);
    signal dram1_data : std_logic_vector(63 downto 0);

    signal control_to_dsp : control_to_dsp_t;
    signal dsp_to_control : dsp_to_control_t;

begin
    clock_inst : entity work.clock_support port map (
        adc_clk_o => adc_clk,
        dsp_clk_o => dsp_clk,
        adc_phase_o => adc_phase
    );

    -- Simple ADC data simulation: we just generate a ramp.
    process (adc_clk) begin
        if rising_edge(adc_clk) then
            for c in CHANNELS loop
                adc_data <= adc_data + 1;
            end loop;
        end if;
    end process;


    -- The dsp_top instance.
    dsp_top_inst : entity work.dsp_top port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,
        adc_phase_i => adc_phase,

        adc_data_i => adc_data,
        dac_data_o => dac_data,

        write_strobe_i => write_strobe,
        write_data_i => write_data,
        write_ack_o => write_ack,
        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack,

        control_to_dsp_i => control_to_dsp,
        dsp_to_control_o => dsp_to_control,

        dram1_strobe_o => dram1_strobe,
        dram1_error_i => dram1_error,
        dram1_address_o => dram1_address,
        dram1_data_o => dram1_data
    );

    -- Simple pass-through of control interface
    process (dsp_clk) begin
        if rising_edge(dsp_clk) then
            control_to_dsp.adc_data   <= dsp_to_control.adc_data;
            for l in LANES loop
                control_to_dsp.nco_0_data(l) <=
                    dsp_to_control.nco_0_data(l).cos;
                control_to_dsp.nco_1_data(l) <=
                    dsp_to_control.nco_1_data(l).cos;
            end loop;
        end if;
    end process;


    dram1_error <= '0';

    -- Register control testbench
    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg(dsp_clk, write_data, write_strobe, write_ack, reg, value);
        end;

        procedure read_reg(reg : natural) is
        begin
            read_reg(dsp_clk, read_data, read_strobe, read_ack, reg);
        end;
    begin

        -- Initialise ADC FIR with passthrough.
        clk_wait(dsp_clk, 10);
        write_reg(0, X"00000001");
        write_reg(3, X"7FFFFFFF");

        -- Configure bunch control
        write_reg(4, X"00000004");      -- 10 bunches (2*5) in our ring!
        write_reg(0, X"00000001");      -- Start write
        write_reg(5, X"7FFF0070");      -- Enable all outpus with maximum gain
        write_reg(5, X"7FFF0070");
        write_reg(5, X"7FFF0070");
        write_reg(5, X"7FFF0070");
        write_reg(5, X"7FFF0070");
        write_reg(5, X"7FFF0070");
        write_reg(5, X"7FFF0070");
        write_reg(5, X"7FFF0070");
        write_reg(5, X"7FFF0070");
        write_reg(5, X"7FFF0070");

        -- Write 1 into first tap of bank 0
        write_reg(8, X"7FFFFFFF");

        -- Global DAC output config
        write_reg(9, X"02000000");      -- Enable FIR, zero delay

        -- Initialise DAC FIR
        write_reg(0, X"00000001");
        write_reg(10, X"7FFFFFFF");

        -- Enable DAC output
        write_reg(11, X"00000008");

        -- Set both oscillator frequencies
        write_reg(12, X"01000000");
        write_reg(13, X"10000000");

        clk_wait(dsp_clk, 10);

        write_reg(9, X"06000011");     -- 17 tick delay, enable NCO0

        wait;

    end process;

end testbench;
