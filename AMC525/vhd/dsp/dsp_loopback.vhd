-- Controls DSP output to ADC input loopback, useful for internal investigation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dsp_loopback is
    generic (
        PIPELINE_IN : natural := 4;
        PIPELINE_OUT : natural := 4
    );
    port (
        adc_clk_i : in std_logic;

        loopback_i : in std_logic;
        output_enable_i : in std_logic;

        adc_data_i : in signed;
        dac_data_i : in signed;

        adc_data_o : out signed;
        dac_data_o : out signed
    );
end;

architecture arch of dsp_loopback is
    signal adc_data_in : adc_data_i'SUBTYPE;
    signal dac_data_in : dac_data_i'SUBTYPE;
    signal adc_data_out : adc_data_o'SUBTYPE := (others => '0');
    signal dac_data_out : dac_data_o'SUBTYPE := (others => '0');

begin
    adc_in_delay : entity work.dlyreg generic map (
        DLY => PIPELINE_IN,
        DW => adc_data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(adc_data_i),
        signed(data_o) => adc_data_in
    );

    dac_in_delay : entity work.dlyreg generic map (
        DLY => PIPELINE_IN,
        DW => dac_data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(dac_data_i),
        signed(data_o) => dac_data_in
    );


    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            case loopback_i is
                when '0' => adc_data_out <= adc_data_in;
                when '1' => adc_data_out <= dac_data_in(15 downto 2);
                when others =>
            end case;

            if output_enable_i = '1' then
                dac_data_out <= dac_data_in;
            else
                dac_data_out <= (others => '0');
            end if;
        end if;
    end process;


    adc_out_delay : entity work.dlyreg generic map (
        DLY => PIPELINE_OUT,
        DW => adc_data_o'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(adc_data_out),
        signed(data_o) => adc_data_o
    );

    dac_out_delay : entity work.dlyreg generic map (
        DLY => PIPELINE_OUT,
        DW => dac_data_o'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(dac_data_out),
        signed(data_o) => dac_data_o
    );
end;
