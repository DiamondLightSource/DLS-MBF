# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -93 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/spi_master.vhd

vcom -64 -93 -work xil_defaultlib \
    $bench_dir/testbench.vhd


# compile glbl module
vlog -work xil_defaultlib $bench_dir/glbl.v

vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

# add wave sim:*
add wave sim:/testbench/spi_master_inst/*

run 700ns

# vim: set filetype=tcl:
