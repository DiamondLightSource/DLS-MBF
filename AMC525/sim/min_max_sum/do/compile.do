# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    register_defs.vhd \
    $vhd_dir/system/pulse_adc_to_dsp.vhd \
    $vhd_dir/system/pulse_dsp_to_adc.vhd \
    $vhd_dir/system/adc_dsp_phase.vhd \
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/util/sync_reset.vhd \
    $vhd_dir/util/edge_detect.vhd \
    $vhd_dir/util/block_memory.vhd \
    $vhd_dir/registers/register_read_adc.vhd \
    $vhd_dir/min_max_sum/min_max_sum_defs.vhd \
    $vhd_dir/min_max_sum/min_max_sum_bank.vhd \
    $vhd_dir/min_max_sum/min_max_sum_memory.vhd \
    $vhd_dir/min_max_sum/min_max_sum_store.vhd \
    $vhd_dir/min_max_sum/min_max_sum_update.vhd \
    $vhd_dir/min_max_sum/min_max_sum_readout.vhd \
    $vhd_dir/min_max_sum/min_max_sum.vhd \
    $vhd_dir/min_max_sum/min_max_limit.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

set mms sim:/testbench/min_max_sum_inst

add wave -group "MMS" $mms/*
add wave -group "Bank" $mms/bank/*
add wave -group "MMS Store" $mms/store/*
add wave -group "mem(0)" $mms/store/mem_gen(0)/memory_inst/*
add wave -group "bram(0)" $mms/store/mem_gen(0)/memory_inst/bram/*
add wave -group "mem(1)" $mms/store/mem_gen(1)/memory_inst/*
add wave -group "update" $mms/update/*
add wave -group "Readout" $mms/readout_inst/*
add wave -group "Limit" sim:/testbench/min_max_limit_inst/*
add wave -group "Read" $mms/register_read_adc/*

add wave sim:*


run 4 us

# vim: set filetype=tcl:
