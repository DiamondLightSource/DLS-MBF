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
    signal adc_clk : std_ulogic := '1';
    signal dsp_clk : std_ulogic := '0';

    constant TURN_COUNT : natural := 50;
    signal turn_clock : std_ulogic;

    signal adc_data : signed(13 downto 0) := 14X"1FFF";
    signal dac_data : signed(15 downto 0);

    signal write_strobe : std_ulogic_vector(DSP_REGS_RANGE) := (others => '0');
    signal write_data : reg_data_t := (others => '0');
    signal write_ack : std_ulogic_vector(DSP_REGS_RANGE);
    signal read_strobe : std_ulogic_vector(DSP_REGS_RANGE) := (others => '0');
    signal read_data : reg_data_array_t(DSP_REGS_RANGE);
    signal read_ack : std_ulogic_vector(DSP_REGS_RANGE);

    signal control_to_dsp : control_to_dsp_t := control_to_dsp_reset;
    signal dsp_to_control : dsp_to_control_t;
    signal dsp_to_control_array : dsp_to_control_array_t;
    signal dsp_event : std_ulogic;

    signal mux_adc_out   : signed_array(CHANNELS)(ADC_DATA_RANGE);
    signal mux_nco_0_out : dsp_nco_from_mux_array_t;
    signal mux_nco_1_out : dsp_nco_from_mux_array_t;
    signal mux_nco_2_out : dsp_nco_from_mux_array_t;
    signal mux_nco_3_out : dsp_nco_from_mux_array_t;
    signal bank_select_out : unsigned_array(CHANNELS)(1 downto 0);

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

    -- Simple ADC data simulation: we just generate a ramp.
    process (adc_clk) begin
        if rising_edge(adc_clk) then
--             adc_data <= dac_data(15 downto 2);  -- Loopback
--             adc_data <= adc_data + 1;
            adc_data <= not adc_data;
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


    -- Pass control through DSP mux for more realistic timing
    dsp_to_control_array(0) <= dsp_to_control;
    dsp_control_mux : entity work.dsp_control_mux port map (
        clk_i => adc_clk,

        adc_mux_i => '0',
        nco_0_mux_i => '0',
        nco_1_mux_i => '0',
        nco_2_mux_i => '0',
        nco_3_mux_i => '0',
        bank_mux_i => '0',

        dsp_to_control_i => dsp_to_control_array,

        adc_o => mux_adc_out,
        nco_0_o => mux_nco_0_out,
        nco_1_o => mux_nco_1_out,
        nco_2_o => mux_nco_2_out,
        nco_3_o => mux_nco_3_out,
        bank_select_o => bank_select_out
    );
    control_to_dsp.adc_data <= mux_adc_out(0);
    control_to_dsp.nco_0_data <= mux_nco_0_out(0);
    control_to_dsp.nco_1_data <= mux_nco_1_out(0);
    control_to_dsp.nco_2_data <= mux_nco_2_out(0);
    control_to_dsp.nco_3_data <= mux_nco_3_out(0);
    control_to_dsp.bank_select <= bank_select_out(0);
    control_to_dsp.turn_clock <= turn_clock;


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

        -- Initialise ADC FIR
        write_reg(DSP_ADC_COMMAND_REG_W,  (
            DSP_ADC_COMMAND_WRITE_BIT => '1',
            others => '0'));
        write_reg(DSP_ADC_TAPS_REG, X"7FFFFFFF");

        -- Initialise DAC FIR
        write_reg(DSP_DAC_COMMAND_REG_W, (
            DSP_DAC_COMMAND_WRITE_BIT => '1',
            others => '0'));
        write_reg(DSP_DAC_TAPS_REG, X"7FFFFFFF");

        -- Initialise Bunch FIR
        write_reg(DSP_FIR_CONFIG_REG_W, (others => '0'));
        write_reg(DSP_FIR_TAPS_REG, X"7FFFFFFF");

        -- Set FIR gain reasonably low
        write_reg(DSP_DAC_CONFIG_REG, (
            DSP_DAC_CONFIG_FIR_GAIN_BITS => "1100", others => '0'));

        -- Set a sensible NCO frequency, reset the phase
        write_reg(DSP_FIXED_NCO_NCO1_FREQ_REGS'LOW, X"00000000");
        write_reg(DSP_FIXED_NCO_NCO1_FREQ_REGS'LOW + 1, (
            NCO_FREQ_HIGH_BITS_BITS => X"1800",
            NCO_FREQ_HIGH_RESET_PHASE_BIT => '1',
            others => '0'));
        write_reg(DSP_FIXED_NCO_NCO1_REG, (
            DSP_FIXED_NCO_NCO1_GAIN_BITS => 18X"10000",
            others => '0'));

        -- Configure bunch control: bank 0 for NCO
        write_reg(DSP_BUNCH_CONFIG_REG, (
            DSP_BUNCH_CONFIG_BANK_BITS => "00",
            others => '0'));
        for n in 1 to TURN_COUNT loop
            write_reg(DSP_BUNCH_BANK_REG, (
                DSP_BUNCH_BANK_GAIN_BITS => 18X"01000",
                DSP_BUNCH_BANK_FIR_ENABLE_BIT => '1',
                DSP_BUNCH_BANK_NCO0_ENABLE_BIT => '1',
--                 DSP_BUNCH_BANK_NCO3_ENABLE_BIT => '1',
                others => '0'));
        end loop;
        -- Bank 1 for sweep
        write_reg(DSP_BUNCH_CONFIG_REG, (
            DSP_BUNCH_CONFIG_BANK_BITS => "01",
            others => '0'));
        for n in 1 to TURN_COUNT loop
            write_reg(DSP_BUNCH_BANK_REG, (
                DSP_BUNCH_BANK_GAIN_BITS => 18X"10000",
                DSP_BUNCH_BANK_NCO1_ENABLE_BIT => '1',
                others => '0'));
        end loop;

        -- Configure sequencer
        write_reg(DSP_SEQ_CONFIG_REG, (
            DSP_SEQ_CONFIG_PC_BITS => "001",
            DSP_SEQ_CONFIG_TARGET_BITS => "00",
            others => '0'));
        write_reg(DSP_SEQ_COMMAND_REG_W, ( -- start write
            DSP_SEQ_COMMAND_WRITE_BIT => '1',
            others => '0'));

        -- First write state 0.  This is the idle state, needs most fields
        -- zero.  We enable the phase reset bit in the idle state
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");
        write_reg(DSP_SEQ_WRITE_REG, (
            DSP_SEQ_STATE_CONFIG_RESET_PHASE_BIT => '1',
            others => '0'));
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");

        -- Next write state 1.  1 dwell 1 capture, different NCO frequency
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");  -- start freq (bottom
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");  -- delta freq  bits)
        write_reg(DSP_SEQ_WRITE_REG, (
            DSP_SEQ_STATE_HIGH_BITS_START_HIGH_BITS => X"1000",
            DSP_SEQ_STATE_HIGH_BITS_DELTA_HIGH_BITS => X"0000"));
        write_reg(DSP_SEQ_WRITE_REG, (
            DSP_SEQ_STATE_TIME_DWELL_BITS => X"0000",
            DSP_SEQ_STATE_TIME_CAPTURE_BITS => X"0000"));
        write_reg(DSP_SEQ_WRITE_REG, (
            DSP_SEQ_STATE_CONFIG_BANK_BITS => "01",
            DSP_SEQ_STATE_CONFIG_NCO_GAIN_BITS => 18X"04000",
            others => '0'));
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");

        -- We should be ready to go.  Start the sequencer
        control_to_dsp.seq_start <= '1';
        clk_wait(dsp_clk);
        control_to_dsp.seq_start <= '0';
        -- Wait for sequencer to start and finish
        wait until dsp_to_control.seq_busy = '1';
        wait until dsp_to_control.seq_busy = '0';
        clk_wait(dsp_clk);

        -- Enable second NCO
        write_reg(DSP_FIXED_NCO_NCO2_FREQ_REGS'LOW, X"00000000");
        write_reg(DSP_FIXED_NCO_NCO2_FREQ_REGS'LOW + 1, (
            NCO_FREQ_HIGH_BITS_BITS => X"0F00",
            others => '0'));
        write_reg(DSP_FIXED_NCO_NCO2_REG, (
            DSP_FIXED_NCO_NCO2_GAIN_BITS => 18X"0FFFF",
            others => '0'));

        -- Work through the FIR gain settings
        for i in 15 downto 0 loop
            wait for 100 ns;
            clk_wait(dsp_clk);
            write_reg(DSP_DAC_CONFIG_REG, (
                DSP_DAC_CONFIG_FIR_GAIN_BITS =>
                    std_logic_vector(to_unsigned(i, 4)),
                others => '0'));
        end loop;

        -- Finally turn NCO1 off
        clk_wait(dsp_clk);
        write_reg(DSP_FIXED_NCO_NCO1_REG, (others => '0'));

        wait;
    end process;
end;
