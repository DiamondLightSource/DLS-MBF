library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity testbench is
end testbench;


architecture testbench of testbench is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;

    signal dsp_clk : std_logic := '0';

    procedure tick_wait(count : natural) is
    begin
        clk_wait(dsp_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(dsp_clk, 1);
    end procedure;


    signal adc_clk : std_logic := '1';

    signal dsp_reset_n : std_logic := '0';
    signal dsp_clk_ok : std_logic := '0';



    signal adc_phase : std_logic;

    signal adc_data : adc_inp_t := (others => '0');
    signal dac_data : dac_out_t;

    signal write_strobe : reg_strobe_t;
    signal write_data : reg_data_t;
    signal write_ack : reg_strobe_t;
    signal read_strobe : reg_strobe_t;
    signal read_data : reg_data_array_t(REG_ADDR_RANGE);
    signal read_ack : reg_strobe_t;

    signal ddr0_data : ddr0_data_channels;

    signal ddr1_data : ddr1_data_t;
    signal ddr1_data_strobe : std_logic;

    signal dsp_control : dsp_control_t;
    signal dsp_status : dsp_status_t;

    signal dsp_data : dac_out_channels;

begin

    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

    dsp_reset_n <= '1' after 5.5 ns;

    process (adc_clk, dsp_reset_n) begin
        if dsp_reset_n = '1' then
            if rising_edge(adc_clk) then
                if dsp_clk_ok then
                    adc_data <= adc_data + 1;
                end if;
            end if;
        end if;
    end process;

    sync_reset_inst : entity work.sync_reset port map (
        clk_i => dsp_clk,
        clk_ok_i => dsp_reset_n,
        sync_clk_ok_o => dsp_clk_ok
    );

    adc_phase_inst : entity work.adc_phase port map (
        adc_clk_i => adc_clk,
        dsp_clk_ok_i => dsp_clk_ok,
        adc_phase_o => adc_phase
    );

    adc_to_dsp_inst : entity work.adc_to_dsp port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,
        adc_phase_i => adc_phase,

        adc_data_i => resize(adc_data, DAC_OUT_WIDTH),
        dsp_data_o => dsp_data
    );

    dsp_to_adc_inst : entity work.dsp_to_adc port map (
        adc_clk_i => adc_clk,
        adc_phase_i => adc_phase,

        dsp_data_i => dsp_data,
        adc_data_o => dac_data
    );

--     dsp_top_inst : entity work.dsp_top port map (
--         adc_clk_i => adc_clk,
--         dsp_clk_i => dsp_clk,
--         adc_phase_i => adc_phase,
-- 
--         adc_data_i => adc_data,
--         dac_data_o => dac_data,
-- 
--         write_strobe_i => write_strobe,
--         write_data_i => write_data,
--         write_ack_o => write_ack,
--         read_strobe_i => read_strobe,
--         read_data_o => read_data,
--         read_ack_o => read_ack,
-- 
--         ddr0_data_o => ddr0_data,
-- 
--         ddr1_data_o => ddr1_data,
--         ddr1_data_strobe_o => ddr1_data_strobe,
-- 
--         dsp_control_i => dsp_control,
--         dsp_status_o => dsp_status
--     );


end testbench;
