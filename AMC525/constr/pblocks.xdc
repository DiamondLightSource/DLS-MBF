# vim: set filetype=tcl:

# The constraints in this file are not applied during synthesis, only during
# implementation.

# Place the two FIR blocks in tile X1Y1
create_pblock pblock_x1y1
add_cells_to_pblock [get_pblocks pblock_x1y1] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/bunch_fir_top} \
    {dsp_main/dsp_gen[1].dsp_top/bunch_fir_top}]]
resize_pblock [get_pblocks pblock_x1y1] -add {DSP48_X7Y20:DSP48_X17Y39}
resize_pblock [get_pblocks pblock_x1y1] -add {RAMB18_X7Y20:RAMB18_X14Y39}
resize_pblock [get_pblocks pblock_x1y1] -add {RAMB36_X7Y10:RAMB36_X14Y19}

# Put the two detectors in tile X0Y1
create_pblock pblock_x0y1
add_cells_to_pblock [get_pblocks pblock_x0y1] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/detector} \
    {dsp_main/dsp_gen[1].dsp_top/detector}]]

resize_pblock [get_pblocks pblock_x0y1] -add {DSP48_X0Y20:DSP48_X6Y39}
resize_pblock [get_pblocks pblock_x0y1] -add {RAMB18_X0Y20:RAMB18_X6Y39}
resize_pblock [get_pblocks pblock_x0y1] -add {RAMB36_X0Y10:RAMB36_X6Y19}

# Let's force the MMS blocks into tile X1Y2
create_pblock pblock_x1y2
add_cells_to_pblock [get_pblocks pblock_x1y2] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/adc_top/min_max_sum} \
    {dsp_main/dsp_gen[0].dsp_top/dac_top/min_max_sum} \
    {dsp_main/dsp_gen[1].dsp_top/adc_top/min_max_sum} \
    {dsp_main/dsp_gen[1].dsp_top/dac_top/min_max_sum}]]

resize_pblock [get_pblocks pblock_x1y2] -add {DSP48_X7Y40:DSP48_X17Y59}
resize_pblock [get_pblocks pblock_x1y2] -add {RAMB18_X7Y40:RAMB18_X14Y59}
resize_pblock [get_pblocks pblock_x1y2] -add {RAMB36_X7Y20:RAMB36_X14Y29}

# A special pblock just for the output AXI Lite register.  The idea here is to
# try to protect the interconnect from timing tensions by fixing the output
# register.
create_pblock pblock_axi_lite
add_cells_to_pblock [get_pblocks pblock_axi_lite] [get_cells -quiet [list \
    {interconnect/interconnect_i/axi_lite/axi_register_slice_1}]]
resize_pblock [get_pblocks pblock_axi_lite] -add {SLICE_X142Y200:SLICE_X161Y224}
