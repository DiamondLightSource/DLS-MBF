-- Implementation of p_o <= a_i*b_i+c_i with overflow detection
--
-- To be precise, the timing from inputs to output is:
--
--      a_i, b_i =(3)=> p_o, ovf_o
--      c_i =(2)=> p_o, pc_o, ovf_o
--      pc_i =(1)=> p_o, pc_o, ovf_o
--
-- Note that ovf_o is synchronous with p_o, and is computed using the DSP
-- pattern detection mechanism.  Note also that c_i is registered, but pc_i is
-- *not*.
--
-- A more complete definition depends on en_ab_i and en_c_i, as follows:
--
--  en_ab_i     en_c_i      p_o, pc_o
--  -------     ------      ---------
--  0           0           0
--  0           1           c_i                 or      pc_i
--  1           0           a_i * b_i
--  1           1           a_i * b_i + c_i     or      a_i * b_i + pc_i
--
-- Note that en_ab_i is synchronous with a_i, b_i, and en_c_i is synchronous
-- with c_i, but is one tick behind of pc_i.
--
--
-- Alas, Vivado is unreliable about instantiating the PCIN=>PCOUT accumulator
-- chain, so this algorithm is implemented by directly instantiating the DSP48E
-- unit.  The algorithm implemented here is the following:
--
--  process (clk_i) begin
--      if rising_edge(clk_i) then
--          a_in <= a_i;
--          b_in <= b_i;
--          en_ab_in <= en_ab_i;
--          if en_ab_in then
--              ab <= a_in * b_in;
--          else
--              ab <= (others => '0');
--          end if;
--          c_in <= c_i;
--          en_c_in <= en_c_i;
--          pc_o <= abc;
--          all_ones <= abc(OVF_RANGE) = ONES_MASK;
--          all_zeros <= abc(OVF_RANGE) = 0;
--      end if;
--  end process;
--
--  if USE_PCIN generate
--      abc <= resize(ab, 48) + pc_i when en_c_in = '1' else resize(ab, 48);
--  else
--      abc <= resize(ab, 48) + c_in when en_c_in = '1' else resize(ab, 48);
--  end generate;
--
--  ovf_o <= to_std_ulogic(not all_ones and not all_zeros);
--  p_o <= pc_o;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity dsp48e_mac is
    generic (
        TOP_RESULT_BIT : natural := 48;
        USE_PCIN : boolean := false
    );
    port (
        clk_i : in std_ulogic;

        a_i : in signed(24 downto 0);
        b_i : in signed(17 downto 0);
        en_ab_i : in std_ulogic;

        c_i : in signed(47 downto 0) := (others => '0');
        en_c_i : in std_ulogic;

        p_o : out signed(47 downto 0);
        pc_o : out signed(47 downto 0);
        ovf_o : out std_ulogic
    );
end;

architecture arch of dsp48e_mac is
    signal c_in : signed(47 downto 0);
    signal pc_in : signed(47 downto 0);

    subtype OVF_RANGE is natural range 47 downto TOP_RESULT_BIT;
    constant ONES_MASK : signed(OVF_RANGE) := (others => '1');
    signal all_ones : std_ulogic;
    signal all_zeros : std_ulogic;

    signal opmode : std_ulogic_vector(6 downto 0);

    -- Wow.  VHDL makes this hard!  This is *supposed* to be just
    --     constant PATTERN_MASK : bit_vector(47 downto 0) := (
    --         47 downto TOP_RESULT_BIT => '0',
    --         TOP_RESULT_BIT-1 downto 0 => '1');
    -- but clearly that would be too easy to write :(
    function pattern_mask return bit_vector is
        variable result : bit_vector(47 downto 0);
    begin
        result(47 downto TOP_RESULT_BIT) := (others => '0');
        result(TOP_RESULT_BIT-1 downto 0) := (others => '1');
        return result;
    end;

begin
    -- OPMODE is documented on page 34 of UG479 (v1.10).  We configure 3 input
    -- muxes for the adder, inputs X/Y/Z.
    opmode(3 downto 0) <= "0101";       -- X/Y <= M for multiplier result
    opmode(6 downto 4) <=
        "000" when not en_c_i else      -- Z <= 0 when C not enabled
        "001" when USE_PCIN else        -- Z <= PCIN when using PCIN
        "011";                          -- Z <= C otherwise

    c_input : if USE_PCIN generate
        c_in <= (others => '0');
        pc_in <= c_i;
    else generate
        c_in <= c_i;
        pc_in <= (others => '0');
    end generate;

    dsp : DSP48E1 generic map (
        USE_PATTERN_DETECT => "PATDET",
        MASK => pattern_mask,
        SEL_MASK => "MASK"
    ) port map (
        A => std_ulogic_vector(resize(a_i, 30)),
        ACIN => (others => '0'),
        ALUMODE => "0000",
        B => std_ulogic_vector(b_i),
        BCIN => (others => '0'),
        C => std_ulogic_vector(c_in),
        CARRYCASCIN => '0',
        CARRYIN => '0',
        CARRYINSEL => "000",
        CEA1 => '0',
        CEA2 => '1',
        CEAD => '0',
        CEALUMODE => '0',
        CEB1 => '0',
        CEB2 => '1',
        CEC => '1',
        CECARRYIN => '0',
        CECTRL => '1',
        CED => '0',
        CEINMODE => '0',
        CEM => '1',
        CEP => '1',
        CLK => clk_i,
        D => (others => '0'),
        INMODE => "00000",
        MULTSIGNIN => '0',
        OPMODE => opmode,
        PCIN => std_ulogic_vector(pc_in),
        RSTA => not en_ab_i,
        RSTALLCARRYIN => '0',
        RSTALUMODE => '0',
        RSTB => not en_ab_i,
        RSTC => '0',
        RSTCTRL => '0',
        RSTD => '0',
        RSTINMODE => '0',
        RSTM => '0',
        RSTP => '0',

        ACOUT => open,
        BCOUT => open,
        CARRYCASCOUT => open,
        CARRYOUT => open,
        MULTSIGNOUT => open,
        OVERFLOW => open,
        signed(P) => p_o,
        PATTERNBDETECT => all_zeros,
        PATTERNDETECT => all_ones,
        signed(PCOUT) => pc_o,
        UNDERFLOW => open
    );

    -- No overflow when the selected pattern is detected.
    ovf_o <= '0' when all_ones or all_zeros else '1';
end;
