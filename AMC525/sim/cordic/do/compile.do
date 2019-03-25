# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/nco/nco_defs.vhd \
    cordic_table.vhd \
    $vhd_dir/tune_pll/tune_pll_cordic.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -novopt -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Table" sim:/testbench/cordic/atan_table/*
add wave -group "CORDIC" sim:/testbench/cordic/*
add wave sim:*

# add wave -noupdate \
#     -childformat { \
#         {/testbench/difference.cos -radix decimal} \
#         {/testbench/difference.sin -radix decimal}} \
#     -expand -subitemconfig { \
#         /testbench/difference.cos \
#             {-format Analog-Step \
#                 -height 84 -max 2.0 -min -2.0 -radix decimal} \
#         /testbench/difference.sin \
#             {-format Analog-Step \
#                 -height 84 -max 2.0 -min -2.0 -radix decimal}} \
#     /testbench/difference

run 10us

# vim: set filetype=tcl:
