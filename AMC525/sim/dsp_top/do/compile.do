# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/util/sync_reset.vhd \
    $vhd_dir/adc_phase.vhd \
    $vhd_dir/dsp/adc_to_dsp.vhd \
    $vhd_dir/dsp/dsp_to_adc.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

add wave -group "Top" sim:*
add wave sim:*
add wave -group "ADC -> DSP" sim:/testbench/adc_to_dsp_inst/*
add wave -group "DSP -> ADC" sim:/testbench/dsp_to_adc_inst/*
# add wave -group "Phase" sim:/testbench/adc_phase_inst/*
# add wave sim:/testbench/axi_burst_master_inst/*


run 1us

# vim: set filetype=tcl:
