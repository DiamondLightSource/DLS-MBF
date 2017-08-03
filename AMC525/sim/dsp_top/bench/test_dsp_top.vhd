library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.dsp_defs.all;
use work.register_defs.all;

use work.sim_support.all;

entity testbench is
end testbench;


architecture arch of testbench is
    signal adc_clk : std_logic := '1';
    signal dsp_clk : std_logic := '0';

    constant TURN_COUNT : natural := 64;
    signal turn_clock : std_logic;

    signal adc_data : signed(13 downto 0) := (others => '0');
    signal dac_data : signed(15 downto 0);

    signal write_strobe : std_logic_vector(DSP_REGS_RANGE) := (others => '0');
    signal write_data : reg_data_t := (others => '0');
    signal write_ack : std_logic_vector(DSP_REGS_RANGE);
    signal read_strobe : std_logic_vector(DSP_REGS_RANGE) := (others => '0');
    signal read_data : reg_data_array_t(DSP_REGS_RANGE);
    signal read_ack : std_logic_vector(DSP_REGS_RANGE);

    signal control_to_dsp : control_to_dsp_t := control_to_dsp_reset;
    signal dsp_to_control : dsp_to_control_t;
    signal dsp_event : std_logic;

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

    -- Simple ADC data simulation: we just generate a ramp.
    process (adc_clk) begin
        if rising_edge(adc_clk) then
            adc_data <= dac_data(15 downto 2);  -- Loopback
--             adc_data <= adc_data + 1;
        end if;
    end process;


    -- The dsp_top instance.
    dsp_top : entity work.dsp_top port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,

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

        dsp_event_o => dsp_event
    );


    -- Generate turn clock
    process begin
        turn_clock <= '0';
        loop
            clk_wait(adc_clk, TURN_COUNT-1);
            turn_clock <= '1';
            clk_wait(adc_clk);
            turn_clock <= '0';
        end loop;
        wait;
    end process;


    -- Simple pass-through of control interface
    process (adc_clk) begin
        if rising_edge(adc_clk) then
            control_to_dsp.adc_data   <= dsp_to_control.adc_data;
            control_to_dsp.nco_0_data <= (
                nco => dsp_to_control.nco_0_data.nco.cos,
                gain => dsp_to_control.nco_0_data.gain,
                enable => dsp_to_control.nco_0_data.enable
            );
            control_to_dsp.nco_1_data <= (
                nco => dsp_to_control.nco_1_data.nco.cos,
                gain => dsp_to_control.nco_1_data.gain,
                enable => dsp_to_control.nco_1_data.enable
            );
            control_to_dsp.turn_clock <= turn_clock;
        end if;
    end process;


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

        clk_wait(dsp_clk, 10);

        -- Simple test, small ring: just pass NCO0 through to DSP

        -- Set a sensible NCO frequency
        write_reg(DSP_NCO0_FREQ_REG,  X"08000000");

        -- Enable output of NCO0
        -- .DELAY = 1
        -- .FIR_GAIN = 0
        -- .NCO0_GAIN = 0
        -- .FIR_ENABLE = 0
        -- .NCO0_ENABLE = 1
        -- .NCO1_ENABLE = 0
        write_reg(DSP_DAC_CONFIG_REG, X"00040001");

        -- Initialise DAC FIR
        write_reg(DSP_DAC_COMMAND_REG_W,  X"00000001");
        write_reg(DSP_DAC_TAPS_REG, X"7FFFFFFF");

        -- Configure bunch control
        write_reg(DSP_BUNCH_CONFIG_REG,  X"00000000");
        for n in 1 to TURN_COUNT loop
            -- .FIR_SELECT = 0
            -- .GAIN = 0x0FFF
            -- .FIR_ENABLE = 0
            -- .NCO0_ENABLE = 1
            -- .NCO1_ENABLE = 0
            write_reg(DSP_BUNCH_BANK_REG, X"00013FFC");
        end loop;

        -- Write FIR 0 taps
        write_reg(DSP_FIR_CONFIG_REG, X"00000000");
        write_reg(DSP_FIR_TAPS_REG,   X"5a827980");
--         write_reg(DSP_FIR_TAPS_REG,   X"5a827980");
        write_reg(DSP_FIR_TAPS_REG,   X"a57d8680");
--         write_reg(DSP_FIR_TAPS_REG,   X"a57d8680");

        -- Initialise ADC FIR
        write_reg(DSP_ADC_COMMAND_REG_W,  X"00000001");
        write_reg(DSP_ADC_TAPS_REG, X"7FFFFFFF");

        wait for 2 us;

        write_reg(DSP_NCO0_FREQ_REG,  X"08000010");

        wait;
    end process;
end;
