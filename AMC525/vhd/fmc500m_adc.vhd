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
    -- IDELAY control
    signal delay_in : std_logic_vector(4 downto 0);
    signal delay_strobe : std_logic;
    signal inc_decn : std_logic;
    signal inc_decn_strobe : std_logic;
    signal delay_out : std_logic_vector(4 downto 0);

    -- IDELAY
    signal adc_dco_delay : std_logic;       -- Delayed input clock from IDELAY
    signal ref_clk_reset : std_logic;

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
    -- Clock control
    -- Set the IDELAY with value of form 0x1xx for xx in range 0 to 31.
    delay_in <= write_data_i(4 downto 0);
    delay_strobe <= write_data_i(8) and write_strobe_i;
    -- Increment IDELAY by writing 0x3000, decrement with 0x1000.
    inc_decn <= write_data_i(13);
    inc_decn_strobe <= write_data_i(12) and write_strobe_i;
    -- Read current value
    read_data_o(4 downto 0) <= delay_out;
    read_data_o(30 downto 5) <= (others => '0');
    read_data_o(31) <= not dsp_clk_ok;
    -- PLL reset request
    pll_reset_request <= write_data_i(31) and write_strobe_i;

    write_ack_o <= '1';
    read_ack_o <= '1';


    -- IDELAY
    --
    -- Note that the documentation indicates that we need an IDELAYCTRL instance
    -- in the same clock region as this IDELAYE2 instance ... however, it turns
    -- out that the tool only requires one IDELAYCTRL to be declared globally
    -- (the required regional instances are created automatically), and there's
    -- one already in the MIG DRAM interface.
    idelay_inst : IDELAYE2 generic map (
        IDELAY_TYPE => "VAR_LOAD",
        DELAY_SRC => "IDATAIN",
        SIGNAL_PATTERN => "CLOCK",
        REFCLK_FREQUENCY => 200.0,
        HIGH_PERFORMANCE_MODE => "TRUE"
    ) port map (
        C => ref_clk_i,

        -- Value control
        LD => delay_strobe,
        CNTVALUEIN => delay_in,
        CNTVALUEOUT => delay_out,
        CE => inc_decn_strobe,
        INC => inc_decn,

        -- Delayed clock
        IDATAIN => adc_dco_i,
        DATAOUT => adc_dco_delay,

        -- Unused
        DATAIN => '0',
        CINVCTRL => '0',
        REGRST => '0',
        LDPIPEEN => '0'
    );

    ref_clk_reset <= not ref_clk_ok_i;
    idelayctrl_inst : IDELAYCTRL port map (
        REFCLK => ref_clk_i,
        RST => ref_clk_reset,
        RDY => open
    );


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
