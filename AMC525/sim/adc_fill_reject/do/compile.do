# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/util/block_memory.vhd \
    $vhd_dir/bunch_fir/bunch_fir_delay.vhd \
    $vhd_dir/adc/adc_fill_reject_counter.vhd \
    $vhd_dir/adc/adc_fill_reject.vhd

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Counter" fill_reject/counter/*
add wave -group "Reject" fill_reject/*
add wave -group "Top" sim:*
add wave sim:*
# add wave sim:/testbench/axi_burst_master_inst/*


run 1us

# vim: set filetype=tcl:
