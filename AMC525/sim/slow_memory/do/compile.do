# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/axi/axi_lite_master.vhd \
    $vhd_dir/memory/slow_memory_fifo.vhd \
    $vhd_dir/memory/slow_memory_priority.vhd \
    $vhd_dir/memory/slow_memory_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

add wave -group "AXI Master" sim:/testbench/axi_lite_master_inst/*
add wave -group "Slow top" sim:/testbench/slow_inst/*
add wave -group "FIFO(0)" sim:/testbench/slow_inst/fifo_gen(0)/fifo_inst/*
add wave -group "FIFO(1)" sim:/testbench/slow_inst/fifo_gen(1)/fifo_inst/*
add wave -group "Priority" sim:/testbench/slow_inst/priority_inst/*
add wave -group "Top" sim:*


run 250 ns

# vim: set filetype=tcl:
