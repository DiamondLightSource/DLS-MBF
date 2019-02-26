library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.nco_defs.all;
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
    signal pll_freq : angle_t := (others => '0');
    signal hom_freq : angle_t;
    signal hom_reset : std_ulogic;
    signal hom_gain : unsigned(3 downto 0);
    signal hom_enable : std_ulogic;
    signal hom_window : hom_win_t;
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

    sequencer : entity work.sequencer_top port map (
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

        pll_freq_i => pll_freq,
        hom_freq_o => hom_freq,
        hom_reset_o => hom_reset,
        hom_gain_o => hom_gain,
        hom_enable_o => hom_enable,
        hom_window_o => hom_window,
        bunch_bank_o => bunch_bank
    );


    -- Register control interface
    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg(dsp_clk, write_data, write_strobe, write_ack, reg, value);
        end;

    begin
        write_strobe <= (others => '0');
        read_strobe <= (others => '0');
        trigger <= '0';

        clk_wait(dsp_clk, 10);
        -- Configure: PC = 1, event on completion, no super sequencer, write to
        -- sequencer memory
        write_reg(DSP_SEQ_CONFIG_REG,    X"00000001");  -- write to seq memory

        write_reg(DSP_SEQ_COMMAND_REG_W, X"00000002");  -- start write

        -- First write bank 0.  This is the idle state, needs most fields zero.
        -- We enable the phase reset bit in the idle state
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");  -- start freq
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");  -- delta freq
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");  -- high bits of freqs
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");  -- dwell and capture
        write_reg(DSP_SEQ_WRITE_REG,     X"00000400");  -- detailed config
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");  -- window rate
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");  -- holdoff time
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");  -- (padding)

        -- Next write bank 1
        write_reg(DSP_SEQ_WRITE_REG,     X"56789ABC");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000001");
        write_reg(DSP_SEQ_WRITE_REG,     X"00001234");
        write_reg(DSP_SEQ_WRITE_REG,     X"00020001");  -- 2 dwell, 3 capture
        write_reg(DSP_SEQ_WRITE_REG,     X"00000291");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");
        write_reg(DSP_SEQ_WRITE_REG,     X"00010001");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000000");

        -- Finally bank 2
        write_reg(DSP_SEQ_WRITE_REG,     X"00000001");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000002");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000007");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000002");
        write_reg(DSP_SEQ_WRITE_REG,     X"0003D001");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000005");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000003");
        write_reg(DSP_SEQ_WRITE_REG,     X"00000008");

        -- Now trigger sequencer
        clk_wait(dsp_clk);
        trigger <= '1';
        clk_wait(dsp_clk);
        trigger <= '0';


        -- Wait for program to complete
        wait until seq_busy = '0';
        clk_wait(dsp_clk);

        -- Trigger again!
        trigger <= '1';
        clk_wait(dsp_clk);
        trigger <= '0';

        clk_wait(dsp_clk, 20);
        write_reg(DSP_SEQ_COMMAND_REG_W, X"00000001");  -- force reset


        -- Wait for program to complete and trigger again
        wait until seq_busy = '0';
        clk_wait(dsp_clk);
        trigger <= '1';
        clk_wait(dsp_clk);
        trigger <= '0';

        wait;
    end process;
end;
