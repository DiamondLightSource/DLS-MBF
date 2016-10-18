-- ADC input compensation FIR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity adc_fir is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- Taps write interface
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        -- Write reset
        write_reset_i : in std_logic;

        -- ADC data stream
        data_i : in adc_inp_t;
        data_o : out signed(15 downto 0);
        overflow_o : out std_logic
    );
end;

architecture adc_fir of adc_fir is
    constant TAP_COUNT : natural := 8;

    signal taps    : reg_data_array_t(0 to TAP_COUNT-1);
    signal taps_pl0 : reg_data_array_t(0 to TAP_COUNT-1);
    signal taps_pl : reg_data_array_t(0 to TAP_COUNT-1);

    signal fir_overflow : std_logic;
    signal overflow_detect : std_logic;

begin
    -- Single register writes to array of taps
    taps_inst : entity work.register_array generic map (
        COUNT => TAP_COUNT
    ) port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        read_strobe_i => '0',
        read_data_o => open,
        read_ack_o => open,

        write_reset_i => write_reset_i,
        read_reset_i => '0',

        registers_o => taps
    );

    false_path_gen : for t in 0 to TAP_COUNT-1 generate
        untimed_inst : entity work.untimed_register port map (
            clk_in_i => dsp_clk_i,
            clk_out_i => adc_clk_i,
            data_i => taps(t),
            data_o => taps_pl(t)
        );
    end generate;

    fast_fir_inst : entity work.fast_fir generic map (
        TAP_WIDTH => 18,
        TAP_COUNT => TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        taps_i => taps_pl,
        data_i => data_i,
        data_o => data_o,
        overflow_o => fir_overflow
    );

    -- Bring aggregate overflow signal onto DSP clock
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            if adc_phase_i = '1' then
                overflow_detect <= overflow_detect or fir_overflow;
            else
                overflow_detect <= fir_overflow;
            end if;
        end if;
    end process;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            overflow_o <= overflow_detect;
        end if;
    end process;

end;
