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
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/registers/strobed_bits.vhd \
    $vhd_dir/registers/all_pulsed_bits.vhd \
    $vhd_dir/system/adc_dsp_phase.vhd \
    $vhd_dir/system/pulse_adc_to_dsp.vhd \
    $vhd_dir/nco/nco_defs.vhd \
    $vhd_dir/nco/nco_delay.vhd \
    $vhd_dir/arithmetic/extract_signed.vhd \
    $vhd_dir/arithmetic/gain_control.vhd \
    $vhd_dir/arithmetic/rounded_product.vhd \
    $vhd_dir/memory/memory_buffer_fast.vhd \
    $vhd_dir/memory/memory_buffer_simple.vhd \
    $vhd_dir/memory/memory_buffer.vhd \
    register_defs.vhd \
    $vhd_dir/detector/detector_defs.vhd \
    $vhd_dir/detector/detector_registers.vhd \
    $vhd_dir/detector/detector_bunch_mem.vhd \
    $vhd_dir/detector/detector_bunch_select.vhd \
    $vhd_dir/detector/detector_dsp96.vhd \
    $vhd_dir/detector/detector_core.vhd \
    $vhd_dir/detector/detector_output.vhd \
    $vhd_dir/detector/detector_body.vhd \
    $vhd_dir/detector/detector_input.vhd \
    $vhd_dir/detector/detector_dram_output.vhd \
    $vhd_dir/detector/detector_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/testbench.vhd \


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Input" sim:detector/detector_input/*
add wave -group "Body(0) Bunch Mem" \
    sim:detector/detectors(0)/detector_body/bunch_select/bunch_mem/*
add wave -group "Body(0) Bunch" \
    sim:detector/detectors(0)/detector_body/bunch_select/*
add wave -group "Body(0) Core" \
    sim:detector/detectors(0)/detector_body/detector/*
add wave -group "Body(0) Output" \
    sim:detector/detectors(0)/detector_body/output/*
add wave -group "Body(0)" sim:detector/detectors(0)/detector_body/*
add wave -group "DRAM" sim:/testbench/detector/dram_output/*
add wave -group "Top" sim:/testbench/detector/*
add wave sim:*


run 200 ns

# vim: set filetype=tcl:
