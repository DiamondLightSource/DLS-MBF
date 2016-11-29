-- Control of memory dispatch for DSP data

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity memory_top is
    port (
        dsp_clk_i : in std_logic;

        -- Data sources
        adc_data_i : in signed_array;
        fir_data_i : in signed_array;
        dac_data_i : in signed_array;

        -- Data destinations
        ddr0_data_o : out ddr0_data_lanes;

        ddr1_data_o : out ddr1_data_t;
        ddr1_data_strobe_o : out std_logic;

        -- General register interface
        write_strobe_i : in std_logic_vector(0 to 0);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 0);
        read_strobe_i : in std_logic_vector(0 to 0);
        read_data_o : out reg_data_array_t(0 to 0);
        read_ack_o : out std_logic_vector(0 to 0)
    );
end;

architecture memory_top of memory_top is
    signal control_reg : reg_data_t;
    signal ddr0_sel : std_logic_vector(1 downto 0);
    signal fir_gain : unsigned(3 downto 0);

    signal scaled_fir_data : signed_array(LANES)(15 downto 0);
    signal adc_data : ddr0_data_lanes;
    signal fir_data : ddr0_data_lanes;
    signal dac_data : ddr0_data_lanes;
    signal ddr0_data : ddr0_data_lanes;

begin
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        register_data_o(0) => control_reg
    );
    read_data_o(0) <= control_reg;
    read_ack_o <= (others => '1');

    ddr0_sel <= control_reg(1 downto 0);
    fir_gain <= unsigned(control_reg(7 downto 4));

    fir_scale_gen : for l in LANES generate
        fir_gain_inst : entity work.gain_control generic map (
            INTERVAL => 2
        ) port map (
            clk_i => dsp_clk_i,
            gain_sel_i => fir_gain,
            data_i => fir_data_i(l),
            data_o => scaled_fir_data(l),
            overflow_o => open
        );
    end generate;

    convert_gen : for l in LANES generate
        adc_data(l) <= std_logic_vector(adc_data_i(l));
        fir_data(l) <= std_logic_vector(scaled_fir_data(l));
        dac_data(l) <= std_logic_vector(dac_data_i(l));
    end generate;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            case ddr0_sel is
                when "00" => ddr0_data <= adc_data;
                when "01" => ddr0_data <= fir_data;
                when "10" => ddr0_data <= dac_data;
                when others =>
            end case;
            ddr0_data_o <= ddr0_data;
        end if;
    end process;

    ddr1_data_strobe_o <= '0';

end;
