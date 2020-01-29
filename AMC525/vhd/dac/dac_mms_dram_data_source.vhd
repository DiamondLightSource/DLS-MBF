-- Implements dispatch of data for MMS and DRAM capture
--
-- Each source can come from either the raw output data or from the FIR
-- pre-compensated data.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac_mms_dram_data_source is
    generic (
        PIPELINE_IN : natural := 2
    );
    port (
        adc_clk_i : in std_ulogic;

        unfiltered_data_i : in signed;
        filtered_data_i : in signed;
        fir_data_i : in signed;

        mms_source_i : in std_ulogic_vector;
        mms_data_o : out signed;

        dram_source_i : in std_ulogic;
        dram_data_o : out signed
    );
end;

architecture arch of dac_mms_dram_data_source is
    signal unfiltered_data_in : unfiltered_data_i'SUBTYPE;
    signal filtered_data_in : filtered_data_i'SUBTYPE;
    signal fir_data_in : fir_data_i'SUBTYPE;
    signal dram_data_out : dram_data_o'SUBTYPE := (others => '0');

begin
    unfiltered_data_delay : entity work.dlyreg generic map (
        DLY => PIPELINE_IN,
        DW => unfiltered_data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(unfiltered_data_i),
        signed(data_o) => unfiltered_data_in
    );

    filtered_data_delay : entity work.dlyreg generic map (
        DLY => PIPELINE_IN,
        DW => filtered_data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(filtered_data_i),
        signed(data_o) => filtered_data_in
    );

    fir_data_delay : entity work.dlyreg generic map (
        DLY => PIPELINE_IN,
        DW => fir_data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(fir_data_i),
        signed(data_o) => fir_data_in
    );


    -- Select sources for stored and MMS data
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            case mms_source_i is
                when "00" =>
                    mms_data_o <= unfiltered_data_in;
                when "01" =>
                    mms_data_o <= filtered_data_in;
                when "10" =>
                    mms_data_o <= fir_data_in;
                when others =>
            end case;

            if dram_source_i = '0' then
                dram_data_out <= unfiltered_data_in;
            else
                dram_data_out <= filtered_data_in;
            end if;
        end if;
    end process;

    dram_data_o <= dram_data_out;
end;
