# Used to edit an existing block design
open_project edit_bd/edit_bd.xpr
set_property target_language Verilog [current_project]
open_bd_design interconnect/interconnect.bd
start_gui
# Rather odd: to actually get the design up on the screen, we need to open it
# again!  It still makes sense to do the first open, as that's already done all
# the hard work of bringing the design into memory.
open_bd_design interconnect/interconnect.bd
