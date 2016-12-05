-- Taps for bunch by bunch filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.bunch_defs.all;

entity bunch_fir_taps is
    port (
        dsp_clk_i : in std_logic;

        -- Register write interface for writing taps
        -- Taps write interface
        write_start_i : in std_logic;
        write_fir_i : in unsigned;      -- Selects which FIR group to write

        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;

        -- Taps output
        bunch_config_i : in bunch_config_lanes_t;
        taps_o : out signed_array_array
    );
end;

architecture bunch_fir_taps of bunch_fir_taps is
    constant TAP_COUNT : natural := taps_o'ELEMENT'LENGTH;
    constant TAP_WIDTH : natural := taps_o'ELEMENT'ELEMENT'LENGTH;

    subtype BANKS_RANGE is natural range 0 to 2**FIR_BANK_BITS-1;
    subtype TAPS_RANGE is natural range 0 to TAP_COUNT-1;
    subtype TAP_RANGE  is natural range TAP_WIDTH-1 downto 0;

    signal taps : signed_array_array(BANKS_RANGE)(TAPS_RANGE)(TAP_RANGE)
        := (others => (others => (others => '0')));
    signal tap_index : unsigned(bits(TAP_COUNT-1)-1 downto 0);

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Output selected taps
            for l in LANES loop
                taps_o(l) <= taps(to_integer(bunch_config_i(l).fir_select));
            end loop;

            -- Write to selected taps
            if write_start_i then
                tap_index <= (others => '0');
            elsif write_strobe_i then
                taps(to_integer(write_fir_i))(to_integer(tap_index)) <=
                    signed(write_data_i(31 downto 32-TAP_WIDTH));
                tap_index <= tap_index + 1;
            end if;
        end if;
    end process;

    write_ack_o <= '1';
end;
