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

        -- Temporary dummy DSP clock at 250 MHz
        dsp_clk_o : out std_logic;
        dsp_rst_n_o : out std_logic;

        -- 200 MHz DRAM timing reference clock
        dram_ref_clk_o : out std_logic;
        dram_ref_rst_n_o : out std_logic
    );
end;

architecture dsp_clock of dsp_clock is
    signal clk125mhz : std_logic;       -- Incoming buffered clock

    signal clk200mhz : std_logic;
    signal clk250mhz : std_logic;
    signal clk_fb : std_logic;
    signal clk_locked : std_logic;

    signal dsp_clk : std_logic;
    signal dram_ref_clk : std_logic;

    signal coldrst : std_logic;
    signal dsp_reset_n : std_logic;

begin
    clk125mhz_inst : entity work.gte2_ibufds port map (
        clk_p_i => CLK125MHZ0_P,
        clk_n_i => CLK125MHZ0_N,
        clk_o => clk125mhz
    );

    -- Note: internal PLL must run at frequency in range 800MHz..1.86GHz
    coldrst <= not nCOLDRST;
    clk250mhz_inst : PLLE2_BASE generic map (
        CLKIN1_PERIOD => 8.0,   -- 8ns period for 125 MHz input clock
        CLKFBOUT_MULT => 8,     -- PLL runs at 1000 MHz
        CLKOUT0_DIVIDE => 4,    -- DSP clock at 250 MHz
        CLKOUT1_DIVIDE => 5     -- DRAM reference clock at 200 MHz
    ) port map (
        -- Inputs
        CLKIN1  => clk125mhz,
        CLKFBIN => clk_fb,
        RST     => coldrst,
        PWRDWN  => '0',
        -- Outputs
        CLKOUT0 => clk250mhz,
        CLKOUT1 => clk200mhz,
        CLKOUT2 => open,
        CLKOUT3 => open,
        CLKOUT4 => open,
        CLKOUT5 => open,
        CLKFBOUT => clk_fb,
        LOCKED  => clk_locked
    );
    clk250mhz_bufg_inst : BUFG port map (
        I => clk250mhz,
        O => dsp_clk
    );
    clk200mhz_bufg_inst : BUFG port map (
        I => clk200mhz,
        O => dram_ref_clk
    );

    -- Now generate synchronous locked signals for each generated clock from the
    -- clk_locked signal.
    process (dsp_clk) begin
        if clk_locked = '0' or nCOLDRST = '0' then
            dsp_rst_n_o <= '0';
        elsif rising_edge(dsp_clk) then
            dsp_rst_n_o <= clk_locked;
        end if;
    end process;

    process (dram_ref_clk) begin
        if clk_locked = '0' or nCOLDRST = '0' then
            dram_ref_rst_n_o <= '0';
        elsif rising_edge(dram_ref_clk) then
            dram_ref_rst_n_o <= clk_locked;
        end if;
    end process;

    dsp_clk_o <= dsp_clk;
    dram_ref_clk_o <= dram_ref_clk;
end;
