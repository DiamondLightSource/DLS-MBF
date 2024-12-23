-- Selector for fast memory

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.dsp_defs.all;

entity fast_memory_data_mux is
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- Input control
        mux_select_i : in std_ulogic_vector(3 downto 0);

        dsp_to_control_i : in dsp_to_control_array_t;
        extra_i : in std_ulogic_vector(63 downto 0);

        data_o : out std_ulogic_vector(63 downto 0) := (others => '0')
    );
end;

architecture arch of fast_memory_data_mux is
    signal adc_phase : std_ulogic;

    -- Incoming data
    signal adc    : signed_array(CHANNELS)(15 downto 0);
    signal fir    : signed_array(CHANNELS)(15 downto 0);
    signal dac    : signed_array(CHANNELS)(15 downto 0);
    signal extra  : signed_array(CHANNELS)(15 downto 0);
    -- Outgoing data
    signal data   : signed_array(CHANNELS)(15 downto 0)
        := (others => (others => '0'));
    signal data_out : std_ulogic_vector(31 downto 0);
    signal wide_data : std_ulogic_vector(63 downto 0) := (others => '0');

begin
    phase : entity work.adc_dsp_phase port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_o => adc_phase
    );

    pipeline_inst : entity work.fast_memory_pipeline generic map (
        DELAY => 4
    ) port map (
        clk_i => adc_clk_i,

        dsp_to_control_i => dsp_to_control_i,
        adc_o => adc,
        fir_o => fir,
        dac_o => dac
    );


    -- The extra data path is actually mapped directly to the output stream.
    extra(0) <= signed(extra_i(15 downto  0));
    extra(1) <= signed(extra_i(31 downto 16));

    -- Output data selection
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            case mux_select_i is
                -- For the normal case we have separate data from each
                -- channel : 00 => ADC, 01 => FIR, 10 => DAC
                when "0000" => data(0) <= adc(0); data(1) <= adc(1);
                when "0001" => data(0) <= adc(0); data(1) <= fir(1);
                when "0010" => data(0) <= adc(0); data(1) <= dac(1);
                when "0100" => data(0) <= fir(0); data(1) <= adc(1);
                when "0101" => data(0) <= fir(0); data(1) <= fir(1);
                when "0110" => data(0) <= fir(0); data(1) <= dac(1);
                when "1000" => data(0) <= dac(0); data(1) <= adc(1);
                when "1001" => data(0) <= dac(0); data(1) <= fir(1);
                when "1010" => data(0) <= dac(0); data(1) <= dac(1);
                -- When one channel is 11 we use both outputs for the other
                when "0011" => data(0) <= adc(0); data(1) <= fir(0);
                when "0111" => data(0) <= fir(0); data(1) <= dac(0);
                when "1011" => data(0) <= adc(0); data(1) <= dac(0);
                when "1100" => data(0) <= adc(1); data(1) <= fir(1);
                when "1101" => data(0) <= fir(1); data(1) <= dac(1);
                when "1110" => data(0) <= adc(1); data(1) <= dac(1);
                -- Finally, we have a reserved output option
                when "1111" => data <= extra;
                when others =>
            end case;
        end if;
    end process;

    -- Flatten the data to a single 32-bit value
    data_out(15 downto  0) <= std_ulogic_vector(data(0));
    data_out(31 downto 16) <= std_ulogic_vector(data(1));

    -- Retime the data across to the DSP clock domain
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            case adc_phase is
                when '0' => wide_data(31 downto  0) <= data_out;
                when '1' => wide_data(63 downto 32) <= data_out;
                when others =>
            end case;
        end if;
    end process;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            data_o <= wide_data;
        end if;
    end process;
end;
