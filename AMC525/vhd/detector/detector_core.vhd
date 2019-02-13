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
    generic (
        RESULT_WIDTH : natural := 32    -- Used for overflow checking
    );
    port (
        clk_i : in std_ulogic;

        data_i : in signed(24 downto 0);
        iq_i : in cos_sin_18_t;
        bunch_enable_i : in std_ulogic;

        detector_overflow_o : out std_ulogic;

        shift_i : in natural;   -- Valid range 0 to 64

        start_i : in std_ulogic;
        write_i : in std_ulogic;

        write_o : out std_ulogic := '0';
        iq_o : out cos_sin_96_t
    );
end;

architecture arch of detector_core is
    signal bunch_enable_cos : std_ulogic;
    signal bunch_enable_sin : std_ulogic;

    signal iq_out : iq_o'SUBTYPE;
    signal cos_overflow : std_ulogic;
    signal sin_overflow : std_ulogic;

    signal overflow_mask : signed(95 downto 0);
    signal preload : signed(95 downto 0);

    -- Typically both start_i and write_i are synchronous, and the delay from
    -- start_i to reset data out is 4 ticks, so we need the write delay to be
    -- one less to pick up the data before reset.
    constant WRITE_DELAY : natural := 3;
    signal write_in : std_ulogic;

begin
    -- Compute preload and overflow detection mask for output shift.  The
    -- parameter shift_i tells us the offset of the first bit to be read out, so
    -- want to inject a one bit directly below that.  For the overflow mask we
    -- want the sign bit of the result and all bits above to be checked.
    process (shift_i) begin
        for i in 0 to 95 loop
            preload(i) <= to_std_ulogic(i + 1 = shift_i);
            overflow_mask(i) <= to_std_ulogic(i < RESULT_WIDTH - 1 + shift_i);
        end loop;
    end process;


    bunch_delay_cos : entity work.dlyreg generic map (
        DLY => 4
    ) port map (
        clk_i => clk_i,
        data_i(0) => bunch_enable_i,
        data_o(0) => bunch_enable_cos
    );
    bunch_delay_sin : entity work.dlyreg generic map (
        DLY => 4
    ) port map (
        clk_i => clk_i,
        data_i(0) => bunch_enable_i,
        data_o(0) => bunch_enable_sin
    );


    cos_detect : entity work.detector_dsp96 generic map (
        WRITE_DELAY => WRITE_DELAY
    ) port map (
        clk_i => clk_i,
        data_i => data_i,
        mul_i => iq_i.cos,
        enable_i => bunch_enable_cos,
        start_i => start_i,
        overflow_mask_i => overflow_mask,
        preload_i => preload,
        sum_o => iq_out.cos,
        overflow_o => cos_overflow
    );

    sin_detect : entity work.detector_dsp96 generic map (
        WRITE_DELAY => WRITE_DELAY
    ) port map (
        clk_i => clk_i,
        data_i => data_i,
        mul_i => iq_i.sin,
        enable_i => bunch_enable_sin,
        start_i => start_i,
        overflow_mask_i => overflow_mask,
        preload_i => preload,
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
            write_o <= write_in;
            if write_in = '1' then
                iq_o <= iq_out;
                detector_overflow_o <= cos_overflow or sin_overflow;
            end if;
        end if;
    end process;
end;
