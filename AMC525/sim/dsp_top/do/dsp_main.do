do compile.do

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/registers/register_mux_strobe.vhd \
    $vhd_dir/registers/register_mux.vhd \
    $vhd_dir/memory/memory_fifo.vhd \
    $vhd_dir/memory/memory_mux_priority.vhd \
    $vhd_dir/memory/fast_memory_control.vhd \
    $vhd_dir/memory/fast_memory_pipeline.vhd \
    $vhd_dir/memory/fast_memory_data_mux.vhd \
    $vhd_dir/memory/fast_memory_top.vhd \
    $vhd_dir/trigger/trigger_defs.vhd \
    $vhd_dir/trigger/trigger_registers.vhd \
    $vhd_dir/trigger/trigger_condition.vhd \
    $vhd_dir/trigger/trigger_setup.vhd \
    $vhd_dir/trigger/trigger_turn_clock.vhd \
    $vhd_dir/trigger/trigger_blanking.vhd \
    $vhd_dir/trigger/trigger_handler.vhd \
    $vhd_dir/trigger/trigger_target.vhd \
    $vhd_dir/trigger/trigger_phase.vhd \
    $vhd_dir/trigger/trigger_top.vhd \
    $vhd_dir/util/stretch_pulse.vhd \
    $vhd_dir/dsp/dsp_control_mux.vhd \
    $vhd_dir/dsp/dsp_interrupts.vhd \
    $vhd_dir/dsp/dsp_control_top.vhd \
    $vhd_dir/dsp/dsp_main.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/test_dsp_main.vhd

# Add -novopt to prevent optimisation from deleting things
vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

set dsp_main sim:dsp_main_inst
set ctrl_top $dsp_main/dsp_control_top
set dsp0_top $dsp_main/dsp_gen(0)/dsp_top
set dsp1_top $dsp_main/dsp_gen(1)/dsp_top

add wave -group "DSP Main" $dsp_main/*
add wave -group "Ctrl Top" $ctrl_top/*
add wave -group "Fast Mem Top" $ctrl_top/fast_memory_top/*
add wave -group "Fast Mem Ctrl" $ctrl_top/fast_memory_top/fast_memory_control/*
# add wave -group "Trigger Top" $ctrl_top/trigger_inst/*
# add wave -group "Trigger Registers" \
#     $ctrl_top/trigger_inst/trigger_registers_inst/*
# add wave -group "Trigger Pulsed" \
#     $ctrl_top/trigger_inst/trigger_registers_inst/pulsed_bits_inst/*
# add wave -group "Turn Clock" $ctrl_top/trigger_inst/turn_clock_inst/*
# add wave -group "Trigger DRAM" $ctrl_top/trigger_inst/dram0_trigger_inst/*
# add wave -group "Trigger handler DRAM" \
#     $ctrl_top/trigger_inst/dram0_trigger_inst/trigger_handler/*
# add wave -group "DSP(1)" $dsp1_top/*
# add wave -group "DSP(1) Fir" $dsp1_top/bunch_fir_top_inst/*
# add wave -group "DSP(1) Seq" $dsp1_top/sequencer_top_inst/*
# add wave -group "DSP(0) Seq" $dsp0_top/sequencer_top_inst/*
# add wave -group "DSP(0) Seq Sup" $dsp0_top/sequencer_top_inst/sequencer_super/*

add wave *

run 1 us

# vim: set filetype=tcl:
