-- Refines raw cos/sin by linear interpolation

-- The correction applied here is simply the following, with the appropriate
-- scaling:
--
--  delta = 2 * pi * residue
--  cos' = cos - delta * sin,  sin' = sin + delta * cos
--
-- but of course we need to manage our bits, and we need to ensure that we use
-- the DSP48E1 resources appropriately.
--
-- We're dealing with fixed point numbers, and we need to keep track of the
-- actual scaling of each number together with the width of each field and the
-- number of significant bits.  For example, the inputs sin_in and cos_in are
-- both 19 bit signed numbers, but we treat them as if the top bit is the units
-- bit, and in this entity the sign bit is always zero.  So let's write
--
--      cos_in, sin_in : 1.18
--
-- Unfortunately, this representation doesn't seem to behave so cleanly when
-- we're dealing with pure fractions, for example residue_i is scaled by 2^-13,
-- and is 19 bits wide; we'd probably have to write
--
--      residue_i : -13.32
--
-- So, let's try a different representation.  Let's write instead
--
--      cos_in, sin_in : 19/-18 (18)
--      residue_i : 19/-32
--
-- We interpret  x : A/B (C)  as meaning the underlying value of x is 2^B * x,
-- x is represented in A bits, of which C are significant.  When multiplying
-- we can simply add the bits in this representation.  Now we can proceed
-- with the rest of the arithmetic:
--
--      residue : 9/-21 (8)         top 8 bits of residue_i, sign extended
--      PI_SCALED : 9/-5 (8)        2*pi
--      delta_product : 18/-26 (16) raw product
--      delta : 10/-18 (8)          top 10 bits of product
--      cos_product, sin_product : 29/-36 (24)
--
-- At this point the accumulator layout needs to match the product layout so
-- that we can use the internal accumulator, so we know we need a 1.36 register:
--
--      cos_acc_in, sin_acc_in : 37/-36
--      cos_acc_out, sout_acc_out : 37/-36


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.nco_defs.all;

entity nco_cos_sin_refine is
    generic (
        LOOKUP_DELAY : natural;         -- Lead time for residue_i
        REFINE_DELAY : natural          -- Our internal delay for validation
    );
    port (
        clk_i : in std_logic;
        residue_i : in residue_t;       -- Arrives LOOKUP_DELAY ticks early

        cos_sin_i : in cos_sin_19_t;    -- Unrefined in
        cos_sin_o : out cos_sin_18_t    -- Refined out
    );
end;

architecture nco_cos_sin_refine of nco_cos_sin_refine is
    -- 2^6 * PI = 2^5 2 PI : 9/-5
    constant PI_SCALED : signed(8 downto 0) := to_signed(201, 9);

    signal residue : signed(8 downto 0);            -- 9/-21 (8)
    signal delta_product : signed(17 downto 0);     -- 18/-26 (16)
    signal delta : signed(9 downto 0);              -- 10/-18 (8)

    signal cos_in : signed(18 downto 0);            -- 19/-18 (18)
    signal sin_in : signed(18 downto 0);
    signal cos_product : signed(28 downto 0);       -- 29/-36 (24)
    signal sin_product : signed(28 downto 0);
    signal cos_acc_in : signed(36 downto 0);        -- 37/-36
    signal sin_acc_in : signed(36 downto 0);
    signal cos_acc_out : signed(36 downto 0);       -- 37/-36
    signal sin_acc_out : signed(36 downto 0);

begin
    assert LOOKUP_DELAY = 2;    -- Used for residue_i -> cos_sin_i delay
    assert REFINE_DELAY = 3;

    -- Convert unsigned residue to signed for multiplier
    residue <= signed('0' & residue_i(18 downto 11));
    cos_in <= cos_sin_i.cos;
    sin_in <= cos_sin_i.sin;

    process (clk_i) begin
        if rising_edge(clk_i) then
            delta_product <= PI_SCALED * residue;
            delta <= delta_product(17 downto 8);

            -- At this point, due to the two tick lookup delay, delta is now
            -- synchronous with cos_sin_i.

            cos_product <= delta * cos_in;
            sin_product <= delta * sin_in;
            cos_acc_in <= cos_in & "00" & X"0000";
            sin_acc_in <= sin_in & "00" & X"0000";
            cos_acc_out <= cos_acc_in - sin_product;
            sin_acc_out <= sin_acc_in + cos_product;

            -- Round the result
            cos_sin_o.cos <= round(cos_acc_out, 18);
            cos_sin_o.sin <= round(sin_acc_out, 18);
        end if;
    end process;
end;