# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/util/untimed_reg.vhd \
    $vhd_dir/util/block_memory.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/bunch/bunch_defs.vhd \
    $vhd_dir/bunch/bunch_counter.vhd \
    $vhd_dir/bunch/bunch_store.vhd \
    $vhd_dir/bunch/bunch_select.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/testbench.vhd \


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

# add wave -group "MMS" sim:/testbench/min_max_sum_inst/*

add wave -group "Bunch" sim:/testbench/bunch_select_inst/*
add wave -group "Counter" sim:/testbench/bunch_select_inst/bunch_counter/*
add wave -group "Store" sim:/testbench/bunch_select_inst/bunch_mem/*
add wave -group "mem(0)" \
    sim:/testbench/bunch_select_inst/bunch_mem/gen_lanes(0)/memory_inst/*
add wave -group "mem(1)" \
    sim:/testbench/bunch_select_inst/bunch_mem/gen_lanes(1)/memory_inst/*
add wave -group "Top" sim:*
# add wave sim:*


run 200 ns

# vim: set filetype=tcl:
