-- Detector input processing: input selection, FIR gain control, and scaling by
-- detector window.

entity detector_input is
    port (
        clk_i : in std_logic;

        -- Control
        fir_gain_i : in unsigned;
        data_select_i : in std_logic;

        -- Data in
        adc_data_i : in signed;
        fir_data_i : in signed;
        window_i : in signed;

        -- Data out
        data_o : out signed;
        fir_overflow_o : out std_logic
    );
end;

architecture arch of detector_input is
    signal fir_data : signed;
    signal fir_overflow_in : std_logic;
    signal fir_overflow : std_logic;

    signal window : window_i'SUBTYPE;
    signal data_in : signed;
    signal data : signed;
    signal data_out : signed;

begin
    fir_gain_inst : entity work.gain_control port map (
        clk_i => clk_i,
        gain_sel_i => fir_gain_i,
        data_i => fir_data_i,
        data_o => fir_data,
        overflow_o => fir_overflow_in
    );


    process (clk_i) begin
        if rising_edge(clk_i) then
            case data_select_i is
                when '0' =>
                    data_in <= adc_data_i;
                    fir_overflow <= '0';
                when '1' =>
                    data_in <= fir_data;
                    fir_overflow <= fir_overflow_in
                when others =>
            end case;

            -- Product, needs to be carefully pipelined
            window <= window_i;
            data <= data_in;
            windowed_data <= window * data;
            data_out <= window_data;

            -- Final output
            data_o <= round(data_out, data_o'LENGTH);
        end if;
    end process;


    -- Delay overflow to match data delay:
    --  data_in => data => windowed_data => data_out => data_o
    delay : entity work.dlyline generic map (
        DLY => 4
    ) port map (
        clk_i => clk_i,
        data_i(0) => fir_overflow,
        data_o(0) => fir_overflow_o
    );
end;
