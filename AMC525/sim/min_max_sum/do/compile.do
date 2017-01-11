# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/util/sync_reset.vhd \
    $vhd_dir/util/edge_detect.vhd \
    $vhd_dir/util/block_memory.vhd \
    $vhd_dir/system/adc_phase.vhd \
    $vhd_dir/dsp/adc_to_dsp.vhd \
    $vhd_dir/min_max_sum/min_max_sum_defs.vhd \
    $vhd_dir/min_max_sum/min_max_sum_bank.vhd \
    $vhd_dir/min_max_sum/min_max_sum_memory.vhd \
    $vhd_dir/min_max_sum/min_max_sum_store.vhd \
    $vhd_dir/min_max_sum/min_max_sum_update.vhd \
    $vhd_dir/min_max_sum/min_max_sum_readout.vhd \
    $vhd_dir/min_max_sum/min_max_sum.vhd \
    $vhd_dir/min_max_sum/min_max_limit.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/clocks.vhd \
    $bench_dir/testbench.vhd \


vsim -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "MMS" sim:/testbench/min_max_sum_inst/*
add wave -group "Bank" sim:/testbench/min_max_sum_inst/min_max_sum_bank_inst/*
add wave -group "MMS Store" \
    sim:/testbench/min_max_sum_inst/min_max_sum_store_inst/*
add wave -group "mem(0)" \
    sim:/testbench/min_max_sum_inst/min_max_sum_store_inst/mem_gen(0)/memory_inst/*
add wave -group "mem(1)" \
    sim:/testbench/min_max_sum_inst/min_max_sum_store_inst/mem_gen(1)/memory_inst/*
add wave -group "update(0)" \
    sim:/testbench/min_max_sum_inst/update_gen(0)/min_max_sum_update_inst/*
add wave -group "update(1)" \
    sim:/testbench/min_max_sum_inst/update_gen(1)/min_max_sum_update_inst/*
add wave -group "Readout" \
    sim:/testbench/min_max_sum_inst/readout_inst/*
add wave -group "Limit" sim:/testbench/min_max_limit_inst/*

add wave -group "Top" sim:*
# add wave sim:*


run 2 us

# vim: set filetype=tcl:
