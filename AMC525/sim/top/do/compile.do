# Paths from environment
set vhd_dir $env(VHD_DIR)
set bench_dir $env(BENCH_DIR)

vlib work
vlib msim
vlib msim/xil_defaultlib

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/support.vhd \
    $vhd_dir/defines.vhd \
    register_defs.vhd \
    $bench_dir/interconnect_wrapper.vhd \
    $bench_dir/dsp_main.vhd \
    top_entity.vhd \
    $vhd_dir/iodefs/ibuf_array.vhd \
    $vhd_dir/iodefs/ibufgds_array.vhd \
    $vhd_dir/iodefs/obuf_array.vhd \
    $vhd_dir/iodefs/ibufds_array.vhd \
    $vhd_dir/iodefs/iddr_array.vhd \
    $vhd_dir/iodefs/obufds_array.vhd \
    $vhd_dir/iodefs/ibufds_gte2_array.vhd \
    $vhd_dir/iodefs/iobuf_array.vhd \
    $vhd_dir/iodefs/oddr_array.vhd \
    $vhd_dir/fmc/fmc500m_defs.vhd \
    $vhd_dir/fmc/fmc500m_io.vhd \
    $vhd_dir/fmc/spi_master.vhd \
    $vhd_dir/fmc/fmc500m_spi.vhd \
    $vhd_dir/fmc/fmc500m_top.vhd \
    $vhd_dir/fmc/fmc_digital_io.vhd \
    $vhd_dir/nco/nco_defs.vhd \
    $vhd_dir/dsp/dsp_defs.vhd \
    $vhd_dir/util/dlyreg.vhd \
    $vhd_dir/util/dlyline.vhd \
    $vhd_dir/util/sync_reset.vhd \
    $vhd_dir/util/sync_bit.vhd \
    $vhd_dir/util/edge_detect.vhd \
    $vhd_dir/util/untimed_reg.vhd \
    $vhd_dir/registers/register_mux_strobe.vhd \
    $vhd_dir/registers/register_mux.vhd \
    $vhd_dir/registers/register_strobe_cc.vhd \
    $vhd_dir/registers/register_cc.vhd \
    $vhd_dir/registers/register_file.vhd \
    $vhd_dir/system/adc_dsp_phase.vhd \
    $vhd_dir/system/dac_test_pattern.vhd \
    $vhd_dir/system/idelay_control.vhd \
    $vhd_dir/system/clocking.vhd \
    $vhd_dir/system/register_top.vhd \
    $vhd_dir/system/system_registers.vhd \
    $vhd_dir/axi/axi_burst_master.vhd \
    $vhd_dir/axi/axi_lite_master.vhd \
    $vhd_dir/axi/axi_lite_slave.vhd \
    $vhd_dir/top_arch.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/testbench.vhd


vsim -t 1ps -lib xil_defaultlib testbench

view wave

add wave -group "Top" sim:/testbench/top/*
add wave sim:*
# add wave sim:/testbench/axi_burst_master_inst/*


run 500 ns

# vim: set filetype=tcl:
