# Used to edit an existing block design
open_project edit_bd/edit_bd.xpr
set_property target_language Verilog [current_project]
open_bd_design interconnect/interconnect.bd
validate_bd_design
