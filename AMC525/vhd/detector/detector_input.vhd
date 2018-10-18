-- Detector input processing: input selection, FIR gain control, and scaling by
-- detector window.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.detector_defs.all;

entity detector_input is
    generic (
        BUFFER_LENGTH : natural
    );
    port (
        clk_i : in std_ulogic;

        -- Control
        data_select_i : in std_ulogic;

        -- Data in
        adc_data_i : in signed;
        fir_data_i : in signed;
        window_i : in signed;

        -- Data out to detector
        data_o : out signed
    );
end;

architecture arch of detector_input is
    signal fir_data_in : fir_data_i'SUBTYPE;
    signal adc_data_in : adc_data_i'SUBTYPE;
    signal window_in : window_i'SUBTYPE;
    signal scaled_adc_data : data_o'SUBTYPE;

    signal data_in : data_o'SUBTYPE := (others => '0');

    -- Shift the ADC data left so that it sits almost at the top of the word
    constant ADC_SHIFT : natural := data_o'LENGTH - adc_data_i'LENGTH - 2;

begin
    -- Input data buffers
    fir_buffer : entity work.dlyreg generic map (
        DLY => BUFFER_LENGTH,
        DW => fir_data_i'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_ulogic_vector(fir_data_i),
        signed(data_o) => fir_data_in
    );

    adc_buffer : entity work.dlyreg generic map (
        DLY => BUFFER_LENGTH,
        DW => adc_data_i'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_ulogic_vector(adc_data_i),
        signed(data_o) => adc_data_in
    );

    window_buffer : entity work.dlyreg generic map (
        DLY => BUFFER_LENGTH,
        DW => window_i'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_ulogic_vector(window_i),
        signed(data_o) => window_in
    );


    scaled_adc_data <=
        shift_left(resize(adc_data_in, data_o'LENGTH), ADC_SHIFT);

    -- Input multiplexer
    process (clk_i) begin
        if rising_edge(clk_i) then
            case data_select_i is
                when '0' =>
                    data_in <= scaled_adc_data;
                when '1' =>
                    data_in <= resize(fir_data_in, data_o'LENGTH);
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
        a_i => window_in,
        b_i => data_in,
        ab_o => data_o
    );
end;
