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
    $vhd_dir/system/adc_dsp_phase.vhd \
    $vhd_dir/nco/nco_defs.vhd \
    $vhd_dir/registers/strobed_bits.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/sequencer/sequencer_defs.vhd \
    $vhd_dir/sequencer/sequencer_registers.vhd \
    $vhd_dir/sequencer/sequencer_super.vhd \
    $vhd_dir/sequencer/sequencer_pc.vhd \
    $vhd_dir/sequencer/sequencer_load_state.vhd \
    $vhd_dir/sequencer/sequencer_dwell.vhd \
    $vhd_dir/sequencer/sequencer_counter.vhd \
    $vhd_dir/sequencer/sequencer_window.vhd \
    $vhd_dir/sequencer/sequencer_delays.vhd \
    $vhd_dir/sequencer/sequencer_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/testbench.vhd


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Sequencer" sim:/testbench/sequencer/*
add wave sim:*


run 100 ns

# vim: set filetype=tcl:
