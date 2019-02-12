# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/util/block_memory.vhd \
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/util/untimed_reg.vhd \
    $vhd_dir/system/pulse_adc_to_dsp.vhd \
    $vhd_dir/arithmetic/rounded_product.vhd \
    $vhd_dir/nco/nco_defs.vhd \
    $vhd_dir/detector/detector_defs.vhd \
    $vhd_dir/detector/detector_bunch_mem.vhd \
    $vhd_dir/detector/detector_bunch_select.vhd \
    $vhd_dir/detector/detector_input.vhd \
    $vhd_dir/detector/detector_dsp96.vhd \
    $vhd_dir/detector/detector_core.vhd \
    register_defs.vhd \
    $vhd_dir/dsp/nco_register.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/registers/all_pulsed_bits.vhd \
    $vhd_dir/registers/strobed_bits.vhd \
    $vhd_dir/tune_pll/tune_pll_registers.vhd \
    $vhd_dir/tune_pll/tune_pll_detector.vhd \
    cordic_table.vhd \
    $vhd_dir/tune_pll/tune_pll_cordic.vhd \
    $vhd_dir/tune_pll/tune_pll_feedback.vhd \
    $vhd_dir/tune_pll/tune_pll_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/sim_nco.vhd \
    $bench_dir/testbench.vhd


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Registers" tune_pll/registers/*
add wave -group "Detector" tune_pll/detector/*
add wave -group "CORDIC" tune_pll/cordic/*
add wave -group "Feedback" tune_pll/feedback/*
add wave -group "Tune Pll" tune_pll/*
add wave sim:*

run 10ns

# vim: set filetype=tcl:
