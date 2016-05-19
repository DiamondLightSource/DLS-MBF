create_clock -period 10.0 -name CLK100MHZ1 [get_ports CLK100MHZ1_P]
create_clock -period 10.0 -name FCLKA [get_ports FCLKA_P]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks CLK100MHZ1] \
    -group [get_clocks -include_generated_clocks FCLKA] \
    -group [get_clocks -include_generated_clocks CLK533MHZ0_P] \
    -group [get_clocks -include_generated_clocks CLK533MHZ1_P]
