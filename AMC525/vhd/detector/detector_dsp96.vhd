-- Explicit instantiation of two DSP48E1 cores for a 96 bit accumulator
--
-- Unfortunately it would appear that the 96 bit accumulator cannot be inferred,
-- so we have to instantiate the complete DSP48E1 core explicitly.  This is
-- quite complex!
--
-- Here we implement the following processing loop using two cascaded DSP48E1
-- cores to implement a 96 bit accumulator.
--
--     process (clk_i) begin
--         if rising_edge(clk_i) then
--             data_in <= data_i when enable_i = '1' else (others => '0');
--             mul_in  <= mul_i  when enable_i = '1' else (others => '0');
--             product <= mul_in * data_in;
--             start_in <= start_i;
--             start_delay <= start_in;
--             if start_delay = '1' then
--                 accum <= product + preload_i;
--             else
--                 accum <= product + accum;
--             end if;
--             sum_o <= accum;
--         end if;
--     end process;
--
-- This design means that the delay from data_i to sum_o is 4 ticks as shown:
--
--      0         1          2          3        4
--      data_i -> data_in -> product -> accum -> sum_o
--
-- Perhaps somewhat more to the point is the four and five tick delay from
-- start_i to sum_o and overflow_o as shown below:
--
--  clk_i           /       /       /       /       /       /       /       /
--                    _______   1       2       3       4       5
--  start_i         _/       \_______________________________________________
--
--  register c low     mask  / load  /  mask
--  C low              mask          / load  /  mask
--
--  P low            / Pn-2  / Pn-1  / Pn    / P0    / P1    / P2    / P3    /
--  detect_low       / Pn-2  / Pn-1  / Pn    / xxxxx / P1    / P2    / P3    /
--  detect_low_pl    / Pn-3  / Pn-2  / Pn-1  / Pn    / xxxxx / P1    / P2    /
--
--  register c high    mask          / load  /  mask
--  C high             mask                  / load  /  mask
--
--  P high           / Pn-3  / Pn-2  / Pn-1  / Pn    / P0    / P1    / P2    /
--  detect_high      / Pn-3  / Pn-2  / Pn-1  / Pn    / xxxxx / P0    / P1    /
--
--  sum_o            / Pn-3  / Pn-2  / Pn-1  / Pn    / P0    / P1    / P2    /
--  overflow_o       / Pn-4  / Pn-3  / Pn-2  / Pn-1  / Pn    / xxxxx / P0    /
--
--  delay from start    0       1       2       3       4       5
--
-- Several details to note here.  Firstly, there is significant pipelining
-- required to keep the DSP units happy.  Secondly, because both the preload and
-- pattern compare masks share the C register, this means that immediately after
-- loading P the pattern detect bits are invalid; fortunately, the pattern we're
-- actually interested in (the last updated value) is valid.  Finally, in this
-- design there is a skew between sum_o and overflow_o.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity detector_dsp96 is
    port (
        clk_i : in std_logic;

        data_i : in signed(24 downto 0);
        mul_i : in signed(17 downto 0);

        enable_i : in std_logic;
        start_i : in std_logic;

        overflow_mask_i : in signed(95 downto 0);
        preload_i : in signed(95 downto 0);

        sum_o : out signed(95 downto 0) := (others => '0');
        overflow_o : out std_logic
    );
end;

architecture arch of detector_dsp96 is
    signal carrycasc : std_logic;
    signal multsign : std_logic;
    signal start_in : std_logic := '0';

    signal opmode_low : std_logic_vector(6 downto 0) := "0000101";
    signal opmode_high : std_logic_vector(6 downto 0) := "0001000";
    signal carryinsel_high : std_logic_vector(2 downto 0) := "000";
    signal sum_low : signed(47 downto 0) := (others => '0');

    signal register_c_low : signed(47 downto 0);
    signal register_c_high : signed(95 downto 48);
    signal detect_low : std_logic;
    signal detect_low_bar : std_logic;
    signal detect_low_pl : std_logic;
    signal detect_low_bar_pl : std_logic;
    signal detect_high : std_logic;
    signal detect_high_bar : std_logic;

begin
    -- Both the OPMODE and CARRYINSEL controls are registered, so we need to
    -- manage our timing carefully.  Both low and high units need to be
    -- programmed differently when starting, and the high unit needs to be
    -- controlled one tick later.

    process (clk_i) begin
        if rising_edge(clk_i) then
            if start_i = '1' then
                opmode_low  <= "011" & "01" & "01";     -- Load M + C into P
                register_c_low <= preload_i(47 downto 0);
            else
                opmode_low  <= "010" & "01" & "01";     -- Accumulate M into P
                register_c_low <= overflow_mask_i(47 downto 0);
            end if;

            start_in <= start_i;
            if start_in = '1' then
                -- Here we load the sign bit from the previous load (available
                -- as sum_low(47) into P; to reduce routing costs we do the
                -- appropriate calculations in the DSP unit.
                opmode_high <= "011" & "10" & "00";     -- C + -1 + CARRYIN
                carryinsel_high <= "000";               -- Select CARRYIN = sign
                register_c_high <= preload_i(95 downto 48);
            else
                -- In this mode we need to add both the multiplier sign
                -- extension and the accumulator carry.
                opmode_high <= "100" & "10" & "00";     -- MACC_EXTEND
                carryinsel_high <= "010";               -- CARRYCASCIN
                register_c_high <= overflow_mask_i(95 downto 48);
            end if;

            sum_o(47 downto 0) <= sum_low;

            detect_low_pl <= detect_low;
            detect_low_bar_pl <= detect_low_bar;

            -- Detect overflow if we don't get perfect pattern match.
            overflow_o <= not (
                (detect_low_pl and detect_high) or
                (detect_low_bar_pl and detect_high_bar));
        end if;
    end process;


    -- Low order multiply/accumlate unit.  This accumulates the bottom 48 bits
    -- of the accumulator and performs the multiplication.  This unit runs one
    -- clock tick in advance of the the high order unit.
    dsp48e1_low : DSP48E1 generic map (
        ALUMODEREG => 0,
        CARRYINSELREG => 0,
        INMODEREG => 0,
        USE_PATTERN_DETECT => "PATDET",
        SEL_MASK => "C"
    ) port map (
        A => std_logic_vector(resize(data_i, 30)),
        ACIN => (others => '0'),
        ALUMODE => "0000",
        B => std_logic_vector(mul_i),
        BCIN => (others => '0'),
        C => std_logic_vector(register_c_low),
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
        OPMODE => opmode_low,
        PCIN => (others => '0'),
        RSTA => not enable_i,
        RSTALLCARRYIN => '0',
        RSTALUMODE => '0',
        RSTB => not enable_i,
        RSTC => '0',
        RSTCTRL => '0',
        RSTD => '0',
        RSTINMODE => '0',
        RSTM => '0',
        RSTP => '0',

        ACOUT => open,
        BCOUT => open,
        CARRYCASCOUT => carrycasc,
        CARRYOUT => open,
        MULTSIGNOUT => multsign,
        OVERFLOW => open,
        signed(P) => sum_low,
        PATTERNBDETECT => detect_low_bar,
        PATTERNDETECT => detect_low,
        PCOUT => open,
        UNDERFLOW => open
    );

    -- High order unit, just accumulates product sign extension and accumulator
    -- carry, so we can turn the multiply unit off.
    dsp48e1_high : DSP48E1 generic map (
        ALUMODEREG => 0,
        CARRYINREG => 0,
        INMODEREG => 0,
        MREG => 0,
        USE_MULT => "NONE",
        USE_PATTERN_DETECT => "PATDET",
        SEL_MASK => "C"
    ) port map (
        A => (others => '0'),
        ACIN => (others => '0'),
        ALUMODE => "0000",
        B => (others => '0'),
        BCIN => (others => '0'),
        C => std_logic_vector(register_c_high),
        CARRYCASCIN => carrycasc,
        CARRYIN => not sum_low(47),
        CARRYINSEL => carryinsel_high,
        CEA1 => '0',
        CEA2 => '0',
        CEAD => '0',
        CEALUMODE => '1',
        CEB1 => '0',
        CEB2 => '0',
        CEC => '1',
        CECARRYIN => '0',
        CECTRL => '1',
        CED => '0',
        CEINMODE => '0',
        CEM => '0',
        CEP => '1',
        CLK => clk_i,
        D => (others => '0'),
        INMODE => "00000",
        MULTSIGNIN => multsign,
        OPMODE => opmode_high,
        PCIN => (others => '0'),
        RSTA => '0',
        RSTALLCARRYIN => '0',
        RSTALUMODE => '0',
        RSTB => '0',
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
        signed(P) => sum_o(95 downto 48),
        PATTERNBDETECT => detect_high,
        PATTERNDETECT => detect_high_bar,
        PCOUT => open,
        UNDERFLOW => open
    );
end;
