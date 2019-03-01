# vim: set filetype=tcl:

# The constraints in this file are not applied during synthesis, only during
# implementation.
#
# Note that the TCL in this file is a limited subset, see here for details:
#   https://www.xilinx.com/support/answers/59134.html

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
resize_pblock [get_pblocks pblock_fir] -add {DSP48_X11Y0:DSP48_X17Y19}
resize_pblock [get_pblocks pblock_fir] -add {RAMB18_X9Y0:RAMB18_X14Y19}
resize_pblock [get_pblocks pblock_fir] -add {RAMB36_X9Y0:RAMB36_X14Y9}

# Put the two detectors in tile X0Y0
create_pblock pblock_det
add_cells_to_pblock [get_pblocks pblock_det] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/detector} \
    {dsp_main/dsp_gen[1].dsp_top/detector}]]
resize_pblock [get_pblocks pblock_det] -add {DSP48_X0Y0:DSP48_X5Y19}
resize_pblock [get_pblocks pblock_det] -add {RAMB18_X0Y0:RAMB18_X5Y19}
resize_pblock [get_pblocks pblock_det] -add {RAMB36_X0Y0:RAMB36_X5Y9}

# Let's force the MMS blocks into right hand side of tile X1Y1
create_pblock pblock_mms
add_cells_to_pblock [get_pblocks pblock_mms] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/adc_top/min_max_sum} \
    {dsp_main/dsp_gen[0].dsp_top/dac_top/min_max_sum} \
    {dsp_main/dsp_gen[1].dsp_top/adc_top/min_max_sum} \
    {dsp_main/dsp_gen[1].dsp_top/dac_top/min_max_sum}]]
resize_pblock [get_pblocks pblock_mms] -add {DSP48_X14Y20:DSP48_X17Y39}
resize_pblock [get_pblocks pblock_mms] -add {RAMB18_X10Y20:RAMB18_X14Y39}
resize_pblock [get_pblocks pblock_mms] -add {RAMB36_X10Y10:RAMB36_X14Y19}
# Plus an extra pblock for slices only.  This is to prevent FF->BRAM paths from
# spilling across clock tile boundaries.
create_pblock pblock_mms_slice
add_cells_to_pblock [get_pblocks pblock_mms_slice] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/adc_top/min_max_sum/bank} \
    {dsp_main/dsp_gen[0].dsp_top/adc_top/min_max_sum/store} \
    {dsp_main/dsp_gen[0].dsp_top/adc_top/min_max_sum/update} \
    {dsp_main/dsp_gen[0].dsp_top/dac_top/min_max_sum/bank} \
    {dsp_main/dsp_gen[0].dsp_top/dac_top/min_max_sum/store} \
    {dsp_main/dsp_gen[0].dsp_top/dac_top/min_max_sum/update} \
    {dsp_main/dsp_gen[1].dsp_top/adc_top/min_max_sum/bank} \
    {dsp_main/dsp_gen[1].dsp_top/adc_top/min_max_sum/store} \
    {dsp_main/dsp_gen[1].dsp_top/adc_top/min_max_sum/update} \
    {dsp_main/dsp_gen[1].dsp_top/dac_top/min_max_sum/bank} \
    {dsp_main/dsp_gen[1].dsp_top/dac_top/min_max_sum/store} \
    {dsp_main/dsp_gen[1].dsp_top/dac_top/min_max_sum/update}]]
resize_pblock [get_pblocks pblock_mms_slice] -add {SLICE_X158Y50:SLICE_X221Y99}

# Put Tune PLL in the right hand of X1Y2
create_pblock pblock_tune_pll
add_cells_to_pblock [get_pblocks pblock_tune_pll] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/tune_pll} \
    {dsp_main/dsp_gen[1].dsp_top/tune_pll}]]
resize_pblock [get_pblocks pblock_tune_pll] -add {DSP48_X14Y40:DSP48_X17Y59}
resize_pblock [get_pblocks pblock_tune_pll] -add {RAMB18_X10Y40:RAMB18_X14Y59}
resize_pblock [get_pblocks pblock_tune_pll] -add {RAMB36_X10Y20:RAMB36_X14Y29}
