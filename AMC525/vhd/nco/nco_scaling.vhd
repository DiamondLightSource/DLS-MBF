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
        unscaled_i : in cos_sin_18_channels_t;
        scaled_o : out cos_sin_16_channels_t
    );
end;

architecture nco_scaling of nco_scaling is
    signal scaled : cos_sin_18_channels_t;

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            for c in CHANNELS loop
                scaled(c).cos <=
                    shift_right(unscaled_i(c).cos, to_integer(gain_i));
                scaled(c).sin <=
                    shift_right(unscaled_i(c).sin, to_integer(gain_i));
                scaled_o(c).cos <= round(scaled(c).cos, 16);
                scaled_o(c).sin <= round(scaled(c).sin, 16);
            end loop;
        end if;
    end process;
end;
