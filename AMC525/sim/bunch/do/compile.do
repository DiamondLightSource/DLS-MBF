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
    $vhd_dir/util/untimed_reg.vhd \
    $vhd_dir/util/block_memory.vhd \
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/bunch/bunch_defs.vhd \
    $vhd_dir/bunch/bunch_counter.vhd \
    $vhd_dir/bunch/bunch_store.vhd \
    $vhd_dir/bunch/bunch_select.vhd \
    $vhd_dir/bunch_fir/bunch_fir_taps.vhd \
    $vhd_dir/bunch_fir/bunch_fir_counter.vhd \
    $vhd_dir/bunch_fir/bunch_fir_delay.vhd \
    $vhd_dir/bunch_fir/bunch_fir_decimate.vhd \
    $vhd_dir/bunch_fir/bunch_fir_interpolate.vhd \
    $vhd_dir/bunch_fir/bunch_fir.vhd \
    $vhd_dir/bunch_fir/bunch_fir_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_support.vhd \
    $bench_dir/testbench.vhd \


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Bunch" bunch_select/*
add wave -group "FIR Taps" bunch_fir_top/bunch_fir_taps/*
add wave -group "FIR Counter" bunch_fir_top/counter/*
add wave -group "FIR Decimate" bunch_fir_top/decimate/*
add wave -group "FIR Interp" bunch_fir_top/interpolate/*
add wave -group "FIR" bunch_fir_top/bunch_fir/*
add wave -group "FIR Top" bunch_fir_top/*
add wave sim:*


run 1000 ns

# vim: set filetype=tcl:
