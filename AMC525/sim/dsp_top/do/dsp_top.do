do compile.do

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/test_dsp_top.vhd

vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Bunch Store" sim:dsp_top/bunch_select/bunch_store/*
add wave -group "Bunch Select" sim:dsp_top/bunch_select/*
add wave -group "ADC Top" sim:dsp_top/adc_top/*
add wave -group "Fixed NCOs" sim:dsp_top/fixed_ncos/*
add wave -group "Bunch FIR Top" sim:dsp_top/bunch_fir_top/*
add wave -group "DAC FIR Gain" sim:dsp_top/dac_top/dac_output_mux/fir/*
add wave -group "DAC Output Mux" sim:dsp_top/dac_top/dac_output_mux/*
add wave -group "DAC Output Mux NCO0" \
    sim:dsp_top/dac_top/dac_output_mux/scale_ncos(0)/*
add wave -group "DAC Top" sim:dsp_top/dac_top/*
add wave -group "Sequencer" sim:dsp_top/sequencer/*
add wave -group "Detector" sim:dsp_top/detector/*
add wave -group "DSP Top" sim:dsp_top/*

add wave -group "Bench" *


run 3.5 us

# vim: set filetype=tcl:
