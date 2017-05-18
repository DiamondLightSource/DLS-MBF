-- Processing core of detector: computes IQ output from given data stream
-- and reference cos/sin.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;
use work.detector_defs.all;

entity detector_core is
    port (
        clk_i : in std_logic;

        data_i : in signed(24 downto 0);
        iq_i : in cos_sin_18_t;
        bunch_enable_i : in std_logic;

        data_overflow_i : in std_logic;
        data_overflow_o : out std_logic := '0';
        detector_overflow_o : out std_logic;

        overflow_mask_i : in signed(95 downto 0);
        preload_i : in signed(95 downto 0);

        start_i : in std_logic;
        write_i : in std_logic;

        write_o : out std_logic := '0';
        iq_o : out cos_sin_96_t
    );
end;

architecture arch of detector_core is
    signal iq_out : iq_o'SUBTYPE;
    signal cos_overflow : std_logic;
    signal sin_overflow : std_logic;

    -- Typically both start_i and write_i are synchronous, and the delay from
    -- start_i to reset data out is 4 ticks, so we need the write delay to be
    -- one less to pick up the data before reset.
    constant WRITE_DELAY : natural := 3;
    signal write_in : std_logic;

begin
    cos_detect : entity work.detector_dsp96 port map (
        clk_i => clk_i,
        data_i => data_i,
        mul_i => iq_i.cos,
        enable_i => bunch_enable_i,
        start_i => start_i,
        overflow_mask_i => overflow_mask_i,
        preload_i => preload_i,
        sum_o => iq_out.cos,
        overflow_o => cos_overflow
    );

    sin_detect : entity work.detector_dsp96 port map (
        clk_i => clk_i,
        data_i => data_i,
        mul_i => iq_i.sin,
        enable_i => bunch_enable_i,
        start_i => start_i,
        overflow_mask_i => overflow_mask_i,
        preload_i => preload_i,
        sum_o => iq_out.sin,
        overflow_o => sin_overflow
    );

    delay_write : entity work.dlyline generic map (
        DLY => WRITE_DELAY
    ) port map (
        clk_i => clk_i,
        data_i(0) => write_i,
        data_o(0) => write_in
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            data_overflow_o <= data_overflow_i and bunch_enable_i;

            write_o <= write_in;
            if write_in = '1' then
                iq_o <= iq_out;
            end if;
            detector_overflow_o <= write_o and (cos_overflow or sin_overflow);
        end if;
    end process;
end;
