-- DSP data multiplexing
--
-- This manages the switching of DSP data between the two operational channels
-- depending on whether we're operating in independent or coupled channel mode.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.dsp_defs.all;

entity dsp_control_mux is
    generic (
        NCO_DELAY : natural := 4
    );
    port (
        clk_i : in std_ulogic;

        -- Multiplexer selections
        adc_mux_i : in std_ulogic;
        nco_0_mux_i : in std_ulogic;
        nco_1_mux_i : in std_ulogic;
        nco_2_mux_i : in std_ulogic;
        nco_3_mux_i : in std_ulogic;
        bank_mux_i : in std_ulogic;

        -- Data channels
        dsp_to_control_i : in dsp_to_control_array_t;

        -- Outgoing data
        adc_o   : out signed_array;
        nco_0_o : out dsp_nco_from_mux_array_t;
        nco_1_o : out dsp_nco_from_mux_array_t;
        nco_2_o : out dsp_nco_from_mux_array_t;
        nco_3_o : out dsp_nco_from_mux_array_t;
        bank_select_o : out unsigned_array
    );
end;

architecture arch of dsp_control_mux is
    -- Aliases for more compact code
    alias d2c0 : dsp_to_control_t is dsp_to_control_i(0);
    alias d2c1 : dsp_to_control_t is dsp_to_control_i(1);

    function assign_cos(input : dsp_nco_to_mux_t) return dsp_nco_from_mux_t is
        variable result : dsp_nco_from_mux_t;
    begin
        result.nco := input.nco.cos;
        result.gain := input.gain;
        result.enable := input.enable;
        return result;
    end;

    function assign_sin(input : dsp_nco_to_mux_t) return dsp_nco_from_mux_t is
        variable result : dsp_nco_from_mux_t;
    begin
        result.nco := input.nco.sin;
        result.gain := input.gain;
        result.enable := input.enable;
        return result;
    end;

    procedure nco_mux(
        signal output : out dsp_nco_from_mux_array_t;
        selector : in std_ulogic;
        input_0 : in dsp_nco_to_mux_t;
        input_1 : in dsp_nco_to_mux_t) is
    begin
        output(0) <= assign_cos(input_0);
        if selector = '1' then
            output(1) <= assign_sin(input_0);
        else
            output(1) <= assign_cos(input_1);
        end if;
    end;


    signal d2c0_nco_0_data : dsp_nco_to_mux_t;
    signal d2c0_nco_1_data : dsp_nco_to_mux_t;
    signal d2c0_nco_2_data : dsp_nco_to_mux_t;
    signal d2c0_nco_3_data : dsp_nco_to_mux_t;
    signal d2c1_nco_0_data : dsp_nco_to_mux_t;
    signal d2c1_nco_1_data : dsp_nco_to_mux_t;
    signal d2c1_nco_2_data : dsp_nco_to_mux_t;
    signal d2c1_nco_3_data : dsp_nco_to_mux_t;

    -- Outputs so that we can zero initialise for simulation
    signal adc_out   : signed_array(CHANNELS)(ADC_DATA_RANGE) :=
        (others => (others => '0'));
    signal nco_0_out : dsp_nco_from_mux_array_t :=
        (others => dsp_nco_from_mux_reset);
    signal nco_1_out : dsp_nco_from_mux_array_t :=
        (others => dsp_nco_from_mux_reset);
    signal nco_2_out : dsp_nco_from_mux_array_t :=
        (others => dsp_nco_from_mux_reset);
    signal nco_3_out : dsp_nco_from_mux_array_t :=
        (others => dsp_nco_from_mux_reset);
    signal bank_select_out : unsigned_array(CHANNELS)(1 downto 0) :=
        (others => (others => '0'));

begin
    -- Delay lines for NCO data in.
    c0_nco_0_delay : entity work.dsp_nco_to_mux_delay generic map (
        DELAY => NCO_DELAY
    ) port map (
        clk_i => clk_i,
        data_i => d2c0.nco_0_data,
        data_o => d2c0_nco_0_data
    );

    c0_nco_1_delay : entity work.dsp_nco_to_mux_delay generic map (
        DELAY => NCO_DELAY
    ) port map (
        clk_i => clk_i,
        data_i => d2c0.nco_1_data,
        data_o => d2c0_nco_1_data
    );

    c0_nco_2_delay : entity work.dsp_nco_to_mux_delay generic map (
        DELAY => NCO_DELAY
    ) port map (
        clk_i => clk_i,
        data_i => d2c0.nco_2_data,
        data_o => d2c0_nco_2_data
    );

    c0_nco_3_delay : entity work.dsp_nco_to_mux_delay generic map (
        DELAY => NCO_DELAY
    ) port map (
        clk_i => clk_i,
        data_i => d2c0.nco_3_data,
        data_o => d2c0_nco_3_data
    );

    c1_nco_0_delay : entity work.dsp_nco_to_mux_delay generic map (
        DELAY => NCO_DELAY
    ) port map (
        clk_i => clk_i,
        data_i => d2c1.nco_0_data,
        data_o => d2c1_nco_0_data
    );

    c1_nco_1_delay : entity work.dsp_nco_to_mux_delay generic map (
        DELAY => NCO_DELAY
    ) port map (
        clk_i => clk_i,
        data_i => d2c1.nco_1_data,
        data_o => d2c1_nco_1_data
    );

    c1_nco_2_delay : entity work.dsp_nco_to_mux_delay generic map (
        DELAY => NCO_DELAY
    ) port map (
        clk_i => clk_i,
        data_i => d2c1.nco_2_data,
        data_o => d2c1_nco_2_data
    );

    c1_nco_3_delay : entity work.dsp_nco_to_mux_delay generic map (
        DELAY => NCO_DELAY
    ) port map (
        clk_i => clk_i,
        data_i => d2c1.nco_3_data,
        data_o => d2c1_nco_3_data
    );


    -- Data multiplexing control
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- ADC input multiplexing
            adc_out(0) <= d2c0.adc_data;
            if adc_mux_i = '1' then
                adc_out(1) <= d2c0.adc_data;
            else
                adc_out(1) <= d2c1.adc_data;
            end if;

            -- NCO output multiplexing
            nco_mux(nco_0_out, nco_0_mux_i, d2c0_nco_0_data, d2c1_nco_0_data);
            nco_mux(nco_1_out, nco_1_mux_i, d2c0_nco_1_data, d2c1_nco_1_data);
            nco_mux(nco_2_out, nco_2_mux_i, d2c0_nco_2_data, d2c1_nco_2_data);
            nco_mux(nco_3_out, nco_3_mux_i, d2c0_nco_3_data, d2c1_nco_3_data);

            -- Bank selection
            bank_select_out(0) <= d2c0.bank_select;
            if bank_mux_i = '1' then
                bank_select_out(1) <= d2c0.bank_select;
            else
                bank_select_out(1) <= d2c1.bank_select;
            end if;
        end if;
    end process;

    adc_o <= adc_out;
    nco_0_o <= nco_0_out;
    nco_1_o <= nco_1_out;
    nco_2_o <= nco_2_out;
    nco_3_o <= nco_3_out;
    bank_select_o <= bank_select_out;
end;
