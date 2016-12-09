-- DSP control specific definitions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;

package dsp_defs is
    type dsp_to_control_t is record
        -- Data streams.  adc_data for capture and for multiplexing to FIR
        -- input stage, fir_data and dac_data for capture.
        adc_data : signed_array(LANES)(15 downto 0);
        fir_data : signed_array(LANES)(FIR_DATA_WIDTH-1 downto 0);
        dac_data : signed_array(LANES)(DAC_OUT_WIDTH-1 downto 0);

        nco_0_data : cos_sin_18_lanes_t;
        nco_1_data : cos_sin_18_lanes_t;
    end record;

    type control_to_dsp_t is record
        adc_data : signed_array(LANES)(15 downto 0);
        nco_0_data : signed_array(LANES)(17 downto 0);
        nco_1_data : signed_array(LANES)(17 downto 0);
    end record;
end;
