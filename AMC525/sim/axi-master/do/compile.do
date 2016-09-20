# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)


# Our own local entities including device under test
vcom -64 -93 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/edge_detect.vhd \
    $vhd_dir/axi_burst_master.vhd \
    $vhd_dir/adc_dram_capture.vhd

# The test bench
vcom -64 -93 -work xil_defaultlib \
    $bench_dir/interconnect_tb.vhd

# Libraries taken from generated interconnect_wrapper_elaborate.do
vopt -64 +acc -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -L \
    generic_baseblocks_v2_1 -L fifo_generator_v12_0 -L axi_data_fifo_v2_1 -L \
    axi_infrastructure_v1_1 -L axi_register_slice_v2_1 -L \
    axi_protocol_converter_v2_1 -L axi_clock_converter_v2_1 \
    -L blk_mem_gen_v8_2 -L \
    axi_dwidth_converter_v2_1 -work xil_defaultlib \
    xil_defaultlib.interconnect_tb xil_defaultlib.glbl -o interconnect_tb_opt

vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib interconnect_tb_opt

view wave

add wave -group "Top" sim:*
add wave -group "ADC Mem" sim:/interconnect_tb/adc_dram_capture_inst/*
add wave sim:/interconnect_tb/axi_burst_master_inst/*

run 1us

# vim: set filetype=tcl:
