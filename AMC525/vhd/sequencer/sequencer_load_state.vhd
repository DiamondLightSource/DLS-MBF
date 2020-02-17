-- Program state loading
--
-- Loads configuration for the next state from program memory.
-- Loading is triggered by start_load_i which must be pulsed.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.nco_defs.all;
use work.sequencer_defs.all;

entity sequencer_load_state is
    port (
        dsp_clk_i : in std_ulogic;

        write_strobe_i : in std_ulogic;
        write_addr_i : in unsigned;
        write_data_i : in reg_data_t;

        start_load_i : in std_ulogic;   -- Trigger load of next state
        seq_pc_i : in seq_pc_t;       -- Program counter to load from
        seq_state_o : out seq_state_t := initial_seq_state
    );
end;

architecture arch of sequencer_load_state is
    -- The following state is used to load the parameters for the next state.
    -- This needs to be triggered early as we'll need eight clock cycles to
    -- load the necessary state from the program memory.
    signal loading : std_ulogic := '0';
    signal loading_dly : std_ulogic;
    signal load_ctr : unsigned(2 downto 0) := "000";
    signal load_ctr_dly : unsigned(2 downto 0);
    signal prog_word : reg_data_t;

    -- Loading is delayed to so that seq_state_o remains valid for a few more
    -- ticks after the start of the next state.
    signal start_load : std_ulogic;

    constant READ_DELAY : natural := 2;

begin
    -- Somewhat arbitrary delay to load, just long enough for us to delay some
    -- of our outputs so that we can load them late.
    delay_load : entity work.dlyline generic map (
        DLY => 8
    ) port map (
        clk_i => dsp_clk_i,
        data_i(0) => start_load_i,
        data_o(0) => start_load
    );

    -- Memory
    block_memory : entity work.block_memory generic map (
        ADDR_BITS => 6,
        DATA_BITS => reg_data_t'LENGTH,
        READ_DELAY => READ_DELAY
    ) port map (
        read_clk_i => dsp_clk_i,
        read_addr_i => seq_pc_i & load_ctr,
        read_data_o => prog_word,

        write_clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i,
        write_addr_i => write_addr_i(5 downto 0),
        write_data_i => write_data_i
    );

    -- Delay load counter and loading state to match memory delay
    delay_load_ctr : entity work.dlyline generic map (
        DLY => READ_DELAY,
        DW => load_ctr'LENGTH
    ) port map (
        clk_i => dsp_clk_i,
        data_i => std_ulogic_vector(load_ctr),
        unsigned(data_o) => load_ctr_dly
    );

    delay_loading : entity work.dlyline generic map (
        DLY => READ_DELAY
    ) port map (
        clk_i => dsp_clk_i,
        data_i(0) => loading,
        data_o(0) => loading_dly
    );


    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Loading sequencer program state from PC.  Wait for start_load
            -- trigger then run through all the words that need loading.
            if loading_dly = '1' then
                case to_integer(load_ctr_dly) is
                    when DSP_SEQ_STATE_START_FREQ_OVL =>
                        seq_state_o.start_freq(31 downto 0)
                            <= unsigned(prog_word);
                    when DSP_SEQ_STATE_DELTA_FREQ_OVL =>
                        seq_state_o.delta_freq(31 downto 0)
                            <= unsigned(prog_word);
                    when DSP_SEQ_STATE_HIGH_BITS_OVL =>
                        seq_state_o.start_freq(47 downto 32) <= unsigned(
                            prog_word(DSP_SEQ_STATE_HIGH_BITS_START_HIGH_BITS));
                        seq_state_o.delta_freq(47 downto 32) <= unsigned(
                            prog_word(DSP_SEQ_STATE_HIGH_BITS_DELTA_HIGH_BITS));
                    when DSP_SEQ_STATE_TIME_OVL =>
                        seq_state_o.dwell_count <= dwell_count_t(
                            prog_word(DSP_SEQ_STATE_TIME_DWELL_BITS));
                        seq_state_o.capture_count <= capture_count_t(
                            prog_word(DSP_SEQ_STATE_TIME_CAPTURE_BITS));
                    when DSP_SEQ_STATE_CONFIG_OVL =>
                        seq_state_o.bunch_bank <= unsigned(
                            prog_word(DSP_SEQ_STATE_CONFIG_BANK_BITS));
                        seq_state_o.nco_gain <= unsigned(
                            prog_word(DSP_SEQ_STATE_CONFIG_NCO_GAIN_BITS));
                        seq_state_o.enable_window <=
                            prog_word(DSP_SEQ_STATE_CONFIG_ENA_WINDOW_BIT);
                        seq_state_o.enable_write <=
                            prog_word(DSP_SEQ_STATE_CONFIG_ENA_WRITE_BIT);
                        seq_state_o.enable_blanking <=
                            prog_word(DSP_SEQ_STATE_CONFIG_ENA_BLANK_BIT);
                        seq_state_o.reset_phase <=
                            prog_word(DSP_SEQ_STATE_CONFIG_RESET_PHASE_BIT);
                        seq_state_o.enable_tune_pll <=
                            prog_word(DSP_SEQ_STATE_CONFIG_ENA_TUNE_PLL_BIT);
                        seq_state_o.disable_super <=
                            prog_word(DSP_SEQ_STATE_CONFIG_DIS_SUPER_BIT);
                    when DSP_SEQ_STATE_WINDOW_RATE_OVL =>
                        seq_state_o.window_rate <= window_rate_t(prog_word);
                    when DSP_SEQ_STATE_HOLDOFF_OVL =>
                        seq_state_o.holdoff_count <= dwell_count_t(
                            prog_word(DSP_SEQ_STATE_HOLDOFF_HOLDOFF_BITS));
                        seq_state_o.state_holdoff <= dwell_count_t(prog_word(
                            DSP_SEQ_STATE_HOLDOFF_STATE_HOLDOFF_BITS));
                    when others =>
                end case;
            end if;

            if loading = '1' then
                load_ctr <= load_ctr + 1;
                if load_ctr = 7 then
                    loading <= '0';
                end if;
            elsif start_load = '1' then
                loading <= '1';
                load_ctr <= "000";
            end if;

        end if;
    end process;
end;
