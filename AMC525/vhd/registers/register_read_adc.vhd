-- Maps a register read from DSP to ADC clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity register_read_adc is
    generic (
        ACK_PIPELINE : natural := 2
    );
    port (
        dsp_clk_i : in std_ulogic;
        adc_clk_i : in std_ulogic;

        -- Register interface on DSP clock
        dsp_read_strobe_i : in std_ulogic_vector;
        dsp_read_data_o : out reg_data_array_t;
        dsp_read_ack_o : out std_ulogic_vector;

        -- Translated register interface on ADC clock
        adc_read_strobe_o : out std_ulogic_vector;
        adc_read_data_i : in reg_data_array_t;
        adc_read_ack_i : in std_ulogic_vector
    );
end;

architecture arch of register_read_adc is
    -- The acknowledge and data is synchronised in two stages before being
    -- pipelined to help with routing.  Note that this design does rely on ack_i
    -- only being high in response to a strobe request, otherwise the data read
    -- will be old.

    signal dsp_read_ack : dsp_read_ack_o'SUBTYPE;
    signal read_ack : dsp_read_ack_o'SUBTYPE;
    signal dsp_read_data : adc_read_data_i'SUBTYPE;
    signal read_data : adc_read_data_i'SUBTYPE;

begin
    gen : for r in dsp_read_strobe_i'RANGE generate
        -- The read strobe can be passed straight through
        strobe_in : entity work.pulse_dsp_to_adc port map (
            adc_clk_i => adc_clk_i,
            dsp_clk_i => dsp_clk_i,
            pulse_i => dsp_read_strobe_i(r),
            pulse_o => adc_read_strobe_o(r)
        );


        -- The acknowledge is synchronised with data and pipelined
        ack_out : entity work.pulse_adc_to_dsp port map (
            adc_clk_i => adc_clk_i,
            dsp_clk_i => dsp_clk_i,
            pulse_i => adc_read_ack_i(r),
            pulse_o => dsp_read_ack(r)
        );

        -- Synchronise and capture ADC data.
        process (dsp_clk_i) begin
            if rising_edge(dsp_clk_i) then
                dsp_read_data(r) <= adc_read_data_i(r);
                if dsp_read_ack(r) = '1' then
                    read_data(r) <= dsp_read_data(r);
                end if;
                read_ack(r) <= dsp_read_ack(r);
            end if;
        end process;

        -- Pipeline for ack
        pipe_ack : entity work.dlyreg generic map (
            DLY => ACK_PIPELINE
        ) port map (
            clk_i => dsp_clk_i,
            data_i(0) => read_ack(r),
            data_o(0) => dsp_read_ack_o(r)
        );

        -- Pipeline for data
        pipe_data : entity work.dlyreg generic map (
            DLY => ACK_PIPELINE,
            DW => REG_DATA_WIDTH
        ) port map (
            clk_i => dsp_clk_i,
            data_i => read_data(r),
            data_o => dsp_read_data_o(r)
        );
    end generate;
end;
