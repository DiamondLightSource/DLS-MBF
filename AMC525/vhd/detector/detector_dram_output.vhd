-- Output to DRAM controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity detector_dram_output is
    port (
        clk_i : in std_logic;

        address_reset_i : in std_logic;
        input_enable_i : in std_logic_vector;

        input_valid_i : in std_logic_vector;
        input_ready_o : out std_logic_vector;
        input_data_i : vector_array;

        output_valid_o : out std_logic;
        output_ready_i : in std_logic;
        output_addr_o : out unsigned;
        output_data_o : out std_logic_vector
    );
end;

architecture arch of detector_dram_output is
    subtype selection_t is natural range input_enable_i'RANGE;
    signal selection : selection_t := selection_t'LOW;

    signal input_valid : boolean;
    signal input_enable : boolean;
    signal emit_output : boolean;
    signal advance_input : boolean;
    signal output_ready : boolean;
    signal output_busy : boolean := false;

begin
    -- Input state management
    --
    input_valid <= input_valid_i(selection) = '1';
    input_enable <= input_enable_i(selection) = '1';
    emit_output <= input_valid and input_enable;
    advance_input <= input_valid and (output_ready or not input_enable);
    process (clk_i) begin
        if rising_edge(clk_i) then
            if address_reset_i = '1' then
                selection <= 0;
            elsif advance_input then
                if selection = selection_t'HIGH then
                    selection <= selection_t'LOW;
                else
                    selection <= selection + 1;
                end if;
            end if;

            compute_strobe(
                input_ready_o, selection, to_std_logic(advance_input));
        end if;
    end process;


    -- Output state management
    --
    --    state  ov rdy  e or  state'  action
    --  +-------+------+------+-------+---------------
    --  | idle  | 0 1  | 0    : idle   -
    --  |       |      | 1    : busy   od <= id(n)
    --  +-------+------+------+-------+---------------
    --  | busy  | 1 or |   0  : busy   -
    --  |       |      | 0 1  : idle   oa <= oa+1
    --  |       |      | 1 1  : busy   oa <= oa+1; od <= id(n)
    --  +-------+------+------+-------+---------------
    --  Outputs:
    --      ov = output_valid_o, rdy = output_ready,
    --      od = output_data_o, oa = output_address_o
    --  Inputs:
    --      e = emit_output, or = output_ready_i,
    --      id(n) = input_data_i(selection)
    --
    output_ready <= not output_busy or output_ready_i = '1';
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- We remain busy while we have requests for output and we haven't
            -- managed to get rid of our data.
            output_busy <=
                emit_output or (output_busy and output_ready_i = '0');

            -- When we're ready to take output use the current selection; the
            -- input stage manager will advance the selection.
            if emit_output and output_ready then
                output_data_o <= input_data_i(selection);
            end if;

            -- When data is taken advance the address.
            if address_reset_i = '1' then
                output_addr_o <= (output_addr_o'RANGE => '0');
            elsif output_busy and output_ready_i = '1' then
                output_addr_o <= output_addr_o + 1;
            end if;
        end if;
    end process;

    output_valid_o <= to_std_logic(output_busy);
end;
