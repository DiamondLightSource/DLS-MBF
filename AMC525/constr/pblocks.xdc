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


# Pinning down the buffer between the PCIe bridge and the AXI lite interconnect
# seems to help with timing in the PCIe bridge.
set pblock_axi_lite [create_pblock pblock_axi_lite]
resize_pblock $pblock_axi_lite -add {SLICE_X106Y250:SLICE_X169Y299}
add_cells_to_pblock $pblock_axi_lite [get_cells \
    {interconnect/interconnect_i/axi_lite/axi_register_slice_0} \
]

set pblock_pcie [create_pblock pblock_pcie]
resize_pblock $pblock_pcie -add {SLICE_X170Y200:SLICE_X221Y299}
resize_pblock $pblock_pcie -add {RAMB18_X11Y80:RAMB18_X14Y119}
resize_pblock $pblock_pcie -add {RAMB36_X11Y40:RAMB36_X14Y59}
add_cells_to_pblock $pblock_pcie [get_cells \
    {interconnect/interconnect_i/axi_pcie3_bridge} \
]

# Place the two FIR blocks in tile X1Y0
set pblock_fir [create_pblock pblock_fir]
resize_pblock $pblock_fir -add {DSP48_X11Y0:DSP48_X17Y19}
resize_pblock $pblock_fir -add {RAMB18_X9Y0:RAMB18_X14Y19}
resize_pblock $pblock_fir -add {RAMB36_X9Y0:RAMB36_X14Y9}
add_cells_to_pblock $pblock_fir [get_cells [list \
    {dsp_main/dsp_gen[0].dsp_top/bunch_fir_top} \
    {dsp_main/dsp_gen[1].dsp_top/bunch_fir_top} \
]]

# Put the two detectors in tile X0Y0
set pblock_det [create_pblock pblock_det]
resize_pblock $pblock_det -add {DSP48_X0Y0:DSP48_X5Y19}
resize_pblock $pblock_det -add {RAMB18_X0Y0:RAMB18_X5Y19}
resize_pblock $pblock_det -add {RAMB36_X0Y0:RAMB36_X5Y9}
add_cells_to_pblock $pblock_det [get_cells [list \
    {dsp_main/dsp_gen[0].dsp_top/detector} \
    {dsp_main/dsp_gen[1].dsp_top/detector} \
]]

# Let's force the MMS blocks into right hand side of tile X1Y1
set pblock_mms [create_pblock pblock_mms]
resize_pblock $pblock_mms -add {DSP48_X14Y20:DSP48_X17Y39}
resize_pblock $pblock_mms -add {RAMB18_X10Y20:RAMB18_X14Y39}
resize_pblock $pblock_mms -add {RAMB36_X10Y10:RAMB36_X14Y19}
add_cells_to_pblock $pblock_mms [get_cells [list \
    {dsp_main/dsp_gen[0].dsp_top/adc_top/min_max_sum} \
    {dsp_main/dsp_gen[0].dsp_top/dac_top/min_max_sum} \
    {dsp_main/dsp_gen[1].dsp_top/adc_top/min_max_sum} \
    {dsp_main/dsp_gen[1].dsp_top/dac_top/min_max_sum} \
]]
# Plus an extra pblock for slices only.  This is to prevent FF->BRAM paths from
# spilling across clock tile boundaries.
set pblock_mms_slice [create_pblock pblock_mms_slice]
resize_pblock $pblock_mms_slice -add {SLICE_X158Y50:SLICE_X221Y99}
add_cells_to_pblock $pblock_mms_slice [get_cells [list \
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
    {dsp_main/dsp_gen[1].dsp_top/dac_top/min_max_sum/update} \
]]

# Put sequencer and its NCO above the detector
set pblock_seq [create_pblock pblock_seq]
resize_pblock $pblock_seq -add {SLICE_X1Y50:SLICE_X75Y99}
add_cells_to_pblock $pblock_seq [get_cells [list \
    {dsp_main/dsp_gen[0].dsp_top/sequencer} \
    {dsp_main/dsp_gen[0].dsp_top/nco_1/nco_core} \
    {dsp_main/dsp_gen[1].dsp_top/sequencer} \
    {dsp_main/dsp_gen[1].dsp_top/nco_1/nco_core} \
]]
remove_cells_from_pblock $pblock_seq [get_cells [list \
    {dsp_main/dsp_gen[0].dsp_top/sequencer/pll_freq_delay} \
    {dsp_main/dsp_gen[0].dsp_top/sequencer/registers} \
    {dsp_main/dsp_gen[1].dsp_top/sequencer/pll_freq_delay} \
    {dsp_main/dsp_gen[1].dsp_top/sequencer/registers} \
]]

# set pblock_extra [create_pblock pblock_extra]
# resize_pblock $pblock_extra -add {SLICE_X52Y100:SLICE_X105Y149}
# resize_pblock $pblock_extra -add {RAMB18_X4Y40:RAMB18_X6Y59}
# resize_pblock $pblock_extra -add {RAMB36_X4Y20:RAMB36_X6Y29}
# add_cells_to_pblock $pblock_extra [get_cells [list \
#     {dsp_main/dsp_gen[0].dsp_top/adc_top/fill_reject} \
#     {dsp_main/dsp_gen[1].dsp_top/adc_top/fill_reject} \
# ]]
# remove_cells_from_pblock $pblock_extra [get_cells [list \
#     {dsp_main/dsp_gen[0].dsp_top/adc_top/fill_reject/turn_clock_delay} \
#     {dsp_main/dsp_gen[1].dsp_top/adc_top/fill_reject/turn_clock_delay} \
# ]]


# Put Tune PLL in the right hand of X1Y2
set pblock_tune_pll [create_pblock pblock_tune_pll]
resize_pblock $pblock_tune_pll -add {DSP48_X14Y40:DSP48_X17Y59}
resize_pblock $pblock_tune_pll -add {RAMB18_X10Y40:RAMB18_X14Y59}
resize_pblock $pblock_tune_pll -add {RAMB36_X10Y20:RAMB36_X14Y29}
add_cells_to_pblock $pblock_tune_pll [get_cells [list \
    {dsp_main/dsp_gen[0].dsp_top/tune_pll} \
    {dsp_main/dsp_gen[1].dsp_top/tune_pll} \
]]
