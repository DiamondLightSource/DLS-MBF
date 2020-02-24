-- Applies gain selection to FIR, produces two outputs: one wide output for
-- input to further accumulation of NCO values, one narrow output for optional
-- output to the MMS.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity dac_fir_gain is
    port (
        clk_i : in std_ulogic;

        fir_data_i : in signed(24 downto 0);    -- 4.21
        fixed_gain_i : in unsigned(3 downto 0); -- Treat as x2^7 to x2^-8
        bb_gain_i : in signed(17 downto 0);     -- 4.14

        fir_data_o : out signed(47 downto 0);   -- 13.35
        fir_mms_o : out signed(15 downto 0);    -- 1.15
        fir_overflow_o : out std_ulogic;
        mms_overflow_o : out std_ulogic
    );
end;

architecture arch of dac_fir_gain is
    signal data_in : signed(39 downto 0) := (others => '0');
    signal shifted_data : signed(39 downto 0) := (others => '0');
    signal shifted_data_out : signed(39 downto 0) := (others => '0');
    signal fir_overflow : std_ulogic := '0';

    signal shifted_fir : signed(24 downto 0);

    signal full_mms_out : signed(47 downto 0);
    signal mms_overflow : std_ulogic;

    -- Our output is a 12.35 value packed into a PCOUT wire.  We generate this
    -- by multiplying a 4.14 bunch by bunch scaling factor into a 4.21 input,
    -- which was in turn extracted from the 11.29 scaled value.
    --
    -- This readout shift determines the position of the binary point in the
    -- final output.
    constant BASE_READOUT_SHIFT : natural := 8;
    subtype BASE_READOUT_RANGE is natural range
        BASE_READOUT_SHIFT + 24 downto BASE_READOUT_SHIFT;
    subtype OVERFLOW_RANGE is natural range
        shifted_data'LEFT downto BASE_READOUT_RANGE'LEFT;
    -- We extract 1.15 from 12.35
    subtype MMS_READOUT_RANGE is natural range 35 downto 20;

begin
    -- Shift the data to apply the fixed gain
    process (clk_i) begin
        if rising_edge(clk_i) then
            data_in <= (39 downto 15 => fir_data_i, others => '0');
            shifted_data <= shift_right(data_in, to_integer(fixed_gain_i));
            -- Compute output data and overflow detection together, we'll need
            -- this for the saturation stage.
            shifted_data_out <= shifted_data;
            fir_overflow <= overflow_detect(shifted_data(OVERFLOW_RANGE));
        end if;
    end process;

    -- Slice 25 bits from the shifted FIR so we can scale it; at this point we
    -- may suffer an overflow.
    saturate_fir : entity work.saturate generic map (
        OFFSET => BASE_READOUT_SHIFT
    ) port map (
        clk_i => clk_i,
        data_i => shifted_data_out,
        ovf_i => fir_overflow,
        data_o => shifted_fir,
        ovf_o => fir_overflow_o
    );

    -- Next scale the shifted and saturated data by the bunch by bunch factor
    bb_scale_nco : entity work.dsp48e_mac generic map (
        TOP_RESULT_BIT => MMS_READOUT_RANGE'LEFT
    ) port map (
        clk_i => clk_i,
        a_i => shifted_fir,
        b_i => bb_gain_i,
        en_ab_i => '1',
        en_c_i => '0',
        p_o => full_mms_out,
        pc_o => fir_data_o,
        ovf_o => mms_overflow
    );

    -- Finally saturate the displayed MMS output.
    saturate_mms : entity work.saturate generic map (
        OFFSET => MMS_READOUT_RANGE'RIGHT
    ) port map (
        clk_i => clk_i,
        data_i => full_mms_out,
        ovf_i => mms_overflow,
        data_o => fir_mms_o,
        ovf_o => mms_overflow_o
    );
end;
