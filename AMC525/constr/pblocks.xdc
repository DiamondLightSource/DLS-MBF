# vim: set filetype=tcl:

# The constraints in this file are not applied during synthesis, only during
# implementation.

# Some basic geographical locations.  The device has 20 clock tiles in two
# columns of 10, numbered XxYy for x=0..1, y=0..9.  Four types of resource are
# allocated per tile: DSP48, RAMB18, RAMB36, and SLICE.  For each resource the
# tiles have the following dimensions:
#
#               X0 width    X1 width    height
#   DSP48       7           11          20
#   RAMB18      7           8           20
#   RAMB36      7           8           10
#   SLICE       106         116         50


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

# Let's force the MMS blocks into right hand side of tile X1Y2
create_pblock pblock_x1y2
add_cells_to_pblock [get_pblocks pblock_x1y2] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/adc_top/min_max_sum} \
    {dsp_main/dsp_gen[0].dsp_top/dac_top/min_max_sum} \
    {dsp_main/dsp_gen[1].dsp_top/adc_top/min_max_sum} \
    {dsp_main/dsp_gen[1].dsp_top/dac_top/min_max_sum}]]

resize_pblock [get_pblocks pblock_x1y2] -add {DSP48_X15Y40:DSP48_X17Y59}
resize_pblock [get_pblocks pblock_x1y2] -add {RAMB18_X11Y40:RAMB18_X14Y59}
resize_pblock [get_pblocks pblock_x1y2] -add {RAMB36_X11Y20:RAMB36_X14Y29}

# # A special pblock just for the output AXI Lite register.  The idea here is to
# # try to protect the interconnect from timing tensions by fixing the output
# # register.
# create_pblock pblock_axi_lite
# add_cells_to_pblock [get_pblocks pblock_axi_lite] [get_cells -quiet [list \
#     {interconnect/interconnect_i/axi_lite/axi_register_slice_1}]]
# resize_pblock [get_pblocks pblock_axi_lite] -add {SLICE_X162Y225:SLICE_X169Y230}
