# The following constraints are applied to the design after synthesis.

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
