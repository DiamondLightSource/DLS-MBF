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
        nco_mux_i : in std_ulogic_vector(NCO_SET);
        bank_mux_i : in std_ulogic;

        -- Data channels
        dsp_to_control_i : in dsp_to_control_array_t;

        -- Outgoing data
        adc_o   : out signed_array;
        nco_data_ch0_o : out nco_data_array_t;
        nco_data_ch1_o : out nco_data_array_t;
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
        return result;
    end;

    function assign_sin(input : dsp_nco_to_mux_t) return dsp_nco_from_mux_t is
        variable result : dsp_nco_from_mux_t;
    begin
        result.nco := input.nco.sin;
        result.gain := input.gain;
        return result;
    end;

    signal d2c0_nco_iq : nco_iq_array_t;
    signal d2c1_nco_iq : nco_iq_array_t;

    -- Outputs so that we can zero initialise for simulation
    signal adc_out   : signed_array(CHANNELS)(ADC_DATA_RANGE) :=
        (others => (others => '0'));
    signal nco_data_ch0_out : nco_data_array_t :=
        (others => (nco => (others => '0'), gain => (others => '0')));
    signal nco_data_ch1_out : nco_data_array_t :=
        (others => (nco => (others => '0'), gain => (others => '0')));
    signal bank_select_out : unsigned_array(CHANNELS)(1 downto 0) :=
        (others => (others => '0'));

begin
    -- Delay lines for NCO data in.
    nco_delays : for i in NCO_SET generate
        ch0_delay : entity work.dsp_nco_to_mux_delay generic map (
            DELAY => NCO_DELAY
        ) port map (
            clk_i => clk_i,
            data_i => d2c0.nco_iq(i),
            data_o => d2c0_nco_iq(i)
        );

        ch1_delay : entity work.dsp_nco_to_mux_delay generic map (
            DELAY => NCO_DELAY
        ) port map (
            clk_i => clk_i,
            data_i => d2c1.nco_iq(i),
            data_o => d2c1_nco_iq(i)
        );
    end generate;

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
            for i in NCO_SET loop
                nco_data_ch0_out(i) <= assign_cos(d2c0_nco_iq(i));
                if nco_mux_i(i) = '1' then
                    nco_data_ch1_out(i) <= assign_sin(d2c0_nco_iq(i));
                else
                    nco_data_ch1_out(i) <= assign_cos(d2c1_nco_iq(i));
                end if;
            end loop;

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
    nco_data_ch0_o <= nco_data_ch0_out;
    nco_data_ch1_o <= nco_data_ch1_out;
    bank_select_o <= bank_select_out;
end;
