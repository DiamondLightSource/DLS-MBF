# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -93 -work xil_defaultlib \
    $vhd_dir/support.vhd

vcom -64 -93 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

add wave -group "Top" sim:*
add wave sim:*
# add wave sim:/testbench/axi_burst_master_inst/*


run 1us

# vim: set filetype=tcl:
