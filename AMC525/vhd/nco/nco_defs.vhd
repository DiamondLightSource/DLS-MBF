library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

package nco_defs is

    type cos_sin_t is record
        cos : signed;
        sin : signed;
    end record;

    -- Three different sizes of cos/sin.  We output a scaled 16-bit value for
    -- output to the DAC, and an unscaled 18-bit value for multiplication in
    -- the detector.  Finally, an internal 19-bit value is returned by table
    -- lookup (the top bit is always zero) before refinement.
    subtype cos_sin_16_t is cos_sin_t(cos(15 downto 0), sin(15 downto 0));
    subtype cos_sin_18_t is cos_sin_t(cos(17 downto 0), sin(17 downto 0));
    subtype cos_sin_19_t is cos_sin_t(cos(18 downto 0), sin(18 downto 0));

    -- Global phase and phase advance
    subtype angle_t is unsigned(47 downto 0);

    -- For calculation the angle is split into three parts: octant, lookup, and
    -- residue.
    subtype octant_t is unsigned(2 downto 0);
    subtype lookup_t is unsigned(9 downto 0);
    subtype residue_t is unsigned(34 downto 0);

    -- 10 bit lookup
    subtype cos_sin_addr_t is unsigned(9 downto 0);
end;
