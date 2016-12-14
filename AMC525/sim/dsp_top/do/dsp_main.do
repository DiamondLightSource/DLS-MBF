do compile.do

vcom -64 -2008 -work xil_defaultlib \
    $vhd_dir/registers/register_mux_strobe.vhd \
    $vhd_dir/registers/register_mux.vhd \
    $vhd_dir/memory/slow_memory_fifo.vhd \
    $vhd_dir/memory/slow_memory_priority.vhd \
    $vhd_dir/memory/slow_memory_top.vhd \
    $vhd_dir/memory/fast_memory_control.vhd \
    $vhd_dir/memory/fast_memory_mux.vhd \
    $vhd_dir/memory/fast_memory_top.vhd \
    $vhd_dir/dsp/dsp_control_mux.vhd \
    $vhd_dir/dsp/dsp_control_top.vhd \
    $vhd_dir/dsp/dsp_main.vhd \

vcom -64 -2008 -work xil_defaultlib \
    $bench_dir/clock_support.vhd \
    $bench_dir/test_dsp_main.vhd

vsim -t 1ps \
    -pli "/dls_sw/FPGA/Xilinx/Vivado/2015.1/lib/lnx64.o/libxil_vsim.so" \
    -lib xil_defaultlib testbench

view wave

add wave -group "Top" sim:*

run 100 ns

# run 1 us

# vim: set filetype=tcl:
