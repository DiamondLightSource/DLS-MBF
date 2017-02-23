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
    signal reset : std_logic;
    signal phase_advance : angle_t := (others => '0');
    signal phase : angle_t := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Phase advance
            phase_advance <= phase_advance_i;
            reset <= reset_i;
            if reset = '1' then
                phase <= (others => '0');
            else
                phase <= phase + phase_advance;
            end if;

            phase_o <= phase;
        end if;
    end process;
end;
