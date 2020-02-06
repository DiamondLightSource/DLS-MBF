-- Implementation of p_o <= a_i*b_i+c_i with overflow detection
--
-- To be precise, the timing from inputs to output is:
--
--      a_i, b_i =(3)=> p_o, ovf_o
--      c_i =(1)=> p_o, ovf_o
--
-- Note that ovf_o is synchronous with p_o, and is computed using the DSP
-- pattern detection mechanism.  Note also that c_i is *not* registered, so that
-- cascaded instances of this can use the PC chain.
--
-- A more complete definition depends on en_ab_i and en_c_i, as follows:
--
--  en_ab_i     en_c_i      p_o
--  -------     ------      ---
--  0           0           0
--  0           1           c_i
--  1           0           a_i * b_i
--  1           1           a_i * b_i + c_i
--
-- Note that en_c_i is synchronous with c_i, but en_ab_i is one tick ahead (so
-- acts on a_i,b_i from the previous tick).

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dsp_mac is
    generic (
        TOP_RESULT_BIT : natural := 48
    );
    port (
        clk_i : in std_ulogic;
        a_i : in signed(17 downto 0);
        b_i : in signed(24 downto 0);
        en_ab_i : in std_ulogic;
        c_i : in signed(47 downto 0);
        en_c_i : in std_ulogic;
        p_o : out signed(47 downto 0);
        ovf_o : out std_ulogic
    );
end;

architecture arch of dsp_mac is
    signal a_in : signed(17 downto 0);
    signal b_in : signed(24 downto 0);
    signal ab : signed(42 downto 0);
    signal abc : signed(47 downto 0);

    subtype OVF_RANGE is natural range 47 downto TOP_RESULT_BIT;
    constant ONES_MASK : signed(OVF_RANGE) := (others => '1');
    signal all_ones : boolean;
    signal all_zeros : boolean;

    -- Stop input registers being absorbed into the DSP
    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of a_i : signal is "yes";
    attribute DONT_TOUCH of b_i : signal is "yes";

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            a_in <= a_i;
            b_in <= b_i;
            if en_ab_i = '1' then
                ab <= a_in * b_in;
            else
                ab <= (others => '0');
            end if;
            p_o <= abc;
            all_ones <= abc(OVF_RANGE) = ONES_MASK;
            all_zeros <= abc(OVF_RANGE) = 0;
        end if;
    end process;

    abc <= resize(ab, 48) + c_i when en_c_i = '1' else resize(ab, 48);
    ovf_o <= '0' when all_ones or all_zeros else '1';
end;
