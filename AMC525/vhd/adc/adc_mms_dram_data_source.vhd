-- Implements dispatch of data for MMS and DRAM capture
--
-- Each source can come from either the raw output data or from the FIR
-- pre-compensated data.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_mms_dram_data_source is
    generic (
        PIPELINE_IN : natural := 4
    );
    port (
        adc_clk_i : in std_ulogic;

        unfiltered_data_i : in signed;
        filtered_data_i : in signed;
        fill_reject_data_i : in signed;

        mms_source_i : in std_ulogic_vector(1 downto 0);
        mms_data_o : out signed;

        dram_source_i : in std_ulogic_vector(1 downto 0);
        dram_data_o : out signed
    );
end;

architecture arch of adc_mms_dram_data_source is
    signal unfiltered_data_in : unfiltered_data_i'SUBTYPE;
    signal filtered_data_in : filtered_data_i'SUBTYPE;
    signal fill_reject_data_in : fill_reject_data_i'SUBTYPE;

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

    fill_reject_data_delay : entity work.dlyreg generic map (
        DLY => PIPELINE_IN,
        DW => fill_reject_data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(fill_reject_data_i),
        signed(data_o) => fill_reject_data_in
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
                    mms_data_o <= fill_reject_data_in;
                when others =>
                    mms_data_o <= (mms_data_o'RANGE => '0');
            end case;

            case dram_source_i is
                when "00" =>
                    dram_data_o <= unfiltered_data_in;
                when "01" =>
                    dram_data_o <= filtered_data_in;
                when "10" =>
                    dram_data_o <= fill_reject_data_in;
                when others =>
                    dram_data_o <= (dram_data_o'RANGE => '0');
            end case;
        end if;
    end process;
end;
