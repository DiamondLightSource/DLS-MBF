library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.nco_defs.all;
use work.dsp_defs.all;

use work.sim_support.all;

entity testbench is
end testbench;


architecture arch of testbench is
    signal adc_clk : std_ulogic := '1';
    signal dsp_clk : std_ulogic := '0';

--     constant TURN_COUNT : natural := 31;
    constant TURN_COUNT : natural := 125;
    signal turn_clock : std_ulogic;

    -- Device under test signals
    signal write_strobe : std_ulogic_vector(DSP_TUNE_PLL_REGS)
        := (others => '0');
    signal write_data : reg_data_t;
    signal write_ack : std_ulogic_vector(DSP_TUNE_PLL_REGS);
    signal read_strobe : std_ulogic_vector(DSP_TUNE_PLL_REGS)
        := (others => '0');
    signal read_data : reg_data_array_t(DSP_TUNE_PLL_REGS);
    signal read_ack : std_ulogic_vector(DSP_TUNE_PLL_REGS);
    signal adc_data : signed(15 downto 0) := (others => '0');
    -- We're just using 'Z' as a placeholder for unused signals because it shows
    -- as a different colour from 'X' and 'U'.
    signal adc_fill_reject : signed(15 downto 0) := (others => 'Z');
    signal fir_data : signed(24 downto 0) := (others => 'Z');
    signal start : std_ulogic := '0';
    signal stop : std_ulogic := '0';
    signal blanking : std_ulogic := '0';
    signal nco_data : dsp_nco_to_mux_t;
    signal freq_offset : signed(31 downto 0);
    signal interrupt : std_ulogic_vector(2 downto 0);

    -- Resonant filter
    signal FILTER_CENTRE_FREQ : real := 0.2;
    constant FILTER_WIDTH : real := 0.001;
    constant FILTER_GAIN : real := 0.2;
    signal resonant_adc_data : adc_data'SUBTYPE;

    -- Noise to add to ADC data
    constant NOISE_GAIN : real := 2000.0;
    signal adc_noise : adc_data'SUBTYPE;

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

    tune_pll : entity work.tune_pll_top generic map (
        -- We run the IIR a lot faster for simulation
        READOUT_IIR_SHIFT => "0100",
        READOUT_IIR_CLOCK_BITS => 5,
        READOUT_FIFO_BITS => 3
    ) port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,
        turn_clock_i => turn_clock,
        write_strobe_i => write_strobe,
        write_data_i => write_data,
        write_ack_o => write_ack,
        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack,
        adc_data_i => adc_data,
        adc_fill_reject_i => adc_fill_reject,
        fir_data_i => fir_data,
        start_i => start,
        stop_i => stop,
        blanking_i => blanking,
        nco_data_o => nco_data,
        freq_offset_o => freq_offset,
        interrupt_o => interrupt
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


    -- Simulated resonant filter
    resonator : entity work.sim_resonator port map (
        clk_i => adc_clk,
        centre_freq_i => FILTER_CENTRE_FREQ,
        width_i => FILTER_WIDTH,
        gain_i => FILTER_GAIN,
        data_i => nco_data.nco.cos(17 downto 2),
        data_o => resonant_adc_data
    );

    sim_noise : entity work.sim_noise port map (
        clk_i => adc_clk,
        gain_i => NOISE_GAIN,
        data_o => adc_noise
    );
    adc_data <= resonant_adc_data + adc_noise;


    -- Register control
    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg(dsp_clk, write_data, write_strobe, write_ack, reg, value);
        end;

        procedure read_reg(reg : natural) is
        begin
            read_reg(dsp_clk, read_data, read_strobe, read_ack, reg);
        end;

        procedure clk_wait(count : in natural := 1) is
        begin
            clk_wait(dsp_clk, count);
        end;

        constant DSP_TUNE_PLL_CONTROL_NCO_FREQ_LOW_REG : natural :=
            DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS'LEFT +
            NCO_FREQ_LOW_REG;
        constant DSP_TUNE_PLL_CONTROL_NCO_FREQ_HIGH_REG : natural :=
            DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS'LEFT +
            NCO_FREQ_HIGH_REG;

        constant TEST_FREQ : std_ulogic_vector(15 downto 0) := X"0826";

    begin
        write_strobe <= (others => '0');
        read_strobe <= (others => '0');
        blanking <= '0';

        clk_wait;

        -- Set NCO frequency close to test frequency
        write_reg(DSP_TUNE_PLL_CONTROL_NCO_FREQ_LOW_REG, X"F0000000");
        write_reg(DSP_TUNE_PLL_CONTROL_NCO_FREQ_HIGH_REG, (
            NCO_FREQ_HIGH_BITS_BITS => TEST_FREQ,
            others => '0'));
        -- Configure dwell time to be long enough for CORDIC to complete
        write_reg(DSP_TUNE_PLL_CONTROL_CONFIG_REG_W, (
            DSP_TUNE_PLL_CONTROL_CONFIG_DWELL_TIME_BITS => X"0002",
            DSP_TUNE_PLL_CONTROL_CONFIG_CAPTURE_CORDIC_BIT => '1',
            DSP_TUNE_PLL_CONTROL_CONFIG_BLANKING_BIT => '1',
            others => '0'));
        -- Effectively disable phase error checking
        write_reg(DSP_TUNE_PLL_CONTROL_MAX_OFFSET_ERROR_REG_W, X"7FFFFFFF");
        -- Write all ones to bunch memory to enable detector operation
        write_reg(DSP_TUNE_PLL_CONTROL_COMMAND_REG_W, (
            DSP_TUNE_PLL_CONTROL_COMMAND_WRITE_BUNCH_BIT => '1',
            others => '0'));
        write_reg(DSP_TUNE_PLL_CONTROL_BUNCH_REG, (others => '1'));
        -- Set integral term
        write_reg(DSP_TUNE_PLL_CONTROL_INTEGRAL_REG, X"04000000");
        -- Set proportional term
        write_reg(DSP_TUNE_PLL_CONTROL_PROPORTIONAL_REG, X"08000000");
        -- Set target phase close to starting phase
        write_reg(DSP_TUNE_PLL_CONTROL_TARGET_PHASE_REG, X"80000000");

        read_reg(DSP_TUNE_PLL_READOUT_DEBUG_FIFO_REG);
        read_reg(DSP_TUNE_PLL_READOUT_OFFSET_FIFO_REG);
        write_reg(DSP_TUNE_PLL_READOUT_COMMAND_REG_W, (
            DSP_TUNE_PLL_READOUT_COMMAND_RESET_DEBUG_BIT => '1',
            DSP_TUNE_PLL_READOUT_COMMAND_RESET_OFFSET_BIT => '1',
            DSP_TUNE_PLL_READOUT_COMMAND_ENABLE_DEBUG_BIT => '1',
            DSP_TUNE_PLL_READOUT_COMMAND_ENABLE_OFFSET_BIT => '1',
            others => '0'));

        -- Write repeated FIFO resets
        write_reg(DSP_TUNE_PLL_READOUT_COMMAND_REG_W, (
            DSP_TUNE_PLL_READOUT_COMMAND_RESET_DEBUG_BIT => '1',
            DSP_TUNE_PLL_READOUT_COMMAND_RESET_OFFSET_BIT => '1',
            others => '0'));
        write_reg(DSP_TUNE_PLL_READOUT_COMMAND_REG_W, (
            DSP_TUNE_PLL_READOUT_COMMAND_RESET_DEBUG_BIT => '1',
            DSP_TUNE_PLL_READOUT_COMMAND_RESET_OFFSET_BIT => '1',
            others => '0'));
        write_reg(DSP_TUNE_PLL_READOUT_COMMAND_REG_W, (
            DSP_TUNE_PLL_READOUT_COMMAND_RESET_DEBUG_BIT => '1',
            DSP_TUNE_PLL_READOUT_COMMAND_RESET_OFFSET_BIT => '1',
            others => '0'));
        write_reg(DSP_TUNE_PLL_READOUT_COMMAND_REG_W, (
            DSP_TUNE_PLL_READOUT_COMMAND_RESET_DEBUG_BIT => '1',
            DSP_TUNE_PLL_READOUT_COMMAND_RESET_OFFSET_BIT => '1',
            others => '0'));

        -- Can now start the detector
        start <= '1';
        clk_wait;
        start <= '0';

        -- Quick blanking test
        wait for 1 us;
        clk_wait;
        blanking <= '1';
        wait for 3 us;
        clk_wait;
        blanking <= '0';

        -- Let things run until frequency settles, stop and restart
        wait for 4 us;
        clk_wait;
        stop <= '1';
        clk_wait;
        stop <= '0';

        -- Write a large magnitude limit to force an error
        write_reg(DSP_TUNE_PLL_CONTROL_MIN_MAGNITUDE_REG, X"00800000");

        wait for 1.75 us;
        clk_wait;
        start <= '1';
        clk_wait;
        start <= '0';

        -- Reset the magnitude limit and start again
        write_reg(DSP_TUNE_PLL_CONTROL_MIN_MAGNITUDE_REG, X"00000000");

        wait for 2 us;
        clk_wait;
        start <= '1';
        clk_wait;
        start <= '0';



        wait for 25 us;
        clk_wait;
        write_reg(DSP_TUNE_PLL_CONTROL_TARGET_PHASE_REG, X"90000000");

        -- Read back the NCO as a quick test.  This has to be done in HIGH then
        -- LOW order to latch the full value correctly.
        read_reg(DSP_TUNE_PLL_CONTROL_NCO_FREQ_HIGH_REG);
        read_reg(DSP_TUNE_PLL_CONTROL_NCO_FREQ_LOW_REG);

        wait for 25 us;
        clk_wait;
        write_reg(DSP_TUNE_PLL_CONTROL_TARGET_PHASE_REG, X"70000000");

        wait for 25 us;
        clk_wait;
        write_reg(DSP_TUNE_PLL_CONTROL_TARGET_PHASE_REG, X"60000000");

        wait for 25 us;
        FILTER_CENTRE_FREQ <= 0.201;

        wait for 25 us;
        FILTER_CENTRE_FREQ <= 0.205;

        wait for 25 us;
        FILTER_CENTRE_FREQ <= 0.210;

        wait for 25 us;
        clk_wait;

        -- All done, now stop the detector
        stop <= '1';
        clk_wait;
        stop <= '0';

        wait;
    end process;
end;
