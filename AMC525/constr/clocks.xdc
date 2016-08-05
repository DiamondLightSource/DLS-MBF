create_clock -period 10.0 -name FCLKA [get_ports FCLKA_P]
create_clock -period 8.0 -name CLK125MHZ [get_ports CLK125MHZ0_P]
create_clock -period 2.0 -name ADC_CLK [get_ports {FMC1_LA_P[0]}]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks CLK125MHZ] \
    -group [get_clocks -include_generated_clocks FCLKA] \
    -group [get_clocks -include_generated_clocks CLK533MHZ0_P] \
    -group [get_clocks -include_generated_clocks CLK533MHZ1_P] \
    -group [get_clocks -include_generated_clocks txoutclk_x0y1] \
    -group [get_clocks -include_generated_clocks ADC_CLK]
