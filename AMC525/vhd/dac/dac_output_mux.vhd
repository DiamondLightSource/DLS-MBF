-- A single lane of DAC output multiplexer generation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.dsp_defs.all;
use work.bunch_defs.all;

entity dac_output_mux is
    generic (
        PIPELINE_OUT : natural := 4
    );
    port (
        clk_i : in std_ulogic;

        -- output selection and bunch by bunch gains
        bunch_config_i : in bunch_config_t;

        -- Input signals with individual "fixed" gains
        fir_data_i : in signed;
        fir_gain_i : in unsigned;

        nco_data_i : in nco_data_array_t;

        -- Generated outputs.  Note that the FIR overflow is pipelined through
        -- so that we know whether to ignore it, if the output was unused.
        data_o : out signed;
        -- This FIR data out is just for the MMS view
        fir_mms_o : out signed;

        mms_overflow_o : out std_ulogic;
        fir_overflow_o : out std_ulogic;
        mux_overflow_o : out std_ulogic
    );
end;

architecture arch of dac_output_mux is
    signal scaled_fir_data : signed(47 downto 0);

begin
    fir_gain : entity work.dac_fir_gain port map (
        clk_i => clk_i,

        fir_data_i => fir_data_i,
        fixed_gain_i => fir_gain_i,
        bb_gain_i => bunch_config_i.fir_gain,

        fir_data_o => scaled_fir_data,
        fir_mms_o => fir_mms_o,
        fir_overflow_o => fir_overflow_o,
        mms_overflow_o => mms_overflow_o
    );

    nco_gain : entity work.dac_nco_gains port map (
        clk_i => clk_i,

        bunch_config_i => bunch_config_i,
        nco_data_i => nco_data_i,

        fir_data_i => scaled_fir_data,
        dac_data_o => data_o,
        mux_overflow_o => mux_overflow_o
    );
end;
