-- Output delay alignment
--
-- To ensure that outputs from the NCO arrive at the same time as our other
-- control outputs we need to add some delays to the bank output, the window
-- control and the detector start stop events.

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.sequencer_defs.all;

entity sequencer_delays is
    port (
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;

        seq_state_i : in seq_state_t;
        seq_pc_i : in seq_pc_t;

        seq_pc_o : out seq_pc_t := (others => '0');
        hom_gain_o : out unsigned(3 downto 0) := (others => '0');
        bunch_bank_o : out unsigned(1 downto 0) := (others => '0')
    );
end;

architecture arch of sequencer_delays is
    signal load_bunch_bank : std_logic;
    signal load_hom_gain : std_logic;

begin
    bunch_bank_delay:
    entity work.dlyline generic map (DLY => 6) port map (
        clk_i => dsp_clk_i,
        data_i(0) => turn_clock_i, data_o(0) => load_bunch_bank);

    hom_gain_delay:
    entity work.dlyline generic map (DLY => 1) port map (
        clk_i => dsp_clk_i,
        data_i(0) => turn_clock_i, data_o(0) => load_hom_gain);

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if turn_clock_i = '1' then
                seq_pc_o <= seq_pc_i;
            end if;

            if load_bunch_bank = '1' then
                bunch_bank_o <= seq_state_i.bunch_bank;
            end if;

            if load_hom_gain = '1' then
                hom_gain_o <= seq_state_i.hom_gain;
            end if;
        end if;
    end process;
end;
