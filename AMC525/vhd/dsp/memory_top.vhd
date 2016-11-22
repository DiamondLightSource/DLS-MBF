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
begin
    ddr1_data_strobe_o <= '0';
    write_ack_o <= (others => '1');
    read_ack_o <= (others => '1');

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            for l in LANES loop
                ddr0_data_o(l) <= std_logic_vector(adc_data_i(l));
            end loop;
        end if;
    end process;

end;
