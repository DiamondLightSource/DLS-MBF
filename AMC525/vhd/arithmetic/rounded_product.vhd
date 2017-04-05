-- Wraps the slight complexity of computing a rounded product
--
-- Delay from a_i,b_i => ab_o is 3 ticks:
--  a_i,b_i => a_in,b_in => product => ab_out = ab_o

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rounded_product is
    port (
        clk_i : in std_logic;

        a_i : in signed;            -- Narrow term
        b_i : in signed;            -- Wider term
        ab_o : out signed           -- Rounded output
    );
end;

architecture arch of rounded_product is
    constant A_WIDTH : natural := a_i'LENGTH;
    constant B_WIDTH : natural := b_i'LENGTH;
    constant OUT_WIDTH : natural := ab_o'LENGTH;
    constant PRODUCT_WIDTH : natural := A_WIDTH + B_WIDTH;
    constant DISCARD_WIDTH : natural := PRODUCT_WIDTH - OUT_WIDTH;

    signal a_in : a_i'SUBTYPE := (others => '0');
    signal b_in : b_i'SUBTYPE := (others => '0');
    signal product : signed(PRODUCT_WIDTH-1 downto 0) := (others => '0');
    signal rounding : signed(PRODUCT_WIDTH-1 downto 0) := (others => '0');
    signal ab_out : signed(PRODUCT_WIDTH-1 downto 0) := (others => '0');

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of a_i : signal is "yes";
    attribute DONT_TOUCH of b_i : signal is "yes";

begin
    assert A_WIDTH <= 18 severity failure;
    assert B_WIDTH <= 25 severity failure;
    assert DISCARD_WIDTH > 0 severity failure;

    process (clk_i) begin
        if rising_edge(clk_i) then
            a_in <= a_i;
            b_in <= b_i;
            product <= a_in * b_in;
            rounding <= (DISCARD_WIDTH-1 => '1', others => '0');
            ab_out <= product + rounding;
        end if;
    end process;

    ab_o <= ab_out(PRODUCT_WIDTH-1 downto DISCARD_WIDTH);
end;
