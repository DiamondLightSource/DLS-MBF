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
    $vhd_dir/nco/nco_defs.vhd \
    nco_cos_sin_table.vhd \
    $vhd_dir/nco/nco_phase.vhd \
    $vhd_dir/nco/nco_cos_sin_prepare.vhd \
    $vhd_dir/nco/nco_cos_sin_octant.vhd \
    $vhd_dir/nco/nco_cos_sin_refine.vhd \
    $vhd_dir/nco/nco_core.vhd \
    $vhd_dir/nco/nco_delay.vhd \
    $vhd_dir/nco/nco.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/sim_nco.vhd \
    $bench_dir/testbench.vhd


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Prepare" sim:/testbench/nco/prepare/*
add wave -group "Refine" sim:/testbench/nco/refine/*
add wave -group "Fixup" sim:/testbench/nco/fixup_octant/*
add wave -group "NCO" sim:/testbench/nco/*
add wave sim:*

add wave -noupdate \
    -childformat { \
        {/testbench/difference.cos -radix decimal} \
        {/testbench/difference.sin -radix decimal}} \
    -expand -subitemconfig { \
        /testbench/difference.cos \
            {-format Analog-Step \
                -height 84 -max 2.0 -min -2.0 -radix decimal} \
        /testbench/difference.sin \
            {-format Analog-Step \
                -height 84 -max 2.0 -min -2.0 -radix decimal}} \
    /testbench/difference

run 2us

# vim: set filetype=tcl:
