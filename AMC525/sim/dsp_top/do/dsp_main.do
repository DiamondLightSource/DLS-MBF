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
    $vhd_dir/dsp/dsp_control_mux.vhd \
    $vhd_dir/dsp/dsp_control_top.vhd \
    $vhd_dir/dsp/dsp_main.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/clock_support.vhd \
    $bench_dir/test_dsp_main.vhd

vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

set dsp_main sim:/testbench/dsp_main_inst
set dsp0_top $dsp_main/dsp_gen(0)/dsp_top_inst
set dsp1_top $dsp_main/dsp_gen(1)/dsp_top_inst

add wave -group "DSP Main" $dsp_main/*
add wave -group "DSP(1)" $dsp1_top/*
add wave -group "DSP(1) DAC" $dsp1_top/dac_top_inst/*
add wave -group "DSP(1) FIR Top" $dsp1_top/bunch_fir_top_inst/*
add wave -group "DSP(1) FIR" \
    $dsp1_top/bunch_fir_top_inst/lanes_gen(0)/fir_inst/*
add wave -group "Top" sim:*

add wave -group "MMS" $dsp1_top/dac_top_inst/min_max_sum_inst/*
add wave -group "MMS Store" \
    $dsp1_top/dac_top_inst/min_max_sum_inst/min_max_sum_store_inst/*
add wave -group "MMS Memory" \
    $dsp1_top/dac_top_inst/min_max_sum_inst/min_max_sum_store_inst/mem_gen(0)/memory_inst/*
add wave -group "MMS Update" \
    $dsp1_top/dac_top_inst/min_max_sum_inst/update_gen(0)/min_max_sum_update_inst/*

run 100 ns

# run 1 us

# vim: set filetype=tcl:
