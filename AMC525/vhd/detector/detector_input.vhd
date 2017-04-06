-- Detector input processing: input selection, FIR gain control, and scaling by
-- detector window.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.detector_defs.all;

entity detector_input is
    port (
        clk_i : in std_logic;

        -- Control
        fir_gain_i : in unsigned(0 downto 0);
        data_select_i : in std_logic;

        -- Data in
        adc_data_i : in signed;
        fir_data_i : in signed;
        window_i : in signed;

        -- Data out to detector
        data_o : out signed(24 downto 0);
        fir_overflow_o : out std_logic
    );
end;

architecture arch of detector_input is
    signal scaled_adc_data : data_o'SUBTYPE;
    signal scaled_fir_data : data_o'SUBTYPE;
    signal fir_overflow_in : std_logic;
    signal fir_overflow : std_logic := '0';

    signal data_in : data_o'SUBTYPE := (others => '0');

    -- Shift the ADC data left so that it sits almost at the top of the word
    constant ADC_SHIFT : natural := data_o'LENGTH - adc_data_i'LENGTH - 2;

begin
    fir_gain : entity work.gain_control generic map (
        INTERVAL => 8,
        EXTRA_SHIFT => 3
    ) port map (
        clk_i => clk_i,
        gain_sel_i => fir_gain_i,
        data_i => fir_data_i,
        data_o => scaled_fir_data,
        overflow_o => fir_overflow_in
    );

    scaled_adc_data <= shift_left(resize(adc_data_i, data_o'LENGTH), ADC_SHIFT);

    -- Input multiplexer
    process (clk_i) begin
        if rising_edge(clk_i) then
            case data_select_i is
                when '0' =>
                    data_in <= scaled_adc_data;
                    fir_overflow <= '0';
                when '1' =>
                    data_in <= scaled_fir_data;
                    fir_overflow <= fir_overflow_in;
                when others =>
            end case;
        end if;
    end process;


    -- Multiply incoming data by window for final output.  We discard the
    -- top-most bit of the product, as this is only significant if both input
    -- terms are min-int, and the FIR value never will be.
    product : entity work.rounded_product generic map (
        DISCARD_TOP => 1
    ) port map (
        clk_i => clk_i,
        a_i => window_i,
        b_i => data_in,
        ab_o => data_o
    );


    -- Delay overflow report to match data delay:
    --  data_in =(3)=> data_o
    delay : entity work.dlyline generic map (
        DLY => 3
    ) port map (
        clk_i => clk_i,
        data_i(0) => fir_overflow,
        data_o(0) => fir_overflow_o
    );
end;
