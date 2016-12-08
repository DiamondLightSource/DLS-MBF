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
    -- the detectory.  Finally, an internal 19-bit value is returned by table
    -- lookup (the top bit is always zero) before refinement.
    subtype cos_sin_16_t is cos_sin_t(cos(15 downto 0), sin(15 downto 0));
    subtype cos_sin_18_t is cos_sin_t(cos(17 downto 0), sin(17 downto 0));
    subtype cos_sin_19_t is cos_sin_t(cos(18 downto 0), sin(18 downto 0));

    type cos_sin_16_lanes_t is array(LANES) of cos_sin_16_t;
    type cos_sin_18_lanes_t is array(LANES) of cos_sin_18_t;
    type cos_sin_19_lanes_t is array(LANES) of cos_sin_19_t;

    -- Global phase and phase advance
    subtype angle_t is unsigned(31 downto 0);
    type angle_lanes_t is array(LANES) of angle_t;

    -- For calculation the angle is split into three parts: octant, lookup, and
    -- residue.
    subtype octant_t is unsigned(2 downto 0);
    subtype lookup_t is unsigned(9 downto 0);
    subtype residue_t is unsigned(18 downto 0);
    type lookup_lanes_t is array(LANES) of lookup_t;
    type residue_lanes_t is array(LANES) of residue_t;

    -- 10 bit lookup
    subtype cos_sin_addr_t is unsigned(9 downto 0);

end;
