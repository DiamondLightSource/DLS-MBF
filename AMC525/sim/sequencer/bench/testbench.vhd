library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.nco_defs.all;
use work.dsp_defs.all;
use work.sequencer_defs.all;

use work.sim_support.all;

entity testbench is
end testbench;


architecture arch of testbench is
    signal adc_clk : std_ulogic := '1';
    signal dsp_clk : std_ulogic := '0';
    signal turn_clock : std_ulogic;

    -- This is pretty well the shortest turn if the sequencer is to have enough
    -- time to load its next state
    constant TURN_COUNT : natural := 55;

    signal blanking : std_ulogic;
    signal write_strobe : std_ulogic_vector(DSP_SEQ_REGS);
    signal write_data : reg_data_t;
    signal write_ack : std_ulogic_vector(DSP_SEQ_REGS);
    signal read_strobe : std_ulogic_vector(DSP_SEQ_REGS);
    signal read_data : reg_data_array_t(DSP_SEQ_REGS);
    signal read_ack : std_ulogic_vector(DSP_SEQ_REGS);
    signal trigger : std_ulogic;
    signal state_trigger : std_ulogic;
    signal seq_busy : std_ulogic;
    signal seq_start : std_ulogic;
    signal seq_write : std_ulogic;
    signal tune_pll_offset : signed(31 downto 0) := (others => '0');
    signal nco_data : dsp_nco_to_mux_t;
    signal detector_window : detector_win_t;
    signal bunch_bank : unsigned(1 downto 0);

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;


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

    blanking <= '0';

    sequencer : entity work.sequencer_top generic map (
        BUNCH_SELECT_DELAY => 8
    ) port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,

        turn_clock_adc_i => turn_clock,
        blanking_i => blanking,

        write_strobe_i => write_strobe,
        write_data_i => write_data,
        write_ack_o => write_ack,
        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack,

        trigger_i => trigger,
        state_trigger_o => state_trigger,
        seq_busy_o => seq_busy,

        seq_start_adc_o => seq_start,
        seq_write_adc_o => seq_write,

        tune_pll_offset_i => tune_pll_offset,
        nco_data_o => nco_data,
        detector_window_o => detector_window,
        bunch_bank_o => bunch_bank
    );


    -- Register control interface
    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg(dsp_clk, write_data, write_strobe, write_ack, reg, value);
        end;

        procedure write_bank(
            start_freq : angle_t := (others => '0');
            delta_freq : angle_t := (others => '0');
            dwell : unsigned(15 downto 0) := (others => '0');
            capture : unsigned(15 downto 0) := (others => '0');
            bank : unsigned(1 downto 0) := (others => '0');
            gain : unsigned(17 downto 0) := (others => '0');
            en_window : std_ulogic := '0';
            en_write : std_ulogic := '0';
            en_blank : std_ulogic := '0';
            reset_phase : std_ulogic := '0';
            en_tune_pll : std_ulogic := '0';
            window_rate : reg_data_t := (others => '0');
            holdoff : unsigned(15 downto 0) := (others => '0');
            state_holdoff : unsigned(15 downto 0) := (others => '0')) is
        begin
            write_reg(DSP_SEQ_WRITE_REG, (              -- START_FREQ
                DSP_SEQ_STATE_START_FREQ_LOW_BITS_BITS =>
                    std_ulogic_vector(start_freq(31 downto 0))));
            write_reg(DSP_SEQ_WRITE_REG, (              -- DELTA_FREQ
                DSP_SEQ_STATE_DELTA_FREQ_LOW_BITS_BITS =>
                    std_ulogic_vector(delta_freq(31 downto 0))));
            write_reg(DSP_SEQ_WRITE_REG, (              -- HIGH_BITS
                DSP_SEQ_STATE_HIGH_BITS_START_HIGH_BITS =>
                    std_ulogic_vector(start_freq(47 downto 32)),
                DSP_SEQ_STATE_HIGH_BITS_DELTA_HIGH_BITS =>
                    std_ulogic_vector(delta_freq(47 downto 32))));
            write_reg(DSP_SEQ_WRITE_REG, (              -- TIME
                DSP_SEQ_STATE_TIME_DWELL_BITS => std_ulogic_vector(dwell),
                DSP_SEQ_STATE_TIME_CAPTURE_BITS => std_ulogic_vector(capture)));
            write_reg(DSP_SEQ_WRITE_REG, (              -- CONFIG
                DSP_SEQ_STATE_CONFIG_BANK_BITS => std_ulogic_vector(bank),
                DSP_SEQ_STATE_CONFIG_NCO_GAIN_BITS => std_ulogic_vector(gain),
                DSP_SEQ_STATE_CONFIG_ENA_WINDOW_BIT => en_window,
                DSP_SEQ_STATE_CONFIG_ENA_WRITE_BIT => en_write,
                DSP_SEQ_STATE_CONFIG_ENA_BLANK_BIT => en_blank,
                DSP_SEQ_STATE_CONFIG_RESET_PHASE_BIT => reset_phase,
                DSP_SEQ_STATE_CONFIG_ENA_TUNE_PLL_BIT => en_tune_pll,
                others => '0'));
            write_reg(DSP_SEQ_WRITE_REG, window_rate);  -- WINDOW_RATE
            write_reg(DSP_SEQ_WRITE_REG, (              -- HOLDOFF
                DSP_SEQ_STATE_HOLDOFF_HOLDOFF_BITS =>
                    std_ulogic_vector(holdoff),
                DSP_SEQ_STATE_HOLDOFF_STATE_HOLDOFF_BITS =>
                    std_ulogic_vector(state_holdoff)));
            write_reg(DSP_SEQ_WRITE_REG, X"0000_0000"); -- PADDING
        end;

        procedure write_bank0 is
        begin
            write_reg(DSP_SEQ_CONFIG_REG, (         -- write to seq mem
                DSP_SEQ_CONFIG_PC_BITS => "001",
                DSP_SEQ_CONFIG_TARGET_BITS => "00",
                others => '0'));
            write_reg(DSP_SEQ_COMMAND_REG_W, (      -- start write
                DSP_SEQ_COMMAND_WRITE_BIT => '1',
                others => '0'));

            -- First write bank 0.  This is the idle state, needs most fields
            -- zero.  We enable the phase reset bit in the idle state
            write_bank(reset_phase => '1');
        end;

        procedure trigger_seq is
        begin
            trigger <= '1';
            clk_wait(dsp_clk);
            trigger <= '0';
        end;

        procedure wait_until_done is
        begin
            wait until seq_busy = '0';
            clk_wait(dsp_clk);
        end;

    begin
        write_strobe <= (others => '0');
        read_strobe <= (others => '0');
        trigger <= '0';

        clk_wait(dsp_clk, 10);

        -- Configure: PC = 1, event on completion, no super sequencer, write to
        -- sequencer memory
        write_bank0;
        write_bank(
            start_freq => X"1235_5678_9ABC",
            delta_freq => X"0000_0000_0001",
            dwell => X"0001", capture => X"0002",
            bank => "01", gain => 18X"3FFFF", en_write => '1');

        -- Now trigger sequencer
        clk_wait(dsp_clk);
        trigger_seq;
        wait_until_done;


        -- Reload again, but with holdoff
        write_bank0;
        write_bank(
            start_freq => X"1235_5678_9ABC",
            delta_freq => X"0000_0000_0001",
            dwell => X"0001", capture => X"0002",
            bank => "01", gain => 18X"3FFFF", en_write => '1',
            holdoff => X"0001");

        -- Trigger again!
        trigger_seq;
        wait_until_done;


        -- Reload again, state_holdoff now
        write_bank0;
        write_bank(
            start_freq => X"1235_5678_9ABC",
            delta_freq => X"0000_0000_0001",
            dwell => X"0001", capture => X"0002",
            bank => "01", gain => 18X"3FFFF", en_write => '1',
            state_holdoff => X"0001");

        -- Trigger again!
        trigger_seq;
        wait_until_done;


        -- Reload again
        write_bank0;
        write_bank(
            start_freq => X"1235_5678_9ABC",
            delta_freq => X"0000_0000_0001",
            dwell => X"0001", capture => X"0002",
            bank => "01", gain => 18X"3FFFF", en_write => '1',
            holdoff => X"0001", state_holdoff => X"0001");

        -- Trigger again!
        trigger_seq;
        wait_until_done;


        -- Now trigger and force reset after a brief wait
        trigger_seq;
        clk_wait(dsp_clk, 100);
        write_reg(DSP_SEQ_COMMAND_REG_W, (
            DSP_SEQ_COMMAND_ABORT_BIT => '1',       -- force reset
            others => '0'));


        -- Wait for program to complete and trigger again
        wait_until_done;
--         trigger_seq;

        wait;
    end process;
end;
