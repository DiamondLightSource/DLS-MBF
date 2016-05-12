# TCL script used by Vivado to perform scripted build.

read_vhdl top_entity.vhd
read_xdc top_pins.xdc
read_vhdl vhd/top_arch.vhd

synth_design -top top -part xc7vx690tffg1761-2
write_checkpoint -force post_synth.dcp

opt_design
place_design
route_design

set_property SEVERITY Warning [get_drc_checks NSTD-1]
write_bitstream -force top.bit
