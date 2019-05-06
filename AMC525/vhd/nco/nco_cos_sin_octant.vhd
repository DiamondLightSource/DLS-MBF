-- Computation of cos and sin from lookup table

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.nco_defs.all;

entity nco_cos_sin_octant is
    generic (
        OCTANT_DELAY : natural
    );
    port (
        clk_i : in std_ulogic;

        octant_i : octant_t;
        cos_sin_i : in cos_sin_18_t;
        cos_sin_o : out cos_sin_18_t := (others => (others => '0'))
    );
end;

architecture arch of nco_cos_sin_octant is
    signal octant_in : octant_t;
    signal octant : octant_t;
    signal cos_sin_in : cos_sin_18_t;
    signal p_cos : signed(17 downto 0);
    signal p_sin : signed(17 downto 0);
    signal m_cos : signed(17 downto 0);
    signal m_sin : signed(17 downto 0);
    signal cos : signed(17 downto 0) := (others => '0');
    signal sin : signed(17 downto 0) := (others => '0');

begin
    -- Processing delay:
    -- octant_i, cos_sin_i =>
    --  1   octant_in, cos_sin_in =>
    --  2   octant, {m,p}_{cos,sin} =>
    --  3   cos, sin = cos_sin_o
    assert OCTANT_DELAY = 3 severity failure;

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- A little pipelining
            cos_sin_in <= cos_sin_i;
            octant_in <= octant_i;

            -- Precompute negation before final multiplexer
            p_cos <=  cos_sin_in.cos;
            p_sin <=  cos_sin_in.sin;
            m_cos <= -cos_sin_in.cos;
            m_sin <= -cos_sin_in.sin;

            octant <= octant_in;
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

        end if;
    end process;

    cos_sin_o.cos <= cos;
    cos_sin_o.sin <= sin;
end;
