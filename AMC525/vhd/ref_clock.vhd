-- Internal 200MHz reference clock.  This is used for IDELAY elements on our
-- own data DDR inputs and for the DRAM I/O

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;

entity ref_clock is
    port (
        -- Raw pin inputs
        CLK125MHZ0_P : in std_logic;
        CLK125MHZ0_N : in std_logic;
        nCOLDRST : in std_logic;

        -- 200 MHz DRAM timing reference clock
        ref_clk_o : out std_logic;
        ref_clk_ok_o : out std_logic;

        -- 125 MHz register interface clock (temporary)
        reg_clk_o : out std_logic;
        reg_clk_ok_o : out std_logic
    );
end;

architecture ref_clock of ref_clock is
    signal clk125mhz_in : std_logic;    -- Incoming buffered clock
    signal clk200mhz : std_logic;
    signal clk125mhz : std_logic;
    signal pll_feedback : std_logic;
    signal pll_locked : std_logic;
    signal pll_ok : std_logic;

    signal ref_clk : std_logic;
    signal reg_clk : std_logic;

    signal reset_pll : std_logic;

begin
    clk125mhz_inst : entity work.gte2_ibufds port map (
        clk_p_i => CLK125MHZ0_P,
        clk_n_i => CLK125MHZ0_N,
        clk_o => clk125mhz_in
    );

    -- Note: internal PLL must run at frequency in range 800MHz..1.86GHz
    reset_pll <= not nCOLDRST;
    pll_inst : PLLE2_BASE generic map (
        CLKIN1_PERIOD => 8.0,   -- 8ns period for 125 MHz input clock
        CLKFBOUT_MULT => 8,     -- PLL runs at 1000 MHz
        CLKOUT0_DIVIDE => 5,    -- DRAM reference clock at 200 MHz
        CLKOUT1_DIVIDE => 8     -- Register interface clock at 125 MHz
    ) port map (
        -- Inputs
        CLKIN1  => clk125mhz_in,
        CLKFBIN => pll_feedback,
        RST     => reset_pll,
        PWRDWN  => '0',
        -- Outputs
        CLKOUT0 => clk200mhz,   -- 200 MHz for timing reference
        CLKOUT1 => clk125mhz,   -- 125 MHz for reference clock
        CLKOUT2 => open,
        CLKOUT3 => open,
        CLKOUT4 => open,
        CLKOUT5 => open,
        CLKFBOUT => pll_feedback,
        LOCKED  => pll_locked
    );
    clk200mhz_bufg_inst : BUFG port map (
        I => clk200mhz,
        O => ref_clk
    );
    clk125mhz_bufg_inst : BUFG port map (
        I => clk125mhz,
        O => reg_clk
    );


    -- Generate synchronised resets for the generated clocks.
    -- Don't report ok until we're out of reset and the PLL is locked.
    pll_ok <= pll_locked and nCOLDRST;
    ref_reset_inst : entity work.sync_reset port map (
        clk_i => ref_clk,
        clk_ok_i => pll_ok,
        sync_clk_ok_o => ref_clk_ok_o
    );
    reg_reset_inst : entity work.sync_reset port map (
        clk_i => reg_clk,
        clk_ok_i => pll_ok,
        sync_clk_ok_o => reg_clk_ok_o
    );

    ref_clk_o <= ref_clk;
    reg_clk_o <= reg_clk;
end;
