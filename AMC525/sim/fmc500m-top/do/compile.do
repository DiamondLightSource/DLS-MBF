# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/iodefs/ibuf_array.vhd \
    $vhd_dir/iodefs/ibufds_array.vhd \
    $vhd_dir/iodefs/ibufgds_array.vhd \
    $vhd_dir/iodefs/obuf_array.vhd \
    $vhd_dir/iodefs/obufds_array.vhd \
    $vhd_dir/iodefs/iobuf_array.vhd \
    $vhd_dir/iodefs/iddr_array.vhd \
    $vhd_dir/iodefs/oddr_array.vhd \
    $vhd_dir/fmc/fmc500m_defs.vhd \
    $vhd_dir/fmc/fmc500m_io.vhd \
    $vhd_dir/fmc/spi_master.vhd \
    $vhd_dir/fmc/fmc500m_spi.vhd \
    $vhd_dir/registers/register_mux_strobe.vhd \
    $vhd_dir/registers/register_mux.vhd \
    $vhd_dir/fmc/fmc500m_top.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

add wave -group "FMC" sim:/testbench/fmc500m_top_inst/*
add wave sim:*


run 4us

# vim: set filetype=tcl:
