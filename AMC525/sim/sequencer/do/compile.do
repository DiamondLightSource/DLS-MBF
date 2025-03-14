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
    $vhd_dir/util/untimed_reg.vhd \
    $vhd_dir/util/block_memory.vhd \
    $vhd_dir/system/pulse_adc_to_dsp.vhd \
    $vhd_dir/system/pulse_dsp_to_adc.vhd \
    $vhd_dir/nco/nco_defs.vhd \
    nco_cos_sin_table.vhd \
    $vhd_dir/nco/nco_phase.vhd \
    $vhd_dir/nco/nco_cos_sin_prepare.vhd \
    $vhd_dir/nco/nco_cos_sin_octant.vhd \
    $vhd_dir/nco/nco_cos_sin_refine.vhd \
    $vhd_dir/nco/nco_core.vhd \
    $vhd_dir/nco/nco_delay.vhd \
    $vhd_dir/nco/nco.vhd \
    $vhd_dir/dsp/dsp_defs.vhd \
    $vhd_dir/tune_pll/tune_pll_offset.vhd \
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
    $vhd_dir/sequencer/sequencer_nco.vhd \
    $vhd_dir/sequencer/sequencer_delays.vhd \
    $vhd_dir/sequencer/sequencer_clocking.vhd \
    $vhd_dir/sequencer/sequencer_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/testbench.vhd


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Registers" sim:sequencer/registers/*
add wave -group "Super" sim:sequencer/super/*
add wave -group "PC" sim:sequencer/pc/*
add wave -group "Load State" sim:sequencer/load_state/*
add wave -group "Dwell" sim:sequencer/dwell/*
add wave -group "Counter" sim:sequencer/counter/*
add wave -group "Window" sim:sequencer/window/*
add wave -group "Delays" sim:sequencer/delays/*
add wave -group "Clocking" sim:sequencer/clocking/*
add wave -group "Sequencer" sim:sequencer/*
add wave -group "Bench" sim:*


run 8 us

# vim: set filetype=tcl:
