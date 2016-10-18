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
    $vhd_dir/util/sync_reset.vhd \
    $vhd_dir/util/untimed_register.vhd \
    $vhd_dir/registers/strobed_bits.vhd \
    $vhd_dir/registers/strobed_bits.vhd \
    $vhd_dir/registers/register_array.vhd \
    $vhd_dir/adc_phase.vhd \
    $vhd_dir/extract_signed.vhd \
    $vhd_dir/fast_fir.vhd \
    $vhd_dir/dsp/adc_to_dsp.vhd \
    $vhd_dir/dsp/adc_fir.vhd \
    $vhd_dir/dsp/dsp_to_adc.vhd \
    $vhd_dir/dsp/dsp_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/testbench.vhd


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

add wave -group "Top" sim:*
add wave -group "DSP" sim:/testbench/dsp_top_inst/*
add wave -group "ADC FIR" sim:/testbench/dsp_top_inst/adc_fir_inst/*
add wave -group "Fast FIR" \
    sim:/testbench/dsp_top_inst/adc_fir_inst/fast_fir_inst/*
add wave sim:*

run 200ns

# vim: set filetype=tcl:
