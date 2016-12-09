-- Selector for fast memory


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.dsp_defs.all;

entity fast_memory_mux is
    port (
        dsp_clk_i : in std_logic;

        -- Input control
        mux_select_i : in std_logic_vector(3 downto 0);
        fir_gain_i : in unsigned(3 downto 0);

        -- Data processing
        data_valid_i : in std_logic;
        dsp0_to_control_i : in dsp_to_control_t;
        dsp1_to_control_i : in dsp_to_control_t;
        extra_i : in std_logic_vector;

        -- Data out with write enable
        data_valid_o : out std_logic;
        data_o : out std_logic_vector
    );
end;

architecture fast_memory_mux of fast_memory_mux is
    subtype CHANNELS is natural range 0 to 1;
    -- Incoming data
    signal adc    : signed_array_array(CHANNELS)(LANES)(15 downto 0);
    signal fir_in : signed_array_array(CHANNELS)(LANES)(FIR_DATA_RANGE);
    signal fir    : signed_array_array(CHANNELS)(LANES)(15 downto 0);
    signal dac    : signed_array_array(CHANNELS)(LANES)(15 downto 0);
    signal extra  : signed_array_array(CHANNELS)(LANES)(15 downto 0);
    -- Outgoing data
    signal data   : signed_array_array(CHANNELS)(LANES)(15 downto 0);

begin
    -- Extract incoming data for processing
    adc(0)    <= dsp0_to_control_i.adc_data;
    fir_in(0) <= dsp0_to_control_i.fir_data;
    dac(0)    <= dsp0_to_control_i.dac_data;
    adc(1)    <= dsp1_to_control_i.adc_data;
    fir_in(1) <= dsp1_to_control_i.fir_data;
    dac(1)    <= dsp1_to_control_i.dac_data;
    -- The extra data path is actually mapped directly to the output stream, so
    -- this is just an inversion of the output ordering.
    extra(0)(0) <= signed(extra_i(15 downto  0));
    extra(1)(0) <= signed(extra_i(31 downto 16));
    extra(0)(1) <= signed(extra_i(47 downto 32));
    extra(1)(1) <= signed(extra_i(63 downto 48));

    -- Gain control on FIR data
    chans_gen : for c in CHANNELS generate
        lanes_gen : for l in LANES generate
            fir_gain_inst : entity work.gain_control generic map (
                INTERVAL => 2
            ) port map (
                clk_i => dsp_clk_i,
                gain_sel_i => fir_gain_i,
                data_i => fir_in(c)(l),
                data_o => fir(c)(l),
                overflow_o => open
            );
        end generate;
    end generate;

    -- Output data selection
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
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
                when "1011" => data(0) <= dac(0); data(1) <= adc(0);
                when "1100" => data(0) <= adc(1); data(1) <= fir(1);
                when "1101" => data(0) <= fir(1); data(1) <= dac(1);
                when "1110" => data(0) <= dac(1); data(1) <= adc(1);
                -- Finally, we have a reserved output option
                when "1111" => data <= extra;
                when others =>
            end case;

            data_valid_o <= data_valid_i;
        end if;
    end process;

    -- Reorder DRAM0 data: we want alternating dsp0/dsp1 values.
    data_o(15 downto  0) <= std_logic_vector(data(0)(0));
    data_o(31 downto 16) <= std_logic_vector(data(1)(0));
    data_o(47 downto 32) <= std_logic_vector(data(0)(1));
    data_o(63 downto 48) <= std_logic_vector(data(1)(1));
end;
