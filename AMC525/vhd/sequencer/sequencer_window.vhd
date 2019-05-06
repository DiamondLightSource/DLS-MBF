-- Window generator
--
-- Generates detector capture window and output control pulses.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;
use work.sequencer_defs.all;

entity sequencer_window is
    port (
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;

        write_strobe_i : in std_ulogic;
        write_addr_i : in unsigned;
        write_data_i : in reg_data_t;

        -- Settings for current state
        window_rate_i : in window_rate_t;   -- Window phase advance per tick
        enable_window_i : in std_ulogic;     -- Window or rectangle
        write_enable_i : in std_ulogic;

        first_turn_i : in std_ulogic;
        last_turn_i : in std_ulogic;

        seq_start_o : out std_ulogic;
        seq_write_o : out std_ulogic;
        hom_window_o : out hom_win_t := (others => '0') -- Generated window
    );
end;

architecture arch of sequencer_window is
    -- As well as an intrinsic delay of 4 clocks we need an extra delay so that
    -- controls to the detector arrive at the same time as the IQ data.
    constant EXTRA_DELAY : natural := 3;

    -- Window pattern is stored in memory.
    type window_memory_t is array(0 to 1023) of hom_win_t;
    signal window_memory : window_memory_t := (others => (others => '0'));
    attribute ram_style : string;
    attribute ram_style of window_memory : signal is "block";

    -- The rate and enable parameters are loaded early, but need to be valid
    -- during the entire turn, so load working copies at start of each turn.
    signal window_rate : window_rate_t := (others => '0');
    signal enable_window : std_ulogic := '0';
    signal write_enable : std_ulogic := '0';

    -- Generate window from appropriate triggered start.
    signal start_window : std_ulogic;
    signal window_phase : window_rate_t := (others => '0');
    signal enable_window_delay : std_ulogic := '0';

    signal seq_write_in : std_ulogic;
    -- Extra register to help with flow
    signal hom_window : hom_win_t := (others => '0');
    signal hom_window_read : hom_win_t := (others => '0');

begin
    start_dly : entity work.dlyline generic map (
        DLY => EXTRA_DELAY + 4
    ) port map (
        clk_i => dsp_clk_i,
        data_i(0) => first_turn_i,
        data_o(0) => seq_start_o
    );

    seq_write_in <= last_turn_i and turn_clock_i and write_enable;
    write_dly : entity work.dlyline generic map (
        DLY => EXTRA_DELAY + 5
    ) port map (
        clk_i => dsp_clk_i,
        data_i(0) => seq_write_in,
        data_o(0) => seq_write_o
    );

    window_dly : entity work.dlyline generic map (
        DLY => EXTRA_DELAY
    ) port map (
        clk_i => dsp_clk_i,
        data_i(0) => first_turn_i,
        data_o(0) => start_window
    );

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if write_strobe_i = '1' then
                window_memory(to_integer(write_addr_i)) <=
                    hom_win_t(write_data_i(hom_win_t'range));
            end if;
            hom_window_read <=
                window_memory(to_integer(window_phase(31 downto 22)));

            if start_window = '1' then
                window_rate <= window_rate_i;
                enable_window <= enable_window_i;
                write_enable <= write_enable_i;
            end if;

            enable_window_delay <= enable_window;

            if start_window = '1' then
                window_phase <= (others => '0');
            else
                window_phase <= window_phase + window_rate;
            end if;

            if enable_window_delay = '1' then
                hom_window <= hom_window_read;
            else
                hom_window <= max_int(hom_win_t'LENGTH);
            end if;
            hom_window_o <= hom_window;

        end if;
    end process;
end;
