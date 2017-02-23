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

        phase_o : out angle_t := (others => '0')
    );
end;

architecture nco_phase of nco_phase is
    -- Phase advance for the two lanes
    signal phase_advance : angle_t := (others => '0');

    -- Current master phase
    signal phase : angle_t := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Phase advance
            phase_advance <= phase_advance_i;
            if reset_i = '1' then
                phase <= (others => '0');
            else
                phase <= phase + phase_advance;
            end if;

            phase_o <= phase;
        end if;
    end process;
end;
