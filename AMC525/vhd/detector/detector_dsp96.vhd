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
--             start_delay <= start_i;
--             if start_delay = '1' then
--                 accum <= resize(product, accum'LENGTH);
--             else
--                 accum <= accum + product;
--             end if;
--             sum_o <= accum;
--         end if;
--     end process;
--
-- This design means that the delay from data_i to sum_o is 4 ticks as shown:
--
--      0         1          2          3        4
--      data_i -> data_in -> product -> accum -> sum_o

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

        sum_o : out signed(95 downto 0)
    );
end;

architecture arch of detector_dsp96 is
    signal carrycasc : std_logic;
    signal multsign : std_logic;

    signal opmode_low : std_logic_vector(6 downto 0);
    signal opmode_high : std_logic_vector(6 downto 0);
    signal carryinsel_high : std_logic_vector(2 downto 0);
    signal sum_low : signed(47 downto 0);

begin
    -- Both the OPMODE and CARRYINSEL controls are registered, so we need to
    -- manage our timing carefully.  Both low and high units need to be
    -- programmed differently when starting, and the high unit needs to be
    -- controlled one tick later.

    process (start_i) begin
        if start_i = '1' then
            opmode_low  <= "000" & "01" & "01";     -- Load M into P
        else
            opmode_low  <= "010" & "01" & "01";     -- Add M to P
        end if;
    end process;

    process (clk_i) begin
        if rising_edge(clk_i) then
            if start_i = '1' then
                -- In this condition we need to extend the MULTSIGN from the low
                -- unit, but need to ignore the accumulator carry.
                opmode_high <= "000" & "10" & "00";     -- Use MACC extend, no P
                carryinsel_high <= "000";               -- CARRYIN = '1'
            else
                -- In this mode we need to add both the multiplier sign
                -- extension and the accumulator carry.
                opmode_high <= "100" & "10" & "00";     -- MACC_EXTEND
                carryinsel_high <= "010";               -- CARRYCASCIN
            end if;

            sum_o(47 downto 0) <= sum_low;
        end if;
    end process;


    -- Low order multiply/accumlate unit.  This accumulates the bottom 48 bits
    -- of the accumulator and performs the multiplication.  This unit runs one
    -- clock tick in advance of the the high order unit.
    dsp48e1_low : DSP48E1 generic map (
        ALUMODEREG => 0,
        CARRYINSELREG => 0,
        INMODEREG => 0
    ) port map (
        A => std_logic_vector(resize(data_i, 30)),
        ACIN => (others => '0'),
        ALUMODE => "0000",
        B => std_logic_vector(mul_i),
        BCIN => (others => '0'),
        C => (others => '0'),
        CARRYCASCIN => '0',
        CARRYIN => '0',
        CARRYINSEL => "000",
        CEA1 => '0',
        CEA2 => '1',
        CEAD => '0',
        CEALUMODE => '0',
        CEB1 => '0',
        CEB2 => '1',
        CEC => '0',
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
        PATTERNBDETECT => open,
        PATTERNDETECT => open,
        PCOUT => open,
        UNDERFLOW => open
    );

    -- High order unit, just accumulates product sign extension and accumulator
    -- carry, so we can turn the multiply unit off.
    dsp48e1_high : DSP48E1 generic map (
        ALUMODEREG => 0,
        CARRYINREG => 0,
        INMODEREG => 0,
        USE_MULT => "NONE",
        MREG => 0
    ) port map (
        A => (others => '0'),
        ACIN => (others => '0'),
        ALUMODE => "0000",
        B => (others => '0'),
        BCIN => (others => '0'),
        C => (others => '0'),
        CARRYCASCIN => carrycasc,
        CARRYIN => '1',
        CARRYINSEL => carryinsel_high,
        CEA1 => '0',
        CEA2 => '0',
        CEAD => '0',
        CEALUMODE => '0',
        CEB1 => '0',
        CEB2 => '0',
        CEC => '0',
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
        PATTERNBDETECT => open,
        PATTERNDETECT => open,
        PCOUT => open,
        UNDERFLOW => open
    );
end;
