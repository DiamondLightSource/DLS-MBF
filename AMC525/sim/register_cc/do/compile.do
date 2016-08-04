# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -93 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/sync_bit.vhd \
    $vhd_dir/sync_reset.vhd \
    $vhd_dir/edge_detect.vhd \
    $vhd_dir/register_strobe_cc.vhd \
    $vhd_dir/register_cc.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

add wave -group "REG" sim:/testbench/register_cc_inst/*
add wave -group "R_CC" sim:/testbench/register_cc_inst/read_cc_inst/*
add wave -group "W_CC" sim:/testbench/register_cc_inst/write_cc_inst/*
add wave sim:*


run 400ns

# vim: set filetype=tcl:
