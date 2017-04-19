-- Controls DSP output to ADC input loopback, useful for internal investigation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dsp_loopback is
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
    signal adc_data_in : adc_data_o'SUBTYPE := (others => '0');
    signal adc_data : adc_data_o'SUBTYPE := (others => '0');
    signal dac_data : dac_data_o'SUBTYPE := (others => '0');

begin
    adc_delay : entity work.dlyreg generic map (
        DLY => 4,
        DW => adc_data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(adc_data_i),
        signed(data_o) => adc_data_in
    );

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            case loopback_i is
                when '0' => adc_data <= adc_data_in;
                when '1' => adc_data <= dac_data_i(15 downto 2);
                when others =>
            end case;

            if output_enable_i = '1' then
                dac_data <= dac_data_i;
            else
                dac_data <= (others => '0');
            end if;
        end if;
    end process;

    adc_data_o <= adc_data;
    dac_data_o <= dac_data;
end;
