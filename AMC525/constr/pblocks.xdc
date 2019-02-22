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


# Place the two FIR blocks in tile X1Y0
create_pblock pblock_fir
add_cells_to_pblock [get_pblocks pblock_fir] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/bunch_fir_top} \
    {dsp_main/dsp_gen[1].dsp_top/bunch_fir_top}]]
resize_pblock [get_pblocks pblock_fir] -add {DSP48_X7Y0:DSP48_X17Y19}
resize_pblock [get_pblocks pblock_fir] -add {RAMB18_X7Y0:RAMB18_X14Y19}
resize_pblock [get_pblocks pblock_fir] -add {RAMB36_X7Y0:RAMB36_X14Y9}

# Put the two detectors in tile X0Y0
create_pblock pblock_det
add_cells_to_pblock [get_pblocks pblock_det] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/detector} \
    {dsp_main/dsp_gen[1].dsp_top/detector}]]
resize_pblock [get_pblocks pblock_det] -add {DSP48_X0Y0:DSP48_X4Y19}
resize_pblock [get_pblocks pblock_det] -add {RAMB18_X0Y0:RAMB18_X4Y19}
resize_pblock [get_pblocks pblock_det] -add {RAMB36_X0Y0:RAMB36_X4Y9}

# Let's force the MMS blocks into right hand side of tile X1Y1
create_pblock pblock_mms
add_cells_to_pblock [get_pblocks pblock_mms] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/adc_top/min_max_sum} \
    {dsp_main/dsp_gen[0].dsp_top/dac_top/min_max_sum} \
    {dsp_main/dsp_gen[1].dsp_top/adc_top/min_max_sum} \
    {dsp_main/dsp_gen[1].dsp_top/dac_top/min_max_sum}]]
resize_pblock [get_pblocks pblock_mms] -add {DSP48_X15Y20:DSP48_X17Y39}
resize_pblock [get_pblocks pblock_mms] -add {RAMB18_X11Y20:RAMB18_X14Y39}
resize_pblock [get_pblocks pblock_mms] -add {RAMB36_X11Y10:RAMB36_X14Y19}

# Persuade Tune PLL to live in X1Y2
# For the moment, just fix the major resources
create_pblock pblock_tune_pll
add_cells_to_pblock [get_pblocks pblock_tune_pll] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/tune_pll} \
    {dsp_main/dsp_gen[1].dsp_top/tune_pll}]]
resize_pblock [get_pblocks pblock_tune_pll] -add {DSP48_X7Y40:DSP48_X17Y59}
resize_pblock [get_pblocks pblock_tune_pll] -add {RAMB18_X7Y40:RAMB18_X14Y59}
resize_pblock [get_pblocks pblock_tune_pll] -add {RAMB36_X7Y20:RAMB36_X14Y29}

# # A special pblock just for the output AXI Lite register.  The idea here is to
# # try to protect the interconnect from timing tensions by fixing the output
# # register.
# create_pblock pblock_axi_lite
# add_cells_to_pblock [get_pblocks pblock_axi_lite] [get_cells -quiet [list \
#     {interconnect/interconnect_i/axi_lite/axi_register_slice_1}]]
# resize_pblock [get_pblocks pblock_axi_lite] -add {SLICE_X162Y225:SLICE_X169Y230}
