-- Top level controller.  Maps registers to targes and generates DSP control
-- signals.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity register_top is
    port (
        -- Clocking
        reg_clk_i : in std_logic;
        reg_clk_ok_i : in std_logic;
        dsp_clk_i : in std_logic;
        dsp_clk_ok_i : in std_logic;

        -- Register interface from AXI
        write_strobe_i : in std_logic_vector;
        write_address_i : in reg_addr_t;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_address_i : in reg_addr_t;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- System registers.
        system_write_strobe_o : out reg_strobe_t;
        system_write_data_o : out reg_data_t;
        system_write_ack_i : in reg_strobe_t;
        system_read_strobe_o : out reg_strobe_t;
        system_read_data_i : in reg_data_array_t;
        system_read_ack_i : in reg_strobe_t;

        -- The Control and DSP register interfaces are all on dsp_clk

        -- Control registers.
        ctrl_write_strobe_o : out reg_strobe_t;
        ctrl_write_data_o : out reg_data_t;
        ctrl_write_ack_i : in reg_strobe_t;
        ctrl_read_strobe_o : out reg_strobe_t;
        ctrl_read_data_i : in reg_data_array_t;
        ctrl_read_ack_i : in reg_strobe_t;

        -- Register output to DSP0
        dsp0_write_strobe_o : out reg_strobe_t;
        dsp0_write_data_o : out reg_data_t;
        dsp0_write_ack_i : in reg_strobe_t;
        dsp0_read_strobe_o : out reg_strobe_t;
        dsp0_read_data_i : in reg_data_array_t;
        dsp0_read_ack_i : in reg_strobe_t;

        -- Register output to DSP1
        dsp1_write_strobe_o : out reg_strobe_t;
        dsp1_write_data_o : out reg_data_t;
        dsp1_write_ack_i : in reg_strobe_t;
        dsp1_read_strobe_o : out reg_strobe_t;
        dsp1_read_data_i : in reg_data_array_t;
        dsp1_read_ack_i : in reg_strobe_t
    );
end;

architecture register_top of register_top is
    constant SYSTEM_MOD : natural := 0;
    constant CTRL_MOD : natural := 1;
    constant DSP0_MOD : natural := 2;
    constant DSP1_MOD : natural := 3;

    -- CTRL clock domain crossing
    signal ctrl_write_strobe : std_logic;
    signal ctrl_write_data : reg_data_t;
    signal ctrl_write_ack : std_logic;
    signal ctrl_read_strobe : std_logic;
    signal ctrl_read_data : reg_data_t;
    signal ctrl_read_ack : std_logic;

    -- DSP0 clock domain crossing
    signal dsp0_write_strobe : std_logic;
    signal dsp0_write_data : reg_data_t;
    signal dsp0_write_ack : std_logic;
    signal dsp0_read_strobe : std_logic;
    signal dsp0_read_data : reg_data_t;
    signal dsp0_read_ack : std_logic;

    -- DSP1 clock domain crossing
    signal dsp1_write_strobe : std_logic;
    signal dsp1_write_data : reg_data_t;
    signal dsp1_write_ack : std_logic;
    signal dsp1_read_strobe : std_logic;
    signal dsp1_read_data : reg_data_t;
    signal dsp1_read_ack : std_logic;

begin
    -- System control registers on external register clock
    system_register_mux_inst : entity work.register_mux port map (
        clk_i => reg_clk_i,

        read_strobe_i => read_strobe_i(SYSTEM_MOD),
        read_address_i => read_address_i,
        read_data_o => read_data_o(SYSTEM_MOD),
        read_ack_o => read_ack_o(SYSTEM_MOD),

        read_data_i => system_read_data_i,
        read_strobe_o => system_read_strobe_o,
        read_ack_i => system_read_ack_i,

        write_strobe_i => write_strobe_i(SYSTEM_MOD),
        write_address_i => write_address_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(SYSTEM_MOD),

        write_strobe_o => system_write_strobe_o,
        write_data_o => system_write_data_o,
        write_ack_i => system_write_ack_i
    );


    -- -------------------------------------------------------------------------
    -- All the remaining registers are clock domain crossed to the DSP clock.

    -- Clock domain crossing to dsp clock domain for CTRL and DSP registers.
    ctrl_register_cc_inst : entity work.register_cc port map (
        reg_clk_i => reg_clk_i,
        out_clk_i => dsp_clk_i,
        out_clk_ok_i => dsp_clk_ok_i,

        reg_write_strobe_i => write_strobe_i(CTRL_MOD),
        reg_write_data_i => write_data_i,
        reg_write_ack_o => write_ack_o(CTRL_MOD),
        out_write_strobe_o => ctrl_write_strobe,
        out_write_data_o => ctrl_write_data,
        out_write_ack_i => ctrl_write_ack,

        reg_read_strobe_i => read_strobe_i(CTRL_MOD),
        reg_read_data_o => read_data_o(CTRL_MOD),
        reg_read_ack_o => read_ack_o(CTRL_MOD),
        out_read_strobe_o => ctrl_read_strobe,
        out_read_data_i => ctrl_read_data,
        out_read_ack_i => ctrl_read_ack
    );

    dsp0_register_cc_inst : entity work.register_cc port map (
        reg_clk_i => reg_clk_i,
        out_clk_i => dsp_clk_i,
        out_clk_ok_i => dsp_clk_ok_i,

        reg_write_strobe_i => write_strobe_i(DSP0_MOD),
        reg_write_data_i => write_data_i,
        reg_write_ack_o => write_ack_o(DSP0_MOD),
        out_write_strobe_o => dsp0_write_strobe,
        out_write_data_o => dsp0_write_data,
        out_write_ack_i => dsp0_write_ack,

        reg_read_strobe_i => read_strobe_i(DSP0_MOD),
        reg_read_data_o => read_data_o(DSP0_MOD),
        reg_read_ack_o => read_ack_o(DSP0_MOD),
        out_read_strobe_o => dsp0_read_strobe,
        out_read_data_i => dsp0_read_data,
        out_read_ack_i => dsp0_read_ack
    );

    dsp1_register_cc_inst : entity work.register_cc port map (
        reg_clk_i => reg_clk_i,
        out_clk_i => dsp_clk_i,
        out_clk_ok_i => dsp_clk_ok_i,

        reg_write_strobe_i => write_strobe_i(DSP1_MOD),
        reg_write_data_i => write_data_i,
        reg_write_ack_o => write_ack_o(DSP1_MOD),
        out_write_strobe_o => dsp1_write_strobe,
        out_write_data_o => dsp1_write_data,
        out_write_ack_i => dsp1_write_ack,

        reg_read_strobe_i => read_strobe_i(DSP1_MOD),
        reg_read_data_o => read_data_o(DSP1_MOD),
        reg_read_ack_o => read_ack_o(DSP1_MOD),
        out_read_strobe_o => dsp1_read_strobe,
        out_read_data_i => dsp1_read_data,
        out_read_ack_i => dsp1_read_ack
    );


    -- -------------------------------------------------------------------------
    -- Register blocks in DSP clock domain

    -- Top level control registers
    ctrl_register_mux_inst : entity work.register_mux port map (
        clk_i => dsp_clk_i,

        read_strobe_i => ctrl_read_strobe,
        read_address_i => read_address_i,
        read_data_o => ctrl_read_data,
        read_ack_o => ctrl_read_ack,

        read_data_i => ctrl_read_data_i,
        read_strobe_o => ctrl_read_strobe_o,
        read_ack_i => ctrl_read_ack_i,

        write_strobe_i => ctrl_write_strobe,
        write_address_i => write_address_i,
        write_data_i => ctrl_write_data,
        write_ack_o => ctrl_write_ack,

        write_strobe_o => ctrl_write_strobe_o,
        write_data_o => ctrl_write_data_o,
        write_ack_i => ctrl_write_ack_i
    );

    dsp0_register_mux_inst : entity work.register_mux port map (
        clk_i => dsp_clk_i,

        read_strobe_i => dsp0_read_strobe,
        read_address_i => read_address_i,
        read_data_o => dsp0_read_data,
        read_ack_o => dsp0_read_ack,

        read_data_i => dsp0_read_data_i,
        read_strobe_o => dsp0_read_strobe_o,
        read_ack_i => dsp0_read_ack_i,

        write_strobe_i => dsp0_write_strobe,
        write_address_i => write_address_i,
        write_data_i => dsp0_write_data,
        write_ack_o => dsp0_write_ack,

        write_strobe_o => dsp0_write_strobe_o,
        write_data_o => dsp0_write_data_o,
        write_ack_i => dsp0_write_ack_i
    );

    dsp1_register_mux_inst : entity work.register_mux port map (
        clk_i => dsp_clk_i,

        read_strobe_i => dsp1_read_strobe,
        read_address_i => read_address_i,
        read_data_o => dsp1_read_data,
        read_ack_o => dsp1_read_ack,

        read_data_i => dsp1_read_data_i,
        read_strobe_o => dsp1_read_strobe_o,
        read_ack_i => dsp1_read_ack_i,

        write_strobe_i => dsp1_write_strobe,
        write_address_i => write_address_i,
        write_data_i => dsp1_write_data,
        write_ack_o => dsp1_write_ack,

        write_strobe_o => dsp1_write_strobe_o,
        write_data_o => dsp1_write_data_o,
        write_ack_i => dsp1_write_ack_i
    );

end;
