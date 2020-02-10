-- Applies gain selection to FIR, produces two outputs: one wide output for
-- input to further accumulation of NCO values, one narrow output for optional
-- output to the MMS.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity dac_fir_gain is
    generic (
        MMS_OFFSET : natural
    );
    port (
        clk_i : in std_ulogic;

        data_i : in signed;
        gain_i : in unsigned;
        enable_i : in std_ulogic;

        data_o : out signed;
        mms_o : out signed;
        overflow_o : out std_ulogic
    );
end;

architecture arch of dac_fir_gain is
    signal shifted_data : data_o'SUBTYPE;
    signal shifted_data_out : data_o'SUBTYPE;
    signal fir_overflow : std_ulogic;
    signal data_out : data_o'SUBTYPE;

    subtype OVERFLOW_RANGE is natural range
        MMS_OFFSET + mms_o'LENGTH - 1 downto MMS_OFFSET;

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Compute output data and overflow detection together, we'll need
            -- this for the saturation stage.
            shifted_data <=
                shift_left(resize(data_i, data_o'LENGTH), to_integer(gain_i));
            shifted_data_out <= shifted_data;
            fir_overflow <= overflow_detect(shifted_data(OVERFLOW_RANGE));

            -- Only report FIR overflow if the data is enabled.  We don't need
            -- to saturate this data as this will be managed downstream.
            if enable_i then
                data_out <= shifted_data_out;
                overflow_o <= fir_overflow;
            else
                data_out <= (others => '0');
                overflow_o <= '0';
            end if;
        end if;
    end process;

    -- Saturate the MMS data for a more friendly display.
    saturate : entity work.saturate generic map (
        OFFSET => MMS_OFFSET
    ) port map (
        clk_i => clk_i,
        data_i => shifted_data_out,
        ovf_i => fir_overflow,
        data_o => mms_o
    );

    data_o <= data_out;
end;
