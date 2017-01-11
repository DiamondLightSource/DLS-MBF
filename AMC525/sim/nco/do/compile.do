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
    $vhd_dir/nco/nco_defs.vhd \
    nco_cos_sin_table.vhd \
    $vhd_dir/nco/nco_phase.vhd \
    $vhd_dir/nco/nco_cos_sin_octant.vhd \
    $vhd_dir/nco/nco_cos_sin_refine.vhd \
    $vhd_dir/nco/nco_scaling.vhd \
    $vhd_dir/nco/nco.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Top" sim:*
add wave -group "NCO" sim:/testbench/nco_inst/*
add wave -group "Refine" sim:/testbench/nco_inst/nco_gen(0)/refine_inst/*
add wave sim:*


run 1us

# vim: set filetype=tcl:
