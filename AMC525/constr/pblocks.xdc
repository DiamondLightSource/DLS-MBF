# vim: set filetype=tcl:

# The constraints in this file are not applied during synthesis, only during
# implementation.

create_pblock pblock_1
add_cells_to_pblock [get_pblocks pblock_1] \
    [get_cells -quiet [list {dsp_main/dsp_gen[0].dsp_top/bunch_fir_top}]]
resize_pblock [get_pblocks pblock_1] -add {DSP48_X7Y40:DSP48_X14Y59}
resize_pblock [get_pblocks pblock_1] -add {RAMB18_X7Y40:RAMB18_X10Y59}
resize_pblock [get_pblocks pblock_1] -add {RAMB36_X7Y20:RAMB36_X10Y29}

create_pblock pblock_2
add_cells_to_pblock [get_pblocks pblock_2] \
    [get_cells -quiet [list {dsp_main/dsp_gen[1].dsp_top/bunch_fir_top}]]
resize_pblock [get_pblocks pblock_2] -add {DSP48_X3Y40:DSP48_X6Y59}
resize_pblock [get_pblocks pblock_2] -add {RAMB18_X4Y40:RAMB18_X6Y59}
resize_pblock [get_pblocks pblock_2] -add {RAMB36_X4Y20:RAMB36_X6Y29}

