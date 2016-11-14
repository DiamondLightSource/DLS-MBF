-- Scaled NCO output

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.nco_defs.all;

entity nco_scaling is
    port (
        clk_i : in std_logic;
        gain_i : in unsigned(3 downto 0);
        unscaled_i : in cos_sin_18_lanes_t;
        scaled_o : out cos_sin_16_lanes_t
    );
end;

architecture nco_scaling of nco_scaling is
    signal scaled : cos_sin_18_lanes_t;

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            for l in LANES loop
                scaled(l).cos <=
                    shift_right(unscaled_i(l).cos, to_integer(gain_i));
                scaled(l).sin <=
                    shift_right(unscaled_i(l).sin, to_integer(gain_i));
                scaled_o(l).cos <= round(scaled(l).cos, 16);
                scaled_o(l).sin <= round(scaled(l).sin, 16);
            end loop;
        end if;
    end process;
end;
