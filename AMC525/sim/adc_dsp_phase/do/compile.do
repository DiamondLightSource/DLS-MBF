# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/system/adc_dsp_phase.vhd

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Phase" sim:/testbench/i_phase/*
add wave sim:*


run 50ns

# vim: set filetype=tcl:
