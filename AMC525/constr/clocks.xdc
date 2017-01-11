create_clock -period 10.0 -name FCLKA [get_ports FCLKA_P]
create_clock -period 8.0 -name CLK125MHZ [get_ports CLK125MHZ0_P]
create_clock -period 2.0 -name ADC_CLK [get_ports {FMC1_LA_P[0]}]

# The following two clocks are derived from CLK125MHZ, but we treat them as
# fully independent clocks.
create_generated_clock -name ref_clk [get_pins clocking_inst/pll_inst/CLKOUT0]
create_generated_clock -name reg_clk [get_pins clocking_inst/pll_inst/CLKOUT1]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks ref_clk] \
    -group [get_clocks -include_generated_clocks reg_clk] \
    -group [get_clocks -include_generated_clocks FCLKA] \
    -group [get_clocks -include_generated_clocks ADC_CLK]

# Trick for false paths.  All registers matching the pattern below are generated
# by the untimed_register entity for explicitly setting a false path.
set_false_path \
    -from [get_cells -hierarchical -regexp .*false_path_register.*]

# vim: set filetype=tcl:
