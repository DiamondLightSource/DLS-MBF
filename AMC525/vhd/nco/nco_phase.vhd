-- Phase advance for NCO

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.nco_defs.all;

entity nco_phase is
    port (
        clk_i : in std_ulogic;
        phase_advance_i : in angle_t;
        reset_phase_i : in std_ulogic;
        phase_o : out angle_t
    );
end;

architecture arch of nco_phase is
    signal phase_advance : angle_t := (others => '0');
    signal phase : angle_t := (others => '0');

    attribute USE_DSP : string;
    attribute USE_DSP of phase : signal is "yes";

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            phase_advance <= phase_advance_i;
            if reset_phase_i = '1' then
                phase <= (others => '0');
            else
                phase <= phase + phase_advance;
            end if;
        end if;
    end process;

    phase_o <= phase;
end;
