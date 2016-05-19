open_project edit_bd/edit_bd.xpr
open_bd_design interconnect/interconnect.bd
validate_bd_design
write_bd_tcl -bd_folder . -exclude_layout -force [lindex $argv 0]
