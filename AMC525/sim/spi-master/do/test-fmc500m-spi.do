# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/spi_master.vhd \
    $vhd_dir/fmc/fmc500m_spi.vhd

vcom -64 -93 -work xil_defaultlib \
    $bench_dir/test_fmc500m_spi.vhd


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib test_fmc500m_spi

view wave

# add wave sim:*
add wave sim:/test_fmc500m_spi/fmc500m_spi_inst/*

run 8us

# vim: set filetype=tcl:
