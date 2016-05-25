# Used to edit an existing block design

# Call this function to save the block design
proc save_bd {} {
    global argv
    validate_bd_design
    write_bd_tcl -bd_folder . -exclude_layout -force [lindex $argv 0]
    save_bd_design
}

open_project edit_bd/edit_bd.xpr
set_property target_language Verilog [current_project]
open_bd_design interconnect/interconnect.bd
start_gui
# Rather odd: to actually get the design up on the screen, we need to open it
# again!  It still makes sense to do the first open, as that's already done all
# the hard work of bringing the design into memory.
open_bd_design interconnect/interconnect.bd
