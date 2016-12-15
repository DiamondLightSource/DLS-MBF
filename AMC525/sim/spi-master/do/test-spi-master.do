# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/fmc/spi_master.vhd

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/test_spi_master.vhd


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib test_spi_master

view wave

# add wave sim:*
add wave sim:/test_spi_master/spi_master_inst/*

run 700ns

# vim: set filetype=tcl:
