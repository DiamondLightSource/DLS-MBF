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

use work.register_defs.all;

entity idelay_control is
    port (
        -- Clocking: must be 200 MHz clock
        ref_clk_i : in std_ulogic;

        -- Signal being delayed.  Must be a physical input.
        signal_i : in std_ulogic;
        signal_o : out std_ulogic;

        -- Control over IDELAY: we have a single register
        write_strobe_i : in std_ulogic;
        write_data_i : in reg_data_t;
        read_data_o : out reg_data_t
    );
end;

architecture arch of idelay_control is
    signal delay_in : std_ulogic_vector(4 downto 0);
    signal delay_strobe : std_ulogic;
    signal inc_decn : std_ulogic;
    signal inc_decn_strobe : std_ulogic;
    signal delay_out : std_ulogic_vector(4 downto 0);

begin
    -- Clock control
    -- Set the IDELAY with value of form 0x1xx for xx in range 0 to 31.
    delay_in <= write_data_i(IDELAY_VALUE_BITS);
    delay_strobe <= write_data_i(IDELAY_WRITE_BIT) and write_strobe_i;
    -- Increment IDELAY by writing 0x3000, decrement with 0x1000.
    inc_decn <= write_data_i(IDELAY_INC_DECN_BIT);
    inc_decn_strobe <= write_data_i(IDELAY_STEP_BIT) and write_strobe_i;
    -- Read current value
    read_data_o <= (
        IDELAY_VALUE_BITS => delay_out,
        others => '0'
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
end;
