# Used to edit an existing block design

# Call this function to save the block design
proc save_bd {} {
    global argv
    validate_bd_design
    write_bd_tcl -bd_folder . -force [lindex $argv 0]
    save_bd_design
}

open_project edit_bd/edit_bd.xpr
set_property target_language Verilog [current_project]
start_gui
# We have do this after starting the gui!
open_bd_design interconnect/interconnect.bd
