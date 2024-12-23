# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)


# Our own local entities including device under test
vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/edge_detect.vhd \
    $vhd_dir/axi/axi_burst_master.vhd \

# The test bench
vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/interconnect_tb.vhd

# Libraries taken from generated interconnect_wrapper_elaborate.do
# Alas, we need to change wrapper to tb in this, otherwise the file should be
# executed as it stands.
vopt -64 +acc=npr -L xil_defaultlib -L xpm -L generic_baseblocks_v2_1_0 -L \
fifo_generator_v13_1_3 -L axi_data_fifo_v2_1_10 -L axi_infrastructure_v1_1_0 -L \
axi_register_slice_v2_1_11 -L axi_protocol_converter_v2_1_11 -L \
axi_clock_converter_v2_1_10 -L blk_mem_gen_v8_3_5 -L \
axi_dwidth_converter_v2_1_11 -L unisims_ver -L unimacro_ver -L secureip -work \
xil_defaultlib xil_defaultlib.interconnect_tb xil_defaultlib.glbl -o \
interconnect_tb_opt


vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2016.4/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib interconnect_tb_opt

view wave

add wave -group "Top" sim:*
add wave -group "Master" sim:/interconnect_tb/axi_burst_master_inst/*
add wave -group "BFM" sim:/interconnect_tb/interconnect_i/cdn_axi_bfm_0/*

run 800 ns

# vim: set filetype=tcl:
