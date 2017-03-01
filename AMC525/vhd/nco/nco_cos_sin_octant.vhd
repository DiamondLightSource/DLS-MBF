-- Computation of cos and sin from lookup table

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.nco_defs.all;

entity nco_cos_sin_octant is
    port (
        clk_i : in std_logic;

        octant_i : octant_t;
        cos_sin_i : in cos_sin_18_t;
        cos_sin_o : out cos_sin_18_t
    );
end;

architecture nco_cos_sin_octant of nco_cos_sin_octant is
    signal octant : octant_t;
    signal p_cos : signed(17 downto 0);
    signal p_sin : signed(17 downto 0);
    signal m_cos : signed(17 downto 0);
    signal m_sin : signed(17 downto 0);
    signal cos : signed(17 downto 0) := (others => '0');
    signal sin : signed(17 downto 0) := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Precompute negation before final multiplexer
            p_cos <=  cos_sin_i.cos;
            p_sin <=  cos_sin_i.sin;
            m_cos <= -cos_sin_i.cos;
            m_sin <= -cos_sin_i.sin;

            octant <= octant_i;
            case octant is
                when "000" => cos <= p_cos;  sin <= p_sin;
                when "001" => cos <= p_sin;  sin <= p_cos;
                when "010" => cos <= m_sin;  sin <= p_cos;
                when "011" => cos <= m_cos;  sin <= p_sin;
                when "100" => cos <= m_cos;  sin <= m_sin;
                when "101" => cos <= m_sin;  sin <= m_cos;
                when "110" => cos <= p_sin;  sin <= m_cos;
                when "111" => cos <= p_cos;  sin <= m_sin;
                when others =>
            end case;

            cos_sin_o.cos <= cos;
            cos_sin_o.sin <= sin;
        end if;
    end process;
end;
