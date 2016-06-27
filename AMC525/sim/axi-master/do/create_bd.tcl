# Loads a block design from script, creating a new project as necessary.

set bd_name   [lindex $argv 0]
set bd_script [lindex $argv 1]

create_project -force $bd_name $bd_name -part xc7vx690tffg1761-2
set_property target_simulator Questa [current_project]
set_property target_language VHDL [current_project]

source $bd_script

# Internal source directory needed for building simulation
set src_dir interconnect/interconnect.srcs/sources_1/bd/interconnect

open_bd_design $src_dir/interconnect.bd
generate_target all [get_files $src_dir/interconnect.bd]
make_wrapper -files [get_files $src_dir/interconnect.bd] -top
add_files -norecurse $src_dir/hdl/interconnect_wrapper.vhd
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Builds the simulation scripts
launch_simulation -scripts_only
