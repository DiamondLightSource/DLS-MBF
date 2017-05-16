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
        dsp_clk_i : in std_logic;
        dsp_clk_ok_i : in std_logic;

        -- Register interface from AXI
        write_strobe_i : in std_logic;
        write_address_i : in unsigned;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        read_strobe_i : in std_logic;
        read_address_i : in unsigned;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;

        -- System registers on REG clk.
        system_write_strobe_o : out std_logic_vector;
        system_write_data_o : out reg_data_t;
        system_write_ack_i : in std_logic_vector;
        system_read_strobe_o : out std_logic_vector;
        system_read_data_i : in reg_data_array_t;
        system_read_ack_i : in std_logic_vector;

        -- DSP control registers (without address decoding) on DSP clk.
        dsp_write_strobe_o : out std_logic;
        dsp_write_address_o : out unsigned;
        dsp_write_data_o : out reg_data_t;
        dsp_write_ack_i : in std_logic;
        dsp_read_strobe_o : out std_logic;
        dsp_read_address_o : out unsigned;
        dsp_read_data_i : in reg_data_t;
        dsp_read_ack_i : in std_logic
    );
end;

architecture arch of register_top is
    constant SYSTEM_MOD : natural := 0;
    constant DSP_MOD : natural := 1;

    subtype TOP_ADDR_RANGE is natural range write_address_i'LEFT-1 downto 0;
    signal top_write_strobe : std_logic_vector(0 to 1);
    signal top_write_address : unsigned(TOP_ADDR_RANGE);
    signal top_write_data : reg_data_t;
    signal top_write_ack : std_logic_vector(0 to 1);

    signal top_read_strobe : std_logic_vector(0 to 1);
    signal top_read_address : unsigned(TOP_ADDR_RANGE);
    signal top_read_data : reg_data_array_t(0 to 1);
    signal top_read_ack : std_logic_vector(0 to 1);

begin
    -- Start by multiplexing between the system and DSP registers on the top bit
    -- of the incoming register
    top_register_mux_inst : entity work.register_mux port map (
        clk_i => reg_clk_i,

        write_strobe_i => write_strobe_i,
        write_address_i(0) => write_address_i(write_address_i'LEFT),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,

        write_strobe_o => top_write_strobe,
        write_data_o => top_write_data,
        write_ack_i => top_write_ack,

        read_strobe_i => read_strobe_i,
        read_address_i(0) => read_address_i(read_address_i'LEFT),
        read_data_o => read_data_o,
        read_ack_o => read_ack_o,

        read_strobe_o => top_read_strobe,
        read_data_i => top_read_data,
        read_ack_i => top_read_ack
    );
    top_read_address  <= read_address_i(TOP_ADDR_RANGE);
    top_write_address <= write_address_i(TOP_ADDR_RANGE);


    -- System control registers on external register clock
    system_register_mux_inst : entity work.register_mux port map (
        clk_i => reg_clk_i,

        write_strobe_i => top_write_strobe(SYSTEM_MOD),
        write_address_i => top_write_address,
        write_data_i => top_write_data,
        write_ack_o => top_write_ack(SYSTEM_MOD),

        write_strobe_o => system_write_strobe_o,
        write_data_o => system_write_data_o,
        write_ack_i => system_write_ack_i,

        read_strobe_i => top_read_strobe(SYSTEM_MOD),
        read_address_i => top_read_address,
        read_data_o => top_read_data(SYSTEM_MOD),
        read_ack_o => top_read_ack(SYSTEM_MOD),

        read_data_i => system_read_data_i,
        read_strobe_o => system_read_strobe_o,
        read_ack_i => system_read_ack_i
    );


    -- Clock domain crossing to DSP clock domain for DSP registers.
    dsp_register_cc_inst : entity work.register_cc port map (
        reg_clk_i => reg_clk_i,
        out_clk_i => dsp_clk_i,
        out_clk_ok_i => dsp_clk_ok_i,

        reg_write_strobe_i => top_write_strobe(DSP_MOD),
        reg_write_data_i => top_write_data,
        reg_write_ack_o => top_write_ack(DSP_MOD),

        out_write_strobe_o => dsp_write_strobe_o,
        out_write_data_o => dsp_write_data_o,
        out_write_ack_i => dsp_write_ack_i,

        reg_read_strobe_i => top_read_strobe(DSP_MOD),
        reg_read_data_o => top_read_data(DSP_MOD),
        reg_read_ack_o => top_read_ack(DSP_MOD),

        out_read_strobe_o => dsp_read_strobe_o,
        out_read_data_i => dsp_read_data_i,
        out_read_ack_i => dsp_read_ack_i
    );
    dsp_write_address_o <= top_write_address;
    dsp_read_address_o <= top_read_address;

end;
