-- Simple pulse stretching

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity stretch_pulse is
    generic (
        DELAY : natural := 31;
        WIDTH : natural := 1
    );
    port (
        clk_i : in std_logic;
        pulse_i : in std_logic_vector(WIDTH-1 downto 0);
        pulse_o : out std_logic_vector(WIDTH-1 downto 0) := (others => '0')
    );
end;

architecture arch of stretch_pulse is
    signal pulse_delay : std_logic_vector(WIDTH-1 downto 0);

begin
    delayline : entity work.dlyline generic map (
        DLY => DELAY,
        DW => WIDTH
    ) port map (
        clk_i => clk_i,
        data_i => pulse_i,
        data_o => pulse_delay
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            for i in WIDTH-1 downto 0 loop
                if pulse_i(i) then
                    pulse_o(i) <= '1';
                elsif pulse_delay(i) then
                    pulse_o(i) <= '0';
                end if;
            end loop;
        end if;
    end process;
end;
