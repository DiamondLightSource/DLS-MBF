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

create_project amc525_lmbf amc525_lmbf -part xc7vx690tffg1761-2

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


# Ensure we've read the block design and generated the associated files.
read_bd interconnect/interconnect.bd
make_wrapper -files [get_files interconnect/interconnect.bd] -top
add_files -norecurse interconnect/hdl/interconnect_wrapper.vhd

# Load the constraints
read_xdc built/top_pins.xdc
read_xdc $src_dir/constr/clocks.xdc
read_xdc $src_dir/constr/post_synth.xdc
set_property used_in_synthesis false [get_files post_synth.xdc]

read_xdc $src_dir/constr/pblocks.xdc
set_property used_in_synthesis false [get_files pblocks.xdc]


# Configure Vivado build options
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.ASSERT true [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]

launch_runs impl_1 -to_step write_bitstream -jobs 6
wait_on_run impl_1
