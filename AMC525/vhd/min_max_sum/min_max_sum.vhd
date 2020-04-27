-- Bunch by bunch min/max/sum accumulation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.min_max_sum_defs.all;

use work.register_defs.all;

entity min_max_sum is
    generic (
        ADDR_BITS : natural := BUNCH_NUM_BITS
    );
    port (
        dsp_clk_i : in std_ulogic;
        adc_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;

        data_i : in signed(15 downto 0);
        delta_o : out unsigned(15 downto 0);

        -- Two register readout interface:
        -- First returns the accumulated event count and swaps buffers
        -- Read second repeatedly to return and reset memory bank
        read_strobe_i : in std_ulogic_vector(MMS_REGS_RANGE);
        read_data_o : out reg_data_array_t(MMS_REGS_RANGE);
        read_ack_o : out std_ulogic_vector(MMS_REGS_RANGE)
    );
end;

architecture arch of min_max_sum is
    signal turn_clock : std_ulogic;
    signal data : signed(15 downto 0);
    signal delta : unsigned(15 downto 0);

    signal read_strobe : std_ulogic_vector(MMS_REGS_RANGE);
    signal read_data : reg_data_array_t(MMS_REGS_RANGE);
    signal read_ack : std_ulogic_vector(MMS_REGS_RANGE);

    -- Pipeline delays
    constant TURN_CLOCK_PIPELINE : natural := 4;
    constant DATA_PIPELINE : natural := 4;
    constant DELTA_PIPELINE : natural := 2;

begin
    -- -------------------------------------------------------------------------
    -- Pipelines for all inputs and outputs

    turn_clock_delay : entity work.dlyreg generic map (
        DLY => TURN_CLOCK_PIPELINE
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => turn_clock_i,
        data_o(0) => turn_clock
    );

    data_delay : entity work.dlyreg generic map (
        DLY => DATA_PIPELINE,
        DW => 16
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(data_i),
        signed(data_o) => data
    );

    delta_delay : entity work.dlyreg generic map (
        DLY => DELTA_PIPELINE,
        DW => 16
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(delta),
        unsigned(data_o) => delta_o
    );


    -- Map register read across from DSP to ADC clock domain
    register_read_adc : entity work.register_read_adc port map (
        dsp_clk_i => dsp_clk_i,
        adc_clk_i => adc_clk_i,

        dsp_read_strobe_i => read_strobe_i,
        dsp_read_data_o => read_data_o,
        dsp_read_ack_o => read_ack_o,

        adc_read_strobe_o => read_strobe,
        adc_read_data_i => read_data,
        adc_read_ack_i => read_ack
    );


    -- Core implementation
    core : entity work.min_max_sum_core generic map (
        ADDR_BITS => ADDR_BITS
    ) port map (
        adc_clk_i => adc_clk_i,
        turn_clock_i => turn_clock,

        data_i => data,
        delta_o => delta,

        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack
    );
end;
