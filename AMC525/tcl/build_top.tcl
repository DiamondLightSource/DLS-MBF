set src_dir [lindex $argv 0]
set hierarchy rebuilt
# set hierarchy none

# We put the timing check here so that at the point of call we don't have the
# error message visible to us.
proc check_timing {timingreport} {
    if {! [string match -nocase {*timing constraints are met*} $timingreport]} {
        send_msg_id showstopper-0 error "Timing constraints weren't met."
        return -code error
    }
}

create_project -force amc525_lmbf amc525_lmbf -part xc7vx690tffg1761-2

set_param project.enableVHDL2008 1
set_property target_language VHDL [current_project]
set_msg_config -severity "CRITICAL WARNING" -new_severity ERROR

# Ensure undriven pins are treated as errors
set_msg_config -id "Synth 8-3295" -new_severity ERROR
set_msg_config -id "Synth 8-3848" -new_severity ERROR


# Add our files and set them to VHDL 2008.  This needs to be done before reading
# any externally generated files, particularly the interconnect.
add_files built
add_files $src_dir/vhd
set_property FILE_TYPE "VHDL 2008" [get_files *.vhd]

# It turns out that some files need to be set to plain VHDL
set_property FILE_TYPE VHDL [get_files block_memory.vhd]


# Ensure we've read the block design and generated the associated files.
read_bd interconnect/interconnect.bd
add_files interconnect/hdl/interconnect_wrapper.vhd

# Load the constraints
read_xdc built/top_pins.xdc
read_xdc $src_dir/constr/clocks.xdc


# Report IP Status before starting P&R
report_ip_status


# run synthesis, report utilization and timing estimates, write checkpoint
#
synth_design -top top -flatten_hierarchy $hierarchy -assert
write_checkpoint -force checkpoints/post_synth
report_timing_summary -file reports/post_synth_timing_summary.rpt


# run placement and logic optimzation, report utilization and timing estimates,
#
opt_design
# place_design
place_design -directive ExtraTimingOpt
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

# generate a bitstream, even if timing failed
#
write_bitstream -force amc525_lmbf.bit

# Finally check that we met timing.
check_timing $timingreport
