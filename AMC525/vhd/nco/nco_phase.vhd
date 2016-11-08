-- Phase advance for NCO

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.nco_defs.all;

entity nco_phase is
    port (
        clk_i : in std_logic;

        phase_advance_i : in angle_t;
        reset_i : in std_logic;

        phase_o : out angle_channels_t
    );
end;

architecture nco_phase of nco_phase is
    -- Phase advance for the two channels
    signal ph_a_1 : angle_t := (others => '0');
    signal ph_a_2 : angle_t := (others => '0');

    -- Current master phase
    signal phase : angle_t := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Phase advance
            ph_a_1 <= phase_advance_i;
            ph_a_2 <= shift_left(phase_advance_i, 1);
            if reset_i = '1' then
                phase <= (others => '0');
            else
                phase <= phase + ph_a_2;
            end if;

            phase_o(0) <= phase;
            phase_o(1) <= phase + ph_a_1;
        end if;
    end process;
end;
