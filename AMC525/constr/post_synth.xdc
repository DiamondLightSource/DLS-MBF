# The following constraints are applied to the design after synthesis.

# Trick for false paths.  All registers matching the pattern below are generated
# by the untimed_register entity for explicitly setting a false path.
set_false_path \
    -from [get_cells -hierarchical -regexp .*false_path_register_from.*] \
    -to   [get_cells -hierarchical -regexp .*false_path_register_to.*]

# Special hack for the DAC output delay line.  This runs at 500 MHz, which is
# perfectly feasible at our speed grade ... except for the fact that the
# inferred BRAM synthesis sets a writing mode which is incompatible with high
# speed operation.  It turns out that forcing port A from READ_FIRST into
# WRITE_FIRST mode is sufficient, if nasty.
set_property WRITE_MODE_A WRITE_FIRST [get_cells \
    dsp0_top_inst/dac_top_inst/dac_delay_inst/memory_inst/memory_reg]
set_property WRITE_MODE_A WRITE_FIRST [get_cells \
    dsp1_top_inst/dac_top_inst/dac_delay_inst/memory_inst/memory_reg]

# vim: set filetype=tcl:
