# vim: set filetype=tcl:

# The constraints in this file are not applied during synthesis, only during
# implementation.

# Place the two FIR blocks in tile X1Y1
create_pblock pblock_fir
add_cells_to_pblock [get_pblocks pblock_fir] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/bunch_fir_top} \
    {dsp_main/dsp_gen[1].dsp_top/bunch_fir_top}]]
resize_pblock [get_pblocks pblock_fir] -add {DSP48_X7Y20:DSP48_X17Y39}
resize_pblock [get_pblocks pblock_fir] -add {RAMB18_X7Y20:RAMB18_X14Y39}
resize_pblock [get_pblocks pblock_fir] -add {RAMB36_X7Y10:RAMB36_X14Y19}

# Put the two detectors (or rather just their bodies) in tile X0Y1
create_pblock pblock_detector
add_cells_to_pblock [get_pblocks pblock_detector] [get_cells -quiet [list \
    {dsp_main/dsp_gen[0].dsp_top/detector/detectors[0].detector_body} \
    {dsp_main/dsp_gen[0].dsp_top/detector/detectors[1].detector_body} \
    {dsp_main/dsp_gen[0].dsp_top/detector/detectors[2].detector_body} \
    {dsp_main/dsp_gen[0].dsp_top/detector/detectors[3].detector_body} \
    {dsp_main/dsp_gen[1].dsp_top/detector/detectors[0].detector_body} \
    {dsp_main/dsp_gen[1].dsp_top/detector/detectors[1].detector_body} \
    {dsp_main/dsp_gen[1].dsp_top/detector/detectors[2].detector_body} \
    {dsp_main/dsp_gen[1].dsp_top/detector/detectors[3].detector_body}]]

resize_pblock [get_pblocks pblock_detector] -add {DSP48_X0Y20:DSP48_X6Y39}
resize_pblock [get_pblocks pblock_detector] -add {RAMB18_X0Y20:RAMB18_X6Y39}
resize_pblock [get_pblocks pblock_detector] -add {RAMB36_X0Y10:RAMB36_X6Y19}
