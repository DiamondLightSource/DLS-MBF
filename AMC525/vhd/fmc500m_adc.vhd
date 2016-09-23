-- Interface to FMC500M ADC resources.
-- This contains the input ADC clock, the associated clock control, and the DDR
-- input data buffer.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.support.all;
use work.defines.all;

entity fmc500m_adc is
    port (
        -- Reference clock for IDELAY control
        ref_clk_i : in std_logic;       -- Must be 200 MHz clock
        ref_clk_ok_i : in std_logic;    -- Reference clock status

        -- Register interface for IDELAY
        -- This entire interface *must* be clocked by ref_clk
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        read_strobe_i : in std_logic;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;

        -- Inputs from ADC
        adc_dco_i : in std_logic;
        adc_data_i : in std_logic_vector(13 downto 0);

        -- ADC and DSP clock.  The OK signal is synchronous with DSP clk.
        adc_clk_o : out std_logic;      -- 500 MHz ADC clock
        dsp_clk_o : out std_logic;      -- 250 MHz divided from ADC
        dsp_clk_ok_o : out std_logic;   -- Clock valid signal

        -- Received data from the two channels on ADC clock.
        adc_data_a_o : out std_logic_vector(13 downto 0);
        adc_data_b_o : out std_logic_vector(13 downto 0)
    );
end;

architecture fmc500m_adc of fmc500m_adc is
    signal adc_dco_delay : std_logic;       -- Delayed input clock from IDELAY
    signal read_data : reg_data_t;

    -- PLL
    signal pll_fb_out : std_logic;
    signal pll_fb_buf : std_logic;
    signal pll_adc_clk : std_logic;
    signal pll_dsp_clk : std_logic;
    signal pll_locked : std_logic;

    signal adc_clk : std_logic;
    signal dsp_clk : std_logic;
    signal dsp_clk_ok : std_logic;

    signal pll_reset_request : std_logic;
    signal pll_reset_counter : unsigned(6 downto 0);
    signal pll_reset : std_logic;

begin
    -- PLL reset request
    pll_reset_request <= write_data_i(31) and write_strobe_i;

    idelay_inst : entity work.idelay_control port map (
        ref_clk_i => ref_clk_i,
        ref_clk_ok_i => ref_clk_ok_i,
        signal_i => adc_dco_i,
        signal_o => adc_dco_delay,
        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        read_strobe_i => read_strobe_i,
        read_data_o => read_data,
        read_ack_o => read_ack_o
    );

    -- Temporary fixup of read_data_o
    read_data_o(30 downto 0) <= read_data(30 downto 0);
    read_data_o(31) <= not dsp_clk_ok;


    -- PLL
    adc_clk_pll_inst : PLLE2_BASE generic map (
        -- Parameters from Clocking Wizard
        CLKIN1_PERIOD => 2.0,   -- 2ns period for 500 MHz input clock
        CLKFBOUT_MULT => 4,     -- PLL runs at 1000 MHz
        DIVCLK_DIVIDE => 2,
        CLKOUT0_DIVIDE => 2,    -- ADC clock at 500 MHz
        CLKOUT1_DIVIDE => 4     -- DSP clock at 250 MHz
    ) port map (
        -- Inputs
        CLKIN1  => adc_dco_delay,
        CLKFBIN => pll_fb_buf,
        RST     => pll_reset,
        PWRDWN  => '0',
        -- Outputs
        CLKOUT0 => pll_adc_clk,
        CLKOUT1 => pll_dsp_clk,
        CLKOUT2 => open,
        CLKOUT3 => open,
        CLKOUT4 => open,
        CLKOUT5 => open,
        CLKFBOUT => pll_fb_out,
        LOCKED  => pll_locked
    );
    pll_bufg_inst : BUFG port map (
        I => pll_fb_out,
        O => pll_fb_buf
    );
    adc_bufg_inst : BUFG port map (
        I => pll_adc_clk,
        O => adc_clk
    );
    dsp_bufg_inst : BUFG port map (
        I => pll_dsp_clk,
        O => dsp_clk
    );

    -- Convert locked signal into a synchronous status
    pll_locked_inst : entity work.sync_reset port map (
        clk_i => dsp_clk,
        clk_ok_i => pll_locked,
        sync_clk_ok_o => dsp_clk_ok
    );

    -- On request we force the PLL into reset for the duration of our counter.
    process (ref_clk_ok_i, ref_clk_i) begin
        if ref_clk_ok_i = '0' then
            pll_reset_counter <= (others => '1');
            pll_reset <= '1';
        elsif rising_edge(ref_clk_i) then
            if pll_reset_request = '1' then
                pll_reset_counter <= (others => '1');
            elsif pll_reset_counter > 0 then
                pll_reset_counter <= pll_reset_counter - 1;
            end if;
            pll_reset <= to_std_logic(pll_reset_counter > 0);
        end if;
    end process;


    -- ADC data
    adc_data_inst : entity work.iddr_array generic map (
        COUNT => 14
    ) port map (
        clk_i => adc_clk,
        ce_i => '1',
        d_i => adc_data_i,
        q1_o => adc_data_a_o,
        q2_o => adc_data_b_o
    );

    adc_clk_o <= adc_clk;
    dsp_clk_o <= dsp_clk;
    dsp_clk_ok_o <= dsp_clk_ok;
end;
