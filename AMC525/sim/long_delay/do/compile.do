# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/util/block_memory.vhd \
    $vhd_dir/util/long_delay.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

add wave -group "Delay" sim:/testbench/delay_inst/*
add wave -group "Memory" sim:/testbench/delay_inst/memory_inst/*
add wave -group "Top" sim:*


run 300ns

# vim: set filetype=tcl:
