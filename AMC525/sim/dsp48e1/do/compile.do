# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/detector/detector_dsp48e1.vhd \
    $bench_dir/sim_dsp96.vhd

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Top" sim:*
add wave -group "DSP48E1" sim:/testbench/dsp48e1/*
add wave -group "Sim" sim:/testbench/sim_dsp96/*


run 100ns

# vim: set filetype=tcl:
