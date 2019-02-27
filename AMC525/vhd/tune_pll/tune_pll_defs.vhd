library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;
use work.detector_defs.all;

package tune_pll_defs is
    constant PHASE_ANGLE_BITS : natural := 18;

    subtype phase_angle_t is signed(PHASE_ANGLE_BITS-1 downto 0);

    -- Control settings
    type tune_pll_config_t is record
        -- NCO control
        nco_gain : unsigned(3 downto 0);
        nco_enable : std_ulogic;
        nco_reset : std_ulogic;

        -- Detector control and status
        data_select : std_logic_vector(1 downto 0);
        detector_shift : unsigned(1 downto 0);

        -- Feedback control and status
        target_phase : phase_angle_t;
        integral : signed(24 downto 0);
        proportional : signed(24 downto 0);
        magnitude_limit : unsigned(31 downto 0);
        offset_limit : signed(31 downto 0);
        base_frequency : angle_t;

        -- Debux multiplexing options for output
        filter_cordic : std_ulogic;
        capture_cordic : std_ulogic;

        -- Top level control
        dwell_time : unsigned(15 downto 0);
    end record;

    -- Direct readback values
    type tune_pll_status_t is record
        detector_overflow : std_ulogic;

        -- Feedback control and status
        magnitude_error : std_ulogic;
        offset_error : std_ulogic;

        -- Top level control
        enable_feedback : std_ulogic;
        stop_stop : std_ulogic;
        stop_detector_overflow : std_ulogic;
        stop_magnitude_error : std_ulogic;
        stop_offset_error : std_ulogic;

        -- Filtered readback signals
        filtered_iq : cos_sin_32_t;
        filtered_frequency_offset : signed(31 downto 0);
    end record;
end;
