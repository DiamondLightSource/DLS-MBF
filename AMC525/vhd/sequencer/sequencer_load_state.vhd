-- Program state loading
--
-- Loads configuration for the next state from program memory.
-- Loading is triggered by start_load_i which must be pulsed.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;
use work.sequencer_defs.all;

entity sequencer_load_state is
    port (
        dsp_clk_i : in std_logic;

        write_strobe_i : in std_logic;
        write_addr_i : in unsigned;
        write_data_i : in reg_data_t;

        start_load_i : in std_logic;   -- Trigger load of next state
        seq_pc_i : in seq_pc_t;       -- Program counter to load from
        seq_state_o : out seq_state_t := initial_seq_state
    );
end;

architecture sequencer_load_state of sequencer_load_state is
    type seq_program_t is array(0 to 63) of reg_data_t;
    signal seq_program : seq_program_t := (others => (others => '0'));
    attribute ram_style : string;
    attribute ram_style of seq_program : signal is "block";

    -- The following state is used to load the parameters for the next state.
    -- This needs to be triggered early as we'll need eight clock cycles to
    -- load the necessary state from the program memory.
    signal loading : std_logic := '0';
    signal load_ctr : unsigned(2 downto 0) := "000";
    signal prog_word : reg_data_t;

    -- Loading is delayed to so that seq_state_o remains valid for a few more
    -- ticks after the start of the next state.
    signal start_load : std_logic;

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

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then

            if write_strobe_i = '1' then
                seq_program(to_integer(write_addr_i)) <= write_data_i;
            end if;

            -- Loading sequencer program state from PC.  Wait for start_load
            -- trigger then run through all the words that need loading.
            if loading = '1' then
                prog_word <= seq_program(to_integer(seq_pc_i & load_ctr));
                case to_integer(load_ctr) is
                    when 0 =>
                    when 1 =>
                        seq_state_o.start_freq <= angle_t(prog_word);
                    when 2 =>
                        seq_state_o.delta_freq <= angle_t(prog_word);
                    when 3 =>
                        seq_state_o.dwell_count <=
                            dwell_count_t(prog_word(15 downto 0));
                    when 4 =>
                        seq_state_o.capture_count <=
                            capture_count_t(prog_word(11 downto 0));
                        seq_state_o.bunch_bank <=
                            unsigned(prog_word(13 downto 12));
                        seq_state_o.hom_gain <=
                            unsigned(prog_word(17 downto 14));
                        seq_state_o.enable_window <= prog_word(18);
                        seq_state_o.enable_write <= prog_word(19);
                        seq_state_o.enable_blanking <= prog_word(20);
                    when 5 =>
                        seq_state_o.window_rate <= angle_t(prog_word);
                    when 6 =>
                        seq_state_o.holdoff_count <=
                            dwell_count_t(prog_word(15 downto 0));
                    when 7 =>
                    when others =>
                end case;
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