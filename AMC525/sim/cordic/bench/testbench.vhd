library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;

use ieee.math_real.all;

entity testbench is
end testbench;


architecture arch of testbench is
    procedure clk_wait(signal clk_i : in std_ulogic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;

    signal clk : std_ulogic := '0';

    procedure tick_wait(count : natural := 1) is
    begin
        clk_wait(clk, count);
    end procedure;


    -- Test sequence
    type test_cos_sin_t is array(0 to 1) of integer;
    type test_seq_t is array(natural range<>) of test_cos_sin_t;
    signal test_sequence : test_seq_t(0 to 5) := (
        (1, 0),
        (0, 0),
        (16#40000#, 0),
        (16#7FFFFFFF#, 16#7FFFFFFF#),
        (16#80000000#, 16#80000000#),
        (1234567, 1234567)
    );


    constant ANGLE_BITS : natural := 18;
    constant IQ_BITS : natural := 32;
    constant MAGNITUDE_BITS : natural := IQ_BITS;

    subtype angle_t is signed(ANGLE_BITS-1 downto 0);
    subtype magnitude_t is unsigned(MAGNITUDE_BITS-1 downto 0);

    subtype cos_sin_32_t is
        cos_sin_t(cos(IQ_BITS-1 downto 0), sin(IQ_BITS-1 downto 0));
    signal iq : cos_sin_32_t;
    signal start : std_ulogic;

    signal angle : angle_t;
    signal magnitude : magnitude_t;
    signal done : std_ulogic;

    signal expected_angle : real;
    signal expected_magnitude : real;

    signal magnitude_error : real := 0.0;
    signal angle_error : real := 0.0;
    signal ok : boolean := true;

begin
    clk <= not clk after 1 ns;

    cordic : entity work.tune_pll_cordic port map (
        clk_i => clk,
        iq_i => iq,
        start_i => start,
        angle_o => angle,
        magnitude_o => magnitude,
        done_o => done
    );

    -- Compute expected angle and magnitude from given iq
    process (iq)
        -- Scaling factor for CORDIC magnitude
        constant scaling : real := 1.6467602581210654 / 2.0;
        variable iq_cos : real;
        variable iq_sin : real;
        variable angle_rad : real;
    begin
        iq_cos := real(to_integer(iq.cos));
        iq_sin := real(to_integer(iq.sin));
        angle_rad := arctan(iq_sin, iq_cos);
        expected_angle <= 2.0**(ANGLE_BITS-1) * angle_rad / MATH_PI;
        expected_magnitude <= sqrt(iq_cos*iq_cos + iq_sin*iq_sin) * scaling;
    end process;

    -- Compute magnitude of error and set ok flag accordingly
    process (done)
        variable real_magnitude : real;
        variable real_angle : real;
    begin
        if rising_edge(done) then
            -- Annoyingly, because magnitude is unsigned(32) it seems we can't
            -- convert to real without overflow unless we drop the bottom bit.
            real_magnitude := 2.0 * real(to_integer(shift_right(magnitude, 1)));
            real_angle := real(to_integer(angle));
            magnitude_error <= real_magnitude - expected_magnitude;
            angle_error <= real_angle - expected_angle;
        end if;
        if falling_edge(done) then
            ok <= abs(magnitude_error) < 6.0 and
                (real_magnitude = 0.0 or abs(angle_error) < 3.0);
        end if;
    end process;

    process
        variable seed1 : positive := 1;
        variable seed2 : positive := 1;

        variable mag : real;
        variable angle : real;

        -- Thin wrapper over the VHDL PRNG
        impure function random(
            scale : real := 1.0; offset : real := 0.0) return real
        is
            variable result : real;
        begin
            uniform(seed1, seed2, result);
            return scale * (result - offset);
        end;

        -- Handshake with CORDIC device under test
        procedure run_cordic is
        begin
            tick_wait;
            start <= '1';
            tick_wait;
            start <= '0';
            wait until rising_edge(done);
            tick_wait(2);
        end;

    begin
        start <= '0';

        for i in test_sequence'RANGE loop
            iq.cos <= to_signed(test_sequence(i)(0), IQ_BITS);
            iq.sin <= to_signed(test_sequence(i)(1), IQ_BITS);
            run_cordic;
        end loop;


        loop
            iq.cos <= to_signed(integer(random(2.0**IQ_BITS, 0.5)), IQ_BITS);
            iq.sin <= to_signed(integer(random(2.0**IQ_BITS, 0.5)), IQ_BITS);

            run_cordic;

            mag := random *
                2.0 ** (random(real(IQ_BITS/2-1)) + real(IQ_BITS/2));
            angle := random(2.0 * MATH_PI, 0.5);
            iq.cos <= to_signed(integer(mag * cos(angle)), IQ_BITS);
            iq.sin <= to_signed(integer(mag * sin(angle)), IQ_BITS);

            run_cordic;

        end loop;
    end process;
end;
