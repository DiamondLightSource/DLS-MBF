-- Sequential state machine to compute angle and magnitude of vector iq_i.
-- Processing is initiated by pulsing start_i and completion signalled by
-- done_o.
--
-- The algorithm implemented here is the classic CORDIC algorithm:
--
--      Volder, J.E., 1959; "The CORDIC Trigonometric Computing Technique",
--      IRE Transactions on Electronic Computers, V.  EC-8, No. 3, pp. 330-334
--
-- The basic iteration step is the calculation:
--
--      x <= x + (y >>> n)
--      y <= y - (x >>> n)
--
-- which can be written as (let xy = column vector of x and y):
--
--            [1    2^-n]
--      xy <= [-2^-n   1] xy = sqrt(1 + 2^-2n) R(th) xy , where tan(th) = 2^-n
--
-- where R(th) is the rotation matrix to rotate a vectory by angle th, in this
-- case tan^-1(2^-n).  Here we perform a sequence of positive or negative
-- rotations for increasing values of n to drive one component of the vector to
-- zero.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;


entity tune_pll_cordic is
    port (
        clk_i : in std_ulogic;

        iq_i : in cos_sin_t;
        start_i : in std_ulogic;

        angle_o : out signed;
        magnitude_o : out unsigned;
        done_o : out std_ulogic
    );
end;

architecture arch of tune_pll_cordic is
    constant WORD_SIZE_IN : natural := iq_i.cos'LENGTH;
    constant ANGLE_BITS : natural := angle_o'LENGTH;
    constant WORD_SIZE : natural := iq_i.cos'LENGTH;

    constant SHIFT_COUNT : natural := ANGLE_BITS - 2;
    constant ATAN_BITS : natural := ANGLE_BITS + 2;

    subtype angle_t is signed(ATAN_BITS-1 downto 0);

    -- Inverse tangent
    signal atan : angle_t;
    signal angle_update : angle_t;

    -- Cordic state machine.
    type state_t is (STATE_IDLE, STATE_SHIFT, STATE_ADD);
    signal state : state_t := STATE_IDLE;
    signal step_count : unsigned(bits(SHIFT_COUNT-1)-1 downto 0);
    signal shift : natural;
    signal done : std_ulogic;
    signal quadrant : std_ulogic_vector(1 downto 0);

    -- To account for CORDIC growth, a factor of around 1.65 together with a
    -- further factor of sqrt(2) from rotation, we need two more bits of high
    -- order result, plus we add two more bits to allow for rounding; we'll
    -- discard the bottom bits on completion.
    constant IQ_SIZE : natural := WORD_SIZE_IN + 4;
    subtype iq_accum_t is
        cos_sin_t(cos(IQ_SIZE-1 downto 0), sin(IQ_SIZE-1 downto 0));

    signal iq : iq_accum_t;
    signal shifted : iq_accum_t;
    signal angle : signed(ATAN_BITS-1 downto 0);


    function initial_angle(quadrant : integer) return angle_t is
    begin
        return to_signed(quadrant, 2) & to_signed(0, ATAN_BITS - 2);
    end;

begin
    -- Angle adustment for step lookup.
    atan_table : entity work.cordic_table port map (
        addr_i => step_count,
        dat_o => atan
    );

    quadrant <= sign_bit(iq_i.cos) & sign_bit(iq_i.sin);
    shift <= to_integer(step_count);

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Cordic state machine
            case state is
                when STATE_IDLE =>
                    done <= '0';
                    step_count <= (others => '0');
                    if start_i = '1' then
                        state <= STATE_SHIFT;
                    end if;

                    -- For the first rotation rotate into first quadrant so both
                    -- components are non-negative
                    case quadrant is
                        when "00" =>    -- 0 deg rotation
                            iq.cos <= resize(iq_i.cos & "00", IQ_SIZE);
                            iq.sin <= resize(iq_i.sin & "00", IQ_SIZE);
                            angle <= initial_angle(0);
                        when "10" =>    -- 90 deg rotation
                            iq.cos <= resize(iq_i.sin & "00", IQ_SIZE);
                            iq.sin <= -resize(iq_i.cos & "00", IQ_SIZE);
                            angle <= initial_angle(1);
                        when "11" =>    -- 180 deg rotation
                            iq.cos <= -resize(iq_i.cos & "00", IQ_SIZE);
                            iq.sin <= -resize(iq_i.sin & "00", IQ_SIZE);
                            angle <= initial_angle(-2);
                        when "01" =>    -- 270 deg rotation
                            iq.cos <= -resize(iq_i.sin & "00", IQ_SIZE);
                            iq.sin <= resize(iq_i.cos & "00", IQ_SIZE);
                            angle <= initial_angle(-1);
                        when others =>
                    end case;

                when STATE_SHIFT =>
                    state <= STATE_ADD;
                    shifted.cos <= shift_right(iq.cos, shift);
                    shifted.sin <= shift_right(iq.sin, shift);
                    angle_update <= atan;

                when STATE_ADD =>
                    if step_count = SHIFT_COUNT-1 then
                        done <= '1';
                        state <= STATE_IDLE;
                    else
                        step_count <= step_count + 1;
                        state <= STATE_SHIFT;
                    end if;

                    if iq.sin >= 0 then
                        iq.cos <= iq.cos + shifted.sin;
                        iq.sin <= iq.sin - shifted.cos;
                        angle <= angle + angle_update;
                    else
                        iq.cos <= iq.cos - shifted.sin;
                        iq.sin <= iq.sin + shifted.cos;
                        angle <= angle - angle_update;
                    end if;
            end case;

            -- Register the final result
            if done = '1' then
                magnitude_o <= unsigned(
                    iq.cos(IQ_SIZE-1 downto IQ_SIZE - magnitude_o'LENGTH));
                angle_o <= angle(ATAN_BITS-1 downto ATAN_BITS-ANGLE_BITS);
            end if;
            done_o <= done;
        end if;
    end process;
end;
