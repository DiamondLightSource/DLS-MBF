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
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/util/sync_bit.vhd \
    $vhd_dir/util/edge_detect.vhd \
    $vhd_dir/system/adc_dsp_phase.vhd \
    $vhd_dir/registers/strobed_bits.vhd \
    $vhd_dir/registers/all_pulsed_bits.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/trigger/trigger_defs.vhd \
    $vhd_dir/trigger/trigger_registers.vhd \
    $vhd_dir/trigger/trigger_condition.vhd \
    $vhd_dir/trigger/trigger_setup.vhd \
    $vhd_dir/trigger/trigger_turn_clock.vhd \
    $vhd_dir/trigger/trigger_blanking.vhd \
    $vhd_dir/trigger/trigger_handler.vhd \
    $vhd_dir/trigger/trigger_sources.vhd \
    $vhd_dir/trigger/trigger_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/testbench.vhd


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Triggers" sim:/testbench/triggers/*
add wave sim:*


run 100 ns

# vim: set filetype=tcl:
