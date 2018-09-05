library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity test_spi_master is
end test_spi_master;


architecture arch of test_spi_master is
    procedure clk_wait(signal clk_i : in std_ulogic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal dsp_clk : std_ulogic := '0';

    signal spi_start : std_ulogic;
    signal spi_r_wn : std_ulogic;
    signal spi_busy : std_ulogic;
    signal spi_data : std_ulogic;

    procedure tick_wait(count : natural) is
    begin
        clk_wait(dsp_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(dsp_clk, 1);
    end procedure;

begin
    dsp_clk <= not dsp_clk after 2 ns;

    spi_master_inst : entity work.spi_master generic map (
        ADDRESS_BITS => 3,
        DATA_BITS => 4,
        LOG_SCLK_DIVISOR => 2
    ) port map (
        clk_i => dsp_clk,

        csn_o => open,
        sclk_o => open,
        mosi_o => spi_data,
        moen_o => open,
        miso_i => spi_data,

        start_i => spi_start,
        r_wn_i => spi_r_wn,
        command_i => "101",
        data_i => "1010",
        busy_o => spi_busy,
        response_o => open
    );

    process begin
        spi_start <= '0';
        spi_r_wn <= '0';

        tick_wait(2);
        spi_start <= '1';
        tick_wait;
        spi_start <= '0';
        tick_wait;

        wait until spi_busy = '0';

        spi_r_wn <= '1';
        spi_start <= '1';
        tick_wait;
        spi_start <= '0';

        wait;
    end process;


end;
