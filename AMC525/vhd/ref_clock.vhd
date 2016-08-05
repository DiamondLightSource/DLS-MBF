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
        ref_clk_ok_o : out std_logic
    );
end;

architecture ref_clock of ref_clock is
    signal clk125mhz : std_logic;       -- Incoming buffered clock
    signal clk200mhz : std_logic;
    signal pll_feeback : std_logic;
    signal pll_locked : std_logic;

    signal ref_clk : std_logic;

    signal reset_pll : std_logic;

begin
    clk125mhz_inst : entity work.gte2_ibufds port map (
        clk_p_i => CLK125MHZ0_P,
        clk_n_i => CLK125MHZ0_N,
        clk_o => clk125mhz
    );

    -- Note: internal PLL must run at frequency in range 800MHz..1.86GHz
    reset_pll <= not nCOLDRST;
    clk250mhz_inst : PLLE2_BASE generic map (
        CLKIN1_PERIOD => 8.0,   -- 8ns period for 125 MHz input clock
        CLKFBOUT_MULT => 8,     -- PLL runs at 1000 MHz
        CLKOUT0_DIVIDE => 5     -- DRAM reference clock at 200 MHz
    ) port map (
        -- Inputs
        CLKIN1  => clk125mhz,
        CLKFBIN => pll_feeback,
        RST     => reset_pll,
        PWRDWN  => '0',
        -- Outputs
        CLKOUT0 => clk200mhz,
        CLKOUT1 => open,
        CLKOUT2 => open,
        CLKOUT3 => open,
        CLKOUT4 => open,
        CLKOUT5 => open,
        CLKFBOUT => pll_feeback,
        LOCKED  => pll_locked
    );
    clk200mhz_bufg_inst : BUFG port map (
        I => clk200mhz,
        O => ref_clk
    );

    -- Now generate synchronous locked signals for the generated clock from the
    -- pll_locked signal.
    process (ref_clk, pll_locked, nCOLDRST) begin
        if pll_locked = '0' or nCOLDRST = '0' then
            ref_clk_ok_o <= '0';
        elsif rising_edge(ref_clk) then
            ref_clk_ok_o <= pll_locked;
        end if;
    end process;

    ref_clk_o <= ref_clk;
end;
