-- Reference implementation for 96 bit accumulator
--
-- This is for comparison with detector_dsp48e1 which is implemented using two
-- cascaded DSP48E1 units.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sim_dsp96 is
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

architecture arch of sim_dsp96 is
    signal data_in : signed(24 downto 0) := (others => '0');
    signal mul_in : signed(17 downto 0) := (others => '0');
    signal product : signed(42 downto 0) := (others => '0');
    signal accum : signed(95 downto 0) := (others => '0');
    signal preload_in : signed(95 downto 0) := (others => '0');
    signal preload : signed(95 downto 0) := (others => '0');
    signal start_in : std_logic := '0';
    signal start_delay : std_logic := '0';

    signal match_zero : std_logic;
    signal match_ones : std_logic;

begin
    match_zero <= and (not sum_o or overflow_mask_i);
    match_ones <= and (sum_o or overflow_mask_i);

    process (clk_i) begin
        if rising_edge(clk_i) then
            if enable_i = '1' then
                data_in <= data_i;
                mul_in <= mul_i;
            else
                data_in <= (others => '0');
                mul_in <= (others => '0');
            end if;
            product <= mul_in * data_in;

            preload_in <= preload_i;
            preload <= preload_in;

            start_in <= start_i;
            start_delay <= start_in;
            if start_delay = '1' then
                accum <= product + preload;
            else
                accum <= product + accum;
            end if;

            sum_o <= accum;
            overflow_o <= not (match_zero or match_ones);
        end if;
    end process;
end;
