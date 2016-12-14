do compile.do

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/clock_support.vhd \
    $bench_dir/test_dsp_top.vhd

vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

add wave -group "Clocks" sim:/testbench/clock_inst/*

add wave -group "Bunch" sim:/testbench/dsp_top_inst/bunch_select_inst/*
add wave -group "Bunch Mem" \
    sim:/testbench/dsp_top_inst/bunch_select_inst/bunch_mem/*
add wave -group "ADC Top" sim:/testbench/dsp_top_inst/adc_top_inst/*
add wave -group "FIR Top" sim:/testbench/dsp_top_inst/bunch_fir_top_inst/*
add wave -group "Bunch FIR" \
    sim:/testbench/dsp_top_inst/bunch_fir_top_inst/lanes_gen(0)/fir_inst/*
add wave -group "Bunch FIR dly(1)" \
    sim:/testbench/dsp_top_inst/bunch_fir_top_inst/lanes_gen(0)/fir_inst/delay_gen(1)/data_delay_inst/*
add wave -group "Bunch FIR taps" \
    sim:/testbench/dsp_top_inst/bunch_fir_top_inst/bunch_fir_taps_inst/*
add wave -group "DAC Top" sim:/testbench/dsp_top_inst/dac_top_inst/*
add wave -group "DAC Mux" \
    sim:/testbench/dsp_top_inst/dac_top_inst/lanes_gen(0)/dac_output_mux_inst/*
add wave -group "DSP Top" sim:/testbench/dsp_top_inst/*
add wave -group "Top" sim:*


run 100 ns

# vim: set filetype=tcl: