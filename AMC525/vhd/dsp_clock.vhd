-- Dummy 250 MHz DSP clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;

entity dsp_clock is
    port (
        -- Raw pin inputs
        CLK125MHZ0_P : in std_logic;
        CLK125MHZ0_N : in std_logic;
        nCOLDRST : in std_logic;

        dsp_clk_o : out std_logic;
        dsp_rst_n_o : out std_logic
    );
end;

architecture dsp_clock of dsp_clock is
    signal clk125mhz : std_logic;

    signal clk250mhz : std_logic;
    signal clk250mhz_fb : std_logic;
    signal clk250mhz_locked : std_logic;

    signal dsp_reset_n : std_logic;

begin
    clk125mhz_inst : entity work.gte2_ibufds port map (
        clk_p_i => CLK125MHZ0_P,
        clk_n_i => CLK125MHZ0_N,
        clk_o => clk125mhz
    );

    -- Note: internal PLL must run at frequency in range 800MHz..1.86GHz
    clk250mhz_inst : PLLE2_BASE generic map (
        CLKIN1_PERIOD => 8.0,   -- 8ns period for 125 MHz input clock
        CLKFBOUT_MULT => 8,     -- PLL runs at 1000 MHz
        CLKOUT0_DIVIDE => 4     -- Target clock at 250 MHz
    ) port map (
        -- Inputs
        CLKIN1  => clk125mhz,
        CLKFBIN => clk250mhz_fb,
        RST     => not nCOLDRST,
        PWRDWN  => '0',
        -- Outputs
        CLKOUT0 => clk250mhz,
        CLKOUT1 => open,
        CLKOUT2 => open,
        CLKOUT3 => open,
        CLKOUT4 => open,
        CLKOUT5 => open,
        CLKFBOUT => clk250mhz_fb,
        LOCKED  => clk250mhz_locked
    );
    clk250mhz_bufg_inst : BUFG port map (
        I => clk250mhz,
        O => dsp_clk_o
    );
    dsp_rst_n_o <= clk250mhz_locked and nCOLDRST;
end;
