-- Controls DSP output to ADC input loopback, useful for internal investigation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dsp_loopback is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        loopback_i : in std_logic;
        output_enable_i : in std_logic;

        adc_data_i : in signed;
        dac_data_i : in signed;

        adc_data_o : out signed;
        dac_data_o : out signed
    );
end;

architecture dsp_loopback of dsp_loopback is
    signal loopback : std_logic;

begin
    -- Make the loopback control untimed to avoid the usual trouble.
    untimed_inst : entity work.untimed_reg generic map (
        WIDTH => 1
    ) port map (
        clk_in_i => adc_clk_i,
        clk_out_i => dsp_clk_i,

        write_i => '1',
        data_i(0) => loopback_i,
        data_o(0) => loopback
    );

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            case loopback is
                when '0' => adc_data_o <= adc_data_i;
                when '1' => adc_data_o <= dac_data_i(15 downto 2);
                when others =>
            end case;

            if output_enable_i = '1' then
                dac_data_o <= dac_data_i;
            else
                dac_data_o <= (dac_data_o'RANGE => '0');
            end if;
        end if;
    end process;
end;
