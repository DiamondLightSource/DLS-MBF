library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;

package detector_defs is
    constant DETECTOR_COUNT : natural := 4;
    subtype DETECTOR_RANGE is natural range DETECTOR_COUNT-1 downto 0;

    subtype cos_sin_96_t is cos_sin_t(cos(95 downto 0), sin(95 downto 0));
    subtype cos_sin_32_t is cos_sin_t(cos(31 downto 0), sin(31 downto 0));
end;
