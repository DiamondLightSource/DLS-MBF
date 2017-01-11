# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/registers/register_mux_strobe.vhd \
    $vhd_dir/registers/register_mux.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Mux" sim:/testbench/register_mux_inst/*
add wave -group "Read" sim:/testbench/register_mux_inst/read_strobe_inst/*
add wave -group "Write" sim:/testbench/register_mux_inst/write_strobe_inst/*
add wave sim:*


run 400ns

# vim: set filetype=tcl:
