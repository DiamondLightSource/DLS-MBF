# Open project or create if necessary.
if [file isfile amc525_lmbf/amc525_lmbf.xpr] {
    open_project amc525_lmbf/amc525_lmbf.xpr
} else {
    create_project -force amc525_lmbf amc525_lmbf -part xc7vx690tffg1761-2
}


set_property target_language VHDL [current_project]
set_msg_config -severity "CRITICAL WARNING" -new_severity ERROR


# Ensure we've read the block design and generated the associated files.
read_bd -quiet bd/interconnect.bd
generate_target all [get_files bd/interconnect.bd]

# Add the built files
add_files built
read_xdc built/top_pins.xdc
add_files bd/hdl/interconnect_wrapper.vhd

# Add the remaining definition files
add_files vhd

# Report IP Status before starting P&R
report_ip_status


# run synthesis, report utilization and timing estimates, write checkpoint
#
synth_design -top top -flatten_hierarchy rebuilt
write_checkpoint -force checkpoints/post_synth
report_timing_summary -file reports/post_synth_timing_summary.rpt


# run placement and logic optimzation, report utilization and timing estimates,
#
opt_design
place_design
phys_opt_design
write_checkpoint -force checkpoints/post_place
report_timing_summary -file reports/post_place_timing_summary.rpt
write_debug_probes -force amc525_lmbf.ltx


# run router, report actual utilization and timing, write checkpoint
# design, run drc, write verilog and xdc out
#
route_design

write_checkpoint -force checkpoints/amc525_top_routed.dcp
report_utilization -file reports/amc525_top_routed.rpt

set timingreport [ \
    report_timing_summary -no_header -no_detailed_paths -return_string \
        -file reports/amc525_top_timing.rpt ]

if {! [string match -nocase {*timing constraints are met*} $timingreport]} {
    send_msg_id showstopper-0 error "Timing constraints weren't met."
    return -code error
}


# generate a bitstream
#
write_bitstream -force amc525_lmbf.bit
