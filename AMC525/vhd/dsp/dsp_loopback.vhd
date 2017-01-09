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
    signal output_enable : std_logic;

    signal adc_data : signed(adc_data_o'RANGE) := (others => '0');
    signal dac_data : signed(dac_data_o'RANGE) := (others => '0');

begin
    -- Make the controls untimed to avoid the usual trouble.
    untimed_inst : entity work.untimed_reg generic map (
        WIDTH => 2
    ) port map (
        clk_i => dsp_clk_i,
        write_i => '1',
        data_i(0) => loopback_i,
        data_i(1) => output_enable_i,
        data_o(0) => loopback,
        data_o(1) => output_enable
    );

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            case loopback is
                when '0' => adc_data <= adc_data_i;
                when '1' => adc_data <= dac_data_i(15 downto 2);
                when others =>
            end case;

            if output_enable = '1' then
                dac_data <= dac_data_i;
            else
                dac_data <= (others => '0');
            end if;
        end if;
    end process;

    adc_data_o <= adc_data;
    dac_data_o <= dac_data;
end;
