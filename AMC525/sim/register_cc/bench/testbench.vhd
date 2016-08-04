library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity testbench is
end testbench;


use work.support.all;
use work.defines.all;

architecture testbench of testbench is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal dsp_clk : std_logic := '0';
    signal axi_clk : std_logic := '0';


    procedure tick_wait(count : natural) is
    begin
        clk_wait(axi_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(axi_clk, 1);
    end procedure;


    signal dsp_rst_n : std_logic := '0';

    signal axi_read_strobe : std_logic := '0';
    signal axi_read_data : reg_data_t;
    signal axi_read_ack : std_logic;
    signal dsp_read_strobe : std_logic;
    signal dsp_read_data : reg_data_t := (others => '0');
    signal dsp_read_ack : std_logic := '0';
    signal axi_write_strobe : std_logic := '0';
    signal axi_write_ack : std_logic;
    signal dsp_write_strobe : std_logic;
    signal dsp_write_ack : std_logic := '0';

    signal force_read_ack : std_logic := '0';

begin

    process begin
        if dsp_rst_n = '1' then
            dsp_clk <= not dsp_clk;
            wait for 2 ns;
        else
            wait on dsp_rst_n;
        end if;
    end process;

    process (dsp_clk) begin
        if rising_edge(dsp_clk) then
            dsp_read_data <=
                std_logic_vector(unsigned(dsp_read_data) + 1);
        end if;
    end process;


    axi_clk <= not axi_clk after 2.1 ns;

    register_cc_inst : entity work.register_cc port map (
        axi_clk_i => axi_clk,
        dsp_clk_i => dsp_clk,
        dsp_rst_n_i => dsp_rst_n,
        axi_read_strobe_i => axi_read_strobe,
        axi_read_data_o => axi_read_data,
        axi_read_ack_o => axi_read_ack,
        dsp_read_strobe_o => dsp_read_strobe,
        dsp_read_data_i => dsp_read_data,
        dsp_read_ack_i => dsp_read_ack,
        axi_write_strobe_i => axi_write_strobe,
        axi_write_ack_o => axi_write_ack,
        dsp_write_strobe_o => dsp_write_strobe,
        dsp_write_ack_i => dsp_write_ack
    );

    -- Simplest test first
--     dsp_read_ack <= '1';
    dsp_write_ack <= '1';

    process (dsp_clk) begin
        if rising_edge(dsp_clk) then
            dsp_read_ack <= dsp_read_strobe or force_read_ack;
        end if;
    end process;

    process begin
        force_read_ack <= '0';
        axi_write_strobe <= '0';
        axi_read_strobe <= '0';

        dsp_rst_n <= '0';
        tick_wait(10);
        dsp_rst_n <= '1';
        tick_wait(10);

        axi_write_strobe <= '1';
        tick_wait;
        axi_write_strobe <= '0';

        tick_wait(15);
        axi_read_strobe <= '1';
        tick_wait;
        axi_read_strobe <= '0';

        tick_wait(15);
        force_read_ack <= '1';
        axi_read_strobe <= '1';
        tick_wait;
        axi_read_strobe <= '0';

--         dsp_rst_n <= '0';
--         tick_wait;
-- 
--         axi_strobe <= '1';
--         tick_wait;
--         axi_strobe <= '0';
-- 
--         tick_wait(10);
--         dsp_rst_n <= '0';
-- 
--         axi_strobe <= '1';
--         tick_wait;
--         axi_strobe <= '0';
-- 
--         tick_wait;
--         tick_wait;
--         dsp_rst_n <= '1';


        wait;
    end process;

end testbench;
