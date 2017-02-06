do compile.do

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/registers/register_mux_strobe.vhd \
    $vhd_dir/registers/register_mux.vhd \
    $vhd_dir/memory/slow_memory_fifo.vhd \
    $vhd_dir/memory/slow_memory_priority.vhd \
    $vhd_dir/memory/slow_memory_top.vhd \
    $vhd_dir/memory/fast_memory_control.vhd \
    $vhd_dir/memory/fast_memory_mux.vhd \
    $vhd_dir/memory/fast_memory_top.vhd \
    $vhd_dir/triggers/triggers_condition.vhd \
    $vhd_dir/triggers/triggers_turn_clock.vhd \
    $vhd_dir/triggers/triggers_top.vhd \
    $vhd_dir/dsp/dsp_control_mux.vhd \
    $vhd_dir/dsp/dsp_control_top.vhd \
    $vhd_dir/dsp/dsp_main.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/clock_support.vhd \
    $bench_dir/test_dsp_main.vhd

# Add -vopt to prevent optimisation
vsim -t 1ps -lib xil_defaultlib testbench

view wave

set dsp_main sim:/testbench/dsp_main_inst
set ctrl_top $dsp_main/dsp_control_top_inst
set dsp0_top $dsp_main/dsp_gen(0)/dsp_top_inst
set dsp1_top $dsp_main/dsp_gen(1)/dsp_top_inst

add wave -group "DSP Main" $dsp_main/*
add wave -group "Ctrl Top" $ctrl_top/*
add wave -group "Triggers Top" $ctrl_top/triggers_inst/*
add wave -group "Turn Clock" $ctrl_top/triggers_inst/turn_clock_inst/*
add wave -group "DSP(1)" $dsp1_top/*
add wave -group "Fast Mem" $dsp_main/dsp_control_top_inst/fast_memory_top_inst/*
add wave -group "DSP(1) Fir" $dsp1_top/bunch_fir_top_inst/*
add wave -group "Top" *

run 1 us

# vim: set filetype=tcl:
