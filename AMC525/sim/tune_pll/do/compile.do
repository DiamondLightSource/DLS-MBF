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
    cordic_table.vhd \
    $vhd_dir/util/block_memory.vhd \
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/util/untimed_reg.vhd \
    $vhd_dir/system/pulse_adc_to_dsp.vhd \
    $vhd_dir/system/pulse_dsp_to_adc.vhd \
    $vhd_dir/memory/memory_fifo.vhd \
    $vhd_dir/arithmetic/rounded_product.vhd \
    $vhd_dir/dsp/dsp_defs.vhd \
    $vhd_dir/nco/nco_defs.vhd \
    nco_cos_sin_table.vhd \
    $vhd_dir/nco/nco_phase.vhd \
    $vhd_dir/nco/nco_cos_sin_prepare.vhd \
    $vhd_dir/nco/nco_cos_sin_octant.vhd \
    $vhd_dir/nco/nco_cos_sin_refine.vhd \
    $vhd_dir/nco/nco_core.vhd \
    $vhd_dir/nco/nco_delay.vhd \
    $vhd_dir/nco/nco.vhd \
    $vhd_dir/detector/detector_defs.vhd \
    $vhd_dir/detector/detector_bunch_mem.vhd \
    $vhd_dir/detector/detector_bunch_select.vhd \
    $vhd_dir/detector/detector_input.vhd \
    $vhd_dir/detector/detector_dsp96.vhd \
    $vhd_dir/detector/detector_core.vhd \
    $vhd_dir/dsp/nco_register.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/registers/all_pulsed_bits.vhd \
    $vhd_dir/registers/strobed_bits.vhd \
    $vhd_dir/tune_pll/tune_pll_defs.vhd \
    $vhd_dir/tune_pll/tune_pll_registers.vhd \
    $vhd_dir/tune_pll/tune_pll_detector.vhd \
    $vhd_dir/tune_pll/tune_pll_cordic.vhd \
    $vhd_dir/tune_pll/tune_pll_feedback.vhd \
    $vhd_dir/tune_pll/tune_pll_control.vhd \
    $vhd_dir/tune_pll/one_pole_iir.vhd \
    $vhd_dir/tune_pll/tune_pll_filtered.vhd \
    $vhd_dir/tune_pll/tune_pll_readout_registers.vhd \
    $vhd_dir/tune_pll/tune_pll_readout_fifo.vhd \
    $vhd_dir/tune_pll/tune_pll_readout.vhd \
    $vhd_dir/tune_pll/tune_pll_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/sim_resonator.vhd \
    $bench_dir/sim_noise.vhd \
    $bench_dir/testbench.vhd


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Registers" tune_pll/registers/*
add wave -group "Detector Core Cos" tune_pll/detector/detector/cos_detect/*
add wave -group "Detector Core" tune_pll/detector/detector/*
add wave -group "Detector" tune_pll/detector/*
add wave -group "CORDIC" tune_pll/cordic/*
add wave -group "Feedback" tune_pll/feedback/*
add wave -group "Control" tune_pll/control/*
add wave -group "Filtered" tune_pll/filtered/*
add wave -group "Offset FIFO" tune_pll/readout/offset_fifo/*
add wave -group "Debug FIFO" tune_pll/readout/debug_fifo/*
add wave -group "Readout" tune_pll/readout/*
add wave -group "Tune Pll" tune_pll/*
add wave sim:*

run 2us

# vim: set filetype=tcl:
