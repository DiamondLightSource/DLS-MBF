-- Internal 200MHz reference clock.  This is used for IDELAY elements on our
-- own data DDR inputs and for the DRAM I/O

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;

entity clocking is
    port (
        -- Raw input clocks and reset
        nCOLDRST : in std_ulogic;
        clk125mhz_i : in std_ulogic;
        adc_dco_i : in std_ulogic;

        -- 200 MHz DRAM timing reference clock
        ref_clk_o : out std_ulogic;
        ref_clk_ok_o : out std_ulogic;

        -- ADC/DSP/REG clocks.
        adc_clk_o : out std_ulogic;      -- 500 MHz data clock
        dsp_clk_o : out std_ulogic;      -- 250 MHz clock = ADC/2
        dsp_clk_ok_o : out std_ulogic;
        reg_clk_o : out std_ulogic;      -- 125 MHz clock
        reg_clk_ok_o : out std_ulogic;
        -- Separate DSP reset.  This is only deasserted at startup (after
        -- coming out of nCOLDRST).
        dsp_reset_n_o : out std_ulogic;

        -- This is a diagnostic signal, shouldn't need to be checked!
        adc_pll_ok_o : out std_ulogic
    );
end;

architecture arch of clocking is
    -- Processed incoming signals
    signal clk125mhz : std_ulogic;

    -- Generated clocks
    signal ref_clk_pll : std_ulogic;
    signal ref_clk : std_ulogic;
    signal ref_clk_ok : std_ulogic;
    signal reg_clk_pll : std_ulogic;
    signal reg_clk : std_ulogic;
    signal reg_clk_ok : std_ulogic;
    signal adc_clk_pll : std_ulogic;
    signal adc_clk : std_ulogic;
    signal dsp_clk_pll : std_ulogic;
    signal dsp_clk : std_ulogic;
    signal dsp_clk_ok : std_ulogic;

    -- 125 MHz reference clock PLL
    signal ref_pll_reset : std_ulogic;
    signal ref_pll_feedback : std_ulogic;
    signal ref_pll_locked : std_ulogic;
    signal ref_pll_ok : std_ulogic;

    -- ADC clock PLL
    signal adc_pll_reset_timer : unsigned(2 downto 0);
    signal adc_pll_reset : std_ulogic := '1';
    signal adc_pll_feedback : std_ulogic;
    signal adc_pll_feedback_bufg : std_ulogic;
    signal adc_pll_locked : std_ulogic;
    signal adc_pll_ok : std_ulogic;

    signal read_data : reg_data_t;

    -- This function is not currently available
    signal adc_pll_reset_request : std_ulogic := '0';

begin
    -- We do seem to need this IDELAYCTRL instance so that our IDELAYE2 works.
    idelayctrl_inst : IDELAYCTRL port map (
        REFCLK => ref_clk,
        RST => not ref_clk_ok,
        RDY => open
    );

    -- -------------------------------------------------------------------------
    -- Timing reference clock and register clock.

    -- This BUFG is needed to transport the incoming 125MHz reference clock to
    -- wherever the PLL is placed.
    clk125_bufg_inst : BUFG port map (
        I => clk125mhz_i,
        O => clk125mhz
    );

    -- Note: internal PLL must run at frequency in range 800MHz..1.86GHz
    ref_pll_reset <= not nCOLDRST;
    -- Note: the name of this PLL instance appears in the constraints file.
    pll_inst : PLLE2_BASE generic map (
        CLKIN1_PERIOD => 8.0,   -- 8ns period for 125 MHz input clock
        CLKFBOUT_MULT => 8,     -- PLL runs at 1000 MHz
        CLKOUT0_DIVIDE => 5,    -- DRAM reference clock at 200 MHz
        CLKOUT1_DIVIDE => 8     -- Register interface clock at 125 MHz
    ) port map (
        -- Inputs
        CLKIN1  => clk125mhz,
        CLKFBIN => ref_pll_feedback,
        RST     => ref_pll_reset,
        PWRDWN  => '0',
        -- Outputs
        CLKOUT0 => ref_clk_pll, -- 200 MHz for timing reference
        CLKOUT1 => reg_clk_pll, -- 125 MHz for register clock
        CLKOUT2 => open,
        CLKOUT3 => open,
        CLKOUT4 => open,
        CLKOUT5 => open,
        CLKFBOUT => ref_pll_feedback,
        LOCKED  => ref_pll_locked
    );
    ref_clk_bufg_inst : BUFG port map (
        I => ref_clk_pll,
        O => ref_clk
    );
    reg_clk_bufg_inst : BUFG port map (
        I => reg_clk_pll,
        O => reg_clk
    );


    -- Generate synchronised resets for the generated clocks.
    -- Don't report ok until we're out of reset and the PLL is locked.
    ref_pll_ok <= ref_pll_locked and nCOLDRST;
    ref_reset_inst : entity work.sync_reset port map (
        clk_i => ref_clk,
        clk_ok_i => ref_pll_ok,
        sync_clk_ok_o => ref_clk_ok
    );
    reg_reset_inst : entity work.sync_reset port map (
        clk_i => reg_clk,
        clk_ok_i => ref_pll_ok,
        sync_clk_ok_o => reg_clk_ok
    );

    ref_clk_o <= ref_clk;
    ref_clk_ok_o <= ref_clk_ok;
    reg_clk_o <= reg_clk;
    reg_clk_ok_o <= reg_clk_ok;


    -- -------------------------------------------------------------------------
    -- ADC clock and derived DSP clock.

    -- ADC PLL reset.  We stretch the reset
    process (ref_clk) begin
        if rising_edge(ref_clk) then
            if adc_pll_reset_request = '1' then
                adc_pll_reset_timer <= (others => '1');
            elsif adc_pll_reset_timer > 0 then
                adc_pll_reset_timer <= adc_pll_reset_timer - 1;
            end if;
            adc_pll_reset <=
                not nCOLDRST or to_std_ulogic(adc_pll_reset_timer > 0);
        end if;
    end process;

    -- PLL
    adc_pll_inst : PLLE2_BASE generic map (
        -- Parameters from Clocking Wizard
        CLKIN1_PERIOD => 2.0,   -- 2ns period for 500 MHz input clock
        CLKFBOUT_MULT => 6,     -- PLL runs at 1500 MHz
        DIVCLK_DIVIDE => 2,     -- Ensure PFD frequency not above 500 MHz
        CLKOUT0_DIVIDE => 3,    -- ADC clock at 500 MHz
        CLKOUT1_DIVIDE => 6     -- DSP clock at 250 MHz
    ) port map (
        -- Inputs
        CLKIN1  => adc_dco_i,
        CLKFBIN => adc_pll_feedback_bufg,
        RST     => adc_pll_reset,
        PWRDWN  => '0',
        -- Outputs
        CLKOUT0 => adc_clk_pll,
        CLKOUT1 => dsp_clk_pll,
        CLKOUT2 => open,
        CLKOUT3 => open,
        CLKOUT4 => open,
        CLKOUT5 => open,
        CLKFBOUT => adc_pll_feedback,
        LOCKED  => adc_pll_locked
    );
    pll_bufg_inst : BUFG port map (
        I => adc_pll_feedback,
        O => adc_pll_feedback_bufg
    );

    -- We use BUFGCTRL instead of BUFGCE because it seems that BUFGCE can
    -- generate a glitch, but this configuration of BUFGCTRL may be glitch free.
    adc_bufg_inst : BUFGCTRL port map (
        S0 => adc_pll_locked,
        I0 => adc_clk_pll,
        O => adc_clk,
        -- Don't use CE or IGNORE
        CE0 => '1',
        IGNORE0 => '0',
        -- Ignore I1 altogether
        I1 => '0',
        S1 => '0',
        CE1 => '0',
        IGNORE1 => '1'
    );
    dsp_bufg_inst : BUFGCTRL port map (
        S0 => adc_pll_locked,
        I0 => dsp_clk_pll,
        O => dsp_clk,
        -- Don't use CE or IGNORE
        CE0 => '1',
        IGNORE0 => '0',
        -- Ignore I1 altogether
        I1 => '0',
        S1 => '0',
        CE1 => '0',
        IGNORE1 => '1'
    );

    -- Convert locked signal into a synchronous status
    adc_pll_ok <= adc_pll_locked and nCOLDRST;
    pll_locked_inst : entity work.sync_reset port map (
        clk_i => dsp_clk,
        clk_ok_i => adc_pll_ok,
        sync_clk_ok_o => dsp_clk_ok
    );

    adc_clk_o <= adc_clk;
    dsp_clk_o <= dsp_clk;
    dsp_clk_ok_o <= dsp_clk_ok;

    -- Special one shot DSP reset
    process (dsp_clk, nCOLDRST) begin
        if nCOLDRST = '0' then
            dsp_reset_n_o <= '0';
        elsif rising_edge(dsp_clk) then
            if dsp_clk_ok = '1' then
                dsp_reset_n_o <= '1';
            end if;
        end if;
    end process;

    -- Debug signals
    adc_pll_ok_o <= adc_pll_locked;
end;
