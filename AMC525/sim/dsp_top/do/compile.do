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
    $vhd_dir/util/block_memory.vhd \
    $vhd_dir/util/long_delay.vhd \
    $vhd_dir/registers/pulsed_bits.vhd \
    $vhd_dir/registers/strobed_bits.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/registers/register_block.vhd \
    $vhd_dir/adc_phase.vhd \
    $vhd_dir/extract_signed.vhd \
    $vhd_dir/fast_fir/fast_fir.vhd \
    $vhd_dir/fast_fir/fast_fir_top.vhd \
    $vhd_dir/min_max_sum/min_max_sum_defs.vhd \
    $vhd_dir/min_max_sum/min_max_sum_memory.vhd \
    $vhd_dir/min_max_sum/min_max_sum_store.vhd \
    $vhd_dir/min_max_sum/min_max_sum_update.vhd \
    $vhd_dir/min_max_sum/min_max_sum_readout.vhd \
    $vhd_dir/min_max_sum/min_max_sum_bank.vhd \
    $vhd_dir/min_max_sum/min_max_sum.vhd \
    $vhd_dir/min_max_sum/min_max_limit.vhd \
    $vhd_dir/bunch/bunch_defs.vhd \
    $vhd_dir/bunch/bunch_counter.vhd \
    $vhd_dir/bunch/bunch_store.vhd \
    $vhd_dir/bunch/bunch_select.vhd \
    $vhd_dir/nco/nco_defs.vhd \
    nco_cos_sin_table.vhd \
    $vhd_dir/nco/nco_phase.vhd \
    $vhd_dir/nco/nco_cos_sin_octant.vhd \
    $vhd_dir/nco/nco_cos_sin_refine.vhd \
    $vhd_dir/nco/nco.vhd \
    $vhd_dir/dsp/dsp_to_adc.vhd \
    $vhd_dir/dac/gain_control.vhd \
    $vhd_dir/dac/dac_output_mux.vhd \
    $vhd_dir/dac/dac_top.vhd \
    $vhd_dir/bunch_fir/bunch_fir_taps.vhd \
    $vhd_dir/bunch_fir/bunch_fir_counter.vhd \
    $vhd_dir/bunch_fir/bunch_fir_delay.vhd \
    $vhd_dir/bunch_fir/bunch_fir_decimate.vhd \
    $vhd_dir/bunch_fir/bunch_fir_interpolate.vhd \
    $vhd_dir/bunch_fir/bunch_fir.vhd \
    $vhd_dir/bunch_fir/bunch_fir_top.vhd \
    $vhd_dir/dsp/dsp_defs.vhd \
    $vhd_dir/dsp/dsp_registers.vhd \
    $vhd_dir/dsp/pulse_adc_to_dsp.vhd \
    $vhd_dir/dsp/adc_overflow.vhd \
    $vhd_dir/dsp/adc_to_dsp.vhd \
    $vhd_dir/dsp/adc_top.vhd \
    $vhd_dir/dsp/memory_top.vhd \
    $vhd_dir/dsp/dsp_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/testbench.vhd


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

add wave -group "ADC Phase" sim:/testbench/adc_phase_inst/*
add wave -group "Bunch" sim:/testbench/dsp_top_inst/bunch_select_inst/*
add wave -group "Bunch Mem" \
    sim:/testbench/dsp_top_inst/bunch_select_inst/bunch_mem/*
add wave -group "ADC Top" sim:/testbench/dsp_top_inst/adc_top_inst/*
add wave -group "DAC Top" sim:/testbench/dsp_top_inst/dac_top_inst/*
add wave -group "FIR Top" sim:/testbench/dsp_top_inst/bunch_fir_top_inst/*
add wave -group "Bunch FIR" \
    sim:/testbench/dsp_top_inst/bunch_fir_top_inst/lanes_gen(0)/fir_inst/*
add wave -group "Bunch FIR dly(1)" \
    sim:/testbench/dsp_top_inst/bunch_fir_top_inst/lanes_gen(0)/fir_inst/delay_gen(1)/data_delay_inst/*
add wave -group "Bunch FIR taps" \
    sim:/testbench/dsp_top_inst/bunch_fir_top_inst/bunch_fir_taps_inst/*
add wave -group "DSP Top" sim:/testbench/dsp_top_inst/*
add wave -group "Top" sim:*


run 1 us

# vim: set filetype=tcl:
