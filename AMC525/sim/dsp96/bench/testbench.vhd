library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity testbench is
end testbench;


architecture arch of testbench is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural := 1) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal clk : STD_LOGIC := '0';


    procedure tick_wait(count : natural := 1) is
    begin
        clk_wait(clk, count);
    end procedure;


    signal data : signed(24 downto 0) := (others => '0');
    signal mul : signed(17 downto 0);
    signal overflow_mask : signed(95 downto 0) := (others => '0');
    signal preload : signed(95 downto 0) := (others => '0');
    signal enable : std_logic;
    signal start : std_logic;

    signal sim_sum : signed(95 downto 0);
    signal sim_overflow : std_logic;
    signal dsp_sum : signed(95 downto 0);
    signal dsp_overflow : std_logic;

    signal diff : signed(95 downto 0);
    signal start_dly : std_logic;

    signal sum_ok : boolean;
    signal ovf_ok : boolean;

begin
    clk <= not clk after 1 ns;

    -- Device under test
    dsp96 : entity work.detector_dsp96 port map (
        clk_i => clk,

        data_i => data,
        mul_i => mul,
        enable_i => enable,
        start_i => start,
        overflow_mask_i => overflow_mask,
        preload_i => preload,
        sum_o => dsp_sum,
        overflow_o => dsp_overflow
    );

    -- Simulation of device
    sim_dsp96 : entity work.sim_dsp96 port map (
        clk_i => clk,

        data_i => data,
        mul_i => mul,
        enable_i => enable,
        start_i => start,
        overflow_mask_i => overflow_mask,
        preload_i => preload,
        sum_o => sim_sum,
        overflow_o => sim_overflow
    );


    start_delay : entity work.dlyline generic map (
        DLY => 5
    ) port map (
        clk_i => clk,
        data_i(0) => start,
        data_o(0) => start_dly
    );

    -- Error checking.
    process (clk) begin
        if rising_edge(clk) then
            -- (we only clock these to avoid annoying glitches)
            diff <= dsp_sum - sim_sum;
            ovf_ok <= dsp_overflow = sim_overflow or start_dly = '1';
        end if;
    end process;
    sum_ok <= diff = 0;


    process
        procedure pulse_start is begin
            start <= '1';
            tick_wait;
            start <= '0';
        end;
    begin
        enable <= '1';
        data <= 25X"0000000";
        mul  <= 18X"00000";
        preload <= 96X"0000_0001_0000_0001_0000_0000";
        overflow_mask <= 96X"0000_0000_0000_FFFF_FFFF_FFFF";
        start <= '0';
        tick_wait(2);

        -- Start by loading zero and then accumulating some positive numbers
        pulse_start;
        data <= 25X"0FFFFFF";
        mul  <= 18X"1FFFF";
        tick_wait(5);

        -- Reload and repeat; should be same result
        pulse_start;
        tick_wait(4);

        pulse_start;
        tick_wait(4);

        -- Force a negative number and load it
        preload <= 96X"0000_F000_0000_0001_0000_0000";
        mul  <= 18X"20000";
        pulse_start;
        tick_wait(5);

        pulse_start;
        tick_wait(5);

        -- Switch sign again
        mul  <= 18X"1FFFF";
        pulse_start;
        tick_wait(5);

        pulse_start;
        tick_wait(5);

        -- Now try with a preload with some more tricky bits set
        preload <= 96X"0000_F000_000F_F001_0000_0000";
        pulse_start;
        tick_wait(5);

        mul  <= 18X"20000";
        pulse_start;
        tick_wait(5);

        -- Now for an accumulator carry.  First a large positive number
        data <= 25X"1000000";
        mul  <= 18X"20000";
        pulse_start;
        tick_wait(150);

        -- Now a large negative number.
        data <= 25X"0FFFFFF";
        pulse_start;

        wait;
    end process;
end;
