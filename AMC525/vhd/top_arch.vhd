library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

architecture top of top is
    signal clk100mhz : std_logic;
    signal ctr100mhz : unsigned(25 downto 0);
begin
--     clk100in : IBUFDS port map (
--         I => CLK100MHZ0_P,
--         IB => CLK100MHZ0_N,
--         O => clk100mhz);

    clk100mhz0_ibufds_gte2_inst : IBUFDS_GTE2
    generic map (
        CLKCM_CFG   => TRUE,
        CLKRCV_TRST         => TRUE,
        CLKSWING_CFG        => "11" )
    port map (
         O      => clk100mhz,
         ODIV2  => open,
         CEB    => '0',
         I      => CLK100MHZ0_P,
         IB     => CLK100MHZ0_N
    );

    process (clk100mhz) begin
        if rising_edge(clk100mhz) then
            ctr100mhz <= ctr100mhz + 1;
        end if;
    end process;

    ULED <= std_logic_vector(ctr100mhz(25 downto 22));
end;
