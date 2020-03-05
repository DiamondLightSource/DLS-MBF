-- Applies saturation to given signal.  This is designed to be cascaded after a
-- dsp_mac entity, so the true sign bit remains valid as the top bit of the
-- input data.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity saturate is
    generic (
        -- Offset of bottom bit of result
        OFFSET : natural := 0
    );
    port (
        clk_i : in std_ulogic;

        data_i : in signed;
        ovf_i : in std_ulogic;

        -- The incoming overflow is registered to keep it in step with the
        -- outgoing data.
        data_o : out signed;
        ovf_o : out std_ulogic := '0'
    );
end;

architecture arch of saturate is
    constant OUT_WIDTH : natural := data_o'LENGTH;
    subtype DATA_RANGE is natural range OUT_WIDTH+OFFSET-1 downto OFFSET;

    signal data_in : data_i'SUBTYPE := (others => '0');
    signal ovf_in : std_ulogic := '0';
    signal data_out : data_o'SUBTYPE := (others => '0');

begin
    assert OUT_WIDTH + OFFSET < data_i'LENGTH severity failure;

    process (clk_i) begin
        if rising_edge(clk_i) then
            data_in <= data_i;
            ovf_in <= ovf_i;

            if ovf_in = '1' then
                if data_in(data_in'LEFT) = '1' then
                    -- Force to most negative value
                    data_out <= (data_out'LEFT => '1', others => '0');
                else
                    -- Force to most positive value
                    data_out <= (data_out'LEFT => '0', others => '1');
                end if;
            else
                -- All good, output selected range
                data_out <= data_in(DATA_RANGE);
            end if;
            ovf_o <= ovf_in;
        end if;
    end process;

    data_o <= data_out;
end;
