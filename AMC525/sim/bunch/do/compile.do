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
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/bunch/bunch_defs.vhd \
    $vhd_dir/bunch/bunch_counter.vhd \
    $vhd_dir/bunch/bunch_store.vhd \
    $vhd_dir/bunch/bunch_select.vhd \
    $vhd_dir/bunch_fir/bunch_fir_taps.vhd \
    $vhd_dir/bunch_fir/bunch_fir_counter.vhd \
    $vhd_dir/bunch_fir/bunch_fir_delay.vhd \
    $vhd_dir/bunch_fir/bunch_fir_decimate.vhd \
    $vhd_dir/bunch_fir/bunch_fir_interpolate.vhd \
    $vhd_dir/bunch_fir/bunch_fir.vhd \
    $vhd_dir/bunch_fir/bunch_fir_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/testbench.vhd \


vsim -t 1ps -lib xil_defaultlib testbench

view wave

# add wave -group "MMS" sim:/testbench/min_max_sum_inst/*

add wave -group "Bunch" sim:/testbench/bunch_select_inst/*
add wave -group "FIR Taps" sim:/testbench/bunch_fir_inst/bunch_fir_taps_inst/*
add wave -group "FIR Counter" \
    sim:/testbench/bunch_fir_inst/bunch_fir_counter_inst/*
add wave -group "FIR Decimate" \
    sim:/testbench/bunch_fir_inst/lanes_gen(0)/decimate_inst/*
add wave -group "FIR Interp" \
    sim:/testbench/bunch_fir_inst/lanes_gen(0)/interpolate_inst/*
add wave -group "FIR" \
    sim:/testbench/bunch_fir_inst/lanes_gen(0)/fir_inst/*
add wave -group "FIR Top" sim:/testbench/bunch_fir_inst/*
add wave -group "Top" sim:*
# add wave sim:*


run 1000 ns

# vim: set filetype=tcl:
