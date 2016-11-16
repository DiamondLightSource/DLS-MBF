# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/sync_reset.vhd \
    $vhd_dir/util/untimed_reg.vhd \
    $vhd_dir/util/edge_detect.vhd \
    $vhd_dir/util/short_delay.vhd \
    $vhd_dir/registers/pulsed_bits.vhd \
    $vhd_dir/registers/strobed_bits.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/registers/register_block.vhd \
    $vhd_dir/adc_phase.vhd \
    $vhd_dir/extract_signed.vhd \
    $vhd_dir/fir/fast_fir.vhd \
    $vhd_dir/fir/fast_fir_top.vhd \
    $vhd_dir/min_max_sum/min_max_sum_defs.vhd \
    $vhd_dir/min_max_sum/min_max_sum_memory.vhd \
    $vhd_dir/min_max_sum/min_max_sum_store.vhd \
    $vhd_dir/min_max_sum/min_max_sum_update.vhd \
    $vhd_dir/min_max_sum/min_max_sum_readout.vhd \
    $vhd_dir/min_max_sum/min_max_sum_bank.vhd \
    $vhd_dir/min_max_sum/min_max_sum.vhd \
    $vhd_dir/min_max_sum/min_max_limit.vhd \
    $vhd_dir/dsp/pulse_adc_to_dsp.vhd \
    $vhd_dir/dsp/adc_overflow.vhd \
    $vhd_dir/dsp/adc_to_dsp.vhd \
    $vhd_dir/dsp/dsp_to_adc.vhd \
    $vhd_dir/dsp/adc_top.vhd \
    $vhd_dir/dsp/dsp_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/testbench.vhd


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

add wave -group "ADC Phase" sim:/testbench/adc_phase_inst/*
add wave -group "ADC Top" sim:/testbench/dsp_top_inst/adc_top_inst/*
add wave -group "FIR Top" \
    sim:/testbench/dsp_top_inst/adc_top_inst/fast_fir_inst/*
add wave -group "Delay" \
    sim:/testbench/dsp_top_inst/adc_top_inst/adc_delay_inst/*
add wave -group "DSP" sim:/testbench/dsp_top_inst/*
add wave -group "Top" sim:*

run 200ns

# vim: set filetype=tcl:
