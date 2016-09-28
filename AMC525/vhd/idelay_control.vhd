-- Input delay control
--
-- We used this for control over an input signal


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.support.all;
use work.defines.all;


entity idelay_control is
    port (
        -- Clocking: must be 200 MHz clock
        ref_clk_i : in std_logic;
        ref_clk_ok_i : in std_logic;

        -- Signal being delayed.  Must be a physical input.
        signal_i : in std_logic;
        signal_o : out std_logic;

        -- Control over IDELAY: we have a single register
        reg_clk_i : in std_logic;
        reg_clk_ok_i : in std_logic;
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        read_strobe_i : in std_logic;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic
    );
end;

architecture idelay_control of idelay_control is
    signal write_strobe : std_logic;
    signal read_data : reg_data_t;

    signal delay_in : std_logic_vector(4 downto 0);
    signal delay_strobe : std_logic;
    signal inc_decn : std_logic;
    signal inc_decn_strobe : std_logic;
    signal delay_out : std_logic_vector(4 downto 0);

    signal ref_clk_reset : std_logic;

begin
    -- Clock control
    -- Set the IDELAY with value of form 0x1xx for xx in range 0 to 31.
    delay_in <= write_data_i(4 downto 0);
    delay_strobe <= write_data_i(8) and write_strobe;
    -- Increment IDELAY by writing 0x3000, decrement with 0x1000.
    inc_decn <= write_data_i(13);
    inc_decn_strobe <= write_data_i(12) and write_strobe;
    -- Read current value
    read_data(4 downto 0) <= delay_out;
    read_data(31 downto 5) <= (others => '0');


    -- Clock domain crossing for clocking control
    register_cc_inst : entity work.register_cc port map (
        reg_clk_i => reg_clk_i,
        out_clk_i => ref_clk_i,
        out_clk_ok_i => ref_clk_ok_i,

        reg_write_strobe_i => write_strobe_i,
        reg_write_ack_o => write_ack_o,
        out_write_strobe_o => write_strobe,
        out_write_ack_i => '1',

        reg_read_strobe_i => read_strobe_i,
        reg_read_data_o => read_data_o,
        reg_read_ack_o => read_ack_o,
        out_read_strobe_o => open,
        out_read_data_i => read_data,
        out_read_ack_i => '1'
    );


    -- Input delay control
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
        IDATAIN => signal_i,
        DATAOUT => signal_o,

        -- Unused
        DATAIN => '0',
        CINVCTRL => '0',
        REGRST => '0',
        LDPIPEEN => '0'
    );

    -- We do seem to need this IDELAYCTRL instance so that our IDELAYE2 works.
    ref_clk_reset <= not ref_clk_ok_i;
    idelayctrl_inst : IDELAYCTRL port map (
        REFCLK => ref_clk_i,
        RST => ref_clk_reset,
        RDY => open
    );

end;
